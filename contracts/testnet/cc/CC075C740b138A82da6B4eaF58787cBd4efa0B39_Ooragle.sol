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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title FlexibleStaking
 * @author gotbit
 */

import '@openzeppelin/contracts/access/Ownable.sol';

contract Ooragle is Ownable {
    struct Link {
        string realLink;
        bool handled;
        bool addedToList;
    }

    mapping(address => string[]) private accessList;
    mapping(string => Link) public linkInfo;

    event LinkAdded(address _address, string link);
    event RealLinkAdded(address _address, string answerLink);

    string[] private allLinks;
    address[] private userList;

    constructor() {
        transferOwnership(msg.sender);
    }

    /// @dev Allows user to add links
    /// @param link user link that he want to have access
    function addUserLink(string memory link) external {
        if (!(linkInfo[link].addedToList)) allLinks.push(link);
        if (accessList[msg.sender].length == 0) userList.push(msg.sender);

        accessList[msg.sender].push(link);

        linkInfo[link].addedToList = true;

        emit LinkAdded(msg.sender, link);
    }

    /// @dev Allows user to add links
    /// @param userLink user link that he want to have access
    /// @param answerLink link that give access to user
    function addAcccessLink(string memory userLink, string memory answerLink)
        external
        onlyOwner
    {
        require(bytes(linkInfo[userLink].realLink).length == 0);
        linkInfo[userLink].realLink = answerLink;

        linkInfo[userLink].handled = true;

        emit RealLinkAdded(msg.sender, answerLink);
    }

    function getUserLinks(address user) public view returns (string[] memory) {
        return accessList[user];
    }

    function getAllUserLinks() public view returns (string[] memory) {
        return allLinks;
    }

    function getUserList() public view returns (address[] memory) {
        return userList;
    }

    struct LinkInfo {
        string userLink;
        string realLink;
        bool handled;
    }

    function getAllLinksInfo() public view returns (LinkInfo[] memory) {
        LinkInfo[] memory links = new LinkInfo[](allLinks.length);
        for (uint256 i = 0; i < allLinks.length; i++) {
            links[i].userLink = allLinks[i];
            links[i].realLink = linkInfo[allLinks[i]].realLink;
            links[i].handled = linkInfo[allLinks[i]].handled;
        }

        return links;
    }
}