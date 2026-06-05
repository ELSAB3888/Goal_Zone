import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/stadium_model.dart';
import '../../core/providers/booking_provider.dart';
import 'ticket_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  final StadiumModel stadium;
  final DateTime date;
  final String fromTime;
  final String toTime;

  const BookingSummaryScreen({
    super.key,
    required this.stadium,
    required this.date,
    required this.fromTime,
    required this.toTime,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Payment methods: 0 = Credit Card, 1 = Instapay/Wallet, 2 = Cash
  int _selectedPaymentMethod = 0;

  // Credit Card Form Controllers
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();

  @override
  void dispose() {
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  // Calculate pricing breakdown
  double get _stadiumPrice {
    // Parse price per hour, e.g., "150 EGP/hr" or just "150"
    final rawPrice = widget.stadium.price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(rawPrice) ?? 150.0;
  }

  double get _serviceFee => 15.0;

  double get _totalPrice => _stadiumPrice + _serviceFee;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(widget.date);
    final timeStr = '${widget.fromTime} → ${widget.toTime}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Booking Summary',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Stadium Details Summary Card
                _buildStadiumCard(),
                const SizedBox(height: 24),

                // 2. Booking Date & Time Details
                _buildDateTimeDetails(dateStr, timeStr),
                const SizedBox(height: 24),

                // 3. Price Breakdown Card
                _buildPriceBreakdown(),
                const SizedBox(height: 24),

                // 4. Payment Options Title
                const Text(
                  'Select Payment Method',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Payment Methods Options
                _buildPaymentMethodOptions(),
                const SizedBox(height: 24),

                // 6. Credit Card Form (Visible if selected)
                if (_selectedPaymentMethod == 0) ...[
                  _buildCreditCardForm(),
                  const SizedBox(height: 30),
                ] else if (_selectedPaymentMethod == 1) ...[
                  _buildInstapayWalletDetails(),
                  const SizedBox(height: 30),
                ],

                // 7. Confirm & Pay Button
                _buildConfirmButton(context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStadiumCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Stadium Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.stadium.imageUrl.isNotEmpty
                ? Image.network(
                    widget.stadium.imageUrl,
                    width: 90,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(
                      width: 90,
                      height: 80,
                      color: Colors.grey[900],
                      child: const Icon(
                        Icons.sports_soccer,
                        color: Colors.white54,
                      ),
                    ),
                  )
                : Container(
                    width: 90,
                    height: 80,
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.sports_soccer,
                      color: Colors.white54,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    widget.stadium.sport,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.stadium.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white54,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.stadium.location,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeDetails(String dateStr, String timeStr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildDetailSummaryRow(
            Icons.calendar_today_outlined,
            'Date',
            dateStr,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Colors.white10, height: 1),
          ),
          _buildDetailSummaryRow(Icons.access_time, 'Time Slot', timeStr),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Colors.white10, height: 1),
          ),
          _buildDetailSummaryRow(Icons.hourglass_empty, 'Duration', '1 Hour'),
        ],
      ),
    );
  }

  Widget _buildDetailSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Playground Rate',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '${_stadiumPrice.toInt()} EGP',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Service Fees',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '${_serviceFee.toInt()} EGP',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Colors.white10, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_totalPrice.toInt()} EGP',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOptions() {
    return Column(
      children: [
        _buildPaymentOptionTile(
          index: 0,
          title: 'Credit / Debit Card',
          subtitle: 'Visa, Mastercard',
          icon: Icons.credit_card_outlined,
        ),
        const SizedBox(height: 12),
        _buildPaymentOptionTile(
          index: 1,
          title: 'Instapay / Digital Wallet',
          subtitle: 'Instant transfer & mobile wallets',
          icon: Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(height: 12),
        _buildPaymentOptionTile(
          index: 2,
          title: 'Pay at Stadium',
          subtitle: 'Cash on arrival at the pitch',
          icon: Icons.payments_outlined,
        ),
      ],
    );
  }

  Widget _buildPaymentOptionTile({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.white54,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : Colors.white38,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Card Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Cardholder Name
          _buildFormField(
            controller: _cardNameController,
            hint: 'Cardholder Name',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter cardholder name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Card Number
          _buildFormField(
            controller: _cardNumberController,
            hint: 'Card Number',
            icon: Icons.credit_card,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.replaceAll(' ', '').length < 16) {
                return 'Please enter a valid 16-digit card number';
              }
              return null;
            },
            onChanged: (value) {
              // Add simple space formatting for credit cards
              String text = value.replaceAll(' ', '');
              if (text.length > 16) {
                text = text.substring(0, 16);
              }
              String formatted = '';
              for (int i = 0; i < text.length; i++) {
                if (i > 0 && i % 4 == 0) {
                  formatted += ' ';
                }
                formatted += text[i];
              }
              if (_cardNumberController.text != formatted) {
                _cardNumberController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          // Expiry and CVV
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: _cardExpiryController,
                  hint: 'Expiry (MM/YY)',
                  icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        !RegExp(
                          r'^(0[1-9]|1[0-2])\/?([0-9]{2})$',
                        ).hasMatch(value)) {
                      return 'Use MM/YY';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    String text = value.replaceAll('/', '');
                    if (text.length > 4) {
                      text = text.substring(0, 4);
                    }
                    String formatted = text;
                    if (text.length > 2) {
                      formatted =
                          '${text.substring(0, 2)}/${text.substring(2)}';
                    }
                    if (_cardExpiryController.text != formatted) {
                      _cardExpiryController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  controller: _cardCvvController,
                  hint: 'CVV',
                  icon: Icons.lock_outline,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 3) {
                      return 'Invalid';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.length > 3) {
                      _cardCvvController.value = TextEditingValue(
                        text: value.substring(0, 3),
                        selection: const TextSelection.collapsed(offset: 3),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstapayWalletDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Instapay / Mobile Wallet Transfer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Transfer the total amount to the address/number below. Enter your account details to confirm.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Instapay IPA:',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      'goalzone@instapay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vodafone Cash:',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      '01012345678',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildFormField(
            controller:
                _cardNameController, // Repurpose controller for Wallet Sender name/number
            hint: 'Your Instapay IPA or Wallet Number',
            icon: Icons.send_to_mobile,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter sender details';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: bookingProvider.isLoading
                ? null
                : () async {
                    // Only validate form if Credit Card or Wallet option is selected
                    if (_selectedPaymentMethod != 2) {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                    }

                    // Perform booking
                    final success = await bookingProvider.createBooking(
                      widget.stadium,
                      widget.date,
                      widget.fromTime,
                      widget.toTime,
                    );

                    if (context.mounted) {
                      if (success) {
                        // Obtain the created booking to get its token/ID.
                        // We fetch bookings and grab the latest upcoming booking.
                        // Get qrToken from:
                        // 1. lastCreatedQrToken (from POST /bookings response) ← preferred
                        // 2. latestBooking.qrCodeData (may be NO_QR in flat format)
                        // 3. Fallback generated string
                        final latestBooking =
                            bookingProvider.upcoming.isNotEmpty
                            ? bookingProvider.upcoming.first
                            : null;

                        final qrToken = bookingProvider.lastCreatedQrToken ??
                            (latestBooking?.qrCodeData != null &&
                                    latestBooking!.qrCodeData != 'NO_QR'
                                ? latestBooking.qrCodeData
                                : null);

                        final dateStr = DateFormat(
                          'dd MMM yyyy',
                        ).format(widget.date);
                        final timeStr =
                            '${widget.fromTime} to ${widget.toTime}';

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TicketScreen(
                              stadiumName: widget.stadium.name,
                              date: dateStr,
                              time: timeStr,
                              location: widget.stadium.location,
                              totalPrice: '${_totalPrice.toInt()} EGP',
                              duration: '1 hour',
                              sport: widget.stadium.sport,
                              qrData:
                                  qrToken ??
                                  'GZ-${widget.stadium.id}-${widget.fromTime}',
                              // Pass booking ID so TicketScreen can fetch qrToken from API if needed
                              bookingId: latestBooking?.id,
                            ),
                          ),
                          (route) => route.isFirst,
                        );

                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '❌ Booking failed. Please check playground availability or try again.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: bookingProvider.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    _selectedPaymentMethod == 2
                        ? 'Confirm Booking'
                        : 'Confirm & Pay',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
