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
# Handles RateExceededError in an application. This code example runs 5 requests
# sequentially, each request attempting to validate 100 keywords. While it is
# unlikely that running these requests would trigger a rate exceeded error,
# substantially increasing the number of requests may have that effect. Note that
# this example is for illustrative purposes only, and you shouldn't intentionally
# try to trigger a rate exceed error in your application.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::AdGroupCriterion;
use Google::Ads::GoogleAds::V21::Common::KeywordInfo;
use Google::Ads::GoogleAds::V21::Enums::KeywordMatchTypeEnum       qw(EXACT);
use Google::Ads::GoogleAds::V21::Enums::AdGroupCriterionStatusEnum qw(ENABLED);
use
  Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd         qw(abs_path);
use Time::HiRes qw(sleep);

# Number of requests to be run.
use constant NUM_REQUESTS => 5;
# Number of keywords to be validated in each API call.
use constant NUM_KEYWORDS => 100;
# Number of retries to be run in case of a RateExceededError.
use constant NUM_RETRIES => 3;
# Minimum number of seconds to wait before a retry.
use constant RETRY_SECONDS => 10;

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

sub handle_rate_exceeded_error {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  # Sequentially send the requests.
  for (my $i = 0 ; $i < NUM_REQUESTS ; $i++) {
    # Create operations.
    my $operations =
      create_ad_group_criterion_operations($customer_id, $ad_group_id, $i);

    eval {
      my $retry_count   = 0;
      my $retry_seconds = RETRY_SECONDS;
      while ($retry_count < NUM_RETRIES) {
        # Send request.
        my $response =
          request_mutate_and_display_result($api_client, $customer_id,
          $operations);
        if ($response->isa("Google::Ads::GoogleAds::GoogleAdsException")) {
          my $has_rate_exceeded_error = 0;
          foreach my $error (@{$response->get_google_ads_failure()->{errors}}) {
            # Check if any of the errors are QuotaError.RESOURCE_EXHAUSTED or
            # QuotaError.RESOURCE_TEMPORARILY_EXHAUSTED.
            my $quota_error = $error->{errorCode}{quotaError};
            if ($quota_error && grep /^$quota_error/,
              ("RESOURCE_EXHAUSTED", "RESOURCE_TEMPORARILY_EXHAUSTED"))
            {
              printf "Received rate exceeded error, retry after %d seconds.\n",
                $retry_seconds;
              sleep($retry_seconds);
              $has_rate_exceeded_error = 1;
              $retry_count++;
              # Use an exponential back-off policy.
              $retry_seconds *= 2;
              last;
            }
          }
          # Bubble up when there is not RateExceededError.
          if (not $has_rate_exceeded_error) {
            die $response->get_message();
          }
        } else {
          last;
        }

        # Bubble up when the number of retries has already been reached.
        if ($retry_count == NUM_RETRIES) {
          die "Could not recover after making $retry_count attempts.\n",;
        }
      }
    };

    if ($@) {
      # Catch and print any unhandled exception.
      printf "Failed to validate keywords.\n%s", $@;
      return 0;
    }
  }

  return 1;
}

# Creates ad group criterion operations.
sub create_ad_group_criterion_operations {
  my ($customer_id, $ad_group_id, $request_index) = @_;

  my $operations = [];
  for (my $i = 0 ; $i < NUM_KEYWORDS ; $i++) {
    # Create a keyword info.
    my $keyword_info = Google::Ads::GoogleAds::V21::Common::KeywordInfo->new({
      text      => "mars cruise req " . $request_index . " seed " . $i,
      matchType => EXACT
    });

    # Construct an ad group criterion using the keyword text info above.
    my $ad_group_criterion =
      Google::Ads::GoogleAds::V21::Resources::AdGroupCriterion->new({
        adGroup => Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group(
          $customer_id, $ad_group_id
        ),
        status  => ENABLED,
        keyword => $keyword_info
      });

    # Create an ad group criterion operation.
    my $ad_group_criterion_operation =
      Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
      ->new({
        create => $ad_group_criterion
      });
    push @$operations, $ad_group_criterion_operation;
  }
  return $operations;
}

# Requests a mutate of ad group criterion operations and displays the results.
sub request_mutate_and_display_result {
  my ($api_client, $customer_id, $operations) = @_;

  # Make a validateOnly mutate request.
  my $ad_group_criteria_response =
    $api_client->AdGroupCriterionService()->mutate({
      customerId     => $customer_id,
      operations     => $operations,
      partialFailure => "false",
      validateOnly   => "true"
    });

  # Display the results.
  if (
    not $ad_group_criteria_response->isa(
      "Google::Ads::GoogleAds::GoogleAdsException"))
  {
    my $ad_group_criterion_results = $ad_group_criteria_response->{results};
    printf "Added %d ad group criteria:\n", scalar @$ad_group_criterion_results;
    foreach my $ad_group_criterion_result (@$ad_group_criterion_results) {
      print $ad_group_criterion_result->{resourceName}, "\n";
    }
  }

  return $ad_group_criteria_response;
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(0);

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id, "ad_group_id=i" => \$ad_group_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $ad_group_id);

# Call the example.
handle_rate_exceeded_error($api_client, $customer_id =~ s/-//gr, $ad_group_id);

=pod

=head1 NAME

handle_rate_exceeded_error

=head1 DESCRIPTION

Handles RateExceededError in an application. This code example runs 5 requests
sequentially, each request attempting to validate 100 keywords. While it is
unlikely that running these requests would trigger a rate exceeded error,
substantially increasing the number of requests may have that effect. Note that
this example is for illustrative purposes only, and you shouldn't intentionally
try to trigger a rate exceed error in your application.

=head1 SYNOPSIS

handle_rate_exceeded_error.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID.

=cut
