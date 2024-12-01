# Copyright 2020-2023 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION="Sphinx extension that automatically documents click applications"
HOMEPAGE="https://github.com/click-contrib/sphinx-click"
SRC_URI="https://github.com/click-contrib/sphinx-click/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Tests are broken with click-8.1* (fixed in next sphinx-click version)
RESTRICT="test"

export PBR_VERSION=${PV}

RDEPEND="
	dev-python/sphinx[${PYTHON_USEDEP}]
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/docutils[${PYTHON_USEDEP}]
	dev-python/pbr[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest
