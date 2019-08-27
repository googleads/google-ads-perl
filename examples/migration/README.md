# Google Ads Client Library for Perl - Migration examples

This folder contains code examples that illustrate how to migrate from the
AdWords API to the Google Ads API in a step-by-step manner. The following code
examples are provided.

## campaign_management

This folder contains a code example that shows how to create a Google Ads search
campaign. The code example does the following operations:

  - Create a budget
  - Create a campaign
  - Create an ad group
  - Create text ads
  - Create keywords

The code example starts with `create_complete_campaign_adwords_api_only.pl` that
shows the whole functionality developed in AdWords API.
`create_complete_campaign_both_apis_phase_1.pl` through
`create_complete_campaign_both_apis_phase_4.pl` shows how to migrate functionality
incrementally from the AdWords API to the Google Ads API.
`create_complete_campaign_google_ads_api_only.pl` shows the code example fully
transformed into using the Google Ads API.

## Running the examples

To execute the examples, open `run_example.pl`, fill in the required authentication
credentials and parameters, then uncomment the example you want to run and run
`perl run_example.pl` from the command line.