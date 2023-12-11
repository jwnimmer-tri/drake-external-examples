#!/bin/bash
# SPDX-License-Identifier: MIT-0
#
# Executes the install_prereqs script contained within @drake_artifacts.
#
# Run this program as:
#  bazel run //:install_prereqs

set -euo pipefail

# Fail-fast when not run via Bazel.
if [[ -z "${BUILD_WORKSPACE_DIRECTORY+x}" ]]; then
  echo 'ERROR: You must run this program as:'
  echo '  bazel run //:install_prereqs'
  exit 1
fi

# Ask for the the password up-front to save confusion later.
if [[ "${EUID}" -ne 0 ]]; then
  sudo -v
  maybe_sudo=sudo
else
  maybe_sudo=
fi

# Update the package lists
$maybe_sudo apt-get update || (sleep 30; apt-get update)

# Install the required packages.
$maybe_sudo apt-get install --no-install-recommends lsb-release
codename=$(lsb_release -sc)
packages1=$(cat "external/drake/setup/ubuntu/binary_distribution/packages-${codename}.txt")
packages2=$(cat "external/drake/setup/ubuntu/source_distribution/packages-${codename}.txt")
$maybe_sudo apt-get install --no-install-recommends ${packages1} ${packages2}
