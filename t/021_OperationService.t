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
# Unit tests for the Google::Ads::GoogleAds::LongRunning::OperationService module.

use strict;
use warnings;

use lib qw(lib);
use Google::Ads::GoogleAds::GoogleAdsClient;
use Google::Ads::GoogleAds::Constants;
use Google::Ads::GoogleAds::LongRunning::OperationService;

use File::Basename;
use File::Spec;
use Test::More (tests => 3);

# Tests use Google::Ads::GoogleAds::LongRunning::OperationService.
use_ok("Google::Ads::GoogleAds::LongRunning::OperationService");

# Tests get OperationService from the API client.
my $properties_file =
  File::Spec->catdir(dirname($0), qw(testdata googleads_mock.properties));
my $api_client = Google::Ads::GoogleAds::GoogleAdsClient->new({
  properties_file => $properties_file
});

my $operation_service = $api_client->OperationService();

ok($operation_service, "Get OperationService from API client.");
is(
  $operation_service->get_version(),
  lc Google::Ads::GoogleAds::Constants::OPERATION_SERVICE_VERSION,
"The version in OperationService equals to Constants::OPERATION_SERVICE_VERSION."
);
