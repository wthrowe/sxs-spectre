# Copyright 2026 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
# sci-ml/pytorch is single-impl, so this has to be too
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="A highly efficient implementation of Gaussian Processes in PyTorch"
HOMEPAGE="https://gpytorch.ai/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	sci-ml/pytorch[${PYTHON_SINGLE_USEDEP}]
	sci-ml/linear-operator[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/mpmath[${PYTHON_USEDEP}]
		dev-python/scikit-learn[${PYTHON_USEDEP}]
		dev-python/scipy[${PYTHON_USEDEP}]
	')
"
BDEPEND="${PYTHON_DEPS}"

distutils_enable_tests pytest
