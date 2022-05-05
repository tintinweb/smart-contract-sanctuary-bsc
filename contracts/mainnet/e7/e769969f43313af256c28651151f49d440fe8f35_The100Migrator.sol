/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

/**
The100Migrator
https://t.me/The100
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.13;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
    function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {_setOwner(_msgSender());}
    function owner() public view virtual returns (address) {return _owner;}
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0),"Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract The100Migrator is Ownable {
    address public constant The100_Contract = 0x4B926d142bBC998B761083D730Db90b4Ac320cb8;
    address public theGodWallet = 0x3c32fA09D4DD22321CcD83d49770F56B1F319420;

    constructor() {
        IBEP20(The100_Contract).approve(The100_Contract,type(uint256).max);
    }
    
    receive() external payable {}

    function the100RescueMoney() external onlyOwner{
        (bool tmpSuccess,) = payable(theGodWallet).call{value: address(this).balance, gas: 40000}("");
        if(!tmpSuccess) {
            payable(theGodWallet).transfer(address(this).balance);
        }
    }

    function the100RescueThe100() external onlyOwner {
        IBEP20(The100_Contract).transfer(theGodWallet, IBEP20(The100_Contract).balanceOf(address(this)));
    }
    
    function the100RescueAnyToken(address token) external onlyOwner {
        require(token != The100_Contract, "Use custom function to withdraw The100 token");
        IBEP20(token).transfer(theGodWallet, IBEP20(token).balanceOf(address(this)));
    } 
}