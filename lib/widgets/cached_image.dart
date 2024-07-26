import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fp2/widgets/indicators.dart';

Widget cachedNetworkImage(String imgUrl) {
  return CachedNetworkImage(
    imageUrl: imgUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) => circularProgress(context),
    errorWidget: (context, url, error) => Center(
      child: Text(
        'Unable to load Image $imgUrl',
        style: TextStyle(fontSize: 10.0),
      ),
    ),
  );
}
