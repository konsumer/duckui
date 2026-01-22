I kept needing a quick way to run duckdb ui after running some SQL setup, and I wanted a cross-platform way to do this.

This will allow you to distribute a small cross-platform program that will download/import your database and let users play with the data.


## compile

You will need cargo installed and some C deps.

```sh
# deb/ubuntu/etc
sudo apt install libwebkit2gtk-4.1-dev

# arch
sudo pacman -S webkit2gtk-4.1

# fedora
sudo dnf install gtk3-devel webkit2gtk4.1-devel

# run it locally
cargo run
```