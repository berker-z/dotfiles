#!/usr/bin/env -S ags run
import { App, Astal } from "astal/gtk3";
import { execAsync } from "astal/process";

const { RIGHT, TOP, BOTTOM } = Astal.WindowAnchor;

function launchBt() {
  execAsync("kitty bluetuith");
}

App.start({
  instanceName: "org.hypr.cc", // needs a dot
  main() {
    return (
      <window
        anchor={RIGHT | TOP | BOTTOM}
        width-request={320}
        className="control"
      >
        <box vertical spacing={10} margin={10}>
          <label xalign={0} label="control center" />
          <button label="" onClicked={launchBt} />
        </box>
      </window>
    );
  },
  css: `
        window.control { background: #2e3440; border-radius: 12px; }
        label          { color: #d8dee9;  font-family: "Iosevka Nerd Font"; }
        button         { padding: 4px 8px; border-radius: 6px; }
    `,
});
