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
our $VERSION = qv("3.0.0");

use constant DEFAULT_PROPERTIES_FILE =>
  catfile(File::HomeDir->my_home, "googleads.properties");

# Default Google Ads API version used if the API client is created without a
# specified version.
use constant DEFAULT_API_VERSION => "V3";

# Default OAuth2 scope for Google Ads API.
use constant DEFAULT_OAUTH2_SCOPE => "https://www.googleapis.com/auth/adwords";

# The error message when the auth handlers are not set up properly.
use constant NO_AUTH_HANDLER_SETUP_MESSAGE =>
  "The library couldn't find any authorization mechanism set up to properly " .
  "sign the requests against the API. Please read the guide for OAuth2 from " .
  "https://github.com/googleads/google-ads-perl#getting-started";

# Default Google Ads API service address.
use constant DEFAULT_SERVICE_ADDRESS => "https://googleads.googleapis.com/";

# Default user-agent header for HTTP request.
use constant DEFAULT_USER_AGENT => "gl-perl/" . substr($^V, 1);

# Default LWP::UserAgent timeout.
use constant DEFAULT_HTTP_TIMEOUT => 3600;

# The LongRunning.OperationSerivce version.
use constant OPERATION_SERVICE_VERSION => "V3";

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
