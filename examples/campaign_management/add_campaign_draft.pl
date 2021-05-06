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
# This example adds a campaign draft for a campaign. Make sure you specify a
# campaign that has a non-shared budget.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V7::Resources::CampaignDraft;
use
  Google::Ads::GoogleAds::V7::Services::CampaignDraftService::CampaignDraftOperation;
use Google::Ads::GoogleAds::V7::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use Data::Uniqid qw(uniqid);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id      = "INSERT_CUSTOMER_ID_HERE";
my $base_campaign_id = "INSERT_BASE_CAMPAIGN_ID_HERE";

sub add_campaign_draft {
  my ($api_client, $customer_id, $base_campaign_id) = @_;

  # Create a campaign draft.
  my $campaign_draft =
    Google::Ads::GoogleAds::V7::Resources::CampaignDraft->new({
      baseCampaign =>
        Google::Ads::GoogleAds::V7::Utils::ResourceNames::campaign(
        $customer_id, $base_campaign_id
        ),
      name => "Campaign Draft #" . uniqid()});

  # Create a campaign draft operation.
  my $campaign_draft_operation =
    Google::Ads::GoogleAds::V7::Services::CampaignDraftService::CampaignDraftOperation
    ->new({
      create => $campaign_draft
    });

  # Add the campaign draft.
  my $campaign_drafts_response = $api_client->CampaignDraftService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_draft_operation]});

  printf "Added a campaign draft with resource name: '%s'.\n",
    $campaign_drafts_response->{results}[0]{resourceName};

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
  "customer_id=s"      => \$customer_id,
  "base_campaign_id=i" => \$base_campaign_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $base_campaign_id);

# Call the example.
add_campaign_draft($api_client, $customer_id =~ s/-//gr, $base_campaign_id);

=pod

=head1 NAME

add_campaign_draft

=head1 DESCRIPTION

This example adds a campaign draft for a campaign. Make sure you specify a campaign
that has a non-shared budget.

=head1 SYNOPSIS

add_campaign_draft.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -base_campaign_id           The campaign ID to base the draft on.

=cut
