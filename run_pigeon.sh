#!/bin/sh
# Copyright (c) 2019 Alibaba Group. All rights reserved.
# Use of this source code is governed by a MIT license that can be
# found in the LICENSE file.

flutter pub get && flutter pub run pigeon --input pigeon/messages.dart
