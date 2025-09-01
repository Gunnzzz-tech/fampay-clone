
class HomeModel {
  final List<HomeSection> sections;

  HomeModel({required this.sections});

  factory HomeModel.fromJson(dynamic json) {
    // if the response is already a list
    if (json is List) {
      return HomeModel(
        sections: json.map((e) => HomeSection.fromJson(e)).toList(),
      );
    }

    // if response is wrapped in an object (just in case)
    if (json is Map<String, dynamic> && json['sections'] != null) {
      return HomeModel(
        sections: (json['sections'] as List)
            .map((e) => HomeSection.fromJson(e))
            .toList(),
      );
    }

    return HomeModel(sections: []);
  }
}
class HomeSection {
  final int id;
  final String slug;
  final List<HcGroup> hcGroups;

  HomeSection({
    required this.id,
    required this.slug,
    required this.hcGroups,
  });

  factory HomeSection.fromJson(Map<String, dynamic> json) {
    return HomeSection(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      hcGroups: (json['hc_groups'] as List<dynamic>)
          .map((e) => HcGroup.fromJson(e))
          .toList(),
    );
  }

  HomeSection copyWith({
    int? id,
    String? slug,
    List<HcGroup>? hcGroups,
  }) {
    return HomeSection(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      hcGroups: hcGroups ?? this.hcGroups,
    );
  }
}

class HcGroup {
  final int id;
  final String name;
  final String designType; // HC3, HC6, HC9, HC1...
  final int cardType;
  final List<CardItem> cards;
  final int? height;
  final bool isScrollable;
  final bool isFullWidth;

  HcGroup({
    required this.id,
    required this.name,
    required this.designType,
    required this.cardType,
    required this.cards,
    this.height,
    this.isScrollable = false,
    this.isFullWidth = false,
  });

