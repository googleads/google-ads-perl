FROM perl:5.32

RUN cpan install Module::Build

WORKDIR /google-ads-perl
