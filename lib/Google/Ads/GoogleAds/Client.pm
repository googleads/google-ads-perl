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

package Google::Ads::GoogleAds::Client;

use strict;
use warnings;
use version;
our $VERSION = qv("1.0.0");

use Google::Ads::GoogleAds::OAuth2ApplicationsHandler;
use Google::Ads::GoogleAds::Logging::GoogleAdsLogger;

use Class::Std::Fast;

use constant OAUTH_2_APPLICATIONS_HANDLER => "OAUTH_2_APPLICATIONS_HANDLER";
use constant AUTH_HANDLERS_ORDER          => (OAUTH_2_APPLICATIONS_HANDLER);

# Class::Std-style attributes. Most values are read from googleads.properties file.
# These need to go in the same line for older Perl interpreters to understand.
my %developer_token_of : ATTR(:name<developer_token> :default<>);
my %login_customer_id_of : ATTR(:name<login_customer_id> :default<>);
my %proxy_of : ATTR(:name<proxy> :default<>);
my %service_address_of : ATTR(:name<service_address> :default<>);
my %version_of : ATTR(:name<version> :default<>);
my %die_on_faults_of : ATTR(:name<die_on_faults> :default<0>);

my %properties_file_of : ATTR(:init_arg<properties_file> :default<>);
my %services_of : ATTR(:name<services> :default<{}>);
my %auth_handlers_of : ATTR(:name<auth_handlers> :default<>);
my %__enabled_auth_handler_of : ATTR(:name<__enabled_auth_handler> :default<>);

# Automatically called by Class::Std after the values for all the attributes
# have been populated but before the constructor returns the new object.
sub START {
  my ($self, $ident) = @_;

  my $default_properties_file =
    Google::Ads::GoogleAds::Constants::DEFAULT_PROPERTIES_FILE;
  if (not $properties_file_of{$ident} and -e $default_properties_file) {
    $properties_file_of{$ident} = $default_properties_file;
  }

  my %properties = ();
  if ($properties_file_of{$ident}) {
    # If there's a valid properties file to read from, parse it and use the
    # config values to fill in any missing attributes.
    %properties = __parse_properties_file($properties_file_of{$ident});
    $developer_token_of{$ident}   ||= $properties{developerToken};
    $login_customer_id_of{$ident} ||= $properties{loginCustomerId};
    $proxy_of{$ident}             ||= $properties{proxy};
  }

  # Provides default values for below attributes if they weren't
  # set by parameters to new().
  $service_address_of{$ident} ||=
    Google::Ads::GoogleAds::Constants::DEFAULT_SERVICE_ADDRESS;
  $version_of{$ident} ||=
    Google::Ads::GoogleAds::Constants::DEFAULT_API_VERSION;

  # Setup of auth handlers.
  my %auth_handlers = ();

  my $auth_handler = Google::Ads::GoogleAds::OAuth2ApplicationsHandler->new();
  $auth_handler->initialize($self, \%properties);
  $auth_handlers{OAUTH_2_APPLICATIONS_HANDLER} = $auth_handler;

  $auth_handlers_of{$ident} = \%auth_handlers;

  # Initialize the logger module with the default log4perl.conf file or the default
  # values if the file is not found.
  # The logger module can only be initialized once, so the log settings in the
  # code before current method call will override the default settings.
  Google::Ads::GoogleAds::Logging::GoogleAdsLogger::initialize_logging();

  # Enable STDOUT output in utf8.
  binmode(STDOUT, ":utf8");
}

# Automatically called by Class::Std when an unknown method is invoked on an
# instance of this class. It is used to handle creating singletons (local to
# each Google::Ads::GoogleAds::Client instance) of all the services. The names
# of the services may change and shouldn't be hardcoded.
sub AUTOMETHOD {
  my ($self, $ident) = @_;
  my $service_name = $_;

  if ($service_name =~ /^\w+Service$/) {
    if ($self->get_services()->{$service_name}) {
      # To emulate a singleton, return the existing instance of the service if
      # we already have it. The return value of AUTOMETHOD must be a sub
      # reference which is then invoked, so wrap the service in sub { }.
      return sub {
        return $self->get_services()->{$service_name};
      };
    } else {
      my $version = $self->get_version();

      # Check to see if there is a module with that name under
      # Google::Ads::GoogleAds::$version if not we warn and return nothing.
      my $module_name =
        "Google::Ads::GoogleAds::${version}::Services::${service_name}";

      eval("require $module_name");    # require module name
      if ($@) {
        warn("Module $module_name was not found.");
        return;
      } else {
        # Pass in this API client, so each service has access to the
        # current properties as developer_token, login_customer_id,
        # die_on_faults and these may change dynamically during runtime.
        my $service = $module_name->new({api_client => $self});
        $self->get_services()->{$service_name} = $service;

        return sub {
          return $self->get_services()->{$service_name};
        };
      }
    }
  }
}

