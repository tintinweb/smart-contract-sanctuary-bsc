// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "../common/OwnPauseBase.sol";
import "../common/IAgencyNFT.sol";
import "../passport/IPassportCNFT.sol";

contract DataStorage is OwnPauseBase {
  address public _passportContractAddress;

  address public _stampContractAddress;

  string public _delimiter = "===";

  // tokenId => string of private data string (encrypted)
  mapping(uint256 => string) private _passportTokenId_privateData;

  // tokenId => string of public data string
  mapping(uint256 => string) public _passportTokenId_publicData;

  // tokenId => string of private data string (encrypted)
  mapping(uint256 => string) private _stampTokenId_privateData;

  // tokenId => string of public data string
  mapping(uint256 => string) public _stampTokenId_publicData;

  event EvtSetPassportContractAddress(address passportContractAddress);
  event EvtSetStampContractAddress(address stampContractAddress);

  event EvtSetTokenIdPrivateData(uint256 tokenId, bool isForPassport);
  event EvtDeleteTokenIdPrivateData(uint256 tokenId, bool isForPassport);
  event EvtDeleteTokenIdPrivateDataMany(
    uint256[] tokenIdList,
    bool isForPassport
  );

  event EvtSetTokenIdDataVisibility(
    uint256 tokenId,
    bool isPublic,
    bool isForPassport
  );
  event EvtSetTokenIdDataVisibilityMany(
    uint256[] tokenIdList,
    bool isPublic,
    bool isForPassport
  );

  event EvtViewPassportTokenIdPrivateData(uint256 tokenId, string privateData);
  event EvtViewPassportTokenIdPrivateDataMany(
    uint256[] tokenIdList,
    string privateData
  );
  event EvtViewPassportTokenIdPublicDataMany(
    uint256[] tokenIdList,
    string publicData
  );

  event EvtViewStampTokenIdPrivateData(uint256 tokenId, string privateData);
  event EvtViewStampTokenIdPrivateDataMany(
    uint256[] tokenIdList,
    string privateData
  );
  event EvtViewStampTokenIdPublicDataMany(
    uint256[] tokenIdList,
    string publicData
  );

  constructor(address passportContractAddress_, address stampContractAddress_) {
    _passportContractAddress = passportContractAddress_;
    _stampContractAddress = stampContractAddress_;
  }

  function setPassportContractAddress(address passportContractAddress_)
    external
    isOwner
  {
    require(
      passportContractAddress_ != address(0),
      "Invalid passportContractAddress_"
    );
    _passportContractAddress = passportContractAddress_;

    emit EvtSetPassportContractAddress(passportContractAddress_);
  }

  function setStampContractAddress(address stampContractAddress_)
    external
    isOwner
  {
    require(
      stampContractAddress_ != address(0),
      "Invalid stampContractAddress_"
    );
    _stampContractAddress = stampContractAddress_;

    emit EvtSetStampContractAddress(stampContractAddress_);
  }

  function setTokenIdPrivateData(
    uint256 tokenId_,
    string memory privateData_,
    bool isForPassport_
  ) external whenNotPaused isAuthorized {
    if (isForPassport_) {
      require(
        IAgencyNFT(_passportContractAddress).tokenExists(tokenId_),
        "tokenId not exist"
      );
      _passportTokenId_privateData[tokenId_] = privateData_;
    } else {
      require(
        IAgencyNFT(_stampContractAddress).tokenExists(tokenId_),
        "tokenId not exist"
      );
      _stampTokenId_privateData[tokenId_] = privateData_;
    }

    // Do not include the "privateData_" in the emitted Event
    emit EvtSetTokenIdPrivateData(tokenId_, isForPassport_);
  }

  function deleteTokenIdPrivateData(uint256 tokenId_, bool isForPassport_)
    external
    whenNotPaused
    isAuthorized
  {
    if (isForPassport_) {
      // No need to check if token exists
      delete _passportTokenId_privateData[tokenId_];
    } else {
      // No need to check if token exists
      delete _stampTokenId_privateData[tokenId_];
    }

    emit EvtDeleteTokenIdPrivateData(tokenId_, isForPassport_);
  }

  function deleteTokenIdPrivateDataMany(
    uint256[] memory tokenIdList_,
    bool isForPassport_
  ) external whenNotPaused isAuthorized {
    if (isForPassport_) {
      for (uint256 i = 0; i < tokenIdList_.length; i++) {
        // No need to check if token exists
        delete _passportTokenId_privateData[tokenIdList_[i]];
      }
    } else {
      for (uint256 i = 0; i < tokenIdList_.length; i++) {
        // No need to check if token exists
        delete _stampTokenId_privateData[tokenIdList_[i]];
      }
    }

    emit EvtDeleteTokenIdPrivateDataMany(tokenIdList_, isForPassport_);
  }

  function setTokenIdDataVisibility(
    uint256 tokenId_,
    bool isPublic_,
    bool isForPassport_
  ) external whenNotPaused {
    if (isForPassport_) {
      require(
        checkAuthorized(msg.sender) ||
          IAgencyNFT(_passportContractAddress).ownerOf(tokenId_) == msg.sender,
        "not authorized or not token owner"
      );

      // make data public
      if (isPublic_) {
        // Copy from private to public storage
        _passportTokenId_publicData[tokenId_] = _passportTokenId_privateData[
          tokenId_
        ];

        // Delete away the private
        delete _passportTokenId_privateData[tokenId_];
      } else {
        // make data private
        // Copy from public to private storage
        _passportTokenId_privateData[tokenId_] = _passportTokenId_publicData[
          tokenId_
        ];

        // Delete away the public
        delete _passportTokenId_publicData[tokenId_];
      }
    } else {
      // Get the passport tokenId from the stamp tokenId
      uint256 passportTokenId = IPassportCNFT(_passportContractAddress)
        ._composedNFT_parentTokenId(tokenId_, _stampContractAddress);

      require(
        checkAuthorized(msg.sender) ||
          IAgencyNFT(_stampContractAddress).ownerOf(tokenId_) == msg.sender ||
          (passportTokenId > 0 &&
            IAgencyNFT(_passportContractAddress).ownerOf(passportTokenId) ==
            msg.sender),
        "not authorized or not token owner"
      );

      if (isPublic_) {
        // Copy from private to public storage
        _stampTokenId_publicData[tokenId_] = _stampTokenId_privateData[
          tokenId_
        ];

        // Delete away the private
        delete _stampTokenId_privateData[tokenId_];
      } else {
        // make data private
        // Copy from public to private storage
        _stampTokenId_privateData[tokenId_] = _stampTokenId_publicData[
          tokenId_
        ];

        // Delete away the public
        delete _stampTokenId_publicData[tokenId_];
      }
    }

    emit EvtSetTokenIdDataVisibility(tokenId_, isPublic_, isForPassport_);
  }

  function setTokenIdDataVisibilityMany(
    uint256[] memory tokenIdList_,
    bool isPublic_,
    bool isForPassport_
  ) external whenNotPaused isAuthorized {
    if (isForPassport_) {
      // make data public
      if (isPublic_) {
        for (uint256 i = 0; i < tokenIdList_.length; i++) {
          // Copy from private to public storage
          _passportTokenId_publicData[
            tokenIdList_[i]
          ] = _passportTokenId_privateData[tokenIdList_[i]];

          // Delete away the private
          delete _passportTokenId_privateData[tokenIdList_[i]];
        }
      } else {
        // make data private
        for (uint256 i = 0; i < tokenIdList_.length; i++) {
          // Copy from public to private storage
          _passportTokenId_privateData[
            tokenIdList_[i]
          ] = _passportTokenId_publicData[tokenIdList_[i]];

          // Delete away the public
          delete _passportTokenId_publicData[tokenIdList_[i]];
        }
      }
    } else {
      // make data public
      if (isPublic_) {
        for (uint256 i = 0; i < tokenIdList_.length; i++) {
          // Copy from private to public storage
          _stampTokenId_publicData[tokenIdList_[i]] = _stampTokenId_privateData[
            tokenIdList_[i]
          ];

          // Delete away the private
          delete _stampTokenId_privateData[tokenIdList_[i]];
        }
      } else {
        // make data private
        for (uint256 i = 0; i < tokenIdList_.length; i++) {
          // Copy from public to private storage
          _stampTokenId_privateData[tokenIdList_[i]] = _stampTokenId_publicData[
            tokenIdList_[i]
          ];

          // Delete away the public
          delete _stampTokenId_publicData[tokenIdList_[i]];
        }
      }
    }

    emit EvtSetTokenIdDataVisibilityMany(
      tokenIdList_,
      isPublic_,
      isForPassport_
    );
  }

  // Before calling this func, check the public field "_passportTokenId_publicData"
  // Calling this view function results in tx
  function viewPassportTokenIdPrivateData(uint256 passportTokenId_)
    external
    whenNotPaused
  {
    require(
      IAgencyNFT(_passportContractAddress).tokenExists(passportTokenId_),
      "passport token not exist"
    );

    require(
      checkAuthorized(msg.sender) ||
        IAgencyNFT(_passportContractAddress).ownerOf(passportTokenId_) ==
        msg.sender,
      "not authorized or not token owner"
    );

    emit EvtViewPassportTokenIdPrivateData(
      passportTokenId_,
      _passportTokenId_privateData[passportTokenId_]
    );
  }

  // Before calling this func, check the public field "_passportTokenId_publicData"
  // Calling this view function results in tx
  function viewPassportTokenIdPrivateDataMany(
    uint256[] memory passportTokenIdList_
  ) external whenNotPaused {
    string memory privDataList = "";

    for (uint256 i = 0; i < passportTokenIdList_.length; i++) {
      require(
        IAgencyNFT(_passportContractAddress).tokenExists(
          passportTokenIdList_[i]
        ),
        "passport token not exist"
      );

      require(
        checkAuthorized(msg.sender) ||
          IAgencyNFT(_passportContractAddress).ownerOf(
            passportTokenIdList_[i]
          ) ==
          msg.sender,
        "not authorized or not token owner"
      );

      privDataList = string(
        abi.encodePacked(
          privDataList,
          _passportTokenId_privateData[passportTokenIdList_[i]],
          _delimiter
        )
      );
    }

    emit EvtViewPassportTokenIdPrivateDataMany(
      passportTokenIdList_,
      privDataList
    );
  }

  function viewPassportTokenIdPublicDataMany(
    uint256[] memory passportTokenIdList_
  ) external view returns (string memory) {
    string memory pubDataList = "";

    for (uint256 i = 0; i < passportTokenIdList_.length; i++) {
      require(
        IAgencyNFT(_passportContractAddress).tokenExists(
          passportTokenIdList_[i]
        ),
        "passport token not exist"
      );

      pubDataList = string(
        abi.encodePacked(
          pubDataList,
          _passportTokenId_publicData[passportTokenIdList_[i]],
          _delimiter
        )
      );
    }

    return pubDataList;
  }

  // Before calling this func, check the public field "_stampTokenId_publicData"
  // Calling this view function results in tx
  function viewStampTokenIdPrivateData(uint256 stampTokenId_)
    external
    whenNotPaused
  {
    require(
      IAgencyNFT(_stampContractAddress).tokenExists(stampTokenId_),
      "stamp token not exist"
    );

    // Get the passport tokenId from the stamp tokenId
    uint256 passportTokenId = IPassportCNFT(_passportContractAddress)
      ._composedNFT_parentTokenId(stampTokenId_, _stampContractAddress);

    require(
      checkAuthorized(msg.sender) ||
        IAgencyNFT(_stampContractAddress).ownerOf(stampTokenId_) ==
        msg.sender ||
        (passportTokenId > 0 &&
          IAgencyNFT(_passportContractAddress).ownerOf(passportTokenId) ==
          msg.sender),
      "not authorized or not token owner"
    );

    emit EvtViewStampTokenIdPrivateData(
      stampTokenId_,
      _stampTokenId_privateData[stampTokenId_]
    );
  }

  // Before calling this func, check the public field "_stampTokenId_publicData"
  // Calling this view function results in tx
  function viewStampTokenIdPrivateDataMany(uint256[] memory stampTokenIdList_)
    external
    whenNotPaused
  {
    string memory privDataList = "";

    for (uint256 i = 0; i < stampTokenIdList_.length; i++) {
      require(
        IAgencyNFT(_stampContractAddress).tokenExists(stampTokenIdList_[i]),
        "stamp token not exist"
      );

      // Get the passport tokenId from the stamp tokenId
      uint256 passportTokenId = IPassportCNFT(_passportContractAddress)
        ._composedNFT_parentTokenId(
          stampTokenIdList_[i],
          _stampContractAddress
        );

      require(
        checkAuthorized(msg.sender) ||
          IAgencyNFT(_stampContractAddress).ownerOf(stampTokenIdList_[i]) ==
          msg.sender ||
          (passportTokenId > 0 &&
            IAgencyNFT(_passportContractAddress).ownerOf(passportTokenId) ==
            msg.sender),
        "not authorized or not token owner"
      );

      privDataList = string(
        abi.encodePacked(
          privDataList,
          _stampTokenId_privateData[stampTokenIdList_[i]],
          _delimiter
        )
      );
    }

    emit EvtViewStampTokenIdPrivateDataMany(stampTokenIdList_, privDataList);
  }

  function viewStampTokenIdPublicDataMany(uint256[] memory stampTokenIdList_)
    external
    view
    returns (string memory)
  {
    string memory pubDataList = "";

    for (uint256 i = 0; i < stampTokenIdList_.length; i++) {
      require(
        IAgencyNFT(_stampContractAddress).tokenExists(stampTokenIdList_[i]),
        "stamp token not exist"
      );

      pubDataList = string(
        abi.encodePacked(
          pubDataList,
          _stampTokenId_publicData[stampTokenIdList_[i]],
          _delimiter
        )
      );
    }

    return pubDataList;
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IPassportCNFT {
  function _composedNFT_parentTokenId(
    uint256 composedTokenId,
    address composedNftAddress
  ) external view returns (uint256);

  function mintManyTokens(
    address receiver_,
    uint256 tokenAmount_,
    string memory agencyId_
  ) external returns (uint256[] memory);

  function mintToken(
    address receiver_,
    string memory agencyId_,
    string memory tokenImage_ // can be empty string
  ) external returns (uint256);
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
  function tokenExists(uint256 tokenId) external view returns (bool);

  function ownerOf(uint256 tokenId) external view returns (address);

  function adminTransferToken(uint256 tokenId, address receiver) external;
}