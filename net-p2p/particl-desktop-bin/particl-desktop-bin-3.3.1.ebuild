# Copyright 2020-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit chromium-2 desktop rpm xdg

MY_PN="${PN/-bin}"

DESCRIPTION="Particl Marketplace and PART coin wallet."
HOMEPAGE="https://particl.io/"
SRC_URI="https://github.com/particl/${MY_PN}/releases/download/v${PV}/${MY_PN}-${PV}-linux-x86_64.rpm -> ${P}.rpm"
S="${WORKDIR}"

DEPEND="
	sys-libs/glibc
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

pkg_pretend() {
	chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	default

	# Renaming is done due to whitespaces breaking icon caching.
	mv "opt/Particl Desktop/" "opt/${PN}"

	# Fix desktop entry.
	ENTRY="usr/share/applications/${MY_PN}.desktop"
	sed -i "s/Exec=.*//" ${ENTRY}
	echo "Exec=${PN} %u" >> ${ENTRY}

	# Files in local usr/lib are only used in Fedora and causing warnings if not deleted.
	rm -rf "usr/lib"
}

src_configure() {
	chromium_suid_sandbox_check_kernel_config
	default
}

PREBUILT="
	${MY_PN}
	libEGL.so
	libffmpeg.so
	libGLESv2.so
	libvk_swiftshader.so
"

src_install() {
	insinto /
	doins -r usr
	doins -r opt

	local b
	for b in ${PREBUILT}; do
		fperms +x "/opt/${PN}/${b}"
	done

	doicon usr/share/icons/hicolor/512x512/apps/${MY_PN}.png
	domenu usr/share/applications/${MY_PN}.desktop

	dosym ../../opt/${PN}/${MY_PN} usr/bin/${PN}
}

pkg_postinst() {
	xdg_pkg_postinst
}
