# STM32 embedded C development in Neovim

How this Neovim config is set up to replace STM32CubeIDE: clangd cross-compilation,
Cortex-M debugging over OpenOCD, and build/flash keybindings.

## What was changed

| File | Change |
|---|---|
| `lua/custom/plugins/lsp.lua` | Added `--query-driver=/opt/homebrew/bin/arm-none-eabi-*` to clangd's `cmd`, so clangd is allowed to query the ARM toolchain for system include paths. |
| `templates/stm32/.clangd` | New per-project template (see below). |
| `lua/custom/plugins/tests.lua` | Added a `cppdbg` (cpptools) DAP adapter and an "STM32: Attach via OpenOCD" launch config, alongside the existing `codelldb` config. |
| `lua/custom/plugins/toggleterm.lua` | Added `<leader>bb` (make) and `<leader>bf` (make flash). |
| `init.lua` | Registered `<leader>b` as a which-key group ("Build"). |

Tooling installed on this machine:
- **OpenOCD** — already present (`brew`), talks to your debug probe and runs a GDB server.
- **`compiledb`** — installed via Homebrew, generates `compile_commands.json` from a Makefile build. (`bear` was tried first but triggered a from-source Rust compiler bootstrap on this machine's Homebrew/macOS combo, so `compiledb` is used instead — no functional difference for our purposes.)
- **cpptools** — a Mason-managed package (auto-installs on Neovim startup now that it's in `lsp.lua`'s `ensure_installed`), used as the DAP adapter that speaks GDB/MI to OpenOCD.

## Scaffolding a new project (STM32F3Discovery, bare CMSIS)

For a fresh project targeting this exact board, there's a one-command skeleton generator:

```sh
~/.config/nvim/templates/stm32/new-f3discovery-project.sh <project-name> [parent-dir]
```

It creates `<parent-dir>/<project-name>/` containing:

- **CMSIS headers** (ARM core + STM32F303xC device) and **`system_stm32f3xx.c`** — vendored from STMicroelectronics' official `STM32CubeF3` and `cmsis_device_f3` repos, not hand-written.
- **`startup_stm32f303xc.s`** and **`STM32F303VCTx_FLASH.ld`** — the real startup file and board-specific linker script from ST's own `Projects/STM32F3-Discovery/Templates/SW4STM32/` project (correct FLASH/RAM/CCMRAM layout for the VCT6, not guessed).
- **`Core/Src/syscalls.c`** and **`Core/Src/sysmem.c`** — your existing CubeIDE-generated versions.
- **`Core/Src/main.c`** — a minimal bare-register blink of LD3 (PE8), no HAL/LL involved, so you can see the whole boot path (reset handler → `SystemInit()` → `main()`) with nothing hidden.
- **`Makefile`** — builds `.elf`/`.hex`/`.bin` for Cortex-M4F (`-mfpu=fpv4-sp-d16 -mfloat-abi=hard`, matches the F303's hardware FPU), plus a `flash` target using `openocd -f board/stm32f3discovery.cfg`.
- **`.clangd`** and **`.gitignore`** already in place.

The script also runs an initial `make` + `compiledb make` for you, so the project is fully buildable and clangd-ready the moment it's created — no manual setup steps afterward. This whole flow (vendored files, generated skeleton, and the resulting build) was test-built end-to-end before being handed to you: `arm-none-eabi-gcc` compiled and linked cleanly, and the produced `.elf`'s vector table was checked byte-for-byte (initial stack pointer `0x2000A000` matching `_estack`, entry point matching `Reset_Handler`).

**If you outgrow bare-metal for a specific peripheral** (USB, RTC, etc.), HAL or LL sources can be vendored in later the same way (`stm32f3xx_hal_driver` / same repo's `Templates_LL`) — nothing about this skeleton locks you out of that.

## One-time setup for an existing STM32 project

If you didn't use the scaffold script above (e.g. a project ported from CubeIDE), do this by hand:

1. **Generate `compile_commands.json`** so clangd can see your actual build flags, defines, and include paths:
   ```sh
   compiledb make
   ```
   Re-run this whenever you add/remove source files or change build flags. Commit `compile_commands.json` to `.gitignore`, not to git — it's machine/build-specific.

2. **Drop in the `.clangd` config**: copy the template into your project root, next to the Makefile:
   ```sh
   cp ~/.config/nvim/templates/stm32/.clangd /path/to/your/stm32/project/.clangd
   ```
   Open the copy and check:
   - `Compiler: arm-none-eabi-gcc` — leave as-is.
   - If `compile_commands.json` isn't in the project root (e.g. it's generated into a `build/` subdirectory), uncomment and set `CompilationDatabase: build`.

3. **OpenOCD target config** — you're on the **STM32F3Discovery** (STM32F303VCT6, onboard ST-Link, SWD). OpenOCD ships a board file that wires up the probe and target correctly for it, so there's nothing to fill in:
   ```sh
   openocd -f board/stm32f3discovery.cfg
   ```
   This is already what's referenced in `tests.lua`. If you ever move to different hardware, swap this for a matching `interface/*.cfg` + `target/*.cfg` (or board file) pair — see `/opt/homebrew/Cellar/open-ocd/*/share/openocd/scripts/{interface,target,board}/` for what's available.

   Optional: add it as a Makefile target (e.g. `make openocd`) so you don't have to retype the command each session.

## Daily workflow

### Editing

Nothing new to learn — clangd now understands the cross-compiled code as long as `compile_commands.json` exists and `.clangd` is in place. Go-to-definition (`gd`), references (`gR`), diagnostics (`<leader>d`), hover (`K`), etc. all work as they do for any other C project in this config.

### Building and flashing

| Keybinding | Action |
|---|---|
| `<leader>bb` | Runs `make` in a horizontal terminal split (focus stays in the terminal so you see errors immediately). |
| `<leader>bf` | Runs `make flash` the same way. |

These assume Neovim was opened at the project root (where the Makefile lives) and that your Makefile has `make` and `make flash` targets — standard for STM32CubeIDE/CubeMX-generated Makefile projects.

### Debugging on the chip

Debugging happens in two steps: start OpenOCD (once per debug session, stays running), then attach with nvim-dap.

1. **Start OpenOCD** in a terminal split (`<leader>Th` for horizontal, `<leader>Tv` for vertical, `<leader>Tf` for float):
   ```sh
   openocd -f board/stm32f3discovery.cfg
   ```
   Wait for `Info : Listening on port 3333 for gdb connections`. Leave this terminal running — it stays up for the whole debug session. Make sure the board is plugged in via its USB ST-Link port (not just the USB user port) — that's what exposes the debug interface.

2. **Set breakpoints** in your code with `<leader>db` (toggle) or `<leader>dB` (conditional breakpoint).

3. **Start debugging** with `<leader>dc` (or `F1`). Since there are now two possible debug configs for C/C++, you'll be prompted to pick one:
   - **Launch executable** / **Attach to process** — the existing codelldb configs, for debugging native (Mac-compiled) C/C++ binaries. Not what you want here.
   - **STM32: Attach via OpenOCD** — pick this one. It will:
     - prompt for the path to your `.elf` file (defaults to `<project>/build/`),
     - connect to OpenOCD on `localhost:3333` via `arm-none-eabi-gdb`,
     - reset and halt the target, flash the ELF (`load`), then reset and halt again so you start from a known state.

4. **Step through code**:
   | Key | Action |
   |---|---|
   | `F1` / `<leader>dc` | Continue |
   | `F2` | Step over |
   | `F3` | Step into |
   | `F4` | Step out |
   | `<leader>du` | Toggle the DAP UI (variables, breakpoints, call stack, watches) — opens/closes automatically on session start/stop too |
   | `<leader>dr` | Open the debug REPL (can type raw gdb commands here) |
   | `<leader>dl` | Re-run the last debug config (skips the picker) |
   | `<leader>dq` | Terminate the debug session |

5. When you're done, `<leader>dq` to stop the DAP session, then `Ctrl-\` or your terminal toggle key to close the OpenOCD terminal (or `Ctrl-C` inside it).

**If you'd rather flash only via `<leader>bf`** and just attach (not reflash) when you start a debug session, remove the `load` line from `postRemoteConnectCommands` in `tests.lua` — keep the two `monitor reset halt` lines to still reset and halt the target on attach.

### Debug console output: ITM/SWO vs ARM semihosting

`main.c`'s `printf` normally goes out over **ITM/SWO** — `syscalls.c`'s `_write` calls `ITM_SendChar()`. For semihosted `printf` (output shows up directly in gdb's console instead), the Makefile has a build-mode toggle:

```sh
make                  # default: ITM/SWO printf via syscalls.c
make SEMIHOSTING=1    # semihosted printf via librdimon, needs a live debugger
```

**Why this needs to be a separate build, not just an extra linker flag**: `librdimon` (the semihosting library) bundles its `_close`/`_lseek`/`_open`/`_isatty`/`_unlink`/`_times`/`initialise_monitor_handles` into a single archive object as *strong* symbols — the same names `syscalls.c` defines. Linking both together fails outright:

```
multiple definition of `_lseek'; ... first defined here
multiple definition of `_close'; ...
multiple definition of `_open'; ...
multiple definition of `initialise_monitor_handles'; ...
multiple definition of `_unlink'; ...
multiple definition of `_times'; ...
multiple definition of `_isatty'; ...
```

(I hit this and verified it directly before writing this toggle.) So `SEMIHOSTING=1`:
- **Excludes `Core/Src/syscalls.c`** from the build entirely (`Core/Src/sysmem.c` stays either way — its `_sbrk` is a strong symbol that safely overrides `librdimon`'s weak default, so heap allocation keeps its stack-collision safety check regardless of mode).
- Swaps `LIBS`/`LDFLAGS` to `-specs=rdimon.specs` (which injects `librdimon` and `libc` itself — don't add `-lrdimon` manually) instead of `-lnosys`.
- Builds into `build-semihost/` instead of `build/`, so switching modes back and forth never needs a `make clean` first and never mixes stale objects from the other mode.

With `syscalls.c` excluded, `librdimon` provides real implementations rather than colliding with them — verified by symbol size: `initialise_monitor_handles` is 12 bytes (empty stub) in the default build vs. 188 bytes (real implementation) with `SEMIHOSTING=1`, and `_write`/`_read` resolve to real semihosting calls instead of ITM.

Already wired up for this mode, regardless of which one is active:
- **`monitor arm semihosting enable`** in `postRemoteConnectCommands` (`tests.lua`) — runs on every debug session. Harmless when unused: it just tells OpenOCD to trap the semihosting instruction instead of faulting on it.
- **`extern void initialise_monitor_handles(void);`** + a call to it at the top of `main()` in the vendored template — a no-op in the default build, the real handshake call under `SEMIHOSTING=1`.

**Trade-offs**: ITM/SWO is faster (trace output, not a CPU-halting trap per character) and doesn't require a live debugger to produce output. Semihosting is slower and *only* works while a debugger is attached with semihosting enabled — flashed and run standalone (no debugger), semihosting calls will hang. Default to ITM; reach for `make SEMIHOSTING=1` when you specifically need `printf` visible in gdb's console during a debug session.

When debugging with `SEMIHOSTING=1`, remember the DAP config's default ELF-path prompt still suggests `<project>/build/` — point it at `build-semihost/firmware.elf` instead.

## Troubleshooting

- **clangd shows errors on HAL/CMSIS headers, or "unknown argument" errors mentioning ARM-specific flags** — usually means `.clangd` isn't in the project root, or `compile_commands.json` is stale/missing. Re-run `compiledb make` and check `:LspInfo` in Neovim to confirm which config it picked up.
- **clangd complains it doesn't trust the compiler** — the `--query-driver` glob in `lsp.lua` must match the full path of `arm-none-eabi-gcc` on your machine. Confirm with `which arm-none-eabi-gcc`; if it's not under `/opt/homebrew/bin/`, update the glob in `lsp.lua`.
- **nvim-dap can't connect / hangs on "STM32: Attach via OpenOCD"** — make sure OpenOCD is actually running and printed "Listening on port 3333 for gdb connections" *before* you start the debug session. If the port's in use, another OpenOCD instance is probably already running (check with `lsof -i :3333`).
- **`cppdbg` adapter not found** — cpptools hasn't finished installing via Mason yet. Run `:Mason` in Neovim and check its status, or `:MasonInstall cpptools` to force it.
- **Wrong `.elf` path when prompted** — the default guess is `<project>/build/`; adjust to wherever your Makefile actually outputs the ELF.
