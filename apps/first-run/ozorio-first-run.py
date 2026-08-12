#!/usr/bin/env python3
"""Assistente de primeiro uso do Ozorio OS."""

from __future__ import annotations

import pwd
import re
import subprocess
import tkinter as tk
from pathlib import Path
from tkinter import messagebox

USERNAME_RE = re.compile(r"^[a-z_][a-z0-9_-]{2,31}$")
MARKER = Path.home() / ".config" / "ozorio" / "first-run-complete"


def run_privileged(args: list[str], input_text: str | None = None) -> subprocess.CompletedProcess[str]:
    """Executa apenas utilitários autorizados, sem shell intermediário."""
    return subprocess.run(
        ["sudo", "-n", *args],
        input=input_text,
        text=True,
        capture_output=True,
        check=False,
    )


def validate(username: str, password: str, confirmation: str) -> str | None:
    if not USERNAME_RE.fullmatch(username):
        return "Use 3 a 32 caracteres: letras minúsculas, números, _ ou -."
    if username in {"root", "ozorio", "daemon", "nobody"}:
        return "Escolha outro nome de usuário."
    try:
        pwd.getpwnam(username)
        return "Esse usuário já existe."
    except KeyError:
        pass
    if len(password) < 6:
        return "A senha precisa ter pelo menos 6 caracteres."
    if password != confirmation:
        return "As senhas não coincidem."
    return None


def create_user(username: str, full_name: str, password: str) -> tuple[bool, str]:
    result = run_privileged([
        "/usr/sbin/useradd",
        "--create-home",
        "--shell", "/bin/bash",
        "--groups", "sudo,audio,video,plugdev,netdev",
        "--comment", full_name or username,
        username,
    ])
    if result.returncode != 0:
        return False, result.stderr.strip() or "Não foi possível criar o usuário."

    passwd_result = run_privileged(
        ["/usr/sbin/chpasswd"],
        input_text=f"{username}:{password}\n",
    )
    if passwd_result.returncode != 0:
        run_privileged(["/usr/sbin/userdel", "-r", username])
        return False, passwd_result.stderr.strip() or "Não foi possível definir a senha."

    return True, "Usuário criado com sucesso."


class FirstRunApp(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("Bem-vindo ao Ozorio OS")
        self.configure(bg="#0F1426")
        self.minsize(640, 560)
        self._center_window(720, 620)

        outer = tk.Frame(self, bg="#0F1426")
        outer.pack(fill="both", expand=True)

        header = tk.Frame(outer, bg="#111A3A", padx=28, pady=20)
        header.pack(fill="x")
        self._draw_logo(header)

        content = tk.Frame(outer, bg="#0F1426", padx=38, pady=26)
        content.pack(fill="both", expand=True)

        tk.Label(content, text="Bem-vindo ao Ozorio OS", font=("Sans", 22, "bold"),
                 fg="#F4F7FB", bg="#0F1426").pack(anchor="w")
        tk.Label(content,
                 text="Você entrou automaticamente na sessão Live. Crie seu usuário agora ou continue testando o sistema.",
                 font=("Sans", 10), fg="#B9C1D0", bg="#0F1426",
                 wraplength=620, justify="left").pack(anchor="w", pady=(6, 18))

        form = tk.Frame(content, bg="#0F1426")
        form.pack(fill="both", expand=True)

        self.username = self._field(form, "Nome de usuário", None)
        self.full_name = self._field(form, "Seu nome", None)
        self.password = self._field(form, "Senha", "•")
        self.confirmation = self._field(form, "Confirmar senha", "•")

        hint = tk.Label(
            form,
            text="A senha deve ter pelo menos 6 caracteres. O usuário Live continuará disponível para testes.",
            font=("Sans", 9), fg="#8FA0B8", bg="#0F1426", justify="left",
            wraplength=620,
        )
        hint.pack(anchor="w", pady=(8, 0))

        buttons = tk.Frame(content, bg="#0F1426")
        buttons.pack(fill="x", pady=(22, 0))
        tk.Button(buttons, text="Continuar usando Live", command=self.skip,
                  padx=16, pady=10, relief="flat").pack(side="left")
        tk.Button(buttons, text="Criar usuário", command=self.submit,
                  padx=20, pady=10, bg="#6F4CC3", fg="white", relief="flat",
                  activebackground="#244A86", activeforeground="white").pack(side="right")

    def _center_window(self, width: int, height: int) -> None:
        self.update_idletasks()
        screen_w = self.winfo_screenwidth()
        screen_h = self.winfo_screenheight()
        width = min(width, max(640, screen_w - 40))
        height = min(height, max(520, screen_h - 60))
        x = max(0, (screen_w - width) // 2)
        y = max(0, (screen_h - height) // 2)
        self.geometry(f"{width}x{height}+{x}+{y}")

    @staticmethod
    def _draw_logo(parent: tk.Widget) -> None:
        wrap = tk.Frame(parent, bg="#111A3A")
        wrap.pack(anchor="w")
        canvas = tk.Canvas(wrap, width=58, height=58, bg="#111A3A", highlightthickness=0)
        canvas.pack(side="left")
        canvas.create_oval(6, 6, 52, 52, outline="#6F4CC3", width=7)
        canvas.create_arc(12, 12, 46, 46, start=300, extent=135, style="arc", outline="#2F8F72", width=5)
        canvas.create_oval(21, 21, 37, 37, outline="#244A86", width=4)
        tk.Label(wrap, text="OZORIO OS", font=("Sans", 18, "bold"), fg="#F4F7FB",
                 bg="#111A3A").pack(side="left", padx=(12, 0))

    @staticmethod
    def _field(parent: tk.Widget, label: str, show: str | None) -> tk.Entry:
        frame = tk.Frame(parent, bg="#0F1426")
        frame.pack(fill="x", pady=6)
        tk.Label(frame, text=label, fg="#F4F7FB", bg="#0F1426").pack(anchor="w")
        entry = tk.Entry(frame, show=show or "", font=("Sans", 11), relief="flat", bd=0)
        entry.pack(fill="x", ipady=7, pady=(4, 0))
        return entry

    def mark_complete(self) -> None:
        MARKER.parent.mkdir(parents=True, exist_ok=True)
        MARKER.touch(exist_ok=True)

    def skip(self) -> None:
        self.mark_complete()
        self.destroy()

    def submit(self) -> None:
        username = self.username.get().strip()
        full_name = self.full_name.get().strip()
        password = self.password.get()
        confirmation = self.confirmation.get()
        error = validate(username, password, confirmation)
        if error:
            messagebox.showerror("Verifique os dados", error)
            return
        ok, message = create_user(username, full_name, password)
        if not ok:
            messagebox.showerror("Não foi possível criar o usuário", message)
            return
        self.mark_complete()
        messagebox.showinfo("Tudo certo", message)
        self.destroy()


def main() -> None:
    if MARKER.exists():
        return
    FirstRunApp().mainloop()


if __name__ == "__main__":
    main()
