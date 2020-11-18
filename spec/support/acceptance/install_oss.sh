#!/bin/bash

version=`puppet --version`

if [ -z "$version" ]; then
  PUPPET_RELEASE=6
  DEB_FILE=puppet${PUPPET_RELEASE}.deb
  DOWNLOAD_URL=https://apt.puppet.com/puppet${PUPPET_RELEASE}-release-xenial.deb

  curl -o ${DEB_FILE} ${DOWNLOAD_URL}
  if [[ $? -ne 0 ]]; then
    echo "Error: wget failed to download [${DOWNLOAD_URL}]"
    exit 2
  fi

  dpkg -i ${DEB_FILE}
  if [[ $? -ne 0 ]]; then
    echo 'Error: Failed to install Puppet repository'
    exit 2
  fi

  apt-get update
  if [[ $? -ne 0 ]]; then
    echo 'Error: Failed to update repository'
    exit 2
  fi

  apt-get -qy install puppetserver puppet-agent puppet-bolt
  if [[ $? -ne 0 ]]; then
    echo 'Error: Failed to install Puppet services'
    exit 2
  fi

  ln -s /opt/puppetlabs/bin/puppet /usr/local/bin/puppet
  ln -s /opt/puppetlabs/bin/facter /usr/local/bin/facter
  ln -s /opt/puppetlabs/bin/hiera /usr/local/bin/hiera

  puppet config set server `facter fqdn`
  puppet config set --section server autosign true

  systemctl start puppetserver.service
fi

version=`puppet --version`

if [ -z "$version "]; then
  echo 'puppet install failed'
  exit 1
fi
