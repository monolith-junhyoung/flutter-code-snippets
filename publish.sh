#!/bin/zsh
#
# 사전설치 패키지
#  npm install -g conventional-changelog-cli
#
# 사용법
# publish.sh -s [스프린트 브랜치 이름]
#  ex) publish.sh -s sprint/231025
#
# CHANGELOG 순서
# 0. 새버전 발행 ex) update_version.sh
# 1. changelog 생성하기 (CHANGELOG 작성된다.)
# 2. pubspec.yaml에서 버전 가져오기
# 3. 로컬의 마지막 tag 가져오기, 오늘 날짜 가져오기
# 4. 생성된 changelog의 타이틀 변경하기
# 5. 변경된 파일(pubspec.yaml, CHANGELOG.md), 버전커밋
# 6. 새로운 tag 생성하고 푸시

PATTERN_VERSION="version: ([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)"

version_name=""
version_code=""

# 현재 스프린트 브랜치 이름
sprint=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--sprint)
      shift
      sprint="$1"
      ;;
    *)
      echo "Error: Invalid argument '$1'"
      exit 1
      ;;
  esac
  shift
done

if [ -z "$sprint" ]; then
  echo "Error: sprint branch name is empty. execute command with -s or --sprint option."
  exit 1
fi

echo "Releasing $sprint branch..."

# conventional-changelog 패키지 설치 확인
if command -v node &> /dev/null; then
  # Check if a specific npm package is installed
  package_name="conventional-changelog-cli"
  if ! npm list -g | grep -q "$package_name"; then
    echo "$package_name is not installed, installing now..."
    npm install -g conventional-changelog-cli
  fi
else
    echo "Node.js is not installed. Install node through 'brew install node'"
    exit 1
fi

# 1. changelog 생성하기
conventional-changelog -p angular -i CHANGELOG.md -s

# 2. pubspec.yaml에서 버전 가져오기
if version=$(grep -E "$PATTERN_VERSION" pubspec.yaml); then
  # version name
  if [[ $version =~ $PATTERN_VERSION ]]; then
    version_name="${match[1]}"
  else
    echo "Error: failed to parse version name from pubspec.yaml."
    exit 1
  fi

  # version code
  if [[ $version =~ $PATTERN_VERSION ]]; then
      version_code="${match[2]}"
  else
    echo "Error: failed to parse version code from pubspec.yaml."
    exit 1
  fi
else
  echo "Error: cannot parse versions in pubspec.yaml."
  exit 1
fi

echo "Extracting version($version_name, $version_code) from pubspec"

# 3. 로컬의 마지막 tag 가져오기, 오늘 날짜 가져오기
oldAppVersion=$(git describe --tags --abbrev=0)
today=$(date '+%Y-%m-%d')

# 4. 생성된 changelog의 타이틀 변경하기
sed -i.bak "1s/.*/# [$version_name](https:\/\/github.com\/monolith-junhyoung\/flutter-code-snippets\/compare\/$oldAppVersion...v$version_name) ($version_name+$version_code, $today)/" CHANGELOG.md
rm CHANGELOG.md.bak

# 5. 변경된 파일(pubspec.yaml, CHANGELOG.md), 버전커밋
git add pubspec.yaml CHANGELOG.md
git commit -m "chore(release): v$version_name"

echo "Creating version commit: v$version_name"

# 6. 새로운 tag 생성하고 푸시
tag_name="v$version_name"
git tag $tag_name
git push origin "$tag_name"

# 7. 마스터 브랜치로 sprint 브랜치를 rebase하고 푸시한다.
git checkout master
git rebase $sprint
git push origin master

git checkout dev
git rebase master
git push origin dev