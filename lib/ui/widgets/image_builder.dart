import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../common/app_colors.dart';
import '../common/app_images.dart';
import 'loading.dart';

class ImageBuilder extends StatelessWidget {
  const ImageBuilder({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
    required this.height,
    this.width,
    this.circle = false,
    this.file = false,
    this.color,
    this.loading = false,
    this.errorUploading = false,
    this.onRetry,
    this.borderCurve,
    this.borderRadius,
  });
  final String image;
  final BoxFit fit;
  final double height;
  final double? width;
  final bool circle;
  final bool file;
  final Color? color;
  final bool loading;
  final bool errorUploading;
  final VoidCallback? onRetry;
  final double? borderCurve;
  final BorderRadius? borderRadius;

  bool _isUrl(var string) {
    if (string == null) return false;
    final RegExp urlExp = RegExp(
      r'^((ftp|http|https)://|(www))[a-z0-9-]+(.[a-z0-9-]+)+(:[0-9]{1,5})?(/.*)?$',
    );
    return urlExp.hasMatch(string);
  }

  bool _isSvg(var string) {
    if (string == null || string.isEmpty) return false;
    if (string.contains('.svg')) {
      return true;
    }
    return false;
  }

  // static final Map<String, String> _headers = {
  //   'Authorization': 'Bearer ${UserService.instance.token}',
  //   'X-Scope': "mobile-app"
  // };

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: circle
                ? null
                : borderRadius ??
                      BorderRadius.all(Radius.circular(borderCurve ?? 5.h)),
            image: file && !_isUrl(image) && image != ''
                ? DecorationImage(image: FileImage(File(image)), fit: fit)
                : image != "" && _isUrl(image)
                ? DecorationImage(image: NetworkImage(image), fit: fit)
                : _isSvg(image)
                ? null
                : DecorationImage(
                    image: AssetImage((image != '') ? image : defaultPic),
                    fit: fit,
                  ),
          ),
          height: height,
          width: width ?? height,
          child: (image is Uint8List)
              ? null
              : !_isUrl(image)
              ? _isSvg(image)
                    // ignore: deprecated_member_use
                    ? SvgPicture.asset(image, color: color)
                    : null
              : CachedNetworkImage(
                  imageUrl: image,
                  height: height,
                  width: width,
                  fit: fit,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      shape: circle ? BoxShape.circle : BoxShape.rectangle,
                      borderRadius: circle
                          ? null
                          : borderRadius ??
                                BorderRadius.all(
                                  Radius.circular(borderCurve ?? 5.h),
                                ),
                      image: DecorationImage(image: imageProvider, fit: fit),
                    ),
                  ),
                  placeholder: (context, url) => Stack(
                    alignment: Alignment.center,
                    children: [
                      // Container(
                      //   decoration: BoxDecoration(
                      //     borderRadius: circle
                      //         ? null
                      //         : BorderRadius.all(
                      //             Radius.circular(borderCurve ?? 10),
                      //           ),
                      //     shape: circle ? BoxShape.circle : BoxShape.rectangle,
                      //     image: DecorationImage(
                      //       image: const AssetImage(defaultPic),
                      //       fit: fit,
                      //     ),
                      //   ),
                      // ),
                      _loadingBuilder(),
                    ],
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      borderRadius: circle
                          ? null
                          : const BorderRadius.all(Radius.circular(10)),
                      shape: circle ? BoxShape.circle : BoxShape.rectangle,
                      image: DecorationImage(
                        image: const AssetImage(defaultPic),
                        fit: fit,
                      ),
                    ),
                  ),
                ),
        ),
        if (loading) _loadingBuilder(),
        if (errorUploading) _retryBuilder(),
      ],
    );
  }

  Container _loadingBuilder() {
    return Container(
      height: height,
      width: width ?? height,
      decoration: BoxDecoration(
        color: mediumGrey.withAlpha(100),
        borderRadius: circle
            ? null
            : const BorderRadius.all(Radius.circular(10)),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: const LoadingWidget(color: primaryColor),
    );
  }

  GestureDetector _retryBuilder() {
    return GestureDetector(
      onTap: onRetry,
      child: Container(
        height: height,
        width: width ?? height,
        decoration: BoxDecoration(
          color: mediumGrey.withAlpha(100),
          borderRadius: circle
              ? null
              : const BorderRadius.all(Radius.circular(10)),
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
        ),
        child: const Icon(
          FontAwesomeIcons.rotateRight,
          color: dangerColor,
          size: 35,
        ),
      ),
    );
  }
}
