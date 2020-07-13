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

package TestAPIUtils;

use strict;
use warnings;

use Google::Ads::GoogleAds::V4::Utils::ResourceNames;

use Data::Uniqid qw(uniqid);

# Creates a campaign with the channel type and additional settings if specified.
sub create_campaign {
  my ($api_client, $customer_id, $advertising_channel_type,
    $additional_settings) = @_;

  my $campaign_budget =
    __get_api_package($api_client, "Resources", "CampaignBudget", 1)->new({
      name             => "Campaign Budget #" . uniqid(),
      amountMicros     => 50000000,
      deliveryMethod   => "STANDARD",
      explicitlyShared => "false"
    });

  my $campaign_budget_operation =
    __get_api_package($api_client, "CampaignBudgetService",
    "CampaignBudgetOperation", 1)->new({
      create => $campaign_budget
    });

  my $campaign_budget_resource_name =
    $api_client->CampaignBudgetService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_budget_operation]})->{results}[0]{resourceName};

  my $campaign =
    __get_api_package($api_client, "Resources", "Campaign", 1)->new({
      name                   => "Campaign #" . uniqid(),
      advertisingChannelType => $advertising_channel_type,
      # Set the bidding strategy and budget.
      manualCpc => __get_api_package($api_client, "Common", "ManualCpc", 1)
        ->new({enhancedCpcEnabled => "false"}),
      campaignBudget => $campaign_budget_resource_name
    });

  # Merge the additional settings into the created campaign if specified.
  @$campaign{keys %$additional_settings} = values %$additional_settings;

  my $campaign_operation =
    __get_api_package($api_client, "CampaignService", "CampaignOperation", 1)
    ->new({
      create => $campaign
    });

  my $campaign_resource_name = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]})->{results}[0]{resourceName};

  return __extract_id($campaign_resource_name);
}

# Creates a campaign with the channel type, channel sub type and additional settings
# if specified.
sub create_campaign_with_sub_type {
  my ($api_client, $customer_id, $advertising_channel_type,
    $advertising_channel_sub_type, $additional_settings)
    = @_;

  my $campaign_budget =
    __get_api_package($api_client, "Resources", "CampaignBudget", 1)->new({
      name             => "Campaign Budget #" . uniqid(),
      amountMicros     => 50000000,
      deliveryMethod   => "STANDARD",
      explicitlyShared => "false"
    });

  my $campaign_budget_operation =
    __get_api_package($api_client, "CampaignBudgetService",
    "CampaignBudgetOperation", 1)->new({
      create => $campaign_budget
    });

  my $campaign_budget_resource_name =
    $api_client->CampaignBudgetService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_budget_operation]})->{results}[0]{resourceName};

  my $campaign =
    __get_api_package($api_client, "Resources", "Campaign", 1)->new({
      name                      => "Campaign #" . uniqid(),
      advertisingChannelType    => $advertising_channel_type,
      advertisingChannelSubType => $advertising_channel_sub_type,
      # Set the bidding strategy and budget.
      manualCpc => __get_api_package($api_client, "Common", "ManualCpc", 1)
        ->new({enhancedCpcEnabled => "false"}),
      campaignBudget => $campaign_budget_resource_name
    });

  # Merge the additional settings into the created campaign if specified.
  @$campaign{keys %$additional_settings} = values %$additional_settings;

  my $campaign_operation =
    __get_api_package($api_client, "CampaignService", "CampaignOperation", 1)
    ->new({
      create => $campaign
    });

  my $campaign_resource_name = $api_client->CampaignService()->mutate({
      customerId => $customer_id,
      operations => [$campaign_operation]})->{results}[0]{resourceName};

  return __extract_id($campaign_resource_name);
}

# Creates an ad group with the additional settings if specified.
sub create_ad_group {
  my ($api_client, $customer_id, $campaign_id, $additional_settings) = @_;

  my $ad_group =
    __get_api_package($api_client, "Resources", "AdGroup", 1)->new({
      name     => "Ad group #" . uniqid(),
      campaign => Google::Ads::GoogleAds::V4::Utils::ResourceNames::campaign(
        $customer_id, $campaign_id
      ),
      cpcBidMicros => 500000
    });

  # Merge the additional settings into the created ad group if specified.
  @$ad_group{keys %$additional_settings} = values %$additional_settings;

  my $ad_group_operation =
    __get_api_package($api_client, "AdGroupService", "AdGroupOperation", 1)
    ->new({
      create => $ad_group
    });

  my $ad_group_resource_name = $api_client->AdGroupService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_operation]})->{results}[0]{resourceName};

  return __extract_id($ad_group_resource_name);
}

