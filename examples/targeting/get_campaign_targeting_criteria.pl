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
# This example gets all campaign criteria. To add campaign criteria, run
# add_campaign_targeting_criteria.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use Google::Ads::GoogleAds::V8::Enums::CriterionTypeEnum qw(KEYWORD);
use
  Google::Ads::GoogleAds::V8::Services::GoogleAdsService::SearchGoogleAdsRequest;

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
my $campaign_id = "INSERT_CAMPAIGN_ID_HERE";

sub get_campaign_targeting_criteria {
  my ($api_client, $customer_id, $campaign_id) = @_;

  # Create a query that retrieves campaign criteria.
  my $search_query =
    "SELECT campaign.id, campaign_criterion.campaign, " .
    "campaign_criterion.criterion_id, campaign_criterion.negative, " .
    "campaign_criterion.type, campaign_criterion.keyword.text, " .
    "campaign_criterion.keyword.match_type " .
    "FROM campaign_criterion WHERE campaign.id = $campaign_id";

  # Create a search Google Ads request that will retrieve campaign criteria
  # using pages of the specified page size.
  my $search_request =
    Google::Ads::GoogleAds::V8::Services::GoogleAdsService::SearchGoogleAdsRequest
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
  # the campaign criterion in each row.
  while ($iterator->has_next) {
    my $google_ads_row     = $iterator->next;
    my $campaign_criterion = $google_ads_row->{campaignCriterion};

    printf "Campaign criterion with ID %d was found as a %s",
      $campaign_criterion->{criterionId},
      $campaign_criterion->{negative} ? "negative " : "";

    if ($campaign_criterion->{type} eq KEYWORD) {
      printf "keyword with text '%s' and match type '%s'.\n",
        $campaign_criterion->{keyword}{text},
        $campaign_criterion->{keyword}{matchType};
    } else {
      print "non-keyword.\n";
    }
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
  "customer_id=s" => \$customer_id,
  "campaign_id=i" => \$campaign_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $campaign_id);

# Call the example.
get_campaign_targeting_criteria($api_client, $customer_id =~ s/-//gr,
  $campaign_id);

=pod

=head1 NAME

get_campaign_targeting_criteria

=head1 DESCRIPTION

This example gets all campaign criteria. To add campaign criteria, run
add_campaign_targeting_criteria.pl.

=head1 SYNOPSIS

get_campaign_targeting_criteria.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.

=cut
