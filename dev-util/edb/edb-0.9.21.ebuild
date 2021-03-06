# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils

DESCRIPTION="edb is a cross platform x86/x86-64 debugger, inspired by Ollydbg"
HOMEPAGE="https://github.com/eteran/edb-debugger"

LICENSE="GPL-2"
IUSE="graphviz legacy-mem-write pax_kernel"
SLOT="0"

if [[ ${PV} == "9999" ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/eteran/edb-debugger.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/eteran/edb-debugger/releases/download/${PV}/edb-debugger-${PV}.tgz"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}"/edb-debugger-${PV}
fi

RDEPEND="
	>=dev-libs/capstone-3.0
	graphviz? ( >=media-gfx/graphviz-2.38.0 )
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
	dev-qt/qtxmlpatterns:5
	dev-qt/qtnetwork:5
	dev-qt/qtconcurrent:5
	dev-qt/qtgui:5
	dev-qt/qtcore:5
	"
DEPEND="
	>=dev-libs/boost-1.35.0
	${RDEPEND}"

src_prepare(){
	if ! use graphviz; then
		sed -i '/pkg_check_modules(GRAPHVIZ/d' CMakeLists.txt
	fi
	eapply_user
}

src_configure() {
	mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DQT_VERSION=Qt5
	)
	if use pax_kernel || use legacy-mem-write; then
		mycmakeargs+=( -DASSUME_PROC_PID_MEM_WRITE_BROKEN=Yes )
	else
		mycmakeargs+=( -DASSUME_PROC_PID_MEM_WRITE_BROKEN=No )
	fi

	cmake-utils_src_configure
}

pkg_postinst() {
	if use legacy-mem-write; then
		ewarn "You really do not want to turn on legacy-mem-write unless you need it."
		ewarn "Be sure to test without legacy-mem-write first and only enable if you actually need it."
	else
		ewarn
		ewarn "If you notice that EDB doesn't work correctly, enable legacy-mem-write USE Flag"
		ewarn "Please Report Bugs & Requests At: https://github.com/eteran/edb-debugger/issues"
		ewarn
	fi
}
