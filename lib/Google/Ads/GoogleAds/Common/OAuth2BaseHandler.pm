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

package Google::Ads::GoogleAds::Common::OAuth2BaseHandler;

use strict;
use warnings;
use version;
use base qw(Google::Ads::GoogleAds::Common::AuthHandlerInterface);

# The following needs to be on one line because CPAN uses a particularly hacky
# eval() to determine module versions.
use Google::Ads::GoogleAds::Constants; our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};

use Class::Std::Fast;
use HTTP::Request::Common;
use LWP::UserAgent;
use URI::Escape;

use constant OAUTH2_TOKEN_INFO_URL =>
  "https://www.googleapis.com/oauth2/v2/tokeninfo";

# Class::Std-style attributes. Need to be kept in the same line.
# These need to go in the same line for older Perl interpreters to understand.
my %api_client_of : ATTR(:name<api_client> :default<>);
my %client_id_of : ATTR(:name<client_id> :default<>);
my %access_token_of : ATTR(:init_arg<access_token> :default<>);
my %access_token_expires_of : ATTR(:name<access_token_expires> :default<>);
my %__lwp_agent_of : ATTR(:name<__lwp_agent> :default<>);

# Constructor.
sub START {
  my ($self, $ident) = @_;

  $__lwp_agent_of{$ident} ||= LWP::UserAgent->new();
}

# Methods from Google::Ads::GoogleAds::Common::AuthHandlerInterface.
sub initialize : CUMULATIVE(BASE FIRST) {
  my ($self, $api_client, $properties) = @_;
  my $ident = ident $self;

  $api_client_of{$ident} = $api_client;
  $client_id_of{$ident}  = $properties->{clientId}
    || $client_id_of{$ident};
  $access_token_of{$ident} = $properties->{accessToken}
    || $access_token_of{$ident};

  # Set up proxy for __lwp_agent.
  my $proxy = $api_client->get_proxy();
  $proxy
    ? $__lwp_agent_of{$ident}->proxy(['http', 'https'], $proxy)
    : $__lwp_agent_of{$ident}->env_proxy;
}

sub prepare_request {
  my ($self, $http_method, $request_url, $http_headers, $request_content) = @_;

  my $access_token = $self->get_access_token();

  if (!$access_token) {
    my $api_client = $self->get_api_client();
    my $err_msg =
      "Unable to prepare a request, authorization info is " .
      "incomplete or invalid.";
    $api_client->get_die_on_faults() ? die($err_msg) : warn($err_msg);
    return;
  }

  push @$http_headers, ("Authorization", "Bearer ${access_token}");

  return HTTP::Request->new($http_method, $request_url, $http_headers,
    $request_content);
}

sub is_auth_enabled {
  my ($self) = @_;

  return $self->get_access_token();
}

# Custom getter and setter for the access_token with logic to auto-refresh.
sub get_access_token {
  my $self  = shift;
  my $ident = ident $self;

  if (!$self->_is_access_token_valid()) {
    if (!$self->_refresh_access_token()) {
      return undef;
    }

    return $access_token_of{$ident};
  }

  return $access_token_of{$ident};
}

sub set_access_token {
  my ($self, $token) = @_;

  $access_token_of{ident $self}         = $token;
  $access_token_expires_of{ident $self} = undef;
}

# Internal methods.

