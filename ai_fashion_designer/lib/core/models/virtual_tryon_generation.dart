import 'package:flutter/foundation.dart';
import 'product.dart';

/// Represents a virtual try-on generation result.
class VirtualTryOnGeneration {
  final int id;
  final String? outfitId;
  final List<String> productIds;
  final List<Product> products;
  final String userPrompt;
  final String userImageUrl;
  final String resultImageUrl;
  final String enhancedPrompt;
  final String modelUsed;
  final String qwenModelUsed;
  final int generationTimeMs;
  final String status;
  final String? errorMessage;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  VirtualTryOnGeneration({
    required this.id,
    this.outfitId,
    required this.productIds,
    required this.products,
    required this.userPrompt,
    required this.userImageUrl,
    required this.resultImageUrl,
    required this.enhancedPrompt,
    required this.modelUsed,
    required this.qwenModelUsed,
    required this.generationTimeMs,
    required this.status,
    this.errorMessage,
    required this.metadata,
    required this.createdAt,
  });

  factory VirtualTryOnGeneration.fromJson(
    Map<String, dynamic> json, {
    required List<Product> products,
  }) {
    return VirtualTryOnGeneration(
      id: json['id'] as int,
      outfitId: json['outfit_id'] as String?,
      productIds: List<String>.from(json['product_ids'] ?? []),
      products: products,
      userPrompt: json['user_prompt'] as String? ?? '',
      userImageUrl: json['user_image_url'] as String? ?? '',
      resultImageUrl: json['result_image_url'] as String? ?? '',
      enhancedPrompt: json['enhanced_prompt'] as String? ?? '',
      modelUsed: json['model_used'] as String? ?? '',
      qwenModelUsed: json['qwen_model_used'] as String? ?? '',
      generationTimeMs: json['generation_time_ms'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      errorMessage: json['error_message'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'outfit_id': outfitId,
      'product_ids': productIds,
      'user_prompt': userPrompt,
      'user_image_url': userImageUrl,
      'result_image_url': resultImageUrl,
      'enhanced_prompt': enhancedPrompt,
      'model_used': modelUsed,
      'qwen_model_used': qwenModelUsed,
      'generation_time_ms': generationTimeMs,
      'status': status,
      'error_message': errorMessage,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'enhancing' || status == 'generating';
  bool get isPending => status == 'pending';

  String get statusDisplay {
    switch (status) {
      case 'completed':
        return 'Ready';
      case 'enhancing':
        return 'Analyzing...';
      case 'generating':
        return 'Generating...';
      case 'pending':
        return 'Queued';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  String get formattedTime {
    final seconds = (generationTimeMs / 1000).round();
    if (seconds < 60) return '${seconds}s';
    return '${(seconds / 60).floor()}m ${seconds % 60}s';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VirtualTryOnGeneration && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'VirtualTryOnGeneration(id: $id, status: $status, products: ${products.length})';
}