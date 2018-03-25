# Copyright 2017 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Metapackage for dependencies of SpECTRE"
HOMEPAGE="https://github.com/sxs-collaboration/spectre"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+development"

DEPEND=""
RDEPEND="
	>=dev-util/cmake-3.3.2
	>=sys-cluster/charm-6.8.0_p20170922-r1
	dev-vcs/git
	virtual/blas
	~sci-libs/blaze-3.2
	dev-libs/boost
	>=dev-cpp/brigand-1.3.0_p20170624
	>=dev-cpp/catch-2.1
	sci-libs/gsl
	sci-libs/hdf5[-mpi]
	dev-libs/jemalloc
	sci-libs/libxsmm
	>=dev-cpp/yaml-cpp-0.5.3_p20170403
	development? (
		app-doc/doxygen
		dev-cpp/google-benchmark
		dev-util/lcov
		>=sys-devel/clang-5[static-analyzer]
	)
"
