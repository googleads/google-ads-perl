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
# This example adds various types of negative criteria to a customer. These
# criteria will be applied to all campaigns for the customer.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V23::Resources::CustomerNegativeCriterion;
use Google::Ads::GoogleAds::V23::Common::ContentLabelInfo;
use Google::Ads::GoogleAds::V23::Common::PlacementInfo;
use Google::Ads::GoogleAds::V23::Enums::ContentLabelTypeEnum qw(TRAGEDY);

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub add_customer_negative_criteria {
  my ($api_client, $customer_id) = @_;

  # Create a negative customer criterion excluding the content label type of 'TRAGEDY'.
  my $tragedy_criterion =
    Google::Ads::GoogleAds::V23::Resources::CustomerNegativeCriterion->new({
      contentLabel =>
        Google::Ads::GoogleAds::V23::Common::ContentLabelInfo->new({
          type => TRAGEDY
        })});

  # Create a negative customer criterion excluding the placement with url
  # 'http://www.example.com'.
  my $placement_criterion =
    Google::Ads::GoogleAds::V23::Resources::CustomerNegativeCriterion->new({
      placement => Google::Ads::GoogleAds::V23::Common::PlacementInfo->new({
          url => "http://example.com"
        })});

  # Create the operations.
  my $operations =
    [{create => $tragedy_criterion}, {create => $placement_criterion}];

  # Add the negative customer criteria.
  my $customer_negative_criteria_response =
    $api_client->CustomerNegativeCriterionService()->mutate({
      customerId => $customer_id,
      operations => $operations
    });

  my $customer_negative_criterion_results =
    $customer_negative_criteria_response->{results};

  printf "Created %d new negative customer criteria.\n",
    scalar @$customer_negative_criterion_results;
  foreach my $result (@{$customer_negative_criterion_results}) {
    printf "Created new negative customer criteria with resource name '%s'.\n",
      $result->{resourceName};
  }

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
GetOptions("customer_id=s" => \$customer_id);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id);

# Call the example.
add_customer_negative_criteria($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

add_customer_negative_criteria

=head1 DESCRIPTION

This example adds various types of negative criteria to a customer. These criteria will
be applied to all campaigns for the customer.

=head1 SYNOPSIS

add_customer_negative_criteria.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
