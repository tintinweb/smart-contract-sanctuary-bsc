/**
 *Submitted for verification at BscScan.com on 2022-12-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.5;

contract Context {

  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
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

interface IRewardPool{
  function NewMintProfit(uint256 _token, uint _price) external;
}

contract Reward is  Context,  Pausable{

    string constant public Version = "STMREWARD V0.1.0";  

    address public token;
    address public poolAddr;
    address public dister;

//**********************query function******************************* */

/********************************internal function*********************************/

/*****************************************private function *****************************/

/*************************************public onlyOwner function**********************************/
    function SetContracts(address _token, address _poolAddr, address _dister) public onlyOwner {
        token = _token;
        poolAddr = _poolAddr;
        dister = _dister;
    }

    function WithdrawToken(address _token) public onlyOwner{
        IBEP20(_token).transfer(msg.sender,IBEP20(_token).balanceOf(address(this)));
    }   
/*********************************************public function for contract **************/

/*******************************************public function************************************ */
    function RewardProfit(uint256 _token, uint _price) whenNotPaused public { 
        require(msg.sender == dister, "only call by dister"); 
        IBEP20(token).approve(poolAddr, _token);
        IRewardPool(poolAddr).NewMintProfit(_token, _price * 100);   
    }
}