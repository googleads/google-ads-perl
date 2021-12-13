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
# Creates a rule-based user list defined by an expression rule for users who
# have either checked out in November or December OR visited the checkout page
# with more than one item in their cart.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V9::Resources::UserList;
use Google::Ads::GoogleAds::V9::Common::RuleBasedUserListInfo;
use Google::Ads::GoogleAds::V9::Common::ExpressionRuleUserListInfo;
use Google::Ads::GoogleAds::V9::Common::UserListRuleInfo;
use Google::Ads::GoogleAds::V9::Common::UserListRuleItemGroupInfo;
use Google::Ads::GoogleAds::V9::Common::UserListRuleItemInfo;
use Google::Ads::GoogleAds::V9::Common::UserListStringRuleItemInfo;
use Google::Ads::GoogleAds::V9::Common::UserListNumberRuleItemInfo;
use Google::Ads::GoogleAds::V9::Common::UserListDateRuleItemInfo;
use Google::Ads::GoogleAds::V9::Enums::UserListStringRuleItemOperatorEnum
  qw(EQUALS);
use Google::Ads::GoogleAds::V9::Enums::UserListNumberRuleItemOperatorEnum
  qw(GREATER_THAN);
use Google::Ads::GoogleAds::V9::Enums::UserListDateRuleItemOperatorEnum
  qw(AFTER BEFORE);
use Google::Ads::GoogleAds::V9::Enums::UserListMembershipStatusEnum qw(OPEN);
use Google::Ads::GoogleAds::V9::Enums::UserListPrepopulationStatusEnum
  qw(REQUESTED);
