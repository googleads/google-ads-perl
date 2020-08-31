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
# This example illustrates how to graduate a campaign experiment.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V5::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V5::Enums::BudgetDeliveryMethodEnum qw(STANDARD);
use
  Google::Ads::GoogleAds::V5::Services::CampaignBudgetService::CampaignBudgetOperation;
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
my $customer_id            = "INSERT_CUSTOMER_ID_HERE";
my $campaign_experiment_id = "INSERT_CAMPAIGN_EXPERIMENT_ID_HERE";

sub graduate_campaign_experiment {
  my ($api_client, $customer_id, $campaign_experiment_id) = @_;

  # Graduating a campaign experiment requires a new budget. Since the budget
  # for the base campaign has explicitly_shared set to false, the budget cannot
  # be shared with the campaign after it is made independent by graduation.
  my $campaign_budget =
    Google::Ads::GoogleAds::V5::Resources::CampaignBudget->new({
      name           => "Budget #" . uniqid(),
      amountMicros   => 50000000,
      deliveryMethod => STANDARD
    });

  # Create a campaign budget operation.
  my $campaign_budget_operation =
    Google::Ads::GoogleAds::V5::Services::CampaignBudgetService::CampaignBudgetOperation
    ->new({create => $campaign_budget});

  # Add the campaign budget.
  my $campaign_budget_resource_name =
    $api_client->CampaignBudgetService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_budget_operation]})->{results}[0]{resourceName};

  printf "Created new campaign budget '%s' to add to experiment" .
    " during graduation.\n",
    $campaign_budget_resource_name;

  # Graduate the campaign using the campaign budget created above.
  my $graduate_response = $api_client->CampaignExperimentService()->graduate({
      campaignExperiment =>
        Google::Ads::GoogleAds::V5::Utils::ResourceNames::campaign_experiment(
        $customer_id, $campaign_experiment_id
        ),
      campaignBudget => $campaign_budget_resource_name
    });

  printf "Campaign experiment '%s' is now graduated.\n",
    $graduate_response->{graduatedCampaign};

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
  "customer_id=s"            => \$customer_id,
  "campaign_experiment_id=i" => \$campaign_experiment_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $campaign_experiment_id);

# Call the example.
graduate_campaign_experiment($api_client, $customer_id =~ s/-//gr,
  $campaign_experiment_id);

=pod

=head1 NAME

graduate_campaign_experiment

=head1 DESCRIPTION

This example illustrates how to graduate a campaign experiment.

=head1 SYNOPSIS

graduate_campaign_experiment.pl [options]

    -help                                   Show the help message.
    -customer_id                            The Google Ads customer ID.
    -campaign_experiment_id                 The campaign experiment ID.

=cut
