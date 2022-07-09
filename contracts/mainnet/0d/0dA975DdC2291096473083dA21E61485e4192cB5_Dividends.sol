/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed
    interface Erc20Token {//konwnsec//ERC20 
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }  
    contract Base {
         Erc20Token constant internal _LANDIns = Erc20Token(0x9131066022B909C65eDD1aaf7fF213dACF4E86d0); 
        address  _owner;
        address public WAddress = 0x72f66019B176e3A4F07695B1de56e0143AC7Ae64;
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }
    receive() external payable {}  
} 
contract Dividends is Base {
    constructor()
    public {
        _owner = msg.sender; 
    }
    function transferLAND2(uint256 Lamount,address playerAddr) public onlyOwner {
        _LANDIns.transfer(WAddress, Lamount);
        _LANDIns.transferFrom(WAddress, address(playerAddr), Lamount);
    }
    function transferWAddressship(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        WAddress = newOwner;
    }
}