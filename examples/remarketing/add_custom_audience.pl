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
# This example illustrates adding a custom audience. Custom audiences help you
# reach your ideal audience by entering relevant keywords, URLs and apps. For more
# information about custom audiences, see:
# https://support.google.com/google-ads/answer/9805516.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::CustomAudience;
use Google::Ads::GoogleAds::V21::Resources::CustomAudienceMember;
use Google::Ads::GoogleAds::V21::Enums::CustomAudienceTypeEnum   qw(SEARCH);
use Google::Ads::GoogleAds::V21::Enums::CustomAudienceStatusEnum qw(ENABLED);
use Google::Ads::GoogleAds::V21::Enums::CustomAudienceMemberTypeEnum
  qw(KEYWORD URL APP);
use
  Google::Ads::GoogleAds::V21::Services::CustomAudienceService::CustomAudienceOperation;

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

sub add_custom_audience {
  my ($api_client, $customer_id) = @_;

  # Create a custom audience.
  my $custom_audience =
    Google::Ads::GoogleAds::V21::Resources::CustomAudience->new({
      name        => "Example CustomAudience #" . uniqid(),
      description =>
        "Custom audiences who have searched specific terms on Google Search",
      # Match customers by what they searched on Google Search.
      # Note: "INTEREST" OR "PURCHASE_INTENT" is not allowed for the type field
      # of newly created custom audience. Use "AUTO" instead of these 2 options
      # when creating a new custom audience.
      type   => SEARCH,
      status => ENABLED,
      # List of members that this custom audience is composed of. Customers that
      # meet any of the membership conditions will be reached.
      members => [
        # Keywords or keyword phrases, which describe the customers' interests
        # or search terms.
        create_custom_audience_member(KEYWORD, "mars cruise"),
        create_custom_audience_member(KEYWORD, "jupiter cruise"),
        # Website URLs that your customers might visit.
        create_custom_audience_member(
          URL, "http://www.example.com/locations/mars"
        ),
        create_custom_audience_member(
          URL, "http://www.example.com/locations/jupiter"
        ),
        # Package names of Android apps which customers might install.
        create_custom_audience_member(APP, "com.google.android.apps.adwords"),
      ]});

  # Create a custom audience operation.
  my $custom_audience_operation =
    Google::Ads::GoogleAds::V21::Services::CustomAudienceService::CustomAudienceOperation
    ->new({create => $custom_audience});

  # Add the custom audience.
  my $custom_audiences_response = $api_client->CustomAudienceService()->mutate({
      customerId => $customer_id,
      operations => [$custom_audience_operation]});

  printf "New custom audience added with resource name: '%s'.\n",
    $custom_audiences_response->{results}[0]{resourceName};

  return 1;
}

# Creates a custom audience member.
sub create_custom_audience_member {
  my ($member_type, $value) = @_;
  my $custom_audience_member =
    Google::Ads::GoogleAds::V21::Resources::CustomAudienceMember->new({
      memberType => $member_type
    });

  if ($member_type eq KEYWORD) {
    $custom_audience_member->{keyword} = $value;
  } elsif ($member_type eq URL) {
    $custom_audience_member->{url} = $value;
  } elsif ($member_type eq APP) {
    $custom_audience_member->{app} = $value;
  }

  return $custom_audience_member;
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
pod2usage(2) if not check_params($customer_id);

# Call the example.
add_custom_audience($api_client, $customer_id =~ s/-//gr);

=pod

=head1 NAME

add_custom_audience

=head1 DESCRIPTION

This example illustrates adding a custom audience. Custom audiences help you
reach your ideal audience by entering relevant keywords, URLs and apps. For more
information about custom audiences, see:
https://support.google.com/google-ads/answer/9805516.

=head1 SYNOPSIS

add_custom_audience.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut
