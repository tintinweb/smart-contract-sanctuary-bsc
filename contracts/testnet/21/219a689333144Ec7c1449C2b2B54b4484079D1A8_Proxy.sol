/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

pragma solidity >=0.6.0 <0.8.0;


contract Proxy {
    address public to;

    constructor(address _to) public {
        to = _to;
    }

    function setAmount(uint256 _newAmount) public {
        (bool success, bytes memory data) = to.delegatecall(
            abi.encodeWithSignature('setAmount(uint256)', _newAmount)
        );
    }


}