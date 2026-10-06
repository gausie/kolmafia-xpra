document.addEventListener("DOMContentLoaded", () => {
  const button = document.createElement("button");
  button.id = "kolmafia-version";
  button.textContent = "KoLmafia version";
  button.addEventListener("click", () => {
    client.start_command("KoLmafia Version", "/usr/local/bin/kolmafia-version pick", "False");
  });
  document.body.appendChild(button);
});
