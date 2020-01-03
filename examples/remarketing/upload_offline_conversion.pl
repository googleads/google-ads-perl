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
# This example imports offline conversion values for specific clicks to your account.
# To get Google Click ID for a click, use the "click_view" resource:
# https://developers.google.com/google-ads/api/fields/latest/click_view.
# To set up a conversion action, run the add_conversion_action.pl example.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::GoogleAdsClient;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use
  Google::Ads::GoogleAds::V2::Services::ConversionUploadService::ClickConversion;
use Google::Ads::GoogleAds::V2::Utils::ResourceNames;

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
my $customer_id          = "INSERT_CUSTOMER_ID_HERE";
my $conversion_action_id = "INSERT_CONVERSION_ACTION_ID_HERE";
my $gclid                = "INSERT_GCLID_HERE";
my $conversion_time      = "INSERT_CONVERSION_TIME_HERE";
my $conversion_value     = "INSERT_CONVERSION_VALUE_HERE";

sub upload_offline_conversion {
  my ($api_client, $customer_id, $conversion_action_id, $gclid,
    $conversion_time, $conversion_value)
    = @_;

  # Create a click conversion by specifying currency as USD.
  my $click_conversion =
    Google::Ads::GoogleAds::V2::Services::ConversionUploadService::ClickConversion
    ->new({
      conversionAction =>
        Google::Ads::GoogleAds::V2::Utils::ResourceNames::conversion_action(
        $customer_id, $conversion_action_id
        ),
      gclid              => $gclid,
      conversionValue    => $conversion_value,
      conversionDateTime => $conversion_time,
      currencyCode       => "USD"
    });

  # Issue a request to upload the click conversion.
  my $upload_click_conversions_response =
    $api_client->ConversionUploadService()->upload_click_conversions({
      customerId     => $customer_id,
      conversions    => [$click_conversion],
      partialFailure => "true"
    });

  # Print the result.
  my $uploaded_click_conversion =
    $upload_click_conversions_response->{results}[0];
  printf "Uploaded conversion that occurred at '%s' " .
    "from Google Click ID '%s' to '%s'.\n",
    $uploaded_click_conversion->{conversionDateTime},
    $uploaded_click_conversion->{gclid},
    $uploaded_click_conversion->{conversionAction};

  return 1;
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client =
  Google::Ads::GoogleAds::GoogleAdsClient->new({version => "V2"});

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"          => \$customer_id,
  "conversion_action_id=i" => \$conversion_action_id,
  "gclid=s"                => \$gclid,
  "conversion_time=s"      => \$conversion_time,
  "conversion_value=i"     => \$conversion_value
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $conversion_action_id, $gclid,
  $conversion_time, $conversion_value);

# Call the example.
upload_offline_conversion($api_client, $customer_id =~ s/-//gr,
  $conversion_action_id, $gclid, $conversion_time, $conversion_value);

=pod

=head1 NAME

upload_offline_conversion

=head1 DESCRIPTION

This example imports offline conversion values for specific clicks to your account.
To get Google Click ID for a click, use the "click_view" resource:
https://developers.google.com/google-ads/api/fields/latest/click_view.
To set up a conversion action, run the add_conversion_action.pl example.

=head1 SYNOPSIS

upload_offline_conversion.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -conversion_action_id       The ID of the conversion action to upload to.
    -gclid                      The GCLID for the conversion (should be newer than the number of days
                                set on the conversion window of the conversion action).
    -conversion_time            The date and time of the conversion (should be after the click time).
                                The format is "yyyy-mm-dd hh:mm:ss+|-hh:mm", e.g. "2019-01-01 12:32:45-08:00".
    -conversion_value           The value of the conversion.

=cut
