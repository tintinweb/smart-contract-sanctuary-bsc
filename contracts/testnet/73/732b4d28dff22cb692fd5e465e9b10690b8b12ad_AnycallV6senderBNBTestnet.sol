/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface CallProxy{
    function anyCall(
        address _to,
        bytes calldata _data,
        address _fallback,
        uint256 _toChainID,
        uint256 _flags

    ) external;
}

  

contract AnycallV6senderBNBTestnet{

    // The Multichain anycall contract on bnb mainnet
    address private anycallcontract= 0x37414a8662bC1D25be3ee51Fb27C2686e2490A89; 


    address private owneraddress= 0x87ceC7c894fDBF4D6D6A094BC74048241C8f9909;

    // Destination contract on Polygon
    address private receivercontract= 0x63c3Ec56e3F430A7fdE5bcFB8Ba3711bC065e472;
    
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
        CallProxy(anycallcontract).anyCall(
            receivercontract,

            // sending the encoded bytes of the string msg and decode on the destination chain
            abi.encode("function anyExecuteTest(bytes memory _data)",_msg),

            // 0x as fallback address because we don't have a fallback function
            address(0),

            // chainid of recieveraddress
            4,

            // Using 0 flag to pay fee on destination chain
            0
            );
            
        }

    }
}