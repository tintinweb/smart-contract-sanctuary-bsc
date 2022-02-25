// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "../libs/zeppelin/token/BEP20/IBEP20.sol";

interface IFOTAToken is IBEP20 {
  function releaseGameAllocation(address _gamerAddress, uint _amount) external returns (bool);
  function releasePrivateSaleAllocation(address _buyerAddress, uint _amount) external returns (bool);
  function releaseSeedSaleAllocation(address _buyerAddress, uint _amount) external returns (bool);
  function releaseStrategicSaleAllocation(address _buyerAddress, uint _amount) external returns (bool);
  function burn(uint _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract Auth is Initializable {

  address public mainAdmin;
  address public contractAdmin;

  event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);
  event ContractAdminUpdated(address indexed _newOwner);

  function initialize(address _mainAdmin) virtual public initializer {
    mainAdmin = _mainAdmin;
    contractAdmin = _mainAdmin;
  }

  modifier onlyMainAdmin() {
    require(_isMainAdmin(), "onlyMainAdmin");
    _;
  }

  modifier onlyContractAdmin() {
    require(_isContractAdmin() || _isMainAdmin(), "onlyContractAdmin");
    _;
  }

  function transferOwnership(address _newOwner) onlyMainAdmin external {
    require(_newOwner != address(0x0));
    mainAdmin = _newOwner;
    emit OwnershipTransferred(msg.sender, _newOwner);
  }

  function updateContractAdmin(address _newAdmin) onlyMainAdmin external {
    require(_newAdmin != address(0x0));
    contractAdmin = _newAdmin;
    emit ContractAdminUpdated(_newAdmin);
  }

  function _isMainAdmin() public view returns (bool) {
    return msg.sender == mainAdmin;
  }

  function _isContractAdmin() public view returns (bool) {
    return msg.sender == contractAdmin;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

library MerkleProof {
  function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
    bytes32 computedHash = leaf;
    for (uint256 i = 0; i < proof.length; i++) {
      bytes32 proofElement = proof[i];

      if (computedHash <= proofElement) {
        computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
      } else {
        computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
      }
    }
    return computedHash == root;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IBEP20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "../libs/fota/Auth.sol";
import "../libs/fota/MerkelProof.sol";
import "../libs/zeppelin/token/BEP20/IBEP20.sol";
import "../interfaces/IFOTAToken.sol";

contract IDO is Auth {

  struct Buyer {
    uint boughtAtBlock;
    uint lastClaimed;
    uint totalClaimed;
  }
  enum USDCurrency {
    busd,
    usdt
  }

  address public fundAdmin;
  bytes32 public rootHash;
  IFOTAToken public fotaToken;
  IBEP20 public busdToken;
  IBEP20 public usdtToken;
//  uint public constant blockInOneMonth = 864000; // 30 * 24 * 60 * 20
//  uint public constant blockInOneMonth = 200; // 30 * 24 * 60 * 20
  uint public constant blockInOneMonth = 200; // 30 * 24 * 60 * 20
  uint constant decimal3 = 1000;
  uint public remainingToken;
  uint public tgeRatio;
  uint public vestingTime;
  uint public startVestingBlock;
  uint public eachSlotAllocated;
  uint public price;
  bool public adminCanUpdateAllocation;
  mapping(address => Buyer) buyers;

  event Bought(address indexed buyer, uint amount, uint price, uint timestamp);
  event Claimed(address indexed buyer, uint amount, uint timestamp);
  event VestingStated(uint timestamp);

  function initialize(address _mainAdmin, address _fundAdmin, address _fotaToken) public initializer {
    Auth.initialize(_mainAdmin);
    fundAdmin = _fundAdmin;
    fotaToken = IFOTAToken(_fotaToken);
    remainingToken = 105e23;
    vestingTime = 5;
    tgeRatio = 20;
    eachSlotAllocated = 1176e18;
    price = 200;
    adminCanUpdateAllocation = true;
    busdToken = IBEP20(0xD8aD05ff852ae4EB264089c377501494EA1D03C9);
    usdtToken = IBEP20(0xF5ed09f4b0E89Dff27fe48AaDf559463505fbac4);
    rootHash = 0x673a79ecaed9ed602a27ce985b1da73cf54e07a9f9980a7af1cf7e8bdd941eac;
  }

  function setRootHash(bytes32 _rootHash) onlyMainAdmin external {
    rootHash = _rootHash;
  }

  function startVesting() onlyMainAdmin external {
    require(startVestingBlock == 0, "IDO: vesting had started");
    startVestingBlock = block.number;
    emit VestingStated(startVestingBlock);
  }

  function updateRemainingToken(uint _remainingToken) onlyMainAdmin external {
    remainingToken = _remainingToken;
  }

  function updateVestingTime(uint _month) onlyMainAdmin external {
    require(adminCanUpdateAllocation, "IDO: user had bought");
    vestingTime = _month;
  }

  function updateTGERatio(uint _ratio) onlyMainAdmin external {
    require(adminCanUpdateAllocation, "IDO: user had bought");
    require(_ratio < 100, "IDO: invalid ratio");
    tgeRatio = _ratio;
  }

  function updateFundAdmin(address _address) onlyMainAdmin external {
    require(_address != address(0), "IDO: invalid address");
    fundAdmin = _address;
  }

  function buy(USDCurrency _usdCurrency, bytes32[] calldata _path) external {
    Buyer storage buyer = buyers[msg.sender];
    _verifyBuyer(buyer, _path);
    require(remainingToken >= eachSlotAllocated, "IDO: sold out");
    remainingToken -= eachSlotAllocated;
    if (adminCanUpdateAllocation) {
      adminCanUpdateAllocation = false;
    }
    _takeFund(_usdCurrency, eachSlotAllocated * price / decimal3);
    buyer.boughtAtBlock = block.number;
    emit Bought(msg.sender, eachSlotAllocated, price, block.timestamp);
  }

  function claim() external {
    require(startVestingBlock > 0, "IDO: please wait more time");
    Buyer storage buyer = buyers[msg.sender];
    require(buyer.boughtAtBlock > 0, "IDO: You have no allocation");
    uint maxBlockNumber = startVestingBlock + blockInOneMonth * vestingTime;
    require(maxBlockNumber > buyer.lastClaimed, "IDO: your allocation had released");
    uint blockPass;
    uint releaseAmount;
    if (buyer.lastClaimed == 0) {
      buyer.lastClaimed = startVestingBlock;
      releaseAmount = eachSlotAllocated * tgeRatio / 100;
    } else {
      if (block.number < maxBlockNumber) {
        blockPass = block.number - buyer.lastClaimed;
        buyer.lastClaimed = block.number;
      } else {
        blockPass = maxBlockNumber - buyer.lastClaimed;
        buyer.lastClaimed = maxBlockNumber;
      }
      releaseAmount = eachSlotAllocated * (100 - tgeRatio) / 100 * blockPass / (blockInOneMonth * vestingTime);
    }
    buyer.totalClaimed = buyer.totalClaimed + releaseAmount;
    require(fotaToken.balanceOf(address(this)) >= releaseAmount, "IDO: contract is insufficient balance");
    require(fotaToken.transfer(msg.sender, releaseAmount), "IDO: transfer token failed");
    emit Claimed(msg.sender, releaseAmount, block.timestamp);
  }

  function getBuyer(address _address) external view returns (uint, uint, uint) {
    Buyer storage buyer = buyers[_address];
    return(
      buyer.boughtAtBlock,
      buyer.lastClaimed,
      buyer.totalClaimed
    );
  }

  function soldOut() external view returns (bool) {
    return remainingToken < eachSlotAllocated;
  }

  // PRIVATE FUNCTIONS

  function _verifyBuyer(Buyer storage _buyer, bytes32[] calldata _path) private view {
    require(_buyer.boughtAtBlock == 0, "IDO: You had bought");
    bytes32 hash = keccak256(abi.encodePacked(msg.sender));
    require(MerkleProof.verify(_path, rootHash, hash), 'IDO: 400');
  }

  function _takeFund(USDCurrency _usdCurrency, uint _amount) private {
    IBEP20 usdToken = _usdCurrency == USDCurrency.busd ? busdToken : usdtToken;
    require(usdToken.allowance(msg.sender, address(this)) >= _amount, "IDO: please approve usd token first");
    require(usdToken.balanceOf(msg.sender) >= _amount, "StrategicSale: please fund your account");
    require(usdToken.transferFrom(msg.sender, address(this), _amount), "IDO: transfer usd token failed");
    require(usdToken.transfer(fundAdmin, _amount), "IDO: transfer usd token failed");
  }

  // TODO for testing purpose
  function setContracts(address _busd, address _usdt) external onlyMainAdmin {
    busdToken = IBEP20(_busd);
    usdtToken = IBEP20(_usdt);
  }

  function verifyCode(address _user, bytes32[] calldata _path) external view {
    bytes32 hash = keccak256(abi.encodePacked(_user));
    require(MerkleProof.verify(_path, rootHash, hash), 'IDO: 400');
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}