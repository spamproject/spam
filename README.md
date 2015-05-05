![Spam
Logo](https://cloud.githubusercontent.com/assets/4397642/7172786/46fc38b8-e3bb-11e4-8b7e-672957855b81.png)

spam is an exploratory Swift package manager, enabling the use of third-party
Swift modules outside the context of an iOS or OS X app! And it's dead simple to
use:

``` swift
import ModuleName // username/ModuleName
```

…is all spam needs in order to know where the module lives, how to compile it,
and how to integrate it with your own code. Then, simply run `spam --install` to
clone the module(s) from GitHub and `spam --compile` to build your project!

Compiling spam Itself
---------------------
Requires the latest stable version of Swift.

If you have an older version of spam already installed:
``` bash
cd spam
spam --build --output spam
```

Otherwise:
``` bash
cd spam
git checkout bootstrap
xcrun -sdk macosx swiftc *.swift -o spam
git checkout master
./spam install
./spam compile
```

Then put spam somewhere on your path, e.g. `mv spam /usr/local/bin`.
