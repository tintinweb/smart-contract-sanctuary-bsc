/**
 *Submitted for verification at BscScan.com on 2022-11-15
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

// File: contracts/oilData.sol


pragma solidity ^0.8.16;
pragma abicoder v2;


contract OilData is Ownable {
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
    uint256 totalWorkers;
    uint256 totalTowers;
    uint256 totalInvested;
    address manager = msg.sender;
    mapping(address => Tower) towers;

    function sumtotalInvested(uint value ) public onlyOwner{
        totalInvested += value; 
    }
    function sumTotalTowers() public onlyOwner{
        totalTowers++;
    }

    function tCoins(address user, uint coin) public onlyOwner{
        towers[user].coins +=coin;
    }
    function tCoinsRest(address user, uint coin) public onlyOwner{
        towers[user].coins -=coin;
    }
    function tmoney(address user, uint money) public onlyOwner{
        towers[user].money +=money;
    }
    function tmoneyWithdraw(address user, uint money) public onlyOwner{
        towers[user].money =money;
    }
    function tmoney2(address user, uint money) public onlyOwner{
        towers[user].money2 +=money;
    }
    function tmoney2Set(address user, uint money) public onlyOwner{
        towers[user].money2 =money;
    }
    function tyield(address user, uint yield) public onlyOwner{
        towers[user].yield += yield;
    }
    function tyieldSet(address user, uint yield) public onlyOwner{
        towers[user].yield = yield;
    }
    function ttimestamp(address user, uint time) public onlyOwner{
        towers[user].timestamp = time;
    }
    function tref(address user, address ref) public onlyOwner{
        towers[user].ref = ref;
    }
    function thrs(address user,uint hrs) public onlyOwner{
        towers[user].hrs += hrs;
    }

    function thrsSet(address user, uint hrs)public onlyOwner{
        towers[user].hrs = hrs;
    }
    function trefs(address ref) public onlyOwner{
        towers[ref].refs++;
    }
    function trefDeps(address user, uint coins) public onlyOwner{
        towers[user].refDeps += coins;
    }
    function tWorkers(address user, uint floorId) public onlyOwner{
        towers[user].Workers[floorId]++;
    }
    function tWorkersDelete(address user) public onlyOwner{
        towers[user].Workers = [0, 0, 0, 0, 0, 0, 0, 0];
    }

    function totalWorkersPlus(uint plus) public onlyOwner{
        totalWorkers += plus;
    }
    function totalWorkersSub(uint sub) public onlyOwner{
        totalWorkers -= sub;
    }


    // view function
    function viewTower(address user) public  view returns(Tower memory){
        return towers[user];
    }


}