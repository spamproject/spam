import CommandLine // jatoben/CommandLine

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
let helpOption = BoolOption(shortFlag: "h", longFlag: "help",
    helpMessage: "Display this help message and exit.")
cli.addOptions(installOption, compileOption, buildOption,
               outputOption, uninstallOption, helpOption)

let (success, error) = cli.parse()
if (!success) {
    println(error!)
    cli.printUsage()
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
