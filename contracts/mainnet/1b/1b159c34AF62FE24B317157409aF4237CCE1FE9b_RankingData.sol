/**
 *Submitted for verification at BscScan.com on 2022-04-18
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: contracts/blackhole.sol


pragma solidity ^0.8.0;
pragma abicoder v2;


// BlackHole Referral And Donate Function
contract RankingData is Ownable {
    uint public  recordId;

    // admins to add record
    mapping(address => bool) public admins;

    mapping(address => uint) public RankingRewardBHO;
    mapping(address => uint) public RankingRewardBUSD;

    uint public BHOTotalAmount;
    uint public BUSDTotalAmount;

    constructor(
    ) {
        admins[msg.sender] = true;
    }

    function addMember(address _address) public onlyOwner {
        admins[_address] = true;
    }

    function addRecord(address _address, uint _BHOAmount, uint _BUSDAmount) public {
        require(admins[msg.sender], "this user can't add record");
        RankingRewardBHO[_address] += _BHOAmount;
        RankingRewardBUSD[_address] += _BUSDAmount;
        BUSDTotalAmount += _BUSDAmount;
        BHOTotalAmount += _BHOAmount;
    }

    function minusRecord(address _address, uint _BHOAmount, uint _BUSDAmount) public {
        require(admins[msg.sender], "this user can't add record");
        RankingRewardBHO[_address] -= _BHOAmount;
        RankingRewardBUSD[_address] -= _BUSDAmount;
        BUSDTotalAmount -= _BUSDAmount;
        BHOTotalAmount -= _BHOAmount;
    }

    function getTeamTotalReward(address _address) public view returns (uint, uint){
        return (RankingRewardBHO[_address], RankingRewardBUSD[_address]);
    }

    function getTotalReward() public view returns (uint, uint){
        return (BUSDTotalAmount, BHOTotalAmount);
    }
}