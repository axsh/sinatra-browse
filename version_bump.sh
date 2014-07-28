#!/bin/bash

set -e

new_version=$1
today=$(date +"%Y-%m-%d")
gemspec=sinatra-browse.gemspec

if [ -z "${new_version}" ]; then
  echo "Usage: $0 <version_number>"
  exit 1
fi

sed -i "s/  s.version     = .*/  s.version     = '${new_version}'/g" ${gemspec}
sed -i "s/  s.date        = .*/  s.date        = '${today}'/g" ${gemspec}

git diff sinatra-browse.gemspec

read -p "Is this ok? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  git checkout ${gemspec}
  exit 1
fi

git add ${gemspec}
git commit -m "Bumped version to ${new_version}"
git push origin master

git tag v${new_version}
git push origin v${new_version}

gem build ${gemspec}
gem push sinatra-browse-${new_version}.gem
