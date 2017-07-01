# Copyright 2017 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Metapackage for dependencies of SpECTRE"
HOMEPAGE="https://github.com/sxs-collaboration/spectre"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="
	>=dev-util/cmake-3.3.2
	>=sys-cluster/charm-6.7.1_p20170526
	dev-vcs/git
	virtual/blas
	sci-libs/blaze
	dev-libs/boost
	dev-cpp/brigand
	dev-cpp/catch
	sci-libs/gsl
	sci-libs/hdf5[-mpi]
	dev-libs/jemalloc
	sci-libs/libxsmm
	dev-cpp/yaml-cpp
"
