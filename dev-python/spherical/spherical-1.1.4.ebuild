# Copyright 2026 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
EPYTEST_PLUGINS=( pytest-cov )
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Evaluate and transform D matrices, 3-j symbols, and spherical harmonics"
HOMEPAGE="https://github.com/moble/spherical"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
	dev-python/quaternionic[${PYTHON_USEDEP}]
	dev-python/spinsfast[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest

BDEPEND+="
	test? ( dev-python/sympy[${PYTHON_USEDEP}] )
"
