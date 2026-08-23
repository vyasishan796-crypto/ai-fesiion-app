import 'package:flutter/material.dart';

enum MessageType { text, image, outfit, product, recommendation, action, error }
enum Sender { user, ai }

class ChatMessage {
  final String id;
  final Sender sender;
  final DateTime timestamp;
  final MessageType type;
  final String? text;
  final String? imageUrl;
  final OutfitCardData? outfitData;
  final ProductCardData? productData;
  final RecommendationData? recommendationData;
  final List<ActionButton>? actions;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.timestamp,
    required this.type,
    this.text,
    this.imageUrl,
    this.outfitData,
    this.productData,
    this.recommendationData,
    this.actions,
    this.isError = false,
  });

  factory ChatMessage.text(String text, Sender sender) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: sender,
      timestamp: DateTime.now(),
      type: MessageType.text,
      text: text,
    );
  }

  factory ChatMessage.outfit(OutfitCardData data, {String? text}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: Sender.ai,
      timestamp: DateTime.now(),
      type: MessageType.outfit,
      text: text,
      outfitData: data,
    );
  }

  factory ChatMessage.product(ProductCardData data, {String? text}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: Sender.ai,
      timestamp: DateTime.now(),
      type: MessageType.product,
      text: text,
      productData: data,
    );
  }

  factory ChatMessage.recommendation(RecommendationData data, {String? text}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: Sender.ai,
      timestamp: DateTime.now(),
      type: MessageType.recommendation,
      text: text,
      recommendationData: data,
    );
  }

  factory ChatMessage.error(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: Sender.ai,
      timestamp: DateTime.now(),
      type: MessageType.error,
      text: text,
      isError: true,
    );
  }
}

class OutfitCardData {
  final String name;
  final String style;
  final String occasion;
  final List<String> components;
  final String estimatedPrice;
  final String? imageUrl;

  const OutfitCardData({
    required this.name,
    required this.style,
    required this.occasion,
    required this.components,
    required this.estimatedPrice,
    this.imageUrl,
  });
}

class ProductCardData {
  final String name;
  final double price;
  final double rating;
  final List<String> sizes;
  final String? imageUrl;
  final String brand;
  final bool isWishlisted;

  const ProductCardData({
    required this.name,
    required this.price,
    required this.rating,
    required this.sizes,
    this.imageUrl,
    required this.brand,
    this.isWishlisted = false,
  });
}

class RecommendationData {
  final String title;
  final String subtitle;
  final List<String> items;
  final String? colorPalette;

  const RecommendationData({
    required this.title,
    required this.subtitle,
    required this.items,
    this.colorPalette,
  });
}

class ActionButton {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const ActionButton({
    required this.label,
    required this.icon,
    this.onTap,
  });
}

class QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class ChatConversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final List<ChatMessage> messages;

  const ChatConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
    this.messages = const [],
  });
}
