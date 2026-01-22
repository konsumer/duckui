use std::path::Path;

use anyhow::Result;
use duckdb::{Connection, Result as DuckResult};
use tao::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};
use wry::WebViewBuilder;

fn main() -> Result<()> {
    // 1. Open DuckDB from a relative path
    let db_path = Path::new("data").join("duck.db");
    std::fs::create_dir_all("data")?;
    let conn = Connection::open(db_path)?;

    // 3. Start UI server and get port
    let port = start_duckdb_ui(&conn)?;

    // 4. Start webview pointing to DuckDB UI
    start_webview(port)?;

    Ok(())
}

/// Install/load ui extension, start the UI server, and return the port.
fn start_duckdb_ui(conn: &Connection) -> DuckResult<u16> {
    // Install/load UI extension. [web:16][web:37]
    conn.execute_batch(
        r#"
        INSTALL ui;
        LOAD ui;
        "#,
    )?;

    // Set a known port and start the UI HTTP server. [web:16]
    conn.execute_batch(
        r#"
        SET ui_local_port = 4213;
        CALL start_ui_server();
        "#,
    )?;

    // Read back the current port. [web:16][web:29]
    let mut stmt = conn.prepare(
        "SELECT current_setting('ui_local_port') AS port",
    )?;
    let mut rows = stmt.query([])?;

    let row = rows.next()?.expect("ui_local_port should be set");
    let port: i64 = row.get("port")?;
    let port = port as u16;

    Ok(port)
}

fn start_webview(port: u16) -> Result<()> {
    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_title("DuckDB UI")
        .build(&event_loop)?;

    let url = format!("http://127.0.0.1:{port}");

    let _webview = WebViewBuilder::new(&window)?
        .with_url(&url)?
        .build()?;

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => {
                *control_flow = ControlFlow::Exit;
            }
            _ => {}
        }
    });
}
