/**
 *Submitted for verification at BscScan.com on 2023-01-11
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
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
  function nextIndex() external view returns (uint256);
  function setGameDetails(uint256 _assetId, uint32 _gDetails) external;
  function setUpgrades(uint256 _assetId, uint32 _upgrades) external;
  function fixAssetBridgeTradeDate(uint256 _assetId, uint32 _lastTrade, uint32 _lastPayment) external;
}

library ECDSA {
  function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;
    if (signature.length == 65) {
      // solhint-disable-next-line no-inline-assembly
      assembly {
        r := mload(add(signature, 0x20))
        s := mload(add(signature, 0x40))
        v := byte(0, mload(add(signature, 0x60)))
      }
    } else if (signature.length == 64) {
      // solhint-disable-next-line no-inline-assembly
      assembly {
        let vs := mload(add(signature, 0x40))
        r := mload(add(signature, 0x20))
        s := and(
          vs,
          0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        )
        v := add(shr(255, vs), 27)
      }
    } else {
      revert("ECDSA: invalid signature length");
    }

    return recover(hash, v, r, s);
  }

  function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
    require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
    require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

    // If the signature is valid (and not malleable), return the signer address
    address signer = ecrecover(hash, v, r, s);
    require(signer != address(0), "ECDSA: invalid signature");
    return signer;
  }

  function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
  }

  function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
  }
}

contract NFTBridgeMinter is Managed {
  INFTBridgeLog logger;
  INFT3D public NFTContract;
  uint256 public depositIndex;
  address public NFTVault;
  
  address signer;
  uint256 chainID;
  bool public paused;

  constructor() {
    NFTContract = INFT3D(0x364151EDBAC312C7a636CfA7996C3A2B6C2eC590);
    logger = INFTBridgeLog(0xb71949a8a2886B4f98791Ce9CF70dBdEb4bF749e);
    NFTVault = 0xf7A9F6001ff8b499149569C54852226d719f2D76;
    chainID = 56;
    signer = 0xa4C03a9B4f1c67aC645A990DDB7B8A27D4D9e7af;
    managers[0x00d6E1038564047244Ad37080E2d695924F8515B] = true;
  }

  function verifyTXCall(bytes32 _taskHash, bytes memory _sig) public view returns (bool valid) {
    address mSigner = ECDSA.recover(ECDSA.toEthSignedMessageHash(_taskHash), _sig);
    if (mSigner == signer) {
      return true;
    } else {
      return false;
    }
  }

  function withdrawclone(address _wallet, uint256 _cloneId, uint32 _lastTrade, uint32 _lastPayment, uint32 _upgrades, uint32 _gameDetails, uint256 _chainFrom, uint256 _chainTo, uint256 _logIndex, bytes memory _sig) public {
    require(!paused, "Contract is paused");
    require(_chainTo == chainID, "Invalid chain");
    bytes32 txHash = keccak256(abi.encode(_wallet, _cloneId, _lastTrade, _lastPayment, _upgrades, _gameDetails, _chainFrom, _chainTo, _logIndex));
    bool txv = verifyTXCall(txHash, _sig);
    require (txv == true, "Invalid signature");
    logger.incoming(_wallet, _cloneId, _chainFrom, _logIndex, txHash, false);
    updateAndTransfer(_wallet, _cloneId, _upgrades, _gameDetails, _lastTrade, _lastPayment);
  }

  function updateAndTransfer(address _wallet, uint256 _cloneId, uint32 _upgrades, uint32 _gameDetails, uint32 _lastTrade, uint32 _lastPayment) private {
    NFTContract.setUpgrades(_cloneId, _upgrades);
    NFTContract.setGameDetails(_cloneId, _gameDetails);
    NFTContract.fixAssetBridgeTradeDate(_cloneId, _lastTrade, _lastPayment);
    NFTContract.safeTransferFrom(NFTVault, _wallet, _cloneId);
  }

  function withdraw(address _wallet, uint32 _assetType, uint256 _value, uint32 _customDetails, uint32 _lastTrade, uint32 _lastPayment, uint32 _upgrades, uint32 _gameDetails, uint256 _chainFrom, uint256 _chainTo, uint256 _logIndex, bytes memory _sig) public {
    require(!paused, "Contract is paused");
    require(_chainTo == chainID, "Invalid chain");
    bytes32 txHash = keccak256(abi.encode(_wallet, _assetType, _value, _customDetails, _lastTrade, _lastPayment, _upgrades, _gameDetails, _chainFrom, _chainTo, _logIndex));
    require (verifyTXCall(txHash, _sig) == true, "Invalid signature");
    logger.incoming(_wallet, NFTContract.nextIndex(), _chainFrom, _logIndex, txHash, true);
    require(NFTContract.mintBridge(_wallet, _assetType, _value, _customDetails, 0, _lastTrade, _lastPayment), "Mint fail");
  }

  function setLogger (address _logger) public onlyManagers {
    logger = INFTBridgeLog(_logger);
  }
  
  function setSigner (address _signer) public onlyManagers {
    signer = _signer;
  }

  function setNFTVault (address _vault) public onlyManagers {
    NFTVault = _vault;
  }

  function pauseContract(bool _paused) public onlyManagers {
    paused = _paused;
  }
}