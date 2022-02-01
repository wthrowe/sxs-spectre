# Copyright 2020-2022 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..10} )

inherit python-r1

DESCRIPTION="Metapackage for dependencies of SpECTRE"
HOMEPAGE="https://github.com/sxs-collaboration/spectre"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+development python +visualization"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND=""
# The order of these packages matches the list on the SpECTRE
# installation page.
RDEPEND="
	${PYTHON_DEPS}
	>=dev-util/cmake-3.12.0
	>=sys-cluster/charm-7.0.0
	dev-vcs/git
	virtual/blas
	~sci-libs/blaze-3.8
	python? ( >=dev-libs/boost-1.60.0[python,${PYTHON_USEDEP}] )
	!python? ( >=dev-libs/boost-1.60.0 )
	>=dev-cpp/brigand-1.3.0_p20170624
	>=dev-cpp/catch-2.8.0
	sci-libs/gsl
	sci-libs/hdf5[-mpi]
	dev-libs/jemalloc
	virtual/lapack
	sci-libs/libsharp[-openmp,-mpi(-)]
	>=sci-libs/libxsmm-1.16.1
	~dev-cpp/yaml-cpp-0.6.3
	>=dev-python/numpy-1.10[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/h5py[${PYTHON_USEDEP}]
	python? (
		>=dev-python/pybind11-2.6.0[${PYTHON_USEDEP}]
	)
	development? (
		app-doc/doxygen
		dev-cpp/google-benchmark
		>=sys-devel/clang-5[static-analyzer]
		dev-python/yapf
	)
	visualization? ( media-video/ffmpeg )
"
