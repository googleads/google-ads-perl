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
# Mobulde::Build build file. See
# http://search.cpan.org/~ewilhelm/Module-Build-0.32/lib/Module/Build.pm
# for explanation of format.

use Module::Build;

use strict;
use warnings;

use lib "lib";

my $build_sc = Module::Build->subclass(
  code => q(
      sub ACTION_testsmall {shift->generic_test(type => "small");}
      sub ACTION_testmedium {shift->generic_test(type => "medium");}
      sub ACTION_testnondeterministic {
        shift->generic_test(type => "nondeterministic");
      }
      sub ACTION_testfunctional {shift->generic_test(type => "functional");}
      sub ACTION_testsmoke {shift->generic_test(type => "smoke");}
    )
);

$build_sc->new(
  module_name        => "Google::Ads::GoogleAds::Client",
  license            => "apache",
  dist_author        => "Laura Chevalier",
  create_makefile_pl => "traditional",
  dist_abstract      => "Google Ads API Client Library for Perl",
  dist_name          => "Google-Ads-GoogleAds-Client",
  dist_version       => "30.0.0",
  no_index           => {
    namespace => [
      "Google::Ads::GoogleAds::V20::Enums",
      "Google::Ads::GoogleAds::V20::Common",
      "Google::Ads::GoogleAds::V20::Resources",
      "Google::Ads::GoogleAds::V20::Services",
      "Google::Ads::GoogleAds::V21::Enums",
      "Google::Ads::GoogleAds::V21::Common",
      "Google::Ads::GoogleAds::V21::Resources",
      "Google::Ads::GoogleAds::V21::Services",
      "Google::Ads::GoogleAds::V22::Enums",
      "Google::Ads::GoogleAds::V22::Common",
      "Google::Ads::GoogleAds::V22::Resources",
      "Google::Ads::GoogleAds::V22::Services",
      "Google::Ads::GoogleAds::V23::Enums",
      "Google::Ads::GoogleAds::V23::Common",
      "Google::Ads::GoogleAds::V23::Resources",
      "Google::Ads::GoogleAds::V23::Services",
    ],
  },
  requires           => {
    "Class::Load"                  => 0,
    "Class::Std::Fast"             => 0,
    "Const::Exporter"              => 0,
    "Crypt::OpenSSL::RSA"          => 0,
    "Cwd"                          => 0,
    "Storable"                     => 0,
    "Data::Uniqid"                 => 0,
    "Data::Compare"                => 0,
    "Date::Parse"                  => 0,
    "Date::Format"                 => 0,
    "Digest::SHA"                  => 0,
    "Exporter::Auto"               => 0,
    "File::Basename"               => 0,
    "File::HomeDir"                => 0,
    "File::Path"                   => 0,
    "File::Spec"                   => 0,
    "File::Temp"                   => 0,
    "FindBin"                      => 0,
    "Getopt::Long"                 => 0,
    "HTTP::Server::Simple::CGI"    => 0,
    "IO::Socket::SSL"              => 0,
    "JSON::Parse"                  => 0,
    "JSON::SL"                     => 0,
    "JSON::XS"                     => 0,
    "JSON::WebToken"               => 0,
    "List::Util"                   => 0,
    "Log::Log4perl"                => 0,
    "LWP::Protocol::https"         => 0,
    "LWP::UserAgent"               => 0,
    "LWP::UserAgent::Determined"   => 0,
    "MIME::Base64"                 => 0,
    "POSIX"                        => 0,
    "Template"                     => 0,
    "Time::HiRes"                  => 0,
    "URI::Escape"                  => 0,
    "URI::Query"                   => 0,
    "perl"                         => "5.28.1",
  },
  build_requires => {
    "Class::Std::Fast"          => 0,
    "Config::Properties"        => 0,
    "Module::Build"             => 0,
    "Test::Deep"                => 0,
    "Test::Exception"           => 0,
    "Test::MockObject"          => 0,
    "Test::MockObject::Extends" => 0,
    "Test::More"                => 0,
  },
  test_types => {
    small => [
      "011_Client.t",                    "012_GoogleAdsException.t",
      "013_OAuth2ApplicationsHandler.t", "014_GoogleAdsHelper.t",
      "015_SearchGoogleAdsIterator.t",   "016_FieldMasks.t",
      "017_PartialFailureUtils.t",       "018_MediaUtils.t",
      "019_GoogleAdsLogger.t",           "020_ResourcesNames.t",
      "021_OperationService.t",          "022_SearchStreamHandler.t",
      "023_OAuth2ServiceAccountsHandler.t"
    ],
    medium           => ["001_require.t"],
    smoke            => [".t"],
  },
  meta_merge => {
    resources => {
      repository => 'https://github.com/googleads/google-ads-perl',
      bugtracker => 'https://github.com/googleads/google-ads-perl/issues'
    }})->create_build_script();
