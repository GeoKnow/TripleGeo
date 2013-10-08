## Create a debian package

### Quickstart

Install debian maintainer's toolset:

    apt-get install devscripts

Create the "upstream" source package in the parent directory:

    tar czvf triplegeo_<version>.orig.tar.gz --exclude 'debian' --exclude '.git' triplegeo/

Descend into versioned directory (triplegeo) and build:

    debuild -us -uc

This should produce the .deb package for your current architecture (in the parent directory):

    triplegeo_<version>-<package-version>_<cpu-arch>.deb

e.g.

    triplegeo_1.0-2_amd64.deb
