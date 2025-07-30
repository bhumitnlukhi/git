import 'dart:convert';

import 'package:flutter/foundation.dart';

class MyRadioList {
  final List<MyRadio> radios;
  MyRadioList({
    required this.radios,
  });

  MyRadioList copyWith({
    required List<MyRadio> radios,
  }) {
    return MyRadioList(
      radios: radios,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'radios': radios.map((x) => x.toMap()).toList(),
    };
  }

  factory MyRadioList.fromMap(Map<String, dynamic> map) {
    return MyRadioList(
      radios: List<MyRadio>.from(map['radios']?.map((x) => MyRadio.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory MyRadioList.fromJson(String source) =>
      MyRadioList.fromMap(json.decode(source));

  @override
  String toString() => 'MyRadioList(radios: $radios)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MyRadioList && listEquals(other.radios, radios);
  }

  @override
  int get hashCode => radios.hashCode;
}

class MyRadio {
  final int id;
  final int order;
  final String name;
  final String desk;
  final String url;
  final String category;
  final String icon;
  final String image;
  final String lang;
  final String color;
  final String tagline;
  MyRadio({
    required this.id,
    required this.order,
    required this.name,
    required this.desk,
    required this.url,
    required this.category,
    required this.icon,
    required this.image,
    required this.lang,
    required this.color,
    required this.tagline,
  });

  MyRadio copyWith({
    required int id,
    required int order,
    required String name,
    required String desk,
    required String url,
    required String category,
    required String icon,
    required String image,
    required String lang,
    required String color,
  }) {
    return MyRadio(
      id: id,
      order: order,
      name: name,
      desk: desk,
      url: url,
      category: category,
      icon: icon,
      image: image,
      lang: lang,
      color: color,
      tagline: tagline,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order': order,
      'name': name,
      'desk': desk,
      'url': url,
      'category': category,
      'icon': icon,
      'image': image,
      'lang': lang,
      'color': color,
    };
  }

  factory MyRadio.fromMap(Map<String, dynamic> map) {
    return MyRadio(
      id: map['id'],
      order: map['order'],
      name: map['name'],
      desk: map['desk'],
      url: map['url'],
      category: map['category'],
      icon: map['icon'],
      image: map['image'],
      lang: map['lang'],
      color: map['color'],
      tagline: map['tagline'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MyRadio.fromJson(String source) =>
      MyRadio.fromMap(json.decode(source));

  @override
  String toString() {
    return 'MyRadio(id: $id, order: $order, name: $name, desk: $desk, url: $url, category: $category, icon: $icon, image: $image, lang: $lang, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MyRadio &&
        other.id == id &&
        other.order == order &&
        other.name == name &&
        other.desk == desk &&
        other.url == url &&
        other.category == category &&
        other.icon == icon &&
        other.image == image &&
        other.lang == lang &&
        other.color == color;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        order.hashCode ^
        name.hashCode ^
        desk.hashCode ^
        url.hashCode ^
        category.hashCode ^
        icon.hashCode ^
        image.hashCode ^
        lang.hashCode ^
        color.hashCode;
  }
}
