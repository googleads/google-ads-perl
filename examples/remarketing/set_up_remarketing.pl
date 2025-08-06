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
# Demonstrates various operations involved in remarketing, including:
#   (a) Creating a user list based on visitors to a website.
#   (b) Targeting a user list with an ad group criterion.
#   (c) Updating the bid modifier on an ad group criterion.
#   (d) Finding and removing all ad group criteria under a given campaign.
#   (e) Targeting a user list with a campaign criterion.
#   (f) Updating the bid modifier on a campaign criterion.
# It is unlikely that users will need to perform all of these operations
# consecutively, and all of the operations contained herein are meant for
# illustrative purposes.
#
# Note: you can use user lists to target at the campaign or ad group level, but
# not both simultaneously. Consider removing or disabling any existing user
# lists at the campaign level before running this example.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use Google::Ads::GoogleAds::V21::Resources::AdGroupCriterion;
use Google::Ads::GoogleAds::V21::Resources::CampaignCriterion;
use Google::Ads::GoogleAds::V21::Resources::UserList;
use Google::Ads::GoogleAds::V21::Common::FlexibleRuleOperandInfo;
use Google::Ads::GoogleAds::V21::Common::FlexibleRuleUserListInfo;
use Google::Ads::GoogleAds::V21::Common::RuleBasedUserListInfo;
use Google::Ads::GoogleAds::V21::Common::UserListInfo;
use Google::Ads::GoogleAds::V21::Common::UserListRuleInfo;
use Google::Ads::GoogleAds::V21::Common::UserListRuleItemInfo;
use Google::Ads::GoogleAds::V21::Common::UserListRuleItemGroupInfo;
use Google::Ads::GoogleAds::V21::Common::UserListStringRuleItemInfo;
use Google::Ads::GoogleAds::V21::Enums::UserListFlexibleRuleOperatorEnum
  qw(AND);
use Google::Ads::GoogleAds::V21::Enums::UserListMembershipStatusEnum qw(OPEN);
use Google::Ads::GoogleAds::V21::Enums::UserListPrepopulationStatusEnum
  qw(REQUESTED);
use Google::Ads::GoogleAds::V21::Enums::UserListStringRuleItemOperatorEnum
  qw(CONTAINS);
use
  Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation;
use
  Google::Ads::GoogleAds::V21::Services::CampaignCriterionService::CampaignCriterionOperation;
use
  Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;
use Google::Ads::GoogleAds::V21::Services::UserListService::UserListOperation;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

sub set_up_remarketing {
  my ($api_client, $customer_id, $ad_group_id, $campaign_id,
    $bid_modifier_value)
    = @_;

  # Create a new example user list.
  my $user_list_resource_name = create_user_list($api_client, $customer_id);

  # Target an ad group to the new user list.
  my $ad_group_criterion_resource_name =
    target_ads_in_ad_group_to_user_list($api_client, $customer_id,
    $ad_group_id, $user_list_resource_name);
  modify_ad_group_bids($api_client, $customer_id,
    $ad_group_criterion_resource_name,
    $bid_modifier_value);

  # Remove any existing user lists at the ad group level.
  remove_existing_list_criteria_from_ad_group($api_client, $customer_id,
    $campaign_id);

  # Target the campaign to the new user list.
  my $campaign_criterion_resource_name =
    target_ads_in_campaign_to_user_list($api_client, $customer_id, $campaign_id,
    $user_list_resource_name);
  modify_campaign_bids($api_client, $customer_id,
    $campaign_criterion_resource_name,
    $bid_modifier_value);

  return 1;
}

