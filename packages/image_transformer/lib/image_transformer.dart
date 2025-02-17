library image_transformer;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data' as typed_data;

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

///
/// ImageLoader.asset('asset-name')
///   .asImageTransformer()
///   .resize(with: 150, height: 200)
///   .toFile('file-path')

enum ImageLoadType {
  asset,
  file;
}

class ImageLoader {
  final String path;
  final ImageLoadType type;
  final int? frame;

  ImageLoader._(this.path, this.type, this.frame);

  ImageLoader.asset({required this.path, this.frame}) : type = ImageLoadType.asset;

  ImageLoader.file({required this.path, this.frame}) : type = ImageLoadType.file;

  Future<img.Image> decodeBytes() async {
    img.Image? image;

    switch (type) {
      /// File
      case ImageLoadType.file:
        final original = File(path);
        if (await original.isHeifType()) {
          final data = await FlutterImageCompress.compressWithFile(path);
          if (data != null) {
            image = img.decodeImage(data, frame: frame);
          }
        } else {
          image = await img.decodeImageFile(path, frame: frame);
        }

      /// Asset
      case ImageLoadType.asset:
        final typed_data.Uint8List? data = await FlutterImageCompress.compressAssetImage(path);
        if (data != null) {
          image = img.decodeImage(data, frame: frame);
        }
    }

    if (image == null) {
      throw ImageLoadFailureException(message: 'failed to load image($type): $path');
    }
    return image;
  }

  ImageTransformer asImageTransformer() {
    return ImageTransformer(loadImage: () async {
      return await decodeBytes();
    });
  }
}

typedef ImageLoadCallback = FutureOr<img.Image> Function();
typedef ImageWorkCallback = img.Image Function(img.Image);

/// 이미지를 읽어와서 크기를 줄이거나 조작하고 이에 대한 복사본을 가져올 때 사용한다.
///
/// final result = ImageTransformer(loadCallback)
///   .resize(width)
///   .gaussianBlur(radius: 5)
///   .asFile(FileType.png)
///
class ImageTransformer {
  final ImageLoadCallback loadImage;

  const ImageTransformer({required this.loadImage});

  static Future<String> getTempFilePathWithExtension({required String extension}) async {
    final Directory tempFolder = await getTemporaryDirectory();
    return '${tempFolder.path}/tmp_${DateTime.now().millisecondsSinceEpoch}.$extension';
  }

  /// Get temporary file path with file name including extension
  static Future<String> getTempFilePathWithFileName({required String fileName}) async {
    final Directory tempFolder = await getTemporaryDirectory();
    return '${tempFolder.path}/$fileName';
  }

  Future<ImageTransformer> _doImageWork({
    required ImageWorkCallback callback,
  }) async {
    final source = await loadImage();
    final target = callback(source);
    return ImageTransformer(loadImage: () => target);
  }

  Future<ImageTransformer> resize({
    int? width,
    int? height,
    bool? maintainAspect,
    img.Color? backgroundColor,
    img.Interpolation interpolation = img.Interpolation.nearest,
  }) async {
    return _doImageWork(
      callback: (source) => img.copyResize(
        source,
        width: width,
        height: height,
        maintainAspect: maintainAspect,
        backgroundColor: backgroundColor,
        interpolation: interpolation,
      ),
    );
  }

  Future<ImageTransformer> crop({
    required int x,
    required int y,
    required int width,
    required int height,
    num radius = 0,
    bool antialias = true,
  }) async {
    return _doImageWork(
      callback: (source) => img.copyCrop(
        source,
        x: x,
        y: y,
        width: width,
        height: height,
        radius: radius,
        antialias: antialias,
      ),
    );
  }

  /// filter --
  Future<ImageTransformer> gaussianBlur({
    required int radius,
    img.Image? mask,
    img.Channel maskChannel = img.Channel.luminance,
  }) async {
    return _doImageWork(
      callback: (source) => img.gaussianBlur(
        source,
        radius: radius,
        mask: mask,
        maskChannel: maskChannel,
      ),
    );
  }

  Future<ImageTransformer> pixelate({
    required int size,
    img.PixelateMode mode = img.PixelateMode.upperLeft,
    num amount = 1,
    img.Image? mask,
    img.Channel maskChannel = img.Channel.luminance,
  }) async {
    return _doImageWork(
      callback: (source) => img.pixelate(
        source,
        size: size,
        mode: mode,
        amount: amount,
        mask: mask,
        maskChannel: maskChannel,
      ),
    );
  }

  Future<ImageTransformer> hexagonPixelate({
    int? centerX,
    int? centerY,
    int size = 5,
    num amount = 1,
    img.Image? mask,
    img.Channel maskChannel = img.Channel.luminance,
  }) async {
    return _doImageWork(
      callback: (source) => img.hexagonPixelate(
        source,
        centerX: centerX,
        centerY: centerY,
        size: size,
        amount: amount,
        mask: mask,
        maskChannel: maskChannel,
      ),
    );
  }
}

extension FileX on File {
  Future<String?> getMimeType() async {
    try {
      final file = File(path);

      // Read a small portion of the file
      final bytes = (await file.readAsBytes()).take(12).toList();
      // or
      // final bytes = await file.openRead(0, defaultMagicNumbersMaxLength).single;

      return lookupMimeType(path, headerBytes: bytes);
    } catch (e) {
      return lookupMimeType(path);
    }
  }

  Future<bool> isHeifType() async {
    final mimeType = await getMimeType();
    return (mimeType == 'image/heif' || mimeType == 'image/heif-sequence' || mimeType == 'image/heic');
  }
}

extension ImageEx on Future<img.Image> {
  Future<bool> toFile({required String path}) async {
    final image = await this;
    return img.encodeImageFile(path, image);
  }
}

extension ImageTransformerEx on Future<ImageTransformer> {
  Future<bool> toFile({required String path}) async {
    final transformer = await this;
    final image = await transformer.loadImage();
    return img.encodeImageFile(path, image);
  }
}

class ImageLoadFailureException implements IOException {
  final String message;

  const ImageLoadFailureException({required this.message});

  @override
  String toString() {
    return message;
  }
}
