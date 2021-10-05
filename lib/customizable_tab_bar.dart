library customizable_tab_bar;

import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'utils/animation_converter.dart';
import 'utils/custom_clippers.dart';

part 'customizable_tab.dart';

class CustomizableTabBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomizableTabBar({
    Key? key,
    this.height = 46,
    required this.tabs,
    this.controller,
    this.backgroundColor,
    this.tabTextColor,
    this.textStyle,
    this.selectedTabTextColor,
    this.indicatorColor,
    this.squeezeIntensity = 1,
    this.indicatorPadding = EdgeInsets.zero,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.radius = const Radius.circular(20),
    this.splashColor,
    this.splashHighlightColor,
  }) : super(key: key);

  final double height;
  final List<CustomizableTab> tabs;
  final TabController? controller;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final Color? tabTextColor;
  final Color? selectedTabTextColor;
  final Color? indicatorColor;
  final double squeezeIntensity;
  final EdgeInsets indicatorPadding;
  final EdgeInsets tabPadding;
  final Radius radius;
  final Color? splashColor;
  final Color? splashHighlightColor;

  @override
  _CustomizableTabBarState createState() => _CustomizableTabBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _CustomizableTabBarState extends State<CustomizableTabBar>
    with SingleTickerProviderStateMixin {
  EdgeInsets _currentTilePadding = EdgeInsets.zero;
  Alignment _currentIndicatorAlignment = Alignment.centerLeft;
  double _offset = 0;
  late AnimationController _internalAnimationController;
  late Animation<double> _internalAnimation;
  late AnimationConverter _converter;
  TabController? _controller;
  double _maxOffset = 1;

  @override
  void initState() {
    super.initState();
    _internalAnimationController = AnimationController(vsync: this);
    _internalAnimationController.addListener(_handleInternalAnimationTick);
  }

  @override
  void dispose() {
    _internalAnimationController.removeListener(_handleInternalAnimationTick);
    _internalAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
    _updateConverter();
  }

  @override
  void didUpdateWidget(CustomizableTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateTabController();
    }
    if (!const ListEquality().equals(widget.tabs, oldWidget.tabs)) {
      _updateConverter();
    }
  }

  bool get _controllerIsValid => _controller?.animation != null;

  void _updateTabController() {
    final TabController? newController =
        widget.controller ?? DefaultTabController.of(context);
    assert(() {
      if (newController == null) {
        throw FlutterError(
          'No TabController for ${widget.runtimeType}.\n'
          'When creating a ${widget.runtimeType}, you must either provide an explicit '
          'TabController using the "controller" property, or you must ensure that there '
          'is a DefaultTabController above the ${widget.runtimeType}.\n'
          'In this case, there was neither an explicit controller nor a default controller.',
        );
      }
      return true;
    }());

    if (newController == _controller) {
      return;
    }

    if (_controllerIsValid) {
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    }
    _controller = newController;
    if (_controller != null) {
      _controller!.animation!.addListener(_handleTabControllerAnimationTick);
    }
  }

  void _handleInternalAnimationTick() {
    setState(() {
      _offset = _internalAnimation.value;
    });
  }

  void _handleTabControllerAnimationTick() {
    final currentValue = _controller!.animation!.value;
    _animateIndicatorTo(
        _animationValueToOffset(_converter.convertValue(currentValue)));
  }

  void _updateConverter() {
    _converter = AnimationConverter(
      animation: _controller!.animation!,
      minAnimationValue: 0,
      maxAnimationValue: _controller!.length - 1,
      stops: _generateStops(),
    );
  }

  Map<double, double> _generateStops() {
    final flexes = widget.tabs.map((e) => e.flex).toList();
    final flexesSum = flexes.reduce((a, b) => a + b);
    final step = (_controller!.length) / flexesSum;
    Map<double, double> stops = {};
    for (int i = 1; i < _controller!.length - 1; i++) {
      stops[i.toDouble()] = flexes.take(i).reduce((a, b) => a + b) * step;
    }
    return stops;
  }

  void _updateControllerIndex() {
    _controller!.index = _internalIndex;
  }

  TickerFuture _animateIndicatorToNearest(
      Offset pixelsPerSecond, double width) {
    final nearest = _internalIndex;
    final target = _animationValueToOffset(nearest.toDouble());
    _internalAnimation = _internalAnimationController.drive(Tween<double>(
      begin: _offset,
      end: target,
    ));
    final unitsPerSecondX = pixelsPerSecond.dx / width;
    final unitsPerSecond = Offset(unitsPerSecondX, 0);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    return _internalAnimationController.animateWith(simulation);
  }

  TickerFuture _animateIndicatorTo(double target) {
    _internalAnimation = _internalAnimationController.drive(Tween<double>(
      begin: _offset,
      end: target,
    ));

    return _internalAnimationController.fling();
  }

  double _animationValueToOffset(double? value) {
    if (value == null) {
      return 0;
    }
    final x = value / (_controller!.length - 1) * _maxOffset;
    log(x.toStringAsFixed(2) +
        ' ' +
        value.toStringAsFixed(2) +
        ' ' +
        _maxOffset.toStringAsFixed(2));
    return x;
  }

  int get _internalIndex => _offsetToIndex(_offset);
  int _offsetToIndex(double alignment) {
    final currentPosition = _offset / _maxOffset * (_controller!.length - 1);
    return currentPosition.round();
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = widget.tabs[_internalIndex];

    final textStyle =
        widget.textStyle ?? Theme.of(context).textTheme.bodyText2!;

    final selectedTabTextColor = currentTab.selectedTextColor ??
        widget.selectedTabTextColor ??
        Colors.white;

    final tabTextColor = currentTab.textColor ??
        widget.tabTextColor ??
        Colors.white.withOpacity(0.7);

    final backgroundColor = currentTab.backgroundColor ??
        widget.backgroundColor ??
        Theme.of(context).colorScheme.background;

    final indicatorColor = currentTab.color ??
        widget.indicatorColor ??
        Theme.of(context).indicatorColor;

    final borderRadius = BorderRadius.all(widget.radius);

    return DefaultTextStyle(
      style: widget.textStyle ?? DefaultTextStyle.of(context).style,
      child: LayoutBuilder(builder: (context, constraints) {
        final indicatorWidth =
            (constraints.maxWidth - widget.indicatorPadding.horizontal) /
                widget.tabs.map((e) => e.flex).reduce((a, b) => a + b) *
                currentTab.flex;

        _maxOffset = constraints.maxWidth - indicatorWidth;

        return ClipRRect(
          borderRadius: BorderRadius.all(widget.radius),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: kTabScrollDuration,
                  curve: Curves.ease,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: borderRadius,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: _Labels(
                      radius: widget.radius,
                      splashColor: widget.splashColor,
                      splashHighlightColor: widget.splashHighlightColor,
                      callbackBuilder: _onTabTap(),
                      availableSpace: constraints.maxWidth,
                      tabs: widget.tabs,
                      currentIndex: _internalIndex,
                      textStyle: textStyle.copyWith(
                        color: tabTextColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: _offset,
                  child: GestureDetector(
                    onPanDown: _onPanDown(),
                    onPanUpdate: _onPanUpdate(constraints),
                    onPanEnd: _onPanEnd(constraints),
                    child: _SqueezeAnimated(
                      currentTilePadding: _currentTilePadding,
                      builder: (additionalPadding) => Padding(
                        padding: EdgeInsets.only(top: additionalPadding.top),
                        child: AnimatedContainer(
                          duration: kTabScrollDuration,
                          curve: Curves.ease,
                          width: indicatorWidth,
                          height: widget.height -
                              widget.indicatorPadding.vertical -
                              additionalPadding.vertical,
                          decoration: BoxDecoration(
                            color: indicatorColor,
                            borderRadius: BorderRadius.all(widget.radius),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _SqueezeAnimated(
                  currentTilePadding: _currentTilePadding,
                  builder: (squeezePadding) => TweenAnimationBuilder<double>(
                    duration: kTabScrollDuration,
                    curve: Curves.ease,
                    tween: Tween<double>(
                      begin: indicatorWidth,
                      end: indicatorWidth,
                    ),
                    builder: (context, value, _) => ClipPath(
                      clipper: RRectRevealClipper(
                        radius: widget.radius,
                        size: Size(
                          value,
                          widget.height -
                              widget.indicatorPadding.vertical -
                              squeezePadding.vertical,
                        ),
                        offset: Offset(_offset, 0),
                      ),
                      child: IgnorePointer(
                        child: _Labels(
                          radius: widget.radius,
                          splashColor: widget.splashColor,
                          splashHighlightColor: widget.splashHighlightColor,
                          availableSpace: constraints.maxWidth,
                          tabs: widget.tabs,
                          currentIndex: _internalIndex,
                          textStyle: textStyle.copyWith(
                            color: selectedTabTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  VoidCallback Function(int)? _onTabTap() {
    if (_controller!.indexIsChanging) {
      return null;
    }
    return (int index) => () {
          _internalAnimationController.stop();
          _controller!.animateTo(index);
        };
  }

  GestureDragDownCallback? _onPanDown() {
    if (_controller!.indexIsChanging) {
      return null;
    }
    return (details) {
      _internalAnimationController.stop();
      setState(() {
        _currentTilePadding =
            EdgeInsets.symmetric(vertical: widget.squeezeIntensity);
      });
    };
  }

  GestureDragUpdateCallback? _onPanUpdate(BoxConstraints constraints) {
    if (_controller!.indexIsChanging) {
      return null;
    }
    return (details) {
      double x = _currentIndicatorAlignment.x +
          details.delta.dx / (constraints.maxWidth / 2);
      if (x < -1) {
        x = -1;
      } else if (x > 1) {
        x = 1;
      }
      setState(() {
        _currentIndicatorAlignment = Alignment(x, 0);
      });
    };
  }

  GestureDragEndCallback _onPanEnd(BoxConstraints constraints) {
    return (details) {
      _animateIndicatorToNearest(
        details.velocity.pixelsPerSecond,
        constraints.maxWidth,
      );
      _updateControllerIndex();
      setState(() {
        _currentTilePadding = EdgeInsets.zero;
      });
    };
  }
}

class _Labels extends StatelessWidget {
  _Labels({
    Key? key,
    this.callbackBuilder,
    required this.availableSpace,
    required this.tabs,
    required this.currentIndex,
    required this.textStyle,
    this.radius = const Radius.circular(20),
    this.splashColor,
    this.splashHighlightColor,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 8),
  }) : super(key: key);

  final VoidCallback Function(int index)? callbackBuilder;
  final double availableSpace;
  final List<CustomizableTab> tabs;
  final int currentIndex;
  final TextStyle textStyle;
  final EdgeInsets tabPadding;
  final Radius radius;
  final Color? splashColor;
  final Color? splashHighlightColor;

  @override
  Widget build(BuildContext context) {
    final step =
        availableSpace / tabs.map((e) => e.flex).reduce((a, b) => a + b);
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          tabs.length,
          (index) {
            final tab = tabs[index];
            return SizedBox(
              width: step * tab.flex,
              child: InkWell(
                splashColor: tab.splashColor ?? splashColor,
                highlightColor:
                    tab.splashHighlightColor ?? splashHighlightColor,
                borderRadius: BorderRadius.all(radius),
                onTap: callbackBuilder?.call(index),
                child: Padding(
                  padding: tabPadding,
                  child: Center(
                    child: Text(
                      tab.label,
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                      style: textStyle,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SqueezeAnimated extends StatelessWidget {
  const _SqueezeAnimated({
    Key? key,
    required this.builder,
    required this.currentTilePadding,
  }) : super(key: key);

  final Widget Function(EdgeInsets) builder;
  final EdgeInsets currentTilePadding;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<EdgeInsets>(
      curve: Curves.ease,
      tween: Tween(
        begin: EdgeInsets.zero,
        end: currentTilePadding,
      ),
      duration: kTabScrollDuration,
      builder: (context, padding, _) => builder.call(padding),
    );
  }
}
