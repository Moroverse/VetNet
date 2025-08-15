// String+Scripts.swift
// Copyright (c) 2025 Moroverse
// Created by Daniel Moro on 2025-07-09 06:26 GMT.

import Foundation

public extension String {
    static func lintScript() -> String {
        """
        #!/bin/bash
        export PATH="$PATH:$HOME/.local/share/mise/shims"

        if which swiftformat > /dev/null; then
            swiftformat . --lint
        else
            echo "warning: SwiftFormat not installed, run mise install"
        fi

        if which swiftlint > /dev/null; then
            swiftlint
        else
            echo "warning: SwiftLint not installed, run mise install"
        fi
        """
    }

    static func formatScript() -> String {
        """
        #!/bin/bash
        export PATH="$PATH:$HOME/.local/share/mise/shims"

        if which swiftformat > /dev/null; then
            swiftformat .
        else
            echo "warning: SwiftFormat not installed, run mise install"
        fi

        if which swiftlint > /dev/null; then
            swiftlint --fix
        else
            echo "warning: SwiftLint not installed, run mise install"
        fi
        """
    }
}
