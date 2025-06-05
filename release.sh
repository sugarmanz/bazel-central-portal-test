#!/usr/bin/env bash
# See https://github.com/bazelbuild/rules_nodejs/blob/stable/scripts/publish_release.sh 

set -u -o pipefail

# Called by auto -- `release` for normal releases or `snapshot` for canary/next.
readonly RELEASE_TYPE=${1:-snapshot}
readonly CURRENT_BRANCH=`git symbolic-ref --short HEAD`

# Maven Central publishing
MVN_RELEASE_TYPE=snapshot
MVN_NEXUS_URL=https://central.sonatype.com/repository/maven-snapshots/
if [ "$RELEASE_TYPE" == "next" ] && [ "$CURRENT_BRANCH" == "main" ]; then
  MVN_RELEASE_TYPE=release
  MVN_NEXUS_URL=https://ossrh-staging-api.central.sonatype.com/service/local/
elif [ "$RELEASE_TYPE" == "release" ] && [ "$CURRENT_BRANCH" == "main" ]; then
  MVN_RELEASE_TYPE=release
  MVN_NEXUS_URL=https://ossrh-staging-api.central.sonatype.com/service/local/
fi

echo "Publishing Maven Packages with release type: ${MVN_RELEASE_TYPE} on branch: ${CURRENT_BRANCH}"
bazel run --config=release @rules_player//distribution:staged-maven-deploy -- "$MVN_RELEASE_TYPE" --package-group=com.sugarmanz.test --nexus-url="$MVN_NEXUS_URL" --client-timeout=600 --connect-timeout=600
