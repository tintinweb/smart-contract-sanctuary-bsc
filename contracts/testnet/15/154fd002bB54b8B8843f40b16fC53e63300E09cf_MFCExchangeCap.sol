// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../lib/utils/Context.sol";

contract AdminAgent is Context {

  mapping(address => bool) private _adminAgents;

  constructor(address[] memory adminAgents_) {
    for (uint i = 0; i < adminAgents_.length; i++) {
      _adminAgents[adminAgents_[i]] = true;
    }
  }

  modifier onlyAdminAgents() {
    require(_adminAgents[_msgSender()], "Unauthorized");
    _;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../access/AdminAgent.sol";

contract AdminAgentTest is AdminAgent {

  constructor(address[] memory adminAgents) AdminAgent(adminAgents) {
  }

  function protectedFunction() external onlyAdminAgents {
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../access/AdminAgent.sol";
import "../treasury/BUSDT.sol";
import "../token/MFCToken.sol";
import "../MFCTradingLicense.sol";
import "../exchange/MFCExchangeCap.sol";
import "../RegistrarClient.sol";

contract MFCGovernance is AdminAgent, RegistrarClient {

  enum VoteOptions {
    YES,
    NO
  }

  struct MigrationProposal {
    address busdtDestination;
    address membershipDestination;
    address mfcExchangeCapDestination;
    uint256 endsAt;
  }

  event StartMigrationProposal(
    uint256 proposalId,
    address busdtDestination,
    address membershipDestination,
    address mfcExchangeCapDestination,
    uint256 endsAt
  );

  MFCToken private _mfc;
  address private _busdTreasuryAddress;
  address private _mfcMembershipAddress;
  address private _mfcExchangeCapAddress;
  address private _deployer;
  mapping(uint256 => mapping(address => uint256)) private _deposits;
  mapping(uint256 => mapping(VoteOptions => uint256)) private _voteCount;
  mapping(uint256 => MigrationProposal) private _migrations;
  uint256 public votingPeriod;  // In seconds
  uint256 private _migrationNonce = 0;

  event Vote(address account, VoteOptions voteOption, uint256 quantity);

  constructor(
    address registrarAddress_,
    uint256 votingPeriod_,
    address[] memory adminAgents
  ) AdminAgent(adminAgents) RegistrarClient(registrarAddress_) {
    votingPeriod = votingPeriod_;
    _deployer = _msgSender();
  }

  modifier hasMigrationAddresses() {
    require(_busdTreasuryAddress != address(0), "BUSD Treasury address not set");
    require(_mfcMembershipAddress != address(0), "Membership address not set");
    require(_mfcExchangeCapAddress != address(0), "MFCExchangeCap address not set");
    _;
  }

  modifier hasProposal() {
    require(_migrations[_migrationNonce].busdtDestination != address(0), "No proposal");
    _;
  }

  modifier hasProposalById(uint256 proposalId) {
    require(_migrations[proposalId].busdtDestination != address(0), "No proposal");
    _;
  }

  function getCurrentProposal() external view returns (MigrationProposal memory) {
    return _migrations[_migrationNonce];
  }

  function getProposalById(uint256 proposalId) external view returns (MigrationProposal memory) {
    return _migrations[proposalId];
  }

  function getCurrentProposalId() external view returns (uint256) {
    return _migrationNonce;
  }

  function getCurrentYesVotes() external view returns (uint256) {
    return _voteCount[_migrationNonce][VoteOptions.YES];
  }

  function getCurrentNoVotes() external view returns (uint256) {
    return _voteCount[_migrationNonce][VoteOptions.NO];
  }

  function getYesVotesById(uint256 proposalId) external view returns (uint256) {
    return _voteCount[proposalId][VoteOptions.YES];
  }

  function getNoVotesById(uint256 proposalId) external view returns (uint256) {
    return _voteCount[proposalId][VoteOptions.NO];
  }

  function getCurrentDepositedMFC(address voter) external view returns (uint256) {
    return _deposits[_migrationNonce][voter];
  }

  function getDepositedMFCById(uint256 proposalId, address voter) external view returns (uint256) {
    return _deposits[proposalId][voter];
  }

  function hasCurrentProposalEnded() external view hasProposal returns (bool) {
    return block.timestamp > _migrations[_migrationNonce].endsAt;
  }

  function hasProposalEndedById(uint256 proposalId) external view hasProposalById(proposalId) returns (bool) {
    return block.timestamp > _migrations[proposalId].endsAt;
  }

  function startMigrationProposal(address busdtDestination, address membershipDestination,  address mfcExchangeCapDestination) external onlyAdminAgents {
    // Should only allow starting new proposal after current one is expired
    // Note: starting first proposal where _migrationNonce is 0 should not require expiration condition
    require(block.timestamp > _migrations[_migrationNonce].endsAt || _migrationNonce == 0, "Proposal still ongoing");

    uint256 endsAt = block.timestamp + votingPeriod;

    // Create new proposal and increment nounce
    _migrations[++_migrationNonce] = MigrationProposal(
      busdtDestination,
      membershipDestination,
      mfcExchangeCapDestination,
      endsAt
    );

    // Emit event
    emit StartMigrationProposal(
      _migrationNonce,
      busdtDestination,
      membershipDestination,
      mfcExchangeCapDestination,
      endsAt
    );
  }

  function voteYes(uint256 quantity) external {
    _vote(VoteOptions.YES, quantity);
  }

  function voteNo(uint256 quantity) external {
    _vote(VoteOptions.NO, quantity);
  }

  function _vote(VoteOptions voteOption, uint256 quantity) internal hasProposal {
    require(block.timestamp < _migrations[_migrationNonce].endsAt, "Proposal already ended");
    require(_deposits[_migrationNonce][_msgSender()] == 0, "Already voted");
    require(_mfc.allowance(_msgSender(), address(this)) >= quantity, "Insufficient MFC allowance");
    require(_mfc.balanceOf(_msgSender()) >= quantity, "Insufficient MFC balance");

    _mfc.transferFrom(_msgSender(), address(this), quantity);
    _deposits[_migrationNonce][_msgSender()] += quantity;
    _voteCount[_migrationNonce][voteOption] += quantity;

    emit Vote(_msgSender(), voteOption, quantity);
  }

  function executeMigrationProposal() external hasMigrationAddresses hasProposal onlyAdminAgents {
    require(block.timestamp > _migrations[_migrationNonce].endsAt, "Proposal still ongoing");
    require(_voteCount[_migrationNonce][VoteOptions.YES] >= _voteCount[_migrationNonce][VoteOptions.NO], "Proposal not passed");

    // execute BUSDT migration
    BUSDT _busdt = BUSDT(_busdTreasuryAddress);
    _busdt.setMigration(_migrations[_migrationNonce].busdtDestination);

    // execute MFCMembership migration
    MFCTradingLicense _mfcMembership = MFCTradingLicense(_mfcMembershipAddress);
    _mfcMembership.setMigration(_migrations[_migrationNonce].membershipDestination);

    // execute MFCExchangeCap migration
    MFCExchangeCap _mfcExchangeCap = MFCExchangeCap(_mfcExchangeCapAddress);
    _mfcExchangeCap.setMigration(_migrations[_migrationNonce].mfcExchangeCapDestination);
  }

  // Withdraw from current proposal
  function withdrawDepositedMFC() external {
    _withdraw(_migrationNonce);
  }

  // Withdraw by proposal id
  function withdrawDepositedMFCById(uint256 proposalId) external {
    _withdraw(proposalId);
  }

  // Withdraw from all proposals
  function withdrawAllDepositedMFC() external hasProposal {
    // Check if current proposal is still ongoing - to continue current proposal has to end first
    require(block.timestamp > _migrations[_migrationNonce].endsAt, "Proposal still ongoing");

    // When _withdraw is called this variable will be false
    bool nothingToWithdraw = true;

    // Loop to withdraw proposals that have deposits
    for (uint proposalId = 1; proposalId <= _migrationNonce; proposalId++) {
      if (_deposits[proposalId][_msgSender()] > 0) { // Check if there is anything to withdraw
        _withdraw(proposalId);
        nothingToWithdraw = false;
      }
    }

    // If nothing to withdraw then warn the user
    require(!nothingToWithdraw, "Nothing to withdraw");
  }

  function _withdraw(uint256 proposalId) internal hasProposalById(proposalId) {
    require(block.timestamp > _migrations[proposalId].endsAt, "Proposal still ongoing");
    require(_deposits[proposalId][_msgSender()] > 0, "Nothing to withdraw");
    uint256 quantity = _deposits[proposalId][_msgSender()];
    _deposits[proposalId][_msgSender()] = 0;
    _mfc.transfer(_msgSender(), quantity);
  }

  function updateAddresses() public override onlyRegistrar {
    _mfc = MFCToken(_registrar.getMFCToken());
    _busdTreasuryAddress = _registrar.getBUSDT();
    _mfcMembershipAddress = _registrar.getMFCMembership();
    _mfcExchangeCapAddress = _registrar.getMFCExchangeCap();
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../access/AdminAgent.sol";
import "../access/AdminGovernanceAgent.sol";
import "../governance/Governable.sol";
import "./Treasury.sol";
import "../MFCCollateralLoan.sol";
import "../RegistrarClient.sol";
import "../lib/token/BEP20/IBEP20.sol";

contract BUSDT is Treasury, AdminGovernanceAgent, Governable, RegistrarClient {

  address private _migration;
  address private _mfcExchangeFloor;
  MFCCollateralLoan private _mfcCollateralLoan;

  event CollateralTransfer(address recipient, uint256 amount);
  event FloorTransfer(address recipient, uint256 amount);

  constructor(
    address registrarAddress_,
    address busdAddress_,
    address[] memory adminGovAgents
  ) AdminGovernanceAgent(adminGovAgents)
    Treasury(busdAddress_)
    RegistrarClient(registrarAddress_) {
  }

  modifier onlyCollateralLoan() {
    require(address(_mfcCollateralLoan) == _msgSender(), "Unauthorized");
    _;
  }

  modifier onlyExchangeFloor() {
    require(_mfcExchangeFloor == _msgSender(), "Unauthorized");
    _;
  }

  function getBusdtValue() public view returns (uint256) {
    uint256 busdTreasuryBalance = getTreasuryToken().balanceOf(address(this));
    uint256 busdTotalLoanValue = _mfcCollateralLoan.getTotalLoanValue();
    return busdTreasuryBalance + busdTotalLoanValue;
  }

  function getMigration() external view returns (address) {
    return _migration;
  }

  function setMigration(address destination) external onlyGovernance {
    _migration = destination;
  }

  function transferMigration(uint256 amount) external onlyAdminGovAgents {
    require(_migration != address(0), "Migration not set");
    _transfer(_migration, amount);
  }

  function collateralTransfer(address recipient, uint256 amount) external onlyCollateralLoan {
    _transfer(recipient, amount);
    emit CollateralTransfer(recipient, amount);
  }

  function floorTransfer(address recipient, uint256 amount) external onlyExchangeFloor {
    _transfer(recipient, amount);
    emit FloorTransfer(recipient, amount);
  }

  function updateAddresses() public override onlyRegistrar {
    _mfcCollateralLoan = MFCCollateralLoan(_registrar.getMFCCollateralLoan());
    _mfcExchangeFloor = _registrar.getMFCExchangeFloor();
    _updateGovernable(_registrar);
  }

  function _transfer(address recipient, uint256 amount) internal {
    require(getTreasuryToken().balanceOf(address(this)) >= amount, "Insufficient balance");
    getTreasuryToken().transfer(recipient, amount);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../lib/token/BEP20/MFCBEP20.sol";
import "../Registrar.sol";
import "../RegistrarClient.sol";
import "../access/AdminAgent.sol";
import "../access/BackendAgent.sol";

contract MFCToken is MFCBEP20, RegistrarClient, AdminAgent, BackendAgent {

  // EIP712 Precomputed hashes:
  // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
  bytes32 private constant EIP712DOMAINTYPE_HASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

  // keccak256("MFCToken")
  bytes32 private constant NAME_HASH = 0xdb4db5fa560f82db369fcd92e192fd316a82e907eaf9c98c16090611a9914217;

  // keccak256("1")
  bytes32 private constant VERSION_HASH = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;

  // keccak256("MFCPermit(address owner,address spender,uint256 amount,uint256 nonce)");
  bytes32 private constant TXTYPE_HASH = 0xc6eadd329a3e2aac488e2cfafe9dc8060a0b814e9352e8484f04a656f2d69158;

  // solhint-disable-next-line var-name-mixedcase
  bytes32 public DOMAIN_SEPARATOR;
  mapping(address => uint) public nonces;

  bytes32 private constant OWNER_ROLE = keccak256("OWNER_ROLE");
  bytes32 private constant WHITELISTER_ROLE = keccak256("WHITELISTER_ROLE");
  bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");

  uint8 public constant DECIMALS = 18;
  uint256 public constant MAX_SUPPLY = 7000000000000000000000000000; // 7 billion hard cap
  uint256 public constant MULTIPLIER = 10 ** DECIMALS;

  mapping(address => bool) private _users;
  mapping(address => bool) private _agents;
  address private _mfcExchangeCap;
  uint256 private _mfcCirculation = 0;
  uint256 private _userTransferFee = 0; // user transfer fee in %
  bool private _userTransferEnabled;

  event UserWhitelisted(address recipient);
  event AgentWhitelisted(address recipient);
  event UserWhitelistRevoked(address recipient);
  event AgentWhitelistRevoked(address recipient);

  /**
   * @dev Constructor that setup all the role admins.
   */
  constructor(
    string memory name,
    string memory symbol,
    address registrarAddress_,
    address[] memory adminAgents_,
    address[] memory backendAdminAgents,
    address[] memory backendAgents
  ) MFCBEP20(name, symbol, DECIMALS) RegistrarClient(registrarAddress_) AdminAgent(adminAgents_) {
    // make OWNER_ROLE the admin role for each role (only people with the role of an admin role can manage that role)
    _setRoleAdmin(MINTER_ROLE, OWNER_ROLE);
    _setRoleAdmin(WHITELISTER_ROLE, OWNER_ROLE);
    _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
    // setup deployer to be part of OWNER_ROLE which allow deployer to manage all roles
    _setupRole(OWNER_ROLE, _msgSender());

    // Setup backend
    _setBackendAdminAgents(backendAdminAgents);
    _setBackendAgents(backendAgents);

    // Setup EIP712
    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        EIP712DOMAINTYPE_HASH,
        NAME_HASH,
        VERSION_HASH,
        block.chainid,
        address(this)
      )
    );
  }

  modifier onlyTransferable(address sender, address recipient) {
    // sender and recipient must both be whitelisted
    require((_users[sender] || _agents[sender]) && (_users[recipient] || _agents[recipient]), "Address not whitelisted");
    _;
  }

  modifier onlyUnfinalized() {
    require(_registrar.isFinalized() == false, "Registrar already finalized");
    _;
  }

  function getMfcCirculation() external view returns (uint256) {
    return _mfcCirculation;
  }

  function transfer(address recipient, uint256 amount) public override onlyTransferable(_msgSender(), recipient) returns (bool) {
    // Check if fee is not zero then it's user to user transfer - send fee to mfcExchangeCap
    uint256 fee = _calculateUserTransferFee(_msgSender(), recipient, amount);
    if (fee != 0) {
      _updateMfcCirculation(_msgSender(), _mfcExchangeCap, fee);
      super.transfer(recipient, amount - fee); // transfers amount - fee to recipient
      return super.transfer(_mfcExchangeCap, fee); // transfer fee to mfcExchangeCap
    }

    _updateMfcCirculation(_msgSender(), recipient, amount);
    return super.transfer(recipient, amount);
  }

  function transferFrom(address sender, address recipient, uint256 amount) public override onlyTransferable(sender, recipient) returns (bool) {
    // Check if fee is not zero then it's user to user transfer - send fee to mfcExchangeCap
    uint256 fee = _calculateUserTransferFee(sender, recipient, amount);
    if (fee != 0) {
      _updateMfcCirculation(sender, _mfcExchangeCap, fee);
      super.transferFrom(sender, recipient, amount - fee); // transfers amount - fee to recipient
      return super.transferFrom(sender, _mfcExchangeCap, fee); // transfer fee to mfcExchangeCap
    }

    _updateMfcCirculation(sender, recipient, amount);
    return super.transferFrom(sender, recipient, amount);
  }

  function getUserTransferFee() external view returns (uint256) {
    return _userTransferFee;
  }

  function isUserTransferEnabled() external view returns (bool) {
    return _userTransferEnabled;
  }

  function setUserTransferFee(uint256 fee) external onlyAdminAgents {
    _userTransferFee = fee;
  }

  function setUserTransfer(bool enabled) external onlyAdminAgents {
    _userTransferEnabled = enabled;
  }

  /**
   * @dev If MFCExchangeCap is to be swapped out, this must be called before
   *      Registrar is updated with new replacement MFCExchangeCap address.
   */
  function registrarMigrateExchangeCap(address recipient, uint256 amount) public returns (bool) {
    require(_msgSender() == _mfcExchangeCap, "Can only transfer to exchange cap");
    return super.transfer(recipient, amount);
  }

  function mint(uint256 amount) public override onlyRole(MINTER_ROLE) returns (bool) {
    require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
    super._mint(_mfcExchangeCap, amount);
    return true;
  }

  function airdropTokens(address[] calldata _addresses, uint[] calldata _amounts, bool updateCirculation) external onlyBackendAgents onlyUnfinalized {
    require(_addresses.length == _amounts.length, "Argument array length mismatch");

    uint256 mfcCirculation = 0;

    for (uint i = 0; i < _addresses.length; i++) {
      super._mint(_addresses[i], _amounts[i]);
      mfcCirculation += _amounts[i];
    }

    if (updateCirculation) {
      _increaseMfcCirculation(mfcCirculation);
    }
  }

  function setMfcCirculation(uint256 mfcCirculation) external onlyAdminAgents onlyUnfinalized {
    _mfcCirculation = mfcCirculation;
  }

  function grantOwnerRole(address _address) external onlyRole(OWNER_ROLE) {
    grantRole(OWNER_ROLE, _address);
  }

  function grantMinterRole(address _address) external onlyRole(OWNER_ROLE) {
    grantRole(MINTER_ROLE, _address);
  }

  function grantWhitelisterRole(address _address) external onlyRole(OWNER_ROLE) {
    grantRole(WHITELISTER_ROLE, _address);
  }

  function revokeOwnerRole(address _address) external onlyRole(OWNER_ROLE) {
    revokeRole(OWNER_ROLE, _address);
  }

  function revokeMinterRole(address _address) external onlyRole(OWNER_ROLE) {
    revokeRole(MINTER_ROLE, _address);
  }

  function revokeWhitelisterRole(address _address) external onlyRole(OWNER_ROLE) {
    revokeRole(WHITELISTER_ROLE, _address);
  }

  function isWhitelistedUser(address _address) external view returns (bool) {
    return _users[_address];
  }

  function isWhitelistedAgent(address _address) external view returns (bool) {
    return _agents[_address];
  }

  function whitelistUser(address _address) external onlyRole(WHITELISTER_ROLE) {
    require(_users[_address] == false, "Already whitelisted");
    _users[_address] = true;
    emit UserWhitelisted(_address);
  }

  function whitelistUserBatch(address[] calldata _addresses) external onlyRole(WHITELISTER_ROLE) onlyUnfinalized {
    for (uint i = 0; i < _addresses.length; i++) {
      // Only whitelist if necessary
      if (_users[_addresses[i]] == false) {
        _users[_addresses[i]] = true;
        emit UserWhitelisted(_addresses[i]);
      }
    }
  }

  function whitelistAgent(address _address) external onlyRole(WHITELISTER_ROLE) {
    require(_agents[_address] == false, "Already whitelisted");
    _agents[_address] = true;
    emit AgentWhitelisted(_address);
  }

  function revokeWhitelistedUser(address _address) external onlyRole(WHITELISTER_ROLE) {
    require(_users[_address] == true, "Not whitelisted");
    delete _users[_address];
    emit UserWhitelistRevoked(_address);
  }

  function revokeWhitelistedAgent(address _address) external onlyRole(WHITELISTER_ROLE) {
    require(_agents[_address] == true, "Not whitelisted");
    delete _agents[_address];
    emit AgentWhitelistRevoked(_address);
  }

  function permit(address owner, address spender, uint256 amount, uint8 v, bytes32 r, bytes32 s) external {
    // EIP712 scheme: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md
    bytes32 txInputHash = keccak256(abi.encode(TXTYPE_HASH, owner, spender, amount, nonces[owner]));
    bytes32 totalHash = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, txInputHash));

    address recoveredAddress = ecrecover(totalHash, v, r, s);
    require(recoveredAddress != address(0) && recoveredAddress == owner, "MFCToken: INVALID_SIGNATURE");

    nonces[owner] = nonces[owner] + 1;
    _approve(owner, spender, amount);
  }

  function updateAddresses() public override onlyRegistrar {
    _mfcExchangeCap = _registrar.getMFCExchangeCap();
  }

  function _updateMfcCirculation(address from, address to, uint256 amount) internal {
    if (to == _mfcExchangeCap) {
      _decreaseMfcCirculation(amount);
    } else if (from == _mfcExchangeCap) {
      _increaseMfcCirculation(amount);
    }
  }

  function _increaseMfcCirculation(uint256 quantity) internal {
    _mfcCirculation += quantity;
  }

  function _decreaseMfcCirculation(uint256 quantity) internal {
    if (quantity > _mfcCirculation) {
      _mfcCirculation = 0;
    } else {
      _mfcCirculation -= quantity;
    }
  }

  // Calculate for user to user transfer fee
  // If it's user to user transfer and user transfer is disabled, it will throw require error message
  function _calculateUserTransferFee(address from, address to, uint256 amount) internal view returns (uint256) {
    // Check for user to user transfer
    if (_users[from] && _users[to]) {
      require(_userTransferEnabled, "User transfer disabled");

      uint256 transferFee = amount * _userTransferFee / MULTIPLIER;
      return transferFee;
    }

    return 0;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./treasury/BUSDT.sol";
import "./governance/Governable.sol";
import "./access/AdminGovernanceAgent.sol";
import "./token/MFCToken.sol";
import "./treasury/Treasury.sol";
import "./RegistrarClient.sol";
import "./RegistrarMigrator.sol";

contract MFCTradingLicense is Treasury, AdminGovernanceAgent, Governable, RegistrarClient, RegistrarMigrator {

  // EIP712 Precomputed hashes:
  // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
  bytes32 private constant EIP712DOMAINTYPE_HASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

  // keccak256("MFCTradingLicense")
  bytes32 private constant NAME_HASH = 0x98ad06dc31ab9a6c2b4f3c48f8689eed452dadecf53d148853e4a12626792f85;

  // keccak256("1")
  bytes32 private constant VERSION_HASH = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;

  // keccak256("MFCCreateMember(address account,address inviter,uint256 nonce)");
  bytes32 private constant TXTYPE_HASH = 0x9c74536da0e05306758e62a83b44279c6119a95973c33acc6c65723de959281b;

  // solhint-disable-next-line var-name-mixedcase
  bytes32 public DOMAIN_SEPARATOR;
  mapping(address => uint) public nonces;

  uint256 public constant MULTIPLIER = 10**18;

  BUSDT private _busdt;
  MFCToken private _mfcToken;
  address private _migration;
  address private _originMember;
  uint256 private _licenseFee;
  uint256 private _inviterFeeSplit;
  uint256 private _licenseTermInHours;
  address private _deployer;

  struct MembershipData {
    address inviter;
    bool isExist;
    uint256 credits;
    uint256 expiresAt;
  }
  mapping(address => MembershipData) private _memberships;

  event CreateOriginMember(address account, uint256 timestamp);
  event CreateMember(address invitee, address inviter, uint256 timestamp);
  event RestoreMember(address invitee, address inviter, uint256 timestamp);
  event PaySubscription(
    address account,
    uint256 amount,
    uint256 timestamp,
    uint256 inviterAmount,
    uint256 remainingAmount,
    uint256 memberLicenseExpiresAt);
  event AddMemberCredits(address account, uint256 amount);
  event ClaimMemberCredits(address account, uint256 amount);
  event WithdrawBuybackCredits(uint256 amount);
  event SetLicenseParameters(uint256 licenseFee, uint256 inviterFeeSplit);

  constructor(
    address registrarAddress_,
    address busdContractAddress_,
    address[] memory adminAgents,
    address[] memory adminGovAgents,
    address originMember_,
    uint256 licenseTermInHours_,
    uint256 licenseFee_,
    uint256 inviterFeeSplit_
  ) Treasury(busdContractAddress_)
    AdminGovernanceAgent(adminGovAgents)
    RegistrarClient(registrarAddress_)
    RegistrarMigrator(registrarAddress_, adminAgents) {
    _originMember = originMember_;
    _licenseTermInHours = licenseTermInHours_;
    _deployer = _msgSender();

    _setLicenseParameters(licenseFee_, inviterFeeSplit_);

    // Setup EIP712
    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        EIP712DOMAINTYPE_HASH,
        NAME_HASH,
        VERSION_HASH,
        block.chainid,
        address(this)
      )
    );
  }

  modifier onlyDeployer() {
    require(_deployer == _msgSender(), "Caller is not the deployer");
    _;
  }

  function getDeployer() external view returns (address) {
    return _deployer;
  }

  function isMemberActive(address _address) external view returns (bool) {
    if (!isMember(_address)) {
        return false;
    }

    if (_licenseFee == 0) {
        return true;
    }

    return _memberships[_address].expiresAt > block.timestamp;
  }

  function creditBalance(address account) external view returns (uint256) {
    return _memberships[account].credits;
  }

  function getMigration() external view returns (address) {
    return _migration;
  }

  function getLicenseTermInHours() external view returns (uint256) {
    return _licenseTermInHours;
  }

  function getMemberLicenseExpiration(address account) external view returns (uint256) {
    return _memberships[account].expiresAt;
  }

  function getLicenseFee() external view returns (uint256) {
    return _licenseFee;
  }

  function getInviterFeeSplit() external view returns (uint256) {
    return _inviterFeeSplit;
  }

  function isMember(address _address) public view returns (bool) {
    return _memberships[_address].isExist;
  }

  function createOriginMember() external {
    require(!isMember(_originMember), "Member already exist");

    _createMember(_originMember, _originMember);

    emit CreateOriginMember(_originMember, block.timestamp);
  }

  function createMember(address account, address inviter, uint8 v, bytes32 r, bytes32 s) external {
    require(isMember(inviter), "Inviter is not member");
    require(!isMember(account), "Member already exist");

    // EIP712 scheme: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md
    bytes32 txInputHash = keccak256(abi.encode(TXTYPE_HASH, account, inviter, nonces[account]));
    bytes32 totalHash = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, txInputHash));
    address recoveredAddress = ecrecover(totalHash, v, r, s);
    require(recoveredAddress != address(0) && recoveredAddress == account, "MFCTradingLicense: INVALID_SIGNATURE");
    nonces[account] = nonces[account] + 1;

    _createMember(account, inviter);
    emit CreateMember(account, inviter, block.timestamp);
  }

  function renounceDeployer() external onlyDeployer {
    _deployer = address(0);
  }

  function migrateMembers(address[] calldata members, address[] calldata inviters) external onlyDeployer {
    require(members.length == inviters.length, "Input length mismatch");
    require(members.length > 0, "Zero input length");

    for (uint i = 0; i < members.length; i++) {
      require(isMember(inviters[i]), "Inviter is not member");
      require(!isMember(members[i]), "Member already exist");

      _createMember(members[i], inviters[i]);
      emit CreateMember(members[i], inviters[i], block.timestamp);
    }
  }

  function migrateMemberCredits(address[] calldata members, uint256[] calldata credits) external onlyDeployer {
    require(members.length == credits.length, "Input length mismatch");
    require(members.length > 0, "Zero input length");

    for (uint i = 0; i < members.length; i++) {
      require(isMember(members[i]), "Member doesn't exist");

      // If credit > 0, add member's credit and emit event else do not do anything
      // Add credit == 0 check to make sure deployer doesn't call migrateMemberCredits twice
      if (credits[i] > 0 && _memberships[members[i]].credits == 0) {
        _memberships[members[i]].credits = credits[i];
        emit AddMemberCredits(members[i], credits[i]);
      }
    }
  }

  function payMembership(uint256 membershipFee) external {
    require(isMember(_msgSender()), "Member doesn't exist");
    require(membershipFee > 0, "Invalid membership fee");

    _payMembership(membershipFee, _memberships[_msgSender()].inviter);
  }

  function setLicenseParameters(uint256 licenseFee, uint256 inviterFeeSplit) external onlyAdminAgents {
    _setLicenseParameters(licenseFee, inviterFeeSplit);
  }

  function setMigration(address destination) external onlyGovernance {
    _migration = destination;
  }

  function claimMemberCredits(uint256 amount) external {
    require(_memberships[_msgSender()].credits >= amount, "Insufficient credits");
    _memberships[_msgSender()].credits -= amount;
    getTreasuryToken().transfer(_msgSender(), amount);
    emit ClaimMemberCredits(_msgSender(), amount);
  }

  function transferMigration(uint256 amount) external onlyAdminGovAgents {
    require(_migration != address(0), "Migration not set");
    require(getTreasuryToken().balanceOf(address(this)) >= amount, "Insufficient balance");
    getTreasuryToken().transfer(_migration, amount);
  }

  function updateAddresses() public override onlyRegistrar {
    _mfcToken = MFCToken(_registrar.getMFCToken());
    _busdt = BUSDT(_registrar.getBUSDT());
    _updateGovernable(_registrar);
  }

  function _createMember(address account, address inviterAddress) private {
    _memberships[account].inviter = inviterAddress;
    _memberships[account].isExist = true;
    _memberships[account].credits = 0;

    if (!_mfcToken.isWhitelistedUser(account)) {
      _mfcToken.whitelistUser(account);
    }
  }

  function _payMembership(uint256 membershipFee, address inviter) private {
    require(membershipFee == _licenseFee, "Invalid membership fee");

    if (_licenseFee > 0) {
      require(getTreasuryToken().allowance(_msgSender(), address(this)) >= _licenseFee, "Insufficient allowance");
      require(getTreasuryToken().balanceOf(_msgSender()) >= _licenseFee, "Insufficient balance");

      (uint256 inviterAmount, uint256 remainingAmount) = _splitInviterFee(_licenseFee, inviter);
      _extendExpiresAt(_msgSender());

      emit PaySubscription(_msgSender(), _licenseFee, block.timestamp, inviterAmount, remainingAmount, _memberships[_msgSender()].expiresAt);
    }
  }

  function _setLicenseParameters(uint256 licenseFee, uint256 inviterFeeSplit) private {
    _licenseFee = licenseFee;
    _inviterFeeSplit = inviterFeeSplit;

    emit SetLicenseParameters(licenseFee, inviterFeeSplit);
  }

  function _makePaymentFromBUSD(uint256 amount, address destination) private {
    getTreasuryToken().transferFrom(_msgSender(), destination, amount);
  }

  function _splitInviterFee(uint256 amount, address inviter) private returns (uint256 inviterAmount, uint256 remainingAmount) {
    inviterAmount = _inviterFeeSplit * amount / MULTIPLIER;
    remainingAmount = amount - inviterAmount;

    // inviterAmount goes to inviter's credits
    _memberships[inviter].credits += inviterAmount;

    // transfer inviterAmount to this contract
    _makePaymentFromBUSD(inviterAmount, address(this));

    // remainingAmount goes to BUSDT
    _makePaymentFromBUSD(remainingAmount, address(_busdt));
  }

  function _extendExpiresAt(address account) private {
    // If block timestamp > expiresAt (has already been expired) then extend from block timestamp
    if (block.timestamp > _memberships[account].expiresAt) {
      _memberships[account].expiresAt = block.timestamp + _licenseTermInHours * 3600;
    } else { // Increment expiresAt
      _memberships[account].expiresAt +=  _licenseTermInHours * 3600;
    }
  }

  function _registrarMigrate(uint256 amount) internal override {
    getTreasuryToken().transfer(getRegistrarMigrateDestination(), amount);
  }
}

// SPDX-License-Identifier: MIT
//
// MFCExchangeCap [MFC_BUSD]
//
pragma solidity ^0.8.4;

import "../access/BackendAgent.sol";
import "../lib/token/BEP20/BEP20.sol";
import "../token/MFCToken.sol";
import "../treasury/Treasury.sol";
import "./ExchangeCheck.sol";
import "../RegistrarClient.sol";
import "../RegistrarMigrator.sol";
import "../access/AdminGovernanceAgent.sol";
import "../governance/Governable.sol";
import "./MFCExchangeFloor.sol";

contract MFCExchangeCap is BackendAgent, ExchangeCheck, RegistrarClient, RegistrarMigrator, AdminGovernanceAgent, Governable {

  uint256 public constant BUSD_FEE = 20000000000000000;
  uint256 public constant MFC_FEE = 20000000000000000;
  uint256 public constant MULTIPLIER = 10**18;
  uint256 public constant MIN_PRICE_FACTOR = 1900000000000000000; // 1.9 ethers

  MFCToken private _mfc;
  BEP20 private _busd;
  MFCExchangeFloor private _mfcExchangeFloor;
  address private _busdTreasuryAddress;
  address private _busdComptrollerAddress;
  address private _migration;
  uint256 private _nonce = 1;
  uint256 private _mfcAllocatedInOffers = 0;

  struct Offer {
    uint256 id;
    uint256 quantity;
    uint256 price;
    bool isOpen;
  }

  mapping(uint256 => Offer) private _offers;

  event CreateOffer(uint256 id, uint256 quantity, uint256 price, uint256 timestamp);
  event TradeOffer(uint256 id, address buyer, uint256 sellerQuantity, uint256 buyerQuantity, uint256 unfilledQuantity, uint256 timestamp);
  event CloseOffer(uint256 id, uint256 timestamp);

  constructor(
    address registrarAddress_,
    address busdAddress_,
    address busdComptrollerAddress_,
    address[] memory adminAgents,
    address[] memory backendAdminAgents,
    address[] memory backendAgents,
    address[] memory adminGovAgents
  ) RegistrarClient(registrarAddress_)
    RegistrarMigrator(registrarAddress_, adminAgents)
    AdminGovernanceAgent(adminGovAgents) {
    _busd = BEP20(busdAddress_);
    _busdComptrollerAddress = busdComptrollerAddress_;
    _setBackendAdminAgents(backendAdminAgents);
    _setBackendAgents(backendAgents);
  }

  function getNonce() external view returns (uint256) {
    return _nonce;
  }

  function getMfcAllocatedInOffers() external view returns (uint256) {
    return _mfcAllocatedInOffers;
  }

  function getOffer(uint256 id) external view returns (Offer memory) {
    return _offers[id];
  }

  function getMigration() external view returns (address) {
    return _migration;
  }

  function setMigration(address destination) external onlyGovernance {
    _migration = destination;
  }

  function transferMigration(uint256 amount) external onlyAdminGovAgents {
    require(_migration != address(0), "Migration not set");
    require(_mfc.balanceOf(address(this)) >= amount, "Insufficient balance");
    _mfc.transfer(_migration, amount);
  }

  function createOffer(uint256 quantity, uint256 price) external onlyBackendAgents {
    require(quantity > 0, "Invalid quantity");
    require(price > 0, "Invalid price");

    // If the floor price is > 0, then enforce the 1.9x minimum price
    // else if the floor price is 0 then any price is ok and don't enforce a minimum price.
    // Min price = inverted floor price in BUSD/MFC * 1.9
    if (_mfcExchangeFloor.getPrice() > 0) {
      uint256 minPrice = MIN_PRICE_FACTOR * MULTIPLIER / _mfcExchangeFloor.getPrice();
      require(price >= minPrice, "Price must be >= minPrice");
    }

    uint256 _mfcBalance = _mfc.balanceOf(address(this));
    uint256 _desiredTotalMfc = _mfcAllocatedInOffers + quantity;
    if (_desiredTotalMfc > _mfcBalance) {
      uint256 amountToMint = _desiredTotalMfc - _mfcBalance;
      _mfc.mint(amountToMint);
    }

    uint256 id = _nonce++;
    _offers[id] = Offer(id, quantity, price, true);
    _mfcAllocatedInOffers += quantity;
    emit CreateOffer(id, quantity, price, block.timestamp);
  }

  function tradeOffer(uint256 id, uint256 quantity) external onlyValidMember(_msgSender()) {
    require(_isOfferActive(id), "Invalid offer");
    require(quantity > 0, "Invalid quantity");

    uint256 maxInput = _offers[id].quantity * _offers[id].price / MULTIPLIER;

    require(quantity <= maxInput, "Not enough to sell");

    uint256 buyQuantity = _tradeOffer(quantity, _offers[id].price);

    require(_offers[id].quantity >= buyQuantity, "Bad calculations");
    _offers[id].quantity -= buyQuantity;
    _mfcAllocatedInOffers -= buyQuantity;

    emit TradeOffer(id, _msgSender(), buyQuantity, quantity, _offers[id].quantity, block.timestamp);
  }

  function closeOffer(uint256 id) external onlyBackendAgents {
    require(_isOfferActive(id), "Invalid offer");
    _closeOffer(id);
  }

  function updateAddresses() public override onlyRegistrar {
    _mfc = MFCToken(_registrar.getMFCToken());
    _busdTreasuryAddress = _registrar.getBUSDT();
    _mfcExchangeFloor = MFCExchangeFloor(_registrar.getMFCExchangeFloor());
    _updateExchangeCheck(_registrar);
    _updateGovernable(_registrar);
  }

  function _isOfferActive(uint256 id) private view returns (bool) {
    return _offers[id].isOpen;
  }

  // @dev returns maker quantity fulfilled by this trade
  function _tradeOffer(uint256 quantity, uint256 price) private returns (uint256) {
    require(_busd.allowance(_msgSender(), address(this)) >= quantity, "Insufficient allowance");
    require(_busd.balanceOf(_msgSender()) >= quantity, "Insufficient balance");

    uint256 buyQuantity = quantity * MULTIPLIER / price;

    require(_mfc.balanceOf(address(this)) >= buyQuantity, "Not enough to sell");

    uint256 makerFee = quantity * MFC_FEE / MULTIPLIER;
    uint256 takerFee = buyQuantity * BUSD_FEE / MULTIPLIER;

    uint256 makerReceives = quantity - makerFee;
    uint256 takerReceives = buyQuantity - takerFee;

    _busd.transferFrom(_msgSender(), _busdTreasuryAddress, makerReceives);
    _busd.transferFrom(_msgSender(), _busdComptrollerAddress, makerFee);
    _mfc.transfer(_msgSender(), takerReceives);

    return buyQuantity;
  }

  function _closeOffer(uint256 id) private {
    _mfcAllocatedInOffers -= _offers[id].quantity;
    _offers[id].isOpen = false;
    _offers[id].quantity = 0;
    emit CloseOffer(id, block.timestamp);
  }

  function _registrarMigrate(uint256 amount) internal override {
    _mfc.registrarMigrateExchangeCap(getRegistrarMigrateDestination(), amount);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./lib/utils/Context.sol";
import "./Registrar.sol";

interface IRegistrarClient {
  function updateAddresses() external;
}

abstract contract RegistrarClient is Context, IRegistrarClient {

  Registrar internal _registrar;

  constructor(address registrar) {
    _registrar = Registrar(registrar);
  }

  modifier onlyRegistrar() {
    require(_msgSender() == address(_registrar), "Unauthorized, registrar only");
    _;
  }

  function getRegistrar() external view returns(address) {
    return address(_registrar);
  }

  // All subclasses must implement this function
  function updateAddresses() public override virtual;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../lib/utils/Context.sol";

contract AdminGovernanceAgent is Context {

  mapping(address => bool) private _adminGovAgents;

  constructor(address[] memory adminGovAgents) {
    for (uint i = 0; i < adminGovAgents.length; i++) {
      _adminGovAgents[adminGovAgents[i]] = true;
    }
  }

  modifier onlyAdminGovAgents() {
    require(_adminGovAgents[_msgSender()], "Unauthorized");
    _;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../lib/utils/Context.sol";
import "../Registrar.sol";

contract Governable is Context {

  address internal _governanceAddress;

  constructor() {}

  modifier onlyGovernance() {
    require(_governanceAddress == _msgSender(), "Unauthorized");
    _;
  }

  function _updateGovernable(Registrar registrar) internal {
    _governanceAddress = registrar.getMFCGovernance();
  }


  function getGovernanceAddress() external view returns (address) {
    return _governanceAddress;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../lib/token/BEP20/BEP20.sol";
import "../lib/utils/Context.sol";

contract Treasury is Context {

  BEP20 private _token;

  constructor(address tokenContractAddress_) {
    _token = BEP20(tokenContractAddress_);
  }

  function getTreasuryToken() internal view returns (BEP20) {
    return _token;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// import "hardhat/console.sol";

import "./access/BackendAgent.sol";
import "./lib/token/BEP20/IBEP20.sol";
import "./token/MFCToken.sol";
import "./exchange/ExchangeCheck.sol";
import "./exchange/MFCExchange.sol";
import "./exchange/MFCExchangeFloor.sol";
import "./treasury/BUSDT.sol";
import "./RegistrarClient.sol";
import "./access/AdminGovernanceAgent.sol";

contract MFCCollateralLoan is BackendAgent, ExchangeCheck, RegistrarClient, AdminGovernanceAgent {

  // We use this to get around stack too deep errors.
  struct TradeOfferVars {
    uint256 maxInput;
    uint256 busdFee;
    uint256 mfcFee;
    uint256 mfcOut;
  }

  struct CalcOfferRepayment {
    uint256 effectiveBusdPaidOff;
    uint256 excessBUSD;
    uint256 excessCollateral;
    uint256 accruedInterest;
    bool isPaidOff;
  }

  uint256 public constant MULTIPLIER = 10**18;
  uint256 public constant DAY_IN_SECONDS = 86400;
  uint256 public constant OFFER_PRICE_LTV_RATIO = 1020409000000000000; // 1.020409;
  uint256 public constant OFFER_NET_COLLATERAL_RATIO = 980000000000000000; // 0.98;
  uint256 public constant BUSD_FEE = 20000000000000000;
  uint256 public constant MFC_FEE = 20000000000000000;
  uint256 public constant EXPIRES_IN = 30 days;
  uint256 public constant MINIMUM_OFFER_AUTOCLOSE_IN_BUSD = 1000000000000000000; // 1 Ether
  uint256 public constant MINIMUM_LOAN_AUTOCLOSE = 100000000; // 0.1 gwei

  enum DataTypes {
    BUSD,
    PERCENTAGE
  }

  MFCExchange private _mfcExchange;
  MFCExchangeFloor private _mfcExchangeFloor;
  MFCToken private _mfc;
  IBEP20 private _busd;
  BUSDT private _busdt;
  address private _mfcExchangeCapAddress;
  address private _busdComptrollerAddress;
  address private _deployer;
  uint256 private _loanTermsNonce = 0;
  uint256 private _loansNonce = 0;
  uint256 private _totalLoanValue = 0;
  uint256 private _maxOpenLoans = 4;
  bool private _allowLoanRenewals = true;

  // This contains the mutable loan terms
  struct LoanTerm {
    uint256 dailyInterestRate;
    uint256 loanDurationInDays;
    uint256 minimumLoanBUSD;
    uint256 originationFeePercentage;
    uint256 extensionFeePercentage;
    uint256 extensionMinimumRepayment;
    DataTypes extensionMinimumRepaymentType;
    uint256 extensionMinimumRemainingPrincipal;
    DataTypes extensionMinimumRemainingPrincipalType;
  }

  // This contains loan info per user
  struct Loan {
    uint256 loanTermId;
    uint256 collateralMFC;
    uint256 originalPrincipalBUSD;
    uint256 remainingPrincipalBUSD;
    uint256 principalRepaidSinceExtensionBUSD;
    uint256 ltv;
    uint256 startAt;
    uint256 endAt;
    uint256 lastPaidAt;
  }

  struct Offer {
    uint256 unfilledQuantity;
    uint256 price;
    uint256 maxPrincipal;     // Principal at the time offer is created
    uint256 maxQuantity;      // Max quantity at the time offer is created
    uint256 expiresAt;
    bool isOpen;
  }

  mapping(uint256 => LoanTerm) private _loanTerms;
  mapping(address => mapping(uint256 => Loan)) private _loans;
  mapping(address => uint8) private _openLoans;
  mapping(address => mapping(uint256 => Offer)) private _offers;

  event CreateLoanTerm(
    uint256 loanTermId,
    uint256 dailyInterestRate,
    uint256 loanDurationInDays,
    uint256 minimumLoanBUSD,
    uint256 originationFeePercentage,
    uint256 extensionFeePercentage,
    uint256 extensionMinimumRepayment,
    DataTypes extensionMinimumRepaymentType,
    uint256 extensionMinimumRemainingPrincipal,
    DataTypes extensionMinimumRemainingPrincipalType);
  event CreateLoan(
    address borrower,
    uint256 loanId,
    uint256 loanTermId,
    uint256 collateralMFC,
    uint256 originalPrincipalBUSD,
    uint256 remainingPrincipalBUSD,
    uint256 principalRepaidSinceExtensionBUSD,
    uint256 ltv,
    uint256 startAt,
    uint256 endAt);

  event PayLoan(
    address borrower,
    uint256 loanId,
    uint256 busdAmount,
    uint256 remainingPrincipalBUSD,
    uint256 principalRepaidSinceExtensionBUSD,
    uint256 collateralMFC,
    uint256 collateralReturned,
    uint256 interestPaid,
    uint256 paidAt
  );
  event ExtendLoan(address borrower, uint256 loanId, uint256 endAt);
  event CloseLoan(address borrower, uint256 loanId, uint256 collateralMFCTransferred);
  event CreateOffer(address borrower, uint256 loanId, uint256 quantity, uint256 price, uint256 expiresAt, uint256 timestamp);
  event TradeOffer(
    address borrower,
    uint256 loanId,
    address buyer,
    uint256 sellerQuantity,
    uint256 buyerQuantity,
    uint256 unfilledQuantity,
    uint256 excessBUSD,
    uint256 timestamp
  );
  event CloseOffer(uint256 loanId, uint256 timestamp);

  constructor(
    address registrarAddress_,
    address busdAddress_,
    address busdComptrollerAddress_,
    address[] memory adminGovAgents,
    address[] memory backendAdminAgents,
    address[] memory backendAgents
  ) RegistrarClient(registrarAddress_)
    AdminGovernanceAgent(adminGovAgents) {
    _busd = IBEP20(busdAddress_);
    _busdComptrollerAddress = busdComptrollerAddress_;
    _deployer = _msgSender();
    _setBackendAdminAgents(backendAdminAgents);
    _setBackendAgents(backendAgents);
  }

  modifier onlyDeployer() {
    require(_deployer == _msgSender(), "Caller is not the deployer");
    _;
  }

  modifier onlyActiveLoan(address borrower, uint256 loanId) {
    require(_loans[borrower][loanId].startAt > 0, "Invalid loan");
    require(isLoanActive(borrower, loanId), "Loan is not active");
    _;
  }

  modifier onlyActiveOffer(address borrower, uint256 loanId) {
    require(_offers[borrower][loanId].isOpen && _offers[borrower][loanId].expiresAt > block.timestamp, "Invalid offer");
    _;
  }

  modifier onlyOpenOffer(uint256 id, address borrower) {
    require(_offers[borrower][id].isOpen, "Offer must be open in order to close");
    _;
  }

  function setupInitialLoanTerm(
    uint256 dailyInterestRate,
    uint256 loanDurationInDays,
    uint256 minimumLoanBUSD,
    uint256 originationFeePercentage,
    uint256 extensionFeePercentage,
    uint256 extensionMinimumRepayment,
    DataTypes extensionMinimumRepaymentType,
    uint256 extensionMinimumRemainingPrincipal,
    DataTypes extensionMinimumRemainingPrincipalType
  ) external onlyDeployer {
    require(_loanTermsNonce == 0, "Loan terms already set up");
    _createNewLoanTerm(
      dailyInterestRate,
      loanDurationInDays,
      minimumLoanBUSD,
      originationFeePercentage,
      extensionFeePercentage,
      extensionMinimumRepayment,
      extensionMinimumRepaymentType,
      extensionMinimumRemainingPrincipal,
      extensionMinimumRemainingPrincipalType
    );
  }

  function createNewLoanTerm(
    uint256 dailyInterestRate,
    uint256 loanDurationInDays,
    uint256 minimumLoanBUSD,
    uint256 originationFeePercentage,
    uint256 extensionFeePercentage,
    uint256 extensionMinimumRepayment,
    DataTypes extensionMinimumRepaymentType,
    uint256 extensionMinimumRemainingPrincipal,
    DataTypes extensionMinimumRemainingPrincipalType
  ) external onlyBackendAdminAgents {
    _createNewLoanTerm(
      dailyInterestRate,
      loanDurationInDays,
      minimumLoanBUSD,
      originationFeePercentage,
      extensionFeePercentage,
      extensionMinimumRepayment,
      extensionMinimumRepaymentType,
      extensionMinimumRemainingPrincipal,
      extensionMinimumRemainingPrincipalType
    );
  }

  function getTotalLoanValue() external view returns (uint256) {
    return _totalLoanValue;
  }

  function getLoan(address borrower, uint256 loanId) external view returns (Loan memory) {
    return _loans[borrower][loanId];
  }

  function isLoanActive(address borrower, uint256 loanId) public view returns (bool) {
    return !_isLoanExpired(borrower, loanId) && _loans[borrower][loanId].remainingPrincipalBUSD > 0;
  }

  function getLoanTerm(uint256 loanTermId) external view returns (LoanTerm memory) {
    return _loanTerms[loanTermId];
  }

  function getCurrentLoanTerm() external view returns (LoanTerm memory) {
    return _loanTerms[_loanTermsNonce];
  }

  function getCurrentLoanTermId() external view returns (uint256) {
    return _loanTermsNonce;
  }

  function accruedInterestBUSD(address borrower, uint256 loanId) external view returns (uint256) {
    return _accruedInterestBUSD(borrower, loanId);
  }

  function accruedInterestMFC(address borrower, uint256 loanId) external view returns (uint256) {
    return _accruedInterestMFC(borrower, loanId);
  }

  function getCollateralMFCForLoanBUSD(uint256 busdAmount) external view returns (uint256) {
    return _getCollateralMFCForLoanBUSD(busdAmount);
  }

  function getMaxOpenLoans() external view returns (uint256) {
    return _maxOpenLoans;
  }

  function setMaxOpenLoans(uint256 maxOpenLoans_) external onlyBackendAdminAgents {
    _maxOpenLoans = maxOpenLoans_;
  }

  function getAllowLoanRenewals() external view returns (bool) {
    return _allowLoanRenewals;
  }

  function setAllowLoanRenewals(bool enabled) external onlyAdminGovAgents {
    _allowLoanRenewals = enabled;
  }

  function createLoan(uint256 loanTermId, uint256 busdAmount, uint256 mfcAmount, uint8 v, bytes32 r, bytes32 s) external {
    require(loanTermId == _loanTermsNonce, "Invalid loan term specified");
    require(_openLoans[_msgSender()] < _maxOpenLoans, "Maximum open loans reached");
    uint256 minCollateralMFC = _getCollateralMFCForLoanBUSD(busdAmount);
    require(mfcAmount >= minCollateralMFC, "mfcAmount too low based on floor price");

    // Call approval
    _mfc.permit(_msgSender(), address(this), mfcAmount, v, r, s);
    _createLoan(busdAmount);
  }

  function _createLoan(uint256 busdAmount) private {
    LoanTerm memory loanTerm = _loanTerms[_loanTermsNonce];
    require(busdAmount >= loanTerm.minimumLoanBUSD, "Minimum loan not met");
    uint256 collateralMFC = _getCollateralMFCForLoanBUSD(busdAmount);

    uint256 loanId = ++_loansNonce;
    uint256 busdComptrollerReceives = busdAmount * loanTerm.originationFeePercentage / MULTIPLIER;
    uint256 borrowerReceives = busdAmount - busdComptrollerReceives;
    uint256 startAt = block.timestamp;
    uint256 endAt = startAt + loanTerm.loanDurationInDays * DAY_IN_SECONDS;
    uint256 mfcPrice = _mfcExchangeFloor.getPrice();

    _loans[_msgSender()][loanId] = Loan(_loanTermsNonce, collateralMFC, busdAmount, busdAmount, 0, mfcPrice, startAt, endAt, 0);
    _openLoans[_msgSender()]++;

    _totalLoanValue += busdAmount;
    _mfc.transferFrom(_msgSender(), address(this), collateralMFC);
    _busdt.collateralTransfer(_msgSender(), borrowerReceives);
    _busdt.collateralTransfer(_busdComptrollerAddress, busdComptrollerReceives);

    emit CreateLoan(_msgSender(), loanId, _loanTermsNonce, collateralMFC, busdAmount, busdAmount, 0, mfcPrice, startAt, endAt);
  }

  function payLoan(uint256 loanId, uint256 busdAmount) external onlyActiveLoan(_msgSender(), loanId) {
    require(_busd.allowance(_msgSender(), address(this)) >= busdAmount, "Insufficient allowance");
    require(_busd.balanceOf(_msgSender()) >= busdAmount, "Insufficient balance");
    require(!_offers[_msgSender()][loanId].isOpen, "Active offer found");

    _payLoanBUSD(_msgSender(), loanId, busdAmount);
  }

  function extendLoan(uint256 loanId) external onlyActiveLoan(_msgSender(), loanId) {
    require(_allowLoanRenewals, "Loan renewals disabled");
    Loan storage loan = _loans[_msgSender()][loanId];
    LoanTerm memory loanTerm = _loanTerms[loan.loanTermId];
    require(loan.principalRepaidSinceExtensionBUSD >= _getMinimumExtensionRepayment(loan.loanTermId, loan.originalPrincipalBUSD), "Minimum repayment not met");
    require(loan.remainingPrincipalBUSD >= _getRemainingPrincipalExtensionLimit(loan.loanTermId, loan.originalPrincipalBUSD), "Principal too low to extend");
    uint256 extensionFeeBUSD = loan.remainingPrincipalBUSD * loanTerm.extensionFeePercentage / MULTIPLIER;
    require(_busd.allowance(_msgSender(), address(this)) >= extensionFeeBUSD, "Insufficient allowance");
    require(_busd.balanceOf(_msgSender()) >= extensionFeeBUSD, "Insufficient balance");

    loan.principalRepaidSinceExtensionBUSD = 0;
    loan.endAt = block.timestamp + loanTerm.loanDurationInDays * DAY_IN_SECONDS;

    _busd.transferFrom(_msgSender(), _busdComptrollerAddress, extensionFeeBUSD);

    emit ExtendLoan(_msgSender(), loanId, loan.endAt);
  }

  // for manually closing out expired loans (defaulted) and taking out the remaining collateral
  function closeLoan(address borrower, uint256 loanId) external onlyBackendAgents {
    require(!isLoanActive(borrower, loanId), "Loan is still active");

    uint256 collateralMFC = _loans[borrower][loanId].collateralMFC;
    uint256 remainingPrincipalBUSD = _loans[borrower][loanId].remainingPrincipalBUSD;

    // Update loan and offer (if any)
    _decrementOpenLoansAndCloseOffer(borrower, loanId);
    _loans[borrower][loanId].collateralMFC = 0;
    _loans[borrower][loanId].remainingPrincipalBUSD = 0;

    // Update total loan value
    _totalLoanValue -= remainingPrincipalBUSD;

    // Transfer an remaining collateral MFC to exchange
    // and update circulation
    _transferToExchangeCap(collateralMFC);

    emit CloseLoan(borrower, loanId, collateralMFC);
  }

  function createOffer(uint256 loanId, uint256 quantity, uint256 price) external onlyValidMember(_msgSender()) onlyActiveLoan(_msgSender(), loanId) {
    require(!_offers[_msgSender()][loanId].isOpen, "Limit one offer per loan");

    Loan memory loan = _loans[_msgSender()][loanId];

    // OFFER_NET_COLLATERAL_RATIO
    uint256 accruedInterest = _accruedInterestMFC(_msgSender(), loanId);
    uint256 maximumQuantity = (loan.collateralMFC - accruedInterest) * OFFER_NET_COLLATERAL_RATIO / MULTIPLIER;
    require(quantity <= maximumQuantity, "Quantity exceeds limit");

    // We're creating a [MFC_BUSD] offer:
    // min price = (remaining principal / (remaining collateral after interest * 0.98)) * 1.020409
    uint256 minPrice = loan.remainingPrincipalBUSD * OFFER_PRICE_LTV_RATIO / maximumQuantity;
    require(price >= minPrice, "Minimum price not met");

    // Cannot open an offer if loan is to expire before end
    // of offer (currently 30 days)
    uint256 expiresAt = block.timestamp + EXPIRES_IN;
    require(loan.endAt > expiresAt, "Loan is about to expire");

    // Create offer
    _offers[_msgSender()][loanId] = Offer(quantity, price, loan.remainingPrincipalBUSD, maximumQuantity, expiresAt, true);

    emit CreateOffer(_msgSender(), loanId, quantity, price, expiresAt, block.timestamp);
  }

  /**
   * @dev This is for other members to trade on the offer the borrower created
   */
  function tradeOffer(address borrower, uint256 loanId, uint256 amountBUSD) external onlyValidMember(_msgSender()) onlyActiveOffer(borrower, loanId) {
    require(amountBUSD > 0, "Invalid quantity");
    require(_busd.allowance(_msgSender(), address(this)) >= amountBUSD, "Insufficient allowance");
    require(_busd.balanceOf(_msgSender()) >= amountBUSD, "Insufficient balance");

    Offer storage offer = _offers[borrower][loanId];
    Loan storage loan = _loans[borrower][loanId];

    TradeOfferVars memory info;
    info.maxInput = offer.unfilledQuantity * offer.price / MULTIPLIER;
    require(amountBUSD <= info.maxInput, "Not enough to sell");

    info.busdFee = amountBUSD * BUSD_FEE / MULTIPLIER;
    info.mfcFee = amountBUSD * MFC_FEE / offer.price;

    info.mfcOut = amountBUSD * MULTIPLIER / offer.price;

    // Calculate and update loan
    CalcOfferRepayment memory calc = _payLoanMFC(
      borrower,
      loanId,
      info.mfcOut,
      offer.maxPrincipal,
      offer.maxQuantity,
      amountBUSD - info.busdFee
    );

    // Update offer
    if (!calc.isPaidOff) {
      if (info.mfcOut > offer.unfilledQuantity) {
        info.mfcOut = offer.unfilledQuantity;
      }
      offer.unfilledQuantity -= info.mfcOut;

      // If remaining quantity is low enough, close it out
      // MFC_BUSD market - converted selling amount in MFC to BUSD < MINIMUM_OFFER_AUTOCLOSE_IN_BUSD
      bool takerCloseout = (offer.unfilledQuantity * offer.price / MULTIPLIER) < MINIMUM_OFFER_AUTOCLOSE_IN_BUSD;

      // console.log("unfilledQuantity: %s, takerCloseout: %s, amount: %s", offer.unfilledQuantity, takerCloseout, offer.unfilledQuantity * offer.price / MULTIPLIER);

      if (takerCloseout) {
        // Auto-close when selling amount in BUSD < MINIMUM_OFFER_AUTOCLOSE_IN_BUSD
        // No need to return MFC from offer, since it was reserving
        // the MFC directly from borrower's collateralMFC pool.
        _closeOffer(borrower, loanId);
      }
    }

    _totalLoanValue -= calc.effectiveBusdPaidOff;

    // Send out MFC fee + accrued interest.
    // Note that we have 2% MFC buffer in the collateral, as
    // the offer can only be created with 98% of collateral max.
    _transferToExchangeCap(info.mfcFee + calc.accruedInterest);

    // Send out MFC to buyer
    _mfc.transfer(_msgSender(), info.mfcOut - info.mfcFee);

    // Send out BUSD fee
    _busd.transferFrom(_msgSender(), _busdComptrollerAddress, info.busdFee);

    // Send out to BUSDT
    _busd.transferFrom(_msgSender(), address(_busdt), amountBUSD - calc.excessBUSD - info.busdFee);
    if (calc.excessBUSD > 0) {
      // Send excess to borrower
      _busd.transferFrom(_msgSender(), borrower, calc.excessBUSD);
    }

    if (calc.excessCollateral > 0) {
      // Return excess MFC to borrower (if any) once loan is repaid in full
      _mfc.transfer(borrower, calc.excessCollateral);
    }

    emit TradeOffer(borrower, loanId, _msgSender(), info.mfcOut, amountBUSD, offer.unfilledQuantity, calc.excessBUSD, loan.lastPaidAt);
    emit PayLoan(
      borrower,
      loanId,
      calc.effectiveBusdPaidOff,
      loan.remainingPrincipalBUSD,
      loan.principalRepaidSinceExtensionBUSD,
      loan.collateralMFC,
      0,
      calc.accruedInterest,
      loan.lastPaidAt
    );
  }

  /**
   * @dev This is for the borrower to sell their collateral to other users
   */
  function tradeCollateral(uint256 loanId, uint256 offerId, address seller, uint256 amountMFC) external onlyValidMember(_msgSender()) onlyActiveLoan(_msgSender(), loanId) {
    _tradeCollateralPrerequisite(loanId, amountMFC);

    Loan storage loan = _loans[_msgSender()][loanId];
    // We are trading on a member's [BUSD_MFC] offer, so their price will be MFC/BUSD.
    MFCExchange.Offer memory offer = _mfcExchange.getOffer(offerId, seller);
    require(offer.isOpen == true && offer.quantity > 0, "Offer is closed or has zero quantity");

    uint256 accruedInterest = _accruedInterestMFC(_msgSender(), loanId);

    // min price formula = (remaining principal / remaining collateral after interest) * 1.020409
    // In this case it's actually max price due to inversion.
    uint256 maxPrice = loan.remainingPrincipalBUSD * OFFER_PRICE_LTV_RATIO / (loan.collateralMFC - accruedInterest);
    maxPrice = MULTIPLIER * MULTIPLIER / maxPrice;
    require(offer.price <= maxPrice, "Minimum price not met");

    _mfc.approve(address(_mfcExchange), amountMFC);

    // Calculate (estimate) and update state first
    MFCExchange.TradeOfferCalcInfo memory calc = _mfcExchange.estimateTradeOffer(offerId, seller, amountMFC);
    CalcOfferRepayment memory loanCalcs = _payLoanMFC(
      _msgSender(),
      loanId,
      amountMFC,
      loan.remainingPrincipalBUSD,
      loan.collateralMFC - accruedInterest,
      calc.amountOut - calc.takerFee
    );

    // Execute actual swap
    MFCExchange.TradeOfferCalcInfo memory realCalc = _mfcExchange.tradeOffer(offerId, seller, amountMFC);
    require(calc.amountOut == realCalc.amountOut, "amountOut does not match");

    // Send out funds post-swap
    _tradeCollateralTransfers(loanId, loanCalcs, realCalc.amountOut, realCalc.takerFee);
  }

  function _tradeCollateralTransfers(uint256 loanId, CalcOfferRepayment memory loanCalcs, uint256 amountOut, uint256 takerFee) private {
    address borrower = _msgSender();
    Loan storage loan = _loans[borrower][loanId];

    // This needs to be updated last (but before transfers)
    // as this affects the floor price.
    _totalLoanValue -= loanCalcs.effectiveBusdPaidOff;

    _transferToExchangeCap(loanCalcs.accruedInterest);

    _busd.transfer(address(_busdt), amountOut - loanCalcs.excessBUSD - takerFee);
    if (loanCalcs.excessBUSD > 0) {
      // Send excess to borrower
      _busd.transfer(borrower, loanCalcs.excessBUSD);
    }

    if (loanCalcs.excessCollateral > 0) {
      // Return excess MFC to borrower (if any) once loan is repaid in full
      _mfc.transfer(borrower, loanCalcs.excessCollateral);
    }

    emit PayLoan(
      borrower,
      loanId,
      loanCalcs.effectiveBusdPaidOff,
      loan.remainingPrincipalBUSD,
      loan.principalRepaidSinceExtensionBUSD,
      loan.collateralMFC,
      0,
      loanCalcs.accruedInterest,
      loan.lastPaidAt
    );
  }

  function closeOffer(uint256 loanId) external onlyOpenOffer(loanId, _msgSender()) {
    _closeOffer(_msgSender(), loanId);
  }

  function closeOffer(address borrower, uint256 loanId) external onlyOpenOffer(loanId, borrower) onlyBackendAgents {
    _closeOffer(borrower, loanId);
  }

  function getOffer(address borrower, uint256 loanId) external view returns (Offer memory) {
    return _offers[borrower][loanId];
  }

  function updateAddresses() public override onlyRegistrar {
    _mfcExchange = MFCExchange(_registrar.getMFCExchange());
    _mfcExchangeFloor = MFCExchangeFloor(_registrar.getMFCExchangeFloor());
    _mfcExchangeCapAddress = _registrar.getMFCExchangeCap();
    _mfc = MFCToken(_registrar.getMFCToken());
    _busdt = BUSDT(_registrar.getBUSDT());
    _updateExchangeCheck(_registrar);
  }

  function _createNewLoanTerm(
    uint256 dailyInterestRate,
    uint256 loanDurationInDays,
    uint256 minimumLoanBUSD,
    uint256 originationFeePercentage,
    uint256 extensionFeePercentage,
    uint256 extensionMinimumRepayment,
    DataTypes extensionMinimumRepaymentType,
    uint256 extensionMinimumRemainingPrincipal,
    DataTypes extensionMinimumRemainingPrincipalType
  ) private {
    require(extensionMinimumRepaymentType == DataTypes.PERCENTAGE || extensionMinimumRepaymentType == DataTypes.BUSD, "Invalid type");
    require(extensionMinimumRemainingPrincipalType == DataTypes.PERCENTAGE || extensionMinimumRemainingPrincipalType == DataTypes.BUSD, "Invalid type");

    _loanTerms[++_loanTermsNonce] = LoanTerm(
      dailyInterestRate,
      loanDurationInDays,
      minimumLoanBUSD,
      originationFeePercentage,
      extensionFeePercentage,
      extensionMinimumRepayment,
      extensionMinimumRepaymentType,
      extensionMinimumRemainingPrincipal,
      extensionMinimumRemainingPrincipalType
    );

    emit CreateLoanTerm(
      _loanTermsNonce,
      dailyInterestRate,
      loanDurationInDays,
      minimumLoanBUSD,
      originationFeePercentage,
      extensionFeePercentage,
      extensionMinimumRepayment,
      extensionMinimumRepaymentType,
      extensionMinimumRemainingPrincipal,
      extensionMinimumRemainingPrincipalType
    );
  }

  function _getCollateralMFCForLoanBUSD(uint256 busdAmount) private view returns (uint256) {
    uint256 mfcPrice = _mfcExchangeFloor.getPrice();
    return mfcPrice * busdAmount / MULTIPLIER;
  }

  function _isLoanExpired(address borrower, uint256 loanId) private view returns (bool) {
    return _loans[borrower][loanId].endAt < block.timestamp;
  }

  // rounding down basis, meaning for 11.6 days borrower will pay interests for 11 days
  // we have to account for the case where borrower might pay at 11.6 days and another payment at 20.4 days
  // because 20.4-11.6 = 8.8 days we cannot calculate directly otherwise 11+8 = 19 days of interest instead of 20
  // therefore we have to look at the number of days in total minus the number of days borrower has paid
  function _daysElapsed(uint256 startAt, uint256 lastPaidAt) private view returns (uint256) {
    uint256 currentTime = block.timestamp;
    if (lastPaidAt > 0) {
      uint256 daysTotal = (currentTime - startAt) / DAY_IN_SECONDS;
      uint256 daysPaid = (lastPaidAt - startAt) / DAY_IN_SECONDS;
      return daysTotal - daysPaid;
    } else {
      return (currentTime - startAt) / DAY_IN_SECONDS;
    }
  }

  function _getMinimumExtensionRepayment(uint256 loanTermId, uint256 originalPrincipalBUSD) private view returns (uint256) {
    LoanTerm memory loanTerm = _loanTerms[loanTermId];
    if (loanTerm.extensionMinimumRepaymentType == DataTypes.BUSD) {
      return loanTerm.extensionMinimumRepayment;
    } else if (loanTerm.extensionMinimumRepaymentType == DataTypes.PERCENTAGE) {
      return originalPrincipalBUSD * loanTerm.extensionMinimumRepayment / MULTIPLIER;
    } else {
      return 0;
    }
  }

  function _getRemainingPrincipalExtensionLimit(uint256 loanTermId, uint256 originalPrincipalBUSD) private view returns (uint256) {
    LoanTerm memory loanTerm = _loanTerms[loanTermId];
    if (loanTerm.extensionMinimumRemainingPrincipalType == DataTypes.BUSD) {
      return loanTerm.extensionMinimumRemainingPrincipal;
    } else if (loanTerm.extensionMinimumRemainingPrincipalType == DataTypes.PERCENTAGE) {
      return originalPrincipalBUSD * loanTerm.extensionMinimumRemainingPrincipal / MULTIPLIER;
    } else {
      return 0;
    }
  }

  function _accruedInterestBUSD(address borrower, uint256 loanId) private view returns (uint256) {
    Loan memory loan = _loans[borrower][loanId];
    LoanTerm memory loanTerm = _loanTerms[loan.loanTermId];
    uint256 daysElapsed = _daysElapsed(loan.startAt, loan.lastPaidAt);

    return loan.remainingPrincipalBUSD * loanTerm.dailyInterestRate * daysElapsed / MULTIPLIER;
  }

  function _accruedInterestMFC(address borrower, uint256 loanId) private view returns (uint256) {
    uint256 interestBUSD = _accruedInterestBUSD(borrower, loanId);
    uint256 mfcPrice = _mfcExchangeFloor.getPrice();

    return interestBUSD * mfcPrice / MULTIPLIER;
  }

  function _payLoanBUSD(address borrower, uint256 loanId, uint256 busdAmount) private {
    Loan storage loan = _loans[borrower][loanId];
    uint256 accruedInterest = _accruedInterestMFC(borrower, loanId);
    loan.collateralMFC -= accruedInterest;

    uint256 excessBUSD = 0;
    uint256 collateralReturned = 0;

    if (busdAmount > loan.remainingPrincipalBUSD) {
      excessBUSD = busdAmount - loan.remainingPrincipalBUSD;
      busdAmount = loan.remainingPrincipalBUSD;
    }

    if (loan.remainingPrincipalBUSD == busdAmount) {
      collateralReturned = loan.collateralMFC;
      _decrementOpenLoansAndCloseOffer(borrower, loanId);
    } else {
      collateralReturned = loan.collateralMFC * busdAmount / loan.remainingPrincipalBUSD;
    }

    loan.remainingPrincipalBUSD -= busdAmount;
    loan.principalRepaidSinceExtensionBUSD += busdAmount;
    loan.collateralMFC -= collateralReturned;
    loan.lastPaidAt = block.timestamp;

    _totalLoanValue -= busdAmount;
    _transferToExchangeCap(accruedInterest);
    _mfc.transfer(borrower, collateralReturned);

    _busd.transferFrom(_msgSender(), address(_busdt), busdAmount);

    if (excessBUSD > 0) {
      _busd.transferFrom(_msgSender(), borrower, excessBUSD);
    }

    emit PayLoan(
      borrower,
      loanId,
      busdAmount,
      loan.remainingPrincipalBUSD,
      loan.principalRepaidSinceExtensionBUSD,
      loan.collateralMFC,
      collateralReturned,
      accruedInterest,
      loan.lastPaidAt
    );
  }

  /**
   * @dev Pay off loan by selling MFC collateral
   */
  function _payLoanMFC(address borrower, uint256 loanId, uint256 mfcToTrade, uint256 maxPrincipal, uint256 maxMFC, uint256 amountBUSD) private returns (CalcOfferRepayment memory) {
    Loan storage loan = _loans[borrower][loanId];

    CalcOfferRepayment memory calc;

    // uint256 percentagePaidOff = mfcToTrade * MULTIPLIER / maxMFC;
    // calc.effectiveBusdPaidOff = percentagePaidOff * maxPrincipal / MULTIPLIER;
    calc.effectiveBusdPaidOff = mfcToTrade * maxPrincipal / maxMFC;
    if (amountBUSD > calc.effectiveBusdPaidOff) {
      calc.excessBUSD = amountBUSD - calc.effectiveBusdPaidOff;
    }
    calc.accruedInterest = _accruedInterestMFC(borrower, loanId);

    // console.log("mfcToTrade: %s\npercentagePaidOff: %s\neffectiveBusdPaidOff: %s", mfcToTrade, percentagePaidOff, calc.effectiveBusdPaidOff);
    // console.log("excessBUSD: %s\naccruedInterest: %s\ncollateralMFC: %s", calc.excessBUSD, calc.accruedInterest, loan.collateralMFC);
    // console.log("amountBUSD: %s", amountBUSD);

    // Update loan
    require(loan.collateralMFC >= mfcToTrade + calc.accruedInterest, "Not enough collateral");
    loan.collateralMFC -= mfcToTrade + calc.accruedInterest;

    // Handle possible precision issues
    if (calc.effectiveBusdPaidOff > loan.remainingPrincipalBUSD) {
      calc.effectiveBusdPaidOff = loan.remainingPrincipalBUSD;
    }
    if (loan.remainingPrincipalBUSD > calc.effectiveBusdPaidOff &&
      (loan.remainingPrincipalBUSD - calc.effectiveBusdPaidOff <= MINIMUM_LOAN_AUTOCLOSE)) {
      calc.effectiveBusdPaidOff = loan.remainingPrincipalBUSD;
    }

    // Loan paid off?
    if (calc.effectiveBusdPaidOff == loan.remainingPrincipalBUSD) {
      calc.isPaidOff = true;
      _decrementOpenLoansAndCloseOffer(borrower, loanId);

      // If there is any remaining collateral, record that
      // so we can later return it to borrower.
      if (loan.collateralMFC > 0) {
        calc.excessCollateral = loan.collateralMFC;
        loan.collateralMFC = 0;
      }
    }

    // Update rest of loan
    loan.remainingPrincipalBUSD -= calc.effectiveBusdPaidOff;
    loan.principalRepaidSinceExtensionBUSD += calc.effectiveBusdPaidOff;
    loan.lastPaidAt = block.timestamp;

    // console.log("remainingPrincipalBUSD: %s, excessCollateral: %s", loan.remainingPrincipalBUSD, calc.excessCollateral);
    // console.log("collateralMFC: %s", loan.collateralMFC);

    return calc;
  }

  function _tradeCollateralPrerequisite(uint256 loanId, uint256 amountMFC) private view {
    require(amountMFC > 0, "Invalid quantity");
    Offer memory offer = _offers[_msgSender()][loanId];
    require(offer.isOpen == false, "Active offer found");
    Loan memory loan = _loans[_msgSender()][loanId];
    uint256 accruedInterest = _accruedInterestMFC(_msgSender(), loanId);
    uint256 remainingCollateralMFC = loan.collateralMFC - accruedInterest;
    require(amountMFC <= remainingCollateralMFC, "Not enough to sell");
  }

  function _transferToExchangeCap(uint256 amount) private {
    _mfc.transfer(_mfcExchangeCapAddress, amount);
  }

  function _decrementOpenLoansAndCloseOffer(address borrower, uint256 loanId) internal {
    if (_openLoans[borrower] > 0) {
      _openLoans[borrower]--;
    }
    if (_offers[borrower][loanId].isOpen) {
      _closeOffer(borrower, loanId);
    }
    emit CloseLoan(borrower, loanId, 0);
  }

  function _closeOffer(address borrower, uint256 loanId) internal {
    delete _offers[borrower][loanId];
    emit CloseOffer(loanId, block.timestamp);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./lib/utils/Context.sol";
import "./access/AdminAgent.sol";
import "./RegistrarClient.sol";

contract Registrar is Context, AdminAgent {

  address[] private _contracts;
  bool private _finalized;

  event SetContracts(address[] addresses);
  event SetContractByIndex(uint8 index, address contractAddressTo);
  event Finalize(address registrarAddress);

  /**
   * @dev Constructor that setup the owner of this contract.
   */
  constructor(address[] memory adminAgents_) AdminAgent(adminAgents_) {}

  modifier onlyUnfinalized() {
    require(_finalized == false, "Registrar already finalized");
    _;
  }

  function getContracts() external view returns (address[] memory) {
    return _contracts;
  }

  function setContracts(address[] calldata _addresses) external onlyAdminAgents onlyUnfinalized {
    _contracts = _addresses;
    emit SetContracts(_addresses);
  }

  function setContractByIndex(uint8 _index, address _address) external onlyAdminAgents onlyUnfinalized {
    _contracts[_index] = _address;
    emit SetContractByIndex(_index, _address);
  }

  function updateAllClients() external onlyAdminAgents onlyUnfinalized {
    IRegistrarClient(this.getMFCToken()).updateAddresses();
    IRegistrarClient(this.getMFCMembership()).updateAddresses();
    IRegistrarClient(this.getMFCExchange()).updateAddresses();
    IRegistrarClient(this.getMFCExchangeCap()).updateAddresses();
    IRegistrarClient(this.getMFCExchangeFloor()).updateAddresses();
    IRegistrarClient(this.getMFCCollateralLoan()).updateAddresses();
    IRegistrarClient(this.getBUSDT()).updateAddresses();
    IRegistrarClient(this.getMFCBuyback()).updateAddresses();
    IRegistrarClient(this.getMFCGovernance()).updateAddresses();
  }

  function getMFCToken() external view returns (address) {
    return _contracts[0];
  }

  function getBUSDT() external view returns (address) {
    return _contracts[1];
  }

  function getMFCMembership() external view returns (address) {
    return _contracts[2];
  }

  function getMFCExchange() external view returns (address) {
    return _contracts[3];
  }

  function getMFCExchangeCap() external view returns (address) {
    return _contracts[4];
  }

  function getMFCExchangeFloor() external view returns (address) {
    return _contracts[5];
  }

  function getMFCBuyback() external view returns (address) {
    return _contracts[6];
  }

  function getMFCGovernance() external view returns (address) {
    return _contracts[7];
  }

  function getMFCCollateralLoan() external view returns (address) {
    return _contracts[8];
  }

  function finalize() external onlyAdminAgents onlyUnfinalized {
    _finalized = true;
    emit Finalize(address(this));
  }

  function isFinalized() external view returns (bool) {
    return _finalized;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../../access/Ownable.sol";
import "../../utils/Context.sol";
import "./IBEP20.sol";

/**
 * @dev @dev Implementation of the {IBEP20} interface.
 */
contract BEP20 is Context, IBEP20, Ownable {
  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  constructor(string memory name_, string memory symbol_, uint8 decimals_) {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external override view returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external override view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external override view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external override view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external override view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external override view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external override view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
    return true;
  }

  /**
   * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   *
   * Requirements
   *
   * - `msg.sender` must be the token owner
   */
  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] -= amount;
    _balances[recipient] += amount;
    emit Transfer(sender, recipient, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] -= amount;
    _totalSupply -= amount;
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()] - amount);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../lib/utils/Context.sol";

contract BackendAgent is Context {

  mapping(address => bool) private _backendAdminAgents;
  mapping(address => bool) private _backendAgents;

  event SetBackendAgent(address agent);
  event RevokeBackendAgent(address agent);

  modifier onlyBackendAdminAgents() {
    require(_backendAdminAgents[_msgSender()], "Unauthorized");
    _;
  }

  modifier onlyBackendAgents() {
    require(_backendAgents[_msgSender()], "Unauthorized");
    _;
  }

  function _setBackendAgents(address[] memory backendAgents) internal {
      for (uint i = 0; i < backendAgents.length; i++) {
      _backendAgents[backendAgents[i]] = true;
    }
  }

  function _setBackendAdminAgents(address[] memory backendAdminAgents) internal {
    for (uint i = 0; i < backendAdminAgents.length; i++) {
      _backendAdminAgents[backendAdminAgents[i]] = true;
    }
  }

  function setBackendAgent(address _agent) external onlyBackendAdminAgents {
    _backendAgents[_agent] = true;
    emit SetBackendAgent(_agent);
  }

  function revokeBackendAgent(address _agent) external onlyBackendAdminAgents {
    _backendAgents[_agent] = false;
    emit RevokeBackendAgent(_agent);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../MFCTradingLicense.sol";
import "../token/MFCToken.sol";
import "../Registrar.sol";

contract ExchangeCheck {
  MFCTradingLicense private _mfcMembership;
  MFCToken private _mfcToken;

  function _updateExchangeCheck(Registrar registrar) internal {
    _mfcMembership = MFCTradingLicense(registrar.getMFCMembership());
    _mfcToken = MFCToken(registrar.getMFCToken());
  }

  modifier onlyValidMember(address account) {
    require(_mfcMembership.isMemberActive(account) || _mfcToken.isWhitelistedAgent(account), "Account must have active status");
    _;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./MFCExchangeFloor.sol";
import "../lib/token/BEP20/BEP20.sol";
import "../token/MFCToken.sol";
import "../lib/utils/Context.sol";
import "./ExchangeCheck.sol";
import "../access/BackendAgent.sol";
import "../RegistrarClient.sol";

contract MFCExchange is Context, ExchangeCheck, BackendAgent, RegistrarClient {
  struct TradeOfferCalcInfo {
    uint256 amountOut;
    uint256 takerReceives;
    uint256 takerFee;
    uint256 makerReceives;
    uint256 makerFee;
  }

  uint256 public constant EXPIRES_IN = 30 days;
  uint256 public constant MINIMUM_AUTOCLOSE_IN_BUSD = 1000000000000000000; // 1 Ether
  uint256 public constant BUSD_FEE = 20000000000000000;
  uint256 public constant MFC_FEE = 20000000000000000;
  uint256 public constant MULTIPLIER = 10**18;

  address private _busdAddress;
  address private _busdComptrollerAddress;
  MFCExchangeFloor private _mfcExchangeFloor;
  uint256 private _nonce = 1;

  enum TradingPairs {
    MFC_BUSD,
    BUSD_MFC
  }

  struct Offer {
    uint256 id;
    TradingPairs tradingPair;
    uint256 quantity;
    uint256 price;
    uint256 expiresAt;
    bool isOpen;
  }

  struct TradingPair {
    address makerAssetAddress;
    address takerAssetAddress;
    address makerTreasuryAddress;
    address takerTreasuryAddress;
    uint256 makerFeeRate;
    uint256 takerFeeRate;
  }

  mapping(address => mapping(uint256 => Offer)) private _offers;
  mapping(TradingPairs => TradingPair) private _tradingPairs;

  event CreateOffer(uint256 id, address seller, TradingPairs tradingPair, uint256 quantity, uint256 price, uint256 expiresAt, uint256 timestamp);
  event TradeOffer(uint256 id, address buyer, uint256 sellerQuantity, uint256 buyerQuantity, uint256 unfilledQuantity, uint256 timestamp);
  event CloseOffer(uint256 id, uint256 timestamp);

  constructor(
    address registrarAddress_,
    address busdAddress_,
    address busdComptrollerAddress_,
    address[] memory backendAdminAgents,
    address[] memory backendAgents
  ) RegistrarClient(registrarAddress_) {
    _busdAddress = busdAddress_;
    _busdComptrollerAddress = busdComptrollerAddress_;
    _setBackendAdminAgents(backendAdminAgents);
    _setBackendAgents(backendAgents);
  }

  modifier onlyValidCreateOffer(TradingPairs tradingPair, uint256 quantity, uint256 price) {
    require(_pairExist(tradingPair), "Invalid pair");
    require(quantity > 0, "Invalid quantity");
    require(price > 0, "Invalid price");
    _;
  }

  modifier onlyValidTradeOffer(uint256 id, address seller, uint256 quantity) {
    require(_isOfferActive(id, seller), "Invalid offer");
    require(quantity > 0, "Invalid quantity");
    _;
  }

  modifier onlyOpenOffer(uint256 id, address seller) {
    require(_offers[seller][id].isOpen, "Offer must be open in order to close");
    _;
  }

  function getNonce() external view returns (uint256) {
    return _nonce;
  }

  function getOffer(uint256 id, address seller) external view returns (Offer memory) {
    return _offers[seller][id];
  }

  function createOffer(TradingPairs tradingPair, uint256 quantity, uint256 price)
    external
    onlyValidCreateOffer(tradingPair, quantity, price)
    onlyValidMember(_msgSender())
  {
    _createOffer(tradingPair, quantity, price);
  }

  function createOffer(TradingPairs tradingPair, uint256 quantity, uint256 price, uint8 v, bytes32 r, bytes32 s)
    external
    onlyValidCreateOffer(tradingPair, quantity, price)
    onlyValidMember(_msgSender())
  {
    // Verify maker asset must be MFC
    require(_tradingPairs[tradingPair].makerAssetAddress == _tradingPairs[TradingPairs.MFC_BUSD].makerAssetAddress, "Must be [MFC_BUSD]");
    MFCToken makerAsset = MFCToken(_tradingPairs[tradingPair].makerAssetAddress);
    // Call approval
    makerAsset.permit(_msgSender(), address(this), quantity, v, r, s);
    _createOffer(tradingPair, quantity, price);
  }

  function _createOffer(TradingPairs tradingPair, uint256 quantity, uint256 price) private {
    uint256 exchangeFloorPrice = _mfcExchangeFloor.getPrice();
    if (tradingPair == TradingPairs.BUSD_MFC) {
      require(price <= exchangeFloorPrice, "Price must be <= exchangeFloorPrice");
    } else if (tradingPair == TradingPairs.MFC_BUSD) {
      require((MULTIPLIER * MULTIPLIER / price) <= exchangeFloorPrice, "Price reciprocal must be <= exchangeFloorPrice");
    } else {
      revert("Unsupported pair");
    }
    BEP20 token = _getSpendingTokenAndCheck(_tradingPairs[tradingPair].makerAssetAddress, quantity);
    uint256 expiresAt = block.timestamp + EXPIRES_IN;
    uint256 id = _nonce++;
    _offers[_msgSender()][id] = Offer(id, tradingPair, quantity, price, expiresAt, true);
    token.transferFrom(_msgSender(), address(this), quantity);
    emit CreateOffer(id, _msgSender(), tradingPair, quantity, price, expiresAt, block.timestamp);
  }

  function tradeOffer(uint256 id, address seller, uint256 quantity)
    external
    onlyValidTradeOffer(id, seller, quantity)
    onlyValidMember(_msgSender())
    returns (TradeOfferCalcInfo memory)
  {
    return _tradeOffer(id, seller, quantity);
  }

  function tradeOffer(uint256 id, address seller, uint256 quantity, uint8 v, bytes32 r, bytes32 s)
    external
    onlyValidTradeOffer(id, seller, quantity)
    onlyValidMember(_msgSender())
    returns (TradeOfferCalcInfo memory)
  {
    // Verify taker asset must be MFC
    TradingPair memory tradingPair = _tradingPairs[_offers[seller][id].tradingPair];
    require(tradingPair.takerAssetAddress == _tradingPairs[TradingPairs.BUSD_MFC].takerAssetAddress, "Must be [BUSD_MFC]");

    MFCToken takerAsset = MFCToken(tradingPair.takerAssetAddress);
    // Call approval
    takerAsset.permit(_msgSender(), address(this), quantity, v, r, s);

    return _tradeOffer(id, seller, quantity);
  }

  function estimateTradeOffer(uint256 id, address seller, uint256 quantity) external view onlyValidTradeOffer(id, seller, quantity) onlyValidMember(_msgSender()) returns (TradeOfferCalcInfo memory) {
    TradingPair memory tradingPair = _tradingPairs[_offers[seller][id].tradingPair];
    uint256 maxInput = _offers[seller][id].quantity * _offers[seller][id].price / MULTIPLIER;
    require(quantity <= maxInput, "Not enough to sell");

    return _calcTradeOffer(tradingPair, quantity, _offers[seller][id].price);
  }

  function _tradeOffer(uint256 id, address seller, uint256 quantity) private returns (TradeOfferCalcInfo memory) {
    TradingPair memory tradingPair = _tradingPairs[_offers[seller][id].tradingPair];
    uint256 maxInput = _offers[seller][id].quantity * _offers[seller][id].price / MULTIPLIER;
    require(quantity <= maxInput, "Not enough to sell");

    TradeOfferCalcInfo memory calc = _executeTrade(tradingPair, seller, quantity, _offers[seller][id].price);

    require(_offers[seller][id].quantity >= calc.amountOut, "Bad calculations");
    _offers[seller][id].quantity -= calc.amountOut;

    // BUSD_MFC market - selling amount in BUSD < MINIMUM_AUTOCLOSE_IN_BUSD
    bool makerCloseout = (tradingPair.makerAssetAddress == _busdAddress && _offers[seller][id].quantity < MINIMUM_AUTOCLOSE_IN_BUSD);
    // MFC_BUSD market - converted selling amount in MFC to BUSD < MINIMUM_AUTOCLOSE_IN_BUSD
    bool takerCloseout = (tradingPair.takerAssetAddress == _busdAddress && _offers[seller][id].quantity * _offers[seller][id].price / MULTIPLIER < MINIMUM_AUTOCLOSE_IN_BUSD);

    if (makerCloseout || takerCloseout) {
      _closeOffer(id, seller); // Auto-close when selling amount in BUSD < MINIMUM_AUTOCLOSE_IN_BUSD
    }

    // For [MFC_BUSD] pair, sellerQuantity = MFC, buyerQuantity = BUSD
    emit TradeOffer(id, _msgSender(), calc.amountOut, quantity, _offers[seller][id].quantity, block.timestamp);

    return calc;
  }

  function closeOffer(uint256 id) external onlyOpenOffer(id, _msgSender()) {
    _closeOffer(id, _msgSender());
  }

  function closeOffer(address seller, uint256 id) external onlyOpenOffer(id, seller) onlyBackendAgents {
    _closeOffer(id, seller);
  }

  function _pairExist(TradingPairs tradingPair) private view returns (bool) {
    return _tradingPairs[tradingPair].makerAssetAddress != address(0);
  }

  function _isOfferActive(uint256 id, address seller) private view returns (bool) {
    return _offers[seller][id].isOpen && _offers[seller][id].expiresAt > block.timestamp;
  }

  function _getSpendingTokenAndCheck(address assetAddress, uint256 quantity) private view returns (BEP20) {
    BEP20 token = BEP20(assetAddress);
    require(token.allowance(_msgSender(), address(this)) >= quantity, "Insufficient allowance");
    require(token.balanceOf(_msgSender()) >= quantity, "Insufficient balance");
    return token;
  }

  function _calcTradeOffer(TradingPair memory tradingPair, uint256 quantity, uint256 price) private pure returns (TradeOfferCalcInfo memory) {
    // Offer is 1,000 MFC at 10.0 BUSD each (10,000 BUSD in total)
    // Taker want to swap 100 BUSD for 10 MFC
    // buyQuantity should be 100 BUSD * (10^18 / 10^19) = 10 MFC
    uint256 buyQuantity = quantity * MULTIPLIER / price;

    TradeOfferCalcInfo memory calc;
    calc.amountOut = buyQuantity;
    calc.makerFee = quantity * tradingPair.makerFeeRate / MULTIPLIER;
    calc.takerFee = buyQuantity * tradingPair.takerFeeRate / MULTIPLIER;
    calc.makerReceives = quantity - calc.makerFee;
    calc.takerReceives = buyQuantity - calc.takerFee;

    return calc;
  }

  // @dev returns maker quantity fulfilled by this trade
  function _executeTrade(TradingPair memory tradingPair, address seller, uint256 quantity, uint256 price) private returns (TradeOfferCalcInfo memory) {
    BEP20 makerAsset = BEP20(tradingPair.makerAssetAddress);
    BEP20 takerAsset = _getSpendingTokenAndCheck(tradingPair.takerAssetAddress, quantity);

    TradeOfferCalcInfo memory calc = _calcTradeOffer(tradingPair, quantity, price);

    takerAsset.transferFrom(_msgSender(), address(this), calc.makerReceives);
    takerAsset.transfer(seller, calc.makerReceives);
    takerAsset.transferFrom(_msgSender(), tradingPair.takerTreasuryAddress, calc.makerFee);
    makerAsset.transfer(_msgSender(), calc.takerReceives);
    makerAsset.transfer(tradingPair.makerTreasuryAddress, calc.takerFee);

    return calc;
  }

  function _closeOffer(uint256 id, address seller) private {
    uint256 remainingQuantity = _offers[seller][id].quantity;
    _offers[seller][id].isOpen = false;
    if (remainingQuantity > 0) {
      _offers[seller][id].quantity = 0;
      BEP20 token = BEP20(_tradingPairs[_offers[seller][id].tradingPair].makerAssetAddress);
      token.transfer(seller, remainingQuantity);
    }
    emit CloseOffer(id, block.timestamp);
  }

  function updateAddresses() public override onlyRegistrar {
    _mfcExchangeFloor = MFCExchangeFloor(_registrar.getMFCExchangeFloor());
    _updateExchangeCheck(_registrar);
    _initTradingPairs();
  }

  function _initTradingPairs() internal {
    address mfcExchangeCap = _registrar.getMFCExchangeCap();
    address mfcToken = _registrar.getMFCToken();
    _tradingPairs[TradingPairs.MFC_BUSD] = TradingPair(mfcToken, _busdAddress, mfcExchangeCap, _busdComptrollerAddress, MFC_FEE, BUSD_FEE);
    _tradingPairs[TradingPairs.BUSD_MFC] = TradingPair(_busdAddress, mfcToken, _busdComptrollerAddress, mfcExchangeCap, BUSD_FEE, MFC_FEE);
  }
}

// SPDX-License-Identifier: MIT
//
// MFCExchangeFloor [BUSD_MFC]
//

pragma solidity ^0.8.4;

import "../lib/token/BEP20/IBEP20.sol";
import "../token/MFCToken.sol";
import "../lib/utils/Context.sol";
import "../treasury/BUSDT.sol";
import "../exchange/MFCExchangeCap.sol";
import "./ExchangeCheck.sol";
import "../RegistrarClient.sol";

contract MFCExchangeFloor is ExchangeCheck, RegistrarClient {

  uint256 public constant MFC_FEE = 20000000000000000;
  uint256 public constant BUSD_FEE = 20000000000000000;
  uint256 public constant MULTIPLIER = 10**18;

  MFCToken private _mfc;
  IBEP20 private _busd;
  BUSDT private _busdt;
  MFCExchangeCap private _mfcExchangeCap;
  address private _deployer;
  uint256 private _initialPrice = 0;

  event TradeOffer(address buyer, uint256 price, uint256 sellerQuantity, uint256 buyerQuantity, uint256 timestamp);

  constructor(
    address registrarAddress_,
    address busdAddress_,
    uint256 initialPrice_
  ) RegistrarClient(registrarAddress_) {
    _busd = IBEP20(busdAddress_);
    _initialPrice = initialPrice_;
    _deployer = _msgSender();
  }

  modifier onlyDeployer() {
    require(_deployer == _msgSender(), "Caller is not the deployer");
    _;
  }

  function getInitialPrice() external view returns (uint256) {
    return _initialPrice;
  }

  function setInitialPrice(uint256 price) external onlyDeployer {
    uint256 mfcCirculation = _mfc.getMfcCirculation();
    require(mfcCirculation == 0, "Can no longer set");
    _initialPrice = price;
  }

  function getPrice() external view returns (uint256) {
    return _getPrice();
  }

  function getAmountOut(uint256 quantity) external view returns (uint256) {
    return _getAmountOut(quantity);
  }

  function tradeOffer(uint256 quantity, uint256 minimumOut) external onlyValidMember(_msgSender()) {
    require(quantity > 0, "Invalid quantity");
    _tradeOffer(quantity, minimumOut);
  }

  function tradeOffer(uint256 quantity, uint256 minimumOut, uint8 v, bytes32 r, bytes32 s) external onlyValidMember(_msgSender()) {
    require(quantity > 0, "Invalid quantity");
    _mfc.permit(_msgSender(), address(this), quantity, v, r, s);
    _tradeOffer(quantity, minimumOut);
  }

  function _tradeOffer(uint256 quantity, uint256 minimumOut) private {
    require(_mfc.allowance(_msgSender(), address(this)) >= quantity, "Insufficient allowance");
    require(_mfc.balanceOf(_msgSender()) >= quantity, "Insufficient balance");
    uint256 price = _getPrice();
    uint256 amountOut = _getAmountOut(quantity);
    require(amountOut >= minimumOut, "Insufficient output amount");

    // uint256 mfcFee = quantity * MFC_FEE / MULTIPLIER;
    // uint256 sellerReceives = quantity - mfcFee;
    uint256 busdFee = amountOut * BUSD_FEE / MULTIPLIER;
    uint256 buyerReceives = amountOut - busdFee;

    _mfc.transferFrom(_msgSender(), address(_mfcExchangeCap), quantity);
    _busdt.floorTransfer(_msgSender(), buyerReceives);

    emit TradeOffer(_msgSender(), price, amountOut, quantity, block.timestamp);
  }

  function updateAddresses() public override onlyRegistrar {
    _mfc = MFCToken(_registrar.getMFCToken());
    _busdt = BUSDT(_registrar.getBUSDT());
    _mfcExchangeCap = MFCExchangeCap(_registrar.getMFCExchangeCap());
    _updateExchangeCheck(_registrar);
  }

  function _getAmountOut(uint256 quantity) private view returns (uint256) {
    uint256 mfcCirculation = _mfc.getMfcCirculation();
    uint256 busdBalance = _busdt.getBusdtValue();
    uint256 amountOut = 0;
    if (mfcCirculation > 0) {
      amountOut = quantity * busdBalance / mfcCirculation;
    } else {
      amountOut = quantity * MULTIPLIER / _initialPrice;
    }
    if (amountOut > busdBalance) {
      amountOut = busdBalance;
    }
    return amountOut;
  }

  function _getPrice() private view returns (uint256) {
    uint256 mfcCirculation = _mfc.getMfcCirculation();
    uint256 busdBalance = _busdt.getBusdtValue();
    if (busdBalance == 0) {
      return 0;
    }
    if (mfcCirculation > 0) {
      return MULTIPLIER * mfcCirculation / busdBalance;
    } else {
      return _initialPrice;
    }
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../../access/AccessControl.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "./IBEP20.sol";

/**
 * @dev Implementation of the {IBEP20} interface.
 * 
 * With an addition of AccessControl:
 * https://docs.openzeppelin.com/contracts/4.x/access-control
 * 
 * Tokens derived from this contract should initiate
 * by calling `_setupRole` to initialize the role for deployer
 * 
 * role can be DEFAULT_ADMIN_ROLE which has access
 * to all roles or you can setup your own role, which
 * require you to call `_setRoleAdmin` to specify
 * which role has grant and revoke access to which role
 */
abstract contract MFCBEP20 is Context, IBEP20, AccessControl {
  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  address private _owner;

  constructor(string memory name_, string memory symbol_, uint8 decimals_) {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
    _owner = _msgSender();
  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external override view returns (address) {
    return _owner;
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external override view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external override view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external override view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external override view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external override view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
    return true;
  }

  /**
   * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   *
   * Requirements
   *
   * - Must be implemented by inherited contract
   */
  function mint(uint256 amount) public virtual returns (bool);

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] -= amount;
    _balances[recipient] += amount;
    emit Transfer(sender, recipient, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] -= amount;
    _totalSupply -= amount;
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()] - amount);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./lib/utils/Context.sol";
import "./Registrar.sol";
import "./access/AdminAgent.sol";

abstract contract RegistrarMigrator is Context, AdminAgent {

  address private _migrationDestination;
  Registrar private _registrar;

  constructor(address registrar_, address[] memory adminAgents_) AdminAgent(adminAgents_) {
    _registrar = Registrar(registrar_);
  }

  modifier onlyUnfinalized() {
    require(_registrar.isFinalized() == false, "Registrar already finalized");
    _;
  }

  function getRegistrarMigrateDestination() public view returns(address) {
    return _migrationDestination;
  }

  function setRegistrarMigrateDestination(address destination) external onlyAdminAgents onlyUnfinalized {
    _migrationDestination = destination;
  }

  function registrarMigrate(uint256 amount) external onlyAdminAgents onlyUnfinalized {
    require(_migrationDestination != address(0), "Migration destination is not set");
    _registrarMigrate(amount);
  }

  // All subclasses must implement this function
  function _registrarMigrate(uint256 amount) internal virtual;
}

// SPDX-License-Identifier: MIT

import "./RegistrarClient.sol";

pragma solidity ^0.8.4;

contract MFCBuyback is IRegistrarClient {
  // This contract is no longer needed and has been deprecated. It has been replaced with this non-functional stub contract.
  constructor() {}

  // Since Registrar contract cannot be modified, leave dummy stub updateAddresses method below.
  function updateAddresses() public override {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../governance/Governable.sol";

contract GovernableTest is Governable {

  constructor(
    address governanceAddress
  ) {
    _governanceAddress = governanceAddress;
  }

  function protectedFunction() external onlyGovernance {
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../RegistrarMigrator.sol";

contract RegistrarMigratorTest is RegistrarMigrator {

  constructor(address registrar, address[] memory adminAgents) RegistrarMigrator(registrar, adminAgents) {
  }

  function _registrarMigrate(uint256 amount) internal override {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../access/BackendAgent.sol";

contract BackendAgentTest is BackendAgent {

  constructor(
    address[] memory adminAgents,
    address[] memory backendAgents
  ) {
    _setBackendAdminAgents(adminAgents);
    _setBackendAgents(backendAgents);
  }

  function protectedFunction() external onlyBackendAgents {
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../token/MFCToken.sol";

contract MFCTokenTest is MFCToken {

  // MFCToken MINTER_ROLE is private
  // Declare this variable again because don't want to change anything to MFCToken contract
  bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");

  constructor(
    string memory name,
    string memory symbol,
    address registrarAddress_,
    address[] memory adminAgents_,
    address[] memory backendAdminAgents_,
    address[] memory backendAgents_
  ) MFCToken(name, symbol, registrarAddress_, adminAgents_, backendAdminAgents_, backendAgents_) {
  }

  // ONLY FOR TESTING - unit tests are using this method to mint to minter
  function mintToMinter(uint256 amount) external onlyRole(MINTER_ROLE) returns (bool) {
    require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
    super._mint(_msgSender(), amount);
    return true;
  }

  // ONLY FOR TESTING - vote.ts is the only file that is using mintTo
  function mintTo(address recipient, uint256 amount) external onlyRole(MINTER_ROLE) onlyTransferable(_msgSender(), recipient) returns (bool) {
    require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
    super._mint(recipient, amount);
    return true;
  }

  function increaseMfcCirculation(uint256 quantity) external {
    _increaseMfcCirculation(quantity);
  }

  function decreaseMfcCirculation(uint256 quantity) external {
    _decreaseMfcCirculation(quantity);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../lib/token/BEP20/MFCBEP20.sol";

contract MFCBEP20TestDefaultRole is MFCBEP20 {

  bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 private constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor(
    string memory name,
    string memory symbol,
    uint256 initialSupply,
    uint8 decimals
  ) MFCBEP20(name, symbol, decimals) {
    // no need to _setRoleAdmin for MINTER_ROLE and SIGNER_ROLE because by default, all roles has DEFAULT_ADMIN_ROLE as an admin
    // setup deployer to be part of DEFAULT_ADMIN_ROLE which allow deployer to manage all roles
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    // initial mint
    _mint(_msgSender(), initialSupply);
  }

  function mint(uint256 amount) public override onlyRole(MINTER_ROLE) returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  function hasMinterRole(address _address) public view returns (bool) {
    return hasRole(MINTER_ROLE, _address);
  }

  function hasSignerRole(address _address) public view returns (bool) {
    return hasRole(SIGNER_ROLE, _address);
  }

  function grantMinterRole(address _address) public onlyRole(DEFAULT_ADMIN_ROLE) {
    grantRole(MINTER_ROLE, _address);
  }

  function grantSignerRole(address _address) public onlyRole(DEFAULT_ADMIN_ROLE) {
    grantRole(SIGNER_ROLE, _address);
  }

  function revokeMinterRole(address _address) public onlyRole(DEFAULT_ADMIN_ROLE) {
    revokeRole(MINTER_ROLE, _address);
  }

  function revokeSignerRole(address _address) public onlyRole(DEFAULT_ADMIN_ROLE) {
    revokeRole(SIGNER_ROLE, _address);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../lib/token/BEP20/MFCBEP20.sol";

contract MFCBEP20Test is MFCBEP20 {

  bytes32 private constant OWNER_ROLE = keccak256("OWNER_ROLE");
  bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 private constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor(
    string memory name,
    string memory symbol,
    uint256 initialSupply,
    uint8 decimals
  ) MFCBEP20(name, symbol, decimals) {
    // make OWNER_ROLE the admin role for each role (only people with the role of an admin role can manage that role)
    _setRoleAdmin(MINTER_ROLE, OWNER_ROLE);
    _setRoleAdmin(SIGNER_ROLE, OWNER_ROLE);
    // setup deployer to be part of OWNER_ROLE which allow deployer to manage all roles
    _setupRole(OWNER_ROLE, _msgSender());
    // initial mint
    _mint(_msgSender(), initialSupply);
  }

  function mint(uint256 amount) public override onlyRole(MINTER_ROLE) returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  function hasMinterRole(address _address) public view returns (bool) {
    return hasRole(MINTER_ROLE, _address);
  }

  function hasSignerRole(address _address) public view returns (bool) {
    return hasRole(SIGNER_ROLE, _address);
  }

  function grantMinterRole(address _address) public onlyRole(OWNER_ROLE) {
    grantRole(MINTER_ROLE, _address);
  }

  function grantSignerRole(address _address) public onlyRole(OWNER_ROLE) {
    grantRole(SIGNER_ROLE, _address);
  }

  function revokeMinterRole(address _address) public onlyRole(OWNER_ROLE) {
    revokeRole(MINTER_ROLE, _address);
  }

  function revokeSignerRole(address _address) public onlyRole(OWNER_ROLE) {
    revokeRole(SIGNER_ROLE, _address);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../lib/token/BEP20/BEP20.sol";

contract BUSD is BEP20 {
  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor(
      string memory name,
      string memory symbol,
      uint8 decimals,
      uint256 initialSupply
  ) BEP20(name, symbol, decimals) {
      _mint(_msgSender(), initialSupply);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../lib/token/BEP20/BEP20.sol";
import "../lib/utils/Context.sol";

contract WithdrawAgent is Context {

  mapping(address => bool) private _withdrawAdminAgents;
  mapping(address => bool) private _withdrawAgents;
  BEP20 private _token;

  event SetWithdrawAgent(address agent);
  event RevokeWithdrawAgent(address agent);
  event Withdraw(address recipient, uint256 amount, BEP20 token);

  constructor(
    address tokenContractAddress_
  ) {
    _token = BEP20(tokenContractAddress_);
  }

  modifier onlyWithdrawAdminAgents() virtual {
    require(_withdrawAdminAgents[_msgSender()], "Unauthorized");
    _;
  }

  modifier onlyWithdrawAgents() {
    require(_withdrawAgents[_msgSender()], "Unauthorized");
    _;
  }

  function _setWithdrawAgents(address[] memory withdrawAgents_) internal {
    for (uint i = 0; i < withdrawAgents_.length; i++) {
      _withdrawAgents[withdrawAgents_[i]] = true;
    }
  }

  function _setWithdrawAdminAgents(address[] memory withdrawAdminAgents_) internal {
    for (uint i = 0; i < withdrawAdminAgents_.length; i++) {
      _withdrawAdminAgents[withdrawAdminAgents_[i]] = true;
    }
  }

  function setWithdrawAgent(address _agent) external onlyWithdrawAdminAgents {
    _withdrawAgents[_agent] = true;
    emit SetWithdrawAgent(_agent);
  }

  function revokeWithdrawAgent(address _agent) external onlyWithdrawAdminAgents {
    _withdrawAgents[_agent] = false;
    emit RevokeWithdrawAgent(_agent);
  }

  function withdraw(uint256 amount) virtual external onlyWithdrawAgents {
    _withdrawTo(_msgSender(), amount);
  }

  function withdrawTo(address recipient, uint256 amount) virtual external onlyWithdrawAgents {
    _withdrawTo(recipient, amount);
  }

  function _withdrawTo(address recipient, uint256 amount) internal {
    require(_token.balanceOf(address(this)) >= amount, "Insufficient balance");
    _token.transfer(recipient, amount);
    emit Withdraw(recipient, amount, _token);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../access/WithdrawAgent.sol";

contract WithdrawAgentTest is WithdrawAgent {

  constructor(
    address tokenContractAddress,
    address[] memory adminAgents,
    address[] memory withdrawAgents
  ) WithdrawAgent(tokenContractAddress) {
    _setWithdrawAgents(withdrawAgents);
    _setWithdrawAdminAgents(adminAgents);
  }

  function protectedFunction() external onlyWithdrawAgents {
  }
}