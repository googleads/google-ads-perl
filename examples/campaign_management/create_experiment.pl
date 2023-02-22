#!/usr/bin/perl -w
#
# Copyright 2022, Google LLC
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
# This example creates a new experiment, experiment arms, and demonstrates
# how to modify the draft campaign as well as begin the experiment.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V13::Enums::ExperimentStatusEnum qw(SETUP);
use Google::Ads::GoogleAds::V13::Enums::ExperimentTypeEnum   qw(SEARCH_CUSTOM);
use Google::Ads::GoogleAds::V13::Resources::Campaign;
use Google::Ads::GoogleAds::V13::Resources::Experiment;
use Google::Ads::GoogleAds::V13::Resources::ExperimentArm;
use Google::Ads::GoogleAds::V13::Services::CampaignService::CampaignOperation;
use
  Google::Ads::GoogleAds::V13::Services::ExperimentService::ExperimentOperation;
use
  Google::Ads::GoogleAds::V13::Services::ExperimentArmService::ExperimentArmOperation;
use Google::Ads::GoogleAds::V13::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);
use POSIX        qw(strftime);

my $customer_id;
my $campaign_id;

sub create_experiment {
  my ($api_client, $customer_id, $campaign_id) = @_;

  my $experiment = create_experiment_resource($api_client, $customer_id);
  my $treatment_arm =
    create_experiment_arms($api_client, $customer_id, $campaign_id,
    $experiment);
  my $draft_campaign =
    fetch_draft_campaign($api_client, $customer_id, $treatment_arm);

  modify_draft_campaign($api_client, $customer_id, $draft_campaign);

  # When you're done setting up the experiment and arms and modifying the draft
  # campaign, this will begin the experiment.
  my $response = $api_client->ExperimentService()->schedule_experiment({
    # This is from the very first step above.
    resourceName => $experiment
  });

  return 1;
}

# [START create_experiment_1]
sub create_experiment_resource {
  my ($api_client, $customer_id) = @_;

  my $experiment = Google::Ads::GoogleAds::V13::Resources::Experiment->new({
    # Name must be unique.
    name   => "Example Experiment #" . uniqid(),
    type   => SEARCH_CUSTOM,
    suffix => "[experiment]",
    status => SETUP
  });

  my $operation =
    Google::Ads::GoogleAds::V13::Services::ExperimentService::ExperimentOperation
    ->new({
      create => $experiment
    });

  my $response = $api_client->ExperimentService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});

  my $resource_name = $response->{results}[0]{resourceName};
  printf "Created experiment with resource name '%s'.\n", $resource_name;
  return $resource_name;
}
# [END create_experiment_1]

# [START create_experiment_2]
sub create_experiment_arms {
  my ($api_client, $customer_id, $campaign_id, $experiment) = @_;

  my $operations = [];
  push @$operations,
    Google::Ads::GoogleAds::V13::Services::ExperimentArmService::ExperimentArmOperation
    ->new({
      create => Google::Ads::GoogleAds::V13::Resources::ExperimentArm->new({
          # The "control" arm references an already-existing campaign.
          control   => "true",
          campaigns => [
            Google::Ads::GoogleAds::V13::Utils::ResourceNames::campaign(
              $customer_id, $campaign_id
            )
          ],
          experiment   => $experiment,
          name         => "control arm",
          trafficSplit => 40
        })});

  push @$operations,
    Google::Ads::GoogleAds::V13::Services::ExperimentArmService::ExperimentArmOperation
    ->new({
      create => Google::Ads::GoogleAds::V13::Resources::ExperimentArm->new({
          # The non-"control" arm, also called a "treatment" arm, will automatically
          # generate draft campaigns that you can modify before starting the
          # experiment.
          control      => "false",
          experiment   => $experiment,
          name         => "experiment arm",
          trafficSplit => 60
        })});

  my $response = $api_client->ExperimentArmService()->mutate({
    customerId => $customer_id,
    operations => $operations
  });

  # Results always return in the order that you specify them in the request.
  # Since we created the treatment arm last, it will be the last result.  If
  # you don't remember which arm is the treatment arm, you can always filter
  # the query in the next section with `experiment_arm.control = false`.
  my $control_arm   = $response->{results}[0]{resourceName};
  my $treatment_arm = $response->{results}[1]{resourceName};

  printf "Created control arm with resource name '%s'.\n",   $control_arm;
  printf "Created treatment arm with resource name '%s'.\n", $treatment_arm;
  return $treatment_arm;
}
# [END create_experiment_2]

# [START create_experiment_3]
sub fetch_draft_campaign {
  my ($api_client, $customer_id, $treatment_arm) = @_;

  # The 'in_design_campaigns' represent campaign drafts, which you can modify
  # before starting the experiment.
  my $query =
    "SELECT experiment_arm.in_design_campaigns FROM experiment_arm " .
    "WHERE experiment_arm.resource_name = '$treatment_arm'";

  my $response = $api_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $query
  });

  # In design campaigns returns as an array, but for now it can only ever
  # contain a single ID, so we just grab the first one.
  my $draft_campaign =
    $response->{results}[0]->{experimentArm}{inDesignCampaigns}[0];

  printf "Found draft campaign with resource name '%s'.\n", $draft_campaign;
  return $draft_campaign;
}
# [END create_experiment_3]

sub modify_draft_campaign {
  my ($api_client, $customer_id, $draft_campaign) = @_;

  # In this block you can change anything you like about the campaign. These
  # are the changes you're testing by doing this experiment. Here we just
  # change the name for illustrative purposes, but generally you may want to
  # change more meaningful parts of the campaign.
  #
  # You can also change underlying resources, such as ad groups and keywords,
  # just as you would for any other campaign. When searching with the
  # GoogleAdsService, be sure to include a PARAMETERS clause with
  # `include_drafts = true` when searching for these draft entities.
  my $updated_campaign = Google::Ads::GoogleAds::V13::Resources::Campaign->new({
      resourceName => $draft_campaign,
      name => "Modified Campaign Name " . strftime("%Y%m%d", localtime(time))});

  my $operation =
    Google::Ads::GoogleAds::V13::Services::CampaignService::CampaignOperation->
    new({
      update     => $updated_campaign,
      updateMask => all_set_fields_of($updated_campaign)});

  my $response = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});

  printf "Updated the name for the campaign '%s'.\n", $draft_campaign;

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
  "base_campaign_id=i" => \$campaign_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $campaign_id);

# Call the example.
create_experiment($api_client, $customer_id =~ s/-//gr, $campaign_id);

=pod

=head1 NAME

create_experiment

=head1 DESCRIPTION

This example creates a new experiment, experiment arms, and demonstrates how to modify the draft
campaign as well as begin the experiment.

=head1 SYNOPSIS

create_experiment.pl [options]

    -help                            Show the help message.
    -customer_id                     The Google Ads customer ID.
    -base_campaign_id                   The base campaign ID.

=cut
