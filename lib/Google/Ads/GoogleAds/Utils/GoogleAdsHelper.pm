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
# This module provides utility methods to other services.

package Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

use strict;
use warnings;
use version;

# The following needs to be on one line because CPAN uses a particularly hacky
# eval() to determine module versions.
use Google::Ads::GoogleAds::Constants; our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};

use Exporter::Auto;
use Storable qw(dclone);

# Deletes the unassigned fields in the hash reference.
sub remove_unassigned_fields {
  my ($hash_ref, $args) = @_;
  delete @{$hash_ref}{grep { not exists $args->{$_} } keys %$hash_ref};
}

# Checks whether the scripts parameters are not the "INSERT_..._HERE" values.
sub check_params {
  my (@params) = @_;
  foreach my $param (@params) {
    if (ref $param eq "ARRAY") {
      return 0 if !(@$param && check_params(@$param));
    } elsif (!defined $param || $param =~ /INSERT_.*_HERE/) {
      return 0;
    }
  }
  return 1;
}

# Removes the leading and trailing spaces and line breaks from a string.
sub trim {
  my $str = shift;
  return $str if !defined $str;
  $str =~ s/^\s*(.*?)\s*$/$1/;
  return $str;
}

# Expands a path template by replacing the parameters in braces with the given
# arguments.
sub expand_path_template {
  my ($path_template, $args) = @_;

  # To support the {+customers} format template.
  $path_template =~ s/\{\+/\{/g;

  if (not ref $args) {
    $path_template =~ s/\{\w+}/$args/ if defined $args;
  } elsif (ref $args eq "ARRAY") {
    $path_template =~ s/\{\w+}/shift @$args if @$args/eg;
  } else {
    $path_template =~ s/\{(\w+)}/delete $args->{$1} if exists $args->{$1}/eg;
  }

  return $path_template;
}

# Copies a hash reference to a new object.
sub copy_from {
  my ($original) = shift;
  return undef if !$original;
  return dclone($original);
}

# Converts a string to lower underscore case.
sub to_lower_underscore {
  my $str = shift;
  return $str if !defined $str;
  $str =~
    s/(?:\b|(?<=([a-z])))([A-Z][a-z]+)/(defined($1) ? "_" : "") . lc($2)/eg;
  return $str;
}

# Converts a scalar to boolean string.
sub to_boolean {
  shift ? "true" : "false";
}

# Dies with a specified exit code.
sub die_with_code {
  my $exit_code = shift;
  $! = $exit_code;

  die @_;
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::Utils::GoogleAdsHelper

=head1 DESCRIPTION

This module provides utility methods to other services.

=head1 METHODS

=head2 remove_unassigned_fields

Removes the fields not presenting in the constructor arguments from a newly created
Google Ads API entity. These fields will be excluded when encoding the JSON HTTP
request payload.

=head3 Parameters

=over

=item *

I<hash_ref>: a hash reference to the newly created Google Ads API entity.

=item *

I<args>: the arguments for the constructor of a Google Ads API entity.

=back

=head2 check_params

Checks whether the parameters in the code sample are correctly specified. The
values can either be set in the source code or passed in from the command line.

=head3 Parameters

=over

=item *

I<params>: an array of parameters in the code sample to verify.

=back

=head3 Returns

True, if all the parameters are correctly specified. False, otherwise.

=head2 trim

Removes the leading and trailing spaces and line breaks from a string.

=head3 Parameters

=over

=item *

The original input string.

=back

=head3 Returns

The trimmed string without leading and trailing white spaces.

=head2 expand_path_template

Expands a path template by replacing the parameters in braces with the given
arguments.

=head3 Parameters

=over

=item *

I<path_template>: the path template to expand. The format could be:
'customers/{customer_id}/adGroups/{ad_group_id}' or
'v21/customers/{+customerId}/adGroups:mutate'.

=item *

I<args>: the args in scalar or array/hash reference used to expand the template.

=back

=head3 Returns

The expanded path template.

=head2 copy_from

Copies a hash reference deeply to a new object.

=head3 Parameters

=over

=item *

I<original>: the original hash reference to copy from.

=back

=head3 Returns

A deeply copied object based on the C<original> hash reference.

=head2 to_lower_underscore

Converts a string to lower underscore case.

=head3 Parameters

=over

=item *

The original input string.

=back

=head3 Returns

The result string in lower underscore case.

=head2 to_boolean

Converts a scalar to boolean string.

=head3 Parameters

=over

=item *

The original input scalar value.

=back

=head3 Returns

"true" if the input value is valid. "false", otherwise.

=head2 die_with_code

Dies with a specified exit code.

=head3 Parameters

=over

=item *

I<exit_code>: the exit code.

=item *

I<list>: list of one or more items, which will be stringified and concatenated
to make the exception.

=back

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
