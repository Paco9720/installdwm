#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# dwm - instalación limpia para Debian 13
# ============================================================

DWM_DIR="$HOME/.local/src/dwm"
BIN_DIR="$HOME/.local/bin"
DWM_CONFIG_DIR="$HOME/.config/dwm"
SESSION_FILE="/usr/share/xsessions/dwm.desktop"

echo
echo "=========================================="
echo "       Instalación de dwm para Debian"
echo "=========================================="
echo

# ------------------------------------------------------------
# Dependencias
# ------------------------------------------------------------

echo "==> Instalando dependencias..."

sudo apt update

sudo apt install -y \
  build-essential \
  git \
  libx11-dev \
  libxinerama-dev \
  libxft-dev \
  fonts-jetbrains-mono \
  kitty \
  rofi \
  dunst \
  feh \
  brightnessctl \
  pamixer \
  gnome-screenshot

# ------------------------------------------------------------
# Directorios
# ------------------------------------------------------------

echo
echo "==> Creando directorios..."

mkdir -p "$HOME/.local/src"
mkdir -p "$BIN_DIR"
mkdir -p "$DWM_CONFIG_DIR"

# ------------------------------------------------------------
# Clonar dwm
# ------------------------------------------------------------

echo
echo "==> Preparando código fuente de dwm..."

if [ ! -d "$DWM_DIR/.git" ]; then
  git clone https://git.suckless.org/dwm "$DWM_DIR"
else
  echo "El repositorio de dwm ya existe."
  echo "No se actualizará automáticamente."
fi

cd "$DWM_DIR"

# ------------------------------------------------------------
# Backup de config.h si ya existe
# ------------------------------------------------------------

if [ -f config.h ]; then
  BACKUP="config.h.backup.$(date +%Y%m%d-%H%M%S)"
  echo "==> Guardando configuración anterior en $BACKUP"
  cp config.h "$BACKUP"
fi

# ------------------------------------------------------------
# config.h
# ------------------------------------------------------------

echo
echo "==> Creando config.h..."

cat >config.h <<'EOF'
/* See LICENSE file for copyright and license details. */

/*
 * dwm - configuración personal
 *
 * Terminal: Kitty
 * Launcher: Rofi
 * Font: JetBrains Mono
 * Barra: dwm
 */

#include <unistd.h>

/* appearance */
static const unsigned int borderpx  = 1;
static const unsigned int snap      = 32;
static const int showbar            = 1;
static const int topbar             = 1;

static const char *fonts[] = {
	"JetBrains Mono:size=10"
};

static const char dmenufont[] = "JetBrains Mono:size=10";

/* colors */
static const char col_gray1[] = "#222222";
static const char col_gray2[] = "#444444";
static const char col_gray3[] = "#bbbbbb";
static const char col_gray4[] = "#eeeeee";
static const char col_cyan[]  = "#005577";

static const char *colors[][3] = {
	[SchemeNorm] = {
		col_gray3,
		col_gray1,
		col_gray2
	},

	[SchemeSel] = {
		col_gray4,
		col_cyan,
		col_cyan
	},
};

/* tags */
static const char *tags[] = {
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"0"
};

/* rules */
static const Rule rules[] = {
	/* class      instance   title   tags mask   isfloating   monitor */
	{ "Gimp",     NULL,      NULL,   0,          0,            -1 },
};

/* layout */
static const float mfact     = 0.55;
static const int nmaster     = 1;
static const int resizehints = 1;

static const Layout layouts[] = {
	/* symbol   arrange */
	{ "[]=",     tile },
	{ "><>",     NULL },
	{ "[M]",     monocle },
};

/* modifier */
#define MODKEY Mod4Mask

#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY, view,       {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY, toggleview, {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY, tag,        {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY, toggletag,  {.ui = 1 << TAG} },

