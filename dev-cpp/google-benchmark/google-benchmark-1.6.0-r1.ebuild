# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A microbenchmark support library"
HOMEPAGE="https://github.com/google/benchmark"
SRC_URI="https://github.com/google/benchmark/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RESTRICT="!test? ( test )"

S="${WORKDIR}/benchmark-${PV}"

src_configure() {
	local mycmakeargs=(
		-DBENCHMARK_ENABLE_TESTING=$(usex test ON OFF)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	mv "${ED}"/usr/share/doc/{benchmark,"${P}"} || die
}
