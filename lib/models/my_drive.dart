import 'package:flutter/material.dart';
import 'package:cloud_storage_client/services/storage_service.dart';

class MyDrive {
  final String label;
  final String prefix;
  final Widget icon;
  final StorageService providerService;

  MyDrive({required this.label, required this.prefix, required this.icon, required this.providerService});
}