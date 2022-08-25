// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./AccessControl.sol";
import "./ERC20Burnable.sol";

contract InfinityVault is AccessControl {
  

  bytes32 public constant PACKAGE_MANAGER = keccak256("PACKAGE_MANAGER");
  bytes32 public constant MANAGER = keccak256("MANAGER");
  ERC20Burnable public token;

  uint256 public depositSerialId;

  uint32 private minAmount;

  uint32 private maxAmount;

  uint256 private price;

  mapping(address => uint256[]) private depositsByAddress;



  modifier onlyManager() {
    require(
      hasRole(MANAGER, _msgSender()) || hasRole(PACKAGE_MANAGER, _msgSender()),
      "Unauthorized access"
    );
    _;
  }

  constructor(address addressToken, address manager) {
    token = ERC20Burnable(addressToken);
    _setupRole(DEFAULT_ADMIN_ROLE, manager);
    _setupRole(MANAGER, manager);
    _setupRole(PACKAGE_MANAGER, manager);
  }

  
  function getMinAmount() external view returns (uint32) {
    return minAmount;
  }

  function getMaxAmount() external view returns (uint32) {
    return maxAmount;
  }

  function getPrice() external view returns (uint256) {
    return price;
  }


  function setMinAmount(uint32 minAmountx) external onlyManager {
    minAmount = minAmountx;
  }


  function setMaxAmount(uint32 maxAmountx) external onlyManager {
    maxAmount = maxAmountx;
  }

  function setPrice(uint256 pricex) external onlyManager {
    price = pricex;
  }
  
  function getDepositsByAddress(address _address) external view returns (uint256[] memory) {
    return depositsByAddress[_address];
  }

  function deposit(uint256 amount) external returns (uint256 id) {

    require(amount % price == 0, "Insufficient price");
    require(minAmount <= (amount % price), "Insufficient minAmount");
    require(maxAmount >= (amount % price), "Insufficient maxAmount");

    id = ++depositSerialId;

    require(
      token.transferFrom(_msgSender(), address(this), amount),
      "Transfer failed"
    );
    
    depositsByAddress[address(this)].push(id);

    return id;
  }

  

}