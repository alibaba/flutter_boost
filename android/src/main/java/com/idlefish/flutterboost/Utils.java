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
package com.idlefish.flutterboost;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Build;
import android.os.Looper;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import com.alibaba.fastjson.JSON;

import java.io.*;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.net.URLEncoder;
import java.util.List;
import java.util.Map;

public class Utils {

    public static void assertCallOnMainThread() {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            Debuger.exception("must call method on main thread");
        }
    }

    public static void saveBitmap(Bitmap bm,File path, String name) {
        try {
            File f = new File(path,name);

            if (!path.exists()) {
                if(!path.mkdirs()) {
                    throw new Exception("mkdir except");
                }

                if(!f.createNewFile()){
                    throw new Exception("createNewFile except");
                }
            }

            FileOutputStream out = new FileOutputStream(f);
            bm.compress(Bitmap.CompressFormat.PNG, 100, out);
            out.flush();
            out.close();

            Debuger.exception("saved bitmap:"+f.getAbsolutePath());
        } catch (Throwable t){
            throw new RuntimeException(t);
        }
    }

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

    public static int getMetricsWidth(Context context) {
        //尝试拿真实的屏幕分辨率
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            WindowManager windowMgr = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
            if (null != windowMgr) {
                DisplayMetrics metrics = new DisplayMetrics();
                windowMgr.getDefaultDisplay().getMetrics(metrics);
                if (metrics.widthPixels > 0 && metrics.heightPixels > 0) {
                    return metrics.widthPixels;
                }
            }
        }

        DisplayMetrics metrics = context.getResources().getDisplayMetrics();
        return metrics.widthPixels;
    }

    public static int getMetricsHeight(Context context) {
        //尝试拿真实的屏幕分辨率
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            WindowManager windowMgr = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
            if (null != windowMgr) {
                DisplayMetrics metrics = new DisplayMetrics();
                windowMgr.getDefaultDisplay().getMetrics(metrics);
                if (metrics.widthPixels > 0 && metrics.heightPixels > 0) {
                    return metrics.heightPixels;
                }
            }
        }

        DisplayMetrics metrics = context.getResources().getDisplayMetrics();
        return metrics.heightPixels;
    }

    public static int getStatusBarHeight(Context context) {
        int result = 0;
        int resourceId = context.getResources().getIdentifier("status_bar_height", "dimen", "android");
        if (resourceId > 0) {
            result = context.getResources().getDimensionPixelSize(resourceId);
        }
        return result;
    }

    public static void setStatusBarLightMode(Activity activity, boolean dark) {
        try {
            String pp = Build.MANUFACTURER;
            if (pp == null) pp = "unknow";
            pp = pp.toLowerCase();
            android.util.Log.e("ImmerseTheme","current MANUFACTURER="+pp);
            if (pp.contains("xiaomi") || pp.contains("redmi")) {
                setMIUISetStatusBarLightMode(activity, dark);
            } else if (pp.contains("meizu")) {
                StatusbarColorUtils.setStatusBarDarkIcon(activity,true);
            }else{
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    android.util.Log.e("ImmerseTheme", "setStatusBarLightMode");
                    if(dark) {
                        activity.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
                    } else {
                        activity.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN & ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
                    }
                }
            }
        }catch (Throwable t){
//            Debuger.exception(t);
            t.printStackTrace();
        }
    }

    private static void setMIUISetStatusBarLightMode(Activity activity, boolean dark) {
        try {
            if (isCurrentMIUIVersionBiggerAndEqual("V9") && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                android.util.Log.e("ImmerseTheme", "setMIUISetStatusBarLightMode MIUI > 9");
                if(dark) {
                    activity.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
                } else {
                    activity.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN & ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
                }

            } else if (activity.getWindow() != null) {
                android.util.Log.e("ImmerseTheme", "setMIUISetStatusBarLightMode MIUI < 9");
                Window window = activity.getWindow();
                Class clazz = window.getClass();

                int darkModeFlag = 0;
                Class layoutParams = Class.forName("android.view.MiuiWindowManager$LayoutParams");
                Field field = layoutParams.getField("EXTRA_FLAG_STATUS_BAR_DARK_MODE");
                darkModeFlag = field.getInt(layoutParams);
                Method extraFlagField = clazz.getMethod("setExtraFlags", int.class, int.class);
                if (dark) {
                    extraFlagField.invoke(window, darkModeFlag, darkModeFlag);//状态栏透明且黑色字体
                } else {
                    extraFlagField.invoke(window, 0, darkModeFlag);//清除黑色字体
                }
            }
        } catch (Exception e) {
            Debuger.exception(e);
        }
    }

    public static boolean isCurrentMIUIVersionBiggerAndEqual(String version) {
        if (TextUtils.isEmpty(version)) return false;
        //V9
        int version2 = Integer.parseInt(version.substring(1));
        int version1 = 0;
        String systemVersion = getMIUISystemVersion();
        if (!TextUtils.isEmpty(systemVersion) && systemVersion.length() > 1) {
            version1 = Integer.parseInt(systemVersion.substring(1));
        }
        return version1 != 0 && version2 != 0 && version1 >= version2;
    }

    public static String getMIUISystemVersion() {
        String line;
        BufferedReader input = null;
        try {
            Process p = Runtime.getRuntime().exec("getprop ro.miui.ui.version.name");
            input = new BufferedReader(new InputStreamReader(p.getInputStream()), 1024);
            line = input.readLine();
            input.close();
        } catch (IOException ex) {
            return null;
        } finally {
            if (input != null) {
                try {
                    input.close();
                } catch (IOException e) {
                }
            }
        }
        return line;
    }

    public static void fixInputMethodManagerLeak(Context destContext) {
        if (destContext == null) {
            return;
        }

        InputMethodManager imm = (InputMethodManager) destContext.getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm == null) {
            return;
        }

        String [] arr = new String[]{"mLastSrvView","mServedView", "mNextServedView"};
        Field f = null;
        Object obj_get = null;
        for (int i = 0;i < arr.length;i ++) {
            String param = arr[i];
            try{
                f = imm.getClass().getDeclaredField(param);
                if (f.isAccessible() == false) {
                    f.setAccessible(true);
                }
                obj_get = f.get(imm);
                if (obj_get != null && obj_get instanceof View) {
                    View v_get = (View) obj_get;
                    if (v_get.getContext() == destContext) {
                        f.set(imm, null);
                    } else {
                        break;
                    }
                }
            }catch(Throwable t){
//                t.printStackTrace();
            }
        }
    }




    public static String assembleUrl(String url,Map<String, Object> urlParams){

        StringBuilder targetUrl = new StringBuilder(url);
        if(urlParams != null && !urlParams.isEmpty()) {
            if(!targetUrl.toString().contains("?")){
                targetUrl.append("?");
            }


            for(Map.Entry entry:urlParams.entrySet()) {
                if(entry.getValue() instanceof Map ) {
                    Map<String,Object> params = (Map<String,Object> )entry.getValue();

                    for(Map.Entry param:params.entrySet()) {
                        String key = (String)param.getKey();
                        String value = null;
                        if(param.getValue() instanceof Map || param.getValue() instanceof List) {
                            try {
                                value = URLEncoder.encode(JSON.toJSONString(param.getValue()), "UTF-8");
                            } catch (UnsupportedEncodingException e) {
                                e.printStackTrace();
                            }
                        }else{
                            value = (param.getValue()==null?null:URLEncoder.encode( String.valueOf(param.getValue())));
                        }

                        if(value==null){
                            continue;
                        }
                        if(targetUrl.toString().endsWith("?")){
                            targetUrl.append(key).append("=").append(value);
                        }else{
                            targetUrl.append("&").append(key).append("=").append(value);
                        }

                    }
                }

            }


        }
        return  targetUrl.toString();
    }




}