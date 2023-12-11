#!/usr/bin/env python3
# SPDX-License-Identifier: MIT-0

"""This regression test checks that files which are supposed to be copies of
each other are actually so.
"""

import logging
import os
import sys
from pathlib import Path

COPIES = (
    (
        "drake_bazel_download/LICENSE",
        "drake_bazel_external/LICENSE",
        "drake_bazel_installed/LICENSE",
    ),
    (
        "drake_bazel_download/.bazeliskrc",
        "drake_bazel_external/.bazeliskrc",
        "drake_bazel_installed/.bazeliskrc",
    ),
    (
        "drake_bazel_download/.bazelrc",
        "drake_bazel_external/.bazelrc",
        "drake_bazel_installed/.bazelrc",
    ),
    (
        "drake_ament_cmake_installed/.clang-format",
        "drake_bazel_download/.clang-format",
        "drake_bazel_external/.clang-format",
        "drake_bazel_installed/.clang-format",
        "drake_catkin_installed/.clang-format",
        "drake_cmake_external/.clang-format",
        "drake_cmake_installed/.clang-format",
        "drake_cmake_installed_apt/.clang-format",
    ),
    (
        "drake_ament_cmake_installed/CPPLINT.cfg",
        "drake_bazel_download/CPPLINT.cfg",
        "drake_bazel_external/CPPLINT.cfg",
        "drake_bazel_installed/CPPLINT.cfg",
        "drake_catkin_installed/CPPLINT.cfg",
        "drake_cmake_external/CPPLINT.cfg",
        "drake_cmake_installed/CPPLINT.cfg",
        "drake_cmake_installed_apt/CPPLINT.cfg",
    ),
    (
        "drake_bazel_download/.gitignore",
        "drake_bazel_external/.gitignore",
        "drake_bazel_installed/.gitignore",
    ),
    (
        "drake_bazel_download/apps/BUILD.bazel",
        "drake_bazel_installed/apps/BUILD.bazel",
    ),
    (
        "drake_bazel_download/apps/exec.sh",
        "drake_bazel_external/apps/exec.sh",
        "drake_bazel_installed/apps/exec.sh",
    ),
    (
        "drake_bazel_download/apps/find_resource_test.cc",
        "drake_bazel_installed/apps/find_resource_test.cc",
    ),
    (
        "drake_bazel_download/apps/find_resource_test.py",
        "drake_bazel_external/apps/find_resource_test.py",
        "drake_bazel_installed/apps/find_resource_test.py",
    ),
    (
        "drake_bazel_download/apps/import_all_test.py",
        "drake_bazel_external/apps/import_all_test.py",
        "drake_bazel_installed/apps/import_all_test.py",
    ),
    (
        "drake_bazel_download/apps/include_paths_test.cc",
        "drake_bazel_installed/apps/include_paths_test.cc",
    ),
    (
        "drake_bazel_download/apps/simple_logging_example.py",
        "drake_bazel_installed/apps/simple_logging_example.py",
    ),
)

found_errors = False


def error(message: str):
    logging.error(message)
    global found_errors
    found_errors = True


def check(index: int, paths: tuple[str]):
    # For readability, enforce that the lists are sorted.
    first_name = Path(paths[0]).name
    prologue = f"The {index+1}th list of files (containing {first_name})"
    if list(paths) != sorted(paths):
        error(f"{prologue} is not alpha-sorted; fix the file_sync_test code.")

    # Read all of the files into memory.
    content = dict()
    for path in paths:
        try:
            with open(path, "rb") as f:
                content[path] = f.read()
        except IOError:
            error(f"{prologue} refers to a missing file {path}")
    paths = list(content.keys())

    # Check for matching.
    all_match = all(
        content[a] == content[b]
        for a, b in zip(paths, paths[1:])
    )
    if not all_match:
        error(f"{prologue} do not all match")


def main():
    logging.basicConfig(format="%(levelname)s: %(message)s")
    os.chdir(Path(__file__).parent.parent.parent)
    for i, paths in enumerate(COPIES):
        check(i, paths)
    sys.exit(1 if found_errors else 0)


if __name__ == "__main__":
    main()
