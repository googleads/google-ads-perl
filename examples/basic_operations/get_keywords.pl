#!/usr/bin/perl -w
#
# Copyright 2019, Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This example retrieves keywords for a customer or for a specific ad group and
# demonstrates how to use the omit_unselected_resource_names option in GAQL to
# reduce payload size.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use
  Google::Ads::GoogleAds::V11::Services::GoogleAdsService::SearchGoogleAdsRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

use constant PAGE_SIZE => 1000;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";
# Optional: Specify an ad group ID below to restrict search to only a given ad group.
my $ad_group_id = undef;
# Optional: Change the below value to "true" to omit unselected resource names from
# the returned response of GoogleAdsService.
my $omit_unselected_resource_names = undef;

sub get_keywords {
  my ($api_client, $customer_id, $ad_group_id, $omit_unselected_resource_names)
    = @_;

  # Create the search query.
  my $search_query =
    "SELECT ad_group.id, ad_group_criterion.type, " .
    "ad_group_criterion.criterion_id, " .
    "ad_group_criterion.keyword.text, " .
    "ad_group_criterion.keyword.match_type FROM ad_group_criterion " .
    "WHERE ad_group_criterion.type = KEYWORD";

  if (defined $ad_group_id) {
    $search_query .= " AND ad_group.id = $ad_group_id";
  }

  # Add omit_unselected_resource_names = true to the PARAMETERS clause of the
  # Google Ads Query Language (GAQL) query, which excludes the resource names of
  # all resources that aren't explicitly requested in the SELECT clause.
  # Enabling this option reduces payload size, but if you plan to use a returned
  # object in subsequent mutate operations, make sure you explicitly request its
  # "resource_name" field in the SELECT clause.
  #
  # Read more about PARAMETERS:
  # https://developers.google.com/google-ads/api/docs/query/structure#parameters
  if (defined $omit_unselected_resource_names) {
    $search_query .= " PARAMETERS omit_unselected_resource_names = true";
  }

  # Create a search Google Ads request that will retrieve all keywords using pages
  # of the specified page size.
  my $search_request =
    Google::Ads::GoogleAds::V11::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query,
      pageSize   => PAGE_SIZE
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
    service => $google_ads_service,
    request => $search_request
  });

  # Iterate over all rows in all pages and print the requested field values for
  # the keyword in each row.
  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;

    my $ad_group           = $google_ads_row->{adGroup};
    my $ad_group_criterion = $google_ads_row->{adGroupCriterion};
    my $keyword_info       = $ad_group_criterion->{keyword};
    my $resource_name_string =
      defined $omit_unselected_resource_names
      ? ""
      : sprintf " and resource name '%s'", $ad_group->{resourceName};

    printf
      "Keyword with text '%s', match type '%s', criteria type '%s', and ID %d "
      . "was found in ad group with ID %d%s.\n",
      $keyword_info->{text},
      $keyword_info->{matchType},
      $ad_group_criterion->{type},
      $ad_group_criterion->{criterionId},
      $ad_group->{id},
      $resource_name_string;
  }

  return 1;
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"                    => \$customer_id,
  "ad_group_id=i"                    => \$ad_group_id,
  "omit_unselected_resource_names=s" => \$omit_unselected_resource_names
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
get_keywords(
  $api_client,  $customer_id =~ s/-//gr,
  $ad_group_id, $omit_unselected_resource_names
);

=pod

=head1 NAME

get_keywords

=head1 DESCRIPTION

This example retrieves keywords for a customer or for a specific ad group and
demonstrates how to use the omit_unselected_resource_names option in GAQL to
reduce payload size.

=head1 SYNOPSIS

get_keywords.pl [options]

    -help                               Show the help message.
    -customer_id                        The Google Ads customer ID.
    -ad_group_id                        [optional] The ad group ID from which keywords will be retrieved.
                                        If not set, keywords from all ad groups will be returned.
    -omit_unselected_resource_names     [optional] Whether to omit the resource names of all resources
                                        not explicitly requested in the SELECT clause of the GAQL query.

=cut
