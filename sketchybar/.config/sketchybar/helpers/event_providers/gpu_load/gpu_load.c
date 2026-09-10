#include "gpu.h"
#include "../sketchybar.h"

int main (int argc, char** argv) {
  float update_freq;
  if (argc < 3 || (sscanf(argv[2], "%f", &update_freq) != 1)) {
    printf("Usage: %s \"<event-name>\" \"<event_freq>\"\n", argv[0]);
    exit(1);
  }

  alarm(0);
  struct gpu gpu;
  gpu_init(&gpu);

  // Setup the event in sketchybar
  char event_message[512];
  snprintf(event_message, 512, "--add event '%s'", argv[1]);
  sketchybar(event_message);

  // First read populates the baseline; no event is sent so the widget keeps
  // showing ??% until valid data is ready.
  gpu_update(&gpu);
  usleep(update_freq * 1000000);

  char trigger_message[512];
  for (;;) {
    // Acquire new info
    gpu_update(&gpu);

    // Prepare the event message
    snprintf(trigger_message,
             512,
             "--trigger '%s' device_load='%d' renderer_load='%02d' tiler_load='%02d'",
             argv[1],
             gpu.device_load,
             gpu.renderer_load,
             gpu.tiler_load                                        );

    // Trigger the event
    sketchybar(trigger_message);

    // Wait
    usleep(update_freq * 1000000);
  }
  return 0;
}
