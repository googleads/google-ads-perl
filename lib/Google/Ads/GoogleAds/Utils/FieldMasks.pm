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
# Utility for constructing field masks, which are necessary for update
# operations.

package Google::Ads::GoogleAds::Utils::FieldMasks;

use strict;
use warnings;
use version;

# The following needs to be on one line because CPAN uses a particularly hacky
# eval() to determine module versions.
use Google::Ads::GoogleAds::Constants; our $VERSION = ${Google::Ads::GoogleAds::Constants::VERSION};
use Google::Ads::GoogleAds::Common::FieldMask;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;

use Exporter 'import';
our @EXPORT = qw(field_mask all_set_fields_of get_field_value);

use Data::Compare;

# Compares two hash objects and computes a FieldMask object based on the differences
# between them. The field mask is necessary for update operations, and the field
# paths in the field mask are in lower underscore format.
sub field_mask {
  my ($original, $modified) = @_;
  my $paths = [];
  __compare($paths, "", $original, $modified);

  return Google::Ads::GoogleAds::Common::FieldMask->new({paths => $paths});
}

# Constructs a FieldMask object that captures the list of all set fields of an object.
# The field paths in the field mask are in lower underscore format.
sub all_set_fields_of {
  my ($modified) = @_;
  return field_mask({}, $modified);
}

# Looks up the value of the field located at the given path on an object.
sub get_field_value {
  my ($object, $path) = @_;

  my $value = $object;
  $value = $value->{$_} for split(/\./, $path);

  return $value;
}

# The private method to compare a given field for two objects, and capture the
# differences between them recursively.
sub __compare {
  my ($paths, $current_field, $original, $modified) = @_;

  # Combine fields from original and modified resource, since the original might
  # have nested fields which are cleared in the modified resource.
  my %key_hash = ();
  foreach my $key (keys %$original) { $key_hash{$key} = 1; }
  foreach my $key (keys %$modified) { $key_hash{$key} = 1; }

  foreach my $key (keys %key_hash) {
    # The field mask should contain the field path in underscore format.
    my $field      = to_lower_underscore($key);
    my $field_path = $current_field ? $current_field . "." . $field : $field;

    # Extract values from original and modified objects.
    my $modified_value      = $modified->{$key};
    my $original_value      = $original->{$key};
    my $original_key_exists = exists $original->{$key};

    if (ref($original_value) eq "ARRAY" || ref($modified_value) eq "ARRAY") {
      # Array reference field.
      push @$paths, $field_path
        unless Compare($original_value, $modified_value);
    } elsif (__is_hash_ref($original_value) || __is_hash_ref($modified_value)) {
      # Hash or class reference field whose ref name is not empty.
      next if Compare($original_value, $modified_value);
      if (!$original_key_exists) {
        # If the modified value is an empty object that doesn't exist in the original
        # then add it to the paths list. Otherwise recurse on the modified value object.
        if (!%$modified_value) { push @$paths, $field_path; }
        else {
          __compare($paths, $field_path, {}, $modified_value);
        }
      } elsif (__is_clearing_message($original_value, $modified_value)) {
        push @$paths, $field_path;
      } else {
        if (!defined $modified_value) {
          __compare($paths, $field_path, $original_value, {});
        } else {
          __compare($paths, $field_path, $original_value, $modified_value);
        }
      }
    } else {
      # Scalar field or both $modified_value and $original_value are undef.
      if (!$original_key_exists && !defined $modified_value) {
        push @$paths, $field_path;
        next;
      }

      push @$paths, $field_path
        unless Compare($original_value, $modified_value);
    }
  }
}

# The private method to check if a reference object is for a hash or a class instance.
sub __is_hash_ref {
  my $ref_type = ref shift;
  return 0 if !$ref_type;

  # A boolean value reference in a JSON object is evaluated as "JSON::PP::Boolean".
  my @invalid_types = ("SCALAR", "ARRAY", "JSON::PP::Boolean");
  return 0 if grep /^$ref_type/, @invalid_types;

  return 1;
}

sub __is_clearing_message {
  my ($original_value, $modified_value) = @_;

  my $original_is_defined = defined $original_value;
  my $modified_is_defined = defined $modified_value;

  my $original_values_size = values %$original_value;
  my $modified_values_size = values %$modified_value;

  # Returns true if the original message contains an empty message field that is not present on the
  # modified message, or vice-versa, in which case the user is attempting to clear the top level
  # message field.
  return 1
    if ((
         !$modified_is_defined
      and $original_is_defined
      and $original_values_size == 0
    )
    or ( !$original_is_defined
      and $modified_is_defined
      and $modified_values_size == 0));

  return 0;
}

1;

=pod

=head1 NAME

Google::Ads::GoogleAds::Utils::FieldMasks

=head1 DESCRIPTION

Utility for constructing field masks, which are necessary for update operations.

=head1 METHODS

=head2 field_mask

Compares two hash objects and computes a L<Google::Ads::GoogleAds::Common::FieldMask>
object based on the differences between them. The field mask is necessary for
update operations, and the field paths in the field mask are in lower underscore format.

=head3 Parameters

=over

=item *

I<original>: the original hash object.

=item *

I<modified>: the modified hash object.

=back

=head3 Returns

A L<Google::Ads::GoogleAds::Common::FieldMask> object reflecting the changes
between the original and modified objects.

=head2 all_set_fields_of

Constructs a L<Google::Ads::GoogleAds::Common::FieldMask> object that captures
the list of all set fields of an object. The field paths in the field mask are
in lower underscore format.

=head3 Parameters

=over

=item *

I<modified>: the modified hash object.

=back

=head3 Returns

A L<Google::Ads::GoogleAds::Common::FieldMask> object that captures the list of
all set fields of an object.

=head2 get_field_value

Looks up the value of the field located at the given path on an object.

=head3 Parameters

=over

=item *

I<object>: the object to search on.

=item *

I<path>: the path of the field.

=back

=head3 Returns

The value of the field located at the give path on the object.

=head2 __compare

The private method to compare a given field for two objects, and capture the
differences between them recursively.

=head3 Parameters

=over

=item *

I<paths>: the paths array to store the differences.

=item *

I<current_field>: the field name to compare.

=item *

I<original>: the original hash object.

=item *

I<modified>: the modified hash object.

=back

=head2 __is_hash_ref

The private method to check if a reference object is for a hash or a class instance.

=head3 Parameters

=over

=item *

I<ref>: the reference object to check.

=back

=head3 Returns

True, if the reference object is for a hash or a class instance. False, otherwise.

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
