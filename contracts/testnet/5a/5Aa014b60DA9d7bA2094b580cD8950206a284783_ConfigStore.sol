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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IConfigStore} from "./interfaces/IConfigStore.sol";

/**
 * @notice
 * Stores configuration globally
 *
 * @dev
 * Uris is used as base uri of membership pass
 */
contract ConfigStore is IConfigStore, Ownable {
  /*╔═════════════════════════════╗
    ║  Public Stored Properties   ║
    ╚═════════════════════════════╝*/
  // The base uri of metadata for project
  string public override baseProjectURI;

  // The base uri of metadata for membershippass nft
  string public override baseMembershipPassURI;

  // Contract level data, for intergrating the NFT to OpenSea
  string public override baseContractURI;

  // Signer address, sign proposal and royalty fee distribution merkle tree
  address public override signerAddress;

  // Super amin address
  address public override superAdmin;

  // Dev treasury address, receive contributeFee and claimFee
  address public override devTreasury;

  // The percent fee takes when user contribute to a project, 1 => 0.1%
  uint256 public override contributeFee;

  // The percent fee takes when from tapped amounts, 1 => 1%
  uint256 public override tapFee;

  // The percent fee takes when dao member claims royalty fee
  uint256 public override claimFee;

  // The min lock percent of funds in treasury. 3000 => 30%
  uint256 public override minLockRate;

  // The eligble marketplaces map(marketplace swap contract => true)
  mapping(address => bool) public override royaltyFeeSenderWhiteList;

  mapping(address => bool) public override terminalRoles;

  mapping(address => bool) public override mintRoles;

  /*╔═════════════════════════╗
    ║   External Transaction  ║
    ╚═════════════════════════╝*/

  constructor(
    string memory _baseProjectURI,
    string memory _baseMembershipPassURI,
    string memory _baseContractURI,
    address _signer,
    address _superAdmin,
    address _devTreasury,
    uint256 _contributeFee,
    uint256 _tapFee,
    uint256 _claimFee,
    uint256 _minLockRate
  ) {
    baseProjectURI = _baseProjectURI;
    baseMembershipPassURI = _baseMembershipPassURI;
    baseContractURI = _baseContractURI;
    signerAddress = _signer;
    superAdmin = _superAdmin;
    devTreasury = _devTreasury;
    contributeFee = _contributeFee;
    tapFee = _tapFee;
    claimFee = _claimFee;
    minLockRate = _minLockRate;

    transferOwnership(_superAdmin);
  }

  /**
   * @notice
   * The owner can modify the base project uri

   * @param _uri The new base uri
   */
  function setBaseProjectURI(string calldata _uri) external override onlyOwner {
    baseProjectURI = _uri;

    emit SetBaseProjectURI(_uri);
  }

  /**
   * @notice
   * The owner can modify the base membershipPass uri

   * @param _uri The new base uri
   */
  function setBaseMembershipPassURI(string calldata _uri) external override onlyOwner {
    baseMembershipPassURI = _uri;

    emit SetBaseMembershipPassURI(_uri);
  }

  /**
   * @notice
   * The owner can modify the base contract uri
    
   * @param _uri The new base contract uri 
   */
  function setBaseContractURI(string calldata _uri) external override onlyOwner {
    baseContractURI = _uri;

    emit SetBaseContractURI(_uri);
  }

  /**
   * @notice
   * The owner can modify the signer
        
   * @param _signer The new signer
   */
  function setSigner(address _signer) external override onlyOwner {
    signerAddress = _signer;

    emit SetSigner(_signer);
  }

  /**
   * @notice
   * Transfer the ownership to new admin
        
   * @param _admin The new admin
   */
  function setSuperAdmin(address _admin) external override onlyOwner {
    superAdmin = _admin;

    transferOwnership(_admin);

    emit SetSuperAdmin(_admin);
  }

  /**
   * @notice
   * The owner can modify the treasury
        
   * @param _devTreasury The new dev treasury address
   */
  function setDevTreasury(address _devTreasury) external override onlyOwner {
    devTreasury = _devTreasury;

    emit SetDevTreasury(_devTreasury);
  }

  /**
   * @notice
   * The owner can change the tap fee
        
   * @param _fee The new tap fee
   */
  function setTapFee(uint256 _fee) external override onlyOwner {
    if (_fee > 10) revert BadTapFee();

    tapFee = _fee;

    emit SetTapFee(_fee);
  }

  /**
   * @notice
   * The owner can change the contribute fee
        
   * @param _fee The new fee when user contribute to dao 
   */
  function setContributeFee(uint256 _fee) external override onlyOwner {
    contributeFee = _fee;

    emit SetContributeFee(_fee);
  }

  /**
   * @notice
   * The owner can change the claim fee
        
   * @param _fee The new fee when user claims royalty fee 
   */
  function setClaimFee(uint256 _fee) external override onlyOwner {
    claimFee = _fee;

    emit SetClaimFee(_fee);
  }

  /**
   * @notice
   * The owner can set new min lock rate
        
   * @param _lockRate The new lock rate
   */
  function setMinLockRate(uint256 _lockRate) external override onlyOwner {
    minLockRate = _lockRate;

    emit SetMinLockRate(_lockRate);
  }

  function addRoyaltyFeeSender(address _sender) external override onlyOwner {
    if (_sender == address(0)) revert ZeroAddress();

    royaltyFeeSenderWhiteList[_sender] = true;

    emit RoyaltyFeeSenderChanged(_sender, true);
  }

  function removeRoyaltyFeeSender(address _sender) external override onlyOwner {
    if (_sender == address(0)) revert ZeroAddress();

    delete royaltyFeeSenderWhiteList[_sender];

    emit RoyaltyFeeSenderChanged(_sender, false);
  }

  function grantTerminalRole(address _terminal) external override onlyOwner {
    if (_terminal == address(0)) revert ZeroAddress();

    terminalRoles[_terminal] = true;

    emit TerminalRoleChanged(_terminal, true);
  }

  function revokeTerminalRole(address _terminal) external override onlyOwner {
    if (_terminal == address(0)) revert ZeroAddress();

    delete terminalRoles[_terminal];

    emit TerminalRoleChanged(_terminal, false);
  }

  function grantMintRole(address _account) external override onlyOwner {
    if (_account == address(0)) revert ZeroAddress();

    mintRoles[_account] = true;

    emit MintRoleChanged(_account, true);
  }

  function revokeMintRole(address _account) external override onlyOwner {
    if (_account == address(0)) revert ZeroAddress();

    delete mintRoles[_account];

    emit MintRoleChanged(_account, false);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IConfigStore {
  event SetBaseProjectURI(string uri);

  event SetBaseMembershipPassURI(string uri);

  event SetBaseContractURI(string uri);

  event SetSigner(address signer);

  event SetSuperAdmin(address admin);

  event SetDevTreasury(address devTreasury);

  event SetTapFee(uint256 fee);

  event SetContributeFee(uint256 fee);

  event SetClaimFee(uint256 fee);

  event SetMinLockRate(uint256 minLockRate);

  event RoyaltyFeeSenderChanged(address royaltyFeeSender, bool isAdd);

  event TerminalRoleChanged(address terminal, bool grant);

  event MintRoleChanged(address account, bool grant);

  error BadTapFee();

  error ZeroAddress();

  function baseProjectURI() external view returns (string memory);

  function baseMembershipPassURI() external view returns (string memory);

  function baseContractURI() external view returns (string memory);

  function signerAddress() external view returns (address);

  function superAdmin() external view returns (address);

  function devTreasury() external view returns (address);

  function tapFee() external view returns (uint256);

  function contributeFee() external view returns (uint256);

  function claimFee() external view returns (uint256);

  function minLockRate() external view returns (uint256);

  function royaltyFeeSenderWhiteList(address _sender) external view returns (bool);

  function terminalRoles(address) external view returns (bool);

  function mintRoles(address) external view returns (bool);

  function setBaseProjectURI(string calldata _uri) external;

  function setBaseMembershipPassURI(string calldata _uri) external;

  function setBaseContractURI(string calldata _uri) external;

  function setSigner(address _admin) external;

  function setSuperAdmin(address _signer) external;

  function setDevTreasury(address _devTreasury) external;

  function setTapFee(uint256 _fee) external;

  function setContributeFee(uint256 _fee) external;

  function setClaimFee(uint256 _fee) external;

  function setMinLockRate(uint256 _lockRate) external;

  function addRoyaltyFeeSender(address _sender) external;

  function removeRoyaltyFeeSender(address _sender) external;

  function grantTerminalRole(address _terminal) external;

  function revokeTerminalRole(address _terminal) external;

  function grantMintRole(address _terminal) external;

  function revokeMintRole(address _terminal) external;
}