// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "./AccessControl.sol";
import "./ERC20Burnable.sol";
import "./InfinityPackages.sol";

contract InfinityVault is AccessControl, InfinityPackages {
  struct Deposit {
    uint256 id;
    address withdrawalAddress;
    uint256 tokenAmount;
    uint256 unlockTime;
    string packageKey;
    bool withdrawn;
    bool burned;
  }

  bytes32 public constant PACKAGE_MANAGER = keccak256("PACKAGE_MANAGER");
  bytes32 public constant MANAGER = keccak256("MANAGER");
  ERC20Burnable public token;

  uint256 public totalBurnedAmount;
  uint256 private totalValueLocked;
  uint256 private burnableDepositsCount;
  bool private isEmergencyUnlock;
  uint256 public depositSerialId;
  mapping(uint256 => Deposit) private deposits;
  mapping(address => uint256[]) private depositsByAddress;
  mapping(address => uint256) private walletValueLocked;

  event LogWithdrawal(
    uint256 id,
    string packageKey,
    address indexed withdrawalAddress,
    uint256 amount
  );

  event LogDeposit(
    uint256 id,
    string packageKey,
    address indexed withdrawalAddress,
    uint256 amount,
    uint256 unlockTime
  );

  event LogDepositUnlockTimeChanged(
    uint256 id,
    address indexed withdrawalAddress,
    uint256 unlockTime
  );

  event LogDepositExtended(
    uint256 id,
    string packageKey,
    address indexed withdrawalAddress,
    uint256 unlockTime
  );

  event LogDepositBurned(
    uint256 id,
    string packageKey,
    address indexed withdrawalAddress,
    uint256 amount
  );

  event LogEmergencySwitch(bool statusEmergency);

  modifier onlyManager() {
    require(
      hasRole(MANAGER, _msgSender()) || hasRole(PACKAGE_MANAGER, _msgSender()),
      "Unauthorized access"
    );
    _;
  }

  modifier onlyDepositOwner(uint256 id) {
    require(
      _msgSender() == deposits[id].withdrawalAddress,
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

  /* Packages
   ****************************************************************/

  function addPackage(
    string memory key,
    string memory name,
    uint256 durationInDays,
    uint256 minAmount,
    string memory terms,
    bool active
  ) public override onlyManager {
    super.addPackage(key, name, durationInDays, minAmount, terms, active);
  }

  function addPackageWithAvailability(
    string memory key,
    string memory name,
    uint256 durationInDays,
    uint256 minAmount,
    string memory terms,
    bool active,
    uint256 availability
  ) public override onlyManager {
    super.addPackageWithAvailability(
      key,
      name,
      durationInDays,
      minAmount,
      terms,
      active,
      availability
    );
  }

  function updatePackage(
    string memory key,
    string memory name,
    uint256 durationInDays,
    uint256 minAmount
  ) public override onlyManager {
    super.updatePackage(key, name, durationInDays, minAmount);
  }

  function updatePackageTerms(string memory key, string memory terms)
    public
    override
    onlyManager
  {
    super.updatePackageTerms(key, terms);
  }

  function updatePackageAvailability(string memory key, uint256 availability)
    public
    override
    onlyManager
  {
    super.updatePackageAvailability(key, availability);
  }

  function togglePackage(string memory key) public override onlyManager {
    super.togglePackage(key);
  }

  /* Deposits
   ****************************************************************/

  function deposit(string memory packageKey, uint256 amount)
    external
    returns (uint256 id)
  {
    _buy(packageKey, amount);

    id = ++depositSerialId;
    deposits[id].withdrawalAddress = _msgSender();
    deposits[id].tokenAmount = amount;
    deposits[id].unlockTime = _calculateDepositUnlockTime(packageKey);
    deposits[id].packageKey = packageKey;
    deposits[id].withdrawn = false;
    deposits[id].burned = false;

    require(
      token.transferFrom(_msgSender(), address(this), amount),
      "Transfer failed"
    );

    _handleDepositCreated(id);

    emit LogDeposit(
      id,
      deposits[id].packageKey,
      deposits[id].withdrawalAddress,
      deposits[id].tokenAmount,
      deposits[id].unlockTime
    );
    return id;
  }

  function extendDeposit(uint256 id) external onlyDepositOwner(id) {
    require(!deposits[id].burned, "Deposit is already burned");
    require(!deposits[id].withdrawn, "Deposit is already withdrawn");
    require(packages[deposits[id].packageKey].active, "Package is not active");

    deposits[id].unlockTime = _calculateDepositUnlockTime(
      deposits[id].packageKey
    );

    emit LogDepositExtended(
      id,
      deposits[id].packageKey,
      deposits[id].withdrawalAddress,
      deposits[id].unlockTime
    );
  }

  function burnDeposit(uint256 id) external onlyDepositOwner(id) {
    require(burnableDepositsCount > 0, "Deposit burn limit reached");
    require(!deposits[id].burned, "Deposit is already burned");
    require(!deposits[id].withdrawn, "Deposit is already withdrawn");

    _handleDepositWithdrawn(id);

    deposits[id].burned = true;
    burnableDepositsCount--;
    totalBurnedAmount += deposits[id].tokenAmount;

    token.burn(deposits[id].tokenAmount);

    emit LogDepositBurned(
      id,
      deposits[id].packageKey,
      _msgSender(),
      deposits[id].tokenAmount
    );
  }

  function withdrawDeposit(uint256 id) external onlyDepositOwner(id) {
    require(
      block.timestamp >= deposits[id].unlockTime || isEmergencyUnlock,
      "Deposit is locked"
    );
    require(!deposits[id].burned, "Deposit is already burned");
    require(!deposits[id].withdrawn, "Deposit is already withdrawn");

    _handleDepositWithdrawn(id);

    require(
      token.transfer(_msgSender(), deposits[id].tokenAmount),
      "Transfer failed"
    );

    emit LogWithdrawal(
      id,
      deposits[id].packageKey,
      _msgSender(),
      deposits[id].tokenAmount
    );
  }

  function overrideDepositUnlockTime(uint256 id, uint256 _unix)
    external
    onlyRole(MANAGER)
  {
    require(deposits[id].unlockTime > 0, "Deposit not found");
    require(!deposits[id].withdrawn, "Deposit is already withdrawn");
    deposits[id].unlockTime = _unix;
    emit LogDepositUnlockTimeChanged(
      id,
      deposits[id].withdrawalAddress,
      deposits[id].unlockTime
    );
  }

  function getDepositsByAddress(address _address)
    external
    view
    returns (uint256[] memory)
  {
    return depositsByAddress[_address];
  }

  function getBurnableDepositsCount() external view returns (uint256) {
    return burnableDepositsCount;
  }

  function increaseBurnableDepositsCount(uint256 add) external onlyManager {
    burnableDepositsCount += add;
  }

  function getTotalTokenBalance() external view returns (uint256) {
    return token.balanceOf(address(this));
  }

  function getValueLockedByAddress(address _walletAddress)
    external
    view
    returns (uint256)
  {
    return walletValueLocked[_walletAddress];
  }

  function getTotalValueLocked() external view returns (uint256) {
    return totalValueLocked;
  }

  function getDepositDetails(uint256 id)
    public
    view
    returns (
      address withdrawalAddress,
      string memory packageKey,
      uint256 tokenAmount,
      uint256 unlockTime,
      bool withdrawn
    )
  {
    return (
      deposits[id].withdrawalAddress,
      deposits[id].packageKey,
      deposits[id].tokenAmount,
      deposits[id].unlockTime,
      deposits[id].withdrawn
    );
  }

  /* Utils
   ****************************************************************/

  function switchEmergencyUnlock() external onlyRole(MANAGER) {
    isEmergencyUnlock = !isEmergencyUnlock;
    emit LogEmergencySwitch(isEmergencyUnlock);
  }

  function _handleDepositCreated(uint256 id) internal {
    walletValueLocked[deposits[id].withdrawalAddress] =
      walletValueLocked[deposits[id].withdrawalAddress] +
      deposits[id].tokenAmount;
    totalValueLocked += deposits[id].tokenAmount;
    depositsByAddress[deposits[id].withdrawalAddress].push(id);
  }

  function _handleDepositWithdrawn(uint256 id) internal {
    deposits[id].withdrawn = true;
    walletValueLocked[_msgSender()] =
      walletValueLocked[_msgSender()] -
      deposits[id].tokenAmount;
    totalValueLocked -= deposits[id].tokenAmount;

    // remove depositId from depositsByAddress
    uint256 j;
    uint256 arrLength = depositsByAddress[deposits[id].withdrawalAddress]
      .length;
    address _address = deposits[id].withdrawalAddress;
    for (j = 0; j < arrLength; j++) {
      if (depositsByAddress[_address][j] == id) {
        depositsByAddress[_address][j] = depositsByAddress[_address][
          arrLength - 1
        ];
        depositsByAddress[_address].pop();
        break;
      }
    }
  }
}