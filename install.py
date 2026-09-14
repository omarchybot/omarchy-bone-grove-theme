#!/usr/bin/env python3
"""Install the optional Bone Grove experience into user-owned configuration."""
import argparse, datetime, json, os, shutil, subprocess, tempfile
from pathlib import Path
ROOT = Path(__file__).resolve().parent

def copy(src, dst):
    dst.parent.mkdir(parents=True, exist_ok=True)
    if src.is_dir() and not src.is_symlink(): shutil.copytree(src, dst, symlinks=True)
    else: shutil.copy2(src, dst, follow_symlinks=False)

def remove(path):
    if path.is_dir() and not path.is_symlink(): shutil.rmtree(path)
    elif path.exists() or path.is_symlink(): path.unlink()

def restore(backup, home):
    manifest = json.loads((backup / 'manifest.json').read_text())
    if manifest['home'] != str(home): raise SystemExit('Backup belongs to another home directory.')
    for record in reversed(manifest['paths']):
        rel = Path(record['path'])
        if rel.is_absolute() or '..' in rel.parts: raise SystemExit('Invalid backup path')
        dst = home / rel
        remove(dst)
        if record['existed']: copy(backup / 'files' / rel, dst)
    return manifest

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--full', action='store_true', help='Install the theme, Canopy bar, motion and screensaver')
    ap.add_argument('--dry-run', action='store_true', help='Print changes without writing files')
    ap.add_argument('--no-apply', action='store_true', help='Write files without reloading the desktop')
    ap.add_argument('--restore', type=Path, help='Restore a backup printed by this installer')
    args = ap.parse_args(); home = Path.home()
    if args.restore:
        if args.dry_run: print('Would restore', args.restore); return
        manifest = restore(args.restore, home)
        if not args.no_apply:
            if manifest.get('previous_theme'): subprocess.run(['omarchy','theme','set',manifest['previous_theme']],check=True)
            subprocess.run(['omarchy','restart','shell'],check=True)
        print('Restored', args.restore); return
    if not args.full: ap.error('Use --full after reviewing README.md, or --restore BACKUP.')
    plan = ['.config/omarchy/themes/bone-grove', '.config/omarchy/shell.json']
    plan += ['.config/omarchy/plugins/'+p.name for p in sorted((ROOT/'experience/plugins').iterdir()) if p.is_dir()]
    plan += ['.local/bin/'+p.name for p in sorted((ROOT/'experience/bin').iterdir()) if p.is_file()]
    plan += ['.local/share/applications/bone-grove-screensaver.desktop']
    for rel in plan: print('Install:', home/rel)
    if args.dry_run: return
    if not args.no_apply:
        if not Path('/usr/share/omarchy/default/hypr/bootstrap.lua').exists(): raise SystemExit('The full experience requires Omarchy 4 with Lua Hyprland and Quickshell.')
        for command in ('omarchy','hyprctl','python3'):
            if not shutil.which(command): raise SystemExit('Missing required command: '+command)
    shell_path = home/'.config/omarchy/shell.json'
    # Parse before changing anything. Preserve idle policy and unrelated settings.
    shell = json.loads(shell_path.read_text()) if shell_path.exists() else {'version':1}
    previous_path=home/'.local/state/omarchy/current/theme.name'
    previous_theme=previous_path.read_text().strip() if previous_path.exists() else ''
    backup=home/'.config/omarchy/backups'/('bone-grove-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
    backup.mkdir(parents=True)
    manifest={'home':str(home),'previous_theme':previous_theme,'paths':[]}
    # Stage before writes, including when run from the installed theme repository.
    with tempfile.TemporaryDirectory(prefix='bone-grove-') as temp:
        staging=Path(temp)
        theme=staging/'.config/omarchy/themes/bone-grove';theme.mkdir(parents=True)
        for name in ('colors.toml','shell.toml','icons.theme','backgrounds'): copy(ROOT/name,theme/name)
        for src in (ROOT/'experience/theme').iterdir(): copy(src,theme/src.name)
        shell['bar']=json.loads((ROOT/'experience/bar.json').read_text())
        shell['bar']['reduceMotion']=(home/'.local/state/omarchy/bone-grove/reduced-motion').exists()
        (staging/'.config/omarchy/shell.json').write_text(json.dumps(shell,indent=2)+'\n')
        for src in (ROOT/'experience/plugins').iterdir():
            if src.is_dir(): copy(src,staging/'.config/omarchy/plugins'/src.name)
        for src in (ROOT/'experience/bin').iterdir():
            if src.is_file():
                dst=staging/'.local/bin'/src.name;copy(src,dst);dst.chmod(0o755)
        desktop=staging/'.local/share/applications/bone-grove-screensaver.desktop';desktop.parent.mkdir(parents=True)
        # Desktop Exec is not shell syntax; escape its quoted executable path.
        executable=str(home/'.local/bin/omarchy-launch-screensaver').replace('\\','\\\\').replace('"','\\"').replace('`','\\`').replace('$','\\$').replace('%','%%')
        desktop.write_text('[Desktop Entry]\nType=Application\nName=Bone Grove Screensaver\nComment=Preview the forest clock\nExec="'+executable+'" force\nIcon=preferences-desktop-screensaver\nTerminal=false\nCategories=Utility;\n')
        for rel in plan:
            dst=home/rel;exists=dst.exists() or dst.is_symlink()
            if exists: copy(dst,backup/'files'/rel)
            manifest['paths'].append({'path':rel,'existed':exists})
        (backup/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
        try:
            for rel in plan: remove(home/rel);copy(staging/rel,home/rel)
        except Exception:
            restore(backup,home)
            raise
    print('Backup:',backup)
    if not args.no_apply:
        subprocess.run(['omarchy','theme','set','bone-grove'],check=True)
        subprocess.run(['omarchy','restart','shell'],check=True)
        subprocess.run(['hyprctl','reload'],check=True)
        errors=subprocess.check_output(['hyprctl','configerrors'],text=True).strip()
        if errors: raise SystemExit('Hyprland reported: '+errors+'\nRestore with: python3 install.py --restore '+str(backup))
    print('Bone Grove installed. Middle-click GROVE to toggle reduced motion.')
if __name__=='__main__': main()
