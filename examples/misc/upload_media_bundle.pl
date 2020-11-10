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
# This example uploads an HTML5 zip file as a media bundle.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::MediaUtils;
use Google::Ads::GoogleAds::V6::Resources::MediaFile;
use Google::Ads::GoogleAds::V6::Resources::MediaBundle;
use Google::Ads::GoogleAds::V6::Enums::MediaTypeEnum qw(MEDIA_BUNDLE);
use Google::Ads::GoogleAds::V6::Services::MediaFileService::MediaFileOperation;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

use constant BUNDLE_URL => "https://goo.gl/9Y7qI2";

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub upload_media_bundle {
  my ($api_client, $customer_id) = @_;

  # Create an HTML5 zip file media bundle content.
  my $bundle_content = get_base64_data_from_url(BUNDLE_URL);

  # Create a media file.
  my $media_file = Google::Ads::GoogleAds::V6::Resources::MediaFile->new({
      name        => "Ad Media Bundle",
      type        => MEDIA_BUNDLE,
      mediaBundle => Google::Ads::GoogleAds::V6::Resources::MediaBundle->new({
          data => $bundle_content
        })});

  # Create a media file operation.
  my $media_file_operation =
    Google::Ads::GoogleAds::V6::Services::MediaFileService::MediaFileOperation
    ->new({
      create => $media_file
    });

  # Issue a mutate request to add the media file.
  my $media_file_response = $api_client->MediaFileService()->mutate({
      customerId => $customer_id,
      operations => [$media_file_operation]});

  printf "The media bundle with resource name '%s' was added.\n",
    $media_file_response->{results}[0]{resourceName};

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
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
upload_media_bundle($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

upload_media_bundle

=head1 DESCRIPTION

This example uploads an HTML5 zip file as a media bundle.

=head1 SYNOPSIS

upload_media_bundle.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