# Creates a user list targeting users that have visited a given url.
# [START setup_remarketing]
sub create_user_list {
  my ($api_client, $customer_id) = @_;

  # Create a rule targeting any user that visited a url containing 'example.com'.
  my $rule = Google::Ads::GoogleAds::V21::Common::UserListRuleItemInfo->new({
      # Use a built-in parameter to create a domain URL rule.
      name           => "url__",
      stringRuleItem =>
        Google::Ads::GoogleAds::V21::Common::UserListStringRuleItemInfo->new({
          operator => CONTAINS,
          value    => "example.com"
        })});

  # Specify that the user list targets visitors of a page based on the provided rule.
  my $user_list_rule_item_group_info =
    Google::Ads::GoogleAds::V21::Common::UserListRuleItemGroupInfo->new(
    {ruleItems => [$rule]});
  my $flexible_rule_user_list_info =
    Google::Ads::GoogleAds::V21::Common::FlexibleRuleUserListInfo->new({
      inclusiveRuleOperator => AND,
      # Inclusive operands are joined together with the specified inclusiveRuleOperator.
      inclusiveOperands => [
        Google::Ads::GoogleAds::V21::Common::FlexibleRuleOperandInfo->new({
            rule => Google::Ads::GoogleAds::V21::Common::UserListRuleInfo->new({
                ruleItemGroups => [$user_list_rule_item_group_info]}
            ),
            # Optionally add a lookback window for this rule, in days.
            lookbackWindowDays => 7
          })
      ],
      exclusiveOperands => []});

  # Define a representation of a user list that is generated by a rule.
  my $rule_based_user_list_info =
    Google::Ads::GoogleAds::V21::Common::RuleBasedUserListInfo->new({
      # Optional: To include past users in the user list, set the
      # prepopulationStatus to REQUESTED.
      prepopulationStatus  => REQUESTED,
      flexibleRuleUserList => $flexible_rule_user_list_info
    });

  # Create the user list.
  my $user_list = Google::Ads::GoogleAds::V21::Resources::UserList->new({
    name               => "All visitors to example.com #" . uniqid(),
    description        => "Any visitor to any page of example.com",
    membershipLifespan => 365,
    membershipStatus   => OPEN,
    ruleBasedUserList  => $rule_based_user_list_info
  });

  # Create the operation.
  my $user_list_operation =
    Google::Ads::GoogleAds::V21::Services::UserListService::UserListOperation->
    new({
      create => $user_list
    });

  # Add the user list, then print and return the new list's resource name.
  my $user_lists_response = $api_client->UserListService()->mutate({
      customerId => $customer_id,
      operations => [$user_list_operation]});

  my $user_list_resource_name =
    $user_lists_response->{results}[0]{resourceName};
  printf "Created user list with resource name '%s'.\n",
    $user_list_resource_name;

  return $user_list_resource_name;
}
# [END setup_remarketing]

# Creates an ad group criterion that targets a user list with an ad group.
# [START setup_remarketing_1]
sub target_ads_in_ad_group_to_user_list {
  my ($api_client, $customer_id, $ad_group_id, $user_list_resource_name) = @_;

  # Create the ad group criterion targeting members of the user list.
  my $ad_group_criterion =
    Google::Ads::GoogleAds::V21::Resources::AdGroupCriterion->new({
      adGroup => Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      userList => Google::Ads::GoogleAds::V21::Common::UserListInfo->new({
          userList => $user_list_resource_name
        })});

  # Create the operation.
  my $ad_group_criterion_operation =
    Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({
      create => $ad_group_criterion
    });

  # Add the ad group criterion, then print and return the new criterion's resource name.
  my $ad_group_criteria_response =
    $api_client->AdGroupCriterionService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_criterion_operation]});

  my $ad_group_criterion_resource_name =
    $ad_group_criteria_response->{results}[0]{resourceName};
  printf "Successfully created ad group criterion with resource name '%s' " .
    "targeting user list with resource name '%s' with ad group with ID %d.\n",
    $ad_group_criterion_resource_name, $user_list_resource_name, $ad_group_id;

  return $ad_group_criterion_resource_name;
}
# [END setup_remarketing_1]

