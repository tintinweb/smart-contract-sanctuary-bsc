/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

library BitMath {
    /// @notice Returns the index of the most significant bit of the number,
    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    /// @dev The function satisfies the property:
    ///     x >= 2**mostSignificantBit(x) and x < 2**(mostSignificantBit(x)+1)
    /// @param x the value for which to compute the most significant bit, must be greater than 0
    /// @return r the index of the most significant bit
    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0);

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }
}

library jSVGParameters {

    struct jSVGParams {
        address minterAddress;
        string jewelTier;
        uint256 tokenID;
        string color0;
        string color1;
        string color2;
        string color3;
        string x1;
        string y1;
        string x2;
        string y2;
        string x3; 
        string y3;
    }

    // ["0x9B71B4Dc9E9DCeFAF0e291Cf2DC5135A862A463d", "Boosted", "5897", "9b71b4", "9b71b4", "2a463d", "2a463d", "85", "203", "91", "212", "202", "377"]

    struct SVGSparkle {
        string rare;
        string boosted;
    }

    struct svgDefHelper {
        string rect;
        string circle1;
        string circle2;
        string circle3;
        string defs;
    }

    struct SVGData {
        string svgDefs;
        string svgBorderText;
        string svgCurve;
        SVGSparkle sparkleData;
    }

    struct ConstructJewelPassParams {
        uint256 tokenID;
        address minterAddress;
        address holderAddress;
        string jewelTier;
    }

    struct tokenURIData {
        string name;
        string dateAndTime;
        string descriptionPartOne;
        string descriptionPartTwo;
    }

    struct dYdX {
        string dx1;
        string dx2;
        string dx3;
        string dy1;
        string dy2;
        string dy3;
    }

    struct Colors {
        string c0;
        string c1;
        string c2;
        string c3;
    }

}