  factory HcGroup.fromJson(Map<String, dynamic> json) {
    return HcGroup(
      id: json['id'] as int,
      name: json['name'] as String,
      designType: json['design_type'] as String,
      cardType: json['card_type'] as int,
      height: json['height'] as int?,
      isScrollable: json['is_scrollable'] as bool? ?? false,
      isFullWidth: json['is_full_width'] as bool? ?? false,
      cards: (json['cards'] as List<dynamic>?)
          ?.map((e) => CardItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  HcGroup copyWith({
    int? id,
    String? name,
    String? designType,
    int? cardType,
    List<CardItem>? cards,
    int? height,
    bool? isScrollable,
    bool? isFullWidth,
  }) {
    return HcGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      designType: designType ?? this.designType,
      cardType: cardType ?? this.cardType,
      cards: cards ?? this.cards,
      height: height ?? this.height,
      isScrollable: isScrollable ?? this.isScrollable,
      isFullWidth: isFullWidth ?? this.isFullWidth,
    );
  }
}

class CardItem {
  final int id;
  final String? name;
  final String? slug;
  final String? title;
  final String? description;

  final FormattedText? formattedTitle;
  final FormattedText? formattedDescription;

  final IconModel? icon;
  final String? bgColor;
  final String? url;
  final BgImageModel? bgImage;
  final List<CtaItem> cta;
  final int? iconSize;
  final BgGradient? bgGradient;
  final int? height;

  CardItem({
    required this.id,
    this.name,
    this.slug,
    this.title,
    this.description,
    this.formattedTitle,
    this.formattedDescription,
    this.icon,
    this.bgColor,
    this.url,
    this.bgImage,
    this.cta = const [],
    this.iconSize,
    this.bgGradient,
    this.height,
  });

  factory CardItem.fromJson(Map<String, dynamic> json) {
    return CardItem(
      id: json['id'] as int,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      formattedTitle: json['formatted_title'] != null
          ? FormattedText.fromJson(json['formatted_title'])
          : null,
      formattedDescription: json['formatted_description'] != null
          ? FormattedText.fromJson(json['formatted_description'])
          : null,
      icon: json['icon'] != null ? IconModel.fromJson(json['icon']) : null,
      bgColor: json['bg_color'] as String?,
      url: json['url'] as String?,
      bgImage: json['bg_image'] != null
          ? BgImageModel.fromJson(json['bg_image'])
          : null,
      cta: (json['cta'] as List<dynamic>?)
          ?.map((e) => CtaItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
          const [],
      iconSize: (json['icon_size'] as num?)?.toInt(),
      bgGradient: json['bg_gradient'] != null
          ? BgGradient.fromJson(json['bg_gradient'])
          : null,
      height: json['height'] as int?,
    );
  }
}

class FormattedText {
  final String? text;
  final String? align;
  final List<Entity> entities;

  FormattedText({
    this.text,
    this.align,
    this.entities = const [],
  });

  factory FormattedText.fromJson(Map<String, dynamic> json) {
    return FormattedText(
      text: json['text'] as String?,
      align: json['align'] as String?,
      entities: (json['entities'] as List<dynamic>?)
          ?.map((e) => Entity.fromJson(e as Map<String, dynamic>))
          .toList() ??
          const [],
    );
  }
}

class Entity {
  final String? text;
  final String? type;
  final String? color;
  final int? fontSize;
  final String? fontStyle;
  final String? fontFamily;

  Entity({
    this.text,
    this.type,
    this.color,
    this.fontSize,
    this.fontStyle,
    this.fontFamily,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      text: json['text'] as String?,
      type: json['type'] as String?,
      color: json['color'] as String?,
      fontSize: (json['font_size'] as num?)?.toInt(), // ✅ handles int/double/null
      fontStyle: json['font_style'] as String?,
      fontFamily: json['font_family'] as String?,
    );
  }
}



/// Each entity inside formatted_title.entities
class FormattedTextEntity {
  final String text;
  final String? type;
  final String? color;
  final int? fontSize;
  final String? fontStyle;   // "underline"
  final String? fontFamily;  // "met_semi_bold", etc.

  FormattedTextEntity({
    required this.text,
    this.type,
    this.color,
    this.fontSize,
    this.fontStyle,
    this.fontFamily,
  });

  factory FormattedTextEntity.fromJson(Map<String, dynamic> json) {
    return FormattedTextEntity(
      text: (json['text'] ?? '') as String,
      type: json['type'] as String?,
      color: json['color'] as String?,
      fontSize: (json['font_size'] as num?)?.toInt(),
      fontStyle: json['font_style'] as String?,
      fontFamily: json['font_family'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type,
      'color': color,
      'font_size': fontSize,
      'font_style': fontStyle,
      'font_family': fontFamily,
    };
  }
}
class BgGradient {
  final int? angle;
  final List<String> colors;

  BgGradient({this.angle, this.colors = const []});

  factory BgGradient.fromJson(Map<String, dynamic> json) {
    return BgGradient(
      angle: json['angle'],
      colors: (json['colors'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

/// CTA button (HC3)
class CtaItem {
  final String text;
  final String bgColor;
  final String? type;

  CtaItem({
    required this.text,
    required this.bgColor,
    this.type,
  });

  factory CtaItem.fromJson(Map<String, dynamic> json) {
    return CtaItem(
      text: (json['text'] ?? '') as String,
      bgColor: (json['bg_color'] ?? '#000000') as String,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'bg_color': bgColor,
      'type': type,
    };
  }
}

/// Icon for small card (HC6)
class IconModel {
  final String? imageType;
  final String? imageUrl;
  final double? aspectRatio;

  IconModel({this.imageType, this.imageUrl, this.aspectRatio});

  factory IconModel.fromJson(Map<String, dynamic> json) {
    return IconModel(
      imageType: json['image_type'] as String?,
      imageUrl: json['image_url'] as String?,
      aspectRatio: (json['aspect_ratio'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_type': imageType,
      'image_url': imageUrl,
      'aspect_ratio': aspectRatio,
    };
  }
}

/// Background image for big display card (HC3)
class BgImageModel {
  final String? imageType;
  final String? imageUrl;
  final double? aspectRatio;

  BgImageModel({this.imageType, this.imageUrl, this.aspectRatio});

  factory BgImageModel.fromJson(Map<String, dynamic> json) {
    return BgImageModel(
      imageType: json['image_type'] as String?,
      imageUrl: json['image_url'] as String?,
      aspectRatio: (json['aspect_ratio'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_type': imageType,
      'image_url': imageUrl,
      'aspect_ratio': aspectRatio,
    };
  }
}
