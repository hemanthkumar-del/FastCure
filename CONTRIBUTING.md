# Contributing to FastCure

We welcome contributions to improve FastCure! Please review this guide to learn how you can contribute.

---

## 🛠️ Development Workflow

1.  **Fork the Repository**: Create a personal clone of the repository on GitHub.
2.  **Clone the Repository**: Clone your fork locally to your workstation.
    ```bash
    git clone https://github.com/your-username/FastCure.git
    ```
3.  **Create a Feature Branch**:
    ```bash
    git checkout -b feature/amazing-new-feature
    ```
4.  **Implement Changes**: Keep your code clean, document new functions, and follow the Clean Architecture directory schema.
5.  **Run Quality Checks**:
    ```bash
    flutter analyze
    flutter test
    ```
6.  **Commit Changes**: Follow semantic commit formatting:
    ```bash
    git commit -m "feat: Add amazing new feature"
    ```
7.  **Push and Open a Pull Request**: Push your branch to your fork and submit a PR to the `main` branch.

---

## 📝 Coding Standards

*   **Formatting**: Always format your Dart code using `flutter format .` before committing.
*   **Documentation**: Provide docstrings for public classes and methods.
*   **Test Cases**: Add unit tests in the `test/` directory to verify new domain model parsers.
