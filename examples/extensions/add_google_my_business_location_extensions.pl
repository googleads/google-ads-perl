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
# This example adds a feed that syncs feed items from a Google My Business (GMB)
# account and associates the feed with a customer.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Constants;
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V3::Resources::Feed;
use Google::Ads::GoogleAds::V3::Resources::PlacesLocationFeedData;
use Google::Ads::GoogleAds::V3::Resources::OAuthInfo;
use Google::Ads::GoogleAds::V3::Resources::CustomerFeed;
use Google::Ads::GoogleAds::V3::Common::MatchingFunction;
use Google::Ads::GoogleAds::V3::Common::Operand;
use Google::Ads::GoogleAds::V3::Common::ConstantOperand;
use Google::Ads::GoogleAds::V3::Enums::FeedOriginEnum qw(GOOGLE);
use Google::Ads::GoogleAds::V3::Enums::PlaceholderTypeEnum qw(LOCATION);
use Google::Ads::GoogleAds::V3::Enums::MatchingFunctionOperatorEnum
  qw(IDENTITY);
use Google::Ads::GoogleAds::V3::Services::FeedService::FeedOperation;
use
  Google::Ads::GoogleAds::V3::Services::CustomerFeedService::CustomerFeedOperation;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use Data::Uniqid qw(uniqid);
use Time::HiRes qw(sleep);

use constant MAX_CUSTOMER_FEED_ADD_ATTEMPTS => 10;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id         = "INSERT_CUSTOMER_ID_HERE";
my $gmb_email_address   = "INSERT_GMB_EMAIL_ADDRESS_HERE";
my $business_account_id = "INSERT_BUSINESS_ACCOUNT_ID_HERE";
my $gmb_access_token    = "INSERT_GMB_ACCESS_TOKEN_HERE";

