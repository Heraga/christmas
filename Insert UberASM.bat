@echo off

pushd uberasm
UberASMTool.exe "..\list_uberasm.txt" "..\a2xtgaidengaiden.smc"
del "..\a2xtgaidengaiden.extmod"
popd
