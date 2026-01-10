# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER=1.81.0

inherit cargo

DESCRIPTION="Multi-Purpose Launcher with a lot of features. Highly Customizable and fast."
HOMEPAGE="https://walkerlauncher.com/ https://github.com/abenz1267/walker"
SRC_URI="https://github.com/abenz1267/walker/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://github.com/tuandzung/${PN}/releases/download/v${PV}/${P}-crates.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
  >=gui-libs/gtk-4.6:4
  gui-libs/gtk4-layer-shell
  app-text/poppler[cairo]
"
DEPEND="${RDEPEND}"
BDEPEND="
  >=virtual/rust-${RUST_MIN_VER}
  dev-libs/protobuf
  virtual/pkgconfig
"

S="${WORKDIR}/${PN}-${PV}"

src_install() {
  cargo_src_install
  einstalldocs

  insinto /etc/xdg/walker
  doins resources/config.toml

  insinto /etc/xdg/walker/themes/default
  doins resources/themes/default/*.xml resources/themes/default/*.css
}
