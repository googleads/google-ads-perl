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
# Module to store package-level constants and default values.

package Google::Ads::GoogleAds::Constants;

use strict;
use warnings;
use version;

use File::HomeDir;
use File::Spec::Functions;

# Main version number that the rest of the modules pick up off of.
our $VERSION = qv("30.0.0");

use constant DEFAULT_PROPERTIES_FILE =>
  catfile(File::HomeDir->my_home, "googleads.properties");

# Default Google Ads API version used if the API client is created without a
# specified version.
use constant DEFAULT_API_VERSION => "V23";

# The Google OAuth2 service base URL.
use constant OAUTH2_BASE_URL => "https://accounts.google.com/o/oauth2";

# The Google OAuth2 tokeninfo endpoint.
use constant OAUTH2_TOKEN_INFO_URL => "https://oauth2.googleapis.com/tokeninfo";

# Default OAuth2 scope for Google Ads API.
use constant DEFAULT_OAUTH2_SCOPE => "https://www.googleapis.com/auth/adwords";

# The error message when the auth handlers are not set up properly.
use constant NO_AUTH_HANDLER_SETUP_MESSAGE =>
  "The library couldn't find any authorization mechanism set up to properly " .
  "sign the requests against the API. Please read the guide for OAuth2 from " .
  "https://github.com/googleads/google-ads-perl#getting-started";

# Default Google Ads API service address.
use constant DEFAULT_SERVICE_ADDRESS => "https://googleads.googleapis.com";

# Default user-agent header for HTTP request.
use constant DEFAULT_USER_AGENT => "gl-perl/" . substr($^V, 1);

# Default LWP::UserAgent timeout in seconds.
use constant DEFAULT_HTTP_TIMEOUT => 3600;

# Default retry timing for LWP::UserAgent::Determined. The string controls how
# many times it should retry, and how long the pauses should be in seconds.
use constant DEFAULT_HTTP_RETRY_TIMING => "5,10,15";

# The LongRunning.OperationSerivce version.
use constant OPERATION_SERVICE_VERSION => "V23";

# The LongRunning.OperationSerivce name.
use constant OPERATION_SERVICE_NAME => "OperationService";

# The LongRunning.OperationSerivce class name.
use constant OPERATION_SERVICE_CLASS_NAME =>
  "Google::Ads::GoogleAds::LongRunning::OperationService";

# The Google Ads services class name template.
use constant GOOGLE_ADS_SERVICES_CLASS_NAME =>
  "Google::Ads::GoogleAds::%s::Services::%s";

# The GoogleAdsFailure class name template.
use constant GOOGLE_ADS_FAILURE_CLASS_NAME =>
  "Google::Ads::GoogleAds::V%d::Errors::GoogleAdsFailure";

# The GoogleAdsError class name template.
use constant GOOGLE_ADS_ERROR_CLASS_NAME =>
  "Google::Ads::GoogleAds::V%d::Errors::GoogleAdsError";

# The environment variables that override the loaded config values if set.
use constant ENV_VAR_CONFIGURATION_FILE_PATH =>
  "GOOGLE_ADS_CONFIGURATION_FILE_PATH";
use constant ENV_VAR_DEVELOPER_TOKEN    => "GOOGLE_ADS_DEVELOPER_TOKEN";
use constant ENV_VAR_LOGIN_CUSTOMER_ID  => "GOOGLE_ADS_LOGIN_CUSTOMER_ID";
use constant ENV_VAR_LINKED_CUSTOMER_ID => "GOOGLE_ADS_LINKED_CUSTOMER_ID";
use constant ENV_VAR_ENDPOINT           => "GOOGLE_ADS_ENDPOINT";
use constant ENV_VAR_CLIENT_ID          => "GOOGLE_ADS_CLIENT_ID";
use constant ENV_VAR_CLIENT_SECRET      => "GOOGLE_ADS_CLIENT_SECRET";
use constant ENV_VAR_REFRESH_TOKEN      => "GOOGLE_ADS_REFRESH_TOKEN";
use constant ENV_VAR_JSON_KEY_FILE_PATH => "GOOGLE_ADS_JSON_KEY_FILE_PATH";
use constant ENV_VAR_IMPERSONATED_EMAIL => "GOOGLE_ADS_IMPERSONATED_EMAIL";
use constant ENV_VAR_USER_AGENT         => "GOOGLE_ADS_PERL_USER_AGENT";
use constant ENV_VAR_PROXY              => "GOOGLE_ADS_PERL_PROXY";

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::Constants

=head1 DESCRIPTION

Module to store package-level constants and default values.

=head1 LICENSE AND COPYRIGHT

Copyright 2019 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=head1 REPOSITORY INFORMATION

 $Rev: $
 $LastChangedBy: $
 $Id: $

=cut
