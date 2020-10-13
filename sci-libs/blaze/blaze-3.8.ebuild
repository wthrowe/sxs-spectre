# Copyright 2020 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="A header-only C++ math library for dense and sparse arithmetic"
HOMEPAGE="https://bitbucket.org/blaze-lib/blaze/overview"
SRC_URI="https://bitbucket.org/blaze-lib/blaze/downloads/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="blas"

DEPEND=""
RDEPEND="
	>=dev-libs/boost-1.54.0
	blas? ( virtual/cblas )"

src_configure() {
	local blas_config="#define BLAZE_BLAS_MODE $(usex blas 1 0)"
	sed -i -e "s/^#define BLAZE_BLAS_MODE .*/${blas_config}/" \
		blaze/config/BLAS.h || die
	grep -x "${blas_config}" blaze/config/BLAS.h >/dev/null \
		|| die "Failed to set BLAS mode"
}

src_install() {
	mkdir -p "${ED}/usr/include"
	mv blaze "${ED}/usr/include" || die
}
