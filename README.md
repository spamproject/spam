![Spam
Logo](https://cloud.githubusercontent.com/assets/4397642/7172786/46fc38b8-e3bb-11e4-8b7e-672957855b81.png)

Currently a work in progress.

Compiling
---------
Requires the latest stable version of Swift.

If you have an older version of spam already installed:
``` bash
cd spam
spam --install
spam --compile --output spam
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
