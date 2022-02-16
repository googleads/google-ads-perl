#!/usr/bin/perl -w
#
# Copyright 2021, Google LLC
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
# Adds a customizer attribute, links the customizer attribute to a customer, and
# then adds a responsive search ad with a description using the ad customizer to
# the specified ad group.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V10::Resources::CustomizerAttribute;
use Google::Ads::GoogleAds::V10::Resources::CustomerCustomizer;
use Google::Ads::GoogleAds::V10::Resources::Ad;
use Google::Ads::GoogleAds::V10::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V10::Common::CustomizerValue;
use Google::Ads::GoogleAds::V10::Common::ResponsiveSearchAdInfo;
use Google::Ads::GoogleAds::V10::Common::TextAsset;
use Google::Ads::GoogleAds::V10::Enums::CustomizerAttributeTypeEnum qw(PRICE);
use Google::Ads::GoogleAds::V10::Enums::AdGroupAdStatusEnum qw(PAUSED);
use
  Google::Ads::GoogleAds::V10::Services::CustomizerAttributeService::CustomizerAttributeOperation;
use
  Google::Ads::GoogleAds::V10::Services::CustomerCustomizerService::CustomerCustomizerOperation;
use Google::Ads::GoogleAds::V10::Services::AdGroupAdService::AdGroupAdOperation;
use Google::Ads::GoogleAds::V10::Utils::ResourceNames;

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
my $ad_group_id = "INSERT_AD_GROUP_ID_HERE";
# The name of the customizer attribute to be used in the ad customizer, which must
# be unique. To run this example multiple times, change this value or specify its
# corresponding argument.
# Note that there is a limit for the number of enabled customizer attributes in
# one account, so you shouldn't run this example more than necessary.
# Visit https://developers.google.com/google-ads/api/docs/ads/customize-responsive-search-ads#rules_and_limitations
# for details.
my $customizer_attribute_name = "Price";

sub add_responsive_search_ad_with_ad_customizer {
  my ($api_client, $customer_id, $ad_group_id, $customizer_attribute_name) = @_;

  my $customizer_attribute_resource_name =
    create_customizer_attribute($api_client, $customer_id,
    $customizer_attribute_name);

  link_customizer_attribute_to_customer($api_client, $customer_id,
    $customizer_attribute_resource_name);

  create_responsive_search_ad_with_customization($api_client, $customer_id,
    $ad_group_id, $customizer_attribute_name);

  return 1;
}

# Creates a customizer attribute with the specified customizer attribute name.
# [START add_responsive_search_ad_with_ad_customizer_1]
sub create_customizer_attribute {
  my ($api_client, $customer_id, $customizer_attribute_name) = @_;

  # Create a customizer attribute with the specified name.
  my $customizer_attribute =
    Google::Ads::GoogleAds::V10::Resources::CustomizerAttribute->new({
      name => $customizer_attribute_name,
      # Specify the type to be 'PRICE' so that we can dynamically customize the part
      # of the ad's description that is a price of a product/service we advertise.
      type => PRICE
    });

  # Create a customizer attribute operation for creating a customizer attribute.
  my $operation =
    Google::Ads::GoogleAds::V10::Services::CustomizerAttributeService::CustomizerAttributeOperation
    ->new({
      create => $customizer_attribute
    });

  # Issue a mutate request to add the customizer attribute and print its information.
  my $response = $api_client->CustomizerAttributeService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});
  my $customizer_attribute_resource_name =
    $response->{results}[0]{resourceName};
  printf "Added a customizer attribute with resource name '%s'.\n",
    $customizer_attribute_resource_name;

  return $customizer_attribute_resource_name;
}
# [END add_responsive_search_ad_with_ad_customizer_1]

