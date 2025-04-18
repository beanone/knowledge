# Knowledge

A comprehensive IDE for working with research project assisted by knowledge graphs, featuring a modern web interface, powerful query capabilities, and seamless LLM integration.

## Project Structure

This is a monorepo containing several packages:

- `graph-core`: Core graph operations and data structures
- `graph-service`: Backend service implementation
- `graph-api`: REST API layer
- `graph-builder`: Graph construction and manipulation tools
- `graph-ui`: Web-based user interface

## Getting Started

### Prerequisites

- Python 3.10+
- Poetry for dependency management
- Node.js 18+ (for UI development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-org/knowledge.git
cd knowledge
```

2. Install dependencies:
```bash
poetry install
```

3. Set up development environment:
```bash
poetry shell
```

### Development

- Run tests: `pytest`
- Format code: `ruff format .`
- Lint code: `ruff check .`
- Type check: `mypy .`

## Documentation

- [System Design](docs/architecture/knowledge-system.md)
- [Components and Dependencies](docs/architecture/components-and-dependencies.md)
- [API Documentation](docs/api/README.md)
- [Development Guides](docs/guides/README.md)

## Examples

- [Basic Usage](examples/basic/README.md)
- [Advanced Features](examples/advanced/README.md)
- [Jupyter Notebooks](examples/notebooks/README.md)

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.