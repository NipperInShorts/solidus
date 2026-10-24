import CoreGraphics

/// Both calculator regions are essential. Give each an explicit frame rather than
/// letting an adaptive main/detail container collapse its secondary region.
struct CalculatorWorkspaceFrames {
    let calculation: CGRect
    let keypad: CGRect

    init(size: CGSize, division: CGRect? = nil) {
        let width = max(0, size.width)
        let height = max(0, size.height)

        if let division, !division.isNull, !division.isInfinite {
            if division.width >= division.height,
               division.maxX > 0, division.minX < width,
               division.minY > 0, division.maxY < height {
                calculation = CGRect(x: 0, y: 0, width: width, height: division.minY)
                keypad = CGRect(x: 0, y: division.maxY, width: width, height: height - division.maxY)
                return
            }
            if division.height > division.width,
               division.maxY > 0, division.minY < height,
               division.minX > 0, division.maxX < width {
                calculation = CGRect(x: 0, y: 0, width: division.minX, height: height)
                keypad = CGRect(x: division.maxX, y: 0, width: width - division.maxX, height: height)
                return
            }
        }

        let isWide = width >= 560 && width > height
        if isWide {
            calculation = CGRect(x: 0, y: 0, width: width / 2, height: height)
            keypad = CGRect(x: width / 2, y: 0, width: width / 2, height: height)
        } else {
            calculation = CGRect(x: 0, y: 0, width: width, height: height / 2)
            keypad = CGRect(x: 0, y: height / 2, width: width, height: height / 2)
        }
    }
}
