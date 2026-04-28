import 'package:flutter/material.dart';
import '../../Widgets/kusaku_auth_widgets.dart';
import 'package:frontend_kusaku/navbar.dart';

class OtpVerificationScreen extends StatefulWidget {
	const OtpVerificationScreen({
		required this.phoneNumber,
		super.key,
	});

	final String phoneNumber;

	@override
	State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
	final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
	final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

	@override
	void dispose() {
		for (var controller in _otpControllers) {
			controller.dispose();
		}
		for (var node in _focusNodes) {
			node.dispose();
		}
		super.dispose();
	}

	String _maskPhoneNumber(String phone) {
		if (phone.length < 8) return phone;
		final visibleStart = phone.substring(0, 3);
		final visibleEnd = phone.substring(phone.length - 4);
		final hiddenLength = phone.length - 7;
		return '$visibleStart${'*' * hiddenLength}$visibleEnd';
	}

	void _handleOtpInput(int index, String value) {
		if (value.isEmpty) return;

		// Move to next field
		if (index < 5) {
			_focusNodes[index + 1].requestFocus();
		}

		// Check if all fields are filled
		if (index == 5 && _otpControllers[5].text.isNotEmpty) {
			final otp = _otpControllers.map((c) => c.text).join();
			if (otp.length == 6) {
				if (otp.length == 6) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainShell()), 
          );
        }
			}
		}
	}

	double _otpBoxWidth(double availableWidth) {
		const double spacing = 12;
		const int totalBoxes = 6;
		final double width = (availableWidth - (spacing * (totalBoxes - 1))) / totalBoxes;
		return width.clamp(34, 44).toDouble();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: KusakuColors.backgroundBlue,
			body: SafeArea(
				child: SingleChildScrollView(
					child: Column(
						children: [
							const KusakuAuthHeader(
								logoAsset: 'assets/images/Logo.png',
								titleAsset: 'assets/images/KUSAKU.png',
							),
							const SizedBox(height: 10),
							Align(
								alignment: Alignment.topCenter,
								child: FractionallySizedBox(
									widthFactor: 0.97,
									child: KusakuAuthCard(
										child: Padding(
											padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
											child: Column(
												mainAxisSize: MainAxisSize.min,
												children: [
													Align(
														alignment: Alignment.centerLeft,
														child: TextButton(
															onPressed: () => Navigator.of(context).pop(),
															style: TextButton.styleFrom(
																minimumSize: Size.zero,
																tapTargetSize: MaterialTapTargetSize.shrinkWrap,
																padding: EdgeInsets.zero,
																foregroundColor: Colors.black87,
															),
															child: const Text('< Back', style: TextStyle(fontSize: 11)),
														),
													),
													const SizedBox(height: 20),
													const Text(
														'Verification Code (OTP)',
														style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
														textAlign: TextAlign.center,
													),
													const SizedBox(height: 16),
													Text(
														'Verification code already sent to ${_maskPhoneNumber(widget.phoneNumber)}. Please enter the code within 3 minutes.',
														style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
														textAlign: TextAlign.center,
													),
													const SizedBox(height: 24),
													// OTP Input Fields
													LayoutBuilder(
														builder: (context, constraints) {
															final boxWidth = _otpBoxWidth(constraints.maxWidth);
															return Row(
																mainAxisAlignment: MainAxisAlignment.center,
																children: List.generate(
																	6,
																	(index) => Padding(
																		padding: EdgeInsets.only(right: index == 5 ? 0 : 12),
																		child: SizedBox(
																			width: boxWidth,
																			height: 50,
																			child: TextField(
																				controller: _otpControllers[index],
																				focusNode: _focusNodes[index],
																				textAlign: TextAlign.center,
																				keyboardType: TextInputType.number,
																				maxLength: 1,
																				onChanged: (value) => _handleOtpInput(index, value),
																				decoration: InputDecoration(
																					counterText: '',
																					filled: true,
																					fillColor: Colors.white,
																					contentPadding: EdgeInsets.zero,
																					border: OutlineInputBorder(
																						borderRadius: BorderRadius.circular(8),
																						borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
																					),
																					enabledBorder: OutlineInputBorder(
																						borderRadius: BorderRadius.circular(8),
																						borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
																					),
																					focusedBorder: OutlineInputBorder(
																						borderRadius: BorderRadius.circular(8),
																						borderSide: const BorderSide(
																							color: KusakuColors.primaryBlue,
																						),
																					),
																				),
																			),
																		),
																	),
																),
															);
														},
													),
													const SizedBox(height: 24),
													Center(
														child: KusakuGradientButton(
															text: 'Resend',
															onPressed: () {
																// resend OTP logic
																ScaffoldMessenger.of(context).showSnackBar(
																	const SnackBar(content: Text('OTP resent successfully')),
																);
															},
														),
													),
													const SizedBox(height: 16),
												],
											),
										),
									),
								),
							),
						],
					),
				),
			),
		);
	}
}
