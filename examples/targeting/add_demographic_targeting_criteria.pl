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
# This example adds demographic target criteria to an ad group, one as positive
# ad group criterion and one as negative ad group criterion. To create ad groups,
# run add_ad_groups.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::AdGroupCriterion;
use Google::Ads::GoogleAds::V21::Common::GenderInfo;
use Google::Ads::GoogleAds::V21::Common::AgeRangeInfo;
use Google::Ads::GoogleAds::V21::Enums::GenderTypeEnum   qw(MALE);
use Google::Ads::GoogleAds::V21::Enums::AgeRangeTypeEnum qw(AGE_RANGE_18_24);
use
  Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

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

sub add_demographic_targeting_criteria {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  my $ad_group_resource_name =
    Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group($customer_id,
    $ad_group_id);

  # Create a positive ad group criterion for gender.
  my $gender_ad_group_criterion =
    Google::Ads::GoogleAds::V21::Resources::AdGroupCriterion->new({
      adGroup => $ad_group_resource_name,
      # Target male.
      gender => Google::Ads::GoogleAds::V21::Common::GenderInfo->new({
          type => MALE
        })});

  # Create a negative ad group criterion for age range.
  my $age_range_negative_ad_group_criterion =
    Google::Ads::GoogleAds::V21::Resources::AdGroupCriterion->new({
      adGroup => $ad_group_resource_name,
      # Make this ad group criterion negative.
      negative => "true",
      # Target the age range of 18 to 24.
      ageRange => Google::Ads::GoogleAds::V21::Common::AgeRangeInfo->new({
          type => AGE_RANGE_18_24
        })});

  # Create ad group criterion operations for both ad group criteria.
  my $operations = [
    Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
      ->new({
        create => $gender_ad_group_criterion
      }
      ),
    Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
      ->new({
        create => $age_range_negative_ad_group_criterion
      })];

  # Issue a mutate request to add the ad group criteria and print out some information.
  my $ad_group_criteria_response =
    $api_client->AdGroupCriterionService()->mutate({
      customerId => $customer_id,
      operations => $operations
    });

  my $ad_group_criterion_results = $ad_group_criteria_response->{results};
  printf "Added %d demographic ad group criteria:\n",
    scalar @$ad_group_criterion_results;

  foreach my $ad_group_criterion_result (@$ad_group_criterion_results) {
    printf "\t%s\n", $ad_group_criterion_result->{resourceName};
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
  "customer_id=s" => \$customer_id,
  "ad_group_id=i" => \$ad_group_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $ad_group_id);

# Call the example.
add_demographic_targeting_criteria($api_client, $customer_id =~ s/-//gr,
  $ad_group_id);

=pod

=head1 NAME

add_demographic_targeting_criteria

=head1 DESCRIPTION

This example adds demographic target criteria to an ad group, one as positive ad
group criterion and one as negative ad group criterion. To create ad groups, run
add_ad_groups.pl.

=head1 SYNOPSIS

add_demographic_targeting_criteria.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID.

=cut
