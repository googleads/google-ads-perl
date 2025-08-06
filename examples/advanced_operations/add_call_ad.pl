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
# This example adds a call ad to a given ad group. More information about call ads
# can be found at https://support.google.com/google-ads/answer/6341403.
# To get ad groups, run get_ad_groups.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V21::Resources::Ad;
use Google::Ads::GoogleAds::V21::Common::CallAdInfo;
use Google::Ads::GoogleAds::V21::Enums::AdGroupAdStatusEnum qw(PAUSED);
use Google::Ads::GoogleAds::V21::Enums::CallConversionReportingStateEnum
  qw(USE_RESOURCE_LEVEL_CALL_CONVERSION_ACTION);
use Google::Ads::GoogleAds::V21::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

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
# Specify the phone country code here or the default specified below will be used.
# See supported codes at:
# https://developers.google.com/google-ads/api/reference/data/codes-formats#expandable-17
my $phone_country = "US";
my $phone_number  = "INSERT_PHONE_NUMBER_HERE";
# Optional: Specify the conversion action ID to attribute call conversions to.
# If not set, the default conversion action is used.
my $conversion_action_id = undef;

sub add_call_ad {
  my ($api_client, $customer_id, $ad_group_id, $phone_country, $phone_number,
    $conversion_action_id)
    = @_;

  # Create an ad group ad for the new ad.
  my $ad_group_ad = Google::Ads::GoogleAds::V21::Resources::AdGroupAd->new({
      adGroup => Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      status => PAUSED,
      ad     => Google::Ads::GoogleAds::V21::Resources::Ad->new({
          # The URL of the webpage to refer to.
          finalUrls => ["https://www.example.com"],
          callAd    => Google::Ads::GoogleAds::V21::Common::CallAdInfo->new({
              # Set basic information.
              businessName => "Google",
              headline1    => "Travel",
              headline2    => "Discover",
              description1 => "Travel the World",
              description2 => "Travel the Universe",
              # Set the country code and phone number of the business to call.
              countryCode => $phone_country,
              phoneNumber => $phone_number,
              # Set the verification URL to a webpage that includes the phone number.
              phoneNumberVerificationUrl => "https://www.example.com/contact",

              # The fields below are optional.
              # Configure call tracking and reporting.
              callTracked           => "true",
              disableCallConversion => "false",
              # Set path parts to append for display.
              path1 => "services",
              path2 => "travels"
            })})});

  # Set the conversion action ID to the one provided if any.
  if (defined $conversion_action_id) {
    $ad_group_ad->{ad}{callAd}{conversionAction} =
      Google::Ads::GoogleAds::V21::Utils::ResourceNames::conversion_action(
      $customer_id, $conversion_action_id);
    $ad_group_ad->{ad}{callAd}{conversionReportingState} =
      USE_RESOURCE_LEVEL_CALL_CONVERSION_ACTION;
  }

  # Create an ad group ad operation.
  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V21::Services::AdGroupAdService::AdGroupAdOperation
    ->new({
      create => $ad_group_ad
    });

  # Issue a mutate request to add the ad group ad.
  my $ad_group_ad_response = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]});

  # Print information about the newly created ad group ad.
  printf "Created ad group ad with resource name: '%s'.\n",
    $ad_group_ad_response->{results}[0]{resourceName};

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
  "customer_id=s"          => \$customer_id,
  "ad_group_id=i"          => \$ad_group_id,
  "phone_country=s"        => \$phone_country,
  "phone_number=s"         => \$phone_number,
  "conversion_action_id=i" => \$conversion_action_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if
  not check_params($customer_id, $ad_group_id, $phone_country, $phone_number);

# Call the example.
add_call_ad(
  $api_client,    $customer_id =~ s/-//gr, $ad_group_id,
  $phone_country, $phone_number,           $conversion_action_id
);

=pod

=head1 NAME

add_call_ad

=head1 DESCRIPTION

This example adds a call ad to a given ad group. More information about call ads
can be found at https://support.google.com/google-ads/answer/6341403.
To get ad groups, run get_ad_groups.pl.

=head1 SYNOPSIS

add_call_ad.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID to add a call ad to.
    -phone_country              [optional] The phone country (2-letter code).
    -phone_number               The raw phone number, e.g. "(800) 555-0100".
    -conversion_action_id       [optional] The conversion action ID to attribute conversions to.

=cut
