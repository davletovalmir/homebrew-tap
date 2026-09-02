# Homebrew cask for MD Reader.
#
# This file is the SOURCE OF TRUTH for the cask. It is not consumed by Homebrew
# from here — it has to be copied into the tap repository
# (davletovalmir/homebrew-tap, tapped as `almir/tap`) as Casks/md-reader.rb.
#
# `bash tauri/scripts/release.sh --print-cask` renders this file with the
# release's real version and the DMG's real sha256 substituted in; that rendered
# output is what goes into the tap. Never hand-edit the version/sha256 lines
# here — the two `sed` rewrites in release.sh match the exact
# `  version "..."` / `  sha256 ...` shape and nothing else.
#
#   brew tap almir/tap
#   brew install --cask almir/tap/md-reader
#
# Release artifacts live in davletovalmir/md-reader-releases — a separate
# PUBLIC repo that holds only built DMG/ZIP/update-feed assets. Source
# (davletovalmir/md-reader) stays private; this cask never touches it.
# Homebrew downloads anonymously, which works fine against a public repo, so
# `brew install` works as soon as a release is published there.
cask "md-reader" do
  version "0.2.0"
  sha256 "3b91f25b3f6cc0d60f2dfc7c46c98e39a86943558ae7b4c2cb389cb54fb5dfd8"

  url "https://github.com/davletovalmir/md-reader-releases/releases/download/v#{version}/md-reader-#{version}-arm64.dmg"
  name "MD Reader"
  desc "Native macOS markdown reader and editor"
  homepage "https://github.com/davletovalmir/md-reader-releases"

  # The release pipeline builds arm64 only. (Electron: electron-builder --arm64.
  # Tauri: the host toolchain, on the arm64 release machine.)
  depends_on arch: :arm64
  depends_on macos: :ventura

  app "MD Reader.app"

  # The CLI is a symlink to the shim INSIDE the bundle, shipped as
  # Contents/Resources/bin/mdr, exactly like the in-app installer and
  # scripts/install-cli.sh create. `brew upgrade` replaces the bundle underneath
  # the link and the command keeps working. The shim's source moved with the
  # runtime — app/build/mdr-shim.sh (Electron, `extraResources`) became
  # tauri/src-tauri/resources/bin/mdr (Tauri, `bundle.resources`) — but its
  # installed path inside the bundle is deliberately identical, so an existing
  # `mdr` symlink survives the migration from 0.1.x untouched.
  binary "#{appdir}/MD Reader.app/Contents/Resources/bin/mdr", target: "mdr"

  # This list spans BOTH runtimes, deliberately.
  #
  # MD Reader shipped on Electron through v0.1.2 and on Tauri from v0.2.0, and a
  # machine that installed 0.1.x and upgraded in place has the leavings of both.
  # `zap` is a one-shot "remove everything this app ever wrote" and it has no
  # way to ask which runtime the user came from, so it names every path either
  # one can create. Removing an entry because "we don't use Electron any more"
  # would strand exactly the users who have been here longest.
  #
  #   both      ~/Library/Application Support/MD Reader — the user data
  #             directory. The Tauri port keeps Electron's name on purpose
  #             (USER_DATA_DIR_NAME in tauri/src-tauri/src/lib.rs) so settings,
  #             snapshots and history migrate with no import step.
  #   Electron  the ShipIt cache (Squirrel.Mac's updater) and HTTPStorages
  #             (Chromium's network state).
  #   Tauri     ~/Library/WebKit/com.almir.mdreader — WKWebView's per-app data
  #             store — and ~/Library/Application Support/com.almir.mdreader,
  #             which is Tauri's own bundle-identifier-keyed config directory
  #             (`app_config_dir`), distinct from the "MD Reader" one above.
  #   both      Caches, Preferences and Saved Application State are keyed by the
  #             bundle identifier, which did not change across the port.
  zap trash: [
    "~/Library/Application Support/MD Reader",
    "~/Library/Application Support/com.almir.mdreader",
    "~/Library/Caches/com.almir.mdreader",
    "~/Library/Caches/com.almir.mdreader.ShipIt",
    "~/Library/HTTPStorages/com.almir.mdreader",
    "~/Library/Preferences/com.almir.mdreader.plist",
    "~/Library/Saved Application State/com.almir.mdreader.savedState",
    "~/Library/WebKit/com.almir.mdreader",
  ]
end
