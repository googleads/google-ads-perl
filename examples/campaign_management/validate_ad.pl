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
# This example shows how to use the validateOnly field to validate a responsive
# search ad. No objects will be created, but exceptions will still be returned.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V21::Resources::Ad;
use Google::Ads::GoogleAds::V21::Common::AdTextAsset;
use Google::Ads::GoogleAds::V21::Common::ResponsiveSearchAdInfo;
use Google::Ads::GoogleAds::V21::Enums::AdGroupAdStatusEnum      qw(PAUSED);
use Google::Ads::GoogleAds::V21::Enums::ServedAssetFieldTypeEnum qw(HEADLINE_1);
use Google::Ads::GoogleAds::V21::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

sub validate_ad {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  # Create an ad group ad object.
  my $ad_group_ad = Google::Ads::GoogleAds::V21::Resources::AdGroupAd->new({
      adGroup => Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      # Optional: Set the status.
      status => PAUSED,
      ad     => Google::Ads::GoogleAds::V21::Resources::Ad->new({
          responsiveSearchAd =>
            Google::Ads::GoogleAds::V21::Common::ResponsiveSearchAdInfo->new({
              headlines => [
                Google::Ads::GoogleAds::V21::Common::AdTextAsset->new({
                    text        => "Visit the Red Planet in style.",
                    pinnedField => HEADLINE_1
                  }
                ),
                Google::Ads::GoogleAds::V21::Common::AdTextAsset->new({
                    text => "Low-gravity fun for everyone!!"
                  }
                ),
                Google::Ads::GoogleAds::V21::Common::AdTextAsset->new({
                    text => "Book your Cruise to Mars now"
                  }
                ),
              ],
              descriptions => [
                Google::Ads::GoogleAds::V21::Common::AdTextAsset->new({
                    text => "Luxury Cruise to Mars"
                  }
                ),
                Google::Ads::GoogleAds::V21::Common::AdTextAsset->new({
                    text => "Book your ticket now"
                  }
                ),
              ]}
            ),
          finalUrls => ["https://www.example.com/"]})});

  # Create an ad group ad operation.
  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V21::Services::AdGroupAdService::AdGroupAdOperation
    ->new({create => $ad_group_ad});

  # Add the ad group ad, while setting validateOnly to "true".
  my $response = $api_client->AdGroupAdService()->mutate({
    customerId     => $customer_id,
    operations     => [$ad_group_ad_operation],
    partialFailure => "false",
    validateOnly   => "true"
  });

  if (not $response->isa("Google::Ads::GoogleAds::GoogleAdsException")) {
    # This line will not be executed since the ad will fail validation.
    print "Responsive search ad validated successfully.\n";
  } else {
    # This block will be hit if there is a validation error from the server.
    print "There were validation error(s) while adding responsive search ad.\n";

    # Note: Policy violation errors are returned as PolicyFindingErrors. See
    # https://developers.google.com/google-ads/api/docs/policy-exemption/overview
    # for additional details.
    my $errors            = $response->get_google_ads_failure()->{errors};
    my @policy_violations = grep {
            $_->{errorCode}{policyFindingError}
        and $_->{errorCode}{policyFindingError} eq "POLICY_FINDING"
    } @{$errors};
    if (@policy_violations) {
      my $count = 1;
      foreach my $error (@policy_violations) {
        foreach my $entry (
          @{$error->{details}{policyFindingDetails}{policyTopicEntries}})
        {
          printf "%d) Policy topic entry with topic = '%s' and type = '%s' " .
            "was found.\n", $count, $entry->{topic}, $entry->{type};
          $count++;
        }
      }
    } else {
      # Die if there were unexpected validation errors.
      die $response->get_message();
    }
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
$api_client->set_die_on_faults(0);

my $customer_id = undef;
my $ad_group_id = undef;

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id, "ad_group_id=i" => \$ad_group_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $ad_group_id);

# Call the example.
validate_ad($api_client, $customer_id =~ s/-//gr, $ad_group_id);

=pod

=head1 NAME

validate_ad

=head1 DESCRIPTION

This example shows how to use the validateOnly field to validate a responsive
search ad. No objects will be created, but exceptions will still be returned.

=head1 SYNOPSIS

validate_ad.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID to which ads are added.

=cut
