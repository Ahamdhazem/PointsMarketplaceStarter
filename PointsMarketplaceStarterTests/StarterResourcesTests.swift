import XCTest
import UIKit

/// Supplied setup verification, not conversion implementation tests.
final class StarterResourcesTests: XCTestCase {
    @MainActor
    func testDesignImagesColorsAndFontsAreAvailable() {
        for name in ["current-point-icon", "voucher_icon", "phone_icon", "mobile_phone_icon",
                     "data_bundle_icon", "check_box_on", "check_box_off", "lock_icon",
                     "info_error500_icon", "plus_icon", "minus_icon", "placeholder_icon",
                     "arrow_left", "history_icon", "game_bg_image",
                     "voucher_bg_icon", "topup_icon", "wallet_type_icon",
                     "radio_button_on_white", "radio_button_off_white",
                     "conversion_placeholder_icon", "sucess_sucess600_icon", "coins_blue500_icon"] {
            XCTAssertNotNil(UIImage(named: name), "Missing design image: \(name)")
        }
        for name in ["info500", "green500", "Error500", "black57", "black64",
                     "gradientColor1", "gradientColor2", "gradientColor3",
                     "selectedBackground", "cardBorder", "warningBackground", "warningBorder",
                     "disabledBackground", "balanceGradientStart", "balanceGradientEnd"] {
            XCTAssertNotNil(UIColor(named: name), "Missing design color: \(name)")
        }
        for name in ["Rubik-Regular", "Rubik-Medium", "Rubik-Bold",
                     "Poppins-Regular", "Poppins-Medium", "Poppins-SemiBold"] {
            XCTAssertNotNil(UIFont(name: name, size: 14), "Unregistered font: \(name)")
        }
    }
}
