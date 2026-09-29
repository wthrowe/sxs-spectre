# Copyright 2026 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
# sci-ml/{,g}pytorch is single-impl, so this has to be too
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="Support for SpEC and SpECTRE simulations"
HOMEPAGE="https://github.com/sxs-collaboration/SimulationSupport"

COMMIT_HASH=0b73ea057a6a8915e57cfc37a7c8cb0630a834ad
SRC_URI="https://github.com/sxs-collaboration/${PN}/archive/${COMMIT_HASH}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${COMMIT_HASH}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
		dev-python/matplotlib[${PYTHON_USEDEP}]
		dev-python/pandas[${PYTHON_USEDEP}]
		dev-python/sxs[${PYTHON_USEDEP}]
		~dev-python/varpro-0.1.0_p20251017[${PYTHON_USEDEP}]
		dev-python/click[${PYTHON_USEDEP}]
		dev-python/rich[${PYTHON_USEDEP}]
	')
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	sci-ml/gpytorch[${PYTHON_SINGLE_USEDEP}]
"
BDEPEND="${PYTHON_DEPS}"

distutils_enable_tests pytest
