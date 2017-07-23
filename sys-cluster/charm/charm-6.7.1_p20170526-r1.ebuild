# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Modified by wthrowe for SpECTRE - 2017

EAPI=5

FORTRAN_STANDARD="90"
PYTHON_COMPAT=( python2_7 )

inherit eutils flag-o-matic fortran-2 multilib multiprocessing python-any-r1 toolchain-funcs autotools multilib-minimal

MY_P=${P%_p*}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Message-passing parallel language and runtime system"
HOMEPAGE="http://charm.cs.uiuc.edu/"
SRC_URI="http://charm.cs.uiuc.edu/distrib/${MY_P}.tar.gz"

LICENSE="charm"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="charmdebug charmtracing charmproduction cmkopt doc examples mlogft mpi ampi numa smp static-libs syncft tcp"

RDEPEND="
	sys-libs/zlib[${MULTILIB_USEDEP}]
	mpi? ( virtual/mpi[${MULTILIB_USEDEP}] )
	numa? ( sys-process/numactl[${MULTILIB_USEDEP}] )"
DEPEND="
	${RDEPEND}
	doc? (
		>=app-text/poppler-0.12.3-r3[utils]
		dev-tex/latex2html
		virtual/tex-base
		$(python_gen_any_dep '
			>=dev-python/beautifulsoup-4[${PYTHON_USEDEP}]
			dev-python/lxml[${PYTHON_USEDEP}]
		')
		media-libs/netpbm
		${PYTHON_DEPS}
	)"

REQUIRED_USE="
	cmkopt? ( !charmdebug !charmtracing )
	charmproduction? ( !charmdebug !charmtracing )"

pkg_setup() {
	use doc && python-any-r1_pkg_setup
}

get_opts() {
	local CHARM_OPTS

	# TCP instead of default UDP for socket comunication
	# protocol
	CHARM_OPTS+="$(usex tcp ' tcp' '')"

	# enable direct SMP support using shared memory
	CHARM_OPTS+="$(usex smp ' smp' '')"

	CHARM_OPTS+="$(usex mlogft ' mlogft' '')"
	CHARM_OPTS+="$(usex syncft ' syncft' '')"

	# Build shared libraries by default.
	CHARM_OPTS+=" --build-shared"

	if use charmproduction; then
		CHARM_OPTS+=" --with-production"
	else
		if use charmdebug; then
			CHARM_OPTS+=" --enable-charmdebug"
		fi

		if use charmtracing; then
			CHARM_OPTS+=" --enable-tracing --enable-tracing-commthread"
		fi
	fi

	CHARM_OPTS+="$(usex numa ' --with-numa' '')"
	echo $CHARM_OPTS
}

src_prepare() {
	sed \
		-e "/CMK_CF77/s:[fg]77:$(usex mpi "mpif90" "$(tc-getF77)"):g" \
		-e "/CMK_CF90/s:f95:$(usex mpi "mpif90" "$(tc-getFC)"):g" \
		-e "/CMK_CF90/s:\`which f90.*$::g" \
		-e "/CMK_CXX/s:g++:$(usex mpi "mpic++" "$(tc-getCXX)"):g" \
		-e "/CMK_CC/s:gcc:$(usex mpi "mpicc" "$(tc-getCC)"):g" \
		-e '/CMK_F90_MODINC/s:-p:-I:g' \
		-i src/arch/$(usex mpi "mpi" "net")*-linux*/*sh || die
	sed \
		-e "/CMK_CF90/s:gfortran:$(usex mpi "mpif90" "$(tc-getFC)"):g" \
		-e "/F90DIR/s:gfortran:$(usex mpi "mpif90" "$(tc-getFC)"):g" \
		-e "/f95target/s:gfortran:$(usex mpi "mpif90" "$(tc-getFC)"):g" \
		-e "/f95version/s:gfortran:$(usex mpi "mpif90" "$(tc-getFC)"):g" \
		-i src/arch/common/*.sh || die

	# CMK optimization
	use cmkopt && append-cppflags -DCMK_OPTIMIZE=1

	# Fix QA notice. Filed report with upstream.
	append-cflags -DALLOCA_H

	# Disable library autodetection
	pushd src/scripts >/dev/null || die

	sed -e 's/test_link .*libjpeg/pass=0;fail=1 # &/' \
		-i configure.in || die

	eautoreconf

	popd >/dev/null || die
}

multilib_src_compile() {
	export USER_OPTS_CC="${CFLAGS}"
	export USER_OPTS_CXX="${CXXFLAGS}"
	export USER_OPTS_LD="${LDFLAGS}"
	export USER_OPTS_LDXX="${LDFLAGS}"

	local build_suffix
	case "${MULTILIB_ABI_FLAG}" in
		abi_x86_64) build_suffix="-amd64" ;;
		*) build_suffix="" ;;
	esac
	local build_version="$(usex mpi "mpi" "net")-linux${build_suffix}"
	local build_options="$(get_opts)"
	#build only accepts -j from MAKEOPTS
	local build_commandline="${build_version} ${build_options} -j$(makeopts_jobs) --destination=$(pwd)"

	cd "${S}"
	# Build charmm++ first.
	einfo "running ./build charm++ ${build_commandline}"
	./build charm++ ${build_commandline} || die "Failed to build charm++"

	if use ampi; then
		einfo "running ./build AMPI ${build_commandline}"
		./build AMPI ${build_commandline} || die "Failed to build charm++"
	fi

	# make pdf/html docs
	if multilib_is_native_abi && use doc; then
		emake -j1 -C doc/charm++
	fi
}

multilib_src_test() {
	make -C tests/charm++ test TESTOPTS="++local" || die
}

src_install() {
	# Make charmc play well with gentoo before we move it into /usr/bin. This
	# patch cannot be applied during src_prepare() because the charmc wrapper
	# is used during building.
	epatch "${FILESDIR}/charm-6.5.1-charmc-gentoo.patch"

	# SpECTRE patch
	epatch "${FILESDIR}/spectre-${PV##*_p}.patch"

	multilib_src_install() {
		pushd "${BUILD_DIR}" >/dev/null || die

		# Break symlink to source directory
		cp --remove-destination "$(readlink -e bin/charmc)" bin/charmc || die

		sed -e "s|gentoo-include|${PN}-${MULTILIB_ABI_FLAG}|" \
			-e "s|gentoo-libdir|$(get_libdir)|g" \
			-e "s|VERSION|${PN}-${MULTILIB_ABI_FLAG}/VERSION|" \
			-i bin/charmc || die "failed patching charmc script"

		local charmbin=/usr/libexec/${PN}-${MULTILIB_ABI_FLAG}
		sed -e "s|findCharmBin() {|& CHARMBIN=${charmbin}|" \
			-i bin/charmc || die

		# In the following, some of the files are symlinks to ../tmp which we need
		# to dereference first (see bug 432834).

		local i

		# Install binaries.
		exeinto "${charmbin}"
		doexe bin/charmc
		doexe bin/charmd{,_faceless}
		doexe bin/charmxi
		doexe bin/conv-cpm
		# Disable spying
		newexe bin/charmrun-silent charmrun

		for i in charmc charmd{,_faceless} charmrun ; do
			dosym "../..${charmbin}/${i}" /usr/bin/${CHOST}-${i}
			multilib_is_native_abi && dosym ${CHOST}-${i} /usr/bin/${i}
		done

		# Install headers.
		insinto /usr/include/${PN}-${MULTILIB_ABI_FLAG}
		for i in include/*; do
			if [[ -L ${i} ]]; then
				i=$(readlink -e "${i}") || die
			fi
			doins "${i}"
		done

		# Install libs incl. charm objects
		for i in lib*/*.{so,a}; do
			[[ ${i} = *.a ]] && use !static-libs && continue
			if [[ -L ${i} ]]; then
				i=$(readlink -e "${i}") || die
			fi
			[[ ${i} = *.so ]] && dolib.so "${i}" || dolib "${i}"
		done

		popd >/dev/null || die
	}
	multilib_foreach_abi multilib_src_install

	# Basic docs.
	dodoc CHANGES README

	# Install examples.
	if use examples; then
		find examples/ -name 'Makefile' | xargs sed \
			-r "s:(../)+bin/charmc:/usr/bin/charmc:" -i || \
			die "Failed to fix examples"
		find examples/ -name 'Makefile' | xargs sed \
			-r "s:./charmrun:./charmrun ++local:" -i || \
			die "Failed to fix examples"
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/charm++/*
		docompress -x /usr/share/doc/${PF}/examples
	fi

	# Install pdf/html docs
	if use doc; then
		cd "${S}/doc/charm++"
		# Install pdfs.
		insinto /usr/share/doc/${PF}/pdf
		doins  *.pdf
		# Install html.
		docinto html
		dohtml -r manual/*
	fi
}

pkg_postinst() {
	einfo "Please test your charm installation by copying the"
	einfo "content of /usr/share/doc/${PF}/examples to a"
	einfo "temporary location and run 'make test'."
}