#define SHCMD(cmd) \
	{ .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/*
 * ============================================================
 * Reiniciar dwm
 * ============================================================
 *
 * /proc/self/exe apunta al dwm que se está ejecutando.
 *
 * De esta manera Super+Alt+R reemplaza el proceso de dwm
 * por una nueva instancia sin volver a ejecutar autostart.
 */
static void
restartwm(const Arg *arg)
{
	char *const argv[] = {
		"/proc/self/exe",
		NULL
	};

	(void)arg;

	execv("/proc/self/exe", argv);
}

/*
 * ============================================================
 * Tag anterior
 * ============================================================
 */
static void
viewprevtag(const Arg *arg)
{
	unsigned int tag = selmon->tagset[selmon->seltags];

	(void)arg;

	if (tag == 1)
		tag = 1 << 9;
	else
		tag >>= 1;

	view(&(Arg){ .ui = tag });
}

/*
 * ============================================================
 * Tag siguiente
 * ============================================================
 */
static void
viewnexttag(const Arg *arg)
{
	unsigned int tag = selmon->tagset[selmon->seltags];

	(void)arg;

	if (tag == (1 << 9))
		tag = 1;
	else
		tag <<= 1;

	view(&(Arg){ .ui = tag });
}

/*
 * ============================================================
 * Fullscreen real
 * ============================================================
 *
 * dwm ya posee setfullscreen() internamente.
 * Esta función simplemente alterna el estado fullscreen
 * de la ventana actualmente seleccionada.
 */
static void
togglefullscr(const Arg *arg)
{
	if (!selmon->sel)
		return;

	setfullscreen(selmon->sel, !selmon->sel->isfullscreen);

	(void)arg;
}

/* comandos */
static const char *termcmd[] = {
	"kitty",
	NULL
};

/* teclas */
static Key keys[] = {

	/* ========================================================
	 * Programas
	 * ======================================================== */

	{ MODKEY, XK_Return,
		spawn, {.v = termcmd} },

	{ MODKEY, XK_space,
		spawn, SHCMD("rofi -show drun") },


	/* ========================================================
	 * Brillo
	 * ======================================================== */

	{ 0, XF86XK_MonBrightnessDown,
		spawn, SHCMD("brightnessctl set 10%-") },

	{ 0, XF86XK_MonBrightnessUp,
		spawn, SHCMD("brightnessctl set +10%") },

	{ MODKEY, XK_F11,
		spawn, SHCMD("brightnessctl set 10%-") },

	{ MODKEY, XK_F12,
		spawn, SHCMD("brightnessctl set +10%") },


	/* ========================================================
	 * Volumen
	 * ======================================================== */

	{ 0, XF86XK_AudioRaiseVolume,
		spawn, SHCMD("pamixer --increase 5") },

	{ 0, XF86XK_AudioLowerVolume,
		spawn, SHCMD("pamixer --decrease 5") },

	{ 0, XF86XK_AudioMute,
		spawn, SHCMD("pamixer -t") },

	{ MODKEY, XK_F3,
		spawn, SHCMD("pamixer --increase 5") },

	{ MODKEY, XK_F2,
		spawn, SHCMD("pamixer --decrease 5") },


	/* ========================================================
	 * Ventanas
	 * ======================================================== */

	/* cerrar ventana */
	{ MODKEY, XK_q,
		killclient, {0} },

	{ MODKEY|ShiftMask, XK_q,
		killclient, {0} },


	/* ventana anterior / siguiente */
	{ MODKEY, XK_Left,
		focusstack, {.i = -1} },

	{ MODKEY, XK_Right,
		focusstack, {.i = +1} },


	/* ========================================================
	 * Master
	 * ======================================================== */

	{ MODKEY, XK_Up,
		setmfact, {.f = +0.05} },

	{ MODKEY, XK_Down,
		setmfact, {.f = -0.05} },


	/* ========================================================
	 * Layouts
	 * ======================================================== */

	/* tiled */
	{ MODKEY, XK_t,
		setlayout, {.v = &layouts[0]} },

	/* floating */
	{ MODKEY, XK_s,
		togglefloating, {0} },

	/* fullscreen real */
	{ MODKEY, XK_f,
		togglefullscr, {0} },

	/* siguiente layout */
	{ MODKEY, XK_m,
		setlayout, {.v = NULL} },


	/* ========================================================
	 * Tags
	 * ======================================================== */

	/* tag anterior */
	{ MODKEY|Mod1Mask, XK_Left,
		viewprevtag, {0} },

	/* tag siguiente */
	{ MODKEY|Mod1Mask, XK_Right,
		viewnexttag, {0} },

	/* último tag */
	{ MODKEY, XK_Tab,
		view, {.ui = 0} },


	/* ========================================================
	 * dwm
	 * ======================================================== */

	/* salir */
	{ MODKEY|Mod1Mask, XK_e,
		quit, {0} },

	/* reiniciar */
	{ MODKEY|Mod1Mask, XK_r,
		restartwm, {0} },


	/* ========================================================
	 * Captura
	 * ======================================================== */

	{ 0, XK_Print,
		spawn, SHCMD("gnome-screenshot -i") },


	/* ========================================================
	 * Tags 1-9 y 0
	 * ======================================================== */

	TAGKEYS(XK_1, 0)
	TAGKEYS(XK_2, 1)
	TAGKEYS(XK_3, 2)
	TAGKEYS(XK_4, 3)
	TAGKEYS(XK_5, 4)
	TAGKEYS(XK_6, 5)
	TAGKEYS(XK_7, 6)
	TAGKEYS(XK_8, 7)
	TAGKEYS(XK_9, 8)
	TAGKEYS(XK_0, 9)
};


/* mouse */
static Button buttons[] = {

	{ ClkLtSymbol, 0, Button1,
		setlayout, {0} },

	{ ClkLtSymbol, 0, Button3,
		setlayout, {.v = &layouts[2]} },

	{ ClkStatusText, 0, Button2,
		spawn, {.v = termcmd} },

	{ ClkClientWin, MODKEY, Button1,
		movemouse, {0} },

	{ ClkClientWin, MODKEY, Button3,
		resizemouse, {0} },

	{ ClkTagBar, 0, Button1,
		view, {0} },

	{ ClkTagBar, 0, Button3,
		toggleview, {0} },

	{ ClkTagBar, MODKEY, Button1,
		tag, {0} },

	{ ClkTagBar, MODKEY, Button3,
		toggletag, {0} },
};
EOF

# ------------------------------------------------------------
# Compilar
# ------------------------------------------------------------

echo
echo "==> Compilando dwm..."

make clean
make

# ------------------------------------------------------------
# Instalar
# ------------------------------------------------------------

echo
echo "==> Instalando dwm..."

install -Dm755 dwm "$BIN_DIR/dwm"

# ------------------------------------------------------------
# Autostart
# ------------------------------------------------------------

echo
echo "==> Creando autostart..."

cat >"$DWM_CONFIG_DIR/autostart.sh" <<'EOF'
#!/bin/sh

# Tema GTK
export GTK_THEME="Adwaita-dark"

# Tema Qt
export QT_QPA_PLATFORMTHEME="qt6ct"

# Variables de la sesión
export XDG_CURRENT_DESKTOP="dwm"
export XDG_SESSION_DESKTOP="dwm"
export XDG_SESSION_TYPE="x11"

# D-Bus / systemd --user
systemctl --user import-environment \
    DISPLAY \
    XAUTHORITY \
    XDG_CURRENT_DESKTOP \
    XDG_SESSION_DESKTOP \
    XDG_SESSION_TYPE \
    2>/dev/null || true

dbus-update-activation-environment --systemd \
    DISPLAY \
    XAUTHORITY \
    XDG_CURRENT_DESKTOP \
    XDG_SESSION_DESKTOP \
    XDG_SESSION_TYPE \
    2>/dev/null || true

# Fondo
feh --bg-fill "/mnt/sda1/pictures/Unverse.png" &

# Notificaciones
dunst &

EOF

chmod +x "$DWM_CONFIG_DIR/autostart.sh"

# ------------------------------------------------------------
# Sesión dwm para LightDM
# ------------------------------------------------------------

echo
echo "==> Creando sesión de LightDM..."

sudo mkdir -p /usr/share/xsessions

sudo tee "$SESSION_FILE" >/dev/null <<EOF
[Desktop Entry]
Name=dwm
Comment=Dynamic Window Manager
Exec=$DWM_CONFIG_DIR/dwm-session
TryExec=$BIN_DIR/dwm
Type=Application
DesktopNames=dwm
EOF

# ------------------------------------------------------------
# Wrapper de sesión
# ------------------------------------------------------------

cat >"$DWM_CONFIG_DIR/dwm-session" <<EOF
#!/bin/sh

export PATH="$BIN_DIR:\$PATH"

export XDG_CURRENT_DESKTOP="dwm"
export XDG_SESSION_DESKTOP="dwm"
export XDG_SESSION_TYPE="x11"

"$DWM_CONFIG_DIR/autostart.sh"

exec "$BIN_DIR/dwm"
EOF

chmod +x "$DWM_CONFIG_DIR/dwm-session"

# ------------------------------------------------------------
# Resultado
# ------------------------------------------------------------

echo
echo "=========================================="
echo "       dwm instalado correctamente"
echo "=========================================="
echo
echo "Repositorio:"
echo "  $DWM_DIR"
echo
echo "Ejecutable:"
echo "  $BIN_DIR/dwm"
echo
echo "Configuración:"
echo "  $DWM_DIR/config.h"
echo
echo "Autostart:"
echo "  $DWM_CONFIG_DIR/autostart.sh"
echo
echo "Sesión:"
echo "  $SESSION_FILE"
echo
echo "Selecciona 'dwm' desde LightDM."
echo
echo "No se instalaron:"
echo "  bspwm"
echo "  sxhkd"
echo "  polybar"
echo "  picom"
echo "  dmenu"
echo
echo "=========================================="
