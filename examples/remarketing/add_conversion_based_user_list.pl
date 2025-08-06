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
# Creates a basic user list consisting of people who triggered one or more
# conversion actions.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::UserList;
use Google::Ads::GoogleAds::V21::Common::UserListActionInfo;
use Google::Ads::GoogleAds::V21::Common::BasicUserListInfo;
use Google::Ads::GoogleAds::V21::Enums::UserListMembershipStatusEnum qw(OPEN);
use Google::Ads::GoogleAds::V21::Services::UserListService::UserListOperation;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

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
my $customer_id            = "INSERT_CUSTOMER_ID_HERE";
my $conversion_action_id_1 = "INSERT_CONVERSION_ACTION_ID_1_HERE";
my $conversion_action_id_2 = "INSERT_CONVERSION_ACTION_ID_2_HERE";
my $conversion_action_ids  = [];

# [START add_conversion_based_user_list]
sub add_conversion_based_user_list {
  my ($api_client, $customer_id, $conversion_action_ids) = @_;

  my $user_list_action_info_list = [];
  foreach my $conversion_action_id (@$conversion_action_ids) {
    # Create the UserListActionInfo object for a given conversion action. This
    # specifies the conversion action that, when triggered, will cause a user to
    # be added to a UserList.
    push @$user_list_action_info_list,
      Google::Ads::GoogleAds::V21::Common::UserListActionInfo->new({
        conversionAction =>
          Google::Ads::GoogleAds::V21::Utils::ResourceNames::conversion_action(
          $customer_id, $conversion_action_id
          )});
  }

  # Create a basic user list info object with all of the conversion actions.
  my $basic_user_list_info =
    Google::Ads::GoogleAds::V21::Common::BasicUserListInfo->new({
      actions => $user_list_action_info_list
    });

  # Create the basic user list.
  my $basic_user_list = Google::Ads::GoogleAds::V21::Resources::UserList->new({
    name        => "Example BasicUserList #" . uniqid(),
    description =>
      "A list of people who have triggered one or more conversion actions",
    membershipStatus   => OPEN,
    membershipLifeSpan => 365,
    basicUserList      => $basic_user_list_info
  });

  # Create the operation.
  my $user_list_operation =
    Google::Ads::GoogleAds::V21::Services::UserListService::UserListOperation->
    new({
      create => $basic_user_list
    });

  # Issue a mutate request to add the user list and print some information.
  my $user_lists_response = $api_client->UserListService()->mutate({
      customerId => $customer_id,
      operations => [$user_list_operation]});

  printf
    "Created basic user list with resource name '%s'.\n",
    $user_lists_response->{results}[0]{resourceName};

  return 1;
}
# [END add_conversion_based_user_list]

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
  "customer_id=s"           => \$customer_id,
  "conversion_action_ids=s" => \@$conversion_action_ids,
);
$conversion_action_ids = [$conversion_action_id_1, $conversion_action_id_2]
  unless @$conversion_action_ids;

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $conversion_action_ids);

# Call the example.
add_conversion_based_user_list($api_client, $customer_id =~ s/-//gr,
  $conversion_action_ids);

=pod

=head1 NAME

add_conversion_based_user_list

=head1 DESCRIPTION

Creates a basic user list consisting of people who triggered one or more
conversion actions.

=head1 SYNOPSIS

add_conversion_based_user_list.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -conversion_action_ids      The IDs of the conversion actions for the basic user list.

=cut
