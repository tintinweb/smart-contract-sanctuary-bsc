/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Value {
    // uint256 public result;
    function getCopy(uint256 a,uint256 slot) public pure returns(bytes32 response) {
        // result = a;
        assembly {
            response := calldataload(slot)
        }

       // status = response == a;
    }

    function getBytes(uint256 args) public pure returns (bytes32) {
        return bytes32(args);
    }
    
    function getMax() public pure returns (uint256) {
        return type(uint256).max;
    }

    function getBytesLength(bytes memory data) public pure returns (uint256) {
        return data.length;
    }

    function getSignature(uint256 a,uint256 slot) public pure returns (bytes memory) {
        return abi.encodeWithSignature("getCopy(uint256,uint256)",a,slot);
    }

    function getMultipleCopy(
        uint96 dataOne,
        uint128 dataTwo,
        uint24 dataThree,
        uint8 dataFour,
        uint256 slot) public pure returns(bytes32 response) {
        assembly {
            response := calldataload(slot)
        }
    }

    function getSize(
        uint96 dataOne,
        uint128 dataTwo,
        uint24 dataThree,
        uint8 dataFour,
        uint256 slot) public pure returns(uint256 response) {
        assembly {
            response := calldatasize()
        }
    }

    function getMultiSignature(
        uint96 dataOne,
        uint128 dataTwo,
        uint24 dataThree,
        uint8 dataFour,
        uint256 slot
    ) public pure returns (bytes memory) {
        return abi.encodeWithSignature(
            "getMultipleCopy(uint96,uint128,uint24,uint8,uint256)",
            dataOne,dataTwo,dataThree,dataFour,slot);
    }
} 







// seaport - https://goerli.etherscan.io/address/0x00000000006c3852cbEf3e08E8dF289169EdE581#code


// sell - https://testnets.opensea.io/assets/goerli/0xc36442b4a4522e871399cd717abdd847ab11fe88/37302



// Create Order -
// offerer: 0x36Ee7371c5D0FA379428321b9d531a1cf0a5cAE6
// offer: 
// 0: itemType: 2
//    token: 0xC36442b4a4522E871399CD717aBDD847Ab11FE88
//    identifierOrCriteria: 37302
//    startAmount: 1
//    endAmount: 1
   
// consideration: 
// 0: itemType: 0
//    token: 0x0000000000000000000000000000000000000000
//    identifierOrCriteria: 0
//    startAmount: 97500000000000000
//    endAmount: 97500000000000000
//    recipient: 0x36Ee7371c5D0FA379428321b9d531a1cf0a5cAE6
// 1: itemType: 0
//    token: 0x0000000000000000000000000000000000000000
//    identifierOrCriteria: 0
//    startAmount: 2500000000000000
//    endAmount: 2500000000000000
//    recipient: 0x0000a26b00c1F0DF003000390027140000fAa719
//    startTime: 1669015500
//    endTime: 1678692300
//    orderType: 0
//    zone: 0x0000000000000000000000000000000000000000
//    zoneHash: 0x0000000000000000000000000000000000000000000000000000000000000000
//    salt: 24446860302761739304752683030156737591518664810215442929806115867313005146194
//    conduitKey: 0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000
//    counter: 0
   
 
// Complete Order - 

// FulfillBasicOrder

// Raw Data -0xfb0f3ee1000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015a63bbc199c00000000000000000000000000036ee7371c5d0fa379428321b9d531a1cf0a5cae60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c36442b4a4522e871399cd717abdd847ab11fe8800000000000000000000000000000000000000000000000000000000000091b60000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000637b27cc00000000000000000000000000000000000000000000000000000000640ecfcc0000000000000000000000000000000000000000000000000000000000000000360c6ebe00000000000000000000000000000000000000004f9057d04a3830520000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f00000000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f00000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000002a000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000008e1bc9bf040000000000000000000000000000000a26b00c1f0df003000390027140000faa71900000000000000000000000000000000000000000000000000000000000000410e5771bfa7fcade47fb429590494091aa8cbe082543b92202fc5128c084552801d63c9f888c41a36c400c11d830b2d571d9a99ad4eba80a83f53d4544a4aa9981c00000000000000000000000000000000000000000000000000000000000000360c6ebe






// considerationToken; // 0x24        //  36       0x0000000000000000000000000000000000000000     
 
// considerationIdentifier; // 0x44   //  68       0

// considerationAmount; // 0x64       // 100       97500000000000000

// offerer; // 0x84           // 132               0x36Ee7371c5D0FA379428321b9d531a1cf0a5cAE6

// zone; // 0xa4                      // 164       0x0000000000000000000000000000000000000000

// offerToken; // 0xc4                // 196       0xC36442b4a4522E871399CD717aBDD847Ab11FE88

// offerIdentifier; // 0xe4           // 228       37302

// offerAmount; // 0x104              // 260       1

// BasicOrderType basicOrderType; // 0x124 // 292  0

// startTime; // 0x144                // 324       1669015500

// endTime; // 0x164                  // 356       1678692300

// zoneHash; // 0x184                 // 388       0x0000000000000000000000000000000000000000000000000000000000000000

// salt; // 0x1a4                     // 420          24446860302761739304752683030156737591518664810215442929806115867313005146194  
  
// offererConduitKey; // 0x1c4        // 452       0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000

// fulfillerConduitKey; // 0x1e4      // 484       0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000

// totalOriginalAdditionalRecipients; // 0x204   // 516   ------> 1

// AdditionalRecipient[] additionalRecipients; // 0x224  // 548     2500000000000000,0x0000a26b00c1F0DF003000390027140000fAa719

// signature; // 0x244   0x0e5771bfa7fcade47fb429590494091aa8cbe082543b92202fc5128c084552801d63c9f888c41a36c400c11d830b2d571d9a99ad4eba80a83f53d4544a4aa9981c