#!/usr/bin/env bash
# Exercises update-from-main.sh against a throwaway repository and origin whose build-app.sh and
# install.sh record the checkout they ran from.
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="$(cd "$(mktemp -d -t worldclock-update-test)" && pwd -P)"
trap 'rm -rf "$work"' EXIT
failed=0

check() {
    local description="$1"
    shift
    if "$@"; then
        echo "ok   $description"
    else
        echo "FAIL $description"
        failed=1
    fi
}

git_in() {
    local repo="$1"
    shift
    git -C "$repo" -c user.name=Test -c user.email=test@example.com "$@"
}

origin="$work/origin.git"
checkout="$work/checkout"
publisher="$work/publisher"
built_record="$work/built"
installed_record="$work/installed"
opened_record="$work/opened"

mkdir -p "$work/bin"
printf '#!/bin/sh\necho "$1" >"%s"\n' "$opened_record" >"$work/bin/open"
chmod +x "$work/bin/open"

git init --quiet --bare --initial-branch=main "$origin"
git clone --quiet "$origin" "$publisher" 2>/dev/null
git_in "$publisher" switch --quiet -c main 2>/dev/null

mkdir -p "$publisher/scripts"
cat >"$publisher/scripts/build-app.sh" <<EOF
#!/bin/sh
cd "\$(dirname "\$0")/.." || exit 1
mkdir -p dist && cp marker dist/built-marker
git rev-parse HEAD >"$built_record"
# Fails after the build exists, as a failed signature check in build-app.sh does.
[ -z "\$FAIL_BUILD" ] || exit 1
EOF
cat >"$publisher/scripts/install.sh" <<EOF
#!/bin/sh
cd "\$(dirname "\$0")/.." || exit 1
cp dist/built-marker "$installed_record.marker" || exit 1
git rev-parse HEAD >"$installed_record"
EOF
chmod +x "$publisher/scripts/build-app.sh" "$publisher/scripts/install.sh"
echo merged-first >"$publisher/marker"
git_in "$publisher" add .
git_in "$publisher" commit --quiet -m first
git_in "$publisher" push --quiet origin main

git clone --quiet "$origin" "$checkout"
mkdir -p "$checkout/scripts"
cp "$repo_root/scripts/update-from-main.sh" "$checkout/scripts/update-from-main.sh"
git_in "$checkout" switch --quiet -c feature
echo uncommitted >"$checkout/marker"

echo merged-second >"$publisher/marker"
git_in "$publisher" commit --quiet -am second
git_in "$publisher" push --quiet origin main
tip="$(git -C "$publisher" rev-parse HEAD)"

update() {
    HOME="$work/home" PATH="$work/bin:$PATH" "$checkout/scripts/update-from-main.sh" >/dev/null 2>&1
}

# install.sh opens the app itself, so the update must not open it a second time.
nothing_was_opened() {
    [[ ! -e "$opened_record" ]]
}

built_commit_is_the_tip() {
    [[ "$(cat "$built_record")" == "$tip" ]]
}

installed_commit_is_the_tip() {
    [[ "$(cat "$installed_record")" == "$tip" ]]
}

installed_the_merged_build() {
    [[ "$(cat "$installed_record.marker")" == merged-second ]]
}

nothing_was_installed() {
    [[ ! -e "$installed_record" ]]
}

checkout_is_untouched() {
    [[ "$(git -C "$checkout" branch --show-current)" == feature && "$(cat "$checkout/marker")" == uncommitted ]]
}

no_worktree_is_left() {
    [[ "$(git -C "$checkout" worktree list | wc -l | tr -d ' ')" == 1 ]]
}

fails_the_update() {
    ! FAIL_BUILD=1 update
}

check "runs to completion" update
check "builds the tip of origin/main" built_commit_is_the_tip
check "installs the tip of origin/main" installed_commit_is_the_tip
check "installs the build of the merged tree, not the checkout's" installed_the_merged_build
check "leaves opening the app to install.sh" nothing_was_opened
check "leaves the checkout's branch and changes alone" checkout_is_untouched
check "removes its worktree" no_worktree_is_left

rm -f "$built_record" "$installed_record" "$installed_record.marker"
check "reports a failed build" fails_the_update
check "installs nothing after a failed build" nothing_was_installed
check "removes its worktree after a failed build" no_worktree_is_left

exit "$failed"
