# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DB_VER="4.8"
inherit autotools db-use desktop flag-o-matic xdg-utils

DESCRIPTION="Particl Coin core bundle."
HOMEPAGE="https://particl.io/"

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/particl/${PN}.git"
else
	SRC_URI="https://github.com/particl/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~arm ~arm64 ~ppc ~ppc64 x86 ~amd64-linux ~x86-linux ~riscv"
fi

LICENSE="MIT"
SLOT="0"

IUSE="+asm +qrcode +dbus +wallet +hardened +gui +daemon +utils bench test upnp zeromq man"
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
	if use gui; then
		cp src/qt/res/icons/particl.png particl-qt.png
	fi

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
		$(use_with test rapidcheck)
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
		$(use_enable man man)
		--disable-multiprocess
		--without-multiprocess
		--without-libs
		--disable-static
	)
	econf "${my_econf[@]}"
}

src_install() {
	default

	if use gui; then
		insinto /usr/share/icons/hicolor/scalable/apps
		doins particl-qt.png
		cp "${FILESDIR}/particl-qt.desktop" "${T}"
		domenu "${T}/particl-qt.desktop"
	fi
}

update_caches() {
	xdg_icon_cache_update
	xdg_desktop_database_update
}

pkg_postinst() {
	if use gui; then
		update_caches
	fi

	elog "To get ${PN} running on Musl-based systems,"
	elog "make sure to set LC_ALL=\"C\" environment variable."

	if use gui; then
		elog "particl-qt to launch GUI."
	fi

	if use daemon; then
		elog "particld to launch daemon."
	fi

	if use utils; then
		elog "particl-cli to launch CLI."
		elog "particl-tx to launch transaction utility."
		elog "particl-wallet to launch wallet utility."
	fi
}

pkg_postrm() {
	if use gui; then
		update_caches
	fi
}
