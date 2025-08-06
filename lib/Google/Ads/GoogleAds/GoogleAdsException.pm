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
# The class represents the exception message from Google Ads API server.

package Google::Ads::GoogleAds::GoogleAdsException;

use strict;
use warnings;
use version;

# The following needs to be on one line because CPAN uses a particularly hacky
# eval() to determine module versions.
use Google::Ads::GoogleAds::Constants; our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};

use Class::Std::Fast constructor => 'none';

# Class::Std-style attributes. Most values are read from googleads.properties file.
# These need to go in the same line for older Perl interpreters to understand.
my %code_of : ATTR(:get<code> :default<>);
my %message_of : ATTR(:get<message> :default<>);
my %status_of : ATTR(:get<status> :default<>);
my %details_of : ATTR(:get<details> :default<>);

sub new {
  my $self  = bless \do { my $exception = Class::Std::Fast::ID }, shift;
  my $ident = ident $self;

  my $response_body = shift;
  my $error         = $response_body->{error};

  $code_of{$ident}    = $error->{code};
  $message_of{$ident} = $error->{message};
  $status_of{$ident}  = $error->{status};

  # The details may contain GoogleAdsFailure or standard GRPC errors, e.g.
  # BadRequest, PreconditionFailure, QuotaFailure.
  $details_of{$ident} = $error->{details};

  return $self;
}

# Extracts the GoogleAdsFailure object from the details hash.
sub get_google_ads_failure {
  my $self = shift;

  foreach my $detail (@{$self->get_details}) {
    my $type = $detail->{"\@type"};
    if ($type =~ /google.ads.googleads.v(\d+).errors.GoogleAdsFailure/) {
      my $class =
        sprintf(
        Google::Ads::GoogleAds::Constants::GOOGLE_ADS_FAILURE_CLASS_NAME,
        $1);

      # Require class name.
      eval("require $class");
      return $class->new({errors => $detail->{errors}});
    }
  }
  return undef;
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::GoogleAdsException

=head1 SYNOPSIS

  my $api_client = Google::Ads::GoogleAds::Client->new();
  $api_client->set_die_on_faults(0);

  my $response = $api_client->AdGroupAdService()->mutate($mutate_request);

  if ($response->isa("Google::Ads::GoogleAds::GoogleAdsException")) {
    my $google_ads_failure = $response->get_google_ads_failure();

    # Do something with the GoogleAdsFailure object.
  }

=head1 DESCRIPTION

The class represents the exception message from Google Ads API server.

=head1 ATTRIBUTES

There is a get_ method associated with each attribute for retrieving them dynamically.

=head2 code

The HTTP response code.

=head2 message

A human-readable description of this exception.

=head2 status

The status code of this exception.

=head2 details

The detailed information of this exception, which may contain failure messages.

=head1 METHODS

=head2 get_google_ads_failure

Extracts a L<Google::Ads::GoogleAds::V21::Errors::GoogleAdsFailure> object from the
L</details> attribute of the current exception object.

=head3 Returns

A L<Google::Ads::GoogleAds::V21::Errors::GoogleAdsFailure> object or undef if not found.

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
