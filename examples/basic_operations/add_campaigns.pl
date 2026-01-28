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
# This example adds a campaign. To get campaigns, run get_campaigns.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V23::Resources::Campaign;
use Google::Ads::GoogleAds::V23::Resources::NetworkSettings;
use Google::Ads::GoogleAds::V23::Common::ManualCpc;
use Google::Ads::GoogleAds::V23::Enums::BudgetDeliveryMethodEnum   qw(STANDARD);
use Google::Ads::GoogleAds::V23::Enums::AdvertisingChannelTypeEnum qw(SEARCH);
use Google::Ads::GoogleAds::V23::Enums::CampaignStatusEnum         qw(PAUSED);
use Google::Ads::GoogleAds::V23::Enums::EuPoliticalAdvertisingStatusEnum
  qw(DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING);
use
  Google::Ads::GoogleAds::V23::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);
use POSIX        qw(strftime);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub add_campaigns {
  my ($api_client, $customer_id) = @_;

  # [START add_campaigns]
  # Create a campaign budget, which can be shared by multiple campaigns.
  my $campaign_budget =
    Google::Ads::GoogleAds::V23::Resources::CampaignBudget->new({
      name           => "Interplanetary budget #" . uniqid(),
      deliveryMethod => STANDARD,
      amountMicros   => 500000
    });

  # Create a campaign budget operation.
  my $campaign_budget_operation =
    Google::Ads::GoogleAds::V23::Services::CampaignBudgetService::CampaignBudgetOperation
    ->new({create => $campaign_budget});

  # Add the campaign budget.
  my $campaign_budgets_response = $api_client->CampaignBudgetService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_budget_operation]});
  # [END add_campaigns]

  # [START add_campaigns_1]
  # Create a campaign.
  my $campaign = Google::Ads::GoogleAds::V23::Resources::Campaign->new({
      name                   => "Interplanetary Cruise #" . uniqid(),
      advertisingChannelType => SEARCH,
      # Recommendation: Set the campaign to PAUSED when creating it to stop
      # the ads from immediately serving. Set to ENABLED once you've added
      # targeting and the ads are ready to serve.
      status => PAUSED,
      # Set the bidding strategy and budget.
      manualCpc      => Google::Ads::GoogleAds::V23::Common::ManualCpc->new(),
      campaignBudget => $campaign_budgets_response->{results}[0]{resourceName},
      # Set the campaign network options.
      networkSettings =>
        Google::Ads::GoogleAds::V23::Resources::NetworkSettings->new({
          targetGoogleSearch  => "true",
          targetSearchNetwork => "true",
          # Enable Display Expansion on Search campaigns. See
          # https://support.google.com/google-ads/answer/7193800 to learn more.
          targetContentNetwork       => "true",
          targetPartnerSearchNetwork => "false"
        }
        ),
      # Declare whether or not this campaign serves political ads targeting the EU.
      # Valid values are CONTAINS_EU_POLITICAL_ADVERTISING and
      # DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING.
      containsEuPoliticalAdvertising =>
        DOES_NOT_CONTAIN_EU_POLITICAL_ADVERTISING,
      # Optional: Set the start datetime. The campaign starts tomorrow.
      startDateTime =>
        strftime("%Y%m%d 00:00:00", localtime(time + 60 * 60 * 24)),
      # Optional: Set the end datetime. The campaign runs for 30 days.
      endDateTime =>
        strftime("%Y%m%d 23:59:59", localtime(time + 60 * 60 * 24 * 30)),
    });
  # [END add_campaigns_1]

  # Create a campaign operation.
  my $campaign_operation =
    Google::Ads::GoogleAds::V23::Services::CampaignService::CampaignOperation->
    new({create => $campaign});

  # Add the campaign.
  my $campaigns_response = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]});

  printf "Created campaign '%s'.\n",
    $campaigns_response->{results}[0]{resourceName};

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
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
add_campaigns($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

add_campaigns

=head1 DESCRIPTION

This example adds a campaign. To get campaigns, run get_campaigns.pl.

=head1 SYNOPSIS

add_campaigns.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
