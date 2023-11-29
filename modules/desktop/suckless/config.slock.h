/* user and group to drop privileges to */
static const char *user  = "nobody";
static const char *group = "nobody";

static const char *colorname[NUMCOLS] = {
	[INIT] =   "black",     /* after initialization */
	[INPUT] =  "#005577",   /* during input */
	[FAILED] = "#CC3333",   /* wrong password */
	[CAPS] =   "#007755",   /* CapsLock on */
};

/* treat a cleared input like a wrong password (color) */
static const int failonclear = 1;

/* allow control key to trigger fail on clear */
static const int controlkeyclear = 1;

/* time in seconds before the monitor shuts down */
static const int monitortime = 5;

/* time in seconds to cancel lock with mouse movement */
static const int timetocancel = 4;
/* whether quick-cancel is enabled by default (the `-c` flag flips this) */
static const int quickcancelenabledbydefault = 0;

/* secret passwords for running commands while locked */
static const struct secretpass scom[] = {
	/* password              command */
	{ "shutdown",           "systemctl poweroff -i" },
	{ "reboot",             "systemctl reboot -i" },
	{ "hibernate",          "systemctl hibernate -i" },
};
