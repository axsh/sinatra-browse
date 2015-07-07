#!/bin/bash

set -e

new_version=$1
today=$(date +"%Y-%m-%d")
gemspec=sinatra-browse.gemspec
changelog=CHANGELOG.md

if [ -z "${new_version}" ]; then
  echo "Usage: $0 <version_number>"
  exit 1
fi

sed -i "s/  s.version     = .*/  s.version     = '${new_version}'/g" ${gemspec}
sed -i "s/  s.date        = .*/  s.date        = '${today}'/g" ${gemspec}
sed -i "s/## \[Unreleased\]/## [${new_version}] - ${today}/g" ${changelog}

git diff ${gemspec} ${changelog}

read -p "Is this ok? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  git checkout ${gemspec} ${changelog}
  exit 1
fi

git add ${gemspec} ${changelog}
git commit -m "Bumped version to ${new_version}"

current_branch=$(git rev-parse --abbrev-ref HEAD)
git checkout master
git pull --rebase
git merge ${current_branch}

git push origin master

git tag v${new_version}
echo "git push origin v${new_version}"

gem build ${gemspec}
gem push sinatra-browse-${new_version}.gem
