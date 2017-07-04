# Copyright 2017 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

HASH=85baf9e685eb0c942764b7224fa1ce034bb3beba
S=${WORKDIR}/${PN}-${HASH}

DESCRIPTION="A C++ 11 meta-programming library"
HOMEPAGE="https://github.com/edouarda/brigand/wiki"
SRC_URI="https://github.com/edouarda/brigand/archive/${HASH}.tar.gz -> ${P}.tar.gz"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND=""
