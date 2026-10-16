// NODE_PATH=<node_modules> node tool/render_store_graphics.cjs
// Requires playwright, sharp, and Chrome. Key art is generated with imagegen.
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');
const sharp = require('sharp');
const root = path.resolve(__dirname, '..');
const out = path.join(root, 'docs/store-graphics/en-US');
const assets = [
  ['app-store-header', 3840, 1646],
  ['app-store-search-results', 3840, 2560],
  ['google-play-feature-graphic', 1024, 500],
];
function uri(file, mime) {
  return `data:${mime};base64,${fs.readFileSync(path.join(root,file)).toString('base64')}`;
}
function html(id,w,h) {
  const search = id === 'app-store-search-results';
  const feature = id === 'google-play-feature-graphic';
  const art=uri('docs/store-graphics/sources/key-art.png','image/png');
  const screenshot=search?uri('docs/app-store/en-US/raw/iphone-6.9/01-match.png','image/png'):'';
  const font=uri('assets/fonts/Mali-Bold.ttf','font/ttf');
  const regular=uri('assets/fonts/Mali-Regular.ttf','font/ttf');
  const left=search?300:feature?80:340;
  const top=search?700:feature?140:510;
  const title=search?270:feature?79:280;
  return `<!doctype html><html lang="en"><meta charset="utf-8"><style>
  @font-face{font-family:Mali;src:url('${font}');font-weight:700}
  @font-face{font-family:Mali;src:url('${regular}');font-weight:400}
  *{box-sizing:border-box}body{margin:0;width:${w}px;height:${h}px;overflow:hidden;background:#123f45;color:#fff7e5;font-family:Mali}
  .art{position:absolute;width:100%;height:100%;object-fit:cover;object-position:center;${search?'opacity:.3;':''}}
  .shade{position:absolute;inset:0;background:linear-gradient(90deg,#123f45 ${search?'38%':'0%'},#123f45e8 ${search?'52%':'25%'},#123f4500 ${search?'78%':'49%'})}
  .copy{position:absolute;left:${left}px;top:${top}px;max-width:${search?1750:feature?470:1600}px}
  .eyebrow{font-size:${search?47:feature?16:46}px;letter-spacing:${feature?4:11}px;font-weight:700;color:#ffcf77}
  h1{font-size:${title}px;line-height:1.2;letter-spacing:${feature?-3:-10}px;margin:${feature?14:38}px 0 0;white-space:nowrap;font-weight:700}
  .tagline{font-size:${search?104:feature?23:79}px;line-height:1.4;margin:${search?55:feature?18:42}px 0 0;color:#fff7e5}
  .detail{margin-top:60px;font-size:49px;color:#ffcf77}
  .capture{position:absolute;right:330px;top:285px;width:900px;border:12px solid #fff4df;border-radius:66px;overflow:hidden;line-height:0;box-shadow:0 42px 120px #0006}
  .capture img{display:block;width:100%;height:auto}
  .sprites{display:flex;gap:40px;margin-top:90px}.sprites img{width:230px;height:230px;object-fit:contain;filter:drop-shadow(0 16px 14px #0003)}
  </style><img class="art" src="${art}"><div class="shade"></div><div class="copy"><div class="eyebrow">SUSHI MATCH-3</div><h1>Sushi Trio</h1><p class="tagline">${search?'Match three.<br>Serve happy!':'Match three, serve happy!'}</p>${search?`<p class="detail">205 levels · 14 destinations</p><div class="sprites">${['salmon','tamago','kappa'].map(k=>`<img src="${uri(`assets/sprites/sushi/${k}.webp`,'image/webp')}">`).join('')}</div>`:''}</div>${search?`<div class="capture"><img src="${screenshot}"></div>`:''}</html>`;
}
(async()=>{
  fs.mkdirSync(out,{recursive:true});
  const browser=await chromium.launch({executablePath:process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true});
  try {
    for(const [id,width,height] of assets){
      const page=await browser.newPage({viewport:{width,height},deviceScaleFactor:1});
      await page.setContent(html(id,width,height),{waitUntil:'load'});
      await page.evaluate(async()=>{await document.fonts.ready;await Promise.all([...document.images].map(i=>i.decode()));});
      const fits=await page.evaluate(()=>[...document.querySelectorAll('.copy,.capture')].every(el=>{const b=el.getBoundingClientRect();return b.left>=0&&b.top>=0&&b.right<=innerWidth&&b.bottom<=innerHeight;}));
      if(!fits)throw Error(`Layout bounds failed: ${id}`);
      const file=path.join(out,`${id}.png`);
      await page.screenshot({path:file});
      // Explicit 24-bit RGB exports, without alpha, for both stores.
      const rgb=await sharp(file).flatten({background:'#123f45'}).removeAlpha().toColourspace('srgb').png().toBuffer();
      fs.writeFileSync(file,rgb);
      const meta=await sharp(file).metadata();
      if(meta.width!==width||meta.height!==height||meta.hasAlpha||meta.channels!==3)throw Error(`Invalid export ${id}`);
      console.log(`${id}.png — ${width}×${height}, RGB, no alpha`);
      await page.close();
    }
  }finally{await browser.close();}
  const previews=[];let y=50;
  for(const [id,w,h] of assets){
    const height=Math.round(h*960/w);
    const label=Buffer.from(`<svg width="1000" height="40"><rect width="100%" height="100%" fill="#fbf1dc"/><text x="20" y="28" font-family="Arial" font-size="22" fill="#4d2e1b">${id} · ${w} × ${h}</text></svg>`);
    previews.push({input:label,left:0,top:y});y+=44;
    previews.push({input:await sharp(path.join(out,`${id}.png`)).resize(960,height).toBuffer(),left:20,top:y});y+=height+50;
  }
  await sharp({create:{width:1000,height:y,channels:3,background:'#fbf1dc'}}).composite(previews).png().toFile(path.join(root,'docs/store-graphics/overview.png'));
})().catch(e=>{console.error(e);process.exitCode=1;});
