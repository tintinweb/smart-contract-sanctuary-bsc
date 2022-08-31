// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "./libs/fota/Auth.sol";
import "./libs/zeppelin/token/BEP20/IBEP20.sol";

contract Salary is Auth {

  struct Member {
    uint amount;
    uint startClaimingTime;
    uint totalClaimingTime;
    uint endClaimingTime;
    uint lastClaimed;
    uint totalClaimed;
    bool locked;
  }
  mapping(address => Member) public members;
  IBEP20 public fotaToken;

  event MemberSet(address indexed member, uint amount, uint totalClaimingTime);
  event MemberUpdated(address indexed member, uint amount, uint totalClaimingTime);
  event MemberLockStatusUpdated(address indexed member, bool status);
  event Claimed(address indexed member, uint amount, uint timestamp);
  event Withdrew(address indexed user, uint amount, uint timestamp);

  function initialize(address _fotaToken) override public initializer {
    Auth.initialize(msg.sender);
    fotaToken = IBEP20(_fotaToken);
  }

  function setupMember(address _member, uint _amount, uint _totalClaimingTime) external onlyMainAdmin {
    require(members[_member].startClaimingTime == 0, "Salary: member has setup already");
    members[_member] = Member(_amount, block.timestamp, _totalClaimingTime, block.timestamp + _totalClaimingTime, block.timestamp, 0, false);
    emit MemberSet(_member, _amount, _totalClaimingTime);
  }

  function updateMember(address _member, uint _amount, uint _totalClaimingTime) external onlyMainAdmin {
    Member storage member = members[_member];
    require(member.startClaimingTime > 0, "Salary: member not found");
    require(member.lastClaimed == member.startClaimingTime, "Salary: member has started the claiming");
    member.amount = _amount;
    member.totalClaimingTime = _totalClaimingTime;
    member.endClaimingTime = member.startClaimingTime + _totalClaimingTime;
    emit MemberUpdated(_member, _amount, _totalClaimingTime);
  }

  function updateMemberLockStatus(address _member, bool _locked) external onlyMainAdmin {
    members[_member].locked = _locked;
    emit MemberLockStatusUpdated(_member, _locked);
  }

  function claim() external {
    Member storage member = members[msg.sender];
    require(member.startClaimingTime > 0, "Salary: member not found");
    require(!member.locked, "Salary: member locked");
    uint claimablePerSecond = _calculateMemberClaimablePerSecond(member);
    uint claimableSeconds = block.timestamp < member.endClaimingTime ? block.timestamp - member.lastClaimed : member.endClaimingTime - member.lastClaimed;
    uint claimableAmount = claimablePerSecond * claimableSeconds;
    member.lastClaimed = block.timestamp;
    member.totalClaimed += claimableAmount;
    require(fotaToken.balanceOf(address(this)) >= claimableAmount, "Salary: insufficient balance");
    require(member.totalClaimed <= member.amount, "Salary: amount invalid");
    require(fotaToken.transfer(msg.sender, claimableAmount), "Salary: transfer token failed");

    emit Claimed(msg.sender, claimableAmount, block.timestamp);
  }

  function withdraw(address _tokenAddress, uint _amount) external onlyMainAdmin {
    IBEP20 token = IBEP20(_tokenAddress);
    require(_amount <= token.balanceOf(address(this)), "Salary: amount invalid");
    require(token.transfer(msg.sender, _amount), "Salary: transfer token failed");

    emit Withdrew(msg.sender, _amount, block.timestamp);
  }

  function _calculateMemberClaimablePerSecond(Member memory _member) private pure returns (uint) {
    return _member.amount / _member.totalClaimingTime;
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