# Creates a keyword.
sub create_keyword {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  my $ad_group_criterion =
    __get_api_package($api_client, "Resources", "AdGroupCriterion", 1)->new({
      adGroup => Google::Ads::GoogleAds::V4::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      keyword =>
        __get_api_package($api_client, "Common", "KeywordInfo", 1)->new({
          text      => "Luxury Cruise to Mars",
          matchType => "BROAD"
        })});

  my $ad_group_criterion_operation =
    __get_api_package($api_client, "AdGroupCriterionService",
    "AdGroupCriterionOperation", 1)->new({
      create => $ad_group_criterion
    });

  my $ad_group_criterion_resource_name =
    $api_client->AdGroupCriterionService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_criterion_operation]}
  )->{results}[0]{resourceName};

  return __extract_id($ad_group_criterion_resource_name);
}

# Creates a text ad.
sub create_text_ad {
  my ($api_client, $customer_id, $ad_group_id) = @_;

  my $expanded_text_ad_info =
    __get_api_package($api_client, "Common", "ExpandedTextAdInfo", 1)->new({
      description   => "Buy your tickets now!",
      headlinePart1 => "Luxury Cruise to Mars",
      headlinePart2 => "Best Space Cruise Line",
      path1         => "all-inclusive",
      path2         => "deals"
    });

  my $ad_group_ad =
    __get_api_package($api_client, "Resources", "AdGroupAd", 1)->new({
      adGroup => Google::Ads::GoogleAds::V4::Utils::ResourceNames::ad_group(
        $customer_id, $ad_group_id
      ),
      ad => __get_api_package($api_client, "Resources", "Ad", 1)->new({
          expandedTextAd => $expanded_text_ad_info,
          finalUrls      => ["http://www.example.com/"]})});

  my $ad_group_ad_operation =
    __get_api_package($api_client, "AdGroupAdService", "AdGroupAdOperation", 1)
    ->new({
      create => $ad_group_ad
    });

  my $ad_group_ad_resource_name = $api_client->AdGroupAdService()->mutate({
      customerId => $customer_id,
      operations => [$ad_group_ad_operation]})->{results}[0]{resourceName};

  return __extract_id($ad_group_ad_resource_name);
}

# Creates a label.
sub create_label {
  my ($api_client, $customer_id) = @_;

  my $label = __get_api_package($api_client, "Resources", "Label", 1)->new({
      name => "Label #" . uniqid(),
      textLabel =>
        __get_api_package($api_client, "Common", "TextLabel", 1)->new({
          description => "FT test label."
        })});

  my $label_operation =
    __get_api_package($api_client, "LabelService", "LabelOperation", 1)->new({
      create => $label
    });

  my $label_resource_name = $api_client->LabelService()->mutate({
      customerId => $customer_id,
      operations => [$label_operation]})->{results}[0]{resourceName};

  return __extract_id($label_resource_name);
}

# Deletes a label.
sub delete_label {
  my ($api_client, $customer_id, $label_id) = @_;

  my $label_operation =
    __get_api_package($api_client, "LabelService", "LabelOperation", 1)->new({
      remove => Google::Ads::GoogleAds::V4::Utils::ResourceNames::label(
        $customer_id, $label_id
      )});

  $api_client->LabelService()->mutate({
      customerId => $customer_id,
      operations => [$label_operation]});
}

# Gets the full package name of a module based on the type and name.
sub __get_api_package {
  my ($api_client, $type, $name, $import) = @_;

  my $api_version       = $api_client->get_version();
  my $full_package_name = sprintf "Google::Ads::GoogleAds::%s::", $api_version;

  $full_package_name .= "Services::" if $type =~ /\S+Service$/;
  $full_package_name .= sprintf "%s::%s", $type, $name;

  if ($import) {
    eval("use $full_package_name");
  }

  return $full_package_name;
}

# Extracts the ID from a resource name.
sub __extract_id {
  shift =~ /(\d+)$/;
  return $1;
}

1;
