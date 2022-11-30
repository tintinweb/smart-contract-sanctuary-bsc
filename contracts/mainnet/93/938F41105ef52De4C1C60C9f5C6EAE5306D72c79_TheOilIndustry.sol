/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: contracts/interfaces/ITheOilIndustry.sol


pragma solidity ^0.8.16;
pragma abicoder v2;

interface ITheOilIndustry {
    struct Tower {
        uint256 coins;
        uint256 money;
        uint256 money2;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refs;
        uint256 refDeps;
        uint8[8] Workers;
    }

    function sumtotalInvested(uint value ) external;
    function sumTotalTowers() external;


    function tCoins(address user, uint coin) external;
    function tCoinsRest(address user, uint coin) external;
    function tmoney(address user, uint coin) external;
    function tmoney2(address user,uint money) external;
    function ttimestamp(address user, uint time) external;
    function tyield(address user, uint yield) external;
    function tyieldSet(address user, uint yield) external;
    function tref(address user, address ref) external;
    function thrs(address user,uint hrs) external;
    function trefs(address user) external;
    function trefDeps(address user, uint coins) external;
    function tWorkers(address user, uint floorId) external;
    function tWorkersDelete(address user) external;
    
    function tmoneyWithdraw(address user, uint money) external;
    function thrsSet(address user, uint hrs)external;
    function tmoney2Set(address user, uint money) external ;
    function totalWorkersPlus(uint plus) external;
    function totalWorkersSub(uint sub) external;
    function transferOwnership(address newOwner)external;
    // view Functions
    function viewTower(address user) external  view returns(Tower memory);
}
// File: contracts/TheOilIndustry.sol


pragma solidity ^0.8.16;




