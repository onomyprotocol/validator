Testing and Bootstrapping Layout for Onomy DAO and Contributors
---------------------------------------------------------------

### Root of Testing and Bootstrapping

The foundation for testing and bootstrapping in the Onomy ecosystem is located in the [onomy_tests repo](https://github.com/onomyprotocol/onomy_tests). The `onomy_tests/onomy_test_lib` serves as the common library for all integration tests and tools such as the GraphQL runner. A critical dependency is the Rust crate `super_orchestrator`. For a comprehensive understanding, familiarity with async Rust (utilizing `tokio`) is essential. Additionally, understanding how `super_orchestrator` programmatically creates docker containers is pivotal. To delve deeper, one can explore the [super_orchestrator repo](https://github.com/AaronKutch/super_orchestrator) and experiment with examples using `cargo run --example ...`. This approach was adopted to bypass the complexity and limitations of bash scripts and docker compose files.

### Dockerfiles and Testing Libraries

The `onomy_tests/onomy_test_lib/src/dockerfiles.rs` includes definitions for the current versions used in programmatic dockerfiles within `onomy_tests/tests` and its dependent libraries. Updates to this file are necessary whenever new versions of `onomyd` and `onexd` are released or when standard container setups or Hermes versions require changes. The remainder of `onomy_test_lib` comprises helper structs and functions, with integration tests often employing the docker entrypoint pattern. The common `clap` arguments are located in misc.rs. Future tests can add on arguments or create customized Args structures as needed.

### Integration Tests

`onomy_tests/tests` houses several single-file integration tests, primarily used for development and as reference. While these tests are not run in CI, they are crucial for development. For external imports, `onomy_tests` is not published on crates.io but can be imported via a git revision, e.g., `onomy_test_lib = { git = "https://github.com/pendulum-labs/onomy_tests", rev = "[hash of desired commit] }"`.

### The Main Onomy Repo

The [main Onomy repo](https://github.com/onomyprotocol/onomy) defines the `onomyd` binary, with `onomy_tests` employed by the integration tests under `tests/`. When creating new versions of `onomyd`, it is important to update the `onomy_tests` git revision and the `UPGRADE_VERSION` in the `chain_upgrade.dockerfile` used by the chain upgrade test. This test is vital for detecting issues in the chain upgrade process before deployment on the testnet. Tests in `onomyd_only.rs` and `ics_cdd.rs` are critical for ensuring the proper functionality of custom features in `onomyd` and the provider module, respectively.

### Consumer Chain Layout

Each consumer chain in the Onomy network, such as the ONEX chain, has a dedicated module repository. For example, the market module for the ONEX chain is detailed at [Onomy Market Module](https://github.com/onomyprotocol/market). The [multiverse repo](https://github.com/onomyprotocol/multiverse) represents a plain consumer chain in its main branch, with specific tests and functionality added in branches like `onex`. After releasing a new consumer chain version, update the version in `onomy_tests` `dockerfiles.rs` to ensure consistency across dependent tests.

### Manual Tests and Scripts

The [manual_tests repo](https://github.com/onomyprotocol/manual_tests) contains custom scripts and helpers for contributors. It includes Rust scripts for semi-automated tasks like `init_ics_channels.rs` and scripts for generating consumer genesis files. The `onex_genesis.rs` in `manual_tests` should be used in conjunction with this for testing bootstrapping processes. An important aspect to prevent on mainnet is VSC timeouts, which occur when IBC packets are delayed in relaying. Running active relayers continuously with redundancy from multiple teams is crucial to avoid such issues.