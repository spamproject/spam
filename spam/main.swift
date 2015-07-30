import CommandLine // jatoben/CommandLine:59816c0

let cli = CommandLine()
let installOption = BoolOption(shortFlag: "i", longFlag: "install", helpMessage:
          "Download all imported modules. For spam to detect the module's URL, it must be\n" +
    "      specified in the following manner:\n" +
    "          import ModuleName // username/ModuleName\n" +
    "      This will automatically clone the module from github.com/username/ModuleName.")
let compileOption = BoolOption(shortFlag: "c", longFlag: "compile",
    helpMessage: "Compile downloaded modules and local sources.")
let buildOption = BoolOption(shortFlag: "b", longFlag: "build",
    helpMessage: "Compile, installing if necessary.")
let outputOption = StringOption(shortFlag: "o", longFlag: "output", required: false,
    helpMessage: "Write output to <file>.")
let uninstallOption = BoolOption(shortFlag: "u", longFlag: "uninstall",
    helpMessage: "Completely remove the .spam directory.")
let verboseOption = CounterOption(shortFlag: "v", longFlag: "verbose",
    helpMessage: "Print each step to stdout. -v prints logical steps, and -vv\n" +
    "      prints physical steps.")
let helpOption = BoolOption(shortFlag: "h", longFlag: "help",
    helpMessage: "Display this help message and exit.")

cli.addOptions(installOption, compileOption, buildOption,
               outputOption, uninstallOption, verboseOption,
               helpOption)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if installOption.value {
    install()
} else if uninstallOption.value {
    uninstall()
} else if buildOption.value {
    build(outputFile: outputOption.value)
} else if compileOption.value {
    compile(outputFile: outputOption.value)
} else {
    cli.printUsage()
    exit(EX_USAGE)
}
