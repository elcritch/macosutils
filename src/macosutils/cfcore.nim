
{.passL: "-framework CoreFoundation".}

type
  CFStringRef* = distinct pointer
  CFAllocatorRef* = distinct pointer
  CFIndex* = clong
  CFTypeRef* = distinct pointer
  CFTimeInterval* = cdouble
  CFArrayRef* = distinct pointer

type
  CFRunLoopRef* = distinct pointer
  CFRunLoopMode* = distinct pointer
  CFStringEncoding = uint32

const
  kCFStringEncodingUTF8* = CFStringEncoding(0x08000100'u64)
  kCFRunLoopRunTimedOut* = 3

let
  kCFRunLoopDefaultMode* {.importc, extern: "kCFRunLoopDefaultMode".}: CFRunLoopMode

template implEnumBases*[B; E: enum](enums: typedesc[E], base: typedesc[B]) =
  ## helps generate pairings for enum and base types
  proc enumBase*(tp: typedesc[E]): B {.compileTime.} =
    discard
  proc enumSet*(tp: typedesc[B]): E {.compileTime.} =
    discard

template toBase*[F: enum](flags: set[F]): auto =
  ## cast to base flag type automatically when a `enumBase` proc is provide
  cast[typeof(enumBase(F))](flags)

template toSet*[I](value: I): auto =
  cast[set[typeof(enumSet(I))]](value)

import std/typetraits
template intBase*[I](value: I): auto =
  distinctBase(I)(value)

# Core Foundation Functions
proc CFStringCreateWithCString*(
  alloc: CFAllocatorRef, 
  cStr: cstring,
  encoding: CFStringEncoding
): CFStringRef {.importc.}

proc CFStringGetLength*(theString: CFStringRef): CFIndex {.importc.}

proc CFStringGetCString*(
  theString: CFStringRef,
  buffer: cstring,
  bufferSize: CFIndex,
  encoding: CFStringEncoding
): bool {.importc.}

proc CFRelease*(cf: pointer) {.importc.}

proc toCFString*(s: string): CFStringRef =
  ## Converts a Nim string to a CFStringRef
  ## Note: The caller is responsible for calling CFRelease on the returned CFStringRef
  result = CFStringCreateWithCString(nil.CFAllocatorRef, s.cstring, kCFStringEncodingUTF8)

proc toString*(cfStr: CFStringRef): string =
  ## Converts a CFStringRef to a Nim string
  let length = CFStringGetLength(cfStr)
  var buffer = newString(length + 1)
  if CFStringGetCString(cfStr, buffer.cstring, length + 1, kCFStringEncodingUTF8):
    result = buffer
    result.setLen(length)
  else:
    result = ""


type
  # Function pointer types for the allocator callbacks
  CFAllocatorAllocateCallBack* = proc(allocSize: CFIndex, hint: CFOptionFlags, info: pointer): pointer {.cdecl.}
  CFAllocatorDeallocateCallBack* = proc(pt: pointer, info: pointer) {.cdecl.}
  CFAllocatorReallocateCallBack* = proc(pt: pointer, newsize: CFIndex,
                                       hint: CFOptionFlags, info: pointer): pointer {.cdecl.}
  CFAllocatorPreferredSizeCallBack* = proc(size: CFIndex, hint: CFOptionFlags,
                                          info: pointer): CFIndex {.cdecl.}
  CFAllocatorRetainCallBack* = proc(info: pointer): pointer {.cdecl.}
  CFAllocatorReleaseCallBack* = proc(info: pointer) {.cdecl.}
  CFAllocatorCopyDescriptionCallBack* = proc(info: pointer): CFStringRef {.cdecl.}

  CFOptionFlags* = culong

  CFAllocatorContext* {.bycopy.} = object
    version*: CFIndex
    info*: pointer
    retain*: CFAllocatorRetainCallBack
    release*: CFAllocatorReleaseCallBack
    copyDescription*: CFAllocatorCopyDescriptionCallBack
    allocate*: CFAllocatorAllocateCallBack
    reallocate*: CFAllocatorReallocateCallBack
    deallocate*: CFAllocatorDeallocateCallBack
    preferredSize*: CFAllocatorPreferredSizeCallBack

# Import the Core Foundation function
proc CFAllocatorCreate*(allocator: CFAllocatorRef, context: ptr CFAllocatorContext): CFAllocatorRef {.
  importc, cdecl.}

# Implementation of the allocator callbacks

# Example usage:
#[
]#

# CoreFoundation Functions
proc CFArrayCreate*(alloc: CFAllocatorRef, values: ptr pointer, numValues: CFIndex, callbacks: pointer): CFArrayRef {.importc.}

proc CFRunLoopGetCurrent*(): CFRunLoopRef {.importc.}
proc CFRunLoopRunInMode*(mode: CFRunLoopMode, seconds: CFTimeInterval, returnAfterSourceHandled: bool): cint {.importc.}
proc CFRunLoopStop*(loop: CFRunLoopRef) {.importc.}
