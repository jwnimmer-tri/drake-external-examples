# Bazel project using automatically downloaded Drake binaries

This project demonstrates how to use a
[precompiled binary build of Drake](https://drake.mit.edu/from_binary.html)
automatically downloaded via Bazel.

For an introduction to Bazel, refer to
[Getting Started with Bazel](https://bazel.build/start).

## Assumptions

You must be using one of Drake's
[Supported Configurations](https://drake.mit.edu/installation.html#supported-configurations).

You must have already installed
[Bazelisk](https://github.com/bazelbuild/bazelisk#bazelisk)
or
[Bazel](https://bazel.build/install).

The commands given in these instructions assume that your working directory is
`drake-external-examples/drake_bazel_download`, or the equivalent directory in
your own copy of this code.

## Setup

By default, this project downloads the latest nightly release of Drake. However,
when you copy it to for your own use, generally you should configure your copy
to use a specific version of Drake to ensure a repeatable build. Refer to the
comments in `WORKSPACE.bazel` for how to do that.

After you've adjusted the Drake version, install the required system packages:

```
bazel run //:install_prereqs
```

## Build

To build and test all apps:
```
bazel test //...
```

As an example to run a binary directly:
```
bazel run //apps:simple_logging_example
```

You may also run the binary directly per the `bazel-bin/...` path that the
above command prints out; however, be aware that your working directories may
cause differences.  This is important when using tools like
`drake::FindResource` / `pydrake.common.FindResource`.
You may generally want to stick to using `bazel run` when able.
