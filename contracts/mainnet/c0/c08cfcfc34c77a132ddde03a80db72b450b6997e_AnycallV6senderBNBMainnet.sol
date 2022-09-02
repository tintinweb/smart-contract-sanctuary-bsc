/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

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
    address private anycallcontractbnb=0xC10Ef9F491C9B59f936957026020C321651ac078;

    address private owneraddress=0xE44207bFF57FEE8918CC16708758DbE623468139;

    // Destination contract on Polygon
    address private receivercontract=0x28eaFD30F1B650e3a46B5CEa6FCd8c55dEAE0072;
    
    modifier onlyowner() {
        require(msg.sender == owneraddress, "only owner can call this method");
        _;
    }

    event NewMsg(string msg);

    function changereceivercontract(address newreceiver) external onlyowner {
        receivercontract=newreceiver;
    }

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
            250,

            // Using 0 flag to pay fee on destination chain
            0
            );
            
        }

    }
}