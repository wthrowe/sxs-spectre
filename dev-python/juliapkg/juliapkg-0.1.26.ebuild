# Copyright 2026 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Julia version manager and package manager"
HOMEPAGE="http://github.com/JuliaPy/pyjuliapkg"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/semver[${PYTHON_USEDEP}]
	dev-python/filelock[${PYTHON_USEDEP}]
	dev-python/tomlkit[${PYTHON_USEDEP}]
	dev-python/tomli[${PYTHON_USEDEP}]
	dev-lang/julia-bin
"

# Tests require network access
RESTRICT="test"
