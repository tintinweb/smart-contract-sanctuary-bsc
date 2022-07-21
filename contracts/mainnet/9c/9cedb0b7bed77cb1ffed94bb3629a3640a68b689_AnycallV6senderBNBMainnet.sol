/**
 *Submitted for verification at BscScan.com on 2022-07-21
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface CallProxy{
    function anyCall(
        address _to,
        bytes calldata _data,
        address _fallback,
        uint256 _toChainID,
        uint256 _flags

    ) external;
}
  

contract AnycallV6senderBNBMainnet{

    // The Multichain anycall contract on bnb mainnet
   address private anycallcontractbnb=0xFC23152E04D6039b796c91C9E2FaAaeDc704B33f;


    address private owneraddress=0x0479f45Ad2FAA065c7CC6789fE3F8719b498dB31;

    // Destination contract on Polygon
    address private receivercontract=0xF24e8239ABc84141bc278EDac5cd028F1aF8C943;
    
    event NewMsg(string msg);

    function step1_initiateAnyCallSimple(string calldata _msg) external {
        emit NewMsg(_msg);
        if (msg.sender == owneraddress){
        CallProxy(anycallcontractbnb).anyCall(
            receivercontract,

            // sending the encoded bytes of the string msg and decode on the destination chain
            abi.encode(_msg),

            // 0x as fallback address because we don't have a fallback function
            address(0),

            // chainid of polygon
            137,

            // Using 0 flag to pay fee on destination chain
            0
            );
            
        }

    }
}