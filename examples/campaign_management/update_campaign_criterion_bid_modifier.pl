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
# This example updates a campaign criterion with a new bid modifier value.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V21::Resources::CampaignCriterion;
use
  Google::Ads::GoogleAds::V21::Services::CampaignCriterionService::CampaignCriterionOperation;
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
my $customer_id  = "INSERT_CUSTOMER_ID_HERE";
my $campaign_id  = "INSERT_CAMPAIGN_ID_HERE";
my $criterion_id = "INSERT_CRITERION_ID_HERE";
# Specify the bid modifier value here or the default specified below will be used.
my $bid_modifier_value = 1.5;

sub update_campaign_criterion_bid_modifier {
  my ($api_client, $customer_id, $campaign_id, $criterion_id,
    $bid_modifier_value)
    = @_;

  # Create a campaign criterion with the specified resource name and updated bid
  # modifier value.
  my $campaign_criterion =
    Google::Ads::GoogleAds::V21::Resources::CampaignCriterion->new({
      resourceName =>
        Google::Ads::GoogleAds::V21::Utils::ResourceNames::campaign_criterion(
        $customer_id, $campaign_id, $criterion_id
        ),
      bidModifier => $bid_modifier_value
    });

  # Create the campaign criterion operation.
  my $campaign_criterion_operation =
    Google::Ads::GoogleAds::V21::Services::CampaignCriterionService::CampaignCriterionOperation
    ->new({
      update     => $campaign_criterion,
      updateMask => all_set_fields_of($campaign_criterion)});

  # Issue a mutate request to update the bid modifier of campaign criterion.
  my $campaign_criteria_response =
    $api_client->CampaignCriterionService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_criterion_operation]});

  # Print the resource name of the updated campaign criterion.
  printf "Campaign criterion with resource name '%s' was modified.\n",
    $campaign_criteria_response->{results}[0]{resourceName};

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
  "customer_id=s"        => \$customer_id,
  "campaign_id=i"        => \$campaign_id,
  "criterion_id=i"       => \$criterion_id,
  "bid_modifier_value=f" => \$bid_modifier_value
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $campaign_id, $criterion_id,
  $bid_modifier_value);

# Call the example.
update_campaign_criterion_bid_modifier($api_client, $customer_id =~ s/-//gr,
  $campaign_id, $criterion_id, $bid_modifier_value);

=pod

=head1 NAME

update_campaign_criterion_bid_modifier

=head1 DESCRIPTION

This example updates a campaign criterion with a new bid modifier value.

=head1 SYNOPSIS

update_campaign_criterion_bid_modifier.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.
    -criterion_id               The ID of the campaign criterion to update.
    -bid_modifier_value         [optional] The bid modifier value to set.

=cut
