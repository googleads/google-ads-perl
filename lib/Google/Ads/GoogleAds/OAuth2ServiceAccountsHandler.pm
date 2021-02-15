# Copyright 2021, Google LLC
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

package Google::Ads::GoogleAds::OAuth2ServiceAccountsHandler;

use strict;
use warnings;
use version;
use base qw(Google::Ads::GoogleAds::Common::OAuth2BaseHandler);

# The following needs to be on one line because CPAN uses a particularly hacky
# eval() to determine module versions.
use Google::Ads::GoogleAds::Constants; our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};

use Class::Std::Fast;
use JSON::XS;
use JSON::WebToken;

# Class::Std-style attributes. Need to be kept in the same line.
# These need to go in the same line for older Perl interpreters to understand.
my %json_key_file_path_of : ATTR(:name<json_key_file_path> :default<>);
my %impersonated_email_of : ATTR(:name<impersonated_email> :default<>);
my %additional_scopes_of : ATTR(:name<additional_scopes> :default<>);

# Methods from Google::Ads::GoogleAds::Common::AuthHandlerInterface.
sub initialize : CUMULATIVE(BASE FIRST) {
  my ($self, $api_client, $properties) = @_;
  my $ident = ident $self;

  $json_key_file_path_of{$ident} = $properties->{jsonKeyFilePath}
    || $json_key_file_path_of{$ident};
  $impersonated_email_of{$ident} = $properties->{impersonatedEmail}
    || $impersonated_email_of{$ident};

  # Below attributes are not in the googleads.properties configuration.
  $additional_scopes_of{$ident} = $properties->{additionalScopes}
    || $additional_scopes_of{$ident};
}

# Methods from Google::Ads::GoogleAds::Common::OAuth2BaseHandler.
sub _refresh_access_token {
  my $self = shift;

  if (!$self->get_json_key_file_path()) {
    return 0;
  }

  my $json_key = $self->__read_json_key_file() || return 0;
  my $time     = time;

  my $jwt = JSON::WebToken->encode({
      iss   => $json_key->{client_email},
      scope => $self->__formatted_scopes(),
      aud   => Google::Ads::GoogleAds::Constants::OAUTH2_BASE_URL . "/token",
      exp   => $time + 3600,
      iat   => $time,
      sub   => $self->get_impersonated_email()
    },
    $json_key->{private_key},
    "RS256"
  );

  my $response = $self->get___lwp_agent()->post(
    Google::Ads::GoogleAds::Constants::OAUTH2_BASE_URL . "/token",
    {
      grant_type => "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion  => $jwt
    });

  if (!$response->is_success()) {
    my $err_msg = $response->decoded_content();
    $self->get_api_client()->get_die_on_faults()
      ? die($err_msg)
      : warn($err_msg);
    return 0;
  }

  my $content_hash = $self->__parse_auth_response($response->decoded_content());

  $self->set_access_token($content_hash->{access_token});
  $self->set_access_token_expires(time + $content_hash->{expires_in});

  return 1;
}

sub _scope {
  my $self              = shift;
  my @parsed_scopes     = ();
  my $additional_scopes = $self->get_additional_scopes();
  if ($additional_scopes) {
    @parsed_scopes = split(/\s*,\s*/, $additional_scopes);
  }
  push @parsed_scopes, Google::Ads::GoogleAds::Constants::DEFAULT_OAUTH2_SCOPE;
  return @parsed_scopes;
}

# Retrieves the OAuth2 scopes defined in _scope as a list separated by commas.
# This is the format expected when sending the OAuth request.
sub __formatted_scopes {
  my $self          = shift;
  my @parsed_scopes = $self->_scope();
  return join(',', @parsed_scopes);
}

# Reads the values from the specified JSON key file path as a JSON object.
sub __read_json_key_file {
  my $self = shift;

  my $json_text;
  open(KEY_FILE, $self->get_json_key_file_path()) || return 0;
  while (<KEY_FILE>) {
    $json_text .= $_;
  }
  close(KEY_FILE);

  return decode_json($json_text);
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::OAuth2ServiceAccountsHandler

=head1 DESCRIPTION

A concrete implementation of L<Google::Ads::GoogleAds::Common::OAuth2BaseHandler>
that supports OAuth2 for service accounts and defines the scope required to
access the Google Ads API server.

See L<https://developers.google.com/identity/protocols/oauth2/service-account>
for details of the protocol.

=head1 ATTRIBUTES

Each of these attributes can be set via
Google::Ads::GoogleAds::OAuth2ServiceAccountsHandler->new().

Alternatively, there is a get_ and set_ method associated with each attribute
for retrieving or setting them dynamically.

=head2 api_client

A reference to the API client used to handle the API requests.

=head2 json_key_file_path

The absolute path to the local JSON key file for the OAuth2 service account.

=head2 impersonated_email

The email address account to impersonate, when the service account has been
delegated domain wide access.

=head2 access_token

Stores an OAuth2 access token after the authorization flow is followed or for
you to manually set it in case you had it previously stored. If this is manually
set this handler will verify its validity before preparing a request.

=head2 additional_scopes

Stores additional OAuth2 scopes as a comma-separated string.
These scopes define which services the tokens are allowed to access,
e.g. https://www.googleapis.com/auth/analytics.

=head1 METHODS

=head2 initialize

Initializes the handler with the API client object and the properties such as
json_key_file_path and impersonated_email, used for generating authorization
requests.

=head3 Parameters

=over

=item *

A required I<api_client> with a reference to the API client object handling the
requests against the API.

=item *

A hash reference with the following keys:

  {
    jsonKeyFilePath   => "json-key-file-path",
    impersonatedEmail => "impersonated-email",
    accessToken       => "access-token",
    additionalScopes  => "additional-scopes",
  }

Refer to the documentation of the properties as L</json_key_file_path>,
L</impersonated_email>, L</access_token> and L</additional_scopes>.

=back

=head2 prepare_request

Refer to L<Google::Ads::GoogleAds::Common::AuthHandlerInterface> documentation
of this method.

=head2 is_auth_enabled

Refer to L<Google::Ads::GoogleAds::Common::AuthHandlerInterface> documentation
of this method.

=head2 _scope

Method defined by L<Google::Ads::GoogleAds::Common::OAuth2BaseHandler> and
implemented in this class to return the required OAuth2 scopes as an array.

=head2 _refresh_access_token

Method defined by L<Google::Ads::GoogleAds::Common::OAuth2BaseHandler> and
implemented in this class to refresh the stored OAuth2 access token.

=head2 __formatted_scopes

Private method to return the OAuth2 scopes as a list of strings separated by
commas. This is the format expected when sending the OAuth request.

=head3 Returns

The string of OAuth2 scopes separated by commas.

=head1 LICENSE AND COPYRIGHT

Copyright 2021 Google LLC

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
