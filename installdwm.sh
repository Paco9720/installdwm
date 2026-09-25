#!/usr/bin/env bash

set -euo pipefail

DWM_DIR="$HOME/.local/src/dwm"
BIN_DIR="$HOME/.local/bin"
AUTOSTART_DIR="$HOME/.config/dwm"
SESSION_FILE="/usr/share/xsessions/dwm.desktop"

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
  polybar \
  brightnessctl \
  pamixer \
  gnome-screenshot

echo
echo "==> Preparando directorios..."

mkdir -p "$HOME/.local/src"
mkdir -p "$BIN_DIR"
mkdir -p "$AUTOSTART_DIR"

echo
echo "==> Clonando dwm..."

if [ ! -d "$DWM_DIR/.git" ]; then
  git clone https://git.suckless.org/dwm "$DWM_DIR"
else
  echo "El repositorio de dwm ya existe:"
  echo "    $DWM_DIR"
  echo "No se actualizará automáticamente."
fi

cd "$DWM_DIR"

echo
echo "==> Creando config.h..."

if [ -f config.h ]; then
  cp config.h "config.h.backup.$(date +%Y%m%d-%H%M%S)"
fi

cat >config.h <<'EOF'
/* See LICENSE file for copyright and license details. */

/*
 * dwm configuration
 *
 * Debian 13 + LightDM
 * Terminal: Kitty
 * Launcher: Rofi
 * Bar: Polybar
 */

/* appearance */
static const unsigned int borderpx  = 1;
static const unsigned int snap      = 32;
static const int showbar            = 0;
static const int topbar             = 1;
static const char *fonts[]          = { "JetBrains Mono:size=10" };
static const char dmenufont[]       = "JetBrains Mono:size=10";

/* colors */
static const char col_gray1[]       = "#222222";
static const char col_gray2[]       = "#444444";
static const char col_gray3[]       = "#bbbbbb";
static const char col_gray4[]       = "#eeeeee";
static const char col_cyan[]        = "#005577";

static const char *colors[][3]      = {
	/*               fg         bg         border */
	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
};

/* tagging */
static const char *tags[] = {
	"1", "2", "3", "4", "5",
	"6", "7", "8", "9", "0"
};

static const Rule rules[] = {
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Gimp",     NULL,       NULL,       0,            0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55;
static const int nmaster    = 1;
static const int resizehints = 1;

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },
	{ "><>",      NULL },
	{ "[M]",      monocle },
};

/* commands */
#define MODKEY Mod4Mask

#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,       {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview, {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,        {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,  {.ui = 1 << TAG} },

#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/*
 * Reinicia el propio ejecutable de dwm.
 *
 * No vuelve a ejecutar autostart, por lo que no duplica
 * Polybar, Dunst, Feh, etc.
 */
static void
restartwm(const Arg *arg)
{
	char *const argv[] = { "/proc/self/exe", NULL };

	(void)arg;
	execv("/proc/self/exe", argv);
}

/*
 * Cambia al tag anterior.
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
 * Cambia al tag siguiente.
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

static const char *termcmd[] = { "kitty", NULL };

static Key keys[] = {
	/* modifier                     key        function        argument */

	/* programas */
	{ MODKEY,                       XK_Return, spawn,           {.v = termcmd} },
	{ MODKEY,                       XK_space,  spawn,           SHCMD("rofi -show drun") },

	/* brillo */
	{ 0,                            XF86XK_MonBrightnessDown, spawn, SHCMD("brightnessctl set 10%-") },
	{ 0,                            XF86XK_MonBrightnessUp,   spawn, SHCMD("brightnessctl set +10%") },

	{ MODKEY,                       XK_F11,     spawn,           SHCMD("brightnessctl set 10%-") },
	{ MODKEY,                       XK_F12,     spawn,           SHCMD("brightnessctl set +10%") },

	/* volumen */
	{ 0,                            XF86XK_AudioRaiseVolume,  spawn, SHCMD("pamixer --increase 5") },
	{ 0,                            XF86XK_AudioLowerVolume,  spawn, SHCMD("pamixer --decrease 5") },
	{ 0,                            XF86XK_AudioMute,         spawn, SHCMD("pamixer -t") },

	{ MODKEY,                       XK_F3,      spawn,           SHCMD("pamixer --increase 5") },
	{ MODKEY,                       XK_F2,      spawn,           SHCMD("pamixer --decrease 5") },

	/* cerrar ventana */
	{ MODKEY,                       XK_q,       killclient,      {0} },
	{ MODKEY|ShiftMask,             XK_q,       killclient,      {0} },

	/* navegación entre ventanas */
	{ MODKEY,                       XK_Left,    focusstack,      {.i = -1} },
	{ MODKEY,                       XK_Right,   focusstack,      {.i = +1} },

	/* tamaño del master */
	{ MODKEY,                       XK_Up,      setmfact,        {.f = +0.05} },
	{ MODKEY,                       XK_Down,    setmfact,        {.f = -0.05} },

	/* layouts */
	{ MODKEY,                       XK_t,       setlayout,       {.v = &layouts[0]} },
	{ MODKEY,                       XK_s,       togglefloating,  {0} },
	{ MODKEY,                       XK_f,       setlayout,       {.v = &layouts[2]} },
	{ MODKEY,                       XK_m,       setlayout,       {.v = NULL} },

	/* tags */
	{ MODKEY|Mod1Mask,              XK_Left,    viewprevtag,     {0} },
	{ MODKEY|Mod1Mask,              XK_Right,   viewnexttag,     {0} },

	/* último tag */
	{ MODKEY,                       XK_Tab,     view,            {.ui = 0} },

	/* salir / reiniciar dwm */
	{ MODKEY|Mod1Mask,              XK_e,       quit,            {0} },
	{ MODKEY|Mod1Mask,              XK_r,       restartwm,       {0} },

	/* captura */
	{ 0,                            XK_Print,    spawn,           SHCMD("gnome-screenshot -i") },

	TAGKEYS(                        XK_1,                       0)
	TAGKEYS(                        XK_2,                       1)
	TAGKEYS(                        XK_3,                       2)
	TAGKEYS(                        XK_4,                       3)
	TAGKEYS(                        XK_5,                       4)
	TAGKEYS(                        XK_6,                       5)
	TAGKEYS(                        XK_7,                       6)
	TAGKEYS(                        XK_8,                       7)
	TAGKEYS(                        XK_9,                       8)
	TAGKEYS(                        XK_0,                       9)
};

