/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IERC20 {
    function MINT(address to, uint256 value) external;
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract BridgeNativeToken{
  bool public pause;
  address public bridge;
  address public owner;
  mapping (address => bool) public supportedToken;
  address private burnAddress = 0x000000000000000000000000000000000000dEaD;

  event _bscToken(address indexed to, address indexed from, uint256 amount);
  event _captureXanaNativeToken(address indexed to, uint256 amount);

  constructor() {
    owner = msg.sender;
    bridge = msg.sender;
  }
  modifier onlyBridge() {
    require(msg.sender == bridge, "x");
    _;
  }
  modifier onlyOwner() {
    require(msg.sender == owner, "x");
    _;
  }
  modifier whenNotPaused(){
    require(pause == false, "xx");
    _;
  }
  function setBurnAddress(address _address) external whenNotPaused {
    burnAddress = _address;
  }
  function setSupportedToken(address _address) external whenNotPaused {
    supportedToken[_address] = true;
  }
  function setBridge(address _bridge) external onlyOwner whenNotPaused {
    bridge = _bridge;
  }
  function setQwner(address _address) external onlyOwner whenNotPaused {
    owner = _address;
  }
  function setPause(bool status) external onlyOwner {
    pause = status;
  }
  function bscToken (address _address, uint256 _amount) external whenNotPaused{
    require(supportedToken[_address] , "Contract not Supported");
    require(IERC20(_address).transferFrom(msg.sender, burnAddress, _amount));
    emit _bscToken(msg.sender, _address, _amount);
  }
  function sendXanaNativeToken (address _address, uint256 _amount) external onlyBridge whenNotPaused{
    (bool success, ) = _address.call{value: _amount}("");
    require(success, "Transfer failed");
  }
  function captureXanaNativeToken () external payable whenNotPaused{
    emit _captureXanaNativeToken(msg.sender, msg.value);
  }
  function sendBscToken (address _tokenAddress, address _address, uint256 _amount) external onlyBridge whenNotPaused{   
    IERC20(_tokenAddress).MINT( _address, _amount);
  }
}