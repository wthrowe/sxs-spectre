# Copyright 2026 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="A lightweight LLVM python binding for writing JIT compilers"
HOMEPAGE="https://llvmlite.readthedocs.io/en/latest/"

LICENSE="BSD-2 Apache-2.0-with-LLVM-exceptions"
SLOT="0"
KEYWORDS="~amd64"

# This version doesn't require LLVM patches, so we can use system LLVM
RDEPEND="
	=llvm-core/llvm-22*
"
DEPEND="
	${RDEPEND}
	dev-build/cmake
	dev-build/make
"

distutils_enable_tests pytest

python_configure_all() {
	export LLVMLITE_SHARED=1
}
