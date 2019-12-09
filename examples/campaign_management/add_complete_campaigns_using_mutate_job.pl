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
# This example adds complete campaigns including campaign budgets, campaigns,
# ad groups and keywords using MutateJobService.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::GoogleAdsClient;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V2::Resources::CampaignBudget;
use Google::Ads::GoogleAds::V2::Resources::Campaign;
use Google::Ads::GoogleAds::V2::Resources::CampaignCriterion;
use Google::Ads::GoogleAds::V2::Resources::AdGroup;
use Google::Ads::GoogleAds::V2::Resources::AdGroupCriterion;
use Google::Ads::GoogleAds::V2::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V2::Resources::Ad;
use Google::Ads::GoogleAds::V2::Common::ManualCpc;
use Google::Ads::GoogleAds::V2::Common::KeywordInfo;
use Google::Ads::GoogleAds::V2::Common::ExpandedTextAdInfo;
use Google::Ads::GoogleAds::V2::Enums::BudgetDeliveryMethodEnum qw(STANDARD);
use Google::Ads::GoogleAds::V2::Enums::AdvertisingChannelTypeEnum qw(SEARCH);
use Google::Ads::GoogleAds::V2::Enums::CampaignStatusEnum;
use Google::Ads::GoogleAds::V2::Enums::KeywordMatchTypeEnum qw(BROAD);
use Google::Ads::GoogleAds::V2::Enums::AdGroupTypeEnum qw(SEARCH_STANDARD);
use Google::Ads::GoogleAds::V2::Enums::AdGroupCriterionStatusEnum;
use Google::Ads::GoogleAds::V2::Enums::AdGroupAdStatusEnum;
use Google::Ads::GoogleAds::V2::Services::GoogleAdsService::MutateOperation;
use
  Google::Ads::GoogleAds::V2::Services::CampaignBudgetService::CampaignBudgetOperation;
use Google::Ads::GoogleAds::V2::Services::CampaignService::CampaignOperation;
use
  Google::Ads::GoogleAds::V2::Services::CampaignCriterionService::CampaignCriterionOperation;
use Google::Ads::GoogleAds::V2::Services::AdGroupService::AdGroupOperation;
use
  Google::Ads::GoogleAds::V2::Services::AdGroupCriterionService::AdGroupCriterionOperation;
use Google::Ads::GoogleAds::V2::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V2::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use Data::Uniqid qw(uniqid);

use constant NUMBER_OF_CAMPAIGNS_TO_ADD => 2;
use constant NUMBER_OF_AD_GROUPS_TO_ADD => 2;
use constant NUMBER_OF_KEYWORDS_TO_ADD  => 5;
use constant POLL_FREQUENCY_SECONDS     => 1;
use constant POLL_TIMEOUT_SECONDS       => 60;

use constant PAGE_SIZE => 1000;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub add_complete_campaigns_using_mutate_job {
  my ($api_client, $customer_id) = @_;

  my $mutate_job_service = $api_client->MutateJobService();
  my $operation_service  = $api_client->OperationService();

  my $mutate_job_resource_name =
    create_mutate_job($mutate_job_service, $customer_id);

  add_all_mutate_job_operations($mutate_job_service, $customer_id,
    $mutate_job_resource_name);

  my $mutate_job_lro =
    run_mutate_job($mutate_job_service, $mutate_job_resource_name);

  poll_mutate_job($operation_service, $mutate_job_lro);

  fetch_and_print_results($mutate_job_service, $mutate_job_resource_name);

  return 1;
}

# Creates a new mutate job for the specified customer ID.
sub create_mutate_job {
  my ($mutate_job_service, $customer_id) = @_;

  my $mutate_job_resource_name = $mutate_job_service->create({
      customerId => $customer_id
    })->{resourceName};

  printf
    "Created a mutate job with resource name: '%s'.\n",
    $mutate_job_resource_name;

  return $mutate_job_resource_name;
}

