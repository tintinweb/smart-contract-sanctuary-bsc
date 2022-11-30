/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

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

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract VemateStaking is Ownable{

    struct Position {
        uint256 positionId;
        address walletAddress;
        uint256 createdDate;
        uint256 unlockDate;
        uint256 percentInterest;
        uint256 tokenStaked;
        uint256 tokenInterest;
        bool open;
    }

    address private immutable VMT;

    uint16[] private lockPeriods;

    mapping(uint256 => Position) private positions;
    mapping(address => uint256[]) private positionIdsByAddress;
    mapping(uint256 => uint256) private tiers;

    uint256 public totalStaked;
    uint256 public totalInterest;
    uint256 public currentPositionId;

    constructor(address vemate) {
        require(vemate != address(0x0),'zero address');
        VMT = vemate;

        totalStaked = 0;
        totalInterest = 0;
        currentPositionId = 0;

        tiers[90] = 3;
        tiers[180] = 5;
        tiers[365] = 7;

        lockPeriods.push(90);
        lockPeriods.push(180);
        lockPeriods.push(365);
    }

    function stake(uint256 numDays, uint256 tokenAmount) external {
        require(tiers[numDays] > 0, "Mapping not found");
        require(IERC20(VMT).balanceOf(_msgSender()) >= tokenAmount, "Not enough VMT");

        uint256 interest = tokenAmount * tiers[numDays] * numDays / 36500;
        require(getAmountLeftForPool() >= interest, "Not enough VMT left for rewards");
        require(IERC20(VMT).allowance(_msgSender(), address(this)) >= tokenAmount, "Please increase allowance");

        bool success = IERC20(VMT).transferFrom(_msgSender(), address(this), tokenAmount);

        if(success){
            positions[currentPositionId] = Position (
                currentPositionId,
                _msgSender(),
                block.timestamp,
                block.timestamp + (numDays * 1 days),
                tiers[numDays],
                tokenAmount,
                interest,
                true
            );

            positionIdsByAddress[_msgSender()].push(currentPositionId);
            currentPositionId += 1;
            totalStaked += tokenAmount;
            totalInterest += interest;
        }

    }

    function modifyLockPeriods(uint16 numDays, uint16 basisPoints) external onlyOwner{
        if(tiers[numDays] == 0){
            lockPeriods.push(numDays);
        }
        tiers[numDays] = basisPoints;
    }

    function getLockPeriods() external view returns(uint16[] memory){
        return lockPeriods;
    }

    function getPositionById(uint256 positionId) external view returns(Position memory){
        return positions[positionId];
    }

    function getPositionIdsForAddress(address walletAddress) external view returns(uint256[] memory) {
        return positionIdsByAddress[walletAddress];
    }

    function changeLockDate(uint256 positionId, uint256 newUnlockDate) external onlyOwner{
        positions[positionId].unlockDate = newUnlockDate;
    }

    function getAmountLeftForPool() public view returns(uint256){
        return IERC20(VMT).balanceOf(address(this)) - totalStaked - totalInterest;
    }

    function getPoolSize() external view returns(uint256){
        return IERC20(VMT).balanceOf(address(this)) - totalStaked;
    }

    function unstake(uint256 positionId) external returns(bool) {
        require(positions[positionId].walletAddress == _msgSender(), "Only position creator may modify position");
        require(positions[positionId].open, "Already unstaked");

        require(block.timestamp > positions[positionId].unlockDate, "UnlockDate not reached");

        uint256 tokenAmount = positions[positionId].tokenStaked;
        uint256 amountWithInterest = tokenAmount + positions[positionId].tokenInterest;

        totalStaked -= tokenAmount;
        totalInterest -= positions[positionId].tokenInterest;
        positions[positionId].open = false;

        bool success = IERC20(VMT).transfer(_msgSender(), amountWithInterest);
        return success;
    }

    function emergencyWithdraw(uint256 positionId) external returns(bool){
        require(positions[positionId].walletAddress == _msgSender(), "Only position creator may modify position");
        require(positions[positionId].open, "Already unstaked");
        require(positions[positionId].unlockDate > block.timestamp, "UnlockDate already reached");

        uint256 stakedTime = positions[positionId].createdDate;
        uint256 timeDifference = block.timestamp - stakedTime;

        uint256 amount = positions[positionId].tokenStaked;
        uint256 penalty = checkPenalty(timeDifference, amount);
        uint256 amountAfterPenalty = amount - penalty;

        totalStaked -= amount;
        totalInterest -= positions[positionId].tokenInterest;
        positions[positionId].open = false;

        bool success = IERC20(VMT).transfer(_msgSender(), amountAfterPenalty);
        return success;
    }

    function checkPenalty(uint256 time, uint256 stakedAmount) private pure returns(uint256) {
        uint256 penalty;
        uint256 numberOfDays = time / 86400;

        if(numberOfDays < 10){
            penalty = stakedAmount * 20 / 100;
            return penalty;
        } else if(numberOfDays < 20) {
            penalty = stakedAmount * 15 / 100;
            return penalty;
        } else if(numberOfDays < 30) {
            penalty = stakedAmount * 12 / 100;
            return penalty;
        } else if(numberOfDays < 60) {
            penalty = stakedAmount * 10 / 100;
            return penalty;
        } else if(numberOfDays < 90) {
            penalty = stakedAmount * 8 / 100;
            return penalty;
        } else {
            return 0;
        }
    }

    receive() external payable {}

    function rescueBNB(uint256 amount) external onlyOwner returns(bool){
        payable(_msgSender()).transfer(amount);
        return true;
    }

    function rescueBEP20(address bep20, uint256 amount) external onlyOwner returns(bool){
        bool success = IERC20(bep20).transfer(_msgSender(), amount);
        return success;
    }

}