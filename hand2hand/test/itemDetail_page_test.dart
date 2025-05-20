import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:hand2hand/city_map.dart';
import 'dart:io';
import 'dart:async';
import 'package:hand2hand/add_item_dialog.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main(){
  late MockSupabaseService mockService;

  setUp(() {
    mockService = MockSupabaseService();
  });

  testWidgets('does not submit empty fields', (tester) async{

  });

  testWidgets('handles null donor id gracefully', (tester) async{

  });

  testWidgets('shows available, when available', (tester) async{

  });


}