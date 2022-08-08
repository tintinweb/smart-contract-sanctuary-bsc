/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

pragma solidity ^0.8.15;

contract Olympo{
    event AssinaturaRenovada(address cliente, uint256 timestamp);
    
    address payable private owner;
    string site     = "www.pegasussniper.com";
    string telegram = "https://t.me/pegasusst";
    string discord  = "https://discord.gg/EBxxjSDNWb";

    constructor(address _owner){
        owner = payable(_owner);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function newOwner(address _newOwner) onlyOwner external {
        owner = payable(_newOwner);
    }

    function claimBeans() onlyOwner external{
        uint256 balance = address(this).balance;
        owner.transfer(balance);
    }

    function getOwner() view external returns(address){
        return owner;
    }

    function getTime(address _cliente) view external returns(uint256){

    }

    function renewTime(uint256 _time) external{
    
    }

}