# Adds all mutate job operations to the mutate job. As this is the first time for
# this mutate job, pass null as a sequence token. The response will contain the
# next sequence token that you can use to upload more operations in the future.
sub add_all_mutate_job_operations {
  my ($mutate_job_service, $customer_id, $mutate_job_resource_name) = @_;

  my $add_mutate_job_operations_response = $mutate_job_service->add_operations({
      resourceName     => $mutate_job_resource_name,
      sequenceToken    => undef,
      mutateOperations => build_all_operations($customer_id)});

  printf
    "%d mutate operations have been added so far.\n",
    $add_mutate_job_operations_response->{totalOperations};

  # You can use this next sequence token for calling addMutateJobOperations() next time.
  printf
    "Next sequence token for adding next operations is '%s'.\n",
    $add_mutate_job_operations_response->{nextSequenceToken};
}

# Requests the API to run the mutate job for executing all uploaded mutate
# job operations.
sub run_mutate_job {
  my ($mutate_job_service, $mutate_job_resource_name) = @_;

  my $mutate_job_lro =
    $mutate_job_service->run({resourceName => $mutate_job_resource_name});

  printf
    "Mutate job with resource name '%s' has been executed.\n",
    $mutate_job_resource_name;

  return $mutate_job_lro;
}

# Polls the server until the mutate job execution finishes by setting the
# initial poll delay time and the total time to wait before time-out.
sub poll_mutate_job {
  my ($operation_service, $mutate_job_lro) = @_;

  $operation_service->poll_until_done({
    name                 => $mutate_job_lro->{name},
    pollFrequencySeconds => POLL_FREQUENCY_SECONDS,
    pollTimeoutSeconds   => POLL_TIMEOUT_SECONDS
  });
}

# Prints all the results from running the mutate job.
sub fetch_and_print_results {
  my ($mutate_job_service, $mutate_job_resource_name) = @_;

  printf "Mutate job with resource name '%s' has finished. " .
    "Now, printing its results...\n",
    $mutate_job_resource_name;

  # Get all the results from running mutate job and print their information.
  my $list_mutate_job_results_response = $mutate_job_service->list_results({
    resourceName => $mutate_job_resource_name,
    pageSize     => PAGE_SIZE
  });

  foreach
    my $mutate_job_result (@{$list_mutate_job_results_response->{results}})
  {
    printf
      "Mutate job #%d has a status '%s' and response of type '%s'.\n",
      $mutate_job_result->{operationIndex},
      $mutate_job_result->{status} ? $mutate_job_result->{status}{message}
      : "N/A",
      $mutate_job_result->{mutateOperationResponse}
      ? [values %{$mutate_job_result->{mutateOperationResponse}}]->[0]
      : "N/A";
  }
}

# Builds all operations for creating a complete campaign and return an array
# of their corresponding mutate operations.
sub build_all_operations {
  my $customer_id = shift;

  my $mutate_operations = [];

  # Create a new campaign budget operation and add it to the array of mutate operations.
  my $campaign_budget_operation = build_campaign_budge_operation($customer_id);
  push @$mutate_operations,
    Google::Ads::GoogleAds::V2::Services::GoogleAdsService::MutateOperation->
    new({
      campaignBudgetOperation => $campaign_budget_operation
    });

  # Create new campaign operations and add them to the array of mutate operations.
  my $campaign_operations = build_campaign_operations($customer_id,
    $campaign_budget_operation->{create}{resourceName});
  push @$mutate_operations, map {
    Google::Ads::GoogleAds::V2::Services::GoogleAdsService::MutateOperation->
      new({
        campaignOperation => $_
      })
  } @$campaign_operations;

  # Create new campaign criterion operations and add them to the array of mutate operations.
  my $campaign_criterion_operations =
    build_campaign_criterion_operations($campaign_operations);
  push @$mutate_operations, map {
    Google::Ads::GoogleAds::V2::Services::GoogleAdsService::MutateOperation->
      new({
        campaignCriterionOperation => $_
      })
  } @$campaign_criterion_operations;

  # Creates new ad group operations and add them to the array of mutate operations.
  my $ad_group_operations =
    build_ad_group_operations($customer_id, $campaign_operations);
  push @$mutate_operations, map {
    Google::Ads::GoogleAds::V2::Services::GoogleAdsService::MutateOperation->
      new({
        adGroupOperation => $_
      })
  } @$ad_group_operations;

  # Create new ad group criterion operations and add them to the array of mutate
  # operations.
  my $ad_group_criterion_operations =
    build_ad_group_criterion_operations($ad_group_operations);
  push @$mutate_operations, map {
    Google::Ads::GoogleAds::V2::Services::GoogleAdsService::MutateOperation->
      new({
        adGroupCriterionOperation => $_
      })
  } @$ad_group_criterion_operations;

  # Create new ad group ad operations and add them to the array of mutate operations.
  my $ad_group_ad_operations =
    build_ad_group_ad_operations($ad_group_operations);
  push @$mutate_operations, map {
    Google::Ads::GoogleAds::V2::Services::GoogleAdsService::MutateOperation->
      new({
        adGroupAdOperation => $_
      })
  } @$ad_group_ad_operations;

  return $mutate_operations;
}

