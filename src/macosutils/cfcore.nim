import chronicles

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
  FSEventStreamRef* = distinct pointer
  FSEventStreamEventId* = culonglong
  CFStringEncoding = uint32

  # FSEventStreamEventFlags* = culong
  dispatch_semaphore_t* = distinct pointer
  
  FSEventStreamCreateFlags* = enum
    kFSEventStreamCreateFlagUseCFTypes
    kFSEventStreamCreateFlagNoDefer
    kFSEventStreamCreateFlagWatchRoot
    kFSEventStreamCreateFlagIgnoreSelf
    kFSEventStreamCreateFlagFileEvents
    kFSEventStreamCreateFlagMarkSelf
    kFSEventStreamCreateFlagFullHistory
    kFSEventStreamCreateFlagUseExtendedData
    kFSEventStreamCreateWithDocID

  FSEventStreamEventFlags* = enum
    kFSEventStreamEventFlagMustScanSubDirs
    kFSEventStreamEventFlagUserDropped
    kFSEventStreamEventFlagKernelDropped
    kFSEventStreamEventFlagEventIdsWrapped
    kFSEventStreamEventFlagHistoryDone
    kFSEventStreamEventFlagRootChanged
    kFSEventStreamEventFlagMount
    kFSEventStreamEventFlagUnmount
    kFSEventStreamEventFlagItemChangeOwner
    kFSEventStreamEventFlagItemCreated
    kFSEventStreamEventFlagItemFinderInfoMod
    kFSEventStreamEventFlagItemInodeMetaMod
    kFSEventStreamEventFlagItemIsDir
    kFSEventStreamEventFlagItemIsFile
    kFSEventStreamEventFlagItemIsHardlink
    kFSEventStreamEventFlagItemIsLastHardlink
    kFSEventStreamEventFlagItemIsSymlink
    kFSEventStreamEventFlagItemModified
    kFSEventStreamEventFlagItemRemoved
    kFSEventStreamEventFlagItemRenamed
    kFSEventStreamEventFlagItemXattrMod
    kFSEventStreamEventFlagOwnEvent
    kFSEventStreamEventFlagItemCloned

  FSEventStreamContext* {.pure, final.} = object
    version*: CFIndex
    info*: pointer
    retain*: pointer
    release*: pointer
    copyDescription*: pointer

const
  kCFStringEncodingUTF8* = CFStringEncoding(0x08000100'u64)
  kCFRunLoopRunTimedOut* = 3
  kFSEventStreamEventIdSinceNow* = 0xFFFFFFFFFFFFFFFF'u64

  kFSEventStreamCreateFlagNone*: set[FSEventStreamCreateFlags] = {}
  kFSEventStreamEventFlagNone*: set[FSEventStreamEventFlags] = {}
  
let kCFRunLoopDefaultMode* {.importc, extern: "kCFRunLoopDefaultMode".}: CFRunLoopMode

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

proc createDefaultCFAllocator*(): CFAllocatorRef =
  proc dmonCfMalloc(allocSize: CFIndex, hint: CFOptionFlags, info: pointer): pointer {.cdecl.} =
    trace "dmonCfMalloc ", allocSize = allocSize
    result = alloc(allocSize.csize_t)

  proc dmonCfFree(pt: pointer, info: pointer) {.cdecl.} =
    trace "dmonCfFree ", info = info.repr
    if pt != nil:
      dealloc(pt)

  proc dmonCfRealloc(pt: pointer, newsize: CFIndex, hint: CFOptionFlags, 
                    info: pointer): pointer {.cdecl.} =
    trace "dmonCfRealloc ", newsize = newsize, info = info.repr
    result = realloc(pt, newsize.csize_t)

  var ctx = CFAllocatorContext(
    version: 0,
    info: nil,
    retain: nil,
    release: nil,
    copyDescription: nil,
    allocate: dmonCfMalloc,
    reallocate: dmonCfRealloc,
    deallocate: dmonCfFree,
    preferredSize: nil
  )
  
  result = CFAllocatorCreate(nil.CFAllocatorRef, addr ctx)

# CoreFoundation Functions
proc CFArrayCreate*(alloc: CFAllocatorRef, values: ptr pointer, numValues: CFIndex, callbacks: pointer): CFArrayRef {.importc.}
proc CFRunLoopGetCurrent*(): CFRunLoopRef {.importc.}
proc CFRunLoopRunInMode*(mode: CFRunLoopMode, seconds: CFTimeInterval, returnAfterSourceHandled: bool): cint {.importc.}
proc CFRunLoopStop*(loop: CFRunLoopRef) {.importc.}

# FSEvents Functions
proc FSEventStreamCreate*(
  allocator: CFAllocatorRef, 
  callback: proc (
    streamRef: FSEventStreamRef,
    clientCallBackInfo: pointer,
    numEvents: csize_t,
    eventPaths: pointer,
    # eventFlags: ptr set[FSEventStreamEventFlags],
    eventFlags: UncheckedArray[set[FSEventStreamEventFlags]],
    eventIds: UncheckedArray[FSEventStreamEventId],
  ) {.cdecl.},
  context: ptr FSEventStreamContext,
  pathsToWatch: CFArrayRef,
  sinceWhen: FSEventStreamEventId,
  latency: CFTimeInterval,
  flags: set[FSEventStreamCreateFlags]
): FSEventStreamRef {.importc.}

proc FSEventStreamScheduleWithRunLoop*(
  streamRef: FSEventStreamRef,
  runLoop: CFRunLoopRef,
  runLoopMode: CFRunLoopMode
) {.importc.}

proc FSEventStreamStart*(streamRef: FSEventStreamRef): bool {.importc.}
proc FSEventStreamStop*(streamRef: FSEventStreamRef) {.importc.}
proc FSEventStreamInvalidate*(streamRef: FSEventStreamRef) {.importc.}
proc FSEventStreamRelease*(streamRef: FSEventStreamRef) {.importc.}

when isMainModule: