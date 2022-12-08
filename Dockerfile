FROM perl:5.30

RUN cpan install Module::Build

WORKDIR /google-ads-perl
