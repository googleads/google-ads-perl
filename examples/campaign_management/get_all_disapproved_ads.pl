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
# This example retrieves all the disapproved ads in a given campaign.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use Google::Ads::GoogleAds::V23::Enums::PolicyApprovalStatusEnum
  qw(DISAPPROVED);
use
  Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest;
use Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchSettings;

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

sub get_all_disapproved_ads {
  my ($api_client, $customer_id, $campaign_id) = @_;

  # Create a query that retrieves all the disapproved ads of the specified campaign ID.
  my $search_query =
    "SELECT ad_group_ad.ad.id, ad_group_ad.ad.type, " .
    "ad_group_ad.policy_summary.approval_status, " .
    "ad_group_ad.policy_summary.policy_topic_entries " .
    "FROM ad_group_ad WHERE campaign.id = $campaign_id " .
    "AND ad_group_ad.policy_summary.approval_status = DISAPPROVED";

  # Create a search Google Ads request.
  my $search_request =
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId     => $customer_id,
      query          => $search_query,
      searchSettings =>
        Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchSettings
        ->new({
          returnTotalResultsCount => true
        })});

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
    service => $google_ads_service,
    request => $search_request
  });

  # Iterate over all rows in all pages and count disapproved ads.
  while ($iterator->has_next) {
    my $google_ads_row = $iterator->next;
    my $ad_group_ad    = $google_ads_row->{adGroupAd};
    my $ad             = $ad_group_ad->{ad};
    my $policy_summary = $ad_group_ad->{policySummary};

    printf "Ad with ID %d and type '%s' was disapproved with the " .
      "following policy topic entries:\n", $ad->{id}, $ad->{type};

    # Display the policy topic entries related to the ad disapproval.
    foreach my $policy_topic_entry (@{$policy_summary->{policyTopicEntries}}) {
      printf "  topic: '%s', type: '%s'\n", $policy_topic_entry->{topic},
        $policy_topic_entry->{type};

      # Display the attributes and values that triggered the policy topic.
      next if not $policy_topic_entry->{evidences};
      foreach my $policy_topic_evidence (@{$policy_topic_entry->{evidences}}) {
        next if not $policy_topic_evidence->{textList};
        while (my ($index, $text) =
          each @{$policy_topic_evidence->{textList}{texts}})
        {
          printf "    evidence text[%d]: '%s'\n", $index, $text;
        }
      }
    }
  }

  printf "Number of disapproved ads found: %d.\n",
    $iterator->get_current_response()->{totalResultsCount} || 0;

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
get_all_disapproved_ads($api_client, $customer_id =~ s/-//gr, $campaign_id);

=pod

=head1 NAME

get_all_disapproved_ads

=head1 DESCRIPTION

This example retrieves all the disapproved ads in a given campaign.

=head1 SYNOPSIS

get_all_disapproved_ads.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.

=cut
