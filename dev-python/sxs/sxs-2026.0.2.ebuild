# Copyright 2026 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
EPYTEST_PLUGINS=( pytest-cov )
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Interface to data produced by the Simulating eXtreme Spacetimes collaboration"
HOMEPAGE="https://github.com/sxs-collaboration/sxs"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/sxscatalog[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
	dev-python/numba[${PYTHON_USEDEP}]
	dev-python/quaternionic[${PYTHON_USEDEP}]
	dev-python/spherical[${PYTHON_USEDEP}]
	dev-python/h5py[${PYTHON_USEDEP}]
	dev-python/inflection[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
	dev-python/urllib3[${PYTHON_USEDEP}]
	dev-python/pandas[${PYTHON_USEDEP}]
	dev-python/bibtexparser[${PYTHON_USEDEP}]
	dev-python/juliacall[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest
# Tests require network access
RESTRICT="test"
