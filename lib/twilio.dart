import 'package:twilio_flutter/twilio_flutter.dart';

class TwilioService {
  late TwilioFlutter twilioFlutter;
  final String accountSid = 'AC94c3327d4ab1b3f2163b0b094ef69b9c';
  final String authToken = '9efd2c5485c18d3f8e4408dc75e20f94';
  final String twilioNumber = 'YOUR_TWILIO_NUMBER';
  final String twilioWhatsAppNumber = 'whatsapp:+14155238886'; // Twilio's WhatsApp number

  TwilioService() {
    twilioFlutter = TwilioFlutter(
      accountSid: accountSid,
      authToken: authToken,
      twilioNumber: twilioNumber,
    );
  }
}