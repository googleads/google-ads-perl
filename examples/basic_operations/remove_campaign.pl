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
# This example removes a campaign. To get campaigns, run get_campaigns.pl.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V11::Services::CampaignService::CampaignOperation;
use Google::Ads::GoogleAds::V11::Utils::ResourceNames;

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
my $campaign_id = "INSERT_CAMPAIGN_ID_HERE";

sub remove_campaign {
  my ($api_client, $customer_id, $campaign_id) = @_;

  # Create a single remove operation, specifying the campaign's resource name.
  my $campaign_operation =
    Google::Ads::GoogleAds::V11::Services::CampaignService::CampaignOperation->
    new({
      remove => Google::Ads::GoogleAds::V11::Utils::ResourceNames::campaign(
        $customer_id, $campaign_id
      )});

  # Remove the campaign.
  my $campaigns_response = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]});

  printf "Removed campaign with resource name: '%s'.\n",
    $campaigns_response->{results}[0]{resourceName};

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
  "customer_id=s" => \$customer_id,
  "campaign_id=i" => \$campaign_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $campaign_id);

# Call the example.
remove_campaign($api_client, $customer_id =~ s/-//gr, $campaign_id);

=pod

=head1 NAME

remove_campaign

=head1 DESCRIPTION

This example removes a campaign. To get campaigns, run get_campaigns.pl.

=head1 SYNOPSIS

remove_campaign.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.

=cut
