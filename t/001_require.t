#!/usr/bin/perl -w
#
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
# Unit test to ensure that all modules in "../lib" compile properly.

use strict;
use warnings;

use File::Basename;
use File::Find;
use File::Spec;
use Test::More qw(no_plan);

# Pushes "../lib" into @INC at runtime with an absolute path.
my $lib_path = File::Spec->catdir(dirname($0), "..", "lib");
push(@INC, $lib_path);

require_ok "Google::Ads::GoogleAds::Client";

find(\&test_require, $lib_path);

sub test_require {
  my $file_name = $File::Find::name;
  return if $file_name =~ m{Google/Ads/GoogleAds/Client\.pm$};

  if ($file_name =~ /\.pm$/) {
    local $SIG{__WARN__} = sub {
      warn @_ unless $_[0] =~ /redefine/;
    };

    # Require the modules in relative path.
    require_ok(File::Spec->abs2rel($file_name, $lib_path));
  }
}
