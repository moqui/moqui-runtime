# Security Policy

## Supported Versions

The primary supported version for each repository is the latest commit in the master (primary) branch.

Moqui Ecosystem projects are maintained by volunteer contributors, primarily people who use and work with the code as part of their employment or professional services. There are periodic community releases but most distributions and releases involve custom code and are managed, internally or publicly, by third parties. Community releases are checkpoint releases, not maintained release branches, and are best for evaluation rather than production use.

Moqui uses a 'continous release' approach for managing code repositories. Aside from new (work-in-progress) and archived repositories, the master branch in each repository is considered production ready. Rather than running a centrally dictated release schedule and process, the focus is on keeping master branches in a production ready state so that users may use whatever release process and frequency they prefer.

For most use cases we recommend using code directly from the master branch in each repository. For stabilization and periodic updates (instead of continuous) we recommend using a fork for each git repository with an 'upstream' remote pointing to the Moqui Ecosystem repository for easy upstream updates.

## Reporting a Vulnerability

To report security issues that should not be disclosed publicly before they are fixed, please use the private **[moqui-board@googlegroups.com](mailto:moqui-board@googlegroups.com)** mailing list. This is setup so that anyone can send messages to it, but only members of the group can read the messages.

## Issues and Pull Requests

For more information on submitting issues and pull requests please see the [Issue and Pull Request Guide](https://moqui.org/m/docs/moqui/Issue+and+Pull+Request+Guide) on moqui.org.

## Attack surface

This repository is the default **runtime** directory: `webroot` (root screen, `/rest`, `/rpc`, Login) and `tools` (Assist, System, and Tools apps, `/rest/s1/moqui`, seed artifact authz).

The inventory for moqui-framework **and** this runtime is in the framework repo: [SECURITY_SURFACE.md](https://github.com/moqui/moqui-framework/blob/master/SECURITY_SURFACE.md) (includes Assist `/qapps/assist` from the tools component, `/llm/*`, and A2A). Operator checklist: [Run and Deploy — Production security](https://www.moqui.org/m/docs/framework/Run+and+Deploy).
