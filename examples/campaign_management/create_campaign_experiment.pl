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
# This example illustrates how to begin creation of a campaign experiment from a
# draft and wait for it to complete.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V5::Resources::CampaignExperiment;
use Google::Ads::GoogleAds::V5::Enums::CampaignExperimentTrafficSplitTypeEnum
  qw(RANDOM_QUERY);
use Google::Ads::GoogleAds::V5::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use Data::Uniqid qw(uniqid);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id      = "INSERT_CUSTOMER_ID_HERE";
my $base_campaign_id = "INSERT_BASE_CAMPAIGN_ID_HERE";
my $draft_id         = "INSERT_DRAFT_ID_HERE";

sub create_campaign_experiment {
  my ($api_client, $customer_id, $base_campaign_id, $draft_id) = @_;

  # Create a campaign experiment.
  my $campaign_experiment =
    Google::Ads::GoogleAds::V5::Resources::CampaignExperiment->new({
      campaignDraft =>
        Google::Ads::GoogleAds::V5::Utils::ResourceNames::campaign_draft(
        $customer_id, $base_campaign_id, $draft_id
        ),
      name                => "Campaign Experiment #" . uniqid(),
      trafficSplitPercent => 50,
      trafficSplitType    => RANDOM_QUERY
    });

  # A Long Running Operation (LRO) is returned from this asynchronous request
  # by the API.
  my $campaign_experiment_lro =
    $api_client->CampaignExperimentService()->create({
      customerId         => $customer_id,
      campaignExperiment => $campaign_experiment
    });

  printf "Asynchronous request to create campaign experiment with " .
    "resource name '%s' started.\n",
    $campaign_experiment_lro->{metadata}{campaignExperiment};

  printf "Waiting until operation completes.\n";

  # Poll until the operation completes.
  $campaign_experiment_lro = $api_client->OperationService()->poll_until_done({
      name => $campaign_experiment_lro->{name}});

  # Retrieve the campaign experiment that has been created.
  my $search_query =
    sprintf "SELECT campaign_experiment.experiment_campaign " .
    "FROM campaign_experiment " .
    "WHERE campaign_experiment.resource_name = '%s'",
    $campaign_experiment_lro->{metadata}{campaignExperiment};

  my $search_response = $api_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $search_query
  });

  printf "Experiment campaign '%s' finished creation.\n",
    $search_response->{results}[0]{campaignExperiment}{experimentCampaign};

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
  "customer_id=s"      => \$customer_id,
  "base_campaign_id=i" => \$base_campaign_id,
  "draft_id=i"         => \$draft_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $base_campaign_id, $draft_id);

# Call the example.
create_campaign_experiment($api_client, $customer_id =~ s/-//gr,
  $base_campaign_id, $draft_id);

=pod

=head1 NAME

create_campaign_experiment

=head1 DESCRIPTION

This example illustrates how to begin creation of a campaign experiment from a
draft and wait for it to complete.

=head1 SYNOPSIS

create_campaign_experiment.pl [options]

    -help                            Show the help message.
    -customer_id                     The Google Ads customer ID.
    -base_campaign_id                The base campaign ID.
    -draft_id                        The draft ID used to create an experiment

=cut
