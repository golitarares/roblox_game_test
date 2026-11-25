const { chromium } = require('playwright'); const fs=require('fs');
(async()=>{const b=await chromium.launch({args:['--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
const p=await b.newPage(); p.on('console',m=>console.log('console:',m.text())); p.on('pageerror',e=>console.log('err:',e.message));
await p.goto('file://'+__dirname+'/ship.html'); await p.waitForFunction('window.SHEET',null,{timeout:60000});
const d=await p.evaluate('window.SHEET'); fs.writeFileSync(process.argv[2],Buffer.from(d.split(',')[1],'base64'));
await b.close();})();
