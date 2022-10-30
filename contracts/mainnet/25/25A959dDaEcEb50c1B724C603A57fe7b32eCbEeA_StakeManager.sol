// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


contract StakeManager is Ownable{

    struct UserInfo {

        uint256 totalStakedDefault; //linear
        uint256 totalStakedAutoCompound;

        uint256 walletStartTime;
        uint256 overThresholdTimeCounter;

        uint256 activeStakesCount;
        uint256 withdrawStakesCount;

        mapping(uint256 => StakeInfo) activeStakes;
        mapping(uint256 => WithdrawnStakeInfo) withdrawnStakes;

    }

    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    } 

    struct StakeInfoView {
        uint256 stakeID;
        uint256 taxReduction;
        uint256 amount;
        uint256 startTime;
        bool isAutoPool;
    } 

    struct WithdrawnStakeInfo {
        uint256 amount;
        uint256 taxReduction;
        uint256 endTime;
        bool isAutoPool;
    }

    struct WithdrawnStakeInfoView {
        uint256 stakeID;
        uint256 amount;
        uint256 taxReduction;
        uint256 endTime;
        bool isAutoPool;

    }


    address public DogPoundManger;
    mapping(address => UserInfo) userInfo;


    uint256 public reliefPerDay = 75;      // 0.75% default
    uint256 public reliefPerDayExtra = 25; // 0.25%

    constructor(address _DogPoundManger){
        DogPoundManger = _DogPoundManger;
    }

    modifier onlyDogPoundManager() {
        require(DogPoundManger == msg.sender, "manager only");
        _;
    }

    function saveStake(address _user, uint256 _amount, bool _isAutoCompound) onlyDogPoundManager external{
        UserInfo storage user = userInfo[_user];
        user.activeStakes[user.activeStakesCount].amount = _amount;
        user.activeStakes[user.activeStakesCount].startTime = block.timestamp;
        user.activeStakes[user.activeStakesCount].isAutoPool = _isAutoCompound;
        user.activeStakesCount++;
        if(_isAutoCompound){
            user.totalStakedAutoCompound += _amount;
        }else{
            user.totalStakedDefault += _amount;
        }
    }

    function withdrawFromStake(address _user,uint256 _amount, uint256 _stakeID) onlyDogPoundManager  external{
        UserInfo storage user = userInfo[_user];
        StakeInfo storage activeStake = user.activeStakes[_stakeID];
        require(_amount > 0, "withdraw: zero amount");
        require(activeStake.amount >= _amount, "withdraw: not good");
        uint256 withdrawCount = user.withdrawStakesCount;
        uint256 taxReduction = getActiveStakeTaxReduction(_user, _stakeID);
        bool isAutoCompound = isStakeAutoPool(_user,_stakeID);
        user.withdrawnStakes[withdrawCount].amount = _amount;
        user.withdrawnStakes[withdrawCount].taxReduction = taxReduction;
        user.withdrawnStakes[withdrawCount].endTime = block.timestamp;
        user.withdrawnStakes[withdrawCount].isAutoPool = isAutoCompound;
        user.withdrawStakesCount++;
        activeStake.amount -= _amount;
        if(isAutoCompound){
            user.totalStakedAutoCompound -= _amount;
        }else{
            user.totalStakedDefault -= _amount;
        }

    }

    function utilizeWithdrawnStake(address _user, uint256 _amount, uint256 _stakeID) onlyDogPoundManager external {
        UserInfo storage user = userInfo[_user];
        WithdrawnStakeInfo storage withdrawnStake = user.withdrawnStakes[_stakeID];
        require(withdrawnStake.amount >= _amount);
        user.withdrawnStakes[_stakeID].amount -= _amount;
    }

    function getUserActiveStakes(address _user) public view returns (StakeInfoView[] memory){
        UserInfo storage user = userInfo[_user];
        StakeInfoView[] memory stakes = new StakeInfoView[](user.activeStakesCount);
        for (uint256 i=0; i < user.activeStakesCount; i++){
            stakes[i] = StakeInfoView({
                stakeID : i,
                taxReduction:getActiveStakeTaxReduction(_user,i),
                amount : user.activeStakes[i].amount,
                startTime : user.activeStakes[i].startTime,
                isAutoPool : user.activeStakes[i].isAutoPool
            });
        }
        return stakes;
    }


    function getUserWithdrawnStakes(address _user) public view returns (WithdrawnStakeInfoView[] memory){
        UserInfo storage user = userInfo[_user];
        WithdrawnStakeInfoView[] memory stakes = new WithdrawnStakeInfoView[](user.withdrawStakesCount);
        for (uint256 i=0; i < user.withdrawStakesCount; i++){
            stakes[i] = WithdrawnStakeInfoView({
                stakeID : i,
                amount : user.withdrawnStakes[i].amount,
                taxReduction : user.withdrawnStakes[i].taxReduction,
                endTime : user.withdrawnStakes[i].endTime,
                isAutoPool : user.withdrawnStakes[i].isAutoPool
            });
        }
        return stakes;
    }

    function getActiveStakeTaxReduction(address _user, uint256 _stakeID) public view returns (uint256){
        StakeInfo storage activeStake = userInfo[_user].activeStakes[_stakeID];
        uint256 relief = reliefPerDay;
        if (activeStake.isAutoPool){
            relief = reliefPerDay + reliefPerDayExtra;
        }
        uint256 taxReduction = ((block.timestamp - activeStake.startTime) / 24 hours) * relief;
        return taxReduction;

    }

    function getWithdrawnStakeTaxReduction(address _user, uint256 _stakeID) public view returns (uint256){
        UserInfo storage user = userInfo[_user];
        return user.withdrawnStakes[_stakeID].taxReduction;
    }

    function getUserActiveStake(address _user, uint256 _stakeID) external view returns (StakeInfo memory){
        return userInfo[_user].activeStakes[_stakeID];

    }
    
    function changeReliefValues(uint256 relief1,uint256 relief2) external onlyOwner{
        require(relief1+relief2 < 1000);
        reliefPerDay = relief1;
        reliefPerDayExtra = relief2;
    }

    function getUserWithdrawnStake(address _user, uint256 _stakeID) external view returns (WithdrawnStakeInfo memory){
        return userInfo[_user].withdrawnStakes[_stakeID];
    }

    function isStakeAutoPool(address _user, uint256 _stakeID) public view returns (bool){
        return userInfo[_user].activeStakes[_stakeID].isAutoPool;
    }

    function totalStaked(address _user) public view returns (uint256){
        return userInfo[_user].totalStakedDefault + userInfo[_user].totalStakedAutoCompound;
    }
    
    function setDogPoundManager(address _address) public onlyOwner {
        DogPoundManger = _address;
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