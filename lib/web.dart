import 'dart:io';
import 'package:flutter_launcher_icons/icon_template.dart';
import 'package:image/image.dart';
import 'package:flutter_launcher_icons/constants.dart' as constants;

final IconTemplateGenerator iconGenerator
     = IconTemplateGenerator(defaultLocation: constants.webIconLocation);

List<IconTemplate> webIcons = <IconTemplate>[
  iconGenerator.get(name: 'Icon-192.png', size: 192), // Note: iOS Safari Web Apps seems
  iconGenerator.get(name: 'Icon-512.png', size: 512), // to require images of specific sizes,
  iconGenerator.get(name: 'favicon.png', size: 16,    // so these images will be stretched,
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
    
    for (IconTemplate template in webIcons) {
      overwriteDefaultIcon(template, image);
    }
  }
}

void overwriteDefaultIcon(IconTemplate template, Image image) {
  template.updateFile(image);
}