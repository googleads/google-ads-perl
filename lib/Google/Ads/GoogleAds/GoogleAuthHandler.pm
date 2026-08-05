# Copyright 2026, Google LLC and contributors
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

package Google::Ads::GoogleAds::GoogleAuthHandler;

use strict;
use warnings;
use version;
use base qw(Google::Ads::GoogleAds::Common::AuthHandlerInterface);

use Google::Ads::GoogleAds::Constants;
our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};

use Class::Std::Fast;
use HTTP::Request::Common;

my %api_client_of : ATTR(:name<api_client> :default<>);
my %creds_of : ATTR(:name<creds> :default<>);
my %scopes_of : ATTR(:name<scopes> :default<>);
my %initialized_of : ATTR(:name<initialized> :default<0>);
my %use_application_default_credentials_of : ATTR(:name<use_application_default_credentials> :default<0>);

sub initialize {
  my ($self, $api_client, $properties) = @_;
  my $ident = ident $self;

  $api_client_of{$ident} = $api_client;

  my @scopes = (Google::Ads::GoogleAds::Constants::DEFAULT_OAUTH2_SCOPE);
  if ($properties->{additionalScopes}) {
    push @scopes, split(",", $properties->{additionalScopes});
  }
  $scopes_of{$ident} = \@scopes;

  if (defined $properties->{useApplicationDefaultCredentials}) {
    # Check if the property was provided in the config hash.
    # If not defined in $properties, it safely falls back to whatever the config value
    # was already set to.
    my $raw_val = $properties->{useApplicationDefaultCredentials};
    # Evaluate as true if the string is "true" (case-insensitive) or "1"
    $use_application_default_credentials_of{$ident} = ($raw_val =~ /^(true|1)$/i) ? 1 : 0;
  }
}

sub is_auth_enabled {
  my $self  = shift;
  my $ident = ident $self;

  return 0 if !$api_client_of{$ident};    # Must be initialized first
  return 0 if !$use_application_default_credentials_of{$ident};
  return 1 if $creds_of{$ident};
  return 0 if $initialized_of{$ident};    # Tried and failed

  $initialized_of{$ident} = 1;

  # Soft dependency check
  my $has_google_auth = eval {
    require Google::Auth;
    Google::Auth->VERSION(0.10);
    1;
  };

  if (!$has_google_auth) {
    return 0;
  }

  my $scopes = $scopes_of{$ident} || [];

  require LWP::UserAgent;
  my $ua = LWP::UserAgent->new(timeout => 10);
  
  # Load proxy settings from environment variables (e.g., HTTP_PROXY, NO_PROXY)
  $ua->env_proxy;
  
  # Override with explicit proxy if configured in the API client
  my $proxy = $api_client_of{$ident}->get_proxy();
  $ua->proxy(['http', 'https'], $proxy) if $proxy;

  # Try to load credentials using Google::Auth
  eval { $creds_of{$ident} = Google::Auth->default($scopes, { ua => $ua }); };
  if ($@) {
    # Failed to load, likely no ADC
    return 0;
  }

  return defined $creds_of{$ident};
}

sub prepare_request {
  my ($self, $http_method, $request_url, $http_headers, $request_content) = @_;
  my $ident = ident $self;

  my $creds = $creds_of{$ident};
  if (!$creds) {
    my $api_client = $self->get_api_client();
    my $err_msg = "GoogleAuthHandler is not enabled or credentials not found.";
    $api_client->get_die_on_faults() ? die($err_msg) : warn($err_msg);
    return;
  }

  # Google::Auth credentials should auto-refresh when access_token is called
  # or provide a fresh token.
  my $access_token = eval { $creds->access_token() };
  if ($@) {
    my $api_client = $self->get_api_client();
    my $err_msg = "Exception while getting access token from Google::Auth: $@";
    $api_client->get_die_on_faults() ? die($err_msg) : warn($err_msg);
    return;
  }

  if (!$access_token) {
    my $api_client = $self->get_api_client();
    my $err_msg    = "Failed to obtain access token from Google::Auth.";
    $api_client->get_die_on_faults() ? die($err_msg) : warn($err_msg);
    return;
  }

  push @$http_headers, ("Authorization", "Bearer ${access_token}");

  return HTTP::Request->new($http_method, $request_url, $http_headers,
    $request_content);
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::GoogleAuthHandler

=head1 DESCRIPTION

Authorization handler that uses L<Google::Auth> to obtain credentials,
supporting Application Default Credentials (ADC) and hardened environment integration.

=head1 METHODS

=head2 initialize

Initializes the handler and attempts to load default credentials.

=head2 is_auth_enabled

Returns true if credentials were successfully loaded.

=head2 prepare_request

Prepares the L<HTTP::Request> by adding the Authorization header with the Bearer token.

=cut
