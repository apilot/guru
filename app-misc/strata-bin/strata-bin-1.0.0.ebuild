# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

DESCRIPTION="A fast, keyboard-first file manager for Linux"
HOMEPAGE="https://stratafiles.io/ https://github.com/lgse/strata/"
SRC_URI="
	amd64? ( https://github.com/lgse/strata/releases/download/v${PV}/strata-${PV}-x86_64-unknown-linux-gnu.tar.gz )
	arm64? ( https://github.com/lgse/strata/releases/download/v${PV}/strata-${PV}-aarch64-unknown-linux-gnu.tar.gz )
"

LICENSE="MIT unrar"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"

# Only the binary's direct NEEDED libraries plus runtime services.
# Transitive sonames (icu, gnutls, leancrypto, wayland, X11) arrive via
# the dependency tree of the packages below.
RDEPEND="
	app-text/poppler[glib]
	gnome-base/gvfs
	>=gui-libs/gtk-4.12:4
	gui-libs/gtksourceview:5
	media-libs/fontconfig
	>=media-libs/gst-plugins-base-1.20:1.0
	>=media-libs/gstreamer-1.20:1.0
	>=sys-libs/glibc-2.39
	sys-apps/bubblewrap
"

QA_PREBUILT="usr/bin/strata"

case ${ARCH} in
	amd64) S="${WORKDIR}/strata-${PV}-x86_64-unknown-linux-gnu" ;;
	arm64) S="${WORKDIR}/strata-${PV}-aarch64-unknown-linux-gnu" ;;
	*) die "unsupported ARCH: ${ARCH}" ;;
esac

src_install() {
	dobin strata

	insinto /usr/share/applications
	doins io.github.lgse.Strata.desktop

	insinto /usr/share/icons/hicolor/scalable/apps
	doins io.github.lgse.Strata.svg

	# Opt-in templates only, per upstream packaging policy: never install
	# the D-Bus service into a system services directory and never
	# activate the xdg-desktop-portal backend automatically.
	insinto /usr/share/strata
	doins io.github.lgse.Strata.FileManager1.service
	doins -r portal udiskie

	einstalldocs
	dodoc LICENSE UnRAR.txt THIRD_PARTY_LICENSES.md docs/portal-file-chooser.md
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Updates are managed by Portage. Do not use the in-app updater (Settings -> Updates)."
	elog
	elog "To make Strata the D-Bus activatable handler of org.freedesktop.FileManager1 (opt-in):"
	elog "  mkdir -p ~/.local/share/dbus-1/services"
	elog "  cp ${EROOT}/usr/share/strata/io.github.lgse.Strata.FileManager1.service \\"
	elog "      ~/.local/share/dbus-1/services/"
	elog
	elog "Optional preview/media support: media-video/ffmpeg, media-video/ffmpegthumbnailer,"
	elog "media-plugins/gst-plugins-good, media-plugins/gst-plugins-libav,"
	elog "media-gfx/imagemagick, media-libs/libraw, sys-fs/squashfs-tools"
}
