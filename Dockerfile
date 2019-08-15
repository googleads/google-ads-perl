FROM perl:5.26

RUN cpan install Module::Build

WORKDIR /google-ads-perl
