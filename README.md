# 🟢 Slime Soccer

A 2-player local slime soccer game built with [Processing](https://processing.org/).
*Some art work made by claude.

---

## 🎮 Gameplay

Two slimes face off on a soccer field. First to score the target number of goals wins!

- **Double jump**, **dash**, and **fast fall** to outmaneuver your opponent
- Landing with fast fall sends out a **shockwave** that launches the ball
- Adjust the winning score (1–10) from the title screen

---

## 🕹️ Controls

|  | P1 (Green) | P2 (Blue) |
|---|---|---|
| Move | `A` / `D` | `← / →` |
| Jump (×2) | `W` | `↑` |
| Fast Fall(HardLand) | `S` | `↓` |
| Dash | `L-Shift` | `Enter` |

---

## ✨ Features

- Sprite sheet animation (Idle / Walk / Dash / Jump / Double Jump / Hard Land)
- Landing shockwave effect with dust particles
- Dash cooldown UI
- Score tracker with win condition
- Intro screen with goal selector
- Game Over screen with Play Again / Main Menu

---

## 🚀 How to Run

1. Install [Processing 4](https://processing.org/download)
2. Open `SlimeSoccer.pde`
3. Click **Run** (or press `Ctrl+R`)

---

## 📁 Project Structure

```
SlimeSoccer/
├── SlimeSoccer.pde   # Main sketch (setup, draw, input)
├── Slime.pde         # Slime physics & animation
├── Ball.pde          # Ball physics & collision
├── Goal.pde          # Goal post collision & scoring
├── Hud.pde           # Score & cooldown UI
├── Screens.pde       # Intro & Game Over screens
└── data/
    ├── bg1.png
    ├── goal.png
    └── slime_grid_200.png  (+ 100/300/400 variants)
```
