# Python System Health CLI

A small Python command-line utility for checking basic Linux system health.

The tool collects system information, evaluates memory and disk usage against configurable thresholds, and reports the results either as human-readable output or machine-readable JSON.

The project demonstrates how Python can be used for practical system administration, automation, and monitoring tasks.

## What It Does

The utility collects:

* hostname
* username
* CPU core count
* memory usage
* available memory
* disk usage
* available disk space

It evaluates memory and disk usage and reports:

```text
OK
WARNING
```

The command supports two output formats:

* **Human-readable output** for interactive use
* **JSON output** for scripts, automation, monitoring systems, and other tools

## Example Output

### Human-readable

```text
System Health
-------------
Hostname: HAL
User: aalivtina
CPU cores: 16
Memory usage: 91.0% [WARNING]
Memory available: 1.03 GB
Disk usage: 39.4% [OK]
Disk free: 56.30 GB
```

### JSON

Run:

```bash
python system.py --json
```

Example:

```json
{
    "hostname": "HAL",
    "username": "aalivtina",
    "cpu_cores": 16,
    "memory_percent": 91.0,
    "memory_available_gb": 1.03,
    "disk_percent": 39.4,
    "disk_free_gb": 56.30,
    "memory_status": "WARNING",
    "disk_status": "OK"
}
```

The JSON output makes the tool easier to integrate with automation scripts or monitoring workflows.

---

## Technologies

* Python
* psutil
* Linux
* JSON

## Prerequisites

* Python 3
* Linux or another supported operating system
* `pip`

The project uses `psutil` to access system and process information.

## Installation

Create a virtual environment:

```bash
python -m venv .venv
source .venv/bin/activate
```

Install the dependencies:

```bash
pip install -r requirements.txt
```

## Usage

Run the health check:

```bash
python system.py
```

For machine-readable output:

```bash
python system.py --json
```

The command can therefore be used interactively by an administrator or as part of an automated workflow.

---

## Testing

The project includes automated tests using `pytest`.

Run:

```bash
pytest
```

The tests verify the behavior of the system health functionality without requiring manual inspection of the output.

---

## DevOps Use Case

A system health utility is a small example of a task commonly automated in DevOps and Linux administration.

For example, the JSON output could be consumed by another script:

```text
Python health check
        ↓
JSON output
        ↓
Automation / monitoring
        ↓
Action or alert
```

This project provides a foundation for extending the utility with additional checks such as:

* CPU utilization
* running services
* filesystem checks
* process checks
* network connectivity
* configurable warning thresholds
* integration with monitoring or CI/CD workflows

## Skills Demonstrated

This project demonstrates practical use of:

* Python functions
* modules and imports
* dictionaries
* conditional logic
* command-line arguments
* JSON serialization
* system information retrieval
* dependency management
* virtual environments
* automated testing
* basic health-check logic
* formatted terminal output
* machine-readable output for automation

## Learning Outcome

After completing this project, I can independently:

* create a small Python CLI utility
* work with external Python packages
* create and use virtual environments
* retrieve system information programmatically
* implement health-check logic
* process command-line arguments
* produce human-readable and JSON output
* write and run automated tests
* design a small Python tool with automation and DevOps use cases in mind

This project is part of the larger DevOps Lab and provides a foundation for Python-based system administration, automation, monitoring, and infrastructure tooling.
