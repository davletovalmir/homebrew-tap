# Homebrew cask for MD Reader.
#
# This file is the SOURCE OF TRUTH for the cask. It is not consumed by Homebrew
# from here — it has to be copied into the tap repository
# (davletovalmir/homebrew-tap, tapped as `almir/tap`) as Casks/md-reader.rb.
#
# `bash scripts/release.sh --print-cask` renders this file with the release's
# real version and the DMG's real sha256 substituted in; that rendered output is
# what goes into the tap. Never hand-edit the version/sha256 lines here.
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
  version "0.1.1"
  sha256 "2261fdcc28307fdf797a44d7c63396f9765506c438c656ccb343d61918299980"

  url "https://github.com/davletovalmir/md-reader-releases/releases/download/v#{version}/md-reader-#{version}-arm64.dmg",
      verified: "github.com/davletovalmir/md-reader-releases/"
  name "MD Reader"
  desc "Native macOS markdown reader and editor"
  homepage "https://github.com/davletovalmir/md-reader-releases"

  # The release pipeline builds arm64 only (scripts/release.sh passes --arm64).
  depends_on arch: :arm64
  depends_on macos: :ventura

  app "MD Reader.app"

  # The CLI is a symlink to the shim INSIDE the bundle (app/build/mdr-shim.sh,
  # shipped as Contents/Resources/bin/mdr), exactly like the in-app installer and
  # scripts/install-cli.sh create. `brew upgrade` replaces the bundle underneath
  # the link and the command keeps working.
  binary "#{appdir}/MD Reader.app/Contents/Resources/bin/mdr", target: "mdr"

  zap trash: [
    "~/Library/Application Support/MD Reader",
    "~/Library/Caches/com.almir.mdreader",
    "~/Library/Caches/com.almir.mdreader.ShipIt",
    "~/Library/HTTPStorages/com.almir.mdreader",
    "~/Library/Preferences/com.almir.mdreader.plist",
    "~/Library/Saved Application State/com.almir.mdreader.savedState",
  ]
end
