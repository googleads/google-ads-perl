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

package TestUtils;

use strict;
use warnings;

use Google::Ads::GoogleAds::GoogleAdsClient;

use Exporter 'import';
our @EXPORT = qw(get_test_client get_test_client_no_auth read_file_content
  read_client_properties);

use File::Basename;
use File::Spec;
use Config::Properties;
use Test::MockObject::Extends;

# Constructs a GoogleAdsClient instance using the configurations in the
# 'testdata/googleads_test.properties' file.
sub get_test_client {
  my $api_version = shift;

  my $properties_file =
    File::Spec->catdir(dirname($0), qw(testdata googleads_test.properties));

  my $api_client =
    Google::Ads::GoogleAds::GoogleAdsClient->new(
    {properties_file => $properties_file});

  Google::Ads::GoogleAds::Logging::GoogleAdsLogger::enable_all_logging();
  if ($api_version) {
    $api_client->set_version($api_version);
  }

  return $api_client;
}

# Constructs a GoogleAdsClient instance with a mocked OAuth2 handler, using
# the configurations in the 'testdata/googleads_test.properties' file.
sub get_test_client_no_auth {
  my $properties_file =
    File::Spec->catdir(dirname($0), qw(testdata googleads_test.properties));

  my $api_client =
    Google::Ads::GoogleAds::GoogleAdsClient->new(
    {properties_file => $properties_file});

  $api_client = Test::MockObject::Extends->new($api_client);
  $api_client->mock("_get_auth_handler", sub { return undef; });

  return $api_client;
}

# Reads a text file content.
sub read_file_content {
  my $file = File::Spec->catdir(dirname($0), @_);

  return do {
    open(DATA, "<:encoding(UTF-8)", $file)
      or die("Can't open \$file\": $!\n");
    local $/;
    <DATA>;
  };
}

# Reads the properties in the 'testdata/googleads_test.properties' file.
sub read_client_properties() {
  return __read_properties(
    File::Spec->catdir(dirname($0), qw(testdata googleads_test.properties)));
}

# Reads a properties file into a hash object.
sub __read_properties {
  my $properties_file = shift;
  open(PROPS, "< $properties_file") or die "Unable to read properties file.";
  my $properties = new Config::Properties();
  $properties->load(*PROPS);
  return $properties;
}

return 1;
