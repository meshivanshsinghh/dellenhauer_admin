import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerImage {
  static network(
    String url, {
    Widget? orWidget,
    BoxShape shape = BoxShape.rectangle,
  }) {
    if (url.isEmpty) return _ShimmerEmpty();

    return ExtendedImage.network(
      url,
      cache: true,
      retries: 1,
      clearMemoryCacheIfFailed: true,
      timeRetry: const Duration(milliseconds: 500),
      printError: false,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return _Shimmer();
          case LoadState.completed:
            return ExtendedRawImage(
              image: state.extendedImageInfo?.image,
              fit: BoxFit.cover,
            );
          case LoadState.failed:
            return orWidget ?? _ShimmerEmpty();
        }
      },
    );
  }
}

class _Shimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      direction: ShimmerDirection.ltr,
      baseColor: Colors.grey.withOpacity(0.7),
      highlightColor: Colors.grey.withOpacity(0.4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.7),
        ),
      ),
    );
  }
}

class _ShimmerEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/placeholder.jpeg',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