# Links the customizer attribute to the customer by providing a value to be used
# in a responsive search ad that will be created in a later step.
# [START add_responsive_search_ad_with_ad_customizer_2]
sub link_customizer_attribute_to_customer {
  my ($api_client, $customer_id, $customizer_attribute_resource_name) = @_;

  # Create a customer customizer with the value to be used in the responsive search ad.
  my $customer_customizer =
    Google::Ads::GoogleAds::V10::Resources::CustomerCustomizer->new({
      customizerAttribute => $customizer_attribute_resource_name,
      # Specify '100USD' as a text value. The ad customizer will dynamically replace
      # the placeholder with this value when the ad serves.
      value => Google::Ads::GoogleAds::V10::Common::CustomizerValue->new({
          type        => PRICE,
          stringValue => "100USD"
        })});

  # Create a customer customizer operation.
  my $operation =
    Google::Ads::GoogleAds::V10::Services::CustomerCustomizerService::CustomerCustomizerOperation
    ->new({
      create => $customer_customizer
    });

  # Issue a mutate request to add the customer customizer and print its information.
  my $response = $api_client->CustomerCustomizerService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});
  printf "Added a customer customizer with resource name '%s'.\n",
    $response->{results}[0]{resourceName};
}
# [END add_responsive_search_ad_with_ad_customizer_2]

# Creates a responsive search ad that uses the specified customizer attribute.
# [START add_responsive_search_ad_with_ad_customizer_3]
sub create_responsive_search_ad_with_customization {
  my ($api_client, $customer_id, $ad_group_id, $customizer_attribute_name) = @_;

  # Create an ad and set responsive search ad info.
  my $ad = Google::Ads::GoogleAds::V10::Resources::Ad->new({
      responsiveSearchAd =>
        Google::Ads::GoogleAds::V10::Common::ResponsiveSearchAdInfo->new({
          headlines => [
            Google::Ads::GoogleAds::V10::Common::TextAsset->new({
                text => "Cruise to Mars"
              }
            ),
            Google::Ads::GoogleAds::V10::Common::TextAsset->new({
                text => "Best Space Cruise Line"
              }
            ),
            Google::Ads::GoogleAds::V10::Common::TextAsset->new({
                text => "Experience the Stars"
              })
          ],
          descriptions => [
            Google::Ads::GoogleAds::V10::Common::TextAsset->new({
                text => "Buy your tickets now"
              }
            ),
            # Create this particular description using the ad customizer.
            # Visit https://developers.google.com/google-ads/api/docs/ads/customize-responsive-search-ads#ad_customizers_in_responsive_search_ads
            # for details about the placeholder format.
            # The ad customizer replaces the placeholder with the value we previously
            # created and linked to the customer using `CustomerCustomizer`.
            Google::Ads::GoogleAds::V10::Common::TextAsset->new({
                text => "Just {CUSTOMIZER.$customizer_attribute_name:10USD}"
              })
          ],
          path1 => "all-inclusive",
          path2 => "deals"
        }
        ),
      finalUrls => ["http://www.example.com"]});

  # Create an ad group ad to hold the above ad.
  my $ad_group_ad = Google::Ads::GoogleAds::V10::Resources::AdGroupAd->new({
      adGroup => Google::Ads::GoogleAds::V10::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      status => PAUSED,
      ad     => $ad
    });

  # Create an ad group ad operation.
  my $operation =
    Google::Ads::GoogleAds::V10::Services::AdGroupAdService::AdGroupAdOperation
    ->new({
      create => $ad_group_ad
    });

  # Issue a mutate request to add the ad group ad and print its information.
  my $response = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$operation]});
  printf "Created responsive search ad with resource name '%s'.\n",
    $response->{results}[0]{resourceName};
}
# [END add_responsive_search_ad_with_ad_customizer_3]

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
  "customer_id=s"               => \$customer_id,
  "ad_group_id=i"               => \$ad_group_id,
  "customizer_attribute_name=s" => \$customizer_attribute_name,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params($customer_id, $ad_group_id, $customizer_attribute_name);

# Call the example.
add_responsive_search_ad_with_ad_customizer(
  $api_client,  $customer_id =~ s/-//gr,
  $ad_group_id, $customizer_attribute_name
);

=pod

=head1 NAME

add_responsive_search_ad_with_ad_customizer

=head1 DESCRIPTION

Adds a customizer attribute, links the customizer attribute to a customer, and
then adds a responsive search ad with a description using the ad customizer to
the specified ad group.

=head1 SYNOPSIS

add_responsive_search_ad_with_ad_customizer.pl [options]

    -help                           Show the help message.
    -customer_id                    The Google Ads customer ID.
    -ad_group_id                    The ad group ID.
    -customizer_attribute_name      [optional] The name of the customizer attribute.

=cut
