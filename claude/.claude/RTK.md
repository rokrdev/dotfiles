# RTK - Rust Token Killer

Token-optimized CLI proxy (60-90% savings). All commands auto-routed via hook except meta commands.

## Meta Commands
```bash
rtk gain              # Token savings analytics
rtk gain --history    # Usage history + savings
rtk discover          # Analyze missed opportunities
rtk proxy <cmd>       # Raw command (debugging only)
```

## Verification
```bash
rtk --version         # Should show: rtk X.Y.Z
which rtk             # Verify correct binary
```

⚠️ **Name collision**: If `rtk gain` fails, check for reachingforthejack/rtk (Rust Type Kit) installed.
