#!/usr/bin/perl -w
#
# Copyright 2020, Google LLC
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
# This example shows how to use the validateOnly field to validate an expanded
# text ad. No objects will be created, but exceptions will still be returned.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V3::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V3::Resources::Ad;
use Google::Ads::GoogleAds::V3::Common::ExpandedTextAdInfo;
use Google::Ads::GoogleAds::V3::Enums::AdGroupAdStatusEnum qw(PAUSED);
use Google::Ads::GoogleAds::V3::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V3::Utils::ResourceNames;

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

sub validate_text_ad {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  # Create an ad group ad object.
  my $ad_group_ad = Google::Ads::GoogleAds::V3::Resources::AdGroupAd->new({
      adGroup => Google::Ads::GoogleAds::V3::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      # Optional: Set the status.
      status => PAUSED,
      ad     => Google::Ads::GoogleAds::V3::Resources::Ad->new({
          expandedTextAd =>
            Google::Ads::GoogleAds::V3::Common::ExpandedTextAdInfo->new({
              description   => "Luxury Cruise to Mars",
              headlinePart1 => "Visit the Red Planet in style.",
              # Add a headline that will trigger a policy violation to demonstrate
              # error handling.
              headlinePart2 => "Low-gravity fun for everyone!!"
            }
            ),
          finalUrls => ["http://www.example.com/"]})});

  # Create an ad group ad operation.
  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V3::Services::AdGroupAdService::AdGroupAdOperation
    ->new({create => $ad_group_ad});

  # Add the ad group ad, while setting validateOnly to "true".
  my $response = $api_client->AdGroupAdService()->mutate({
    customerId     => $customer_id,
    operations     => [$ad_group_ad_operation],
    partialFailure => "false",
    validateOnly   => "true"
  });

  if (not $response->isa("Google::Ads::GoogleAds::GoogleAdsException")) {
    # Since validateOnly is set to "true", result will be null.
    print "Expanded text ad validated successfully.\n";
  } else {
    # This block will be hit if there is a validation error from the server.
    print "There were validation error(s) while adding expanded text ad.\n";

    # Note: Depending on the ad type, you may get back policy violation errors as
    # either PolicyFindingError or PolicyViolationError. ExpandedTextAds return
    # errors as PolicyFindingError, so only this case is illustrated here. See
    # https://developers.google.com/google-ads/api/docs/policy-exemption/overview
    # for additional details.
    my $count = 1;
    foreach my $error (@{$response->get_google_ads_failure()->{errors}}) {
      next
        unless ($error->{errorCode}{policyFindingError}
        and $error->{errorCode}{policyFindingError} eq "POLICY_FINDING");

      foreach my $entry (
        @{$error->{details}{policyFindingDetails}{policyTopicEntries}})
      {
        printf "%d) Policy topic entry with topic = '%s' and type = '%s' " .
          "was found.\n", $count, $entry->{topic}, $entry->{type};
      }

      $count++;
    }
  }

  return 1;
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new({version => "V3"});

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(0);

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id, "ad_group_id=i" => \$ad_group_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $ad_group_id);

# Call the example.
validate_text_ad($api_client, $customer_id =~ s/-//gr, $ad_group_id);

=pod

=head1 NAME

validate_text_ad

=head1 DESCRIPTION

This example shows how to use the validateOnly field to validate an expanded
text ad. No objects will be created, but exceptions will still be returned.

=head1 SYNOPSIS

validate_text_ad.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID to which ads are added.

=cut
