EAPI=8

inherit go-module multilib

DESCRIPTION="Plugin-based backend service for custom application launchers and desktop utilities"
HOMEPAGE="https://github.com/abenz1267/elephant"
SRC_URI="https://github.com/abenz1267/elephant/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://github.com/tuandzung/${PN}/releases/download/v${PV}/${P}-vendor.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="1password bluetooth bookmarks calc clipboard +desktopapplications files menus nirisessions providerlist runner snippets symbols todo unicode websearch windows bitwarden"

DEPEND="dev-db/sqlite"
RDEPEND="
  ${DEPEND}
  bitwarden? ( app-admin/rbw )
  bookmarks? ( app-misc/jq )
  calc? ( sci-libs/libqalculate )
  clipboard? (
    gui-apps/wl-clipboard
    media-gfx/imagemagick
  )
  files? ( sys-apps/fd )
  nirisessions? ( gui-wm/niri )
  snippets? ( gui-apps/wtype )
  windows? ( sys-apps/fd )
"
BDEPEND=">=dev-lang/go-1.21"

src_compile() {
  export CGO_ENABLED=1
  ego build -o elephant ./cmd/elephant || die

  mkdir -p providers || die
  local provider name
  for provider in internal/providers/*; do
    [[ -d ${provider} ]] || continue
    name=${provider##*/}
    case ${name} in
      archlinuxpkgs | dnfpackages) continue ;;
    esac
    use "${name}" || continue
    ego build -buildmode=plugin -o "providers/${name}.so" "./internal/providers/${name}" || die
  done
}

src_install() {
  dobin elephant
  local plugins=(providers/*.so)
  if [[ -e ${plugins[0]} ]]; then
    insinto "/usr/$(get_libdir)/elephant"
    doins "${plugins[@]}"
  fi
  newinitd "${FILESDIR}/elephant.initd" elephant
  newconfd "${FILESDIR}/elephant.confd" elephant
  DOCS=(README.md)
  einstalldocs
}

pkg_postinst() {
  elog "To enable the system service:"
  elog "  rc-update add elephant default"
  elog "  rc-service elephant start"
  elog "The service can also run as an unprivileged user via"
  elog "ELEPHANT_USER and ELEPHANT_GROUP in /etc/conf.d/elephant."
}
