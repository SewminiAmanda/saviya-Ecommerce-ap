import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/user_service.dart';

class UpdateAddressModal {
  final int userId;

  UpdateAddressModal({required this.userId});

  Future<void> show(BuildContext context) async {
    final _addressController = TextEditingController();
    bool _isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('change_address'.tr()),
              content: TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'shipping_address'.tr(),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              actions: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: Text('cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final address = _addressController.text.trim();
                          if (address.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("shipping_address_required".tr()),
                              ),
                            );
                            return;
                          }

                          setState(() => _isLoading = true);

                          final success =
                              await UserService.updateShippingAddress(
                                userId,
                                address,
                              );

                          setState(() => _isLoading = false);

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("address_updated_success".tr()),
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("address_update_failed".tr()),
                              ),
                            );
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('update'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
