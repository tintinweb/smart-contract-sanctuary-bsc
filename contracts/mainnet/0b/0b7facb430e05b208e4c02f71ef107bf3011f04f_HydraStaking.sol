/**
 *Submitted for verification at BscScan.com on 2022-04-07
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// File: stake.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



contract HydraStaking is Ownable {
    // struct to save the stake detail
    struct StakeRecord {
        uint256 packageId;
        uint256 startTime;
        uint256 endTime;
        uint256 unstakeTime;
        uint256 amount;
        uint256 rate;
        bool claimed;
    }

    // struct to save the staking package
    struct Package {
        uint256 rate;
        uint256 duration;
        uint256 amountRequired;
    }

    // mappings to save staked records, staking packages
    mapping(address => StakeRecord[]) staked; 
    Package[] StakingPackages;

    // total token staked
    mapping(address => uint256) public totalAmountStaked;

    // total token in staking now
    mapping(address => uint256) public totalAmountStaking;

    // main token address
    address public tokenAddress;
    IERC20 tokenContract;

    /**
     * @dev Initialize
     * @notice This is the initialize function, run on deploy event
     * @param _tokenAddr    address of main token
    */
    constructor(address _tokenAddr) {
        tokenAddress = _tokenAddr;
        tokenContract = IERC20(tokenAddress);
        
        // add free-time staking package
        Package memory pk;
        pk.rate = 2739; //Package 0 will be 10% APR => 0.02739% per day
        pk.duration = 60*60*24;
        StakingPackages.push(pk);
    }

    /**
     * @dev Add new staking package
     * @notice New package will be pushed to the end of StakingPackages
     * @param _durationDay  duration in day unit
     * @param _rate         rate per ten million per day, 10.000.000 will be 100% per day
    */
    function addStakingPackage(uint256 _durationDay, uint256 _rate, uint256 _amountRequired) public onlyOwner {
        require(_rate > 0, 'Rate have to larger than zero');
        require(_durationDay > 0, 'Duration have to equal or higher than 1');
        Package memory pk;
        pk.rate = _rate;
        pk.duration = _durationDay * 60*60*24;
        pk.amountRequired = _amountRequired;
        StakingPackages.push(pk);
    }

    /**
     * @dev Update a staking package
     * @param _packageId    specific package ID to update
     * @param _newDuration  new duration in day unit
     * @param _newRate      new rate per Million per day
    */
    function updateStakingPackage(uint256 _packageId, uint256 _newDuration, uint256 _newRate) public onlyOwner {
        require(StakingPackages[_packageId].rate > 0, 'Invalid package ID');
        StakingPackages[_packageId].rate = _newRate;
        StakingPackages[_packageId].duration = _newDuration * 60*60*24;
    }

    /**
     * @dev Remove staking package
     * @notice Package rate will be set to 0
     * @param _packageId    package ID to remove
    */
    function removeStakingPackage(uint256 _packageId) public onlyOwner {
        require(StakingPackages[_packageId].rate > 0, 'Invalid package ID');
        StakingPackages[_packageId].rate = 0;
    }

    /**
     * @dev Get staking package information
     * @param _packageId    package ID to get information
    */
    function getStakePackageInfo(uint256 _packageId) public view returns(uint256 _rate, uint256 _duration, uint256 _amountRequired) {
        require(StakingPackages[_packageId].rate > 0, "Invalid package ID");
        return (StakingPackages[_packageId].rate, StakingPackages[_packageId].duration, StakingPackages[_packageId].amountRequired);
    }

    /**
     * @dev Start staking
     * @notice Users have to approve main token to this contract before start staking
     * @param _amount       amount of token to stake
     * @param _packageId    package ID to stake
    */
    function stake(uint256 _amount, uint256 _packageId) public {
        // validate available package and approved amount
        require(StakingPackages[_packageId].rate > 0, "Invalid package");
        require(StakingPackages[_packageId].amountRequired <= _amount, "Insufficient amount");
        require(tokenContract.allowance(msg.sender, address(this)) >= _amount, "Insufficient balance");
        // transfer token to this staking contract
        tokenContract.transferFrom(msg.sender, address(this), _amount);

        // prepare new staking record
        StakeRecord memory sr;
        sr.packageId = _packageId;
        sr.startTime = uint256(block.timestamp);

        // set the withdraw time based on package type
        if (_packageId == 0) {
            // free-time staking package
            sr.endTime = sr.startTime;
        } else {
            // fixed-time staking packages
            sr.endTime = sr.startTime + StakingPackages[_packageId].duration;
        }

        sr.amount = _amount;
        sr.rate = StakingPackages[_packageId].rate;
        totalAmountStaked[msg.sender] += _amount;
        totalAmountStaking[msg.sender] += _amount;
        // save staking record
        staked[msg.sender].push(sr);
    }

    /**
     * @dev Get stake record count of an address
     * @notice With finished records
     * @param _owner    address to check
    */
    function stakeCount(address _owner) public view returns (uint256) {
        return staked[_owner].length;
    }

    /**
     * @dev Get stake info of caller
     * @notice with specific stake ID
     * @param _stakeId  stake id to check
    */
    function getStakeInfo(uint256 _stakeId) public view returns (uint256 _packageId, uint256 startTime, uint256 endTime, uint256 unstakeTime, uint256 amount, uint256 rate, bool claimed) {
        // validate available staking ID
        require(staked[msg.sender][_stakeId].amount > 0, "Invalid stakeId");
        StakeRecord memory sr = staked[msg.sender][_stakeId];
        return (sr.packageId, sr.startTime, sr.endTime, sr.unstakeTime, sr.amount, sr.rate, sr.claimed);
    }

    /**
     * @dev Get staking package count
     * @notice With removed package
    */
    function packageCount() public view returns (uint256) {
        return StakingPackages.length;
    }

    /**
     * @dev Calculate only staking reward with stake amount and package ID
     * @notice Free-time package will be calculated with 1 day
     * @param _packageId    package ID to calculate
     * @param _amount       staking amount to calculate
    */
    function calcReward(uint256 _packageId, uint256 _amount) public view returns(uint256 _reward) {
        // validate available package ID
        require(StakingPackages[_packageId].rate > 0, "Invalid package ID");

        // calculare and return
        uint256 stakeRate = StakingPackages[_packageId].rate;
        uint256 duration = StakingPackages[_packageId].duration / (60*60*24);
        return _amount * duration * stakeRate / 10000000;
    }

    /**
     * @dev Calculate caller reward
     * @notice With specific staking ID
     * @param _stakeId  staking ID to calculate
    */
    function calcMyReward(uint256 _stakeId) public view returns(uint256 _reward) {
        // validate available staking ID
        require(staked[msg.sender][_stakeId].amount > 0, "Invalid stakeId");

        // retrieve staking infor & package info
        uint256 stakeAmount = staked[msg.sender][_stakeId].amount;
        uint256 stakeRate = staked[msg.sender][_stakeId].rate;
        uint256 startTime = staked[msg.sender][_stakeId].startTime;
        uint256 endTime = staked[msg.sender][_stakeId].endTime;
        uint256 duration = endTime - startTime;

        // check if staking in package 0 is finished
        if(staked[msg.sender][_stakeId].packageId == 0){
            duration = block.timestamp - startTime;
            if(endTime != startTime){
                duration = endTime - startTime;
            }
        }

        if(staked[msg.sender][_stakeId].packageId != 0 && block.timestamp < endTime){
            duration = block.timestamp - startTime;
        }

        // calculate and return
        return stakeAmount * duration * stakeRate / (60*60*24) / 10000000;
    }

    function unlockToken(uint256 _stakeId) public {
        // validate staking infor
        require(staked[msg.sender][_stakeId].amount > 0, "Invalid stakeId");
        require(staked[msg.sender][_stakeId].claimed == false, "Claimed");
        require(staked[msg.sender][_stakeId].packageId == 0 || staked[msg.sender][_stakeId].endTime > block.timestamp, "token can't unlock");
        
        //Set endTime = now and modify rate to flexible pacakge
        staked[msg.sender][_stakeId].endTime = block.timestamp;
        staked[msg.sender][_stakeId].rate = StakingPackages[0].rate;
    }

    /**
     * @dev Unstake
     * @notice With staking ID
     * @param _stakeId  staking ID to unstake
    */
    function unstake(uint256 _stakeId) public {
        // validate staking infor
        require(staked[msg.sender][_stakeId].amount > 0, "Invalid stakeId");
        require(staked[msg.sender][_stakeId].claimed == false, "Claimed");

        // retrieve staking info
        uint256 stakeAmount = staked[msg.sender][_stakeId].amount;
        uint256 claimAmount = stakeAmount;
        uint256 packageId = staked[msg.sender][_stakeId].packageId;
        // check whether package is free-time or fixed-time
        if (packageId == 0) {
            // free-time package
            // check stake unlocked
            require(staked[msg.sender][_stakeId].endTime + 2*60*60*24 <= block.timestamp, "Not available to unstake");
            // calculate with duration
            claimAmount = stakeAmount + calcMyReward(_stakeId);
        } else {
            Package memory pkg = StakingPackages[packageId];
            //check if user withdraw before time end
            if(staked[msg.sender][_stakeId].endTime - staked[msg.sender][_stakeId].startTime < pkg.duration){
                require(staked[msg.sender][_stakeId].endTime + 2*60*60*24 <= block.timestamp, "Not available to unstake");
            } else {
                require(staked[msg.sender][_stakeId].endTime <= block.timestamp, "token is locked");
            }
            claimAmount = stakeAmount + calcMyReward(_stakeId);
        }

        // transfer main token to claimer
        tokenContract.transfer(msg.sender, claimAmount);
        staked[msg.sender][_stakeId].unstakeTime = block.timestamp;
        totalAmountStaking[msg.sender] -= stakeAmount;
        // remove staking record
        staked[msg.sender][_stakeId].claimed = true;
    }

    /**
     * @dev Emergency withdraw main token to contract owner
     * @notice Only owner can call this function
    */
    function emergencyWithdraw() public onlyOwner{
        uint256 myBalance = tokenContract.balanceOf(address(this));
        tokenContract.transfer(owner(), myBalance);
    }

    /**
     * @dev get balance stake of user 
     * @param addressUser  get balance staking off adddress
     */
    function getTotalAmountStaked(address addressUser) external view returns(uint256){
        return totalAmountStaking[addressUser];
    }
}