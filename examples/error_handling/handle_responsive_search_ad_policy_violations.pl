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
# This example demonstrates how to request an exemption for policy violations
# of a responsive search ad. If the request somehow fails with exceptions that are
# not policy finding errors, the example will stop instead of trying sending an
# exemption request.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V23::Resources::Ad;
use Google::Ads::GoogleAds::V23::Common::AdTextAsset;
use Google::Ads::GoogleAds::V23::Common::ResponsiveSearchAdInfo;
use Google::Ads::GoogleAds::V23::Common::PolicyValidationParameter;
use Google::Ads::GoogleAds::V23::Enums::AdGroupStatusEnum qw(PAUSED);
use Google::Ads::GoogleAds::V23::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

sub handle_responsive_search_ad_policy_violations {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  my $ad_group_resource_name =
    Google::Ads::GoogleAds::V23::Utils::ResourceNames::ad_group($customer_id,
    $ad_group_id);

  # Create a responsive search ad info object.
  my $responsive_search_ad_info =
    Google::Ads::GoogleAds::V23::Common::ResponsiveSearchAdInfo->new({
      headlines => [
        Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
            text => "Cruise to Mars #" . uniqid()}
        ),
        Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
            text => "Best Space Cruise Line"
          }
        ),
        Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
            text => "Experience the Stars"
          })
      ],
      descriptions => [
        # Intentionally use an ad text that violates policy -- having too many
        # exclamation marks.
        Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
            text => "Buy your tickets now!!!!!!!"
          }
        ),
        Google::Ads::GoogleAds::V23::Common::AdTextAsset->new({
            text => "Visit the Red Planet"
          })]});

  # Create an ad group ad to hold the above ad.
  my $ad_group_ad = Google::Ads::GoogleAds::V23::Resources::AdGroupAd->new({
      adGroup => $ad_group_resource_name,
      # Set the ad group ad to PAUSED to prevent it from immediately serving.
      # Set to ENABLED once you've added targeting and the ad are ready to serve.
      status => PAUSED,
      # Set the responsive search ad info on an ad.
      ad => Google::Ads::GoogleAds::V23::Resources::Ad->new({
          responsiveSearchAd => $responsive_search_ad_info,
          finalUrls          => ["https://www.example.com"]})});

  # Create an ad group ad operation.
  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupAdService::AdGroupAdOperation
    ->new({
      create => $ad_group_ad
    });

  # Try sending a mutate request to add the ad group ad.
  my $response = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]});

  my $ignorable_policy_topics = [];
  if ($response->isa("Google::Ads::GoogleAds::GoogleAdsException")) {
    # The request will always fail because of the policy violation in the
    # description of the ad.
    $ignorable_policy_topics = fetch_ignorable_policy_topics($response);
  }

  # Try sending exemption requests for creating a responsive search ad.
  request_exemption($api_client, $customer_id, $ad_group_ad_operation,
    $ignorable_policy_topics);

  return 1;
}

# Collects all ignorable policy topics that will be sent for exemption request
# later.
# [START handle_responsive_search_ad_policy_violations]
sub fetch_ignorable_policy_topics {
  my $google_ads_exception = shift;

  my $ignorable_policy_topics = [];

  printf "Google Ads failure details:\n";
  foreach
    my $error (@{$google_ads_exception->get_google_ads_failure()->{errors}})
  {
    if ([keys %{$error->{errorCode}}]->[0] ne "policyFindingError") {
      # This example supports sending exemption request for the policy finding
      # error only.
      die $google_ads_exception->get_message();
    }

    printf "\t%s: %s\n", [keys %{$error->{errorCode}}]->[0], $error->{message};

    if ($error->{details}{policyFindingDetails}) {
      my $policy_finding_details = $error->{details}{policyFindingDetails};
      printf "\tPolicy finding details:\n";

      foreach my $policy_topic_entry (
        @{$policy_finding_details->{policyTopicEntries}})
      {
        push @$ignorable_policy_topics, $policy_topic_entry->{topic};
        printf
          "\t\tPolicy topic name: '%s'\n",
          $policy_topic_entry->{topic};
        printf "\t\tPolicy topic entry type: '%s'\n",
          $policy_topic_entry->{type};
        # For the sake of brevity, we exclude printing "policy topic evidences" and
        # "policy topic constraints" here. You can fetch those data by calling:
        # - $policy_topic_entry->{evidences}
        # - $policy_topic_entry->{constraints}
      }
    }
  }

  return $ignorable_policy_topics;
}
# [END handle_responsive_search_ad_policy_violations]

# Sends exemption requests for creating a responsive search ad.
# [START handle_responsive_search_ad_policy_violations_1]
sub request_exemption {
  my ($api_client, $customer_id, $ad_group_ad_operation,
    $ignorable_policy_topics)
    = @_;

  print
    "Try adding a responsive search ad again by requesting exemption for its "
    . "policy violations.\n";

  $ad_group_ad_operation->{policyValidationParameter} =
    Google::Ads::GoogleAds::V23::Common::PolicyValidationParameter->new(
    {ignorablePolicyTopics => $ignorable_policy_topics});

  my $ad_group_ads_response = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]});

  printf
    "Successfully added a responsive search ad with resource name '%s' by " .
    "requesting for policy violation exemption.\n",
    $ad_group_ads_response->{results}[0]{resourceName};
}
# [END handle_responsive_search_ad_policy_violations_1]

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
GetOptions(
  "customer_id=s" => \$customer_id,
  "ad_group_id=i" => \$ad_group_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $ad_group_id);

# Call the example.
handle_responsive_search_ad_policy_violations($api_client,
  $customer_id =~ s/-//gr, $ad_group_id);

=pod

=head1 NAME

handle_responsive_search_ad_policy_violations

=head1 DESCRIPTION

This example demonstrates how to request an exemption for policy violations of a
responsive search ad. If the request somehow fails with exceptions that are not policy
finding errors, the example will stop instead of trying sending an exemption request.

=head1 SYNOPSIS

handle_responsive_search_ad_policy_violations.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID.

=cut
