# Copyright 2017-2022 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

HASH=66b3d9276ed95425ac919ac1841286d088b5f4b1
S=${WORKDIR}/${PN}-${HASH}

DESCRIPTION="A C++ 11 meta-programming library"
HOMEPAGE="https://github.com/edouarda/brigand/wiki"
SRC_URI="https://github.com/edouarda/brigand/archive/${HASH}.tar.gz -> ${P}.tar.gz"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

DEPEND=""
RDEPEND=""

RESTRICT="!test? ( test )"

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
	)
	cmake_src_configure
}