# Updates the bid modifier on an ad group criterion.
sub modify_ad_group_bids {
  my ($api_client, $customer_id, $ad_group_criterion_resource_name,
    $bid_modifier_value)
    = @_;

  # Create the ad group criterion with a bid modifier. You may alternatively set
  # the bid for the ad group criterion directly.
  my $ad_group_criterion =
    Google::Ads::GoogleAds::V21::Resources::AdGroupCriterion->new({
      resourceName => $ad_group_criterion_resource_name,
      bidModifier  => $bid_modifier_value
    });

  # Create the update operation.
  my $ad_group_criterion_operation =
    Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
    ->new({
      update     => $ad_group_criterion,
      updateMask => all_set_fields_of($ad_group_criterion)});

  # Update the ad group criterion and print the results.
  my $ad_group_criteria_response =
    $api_client->AdGroupCriterionService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_criterion_operation]});
  printf "Successfully updated the bid for ad group criterion with resource " .
    "name '%s'.\n",
    $ad_group_criteria_response->{results}[0]{resourceName};
}

# Removes all ad group criteria targeting a user list under a given campaign.
# This is a necessary step before targeting a user list at the campaign level.
# [START setup_remarketing_3]
sub remove_existing_list_criteria_from_ad_group {
  my ($api_client, $customer_id, $campaign_id) = @_;

  # Retrieve all of the ad group criteria under a campaign.
  my $ad_group_criteria =
    get_user_list_ad_group_criteria($api_client, $customer_id, $campaign_id);

  # Create a list of remove operations.
  my $operations = [];
  foreach my $ad_group_criterion (@$ad_group_criteria) {
    push(
      @$operations,
      Google::Ads::GoogleAds::V21::Services::AdGroupCriterionService::AdGroupCriterionOperation
        ->new({
          remove => $ad_group_criterion
        }));
  }

  # Remove the ad group criteria and print the resource names of the removed criteria.
  my $ad_group_criteria_response =
    $api_client->AdGroupCriterionService()->mutate({
      customerId => $customer_id,
      operations => $operations
    });

  printf "Removed %d ad group criteria.\n",
    scalar @{$ad_group_criteria_response->{results}};
  foreach my $result (@{$ad_group_criteria_response->{results}}) {
    printf "Successfully removed ad group criterion with resource name '%s'.\n",
      $result->{resourceName};
  }
}
# [END setup_remarketing_3]

# Finds all of user list ad group criteria under a campaign.
# [START setup_remarketing_2]
sub get_user_list_ad_group_criteria {
  my ($api_client, $customer_id, $campaign_id) = @_;

  my $user_list_criterion_resource_names = [];

  # Create a search stream request that will retrieve all of the user list ad
  # group criteria under a campaign.
  my $search_stream_request =
    Google::Ads::GoogleAds::V21::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
    ->new({
      customerId => $customer_id,
      query      => sprintf(
        "SELECT ad_group_criterion.criterion_id " .
          "FROM ad_group_criterion " .
          "WHERE campaign.id = %d AND ad_group_criterion.type = 'USER_LIST'",
        $campaign_id
      )});

  my $search_stream_handler =
    Google::Ads::GoogleAds::Utils::SearchStreamHandler->new({
      service => $api_client->GoogleAdsService(),
      request => $search_stream_request
    });

  # Issue a search request and process the stream response.
  $search_stream_handler->process_contents(
    sub {
      # Display the results and add the resource names to the list.
      my $google_ads_row = shift;

      my $ad_group_criterion_resource_name =
        $google_ads_row->{adGroupCriterion}{resourceName};
      printf "Ad group criterion with resource name '%s' was found.\n",
        $ad_group_criterion_resource_name;
      push(@$user_list_criterion_resource_names,
        $ad_group_criterion_resource_name);
    });

  return $user_list_criterion_resource_names;
}
# [END setup_remarketing_2]

