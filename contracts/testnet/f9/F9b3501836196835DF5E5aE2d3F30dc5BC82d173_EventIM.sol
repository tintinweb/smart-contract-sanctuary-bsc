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

contract EventIM {
    event NewMsg(string msg);
    bool public success;
    uint public count;
    string public lastMsg;
      constructor(){
    }

    function anyExecute(bytes memory _data) external returns (bool success, bytes memory result){
        (string memory _msg) = abi.decode(_data, (string));  
        emit NewMsg(_msg);
        count++;
        success=true;
        result=_data;
        lastMsg = _msg;
    }
}