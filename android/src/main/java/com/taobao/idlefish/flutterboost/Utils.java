/*
 * The MIT License (MIT)
 * 
 * Copyright (c) 2019 Alibaba Group
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.taobao.idlefish.flutterboost;

import android.graphics.Bitmap;
import android.graphics.Color;

public class Utils {

    public static boolean checkImageValid(final Bitmap bitmap) {
        if (null == bitmap) {
            return false;
        }

        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        int[] pixels = new int[width * height];
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height);
        int [] checkPixels = new int[18];
        for (int i=0; i<5; i++) {
            int colCount = 4 - i%2;
            for (int j=0; j<colCount; j++) {
                checkPixels[i*3 + j + (i+1)/2] = pixels[(i + 1)*(height/6)*width + (j + 1)*(width/(colCount + 1))];
            }
        }
        float[][] checkHSV = new float[checkPixels.length][3];
        for (int i=0; i<checkPixels.length; i++) {
            int clr = checkPixels[i];
            int red = (clr & 0x00ff0000) >> 16; // 取高两位
            int green = (clr & 0x0000ff00) >> 8; // 取中两位
            int blue = clr & 0x000000ff;
            Color.RGBToHSV(red, green, blue, checkHSV[i]);
        }

        int diffCount = 0;
        for (int i=0; i<checkPixels.length; i++) {
            for (int j=i+1; j<checkPixels.length; j++) {
                double d = Math.sqrt(Math.pow(checkHSV[i][0] - checkHSV[j][0], 2.0)
                        + Math.pow(checkHSV[i][1] - checkHSV[j][1], 2.0)
                        + Math.pow(checkHSV[i][2] - checkHSV[j][2], 2.0));
                if (d >= 1) {
                    diffCount++;
                }
            }
        }

        if (diffCount <= 10) {
            return false;
        } else {
            return true;
        }
    }
}