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
# This example illustrates the use of custom client timeouts and retry delays
# in the context of server streaming and unary calls.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator;
use
  Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;
use
  Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

# 5 minutes in seconds.
use constant CLIENT_TIMEOUT_SECONDS => 5 * 60;
# The query to retrieve all campaign IDs.
use constant SEARCH_QUERY => "SELECT campaign.id FROM campaign";
# The message returned in the HTTP response for request timeout.
use constant HTTP_TIMEOUT_MESSAGE => "read timeout";
# Maximum number of retries.
use constant MAX_RETRIES => 3;
# Number of seconds to wait on the first retry.
use constant RETRY_INITIAL_DELAY_SECONDS => 15;
# Retry delay multiplier for exponential backoffs.
use constant RETRY_DELAY_MULTIPLIER => 2;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub set_custom_client_timeouts {
  my ($api_client, $customer_id) = @_;

  make_server_streaming_call($api_client, $customer_id);
  make_unary_call($api_client, $customer_id);

  return 1;
}

# Makes a server streaming call using a custom client timeout.
sub make_server_streaming_call {
  my ($api_client, $customer_id) = @_;

  # Any server streaming call has a default timeout setting, which can be found
  # in the module of Google::Ads::GoogleAds::Constants.
  #
  # A new value can be provided to override the default timeout setting in the
  # API client.
  $api_client->set_http_timeout(CLIENT_TIMEOUT_SECONDS);

  # Create a search Google Ads stream request that will retrieve all campaign IDs.
  my $search_stream_request =
    Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => SEARCH_QUERY
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $output = "";
  eval {
    my $search_stream_handler =
      Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
        service => $google_ads_service,
        request => $search_stream_request
      });

    # Iterate over all rows in all messages and collect the campaign IDs.
    $search_stream_handler->process_contents(
      sub {
        my $google_ads_row = shift;
        $output .= ' ' . $google_ads_row->{campaign}{id};
      });
    print "The server streaming call completed before the timeout.\n";
  };
  if ($@) {
    my $response_message = $api_client->get_last_response()->message;
    # The LWP::UserAgent module returns a "read timeout" message in the HTTP
    # response for request timeout.
    if ($response_message =~ m/${\HTTP_TIMEOUT_MESSAGE}/) {
      print "The server streaming call did not complete before the timeout.\n";
    } else {
      # Bubble up if the exception is not about timeout.
      die $$response_message;
    }
  }

  print "All campaign IDs retrieved : " . ($output ? $output : "None") . "\n";
}

# Makes an unary call using a custom client timeout.
sub make_unary_call {
  my ($api_client, $customer_id) = @_;

  # Any unary call has a default timeout setting, which can be found in the
  # module of Google::Ads::GoogleAds::Constants.
  #
  # A new value can be provided to override the default timeout setting in the
  # API client.
  $api_client->set_http_timeout(CLIENT_TIMEOUT_SECONDS);

  # Override default retry setting, which can be found in the module of
  # Google::Ads::GoogleAds::Constants.
  #
  # This sets the retry timing based on the initial delay, the delay multiplier,
  # and the maximum number of retries.
  my $http_retry_timing = "" . RETRY_INITIAL_DELAY_SECONDS;
  if (MAX_RETRIES > 1) {
    my $delay = RETRY_INITIAL_DELAY_SECONDS;
    for my $i (1 .. (MAX_RETRIES - 1)) {
      $delay             = $delay * RETRY_DELAY_MULTIPLIER;
      $http_retry_timing = $http_retry_timing . "," . $delay;
    }
  }
  $api_client->set_http_retry_timing($http_retry_timing);

  # Create a search Google Ads request that will retrieve all campaign IDs.
  my $search_request =
    Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsRequest
    ->new({
      customerId => $customer_id,
      query      => SEARCH_QUERY,
    });

  # Get the GoogleAdsService.
  my $google_ads_service = $api_client->GoogleAdsService();

  my $output = "";
  eval {
    my $iterator = Google::Ads::GoogleAds::Utils::SearchGoogleAdsIterator->new({
      service => $google_ads_service,
      request => $search_request
    });

    # Iterate over all rows in all messages and collect the campaign IDs.
    while ($iterator->has_next) {
      my $google_ads_row = $iterator->next;
      $output .= ' ' . $google_ads_row->{campaign}{id};
    }
    print "The unary call completed before the timeout.\n";
  };
  if ($@) {
    my $response_message = $api_client->get_last_response()->message;
    # The LWP::UserAgent module returns a "read timeout" message in the HTTP
    # response for request timeout.
    if ($response_message =~ m/${\HTTP_TIMEOUT_MESSAGE}/) {
      print "The unary call did not complete before the timeout.\n";
    } else {
      # Bubble up if the exception is not about timeout.
      die $$response_message;
    }
  }

  print "All campaign IDs retrieved : " . ($output ? $output : "None") . "\n";
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
set_custom_client_timeouts($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

set_custom_client_timeouts

=head1 DESCRIPTION

This example illustrates the use of custom client timeouts and retry delays
in the context of server streaming and unary calls.

=head1 SYNOPSIS

set_custom_client_timeouts.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
