# Copyright 2017 William Throwe
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils toolchain-funcs multilib-minimal

DESCRIPTION="A library for small matrix-matrix multiplications and small convolutions"
HOMEPAGE="https://github.com/hfp/libxsmm"
SRC_URI="https://github.com/hfp/libxsmm/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE_CPUFLAGS=( cpu_flags_x86_{avx2,avx,sse4_2,sse3} )
IUSE="${IUSE_CPUFLAGS[*]} +blas static-libs"

RDEPEND="blas? ( virtual/blas[${MULTILIB_USEDEP}] )"
DEPEND="${RDEPEND}"

src_prepare() {
	# Respect *FLAGS
	sed -i -e '/^\(C\|CXX\|FC\)FLAGS :\?=/s/^/#/' Makefile || die

	eapply "${FILESDIR}/Fix-linking-error-on-32-bit.patch"

	eapply_user

	multilib_copy_sources
}

multilib_src_compile() {
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
		FC= # Disable fortran
		OPTFLAG=
		AVX=${AVX}
		SSE=${SSE}
		BLAS=$(usex blas 1 0)
	)

	emake STATIC=0 "${OPTIONS[@]}"
	if use static-libs ; then
		emake STATIC=1 "${OPTIONS[@]}"
	fi
}

multilib_src_test() {
	# This rebuilds the package for some reason, and fails in parallel.
	# It's not obvious to me why.
	emake -j1 STATIC=0 "${OPTIONS[@]}" test-all
	if use static-libs ; then
		emake -j1 STATIC=1 "${OPTIONS[@]}" test-all
	fi
}

multilib_src_install() {
	# Upstream's install converts all their library symlinks into copies
	dolib lib/*
	doheader include/*
	multilib_is_native_abi && dobin bin/*
}
