//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

error MyVerse__RegistrationClosed();
error MyVerse__AlreadyRegistered();
error MyVerse__NotRegistered();

/**
 * @title Smart Contract for register in MetaVision Network
 * @author mpp1337
 * @notice Only for user registration in our system.
 * Contract's owner can disable registration
 * @dev Only register function is available for call
 */

contract MyVerseRegister is Ownable {
    struct User {
        string telegramUsername;
        string eMail;
        string metaVerse;
        address userAddress;
        bool isRegistered;
    }

    bool s_isOpened = false;
    mapping(address => User) private s_addressToUser;
    User[] private s_users;

    modifier isOpened() {
        if (s_isOpened) {
            _;
        } else {
            revert MyVerse__RegistrationClosed();
        }
    }

    modifier onlyOnce() {
        if (s_addressToUser[msg.sender].isRegistered) {
            revert MyVerse__AlreadyRegistered();
        } else {
            _;
        }
    }

    modifier onlyRegistered() {
        if (!s_addressToUser[msg.sender].isRegistered) {
            revert MyVerse__NotRegistered();
        }
        _;
    }

    event UserRegistered(address indexed _newMember);
    event RegistrationOpened();
    event RegistrationClosed();

    /**
     * @notice This method registers users in our system.
     * Works only if registration has been opened
     * User can register only once
     */
    function register(
        string memory _tgUsername,
        string memory _eMail,
        string memory _metaVerse
    ) external isOpened onlyOnce {
        User memory user = User(
            _tgUsername,
            _eMail,
            _metaVerse,
            msg.sender,
            true
        );
        s_addressToUser[msg.sender] = user;
        s_users.push(user);
        emit UserRegistered(msg.sender);
    }

    function updateUserData(string memory telegram, string memory email)
        external
        onlyRegistered
    {
        User storage user = s_addressToUser[msg.sender];
        if (checkStringLength(telegram) > 1) {
            user.telegramUsername = telegram;
        }
        if (checkStringLength(email) > 1) {
            user.eMail = email;
        }
    }

    /* OWNER FUNCTIONS */

    /**
     * @notice This method opens registration. Available only for owner
     */
    function openRegistration() external onlyOwner {
        s_isOpened = true;
        emit RegistrationOpened();
    }

    /**
     * @notice This method closes registration. Available only for owner
     */
    function closeRegistration() external onlyOwner {
        s_isOpened = false;
        emit RegistrationClosed();
    }

    /* VIEW FUNCTIONS */

    /**
     * @notice This method returns user info.
     * @return Returns User struct if user registered in MV system
     */

    function getUser() external view returns (User memory) {
        return s_addressToUser[msg.sender];
    }

    /**
     * @notice This method returns user info at index in array.
     * @param _index Index of user in arraay
     * @return Returns User struct if user registered in MV system
     */

    function getUserAt(uint256 _index) external view returns (User memory) {
        return s_users[_index];
    }

    /**
     * @notice This method returns number of users registered in the system.
     * @return Returns number of users
     */

    function getNumberOfUsers() external view returns (uint256) {
        return s_users.length;
    }

    function getRegistrationState() external view returns (bool) {
        return s_isOpened;
    }

    function getAllUsers() external view onlyOwner returns (User[] memory) {
        return s_users;
    }

    /* PRIVATE FUNCTIONS */

    function checkStringLength(string memory s) private pure returns (uint256) {
        return bytes(s).length;
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