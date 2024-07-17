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

import { FlutterBoostPlugin } from './src/main/ets/components/plugin/FlutterBoostPlugin';
import { FlutterBoost } from './src/main/ets/components/FlutterBoost';
import FlutterBoostDelegate from './src/main/ets/components/FlutterBoostDelegate';
import {
  FlutterBoostSetupOptions,
  FlutterBoostSetupOptionsBuilder
} from './src/main/ets/components/FlutterBoostSetupOptions';
import FlutterBoostRouteOptions, {
  FlutterBoostRouteOptionsBuilder
} from './src/main/ets/components/FlutterBoostRouteOptions';

import FlutterBoostAbility from './src/main/ets/components/containers/FlutterBoostAbility';
import FlutterBoostEntry, {
  FlutterBoostRouteResult
} from './src/main/ets/components/containers/FlutterBoostEntry';
import { FlutterBoostPage } from './src/main/ets/components/containers/FlutterBoostPage';
import CommonParams from './src/main/ets/components/messages/CommonParams';
import FlutterContainerManager from './src/main/ets/components/containers/FlutterContainerManager';

export {
  CommonParams,
  FlutterBoostAbility,
  FlutterBoost,
  FlutterBoostDelegate,
  FlutterBoostSetupOptions,
  FlutterBoostSetupOptionsBuilder,
  FlutterBoostRouteOptions,
  FlutterBoostRouteOptionsBuilder,
  FlutterBoostRouteResult,
  FlutterBoostEntry,
  FlutterBoostPage,
  FlutterContainerManager,
}

export default FlutterBoostPlugin;
