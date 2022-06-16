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
# This example demonstrates how to add a campaign-level bid modifier for call
# interactions.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V11::Resources::CampaignBidModifier;
use Google::Ads::GoogleAds::V11::Common::InteractionTypeInfo;
use Google::Ads::GoogleAds::V11::Enums::InteractionTypeEnum qw(CALLS);
use Google::Ads::GoogleAds::V11::Enums::ResponseContentTypeEnum
  qw(MUTABLE_RESOURCE);
use
  Google::Ads::GoogleAds::V11::Services::CampaignBidModifierService::CampaignBidModifierOperation;
use Google::Ads::GoogleAds::V11::Utils::ResourceNames;

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
my $customer_id        = "INSERT_CUSTOMER_ID_HERE";
my $campaign_id        = "INSERT_CAMPAIGN_ID_HERE";
my $bid_modifier_value = "INSERT_BID_MODIFIER_VALUE_HERE";

sub add_campaign_bid_modifier {
  my ($api_client, $customer_id, $campaign_id, $bid_modifier_value) = @_;

  # Create a campaign bid modifier for call interactions with the specified
  # campaign ID and bid modifier value.
  my $campaign_bid_modifier =
    Google::Ads::GoogleAds::V11::Resources::CampaignBidModifier->new({
      campaign => Google::Ads::GoogleAds::V11::Utils::ResourceNames::campaign(
        $customer_id, $campaign_id
      ),
      # Make the bid modifier apply to call interactions.
      interactionType =>
        Google::Ads::GoogleAds::V11::Common::InteractionTypeInfo->new({
          type => CALLS
        }
        ),
      # Set the bid modifier value.
      bidModifier => $bid_modifier_value
    });

  # Create a campaign bid modifier operation.
  my $campaign_bid_modifier_operation =
    Google::Ads::GoogleAds::V11::Services::CampaignBidModifierService::CampaignBidModifierOperation
    ->new({
      create => $campaign_bid_modifier
    });

  # [START mutable_resource]
  # Add the campaign bid modifier. Here we pass the optional parameter
  # responseContentType => MUTABLE_RESOURCE so that the response contains the
  # mutated object and not just its resource name.
  my $campaign_bid_modifiers_response =
    $api_client->CampaignBidModifierService()->mutate({
      customerId          => $customer_id,
      operations          => [$campaign_bid_modifier_operation],
      responseContentType => MUTABLE_RESOURCE
    });

  # The resource returned in the response can be accessed directly in the
  # results list. Its fields can be read directly, and it can also be mutated
  # further and used in subsequent requests, without needing to make additional
  # Get or Search requests.
  my $mutable_resource =
    $campaign_bid_modifiers_response->{results}[0]{campaignBidModifier};

  printf
    "Created campaign bid modifier with resource name '%s', criterion ID %d, "
    . "and bid modifier value %s, under the campaign with resource name '%s'.\n",
    $mutable_resource->{resourceName}, $mutable_resource->{criterionId},
    $mutable_resource->{bidModifier},  $mutable_resource->{campaign};
  # [END mutable_resource]

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
  "customer_id=s"        => \$customer_id,
  "campaign_id=i"        => \$campaign_id,
  "bid_modifier_value=f" => \$bid_modifier_value
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $campaign_id, $bid_modifier_value);

# Call the example.
add_campaign_bid_modifier($api_client, $customer_id =~ s/-//gr,
  $campaign_id, $bid_modifier_value);

=pod

=head1 NAME

add_campaign_bid_modifier

=head1 DESCRIPTION

This example demonstrates how to add a campaign-level bid modifier for call interactions.

=head1 SYNOPSIS

add_campaign_bid_modifier.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.
    -bid_modifier_value         The bid modifier value.

=cut
