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
# This example demonstrates how to add a keyword to an ad group. To get keywords,
# run get_keywords.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V13::Resources::AdGroupCriterion;
use Google::Ads::GoogleAds::V13::Common::KeywordInfo;
use Google::Ads::GoogleAds::V13::Enums::AdGroupCriterionStatusEnum qw(ENABLED);
use Google::Ads::GoogleAds::V13::Enums::KeywordMatchTypeEnum       qw(EXACT);
use
  Google::Ads::GoogleAds::V13::Services::AdGroupCriterionService::AdGroupCriterionOperation;
use Google::Ads::GoogleAds::V13::Utils::ResourceNames;

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
my $keyword_text = "mars cruise";

sub add_keywords {
  my ($api_client, $customer_id, $ad_group_id, $keyword_text) = @_;

  # Create a keyword.
  my $ad_group_criterion =
    Google::Ads::GoogleAds::V13::Resources::AdGroupCriterion->new({
      adGroup => Google::Ads::GoogleAds::V13::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      status  => ENABLED,
      keyword => Google::Ads::GoogleAds::V13::Common::KeywordInfo->new({
          text      => $keyword_text,
          matchType => EXACT
        })});

  # Create an ad group criterion operation.
  my $ad_group_criterion_operation =
    Google::Ads::GoogleAds::V13::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({create => $ad_group_criterion});

  # Add the keyword.
  my $ad_group_criteria_response =
    $api_client->AdGroupCriterionService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_criterion_operation]});

  printf "Created keyword '%s'.\n",
    $ad_group_criteria_response->{results}[0]{resourceName};

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
  "keyword_text=s" => \$keyword_text
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $ad_group_id, $keyword_text);

# Call the example.
add_keywords($api_client, $customer_id =~ s/-//gr, $ad_group_id, $keyword_text);

=pod

=head1 NAME

add_keywords

=head1 DESCRIPTION

This example demonstrates how to add a keyword to an ad group. To get keywords,
run get_keywords.pl.

=head1 SYNOPSIS

add_keywords.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID.
    -keyword_text               [optional] The keyword to be added to the ad group.

=cut
