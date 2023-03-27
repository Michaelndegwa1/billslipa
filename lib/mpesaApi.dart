import 'package:http/http.dart' as http;
import 'dart:convert' show base64, json, utf8;
import 'dart:convert';
void main() async {
  String accessToken = await MpesaApi.authenticate();
  dynamic result = await MpesaApi.initiateC2B(accessToken, '2547XXXXXXXX', 100.00);
  print(result);
}


mixin MpesaApi {
  static const String consumerKey = 'HxBdKtgwfsnyuOSPbTvD2nepeVarRreR';
  static const String consumerSecret = 't20ROqkSCe558BSb';
  static const String baseUrl = 'https://sandbox.safaricom.co.ke';

  static Future<String> authenticate() async {
    String url = '$baseUrl/oauth/v1/generate?grant_type=client_credentials';
    String credentials = base64.encode(utf8.encode('$consumerKey:$consumerSecret'));

    try {
      http.Response response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Basic $credentials'
          }
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        String accessToken = data['access_token'];
        return accessToken;
      } else {
        throw Exception('Failed to authenticate with M-Pesa API');
      }
    } catch (e) {
      throw Exception('Failed to authenticate with M-Pesa API: $e');
    }
  }

  static Future initiateC2B(String accessToken, String phone, double amount) async {
    String url = '$baseUrl/mpesa/c2b/v1/simulate';
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10);
    String password = base64.encode(utf8.encode('$consumerKey:$consumerSecret:$timestamp'));

    try {
      http.Response response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json'
          },
          body: json.encode({
            'ShortCode': 'your_shortcode',
            'CommandID': 'CustomerPayBillOnline',
            'Amount': amount.toString(),
            'Msisdn': phone,
            'BillRefNumber': 'your_bill_reference_number'
          })
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to initiate C2B transaction with M-Pesa API');
      }
    } catch (e) {
      throw Exception('Failed to initiate C2B transaction with M-Pesa API: $e');
    }
  }
}
