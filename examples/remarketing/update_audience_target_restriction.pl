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
# This code example updates the AUDIENCE target restriction of a given ad group
# to bid only.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use Google::Ads::GoogleAds::V23::Resources::FeedItemAttributeValue;
use Google::Ads::GoogleAds::V23::Resources::AdGroup;
use Google::Ads::GoogleAds::V23::Common::TargetingSetting;
use Google::Ads::GoogleAds::V23::Common::TargetRestriction;
use Google::Ads::GoogleAds::V23::Enums::TargetingDimensionEnum qw(AUDIENCE);
use Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation;
use
  Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;
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

sub update_audience_target_restriction {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  # Create a flag that specifies whether or not we should update the targeting
  # setting. We should only do this if we find an AUDIENCE target restriction
  # with bid_only set to false.
  my $should_update_target_setting = 0;

  # Create an empty TargetingSetting instance.
  my $targeting_setting =
    Google::Ads::GoogleAds::V23::Common::TargetingSetting->new();

  # Create a search query that retrieves the targeting settings from a given
  # ad group.
  # [START update_audience_target_restriction]
  my $query =
    "SELECT ad_group.id, ad_group.name, " .
    "ad_group.targeting_setting.target_restrictions FROM ad_group " .
    "WHERE ad_group.id = $ad_group_id";
  # [END update_audience_target_restriction]

  # Create a search Google Ads stream request.
  my $search_stream_request =
    Google::Ads::GoogleAds::V23::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => $query,
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $google_ads_service,
      request => $search_stream_request
    });

  # Issue a search request and process the stream response.
  $search_stream_handler->process_contents(
    sub {
      my $google_ads_row = shift;
      my $ad_group       = $google_ads_row->{adGroup};

      # Print the requested ad group values from each row.
      printf "Ad group with ID %d and name '%s' was found with the following " .
        "targeting restrictions:\n",
        $ad_group->{id}, $ad_group->{name};

      my @target_restrictions =
        @{$ad_group->{targetingSetting}{targetRestrictions}};

      # Loop through and print each of the target restrictions. Reconstruct the
      # TargetingSetting object with the updated audience target restriction
      # because Google will overwrite the entire targeting_setting field of the
      # ad group when the field mask includes targeting_setting in an update
      # operation.
      # [START update_audience_target_restriction_1]
      foreach my $target_restriction (@target_restrictions) {
        my $targeting_dimension = $target_restriction->{targetingDimension};

        printf
          "\tTargeting restriction with targeting dimension '%s' and bid " .
          "only set to '%s'.\n",
          $targeting_dimension,
          $target_restriction->{bidOnly} ? "TRUE" : "FALSE";

        # Add the target restriction to the TargetingSetting object as is if the
        # targeting dimension has a value other than AUDIENCE because those
        # should not change.
        if ($targeting_dimension ne AUDIENCE) {
          $target_restriction->{bidOnly} =
            $target_restriction->{bidOnly} ? "true" : "false";
          push @{$targeting_setting->{targetRestrictions}}, $target_restriction;
        } elsif (!$target_restriction->{bidOnly}) {
          $should_update_target_setting = 1;

          # Add an AUDIENCE target restriction with bid_only set to true to the
          # targeting setting object. This has the effect of setting the
          # AUDIENCE target restriction to "Observation". For more details about
          # the targeting setting, visit
          # https://support.google.com/google-ads/answer/7365594.
          my $new_restriction =
            Google::Ads::GoogleAds::V23::Common::TargetRestriction->new({
              targetingDimension => AUDIENCE,
              bidOnly            => "true"
            });
          push @{$targeting_setting->{targetRestrictions}}, $new_restriction;
        }
      }
      # [END update_audience_target_restriction_1]
    });

  # Only update the TargetSetting on the ad group if there is an AUDIENCE
  # TargetRestriction with bid_only set to false.
  if ($should_update_target_setting) {
    update_targeting_setting($api_client, $customer_id, $ad_group_id,
      $targeting_setting);
  } else {
    print "No target restrictions to update.\n";
  }

  return 1;
}

# Updates the given TargetingSetting of an ad group.
# [START update_audience_target_restriction_2]
sub update_targeting_setting {
  my ($api_client, $customer_id, $ad_group_id, $targeting_setting) = @_;

  # Construct an ad group object with the updated targeting setting.
  my $ad_group = Google::Ads::GoogleAds::V23::Resources::AdGroup->new({
      resourceName =>
        Google::Ads::GoogleAds::V23::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
        ),
      targetingSetting => $targeting_setting
    });

  # Create an operation that will update the ad group, using the FieldMasks
  # utility to derive the update mask. This mask tells the Google Ads API which
  # attributes of the ad group you want to change.
  my $ad_group_operation =
    Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation->
    new({
      update     => $ad_group,
      updateMask => all_set_fields_of($ad_group)});

  # Send the operation in a mutate request and print the resource name of the
  # updated resource.
  my $ad_groups_response = $api_client->AdGroupService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_operation]});

  printf "Updated targeting setting of ad group with resourceName " .
    "'%s'; set the AUDIENCE target restriction to 'Observation'.\n",
    $ad_groups_response->{results}[0]{resourceName};
}
# [END update_audience_target_restriction_2]

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
  "customer_id=s" => \$customer_id,
  "ad_group_id=i" => \$ad_group_id,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $ad_group_id);

# Call the example.
update_audience_target_restriction($api_client, $customer_id =~ s/-//gr,
  $ad_group_id);

=pod

=head1 NAME

update_audience_target_restriction

=head1 DESCRIPTION

This code example updates the AUDIENCE target restriction of a given ad group
to bid only.

=head1 SYNOPSIS

update_audience_target_restriction.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID for which to update the audience
                                targeting restriction.

=cut
