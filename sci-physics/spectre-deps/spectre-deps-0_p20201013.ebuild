# Copyright 2020 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Metapackage for dependencies of SpECTRE"
HOMEPAGE="https://github.com/sxs-collaboration/spectre"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+development python"

DEPEND=""
# The order of these packages matches the list on the SpECTRE
# installation page.
RDEPEND="
	>=dev-util/cmake-3.8.0
	~sys-cluster/charm-6.10.2
	dev-vcs/git
	virtual/blas
	~sci-libs/blaze-3.8
	>=dev-libs/boost-1.60.0[python?]
	>=dev-cpp/brigand-1.3.0_p20170624
	>=dev-cpp/catch-2.1
	sci-libs/gsl
	sci-libs/hdf5[-mpi]
	dev-libs/jemalloc
	virtual/lapack
	sci-libs/libsharp[-openmp,-mpi(-)]
	sci-libs/libxsmm
	~dev-cpp/yaml-cpp-0.6.3
	>=dev-python/numpy-1.10
	dev-python/scipy
	python? (
		dev-python/pybind11
	)
	development? (
		app-doc/doxygen
		dev-cpp/google-benchmark
		>=sys-devel/clang-5[static-analyzer]
		dev-util/include-what-you-use
		dev-python/yapf
	)
"
