# Copyright 2020-2026 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

# dev-python/SimulationSupport is single-impl, so this has to be too
inherit python-single-r1

DESCRIPTION="Metapackage for dependencies of SpECTRE"
HOMEPAGE="https://github.com/sxs-collaboration/spectre"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+development +visualization"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# The order of these packages matches the list on the SpECTRE
# installation page.
RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		>=dev-build/cmake-3.18.0
		dev-vcs/git
		virtual/blas
		virtual/lapack
		>=dev-libs/boost-1.60.0[python,${PYTHON_USEDEP}]
		sci-libs/gsl
		sci-libs/hdf5
		>=sys-cluster/charm-7.0.0-r1
		~sci-libs/blaze-3.8
		>=dev-cpp/catch-3.4.0
		>=sci-libs/libxsmm-1.16.1
		>=dev-cpp/yaml-cpp-0.7.0
		dev-python/click[${PYTHON_USEDEP}]
		dev-python/h5py[${PYTHON_USEDEP}]
		dev-python/humanize[${PYTHON_USEDEP}]
		dev-python/jinja2[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/matplotlib[${PYTHON_USEDEP}]
		dev-python/pandas[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/rich[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		>=dev-python/pybind11-2.6.0[${PYTHON_USEDEP}]
		dev-libs/jemalloc
		development? (
			>=app-text/doxygen-1.9.1
			dev-python/beautifulsoup4[${PYTHON_USEDEP}]
			dev-python/nbconvert[${PYTHON_USEDEP}]
			dev-python/pybtex[${PYTHON_USEDEP}]
			dev-python/sphinx[${PYTHON_USEDEP}]
			dev-python/sphinx-click[${PYTHON_USEDEP}]
			dev-python/furo[${PYTHON_USEDEP}]
			dev-python/myst-parser[${PYTHON_USEDEP}]
			~dev-python/black-26.5.1[${PYTHON_USEDEP}]
			dev-python/isort[${PYTHON_USEDEP}]
			dev-cpp/google-benchmark
			llvm-core/clang
		)
		visualization? ( media-video/ffmpeg )
		>=dev-cpp/xsimd-11.0.1
	')
	~dev-python/SimulationSupport-0.1.0_p20260806[${PYTHON_SINGLE_USEDEP}]
"
