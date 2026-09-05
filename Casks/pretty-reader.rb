# Homebrew cask for Pretty Reader.
#
# This file is the SOURCE OF TRUTH for the cask. It is not consumed by Homebrew
# from here — it has to be copied into the tap repository
# (davletovalmir/homebrew-tap, tapped as `almir/tap`) as Casks/pretty-reader.rb.
#
# `bash tauri/scripts/release.sh --print-cask` renders this file with the
# release's real version and the DMG's real sha256 substituted in; that rendered
# output is what goes into the tap. Never hand-edit the version/sha256 lines
# here — the two `sed` rewrites in release.sh match the exact
# `  version "..."` / `  sha256 ...` shape and nothing else.
#
#   brew tap almir/tap
#   brew install --cask almir/tap/pretty-reader
#
# Release artifacts live in davletovalmir/md-reader-releases — a separate
# PUBLIC repo that holds only built DMG/ZIP/update-feed assets. Source
# (davletovalmir/md-reader) stays private; this cask never touches it.
# Homebrew downloads anonymously, which works fine against a public repo, so
# `brew install` works as soon as a release is published there.
cask "pretty-reader" do
  version "0.3.0"
  sha256 "97669d647ad39e5f5497ef513a66589a4a20ba192d8fa42db203dafe6b84cd8b"

  url "https://github.com/davletovalmir/md-reader-releases/releases/download/v#{version}/pretty-reader-#{version}-arm64.dmg"
  name "Pretty Reader"
  desc "Native macOS markdown reader and editor"
  homepage "https://github.com/davletovalmir/md-reader-releases"

  # The release pipeline builds arm64 only. (Electron: electron-builder --arm64.
  # Tauri: the host toolchain, on the arm64 release machine.)
  depends_on arch: :arm64
  depends_on macos: :ventura

  app "Pretty Reader.app"

  # The CLI is a symlink to the shim INSIDE the bundle, shipped as
  # Contents/Resources/bin/pretty, exactly like the in-app installer and
  # tauri/scripts/install-cli.sh create. `brew upgrade` replaces the bundle
  # underneath the link and the command keeps working.
  #
  # BOTH halves of this line changed in 0.3.0: the command was `mdr` and the
  # shim was `Contents/Resources/bin/mdr`. Homebrew unlinks a cask's old
  # binaries on upgrade, so `brew upgrade` from a 0.2.x install removes
  # `mdr` and adds `pretty` on its own. An `mdr` installed any OTHER way — the
  # in-app Settings row, install-cli.sh, a hand-made symlink — is NOT the
  # cask's to remove and is left where it is; `rm` it yourself.
  binary "#{appdir}/Pretty Reader.app/Contents/Resources/bin/pretty", target: "pretty"

  # This list spans BOTH runtimes AND BOTH product names, deliberately.
  #
  # The app shipped on Electron through v0.1.2 and on Tauri from v0.2.0, and it
  # was called MD Reader through v0.2.1. A machine that installed 0.1.x and
  # upgraded in place has the leavings of all of it. `zap` is a one-shot "remove
  # everything this app ever wrote" and it has no way to ask which runtime or
  # which name the user came from, so it names every path any of them can
  # create. Removing an entry because "we don't use Electron any more" or
  # "we aren't called that any more" would strand exactly the users who have
  # been here longest.
  #
  #   both      ~/Library/Application Support/Pretty Reader — the user data
  #             directory. It is keyed on the PRODUCT NAME, Electron-style
  #             (USER_DATA_DIR_NAME in tauri/src-tauri/src/lib.rs), which is
  #             what let the Tauri port inherit every Electron profile without
  #             an import step.
  #   both      ~/Library/Application Support/MD Reader — the same directory
  #             under the name it had through v0.2.1. v0.3.0 renames it on
  #             first launch, so on an up-to-date machine this is already gone;
  #             it survives on one that installed the app, never opened v0.3.0,
  #             and then ran `brew uninstall --zap`.
  #   Electron  the ShipIt cache (Squirrel.Mac's updater) and HTTPStorages
  #             (Chromium's network state).
  #   Tauri     ~/Library/WebKit/com.almir.mdreader — WKWebView's per-app data
  #             store — and ~/Library/Application Support/com.almir.mdreader,
  #             which is Tauri's own bundle-identifier-keyed config directory
  #             (`app_config_dir`), distinct from the product-name ones above.
  #   both      Caches, Preferences and Saved Application State are keyed by the
  #             bundle identifier, which changed with neither the port nor the
  #             rename — com.almir.mdreader is permanent.
  zap trash: [
    "~/Library/Application Support/Pretty Reader",
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