sub add_google_my_business_location_extensions {
  my ($api_client, $customer_id, $gmb_email_address, $business_account_id,
    $gmb_access_token)
    = @_;

  # Create a feed that will sync to the Google My Business account specified by
  # $gmb_email_address. Do not add FeedAttributes to this object as Google Ads
  # will add them automatically because this will be a system generated feed.
  my $gmb_feed = Google::Ads::GoogleAds::V3::Resources::Feed->new({
      name => "Google My Business feed #" . uniqid(),
      # Configure the location feed populated from Google My Business Locations.
      placesLocationFeedData =>
        Google::Ads::GoogleAds::V3::Resources::PlacesLocationFeedData->new({
          emailAddress      => $gmb_email_address,
          businessAccountId => $business_account_id,
          # Used to filter Google My Business listings by labels. If entries exist in
          # label_filters, only listings that have at least one of the labels set are
          # candidates to be synchronized into FeedItems. If no entries exist in
          # label_filters, then all listings are candidates for syncing.
          labelFilters => ["Stores in New York"],
          # Set the authentication info to be able to connect Google Ads to the GMB
          # account.
          oauthInfo => Google::Ads::GoogleAds::V3::Resources::OAuthInfo->new({
              httpMethod => "GET",
              httpRequestUrl =>
                Google::Ads::GoogleAds::Constants::DEFAULT_OAUTH2_SCOPE,
              httpAuthorizationHeader => "Bearer " . $gmb_access_token
            })}
        ),
      # Since this feed's feed items will be managed by Google, you must set its
      # origin to GOOGLE.
      origin => GOOGLE
    });

  # Create a feed operation.
  my $feed_operation =
    Google::Ads::GoogleAds::V3::Services::FeedService::FeedOperation->new(
    {create => $gmb_feed});

  # Add the feed. Since it is a system generated feed, Google Ads will automatically:
  # 1. Set up the FeedAttributes on the feed.
  # 2. Set up a FeedMapping that associates the FeedAttributes of the feed with the
  #    placeholder fields of the LOCATION placeholder type.
  my $feed_response = $api_client->FeedService()->mutate({
      customerId => $customer_id,
      operations => [$feed_operation]});

  my $feed_resource_name = $feed_response->{results}[0]{resourceName};

  printf "GMB feed created with resource name: '%s'.\n", $feed_resource_name;

  # Add a CustomerFeed that associates the feed with this customer for the LOCATION
  # placeholder type.
  my $customer_feed = Google::Ads::GoogleAds::V3::Resources::CustomerFeed->new({
      feed             => $feed_resource_name,
      placeholderTypes => LOCATION,
      # Create a matching function that will always evaluate to true.
      matchingFunction =>
        Google::Ads::GoogleAds::V3::Common::MatchingFunction->new({
          leftOperands => [
            Google::Ads::GoogleAds::V3::Common::Operand->new({
                constantOperand =>
                  Google::Ads::GoogleAds::V3::Common::ConstantOperand->new({
                    booleanValue => "true"
                  })})
          ],
          functionString => "IDENTITY(true)",
          operator       => IDENTITY
        })});

  # Create a customer feed operation.
  my $customer_feed_operation =
    Google::Ads::GoogleAds::V3::Services::CustomerFeedService::CustomerFeedOperation
    ->new({create => $customer_feed});

  # After the completion of the Feed ADD operation above the added feed will not be available
  # for usage in a CustomerFeed until the sync between the Google Ads and GMB accounts
  # completes. The loop below will retry adding the CustomerFeed up to ten times with an
  # exponential back-off policy.
  my $customer_feed_service       = $api_client->CustomerFeedService();
  my $customer_feed_resource_name = undef;
  my $number_of_attempts          = 0;

  while ($number_of_attempts < MAX_CUSTOMER_FEED_ADD_ATTEMPTS) {
    $number_of_attempts++;

    my $customer_feed_response = eval {
      $customer_feed_service->mutate({
        customerId => $customer_id,
        operations => [$customer_feed_operation],
      });
    };

    if ($@) {
      # Wait using exponential backoff policy.
      my $sleep_seconds = 5 * (2**$number_of_attempts);

      # Exit the loop early if $sleep_seconds grows too large in the event that
      # MAX_CUSTOMER_FEED_ADD_ATTEMPTS is set too high.
      if ($sleep_seconds > 5 * (2**10)) {
        last;
      }

      printf "Attempt #%d to add the CustomerFeed was not successful. " .
        "Waiting %d seconds before trying again.\n",
        $number_of_attempts, $sleep_seconds;

      sleep($sleep_seconds);
    } else {
      $customer_feed_resource_name =
        $customer_feed_response->{results}[0]{resourceName};

      printf "Customer feed created with resource name: '%s'.\n",
        $customer_feed_resource_name;

      last;
    }
  }

  printf "Could not create the CustomerFeed after %d attempts. " .
    "Please retry the CustomerFeed ADD operation later.",
    MAX_CUSTOMER_FEED_ADD_ATTEMPTS
    if not $customer_feed_resource_name;

  # OPTIONAL: Create a CampaignFeed to specify which FeedItems to use at the Campaign level.

  # OPTIONAL: Create an AdGroupFeed for even more fine grained control over which feed items
  # are used at the AdGroup level.

  return 1;
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new({version => "V3"});

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"         => \$customer_id,
  "gmb_email_address=s"   => \$gmb_email_address,
  "business_account_id=s" => \$business_account_id,
  "gmb_access_token=s"    => \$gmb_access_token,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $gmb_email_address,
  $business_account_id, $gmb_access_token);

# Call the example.
add_google_my_business_location_extensions(
  $api_client, $customer_id =~ s/-//gr, $gmb_email_address,
  $business_account_id, $gmb_access_token
);

=pod

=head1 NAME

add_google_my_business_location_extensions

=head1 DESCRIPTION

This example adds a feed that syncs feed items from a Google My Business (GMB)
account and associates the feed with a customer.

=head1 SYNOPSIS

add_google_my_business_location_extensions.pl [options]

    -help                               Show the help message.
    -customer_id                        The Google Ads customer ID.
    -gmb_email_address                  The email address associated with the GMB account.
    -business_account_id                The account ID of the managed business.
    -gmb_access_token                   The access token created using the 'AdWords' scope
                                        and the client ID and client secret of with the
                                        Cloud project associated with the GMB account.

=cut
