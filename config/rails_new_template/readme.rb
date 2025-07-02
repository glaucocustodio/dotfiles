README_CONTENT = <<-CODE
# #{$app_name.humanize}

## Setup

### Dependencies

Ensure your system has installed: ([asdf](https://asdf-vm.com/guide/introduction.html) is recommended to manage versions):

- Ruby (as per [.ruby-version](.ruby-version))
- PostgreSQL (version 16+)

### Installation

Install gems:

```bash
bundle install
```

Prepare database:

```bash
bin/rails db:create db:migrate db:seed
```

## Running

To run the application:

```bash
make run
```

To enter the console:

```bash
make console
```

To enter the database console (it requires [pgcli](https://www.pgcli.com/)):

```bash
make db_console
```

## Tests

To run tests:

```bash
make test
```

## Formatting

To check for lint/formatting issues:

```bash
make lint
```

To automatically fix the ones that can be fixed:

```bash
make lint_fix
```
CODE
