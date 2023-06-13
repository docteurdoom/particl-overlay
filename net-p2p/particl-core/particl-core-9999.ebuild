# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DB_VER="4.8"
inherit autotools db-use flag-o-matic xdg-utils

DESCRIPTION="Particl, P2P privacy ecosystem."
HOMEPAGE="https://particl.io/"

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/particl/${PN}.git"
else
	SRC_URI="https://github.com/particl/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~arm ~arm64 ~ppc ~ppc64 x86 ~amd64-linux ~x86-linux"
fi

LICENSE="MIT"
SLOT="0"

IUSE="+asm +qrcode +dbus +wallet +hardened +gui +daemon +utils bench test upnp zeromq"
REQUIRED_USE="
	wallet? (
		|| ( gui daemon )
	)
	upnp? (
		|| ( gui daemon )
	)
	zeromq? (
		|| ( gui daemon )
	)
	dbus? ( gui )
	qrcode? ( gui )
	|| ( gui daemon utils )
"

DEP_LIB="
	>dev-libs/libsecp256k1-0.1_pre20200911:=[recovery,schnorr]
"
DEP_DB="
	sys-libs/db:$(db_ver_to_slot "${DB_VER}")=[cxx]
"

RDEPEND="
	dev-libs/boost:=
	dev-libs/libevent:=
	daemon? ( ${DEP_LIB} )
	gui? (
		${DEP_LIB}
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5
		dev-qt/qtwidgets:5
	)
	dbus? ( dev-qt/qtdbus:5 )
	utils? ( ${DEP_DB} )
	wallet? (
		>=dev-db/sqlite-3.7.17:=
		${DEP_DB}
	)
	qrcode? ( media-gfx/qrencode:= )
	upnp? ( >=net-libs/miniupnpc-1.9.20150916:= )
	zeromq? ( net-libs/zeromq:= )
"

DEPEND="${RDEPEND}"
BDEPEND="
	>=sys-devel/automake-1.13
	|| ( >=sys-devel/gcc-7[cxx] >=sys-devel/clang-5 )
	gui? ( dev-qt/linguist-tools:5 )
"

RESTRICT="!test? ( test )"

S="${WORKDIR}/${P}"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	append-cxxflags "-fpermissive"
	local my_econf=(
		$(use_enable asm)
		$(use_with dbus qtdbus)
		$(use_with qrcode qrencode)
		$(use_with upnp miniupnpc)
		$(use_enable upnp upnp-default)
		$(use_enable test tests)
		$(use_enable test gui-tests)
		$(use_enable wallet wallet)
		$(use_with wallet sqlite)
		$(use_enable zeromq zmq)
		$(use_enable hardened hardening)
		$(use_with gui gui)
		$(use_with daemon daemon)
		$(use_enable utils util)
		$(use_enable utils util-cli)
		$(use_enable utils util-tx)
		$(use_enable utils util-wallet)
		$(use_enable bench bench)
		--disable-multiprocess
		--without-multiprocess
		--without-libs
		--disable-static
	)
	econf "${my_econf[@]}"
}

src_install() {
	default
}

update_caches() {
	xdg_icon_cache_update
	xdg_desktop_database_update
}

pkg_postinst() {
	if use gui; then
		update_caches
	fi
}

pkg_postrm() {
	if use gui; then
		update_caches
	fi
}
