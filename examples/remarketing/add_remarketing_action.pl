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
# This example adds a new remarketing action to the customer and then retrieves
# its associated tag snippets.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V14::Resources::RemarketingAction;
use
  Google::Ads::GoogleAds::V14::Services::RemarketingActionService::RemarketingActionOperation;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

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

# [START add_remarketing_action]
sub add_remarketing_action {
  my ($api_client, $customer_id) = @_;

  # Create a remarketing action with the specified name.
  my $remarketing_action =
    Google::Ads::GoogleAds::V14::Resources::RemarketingAction->new({
      name => "Remarketing action #" . uniqid()});

  # Create a remarketing action operation.
  my $remarketing_action_operation =
    Google::Ads::GoogleAds::V14::Services::RemarketingActionService::RemarketingActionOperation
    ->new({
      create => $remarketing_action
    });

  # Issue a mutate request to add the remarketing action and print out some information.
  my $remarketing_actions_response =
    $api_client->RemarketingActionService()->mutate({
      customerId => $customer_id,
      operations => [$remarketing_action_operation]});

  my $remarketing_action_resource_name =
    $remarketing_actions_response->{results}[0]{resourceName};
  printf
    "Added remarketing action with resource name '%s'.\n",
    $remarketing_action_resource_name;

  # Create a query that retrieves the previously created remarketing action with
  # its generated tag snippets.
  # [START add_remarketing_action_1]
  my $search_query =
    sprintf "SELECT remarketing_action.id, remarketing_action.name, " .
    "remarketing_action.tag_snippets FROM remarketing_action " .
    "WHERE remarketing_action.resource_name = '%s'",
    $remarketing_action_resource_name;
  # [END add_remarketing_action_1]

  # Issue a search request by specifying page size.
  my $search_response = $api_client->GoogleAdsService()->search({
    customerId => $customer_id,
    query      => $search_query,
    pageSize   => PAGE_SIZE
  });

  # There is only one row because we limited the search using the resource name,
  # which is unique.
  my $google_ads_row = $search_response->{results}[0];

  # Print some attributes of the remarketing action. The ID and tag snippets are
  # generated by the API.
  printf
    "Remarketing action has ID %d and name '%s'.\n\n",
    $google_ads_row->{remarketingAction}{id},
    $google_ads_row->{remarketingAction}{name};

  print "It has the following generated tag snippets:\n";

  foreach my $tag_snippet (@{$google_ads_row->{remarketingAction}{tagSnippets}})
  {
    printf "Tag snippet with code type '%s' and code page format '%s' " .
      "has the following global site tag:\n%s\n",
      $tag_snippet->{type},
      $tag_snippet->{pageFormat},
      $tag_snippet->{globalSiteTag};

    printf "and the following event snippet:\n%s\n\n",
      $tag_snippet->{eventSnippet};
  }

  return 1;
}
# [END add_remarketing_action]

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
add_remarketing_action($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

add_remarketing_action

=head1 DESCRIPTION

This example adds a new remarketing action to the customer and then retrieves its
associated tag snippets.

=head1 SYNOPSIS

add_remarketing_action.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
