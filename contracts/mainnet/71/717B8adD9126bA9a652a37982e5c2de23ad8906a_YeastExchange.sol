/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

abstract contract IERC20 {


    function totalSupply() external view virtual returns (uint256);

    function balanceOf(address account) external view virtual returns (uint256);

    function allowance(address owner, address spender) external view virtual returns (uint256);


    function transfer(address recipient, uint256 amount) external virtual returns (bool);

    function approve(address spender, uint256 amount) external virtual returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external virtual returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract YeastExchange is Ownable {

   IERC20 public oldTokenInstance;
   IERC20 public newTokenInstance;

    address payable public devWallet = payable(0x3Bd09429Db51760471a5885018011Cbf4960b579);

    mapping(address => uint256) private _allowances;

  /*
    constructor function to set token address
   */
  constructor()  {

    //0xc18a2673bd28e65f6acd938d1e19bcd9b0b64cab
    oldTokenInstance = IERC20(0xc18A2673bD28e65f6Acd938D1e19BCd9B0b64CAB);
    newTokenInstance = IERC20(0xD1970c1E9B6b03A79d0097D66BED1F868E7128E0);
  
  }

  ///////////////////////////
// Frees locked tokens/BNB
/////////////////////////////

function disperseBalanceToAdmin() onlyOwner public {
   uint256 balance = address(this).balance;
   
   devWallet.transfer(balance);  
}

function disperseTokenBalanceToAdmin(address address_) onlyOwner public {
    IERC20 _token = IERC20(address_);

    _token.transfer(address(devWallet), _token.balanceOf(address(this)));

}

   function updateAllowances(address[] memory _recipients, uint[] memory _values) onlyOwner public {
         require(_recipients.length == _values.length);
         for (uint i = 0; i < _values.length; i++) {
             _allowances[_recipients[i]] = _values[i];
         }

   }

   function redeemTokens() public 
   {
       require(_allowances[msg.sender] > 0, "Yeast Exchange : Insufficient Balance");

        uint256 totalToSend = _allowances[msg.sender];
        _allowances[msg.sender] = 0;

        sendTokens(msg.sender, totalToSend);


   }

       function redeemTokenByAddress(address _add) public onlyOwner
   {
       require(_allowances[_add] > 0, "Yeast Exchange : Insufficient Balance");

        uint256 totalToSend = _allowances[_add];
        _allowances[_add] = 0;

        sendTokens(_add, totalToSend);


   }

    function setOldAddress(address _add) public onlyOwner
   {
      
        oldTokenInstance = IERC20(_add);


   }

   function setNewAddress(address _add) public onlyOwner
   {
      
        newTokenInstance = IERC20(_add);


   }



   function viewAllowance(address _add) public view returns (uint256)
   {
       return _allowances[_add];
   }

function sendTokens(address _to, uint256 _val) internal
{
    oldTokenInstance.transferFrom(_to, address(this), _val);
    newTokenInstance.transfer(_to, _val * (10**9));
}
 


 
}