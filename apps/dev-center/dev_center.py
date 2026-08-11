#!/usr/bin/env python3
"""Ozorio Development Center.

Launcher gráfico leve para ferramentas de desenvolvimento do Ozorio OS.
Usa apenas comandos permitidos e argumentos fixos para evitar injeção de shell.
"""
from __future__ import annotations

import os
import shutil
import subprocess
import tkinter as tk
from pathlib import Path
from tkinter import messagebox

APP_TITLE = "Central de Desenvolvimento — Ozorio OS"
PROJECTS_DIR = Path.home() / "Projetos"

TOOLS = [
    ("Git", "git", ["git", "--version"]),
    ("Python", "python3", ["python3", "--version"]),
    ("Node.js", "node", ["node", "--version"]),
    ("NPM", "npm", ["npm", "--version"]),
    ("Java", "java", ["java", "-version"]),
    ("Gradle", "gradle", ["gradle", "--version"]),
]


def command_exists(command: str) -> bool:
    return shutil.which(command) is not None


def get_version(command: list[str]) -> str:
    try:
        result = subprocess.run(
            command,
            check=False,
            capture_output=True,
            text=True,
            timeout=3,
        )
        output = (result.stdout or result.stderr).strip().splitlines()
        return output[0][:80] if output else "instalado"
    except (OSError, subprocess.TimeoutExpired):
        return "instalado"


def launch(command: list[str]) -> None:
    try:
        subprocess.Popen(command, start_new_session=True)
    except OSError as exc:
        messagebox.showerror("Ozorio OS", f"Não foi possível abrir o programa:\n{exc}")


def open_terminal() -> None:
    launch(["x-terminal-emulator"])


def open_editor() -> None:
    for editor in ("geany", "mousepad", "leafpad"):
        if command_exists(editor):
            launch([editor])
            return
    messagebox.showinfo("Editor", "Nenhum editor gráfico compatível foi encontrado.")


def open_projects() -> None:
    PROJECTS_DIR.mkdir(parents=True, exist_ok=True)
    if command_exists("pcmanfm"):
        launch(["pcmanfm", str(PROJECTS_DIR)])
    else:
        messagebox.showinfo("Projetos", f"Pasta criada em {PROJECTS_DIR}")


def open_chatgpt() -> None:
    browser = shutil.which("x-www-browser")
    if browser:
        launch([browser, "https://chatgpt.com/"])
    else:
        messagebox.showinfo("Navegador", "Nenhum navegador padrão foi encontrado.")


def build_tool_status(parent: tk.Widget) -> None:
    frame = tk.LabelFrame(parent, text="Ambiente", padx=12, pady=10)
    frame.pack(fill="x", padx=16, pady=(8, 12))

    for row, (label, binary, version_cmd) in enumerate(TOOLS):
        installed = command_exists(binary)
        status = get_version(version_cmd) if installed else "não instalado"
        symbol = "✓" if installed else "—"
        tk.Label(frame, text=f"{symbol} {label}", width=16, anchor="w").grid(row=row, column=0, sticky="w", pady=2)
        tk.Label(frame, text=status, anchor="w").grid(row=row, column=1, sticky="w", pady=2)


def main() -> None:
    root = tk.Tk()
    root.title(APP_TITLE)
    root.geometry("720x520")
    root.minsize(640, 460)

    header = tk.Frame(root, padx=16, pady=14)
    header.pack(fill="x")
    tk.Label(header, text="Central de Desenvolvimento", font=("Sans", 18, "bold")).pack(anchor="w")
    tk.Label(header, text="Ferramentas essenciais para criar sistemas, sites e APKs.").pack(anchor="w", pady=(3, 0))

    actions = tk.LabelFrame(root, text="Ações rápidas", padx=12, pady=12)
    actions.pack(fill="x", padx=16, pady=(0, 8))

    buttons = [
        ("Terminal", open_terminal),
        ("Editor", open_editor),
        ("Meus Projetos", open_projects),
        ("ChatGPT", open_chatgpt),
    ]
    for index, (text, callback) in enumerate(buttons):
        tk.Button(actions, text=text, command=callback, width=18, height=2).grid(
            row=index // 2,
            column=index % 2,
            padx=6,
            pady=6,
            sticky="ew",
        )
    actions.columnconfigure(0, weight=1)
    actions.columnconfigure(1, weight=1)

    build_tool_status(root)

    footer = tk.Frame(root, padx=16, pady=10)
    footer.pack(fill="x", side="bottom")
    tk.Label(footer, text="Ozorio OS 0.1 • Dev Center leve e modular").pack(anchor="w")

    root.mainloop()


if __name__ == "__main__":
    main()
