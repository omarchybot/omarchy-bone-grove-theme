import json,os,subprocess,sys,tempfile,unittest
from pathlib import Path
CLI=Path(__file__).resolve().parents[1]/'experience/bin/bone-grove'
class Controls(unittest.TestCase):
 def test_preferences_validate_preserve_and_apply(self):
  with tempfile.TemporaryDirectory() as tmp:
   home=Path(tmp);cfg=home/'.config/omarchy/shell.json';cfg.parent.mkdir(parents=True)
   original={'idle':{'screensaver':150,'lock':300},'plugins':['custom'],'bar':{'id':'custom.bar'}}
   cfg.write_text(json.dumps(original));bin=home/'bin';bin.mkdir();hypr=bin/'hyprctl';hypr.write_text('#!/bin/sh\nexit 0\n');hypr.chmod(0o755)
   env={**os.environ,'HOME':str(home),'PATH':str(bin)+':'+os.environ['PATH']}
   def call(*args):return subprocess.run([sys.executable,str(CLI),*args],env=env,capture_output=True,text=True)
   self.assertNotEqual(call('set','size','5').returncode,0);self.assertEqual(json.loads(cfg.read_text()),original)
   self.assertEqual(call('set','size','28').returncode,0)
   self.assertEqual(call('set','opacity','.85').returncode,0)
   self.assertEqual(call('set','motion','0').returncode,0)
   state=home/'.local/state/omarchy/bone-grove'
   self.assertTrue((state/'reduced-motion').exists())
   result=json.loads(cfg.read_text());self.assertEqual(result['idle'],original['idle']);self.assertEqual(result['plugins'],original['plugins'])
   self.assertEqual(result['bar']['groveSize'],28);self.assertEqual(result['bar']['groveOpacity'],.85)
   self.assertEqual(call('set','motion','.65').returncode,0);self.assertFalse((state/'reduced-motion').exists())
   self.assertEqual((state/'motion-strength').read_text(),'0.65')
   self.assertNotEqual(call('set','volume','101').returncode,0)
   self.assertNotEqual(call('set','opacity','nan').returncode,0)
if __name__=='__main__':unittest.main()
