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
# This example sets ad parameters for an ad group criterion.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::AdParameter;
use
  Google::Ads::GoogleAds::V23::Services::AdParameterService::AdParameterOperation;
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
my $customer_id  = "INSERT_CUSTOMER_ID_HERE";
my $ad_group_id  = "INSERT_AD_GROUP_ID_HERE";
my $criterion_id = "INSERT_CRITERION_ID_HERE";

sub set_ad_parameters {
  my ($api_client, $customer_id, $ad_group_id, $criterion_id) = @_;

  my $ad_group_criterion_resource_name =
    Google::Ads::GoogleAds::V23::Utils::ResourceNames::ad_group_criterion(
    $customer_id, $ad_group_id, $criterion_id);

  # Create ad parameters.
  # There can be a maximum of two ad parameters per ad group criterion.
  # (One with parameter_index = 1 and one with parameter_index = 2.)
  my $ad_parameter_1 = Google::Ads::GoogleAds::V23::Resources::AdParameter->new(
    {
      adGroupCriterion => $ad_group_criterion_resource_name,
      # The unique index of this ad parameter. Must be either 1 or 2.
      parameterIndex => 1,
      # String containing a numeric value to insert into the ad text.
      # The following restrictions apply: (a) can use comma or period as a separator,
      # with an optional period or comma (respectively) for fractional values,
      # (b) can be prepended or appended with a currency code, (c) can use plus or minus,
      # (d) can use '/' between two numbers.
      insertionText => "100"
    });

  my $ad_parameter_2 = Google::Ads::GoogleAds::V23::Resources::AdParameter->new(
    {
      adGroupCriterion => $ad_group_criterion_resource_name,
      parameterIndex   => 2,
      insertionText    => "\$40"
    });

  # Create ad parameter operations.
  my $ad_parameter_operation1 =
    Google::Ads::GoogleAds::V23::Services::AdParameterService::AdParameterOperation
    ->new({create => $ad_parameter_1});

  my $ad_parameter_operation2 =
    Google::Ads::GoogleAds::V23::Services::AdParameterService::AdParameterOperation
    ->new({create => $ad_parameter_2});

  # Set the ad parameters.
  my $ad_parameters_response = $api_client->AdParameterService()->mutate({
      customerId => $customer_id,
      operations => [$ad_parameter_operation1, $ad_parameter_operation2]});

  my $ad_parameter_results = $ad_parameters_response->{results};
  printf "Set %d ad parameters:\n", scalar @$ad_parameter_results;

  foreach my $ad_parameter_result (@$ad_parameter_results) {
    printf "Set ad parameter '%s'.\n", $ad_parameter_result->{resourceName};
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
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"  => \$customer_id,
  "ad_group_id=i"  => \$ad_group_id,
  "criterion_id=i" => \$criterion_id,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $ad_group_id, $criterion_id);

# Call the example.
set_ad_parameters($api_client, $customer_id =~ s/-//gr,
  $ad_group_id, $criterion_id);

=pod

=head1 NAME

set_ad_parameters

=head1 DESCRIPTION

This example sets ad parameters for an ad group criterion.

=head1 SYNOPSIS

set_ad_parameters.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID.
    -criterion_id               The criterion ID.

=cut
