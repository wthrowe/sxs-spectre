# Copyright 2026 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="NumPy aware dynamic Python compiler using LLVM"
HOMEPAGE="https://numba.pydata.org/"

LICENSE="BSD-2 MIT BSD PSF-2.4 NVIDIA-CUDA"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="bindist mirror"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/llvmlite[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

# CUDA tests fail.  Seems to be some missing dependency, but can't
# figure out what.
RESTRICT+=" test"
