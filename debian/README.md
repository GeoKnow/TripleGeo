## Create a debian package

### Build .deb package

Install debian maintainer's toolset:

    apt-get install devscripts

Create the "upstream" source package in the parent directory:

    tar czvf triplegeo_<version>.orig.tar.gz --exclude 'debian' --exclude '.git' triplegeo/

Descend into versioned directory (triplegeo) and build:

    debuild -us -uc

This should produce the .deb package for your current architecture (in the parent directory):

    triplegeo_<version>-<package-version>_<cpu-arch>.deb

e.g.

    triplegeo_1.0-3_amd64.deb

### Install .deb package

Let's assume we have built (or just downloaded) triplegeo_1.0-3_amd64.deb. Install through _dpkg_:

    dpkg --install triplegeo_1.0-3_amd64.deb

If the command fails, complaining about missing dependencies, install them through _apt_: 

    apt-get install -f    

### Run triplegeo from shell

All methods to invoke _triplegeo_ that are described in the generic case, also apply here. Additionaly,
the .deb package ships with a wrapper shell (bash) script that hides some of the impractical java details.

For example:
    
    triplegeo.sh run-on-shp path/to/shp-options.conf

Get the description of recognized arguments:

    triplegeo.sh help



