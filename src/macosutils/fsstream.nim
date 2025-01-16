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

  FSEventStreamEventFlags* {.pure.} = enum
    kFSEventStreamEventFlagMustScanSubDirs = 0      # 0x00000001 (1 << 0)
    kFSEventStreamEventFlagUserDropped = 1          # 0x00000002 (1 << 1)
    kFSEventStreamEventFlagKernelDropped = 2        # 0x00000004 (1 << 2)
    kFSEventStreamEventFlagEventIdsWrapped = 3      # 0x00000008 (1 << 3)
    kFSEventStreamEventFlagHistoryDone = 4          # 0x00000010 (1 << 4)
    kFSEventStreamEventFlagRootChanged = 5          # 0x00000020 (1 << 5)
    kFSEventStreamEventFlagMount = 6                # 0x00000040 (1 << 6)
    kFSEventStreamEventFlagUnmount = 7              # 0x00000080 (1 << 7)
    kFSEventStreamEventFlagItemCreated = 8          # 0x00000100 (1 << 8)
    kFSEventStreamEventFlagItemRemoved = 9          # 0x00000200 (1 << 9)
    kFSEventStreamEventFlagItemInodeMetaMod = 10    # 0x00000400 (1 << 10)
    kFSEventStreamEventFlagItemRenamed = 11         # 0x00000800 (1 << 11)
    kFSEventStreamEventFlagItemModified = 12        # 0x00001000 (1 << 12)
    kFSEventStreamEventFlagItemFinderInfoMod = 13   # 0x00002000 (1 << 13)
    kFSEventStreamEventFlagItemChangeOwner = 14     # 0x00004000 (1 << 14)
    kFSEventStreamEventFlagItemXattrMod = 15        # 0x00008000 (1 << 15)
    kFSEventStreamEventFlagItemIsFile = 16          # 0x00010000 (1 << 16)
    kFSEventStreamEventFlagItemIsDir = 17           # 0x00020000 (1 << 17)
    kFSEventStreamEventFlagItemIsSymlink = 18       # 0x00040000 (1 << 18)
    kFSEventStreamEventFlagOwnEvent = 19            # 0x00080000 (1 << 19)
    kFSEventStreamEventFlagItemIsHardlink = 20      # 0x00100000 (1 << 20)
    kFSEventStreamEventFlagItemIsLastHardlink = 21  # 0x00200000 (1 << 21)
    kFSEventStreamEventFlagItemCloned = 22          # 0x00400000 (1 << 22)

    


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
    eventFlags: ptr set[FSEventStreamEventFlags],
    eventIds: ptr FSEventStreamEventId,
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

