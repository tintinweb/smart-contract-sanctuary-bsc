// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./libs/dgg/Auth.sol";
import "./libs/zeppelin/token/BEP20/IBEP20.sol";

contract AutoTransfer is Auth {

  struct Receiver {
    uint percent;
    uint totalUsdtAmount;
    uint totalBusdAmount;
  }

  IBEP20 public usdtToken;
  IBEP20 public busdToken;

  uint public oneHundredPercentInDecimal3;
  address[] public receiverAddresses;
  mapping(address => Receiver) public receivers;

  enum USDCurrency {
    busd,
    usdt
  }

  event DidSetupAddress(address[] addresses, uint[] percent);

  function initializeAutoTransfer(address _usdtAddress, address _busdAddress) virtual public initializer {
    initialize(msg.sender);
    usdtToken = IBEP20(_usdtAddress);
    busdToken = IBEP20(_busdAddress);
    oneHundredPercentInDecimal3 = 100000;
  }

  function setupAddress(address[] calldata _addresses, uint[] calldata _percent) external onlyMainAdmin {
    _validateSetupAddressData(_addresses, _percent);

    receiverAddresses = _addresses;

    for(uint i = 0; i < _addresses.length; i += 1) {
      address receiverAddress = _addresses[i];
      uint receiverPercent = _percent[i];

      receivers[receiverAddress] = Receiver(receiverPercent, 0, 0);
    }


    emit DidSetupAddress(_addresses, _percent);
  }

  function splitToken() external onlyContractAdmin {
    uint usdtBalance = usdtToken.balanceOf(address(this));
    uint busdBalance = busdToken.balanceOf(address(this));

    for (uint i = 0; i < receiverAddresses.length; i += 1) {
      Receiver storage receiver = receivers[receiverAddresses[i]];

      if (usdtBalance > 0) {
        uint amount = usdtBalance * receiver.percent / oneHundredPercentInDecimal3;
        _transferToken(receiverAddresses[i], amount, USDCurrency.usdt);
      }

      if (busdBalance > 0) {
        uint amount = busdBalance * receiver.percent / oneHundredPercentInDecimal3;
        _transferToken(receiverAddresses[i], amount, USDCurrency.busd);
      }
    }
  }

  // Private functions

  function _validateSetupAddressData(address[] memory _addresses, uint[] memory _percent) private view {
    require(_addresses.length == _percent.length, "AutoTransfer: invalid input data.");

    uint totalPercentage = 0;

    for (uint i = 0; i < _addresses.length; i += 1) {
      uint percent = _percent[i];
      require(_addresses[i] != address(0), "AutoTransfer: invalid address.");
      require(percent <= oneHundredPercentInDecimal3, "AutoTransfer: percent must be less than or equal 100000.");
      totalPercentage += percent;
    }

    require(totalPercentage == oneHundredPercentInDecimal3, "AutoTransfer: invalid input percent data.");
  }

  function _transferToken(address _address, uint _amount, USDCurrency _usdCurrency) private {
    IBEP20 usdToken = _usdCurrency == USDCurrency.busd ? busdToken : usdtToken;
    Receiver storage receiver = receivers[_address];

    require(usdToken.balanceOf(address(this)) >= _amount, "AutoTransfer: balance is low.");
    require(usdToken.transfer(_address, _amount), "AutoTransfer: transfer usd token failed.");

    if (_usdCurrency == USDCurrency.busd) {
      receiver.totalBusdAmount += _amount;
    } else {
      receiver.totalUsdtAmount += _amount;
    }
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