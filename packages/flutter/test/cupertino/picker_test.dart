// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../rendering/mock_canvas.dart';

void main() {
  testWidgets('Picker respects theme styling', (WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 300.0,
            width: 300.0,
            child: CupertinoPicker(
              itemExtent: 50.0,
              onSelectedItemChanged: (_) { },
              children: List<Widget>.generate(3, (int index) {
                return SizedBox(
                  height: 50.0,
                  width: 300.0,
                  child: Text(index.toString()),
                );
              }),
            ),
          ),
        ),
      ),
    );

    final RenderParagraph paragraph = tester.renderObject(find.text('1'));

    expect(paragraph.text.style!.color, isSameColorAs(CupertinoColors.black));
    expect(paragraph.text.style!.copyWith(color: CupertinoColors.black), const TextStyle(
      inherit: false,
      fontFamily: '.SF Pro Display',
      fontSize: 21.0,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.6,
      color: CupertinoColors.black,
    ));
  });

  group('layout', () {
    // Regression test for https://github.com/flutter/flutter/issues/22999
    testWidgets('CupertinoPicker.builder test', (WidgetTester tester) async {
      Widget buildFrame(int childCount) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: CupertinoPicker.builder(
            itemExtent: 50.0,
            onSelectedItemChanged: (_) { },
            itemBuilder: (BuildContext context, int index) {
              return Text('$index');
            },
            childCount: childCount,
          ),
        );
      }

      await tester.pumpWidget(buildFrame(1));
      expect(tester.renderObject(find.text('0')).attached, true);

      await tester.pumpWidget(buildFrame(2));
      expect(tester.renderObject(find.text('0')).attached, true);
      expect(tester.renderObject(find.text('1')).attached, true);
    });

    testWidgets('selected item is in the middle', (WidgetTester tester) async {
      final FixedExtentScrollController controller = FixedExtentScrollController(initialItem: 1);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 300.0,
              width: 300.0,
              child: CupertinoPicker(
                scrollController: controller,
                itemExtent: 50.0,
                onSelectedItemChanged: (_) { },
                children: List<Widget>.generate(3, (int index) {
                  return SizedBox(
                    height: 50.0,
                    width: 300.0,
                    child: Text(index.toString()),
                  );
                }),
              ),
            ),
          ),
        ),
      );

      expect(
        tester.getTopLeft(find.widgetWithText(SizedBox, '1').first),
        const Offset(0.0, 125.0),
      );

      controller.jumpToItem(0);
      await tester.pump();

      expect(
        tester.getTopLeft(find.widgetWithText(SizedBox, '1').first),
        const Offset(0.0, 175.0),
      );
      expect(
        tester.getTopLeft(find.widgetWithText(SizedBox, '0').first),
        const Offset(0.0, 125.0),
      );
    });
  });

  testWidgets('picker dark mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        theme: const CupertinoThemeData(brightness: Brightness.light),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 300.0,
            width: 300.0,
            child: CupertinoPicker(
              backgroundColor: const CupertinoDynamicColor.withBrightness(
                color: Color(0xFF123456), // Set alpha channel to FF to disable under magnifier painting.
                darkColor: Color(0xFF654321),
              ),
              itemExtent: 15.0,
              children: const <Widget>[Text('1'), Text('1')],
              onSelectedItemChanged: (int i) { },
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CupertinoPicker), paints..rrect(color: const Color.fromARGB(30, 118, 118, 128)));
    expect(find.byType(CupertinoPicker), paints..rect(color: const Color(0xFF123456)));

    await tester.pumpWidget(
      CupertinoApp(
        theme: const CupertinoThemeData(brightness: Brightness.dark),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 300.0,
            width: 300.0,
            child: CupertinoPicker(
              backgroundColor: const CupertinoDynamicColor.withBrightness(
                color: Color(0xFF123456),
                darkColor: Color(0xFF654321),
              ),
              itemExtent: 15.0,
              children: const <Widget>[Text('1'), Text('1')],
              onSelectedItemChanged: (int i) { },
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CupertinoPicker), paints..rrect(color: const Color.fromARGB(61,118, 118, 128)));
    expect(find.byType(CupertinoPicker), paints..rect(color: const Color(0xFF654321)));
  });

  testWidgets('picker selectionOverlay', (WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        theme: const CupertinoThemeData(brightness: Brightness.light),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 300.0,
            width: 300.0,
            child: CupertinoPicker(
              itemExtent: 15.0,
              onSelectedItemChanged: (int i) {},
              selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(background: Color(0x12345678)),
              children: const <Widget>[Text('1'), Text('1')],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CupertinoPicker), paints..rrect(color: const Color(0x12345678)));
  });

  testWidgets('CupertinoPicker.selectionOverlay is nullable', (WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        theme: const CupertinoThemeData(brightness: Brightness.light),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 300.0,
            width: 300.0,
            child: CupertinoPicker(
              itemExtent: 15.0,
              onSelectedItemChanged: (int i) {},
              selectionOverlay: null,
              children: const <Widget>[Text('1'), Text('1')],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CupertinoPicker), isNot(paints..rrect()));
  });

  group('scroll', () {
    testWidgets(
      'scrolling calls onSelectedItemChanged and triggers haptic feedback',
      (WidgetTester tester) async {
        final List<int> selectedItems = <int>[];
        final List<MethodCall> systemCalls = <MethodCall>[];

        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
          systemCalls.add(methodCall);
          return null;
        });

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CupertinoPicker(
              itemExtent: 100.0,
              onSelectedItemChanged: (int index) { selectedItems.add(index); },
              children: List<Widget>.generate(100, (int index) {
                return Center(
                  child: SizedBox(
                    width: 400.0,
                    height: 100.0,
                    child: Text(index.toString()),
                  ),
                );
              }),
            ),
          ),
        );

        await tester.drag(find.text('0'), const Offset(0.0, -100.0), warnIfMissed: false); // has an IgnorePointer
        expect(selectedItems, <int>[1]);
        expect(
          systemCalls.single,
          isMethodCall(
            'HapticFeedback.vibrate',
            arguments: 'HapticFeedbackType.selectionClick',
          ),
        );

        await tester.drag(find.text('0'), const Offset(0.0, 100.0), warnIfMissed: false); // has an IgnorePointer
        expect(selectedItems, <int>[1, 0]);
        expect(systemCalls, hasLength(2));
        expect(
          systemCalls.last,
          isMethodCall(
            'HapticFeedback.vibrate',
            arguments: 'HapticFeedbackType.selectionClick',
          ),
        );
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'do not trigger haptic effects on non-iOS devices',
      (WidgetTester tester) async {
        final List<int> selectedItems = <int>[];
        final List<MethodCall> systemCalls = <MethodCall>[];

        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
          systemCalls.add(methodCall);
          return null;
        });

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CupertinoPicker(
              itemExtent: 100.0,
              onSelectedItemChanged: (int index) { selectedItems.add(index); },
              children: List<Widget>.generate(100, (int index) {
                return Center(
                  child: SizedBox(
                    width: 400.0,
                    height: 100.0,
                    child: Text(index.toString()),
                  ),
                );
              }),
            ),
          ),
        );

        await tester.drag(find.text('0'), const Offset(0.0, -100.0), warnIfMissed: false); // has an IgnorePointer
        expect(selectedItems, <int>[1]);
        expect(systemCalls, isEmpty);
      },
      variant: TargetPlatformVariant(TargetPlatform.values.where((TargetPlatform platform) => platform != TargetPlatform.iOS).toSet()),
    );

    testWidgets('a drag in between items settles back', (WidgetTester tester) async {
      final FixedExtentScrollController controller = FixedExtentScrollController(initialItem: 10);
      final List<int> selectedItems = <int>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CupertinoPicker(
            scrollController: controller,
            itemExtent: 100.0,
            onSelectedItemChanged: (int index) { selectedItems.add(index); },
            children: List<Widget>.generate(100, (int index) {
              return Center(
                child: SizedBox(
                  width: 400.0,
                  height: 100.0,
                  child: Text(index.toString()),
                ),
              );
            }),
          ),
        ),
      );

      // Drag it by a bit but not enough to move to the next item.
      await tester.drag(find.text('10'), const Offset(0.0, 30.0), touchSlopY: 0.0, warnIfMissed: false); // has an IgnorePointer

      // The item that was in the center now moved a bit.
      expect(
        tester.getTopLeft(find.widgetWithText(SizedBox, '10')),
        const Offset(200.0, 280.0),
      );

      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.widgetWithText(SizedBox, '10')).dy,
        moreOrLessEquals(250.0, epsilon: 0.5),
      );
      expect(selectedItems.isEmpty, true);

      // Drag it by enough to move to the next item.
      await tester.drag(find.text('10'), const Offset(0.0, 70.0), touchSlopY: 0.0, warnIfMissed: false); // has an IgnorePointer

      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.widgetWithText(SizedBox, '10')).dy,
        // It's down by 100.0 now.
        moreOrLessEquals(350.0, epsilon: 0.5),
      );
      expect(selectedItems, <int>[9]);
    }, variant: const TargetPlatformVariant(<TargetPlatform>{ TargetPlatform.iOS,  TargetPlatform.macOS }));

    testWidgets('a big fling that overscrolls springs back', (WidgetTester tester) async {
      final FixedExtentScrollController controller =
          FixedExtentScrollController(initialItem: 10);
      final List<int> selectedItems = <int>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CupertinoPicker(
            scrollController: controller,
            itemExtent: 100.0,
            onSelectedItemChanged: (int index) { selectedItems.add(index); },
            children: List<Widget>.generate(100, (int index) {
              return Center(
                child: SizedBox(
                  width: 400.0,
                  height: 100.0,
                  child: Text(index.toString()),
                ),
              );
            }),
          ),
        ),
      );

      // A wild throw appears.
      await tester.fling(
        find.text('10'),
        const Offset(0.0, 10000.0),
        1000.0,
        warnIfMissed: false, // has an IgnorePointer
      );

      // Should have been flung far enough that even the first item goes off
      // screen and gets removed.
      expect(find.widgetWithText(SizedBox, '0').evaluate().isEmpty, true);

      expect(
        selectedItems,
        // This specific throw was fast enough that each scroll update landed
        // on every second item.
        <int>[8, 6, 4, 2, 0],
      );

      // Let it spring back.
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.widgetWithText(SizedBox, '0')).dy,
        // Should have sprung back to the middle now.
        moreOrLessEquals(250.0),
      );
      expect(
        selectedItems,
        // Falling back to 0 shouldn't produce more callbacks.
        <int>[8, 6, 4, 2, 0],
      );
    }, variant: const TargetPlatformVariant(<TargetPlatform>{ TargetPlatform.iOS,  TargetPlatform.macOS }));
  });

  testWidgets('Picker adapts to MaterialApp dark mode', (WidgetTester tester) async {
    Widget _buildCupertinoPicker(Brightness brightness) {
      return MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 300.0,
            width: 300.0,
            child: CupertinoPicker(
              itemExtent: 50.0,
              onSelectedItemChanged: (_) { },
              children: List<Widget>.generate(3, (int index) {
                return SizedBox(
                  height: 50.0,
                  width: 300.0,
                  child: Text(index.toString()),
                );
              }),
            ),
          ),
        ),
      );
    }

    // CupertinoPicker with light theme.
    await tester.pumpWidget(_buildCupertinoPicker(Brightness.light));
    RenderParagraph paragraph = tester.renderObject(find.text('1'));
    expect(paragraph.text.style!.color, CupertinoColors.label);
    // Text style should not return unresolved color.
    expect(paragraph.text.style!.color.toString().contains('UNRESOLVED'), isFalse);

    // CupertinoPicker with dark theme.
    await tester.pumpWidget(_buildCupertinoPicker(Brightness.dark));
    paragraph = tester.renderObject(find.text('1'));
    expect(paragraph.text.style!.color, CupertinoColors.label);
    // Text style should not return unresolved color.
    expect(paragraph.text.style!.color.toString().contains('UNRESOLVED'), isFalse);
  });

  group('CupertinoPickerDefaultSelectionOverlay', () {
    testWidgets('should be using directional decoration', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(brightness: Brightness.light),
          home: CupertinoPicker(
            itemExtent: 15.0,
            onSelectedItemChanged: (int i) {},
            selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(background: Color(0x12345678)),
            children: const <Widget>[Text('1'), Text('1')],
          ),
        ),
      );

      final Finder selectionContainer = find.byType(Container);
      final Container container = tester.firstWidget<Container>(selectionContainer);
      final EdgeInsetsGeometry? margin = container.margin;
      final BorderRadiusGeometry? borderRadius = (container.decoration as BoxDecoration?)?.borderRadius;

      expect(margin, isA<EdgeInsetsDirectional>());
      expect(borderRadius, isA<BorderRadiusDirectional>());
    });
  });
}
