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

package Google::Ads::GoogleAds::Common::AuthHandlerInterface;

use strict;
use warnings;

# Initializes the handler with the API client object and a given set
# of properties.
sub initialize {
  my ($self, $api_client, $properties) = @_;
  die "Needs to be implemented by subclass";
}

# Method that prepares an HTTP:Request with the relevant authorization
# data (i.e. headers, protected resource url, etc).
sub prepare_request {
  my ($self, $http_method, $request_url, $http_headers, $request_content) = @_;
  die "Needs to be implemented by subclass";
}

# Returns true if the handler can prepare request with the appropriate
# authorization info.
sub is_auth_enabled {
  my ($self) = @_;
  die "Needs to be implemented by subclass";
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::Common::AuthHandlerInterface

=head1 DESCRIPTION

Interface to be implemented by concrete authorization handlers. Defines the
necessary subroutines to build authorized requests against a Google API.

=head1 METHODS

=head2 initialize

Initializes the handler with the API client object and a given set of properties,
such as: client_id, client_secret, etc.

=head3 Parameters

=over

=item *

A required I<api_client> with a reference to the API client object handling the
requests against the API.

=item *

A required I<properties> with a reference to a hash of properties.

=back

=head2 prepare_request

Constructs a L<HTTP::Request> object to send an authorized request to the API.
Implementors will attach authorization headers to the request at this phase.

=head3 Parameters

=over

=item *

I<http_method>: HTTP request method, e.g. GET, POST.

=item *

I<request_url>: URL to the resource to access.

=item *

I<http_headers>: an array of HTTP headers to be included in the request.

=item *

I<request_content>: a string as the payload to be sent in the request.

=back

=head2 is_auth_enabled

Method called to check if the authorization has already been setup, so the
L</prepare_request> method can be called.

=head3 Returns

True, if the authorization is in place and the handler can prepare requests.
False, otherwise.

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