use Google::Ads::GoogleAds::V9::Services::UserListService::UserListOperation;

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
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub set_up_advanced_remarketing {
  my ($api_client, $customer_id) = @_;

  # Create a rule targeting any user that visited the checkout page.
  # [START setup_advanced_remarketing]
  my $checkout_rule =
    Google::Ads::GoogleAds::V9::Common::UserListRuleItemInfo->new({
      # The rule variable name must match a corresponding key name fired from a
      # pixel. To learn more about setting up remarketing tags, visit
      # https://support.google.com/google-ads/answer/2476688.
      # To learn more about remarketing events and parameters, visit
      # https://support.google.com/google-ads/answer/7305793.
      name           => "ecomm_pagetype",
      stringRuleItem =>
        Google::Ads::GoogleAds::V9::Common::UserListStringRuleItemInfo->new({
          operator => EQUALS,
          value    => "checkout"
        })});
  # [END setup_advanced_remarketing]

  # Create a rule targeting any user that had more than one item in their cart.
  # [START setup_advanced_remarketing_1]
  my $cart_size_rule =
    Google::Ads::GoogleAds::V9::Common::UserListRuleItemInfo->new({
      # The rule variable name must match a corresponding key name fired from a
      # pixel.
      name           => "cart_size",
      numberRuleItem =>
        Google::Ads::GoogleAds::V9::Common::UserListNumberRuleItemInfo->new({
          # Available UserListNumberRuleItemOperators can be found at
          # https://developers.google.com/google-ads/api/reference/rpc/latest/UserListNumberRuleItemOperatorEnum.UserListNumberRuleItemOperator
          operator => GREATER_THAN,
          value    => 1.0
        })});
  # [END setup_advanced_remarketing_1]

  # Create a rule group that includes the checkout and cart size rules.
  # Combining the two rule items into a UserListRuleItemGroupInfo object causes
  # Google Ads to AND their rules together. To instead OR the rules together,
  # each rule should be placed in its own rule item group.
  # [START setup_advanced_remarketing_2]
  my $checkout_and_cart_size_rule_group =
    Google::Ads::GoogleAds::V9::Common::UserListRuleItemGroupInfo->new(
    {ruleItems => [$checkout_rule, $cart_size_rule]});
  # [END setup_advanced_remarketing_2]

  # Create the RuleItem for checkout start date.
  # The tags and keys used below must have been in place in the past for the
  # date range specified in the rules.
  # [START setup_advanced_remarketing_3]
  my $start_date_rule =
    Google::Ads::GoogleAds::V9::Common::UserListRuleItemInfo->new({
      # The rule variable name must match a corresponding key name fired from a
      # pixel.
      name         => "checkoutdate",
      dateRuleItem =>
        Google::Ads::GoogleAds::V9::Common::UserListDateRuleItemInfo->new({
          # Available UserListDateRuleItemOperators can be found at
          # https://developers.google.com/google-ads/api/reference/rpc/latest/UserListDateRuleItemOperatorEnum.UserListDateRuleItemOperator
          operator => AFTER,
          value    => "20191031"
        })});
  # [END setup_advanced_remarketing_3]

  # Create the RuleItem for checkout end date.
  # [START setup_advanced_remarketing_4]
  my $end_date_rule =
    Google::Ads::GoogleAds::V9::Common::UserListRuleItemInfo->new({
      # The rule variable name must match a corresponding key name fired from a
      # pixel.
      name         => "checkoutdate",
      dateRuleItem =>
        Google::Ads::GoogleAds::V9::Common::UserListDateRuleItemInfo->new({
          operator => BEFORE,
          value    => "20200101"
        })});
  # [END setup_advanced_remarketing_4]

  # Create a rule group targeting users who checked out between November and
  # December by using the start and end date rules. Combining the two rule items
  # into a UserListRuleItemGroupInfo object causes Google Ads to AND their rules
  # together. To instead OR the rules together, each rule should be placed in
  # its own rule item group.
  # [START setup_advanced_remarketing_5]
  my $checkout_date_rule_group =
    Google::Ads::GoogleAds::V9::Common::UserListRuleItemGroupInfo->new(
    {ruleItems => [$start_date_rule, $end_date_rule]});
  # [END setup_advanced_remarketing_5]

  # Create an ExpressionRuleUserListInfo object, or a boolean rule that defines
  # this user list. The default rule_type for a UserListRuleInfo object is OR of
  # ANDs (disjunctive normal form). That is, rule items will be ANDed together
  # within rule item groups and the groups themselves will be ORed together.
  # [START setup_advanced_remarketing_6]
  my $expression_rule_user_list_info =
    Google::Ads::GoogleAds::V9::Common::ExpressionRuleUserListInfo->new({
      rule => Google::Ads::GoogleAds::V9::Common::UserListRuleInfo->new({
          ruleItemGroups =>
            [$checkout_date_rule_group, $checkout_and_cart_size_rule_group]})});
  # [END setup_advanced_remarketing_6]

  # Define a representation of a user list that is generated by a rule.
  my $rule_based_user_list_info =
    Google::Ads::GoogleAds::V9::Common::RuleBasedUserListInfo->new({
      # Optional: To include past users in the user list, set the
      # prepopulation status to REQUESTED.
      prepopulationStatus    => REQUESTED,
      expressionRuleUserList => $expression_rule_user_list_info
    });

  # Create the user list.
  my $user_list = Google::Ads::GoogleAds::V9::Resources::UserList->new({
    name        => "My expression rule user list #" . uniqid(),
    description => "Users who checked out in November or December OR " .
      "visited the checkout page with more than one item in their cart",
    membershipLifespan => 90,
    membershipStatus   => OPEN,
    ruleBasedUserList  => $rule_based_user_list_info
  });

  # Create the operation.
  my $user_list_operation =
    Google::Ads::GoogleAds::V9::Services::UserListService::UserListOperation->
    new({
      create => $user_list
    });

  # Issue a mutate request to add the user list and print some information.
  my $user_lists_response = $api_client->UserListService()->mutate({
      customerId => $customer_id,
      operations => [$user_list_operation]});
  printf "Created user list with resource name '%s'.\n",
    $user_lists_response->{results}[0]{resourceName};

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
GetOptions("customer_id=s" => \$customer_id,);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
set_up_advanced_remarketing($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

set_up_advanced_remarketing

=head1 DESCRIPTION

Creates a rule-based user list defined by an expression rule for users who have
either checked out in November or December OR visited the checkout page with
more than one item in their cart.

=head1 SYNOPSIS

set_up_advanced_remarketing.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
