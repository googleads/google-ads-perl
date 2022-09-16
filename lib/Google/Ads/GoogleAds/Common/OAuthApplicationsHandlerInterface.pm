# Copyright 2022, Google LLC
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

package Google::Ads::GoogleAds::Common::OAuthApplicationsHandlerInterface;

use strict;
use warnings;
use base qw(Google::Ads::GoogleAds::Common::AuthHandlerInterface);

# Method to retrieve an authorization URL for the user to put into a browser and
# request for an authorization code.
# Meant to be implemented by a concrete class, which should issue an
# authorization code and return a valid URL for the user to authorize.
# A callback URL can be passed optionally to redirect the user after the code is
# authorized.
sub get_authorization_url {
  my ($self, $callback) = @_;
  die "Needs to be implemented by subclass";
}

# Method to issue an access token with an authorization code. After calling
# this method the auth handler should be ready to prepare the HTTP requests
# against protected API resources.
sub issue_access_token {
  my ($self, $auth_code) = @_;
  die "Needs to be implemented by subclass";
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::Common::OAuthApplicationsHandlerInterface

=head1 DESCRIPTION

Abstract interface for OAuth application flows that require user interaction.

Meant to be implemented by concrete OAuth handlers that require user intervention
for authorizing requests against the API.

=head1 METHODS

=head2 get_authorization_url

Meant to be implemented by a concrete class, which should return a valid URL for
the user to authorize the access to the API.

=head3 Returns

The URL for the user to authorize for an authorization code. The user must login
to the account that he wants to grant access to.

=head2 issue_access_token

Method to obtain/update an access token.

=head3 Parameters

=over

=item *

The authorization code returned to your callback URL.

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2022 Google LLC

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