/* button definitions */
static Button buttons[] = {
	/* click          event mask        button      function        argument */
	{ ClkLtSymbol,    0,                Button1,    setlayout,       {0} },
	{ ClkLtSymbol,    0,                Button3,    setlayout,       {.v = &layouts[2]} },
	{ ClkStatusText,  0,                Button2,    spawn,            {.v = termcmd} },
	{ ClkClientWin,   MODKEY,           Button1,    movemouse,       {0} },
	{ ClkClientWin,   MODKEY,           Button3,    resizemouse,     {0} },
	{ ClkTagBar,      0,                Button1,    view,            {0} },
	{ ClkTagBar,      0,                Button3,    toggleview,      {0} },
	{ ClkTagBar,      MODKEY,           Button1,    tag,             {0} },
	{ ClkTagBar,      MODKEY,           Button3,    toggletag,       {0} },
};
EOF

echo
echo "==> Compilando dwm..."

make clean
make

echo
echo "==> Instalando dwm en $BIN_DIR..."

install -Dm755 dwm "$BIN_DIR/dwm"

echo
echo "==> Creando autostart de dwm..."

cat >"$AUTOSTART_DIR/autostart.sh" <<'EOF'
#!/bin/sh

# Entorno gráfico
export GTK_THEME="Adwaita-dark"
export QT_QPA_PLATFORMTHEME="qt6ct"

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

# Polybar
"$HOME/.config/polybar/launch.sh" &

EOF

chmod +x "$AUTOSTART_DIR/autostart.sh"

echo
echo "==> Creando sesión de LightDM..."

sudo mkdir -p /usr/share/xsessions

sudo tee "$SESSION_FILE" >/dev/null <<EOF
[Desktop Entry]
Name=dwm
Comment=Dynamic Window Manager
Exec=$AUTOSTART_DIR/dwm-session
TryExec=$BIN_DIR/dwm
Type=Application
DesktopNames=dwm
EOF

cat >"$AUTOSTART_DIR/dwm-session" <<EOF
#!/bin/sh

export PATH="$BIN_DIR:\$PATH"

# Variables de sesión
export XDG_CURRENT_DESKTOP="dwm"
export XDG_SESSION_DESKTOP="dwm"
export XDG_SESSION_TYPE="x11"

# Autostart
"$AUTOSTART_DIR/autostart.sh"

# Ejecutar dwm
exec "$BIN_DIR/dwm"
EOF

chmod +x "$AUTOSTART_DIR/dwm-session"

echo
echo "=========================================="
echo " dwm instalado correctamente"
echo "=========================================="
echo
echo "Ejecutable:"
echo "  $BIN_DIR/dwm"
echo
echo "Sesión de LightDM:"
echo "  $SESSION_FILE"
echo
echo "Configuración:"
echo "  $DWM_DIR/config.h"
echo
echo "Autostart:"
echo "  $AUTOSTART_DIR/autostart.sh"
echo
echo "En LightDM selecciona:"
echo "  dwm"
echo
echo "Atajos principales:"
echo "  Super + Enter       Kitty"
echo "  Super + Space       Rofi"
echo "  Super + ←/→         ventana anterior/siguiente"
echo "  Super + ↑/↓         tamaño del master"
echo "  Super + T           tiled"
echo "  Super + S           floating"
echo "  Super + F           fullscreen/monocle"
echo "  Super + M           siguiente layout"
echo "  Super + Alt + ←/→   tag anterior/siguiente"
echo "  Super + Tab         último tag"
echo "  Super + 1..0        cambiar tag"
echo "  Super + Shift+1..0  mover ventana al tag"
echo "  Super + Q            cerrar ventana"
echo "  Super + Alt + E      salir de dwm"
echo "  Super + Alt + R      reiniciar dwm"
echo
echo "No se instalaron bspwm, sxhkd, dmenu ni picom."
echo
