#!/bin/sh -l

set -u

cd /github/workspace || exit 1

# Env and options
if [ -z "${GITHUB_TOKEN}" ]
then
    echo "The GITHUB_TOKEN environment variable is not defined."
    exit 1
fi

BRANCH="${1}"
NAME="${2}"
MESSAGE="${3}"
DRAFT="${4}"
PRE="${5}"
DATE_FORMAT="${6}"

# Security
git config --global --add safe.directory /github/workspace

# Fetch git tags
git fetch --depth=1 origin +refs/tags/*:refs/tags/*

NEXT_RELEASE=$(date "+${DATE_FORMAT}")

# ColemanB - Script looks for tags meeting requirements
# and then looks up hash.
LAST_RELEASE=$(git tag --sort=v:refname | grep "^[0-9]" | tail -n 1)
echo "Last release : ${LAST_RELEASE}"

LAST_HASH="$(git show-ref -s "${LAST_RELEASE}")"
echo "Last hash : ${LAST_HASH}"
# ColemanB - End changes.

MAJOR_LAST_RELEASE=$(echo "${LAST_RELEASE}" | awk -v l=${#NEXT_RELEASE} '{ string=substr($0, 1, l); print string; }' )
echo "Last major release : ${MAJOR_LAST_RELEASE}"

if [ "${MAJOR_LAST_RELEASE}" = "${NEXT_RELEASE}" ]; then
    MINOR_LAST_RELEASE=$(echo "${LAST_RELEASE}" | awk -v l=`expr ${#NEXT_RELEASE} + 2` '{ string=substr($0, l); print string; }' )
    NEXT_RELEASE=${MAJOR_LAST_RELEASE}.$((MINOR_LAST_RELEASE + 1))
    echo "Minor release"
fi

echo "Last release : ${LAST_RELEASE}"
echo "Next release : ${NEXT_RELEASE}"

echo ::set-output name=lastRelease::"${LAST_RELEASE}"
echo ::set-output name=nextRelease::"${NEXT_RELEASE}"
