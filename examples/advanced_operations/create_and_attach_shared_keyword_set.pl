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
# This example creates a shared list of negative broad match keywords. It then
# attaches them to a campaign.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::SharedSet;
use Google::Ads::GoogleAds::V23::Resources::SharedCriterion;
use Google::Ads::GoogleAds::V23::Resources::CampaignSharedSet;
use Google::Ads::GoogleAds::V23::Common::KeywordInfo;
use Google::Ads::GoogleAds::V23::Enums::SharedSetTypeEnum qw(NEGATIVE_KEYWORDS);
use Google::Ads::GoogleAds::V23::Enums::KeywordMatchTypeEnum qw(BROAD);
use Google::Ads::GoogleAds::V23::Services::SharedSetService::SharedSetOperation;
use
  Google::Ads::GoogleAds::V23::Services::SharedCriterionService::SharedCriterionOperation;
use
  Google::Ads::GoogleAds::V23::Services::CampaignSharedSetService::CampaignSharedSetOperation;
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

sub create_and_attach_shared_keyword_set {
  my ($api_client, $customer_id, $campaign_id) = @_;

  # Create shared negative keyword set.
  my $shared_set = Google::Ads::GoogleAds::V23::Resources::SharedSet->new({
    name => "API Negative keyword list - " . uniqid(),
    type => NEGATIVE_KEYWORDS
  });

  my $shared_set_operation =
    Google::Ads::GoogleAds::V23::Services::SharedSetService::SharedSetOperation
    ->new({
      create => $shared_set
    });

  my $shared_sets_response = $api_client->SharedSetService()->mutate({
      customerId => $customer_id,
      operations => [$shared_set_operation]});

  my $shared_set_resource_name =
    $shared_sets_response->{results}[0]{resourceName};
  printf "Created shared set: '%s'.\n", $shared_set_resource_name;

  # Create shared set criterion.
  my $shared_criterion_operations = [];
  # Keywords to create a shared set of.
  my $keywords = ['mars cruise', 'mars hotels'];
  foreach my $keyword (@$keywords) {
    my $shared_criterion =
      Google::Ads::GoogleAds::V23::Resources::SharedCriterion->new({
        keyword => Google::Ads::GoogleAds::V23::Common::KeywordInfo->new({
            text      => $keyword,
            matchType => BROAD
          }
        ),
        sharedSet => $shared_set_resource_name
      });

    my $shared_criterion_operation =
      Google::Ads::GoogleAds::V23::Services::SharedCriterionService::SharedCriterionOperation
      ->new({
        create => $shared_criterion
      });
    push @$shared_criterion_operations, $shared_criterion_operation;
  }

  my $shared_criteria_response = $api_client->SharedCriterionService()->mutate({
    customerId => $customer_id,
    operations => $shared_criterion_operations
  });

  my $shared_criterion_results = $shared_criteria_response->{results};
  printf "Added %d shared criterion:\n", scalar @$shared_criterion_results;
  foreach my $shared_criterion_result (@$shared_criterion_results) {
    printf "\t%s\n", $shared_criterion_result->{resourceName};
  }

  # Create campaign shared set.
  my $campaign_shared_set =
    Google::Ads::GoogleAds::V23::Resources::CampaignSharedSet->new({
      campaign => Google::Ads::GoogleAds::V23::Utils::ResourceNames::campaign(
        $customer_id, $campaign_id
      ),
      sharedSet => $shared_set_resource_name
    });

  my $campaign_shared_set_operation =
    Google::Ads::GoogleAds::V23::Services::CampaignSharedSetService::CampaignSharedSetOperation
    ->new({
      create => $campaign_shared_set
    });

  my $campaign_shared_sets_response =
    $api_client->CampaignSharedSetService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_shared_set_operation]});

  printf "Created campaign shared set: '%s'.\n",
    $campaign_shared_sets_response->{results}[0]{resourceName};
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
GetOptions("customer_id=s" => \$customer_id, "campaign_id=i" => \$campaign_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $campaign_id);

# Call the example.
create_and_attach_shared_keyword_set($api_client, $customer_id =~ s/-//gr,
  $campaign_id);

=pod

=head1 NAME

create_and_attach_shared_keyword_set

=head1 DESCRIPTION

This example creates a shared list of negative broad match keywords. It then attaches
them to a campaign.

=head1 SYNOPSIS

create_and_attach_shared_keyword_set.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.

=cut
