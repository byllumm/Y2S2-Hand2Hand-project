import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:hand2hand/city_map.dart';
import 'dart:io';
import 'dart:async';

class MockSupabaseService extends Mock implements SupabaseService {}

void main(){
    late MockSupabaseService mockService;

    setUp(() {
      mockService = MockSupabaseService();
    });
    
    testWidgets('does not submit empty fields', (tester) async{

    });

    testWidgets('data field has to be valid', (tester) async{

    });

    testWidgets('submits the item, when submit button tapped', (tester) async{

    });


}