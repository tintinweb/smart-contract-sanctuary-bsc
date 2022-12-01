/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;




// Sources flattened with hardhat v2.9.9 https://hardhat.org

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

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)


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


// File contracts/utils/Taxer.sol



// OpenZeppelin Access.

interface IExchequer {
    function taxOre(address account) external;
}


/// @title Taxer contracts interface with the Exchequer to tax user's Ore.
///
/// @author Mithrilverse dev team.
///
/// @custom:security-contact [email protected]
contract Mithrilverse_Taxer is Ownable {


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


// File contracts/Avatars.sol




// OpenZeppelin Access.

// OpenZeppelin Utils.

// Mithrilverse.

/// @title Defines and stores Mithrilverse user Avatars.
///
/// @author Mithrilverse dev team.
///
/// @custom:security-contact [email protected]
contract Mithrilverse_Avatars is Context,
                                 Ownable,
                                 Mithrilverse_Taxer
{


    ////
    //// AVATARS
    ////


    /// @dev <baseURI>/<userAvatarURIs[address]>
    string public baseURI;

    mapping(address => string) public userAvatarURIs;

    event SetAvatar(
        address indexed account,
        string indexed uri
    );


    ////
    //// INIT
    ////


    /// @param exchequer as contract address.
    constructor(address exchequer) Mithrilverse_Taxer(exchequer) {
    }


    ////
    //// AVATARS
    ////


    /// Set user's avatar URI.
    ///
    /// @param uri as metadata location of avatar.
    function setAvatar(string memory uri) external {
        address account = _msgSender();

        // Tax Ore.
        taxOre(account);

        // Update avatar.
        userAvatarURIs[account] = uri;
        emit SetAvatar(account, uri);
    }
}