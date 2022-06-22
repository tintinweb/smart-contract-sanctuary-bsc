// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./OwnPauseBase.sol";

contract Agency is OwnPauseBase {
  string public _defaultAgencyId = "trvl";
  string public _defaultAgencyVeriSign = "trvl.com";
  string public _defaultAgencyImage = "https://";

  string public _agencyOwnerContractName;
  address public _agencyOwnerContractAddress;

  // No need to include AgencyMetadata here because token's metadata can be retrieved via tokenURI() method
  struct AgencyInfo {
    string id;
    string veriSign; // verification signature. Empty if the token is not yet verified
    uint256 timestamp; // token minted/updated timestamp
  }

  struct AgencyMetadata {
    string name; // Travel ABC #{tokenId}
    string description; // This is travel ABC agency
    string image; // https://link-to-template-image
    // AgencyMetadataAttributes[] attributes; // do not include attributes[] here
  }

  struct AgencyMetadataAttributes {
    string trait_type;
    string value;
  }

  // tokenId => AgencyInfo
  mapping(uint256 => AgencyInfo) public _tokenId_agencyInfo;

  // agencyId => tokenId list
  // if later the token is burnt, the method tokenExists() returns false
  mapping(string => uint256[]) public _agencyId_tokenIdList;

  // agencyId => veriSign
  mapping(string => string) public _agencyId_agencyVeriSign;
  bytes32[] public _agencyIdList;
  // count the number of registered agencies. It can be diff from _agencyIdList.length due to removeAgencyInfo()
  uint256 public _agencyCount;

  // agencyId => AgencyMetadata
  mapping(string => AgencyMetadata) public _agencyId_agencyMetadata;

  // agencyId => AgencyMetadata
  mapping(string => AgencyMetadataAttributes[])
    public _agencyId_agencyMetadataAttributes;

  event EvtSetDefaultAgencyInfo(string id, string veriSign, string image);
  event EvtRegisterAgencyInfo(string agencyId, string agencyVeriSign);
  event EvtUpdateAgencyInfo(string agencyId, string agencyVeriSign);
  event EvtRemoveAgencyInfo(string agencyId);
  event EvtSetAgencyMetadata(
    string agencyId,
    string name,
    string description,
    string image
  );
  event EvtAddAgencyMetadataAttribute(
    string agencyId,
    string trait_type,
    string value
  );
  event EvtUpdateAgencyMetadataAttribute(
    string agencyId,
    string trait_type,
    string value
  );
  event EvtUpdateOrVerifyTokenIdAgencyInfo(uint256 tokenId, string agencyId);
  event EvtUpdateOrVerifyManyTokenIdsAgencyInfo(
    uint256[] tokenIds,
    string agencyId
  );

  function setOwnerContract(
    string memory agencyOwnerContractName_,
    address agencyOwnerContractAddress_
  ) external isOwner {
    _agencyOwnerContractName = agencyOwnerContractName_;
    _agencyOwnerContractAddress = agencyOwnerContractAddress_;
  }

  function setDefaultAgencyInfo(
    string memory defaultAgencyId_,
    string memory defaultAgencyVeriSign_,
    string memory defaultAgencyImage_
  ) external isOwner {
    _defaultAgencyId = defaultAgencyId_;
    _defaultAgencyVeriSign = defaultAgencyVeriSign_;
    _defaultAgencyImage = defaultAgencyImage_;
    emit EvtSetDefaultAgencyInfo(
      defaultAgencyId_,
      defaultAgencyVeriSign_,
      defaultAgencyImage_
    );
  }

  function registerAgencyInfo(
    string memory agencyId_,
    string memory agencyVeriSign_
  ) external isAuthorized {
    _agencyId_agencyVeriSign[agencyId_] = agencyVeriSign_;
    _agencyCount++;
    _agencyIdList.push(bytes32(abi.encodePacked(agencyId_)));

    emit EvtRegisterAgencyInfo(agencyId_, agencyVeriSign_);
  }

  function updateAgencyVeriSign(
    string memory agencyId_,
    string memory agencyVeriSign_
  ) external isAuthorized {
    _agencyId_agencyVeriSign[agencyId_] = agencyVeriSign_;
    emit EvtUpdateAgencyInfo(agencyId_, agencyVeriSign_);
  }

  function removeAgencyInfo(string memory agencyId_) external isAuthorized {
    delete _agencyId_agencyVeriSign[agencyId_];
    _agencyCount--;
    emit EvtRemoveAgencyInfo(agencyId_);
  }

  function setAgencyMetadata(
    string memory agencyId_,
    string memory name_,
    string memory description_,
    string memory image_
  ) external isAuthorized {
    require(
      bytes(_agencyId_agencyVeriSign[agencyId_]).length > 0,
      "Agency not exist"
    );

    _agencyId_agencyMetadata[agencyId_] = AgencyMetadata(
      name_,
      description_,
      image_
    );

    emit EvtSetAgencyMetadata(agencyId_, name_, description_, image_);
  }

  function addAgencyMetadataAttribute(
    string memory agencyId_,
    string memory trait_type,
    string memory value
  ) external isAuthorized {
    require(
      bytes(_agencyId_agencyMetadata[agencyId_].name).length > 0,
      "Agency metadata not exist"
    );

    _agencyId_agencyMetadataAttributes[agencyId_].push(
      AgencyMetadataAttributes(trait_type, value)
    );

    emit EvtAddAgencyMetadataAttribute(agencyId_, trait_type, value);
  }

  // Update "trait_type" with new "value"
  // Set "value" to empty string to wipe the "trait_type"
  function updateAgencyMetadataAttribute(
    string memory agencyId_,
    string memory trait_type,
    string memory value
  ) external isAuthorized {
    require(
      bytes(_agencyId_agencyMetadata[agencyId_].name).length > 0,
      "Agency metadata not exist"
    );

    for (
      uint256 i = 0;
      i < _agencyId_agencyMetadataAttributes[agencyId_].length;
      i++
    ) {
      string memory trait_type_stored = _agencyId_agencyMetadataAttributes[
        agencyId_
      ][i].trait_type;
      if (
        (keccak256(abi.encodePacked((trait_type_stored))) ==
          keccak256(abi.encodePacked((trait_type))))
      ) {
        _agencyId_agencyMetadataAttributes[agencyId_][i].value = value;
      }
    }

    emit EvtUpdateAgencyMetadataAttribute(agencyId_, trait_type, value);
  }

  function safeGetAgencyId(string memory agencyId_)
    public
    view
    returns (string memory)
  {
    return bytes(agencyId_).length > 0 ? agencyId_ : _defaultAgencyId;
  }

  function safeGetAgencyVeriSign(string memory agencyId_)
    public
    view
    returns (string memory)
  {
    return
      bytes(agencyId_).length > 0
        ? _agencyId_agencyVeriSign[agencyId_]
        : _defaultAgencyVeriSign;
  }

  // Can only be called by the owner contract (Passport or Stamp) whenever token is minted.
  // veriSign will be set if "agencyId_" not empty
  function setTokenIdAgencyInfo(uint256 tokenId_, string memory agencyId_)
    external
  {
    require(_agencyOwnerContractAddress != address(0), "owner contract not set");
    require(msg.sender == _agencyOwnerContractAddress, "Not owner contract");

    if (bytes(agencyId_).length > 0) {
      require(
        bytes(_agencyId_agencyVeriSign[agencyId_]).length > 0,
        "agencyId not registed"
      );

      _tokenId_agencyInfo[tokenId_] = AgencyInfo(
        agencyId_,
        _agencyId_agencyVeriSign[agencyId_],
        block.timestamp
      );

      _agencyId_tokenIdList[agencyId_].push(tokenId_);
    } else {
      _tokenId_agencyInfo[tokenId_] = AgencyInfo(
        _defaultAgencyId,
        "",
        block.timestamp
      );

      _agencyId_tokenIdList[_defaultAgencyId].push(tokenId_);
    }
  }

  // "agencyId_" can be empty str
  // "veriSign" will also be set (no longer empty)
  function updateOrVerifyTokenIdAgencyInfo(
    uint256 tokenId_,
    string memory agencyId_
  ) external isAuthorized {
    _tokenId_agencyInfo[tokenId_] = AgencyInfo(
      safeGetAgencyId(agencyId_),
      safeGetAgencyVeriSign(agencyId_),
      block.timestamp
    );

    emit EvtUpdateOrVerifyTokenIdAgencyInfo(tokenId_, agencyId_);
  }

  function updateOrVerifyManyTokenIdsAgencyInfo(
    uint256[] memory tokenIdList_,
    string memory agencyId_
  ) external isAuthorized {
    for (uint256 i = 0; i < tokenIdList_.length; i++) {
      _tokenId_agencyInfo[tokenIdList_[i]] = AgencyInfo(
        safeGetAgencyId(agencyId_),
        safeGetAgencyVeriSign(agencyId_),
        block.timestamp
      );
    }

    emit EvtUpdateOrVerifyManyTokenIdsAgencyInfo(tokenIdList_, agencyId_);
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