/* See LICENSE file for copyright and license details. */

#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx  = 2;
static const unsigned int snap      = 32;
static const int showbar            = 1;
static const int topbar             = 1;

static const char *fonts[] = {
	"JetBrains Mono:size=10"
};

static const char dmenufont[] =
	"JetBrains Mono:size=10";

/*
 * Necesario para dwm 6.8.
 * No usamos dmenu; usamos Rofi.
 */
static char dmenumon[2] = "0";

static const char *dmenucmd[] = {
	"dmenu_run",
	"-m",
	dmenumon,
	"-fn",
	dmenufont,
	"-p",
	"Run: ",
	NULL
};

static const int lockfullscreen = 1;
static const int refreshrate = 60;

/* colores */
static const char col_gray1[] = "#222222";
static const char col_gray2[] = "#444444";
static const char col_gray3[] = "#bbbbbb";
static const char col_gray4[] = "#eeeeee";
static const char col_cyan[]  = "#000000";

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

/* 9 tags */
static const char *tags[] = {
	"1", "2", "3", "4", "5",
	"6", "7", "8", "9"
};

/* rules */
static const Rule rules[] = {
	{ NULL, NULL, NULL, 0, 0, -1 },
};

/* layout */
static const float mfact     = 0.55;
static const int nmaster     = 1;
static const int resizehints = 1;

static const Layout layouts[] = {
	{ "[]=", tile },
	{ "><>", NULL },
	{ "[M]", monocle },
};

#define MODKEY Mod4Mask

#define TAGKEYS(KEY,TAG) \
	{ MODKEY, KEY, view, {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask, KEY, toggleview, {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask, KEY, tag, {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY, toggletag, {.ui = 1 << TAG} },

#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

static const char *termcmd[] = {
	"kitty",
	NULL
};

static Key keys[] = {

	/* Kitty */
	{ MODKEY, XK_Return, spawn, {.v = termcmd} },

	/* Rofi */
	{ MODKEY, XK_space, spawn,
		SHCMD("rofi -show drun") },

	/* brillo */
	{ 0, XF86XK_MonBrightnessDown, spawn,
		SHCMD("brightnessctl set 10%-") },

	{ 0, XF86XK_MonBrightnessUp, spawn,
		SHCMD("brightnessctl set +10%") },

	{ MODKEY, XK_F11, spawn,
		SHCMD("brightnessctl set 10%-") },

	{ MODKEY, XK_F12, spawn,
		SHCMD("brightnessctl set +10%") },

	/* volumen */
	{ 0, XF86XK_AudioRaiseVolume, spawn,
		SHCMD("pamixer --increase 5") },

	{ 0, XF86XK_AudioLowerVolume, spawn,
		SHCMD("pamixer --decrease 5") },

	{ 0, XF86XK_AudioMute, spawn,
		SHCMD("pamixer -t") },

	{ MODKEY, XK_F3, spawn,
		SHCMD("pamixer --increase 5") },

	{ MODKEY, XK_F2, spawn,
		SHCMD("pamixer --decrease 5") },

	/* captura */
	{ 0, XK_Print, spawn,
		SHCMD("gnome-screenshot -i") },

	/* cerrar */
	{ MODKEY, XK_q, killclient, {0} },
	{ MODKEY|ShiftMask, XK_q, killclient, {0} },

	/* ventana anterior / siguiente */
	{ MODKEY, XK_Left, focusstack, {.i = -1} },
	{ MODKEY, XK_Right, focusstack, {.i = +1} },

	/* tamaño del master */
	{ MODKEY, XK_Up, setmfact, {.f = +0.05} },
	{ MODKEY, XK_Down, setmfact, {.f = -0.05} },

	/* tag anterior / siguiente */
	{ MODKEY|Mod1Mask, XK_Left, viewprevtag, {0} },
	{ MODKEY|Mod1Mask, XK_Right, viewnexttag, {0} },

	/* layouts */
	{ MODKEY, XK_t, setlayout, {.v = &layouts[0]} },
	{ MODKEY, XK_s, togglefloating, {0} },
	{ MODKEY, XK_f, setlayout, {.v = &layouts[2]} },
	{ MODKEY, XK_m, setlayout, {.v = NULL} },

	/* última tag */
	{ MODKEY, XK_Tab, view, {.ui = 0} },

	/* salir */
	{ MODKEY|Mod1Mask, XK_e, quit, {0} },

	/* reiniciar */
	{ MODKEY|Mod1Mask, XK_r,
		spawn,
		SHCMD("touch \"$HOME/.config/dwm/restart\"; pkill -TERM -x dwm") },

	/* tags 1-9 */
	TAGKEYS(XK_1, 0)
	TAGKEYS(XK_2, 1)
	TAGKEYS(XK_3, 2)
	TAGKEYS(XK_4, 3)
	TAGKEYS(XK_5, 4)
	TAGKEYS(XK_6, 5)
	TAGKEYS(XK_7, 6)
	TAGKEYS(XK_8, 7)
	TAGKEYS(XK_9, 8)
};

static Button buttons[] = {
	{ ClkLtSymbol, 0, Button1, setlayout, {.v = &layouts[0]} },
	{ ClkLtSymbol, 0, Button3, setlayout, {.v = &layouts[2]} },
	{ ClkWinTitle, 0, Button2, zoom, {0} },

	{ ClkClientWin, MODKEY, Button1, movemouse, {0} },
	{ ClkClientWin, MODKEY, Button2, togglefloating, {0} },
	{ ClkClientWin, MODKEY, Button3, resizemouse, {0} },

	{ ClkTagBar, 0, Button1, view, {0} },
	{ ClkTagBar, 0, Button3, toggleview, {0} },
	{ ClkTagBar, MODKEY, Button1, tag, {0} },
	{ ClkTagBar, MODKEY, Button3, toggletag, {0} },
};
