// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

contract NFTUtils {
    string internal constant TABLE =  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    
    function genReferralCode(uint256 _accountId) public pure returns (string memory) {
        bytes memory _orgCode = bytes(toHexString(_accountId));
        uint8 rType = uint8(_accountId % 10);
        bytes memory rtnV = new bytes( (_orgCode.length > 5 ? _orgCode.length : 5) + 1);//abi.encodePacked(rType);

        rtnV[0] = toChar(rType);
        for(uint i = 0; i < 5; i++){
            uint use_digit = rType > 4 ? (i + rType ) % 5 : (5 - i + rType) % 5;
            rtnV[i+1] = use_digit >= _orgCode.length ? bytes1("0"): _orgCode[use_digit];
        }

        for(uint i = 5; i < _orgCode.length; i++){
            rtnV[i+1] =  _orgCode[i];
        }
        return string(rtnV);
    }

    function attributeForTypeAndValue(
        string memory traitType,
        string memory value
    ) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"trait_type":"',
                    traitType,
                    '","value":"',
                    value,
                    '"}'
                )
            );
    }

    function toChar(uint8 d) public pure returns (bytes1) {
        if (0 <= d && d <= 9) {
            return bytes1(uint8(bytes1('0')) + d);
        } else if (10 <= uint8(d) && uint8(d) <= 35) {
            return bytes1(uint8(bytes1('a')) + d - 10);
        }
        // revert("Invalid hex digit");
        revert();
    }

    function toHexString(uint a) public pure returns (string memory) {
        uint _count = 0;
        uint b = a;
        while (b != 0) {
            _count++;
            b /= 16;
        }
        bytes memory res = new bytes(_count);
        for (uint i=0; i<_count; ++i) {
            b = a % 36;
            res[_count - i - 1] = toChar(uint8(b));
            a /= 16;
        }
        return string(res);
    }

    
    function base64(bytes memory data) public pure returns (string memory) {
        if (data.length == 0) return "";

        // load the table into memory
        string memory table = TABLE;

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
            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)

                // read 3 bytes
                let input := mload(dataPtr)

                // write 4 characters
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(input, 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }
}