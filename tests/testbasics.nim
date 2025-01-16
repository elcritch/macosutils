# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import std/strutils

import macosutils/cfcore
import macosutils/fsstream

suite "macos utils":
  test "CFString":
    # Example usage with proper cleanup:
    let nimStr = "Hello, World!"
    let cfStr = nimStr.toCFString()
    echo "nimStr: ", nimStr.repr
    echo "cfStr: ", cfStr.repr
    defer: CFRelease(cfStr.pointer)  # Clean up the CFStringRef
    
    let backToNim = cfStr.toString()
    echo "backToNim: ", backToNim.repr  # Prints: Hello, World!
    check backToNim == nimStr

  test "cf allocator":

    # Function to create the allocator
    let cfAllocRef = createBasicDefaultCFAllocator()
    echo "cfAllocRef: ", cfAllocRef.repr
    check not cfAllocRef.pointer.isNil

  test "fstream enums":

    let
      f1: FSEventStreamEventFlags = {MustScanSubDirs}.toBase()
      s1: set[FSEventStreamEventFlag] = f1.toSet()

    # check FSEventStreamEventFlag
    check {MustScanSubDirs}.toBase().intBase.toHex() ==   "00000001"
    check {ItemIsFile}.toBase().intBase.toHex() ==        "00010000"
    check {ItemIsDir}.toBase().intBase.toHex() ==         "00020000"
    check {ItemFinderInfoMod}.toBase().intBase.toHex() == "00002000"
    check {ItemIsSymlink}.toBase().intBase.toHex() == "00040000"



