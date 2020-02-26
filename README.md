# Google Ads API Client Library for Perl

[![CPAN version](https://badge.fury.io/pl/Google-Ads-GoogleAds-Client.svg)](https://badge.fury.io/pl/Google-Ads-GoogleAds-Client)

This project hosts the Perl client library for the [Google Ads
API](https://developers.google.com/google-ads/api/docs/start).

## Features

  * Distributed via [CPAN](https://metacpan.org/release/Google-Ads-GoogleAds-Client).
  * Easy management of credentials.
  * Easy creation of Google Ads API service clients.

## Requirements

  * Perl 5.24.1+

## Getting started

1.  Clone this project in the directory of your choice via:

        git clone https://github.com/googleads/google-ads-perl.git

1.  Change into the `google-ads-perl` directory.

        cd google-ads-perl

    You'll see some files and subdirectories:

    *   `Build.PL`: the Perl build file, which holds the dependencies and test
        types of this project.
    *   `lib`: source code of the library.
    *   `t`: test cases of the library code.
    *   `examples`: many examples that demonstrate how to use the library to
        execute common use cases via the Google Ads API.
    *   `googleads.properties`: the sample configuration file for the library.
    *   `log4perl.conf`: the sample logging configuration file.

1.  Now run the following command at the command prompt. This will install all
    dependencies needed for using the library and running examples.

        cpan install Module::Build
        perl Build.PL
        perl Build installdeps

1.  Set up your OAuth2 credentials.

    The Google Ads API uses [OAuth2](http://oauth.net/2/) as the authentication
    mechanism. Choose the appropriate option below based on your use case, and
    read and follow the instructions that the example prints to the console.

    **If you already have credentials for the AdWords API...**

    *   If you have the `adwords.properties` file you used for the AdWords API,
        copy and name it as `googleads.properties`. Simply change the key names
        in the new configuration file as below:

            oAuth2ClientId       --> clientId
            oAuth2ClientSecret   --> clientSecret
            oAuth2RefreshToken   --> refreshToken
            developerToken       --> developerToken

        If you are authenticating as a manager account, additionally you must
        specify:

            loginCustomerId --> Manager account ID (with hyphens removed).

    **If you're accessing the Google Ads API using your own credentials...**

    *   Copy the sample [`googleads.properties`](googleads.properties)
        to your [home directory](https://en.wikipedia.org/wiki/Home_directory#Default_home_directory_per_operating_system).

    *   Follow the instructions at
        https://developers.google.com/google-ads/api/docs/oauth/cloud-project
        to create an OAuth2 client ID and secret for the **installed application**
        OAuth2 flow.

    *   Run the
        [authenticate_in_standalone_application](examples/authentication/authenticate_in_standalone_application.pl)
        example, by providing your OAuth2 client ID and secret as the parameters.

    *   Copy the output from the last step of the example into the
        `googleads.properties` file in your home directory. Don't forget to fill
        in your developer token too.

    **If you're accessing the Google Ads API on behalf of clients...**

    *   Copy the sample [`googleads.properties`](googleads.properties)
        to your [home directory](https://en.wikipedia.org/wiki/Home_directory#Default_home_directory_per_operating_system).

    *   Follow the instructions at
        https://developers.google.com/google-ads/api/docs/oauth/cloud-project
        to create an OAuth2 client ID and secret for the **web application**
        OAuth2 flow.

    *   Run the
        [authenticate_in_web_application](examples/authentication/authenticate_in_web_application.pl)
        example, by providing your OAuth2 client ID and secret as the parameters.

    *   Copy the output from the last step of the example into the
        `googleads.properties` file in your home directory. Don't forget to fill
        in your developer token too.

1.  Run the [get_campaigns](examples/basic_operations/get_campaigns.pl) example
    to test if your credentials are valid. You also need to pass your Google Ads
    account's customer ID as a command-line parameter:

        perl examples/basic_operations/get_campaigns.pl -customer_id <YOUR_CUSTOMER_ID>

    **NOTE**: Code examples are meant to be run from command prompt, not via the
    web browsers.

1.  Explore other examples.

    The [examples](examples) directory contains several useful examples. Most of
    the examples require parameters. You can either pass the parameters as
    arguments (recommended) or edit the `INSERT_XXXXX_HERE` values in the source
    code. To see a usage statement for an example, pass `-help` as a
    command-line argument.

## Basic usage

To issue requests via the Google Ads API, you first need to create an
[API client](lib/Google/Ads/GoogleAds/Client.pm). For convenience, you can store
the required settings in a properties file (`googleads.properties`) with the
following format:

    ### Google Ads ###
    developerToken=INSERT_DEVELOPER_TOKEN_HERE

    ### OAuth2 ###
    clientId=INSERT_OAUTH2_CLIENT_ID_HERE
    clientSecret=INSERT_OAUTH2_CLIENT_SECRET_HERE
    refreshToken=INSERT_REFRESH_TOKEN_HERE

If you're authenticating as a manager account, additionally you must specify the
manager account ID (with hyphens removed) as the login customer ID:

    ### Google Ads ###
    loginCustomerId=INSERT_LOGIN_CUSTOMER_ID_HERE

If you have an `googleads.properties` configuration file in the above format in
your home directory, you can instantiate the client with no arguments:

```perl
my $api_client = Google::Ads::GoogleAds::Client->new();
```

If your configuration file is not in your home directory, you can pass the file
location to the the `properties_file` property as follows:

```perl
my $properties_file = "/path/to/googleads.properties";

my $api_client = Google::Ads::GoogleAds::Client->new({
  properties_file => $properties_file
});
```

You can also get a [OAuth2ApplicationsHandler](lib/Google/Ads/GoogleAds/OAuth2ApplicationsHandler.pm)
object from the `API client`, and change the client ID, client secret and
refresh token at runtime:

```perl
my $api_client = Google::Ads::GoogleAds::Client->new({
  developer_token   => "INSERT_DEVELOPER_TOKEN_HERE",
  login_customer_id => "INSERT_LOGIN_CUSTOMER_ID_HERE"
});

my $oauth_2_applications_handler = $api_client->get_oauth_2_applications_handler();
$oauth_2_applications_handler->set_client_id("INSERT_CLIENT_ID");
$oauth_2_applications_handler->set_client_secret("INSERT_CLIENT_SECRET");
$oauth_2_applications_handler->set_refresh_token("INSERT_REFRESH_TOKEN");
```

### Get a service client

Once you have an instance of `API client`, you can obtain a service client for a
particular service using one of the `...Service()` methods:

```perl
my $campaign_serevice = $api_client->CampaignService();
```

### Request/Response Logging

Logging is configured with [Log::Log4perl](https://metacpan.org/pod/Log::Log4perl),
a generic logging library for Perl.

#### Logging layout and functionality

Requests are logged with a one line summary and the full request/response body
and headers. The level at which messages are logged depends on whether the event
succeeded.

| Log type | Log name                       | Success level | Failure level |
| -------- | ------------------------------ | ------------- | ------------- |
| SUMMARY  | Google.Ads.GoogleAds.Summary   | INFO          | WARN          |
| DETAIL   | Google.Ads.GoogleAds.Detail    | DEBUG         | INFO          |

**Caveat**: Mutate requests where [Partial failure](https://developers.google.com/google-ads/api/docs/samples/handle-partial-failure)
is true do not cause the entire request to fail. Therefore, partial failure logs
are always logged at Success level, not at Failure level as may be expected.

#### Configuring logging

The client library uses a custom class for all logging purposes and is exposed
through the [GoogleAdsLogger](lib/Google/Ads/GoogleAds/Logging/GoogleAdsLogger.pm)
module. This class provides a default configuration that both summary and detail
loggers will log to relative files in the `logs` folder under your home directory.
But the default configuration can be overridden by providing a
[log4perl.conf](log4perl.conf) file in your home directory.

Logging can be enabled/disabled using the following methods:

* Enables logging for both loggers.

  ```perl
  Google::Ads::GoogleAds::Logging::GoogleAdsLogger::enable_all_logging();
  ```

* Disables the summary logging.

  ```perl
  Google::Ads::GoogleAds::Logging::GoogleAdsLogger::disable_summary_logging();
  ```

* Disables the detail logging.

  ```perl
  Google::Ads::GoogleAds::Logging::GoogleAdsLogger::disable_detail_logging();
  ```

You can use the methods of the `GoogleAdsLogger` class directly for even more
control over how requests are logged.

## Running in a Docker container

See the [Running in a Docker Container guide](https://developers.google.com/google-ads/api/docs/client-libs/perl/docker).

## Proxy configuration

See the [Proxy guide](https://developers.google.com/google-ads/api/docs/client-libs/perl/proxy).

## Miscellaneous

### Wiki

- https://github.com/googleads/google-ads-perl/wiki

### Issue tracker

- https://github.com/googleads/google-ads-perl/issues

### API Documentation:

- https://developers.google.com/google-ads/api/docs

### Support forum

- https://groups.google.com/forum/#!forum/adwords-api

### Authors

- [Wang Fan](https://github.com/wfansh)
