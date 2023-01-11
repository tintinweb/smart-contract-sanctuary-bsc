/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Managed {
  mapping(address => bool) public managers;
  modifier onlyManagers() {
    require(managers[msg.sender] == true, "Caller is not manager");
    _;
  }
  constructor() {
    managers[msg.sender] = true;
  }
  function setManager(address _wallet, bool _manager) public onlyManagers {
    require(_wallet != msg.sender, "Not allowed");
    managers[_wallet] = _manager;
  }
}

interface INFTBridgeLog {
  function outgoing(address _wallet, uint256 _assetId, uint256 _chainID, uint256 _bridgeIndex) external;
  function incoming(address _wallet, uint256 _assetId, uint256 _chainID, uint256 _logIndex, bytes32 txHash, bool _minted) external;
}

interface INFT3D {
  function getTokenDetails(uint256 index) external view returns (uint32 aType, uint32 customDetails, uint32 lastTx, uint32 lastPayment, uint256 initialvalue, uint32 upgrades, uint32 gDetails, bool leased);
  function mintBridge(address to, uint32 _assetType, uint256 _value, uint32 _customDetails, uint256 _ethChainIndex, uint32 _lastTrade, uint32 _lastPayment) external returns (bool success);
  function mintBridge(address to, uint32 _assetType, uint256 _value, uint32 _customDetails, uint32 _lastTrade, uint32 _lastPayment) external returns (bool success);
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
  function nextIndex() external view returns (uint256);
}

contract NFTBridgeTransfers is Managed {

  INFTBridgeLog logger;
  address public nftVault;
  INFT3D public NFTContract;
  uint256 public depositIndex;
  bool public paused;
  
  struct Deposit {
    address sender;
    uint256 assetId;
    uint256 value;
    uint32 lastTx;
    uint32 lastPayment;
    uint32 aType;
    uint32 customDetails;
    uint32 upgrades;
    uint32 gDetails;
  } 
  
  mapping (uint256 => Deposit) public deposits;
  mapping (uint256 => bool) public chains;
  
  
  constructor() {
    NFTContract = INFT3D(0x364151EDBAC312C7a636CfA7996C3A2B6C2eC590);
    logger = INFTBridgeLog(0xb71949a8a2886B4f98791Ce9CF70dBdEb4bF749e);
    managers[0x00d6E1038564047244Ad37080E2d695924F8515B] = true;
    nftVault = 0xf7A9F6001ff8b499149569C54852226d719f2D76;
    chains[1] = true;
    chains[112358] = true;
    depositIndex = 1;
  }

  function bridgeSend(uint256 _assetId, uint256 _chainTo) public returns (bool) {
    require(!paused, "Contract is paused");
    require(chains[_chainTo] == true, "Invalid chain");
    (uint32 aType, uint32 customDetails, uint32 lastTx, uint32 lastPayment, uint256 initialvalue, uint32 upgrades, uint32 gDetails, ) = NFTContract.getTokenDetails(_assetId);
    Deposit memory _deposit = Deposit(msg.sender, _assetId, initialvalue, lastTx, lastPayment, aType, customDetails, upgrades, gDetails);
    NFTContract.safeTransferFrom(msg.sender, nftVault, _assetId);
    deposits[depositIndex] = _deposit;
    logger.outgoing(msg.sender, _assetId, _chainTo, depositIndex);
    depositIndex += 1;
    return true;
  }
  
  function pauseBridge(bool _paused) public onlyManagers {
    paused = _paused;
  }

  function setNFTVault(address _vault) public onlyManagers {
    nftVault = _vault;
  }

  function setChain(uint256 _chain, bool _available) public onlyManagers {
    chains[_chain] = _available;
  }

  function setLogger (address _logger) public onlyManagers {
    logger = INFTBridgeLog(_logger);
  }
    
}