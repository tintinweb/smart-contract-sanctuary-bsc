/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;




// Sources flattened with hardhat v2.12.3 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)


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


// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)


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


// File contracts/utils/Taxer.sol





// OpenZeppelin Access.

// OpenZeppelin Utils.

interface IExchequer {
    function taxOre(address account) external;
}


/// @title Taxer contracts interface with the Exchequer to tax user's Ore.
///
/// @author Mithrilverse dev team.
///
/// @custom:security-contact [email protected]
contract Mithrilverse_Taxer is Context,
                               Ownable
{


    ////
    //// EXCHEQUER
    ////


    IExchequer internal exchequer;


    ////
    //// INIT
    ////

 
    /// @param _exchequer as contract address.
    constructor(address _exchequer) {
        exchequer = IExchequer(_exchequer);
    }


    ////
    //// EXCHEQUER
    ////


    /// Update Exchequer contract address.
    ///
    /// @param _exchequer as contract address.
    function setExchequerContract(address _exchequer) external onlyOwner {
        exchequer = IExchequer(_exchequer);
    }

    /// Tax a given `account`'s Ore balance.
    ///
    /// @param account as address to Tax  Ore from.
    function taxOre(address account) internal {
        exchequer.taxOre(account);
    }
}


// File contracts/utils/Permissioned.sol





// OpenZeppelin Access.

// OpenZeppelin Utils.

/// @title Permissioning layer for Mithrilverse contracts.
///
/// @author Mithrilverse dev team.
///
/// @custom:security-contact [email protected]
contract Mithrilverse_Permissioned is Context,
                                      Ownable
{


    ////
    //// PERMISSIONS
    ////


    mapping(address => bool) public isPermissioned;

    modifier onlyPermissioned {
        require(isPermissioned[_msgSender()], "Unpermissioned caller");
        _;
    }


    ////
    //// INIT
    ////


    constructor() {
        isPermissioned[_msgSender()] = true;
    }


    ////
    //// PERMISSIONS
    ////


    /// Set address of permissioned caller.
    /// 
    /// @param account as address of permitted caller.
    function togglePermission(address account) external onlyOwner {
        isPermissioned[account] = !isPermissioned[account];
    }
}


// File contracts/Users.sol




// Mithrilverse.


