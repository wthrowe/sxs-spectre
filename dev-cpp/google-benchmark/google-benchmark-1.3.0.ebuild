# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="A microbenchmark support library"
HOMEPAGE="https://github.com/google/benchmark"
SRC_URI="https://github.com/google/benchmark/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/benchmark-${PV}"

src_configure() {
	local mycmakeargs=(
		-DBENCHMARK_ENABLE_TESTING=$(usex test ON OFF)
	)
	cmake-utils_src_configure
}