# Convert Points design

Open [the bundled layout reference](ConvertPoints.svg). It illustrates the supplied screenshot with API-consistent amounts and shortages; the original screenshot is the visual direction.

Match the Convert Points reference supplied with the assessment: a points banner, single-choice wallet cards, reusable conversion-option cards, and a fixed Convert footer. Use UIKit, Auto Layout and XIBs for layouts. Keep long backend names readable with multiline labels and adaptive heights.

- Points banner: `points_background_image` and `current-point-icon`.
- Wallet `code: e_voucher`: `voucher_bg_icon`; `e_topup`: `topup_icon`; other codes: `wallet_type_icon`. Use this artwork instead of backend `color`.
- Wallet selection: `radio_button_on_white` / `radio_button_off_white`; a selected border. Show each API balance with three fraction digits and its own currency.
- Option selection: `selectedBackground` / `cardBorder`; `coins_blue500_icon` and blue points label. Only one selected option at a time; unavailable options show a red lock and their shortage/restriction.
- Empty conversion options: `conversion_placeholder_icon`, "No Conversion Options Available", "No conversion options available for this wallet."
- Success artwork: `sucess_sucess600_icon`. Use returned amounts and wallet in the confirmation/result, not screenshot values.
- Omit Current Point navigation and additional screens from the assessment. The label may remain in the banner as visual reference.

The screenshot's rates and balances are examples. Render actual API values, including the supplied contract's 100 points = 1 JOD rate.
