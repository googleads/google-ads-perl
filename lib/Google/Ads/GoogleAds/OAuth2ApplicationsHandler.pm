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

package Google::Ads::GoogleAds::OAuth2ApplicationsHandler;

use strict;
use warnings;
use version;
use base qw(Google::Ads::GoogleAds::Common::OAuth2ApplicationsHandler);

# The following needs to be on one line because CPAN uses a particularly hacky
# eval() to determine module versions.
use Google::Ads::GoogleAds::Constants; our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};

use Class::Std::Fast;
use URI::Escape;

# Retrieves the OAuth2 scopes as an array.
sub _scope {
  my ($self)            = @_;
  my @parsed_scopes     = ();
  my $additional_scopes = $self->get_additional_scopes();
  if ($additional_scopes) {
    @parsed_scopes = split(/\s*,\s*/, $additional_scopes);
  }
  push @parsed_scopes, Google::Ads::GoogleAds::Constants::DEFAULT_OAUTH2_SCOPE;
  return @parsed_scopes;
}

# Retrieves the OAuth2 scopes defined in _scope as a list of encoded URLs
# separated by pluses.
# This is the format expected when sending the OAuth2 request in a URL.
sub _formatted_scopes {
  my ($self) = @_;
  my @parsed_scopes = $self->_scope();
  # Removes spaces and replaces commas with pluses. Encode the URI.
  # Don't encode the plus!
  # Example:
  # https://www.googleapis.com/auth/adwords,https://
  # www.googleapis.com/auth/analytics
  # changes to
  # https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fadwords+https%3A%2F%2F
  # www.googleapis.com%2Fauth%2Fanalytics
  foreach my $single_scope (@parsed_scopes) {
    $single_scope = uri_escape($single_scope);
  }
  return join('+', @parsed_scopes);
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::OAuth2ApplicationsHandler

=head1 DESCRIPTION

A concrete implementation of
L<Google::Ads::GoogleAds::Common::OAuth2ApplicationsHandler> that defines the
scope required to access the Google Ads API server using OAuth2 for Web/Installed
Applications. See L<https://developers.google.com/accounts/docs/OAuth2>
for details of the protocol.

Refer to the base object L<Google::Ads::GoogleAds::Common::OAuth2ApplicationsHandler>
for a complete documentation of all the methods supported by this handler class.

=head1 ATTRIBUTES

Each of these attributes can be set via
Google::Ads::GoogleAds::OAuth2ApplicationsHandler->new().

Alternatively, there is a get_ and set_ method associated with each attribute
for retrieving or setting them dynamically.

Refer to L<Google::Ads::GoogleAds::Common::OAuth2ApplicationsHandler> documentation
of all the supported attributes.

=head1 METHODS

=head2 _scope

Method defined by L<Google::Ads::GoogleAds::Common::OAuth2BaseHandler> and
implemented in this class to return the required OAuth2 scopes as an array.

=head3 Returns

An array of required OAuth2 scopes for authorization.

=head2 _formatted_scopes

Method defined by L<Google::Ads::GoogleAds::Common::OAuth2ApplicationsHandler>
and implemented in this class to return the OAuth2 scopes as a list of encoded
URLs separated by pluses. This is the format expected when sending the OAuth2
request in a URL.

=head3 Returns

The encoded URL string of OAuth2 scopes separated by pluses.

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
