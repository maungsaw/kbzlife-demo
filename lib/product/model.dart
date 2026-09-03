import 'package:flutter/material.dart';

class ProductItem {
  final String id;
  final String title;
  final String category;
  final String shortDescription;
  final String fullDescription;
  final IconData icon;
  final String? imageAsset;
  final String minAge;
  final String maxAge;
  final String policyTerm;
  final String minPremium;
  final List<String> benefits;
  final List<DesignedForItem> designedFor;
  final List<String> whyBuy;

  ProductItem({
    required this.id,
    required this.title,
    required this.category,
    required this.shortDescription,
    required this.fullDescription,
    required this.icon,
    this.imageAsset,
    required this.minAge,
    required this.maxAge,
    required this.policyTerm,
    required this.minPremium,
    required this.benefits,
    required this.designedFor,
    required this.whyBuy,
  });
}

class DesignedForItem {
  final IconData icon;
  final String title;
  final String description;

  DesignedForItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
