# Code of Conduct & Contributing to Hytale Server Container

## Reporting Bugs

Before creating a new issue, please check if it already exists: [GitHub Issues](https://github.com/deinfreu/hytale-server-container/issues). When reporting, include:

- A clear description of the issue.
- Steps to reproduce.
- Your environment (OS, Docker version, container image tag).

## New Features & Contributions

**Before implementing a new feature, please open an issue or join our [Discord community](https://discord.gg/M8yrdnHb32) to discuss your idea.** Not every feature suggestion is subject to implementation — some may fall outside the project's scope, introduce unnecessary complexity, or conflict with existing design goals. Early discussion helps ensure alignment and prevents wasted effort on changes that won't be merged.

If your proposal aligns with the project direction:

1. **Fork this repository** on GitHub, then clone it: `git clone https://github.com/YOUR-USERNAME/hytale-server-container.git`
2. Create a new branch: `cd hytale-server-container && git checkout -b feature-name`
3. Make your changes — ensure all scripts work on both x86_64 and ARM64, and test Docker images build successfully with `docker compose build`. Please keep code style consistent with existing scripts and follow ShellCheck standards where possible.
4. Commit and push to your fork.
5. Open a Pull Request against the main repository with a clear summary of what changed and why.

## License

By contributing, you agree that your contributions will be licensed under the project's [GPL-3.0 license](https://github.com/deinfreu/hytale-server-container/blob/main/LICENSE).
