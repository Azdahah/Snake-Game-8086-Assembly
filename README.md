# 🐍 Snake Game – 8086 Assembly

A classic **Snake Game implemented in 8086 Assembly Language**.
This project demonstrates low-level programming concepts such as **BIOS interrupts, keyboard input handling, memory manipulation, timing, and direct video memory rendering**. The game updates the screen using a buffer and interacts directly with hardware features like the **PC speaker** for sound.

It is a simple but complete example of building a **real-time game using 8086 assembly**, including movement logic, collision detection, score tracking, and sound effects.

---

## 🎮 Features

* Classic Snake gameplay
* Arrow key movement controls
* Random food generation
* Score display system
* Game Over screen
* Sound effects using PC speaker
* Screen buffer rendering
* Bordered play area

---

## 🕹 Controls

| Key     | Action     |
| ------- | ---------- |
| ↑ Arrow | Move Up    |
| ↓ Arrow | Move Down  |
| ← Arrow | Move Left  |
| → Arrow | Move Right |
| ESC     | Exit Game  |

---

## ⚙️ Requirements

* NASM – to assemble the source code
* DOSBox – to run the compiled program

---

## ▶️ How to Run

### 1. Assemble the Program

Compile the assembly file:

```
nasm snake.asm -f bin -o snake.com
```

This will create the executable **snake.com**.

---

### 2. Run the Game

Start DOSBox and mount the folder containing the project.

Example:

```
mount c C:\snake
c:
snake.com
```

---

## 🧠 How the Game Works

The game uses a **buffer-based rendering system** where a memory buffer represents the screen.

Each frame of the game performs the following steps:

1. Read keyboard input using BIOS interrupt `INT 16h`
2. Update the snake’s direction
3. Move the snake head
4. Check collisions with walls, snake body, or food
5. Increase the score if food is eaten
6. Update the snake tail position
7. Render the buffer to video memory (`B800h`)

---

## 🔊 Sound

Sound effects are generated using the **PC speaker** by programming the **PIT timer** and controlling the speaker port (`61h`). Sounds play when:

* The snake eats food
* The game ends

---

## 📂 Project Structure

```
snake.asm   # Main assembly source code
README.md   # Project documentation
```

---

## 🎓 Concepts Demonstrated

* 8086 **16-bit assembly programming**
* BIOS interrupts
* Keyboard input handling
* Game loop design
* Collision detection
* Direct video memory access
* PC speaker sound generation
* Random food placement
* Screen buffering

---

## 🚀 Possible Improvements

* Add increasing difficulty levels
* Add high score tracking
* Add pause functionality
* Improve snake graphics
* Add more sound effects

---

⭐ If you found this project useful, consider giving the repository a star.
