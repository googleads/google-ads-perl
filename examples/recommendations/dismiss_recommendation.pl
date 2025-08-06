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
# This example dismisses a given recommendation.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use
  Google::Ads::GoogleAds::V21::Services::RecommendationService::DismissRecommendationOperation;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

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
# Recommendation ID is the last alphanumeric portion of the value from the
# resourceName field of a Recommendation, which has the format of
# customers/<customer_id>/recommendations/<recommendation_id>.
# Its example can be retrieved from get_text_ad_recommendations.pl.
my $recommendation_id = "INSERT_RECOMMENDATION_ID_HERE";

sub dismiss_recommendation {
  my ($api_client, $customer_id, $recommendation_id) = @_;

  my $recommendation_resource_name =
    Google::Ads::GoogleAds::V21::Utils::ResourceNames::recommendation(
    $customer_id, $recommendation_id);

  # Create an dismiss recommendation operation.
  my $dismiss_recommendation_operation =
    Google::Ads::GoogleAds::V21::Services::RecommendationService::DismissRecommendationOperation
    ->new({
      resourceName => $recommendation_resource_name
    });

  # Dismiss the recommendation.
  my $dismiss_recommendation_response =
    $api_client->RecommendationService()->dismiss({
      customerId => $customer_id,
      operations => [$dismiss_recommendation_operation]});

  printf "Dismissed recommendation with resource name: '%s'.\n",
    $dismiss_recommendation_response->{results}[0]{resourceName};

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
  "customer_id=s"       => \$customer_id,
  "recommendation_id=i" => \$recommendation_id,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $recommendation_id);

# Call the example.
dismiss_recommendation($api_client, $customer_id =~ s/-//gr,
  $recommendation_id);

=pod

=head1 NAME

dismiss_recommendation

=head1 DESCRIPTION

This example dismisses a given recommendation. To retrieve recommendations for
text ads, run get_text_ad_recommendations.pl.

=head1 SYNOPSIS

dismiss_recommendation.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -recommendation_id          The recommendation ID to dismiss.

=cut
