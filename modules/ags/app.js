#!/usr/bin/env -S ags run
import GObject from "gi://GObject";
import { App, Astal, Gtk, astalify } from "astal/gtk3";
import { Variable } from "astal";
import { execAsync } from "astal/process";

// wrap gtk.calendar for jsx
class Calendar extends astalify(Gtk.Calendar) {
  static {
    GObject.registerClass(this);
  }
}

// reactive flag for slide state
const open = Variable(false);
const toggleCC = () => open.set(!open.get());
const launchBt = () => execAsync("kitty bluetuith");
const { RIGHT, TOP, BOTTOM } = Astal.WindowAnchor;

App.start({
  instanceName: "org.hypr.cc",
  main() {
    return (
      <window
        anchor={RIGHT | TOP | BOTTOM}
        width-request={320}
        className="control"
      >
        {/* single child: a box */}
        <box vertical spacing={0} margin={0}>
          <label
            xalign={0}
            label="control center"
            onButtonPressEvent={toggleCC}
          />
          <revealer
            revealChild={open.bind()}
            transition="slide_left"
            transitionDuration={250}
          >
            <box vertical spacing={10} margin={10}>
              <button label="" onClicked={launchBt} />
              <Calendar showHeading showDayNames showWeekNumbers={false} />
            </box>
          </revealer>
        </box>
      </window>
    );
  },
  css: `
    window.control { background: #2e3440; border-radius: 12px; border: 1px solid #88c0d0; }
    label          { color: #d8dee9; font-family: "Iosevka Nerd Font"; padding: 8px; }
    button         { padding: 4px 8px; border-radius: 6px; }
  `,
});