# Protected method to retrieve the proper enabled authorization handler.
sub _get_auth_handler {
  my ($self) = @_;

  # Check if we have cached the enabled auth_handler.
  if ($self->get___enabled_auth_handler()) {
    return $self->get___enabled_auth_handler();
  }

  my $auth_handlers = $self->get_auth_handlers();

  foreach my $handler_id (AUTH_HANDLERS_ORDER) {
    if ($auth_handlers->{$handler_id}->is_auth_enabled()) {
      $self->set___enabled_auth_handler($auth_handlers->{$handler_id});
      last;
    }
  }

  return $self->get___enabled_auth_handler();
}

# Private method to parse values in a properties file.
sub __parse_properties_file {
  my ($properties_file) = @_;
  my %properties;

  # glob() to expand any metacharacters.
  ($properties_file) = glob($properties_file);

  if (open(PROP_FILE, $properties_file)) {
    # The data in the file should be in the following format:
    #   key1=value1
    #   key2=value2
    while (my $line = <PROP_FILE>) {
      chomp($line);

      # Skip comments.
      next if ($line =~ /^#/ || $line =~ /^\s*$/);
      my ($key, $value) = split(/=/, $line, 2);
      $properties{$key} = $value;
    }
    close(PROP_FILE);
  } else {
    die("Couldn't open properties file $properties_file for reading: $!\n");
  }
  return %properties;
}

sub get_oauth_2_handler {
  my ($self) = @_;

  return $self->get_auth_handlers()->{OAUTH_2_APPLICATIONS_HANDLER};
}

sub get_oauth_2_applications_handler {
  my ($self) = @_;

  return $self->get_auth_handlers()->{OAUTH_2_APPLICATIONS_HANDLER};
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::Client

=head1 SYNOPSIS

  use Google::Ads::GoogleAds::Client;

  my $client = Google::Ads::GoogleAds::Client->new({version => "V1"});

  my $customer_id = "1234567890";

  my $query = "SELECT campaign.id, campaign.name FROM campaign";

  my $result = $client->GoogleAdsService()->search({
    customer_id => $customer_id,
    query       => $query,
    pageSize    => PAGE_SIZE
  });

  foreach my $row (@{$result->{results}}) {
    # Do something with the results
  }

=head1 DESCRIPTION

Google::Ads::GoogleAds::Client is the main interface to the Google Ads API. It
takes care of handling your API credentials, and exposes all of the underlying
services that make up the Google Ads API.

The C<Google::Ads::GoogleAds::Client> module should be loaded before other
C<Google::Ads::> modules. A warning will occur if modules are loaded in the
wrong order.

=head1 ATTRIBUTES

Each of these attributes can be set via
Google::Ads::GoogleAds::Client->new().

Alternatively, there is a get_ and set_ method associated with each attribute
for retrieving or setting them dynamically. For example, the set_login_customer_id()
allows you to change the value of the L</login_customer_id> attribute and
get_login_customer_id() returns the current value of the attribute.

=head2 developer_token

A string used to tie usage of the Google Ads API to a specific Google Ads manager
account.

The value should be a character string assigned to you by Google. You can
apply for a Developer Token by following the instructions at
L<https://developers.google.com/google-ads/api/docs/first-call/dev-token>

=head2 login_customer_id

This is the customer ID of the authorized customer to use in the request, without
hyphens. If your access to the customer account is through a manager account,
this attribute is required and must be set to the customer ID of the manager account.

=head2 proxy

The proxy server URL to be used for internet connectivity.

=head2 version

The version of the Google Ads API to use. The latest is the default.

=head2 die_on_faults

By default the client returns a L<Google::Ads::GoogleAds::GoogleAdsException> object
if an error has occurred at the server side. However if this flag is set to true,
the client will issue a die() command on received API faults.

The default is "false".

=head2 properties_file

The path of the configuration file. The default value is F<googleads.properties>
file in the home directory.

=head1 METHODS

=head2 new

Initializes a new Google::Ads::GoogleAds::Client object.

=head3 Parameters

The new() method takes parameters as a hash reference. The attributes of this
object can be populated in a number of ways:

=over

=item *

If the L</properties_file> parameter is given, then properties are read from that
file and the corresponding attributes are populated.

=item *

If no L</properties_file> parameter is given, then the code checks to see if there
is a file named F<googleads.properties> in the home directory of the current user.
If there is, then properties are read from there.

=item *

Any of the L</ATTRIBUTES> can be passed in as keys in the parameters hash reference.
If any attribute is explicitly passed in then it will override the value for that
attribute that might be in the properties file.

=back

=head3 Returns

A new Google::Ads::GoogleAds::Client object with the appropriate attributes set.

=head3 Exceptions

If a L</properties_file> is passed in but the file cannot be read, the code will
die() with an error message describing the failure.

=head3 Example

  # Basic use case. Attributes will be read from ~/googleads.properties file.
  my $client = Google::Ads::GoogleAds::Client->new();

  # Most attributes from a custom properties file, but override login_customer_id.
  eval {
    my $client = Google::Ads::GoogleAds::Client->new({
      properties_file   => "/path/to/googleads.properties",
      login_customer_id => "1234567890"
    });
  };
  if ($@) {
    # The properties file couldn't be read; handle error as appropriate.
  }

  # Specify all attributes explicitly. The properties file will not override.
  my $client = Google::Ads::GoogleAds::Client->new({
    developer_token   => "123xyzabc...",
    login_customer_id => "1234567890"
  });

  $client->get_oauth_2_applications_handler()->set_refresh_token('1/Abc...');

=head2 set_die_on_faults

This module supports two approaches for handling API faults (i.e. errors
returned by the underlying REST API service).

One approach is to issue a die() with a description of the error when a API
fault occurs. This die() would ideally be contained within an eval { }; block,
thereby emulating try { } / catch { } exception functionality in other
languages.

A different approach is to require developers to explicitly check for API
faults being returned after each Google Ads API request. This approach requires
a bit more work, but has the advantage of exposing the full details of the API
fault, like the fault code.

Refer to the object L<Google::Ads::GoogleAds::GoogleAdsException> for more details
on how faults get returned.

The default value is false, i.e. you must explicitly check for faults.

=head3 Parameters

A true value will cause this module to die() when a API fault occurs.

A false value will suppress this die(). This is the default behavior.

=head3 Returns

The input parameter is returned.

=head3 Example

  # $client is a Google::Ads::GoogleAds::Client.

  # Enable die()ing on faults.
  $client->set_die_on_faults(1);
  eval { my $response = $client->AdGroupAdService()->mutate($mutate_request); };
  if ($@) {
    # Do something with the error information in $@.
  }

  # Default behavior.
  $client->set_die_on_faults(0);
  my $response = $client->AdGroupAdService()->mutate($mutate_request);
  if ($response->isa("Google::Ads::GoogleAds::GoogleAdsException")) {
    # Do something with this GoogleAdsException object.
  }

=head2 get_die_on_faults

=head3 Returns

A true or false value indicating whether the L<Google::Ads::GoogleAds::Client>
instance is set to die() on API faults.

=head2 {ServiceName}

The client object contains a method for each service provided by the Google Ads
API. For example it can be invoked as $client->AdGroupService() and it will
return an object of type L<Google::Ads::GoogleAds::V1::Services::AdGroupService>
when using version V1 of the API.

For a list of all the available services please refer to
L<https://developers.google.com/google-ads/api/docs> and for code samples on
how to invoke the services please refer to scripts in the examples folder.

=head2 get_oauth_2_applications_handler

Returns the OAuth2 authorization handler for Web/Installed applications
attached to the client, for programmatically setting/overriding its properties.

  $client->get_oauth_2_applications_handler()->set_client_id('client-id');
  $client->get_oauth_2_applications_handler()->set_client_secret('client-secret');
  $client->get_oauth_2_applications_handler()->set_access_token('access-token');
  $client->get_oauth_2_applications_handler()->set_refresh_token('refresh-token');
  $client->get_oauth_2_applications_handler()->set_access_type('access-type');
  $client->get_oauth_2_applications_handler()->set_prompt('prompt');
  $client->get_oauth_2_applications_handler()->set_redirect_uri('redirect-url');

Refer to L<Google::Ads::GoogleAds::OAuth2ApplicationsHandler> for more details.

=head2 __parse_properties_file (Private)

=head3 Parameters

The path to a properties file on disk. The data in the file should be in the
following format:

 key1=value1
 key2=value2

=head3 Returns

A hash corresponding to the keys and values in the properties file.

=head3 Exceptions

Issues a die() with an error message if the properties file could not be read.

=head2 _auth_handler (Protected)

Retrieves the active auth handler. All handlers are checked in the order.

=head3 Returns

An implementation of L<Google::Ads::GoogleAds::Common::AuthHandlerInterface>.

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
