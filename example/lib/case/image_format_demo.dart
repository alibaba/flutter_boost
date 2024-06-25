import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class ImageFormatDemo extends StatefulWidget {
  const ImageFormatDemo({Key? key}) : super(key: key);

  @override
  State<ImageFormatDemo> createState() => _ImageFormatDemoState();
}

class _ImageFormatDemoState extends State<ImageFormatDemo> {
  late Image sample_hdr;
  late Image sample_heic;
  late Image sample_heif;
  late Image sample_tiff;
  late Image sample_wbmp;
  late Image sample_webp;
  late Image sample_bmp;
  late Image sample_cur;
  late Image sample_dds;
  late Image sample_dng;
  late Image sample_erf;
  late Image sample_exr;
  late Image sample_fts;
  late Image sample_gif;
  late Image sample_ico;
  late Image sample_jfif;
  late Image sample_jp2;
  late Image sample_jpe;
  late Image sample_jpeg;
  late Image sample_jpg;
  late Image sample_jps;
  late Image sample_mng;
  late Image sample_nef;
  late Image sample_nrw;
  late Image sample_orf;
  late Image sample_pam;
  late Image sample_pbm;
  late Image sample_pcd;
  late Image sample_pcx;
  late Image sample_pef;
  late Image sample_pes;
  late Image sample_pfm;
  late Image sample_pgm;
  late Image sample_picon;
  late Image sample_pict;
  late Image sample_png;
  late Image sample_pnm;
  late Image sample_ppm;
  late Image sample_psd;
  late Image sample_raf;
  late Image sample_ras;
  late Image sample_rw2;
  late Image sample_sgi;
  late Image sample_svg;
  late Image sample_tga;
  late Image sample_xbm;
  late Image sample_xpm;
  late Image sample_xwd;

