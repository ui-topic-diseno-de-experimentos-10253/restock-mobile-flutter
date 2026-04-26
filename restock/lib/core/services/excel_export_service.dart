// lib/core/services/excel_export_service.dart

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restock/features/resource/orders/domain/models/order.dart';
import 'package:restock/features/resource/orders/domain/models/order_state.dart';

class ExcelExportService {
  Future<String?> exportOrdersToExcel(
    List<Order> orders,
    Map<int, String> restaurantNames,
  ) async {
    try {
      // Solicitar permisos en Android
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            return null;
          }
        }
      }

      // Crear Excel
      final excel = Excel.createExcel();
      final sheet = excel['Orders History'];

      // Headers con estilo
      final headers = [
        'Order ID',
        'Restaurant',
        'Date',
        'Products Count',
        'Total Price (S/)',
        'State',
        'Situation',
        'Products Detail',
      ];

      // Estilo para headers
      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.blue,
        fontColorHex: ExcelColor.white,
      );

      // Agregar headers
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // Agregar datos
      for (var i = 0; i < orders.length; i++) {
        final order = orders[i];
        final rowIndex = i + 1;

        // Order ID
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = IntCellValue(order.id);

        // Restaurant Name
        final restaurantName = restaurantNames[order.adminRestaurantId] ??
            'Restaurant #${order.adminRestaurantId}';
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(restaurantName);

        // Date
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(order.requestedDate);

        // Products Count
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = IntCellValue(order.requestedProductsCount);

        // Total Price
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = DoubleCellValue(order.totalPrice);

        // State
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = TextCellValue(_labelForState(order.state));

        // Situation
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = TextCellValue(order.situation.name);

        // Products Detail
        final productsDetail = order.batchItems.map((item) {
          final productName = item.batch?.customSupply?.supply?.name ?? 'Product';
          return '$productName (${item.quantity})';
        }).join(', ');
        
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            .value = TextCellValue(productsDetail);
      }

      // Ajustar ancho de columnas
      for (var i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 20);
      }

      // Guardar archivo
      final bytes = excel.encode();
      if (bytes == null) return null;

      final directory = await _getDownloadDirectory();
      if (directory == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'orders_history_$timestamp.xlsx';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      print('Error exporting to Excel: $e');
      return null;
    }
  }

  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // En Android, usar la carpeta Downloads
      return Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      // En iOS, usar el directorio de documentos
      return await getApplicationDocumentsDirectory();
    }
    return null;
  }

  String _labelForState(OrderState state) {
    switch (state) {
      case OrderState.onHold:
        return 'On hold';
      case OrderState.preparing:
        return 'Preparing';
      case OrderState.onTheWay:
        return 'On the way';
      case OrderState.delivered:
        return 'Delivered';
    }
  }
}