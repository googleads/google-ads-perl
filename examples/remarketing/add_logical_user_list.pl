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
# Creates a combination user list containing users that are present on any one of
# the provided user lists.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::UserList;
use Google::Ads::GoogleAds::V23::Common::LogicalUserListOperandInfo;
use Google::Ads::GoogleAds::V23::Common::UserListLogicalRuleInfo;
use Google::Ads::GoogleAds::V23::Common::LogicalUserListInfo;
use Google::Ads::GoogleAds::V23::Enums::UserListLogicalRuleOperatorEnum qw(ANY);
use Google::Ads::GoogleAds::V23::Services::UserListService::UserListOperation;
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
my $customer_id   = "INSERT_CUSTOMER_ID_HERE";
my $user_list_id1 = "INSERT_USER_LIST_ID_1_HERE";
my $user_list_id2 = "INSERT_USER_LIST_ID_2_HERE";
my $user_list_ids = [];

# [START add_logical_user_list]
sub add_logical_user_list {
  my ($api_client, $customer_id, $user_list_ids) = @_;

  # Add each of the provided list IDs to a list of rule operands specifying which
  # lists the operator should target.
  my $logical_user_list_operand_info_list = [];
  foreach my $user_list_id (@$user_list_ids) {
    push @$logical_user_list_operand_info_list,
      Google::Ads::GoogleAds::V23::Common::LogicalUserListOperandInfo->new({
        userList =>
          Google::Ads::GoogleAds::V23::Utils::ResourceNames::user_list(
          $customer_id, $user_list_id
          )});
  }

  # Create the UserListLogicalRuleInfo specifying that a user should be added to
  # the new list if they are present in any of the provided lists.
  my $user_list_logical_rule_info =
    Google::Ads::GoogleAds::V23::Common::UserListLogicalRuleInfo->new({
      # Using ANY means that a user should be added to the combined list if they
      # are present on any of the lists targeted in the LogicalUserListOperandInfo.
      # Use ALL to add users present on all of the provided lists or NONE to add
      # users that aren't present on any of the targeted lists.
      operator     => ANY,
      ruleOperands => $logical_user_list_operand_info_list
    });

  # Create the new combination user list.
  my $user_list = Google::Ads::GoogleAds::V23::Resources::UserList->new({
      name            => "My combination list of other user lists #" . uniqid(),
      logicalUserList =>
        Google::Ads::GoogleAds::V23::Common::LogicalUserListInfo->new({
          rules => [$user_list_logical_rule_info]})});

  # Create the operation.
  my $user_list_operation =
    Google::Ads::GoogleAds::V23::Services::UserListService::UserListOperation->
    new({
      create => $user_list
    });

  # Issue a mutate request to add the user list and print some information.
  my $user_lists_response = $api_client->UserListService()->mutate({
      customerId => $customer_id,
      operations => [$user_list_operation]});
  printf "Created combination user list with resource name '%s'.\n",
    $user_lists_response->{results}[0]{resourceName};

  return 1;
}
# [END add_logical_user_list]

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
  "customer_id=s"   => \$customer_id,
  "user_list_ids=s" => \@$user_list_ids,
);
$user_list_ids = [$user_list_id1, $user_list_id2] unless @$user_list_ids;

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $user_list_ids);

# Call the example.
add_logical_user_list($api_client, $customer_id =~ s/-//gr, $user_list_ids);

=pod

=head1 NAME

add_logical_user_list

=head1 DESCRIPTION

Creates a combination user list containing users that are present on any one of
the provided user lists

=head1 SYNOPSIS

add_logical_user_list.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -user_list_ids              The IDs of the lists to be used for the new
                                combination user list.

=cut