library KimberliteHelperLib {
    string constant svgLogo = string(
            abi.encodePacked(
                '<svg width="75" height="75" fill-rule="evenodd" clip-rule="evenodd" image-rendering="optimizeQuality" mask="url(#prefix__fade-symbol)" shape-rendering="geometricPrecision" text-rendering="geometricPrecision" transform="translate(29 29)" viewBox="0 0 75 75"><path fill="#fdfdfc" d="M43.309 6.566a18.705 18.705 0 0 0-5.25.375c.746.776 1.62 1.275 2.625 1.5.131.315.38.44.75.375a31.745 31.745 0 0 1-6 .184l-.75-3.75a1.42 1.42 0 0 0 .375-.559 9.21 9.21 0 0 1 4.5-.184 1.42 1.42 0 0 1 .375.559c1.24.35 2.49.664 3.75.941a.84.84 0 0 0-.375.559Z" opacity=".09"/><path fill="#464c4e" d="M21.566 13.684h-.75v-1.125h2.25V7.684h-8.625v4.875h2.25v1.125h-4.5v-7.5h12.75l.375 7.5h-3.75Z" opacity=".783"/><path fill="#464c4e" d="M41.066 32.816c-.251 0-.375.124-.375.375a4.766 4.766 0 0 1-2.625 1.5 2.689 2.689 0 0 1-.375-1.875 1281.72 1281.72 0 0 1 4.125-23.441c-.026-.285-.15-.476-.375-.559-.131-.315-.38-.44-.75-.375a5.135 5.135 0 0 1-2.625-1.5 18.705 18.705 0 0 1 5.25-.375 323.87 323.87 0 0 0 21.941-.375l.184.559a797.545 797.545 0 0 1-24.375 26.059Z" opacity=".912"/><path fill="#737b7f" d="M20.809 13.684a1.091 1.091 0 0 1-.941-.375 2.115 2.115 0 0 0-.184-1.125 2.565 2.565 0 0 1-1.5.375v1.125h-1.5v-1.125h-2.25V7.684h8.625v4.875h-2.25v1.125Z"/><path fill="#6f777c" d="M44.434 9.184a142.92 142.92 0 0 1 14.625.375 1204.151 1204.151 0 0 1-17.434 18.375 798.086 798.086 0 0 1 2.816-18.75Z"/><path fill="#f7f6f5" d="M20.809 13.684h.75c.945.821.945 1.571 0 2.25a17.884 17.884 0 0 0-2.434-1.875 4.62 4.62 0 0 0-2.059 2.25c-1.085.55-1.579.176-1.5-1.125a2.854 2.854 0 0 1 .75-1.5h1.875v-1.125a2.565 2.565 0 0 0 1.5-.375 2.066 2.066 0 0 1 .184 1.125c.251.28.566.405.941.375Z" opacity=".065"/><path fill="#f25509" d="M18.559 20.434h1.5a630.675 630.675 0 0 1-.375 30.75 18.95 18.95 0 0 1-2.25-4.5c.5-7.875.5-15.75 0-23.625a12.195 12.195 0 0 1 1.125-2.625Z"/><path fill="#f55f0a" d="M21.566 20.434a366.452 366.452 0 0 0 1.875 3v25.5c-.645 1.775-1.894 2.651-3.75 2.625v-.375a630.625 630.625 0 0 0 .375-30.75h-1.5c.945-1.444 1.946-1.444 3 0Z"/><path fill="#e46c15" d="m22.684 17.816 12 14.625a7.106 7.106 0 0 1 1.125 1.875 1.091 1.091 0 0 1-.941-.375.91.91 0 0 0-.184.75c-.285.735-.72.859-1.316.375a4.925 4.925 0 0 1-.559 1.875 9.45 9.45 0 0 0-3.75-6.375 77.16 77.16 0 0 0-5.625-7.125 357.79 357.79 0 0 1-1.875-3 1.85 1.85 0 0 0 1.125-.184 42.715 42.715 0 0 1 0-2.434Z" opacity=".876"/><path fill="#fefdfd" d="M12.934 25.316c-.315.131-.44.38-.375.75v.375c-.251 0-.375.124-.375.375v.375c-.5.124-.5.251 0 .375a17.726 17.726 0 0 0-1.875 4.5c-.975.885-.975 1.82 0 2.816-.836 1.7-.585 3.266.75 4.691a24.364 24.364 0 0 0 2.25 5.25c-.5.124-.5.251 0 .375v.375a.91.91 0 0 1-.184.75 19.02 19.02 0 0 1-4.309-6.75 32.884 32.884 0 0 0-3-.184 3.386 3.386 0 0 1-1.125-2.059 8.117 8.117 0 0 0 0-4.875c.101-1.29.79-2.04 2.059-2.25a2.651 2.651 0 0 0 2.059.184 29.13 29.13 0 0 1 3.941-5.828.904.904 0 0 1 .184.75Z" opacity=".097"/><path fill="#df5017" d="M21.566 15.941a7.106 7.106 0 0 1 1.125 1.875 42.715 42.715 0 0 0 0 2.434 1.85 1.85 0 0 1-1.125.184 4.185 4.185 0 0 1-.75-2.625h-1.875a4.175 4.175 0 0 1-.75 2.25c.045.229.17.35.375.375a12.195 12.195 0 0 0-1.125 2.625 166.29 166.29 0 0 0-5.25 11.809 475.53 475.53 0 0 1 4.875 11.809c.14 1.215.581 2.34 1.316 3.375l.375 4.5a13.68 13.68 0 0 1 2.434.375c-.79 1.095-1.79 1.345-3 .75l-.375-.75a162.37 162.37 0 0 0-4.5-9.375v-.75a24.364 24.364 0 0 1-2.25-5.25 32.321 32.321 0 0 1-.559-3c.315.566.75.754 1.316.559a5.614 5.614 0 0 1-1.125-1.316 7.115 7.115 0 0 1 .375-2.25 1.78 1.78 0 0 1-.75-1.5 17.726 17.726 0 0 1 1.875-4.5v-.75c.251 0 .375-.124.375-.375v-.375c.315-.131.44-.38.375-.75a73.654 73.654 0 0 0 4.125-9 4.639 4.639 0 0 1 2.059-2.25 17.884 17.884 0 0 1 2.434 1.875Z" opacity=".955"/><path fill="#ef8955" d="M21.566 20.434c-1.054-1.444-2.055-1.444-3 0-.206-.019-.33-.146-.375-.375a4.175 4.175 0 0 0 .75-2.25h1.875a4.215 4.215 0 0 0 .75 2.625Z"/><path fill="#f86c0b" d="M23.441 23.441a77.16 77.16 0 0 1 5.625 7.125 82.012 82.012 0 0 0 .375 10.875 87.581 87.581 0 0 1-6 7.5v-25.5Z"/><path fill="#ef4a09" d="M17.434 23.059c.5 7.875.5 15.75 0 23.625h-.375a475.53 475.53 0 0 0-4.875-11.809 166.29 166.29 0 0 1 5.25-11.809Z"/><path fill="#fb7b0e" d="M29.066 30.559c2.13 1.639 3.38 3.765 3.75 6.375v.375a26.554 26.554 0 0 1-3.375 4.125 82.02 82.02 0 0 1-.375-10.875Z"/><path fill="#f8f6f5" d="M37.684 32.816a2.689 2.689 0 0 0 .375 1.875 4.766 4.766 0 0 0 2.625-1.5c.251 0 .375-.124.375-.375.06 2.13.06 4.256 0 6.375a9.559 9.559 0 0 1-2.625-1.875 1.639 1.639 0 0 0-.559-.75 2.425 2.425 0 0 1-1.684.375 3.416 3.416 0 0 1 .375-1.875 1.125 1.125 0 0 0-.75-.75 7.106 7.106 0 0 0-1.125-1.875c-.011-.375.176-.625.559-.75a4.405 4.405 0 0 1 2.434 1.125Z" opacity=".079"/><path fill="#f0a790" d="M10.316 32.059a1.77 1.77 0 0 0 .75 1.5 7.115 7.115 0 0 0-.375 2.25 5.614 5.614 0 0 0 1.125 1.316c-.559.191-1.001.005-1.316-.559.135.98.326 1.98.559 3-1.335-1.425-1.585-2.985-.75-4.691-.975-.99-.975-1.93 0-2.816Z"/><path fill="#f0a660" d="M34.691 34.691c1.5 1.125 1.5 2.25 0 3.375-.285-1.3-.844-1.42-1.684-.375-.15-.086-.21-.21-.184-.375v-.375a4.84 4.84 0 0 0 .559-1.875c.59.491 1.03.36 1.316-.375Z"/><path fill="#f6ccb0" d="M35.809 34.309a1.125 1.125 0 0 1 .75.75 3.416 3.416 0 0 0-.375 1.875 2.42 2.42 0 0 0 1.684-.375 1.6 1.6 0 0 1 .559.75 14.936 14.936 0 0 1-2.25.184 3.945 3.945 0 0 1-1.125.941c-.251 0-.375-.124-.375-.375 1.5-1.125 1.5-2.25 0-3.375a.91.91 0 0 1 .184-.75c.251.28.566.405.941.375Z" opacity=".992"/><path fill="#e8703e" d="M43.309 45.184c-.251 0-.375.124-.375.375a38.599 38.599 0 0 1-5.434-5.625 40.505 40.505 0 0 0-3.185 3.375 223.091 223.091 0 0 0 10.5 11.25l1.5 1.875v.375a128.34 128.34 0 0 0-8.25-8.25 1457.696 1457.696 0 0 1-4.5-5.25l2.625-3a1.631 1.631 0 0 1 1.875-.559 106.834 106.834 0 0 1 5.25 5.434Z"/><path fill="#dd440c" d="M34.691 39.184h1.5v1.125l-2.625 3a1473.041 1473.041 0 0 0 4.5 5.25 4.035 4.035 0 0 0 1.5 2.059 4.705 4.705 0 0 1-.375 2.059 128.359 128.359 0 0 1-8.25-8.25 38.014 38.014 0 0 1 3.75-5.25Z" opacity=".859"/><path fill="#f15309" d="m42.941 45.559 2.25 2.625a31.526 31.526 0 0 0-.375 6.375 223.091 223.091 0 0 1-10.5-11.25 40.505 40.505 0 0 1 3.185-3.375 38.599 38.599 0 0 0 5.434 5.625Z"/><path fill="#e15b10" d="M38.441 37.309a9.559 9.559 0 0 0 2.625 1.875l15.375 16.5a4.849 4.849 0 0 1-.184 1.875 3.44 3.44 0 0 0-1.684-.75l-11.25-11.625a106.834 106.834 0 0 0-5.25-5.434 1.635 1.635 0 0 0-1.875.559v-1.125h-1.5l.375-.75a3.945 3.945 0 0 0 1.125-.941 15.758 15.758 0 0 0 2.25-.184Z" opacity=".786"/><path fill="#e36717" d="M34.691 38.059c0 .251.124.375.375.375l-.375.75a38.014 38.014 0 0 0-3.75 5.25 283.87 283.87 0 0 0-8.625 10.875 1113.13 1113.13 0 0 0-2.625 2.25 8.434 8.434 0 0 1-1.5-1.875c1.211.596 2.21.345 3-.75a13.68 13.68 0 0 0-2.434-.375l-.375-4.5a7.279 7.279 0 0 1-1.316-3.375h.375a18.95 18.95 0 0 0 2.25 4.5v.375c1.856.026 3.105-.85 3.75-2.625a87.581 87.581 0 0 0 6-7.5 26.554 26.554 0 0 0 3.375-4.125c-.026.165.041.289.184.375.84-1.045 1.405-.919 1.684.375Z" opacity=".871"/><path fill="#f6650c" d="M45.184 48.184a38.291 38.291 0 0 1 4.5 4.5 27.42 27.42 0 0 1-.375 6.375l-3-2.625-1.5-1.875a31.526 31.526 0 0 1 .375-6.375Z"/><path fill="#ef9465" d="M19.691 51.566a1.125 1.125 0 0 0 .75.75c.355-.31.73-.37 1.125-.184a1.639 1.639 0 0 0-.375 1.316 1.645 1.645 0 0 0-1.316.375 10.515 10.515 0 0 0-.559-1.875c.045-.229.17-.35.375-.375Z"/><path fill="#e0590e" d="M38.059 48.566a128.34 128.34 0 0 1 8.25 8.25 116.45 116.45 0 0 1 5.25 5.809l6 .375c.315.465.191.904-.375 1.316a15.62 15.62 0 0 0-2.25.75 27.139 27.139 0 0 1-4.5-.184 510.44 510.44 0 0 1-11.25-12.191 4.72 4.72 0 0 0 .375-2.059 4.05 4.05 0 0 1-1.5-2.059Z" opacity=".806"/><path fill="#fa740c" d="M49.691 52.684a309.206 309.206 0 0 0 9 9.184 22.765 22.765 0 0 1-7.125-.184 1113.13 1113.13 0 0 1-2.25-2.625c.37-2.055.495-4.181.375-6.375Z"/><path fill="#fbf7f5" d="m17.816 54.934.375.75a8.434 8.434 0 0 0 1.5 1.875l2.625-2.25c.995.73.995 1.48 0 2.25l-1.5.375a3.75 3.75 0 0 0-1.316.75 2.254 2.254 0 0 0-2.434-1.125h-.375c-.77-1.466-.395-2.34 1.125-2.625Z" opacity=".077"/><path fill="#fefefd" d="M57.941 56.809c.461-.36.96-.3 1.5.184l4.5 4.5a10.21 10.21 0 0 1 3.565.184 24.08 24.08 0 0 1 0 6c-1.609.131-3.236.255-4.875.375a144.266 144.266 0 0 0-3-1.5 98.365 98.365 0 0 1-8.809-.941 22.549 22.549 0 0 0 4.125-.559h3a14.035 14.035 0 0 0 6.75-.941 3.945 3.945 0 0 0-1.125-.941 17.651 17.651 0 0 0-4.125-4.5v-.375c0-.251-.124-.375-.375-.375 0-.251-.124-.375-.375-.375 0-.251-.124-.375-.375-.375 0-.251-.124-.375-.375-.375Z" opacity=".079"/><path fill="#474d4f" d="M16.684 57.559h.375c.265.341.64.465 1.125.375v1.125h-3.75v4.875h8.625v-4.875h-2.25v-1.125l1.5-.375a5.957 5.957 0 0 1 2.816.375c.184 2.37.251 4.744.184 7.125H12.184v-7.5h4.5Z" opacity=".779"/><path fill="#e47314" d="m56.434 55.684 1.5 1.125c.251 0 .375.124.375.375.251 0 .375.124.375.375.251 0 .375.124.375.375.251 0 .375.124.375.375v.375a647.855 647.855 0 0 0 1.875 3c-.214.971-.84 1.345-1.875 1.125a1.85 1.85 0 0 0-.184-1.125 85.631 85.631 0 0 1-4.691-4.875 3.435 3.435 0 0 1 1.684.75 4.849 4.849 0 0 0 .184-1.875Z"/><path fill="#757c81" d="M17.066 57.559a2.25 2.25 0 0 1 2.434 1.125 3.7 3.7 0 0 1 1.316-.75v1.125h2.25v4.875h-8.625v-4.875h3.75v-1.125c-.485.09-.859-.035-1.125-.375Z"/><path fill="#ea8638" d="m43.309 45.184 11.25 11.625a85.631 85.631 0 0 0 4.691 4.875 1.826 1.826 0 0 1 .184 1.125c1.035.22 1.66-.154 1.875-1.125a647.855 647.855 0 0 1-1.875-3 17.651 17.651 0 0 1 4.125 4.5 48.131 48.131 0 0 0-5.625 1.875h-3a15.62 15.62 0 0 1 2.25-.75c.566-.41.69-.844.375-1.316l-6-.375a116.45 116.45 0 0 0-5.25-5.809v-.375l3 2.625 2.25 2.625a22.765 22.765 0 0 0 7.125.184 309.206 309.206 0 0 1-9-9.184 38.291 38.291 0 0 0-4.5-4.5l-2.25-2.625c0-.251.124-.375.375-.375Z"/><path fill="#f7d4b3" d="M63.566 63.184a3.945 3.945 0 0 1 1.125.941 14.096 14.096 0 0 1-6.75.941 48.131 48.131 0 0 1 5.625-1.875Z" opacity=".529"/></svg>'
                )
    );

    string constant svgQR = string( 
        abi.encodePacked(
            '<svg width="75" height="75" fill-rule="evenodd" clip-rule="evenodd" image-rendering="optimizeQuality" shape-rendering="geometricPrecision" text-rendering="geometricPrecision" transform="translate(390 180)" viewBox="0 0 75 75"><path fill="#fefffe" d="M-.125-.125h75v75h-75v-75Z"/><path d="M9.125 9.125h15.75v15.75H9.125V9.125Zm29.25 2.25v2.25h-2.25v4.5h-2.25v6.75h-2.25v-2.25h-2.25v-2.25h2.25v-4.5h-2.25v-2.25h4.5v-2.25h-4.5v-2.25h6.75v2.25h2.25Z"/><path d="M38.375 22.625v-2.25h-2.25v-2.25h2.25v-2.25h2.25v-4.5h-2.25v-2.25h4.5v4.5h4.5v2.25h-4.5v2.25h-2.25v2.25h2.25v4.5h-2.25v-2.25h-2.25Zm11.25-13.5h15.75v15.75h-15.75V9.125Z"/><path fill="#fefffe" d="M11.375 11.375h11.25v11.25h-11.25v-11.25Zm27 0h2.25v4.5h-2.25v2.25h-2.25v-4.5h2.25v-2.25Zm13.5 0h11.25v11.25h-11.25v-11.25Z"/><path d="M13.625 13.625h6.75v6.75h-6.75v-6.75Zm40.5 0h6.75v6.75h-6.75v-6.75Zm-24.75 2.25v4.5h-2.25v-4.5h2.25Z"/><path fill="#fefffe" d="M29.375 15.875h2.25v4.5h-2.25v-4.5Zm6.75 2.25v2.25h2.25v2.25h-2.25v6.75h6.75v4.5h2.25v4.5h-2.25v2.25h-2.25v-2.25h-4.5v2.25h2.25v2.25h-2.25v4.5h6.75v2.25h-2.25v4.5h-4.5v-2.25h-4.5v-2.25h2.25v-4.5h-4.5v-2.25h2.25v-2.25h2.25v-4.5h2.25v-2.25h4.5v-2.25h-6.75v-4.5h-2.25v-2.25h2.25v-6.75h2.25Z"/><path d="M45.125 18.125h2.25v6.75h-2.25v-6.75Zm-15.75 4.5v2.25h-2.25v-2.25h2.25Z"/><path fill="#fefffe" d="M29.375 22.625h2.25v2.25h-2.25v-2.25Z"/><path d="M38.375 22.625v4.5h4.5v2.25h-6.75v-6.75h2.25Zm-9 2.25h2.25v2.25h2.25v4.5h-2.25v-2.25h-2.25v-4.5Zm-11.25 6.75v2.25h-4.5v-2.25h-2.25v-2.25h-2.25v-2.25h4.5v2.25h2.25v2.25h2.25Zm2.25-2.25v-2.25h6.75v2.25h-6.75Zm42.75 9v-4.5h-2.25v-2.25h-2.25v4.5h-4.5v-2.25h-2.25v-4.5h2.25v-2.25h4.5v2.25h4.5v2.25h2.25v6.75h-2.25Zm-42.75-9v2.25h-2.25v-2.25h2.25Zm22.5 0h2.25v4.5h-2.25v-4.5Zm-18 4.5h-2.25v-2.25h2.25v2.25Zm6.75-2.25v2.25h-4.5v-2.25h4.5Z"/><path fill="#fefffe" d="M31.625 31.625h2.25v2.25h-2.25v-2.25Z"/><path d="M33.875 31.625h6.75v2.25h-4.5v2.25h-2.25v4.5h-2.25v-2.25h-2.25v-2.25h2.25v-2.25h2.25v-2.25Z"/><path fill="#fefffe" d="M63.125 38.375h-2.25v4.5h-2.25v-2.25h-4.5v-4.5h4.5v-4.5h2.25v2.25h2.25v4.5Z"/><path d="M13.625 33.875v2.25h-4.5v-2.25h4.5Z"/><path fill="#fefffe" d="M13.625 33.875h4.5v2.25h2.25v2.25h6.75v2.25h2.25v2.25h-4.5v-2.25h-2.25v2.25h-6.75v-2.25h-2.25v-2.25h2.25v-2.25h-2.25v-2.25Z"/><path d="M18.125 33.875h2.25v2.25h-2.25Zm6.75 0h2.25v4.5h-6.75v-2.25h4.5v-2.25Z"/><path fill="#fefffe" d="M27.125 33.875h4.5v2.25h-2.25v2.25h-2.25v-4.5Z"/><path d="M45.125 33.875h9v6.75h4.5v2.25h2.25v4.5h-2.25v-2.25h-2.25v11.25h-4.5v2.25h-11.25v2.25h-2.25v-2.25h-2.25v-2.25h-2.25v-2.25h-2.25v-2.25h4.5v2.25h4.5v-4.5h2.25v-2.25h-6.75v-4.5h2.25v-2.25h-2.25v-2.25h4.5v2.25h2.25v-2.25h2.25v-4.5Z"/><path fill="#fefffe" d="M51.875 33.875h2.25v2.25h-2.25v-2.25Z"/><path d="M13.625 36.125h2.25v2.25h-2.25v-2.25Z"/><path fill="#fefffe" d="M47.375 40.625v-4.5h2.25v2.25h2.25v4.5h-2.25v-2.25h-2.25Z"/><path d="M13.625 38.375v2.25h-2.25v6.75h-2.25v-9h4.5Zm13.5 0h2.25v2.25h-2.25v-2.25Z"/><path fill="#fefffe" d="M29.375 38.375h2.25v2.25h-2.25v-2.25Z"/><path d="M63.125 38.375v2.25h2.25v4.5h-2.25v-2.25h-2.25v-4.5h2.25Zm-49.5 2.25h2.25v2.25h6.75v2.25h-4.5v2.25h-4.5v-6.75Zm11.25 2.25h-2.25v-2.25h2.25v2.25Zm4.5-2.25h2.25v2.25h-2.25v-2.25Z"/><path fill="#fefffe" d="M47.375 40.625v2.25h-2.25v-2.25h2.25Zm-24.75 2.25h2.25v2.25h-2.25v-2.25Z"/><path d="M24.875 42.875h4.5v2.25h4.5v4.5h-2.25v2.25h-2.25v2.25h-2.25v-9h-2.25v-2.25Z"/><path fill="#fefffe" d="M38.375 42.875h4.5v2.25h-4.5v-2.25Zm18 2.25h-2.25v-2.25h2.25v2.25Z"/><path d="M22.625 45.125h2.25v2.25h-2.25v-2.25Z"/><path fill="#fefffe" d="M31.625 49.625h-2.25v-2.25h2.25v2.25Zm15.75-2.25h6.75v6.75h-6.75v-6.75Z"/><path d="M9.125 49.625h15.75v15.75H9.125v-15.75Zm27 2.25v-2.25h2.25v2.25h-2.25Z"/><path fill="#fefffe" d="M42.875 49.625h2.25v2.25h-2.25v-2.25Z"/><path d="M49.625 49.625h2.25v2.25h-2.25v-2.25Zm13.5 0h2.25v4.5h-2.25v-4.5Z"/><path fill="#fefffe" d="M11.375 51.875h11.25v11.25h-11.25v-11.25Zm20.25 0v2.25h-2.25v-2.25h2.25Z"/><path d="M13.625 54.125h6.75v6.75h-6.75v-6.75Zm15.75 0h4.5v4.5h-2.25v2.25h6.75v2.25h-2.25v2.25h-9v-4.5h2.25v-6.75Z"/><path fill="#fefffe" d="M31.625 54.125h2.25v2.25h-2.25v-2.25Z"/><path d="M60.875 56.375h-2.25v-2.25h2.25v2.25Z"/><path fill="#fefffe" d="M33.875 56.375h2.25v2.25h2.25v2.25h-6.75v-2.25h2.25v-2.25Z"/><path d="M60.875 56.375h4.5v9h-2.25v-6.75h-2.25v-2.25Zm0 2.25v2.25h-4.5v-2.25h4.5Zm-20.25 2.25h2.25v2.25h-2.25v-2.25Zm9 2.25v2.25h-4.5v-4.5h2.25v2.25h2.25Zm6.75-2.25v2.25h-6.75v-2.25h6.75Zm0 2.25h2.25v2.25h-2.25v-2.25Z"/></svg>'));

    bytes32 constant boostHash = keccak256(abi.encodePacked('Boosted'));

    string constant base0 = 'Kimberlite Labs';
    string constant base1 = 'Jewel Pass';
    string constant end0 = 'AI + DeFi';
    string constant mantleText = 'ADORNED WITH JEWELS';
    string constant SVG_WIDTH = "500";
    string constant SVG_HEIGHT = "290";

    //function generateSVGBoostedSparkle(/* string memory _jewelTier */) public pure returns (string memory svg) {
    string constant svgBoostedSparkle = string(abi.encodePacked('<g style="transform:translate(264px,254px)"><rect width="36px" height="36px" rx="8px" ry="8px" fill="none" stroke="rgba(255,255,255,0.2)"/><g><path style="transform:translate(6px,6px)" d="M12 0L12.6522 9.56587L18 1.6077L13.7819 10.2181L22.3923 6L14.4341 11.3478L24 12L14.4341 12.6522L22.3923 18L13.7819 13.7819L18 22.3923L12.6522 14.4341L12 24L11.3478 14.4341L6 22.3923L10.2181 13.7819L1.6077 18L9.56587 12.6522L0 12L9.56587 11.3478L1.6077 6L10.2181 10.2181L6 1.6077L11.3478 9.56587L12 0Z" fill="white"/><animateTransform attributeName="transform" type="rotate" from="0 18 18" to="360 18 18" dur="10s" repeatCount="indefinite"/></g></g>'));
    //}
    
    string constant svgRareSparkle = string(
        abi.encodePacked(
            '<g style="transform:translate(226px,392px)"><rect width="36px" height="36px" rx="8px" ry="8px" fill="none" stroke="rgba(255,255,255,0.2)"/>',
            '<g><path style="transform:translate(6px,6px)" d="M12 0L12.6522 9.56587L18 1.6077L13.7819 10.2181L22.3923 6L14.4341',
            '11.3478L24 12L14.4341 12.6522L22.3923 18L13.7819 13.7819L18 22.3923L12.6522 14.4341L12 24L11.3478 14.4341L6 22.39',
            '23L10.2181 13.7819L1.6077 18L9.56587 12.6522L0 12L9.56587 11.3478L1.6077 6L10.2181 10.2181L6 1.6077L11.3478 9.56587L12 0Z" fill="white"/>',
            '<animateTransform attributeName="transform" type="rotate" from="0 18 18" to="360 18 18" dur="10s" repeatCount="indefinite"/></g></g>'
        )
    );

   function isRare(uint256 tokenId, address minterAddress) internal pure returns (bool) {
        bytes32 h = keccak256(abi.encodePacked(tokenId, minterAddress));
        return uint256(h) < type(uint256).max / (1 + BitMath.mostSignificantBit(tokenId) * 2);
    }

    function uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = uint8(48 + (_i % 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        str = string(bstr);
    }

    function getSVGMantleData(
        string memory tokenId,
        string memory _jewelTier
    ) public pure returns (string memory svg) {

        svg = string(abi.encodePacked(
            generateIDGroup(tokenId),
            generateMantleGroup(),
            generateAccessTypeGroup(_jewelTier)
        ));
    }

    function generateIDGroup(string memory tokenId) internal pure returns (string memory) {
        return string(abi.encodePacked(
            ' <g style="transform:translate(29px, 150px)">',
            '<rect width="',
            uint2str(uint256(7 * (bytes(tokenId).length + 8))),
            'px" height="26px" rx="8px" ry="8px" fill="rgba(0,0,0,0.6)" />',
            '<text x="12px" y="17px" font-family="\'Courier New\', monospace" font-size="12px" fill="white"><tspan fill="rgba(255,255,255,0.6)">ID: </tspan>',
            tokenId,
            '</text></g>'
        ));
    }

    function generateMantleGroup() internal pure returns (string memory) {
        return string(abi.encodePacked(
            ' <g style="transform:translate(350px, 29px)">',
            '<rect width="',
            uint2str(uint256(7 * (bytes(mantleText).length + 14))),
            'px" height="26px" rx="8px" ry="8px" fill="rgba(0,0,0,0.6)" />',
            '<text x="12px" y="17px" font-family="\'Courier New\', monospace" font-size="12px" fill="white"><tspan fill="rgba(255,255,255,0.6)"># </tspan>',
            mantleText,
            '</text></g>'
        ));
    }

    function generateAccessTypeGroup(string memory _jewelTier) internal pure returns (string memory) {
        return string(abi.encodePacked(
            ' <g style="transform:translate(29px, 180px)">',
            '<rect width="',
            uint2str(uint256(7 * (bytes(_jewelTier).length + 14))),
            'px" height="26px" rx="8px" ry="8px" fill="rgba(0,0,0,0.6)" />',
            '<text x="12px" y="17px" font-family="\'Courier New\', monospace" font-size="12px" fill="white"><tspan fill="rgba(255,255,255,0.6)">Access Type: </tspan>',
            _jewelTier,
            '</text></g>'
        ));
    }

    function generateSVGBorderText(
            string memory end1
        ) public pure returns (string memory svg) {
            string memory base0Part = string(abi.encodePacked(base0, unicode' • ', end0));
            string memory base1Part = string(abi.encodePacked(base1, unicode' • ', end1));
            
            svg = string(
                abi.encodePacked(
                    '<text text-rendering="optimizeSpeed">',
                    '<textPath startOffset="-100%" fill="white" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
                    base0Part,
                    ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                    '</textPath> <textPath startOffset="0%" fill="white" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
                    base0Part,
                    ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /> </textPath>',
                    '<textPath startOffset="50%" fill="white" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
                    base1Part,
                    ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /></textPath>',
                    '<textPath startOffset="-50%" fill="white" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
                    base1Part,
                    ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /></textPath></text>'
                )
            );
        }

    function generateSVGDefs1(jSVGParameters.jSVGParams memory params) public pure returns (string memory) {
    return string(abi.encodePacked(
        '<svg width="', SVG_WIDTH, '" height="', SVG_HEIGHT, '" viewBox="0 0 ', SVG_WIDTH, ' ', SVG_HEIGHT, '" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
        generateDefs(params),
        '<g clip-path="url(#corners)">',
        generateRect(params.color0),
        generateCircle(params.x1, params.y1, params.color1)
    ));
}

function generateSVGDefs2(jSVGParameters.jSVGParams memory params) public pure returns (string memory) {
    return string(abi.encodePacked(
        generateCircle(params.x2, params.y2, params.color2),
        generateCircle(params.x3, params.y3, params.color3),
        '</g>',
        '</svg>'
    ));
}

function generateSVGDefs(jSVGParameters.jSVGParams memory params) public pure returns (string memory svg) {
    svg = string(abi.encodePacked(
        generateSVGDefs1(params),
        generateSVGDefs2(params)
    ));
}

    
    function generateRect(string memory color) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<rect width="', SVG_WIDTH, '" height="', SVG_HEIGHT, '" fill="#', color, '"/>'
        ));
    }
    
    function generateCircle(string memory x, string memory y, string memory color) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<circle cx="', x, '" cy="', y, '" r="120px" fill="#', color, '"/>'
        ));
    }

    function generateFilterSection(string memory rect, string memory circle1, string memory circle2, string memory circle3) private pure returns (string memory) {
        return string(abi.encodePacked(
            '<filter id="f1">',
            '<feImage result="p0" xlink:href="data:image/svg+xml;base64,', rect,
            '<feImage result="p1" xlink:href="data:image/svg+xml;base64,', circle1,
            '<feImage result="p2" xlink:href="data:image/svg+xml;base64,', circle2,
            '<feImage result="p3" xlink:href="data:image/svg+xml;base64,', circle3,
            '<feBlend mode="overlay" in="p0" in2="p1"/><feBlend mode="exclusion" in2="p2"/><feBlend mode="overlay" in2="p3" result="blendOut"/><feGaussianBlur in="blendOut" stdDeviation="42"/></filter>'
        ));
    }
    
    function generateClipPathSection() public pure returns (string memory) {
        return string(abi.encodePacked('<clipPath id="corners"><rect width="', SVG_WIDTH, '" height="', SVG_HEIGHT, '" rx="42" ry="42"/></clipPath>'));
    }

    function generateMaskAndGradientSection() public pure returns (string memory) {
        return string(abi.encodePacked(
            '<filter id="top-region-blur"><feGaussianBlur in="SourceGraphic" stdDeviation="24"/></filter>',
            '<linearGradient id="grad-up" x1="1" x2="0" y1="1" y2="0"><stop offset="0.0" stop-color="white" stop-opacity="1"/><stop offset=".9" stop-color="white" stop-opacity="0"/></linearGradient>',
            '<linearGradient id="grad-down" x1="0" x2="1" y1="0" y2="1"><stop offset="0.0" stop-color="white" stop-opacity="1"/><stop offset="0.9" stop-color="white" stop-opacity="0"/></linearGradient>',
            '<mask id="fade-up" maskContentUnits="objectBoundingBox"><rect width="1" height="1" fill="url(#grad-up)"/></mask>',
            '<mask id="fade-down" maskContentUnits="objectBoundingBox"><rect width="1" height="1" fill="url(#grad-down)"/></mask>',
            '<mask id="none" maskContentUnits="objectBoundingBox"><rect width="1" height="1" fill="white"/></mask>',
            '<linearGradient id="grad-symbol"><stop offset="0.7" stop-color="white" stop-opacity="1"/><stop offset=".95" stop-color="white" stop-opacity="0"/></linearGradient>',
            '<mask id="fade-symbol" maskContentUnits="userSpaceOnUse"><rect width="', SVG_WIDTH, '" height="140px" fill="url(#grad-symbol)"/></mask>'
        ));
    }

    function generateDefs(jSVGParameters.jSVGParams memory params) public pure returns (string memory) {
    string memory rect = generateRect(params.color0);
    string memory circle1 = generateCircle(params.x1, params.y1, params.color1);
    string memory circle2 = generateCircle(params.x2, params.y2, params.color2);
    string memory circle3 = generateCircle(params.x3, params.y3, params.color3);

    return string(abi.encodePacked(
        '<defs>',
        generateFilterSection(rect, circle1, circle2, circle3),
        generateClipPathSection(),
        generateMaskAndGradientSection(),
        '</defs>'
    ));
}

}