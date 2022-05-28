// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

import "../interfaces/IFOTAGame.sol";
import "../libs/fota/Auth.sol";

contract GameProxy is Auth {

  IFOTAGame public gamePve;
  IFOTAGame public gamePvp;
  IFOTAGame public gameDual;

  function initialize(address _mainAdmin, address _pve, address _pvp, address _dual) public initializer {
    super.initialize(_mainAdmin);
    gamePve = IFOTAGame(_pve);
    gamePvp = IFOTAGame(_pvp);
    gameDual = IFOTAGame(_dual);
  }

  function validateInviter(address _inviter) external pure returns (bool) {
    return _inviter != address(0);
  }

  function getTotalPVEWinInDay(address _user) external view returns (uint) {
    return gamePve.totalWinInDay(_user);
  }

  function getTotalPVPWinInDay(address _user) external view returns (uint) {
    return gamePvp.totalWinInDay(_user);
  }

  function getTotalDUALWinInDay(address _user) external view returns (uint) {
    return gameDual.totalWinInDay(_user);
  }

  function totalMissions() external view returns (uint) {
    return gamePve.totalMissions();
  }

  function setGameAddresses(address _pve, address _pvp, address _dual) external onlyMainAdmin {
    require(_pve != address(0) && _pvp != address(0) && _dual != address(0), "Invalid address");
    gamePve = IFOTAGame(_pve);
    gamePvp = IFOTAGame(_pvp);
    gameDual = IFOTAGame(_dual);
  }

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

// SPDX-License-Identifier: GPL

pragma solidity 0.8.0;

interface IFOTAGame {
  function validateInviter(address _inviter) external view returns (bool);
  function totalWinInDay(address _user) external view returns (uint);
  function getTotalPVEWinInDay(address _user) external view returns (uint);
  function getTotalPVPWinInDay(address _user) external view returns (uint);
  function getTotalDUALWinInDay(address _user) external view returns (uint);
  function getLandLord(uint _mission) external view returns (address);
  function totalMissions() external view returns (uint);
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