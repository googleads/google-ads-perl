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
# This example shows how to deal with partial failures. There are several ways
# of detecting partial failures. This example highlights the top main detection
# options: empty results and error instances.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::PartialFailureUtils;
use Google::Ads::GoogleAds::V23::Resources::AdGroup;
use Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation;
use Google::Ads::GoogleAds::V23::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";
my $campaign_id = "INSERT_CAMPAIGN_ID_HERE";

sub handle_partial_failure {
  my ($api_client, $customer_id, $campaign_id) = @_;

  my $ad_groups_response =
    create_ad_groups($api_client, $customer_id, $campaign_id);
  check_if_partial_failure_error_exists($ad_groups_response);
  print_results($ad_groups_response);

  return 1;
}

# Creates ad groups by enabling partial failure mode.
# [START handle_partial_failure]
sub create_ad_groups {
  my ($api_client, $customer_id, $campaign_id) = @_;

  my $campaign_resource_name =
    Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign($customer_id,
    $campaign_id);

  # This ad group should be created successfully - assuming the campaign in the
  # params exists.
  my $ad_group1 = Google::Ads::GoogleAds::V23::Resources::AdGroup->new({
    name     => "Valid AdGroup: " . uniqid(),
    campaign => $campaign_resource_name
  });

  # This ad group will always fail - campaign ID 0 in the resource name is never
  # valid.
  my $ad_group2 = Google::Ads::GoogleAds::V23::Resources::AdGroup->new({
      name     => "Broken AdGroup: " . uniqid(),
      campaign => Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign(
        $customer_id, 0
      )});

  # This ad group will always fail - duplicate ad group names are not allowed.
  my $ad_group3 = Google::Ads::GoogleAds::V23::Resources::AdGroup->new({
    name     => $ad_group1->{name},
    campaign => $campaign_resource_name
  });

  # Create ad group operations.
  my $ad_group_operation1 =
    Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation->
    new({create => $ad_group1});
  my $ad_group_operation2 =
    Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation->
    new({create => $ad_group2});
  my $ad_group_operation3 =
    Google::Ads::GoogleAds::V23::Services::AdGroupService::AdGroupOperation->
    new({create => $ad_group3});

  # Issue the mutate request, enabling partial failure mode.
  my $ad_groups_response = $api_client->AdGroupService()->mutate({
    customerId => $customer_id,
    operations =>
      [$ad_group_operation1, $ad_group_operation2, $ad_group_operation3],
    partialFailure => "true"
  });

  return $ad_groups_response;
}
# [END handle_partial_failure]

# Checks if partial failure error exists in the given mutate ad group response.
# [START handle_partial_failure_1]
sub check_if_partial_failure_error_exists {
  my $ad_groups_response = shift;

  if ($ad_groups_response->{partialFailureError}) {
    print "Partial failures occurred. Details will be shown below.\n";
  } else {
    print
      "All operations completed successfully. No partial failures to show.\n";
  }
}
# [END handle_partial_failure_1]

# Prints results of the given mutate ad group response. For those that are partial
# failure, prints all their errors with corresponding operation indices. For those
# that succeeded, prints the resource names of created ad groups.
# [START handle_partial_failure_2]
sub print_results {
  my $ad_groups_response = shift;

  # Find the failed operations by looping through the results.
  while (my ($operation_index, $result) =
    each @{$ad_groups_response->{results}})
  {
    if (is_partial_failure_result($result)) {
      my $google_ads_errors = get_google_ads_errors($operation_index,
        $ad_groups_response->{partialFailureError});

      foreach my $google_ads_error (@$google_ads_errors) {
        printf "Operation %d failed with error: %s\n", $operation_index,
          $google_ads_error->{message};
      }
    } else {
      printf "Operation %d succeeded: ad group with resource name '%s'.\n",
        $operation_index, $result->{resourceName};
    }
  }
}
# [END handle_partial_failure_2]

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id, "campaign_id=i" => \$campaign_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $campaign_id);

# Call the example.
handle_partial_failure($api_client, $customer_id =~ s/-//gr, $campaign_id);

=pod

=head1 NAME

handle_partial_failure

=head1 DESCRIPTION

This example shows how to deal with partial failures. There are several ways of
detecting partial failures. This example highlights the top main detection
options: empty results and error instances.

=head1 SYNOPSIS

handle_partial_failure.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.

=cut
