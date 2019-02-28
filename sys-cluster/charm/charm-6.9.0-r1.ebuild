# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# Copyright 2017-2019 William Throwe

EAPI=5

FORTRAN_STANDARD="90"
PYTHON_COMPAT=( python2_7 )

inherit eutils flag-o-matic fortran-2 multilib multiprocessing python-any-r1 toolchain-funcs

DESCRIPTION="Message-passing parallel language and runtime system"
HOMEPAGE="http://charm.cs.uiuc.edu/"
SRC_URI="http://charm.cs.uiuc.edu/distrib/${P}.tar.gz"

LICENSE="charm"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="charmdebug charmtracing charmproduction cmkopt doc examples mlogft mpi ampi numa smp static-libs syncft tcp udp"

RDEPEND="mpi? ( virtual/mpi )"
# The build system uses autotools internally in unusual ways
DEPEND="
	${RDEPEND}
	sys-devel/autoconf
	sys-devel/automake
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
	)
	"

REQUIRED_USE="
	cmkopt? ( !charmdebug !charmtracing )
	charmproduction? ( !charmdebug !charmtracing )
	?? ( tcp udp )"

pkg_setup() {
	use doc && python-any-r1_pkg_setup
}

get_opts() {
	local CHARM_OPTS

	if use mpi || use tcp || use udp ; then
		# TCP instead of default UDP for socket comunication
		# protocol
		CHARM_OPTS+="$(usex tcp ' tcp' '')"

		# enable direct SMP support using shared memory
		CHARM_OPTS+="$(usex smp ' smp' '')"
	fi

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

	# Fix QA notice. Filed report with upstream.
	append-cflags -DALLOCA_H

	# Disable isomalloc.  It does stuff like decide that chunks of the
	# program's text section mapping are good places to store data
	# (particularly on 32-bit).
	append-cflags -DCMK_NO_ISO_MALLOC
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

	# Build charmm++ first.
	einfo "running ./build charm++ ${build_commandline}"
	./build charm++ ${build_commandline} || die "Failed to build charm++"

	if use ampi; then
		einfo "running ./build AMPI ${build_commandline}"
		./build AMPI ${build_commandline} || die "Failed to build charm++"
	fi

	# make pdf/html docs
	if use doc; then
		emake -j1 -C doc/charm++
	fi
}

src_test() {
	make -C tests/charm++ test TESTOPTS="++local" || die
}

src_install() {
	# Make charmc play well with gentoo before we move it into /usr/bin. This
	# patch cannot be applied during src_prepare() because the charmc wrapper
	# is used during building.
	epatch "${FILESDIR}/charm-6.5.1-charmc-gentoo.patch"

	sed -e "s|gentoo-include|${P}|" \
		-e "s|gentoo-libdir|$(get_libdir)|g" \
		-e "s|VERSION|${P}/VERSION|" \
		-i ./src/scripts/charmc || die "failed patching charmc script"

	# In the following, some of the files are symlinks to ../tmp which we need
	# to dereference first (see bug 432834).

	local i

	# Install binaries.
	for i in bin/{charm*,conv-cpm}; do
		if [[ -L ${i} ]]; then
			i=$(readlink -e "${i}") || die
		fi
		dobin "${i}"
	done

	# Install headers.
	insinto /usr/include/${P}
	for i in include/*; do
		if [[ -L ${i} ]]; then
			i=$(readlink -e "${i}") || die
		fi
		doins -r "${i}"
	done

	# Install libs incl. charm objects
	for i in lib*/*.{so,a}; do
		[[ ${i} = *.a ]] && use !static-libs && continue
		if [[ -L ${i} ]]; then
			i=$(readlink -e "${i}") || die
		fi
		[[ -s $i ]] || continue
		[[ ${i} = *.so ]] && dolib.so "${i}" || dolib.a "${i}"
	done

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
