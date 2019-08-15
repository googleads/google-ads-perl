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
# Unit tests for the Google::Ads::GoogleAds::Utils::MediaUtils module.

use strict;
use warnings;

use lib qw(lib t/utils);

use Test::More (tests => 4);

# Tests use Google::Ads::GoogleAds::Utils::PartialFailureUtils.
use_ok("Google::Ads::GoogleAds::Utils::MediaUtils");

# Tests the get_base64_data_from_url() method.
ok(
  get_base64_data_from_url("https://goo.gl/3b9Wfh"),
  "Test get_base64_data_from_url(): valid url."
);
ok(
  !get_base64_data_from_url("https://invalid"),
  "Test get_base64_data_from_url(): invalid url."
);
ok(!get_base64_data_from_url(undef),
  "Test get_base64_data_from_url(): undef url.");

