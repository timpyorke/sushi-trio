// NODE_PATH=<your node_modules> node tool/render_store_screenshots.cjs
// Requires playwright and sharp. Renders HTML/CSS around untouched captures.
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const out = path.join(root, 'docs/app-store/en-US');
const panels = [
  ['01-match', 'Match three.<br>Serve happy!', 'A little sushi. A lot of satisfying matches.', 'salmon', 'cream'],
  ['02-map', '205 tasty levels.<br>One big adventure.', 'Explore 14 destinations across Japan.', 'kappa', 'teal'],
  ['03-home', 'Your next match<br>starts here.', 'Step into the colorful world of Sushi Trio.', 'tamago', 'cream'],
  ['04-challenges', 'A fresh twist<br>in every puzzle.', 'Break the ice. Clear obstacles. Plan your next move.', 'ikura', 'red'],
  ['05-events', 'Play. Collect.<br>Come back for more.', 'Match the weekly special and collect milestone rewards.', 'maguro', 'teal'],
];
function uri(file) {
  const ext = path.extname(file).slice(1);
  return `data:${ext === 'ttf' ? 'font/ttf' : 'image/' + ext};base64,${fs.readFileSync(path.join(root, file)).toString('base64')}`;
}
function markup(panel, device) {
  const [id, headline, sub, sprite, theme] = panel;
  const tablet = device === 'ipad-13';
  const [w, h] = tablet ? [2048, 2732] : [1320, 2868];
  const palettes = {cream:['#fbf1dc','#4d2e1b','#b71c2c'],teal:['#123f45','#fff7e5','#ffcf77'],red:['#ad2633','#fff7e5','#ffdc94']};
  const [bg, ink, accent] = palettes[theme];
  const raw = `docs/app-store/en-US/raw/${device}/${id}.png`;
  return `<!doctype html><html lang="en"><meta charset="utf-8"><style>
  @font-face{font-family:Mali;src:url('${uri('assets/fonts/Mali-Bold.ttf')}');font-weight:700}
  @font-face{font-family:Mali;src:url('${uri('assets/fonts/Mali-Regular.ttf')}');font-weight:400}
  *{box-sizing:border-box}body{margin:0;width:${w}px;height:${h}px;overflow:hidden;background:${bg};color:${ink};font-family:Mali}
  .scene{position:relative;width:100%;height:100%;overflow:hidden}
  .orb{position:absolute;width:1100px;height:1100px;border:2px solid currentColor;border-radius:50%;opacity:.07;right:-600px;top:100px;box-shadow:0 0 0 70px currentColor,0 0 0 140px ${bg},0 0 0 142px currentColor,0 0 0 210px ${bg},0 0 0 212px currentColor}
  header{position:absolute;top:${tablet?85:80}px;left:0;width:100%;text-align:center;z-index:2}
  .brand{font-size:${tablet?32:30}px;font-weight:700;letter-spacing:7px;color:${accent};display:flex;align-items:center;justify-content:center;gap:18px}
  .brand:before,.brand:after{content:'';width:65px;height:3px;background:${accent};opacity:.6}
  h1{margin:${tablet?28:34}px 30px 0;font-size:${tablet?122:112}px;line-height:1.12;letter-spacing:-4px;font-weight:700}
  p{font-size:${tablet?39:35}px;line-height:1.5;margin:28px 40px 0;opacity:.88}
  .capture{position:absolute;left:${tablet?254:190}px;top:${tablet?615:650}px;width:${tablet?1540:940}px;line-height:0;border:10px solid ${theme==='cream'?'#fff9ee':'#fbf1dc'};border-radius:54px;overflow:hidden;box-shadow:0 32px 85px #0004;z-index:1;background:#fbf1dc}
  .capture img{width:100%;height:auto;display:block}
  .sushi{position:absolute;width:${tablet?300:260}px;left:-80px;bottom:35px;transform:rotate(-15deg);z-index:2;filter:drop-shadow(0 15px 12px #0002)}
  .sushi.second{left:auto;right:-70px;bottom:auto;top:${tablet?440:390}px;width:210px;transform:rotate(16deg);z-index:0}
  .edition{position:absolute;bottom:30px;width:100%;text-align:center;font-size:25px;letter-spacing:5px;opacity:.65}
  </style><div class="scene"><div class="orb"></div><header><div class="brand">SUSHI TRIO</div><h1>${headline}</h1><p>${sub}</p></header><img class="sushi" src="${uri(`assets/sprites/sushi/${sprite}.webp`)}"><img class="sushi second" src="${uri('assets/sprites/sushi/ebi.webp')}"><div class="capture"><img src="${uri(raw)}"></div><div class="edition">MATCH THREE, SERVE HAPPY!</div></div></html>`;
}
(async () => {
  const browser = await chromium.launch({executablePath: process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless:true});
  try {
    for (const device of ['iphone-6.9','ipad-13']) {
      const tablet = device === 'ipad-13';
      const size = {width:tablet?2048:1320,height:tablet?2732:2868};
      const dir = path.join(out,device);
      fs.mkdirSync(dir,{recursive:true});
      const page = await browser.newPage({viewport:size,deviceScaleFactor:1});
      for (const panel of panels) {
        const html = markup(panel,device);
        await page.setContent(html,{waitUntil:'load'});
        await page.evaluate(async()=>{await document.fonts.ready;await Promise.all([...document.images].map(i=>i.decode()));});
        const fits = await page.evaluate(()=>{
          const header=document.querySelector('header').getBoundingClientRect();
          const capture=document.querySelector('.capture').getBoundingClientRect();
          return header.bottom<capture.top && capture.bottom<innerHeight-55;
        });
        if (!fits) throw Error(`Layout overflow: ${device}/${panel[0]}`);
        const pngPath = path.join(dir,`${panel[0]}.png`);
        await page.screenshot({path:pngPath});
        const meta = await sharp(pngPath).metadata();
        if (meta.width!==size.width || meta.height!==size.height || meta.hasAlpha) throw Error(`Invalid output ${pngPath}`);
        console.log(`${device}/${panel[0]}.png — ${meta.width}×${meta.height}, opaque`);
      }
      await page.close();
      const thumbW=330,thumbH=Math.round(size.height*thumbW/size.width);
      const thumbs=await Promise.all(panels.map(async(p,i)=>({input:await sharp(path.join(dir,`${p[0]}.png`)).resize(thumbW,thumbH).toBuffer(),left:i*thumbW,top:0})));
      await sharp({create:{width:thumbW*panels.length,height:thumbH,channels:3,background:'#fbf1dc'}}).composite(thumbs).png().toFile(path.join(out,`${device}-overview.png`));
    }
  } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
