# Hyperland System

A personal Linux distro (Arch Linux base) built to **run Windows `.exe` apps and games** on
**NVIDIA GPUs**, with the [Hyprland](https://hypr.land) Wayland desktop.

| Layer | What's used |
|---|---|
| Windows apps | Wine + DXVK (DX9–11 → Vulkan) + VKD3D-Proton (DX12) + VC++ 2022, auto-set-up on first login |
| Games | Steam (Proton), Lutris, GameMode, MangoHud, Gamescope; Bottles via Flatpak |
| GPU | NVIDIA open kernel modules (`nvidia-open`), 32-bit libs, CUDA/OpenCL, VA-API, early KMS, suspend support |
| Desktop | Hyprland, Waybar, Wofi, Kitty, Thunar, PipeWire |

## Get the ISO

**Option A – GitHub (no Linux needed):** go to the repo's **Actions → Build ISO → Run workflow**. When it
finishes, download `hyperland-system-iso` from the run page (it's a zip containing the `.iso`).

**Option B – on an Arch machine:** `./build.sh` → ISO ends up in `out/`.

**Option C – Docker on any Linux:**
```sh
docker run --rm --privileged -v "$PWD:/repo" -w /repo archlinux \
  bash -c 'pacman -Syu --noconfirm archiso && ./build.sh'
```

Flash it to a USB stick with Rufus, balenaEtcher, or `dd`, then boot from it (UEFI, Secure Boot **off**).

## Use it

- The live USB auto-logs in as `live` and starts Hyprland, so you can try it before installing.
- **Install to disk:** open a terminal (`Super+Enter`) and run `sudo hl-install`. It asks for the disk,
  username, password, and timezone, and **wipes the chosen disk**.
- **Already on Arch?** Run `./install-on-arch.sh` instead of reinstalling.

### Running Windows programs
- Double-click any `.exe` / `.msi` in Thunar, **or**
- `hl-run setup.exe` (add `HL_HUD=1` for an FPS overlay), **or**
- `chmod +x app.exe && ./app.exe` (binfmt), **or**
- Games: Steam → Settings → Compatibility → *Enable Steam Play for all titles* (Proton).

The first login builds a Wine prefix with DXVK/VKD3D (this needs internet). Run `hl-wine-setup --force` to redo it.

### Keys
`Super+Enter` terminal · `Super+D` app launcher · `Super+E` files · `Super+B` Firefox · `Super+S` Steam ·
`Super+Q` close · `Super+F` fullscreen · `Super+V` float · `Super+1..9` workspaces · `Super+Shift+M` log out

## Limits (be aware)
- **GPU generation:** `nvidia-open` supports **GTX 16xx / RTX 20xx and newer**. For GTX 10xx and older,
  install `nvidia-580xx-dkms` + `nvidia-580xx-utils` from the AUR in place of `nvidia-open`.
- **Anti-cheat:** games using kernel anti-cheat (Valorant, some Battlefield/CoD titles, etc.) don't run
  on any Linux. Check [areweanticheatyet.com](https://areweanticheatyet.com) and [ProtonDB](https://www.protondb.com).
- Some apps (Adobe CC, new MS Office) work poorly or not at all under Wine. Check [WineHQ AppDB](https://appdb.winehq.org).
- The installer is UEFI-only, uses a single disk, and doesn't encrypt.

## Layout
```
build.sh               ISO builder (archiso "releng" + our changes)
packages.txt           Package set (used by ISO + installer)
overlay/               Files for every Hyperland system (configs, hl-* tools)
live/                  Live-USB-only files (auto-login user)
install-on-arch.sh     Convert an existing Arch install
.github/workflows/     CI ISO build
```
