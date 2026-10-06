// The entrypoint fills this in from KOLMAFIA_UI_SCALE. When KoLmafia renders at a multiple, ask
// for a desktop that much wider than the window and let the client scale it back down, so
// windows keep their size and stay sharp on HiDPI screens. An explicit ?override_width= wins.
const KOLMAFIA_UI_SCALE = 1;
if (KOLMAFIA_UI_SCALE !== 1) {
  const getparam = Utilities.getparam;
  Utilities.getparam = function (property) {
    const value = getparam.call(this, property);
    if (property === "override_width" && value == null) {
      return String(window.innerWidth * KOLMAFIA_UI_SCALE);
    }
    return value;
  };
}

document.addEventListener("DOMContentLoaded", () => {
  const button = document.createElement("button");
  button.id = "kolmafia-version";
  button.textContent = "KoLmafia version";
  button.addEventListener("click", () => {
    client.start_command("KoLmafia Version", "/usr/local/bin/kolmafia-version pick", "False");
  });
  document.body.appendChild(button);
});
