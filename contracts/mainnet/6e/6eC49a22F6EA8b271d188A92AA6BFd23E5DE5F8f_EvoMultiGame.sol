/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

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


interface IController 
{

    /// ERC20 
    function transfer(address owner, address recipient, uint amount) external returns (bool);
    function approve(address owner,address spender, uint amount) external returns (bool);

    //// USER
    function register(address user, uint referlaId) external;
    function updateStatus(address acc)  external;

    //// Deposite
    function deposite (address user,uint amount)external returns(bool);
    function withdrawProfit(address user) external;
    function withdrawAll(address user) external;
    function reinvest(address user) external;

    /// unfrozen
    function setUnfrozenUser(address user) external;
    //// API
    function destroyToken(address acc, uint amount) external ;
    function addTokenforCoin(address acc, uint amount) external;
    function burn(uint amount) external;
    //// Presale
    function pay(address acc, uint amount) external returns(bool, uint,uint);
}

contract EvoMultiGame is OwnableV2
{
    IController controller;
    
   constructor (address contr)
   {
       controller = IController(contr);
   }

/// USER
    function register(uint refId) public
    {
        controller.register(msg.sender, refId);
    }
    function updateStatus(address acc) public
    {
        controller.updateStatus(acc);
    }
///

/// Deposite
    function deposite (uint amount) public returns(bool)
    {
        return controller.deposite(msg.sender, amount);
    }
    function withdrawProfit()  public 
    {
        controller.withdrawProfit(msg.sender);
    }
    function withdrawAll()  public 
    {
        controller.withdrawAll(msg.sender);
    }
    function reinvest() public 
    {
        controller.reinvest(msg.sender);
    }
///

/// UNFROZEN
    function setUnfrozenUser() public 
    {
        controller.setUnfrozenUser(msg.sender);
    }
///
   
///


/// ADMIN

    function setController(address _Controller) onlyOwner public
    {
        controller = IController(_Controller);
    }
///
}