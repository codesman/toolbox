import libc
import Console
import Foundation
import VaporToolbox

let version = "0.8.0"

let terminal = Terminal(arguments: Process.arguments)

var iterator = Process.arguments.makeIterator()

guard let executable = iterator.next() else {
    throw ConsoleError.noExecutable
}

do {
    try terminal.run(executable: executable, commands: [
        New(console: terminal),
        Build(console: terminal),
        Run(console: terminal),
        Fetch(console: terminal),
        Clean(console: terminal),
        Test(console: terminal),
        Xcode(console: terminal),
        Version(console: terminal, version: version),
        Group(id: "self", commands: [
            SelfInstall(console: terminal, executable: executable, version: version),
            SelfUpdate(console: terminal, executable: executable),

        ], help: [
            "Commands that affect the toolbox itself."
        ]),
        Group(id: "heroku", commands: [
            HerokuInit(console: terminal),
            HerokuPush(console: terminal),
        ], help: [
            "Commands to help deploy to Heroku."
        ]),
        Group(id: "docker", commands: [
            DockerInit(console: terminal),
            DockerBuild(console: terminal),
            DockerRun(console: terminal),
            DockerEnter(console: terminal)
        ], help: [
            "Commands to help manage a Docker image."
        ])
    ], arguments: Array(iterator), help: [
        "Join our Slack if you have questions, need help,",
        "or want to contribute: http://slack.qutheory.io"
    ])
} catch ToolboxError.general(let message) {
    terminal.error("Error: ", newLine: false)
    terminal.print(message)
    exit(1)
} catch ConsoleError.insufficientArguments {
    terminal.error("Error: ", newLine: false)
    terminal.print("Insufficient arguments.")
} catch ConsoleError.help {
    exit(0)
} catch ConsoleError.cancelled {
    print("Cancelled")
    exit(2)
} catch ConsoleError.noCommand {
    terminal.error("Error: ", newLine: false)
    terminal.print("No command supplied.")
} catch ConsoleError.commandNotFound(let id) {
    terminal.error("Error: ", newLine: false)
    terminal.print("Command \"\(id)\" not found.")
} catch {
    terminal.error("Error: ", newLine: false)
    terminal.print("\(error)")
    exit(1)
}
