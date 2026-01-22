use anyhow::{Context, Result};
use duckdb::Connection;
use std::fs;
use std::path::PathBuf;
use std::thread;
use tao::{
    dpi::LogicalSize,
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoopBuilder, EventLoopProxy},
    window::WindowBuilder,
};
use wry::WebViewBuilder;

const DUCKDB_UI_PORT: u16 = 4213;
const LOADING_HTML: &str = include_str!("./loading.html");
const SETUP_SQL: &str = include_str!("./setup.sql");

#[derive(Debug, Clone)]
enum UserEvent {
    DatabaseReady,
}

fn get_db_path() -> Result<PathBuf> {
    let data_dir = dirs::data_local_dir()
        .context("Failed to get user data directory")?;
    let app_dir = data_dir.join("duckui");
    fs::create_dir_all(&app_dir)
        .context("Failed to create app directory")?;
    Ok(app_dir.join("data.db"))
}

fn run_setup_sql(conn: &Connection, setup_sql: &str) -> Result<()> {
    println!("Running setup SQL...");

    // Remove comments and split by semicolon
    for statement in setup_sql.split(';') {
        // Remove comment lines and trim
        let statement: String = statement
            .lines()
            .filter(|line| {
                let trimmed = line.trim();
                !trimmed.is_empty() && !trimmed.starts_with("--")
            })
            .collect::<Vec<_>>()
            .join("\n")
            .trim()
            .to_string();

        if !statement.is_empty() {
            println!("Executing: {}", statement);
            conn.execute(&statement, [])
                .with_context(|| format!("Failed to execute: {}", statement))?;
        }
    }

    println!("Setup SQL completed");
    Ok(())
}

fn start_ui_server(conn: &Connection) -> Result<()> {
    println!("Starting DuckDB UI server...");
    // Load the UI extension and configure it
    conn.execute(&format!("SET ui_local_port = {}", DUCKDB_UI_PORT), [])
        .context("Failed to set UI port")?;
    conn.execute("CALL start_ui_server()", [])
        .context("Failed to start UI server")?;
    println!("DuckDB UI server started on port {}", DUCKDB_UI_PORT);
    Ok(())
}

fn initialize_database(proxy: EventLoopProxy<UserEvent>, is_first_run: bool) -> Result<()> {
    let db_path = get_db_path()?;

    println!("Database path: {}", db_path.display());
    println!("First run: {}", is_first_run);

    // Connect to database
    let conn = Connection::open(&db_path)
        .context("Failed to open database connection")?;

    if is_first_run {
        println!("First run detected, running setup...");
        run_setup_sql(&conn, SETUP_SQL)?;
    } else {
        println!("Database already exists...");
    }

    // Start the UI server
    start_ui_server(&conn)?;

    // Wait a moment for the server to be ready
    thread::sleep(std::time::Duration::from_secs(2));

    // Notify that database is ready
    proxy.send_event(UserEvent::DatabaseReady)
        .map_err(|e| anyhow::anyhow!("Failed to send event: {:?}", e))?;

    // Keep the connection alive by leaking it
    // This is necessary because DuckDB UI server needs the connection to stay open
    std::mem::forget(conn);

    Ok(())
}

fn main() {
    let db_path = get_db_path().expect("Failed to get database path");
    let is_first_run = !db_path.exists();

    let event_loop = EventLoopBuilder::<UserEvent>::with_user_event().build();
    let proxy = event_loop.create_proxy();

    let window = WindowBuilder::new()
        .with_title("DuckUI")
        .with_inner_size(LogicalSize::new(1280, 800))
        .build(&event_loop)
        .expect("Failed to create window");

    // Always show loading screen initially to avoid race condition
    let webview = WebViewBuilder::new()
        .with_html(LOADING_HTML)
        .build(&window)
        .expect("Failed to build webview");

    // Initialize database in background thread
    thread::spawn(move || {
        if let Err(e) = initialize_database(proxy, is_first_run) {
            eprintln!("Database initialization failed: {:?}", e);
        }
    });

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;

        match event {
            Event::UserEvent(UserEvent::DatabaseReady) => {
                println!("Database ready, navigating to UI...");
                let url = format!("http://localhost:{}", DUCKDB_UI_PORT);
                if let Err(e) = webview.load_url(&url) {
                    eprintln!("Failed to load URL: {:?}", e);
                }
            }
            Event::WindowEvent {
                event: WindowEvent::CloseRequested,
                ..
            } => *control_flow = ControlFlow::Exit,
            _ => (),
        }
    });
}
