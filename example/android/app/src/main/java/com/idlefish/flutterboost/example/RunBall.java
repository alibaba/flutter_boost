package com.idlefish.flutterboost.example;

import android.animation.ValueAnimator;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Point;
import androidx.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.view.animation.LinearInterpolator;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class RunBall extends View {
    private ValueAnimator mAnimator;//时间流

    private List<Ball> mBalls;//小球对象
    private Paint mPaint;//主画笔
    private Paint mHelpPaint;//辅助线画笔
    private Point mCoo;//坐标系

    private float defaultR = 10;//默认小球半径
    private int defaultColor = Color.BLUE;//默认小球颜色
    private float defaultVX = 10;//默认小球x方向速度
    private float defaultF = 0.95f;//碰撞损耗
    private float defaultVY = -10;//默认小球y方向速度
    private float defaultAY = 0.1f;//默认小球加速度

    private float mMaxX = 500;//X最大值
    private float mMinX = 10;//X最小值
    private float mMaxY = 400;//Y最大值
    private float mMinY = 10;//Y最小值

    private LinearInterpolator li;

    public RunBall(Context context) {
        this(context, null);
    }

    public RunBall(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private void init() {
        mCoo = new Point(10, 10);
        //初始化小球

        //初始画笔
        mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mBalls = new ArrayList<>();
        //Ball ball = initBall();
        for(int i=0;i<100;i++) {
            Ball ball = initBall();
            mBalls.add(ball); //添加一个
        }
        mHelpPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mHelpPaint.setColor(Color.BLACK);
        mHelpPaint.setStyle(Paint.Style.FILL);
        mHelpPaint.setStrokeWidth(3);

        //初始化时间流ValueAnimator
        mAnimator = ValueAnimator.ofFloat(-1, 0);
        mAnimator.setRepeatCount(-1);
        mAnimator.setDuration(1000);
        mAnimator.setRepeatMode(ValueAnimator.REVERSE);
        mAnimator.setInterpolator(new LinearInterpolator());
        //需要开发者选项，打开“动画程序时长”为非关闭状态即可。
        //
        //原因是ValueAnimator是Android用来做动画的选项，
        //因为所有的Animator都有一个Interpolator（默认是AccelerateDecelerateInterpolator），
        //而setInterpolator传入的值是TimeInterpolator，即“动画程序时长”
        mAnimator.addUpdateListener(animation -> {
            // android.util.Log.d("JUMIN", "addUpdateListener "+animation.getAnimatedValue());
            updateBall();//更新小球位置
            invalidate();
        });
        mAnimator.start();

    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        canvas.save();
        canvas.translate(mCoo.x, mCoo.y);
        drawBalls(canvas, mBalls);
        canvas.restore();
    }

    /**
     * 绘制小球集合
     *
     * @param canvas
     * @param balls  小球集合
     */
    private void drawBalls(Canvas canvas, List<Ball> balls) {
        for (Ball ball : balls) {
            //ball.color =randomRGB();
            mPaint.setColor(ball.color);
            canvas.drawCircle(ball.x, ball.y, ball.r, mPaint);
        }
    }

    /**
     * 更新小球
     */
    private void updateBall() {
        for (int i = 0; i < mBalls.size(); i++) {
            Ball ball = mBalls.get(i);

            ball.x += ball.vX;
            ball.y += ball.vY;
            ball.vY += ball.aY;
            ball.vX += ball.aX;
            if (ball.x > mMaxX - ball.r) {
//                Ball newBall = ball.clone();//新建一个ball同等信息的球
//                //newBall.r = newBall.r / 2;
//                newBall.vX = -newBall.vX;
//                newBall.vY = -newBall.vY;
//                mBalls.add(newBall);

                ball.x = mMaxX - ball.r;
                ball.vX = -ball.vX;// * defaultF;
                ball.color =randomRGB();//更改颜色
                //ball.r = ball.r / 2;
            }
            if (ball.x < mMinX - ball.r) {
//                Ball newBall = ball.clone();
//                //newBall.r = newBall.r / 2;
//                newBall.vX = -newBall.vX;
//                newBall.vY = -newBall.vY;
//                mBalls.add(newBall);

                ball.x = mMinX + ball.r;
                ball.vX = -ball.vX ;//* defaultF;
                ball.color =randomRGB();

                //ball.r = ball.r / 2;
            }
            if (ball.y > mMaxY - ball.r) {

                ball.y = mMaxY - ball.r;
                ball.vY = -ball.vY;// * defaultF;
                ball.color =randomRGB();
            }
            if (ball.y < mMinY + ball.r) {
                ball.y = mMinY + ball.r;
                ball.vY = -ball.vY ;//* defaultF;
                ball.color =randomRGB();
            }
        }
    }


//    @Override
//    public boolean onTouchEvent(MotionEvent event) {
//        switch (event.getAction()) {
//            case MotionEvent.ACTION_DOWN:
//                mAnimator.start();
//                break;
//            case MotionEvent.ACTION_UP:
////                mAnimator.pause();
//                break;
//        }
//        return true;
//    }

    private Ball initBall() {
        float vx = new Random().nextFloat();
        Ball mBall = new Ball();
        mBall.color = defaultColor;
        mBall.r = defaultR;
        mBall.vX = defaultVX*vx;
        mBall.vY = defaultVY*vx;
        mBall.aY = defaultAY;
        Random random = new Random();
        mBall.x = random.nextInt(600);
        mBall.y = random.nextInt(300);
        return mBall;
    }


    /**
     * 返回随机颜色
     *
     * @return 随机颜色
     */
    public static int randomRGB() {
        Random random = new Random();
        int r = 30 + random.nextInt(200);
        int g = 30 + random.nextInt(200);
        int b = 30 + random.nextInt(200);
        return Color.rgb( r, g, b);
    }
}
