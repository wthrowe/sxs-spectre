# Copyright 2026 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Julia and Python in seamless harmony"
HOMEPAGE="https://github.com/JuliaPy/PythonCall.jl"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/juliapkg[${PYTHON_USEDEP}]
"

# Tests require network access
RESTRICT="test"
