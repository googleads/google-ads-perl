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
# This example illustrates adding a conversion action.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::ConversionAction;
use Google::Ads::GoogleAds::V21::Resources::ValueSettings;
use Google::Ads::GoogleAds::V21::Enums::ConversionActionCategoryEnum
  qw(DEFAULT);
use Google::Ads::GoogleAds::V21::Enums::ConversionActionTypeEnum   qw(WEBPAGE);
use Google::Ads::GoogleAds::V21::Enums::ConversionActionStatusEnum qw(ENABLED);
use
  Google::Ads::GoogleAds::V21::Services::ConversionActionService::ConversionActionOperation;

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

# [START add_conversion_action]
sub add_conversion_action {
  my ($api_client, $customer_id) = @_;

  # Note that conversion action names must be unique.
  # If a conversion action already exists with the specified conversion_action_name,
  # the create operation fails with error ConversionActionError.DUPLICATE_NAME.
  my $conversion_action_name = "Earth to Mars Cruises Conversion #" . uniqid();

  # Create a conversion action.
  my $conversion_action =
    Google::Ads::GoogleAds::V21::Resources::ConversionAction->new({
      name                          => $conversion_action_name,
      category                      => DEFAULT,
      type                          => WEBPAGE,
      status                        => ENABLED,
      viewThroughLookbackWindowDays => 15,
      valueSettings                 =>
        Google::Ads::GoogleAds::V21::Resources::ValueSettings->new({
          defaultValue          => 23.41,
          alwaysUseDefaultValue => "true"
        })});

  # Create a conversion action operation.
  my $conversion_action_operation =
    Google::Ads::GoogleAds::V21::Services::ConversionActionService::ConversionActionOperation
    ->new({create => $conversion_action});

  # Add the conversion action.
  my $conversion_actions_response =
    $api_client->ConversionActionService()->mutate({
      customerId => $customer_id,
      operations => [$conversion_action_operation]});

  printf "New conversion action added with resource name: '%s'.\n",
    $conversion_actions_response->{results}[0]{resourceName};

  return 1;
}
# [END add_conversion_action]

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
add_conversion_action($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

add_conversion_action

=head1 DESCRIPTION

This example illustrates adding a conversion action.

=head1 SYNOPSIS

add_conversion_action.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
