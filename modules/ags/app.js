#!/usr/bin/env -S ags run
import GObject from "gi://GObject";
import GLib from "gi://GLib";
import { App, Astal, Gtk, astalify } from "astal/gtk3";
import { Variable } from "astal";
import { execAsync } from "astal/process";

// wrap gtk.calendar
class Calendar extends astalify(Gtk.Calendar) {
  static {
    GObject.registerClass(this);
  }
}

// state + helpers
const open = Variable(false);
let btcLabel, ethLabel, solLabel;
function toggleCC() {
  open.set(!open.get());
}
function launchBt() {
  execAsync("kitty bluetuith");
}
function fetchPrices() {
  execAsync(
    'curl -s "https://api.binance.com/api/v3/ticker/price?symbols=[\\"BTCUSDT\\",\\"ETHUSDT\\",\\"SOLUSDT\\"]"'
  )
    .then((r) =>
      JSON.parse(r.stdout).forEach(({ symbol, price }) => {
        const v = parseFloat(price).toFixed(2);
        if (symbol === "BTCUSDT") btcLabel.set_label(`btc: ${v}`);
        if (symbol === "ETHUSDT") ethLabel.set_label(`eth: ${v}`);
        if (symbol === "SOLUSDT") solLabel.set_label(`sol: ${v}`);
      })
    )
    .catch((e) => print("fetch error", e));
}
GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 60, () => {
  fetchPrices();
  return true;
});
fetchPrices();

// build ui imperatively
function buildUI() {
  const win = new Astal.Window({
    anchor:
      Astal.WindowAnchor.RIGHT |
      Astal.WindowAnchor.TOP |
      Astal.WindowAnchor.BOTTOM,
    widthRequest: 320,
    className: "control",
  });
  const outer = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    spacing: 0,
    margin: 0,
  });
  win.set_child(outer);

  const header = new Gtk.Label({ xalign: 0, label: "control center" });
  header.connect("button-press-event", toggleCC);
  outer.append(header);

  const revealer = new Gtk.Revealer({
    revealChild: open.get(),
    transition: Gtk.RevealerTransitionType.SLIDE_LEFT,
    transitionDuration: 250,
  });
  open.connect((val) => revealer.set_reveal_child(val));
  outer.append(revealer);

  const inner = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    spacing: 10,
    margin: 10,
  });
  revealer.set_child(inner);

  const btBtn = new Gtk.Button({ label: "", marginBottom: 6 });
  btBtn.connect("clicked", launchBt);
  inner.append(btBtn);

  const cal = new Calendar({
    showHeading: true,
    showDayNames: true,
    showWeekNumbers: false,
  });
  inner.append(cal);

  const priceBox = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    spacing: 4,
  });
  btcLabel = new Gtk.Label({ label: "btc: …" });
  priceBox.append(btcLabel);
  ethLabel = new Gtk.Label({ label: "eth: …" });
  priceBox.append(ethLabel);
  solLabel = new Gtk.Label({ label: "sol: …" });
  priceBox.append(solLabel);

  const refBtn = new Gtk.Button({ label: "refresh prices", marginTop: 6 });
  refBtn.connect("clicked", fetchPrices);
  priceBox.append(refBtn);

  inner.append(priceBox);
  return win;
}

App.start({
  instanceName: "org.hypr.cc",
  main: buildUI,
  css: `
    window.control { background: #2e3440; border-radius: 12px; border: 1px solid #88c0d0; }
    label          { color: #d8dee9; font-family: "Iosevka Nerd Font"; padding: 8px; }
    button         { padding: 4px 8px; border-radius: 6px; }
  `,
});
