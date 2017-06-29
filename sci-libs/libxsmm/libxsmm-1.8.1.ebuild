# Copyright 2017 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils multilib toolchain-funcs

DESCRIPTION="A library for small matrix-matrix multiplications and small convolutions"
HOMEPAGE="https://github.com/hfp/libxsmm"
SRC_URI="https://github.com/hfp/libxsmm/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE_CPUFLAGS=( cpu_flags_x86_{avx2,avx,sse4_2,sse3} )
IUSE="${IUSE_CPUFLAGS[*]} +blas static-libs"

RDEPEND="blas? ( virtual/blas )"
DEPEND="${RDEPEND}"

src_prepare() {
	# Respect *FLAGS
	sed -i -e '/^\(C\|CXX\|FC\)FLAGS :\?=/s/^/#/' Makefile || die
	# Don't rebuild the entire package in src_install
	sed -i -e 's/^\(install-minimal:\).*/\1/' Makefile || die

	eapply_user
}

src_configure() {
	local AVX SSE

	# The package also supports AVX=3 for avx512f, but there's no flag
	# for that at the moment.
	if use cpu_flags_x86_avx2 ; then
		AVX=2
	elif use cpu_flags_x86_avx ; then
		AVX=1
	else
		AVX=0
	fi

	if use cpu_flags_x86_sse4_2 ; then
		SSE=4
	elif use cpu_flags_x86_sse3 ; then
		SSE=3
	else
		SSE=0
	fi

	OPTIONS=(
		CC=$(tc-getCC)
		CXX=$(tc-getCXX)
		FC=$(tc-getFC)
		OPTFLAG=
		AVX=${AVX}
		SSE=${SSE}
		BLAS=$(usex blas 1 0)
	)
}

src_compile() {
	emake STATIC=0 "${OPTIONS[@]}"
	if use static-libs ; then
		emake STATIC=1 "${OPTIONS[@]}"
	fi
}

src_test() {
	# This rebuilds the package for some reason, and fails in parallel.
	# It's not obvious to me why.
	emake -j1 STATIC=0 "${OPTIONS[@]}" test-all
	if use static-libs ; then
		emake -j1 STATIC=1 "${OPTIONS[@]}" test-all
	fi
}

src_install() {
	emake INSTALL_ROOT="${D}/usr" POUTDIR="$(get_libdir)" install-minimal
}
