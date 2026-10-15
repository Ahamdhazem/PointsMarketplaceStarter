# Convert Points design resources

All resources are bundled in the app target. Use XIB image/color names or `UIImage(named:)` / `UIColor(named:)`. Layouts and reusable cells remain trainee work.

| Element | Image asset |
| --- | --- |
| Points banner background | `points_background_image` |
| Wallet illustration | `current-point-icon` |
| E-Voucher wallet (`e_voucher`) | `voucher_bg_icon` |
| E-Topup wallet (`e_topup`) | `topup_icon` |
| Other wallet codes | `wallet_type_icon` |
| Wallet selected/unselected | `radio_button_on_white` / `radio_button_off_white` |
| Conversion option icon | `coins_blue500_icon` |
| Unavailable option lock | `lock_icon` |
| Empty options | `conversion_placeholder_icon` |
| Success result | `sucess_sucess600_icon` |
| Back navigation | `arrow_left` |

Use fixed wallet artwork mapped by backend `code`; ignore wallet `color`. Keep backend names, amounts and currency. The asset catalog also retains the earlier starter's images; unused artwork does not expand this assignment's scope.

Colors: `info500`, `green500`, `Error500`, `black57`, `black64`, `gradientColor1`, `gradientColor2`, `gradientColor3`, `selectedBackground`, `cardBorder`, `disabledBackground`, `warningBackground`, `warningBorder`.

Fonts registered in Info.plist: `Poppins-Regular`, `Poppins-Medium`, `Poppins-SemiBold`, `Rubik-Regular`, `Rubik-Medium`, `Rubik-Bold`. Supporting text should wrap at readable sizes rather than shrinking. StarterResourcesTests checks the supplied resources at runtime.
