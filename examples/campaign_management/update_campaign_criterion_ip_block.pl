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
# This example demonstrates how to add a campaign-level IP exclusion.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V23::Resources::CampaignCriterion;
use
  Google::Ads::GoogleAds::V23::Services::CampaignCriterionService::CampaignCriterionOperation;
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
my $customer_id = "INSERT_CUSTOMER_ID_HERE";
my $campaign_id = "INSERT_CAMPAIGN_ID_HERE";

# ip_block criterion ID
my $CRITERION_ID = "27";
my $ip_block;

sub update_campaign_criterion_ip_block {
  my ($api_client, $customer_id, $campaign_id, $ip_block) = @_;

  my $resource_name =
    Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign_criterion(
    $customer_id, $campaign_id, $CRITERION_ID,);

  my $operations;
  foreach my $ip (split(',', $ip_block)) {
    # Create a campaign criterion with the specified resource name (ip_block) and
    # IP address which needs to be excluded.
    my $campaign_criterion =
      Google::Ads::GoogleAds::V23::Resources::CampaignCriterion->new({
        resourceName => $resource_name,
        negative     => 'True',
        ipBlock      => {
          ip_address => $ip,
        },
      });

    # Create the campaign criterion operation.
    my $campaign_criterion_operation =
      Google::Ads::GoogleAds::V23::Services::CampaignCriterionService::CampaignCriterionOperation
      ->new({
        create => $campaign_criterion,
        # To remove the IP block campaign criterion, use:
        # remove => <campaign_criterion_resource_name>
      });

    push @{$operations}, $campaign_criterion_operation;
  }
  # Issue a mutate request to create the campaign criteria for the IP addresses to exclude.
  my $campaign_criteria_response =
    $api_client->CampaignCriterionService()->mutate({
      customerId => $customer_id,
      operations => $operations,
    });

  foreach my $response (@{$campaign_criteria_response->{results}}) {
    # Print the resource name (ip_block) of the updated campaign criterion.
    printf "Campaign criterion with resource name '%s' was modified.\n",
      $response->{resourceName};
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
  "campaign_id=i" => \$campaign_id,
  "ip_block=s"    => \$ip_block,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $campaign_id, $ip_block);

# Call the example.
update_campaign_criterion_ip_block($api_client, $customer_id =~ s/-//gr,
  $campaign_id, $ip_block);

=pod

=head1 NAME

update_campaign_criterion_ip_block

=head1 DESCRIPTION

This example add given list of IPs to exclude for the given campaign.

=head1 SYNOPSIS

update_campaign_criterion_ip_block.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.
    -ip_block                   Comma separated IPs to block.

=cut