contract TheOilIndustry is Ownable, Pausable {
    ITheOilIndustry public oilData;
    struct Tower {
        uint256 coins;
        uint256 money;
        uint256 money2;
        uint256 yield;
        uint256 timestamp;
        uint256 hrs;
        address ref;
        uint256 refs;
        uint256 refDeps;
        uint8[8] Workers;
    }
    address public manager;
    

    constructor (ITheOilIndustry _newOil, address _manager) {
        oilData = _newOil;
        manager = _manager;
    }    

    function addCoins(address ref) public payable whenNotPaused{
        uint256 coins = msg.value / 2e13;
        require(coins > 0, "Zero coins");
        address user = msg.sender;
        oilData.sumtotalInvested(msg.value);
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(msg.sender);
        if (userTower.timestamp == 0) {
            oilData.sumTotalTowers();
            ref = userTower.timestamp == 0 ? manager : ref;
            oilData.trefs(ref);
            oilData.tref(user, ref);
            oilData.ttimestamp(user, block.timestamp);
        }
        userTower = oilData.viewTower(msg.sender);
        ref = userTower.ref;
        oilData.tCoins(ref, ((coins * 7) / 100));
        oilData.tmoney(ref, ((coins * 100 * 3) / 100));
        oilData.trefDeps(ref, coins);
        oilData.tCoins(user,coins);
        payable(manager).transfer((msg.value * 3) / 100);
    }

    function withdrawMoney() public whenNotPaused {
        address user = msg.sender;
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(msg.sender);

        uint256 money = userTower.money;
        oilData.tmoneyWithdraw(user,0);        
        uint256 amount = money * 2e11;
        payable(user).transfer(address(this).balance < amount ? address(this).balance : amount);
    }

    function collectMoney() public whenNotPaused {
        address user = msg.sender;
        syncTower(user);
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(msg.sender);
        

        oilData.thrsSet(user, 0);
        // towers[user].hrs = 0;
        oilData.tmoney(user, userTower.money2);
        // towers[user].money += towers[user].money2;
        oilData.tmoney2Set(user, 0);
        // towers[user].money2 = 0;
    }

    function upgradeTower(uint256 floorId) public whenNotPaused {
        require(floorId < 8, "Max 8 floors");
        address user = msg.sender;
        syncTower(user);
        oilData.totalWorkersPlus(1);
        // totalWorkers++;
        oilData.tWorkers(user,floorId);
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(msg.sender);
        // towers[user].Workers[floorId]++;
        uint256 Workers = userTower.Workers[floorId];
        oilData.tCoinsRest(user, getUpgradePrice(floorId, Workers));
        // towers[user].coins -= getUpgradePrice(floorId, Workers);
        oilData.tyield(user, getYield(floorId, Workers));
        // towers[user].yield += getYield(floorId, Workers);
    }
    

    function sellTower() public {
        collectMoney();
        address user = msg.sender;
        uint8[8] memory Workers = getWorkers(user);
        oilData.totalWorkersSub ( Workers[0] + Workers[1] + Workers[2] + Workers[3] + Workers[4] + Workers[5] + Workers[6] + Workers[7]);
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(user);
        oilData.tmoney(user, userTower.yield *24*14);
        // towers[user].money += towers[user].yield * 24 * 14;
        oilData.tWorkersDelete(user);
        // towers[user].Workers = [0, 0, 0, 0, 0, 0, 0, 0];
        oilData.tyieldSet(user, 0);
        // towers[user].yield = 0;
    }

    function works(uint256 floorId)public view returns(uint256){
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(msg.sender);
        return userTower.Workers[floorId];
    }

    function getWorkers(address addr) public view returns (uint8[8] memory) {
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(addr);
        return userTower.Workers;
    }

    function syncTower(address user) internal {
        ITheOilIndustry.Tower memory userTower = oilData.viewTower(msg.sender);
        require(userTower.timestamp > 0, "User is not registered");
        if (userTower.yield > 0) {
            uint256 hrs = block.timestamp / 3600 - userTower.timestamp / 3600;
            if (hrs + userTower.hrs > 24) {
                hrs = 24 -userTower.hrs;
            }
            oilData.tmoney2(user,hrs * userTower.yield);
            // towers[user].money2 += hrs * towers[user].yield;
            oilData.thrs(user, hrs);
            // towers[user].hrs += hrs;
        }
        oilData.ttimestamp(user, block.timestamp);
        // towers[user].timestamp = block.timestamp;
    }

    function getUpgradePrice(uint256 floorId, uint256 workerId) internal pure returns (uint256) {
        if (workerId == 1) return [500, 1500, 4500, 13500, 40500, 120000, 365000, 1000000][floorId];
        if (workerId == 2) return [625, 1800, 5600, 16800, 50600, 150000, 456000, 1200000][floorId];
        if (workerId == 3) return [780, 2300, 7000, 21000, 63000, 187000, 570000, 1560000][floorId];
        if (workerId == 4) return [970, 3000, 8700, 26000, 79000, 235000, 713000, 2000000][floorId];
        if (workerId == 5) return [1200, 3600, 11000, 33000, 98000, 293000, 890000, 2500000][floorId];
        revert("Incorrect workerId PRICE");
    }

    function getYield(uint256 floorId, uint256 workerId) internal pure returns (uint256) {
        if (workerId == 1) return [41, 130, 399, 1220, 3750, 11400, 36200, 104000][floorId];
        if (workerId == 2) return [52, 157, 498, 1530, 4700, 14300, 45500, 126500][floorId];
        if (workerId == 3) return [65, 201, 625, 1920, 5900, 17900, 57200, 167000][floorId];
        if (workerId == 4) return [82, 264, 780, 2380, 7400, 22700, 72500, 216500][floorId];
        if (workerId == 5) return [103, 318, 995, 3050, 9300, 28700, 91500, 275000][floorId];
        revert("Incorrect workerId YIELD");
    }

    function changeOwnerOfOilData(address newOwner)public virtual onlyOwner {
        oilData.transferOwnership(newOwner);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}