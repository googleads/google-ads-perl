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

package Google::Ads::GoogleAds::V11::Enums::ConversionActionTypeEnum;

use strict;
use warnings;

use Const::Exporter enums => [
  UNSPECIFIED                      => "UNSPECIFIED",
  UNKNOWN                          => "UNKNOWN",
  AD_CALL                          => "AD_CALL",
  CLICK_TO_CALL                    => "CLICK_TO_CALL",
  GOOGLE_PLAY_DOWNLOAD             => "GOOGLE_PLAY_DOWNLOAD",
  GOOGLE_PLAY_IN_APP_PURCHASE      => "GOOGLE_PLAY_IN_APP_PURCHASE",
  UPLOAD_CALLS                     => "UPLOAD_CALLS",
  UPLOAD_CLICKS                    => "UPLOAD_CLICKS",
  WEBPAGE                          => "WEBPAGE",
  WEBSITE_CALL                     => "WEBSITE_CALL",
  STORE_SALES_DIRECT_UPLOAD        => "STORE_SALES_DIRECT_UPLOAD",
  STORE_SALES                      => "STORE_SALES",
  FIREBASE_ANDROID_FIRST_OPEN      => "FIREBASE_ANDROID_FIRST_OPEN",
  FIREBASE_ANDROID_IN_APP_PURCHASE => "FIREBASE_ANDROID_IN_APP_PURCHASE",
  FIREBASE_ANDROID_CUSTOM          => "FIREBASE_ANDROID_CUSTOM",
  FIREBASE_IOS_FIRST_OPEN          => "FIREBASE_IOS_FIRST_OPEN",
  FIREBASE_IOS_IN_APP_PURCHASE     => "FIREBASE_IOS_IN_APP_PURCHASE",
  FIREBASE_IOS_CUSTOM              => "FIREBASE_IOS_CUSTOM",
  THIRD_PARTY_APP_ANALYTICS_ANDROID_FIRST_OPEN =>
    "THIRD_PARTY_APP_ANALYTICS_ANDROID_FIRST_OPEN",
  THIRD_PARTY_APP_ANALYTICS_ANDROID_IN_APP_PURCHASE =>
    "THIRD_PARTY_APP_ANALYTICS_ANDROID_IN_APP_PURCHASE",
  THIRD_PARTY_APP_ANALYTICS_ANDROID_CUSTOM =>
    "THIRD_PARTY_APP_ANALYTICS_ANDROID_CUSTOM",
  THIRD_PARTY_APP_ANALYTICS_IOS_FIRST_OPEN =>
    "THIRD_PARTY_APP_ANALYTICS_IOS_FIRST_OPEN",
  THIRD_PARTY_APP_ANALYTICS_IOS_IN_APP_PURCHASE =>
    "THIRD_PARTY_APP_ANALYTICS_IOS_IN_APP_PURCHASE",
  THIRD_PARTY_APP_ANALYTICS_IOS_CUSTOM =>
    "THIRD_PARTY_APP_ANALYTICS_IOS_CUSTOM",
  ANDROID_APP_PRE_REGISTRATION      => "ANDROID_APP_PRE_REGISTRATION",
  ANDROID_INSTALLS_ALL_OTHER_APPS   => "ANDROID_INSTALLS_ALL_OTHER_APPS",
  FLOODLIGHT_ACTION                 => "FLOODLIGHT_ACTION",
  FLOODLIGHT_TRANSACTION            => "FLOODLIGHT_TRANSACTION",
  GOOGLE_HOSTED                     => "GOOGLE_HOSTED",
  LEAD_FORM_SUBMIT                  => "LEAD_FORM_SUBMIT",
  SALESFORCE                        => "SALESFORCE",
  SEARCH_ADS_360                    => "SEARCH_ADS_360",
  SMART_CAMPAIGN_AD_CLICKS_TO_CALL  => "SMART_CAMPAIGN_AD_CLICKS_TO_CALL",
  SMART_CAMPAIGN_MAP_CLICKS_TO_CALL => "SMART_CAMPAIGN_MAP_CLICKS_TO_CALL",
  SMART_CAMPAIGN_MAP_DIRECTIONS     => "SMART_CAMPAIGN_MAP_DIRECTIONS",
  SMART_CAMPAIGN_TRACKED_CALLS      => "SMART_CAMPAIGN_TRACKED_CALLS",
  STORE_VISITS                      => "STORE_VISITS"
];

1;
