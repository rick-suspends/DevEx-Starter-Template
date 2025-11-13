import typer
import requests
from typing_extensions import Annotated
from typing import Optional

# --- 1. Typer Application Setup ---

# The main Typer app instance. The 'name' is what users type in the terminal.
app = typer.Typer(
    name="docstool",
    help="A Developer Experience (DevEx) toolkit for documentation quality assurance.",
    # Enables rich markup for better terminal help text display
    rich_markup_mode="rich",
)

# --- 2. Link Validation Command ---

@app.command(name="check-url")
def check_url_command(
    url: Annotated[str, typer.Argument(help="The full URL to check (e.g., https://example.com/page/).")],
    allow_external: Annotated[bool, typer.Option("--external", help="Allow checking external links (slower and prone to network issues).")] = False,
    timeout: Annotated[int, typer.Option("--timeout", help="Timeout in seconds for each request.")] = 5,
    user_agent: Annotated[Optional[str], typer.Option("--user-agent", help="Specify a custom User-Agent string.")] = None,
):
    """
    Checks a single URL for basic connectivity (HTTP status code 200).

    This command demonstrates a core function of the Docs Validator: ensuring links
    are not broken, which is a key CI/CD quality gate.
    """
    typer.echo(f"Checking URL: [bold blue]{url}[/bold blue]")
    
    # Set User-Agent for requests
    headers = {'User-Agent': user_agent or 'DevEx Docs Validator CLI/1.0'}
    
    # --- Simplified Link Check Logic ---
    try:
        # Use requests.head() which is faster than GET as it only fetches headers
        response = requests.head(url, timeout=timeout, headers=headers, allow_redirects=True)
        
        status_code = response.status_code
        
        if 200 <= status_code < 300:
            typer.echo(f"[green]SUCCESS:[/green] URL is reachable. Status Code: {status_code}")
        elif 300 <= status_code < 400:
            # Note: Redirects (3xx) are technically reachable but may indicate a stale link
            typer.echo(f"[yellow]WARNING:[/yellow] Redirect detected. Status Code: {status_code}")
        else:
            typer.echo(f"[red]FAILED:[/red] Link is broken or inaccessible. Status Code: {status_code}")
            # Exit with a non-zero code for CI/CD failure detection
            raise typer.Exit(code=1)
            
    except requests.exceptions.RequestException as e:
        typer.echo(f"[red]ERROR:[/red] Connection failed ({e})")
        raise typer.Exit(code=1)

# --- 3. Main Execution Block ---

if __name__ == "__main__":
    app()
