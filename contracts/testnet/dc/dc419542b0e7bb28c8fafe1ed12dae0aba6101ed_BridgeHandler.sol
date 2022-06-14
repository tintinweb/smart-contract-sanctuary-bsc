/**
 *Submitted for verification at BscScan.com on 2022-06-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IERC20 {
    function mint(address _address, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC721 {
    function mint(address _address, uint256 _tokenId) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external returns (bool);
}

contract BridgeHandler{
  bool public pause;
  address public bridge;
  address public owner;
  mapping (address => bool) public supportedToken;
  mapping (address => bool) public supportedNFT;
  address private burnAddress = 0x000000000000000000000000000000000000dEaD;

  event _bridgeToken(address indexed to, address indexed from, uint256 amount);
  event _bridgeNFT(address indexed to, address indexed from, uint256 tokenId);

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
  function setSupportedToken(address _address) external whenNotPaused {
    supportedToken[_address] = true;
  }
  function setsupportedNFT(address _address) external whenNotPaused {
    supportedNFT[_address] = true;
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
  function bridgeToken (address _address, uint256 _amount) external whenNotPaused{
    require(supportedToken[_address] , "Contract not Supported");
    require(IERC20(_address).transferFrom(msg.sender, burnAddress, _amount));
    emit _bridgeToken(msg.sender, _address, _amount);
  }
  function bridgeNFT (address _address, uint256 _tokenId) external whenNotPaused{
    require(supportedNFT[_address] , "Contract not Supported");
    require(IERC721(_address).transferFrom(msg.sender, burnAddress, _tokenId));
    emit _bridgeNFT(msg.sender, _address, _tokenId);
  }
  function bridgeXana (address _address, uint256 _amount) external onlyBridge whenNotPaused{
    require(IERC20(_address).mint( _address, _amount));
  }
  function bridgeXanaNFT (address _address,  uint256 _tokenId) external onlyBridge whenNotPaused{
    require(IERC721(_address).mint( _address, _tokenId));
  }
}