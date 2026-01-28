#!/usr/bin/perl -w
#
# Copyright 2022, Google LLC
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
# This example adds a call asset to a specific account.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::Asset;
use Google::Ads::GoogleAds::V23::Resources::CustomerAsset;
use Google::Ads::GoogleAds::V23::Common::CallAsset;
use Google::Ads::GoogleAds::V23::Common::AdScheduleInfo;
use Google::Ads::GoogleAds::V23::Enums::DayOfWeekEnum    qw(MONDAY);
use Google::Ads::GoogleAds::V23::Enums::MinuteOfHourEnum qw(ZERO);
use Google::Ads::GoogleAds::V23::Enums::CallConversionReportingStateEnum
  qw(USE_RESOURCE_LEVEL_CALL_CONVERSION_ACTION);
use Google::Ads::GoogleAds::V23::Enums::AssetFieldTypeEnum qw(CALL);
use Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation;
use
  Google::Ads::GoogleAds::V23::Services::CustomerAssetService::CustomerAssetOperation;
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
# Specify the phone country code here or the default specified below will be used.
# See supported codes at:
# https://developers.google.com/google-ads/api/reference/data/codes-formats#expandable-17
my $phone_country = "US";
my $phone_number  = "INSERT_PHONE_NUMBER_HERE";
# Optional: Specify the conversion action ID to attribute call conversions to.
# If not set, the default conversion action is used.
my $conversion_action_id = undef;

sub add_call {
  my ($api_client, $customer_id, $phone_country, $phone_number,
    $conversion_action_id)
    = @_;

  # Create the call asset.
  my $asset_resource_name =
    add_call_asset($api_client, $customer_id, $phone_country,
    $phone_number, $conversion_action_id);

  # Add the assets at the account level, so these will serve in all eligible campaigns.
  link_asset_to_account($api_client, $customer_id, $asset_resource_name);

  return 1;
}

# Creates a new asset for the call.
sub add_call_asset {
  my ($api_client, $customer_id, $phone_country,
    $phone_number, $conversion_action_id)
    = @_;

  # Create the call asset.
  my $call_asset = Google::Ads::GoogleAds::V23::Common::CallAsset->new({
      # Set the country code and phone number of the business to call.
      countryCode => $phone_country,
      phoneNumber => $phone_number,
      # Optional: Specify all day and time intervals for which the asset may serve.
      adScheduleTargets => [
        Google::Ads::GoogleAds::V23::Common::AdScheduleInfo->new({
            # Set the day of this schedule as Monday.
            dayOfWeek => MONDAY,
            # Set the start hour to 9am.
            startHour => 9,
            # Set the end hour to 5pm.
            endHour => 17,
            # Set the start and end minute of zero, for example: 9:00 and 5:00.
            startMinute => ZERO,
            endMinute   => ZERO
          })]});

  # Set the conversion action ID to the one provided if any.
  if (defined $conversion_action_id) {
    $call_asset->{callConversionAction} =
      Google::Ads::GoogleAds::V23::Utils::ResourceNames::conversion_action(
      $customer_id, $conversion_action_id);
    $call_asset->{callConversionReportingState} =
      USE_RESOURCE_LEVEL_CALL_CONVERSION_ACTION;
  }

  # Create an asset operation wrapping the call asset in an asset.
  my $asset_operation =
    Google::Ads::GoogleAds::V23::Services::AssetService::AssetOperation->new({
      create => Google::Ads::GoogleAds::V23::Resources::Asset->new({
          callAsset => $call_asset
        })});

  # Issue a mutate request to add the asset and print its information.
  my $response = $api_client->AssetService()->mutate({
      customerId => $customer_id,
      operations => [$asset_operation]});
  my $resource_name = $response->{results}[0]{resourceName};
  printf "Created a call asset with resource name: '%s'.\n", $resource_name;
  return $resource_name;
}

# Links the call asset at the account level to serve in all eligible campaigns.
sub link_asset_to_account {
  my ($api_client, $customer_id, $asset_resource_name) = @_;

  # Create a customer asset operation wrapping the call asset in a customer asset.
  my $customer_asset_operation =
    Google::Ads::GoogleAds::V23::Services::CustomerAssetService::CustomerAssetOperation
    ->new({
      create => Google::Ads::GoogleAds::V23::Resources::CustomerAsset->new({
          asset     => $asset_resource_name,
          fieldType => CALL
        })});

  # Issue a mutate request to add the customer asset and print its information.
  my $response = $api_client->CustomerAssetService()->mutate({
      customerId => $customer_id,
      operations => [$customer_asset_operation]});
  printf "Created a customer asset with resource name: '%s'.\n",
    $response->{results}[0]{resourceName};
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
  "customer_id=s"          => \$customer_id,
  "phone_country=s"        => \$phone_country,
  "phone_number=s"         => \$phone_number,
  "conversion_action_id=i" => \$conversion_action_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $phone_country, $phone_number);

# Call the example.
add_call($api_client, $customer_id =~ s/-//gr,
  $phone_country, $phone_number, $conversion_action_id);

=pod

=head1 NAME

add_call

=head1 DESCRIPTION

This example adds a call asset to a specific account.

=head1 SYNOPSIS

add_call.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -phone_country              [optional] The phone country (2-letter code).
    -phone_number               The raw phone number, e.g. "(800) 555-0100".
    -conversion_action_id       [optional] The conversion action ID to attribute conversions to.

=cut
