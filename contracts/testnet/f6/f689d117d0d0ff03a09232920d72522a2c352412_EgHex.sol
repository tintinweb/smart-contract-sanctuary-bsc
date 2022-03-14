/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract EgHex{
    function test() public pure returns(bytes memory){
        return hex"c7A084C055dbc6F1543a32bbf99fd53b379e6614";
    }

    function test1() public pure returns(bytes memory){
        return hex"c7A084C055dbc6F1543a32bbf99fd53b379e6614";
    }

    function test2() public pure returns(bytes memory){
        // bytes memory aaa = new bytes("c7A084C055dbc6F1543a32bbf99fd53b379e6614");
        return fromHex('c7A084C055dbc6F1543a32bbf99fd53b379e6614');
    }

    // Convert an hexadecimal character to their value
function fromHexChar(uint8 c) public pure returns (uint8) {
    if (bytes1(c) >= bytes1('0') && bytes1(c) <= bytes1('9')) {
        return c - uint8(bytes1('0'));
    }
    if (bytes1(c) >= bytes1('a') && bytes1(c) <= bytes1('f')) {
        return 10 + c - uint8(bytes1('a'));
    }
    if (bytes1(c) >= bytes1('A') && bytes1(c) <= bytes1('F')) {
        return 10 + c - uint8(bytes1('A'));
    }
    return 0;
}

    function cakeV2LibPairFor(
        address factory,
        address tokenA,
        address tokenB,
        bytes memory INIT_HASH
    ) internal pure returns (address pair) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(
            bytes20(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        INIT_HASH
                    )
                )
            )
        );
    }

    // Convert an hexadecimal string to raw bytes
    function fromHex(string memory s) public pure returns (bytes memory) {
        bytes memory ss = bytes(s);
        require(ss.length%2 == 0); // length must be even
        bytes memory r = new bytes(ss.length/2);
        for (uint i=0; i<ss.length/2; ++i) {
            r[i] = bytes1(fromHexChar(uint8(ss[2*i])) * 16 +
                        fromHexChar(uint8(ss[2*i+1])));
        }
        return r;
    }

    // function test6() public view returns (string memory){
    //     return test5();
    // }

    function test5() public pure returns(string[] memory returnData){
        returnData[0] = "123";
    }

    function getResult() public pure returns(uint product, uint sum){
      uint a = 1; 
      uint b = 2;
      product = a * b;
      sum = a + b; 
   }

    function areTheyEqual() public pure returns(bool) {
        return cakeV2LibPairFor(0xA54232F351b7E70a227ee4037f34256d2108CF04,0x78C8c2ecE76Dd6af79dD7429e2fd83b439BF413d,0xfF6FD90A470Aaa0c1B8A54681746b07AcdFedc9B, test1()) == 
               cakeV2LibPairFor(0xA54232F351b7E70a227ee4037f34256d2108CF04,0x78C8c2ecE76Dd6af79dD7429e2fd83b439BF413d,0xfF6FD90A470Aaa0c1B8A54681746b07AcdFedc9B, test2());
    }
}