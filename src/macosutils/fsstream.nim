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

proc createBasicDefaultCFAllocator*(): CFAllocatorRef =
  ## creates a simple alloctor using Nim's standard allocators
  proc dmonCfMalloc(allocSize: CFIndex, hint: CFOptionFlags, info: pointer): pointer {.cdecl.} =
    result = allocShared0(allocSize.csize_t)

  proc dmonCfFree(pt: pointer, info: pointer) {.cdecl.} =
    if pt != nil:
      deallocShared(pt)

  proc dmonCfRealloc(pt: pointer, newsize: CFIndex, hint: CFOptionFlags, 
                    info: pointer): pointer {.cdecl.} =
    result = reallocShared(pt, newsize.csize_t)

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

