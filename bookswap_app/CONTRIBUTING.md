# Contributing to BookSwap

Thank you for your interest in contributing to BookSwap! This document provides guidelines and instructions for contributing.

## Development Setup

1. **Fork and Clone**

   ```bash
   git clone https://github.com/YOUR_USERNAME/BookSwap_Flutter.git
   cd BookSwap_Flutter/bookswap_app
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Follow instructions in README.md
   - Add your own `google-services.json`

## Code Style

### Dart Code Guidelines

- Use `dartfmt` to format your code
- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
- Add documentation comments for public APIs
- Keep functions small and focused

### Naming Conventions

- **Classes**: `PascalCase` (e.g., `UserModel`, `AuthService`)
- **Variables**: `camelCase` (e.g., `userId`, `bookTitle`)
- **Constants**: `camelCase` with `const` (e.g., `const primaryColor`)
- **Files**: `snake_case` (e.g., `auth_service.dart`, `user_model.dart`)

### Project Structure

```
lib/
├── models/       # Data models only
├── services/     # Business logic and Firebase operations
├── providers/    # State management (ChangeNotifier)
├── screens/      # UI pages
├── widgets/      # Reusable UI components
└── constants/    # App-wide constants
```

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```
feat(auth): Add password reset functionality

- Added reset password screen
- Implemented Firebase password reset
- Added email validation

Closes #123
```

```
fix(chat): Resolve message ordering issue

Messages now display in correct chronological order
```

## Pull Request Process

1. **Create a Branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**

   - Write clean, documented code
   - Follow the code style guidelines
   - Test your changes thoroughly

3. **Run Tests**

   ```bash
   flutter analyze
   flutter test
   ```

4. **Commit Changes**

   ```bash
   git add .
   git commit -m "feat: Add your feature"
   ```

5. **Push to GitHub**

   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create Pull Request**
   - Provide clear description
   - Reference related issues
   - Add screenshots for UI changes

## Testing

### Before Submitting

- [ ] Code follows style guidelines
- [ ] No Dart analyzer warnings (`flutter analyze`)
- [ ] All existing tests pass
- [ ] New features include tests
- [ ] Documentation updated

### Manual Testing Checklist

- [ ] Authentication flow works
- [ ] Book CRUD operations function correctly
- [ ] Swap offers create and update properly
- [ ] Chat messages send and receive
- [ ] Images upload successfully
- [ ] App runs without errors

## Feature Requests

Have an idea? Open an issue with:

- Clear description of the feature
- Use case and benefits
- Potential implementation approach

## Bug Reports

Found a bug? Report it with:

- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Device and Flutter version

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow

## Questions?

If you have questions, feel free to:

- Open an issue
- Contact the maintainers
- Check existing documentation

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.
