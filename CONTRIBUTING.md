# Contributing to Knowledge

Thank you for your interest in contributing to Knowledge! This document provides guidelines and instructions for contributing to the project.

## Development Standards

### Code Style

- Follow PEP 8 guidelines
- Use type hints for all functions and variables
- Write comprehensive docstrings in Google style
- Keep functions focused and single-purpose
- Use meaningful variable and function names

### Testing

- Write unit tests for all new features
- Maintain test coverage above 90%
- Include both positive and negative test cases
- Use pytest fixtures for complex test setup
- Mock external dependencies in tests

### Documentation

- Update relevant documentation when adding features
- Include usage examples in docstrings
- Document any breaking changes
- Keep README files up to date
- Add comments for complex logic

## Development Workflow

1. Create a new branch for your feature/fix:
```bash
git checkout -b feature/your-feature-name
```

2. Make your changes following the development standards

3. Run tests and checks:
```bash
pytest
ruff check .
mypy .
```

4. Commit your changes with a descriptive message:
```bash
git commit -m "feat: add new feature"
```

5. Push your branch and create a pull request

## Pull Request Process

1. Ensure your PR description clearly describes the changes
2. Link any related issues
3. Request review from at least one maintainer
4. Address any feedback before merging
5. Squash commits if requested

## Commit Message Format

Use the following format for commit messages:

```
<type>: <description>

[optional body]
[optional footer]
```

Types:
- feat: new feature
- fix: bug fix
- docs: documentation changes
- style: formatting, missing semicolons, etc.
- refactor: code refactoring
- test: adding or fixing tests
- chore: maintenance tasks

## Questions?

Feel free to open an issue for any questions about contributing to the project.