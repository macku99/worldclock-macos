# WorldClock

A macOS app and a large desktop widget that show the local time beside a list of other timezones. The app keeps its own list; each widget picks its timezones by ID (such as `Asia/Tokyo`) in Edit Widget (Control-click the widget) and lists them west to east by their current offset. They don't share a list because sharing needs an app group, and macOS refuses a group container to an app whose signature carries no Team ID, which a self-signed certificate never does.

## Layout

- `WorldClock/WorldClock` is the app and its timezone store, `WorldClock/WorldClockWidgetExtension` the widget, and `WorldClock/Shared` the model and formatters both compile.
- `scripts/` builds, installs and updates the app; `fastlane/Fastfile` wraps the update.

## Install

WorldClock runs only on M's Mac and is signed with a self-signed certificate named "WorldClock Local", with no Apple developer account. The project signs to run locally (ad hoc) when built from Xcode; `scripts/build-app.sh` signs with the certificate instead, so the signature stays the same from one install to the next.

Create the certificate once, in Keychain Access:

1. With Keychain Access in front, open the Keychain Access menu in the menu bar and choose Certificate Assistant › Create a Certificate.
2. Name it `WorldClock Local`, set Identity Type to Self Signed Root and Certificate Type to Code Signing, and tick "Let me override defaults".
3. Set the validity to 3650 days, keep the other defaults, and save it to the login keychain.
4. Open it under login › My Certificates, set Trust › Code Signing to Always Trust, close it and enter your password.

`security find-identity -v -p codesigning` then lists `WorldClock Local`. The first build may ask whether `codesign` may use the key; choose Always Allow.

```bash
scripts/build-app.sh
scripts/install.sh
```

`scripts/build-app.sh` runs a Release `xcodebuild` into `dist/WorldClock.noindex/` (the `.noindex` folder keeps Spotlight from listing a second WorldClock), signs the app and its widget, and verifies the signature. `scripts/install.sh` refuses a build whose app or widget is signed by anything other than "WorldClock Local", quits the running app, swaps the build into `~/Applications/WorldClock.app`, stops the old widget process and opens the app. It then unregisters and removes the build, so each install needs a fresh `scripts/build-app.sh`. `SIGNING_IDENTITY=-` signs ad hoc for a local check; `scripts/install.sh` refuses such a build.

Add the widget from the desktop's Edit Widgets, then Control-click it and choose Edit "World Clock" to pick its timezones.

## Update to the latest main

`bundle exec fastlane prod` installs the tip of origin/main and opens it. It runs `scripts/update-from-main.sh`, which builds and installs from a throwaway worktree, so the checkout's branch and uncommitted changes never reach the installed app. fastlane is pinned in the `Gemfile`; set up each checkout once:

```bash
bundle config set --local path vendor/bundle
bundle install
```

`scripts/test-update-from-main.sh` checks the update against a throwaway repository.
