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
# This code example adds two ad customizer attributes and associates them with the ad group.
# Then it adds an ad that uses the ad customizer attributes to populate dynamic data.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::V21::Resources::AttributeFieldMapping;
use Google::Ads::GoogleAds::V21::Resources::Ad;
use Google::Ads::GoogleAds::V21::Resources::AdGroupAd;
use Google::Ads::GoogleAds::V21::Resources::AdGroupCustomizer;
use Google::Ads::GoogleAds::V21::Resources::CustomizerAttribute;
use Google::Ads::GoogleAds::V21::Common::AdTextAsset;
use Google::Ads::GoogleAds::V21::Common::CustomizerValue;
use Google::Ads::GoogleAds::V21::Common::ResponsiveSearchAdInfo;
use Google::Ads::GoogleAds::V21::Enums::CustomizerAttributeTypeEnum
  qw(TEXT PRICE);
use Google::Ads::GoogleAds::V21::Enums::ServedAssetFieldTypeEnum qw(HEADLINE_1);
use Google::Ads::GoogleAds::V21::Services::AdGroupAdService::AdGroupAdOperation;
use
  Google::Ads::GoogleAds::V21::Services::AdGroupCustomizerService::AdGroupCustomizerOperation;
use
  Google::Ads::GoogleAds::V21::Services::CustomizerAttributeService::CustomizerAttributeOperation;
use Google::Ads::GoogleAds::V21::Utils::ResourceNames;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd          qw(abs_path);
use Data::Uniqid qw(uniqid);

sub add_ad_customizer {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  my $string_customizer_name = "Planet_" . uniqid();
  my $price_customizer_name  = "Price_" . uniqid();

  my $text_customizer_attribute_resource_name =
    create_text_customizer_attribute($api_client, $customer_id,
    $string_customizer_name);
  my $price_customizer_attribute_resource_name =
    create_price_customizer_attribute($api_client, $customer_id,
    $price_customizer_name);

  # Link the customizer attributes to the ad group.
  link_customizer_attributes(
    $api_client, $customer_id, $ad_group_id,
    $text_customizer_attribute_resource_name,
    $price_customizer_attribute_resource_name
  );

  # Create an ad with the customizations provided by the ad customizer attributes.
  create_ad_with_customizations($api_client, $customer_id, $ad_group_id,
    $string_customizer_name, $price_customizer_name);

  return 1;
}

# Creates a text customizer attribute and returns its resource name.
# [START add_ad_customizer]
sub create_text_customizer_attribute {
  my ($api_client, $customer_id, $customizer_name) = @_;

  # Creates a text customizer attribute. The customizer attribute name is
  # arbitrary and will be used as a placeholder in the ad text fields.
  my $text_attribute =
    Google::Ads::GoogleAds::V21::Resources::CustomizerAttribute->new({
      name => $customizer_name,
      type => TEXT
    });

  # Create a customizer attribute operation for creating a customizer attribute.
  my $text_attribute_operation =
    Google::Ads::GoogleAds::V21::Services::CustomizerAttributeService::CustomizerAttributeOperation
    ->new({
      create => $text_attribute
    });

  # Issue a mutate request to add the customizer attribute.
  my $response = $api_client->CustomizerAttributeService()->mutate({
      customerId => $customer_id,
      operations => [$text_attribute_operation]});

  my $customizer_attribute_resource_name =
    $response->{results}[0]{resourceName};
  printf "Added text customizer attribute with resource name '%s'.\n",
    $customizer_attribute_resource_name;

  return $customizer_attribute_resource_name;
}
# [END add_ad_customizer]

# Creates a price customizer attribute and returns its resource name.
# [START add_ad_customizer_1]
sub create_price_customizer_attribute {
  my ($api_client, $customer_id, $customizer_name) = @_;

  # Creates a price customizer attribute. The customizer attribute name is
  # arbitrary and will be used as a placeholder in the ad text fields.
  my $price_attribute =
    Google::Ads::GoogleAds::V21::Resources::CustomizerAttribute->new({
      name => $customizer_name,
      type => PRICE
    });

  # Create a customizer attribute operation for creating a customizer attribute.
  my $price_attribute_operation =
    Google::Ads::GoogleAds::V21::Services::CustomizerAttributeService::CustomizerAttributeOperation
    ->new({
      create => $price_attribute
    });

  # Issue a mutate request to add the customizer attribute.
  my $response = $api_client->CustomizerAttributeService()->mutate({
      customerId => $customer_id,
      operations => [$price_attribute_operation]});

  my $customizer_attribute_resource_name =
    $response->{results}[0]{resourceName};
  printf "Added price customizer attribute with resource name '%s'.\n",
    $customizer_attribute_resource_name;

  return $customizer_attribute_resource_name;
}
# [END add_ad_customizer_1]

