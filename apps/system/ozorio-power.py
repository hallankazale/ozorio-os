#!/usr/bin/env python3
"""Central de energia do Ozorio OS."""

from __future__ import annotations

import shutil
import subprocess
import tkinter as tk
from tkinter import messagebox

BG = "#0F1426"
SURFACE = "#18213A"
TEXT = "#F4F7FB"
MUTED = "#B9C1D0"
PURPLE = "#6F4CC3"
BLUE = "#244A86"
GREEN = "#2F8F72"


def run_command(args: list[str]) -> None:
    try:
        subprocess.Popen(args, shell=False)
    except OSError as exc:
        messagebox.showerror("Ozorio OS", f"Não foi possível executar a ação:\n{exc}")


def confirm(title: str, message: str, command: list[str]) -> None:
    if messagebox.askyesno(title, message):
        run_command(command)


def logout() -> None:
    if not messagebox.askyesno("Sair da sessão", "Deseja encerrar sua sessão?"):
        return
    if shutil.which("lxsession-logout"):
        run_command(["lxsession-logout"])
    elif shutil.which("lxde-logout"):
        run_command(["lxde-logout"])
    else:
        messagebox.showerror("Ozorio OS", "Não foi encontrado um comando de logout do LXDE.")


class PowerApp(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("Energia — Ozorio OS")
        self.geometry("520x360")
        self.resizable(False, False)
        self.configure(bg=BG)

        header = tk.Frame(self, bg="#111A3A", padx=24, pady=18)
        header.pack(fill="x")
        self._logo(header)

        body = tk.Frame(self, bg=BG, padx=28, pady=24)
        body.pack(fill="both", expand=True)
        tk.Label(body, text="O que você deseja fazer?", font=("Sans", 17, "bold"),
                 fg=TEXT, bg=BG).pack(anchor="w")
        tk.Label(body, text="Escolha uma opção para encerrar a sessão com segurança.",
                 font=("Sans", 10), fg=MUTED, bg=BG).pack(anchor="w", pady=(4, 18))

        grid = tk.Frame(body, bg=BG)
        grid.pack(fill="both", expand=True)
        self._action(grid, 0, 0, "Sair da sessão", "Voltar para a tela de login", BLUE, logout)
        self._action(grid, 0, 1, "Reiniciar", "Reiniciar o computador", PURPLE,
                     lambda: confirm("Reiniciar", "Deseja reiniciar o computador?",
                                     ["systemctl", "reboot"]))
        self._action(grid, 1, 0, "Desligar", "Desligar com segurança", GREEN,
                     lambda: confirm("Desligar", "Deseja desligar o computador?",
                                     ["systemctl", "poweroff"]))
        self._action(grid, 1, 1, "Cancelar", "Continuar usando o Ozorio OS", SURFACE,
                     self.destroy)

    @staticmethod
    def _logo(parent: tk.Widget) -> None:
        canvas = tk.Canvas(parent, width=48, height=48, bg="#111A3A", highlightthickness=0)
        canvas.pack(side="left")
        canvas.create_oval(5, 5, 43, 43, outline=PURPLE, width=6)
        canvas.create_arc(10, 10, 38, 38, start=300, extent=135, style="arc", outline=GREEN, width=4)
        canvas.create_oval(18, 18, 30, 30, outline=BLUE, width=3)
        tk.Label(parent, text="OZORIO OS", font=("Sans", 16, "bold"), fg=TEXT,
                 bg="#111A3A").pack(side="left", padx=(10, 0))

    @staticmethod
    def _action(parent: tk.Widget, row: int, col: int, title: str, subtitle: str,
                color: str, command) -> None:
        card = tk.Frame(parent, bg=SURFACE, padx=12, pady=12, highlightthickness=1,
                        highlightbackground="#33405D")
        card.grid(row=row, column=col, padx=6, pady=6, sticky="nsew")
        parent.grid_columnconfigure(col, weight=1)
        parent.grid_rowconfigure(row, weight=1)
        tk.Button(card, text=title, command=command, bg=color, fg="white", relief="flat",
                  activeforeground="white", font=("Sans", 11, "bold"), padx=12, pady=8).pack(fill="x")
        tk.Label(card, text=subtitle, bg=SURFACE, fg=MUTED, font=("Sans", 9),
                 wraplength=180, justify="left").pack(anchor="w", pady=(8, 0))


if __name__ == "__main__":
    PowerApp().mainloop()
