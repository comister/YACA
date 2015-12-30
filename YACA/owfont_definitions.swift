//
//  owfont_definitions.swift
//  YACA
//
//  Created by Andreas Pfister on 27/12/15.
//  Copyright © 2015 AP. All rights reserved.
//

import Foundation

public enum OWFont: String {
    // Thunderstorm
    case owf200 = "\u{EB28}"
    case owf201 = "\u{EB29}"
    case owf202 = "\u{EB2A}"
    case owf210 = "\u{EB32}"
    case owf211 = "\u{EB33}"
    case owf212 = "\u{EB34}"
    case owf221 = "\u{EB3D}"
    case owf230 = "\u{EB46}"
    case owf231 = "\u{EB47}"
    case owf232 = "\u{EB48}"
    // Drizzle
    case owf300 = "\u{EB8C}"
    case owf301 = "\u{EB8D}"
    case owf302 = "\u{EB8E}"
    case owf310 = "\u{EB96}"
    case owf311 = "\u{EB97}"
    case owf312 = "\u{EB98}"
    case owf313 = "\u{EB99}"
    case owf314 = "\u{EB9A}"
    case owf321 = "\u{EBA1}"
    // Rain
    case owf500 = "\u{EC54}"
    case owf501 = "\u{EC55}"
    case owf502 = "\u{EC56}"
    case owf503 = "\u{EC57}"
    case owf504 = "\u{EC58}"
    case owf511 = "\u{EC5F}"
    case owf520 = "\u{EC68}"
    case owf521 = "\u{EC69}"
    case owf522 = "\u{EC6A}"
    case owf531 = "\u{EC73}"
    // Snow
    case owf600 = "\u{ECB8}"
    case owf601 = "\u{ECB9}"
    case owf602 = "\u{ECBA}"
    case owf611 = "\u{ECC3}"
    case owf612 = "\u{ECC4}"
    case owf615 = "\u{ECC7}"
    case owf616 = "\u{ECC8}"
    case owf620 = "\u{ECCC}"
    case owf621 = "\u{ECCD}"
    case owf622 = "\u{ECCE}"
    // Atmosphere
    case owf701 = "\u{ED1D}"
    case owf711 = "\u{ED27}"
    case owf721 = "\u{ED31}"
    case owf731 = "\u{ED3B}"
    case owf741 = "\u{ED45}"
    case owf751 = "\u{ED4F}"
    case owf761 = "\u{ED59}"
    case owf762 = "\u{ED5A}"
    case owf771 = "\u{ED63}"
    case owf781 = "\u{ED6D}"
    // Clouds
    case owf800 = "\u{ED80}"
    case owf801 = "\u{ED81}"
    case owf802 = "\u{ED82}"
    case owf803 = "\u{ED83}"
    case owf804 = "\u{ED84}"
    // Extreme
    case owf900 = "\u{EDE4}"
    case owf901 = "\u{EDE5}"
    case owf902 = "\u{EDE6}"
    case owf903 = "\u{EDE7}"
    case owf904 = "\u{EDE8}"
    case owf905 = "\u{EDE9}"
    case owf906 = "\u{EDEA}"
    // Additional
    case owf950 = "\u{EE16}"
    case owf952 = "\u{EE18}"
    case owf953 = "\u{EE19}"
    case owf954 = "\u{EE1A}"
    case owf955 = "\u{EE1B}"
    case owf956 = "\u{EE1C}"
    case owf957 = "\u{EE1D}"
    case owf958 = "\u{EE1E}"
    case owf959 = "\u{EE1F}"
    case owf960 = "\u{EE20}"
    case owf961 = "\u{EE21}"
    case owf962 = "\u{EE22}"
}

public let OWFontIcons = [
    // Thunderstorm
    "200" : "\u{EB28}",
    "201" : "\u{EB29}",
    "202" : "\u{EB2A}",
    "210" : "\u{EB32}",
    "211" : "\u{EB33}",
    "212" : "\u{EB34}",
    "221" : "\u{EB3D}",
    "230" : "\u{EB46}",
    "231" : "\u{EB47}",
    "232" : "\u{EB48}",
    // Drizzle
    "300" : "\u{EB8C}",
    "301" : "\u{EB8D}",
    "302" : "\u{EB8E}",
    "310" : "\u{EB96}",
    "311" : "\u{EB97}",
    "312" : "\u{EB98}",
    "313" : "\u{EB99}",
    "314" : "\u{EB9A}",
    "321" : "\u{EBA1}",
    // Rain
    "500" : "\u{EC54}",
    "501" : "\u{EC55}",
    "502" : "\u{EC56}",
    "503" : "\u{EC57}",
    "504" : "\u{EC58}",
    "511" : "\u{EC5F}",
    "520" : "\u{EC68}",
    "521" : "\u{EC69}",
    "522" : "\u{EC6A}",
    "531" : "\u{EC73}",
    // Snow
    "600" : "\u{ECB8}",
    "601" : "\u{ECB9}",
    "602" : "\u{ECBA}",
    "611" : "\u{ECC3}",
    "612" : "\u{ECC4}",
    "615" : "\u{ECC7}",
    "616" : "\u{ECC8}",
    "620" : "\u{ECCC}",
    "621" : "\u{ECCD}",
    "622" : "\u{ECCE}",
    // Atmosphere
    "701" : "\u{ED1D}",
    "711" : "\u{ED27}",
    "721" : "\u{ED31}",
    "731" : "\u{ED3B}",
    "741" : "\u{ED45}",
    "751" : "\u{ED4F}",
    "761" : "\u{ED59}",
    "762" : "\u{ED5A}",
    "771" : "\u{ED63}",
    "781" : "\u{ED6D}",
    // Clouds
    "800" : "\u{ED80}",
    "801" : "\u{ED81}",
    "802" : "\u{ED82}",
    "803" : "\u{ED83}",
    "804" : "\u{ED84}",
    // Extreme
    "900" : "\u{EDE4}",
    "901" : "\u{EDE5}",
    "902" : "\u{EDE6}",
    "903" : "\u{EDE7}",
    "904" : "\u{EDE8}",
    "905" : "\u{EDE9}",
    "906" : "\u{EDEA}",
    // Additional
    "950" : "\u{EE16}",
    "952" : "\u{EE18}",
    "953" : "\u{EE19}",
    "954" : "\u{EE1A}",
    "955" : "\u{EE1B}",
    "956" : "\u{EE1C}",
    "957" : "\u{EE1D}",
    "958" : "\u{EE1E}",
    "959" : "\u{EE1F}",
    "960" : "\u{EE20}",
    "961" : "\u{EE21}",
    "962" : "\u{EE22}"
]