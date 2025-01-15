import cfcore

type
  FSEventStreamRef* = distinct pointer
  FSEventStreamEventId* = culonglong
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
  kFSEventStreamEventIdSinceNow* = 0xFFFFFFFFFFFFFFFF'u64

  kFSEventStreamCreateFlagNone*: set[FSEventStreamCreateFlags] = {}
  kFSEventStreamEventFlagNone*: set[FSEventStreamEventFlags] = {}
  
let kCFRunLoopDefaultMode* {.importc, extern: "kCFRunLoopDefaultMode".}: CFRunLoopMode

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
