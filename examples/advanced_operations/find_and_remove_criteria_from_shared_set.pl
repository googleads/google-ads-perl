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
# This example demonstrates how to find shared sets, how to find shared set
# criteria, and how to remove shared set criteria.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use Google::Ads::GoogleAds::V23::Enums::CriterionTypeEnum qw(KEYWORD);
use
  Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest;
use
  Google::Ads::GoogleAds::V23::Services::SharedCriterionService::SharedCriterionOperation;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

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

sub find_and_remove_criteria_from_shared_set {
  my ($api_client, $customer_id, $campaign_id) = @_;

  my $shared_set_ids           = [];
  my $criterion_resource_names = [];

  # First, retrieve all shared sets associated with the campaign.
  my $search_query =
    "SELECT shared_set.id, shared_set.name FROM campaign_shared_set " .
    "WHERE campaign.id = $campaign_id";

  my $search_request =
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query
    });

  my $google_ads_service = $api_client->GoogleAdsService();

  my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
    service => $google_ads_service,
    request => $search_request
  });

  # Iterate over all rows in all pages and print the requested field values for
  # the shared set in each row.
  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;
    printf "Campaign shared set with ID %d and name '%s' was found.\n",
      $google_ads_row->{sharedSet}{id}, $google_ads_row->{sharedSet}{name};

    push @$shared_set_ids, $google_ads_row->{sharedSet}{id};
  }

  # Return 0 when no shared set was found for this campaign.
  if (scalar @$shared_set_ids == 0) {
    warn "Campaign shared set was not found for campaign $campaign_id.\n";
    return 0;
  }

  # Next, retrieve shared criteria for all found shared sets.
  $search_query =
    sprintf "SELECT shared_criterion.type, shared_criterion.keyword.text, " .
    "shared_criterion.keyword.match_type, shared_set.id " .
    "FROM shared_criterion WHERE shared_set.id IN (%s)",
    join(',', @$shared_set_ids);

  $search_request =
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId => $customer_id,
      query      => $search_query
    });

  $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
    service => $google_ads_service,
    request => $search_request
  });

  # Iterate over all rows in all pages and print the requested field values for
  # the shared criterion in each row.
  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;

    my $shared_criterion_resource_name =
      $google_ads_row->{sharedCriterion}{resourceName};

    if ($google_ads_row->{sharedCriterion}{type} eq KEYWORD) {
      printf "Shared criterion with resource name '%s' for negative keyword " .
        "with text '%s' and match type '%s' was found.\n",
        $shared_criterion_resource_name,
        $google_ads_row->{sharedCriterion}{keyword}{text},
        $google_ads_row->{sharedCriterion}{keyword}{matchType};
    } else {
      printf "Shared criterion with resource name '%s' was found.\n",
        $shared_criterion_resource_name;
    }

    push @$criterion_resource_names, $shared_criterion_resource_name;
  }

  # Finally, remove the criteria.
  my $shared_criterion_operations = [];
  foreach my $criterion_resource_name (@$criterion_resource_names) {
    push @$shared_criterion_operations,
      Google::Ads::GoogleAds::V23::Services::SharedCriterionService::SharedCriterionOperation
      ->new({
        remove => $criterion_resource_name
      });
  }

  # Send the operations in mutate request.
  my $shared_criteria_response = $api_client->SharedCriterionService()->mutate({
    customerId => $customer_id,
    operations => $shared_criterion_operations
  });

  foreach my $result (@{$shared_criteria_response->{results}}) {
    printf "Removed shared criterion with resource name: '%s'.\n",
      $result->{resourceName};
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
GetOptions("customer_id=s" => \$customer_id, "campaign_id=i" => \$campaign_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $campaign_id);

# Call the example.
find_and_remove_criteria_from_shared_set($api_client, $customer_id =~ s/-//gr,
  $campaign_id);

=pod

=head1 NAME

find_and_remove_criteria_from_shared_set

=head1 DESCRIPTION

This example demonstrates how to find shared sets, how to find shared set criteria,
and how to remove shared set criteria.

=head1 SYNOPSIS

find_and_remove_criteria_from_shared_set.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.

=cut
