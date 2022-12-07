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


// File @openzeppelin/contracts/utils/[email protected]

// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)


/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}


// File contracts/Ranks.sol




// OpenZeppelin Utils.

// Mithrilverse.


interface IPoints {
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) external returns (uint256[] memory);
}


interface IRaces {
    function userRaces(address) external returns (uint256);
}


/// @title Defines and stores Mithrilverse user Ranks.
///
/// @dev User's have Points.
/// @dev Points are required for Levels.
/// @dev Levels unlock Ranks.
///
/// @author Mithrilverse dev team.
///
/// @custom:security-contact [email protected]
contract Mithrilverse_Ranks is Mithrilverse_Permissioned,
                               Mithrilverse_Taxer
{
    using Counters for Counters.Counter;


    ////
    //// POINTS
    ////


    IPoints public points;

    uint256[] public combatPointsIDs;


    ////
    //// RACES
    ////


    IRaces public races;


    ////
    //// RANKS
    ////


    Counters.Counter public rankCount;

    struct Rank {
        uint256   id;
        string    name;
        uint256   unlockLevel;
        uint256[] restrictedRaces;
    }

    /// @dev [0] = 5, [1] = 11, etc
    uint256[] public levels;

    /// @dev id  => Rank
    mapping(uint256 => Rank) public ranks;

    /// @dev account => id
    mapping(address => uint256) public userRanks;

    event SetRank(
        address indexed account,
        string indexed newRank
    );


    ////
    //// INIT
    ////


    /// @param _levels as array.
    /// @param exchequer as contract address.
    /// @param _points as contract address.
    /// @param _races as contract address.
    constructor(uint256[] memory _levels, address exchequer, address _points, address _races)
        Mithrilverse_Taxer(exchequer)
    {
        levels = _levels;
        points = IPoints(_points);
        races = IRaces(_races);
    }


    ////
    //// ADMIN
    ////

    /// Set the points needed per level.
    ///
    /// @param _levels as array.
    function setLevels(uint256[] memory _levels) external onlyOwner {
        levels = _levels;
    }


    /// Set address of the Points contract.
    ///
    /// @param _points as contract address.
    function setPointsContract(address _points) external onlyOwner {
        points = IPoints(_points);
    }

    /// Set the ID's of the Points tokens which are considered in level.
    ///
    /// @param _combatPointsIDs as Points ID's.
    function setCombatPointsIDs(uint256[] memory _combatPointsIDs) external onlyOwner {
        combatPointsIDs = _combatPointsIDs;
    }

    /// Create a new rank.
    ///
    /// @param _name as string.
    /// @param _unlockLevel as level at which rank is unlocked.
    /// @param _restrictedRaces as races, if any, which the rank is restricted to.
    function addNewRank(
        string memory _name,
        uint256 _unlockLevel,
        uint256[] memory _restrictedRaces
    )
        external
        onlyOwner
    {
        ranks[rankCount.current()] = Rank(
            rankCount.current(),
            _name,
            _unlockLevel,
            _restrictedRaces
        );
        rankCount.increment();
    }


    ////
    //// RANKS
    ////


    /// Get user's level based on their combat points.
    ///
    /// @param account as address of user.
    ///
    /// @return uint256 as level.
    function getUsersLevel(address account) public returns (uint256) {
        uint256 combatPoints = getUsersCombatPoints(account);

        uint256 maxLevel = levels.length;
        for (uint256 i = 0; i < maxLevel; i++) {
            if (combatPoints < levels[i + 1]) {
                return i;
            }
        }

        return 0;
    }


    /// Get user's combat points.
    ///
    /// @param account as address of user.
    ///
    /// @return uint256 as total points balance.
    function getUsersCombatPoints(address account) private returns (uint256) {
        // Get Points balances.

        address[] memory accounts;
        uint256 length = combatPointsIDs.length;
        for (uint256 i = 0; i < length; i++)
            accounts[i] = account;

        uint256[] memory pointsBalances = points.balanceOfBatch(
            accounts,
            combatPointsIDs
        );

        // Calculate sum of Points balances.

        uint256 totalCombatPoints;
        for (uint256 i = 0; i < length; i++)
            totalCombatPoints += pointsBalances[i];

        // Return user's Points.

        return totalCombatPoints;
    }

    /// Set user's own rank.
    ///
    /// @param rank as id of rank.
    function setRank(uint256 rank) external {
        address account = _msgSender();

        // Tax Ore.
        taxOre(account);

        // Get user's level.
        uint256 level = getUsersLevel(account);

        // Validate user's level.
        require(level >= ranks[rank].unlockLevel, "Caller not valid level");

        // Validate user's race.
        bool validRace;
        uint256 length = ranks[rank].restrictedRaces.length;
        if (length > 0) {
            uint256 usersRace = races.userRaces(account);
            for (uint256 i = 0; i < length; i++) {
                if (ranks[rank].restrictedRaces[i] == usersRace) {
                    validRace = true;
                }
            }
        }
        require(validRace, "Caller not valid race");

        // Set user's rank.
        userRanks[account] = rank;
        emit SetRank(account, ranks[rank].name);
    }
}