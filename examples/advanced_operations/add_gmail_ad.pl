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
# This example demonstrates how to add a Gmail ad to a given ad group.
# The ad group's campaign needs to have an AdvertisingChannelType of DISPLAY
# and AdvertisingChannelSubType of DISPLAY_GMAIL_AD.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::MediaUtils;
use Google::Ads::GoogleAds::V8::Resources::Ad;
use Google::Ads::GoogleAds::V8::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V8::Resources::MediaImage;
use Google::Ads::GoogleAds::V8::Resources::MediaFile;
use Google::Ads::GoogleAds::V8::Common::GmailAdInfo;
use Google::Ads::GoogleAds::V8::Common::GmailTeaser;
use Google::Ads::GoogleAds::V8::Enums::AdGroupAdStatusEnum qw(PAUSED);
use Google::Ads::GoogleAds::V8::Enums::MediaTypeEnum qw(IMAGE);
use Google::Ads::GoogleAds::V8::Enums::MimeTypeEnum qw(IMAGE_PNG IMAGE_JPEG);
use Google::Ads::GoogleAds::V8::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V8::Services::MediaFileService::MediaFileOperation;
use Google::Ads::GoogleAds::V8::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use Data::Uniqid qw(uniqid);

use constant LOGO_IMAGE_URL      => "https://goo.gl/mtt54n";
use constant MARKETING_IMAGE_URL => "https://goo.gl/3b9Wfh";

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

sub add_gmail_ad {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  my $media_files = add_media_files($api_client, $customer_id);

  # Create the Gmail ad info.
  my $gmail_ad_info = Google::Ads::GoogleAds::V8::Common::GmailAdInfo->new({
      # Set the teaser information.
      teaser => Google::Ads::GoogleAds::V8::Common::GmailTeaser->new({
          headline     => "Dream",
          description  => "Create your own adventure",
          businessName => "Interplanetary Ships",
          logoImage    => $media_files->{logo_image_resource_name}}
      ),

      # Set the marketing image and other information.
      marketingImage         => $media_files->{marketing_image_resource_name},
      marketingImageHeadline => "Travel",
      marketingImageDescription => "Take to the skies!"
    });

  # Set the Gmail ad info on an ad.
  my $ad = Google::Ads::GoogleAds::V8::Resources::Ad->new({
    name      => "Gmail Ad #" . uniqid(),
    finalUrls => ["http://www.example.com"],
    gmailAd   => $gmail_ad_info
  });

  # Create an ad group ad.
  my $ad_group_ad = Google::Ads::GoogleAds::V8::Resources::AdGroupAd->new({
      ad      => $ad,
      status  => PAUSED,
      adGroup => Google::Ads::GoogleAds::V8::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      )});

  # Create an ad group ad operation.
  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V8::Services::AdGroupAdService::AdGroupAdOperation
    ->new({create => $ad_group_ad});

  # Add the ad group ad.
  my $ad_group_ads_response = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]});

  printf "Created ad group ad with resource name: '%s'.\n",
    $ad_group_ads_response->{results}[0]{resourceName};

  return 1;
}

# Adds the media files by using the class constants.
sub add_media_files {
  my ($api_client, $customer_id) = @_;

  # Create the logo image data.
  my $logo_image_data = get_base64_data_from_url(LOGO_IMAGE_URL);

  # Create the logo image.
  my $logo_media_file = Google::Ads::GoogleAds::V8::Resources::MediaFile->new({
      type  => IMAGE,
      image => Google::Ads::GoogleAds::V8::Resources::MediaImage->new({
          data => $logo_image_data
        }
      ),
      mimeType => IMAGE_PNG
    });

  # Create the operation for the logo image.
  my $logo_media_file_operation =
    Google::Ads::GoogleAds::V8::Services::MediaFileService::MediaFileOperation
    ->new({
      create => $logo_media_file
    });

  # Create the marketing image data.
  my $marketing_image_data = get_base64_data_from_url(MARKETING_IMAGE_URL);

  # Create the marketing image.
  my $marketing_media_file =
    Google::Ads::GoogleAds::V8::Resources::MediaFile->new({
      type  => IMAGE,
      image => Google::Ads::GoogleAds::V8::Resources::MediaImage->new({
          data => $marketing_image_data
        }
      ),
      mimeType => IMAGE_JPEG
    });

  # Create the operation for the marketing image.
  my $marketing_media_file_operation =
    Google::Ads::GoogleAds::V8::Services::MediaFileService::MediaFileOperation
    ->new({
      create => $marketing_media_file
    });

  # Add the media files.
  my $media_files_response = $api_client->MediaFileService()->mutate({
      customerId => $customer_id,
      operations =>
        [$logo_media_file_operation, $marketing_media_file_operation]});

  foreach my $result (@{$media_files_response->{results}}) {
    printf "Created media file with resource name: '%s'.\n",
      $result->{resourceName};
  }

  # Return the created media file resource names.
  return {
    logo_image_resource_name =>
      $media_files_response->{results}[0]{resourceName},
    marketing_image_resource_name =>
      $media_files_response->{results}[1]{resourceName}};
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
  "customer_id=s" => \$customer_id,
  "ad_group_id=i" => \$ad_group_id,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $ad_group_id);

# Call the example.
add_gmail_ad($api_client, $customer_id =~ s/-//gr, $ad_group_id);

=pod

=head1 NAME

add_gmail_ad

=head1 DESCRIPTION

This example demonstrates how to add a Gmail ad to a given ad group. The ad
group's campaign needs to have an AdvertisingChannelType of DISPLAY and
AdvertisingChannelSubType of DISPLAY_GMAIL_AD.

=head1 SYNOPSIS

add_gmail_ad.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID.

=cut
