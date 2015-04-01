name = Module
lowername = module

all:
	swiftc -emit-library -emit-object $(name).swift -module-name $(name)
	ar -rcs libmodule.a $(name).o
	swiftc -emit-module $(name).swift -module-name $(name)
executable:
	swiftc -I . -L . -l$(lowername) main.swift
clean:
	rm lib$(lowername).a $(name).swiftdoc $(name).swiftmodule $(name).o
