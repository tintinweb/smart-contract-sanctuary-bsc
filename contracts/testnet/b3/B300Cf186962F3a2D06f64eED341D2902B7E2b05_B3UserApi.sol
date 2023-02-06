// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IB3UserApi.sol";

contract B3UserApi is IB3UserApi, Ownable {
  uint16 public maxDeviation = 10_00;
  uint16 public minDeviation = 10;
  uint16 public basePercent = 5_00;
  bytes6 public defaultData = 0x000000000000;

  mapping(address => UserConfig) public users;

  // Modify By User functions ---------------------------------------------
  function register(
    uint16 devPercent,
    uint16 taxPercent,
    address taxRecipient
  ) external payable override {
    address user = _msgSender();
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
    address user = _msgSender();

    if (!isUserRegistered(user)) revert InvalidUser(user);

    delete users[user];

    emit Unregister(user);
  }

  function changeConfig(
    uint16 devPercent,
    uint16 taxPercent,
    address taxRecipient
  ) external override {
    address user = _msgSender();

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

  function getUserConfig(address user)
    external
    view
    override
    returns (
      uint256,
      uint256,
      uint256,
      address
    )
  {
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
    payable(owner()).transfer(value);
  }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

uint256 constant HUNDRED = 100_00; // 100% with 2 decimal places

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

  function getUserConfig(address user)
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