  @override
  void initState() {
    super.initState();
    sample_bmp = Image.asset("images/sample_bmp.bmp");
    sample_cur = Image.asset("images/sample_cur.cur");
    sample_dds = Image.asset("images/sample_dds.dds");
    sample_dng = Image.asset("images/sample_dng.dng");
    sample_erf = Image.asset("images/sample_erf.erf");
    sample_exr = Image.asset("images/sample_exr.exr");
    sample_fts = Image.asset("images/sample_fts.fts");
    sample_gif = Image.asset("images/sample_gif.gif");
    sample_hdr = Image.asset("images/sample_hdr.hdr");
    sample_heic = Image.asset("images/sample_heic.heic");
    sample_heif = Image.asset("images/sample_heif.heif");
    sample_ico = Image.asset("images/sample_ico.ico");
    sample_jfif = Image.asset("images/sample_jfif.jfif");
    sample_jp2 = Image.asset("images/sample_jp2.jp2");
    sample_jpe = Image.asset("images/sample_jpe.jpe");
    sample_jpeg = Image.asset("images/sample_jpeg.jpeg");
    sample_jpg = Image.asset("images/sample_jpg.jpg");
    sample_jps = Image.asset("images/sample_jps.jps");
    sample_mng = Image.asset("images/sample_mng.mng");
    sample_nef = Image.asset("images/sample_nef.nef");
    sample_nrw = Image.asset("images/sample_nrw.nrw");
    sample_orf = Image.asset("images/sample_orf.orf");
    sample_pam = Image.asset("images/sample_pam.pam");
    sample_pbm = Image.asset("images/sample_pbm.pbm");
    sample_pcd = Image.asset("images/sample_pcd.pcd");
    sample_pcx = Image.asset("images/sample_pcx.pcx");
    sample_pef = Image.asset("images/sample_pef.pef");
    sample_pes = Image.asset("images/sample_pes.pes");
    sample_pfm = Image.asset("images/sample_pfm.pfm");
    sample_pgm = Image.asset("images/sample_pgm.pgm");
    sample_picon = Image.asset("images/sample_picon.picon");
    sample_pict = Image.asset("images/sample_pict.pict");
    sample_png = Image.asset("images/sample_png.png");
    sample_pnm = Image.asset("images/sample_pnm.pnm");
    sample_ppm = Image.asset("images/sample_ppm.ppm");
    sample_psd = Image.asset("images/sample_psd.psd");
    sample_raf = Image.asset("images/sample_raf.raf");
    sample_ras = Image.asset("images/sample_ras.ras");
    sample_rw2 = Image.asset("images/sample_rw2.rw2");
    sample_sgi = Image.asset("images/sample_sgi.sgi");
    sample_svg = Image.asset("images/sample_svg.svg");
    sample_tga = Image.asset("images/sample_tga.tga");
    sample_tiff = Image.asset("images/sample_tiff.tiff");
    sample_wbmp = Image.asset("images/sample_wbmp.wbmp");
    sample_webp = Image.asset("images/sample_webp.webp");
    sample_xbm = Image.asset("images/sample_xbm.xbm");
    sample_xpm = Image.asset("images/sample_xpm.xpm");
    sample_xwd = Image.asset("images/sample_xwd.xwd");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Format Demo"),
      ),
      body: Center(
          child: SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('BMP')),
                          Expanded(flex: 5, child: sample_bmp)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('CUR')),
                          Expanded(flex: 5, child: sample_cur)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('DDS')),
                          Expanded(flex: 5, child: sample_dds)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('DNG')),
                          Expanded(flex: 5, child: sample_dng)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('ERF')),
                          Expanded(flex: 5, child: sample_erf)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('EXR')),
                          Expanded(flex: 5, child: sample_exr)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('FTS')),
                          Expanded(flex: 5, child: sample_fts)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('GIF')),
                          Expanded(flex: 5, child: sample_gif)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('HDR')),
                          Expanded(flex: 5, child: sample_hdr)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('HEIC')),
                          Expanded(flex: 5, child: sample_heic)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('HEIF')),
                          Expanded(flex: 5, child: sample_heif)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('ICO')),
                          Expanded(flex: 5, child: sample_ico)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('JFIF')),
                          Expanded(flex: 5, child: sample_jfif)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('JP2')),
                          Expanded(flex: 5, child: sample_jp2)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('JPE')),
                          Expanded(flex: 5, child: sample_jpe)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('JPEG')),
                          Expanded(flex: 5, child: sample_jpeg)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('JPG')),
                          Expanded(flex: 5, child: sample_jpg)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('JPS')),
                          Expanded(flex: 5, child: sample_jps)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('MNG')),
                          Expanded(flex: 5, child: sample_mng)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('NEF')),
                          Expanded(flex: 5, child: sample_nef)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('NRW')),
                          Expanded(flex: 5, child: sample_nrw)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('ORF')),
                          Expanded(flex: 5, child: sample_orf)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('PAM')),
                          Expanded(flex: 5, child: sample_pam)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('PBM')),
                          Expanded(flex: 5, child: sample_pbm)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('PCD')),
                          Expanded(flex: 5, child: sample_pcd)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('PCX')),
                          Expanded(flex: 5, child: sample_pcx)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('PEF')),
                          Expanded(flex: 5, child: sample_pef)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('PES')),
                          Expanded(flex: 5, child: sample_pes)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('PFM')),
                          Expanded(flex: 5, child: sample_pfm)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('PGM')),
                          Expanded(flex: 5, child: sample_pgm)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('PICON')),
                          Expanded(flex: 5, child: sample_picon)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('PICT')),
                          Expanded(flex: 5, child: sample_pict)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('PNG')),
                          Expanded(flex: 5, child: sample_png)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('PNM')),
                          Expanded(flex: 5, child: sample_pnm)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('PPM')),
                          Expanded(flex: 5, child: sample_ppm)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('PSD')),
                          Expanded(flex: 5, child: sample_psd)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('RAF')),
                          Expanded(flex: 5, child: sample_raf)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('RAS')),
                          Expanded(flex: 5, child: sample_ras)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('RW2')),
                          Expanded(flex: 5, child: sample_rw2)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('SGI')),
                          Expanded(flex: 5, child: sample_sgi)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('SVG')),
                          Expanded(flex: 5, child: sample_svg)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('TGA')),
                          Expanded(flex: 5, child: sample_tga)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('TIFF')),
                          Expanded(flex: 5, child: sample_tiff)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('WBMP')),
                          Expanded(flex: 5, child: sample_wbmp)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('WEBP')),
                          Expanded(flex: 5, child: sample_webp)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('XBM')),
                          Expanded(flex: 5, child: sample_xbm)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('XPM')),
                          Expanded(flex: 5, child: sample_xpm)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: const Text('XWD')),
                          Expanded(flex: 5, child: sample_xwd)
                        ],
                      ),
                    ],
                  )))),
    );
  }
}