# Checks if:
#   - the access token is set
#   - if the token has no expiration set then assumes it was manually set and:
#       - checks the token info, if it is valid then sets its expiration
#       - checks the token scopes
#   - checks the token has not expired
sub _is_access_token_valid {
  my $self  = shift;
  my $ident = ident $self;

  my $access_token = $access_token_of{$ident};
  if (!$access_token) {
    return 0;
  }

  if (!$self->get_access_token_expires()) {
    my $url =
      OAUTH2_TOKEN_INFO_URL . "?access_token=" . uri_escape($access_token);
    my $response = $self->get___lwp_agent()->request(GET $url);
    if (!$response->is_success()) {
      my $err_msg = $response->decoded_content();
      $self->get_api_client()->get_die_on_faults()
        ? die($err_msg)
        : warn($err_msg);
      return 0;
    }
    my $content_hash =
      $self->__parse_auth_response($response->decoded_content());
    my %token_scopes = map { $_ => 1 } split(" ", $content_hash->{scope});

    foreach my $required_scope ($self->_scope()) {
      if (!exists($token_scopes{$required_scope})) {
        return 0;
      }
    }
    $self->set_access_token_expires(time + $content_hash->{expires_in});
  }

  return time < ($self->get_access_token_expires() - 10);
}

sub __parse_auth_response {
  my ($self, $response_content) = @_;

  my %content_hash = ();

  # Use below regex to parse the token info response into hash.
  # The sample token info response is as below:
  # {
  #   "issued_to": "1234567890-abcdefg.apps.googleusercontent.com",
  #   "audience": "1234567890-abcdefg.apps.googleusercontent.com",
  #   "scope": "https://www.googleapis.com/auth/adwords",
  #   "expires_in": 3548
  # }
  while (
    $response_content =~ m/([^"]+)"\s*:\s*"([^"]+)|([^"]+)"\s*:\s*([0-9]+)/g)
  {
    if ($1 && $2) {
      $content_hash{$1} = $2;
    } else {
      $content_hash{$3} = $4;
    }
  }

  return \%content_hash;
}

# Meant to be implemented by a concrete class, which should return the required
# API scopes in an array for the OAuth2 protocol.
sub _scope {
  my $self = shift;
  die "Need to be implemented by subclass";
}

# Method called to refresh the stored OAuth2 access token. Implementors will issue
# an access token refresh request to the OAuth2 server.
sub _refresh_access_token {
  die "Need to be implemented by subclass";
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::Common::OAuth2BaseHandler

=head1 DESCRIPTION

An abstract base implementation that defines part of the logic required to use
OAuth2 against Google APIs.

It is meant to be specialized and its L</_scope>, L</_refresh_access_token>
methods should be properly implemented.

=head1 ATTRIBUTES

Each of these attributes can be set via
Google::Ads::GoogleAds::Common::OAuth2BaseHandler->new().

Alternatively, there is a get_ and set_ method associated with each attribute
for retrieving or setting them dynamically.

  my %api_client_of : ATTR(:name<api_client> :default<>);
  my %client_id_of : ATTR(:name<client_id> :default<>);
  my %access_token_of : ATTR(:init_arg<access_token> :default<>);
  my %access_token_expires_of : ATTR(:name<access_token_expires> :default<>);

=head2 api_client

A reference to the API client used to handle the API requests.

=head2 client_id

OAuth2 client id obtained from the Google APIs Console.

=head2 access_token

Stores an OAuth2 access token after the authorization flow is followed or for
you to manually set it in case you had it previously stored.
If this is manually set this handler will verify its validity before preparing
a request.

=head1 METHODS

=head2 initialize

Initializes the handler with the API client object and the properties such as
client_id and access_token.

=head3 Parameters

=over

=item *

A required I<api_client> with a reference to the API client object handling the
requests against the API.

=item *

A hash reference with the following keys.

  {
    clientId    => "client-id",
    accessToken => "access-token"
  }

Refer to the documentation of the L</client_id> and L</access_token> properties.

=back

=head2 prepare_request

Refer to L<Google::Ads::GoogleAds::Common::AuthHandlerInterface> documentation
of this method.

=head2 is_auth_enabled

Refer to L<Google::Ads::GoogleAds::Common::AuthHandlerInterface> documentation
of this method.

=head2 _scope

Meant to be implemented by a concrete class, which should return the required
API scopes in an array for the OAuth2 protocol.

=head2 _refresh_access_token

Method called to refresh the stored OAuth2 access token. Implementors will issue
an access token refresh request to the OAuth2 server.

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