# Restricts the ad customizer attributes to work only with a specific ad group;
# this prevents the customizer attributes from being used elsewhere and makes sure
# they are used only for customizing a specific ad group.
# [START add_ad_customizer_2]
sub link_customizer_attributes {
  my (
    $api_client, $customer_id, $ad_group_id,
    $text_customizer_attribute_resource_name,
    $price_customizer_attribute_resource_name
  ) = @_;

  my $ad_group_customizer_operations = [];

  # Binds the text attribute customizer to a specific ad group to
  # make sure it will only be used to customizer ads inside that ad group.
  my $marsCustomizer =
    Google::Ads::GoogleAds::V21::Resources::AdGroupCustomizer->new({
      customizerAttribute => $text_customizer_attribute_resource_name,
      value => Google::Ads::GoogleAds::V21::Common::CustomizerValue->new({
          type        => TEXT,
          stringValue => "Mars"
        }
      ),
      adGroup => Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      )});

  push @$ad_group_customizer_operations,
    Google::Ads::GoogleAds::V21::Services::AdGroupCustomizerService::AdGroupCustomizerOperation
    ->new({
      create => $marsCustomizer
    });

  # Binds the price attribute customizer to a specific ad group to
  # make sure it will only be used to customizer ads inside that ad group.
  my $priceCustomizer =
    Google::Ads::GoogleAds::V21::Resources::AdGroupCustomizer->new({
      customizerAttribute => $price_customizer_attribute_resource_name,
      value => Google::Ads::GoogleAds::V21::Common::CustomizerValue->new({
          type        => PRICE,
          stringValue => "100.0€"
        }
      ),
      adGroup => Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      )});

  push @$ad_group_customizer_operations,
    Google::Ads::GoogleAds::V21::Services::AdGroupCustomizerService::AdGroupCustomizerOperation
    ->new({
      create => $priceCustomizer
    });

  # Issue a mutate request to link the customizers to the ad group.
  my $mutate_ad_group_customizers_response =
    $api_client->AdGroupCustomizerService()->mutate({
      customerId => $customer_id,
      operations => $ad_group_customizer_operations
    });

  # Display the results.
  foreach my $result (@{$mutate_ad_group_customizers_response->{results}}) {
    printf "Added an ad group customizer with resource name '%s'.\n",
      $result->{resourceName};
  }
}
# [END add_ad_customizer_2]

# Creates a responsive search ad that uses the ad customizer attributes to populate the placeholders.
# [START add_ad_customizer_3]
sub create_ad_with_customizations {
  my ($api_client, $customer_id, $ad_group_id, $string_customizer_name,
    $price_customizer_name)
    = @_;

  # Creates a responsive search ad using the attribute customizer names as
  # placeholders and default values to be used in case there are no attribute
  # customizer values.
  my $responsive_search_ad_info =
    Google::Ads::GoogleAds::V21::Common::ResponsiveSearchAdInfo->new({
      headlines => [
        Google::Ads::GoogleAds::V21::Common::AdTextAsset->new({
            text =>
              "Luxury cruise to {CUSTOMIZER.$string_customizer_name:Venus}",
            pinnedField => HEADLINE_1
          }
        ),
        Google::Ads::GoogleAds::V21::Common::AdTextAsset->new({
            text => "Only {CUSTOMIZER.$price_customizer_name:10.0€}",
          }
        ),
        Google::Ads::GoogleAds::V21::Common::AdTextAsset->new({
            text =>
"Cruise to {CUSTOMIZER.$string_customizer_name:Venus} for {CUSTOMIZER.$price_customizer_name:10.0€}",
          })
      ],
      descriptions => [
        Google::Ads::GoogleAds::V21::Common::AdTextAsset->new({
            text =>
              "Tickets are only {CUSTOMIZER.$price_customizer_name:10.0€}!",
          }
        ),
        Google::Ads::GoogleAds::V21::Common::AdTextAsset->new({
            text =>
"Buy your tickets to {CUSTOMIZER.$string_customizer_name:Venus} now!"
          })]});

  my $ad = Google::Ads::GoogleAds::V21::Resources::Ad->new({
      responsiveSearchAd => $responsive_search_ad_info,
      finalUrls          => ["https://www.example.com"]});

  my $ad_group_ad = Google::Ads::GoogleAds::V21::Resources::AdGroupAd->new({
      ad      => $ad,
      adGroup => Google::Ads::GoogleAds::V21::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      )});

  my $ad_group_ad_operation =
    Google::Ads::GoogleAds::V21::Services::AdGroupAdService::AdGroupAdOperation
    ->new({
      create => $ad_group_ad
    });

  # Issue a mutate request to add the ads.
  my $response = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]});

  my $ad_group_ad_resource_name = $response->{results}[0]{resourceName};
  printf "Added an ad with resource name '%s'.\n", $ad_group_ad_resource_name;
}
# [END add_ad_customizer_3]

# Don't run the example if the file is being included.
if (abs_path($0) ne abs_path(__FILE__)) {
  return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

my $customer_id = undef;
my $ad_group_id = undef;

# Parameters passed on the command line will override any parameters set in code.
GetOptions(
  "customer_id=s" => \$customer_id,
  "ad_group_id=i" => \$ad_group_id
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id, $ad_group_id);

# Call the example.
add_ad_customizer($api_client, $customer_id =~ s/-//gr, $ad_group_id);

=pod

=head1 NAME

add_ad_customizer

=head1 DESCRIPTION

This code example adds two ad customizer attributes and associates them with the ad group.
Then it adds an ad that uses the ad customizer attributes to populate dynamic data.

=head1 SYNOPSIS

add_ad_customizer.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -ad_group_id                The ad group ID to add the ad customizers to.

=cut
