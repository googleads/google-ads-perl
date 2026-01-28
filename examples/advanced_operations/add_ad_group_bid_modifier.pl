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
# This example demonstrates how to add an ad group bid modifier for mobile devices.
# To get ad group bid modifiers, see advanced_operations/get_ad_group_bid_modifiers.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::AdGroupBidModifier;
use Google::Ads::GoogleAds::V23::Common::DeviceInfo;
use Google::Ads::GoogleAds::V23::Enums::DeviceEnum qw(MOBILE);
use
  Google::Ads::GoogleAds::V23::Services::AdGroupBidModifierService::AdGroupBidModifierOperation;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

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
my $ad_group_id = "INSERT_AD_GROUP_ID_HERE";
# Specify the bid modifier value here or the default specified below will be used.
my $bid_modifier_value = 1.5;

# [START add_ad_group_bid_modifier]
sub add_ad_group_bid_modifier {
  my ($api_client, $customer_id, $ad_group_id, $bid_modifier_value) = @_;

  # Create an ad group bid modifier for mobile devices with the specified ad group ID and
  # bid modifier value.
  my $ad_group_bid_modifier =
    Google::Ads::GoogleAds::V23::Resources::AdGroupBidModifier->new({
      adGroup => Google::Ads::GoogleAds::V23::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      bidModifier => $bid_modifier_value,
      device      => Google::Ads::GoogleAds::V23::Common::DeviceInfo->new({
          type => MOBILE
        })});

  # Create an ad group bid modifier operation.
  my $ad_group_bid_modifier_operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupBidModifierService::AdGroupBidModifierOperation
    ->new({
      create => $ad_group_bid_modifier
    });

  # Add the ad group bid modifier.
  my $ad_group_bid_modifiers_response =
    $api_client->AdGroupBidModifierService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_bid_modifier_operation]});

  printf "Created ad group bid modifier '%s'.\n",
    $ad_group_bid_modifiers_response->{results}[0]{resourceName};

  return 1;
}
# [END add_ad_group_bid_modifier]

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
  "ad_group_id=i"        => \$ad_group_id,
  "bid_modifier_value=f" => \$bid_modifier_value
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $ad_group_id, $bid_modifier_value);

# Call the example.
add_ad_group_bid_modifier($api_client, $customer_id =~ s/-//gr,
  $ad_group_id, $bid_modifier_value);

=pod

=head1 NAME

add_ad_group_bid_modifier

=head1 DESCRIPTION

This example demonstrates how to add an ad group bid modifier for mobile devices.
To get ad group bid modifiers, see advanced_operations/get_ad_group_bid_modifiers.pl.

=head1 SYNOPSIS

add_ad_group_bid_modifier.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID.
    -bid_modifier_value         [optional] The bid modifier value.

=cut
