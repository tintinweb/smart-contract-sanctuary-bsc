// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../common/OwnPauseBase.sol";
import "../common/IAgencyNFT.sol";

contract PrivacyStorage is OwnPauseBase {
  address public _passportContractAddress;

  address public _stampContractAddress;

  // tokenId => string of private data string in form of JSON
  mapping(uint256 => string) private _passportTokenId_data;

  // tokenId => string of private data string in form of JSON
  mapping(uint256 => string) private _stampTokenId_data;

  event EvtSetPassportContractAddress(address passportContractAddress);
  event EvtSetStampContractAddress(address stampContractAddress);
  event EvtSetPassportTokenIdPrivateData(uint256 tokenId, string privateData);
  event EvtSetStampTokenIdPrivateData(uint256 tokenId, string privateData);

  event EvtViewPassportTokenIdPrivateData(uint256 tokenId, string privateData);
  event EvtViewStampTokenIdPrivateData(uint256 tokenId, string privateData);

  constructor(address passportContractAddress_, address stampContractAddress_) {
    _passportContractAddress = passportContractAddress_;
    _stampContractAddress = stampContractAddress_;
  }

  function setPassportContractAddress(address passportContractAddress_)
    external
    isOwner
  {
    _passportContractAddress = passportContractAddress_;

    emit EvtSetPassportContractAddress(passportContractAddress_);
  }

  function setStampContractAddress(address stampContractAddress_)
    external
    isOwner
  {
    _stampContractAddress = stampContractAddress_;

    emit EvtSetStampContractAddress(stampContractAddress_);
  }

  function setPassportTokenIdPrivateData(
    uint256 tokenId_,
    string memory privateData_
  ) external isAuthorized {
    require(
      IAgencyNFT(_passportContractAddress).tokenExists(tokenId_),
      "tokenId not exist"
    );
    _passportTokenId_data[tokenId_] = privateData_;

    emit EvtSetPassportTokenIdPrivateData(tokenId_, privateData_);
  }

  function setStampTokenIdPrivateData(
    uint256 tokenId_,
    string memory privateData_
  ) external isAuthorized {
    require(
      IAgencyNFT(_stampContractAddress).tokenExists(tokenId_),
      "tokenId not exist"
    );
    _stampTokenId_data[tokenId_] = privateData_;

    emit EvtSetStampTokenIdPrivateData(tokenId_, privateData_);
  }

  // Calling this view function results in tx
  function viewPassportTokenIdPrivateData(uint256 tokenId_)
    external
    isAuthorized
  {
    emit EvtViewPassportTokenIdPrivateData(
      tokenId_,
      _passportTokenId_data[tokenId_]
    );
  }

  // Calling this view function results in tx
  function viewStampTokenIdPrivateData(uint256 tokenId_) external isAuthorized {
    emit EvtViewStampTokenIdPrivateData(tokenId_, _stampTokenId_data[tokenId_]);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract OwnPauseBase is Ownable, Pausable {
  mapping(address => bool) public _authorizedAddressList;

  event EvtRevokeAuthorized(address auth_);
  event EvtGrantAuthorized(address auth_);
  
  modifier isAuthorized() {
    require(
      msg.sender == owner() || _authorizedAddressList[msg.sender] == true,
      "not authorized"
    );
    _;
  }

  modifier isOwner() {
    require(msg.sender == owner(), "not owner");
    _;
  }

  function grantAuthorized(address auth_) external isOwner {
    _authorizedAddressList[auth_] = true;
    emit EvtGrantAuthorized(auth_);
  }

  function revokeAuthorized(address auth_) external isOwner {
    _authorizedAddressList[auth_] = false;
    emit EvtRevokeAuthorized(auth_);
  }

  function checkAuthorized(address auth_) public view returns (bool) {
    return auth_ == owner() || _authorizedAddressList[auth_] == true;
  }

  function unpause() external isOwner {
    _unpause();
  }

  function pause() external isOwner {
    _pause();
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IAgencyNFT {
  function tokenExists(uint256 tokenId_) external view returns (bool);
}