///
/// @title Defines and stores Mithrilverse user accounts.
///
/// @author Mithrilverse dev team.
///
/// @custom:security-contact [email protected]
contract Mithrilverse_Users is Mithrilverse_Permissioned,
                               Mithrilverse_Taxer
{


    ////
    //// ADMIN
    ////


    mapping(address => bool) public accountBlacklist;
    modifier notBlacklisted(address account) {
        require(
            !accountBlacklist[account],
            "Blacklisted account"
        );
        _;
    }

    /// @dev "support" => true
    mapping(string => bool) public usernameBlacklist;


    ////
    //// USERS
    ////


    struct User {
        address account;
        string username;
        string bioURI;
    }

    /// @dev <baseURI>/<tokenURI>
    string public baseURI;

    address[] public accountsList;

    /// @dev 0x13412513 => User { 0x1341..., "silencio", "lonely woodland elf" }
    mapping(address => User) private _users;

    /// @dev "silencio" => 0x1323...
    mapping(string => address) private _activeUsernames;

    modifier isUser(address _account) {
        require(accountExists(_account), "No account found");
        _;
    }

    /// Emits when a new user is created.
    event CreateUser(
        address indexed account,
        string indexed username
    );

    /// Emits when a username is updated.
    event UpdateUsername(
        address indexed account,
        string indexed oldUsername,
        string indexed newUsername
    );

    /// Emits when a URI is updated.
    event UpdateBio(
        address indexed account,
        string indexed newURI
    );


    ////
    //// INIT
    ////


    /// @param exchequer as contract address.
    constructor(address exchequer)
        Mithrilverse_Taxer(exchequer)
    {
        baseURI = "ipfs://";
    }


    ////
    //// ADMIN
    ////


    /// @param baseURI_ as shared URI location.
    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }

    /// Modify username blacklist.
    ///
    /// @param usernames as list of string to add/remove from blacklist.
    function toggleUsernameBlacklist(string[] memory usernames) external onlyOwner {
        uint256 usernamesLength = usernames.length;
        for (uint256 i = 0; i < usernamesLength; i++)
            usernameBlacklist[usernames[i]] = !usernameBlacklist[usernames[i]];
    }

    /// Modify account blacklist.
    ///
    /// @param accounts as addresses to add/remove from blacklist.
    function toggleAccountBlacklist(address[] memory accounts) external onlyOwner {
        uint256 accountsLength = accounts.length;
        for (uint256 i = 0; i < accountsLength; i++)
            accountBlacklist[accounts[i]] = !accountBlacklist[accounts[i]];
    }

    /// As owner, manually update a user.
    ///
    /// @param account as address of user.
    /// @param newUsername as unique string to maintain/update.
    /// @param bioURI as metadata location.
    function ownerSetUser(
        address account,
        string memory newUsername,
        string memory bioURI
    )
        external
        onlyOwner
        isUser(account)
    {
        // Check username is available.
        require(!usernameExists(newUsername), "Username exists");

        // Delete old username.
        _activeUsernames[_users[account].username] = address(0);

        // Register new username.
        _users[account] = User(account, newUsername, bioURI);
        _activeUsernames[newUsername] = account;
    }


    ////
    //// GET USER DATA
    ////


    /// Check if a user exists with `account`.
    ///
    /// @param account as address to check.
    ///
    /// @return bool where true if user exists.
    function accountExists(address account) public view returns (bool) {
        return _users[account].account != address(0);
    }

    /// Check if a username exists.
    ///
    /// @param username as string to check.
    ///
    /// @return bool where true if user exists.
    function usernameExists(string memory username) public view returns (bool) {
        return _activeUsernames[username] != address(0);
    }

    /// Get an account address for a given `username`.
    ///
    /// @dev For privacy reasons this is permissioned.
    ///
    /// @param username of account to get.
    ///
    /// @return address of account.
    function getAddressWithUsername(string memory username) external view returns (address) {
        address account = _activeUsernames[username];
        require(
            account == _msgSender() || isPermissioned[_msgSender()],
            "Unpermissioned caller"
        );
        return account;
    }

    /// Get a username for a given `account`.
    ///
    /// @dev For privacy reasons this is permissioned.
    ///
    /// @param account as address of account to get.
    ///
    /// @return string of username.
    function getUsernameWithAddress(
        address account
    )
        external
        view
        isUser(account)
        returns (string memory)
    {
        require(
            account == _msgSender() || isPermissioned[_msgSender()],
            "Unpermissioned caller"
        );
        return _users[account].username;
    }

    /// Get a user's bio URI.
    ///
    /// @param account as address of user.
    ///
    /// @return string as URI of avatar.
    function getBioURI(address account) external view isUser(account) returns (string memory) {
        return _users[account].bioURI;
    }

    /// Get total count of users.
    /// 
    /// @return uint256 as number of users.
    function getUsersCount() external view returns (uint256) {
        return accountsList.length;
    }


    ////
    //// SET USER DATA
    ////


    /// Create a new user.
    ///
    /// @param username as unique string.
    /// @param bioURI as metadata location of bio.
    function createUser(
        string memory username,
        string memory bioURI
    )
        external
        notBlacklisted(_msgSender())
    {
        address account = _msgSender();

        // Confirm account does not exist.
        require(!accountExists(account), "Account exists");

        // Validate requested username.
        require(!usernameExists(username), "Username exists");
        require(!usernameBlacklist[username], "Blacklisted username");

        // Tax Ore.
        taxOre(account);

        // Create user.
        accountsList.push(account);
        _users[account] = User(account, username, bioURI);
        _activeUsernames[username] = account;
        emit CreateUser(account, username);
    }

    /// Update a username.
    ///
    /// @param newUsername as unique string.
    function setUsername(
        string memory newUsername
    )
        external
        notBlacklisted(_msgSender())
        isUser(_msgSender())
    {
        address account = _msgSender();

        require(!usernameExists(newUsername), "Username exists");
        require(!usernameBlacklist[newUsername], "Blacklisted username");

        taxOre(account);

        // Delete old username.
        string memory oldUsername = _users[account].username;
        _activeUsernames[oldUsername] = address(0);

        // Store new username.
        _users[account].username = newUsername;
        _activeUsernames[newUsername] = account;

        emit UpdateUsername(account, oldUsername, newUsername);
    }

    /// Set bio URI.
    ///
    /// @param bioURI as new metadata location.
    function setBioURI(
        string memory bioURI
    )
        external
        isUser(_msgSender())
        notBlacklisted(_msgSender())
    {
        address account = _msgSender();

        taxOre(account);
 
        _users[account].bioURI = bioURI;

        emit UpdateBio(account, bioURI);
    }
}