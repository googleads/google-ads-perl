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
# This module contains utility methods for handling partial failure of operations.

package Google::Ads::GoogleAds::Utils::PartialFailureUtils;

use strict;
use warnings;
use version;

# The following needs to be on one line because CPAN uses a particularly hacky
# eval() to determine module versions.
use Google::Ads::GoogleAds::Constants; our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};

use Exporter 'import';
our @EXPORT =
  qw(is_partial_failure_result get_google_ads_errors get_google_ads_failure);

# Checks if a result in a mutate response is a partial failure.
sub is_partial_failure_result {
  my $result = shift;
  return !keys %$result;
}

# Returns a list of GoogleAdsError instances for a given operation index.
sub get_google_ads_errors {
  my ($operation_index, $partial_failure_error) = @_;

  my $google_ads_errors = [];

  foreach my $detail (@{$partial_failure_error->{details}}) {
    my $google_ads_failure = get_google_ads_failure($detail);
    next if not $google_ads_failure;

    push @$google_ads_errors,
      @{__get_google_ads_errors($operation_index, $google_ads_failure)};
  }

  return $google_ads_errors;
}

# Extracts the GoogleAdsFailure instance from a partial failure detail.
sub get_google_ads_failure {
  my ($detail) = @_;

  my $type = $detail->{"\@type"};
  if ($type =~ /google.ads.googleads.v(\d+).errors.GoogleAdsFailure/) {
    my $class =
      sprintf(Google::Ads::GoogleAds::Constants::GOOGLE_ADS_FAILURE_CLASS_NAME,
      $1);

    # Require class name.
    eval("require $class");
    return $class->new({errors => $detail->{errors}});
  }

  return undef;
}

# The private method to extract a list of GoogleAdsError instances from a
# GoogleAdsFailure instance for a given operation index.
sub __get_google_ads_errors {
  my ($operation_index, $google_ads_failure) = @_;

  my $google_ads_errors = [];

  if ((ref $google_ads_failure) =~ /::V(\d+)::/) {
    my $class =
      sprintf(Google::Ads::GoogleAds::Constants::GOOGLE_ADS_ERROR_CLASS_NAME,
      $1);

    foreach my $error (@{$google_ads_failure->{errors}}) {
      foreach my $field_path_element (@{$error->{location}{fieldPathElements}})
      {
        my $field_name = $field_path_element->{fieldName};
        my $index      = $field_path_element->{index};

        if ($field_name eq "operations" and $index == $operation_index) {
          # Bless to class name.
          bless $error, $class;
          push @$google_ads_errors, $error;
          last;
        }
      }
    }
  }

  return $google_ads_errors;
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::Utils::PartialFailureUtils

=head1 SYNOPSIS

  use Google::Ads::GoogleAds::Utils::PartialFailureUtils;

  while (my ($operation_index, $result) = each @{$response->{results}}) {
    if (is_partial_failure_result($result)) {
      my $google_ads_errors = get_google_ads_errors($operation_index,
        $response->{partialFailureError});

      foreach my $google_ads_error (@$google_ads_errors) {
        printf "Operation %d failed with error: %s.\n", $operation_index,
          $google_ads_error->{message};
      }
    } else {
      printf "Operation %d succeeded.\n", $operation_index;
    }
  }

=head1 DESCRIPTION

This module contains utility methods for handling partial failure of operations.

=head1 METHODS

=head2 is_partial_failure_result

Checks if a result in a mutate response is a partial failure.

=head3 Parameters

=over

=item *

I<result>: a B<result> hash in a mutate response.

=back

=head3 Returns

True, if the result is a partial failure. False, otherwise.

=head2 get_google_ads_errors

Returns a list of L<Google::Ads::GoogleAds::V21::Errors::GoogleAdsError> instances
for a given operation index.

=head3 Parameters

=over

=item *

I<operation_index>: the index of the operation, starting from 0.

=item *

I<partial_failure_error>: the B<partialFailureError> hash in the mutate response,
with the detail list containing L<Google::Ads::GoogleAds::V21::Errors::GoogleAdsFailure>
instances.

=back

=head3 Returns

An array containing the L<Google::Ads::GoogleAds::V21::Errors::GoogleAdsError>
instances for the given operation index.

=head2 get_google_ads_failure

Extracts the L<Google::Ads::GoogleAds::V21::Errors::GoogleAdsFailure> instance
from a partial failure detail.

=head3 Parameters

=over

=item *

I<detail>: an element in the B<details> hash in the mutate response.

=back

=head3 Returns

A L<Google::Ads::GoogleAds::V21::Errors::GoogleAdsFailure> object or undef if not found.

=head2 __get_google_ads_errors

The private method to extract a list of L<Google::Ads::GoogleAds::V21::Errors::GoogleAdsError>
instances from a L<Google::Ads::GoogleAds::V21::Errors::GoogleAdsFailure> instance
for a given operation index.

=head3 Parameters

=over

=item *

I<operation_index>: the index of the operation, starting from 0.

=item *

I<google_ads_failure>: the L<Google::Ads::GoogleAds::V21::Errors::GoogleAdsFailure> instance.

=back

=head3 Returns

An array containing the L<Google::Ads::GoogleAds::V21::Errors::GoogleAdsError>
instances from the L<Google::Ads::GoogleAds::V21::Errors::GoogleAdsFailure>
instance for the given operation index.

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
