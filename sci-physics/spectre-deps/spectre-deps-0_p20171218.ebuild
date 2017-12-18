# Copyright 2017 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit multilib-build

DESCRIPTION="Metapackage for dependencies of SpECTRE"
HOMEPAGE="https://github.com/sxs-collaboration/spectre"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
# cmake-3.8 cannot find multilib hdf5.  Upstream bug #17442.
RDEPEND="
	>=dev-util/cmake-3.3.2
	abi_x86_32? ( !>=dev-util/cmake-3.8 )
	>=sys-cluster/charm-6.8.0_p20170922-r1[${MULTILIB_USEDEP}]
	dev-vcs/git
	virtual/blas[${MULTILIB_USEDEP}]
	~sci-libs/blaze-3.2
	dev-libs/boost[${MULTILIB_USEDEP}]
	>=dev-cpp/brigand-1.3.0_p20170624
	dev-cpp/catch
	sci-libs/gsl[${MULTILIB_USEDEP}]
	sci-libs/hdf5[-mpi,${MULTILIB_USEDEP}]
	dev-libs/jemalloc[${MULTILIB_USEDEP}]
	sci-libs/libxsmm[${MULTILIB_USEDEP}]
	>=dev-cpp/yaml-cpp-0.5.3_p20170403[${MULTILIB_USEDEP}]
"
