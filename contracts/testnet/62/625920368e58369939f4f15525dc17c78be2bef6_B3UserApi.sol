// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {Owned} from "lib/solmate/src/auth/Owned.sol";
import {IB3UserApi} from "./interfaces/IB3UserApi.sol";

contract B3UserApi is IB3UserApi, Owned {
  uint256 constant HUNDRED = 100_00; // 100% with 2 decimal places
  uint16 public maxDeviation = 10_00;
  uint16 public minDeviation = 10;
  uint16 public basePercent = 5_00;
  bytes6 public defaultData = 0x000000000000;

  mapping(address => UserConfig) public users;

  constructor(address owner_) Owned(owner_) {}

  // Modify By User functions ---------------------------------------------
  function register(
    uint16 devPercent,
    uint16 taxPercent,
    address taxRecipient
  ) external payable override {
    address user = msg.sender;
    if (isUserRegistered(user)) revert UserAlreadyRegistered(user);

    if (devPercent < minDeviation) revert DeviationTooLow(devPercent);
    if (devPercent > maxDeviation) revert DeviationTooHigh(devPercent);

    if (taxPercent > 0) {
      if (taxRecipient == address(0)) revert TaxRecipientNotZero();
      if (taxPercent > HUNDRED) revert TaxTooHigh(taxPercent);
    }

    users[user] = UserConfig(
      basePercent,
      devPercent,
      taxPercent,
      taxRecipient,
      defaultData
    );

    emit Register(user, taxRecipient, taxPercent, msg.value);
  }

  function unregister() external override {
    address user = msg.sender;

    if (!isUserRegistered(user)) revert InvalidUser(user);

    delete users[user];

    emit Unregister(user);
  }

  function changeConfig(
    uint16 devPercent,
    uint16 taxPercent,
    address taxRecipient
  ) external override {
    address user = msg.sender;

    if (!isUserRegistered(user)) revert InvalidUser(user);

    if (devPercent > HUNDRED) revert DeviationTooHigh(devPercent);
    if (taxPercent > HUNDRED) revert TaxTooHigh(taxPercent);

    users[user].devPercent = devPercent;
    users[user].taxPercent = taxRecipient == address(0) ? 0 : taxPercent;
    users[user].taxRecipient = taxRecipient;
  }

  // Modify By Owner functions --------------------------------------------
  function changeMaxDev(uint16 percent) external onlyOwner {
    maxDeviation = percent;
  }

  function changeMinDev(uint16 percent) external onlyOwner {
    minDeviation = percent;
  }

  function changeBasePercent(uint16 percent) external onlyOwner {
    basePercent = percent;
  }

  function changeDefaultData(bytes6 data) external onlyOwner {
    defaultData = data;
  }

  function changeUserFee(address user, uint16 percent) external onlyOwner {
    users[user].feePercent = percent;
  }

  function changeUserData(address user, bytes6 data) external onlyOwner {
    users[user].data = data;
  }

  function registerUser(
    address user,
    uint16 feePercent,
    uint16 devPercent,
    uint16 taxPercent,
    address taxRecipient,
    bytes6 data
  ) external payable onlyOwner {
    if (users[user].feePercent == 0) {
      emit Register(user, taxRecipient, taxPercent, msg.value);
    }
    users[user] = UserConfig(feePercent, devPercent, taxPercent, taxRecipient, data);
  }

  function unregisterUser(address user) external onlyOwner {
    delete users[user];

    emit Unregister(user);
  }

  // View functions ------------------------------------------------------------
  function isUserRegistered(address user) public view override returns (bool) {
    return users[user].feePercent > 0;
  }

  function getUserConfig(
    address user
  ) external view override returns (uint256, uint256, uint256, address) {
    UserConfig storage config = users[user];
    if (config.feePercent == 0) revert InvalidUser(user);

    return (config.feePercent, config.devPercent, config.taxPercent, config.taxRecipient);
  }

  function getUserDeviation(address user) public view override returns (uint256) {
    return users[user].devPercent;
  }

  function getUserData(address user) public view override returns (bytes6) {
    return users[user].data;
  }

  // Transfer functions --------------------------------------
  function withdrawETH(uint256 value) external onlyOwner {
    payable(owner).transfer(value);
  }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

interface IB3UserApi {
  error InvalidUser(address user);

  error UserAlreadyRegistered(address user);
  error RegisterationFeeTooLow(uint256 fee);
  error DeviationTooHigh(uint256 percent);
  error DeviationTooLow(uint256 percent);
  error TaxTooHigh(uint256 percent);
  error TaxRecipientNotZero();

  event Register(
    address indexed user,
    address indexed taxReceipt,
    uint256 taxPercent,
    uint256 value
  );
  event Unregister(address indexed user);

  struct UserConfig {
    uint16 feePercent;
    uint16 devPercent;
    uint16 taxPercent;
    address taxRecipient;
    bytes6 data;
  }

  function isUserRegistered(address user) external view returns (bool);

  function changeConfig(
    uint16 devPercent,
    uint16 taxPercent,
    address taxRecipient
  ) external;

  function register(
    uint16 devPercent,
    uint16 taxPercent,
    address taxRecipient
  ) external payable;

  function unregister() external;

  function getUserConfig(
    address user
  )
    external
    view
    returns (
      uint256 feePercent,
      uint256 devPercent,
      uint256 taxPercent,
      address taxRecipient
    );

  function getUserDeviation(address user) external view returns (uint256);

  function getUserData(address user) external view returns (bytes6);
}

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}