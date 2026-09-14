import json, os, subprocess, sys, tempfile, unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

class Installation(unittest.TestCase):
    def run_installer(self, home, *args):
        return subprocess.run([sys.executable,str(ROOT/'install.py'),*args],env={**os.environ,'HOME':str(home)},check=True,capture_output=True,text=True)
    def test_dry_run_does_not_write(self):
        with tempfile.TemporaryDirectory() as tmp:
            home=Path(tmp);self.run_installer(home,'--full','--dry-run');self.assertEqual(list(home.iterdir()),[])
    def test_install_and_restore_preserve_user_settings(self):
        with tempfile.TemporaryDirectory() as tmp:
            home=Path(tmp);cfg=home/'.config/omarchy';cfg.mkdir(parents=True)
            original={'version':1,'idle':{'screensaver':600,'lock':900},'bar':{'id':'custom.old'},'plugins':['example.plugin']}
            content=json.dumps(original);(cfg/'shell.json').write_text(content)
            hypr=home/'.config/hypr';hypr.mkdir(parents=True)
            (hypr/'looknfeel.lua').write_text('-- existing appearance\n')
            old_theme=cfg/'themes/bone-grove';old_theme.mkdir(parents=True);(old_theme/'keep.txt').write_text('previous theme')
            self.run_installer(home,'--full','--no-apply')
            actual=json.loads((cfg/'shell.json').read_text())
            self.assertEqual(actual['idle'],original['idle']);self.assertIn('example.plugin',actual['plugins']);self.assertIn({'id':'bone-grove.lock'},actual['plugins'])
            self.assertEqual(actual['bar']['id'],'bone-grove.bar')
            self.assertIn('require("hypr.bone-grove-session")',(hypr/'looknfeel.lua').read_text())
            self.assertTrue((home/'.local/bin/omarchy').exists())
            self.assertTrue((home/'.local/bin/omarchy-screensaver').stat().st_mode & 0o111)
            backup=next((cfg/'backups').iterdir())
            self.run_installer(home,'--restore',str(backup),'--no-apply')
            self.assertEqual((cfg/'shell.json').read_text(),content)
            self.assertEqual((hypr/'looknfeel.lua').read_text(),'-- existing appearance\n')
            self.assertFalse((hypr/'bone-grove-session.lua').exists())
            self.assertFalse((home/'.local/bin/omarchy').exists())
            self.assertEqual((old_theme/'keep.txt').read_text(),'previous theme')
            self.assertFalse((home/'.local/bin/omarchy-screensaver').exists())
            self.assertFalse((cfg/'plugins/bone-grove.bar').exists())
if __name__=='__main__':unittest.main()
