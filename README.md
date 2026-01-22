# DuckUI

A quick way to run DuckDB UI after running some SQL setup, in a cross-platform way.

## Features

- 🦆 Embedded DuckDB database with bundled UI extension
- 🖥️ Cross-platform: macOS, Windows, and Linux
- 🚀 Self-contained executable - no dependencies required
- ⚡ Fast startup with automatic database initialization
- 📦 Customizable setup via SQL configuration

## Quick Start

### Running from Source

```sh
cargo run
```

### Building for Distribution

```sh
bash scripts/package-macos.sh          # macOS .app and .dmg
bash scripts/package-linux.sh          # Linux tarball
powershell scripts/package-windows.ps1 # Windows .exe and .zip
```

Output will be in the `dist/` directory.

## Development Setup

You will need Rust and some platform-specific dependencies:

**Linux:**

```sh
# deb/ubuntu/etc
sudo apt install libwebkit2gtk-4.1-dev

# arch
sudo pacman -S webkit2gtk-4.1

# fedora
sudo dnf install gtk3-devel webkit2gtk4.1-devel
```

**macOS:**

```sh
# Xcode Command Line Tools (usually already installed)
xcode-select --install
```

**Windows:**

Download [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/).

## How It Works

1. **First Run**:
   - Shows a loading screen while setting up
   - Executes `setup.sql` to configure DuckDB UI & import any data
   - Starts DuckDB UI server on port 4213
   - Executes `runtime.sql` to do any runtime stuff (attach databases, etc.)
   - Redirects to the UI when ready

2. **Subsequent Runs**:
   - Opens existing database
   - Shows brief loading screen while server starts
   - Executes `runtime.sql` to do any runtime stuff (attach databases, etc.)
   - Navigates to UI when ready

## Database Location

The database is stored in your user data directory:

- **macOS**: `~/Library/Application Support/duckui/data.db`
- **Windows**: `%LOCALAPPDATA%\duckui\data.db`
- **Linux**: `~/.local/share/duckui/data.db`

## Customization

Edit `setup.sql` to add custom initialization commands:

```sql
CREATE TABLE titanic AS SELECT * FROM read_parquet('https://www.timestored.com/data/sample/titanic.parquet');
```

The setup SQL & loading-screen HTML is embedded into the binary at compile time, if you want to customize things.

## Releases

See [PACKAGING.md](PACKAGING.md) for detailed packaging instructions.

## License

MIT
