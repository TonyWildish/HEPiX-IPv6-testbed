# Installing the gridFTP testbed

## Prerequisites
The testbed runs on Linux, on something resembling SLC5/6 or CentOS 6. It can probably run on later versions or other flavours of Linux too without difficulty, I haven't tested it.

You will need **POE**, the **Perl Object Environment**, and a few other modules. You can install them either via yum:

> yum install -y perl-JSON-XS perl-Clone perl-YAML perl-POE

or by using the CPAN module:

> yum install -y perl-CPAN # unless you already have it on your system?
> perl -mCPAN -e shell # follow the configuration prompts if this is the first time you launch CPAN
> install JSON::XS Clone YAML POE # this can take 10 minutes or so

I prefer the latter since it runs a whole bunch of tests. That said, the tests for POE often fail for unimportant reasons, so you end up having to do a **force install POE** to make it work, so the choice is yours.

You can install with CPAN either as root or as a normal user, if you prefer not to pollute your system environment. If you install as a normal user it's up to you to configure CPAN yourself. You will also need to make sure your **PERL5LIB** environment variable is set pointing to the correct place afterwards, so the testbed software can find it.

You will also need the **POE::Component::Child** module. Not all distributions have an RPM for that, so you will probably have to use CPAN to get it installed. This can be tedious sometimes, it's a bit fragile and doesn't declare its dependencies properly.

## Using the testbed
first, source the env.sh script in this directory. This will put the perl libraries and the **Lifecycle.pl** script in your **PERL5LIB** and **PATH**, respectively. If you've installed Perl modules locally, you can set your PERL5LIB here.

First, you can check your installation is sane by running some of the examples in the **examples** directory. See the README there for details.

Next, go to the appropriate subdirectory (HEPiX or EBI) and follow the instructions in the README there.