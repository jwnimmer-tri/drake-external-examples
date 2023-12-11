# Bazel project with Drake as an external

This pulls in Drake via the Bazel workspace mechanism.

For an introduction to Bazel, refer to
[Getting Started with Bazel](https://docs.bazel.build/versions/master/getting-started.html).

## Assumptions

You must be using one of Drake's
[Supported Configurations](https://drake.mit.edu/installation.html#supported-configurations).

You must have already installed
[Bazelisk](https://github.com/bazelbuild/bazelisk#bazelisk)
or
[Bazel](https://bazel.build/install).

The commands given in these instructions assume that your working directory is
`drake-external-examples/drake_bazel_external`, or the equivalent directory in
your own copy of this code.

## Setup

By default, this project downloads the master branch of Drake. However, when you
copy it to for your own use, generally you should configure your copy to use a
specific version of Drake to ensure a repeatable build. Refer to the comments in
`WORKSPACE.bazel` for how to do that.

After you've adjusted the Drake version, install the required system packages:

```
bazel run //:install_prereqs
```

## Build

Then, to build and test all apps:
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

## Python Versions

By default, Python 3 is the Python interpreter that Drake will use when built
with Bazel. To see which Python versions are supported, see the
[supported configurations](https://drake.mit.edu/developers.html#supported-configurations).
