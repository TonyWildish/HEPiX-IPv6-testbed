# Installing the gridFTP testbed

## Prerequisites
You will need **POE**, the **Perl Object Environment**. You can install this either via 

> yum install -y perl-POE

or by using the CPAN module:

> yum install -y perl-CPAN # unless you already have it on your system?
> perl -mCPAN -e shell # follow the configuration prompts if this is the first time you launch CPAN
> install POE # this can take 10 minutes or so

I prefer the latter since it runs a whole bunch of tests, but the choice is yours.

You can install with CPAN either as root or as a normal user, if you prefer not to pollute your system environment. If you install as a normal user it's up to you to configure CPAN yourself, and to make sure your **PERL5LIB** environment variable is set pointing to the correct place.

You will also need the **POE::Component::Child** module. Not all distributions have an RPM for that, so you may have to use CPAN to get it installed.

You will also need the **JSON::XS** and **Clone** Perl modules.