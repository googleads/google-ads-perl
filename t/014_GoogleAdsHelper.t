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
# Unit tests for the Google::Ads::GoogleAds::Utils::GoogleAdsHelper module.

use strict;
use warnings;

use lib qw(lib);
use Google::Ads::GoogleAds::V23::Resources::Campaign;

use Test::More(tests => 39);

# Tests use Google::Ads::GoogleAds::Utils::GoogleAdsHelper.
use_ok("Google::Ads::GoogleAds::Utils::GoogleAdsHelper");

# Tests the remove_unassigned_fields() method.
my $campaign = {
  name                   => "Interplanetary Cruise",
  advertisingChannelType => "SEARCH",
  status                 => "PAUSED",
  biddingStrategy        => "MANUAL_CPC"
};

my $args = {
  name                   => "Interplanetary Cruise",
  advertisingChannelType => "SEARCH"
};

remove_unassigned_fields($campaign, $args);
ok(!exists $campaign->{status},
  "Test remove_unassigned_fields(): status removed.");
ok(!exists $campaign->{biddingStrategy},
  "Test remove_unassigned_fields(): biddingStrategy removed.");
ok(eq_hash($campaign, $args),
  "Test remove_unassigned_fields(): \$campaign equals \$args after invoked.");

remove_unassigned_fields($campaign, undef);
is(scalar(keys %$campaign),
  0, "Test remove_unassigned_fields(): all keys removed.");

# Tests the check_params method.
my $valid_param   = "1234567";
my $invalid_param = "INSERT_CUSTOMER_ID_HERE";
my $undef_param   = undef;

ok(check_params($valid_param), "Test check_params(): valid param.");
ok(
  !check_params($invalid_param, $undef_param),
  "Test check_params(): invalid and undef params."
);
ok(
  !check_params($valid_param, $invalid_param),
  "Test check_params(): valid and invalid params."
);
ok(
  !check_params($valid_param, $undef_param),
  "Test check_params(): valid and undef params."
);
ok(
  check_params([$valid_param, $valid_param]),
  "Test check_params(): valid array param."
);
ok(
  !check_params($valid_param, [$invalid_param]),
  "Test check_params(): invalid array param."
);
ok(!check_params($valid_param, []), "Test check_params(): empty array param.");

# Tests the trim() method.
my $str         = "string-value";
my $to_trim_str = "      " . $str . "      \n";
is(trim($to_trim_str), $str,
  "Test trim(): remove leading and trailing spaces and line breaks.");
is(trim(undef), undef, "Test trim: with undefined arguments.");

# Tests the expand_path_template() method.
my $path_template = "v23/googleAdsFields:search";
is(expand_path_template($path_template),
  $path_template, "Test expand_path_template(): no expand.");
is(expand_path_template($path_template, undef),
  $path_template, "Test expand_path_template(): with undefined arguments.");

$path_template = "v23/{+resourceName}";
my $resource_name = "customers/12345/campaigns/54321";
is(
  expand_path_template($path_template, $resource_name),
  "v23/customers/12345/campaigns/54321",
  "Test expand_path_template(): normal expand with scalar."
);

$path_template = "customers/{customer_id}/accountBudgets/{account_budget_id}";
my $customer_id       = 12345;
my $account_budget_id = 67890;
is(
  expand_path_template($path_template, [$customer_id, $account_budget_id]),
  "customers/12345/accountBudgets/67890",
  "Test expand_path_template(): normal expand with array reference."
);
is(
  expand_path_template(
    $path_template, [$customer_id, $account_budget_id, "extra_arg"]
  ),
  "customers/12345/accountBudgets/67890",
  "Test expand_path_template(): expand with more array elements."
);
is(
  expand_path_template($path_template, [$customer_id]),
  "customers/12345/accountBudgets/0",
  "Test expand_path_template(): expand with less array elements."
);

$path_template = "v23/customers/{+customerId}/adGroups:mutate";
is(
  expand_path_template(
    $path_template,
    {
      customerId => $customer_id,
      operations => []}
  ),
  "v23/customers/12345/adGroups:mutate",
  "Test expand_path_template(): normal expand with hash reference."
);

$path_template = "v23/{+resourceName}:listAsyncErrors";
$args          = {
  resourceName => "customers/12345/campaignDrafts/98765",
  pageSize     => 1000,
  pageToken    => "page_token"
};
is(
  expand_path_template($path_template, $args),
  "v23/customers/12345/campaignDrafts/98765:listAsyncErrors",
  "Test expand_path_template(): normal expand with args as hash reference."
);
is(scalar(keys %$args),
  2, "Test expand_path_template(): expand arg removed from hash.");

# Tests the copy_from() method.
my $original_campaign = Google::Ads::GoogleAds::V23::Resources::Campaign->new({
    name                   => "Interplanetary Cruise",
    advertisingChannelType => "SEARCH",
    status                 => "PAUSED",
    biddingStrategy        => "MANUAL_CPC",
    networkSettings        => {
      targetContentNetwork       => "true",
      targetGoogleSearch         => "true",
      targetPartnerSearchNetwork => "false",
    }});

my $copied_campaign = copy_from($original_campaign);
is_deeply($original_campaign, $copied_campaign,
  "Test copy_from(): is deeply the same.");

$copied_campaign->{status} = "ENABLED";
is($original_campaign->{status},
  "PAUSED", "Test copy_from(): modify status - original object.");
is($copied_campaign->{status},
  "ENABLED", "Test copy_from(): modify status - copied object.");

$copied_campaign->{networkSettings}{targetSearchNetwork} = "false";
ok(
  eq_hash(
    $original_campaign->{networkSettings},
    {
      targetContentNetwork       => "true",
      targetGoogleSearch         => "true",
      targetPartnerSearchNetwork => "false"
    }
  ),
  "Test copy_from(): modify hash - original object."
);
ok(
  eq_hash(
    $copied_campaign->{networkSettings},
    {
      targetContentNetwork       => "true",
      targetGoogleSearch         => "true",
      targetPartnerSearchNetwork => "false",
      targetSearchNetwork        => "false"
    }
  ),
  "Test copy_from(): modify hash - copied object."
);

is(copy_from(undef), undef, "Test copy_from(): with undefined arguments.");

# Tests the to_lower_underscore() method.
is(to_lower_underscore("CampaignSharedSet"),
  "campaign_shared_set",
  "Test to_lower_underscore(): CampaignSharedSet - campaign_shared_set.");
is(
  to_lower_underscore("targetPartnerSearchNetwork"),
  "target_partner_search_network",
"Test to_lower_underscore(): targetPartnerSearchNetwork - target_partner_search_network."
);
is(to_lower_underscore("network_settings"),
  "network_settings",
  "Test to_lower_underscore(): network_settings - network_settings.");
is(to_lower_underscore(undef),
  undef, "Test to_lower_underscore(): undef - undef.");

# Tests the to_boolean() method.
is(to_boolean(undef),  "false", "Test to_boolean(): undef.");
is(to_boolean(""),     "false", "Test to_boolean(): empty string.");
is(to_boolean(0),      "false", "Test to_boolean(): 0.");
is(to_boolean("abcd"), "true",  "Test to_boolean(): valid string.");
is(to_boolean(1),      "true",  "Test to_boolean(): 1.");

# Tests the die_with_code() method.
eval { die_with_code(-1, "die with -1."); };
ok($@, "Test die_with_code(): die wih -1.");
