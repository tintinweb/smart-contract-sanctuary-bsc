//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title KYC verifications, validators and blacklist for Narfex P2P service
/// @author Danil Sakhinov
contract NarfexKYC is Ownable {

    mapping(address=>string) private _clients;
    mapping(address=>bool) private _verificators;
    mapping(address=>bool) private _blacklisted;
    address public writer;

    constructor() {
        setWriter(msg.sender);
    }

    event SetWriter(address _account);
    event Verify(address _account);
    event RevokeVerification(address _account);
    event AddVerificator(address _account);
    event RemoveVerificator(address _account);
    event Blacklisted(address _account);
    event Unblacklisted(address _account);

    modifier canWrite() {
        require(_msgSender() == owner() || _msgSender() == writer, "No permission");
        _;
    }
    modifier onlyWriter() {
        require(_msgSender() == writer, "Only writer can do it");
        _;
    }

    /// @notice Set writer account
    /// @param _account New writer account address
    function setWriter(address _account) public onlyOwner {
        writer = _account;
        emit SetWriter(_account);
    }

    /// @notice Is account verified
    /// @param _client Account address
    /// @return True if contract have personnel data for this account
    function isKYCVerified(address _client) public view returns(bool) {
        return bytes(_clients[_client]).length > 0;
    }

    /// @notice Verify the account
    /// @param _account Account address
    /// @param _data Encrypted JSON encoded account personnel data
    function verify(address _account, string calldata _data) public onlyWriter {
        require(bytes(_data).length > 0, "Data can't be empty");
        _clients[_account] = _data;
        emit Verify(_account);
    }

    /// @notice Clead account personnel data
    /// @param _account Account address
    function revokeVerification(address _account) public canWrite {
        _clients[_account] = '';
        emit RevokeVerification(_account);
    }

    /// @notice Get data in one request
    /// @param _accounts Array of addresses
    /// @return Array of strings
    function getData(address[] calldata _accounts) public view returns(string[] memory) {
        string[] memory data = new string[](_accounts.length);
        unchecked {
            for (uint i; i < _accounts.length; i++) {
                data[i] = _clients[_accounts[i]];
            }
        }
        return data;
    }

    /// @notice Mark account as verificator
    /// @param _account Account address
    function addVerificator(address _account) public onlyWriter {
        _verificators[_account] = true;
        emit AddVerificator(_account);
    }

    /// @notice Remove account from verificators list
    /// @param _account Account address
    function removeVerificator(address _account) public canWrite {
        _verificators[_account] = false;
        emit RemoveVerificator(_account);
    }

    /// @notice Add account to global Protocol blacklist
    /// @param _account Account address
    function addToBlacklist(address _account) public canWrite {
        _blacklisted[_account] = true;
        emit Blacklisted(_account);
    }

    /// @notice Remove account from global Protocol blacklist
    /// @param _account Account address
    function removeFromBlacklist(address _account) public canWrite {
        _blacklisted[_account] = false;
        emit Unblacklisted(_account);
    }

    /// @notice Return true if account is blacklisted
    /// @param _account Account address
    /// @return Is blacklisted
    function getIsBlacklisted(address _account) public view returns(bool) {
        return _blacklisted[_account];
    }
    
    /// @notice Return true if account verified and added to verificators list
    /// @param _account Account address
    /// @return Is can trade
    function getCanTrade(address _account) public view returns(bool) {
        return _verificators[_account] && !getIsBlacklisted(_account) && isKYCVerified(_account);
    }
}

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