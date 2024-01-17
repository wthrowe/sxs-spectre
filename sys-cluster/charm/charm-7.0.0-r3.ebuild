# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# Copyright 2017-2024 William Throwe

EAPI=8

FORTRAN_STANDARD="90"

inherit flag-o-matic fortran-2 multiprocessing toolchain-funcs

MY_PV=${PV/_/-}

DESCRIPTION="Message-passing parallel language and runtime system"
HOMEPAGE="http://charm.cs.uiuc.edu/"
SRC_URI="https://github.com/UIUC-PPL/charm/archive/refs/tags/v${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="charm"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="charmdebug charmtracing cmkopt examples mlogft mpi numa smp static-libs syncft tcp udp"

RDEPEND="mpi? ( virtual/mpi )"
# The build system uses autotools internally in unusual ways
DEPEND="
	${RDEPEND}
	dev-build/autoconf
	dev-build/automake
	dev-build/cmake
	"

REQUIRED_USE="?? ( tcp udp )"

S=${WORKDIR}/${PN}-${MY_PV}

get_opts() {
	local CHARM_OPTS

	if use mpi || use tcp || use udp ; then
		# TCP instead of default UDP for socket communication
		# protocol
		CHARM_OPTS+="$(usex tcp ' tcp' '')"

		# enable direct SMP support using shared memory
		CHARM_OPTS+="$(usex smp ' smp' '')"
	fi

	CHARM_OPTS+="$(usex mlogft ' mlogft' '')"
	CHARM_OPTS+="$(usex syncft ' syncft' '')"

	# Build shared libraries by default.
	CHARM_OPTS+=" --build-shared"

	use charmdebug && CHARM_OPTS+=" --enable-charmdebug"
	use charmtracing && \
		CHARM_OPTS+=" --enable-tracing --enable-tracing-commthread"

	CHARM_OPTS+="$(usex numa ' --with-numa' '')"
	echo $CHARM_OPTS
}

src_prepare() {
	local f77="$(usex mpi "mpif90" "$(tc-getF77)") ${FCFLAGS}"
	local f90="$(usex mpi "mpif90" "$(tc-getFC)") ${FCFLAGS}"
	local whichpat='`which .*`\|$(which .*)'
	sed \
		-e "/CMK_CF77=/s:[fg]77:${f77}:g" \
		-e "/CMK_CF77=/s:${whichpat}:\`echo ${f77}\`:" \
		-e "/CMK_CF90=/s:f95:${f90}:g" \
		-e "/CMK_CF90=/s:gfortran:${f90}:g" \
		-e "/CMK_CF90=/s:${whichpat}:\`echo ${f90}\`:" \
		-e '/-z $CMK_CF90/d' \
		-e "/CMK_CXX=/s:g++:$(usex mpi "mpic++" "$(tc-getCXX)"):g" \
		-e "/CMK_CC=/s:gcc:$(usex mpi "mpicc" "$(tc-getCC)"):g" \
		-e '/CMK_F90_MODINC=/s:-p:-I:g' \
		-e "/F90DIR=/s:gfortran:${f90}:g" \
		-e "/f95target=/s:gfortran:${f90}:g" \
		-e "/f95version=/s:gfortran:${f90}:g" \
		-i src/arch/*-linux*/*sh src/arch/common/*.sh || die

	# CMK optimization
	use cmkopt && append-cppflags -DCMK_OPTIMIZE=1

	eapply "${FILESDIR}/charm-7.0.0-dont-read-builddir.patch"
	# The upstream behavior is necessary for AMPI, but we don't build
	# that, and it breaks dlopening charm libraries.
	eapply "${FILESDIR}/charm-7.0.0-no-ftls-model.patch"

	eapply "${FILESDIR}/charm-7.0.0-c++20.patch"
	eapply "${FILESDIR}/charm-7.0.0-unrecognized-pupid-hint.patch"

	eapply_user
}

src_compile() {
	export USER_OPTS_CC="${CPPFLAGS} ${CFLAGS}"
	export USER_OPTS_CXX="${CPPFLAGS} ${CXXFLAGS}"
	export USER_OPTS_LD="${LDFLAGS}"

	local build_version
	if use mpi ; then
		build_version=mpi
	elif use tcp || use udp ; then
		build_version=netlrts
	else
		build_version=multicore
	fi
	build_version+="-linux"
	use amd64 && build_version+="-x86_64"

	local build_options="$(get_opts)"
	#build only accepts -j from MAKEOPTS
	local build_commandline="${build_version} ${build_options} -j$(makeopts_jobs)"

	einfo "running ./build LIBS ${build_commandline}"
	./build LIBS ${build_commandline} || die "Failed to build LIBS"
}

src_test() {
	make -C tests/charm++ test TESTOPTS="++local" || die
}

src_install() {
	# Make charmc play well with gentoo before we move it into /usr/bin. This
	# patch cannot be applied during src_prepare() because the charmc wrapper
	# is used during building.
	eapply "${FILESDIR}/charm-7.0.0-charmc-gentoo.patch"

	local CHARM_LIBDIR=/usr/$(get_libdir)/charm/lib
	local CHARM_LIBSODIR=/usr/$(get_libdir)/charm/lib_so

	sed -e "s|gentoo-include|${PN}|" \
		-e "s|gentoo-libdir|${CHARM_LIBDIR}|g" \
		-e "s|gentoo-libsodir|${CHARM_LIBSODIR}|g" \
		-e "s|version=.*|version=\`cat /usr/include/${PN}/VERSION\`|" \
		-i bin/charmc || die "failed patching charmc script"

	# Install binaries.
	dobin bin/{charm*,conv-cpm}

	# Install headers.
	insinto /usr/include/${PN}
	doins -r include/*

	mkdir -p "${ED}${CHARM_LIBSODIR}" || die
	cp lib_so/* "${ED}${CHARM_LIBSODIR}" || die

	mkdir "${ED}${CHARM_LIBDIR}" || die
	if use static-libs ; then
		cp lib/* "${ED}${CHARM_LIBDIR}" || die
	else
		cp lib/*.o "${ED}${CHARM_LIBDIR}" || die
		cp lib/*.dep "${ED}${CHARM_LIBDIR}" || die
	fi

	einstalldocs

	# Install examples.
	if use examples; then
		find examples/ -name 'Makefile' | xargs sed \
			-r "s:(../)+bin/charmc:/usr/bin/charmc:" -i || \
			die "Failed to fix examples"
		find examples/ -name 'Makefile' | xargs sed \
			-r "s:./charmrun:./charmrun ++local:" -i || \
			die "Failed to fix examples"
		docinto /usr/share/doc/${PF}/examples
		dodoc -r examples/charm++/*
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
