import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class ListBleDevicesScreen extends StatefulWidget {
  const ListBleDevicesScreen({super.key});

  @override
  State<ListBleDevicesScreen> createState() => _ListBleDevicesScreenState();
}

class _ListBleDevicesScreenState extends State<ListBleDevicesScreen> {
  @override
  void initState() {
    permission();
    FlutterBlue.instance.startScan();
    super.initState();
  }

  Future<void> permission() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ].request();

    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Ble Scanner'),
      ),
      body: StreamBuilder<BluetoothState>(
        initialData: BluetoothState.unknown,
        stream: FlutterBlue.instance.state,
        builder: (context, snapshotStateBle) {
          if (snapshotStateBle.data == BluetoothState.on) {
            return StreamBuilder<List<ScanResult>>(
              stream: FlutterBlue.instance.scanResults,
              initialData: const [],
              builder: (context, snapshotScanResult) {
                log(snapshotScanResult.data.toString());
                final device = snapshotScanResult.data!;
                return ListView.separated(
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          device[index].device.name.isEmpty
                              ? 'N/A'
                              : device[index].device.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          'MAC: ${device[index].device.id.id}',
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          'RSSI: ${device[index].rssi}',
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  separatorBuilder: (context, index) => Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                  itemCount: device.length,
                );
              },
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
