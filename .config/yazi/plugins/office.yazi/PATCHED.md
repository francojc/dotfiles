# Local patch

Vendored from [macydnah/office.yazi](https://github.com/macydnah/office.yazi) at `41ebef8` and patched for Yazi 26.x (removed from `package.toml` so `ya pkg` won't overwrite it).

- `ya.preview_widgets(job, {})` → `ya.preview_widget(job, err)`
- `ya.manager_emit` / `ya.mgr_emit` → `ya.emit`
- Errors from `preload` and `ya.image_show` are now shown in the preview pane
