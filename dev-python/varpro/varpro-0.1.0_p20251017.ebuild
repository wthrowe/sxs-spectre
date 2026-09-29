# Copyright 2026 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="Multiparameter fitting using the variable projection algorithm"
HOMEPAGE="https://github.com/sxs-collaboration/varpro"

COMMIT_HASH=978106eaf3d7a6a7f0c5f167726d8e0fc59fc95d
SRC_URI="https://github.com/sxs-collaboration/${PN}/archive/${COMMIT_HASH}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${COMMIT_HASH}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/scipy[${PYTHON_USEDEP}]
"

distutils_enable_tests import-check
