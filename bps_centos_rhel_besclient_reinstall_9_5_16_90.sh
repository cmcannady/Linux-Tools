#!/bin/sh

# *** ***************************************************************** ***
# ***                                                                   ***
# *** Casey Cannady (casey.cannady@hcl.com)                             ***
# *** BigFix Professional Services                                      ***
# *** HCL Software                                                      ***
# *** 10/02/2020                                                        ***
# ***                                                                   ***
# *** This script MUST be run as root on the endpoint.                  ***
# ***                                                                   ***
# *** Provided AS-IS and without warranty.                              ***
# ***                                                                   ***
# *** This script removes the BES client service, cleans the file       ***
# *** system, downloads the latest BES client version, and then         ***
# *** reinstalls the BES client service.                                ***
# ***                                                                   ***
# *** ***************************************************************** ***

#
# Stop BES client services if running
#
service besclient stop

#
# Remove previous versions of BESClient
#
rpm -ev BESAgent

#
# Clean-up file system
#
rm -rf /etc/opt/BESClient
rm -rf /opt/BESClient
rm -rf /var/opt/BESClient
rm -rf /tmp/BESAgent*.rpm

#
# Create necessary directory on endpoint
#
mkdir -p /etc/opt/BESClient
mkdir -p /opt/BESClient

#
# Download necessary masthead file to endpoint
#
cd /opt/BESClient
wget http://ROOT-BES-FDQN:52311/masthead/masthead.afxm
mv masthead.afxm actionsite.afxm
cp actionsite.afxm /etc/opt/BESClient

#
# Download BESClient version from root BES server
#
cd /tmp
wget http://software.bigfix.com/download/bes/95/BESRelay-9.5.16.90-rhe6.x86_64.rpm

#
# Set BES RPM file permissions
#
chmod 755 BESRelay-9.5.16.90-rhe6.x86_64.rpm

#
# Install BES client and relay packages via RPM
#
rpm -ivh BESRelay-9.5.16.90-rhe6.x86_64.rpm

#
# Restart BES services for good measure
#
service besclient restart

#
# END
#