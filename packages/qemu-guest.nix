# The QEMU guest agent without support for all desktop-related options.
{qemu_kvm, ...}:
(qemu_kvm.override {
  guestAgentSupport = true;
  alsaSupport = false;
  pulseSupport = false;
  pipewireSupport = false;
  sdlSupport = false;
  jackSupport = false;
  gtkSupport = false;
  vncSupport = false;
  smartcardSupport = false;
  spiceSupport = false;
  ncursesSupport = false;
  openGLSupport = false;
  rutabagaSupport = false;
  virglSupport = false;
  libiscsiSupport = false;
  tpmSupport = false;
  canokeySupport = false;
  capstoneSupport = false;
  enableDocs = false;
}).ga
