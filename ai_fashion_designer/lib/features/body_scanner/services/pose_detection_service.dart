import 'dart:math';
import 'package:flutter/material.dart';

class PoseDetectionService {
  List<Offset> generateMockPose(Size canvasSize) {
    final centerX = canvasSize.width / 2;
    final topY = canvasSize.height * 0.12;

    return [
      Offset(centerX, topY),
      Offset(centerX - 20, topY + 30),
      Offset(centerX + 20, topY + 30),
      Offset(centerX - 45, topY + 35),
      Offset(centerX + 45, topY + 35),
      Offset(centerX - 55, topY + 75),
      Offset(centerX + 55, topY + 75),
      Offset(centerX, topY + 80),
      Offset(centerX - 15, topY + 150),
      Offset(centerX + 15, topY + 150),
      Offset(centerX - 18, topY + 230),
      Offset(centerX + 18, topY + 230),
      Offset(centerX - 20, canvasSize.height * 0.88),
      Offset(centerX + 20, canvasSize.height * 0.88),
    ];
  }

  double calculatePoseConfidence(List<Offset> landmarks) {
    if (landmarks.length < 14) return 0.0;
    final headToHip = (landmarks[0] - landmarks[7]).distance;
    final shoulderWidth = (landmarks[1] - landmarks[2]).distance;
    final ratio = shoulderWidth / headToHip;
    if (ratio > 0.3 && ratio < 0.6) return 0.9;
    if (ratio > 0.2 && ratio < 0.7) return 0.7;
    return 0.5;
  }

  String getPoseFeedback(List<Offset> landmarks, Size canvasSize) {
    if (landmarks.isEmpty) return 'Detecting pose...';
    final headY = landmarks[0].dy;
    final feetY = landmarks.last.dy;
    final bodyHeight = feetY - headY;
    if (bodyHeight < canvasSize.height * 0.5) return 'Move slightly back';
    if (bodyHeight > canvasSize.height * 0.85) return 'Move slightly closer';
    if (headY > canvasSize.height * 0.2) return 'Stand a bit further back';
    if (feetY < canvasSize.height * 0.8) return 'Ensure feet are visible';
    return 'Full body detected';
  }

  bool isPoseAligned(List<Offset> landmarks, Size canvasSize) {
    if (landmarks.length < 14) return false;
    final centerX = canvasSize.width / 2;
    final headX = landmarks[0].dx;
    final hipX = landmarks[7].dx;
    final offset = (headX - centerX).abs() + (hipX - centerX).abs();
    return offset < canvasSize.width * 0.15;
  }
}
