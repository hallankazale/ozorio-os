from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / "apps" / "dev-center" / "dev_center.py"
DESKTOP = ROOT / "apps" / "dev-center" / "ozorio-dev-center.desktop"
INSTALLER = ROOT / "scripts" / "install-dev-center.sh"


def test_dev_center_files_exist():
    assert APP.is_file()
    assert DESKTOP.is_file()
    assert INSTALLER.is_file()


def test_dev_center_avoids_shell_execution():
    source = APP.read_text(encoding="utf-8")
    assert "shell=True" not in source
    assert "os.system(" not in source
    assert "subprocess.Popen(command" in source


def test_desktop_launcher_uses_stable_command():
    content = DESKTOP.read_text(encoding="utf-8")
    assert "Exec=ozorio-dev-center" in content
    assert "Terminal=false" in content
