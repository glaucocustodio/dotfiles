// Herdr's tab.move only takes an absolute index; this moves the focused tab by `delta`.
import { View, div } from "gpui-kit";
import { props, closeOverlay, run, focused, spaces } from "herdr";

export function mover(delta) {
  return class extends View {
    init(_props, cx) {
      cx.spawn(async () => {
        const f = focused();
        const tabs = spaces().find((s) => s.id === f?.space)?.tabs ?? [];
        const tab = tabs.find((t) => t.id === f?.tab);
        const index = tab && tab.index + delta;
        if (index >= 1 && index <= tabs.length) run("tab.move", { id: tab.id, index });
        closeOverlay(props()?.overlay);
      });
    }
    render() { return div(); }
  };
}
