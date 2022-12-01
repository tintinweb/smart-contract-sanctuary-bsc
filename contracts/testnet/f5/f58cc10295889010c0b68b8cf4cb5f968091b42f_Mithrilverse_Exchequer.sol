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


// File contracts/utils/Permissioned.sol



// OpenZeppelin Access.

/// @title Permissioning layer for Mithrilverse contracts.
///
/// @author Mithrilverse dev team.
///
/// @custom:security-contact [email protected]
contract Mithrilverse_Permissioned is Ownable {


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


// File contracts/Exchequer.sol




// OpenZeppelin Access.

// Mithrilverse.

/// Ore interface.
interface IMithrilOre {
    function burn(address account, uint256 id, uint256 value) external;
    function isApprovedForAll(address account, address operator) external returns (bool);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
    function setApprovalForAll(address operator, bool approved) external;
}


/// Users interface.
interface IUsers {
    function userExists(address account) external returns (bool);
}


/// @title Defines and manages Ore tax rates in the Mithrilverse.
///
/// @dev Every tax has a Taxer and a Cost.
///
/// @author Mithrilverse dev team.
///
/// @custom:security-contact [email protected]
contract Mithrilverse_Exchequer is Context,
                                   Ownable,
                                   Mithrilverse_Permissioned
{


    ////
    //// ORE
    ////


    // IMithrilOre private ore = IMithrilOre(0x20df66EFA6C3BcE0ba80E8BBEeebE1a58a017DF6); // BSC Mainnet.
    IMithrilOre internal ore = IMithrilOre(0x68C759E8621cE487F7b15145A000541A361a3794); // BSC Testnet.

    address[] public taxers;

    mapping(address => uint256) public taxRates;

    // uint256 private oreID = 3; // BSC Mainnet.
    uint256 internal oreID = 0; // BSC Testnet.

    uint256 public taxedOre;


    ////
    //// EXCHEQUER
    ////


    IUsers internal users;

    address public exchequer;

    /// @dev Percent of taxed Ore transferred to the exchequer.
    uint256 public exchequersBribe;

    /// @dev Amount of Ore needed to become the exchequer.
    uint256 public seizePowerCost;

    /// Emitted by seizePower.
    event NewExchequer(
        address indexed exchequer,
        uint256 indexed exchequersBribe,
        uint256 indexed seizePowerCost
    );


    //////////////
    //// INIT ////
    //////////////


    /// @param _exchequer as address of initial exchequer.
    /// @param _exchequersBribe as initial percent of taxed Ore transferred to the exchequer.
    /// @param _seizePowerCost as initial amount of ore needed to become the next exchequer.
    constructor(
        address _exchequer,
        uint256 _exchequersBribe,
        uint256 _seizePowerCost
    ) {
        exchequer = _exchequer;
        exchequersBribe = _exchequersBribe;
        seizePowerCost = _seizePowerCost;
    }


    ////
    //// ORE TAX
    ////


    /// Update the address of the Ore contract.
    ///
    /// @param _ore as address of MithrilOre contract.
    function setOreContract(address _ore) external onlyOwner {
        ore = IMithrilOre(_ore);
    }

    /// Set tax for a new Ore taxer.
    ///
    /// @param taxer as address of taxing contract.
    /// @param amount as quantity of ore to burn.
    function createOreTax(address taxer, uint256 amount) external onlyOwner {
        taxers[taxers.length] = taxer;
        taxRates[taxer] = amount;
    }

    /// Set tax for an existing Ore taxer.
    ///
    /// @param taxer as address of taxing contract.
    /// @param amount as quantity of ore to burn.
    function updateOreTax(address taxer, uint256 amount) external onlyOwner {
        taxRates[taxer] = amount;
    }

    /// Take some Ore from user, pay the exchequer a bribe, then burn the rest.
    ///
    /// @param account as user.
    function taxOre(address account) external onlyPermissioned {
        address taxer = _msgSender();

        // Check user has approved contract to spend Ore.
        require(
            ore.isApprovedForAll(account, address(this)),
            "Can't spend user's Ore"
        );

        // Get Ore tax rate.
        uint256 oreAmount = taxRates[taxer];

        // Pay exchequer.
        uint256 bribeAmount = oreAmount * exchequersBribe / 100;
        ore.safeTransferFrom(
            account,
            exchequer,
            oreID,
            bribeAmount,
            ""
        );

        // Burn remaining Ore.
        uint256 burnAmount = oreAmount - bribeAmount;
        ore.burn(
            account,
            oreID,
            burnAmount
        );

        taxedOre += oreAmount;
    }


    ////
    //// EXCHEQUER
    ////


    /// Update the address of the Users contract.
    ///
    /// @param _users as address of Users contract.
    function setUsersContract(address _users) external onlyOwner {
        users = IUsers(_users);
    }

    /// Manually set the address of the exchequer.
    ///
    /// @param account as address of exchequer.
    function setExchequer(address account) external onlyOwner {
        exchequer = account;
    }

    /// Set the percent of taxed Ore transferred to the exchequer.
    ///
    /// @param _exchequersBribe as integer percent.
    function setExchequersBribe(uint256 _exchequersBribe) external onlyOwner {
        exchequersBribe = _exchequersBribe;
    }

    /// All the percent of taxed Ore transferred to the exchequer.
    ///
    /// @param amount of Ore being spent by caller.
    function seizePower(uint256 amount) external {
        address newExchequer = _msgSender();

        // Check caller is a registered user.
        require(
            users.userExists(newExchequer),
            "Caller is not a registered user"
        );

        // Check caller is paying more than current exchequer paid.
        require(
            amount >= seizePowerCost,
            "Spend more Ore"
        );

        // Burn caller's Ore.
        ore.burn(
            newExchequer,
            oreID,
            amount
        );

        exchequer = newExchequer;
        seizePowerCost = amount + 1;

        emit NewExchequer(exchequer, exchequersBribe, seizePowerCost);
    }
}