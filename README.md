# My Arch Config for Thinkpad T480 ✨

Welcome to my minimal, fast, and fully functional Arch Linux configuration optimized for the Thinkpad T480. This setup is built on X11 with a lightweight, tiling window manager (bspwm) and a suite of carefully chosen utilities that keep the system responsive while delivering a beautiful user experience.

![Screenshot 1](./screenshots/screenshot1.png)
![Screenshot 2](./screenshots/screenshot2.png)

## Table of Contents
- [Display & Window Management](#display--window-management)
- [Shortcut Manager](#shortcut-manager)
- [Notifications & Screenshots](#notifications--screenshots)
- [Aesthetics](#aesthetics)
- [Utilities](#utilities)
- [Credits](#credits)

---

## Display & Window Management 🖥️🪟

- **Display Manager:** X11  
  The configuration uses X11 for display management, ensuring stability and compatibility.

- **Window Manager:** [bspwm](https://github.com/baskerville/bspwm)  
  A dynamic tiling window manager that maximizes screen real estate while remaining minimal.

---

## Shortcut Manager ⌨️

- **Shortcut Manager:** [sxhkd](https://github.com/baskerville/sxhkd)  
  A simple, powerful daemon for handling keyboard shortcuts.

- **BSPWM Shortcuts:**  
  The following shortcuts are configured to streamline your workflow:

| Shortcut                                     | Description                                          |
|----------------------------------------------|------------------------------------------------------|
| **Super + Return**                           | Open terminal (Kitty)                                |
| **Super + P**                                | Launch application menu (rofi -show drun)            |
| **Super + Escape**                           | Reload sxhkd configuration                           |
| **Super + Alt + R**                          | Quit/Restart bspwm                                   |
| **Super + Q**                                | Close or kill focused window                         |
| **Super + M**                                | Toggle between tiled and monocle layouts             |
| **Super + T**                                | Toggle tiled mode                                    |
| **Super + Shift + T**                        | Toggle pseudo-tiled mode                             |
| **Super + F**                                | Toggle floating mode                                 |
| **Super + S**                                | Toggle fullscreen mode                               |
| **Super + Left/Down/Up/Right**               | Focus adjacent window in specified direction         |
| **Super + Shift + Left/Down/Up/Right**       | Swap window with adjacent window                     |
| **Super + 1-9/0**                            | Focus or send window to the specified desktop        |
| **Super + Alt + Left/Right**                 | Navigate to previous/next desktop on current monitor |
| **Super + Right Mouse**                      | Move floating window                                 |
| **Super + Left Mouse**                       | Resize floating window                               |
| **Super + Alt + Ctrl + Arrows**              | Expand/contract window                               |

---

## Notifications & Screenshots 💬📸

- **Notification Manager:** [dunst](https://github.com/dunst-project/dunst)  
  A lightweight daemon to handle notifications.

- **Screenshot Manager:** [scrot](https://github.com/resurrecting-open-source-projects/scrot)  
  A fast and simple screenshot utility.

---

## Aesthetics 🎨

- **Wallpaper Manager:** [pywal](https://github.com/dylanaraps/pywal)  
  Dynamic theming based on your wallpaper for a cohesive look.

- **App Launcher:** [rofi](https://github.com/davatorium/rofi)  
  A flexible and powerful launcher for your applications.

- **Status Bar:** [polybar](https://github.com/polybar/polybar)  
  A modular and visually appealing status bar.

- **Lockscreen:** [betterlockscreen](https://github.com/betterlockscreen/betterlockscreen)  
  A clean and efficient lockscreen solution.

- **Compositor:** [picom](https://github.com/yshui/picom)  
  Provides window transparency and smooth animations.

- **Fonts:**
  - **JetBrains Mono:** [ttf-jetbrains-mono](https://www.jetbrains.com/lp/mono/) for a modern, legible coding experience.
  - **Material Design Icons:** [ttf-material-design-icons-desktop-git](https://pictogrammers.com/library/mdi/) for crisp icons in Polybar and other UI elements.

---

## Utilities 🛠️

- **Terminal:** [Kitty](https://github.com/kovidgoyal/kitty)  
  A fast, feature-rich GPU-based terminal emulator.

- **Shell:** [Zsh](https://www.zsh.org/)  
  An enhanced shell with powerful features and customization options.

---

## Credits 🌟

- **Inspiration & Configuration:**
  - [verttj/dotfiles-ltint](https://github.com/verttj/dotfiles-ltint) – Provided inspiration for the Polybar configuration.
  - [ericmurphyxyz/rofi-wifi-menu](https://github.com/ericmurphyxyz/rofi-wifi-menu) – Rofi WiFi menu configuration.

Feel free to explore, tweak, and build upon this configuration to suit your needs. Enjoy your minimal Arch experience on the Thinkpad T480!