# Builds a new campaign budget operation for the specified customer ID.
sub build_campaign_budge_operation {
  my $customer_id = shift;

  # Create a campaign budget operation.
  return
    Google::Ads::GoogleAds::V2::Services::CampaignBudgetService::CampaignBudgetOperation
    ->new({
      create => Google::Ads::GoogleAds::V2::Resources::CampaignBudget->new({
          # Create a resource name using the temporary ID.
          resourceName =>
            Google::Ads::GoogleAds::V2::Utils::ResourceNames::campaign_budget(
            $customer_id, next_temporary_id()
            ),
          name           => "Interplanetary Cruise Budget #" . uniqid(),
          deliveryMethod => STANDARD,
          amountMicros   => 5000000
        })});
}

# Builds new campaign operations for the specified customer ID.
sub build_campaign_operations {
  my ($customer_id, $campaign_budget_resource_name) = @_;

  my $campaign_operations = [];
  for (my $i = 0 ; $i < NUMBER_OF_CAMPAIGNS_TO_ADD ; $i++) {
    # Create a campaign.
    my $campaign_id = next_temporary_id();
    my $campaign    = Google::Ads::GoogleAds::V2::Resources::Campaign->new({
        # Create a resource name using the temporary ID.
        resourceName =>
          Google::Ads::GoogleAds::V2::Utils::ResourceNames::campaign(
          $customer_id, $campaign_id
          ),
        name => sprintf("Mutate job campaign #%s.%d", uniqid(), $campaign_id),
        advertisingChannelType => SEARCH,
        # Recommendation: Set the campaign to PAUSED when creating it to prevent
        # the ads from immediately serving. Set to ENABLED once you've added
        # targeting and the ads are ready to serve.
        status => Google::Ads::GoogleAds::V2::Enums::CampaignStatusEnum::PAUSED,
        # Set the bidding strategy and budget.
        manualCpc      => Google::Ads::GoogleAds::V2::Common::ManualCpc->new(),
        campaignBudget => $campaign_budget_resource_name,
      });

    # Create a campaign operation and add it to the operations list.
    push @$campaign_operations,
      Google::Ads::GoogleAds::V2::Services::CampaignService::CampaignOperation
      ->new({
        create => $campaign
      });
  }

  return $campaign_operations;
}

# Builds new campaign criterion operations for creating negative campaign criteria
# (as keywords).
sub build_campaign_criterion_operations {
  my $campaign_operations = shift;

  my $campaign_criterion_operations = [];
  foreach my $campaign_operation (@$campaign_operations) {
    # Create a campaign criterion.
    my $campaign_criterion =
      Google::Ads::GoogleAds::V2::Resources::CampaignCriterion->new({
        keyword => Google::Ads::GoogleAds::V2::Common::KeywordInfo->new({
            text      => "venus",
            matchType => BROAD
          }
        ),
        # Set the campaign criterion as a negative criterion.
        negative => "true",
        campaign => $campaign_operation->{create}{resourceName}});

    # Create a campaign criterion operation and add it to the operations list.
    push @$campaign_criterion_operations,
      Google::Ads::GoogleAds::V2::Services::CampaignCriterionService::CampaignCriterionOperation
      ->new({
        create => $campaign_criterion
      });
  }

  return $campaign_criterion_operations;
}

