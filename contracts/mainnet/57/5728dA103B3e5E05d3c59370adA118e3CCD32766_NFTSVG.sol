// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;
pragma abicoder v2;

import '@openzeppelin/contracts/utils/Strings.sol';
import '@uniswap/v3-core/contracts/libraries/BitMath.sol';
import 'base64-sol/base64.sol';

/// @title NFTSVG
/// @notice Provides a function for generating an SVG associated with a Uniswap NFT
library NFTSVG {
    using Strings for uint256;

    string constant curve1 = 'M90.5264 135.526L181.474 226.474';
    string constant curve2 = 'M90.2231 135.526C110.434 165.842 150.855 206.263 181.171 226.474';
    string constant curve3 = 'M90.5518 135.526C110.762 170.895 146.131 206.263 181.499 226.474';
    string constant curve4 = 'M90.2485 135.526C105.406 175.947 140.775 211.316 181.196 226.474';
    string constant curve5 = 'M90.5767 135.526C100.682 181 136.05 216.368 181.524 226.474';
    string constant curve6 = 'M90.2739 135.526C95.3266 186.053 130.695 221.421 181.221 226.474';
    string constant curve7 = 'M90.6084 135.526C90.6084 191.105 126.293 226.474 181.556 226.474';
    string constant curve8 = 'M90.5264 135.526C90.5264 196.158 120.842 226.474 181.474 226.474';

    struct SVGBodyParams {
        string quoteToken;
        string baseToken;
        address poolAddress;
        string quoteTokenSymbol;
        string baseTokenSymbol;
        string feeTier;
        int24 tickLower;
        int24 tickUpper;
        int24 tickSpacing;
        int8 overRange;
        uint256 tokenId;
    }

    struct SVGDefsParams {
        string color1;
        string color2;
        string color3;
        string x1;
        string y1;
        string x2;
        string y2;
        string x3;
        string y3;
        int8 overRange;
    }

    function generateSVG(string memory defs, string memory body) internal pure returns (string memory svg) {
        /*
        address: "0xe8ab59d3bcde16a29912de83a90eb39628cfc163",
        msg: "Forged in SVG for Uniswap in 2021 by 0xe8ab59d3bcde16a29912de83a90eb39628cfc163",
        sig: "0x2df0e99d9cbfec33a705d83f75666d98b22dea7c1af412c584f7d626d83f02875993df740dc87563b9c73378f8462426da572d7989de88079a382ad96c57b68d1b",
        version: "2"
        */
        return string(abi.encodePacked(defs, body, '</svg>'));
    }

    function generateSVGBody(SVGBodyParams memory params) internal pure returns (string memory body) {
        return
            string(
                abi.encodePacked(
                    generateSVGBorderText(
                        params.quoteToken,
                        params.baseToken,
                        params.quoteTokenSymbol,
                        params.baseTokenSymbol
                    ),
                    generateSVGCardMantle(params.quoteTokenSymbol, params.baseTokenSymbol, params.feeTier),
                    generageSvgCurve(params.tickLower, params.tickUpper, params.tickSpacing, params.overRange),
                    generateSVGPositionDataAndLocationCurve(
                        params.tokenId.toString(),
                        params.tickLower,
                        params.tickUpper
                    ),
                    generateSVGRareSparkle(params.tokenId, params.poolAddress)
                )
            );
    }

    function generateSVGDefs(SVGDefsParams memory params) public pure returns (string memory svg) {
        svg = string(
            abi.encodePacked(
                '<svg width="272" height="362" viewBox="0 0 272 362" xmlns="http://www.w3.org/2000/svg"',
                " xmlns:xlink='http://www.w3.org/1999/xlink'>",
                '<defs>',
                '<style type="text/css">'
                "@import url('https://fonts.googleapis.com/css2?family=Azeret+Mono&#38;display=swap');"
                '</style>'
                '<filter id="f1"><feImage result="p1" xlink:href="data:image/svg+xml;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            "<svg width='272' height='362' viewBox='0 0 272 362' xmlns='http://www.w3.org/2000/svg'><circle cx='",
                            params.x1,
                            "' cy='",
                            params.y1,
                            "' r='100px' fill='#",
                            params.color1,
                            "'/></svg>"
                        )
                    )
                ),
                '"/><feImage result="p2" xlink:href="data:image/svg+xml;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            "<svg width='272' height='362' viewBox='0 0 272 362' xmlns='http://www.w3.org/2000/svg'><circle cx='",
                            params.x2,
                            "' cy='",
                            params.y2,
                            "' r='100px' fill='#",
                            params.color2,
                            "'/></svg>"
                        )
                    )
                ),
                '" />',
                '<feImage result="p3" xlink:href="data:image/svg+xml;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            "<svg width='272' height='362' viewBox='0 0 272 362' xmlns='http://www.w3.org/2000/svg'><circle cx='",
                            params.x3,
                            "' cy='",
                            params.y3,
                            "' r='100px' fill='#",
                            params.color3,
                            "'/></svg>"
                        )
                    )
                ),
                '" /><feBlend mode="overlay" in="p0" in2="p1" /><feBlend mode="exclusion" in2="p2" /><feBlend mode="overlay" in2="p3" result="blendOut" /><feGaussianBlur ',
                'in="blendOut" stdDeviation="42" /><feComponentTransfer><feFuncA type="linear" slope="0.4"/></feComponentTransfer></filter>',
                '<clipPath id="corners"><rect width="272" height="362" rx="10" ry="10" fill="#F1EADA" /></clipPath>',
                '<path id="text-path-a" d="M19.75 12.25 H252.25 A6 6 0 0 1 259.75 19.75 V342.25 A6 6 0 0 1 252.25 349.75 H19.75 A6 6 0 0 1 12.25 342.25 V19.75 A6 6 0 0 1 19.75 12.25 z" />',
                '<path id="minimap" d="M234 444C234 457.949 242.21 463 253 463" />',
                '<filter id="top-region-blur"><feGaussianBlur in="SourceGraphic" stdDeviation="24" /></filter>',
                '<linearGradient id="grad-up" x1="0" x2="0" y1="0.6" y2="0.25"><stop offset="0.0" stop-color="white" stop-opacity="1" />',
                '<stop offset=".7" stop-color="white" stop-opacity="0" /></linearGradient>',
                '<linearGradient id="grad-down" x1="0.25" x2=".6" y1="0" y2="0"><stop offset="0.3" stop-color="white" stop-opacity="1" /><stop offset="1" stop-color="white" stop-opacity="0" /></linearGradient>',
                '<mask id="fade-up" maskContentUnits="objectBoundingBox"><rect width="1" height="1" fill="url(#grad-up)" /></mask>',
                '<mask id="fade-down" maskContentUnits="objectBoundingBox"><rect width="1" height="1" fill="url(#grad-down)" /></mask>',
                '<mask id="none" maskContentUnits="objectBoundingBox"><rect width="1" height="1" fill="white" /></mask>',
                '<linearGradient id="grad-symbol"><stop offset="0.7" stop-color="white" stop-opacity="1" /><stop offset=".95" stop-color="white" stop-opacity="0" /></linearGradient>',
                '<mask id="fade-symbol" maskContentUnits="userSpaceOnUse"><rect width="290px" height="200px" fill="url(#grad-symbol)" /></mask>',
                '<filter id="background" x="-347" y="-225" width="965" height="812" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB"><feFlood flood-opacity="0" result="BackgroundImageFix"/><feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/><feGaussianBlur stdDeviation="57" result="effect1_foregroundBlur_686_60880"/></filter>',
                '<clipPath id="background-clip-path"><rect width="272" height="362" rx="10"/></clipPath>',
                '</defs>',
                '<g clip-path="url(#corners)">',
                '<g clip-path="url(#background-clip-path)">',
                '<g filter="url(#background)" >',
                '<circle opacity="0.5" cx="1.5" cy="319.5" r="153.5" fill="#F3BA2F"/>',
                '<circle opacity="0.5" cx="182.5" cy="319.5" r="153.5" fill="#93876A"/>',
                '<circle opacity="0.5" cx="147.5" cy="42.5" r="153.5" fill="#FFF0CE"/>',
                '<circle opacity="0.5" cx="350.5" cy="265.5" r="153.5" fill="#FAF4E6"/>',
                '<circle opacity="0.5" cx="-79.5" cy="94.5" r="153.5" fill="#AC752C"/>',
                '<circle opacity="0.5" cx="336.5" cy="58.5" r="153.5" fill="#F3BA2F"/>',
                '</g>',
                '</g>',
                '<rect style="filter: url(#f1)" x="0px" y="0px" width="290px" height="500px" />',
                generateBackgroundBanana(params.overRange),
                '</g>'
            )
        );
    }

    function generateSVGBorderText(
        string memory quoteToken,
        string memory baseToken,
        string memory quoteTokenSymbol,
        string memory baseTokenSymbol
    ) private pure returns (string memory svg) {
        svg = string(
            abi.encodePacked(
                '<text text-rendering="optimizeSpeed">',
                '<textPath startOffset="-100%" fill="#4D4040" font-family="\'Azeret Mono\', monospace " font-size="8px" xlink:href="#text-path-a">',
                baseToken,
                unicode' • ',
                baseTokenSymbol,
                ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" />',
                '</textPath> <textPath startOffset="0%" fill="#4D4040" font-family="\'Azeret Mono\', monospace " font-size="8px" xlink:href="#text-path-a">',
                baseToken,
                unicode' • ',
                baseTokenSymbol,
                ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /> </textPath>',
                '<textPath startOffset="50%" fill="#4D4040" font-family="\'Azeret Mono\', monospace " font-size="8px" xlink:href="#text-path-a">',
                quoteToken,
                unicode' • ',
                quoteTokenSymbol,
                ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s"',
                ' repeatCount="indefinite" /></textPath><textPath startOffset="-50%" fill="#4D4040" font-family="\'Azeret Mono\', monospace " font-size="8px" xlink:href="#text-path-a">',
                quoteToken,
                unicode' • ',
                quoteTokenSymbol,
                ' <animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /></textPath></text>'
            )
        );
    }

    function generateSVGCardMantle(
        string memory quoteTokenSymbol,
        string memory baseTokenSymbol,
        string memory feeTier
    ) private pure returns (string memory svg) {
        svg = string(
            abi.encodePacked(
                '<g mask="url(#fade-symbol)"><rect x="30" y="35" width="',
                uint256((78 * (bytes(quoteTokenSymbol).length + bytes(baseTokenSymbol).length + 4)) / 10).toString(),
                '" height="28" rx="10" fill="#EADFC7" fill-opacity="0.4"/> <text y="53px" x="40.25px" fill="#4D4040" font-family="\'Azeret Mono\', monospace " font-weight="900" font-size="12px">',
                quoteTokenSymbol,
                '/',
                baseTokenSymbol,
                '</text><rect x="30" y="73" width="',
                uint256((78 * (bytes(feeTier).length + 3)) / 10).toString(),
                '" height="28" rx="10" fill="#EADFC7" fill-opacity="0.4"/>',
                '<text y="91px" x="40.25px" fill="#4D4040" font-family="\'Azeret Mono\', monospace " font-weight="600" font-size="12px">',
                feeTier,
                '</text></g>',
                '<rect x="16.75" y="16.75" width="238" height="328.5" rx="6" fill="none" stroke="#4D4040" stroke-opacity="0.2" stroke-width="1.5"/>'
            )
        );
    }

    function generageSvgCurve(
        int24 tickLower,
        int24 tickUpper,
        int24 tickSpacing,
        int8 overRange
    ) private pure returns (string memory svg) {
        string memory fade = overRange == 1 ? '#fade-up' : overRange == -1 ? '#fade-down' : '#none';
        string memory curve = getCurve(tickLower, tickUpper, tickSpacing);
        svg = string(
            abi.encodePacked(
                '<g mask="url(',
                fade,
                ')">',
                '<rect x="-16px" y="-16px" width="304px" height="394px" fill="none" />'
                '<path d="',
                curve,
                '" stroke="#4D4040" opacity="0.4" stroke-width="26px" fill="none" stroke-linecap="round" stroke-linejoin="round" />',
                '</g><g mask="url(',
                fade,
                ')">',
                '<rect x="-16px" y="-16px" width="304px" height="394px" fill="none" />',
                '<path d="',
                curve,
                '" opacity="0.89" stroke="#4D4040" fill="none" stroke-width="3" stroke-linecap="round" /></g>',
                generateSVGCurveCircle(overRange)
            )
        );
    }

    function generateBackgroundBanana(int8 overRange) internal pure returns (string memory background) {
        if (overRange == -1) {
            background = string(
                abi.encodePacked(
                    '<g style="transform:translate(18px, 60px)" opacity="0.5">',
                    '<path d="M153.3 137.4c3.3-2.4 4.2-7.8 4.1-11s-2-26.9-16.9-47.7c-1.5-2.1-2.4-4.9-4.6-6.3-15.8-10.7-33.1 22.1-31.3 25.4 6.6 11.8 14.4 23.7 26.1 31.2 4 2.4 13.7 14.7 22.6 8.4z" fill="#ffc938"/>',
                    '<path d="M153.7 135.2c3.4-5.1 1.7-16.8-2.4-26.3-.4-1.6-10.7-21.8-13.1-27.4-1-2.4-2.3-5.1-4.7-6-1.1-.4-2.3-.4-3.5-.2-4.5.6-8.7 3.4-11 7.2-1.8 3-2.6 6.4-2.9 9.9-1.6 15.3 29.4 47 30.1 46.7.9-.4 4.9-.5 7.5-3.9h0z" fill="#e8b134"/>',
                    '<path d="M203.1 190.1h0c-9 .6-18 .2-26.9-1.3-3.2-.5-11-3.8-11.8-4.5a32.7 32.7 0 0 1-2.7 1.5c-22.4 11.5-38.8-2.7-55.2-20.7-15.3-16.8-26-36.4-26-36.4l40.2-26.4s12.3 20.1 25 32.8c7.8 7.8 13.1 11.1 21 19 3.5 3.5 6.2 8.1 7 12.8 1.2 1.4 2.3 3 3.4 3.9 6.8 5.8 16.6 8.2 25.2 5.7.7-.7.8-1.7 1.1-2.6h0c2.1-6.8 1.3 16.3-.3 16.2zM51.6 113.2c-.1 2.5.8 4.8 1.8 7.1 2.3 5 5.2 9.8 9.2 13.6 1.6 1.5 3.4 2.9 5.5 3.6 2.1.8 4.4.9 6.4 0 2.1-.9 3.6-2.8 4.5-5 .9-2.1 1.2-4.4 1.3-6.7.4-4.8.2-9.8-1.8-14.2s-6-8.1-10.9-8.5c-5.2-.5-15.6 3.8-16 10.1h0z" fill="#ffc938"/>',
                    '<path d="M56.7 112.7c-.1 0-1.8.6-2.3 1.3-.7 1.1-.4 2.5 0 3.7 1.2 3.3 3.3 6.3 5.4 9.1.9 1.1 1.8 2.3 3.2 2.9 1.2.5 2.6.3 3.8-.1 3.3-1.3 6.2-4.4 8.3-7.2 1-1.3 2.4-3.3 1.7-5-.4-1.1-1.6-1.6-2.7-2.1-5.4-2.2-11.6-3.8-17.4-2.6z" fill="#e8b134"/>',
                    '<path d="M52.2 111c10.6-3.2 22.4.1 31.4 6.5 1-.3-7.8-28.5-23.7-16.1-3.2 2.6-5.9 5.9-7.7 9.6h0zm71.6-43.6c10.3.6 13.4 5.9 13.4 5.9s-4.8-3.1-11-.1C112.8 77.8 112.1 96 112.1 96l-13.8-9.8c-.1 0 3.3-18 25.5-18.8z" fill="#fce18b"/><g fill="#e8b134">',
                    '<path d="M165.5 176.6c.2.1.5.2.7.3a1.08 1.08 0 0 1-.7-.3zm1.7.8c.8.4 2.1.8 2.8 1.2-.9-.4-1.9-.7-2.8-1.2zm35.9 12.8c-9 .6-18 .1-26.9-1.4-3.2-.5-11-3.8-11.8-4.5-.8.5-1.7 1-2.6 1.5-22.4 11.5-38.8-2.7-55.2-20.7-15.3-16.8-26-36.4-26-36.4s13.2-7.7 14.3-5c9.2 21.8 25.7 41 47.4 50.4 5.2 2.2 11.6 5.4 18.6 3.6 1.2-.3 2.6-1.2 3.9-1.1 1.2.1 2.4.9 3.6 1.4 7.4 3 15.3 4.2 23.1 5.3 2.3.3 4.6.6 6.9.7 1.4 0 2.8-.4 4.1-.6a81.59 81.59 0 0 0 .6 6.8z"/>',
                    '<path d="M166.7 177.2c-.3-.1-.4-.2-.5-.2h-.1c.3.1.5.2.6.2z"/></g>',
                    '<path d="M55.8 73.1c-5.6-22.2-5.5-39.4 1-46.2 8.7-9.1 15.3-4.1 20.9 3.7 5.2 7.3 7.9 23.5 21.7 45.9 9.6 15.7 20.7 29.3 20.7 29.3l-35.9 22.9c0 .1-22.5-32.3-28.4-55.6z" fill="#fde8c8"/>',
                    '<path d="M55.8 73.1c-5.6-22.2-5.5-39.4 1-46.2 2.7-2.9 5.3-4.4 7.7-4.8-.3.3-12.7 11-1.8 47 5.5 22 26 52.1 28.2 55.3l-6.7 4.2c0 .2-22.5-32.2-28.4-55.5h0z" fill="#edd5b5"/>',
                    '<path d="M79.2 126.7c1-9 7-12 15.2-12.4l7.2 1.8 17.8-15.8s4.1 6.7 10.1 14.9c-2.3-.2-4.7-1.3-7-1.4-2.8-.1-5.7.2-8.3 1.2-3.7 1.3-7.2 4-7.9 7.8-5.2-.2-9.6 4.3-11 9.3s-.3 10.3 1 15.3c.8 3 1.7 6 3 8.8-12.1-14.8-20.1-29.5-20.1-29.5z" fill="#e2a139"/>',
                    '<path d="M101.6 116.1s-11.2-1.2-15 3.3c-8.9 10.5 13.1 37.7 17.9 48.7 3.6 8.3 1.8 12.3-.5 13.6-5 2.9-18.8.2-29.3-16S67 119.2 80 115.8s21.6.3 21.6.3h0z" fill="#ffc938"/>',
                    '<path d="M101.6 116.1s-13.5-2.5-17.4 1.9c-10 11.4 11.8 38 16.5 49 3.6 8.3 3.1 11.9.9 13.2-5 2.9-18.8.2-29.3-16S58.9 133.5 60 128.9c1.5-6 4.5-11.3 17.6-14.7 13-3.2 24 1.9 24 1.9h0z" fill="#fce18b"/>',
                    '<path d="M217.3 171.1c-.4-1.2-.9-2.3-1.9-3-.6-.4-1.3-.6-1.9-.6-2.8-.3-5.6.9-8.2 2.2-.4.2-.8.4-1.1.7-1.1 1.1-.6 2.9-.4 4.4.3 1.8.2 3.7-.2 5.4-.1.5-.3 1-.2 1.6.1.7 10.6-1.1 13.5-2.9 2.6-1.8 1.3-5.5.4-7.8h0z" fill="#937c69"/>',
                    '<path d="M204.4 179.6c1-.7 2.3-.7 3.5-.9 2.9-.3 5.7-1 8.4-2 .6-.2 1.3-.4 1.8 0 .4.3.4.8.4 1.3 0 2.1-1.4 8.9-2.4 9.9-.6.6-1.4 1-2.2 1.4-2.7 1.1-5.7 1.3-8.6 1.4-.8 0-1.7 0-2.3-.5s-.7-1.3-.8-2c-.2-1.4.8-7.7 2.2-8.6h0z" fill="#776057"/>',
                    '<path d="M101.6 116.1s0-10.7 33.5-16.6c56.2 9.3 50.7 16.1 47.3 22.1-3.4 5.9-24.5-9.2-40.8-14.3-23.1-7.2-40 8.8-40 8.8h0z" fill="#ffc938"/>',
                    '<path d="M101.9 114.9s6.3-24.5 28.4-32.1c13.1-4.6 23.6-5.9 41.2 7.9 13.9 10.9 15.6 21.5 12.3 27.4-3.4 5.9-24.5-9.2-40.8-14.3-31.3-5.9-41.1 11.1-41.1 11.1z" fill="#fce18b"/>',
                    '</g>'
                )
            );
        } else if (overRange == 0) {
            background = string(
                abi.encodePacked(
                    '<g style="transform:translate(18px, 62px)" opacity="0.5">',
                    '<path d="M214.4 177.8C138.7 187.9 50.9 132 62.6 57.6c.1-.3.5-.4.8-.6.4-4.1 1.4-10.7 3.8-17.5.2-.5.3-.9.5-1.4-.5-3.3-1-6.7-2.9-9.5-.4-.6-.9-1.2-1.1-2-.1-.7 0-1.4.2-2C64.4 22.4 73 13.1 84 29c1 1.4-1.1 3.3-1.9 4.9-.2.5-.5.8-.7 1.2-.7 2.5-1.5 5.8-2.2 9.9-.8 4.7-.4 9.1.2 12.7 3.7 1.8 7.5 4.7 11 8.8 9.4 11 6.8 25.3 31.2 49.9 24.6 24.8 52.6 35.9 62 38.7 14.6 4.4 30.5 7.1 30.5 7.1l.3 15.6z" fill="#ffc938"/>',
                    '<path d="M216.7 170.9l-2.3 6.9s-19 20.6-81.3 2.8c-46.2-13.2-75.4-57.9-80.1-75.8-6-23 1.7-40.2 9.6-47.3 0 0 .6-7 4.6-18.1.2-.5.3-.9.5-1.4-.5-3.3-3.8-10.7-4-11.4-.1-.7 3.9-7.8 7.9-5.2.5.3-.6 1-.5 1.6.1.5 2.4 4.5 3.6 7.2-.4 4.4-4.3 25.3-5.5 26.4l5.8.8s-2.6 1.9-1.7 15.7c.9 13.4 9.4 46 39.5 67.7 51.7 37.2 97.4 28.9 97.4 28.9s3.3.1 6.5 1.2z" fill="#f2bb40"/>',
                    '<path d="M214 162.2l2.9 5.5a3.02 3.02 0 0 1 .2 2.1l-2.7 8-5-2.9c-.5-.3-.8-.8-.7-1.4l.2-4.9c0-.3.1-.7.4-.9l4.7-5.5h0z" fill="#776057"/>',
                    '<path d="M75.8 14.3c1.2.7 2.3 1.7 3.5 2.5l4.5 3c.6.5 1.2 1.1 1.6 1.7.6 1 .8 2.1.8 3.3s-.3 2.3-.5 3.4c-.2 1-.5 2-1 2.8-.7 1.2-1.9 2-2.6 3.1 0-1.2.3-2.7-.5-3.6-2-2.6-2.8-3.4-6.9-6.4l-3-2.3c-.6-.4-1.3-.7-1.8-1.3s-.6-1.4-.5-2.1.3-1.4.5-2.2c.2-.7.3-1.4.6-2 .4-.9 1.1-1.3 2-1.1 1.2.1 2.3.6 3.3 1.2h0z" fill="#937c69"/>',
                    '<path d="M74.2 14.8c-.2.7-.5 1.3-.8 1.8-.6 1.1-1 2.3-1.3 3.5-.1.5-.2 1-.5 1.3-.2.2-.5.2-.7.2-2.2 0-4.8 1.8-6.7 4.7-.1.2-.2.4-.4.4-.1 0-.2-.2-.2-.4-.1-1 .1-2.2.4-3.3.6-2.5 1.5-5.1 2.7-7.4.6-1.1 1.3-2.2 2.1-2.6.4-.2.8-.2 1.2-.2 1 .1 4.7-.2 4.2 2h0z" fill="#776057"/>',
                    '</g>'
                )
            );
        } else if (overRange == 1) {
            background = string(
                abi.encodePacked(
                    '<g style="transform:translate(18px, 62px)" opacity="0.5">',
                    '<path d="M140.6 189.1c20.9 9.5 37.7 12.4 45.6 7.3 10.5-6.9 6.8-14.4.1-21.2-6.2-6.4-21.7-12-41.3-29.5-13.7-12.3-25.2-25.6-25.2-25.6l-28.9 31.3c0-.1 27.9 27.9 49.7 37.7z" fill="#fde8c8"/>',
                    '<path d="M140.6 189.1c20.9 9.5 37.7 12.4 45.6 7.3 3.3-2.2 5.2-4.4 6.1-6.7-.3.2-.6.4-1 .7-7.9 5.2-24.7 2.2-45.6-7.3-20.6-9.4-46.7-34.9-49.4-37.6l-5.4 5.8c0 0 27.8 28 49.7 37.8h0z" fill="#edd5b5"/>',
                    '<path d="M151.9 114.6c-1-8.4-3.9-16.5-8.5-23.5-.9-1.3-1.9-2.6-3.3-3.1-2.4-.8-5 1.2-6.1 3.5s-1.1 5-1.7 7.5c-1.5 6.3-6.2 11.4-11.2 15.5-5.1 4.2 30.8 26.2 30.8.1h0zm-75.3 24.2c3 4.3 8.2 9.7 5 13.8-14 18.2-38 23.4-50.6 26.3-7.5 1.7-16.5 1.7-23.3 5.2-2 1-4.1 2.5-4.3 4.7-.3 3.1 3.2 5.1 6.2 5.8 17.6 2.2 72-9.1 86.5-24.5 5.1-5.4 6.6-7.8 6.9-12.7.4-6.5-3.7-12.4-8.7-16.5-2.3-2-20.7-6.5-17.7-2.1z" fill="#e8b134"/>',
                    '<path d="M84.1 140.7l-3.4 1.2c-.1-.1-.3-.2-.4-.4l3.8-.8zm149.4-31.8c0 1.9-1.3 3.5-2.7 4.8-8 8.2-18.9 13-29.7 16.9-8.3 3-38 10.6-44.6 11.3-23.6 2.5-13.1 4.1-10.2 7.2 1.2 1.2-26 17.3-28.4 16.9-6.5-1-23.8-20.4-28-26.8l-9.7 2.3c-14.8-14.4-34.4-60.9-19.8-84.4.2-3.8.8-10.7 3-17.7.1-.5.3-.9.4-1.3-.6-3.2-1.2-6.4-3.1-8.9-.4-.6-1-1.1-1.1-1.8-.2-.6 0-1.3.1-2 .6-2.9 10.1-4.2 10.1-4.2s9.3 8.5 7.7 12.3c-.2.4-.4.8-.7 1.2-.6 2.4-1.2 5.6-1.7 9.5-.5 4.5 0 8.7.7 12.1 3.8 1.5 7.8 4.2 11.5 8.2 9.4 10.1 7.5 23.9 31.8 46.3 4.7 4.4 9.5 8.2 14.3 11.6l-.1.1c7.1 2.8 8.5 2.3 16.2 2 27.7-1.1 55-7.8 80.4-18.6 1.7-.8 3.6 1.2 3.6 3z" fill="#ffc938"/>',
                    '<path d="M148.8 148.5c-1.3-6.2-4.1-12.4-9.3-16.1-2.5-1.8-5.8-2.9-8.5-1.5-2.4 1.2-3.6 4-4.3 6.6-1.6 6.2-2.4 12.5-4.2 18.6-1.9 6.3-4.9 9.9-4.6 10.1 2.4.9 7.4-1 9.9-1.6 5.4-1.3 10.6-3.3 15.5-6.1 4.4-2.6 6.6-4.7 5.5-10h0z" fill="#fce18a"/>',
                    '<path d="M90.6 140.2l-9.2 3.4c-15.1-14.5-26.1-32.3-28.8-41.2-6.7-21.7 0-38.4 7.2-45.5.2-.2.5-.4.7-.6.2-3.9.9-10.3 2.9-16.8.1-.4.3-.9.4-1.3-.6-3.2-4.1-10-4.3-10.8-.2-.6 0-1.3.1-1.9.5-2.2 8-5.8 7.2-3.3-.2.5-.6 1-.4 1.5.1.4 2.5 4.2 3.7 6.7-.2 4.2-.9 7.1-1.4 11.5-.4 3.9-.2 8.1-1.6 11.8-.3.8-.7 1.5-1.2 2.2-.2.1-1.1.8-2.2 2.5-2.2 3.2-5.3 10-5.8 23.3-.5 13 9.3 33.7 26.9 52.9 1.2 1.2 4.4 4.3 5.8 5.6z" fill="#e8b134"/>',
                    '<path d="M80.9 24.6c0 1.7-.2 3.4-.8 4.9-.6 1.6-2 2.6-2.8 4.1-.1-1.1.1-2.6-.6-3.5-2-2.4-2.9-3.1-6.9-5.8-.8-.6-2.2-1.5-3-2 0 0-.1-.1-.2-.1-.2.1-.3.1-.5.1-2.1 0 1.3-8.6 3-8 1.4.6 2.7 1.6 4 2.4 3.4 2.1 7.8 3.5 7.8 7.9z" fill="#937c69"/>',
                    '<path d="M66.9 22.3c2-2.3 3.2-7.6 2.3-7.9-1.7-.7-4.7-1.1-6 .4-.5.6-.8 1.3-1.2 1.9-1.1 2.2-1.9 4.7-2.3 7.2-.2 1.1-.3 2.2-.2 3.2 0 .2 0 .4.2.4.1 0 .2-.2.3-.3 1.6-2.6 5-4.5 6.9-4.9z" fill="#776057"/>',
                    '</g>'
                )
            );
        }
    }

    function getCurve(
        int24 tickLower,
        int24 tickUpper,
        int24 tickSpacing
    ) internal pure returns (string memory curve) {
        int24 tickRange = (tickUpper - tickLower) / tickSpacing;
        if (tickRange <= 4) {
            curve = curve1;
        } else if (tickRange <= 8) {
            curve = curve2;
        } else if (tickRange <= 16) {
            curve = curve3;
        } else if (tickRange <= 32) {
            curve = curve4;
        } else if (tickRange <= 64) {
            curve = curve5;
        } else if (tickRange <= 128) {
            curve = curve6;
        } else if (tickRange <= 256) {
            curve = curve7;
        } else {
            curve = curve8;
        }
    }

    function generateSVGCurveCircle(int8 overRange) internal pure returns (string memory svg) {
        string memory curvex1 = '90.5263';
        string memory curvey1 = '135.526';
        string memory curvex2 = '181.474';
        string memory curvey2 = '226.474';
        if (overRange == 1 || overRange == -1) {
            svg = string(
                abi.encodePacked(
                    '<circle cx="',
                    overRange == -1 ? curvex1 : curvex2,
                    'px" cy="',
                    overRange == -1 ? curvey1 : curvey2,
                    'px" r="3.5px" fill="#4D4040" />',
                    '<circle cx="',
                    overRange == -1 ? curvex1 : curvex2,
                    'px" cy="',
                    overRange == -1 ? curvey1 : curvey2,
                    'px" r="9px" fill-opacity="0.4" fill="#4D4040" />',
                    '<circle cx="',
                    overRange == -1 ? curvex1 : curvex2,
                    'px" cy="',
                    overRange == -1 ? curvey1 : curvey2,
                    'px" r="17px" fill-opacity="0.4" fill="#4D4040" />'
                )
            );
        } else {
            svg = string(
                abi.encodePacked(
                    '<circle cx="',
                    curvex1,
                    'px" cy="',
                    curvey1,
                    'px" r="2.5px" fill="#4D4040" />',
                    '<circle cx="',
                    curvex2,
                    'px" cy="',
                    curvey2,
                    'px" r="2.5px" fill="#4D4040" />'
                )
            );
        }
    }

    function generateSVGPositionDataAndLocationCurve(
        string memory tokenId,
        int24 tickLower,
        int24 tickUpper
    ) private pure returns (string memory svg) {
        string memory tickLowerStr = tickToString(tickLower);
        string memory tickUpperStr = tickToString(tickUpper);
        uint256 str1length = bytes(tokenId).length + 4;
        uint256 str2length = bytes(tickLowerStr).length + 10;
        uint256 str3length = bytes(tickUpperStr).length + 10;
        (string memory xCoord, string memory yCoord) = rangeLocation(tickLower, tickUpper);
        svg = string(
            abi.encodePacked(
                ' <g style="transform:translate(30px, 245px)">',
                '<rect width="',
                uint256(7 * (str1length + 3)).toString(),
                'px" height="25px" rx="10px" ry="10px" fill="#EADFC7" fill-opacity="0.4" />',
                '<text font-weight="900" x="11.25px" y="16px" font-family="\'Azeret Mono\', monospace " font-size="10px" fill="#4D4040"><tspan font-weight="normal" fill="#4D4040">ID: </tspan>',
                tokenId,
                '</text></g>',
                ' <g style="transform:translate(30px, 275px)">',
                '<rect width="',
                uint256(7 * (str2length + 3)).toString(),
                'px" height="25px" rx="10px" ry="10px" fill="#EADFC7" fill-opacity="0.4" />',
                '<text font-weight="900" x="11.25px" y="16px" font-family="\'Azeret Mono\', monospace " font-size="10px" fill="#4D4040"><tspan font-weight="normal" fill="#4D4040">Min Tick: </tspan>',
                tickLowerStr,
                '</text></g>',
                ' <g style="transform:translate(30px, 305px)">',
                '<rect width="',
                uint256(7 * (str3length + 3)).toString(),
                'px" height="25px" rx="10px" ry="10px" fill="#EADFC7" fill-opacity="0.4" />',
                '<text font-weight="900" x="11.25px" y="16px" font-family="\'Azeret Mono\', monospace " font-size="10px" fill="#4D4040"><tspan font-weight="normal" fill="#4D4040">Max Tick: </tspan>',
                tickUpperStr,
                '</text></g>'
                '<g style="transform:translate(215px, 305px)">',
                '<rect width="26px" height="26px" rx="5px" ry="5px" fill="#EADFC7" fill-opacity="0.4" />',
                '<path stroke-linecap="round" d="M5 5C5 17 9 21 21 21" fill="none" stroke="#4D4040" />',
                '<circle style="transform:translate3d(',
                xCoord,
                'px, ',
                yCoord,
                'px, 0px)" cx="0px" cy="0px" r="3px" fill="#4D4040"/></g>'
            )
        );
    }

    function tickToString(int24 tick) internal pure returns (string memory) {
        string memory sign = '';
        if (tick < 0) {
            tick = tick * -1;
            sign = '-';
        }
        return string(abi.encodePacked(sign, uint256(uint24(tick)).toString()));
    }

    function rangeLocation(int24 tickLower, int24 tickUpper) internal pure returns (string memory, string memory) {
        int24 midPoint = (tickLower + tickUpper) / 2;
        if (midPoint < -125_000) {
            return ('5', '5'); //
        } else if (midPoint < -75_000) {
            return ('5.2', '8');
        } else if (midPoint < -25_000) {
            return ('5.7', '11');
        } else if (midPoint < -5_000) {
            return ('6.6', '14');
        } else if (midPoint < 0) {
            return ('7.5', '16'); //
        } else if (midPoint < 5_000) {
            return ('9.5', '18'); //
        } else if (midPoint < 25_000) {
            return ('12', '19.3');
        } else if (midPoint < 75_000) {
            return ('15', '20.2');
        } else if (midPoint < 125_000) {
            return ('18', '20.8');
        } else {
            return ('21', '21'); //
        }
    }

    function generateSVGRareSparkle(uint256 tokenId, address poolAddress) private pure returns (string memory svg) {
        if (isRare(tokenId, poolAddress)) {
            svg = string(
                abi.encodePacked(
                    '<g style="transform:translate(215px, 271px)"><rect width="26px" height="26px" rx="5px" ry="5px" fill="#EADFC7" fill-opacity="0.4" />',
                    '<g style="transform:translate(5px, 4px)">',
                    '<defs><path id="A" d="M.2.2h14.6v17.7H.2z"/></defs><clipPath id="B"><use xlink:href="#A"/></clipPath>',
                    '<path d="M8.2 17.9c-.8.1-1.8-.2-1.4-1.1s1.3-1.5 1.9-2.2l1.1-1.5c.3-.5.7-1.1.8-1.7-.1.1-.6 1.2-1.9 2.1-.8.6-1.7 1.1-2.6 1.4-1.1.4-2.2.5-3.3.4-.7-.1-1.5-.2-2.1-.6-.3-.2-.6-.6-.5-1 .1-.5.8-.6 1.3-.7 1.3-.3 2.4-.7 3.5-1.4.8-.5 1.6-1.2 2.2-2 1.3-1.7 2-3.9 1.9-6v-.3s0-.5.3-.7c0 0-.3-1.3-.2-1.6.2-.2 1.2-.3 1.4-.1.1.2.2 1.3.2 1.3.4.1.8.4 1.1.6.6.5 1.1 1.2 1.6 1.9a9.04 9.04 0 0 1 1.1 2.7c.2.9.3 1.9.2 2.8s-.3 1.9-.7 2.7c-.4.9-1.9 2.6-2.6 3.3-.6.6-2.5 1.6-3.3 1.7z" clip-path="url(#B)" fill="#4d4040"/>',
                    '</g></g>'
                )
            );
        } else {
            svg = '';
        }
    }

    function isRare(uint256 tokenId, address poolAddress) internal pure returns (bool) {
        bytes32 h = keccak256(abi.encodePacked(tokenId, poolAddress));
        return uint256(h) < type(uint256).max / (1 + BitMath.mostSignificantBit(tokenId) * 2);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

/// @title BitMath
/// @dev This library provides functionality for computing bit properties of an unsigned integer
library BitMath {
    /// @notice Returns the index of the most significant bit of the number,
    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    /// @dev The function satisfies the property:
    ///     x >= 2**mostSignificantBit(x) and x < 2**(mostSignificantBit(x)+1)
    /// @param x the value for which to compute the most significant bit, must be greater than 0
    /// @return r the index of the most significant bit
    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0);

        unchecked {
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

    /// @notice Returns the index of the least significant bit of the number,
    ///     where the least significant bit is at index 0 and the most significant bit is at index 255
    /// @dev The function satisfies the property:
    ///     (x & 2**leastSignificantBit(x)) != 0 and (x & (2**(leastSignificantBit(x)) - 1)) == 0)
    /// @param x the value for which to compute the least significant bit, must be greater than 0
    /// @return r the index of the least significant bit
    function leastSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0);

        unchecked {
            r = 255;
            if (x & type(uint128).max > 0) {
                r -= 128;
            } else {
                x >>= 128;
            }
            if (x & type(uint64).max > 0) {
                r -= 64;
            } else {
                x >>= 64;
            }
            if (x & type(uint32).max > 0) {
                r -= 32;
            } else {
                x >>= 32;
            }
            if (x & type(uint16).max > 0) {
                r -= 16;
            } else {
                x >>= 16;
            }
            if (x & type(uint8).max > 0) {
                r -= 8;
            } else {
                x >>= 8;
            }
            if (x & 0xf > 0) {
                r -= 4;
            } else {
                x >>= 4;
            }
            if (x & 0x3 > 0) {
                r -= 2;
            } else {
                x >>= 2;
            }
            if (x & 0x1 > 0) r -= 1;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

/// @title Base64
/// @author Brecht Devos - <[email protected]>
/// @notice Provides functions for encoding/decoding base64
library Base64 {
    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';

        // load the table into memory
        string memory table = TABLE_ENCODE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {} lt(dataPtr, endPtr) {}
            {
                // read 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // write 4 characters
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {
        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        // load the table into memory
        bytes memory table = TABLE_DECODE;

        // every 4 characters represent 3 bytes
        uint256 decodedLen = (data.length / 4) * 3;

        // add some extra buffer at the end required for the writing
        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            // padding with '='
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            // set the actual output length
            mstore(result, decodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 4 characters at a time
            for {} lt(dataPtr, endPtr) {}
            {
               // read 4 characters
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               // write 3 bytes
               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}