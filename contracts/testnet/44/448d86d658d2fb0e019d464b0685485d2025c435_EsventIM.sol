/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

pragma solidity ^0.8.2;

interface CallProxy{
    function anyCall(
        address _to,
        bytes calldata _data,
        uint256 _toChainID,
        uint256 _flags,
        bytes calldata _extdata
    ) external payable;

    function context() external view returns (address from, uint256 fromChainID, uint256 nonce);
    
    function executor() external view returns (address executor);
}

contract EsventIM {
    event NewMsg(string msg);
    bool public success;
    string public result;
    address public anycallcontract;
      constructor(address _anycallcontract){
        anycallcontract=_anycallcontract;
    }
    
    function sendMessage(address receivercontract,string calldata _msg, uint destchain) payable external {
        emit NewMsg(_msg);
        CallProxy(anycallcontract).anyCall{value: msg.value}(receivercontract,abi.encode(_msg),destchain,0,"");
    }
    function anyExecute(bytes memory _data) external returns (bool success){
        (string memory _msg) = abi.decode(_data, (string));  
        emit NewMsg(_msg);
        success=true;
        result=_msg;
    }
}