# Builds new ad group operations for the specified customer ID.
sub build_ad_group_operations {
  my ($customer_id, $campaign_operations) = @_;

  my $ad_group_operations = [];
  foreach my $campaign_operation (@$campaign_operations) {
    for (my $i = 0 ; $i < NUMBER_OF_AD_GROUPS_TO_ADD ; $i++) {
      # Create an ad group.
      my $ad_group_id = next_temporary_id();
      my $ad_group    = Google::Ads::GoogleAds::V2::Resources::AdGroup->new({
          # Create a resource name using the temporary ID.
          resourceName =>
            Google::Ads::GoogleAds::V2::Utils::ResourceNames::ad_group(
            $customer_id, $ad_group_id
            ),
          name => sprintf("Mutate job ad group #%s.%d", uniqid(), $ad_group_id),
          campaign     => $campaign_operation->{create}{resourceName},
          type         => SEARCH_STANDARD,
          cpcBidMicros => 10000000
        });

      # Create an ad group operation and add it to the operations list.
      push @$ad_group_operations,
        Google::Ads::GoogleAds::V2::Services::AdGroupService::AdGroupOperation
        ->new({
          create => $ad_group
        });
    }
  }

  return $ad_group_operations;
}

# Builds new ad group criterion operations for creating keywords. 50% of keywords
# are created with some invalid characters to demonstrate how MutateJobService
# returns information about such errors.
sub build_ad_group_criterion_operations {
  my $ad_group_operations = shift;

  my $ad_group_criterion_operations = [];
  foreach my $ad_group_operation (@$ad_group_operations) {
    for (my $i = 0 ; $i < NUMBER_OF_KEYWORDS_TO_ADD ; $i++) {
      # Create a keyword text by making 50% of keywords invalid to demonstrate
      # error handling.
      my $keyword_text = "mars$i";
      if ($i % 2 == 0) {
        $keyword_text = $keyword_text . '!!!';
      }

      # Create an ad group criterion using the created keyword text.
      my $ad_group_criterion =
        Google::Ads::GoogleAds::V2::Resources::AdGroupCriterion->new({
          keyword => Google::Ads::GoogleAds::V2::Common::KeywordInfo->new({
              text      => $keyword_text,
              matchType => BROAD
            }
          ),
          adGroup => $ad_group_operation->{create}{resourceName},
          status =>
            Google::Ads::GoogleAds::V2::Enums::AdGroupCriterionStatusEnum::ENABLED
        });

      # Create an ad group criterion operation and add it to the operations list.
      push @$ad_group_criterion_operations,
        Google::Ads::GoogleAds::V2::Services::AdGroupCriterionService::AdGroupCriterionOperation
        ->new({
          create => $ad_group_criterion
        });
    }
  }

  return $ad_group_criterion_operations;
}

# Builds new ad group ad operations.
sub build_ad_group_ad_operations {
  my $ad_group_operations = shift;

  my $ad_group_ad_operations = [];
  foreach my $ad_group_operation (@$ad_group_operations) {
    # Create an ad group ad.
    my $ad_group_ad = Google::Ads::GoogleAds::V2::Resources::AdGroupAd->new({
        # Create the expanded text ad info.
        ad => Google::Ads::GoogleAds::V2::Resources::Ad->new({
            # Set the expanded text ad info on an ad.
            expandedTextAd =>
              Google::Ads::GoogleAds::V2::Common::ExpandedTextAdInfo->new({
                headlinePart1 => "Cruise to Mars #" . uniqid(),
                headlinePart2 => "Best Space Cruise Line",
                description   => "Buy your tickets now!"
              }
              ),
            finalUrls => "http://www.example.com",
          },
          adGroup => $ad_group_operation->{create}{resourceName},
          status =>
            Google::Ads::GoogleAds::V2::Enums::AdGroupAdStatusEnum::PAUSED
        )});

    # Create an ad group ad operation and add it to the operations list.
    push @$ad_group_ad_operations,
      Google::Ads::GoogleAds::V2::Services::AdGroupAdService::AdGroupAdOperation
      ->new({
        create => $ad_group_ad
      });
  }

  return $ad_group_ad_operations;
}

# Specifies a decreasing negative number for temporary IDs.
# Returns -1, -2, -3, etc. on subsequent calls.
sub next_temporary_id {
  our $temporary_id ||= 0;
  $temporary_id -= 1;
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client =
  Google::Ads::GoogleAds::GoogleAdsClient->new({version => "V2"});

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
add_complete_campaigns_using_mutate_job($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

add_complete_campaigns_using_mutate_job

=head1 DESCRIPTION

This example adds complete campaigns including campaign budgets, campaigns, ad groups
and keywords using MutateJobService.

=head1 SYNOPSIS

add_complete_campaigns_using_mutate_job.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
