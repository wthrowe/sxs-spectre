# Copyright 2021 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic

DESCRIPTION="Library for fast spherical harmonic transforms"
HOMEPAGE="https://github.com/Libsharp/libsharp"
SRC_URI="https://github.com/Libsharp/libsharp/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="openmp"

RDEPEND=""
DEPEND="${RDEPEND}"

src_prepare() {
	eapply "${FILESDIR}/1.0.0-respect-cflags.patch"
	eapply_user
	eautoreconf
}

src_configure() {
	append-cflags -fPIC
	econf \
		--enable-noisy-make \
		$(use_enable openmp)
}

src_install() {
	doheader auto/include/sharp*
	dolib.a auto/lib/*
}
