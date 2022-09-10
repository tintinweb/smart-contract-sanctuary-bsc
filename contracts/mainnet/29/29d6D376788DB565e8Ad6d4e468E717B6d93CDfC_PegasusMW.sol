/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

pragma solidity ^0.8.16;

contract PegasusMW{
    mapping(address => bool) public allow;

    address payable public owner;
    constructor(){ 
        owner = payable(msg.sender); 
    }
    modifier onlyOwner() { require(msg.sender == owner); _; }

    function register(address _client, bool _status) onlyOwner external{
        allow[_client] = _status;
    }

    function open() external view returns(bool){
        return allow[msg.sender];
    }
}