# Creates a campaign criterion that targets a user list with a campaign.
# [START setup_remarketing_4]
sub target_ads_in_campaign_to_user_list {
  my ($api_client, $customer_id, $campaign_id, $user_list_resource_name) = @_;

  # Create the campaign criterion.
  my $campaign_criterion =
    Google::Ads::GoogleAds::V21::Resources::CampaignCriterion->new({
      campaign => Google::Ads::GoogleAds::V21::Utils::ResourceNames::campaign(
        $customer_id, $campaign_id
      ),
      userList => Google::Ads::GoogleAds::V21::Common::UserListInfo->new({
          userList => $user_list_resource_name
        })});

  # Create the operation.
  my $campaign_criterion_operation =
    Google::Ads::GoogleAds::V21::Services::CampaignCriterionService::CampaignCriterionOperation
    ->new({
      create => $campaign_criterion
    });

  # Add the campaign criterion and print the resulting criterion's resource name.
  my $campaign_criteria_response =
    $api_client->CampaignCriterionService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_criterion_operation]});

  my $campaign_criterion_resource_name =
    $campaign_criteria_response->{results}[0]{resourceName};
  printf "Successfully created campaign criterion with resource name '%s' " .
    "targeting user list with resource name '%s' with campaign with ID %d.\n",
    $campaign_criterion_resource_name, $user_list_resource_name, $campaign_id;

  return $campaign_criterion_resource_name;
}
# [END setup_remarketing_4]

# Updates the bid modifier on a campaign criterion.
sub modify_campaign_bids {
  my ($api_client, $customer_id, $campaign_criterion_resource_name,
    $bid_modifier_value)
    = @_;

  # Create the campaign criterion to update.
  my $campaign_criterion =
    Google::Ads::GoogleAds::V21::Resources::CampaignCriterion->new({
      resourceName => $campaign_criterion_resource_name,
      bidModifier  => $bid_modifier_value
    });

  # Create the update operation.
  my $campaign_criterion_operation =
    Google::Ads::GoogleAds::V21::Services::CampaignCriterionService::CampaignCriterionOperation
    ->new({
      update     => $campaign_criterion,
      updateMask => all_set_fields_of($campaign_criterion)});

  # Update the campaign criterion and print the results.
  my $campaign_criteria_response =
    $api_client->CampaignCriterionService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_criterion_operation]});
  printf "Successfully updated the bid for campaign criterion with " .
    "resource name '%s'.\n",
    $campaign_criteria_response->{results}[0]{resourceName};
}

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

my $customer_id        = undef;
my $ad_group_id        = undef;
my $campaign_id        = undef;
my $bid_modifier_value = undef;

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s"        => \$customer_id,
  "ad_group_id=i"        => \$ad_group_id,
  "campaign_id=i"        => \$campaign_id,
  "bid_modifier_value=f" => \$bid_modifier_value
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $ad_group_id, $campaign_id,
  $bid_modifier_value);

# Call the example.
set_up_remarketing($api_client, $customer_id =~ s/-//gr,
  $ad_group_id, $campaign_id, $bid_modifier_value);

=pod

=head1 NAME

set_up_remarketing

=head1 DESCRIPTION

Demonstrates various operations involved in remarketing, including:

   (a) Creating a user list based on visitors to a website.
   (b) Targeting a user list with an ad group criterion.
   (c) Updating the bid modifier on an ad group criterion.
   (d) Finding and removing all ad group criteria under a given campaign.
   (e) Targeting a user list with a campaign criterion.
   (f) Updating the bid modifier on a campaign criterion.

It is unlikely that users will need to perform all of these operations
consecutively, and all of the operations contained herein are meant of for
illustrative purposes.

Note: you can use user lists to target at the campaign or ad group level, but
not both simultaneously. Consider removing or disabling any existing user lists
at the campaign level before running this example.

=head1 SYNOPSIS

set_up_remarketing.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID on which criteria will be targeted.
    -campaign_id                The campaign ID on which criteria will be targeted.
    -bid_modifier               The bid modifier value.

=cut
