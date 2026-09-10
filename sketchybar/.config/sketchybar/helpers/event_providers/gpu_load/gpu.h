#include <IOKit/IOKitLib.h>
#include <CoreFoundation/CoreFoundation.h>
#include <stdbool.h>
#include <unistd.h>
#include <stdio.h>

struct gpu {
  io_registry_entry_t service;
  int device_load;   /* "Device Utilization %"  */
  int renderer_load; /* "Renderer Utilization %" */
  int tiler_load;    /* "Tiler Utilization %"    */
};

static inline void gpu_init(struct gpu* gpu) {
  gpu->service = 0;
  gpu->device_load = 0;
  gpu->renderer_load = 0;
  gpu->tiler_load = 0;

  // Match the Apple GPU driver service. On Apple Silicon this is an
  // AGXAccelerator* node; IOAccelerator is its generic parent class and
  // also matches (and would match third-party AMD/Intel GPUs on Intel Macs).
  CFMutableDictionaryRef matching = IOServiceMatching("AGXAccelerator");
  if (!matching) return;

  io_service_t service = IOServiceGetMatchingService(kIOMainPortDefault, matching);
  if (service == IO_OBJECT_NULL) return;

  gpu->service = service;
}

static inline void gpu_update(struct gpu* gpu) {
  if (gpu->service == IO_OBJECT_NULL) return;

  // The AGX accelerator exposes its live counters as a CFDictionary under
  // the "PerformanceStatistics" key. Read it directly (no subprocess, no
  // root) -- this is the same data Activity Monitor's GPU graph uses.
  CFTypeRef perf =
    IORegistryEntryCreateCFProperty(gpu->service,
                                    CFSTR("PerformanceStatistics"),
                                    kCFAllocatorDefault,
                                    0);
  if (!perf) return;

  if (CFGetTypeID(perf) == CFDictionaryGetTypeID()) {
    CFDictionaryRef dict = (CFDictionaryRef)perf;

    CFNumberRef device = CFDictionaryGetValue(dict, CFSTR("Device Utilization %"));
    if (device && CFGetTypeID(device) == CFNumberGetTypeID()) {
      int value = 0;
      if (CFNumberGetValue(device, kCFNumberIntType, &value))
        gpu->device_load = value;
    }

    CFNumberRef renderer = CFDictionaryGetValue(dict, CFSTR("Renderer Utilization %"));
    if (renderer && CFGetTypeID(renderer) == CFNumberGetTypeID()) {
      int value = 0;
      if (CFNumberGetValue(renderer, kCFNumberIntType, &value))
        gpu->renderer_load = value;
    }

    CFNumberRef tiler = CFDictionaryGetValue(dict, CFSTR("Tiler Utilization %"));
    if (tiler && CFGetTypeID(tiler) == CFNumberGetTypeID()) {
      int value = 0;
      if (CFNumberGetValue(tiler, kCFNumberIntType, &value))
        gpu->tiler_load = value;
    }
  }

  CFRelease(perf);
}
