import 'dart:io';
import 'package:image/image.dart';
import 'package:flutter_launcher_icons/constants.dart' as constants;

class WebIconTemplate {
  WebIconTemplate({this.size, this.name, this.location=constants.webIconLocation});

  final String name;
  final int size;
  final String location;

  Image createFrom(Image image) {
    Interpolation interpolation = Interpolation.average;

    // Select interpolation based on that done by the iOS
    //launcher icon generator.
    if (image.width >= size) {
      interpolation = Interpolation.linear;
    }

    int cropOffsetX = 0,
        cropOffsetY = 0;
    int resizeSize;

    final int cropOffset = ((image.width - image.height) / 2.0).floor();

    if (cropOffset >= 0) { // If the image is stretched horizontally.
      cropOffsetX = cropOffset;
      resizeSize = image.height;
    } else { // Else, it is stretched vertically.
      cropOffsetY = -cropOffset;
      resizeSize = image.width;
    }

    print ('offset x: $cropOffsetX\noffset y: $cropOffsetY');

    final Image croppedImage = copyCrop(image,
        cropOffsetX, cropOffsetY,
        resizeSize, resizeSize); // Width & height

    final Image resizedImg = copyResize(croppedImage, 
        width: size, height: size, // Auto width
        interpolation: interpolation);
    
    return resizedImg;
  }

  void updateFile(Image image) {
    final Image newLauncher = createFrom(image);

    File(location + name).writeAsBytesSync(encodePng(newLauncher));
  }
}

List<WebIconTemplate> webIcons = <WebIconTemplate>[
  WebIconTemplate(name: 'Icon-192.png', size: 192), // Note: iOS Safari Web Apps seems
  WebIconTemplate(name: 'Icon-512.png', size: 512), // to require images of specific sizes,
  WebIconTemplate(name: 'favicon.png', size: 16,    // so these images will be stretched,
      location: constants.webFaviconLocation),      // unless already squares.
];

void createIcons(Map<String, dynamic> config) {
  final String filePath = config['image_path_web'] ?? config['image_path'];
  final Image image = decodeImage(File(filePath).readAsBytesSync());
  final dynamic webConfig = config['web'];

  // If a String is given, the user wants to be able to revert
  //to the previous icon set. Back up the previous set.
  if (webConfig is String) {
    // As there is only one favicon, fail. Request that the user
    //manually backup requested icons.
    print (constants.errorWebCustomLocationNotSupported);
  } else {
    print ('Overwriting web favicon and launcher icons...');
    
    for (WebIconTemplate template in webIcons) {
      overwriteDefaultIcon(template, image);
    }
  }
}

void overwriteDefaultIcon(WebIconTemplate template, Image image) {
  template.updateFile(image);
}