/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

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
    address private anycallcontractbnb=0xcBd52F7E99eeFd9cD281Ea84f3D903906BB677EC
;


    address private owneraddress=0xb042D589af31C8a3eF48DBF361fAb55444e37d86;

    // Destination contract on Polygon
    address private receivercontract=0x05E8A83FDF8DCDFA7DE80aFaC10600BAec950C12;
    
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
            5,

            // Using 0 flag to pay fee on destination chain
            0
            );
            
        }

    }
}