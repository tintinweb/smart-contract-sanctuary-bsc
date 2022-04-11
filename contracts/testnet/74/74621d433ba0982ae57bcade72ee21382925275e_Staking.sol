/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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

// File: contracts/BusdStaking.sol


pragma solidity ^0.8.4;






contract Staking is Ownable, ReentrancyGuard {
    
    using SafeMath for uint256;
    



    struct Stake{
        uint deposit_amount;        //Deposited Amount
        uint stake_creation_time;   //The time when the stake was created
        bool returned;              //Specifies if the funds were withdrawed
    }


    //---------------------------------------------------------------------
    //-------------------------- EVENTS -----------------------------------
    //---------------------------------------------------------------------


    /**
    *   @dev Emitted when the pot value changes
     */
    event PotUpdated(
        uint newPot
    );


    /**
    *   @dev Emitted when a customer tries to withdraw an amount
    *       of token greater than the one in the pot
     */
    event PotExhausted(

    );


    /**
    *   @dev Emitted when a new stake is issued
     */
    event NewStake(
        uint stakeAmount,
        address from
    );

    /**
    *   @dev Emitted when a new stake is withdrawed
     */
    event UnStake(
        uint stakeID,
        uint amount
    );

    /**
    *   @dev Emitted when a referral reward is sent
     */

    event rewardWithdrawed(
        address account
    );



    //--------------------------------------------------------------------
    //-------------------------- GLOBALS -----------------------------------
    //--------------------------------------------------------------------

    mapping (address => Stake[]) private stake; /// @dev Map that contains account's stakes
    address[] private activeAccounts;   //Store both staker and referer address
    address private tokenAddress;

    IERC20 private busdContract;

    uint private pot;    //The pot where token are taken

    uint256 private _INTEREST_PERIOD = 1 days;    //One day
    uint256 private _INTEREST_RATE = 40;    //40% per year
    uint256 private _INTEREST_RATE_PERIOD = 365;  // 1 year
    uint256 private _PENALTY_VALUE = 5;    //5% of the total stake
    uint256 private _MIN_STAKE_TIME = 2 weeks;     // 2 Weeks
    uint256 private _PENALTY_DAYS = 40 days;       //40 Days



    constructor( address _busdAddress) {
        require(_busdAddress != address(0x0));
        pot = 0;
        tokenAddress = _busdAddress;
        busdContract = IERC20(_busdAddress);
    }

    //--------------------------------------------------------------------
    //-------------------------- TOKEN ADDRESS -----------------------------------
    //--------------------------------------------------------------------

    function getBusdContractAddress() external view returns (address){
        return tokenAddress;
    }

    //--------------------------------------------------------------------
    //-------------------------- ONLY OWNER -----------------------------------
    //--------------------------------------------------------------------


    // Config Functions

    // Set the intrest Value Default 40 
    function setIntrestRate(uint _rate) external onlyOwner {
        _INTEREST_RATE = _rate;
    }

    // Set intrest Period Default 1 DAY
    function setInterestPeriod(uint _interestPeriod) external onlyOwner {
        _INTEREST_PERIOD = _interestPeriod;
    }

    // Set Minimum stake time  Default 2 Weeks
    function setMinimumStakeTime(uint _mst) external onlyOwner {
        _MIN_STAKE_TIME = _mst;
    }

    // Sets the Interest rate period  Default 365 
    function setInterestRatePeriod(uint _irp) external onlyOwner {
        _INTEREST_RATE_PERIOD = _irp;
    }

    // Sets the penalty value in terms of percentage  Default 5
    function setPenaltyValue(uint _pv) external onlyOwner {
        _PENALTY_VALUE = _pv;
    }

    // Sets the penalty days Default 40
    function setPenaltyDays(uint _pd) external onlyOwner {
        _PENALTY_DAYS = _pd;
    }

    function depositPot(uint _amount) external onlyOwner nonReentrant {
        pot = pot.add(_amount);
        if(busdContract.transferFrom(msg.sender, address(this), _amount)){
            //Emit the event to update the UI
            emit PotUpdated(pot);
        }else{
            revert("Unable to tranfer funds");
        }

    }

    function returnPot(uint _amount) external onlyOwner nonReentrant{
        require(pot.sub(_amount) >= 0, "Not enough token");

        pot = pot.sub(_amount);

        if(busdContract.transfer(msg.sender, _amount)){
            //Emit the event to update the UI
            emit PotUpdated(pot);
        }else{
            revert("Unable to tranfer funds");
        }

    }


    function withdraw() external onlyOwner nonReentrant{
        uint machineAmount = getContractBalance();
        if(!busdContract.transfer(owner(), machineAmount)){
            revert("Unable to transfer funds");
        }
    }

    /**
    *   @dev Check if the pot has enough balance to satisfy the potential withdraw
     */
    function getPotentialWithdrawAmount() external onlyOwner view returns (uint){
        uint accountNumber = activeAccounts.length;

        uint potentialAmount = 0;

        for(uint i = 0; i<accountNumber; i++){

            address currentAccount = activeAccounts[i];

            potentialAmount = potentialAmount.add(calculateTotalRewardToWithdraw(currentAccount));  //Normal Reward
        }

        return potentialAmount;
    }


    //--------------------------------------------------------------------
    //-------------------------- CLIENTS -----------------------------------
    //--------------------------------------------------------------------

    /**
    *   @dev Stake token verifying all the contraint
    *   @notice Stake tokens
    *   @param _amount Amoun to stake
     */
    function stakeToken(uint _amount, uint256 stake_end_time ) external nonReentrant {
        require(_amount <= busdContract.balanceOf(msg.sender), "Not enough tokens in your wallet, please try lesser amount");
        require(stake_end_time >= block.timestamp + _MIN_STAKE_TIME , "Minimum stake time must be 2 weeks");

        Stake memory newStake;

        newStake.deposit_amount = _amount;
        newStake.returned = false;
        newStake.stake_creation_time = block.timestamp;

        stake[msg.sender].push(newStake);
        activeAccounts.push(msg.sender);

        if(busdContract.transferFrom(msg.sender, address(this), _amount)){
            emit NewStake(_amount, msg.sender);
        }else{
            revert("Unable to transfer funds");
        }


    }

    /**
    *   @dev Return the staked tokens, requiring that the stake was
    *        not alreay withdrawed
    *   @notice Return staked token
    *   @param _stakeID The ID of the stake to be returned
     */
    function unStakeToken(uint _stakeID) external nonReentrant returns (bool){
        Stake memory selectedStake = stake[msg.sender][_stakeID];

        //Check if the stake were already withdraw
        require(selectedStake.returned == false, "Stake were already returned");
        require(block.timestamp >= selectedStake.stake_creation_time + _MIN_STAKE_TIME, "Not allow to withdraw before 2 weeks");

        uint deposited_amount = selectedStake.deposit_amount;
        uint totalInterest = calculateInterest(_stakeID);
        uint amountWithInterest  = deposited_amount.add(totalInterest);
        uint periods = calculatePeriods(_stakeID);
        uint penalty;
        if(periods <= _PENALTY_DAYS){
            penalty = calculatePenalty(amountWithInterest);
        }

        //Sum the net reward to the total reward to withdraw
        uint total_amount = amountWithInterest.sub(penalty);

        //Add the penalty to the pot
        pot = pot.add(penalty);


        //Only set the withdraw flag in order to disable further withdraw
        stake[msg.sender][_stakeID].returned = true;

        if(busdContract.transfer(msg.sender, total_amount)){
            emit UnStake(_stakeID, total_amount);
        }else{
            revert("Unable to transfer funds");
        }


        return true;
    }

    function withdrawFromPot(uint _amount) public nonReentrant returns (bool){
        if(_amount > pot){
            emit PotExhausted();
            return false;
        }

        //Update the pot value

        pot = pot.sub(_amount);
        return true;

    }


    //--------------------------------------------------------------------
    //-------------------------- VIEWS -----------------------------------
    //--------------------------------------------------------------------

    /**
    * @dev Return the amount of token in the provided caller's stake
    * @param _stakeID The ID of the stake of the caller
     */
    function getCurrentStakeAmount(uint _stakeID) external view returns (uint256)  {
        return stake[msg.sender][_stakeID].deposit_amount;
    }

    /**
    * @dev Return sum of all the caller's stake amount
    * @return Amount of stake
     */
    function getTotalStakeAmount() external view returns (uint256) {
        Stake[] memory currentStake = stake[msg.sender];
        uint nummberOfStake = stake[msg.sender].length;
        uint totalStake = 0;
        uint tmp;
        for (uint i = 0; i<nummberOfStake; i++){
            tmp = currentStake[i].deposit_amount;
            totalStake = totalStake.add(tmp);
        }

        return totalStake;
    }

    /**
    *   @dev Return all the available stake info
    *   @notice Return stake info
    *   @param _stakeID ID of the stake which info is returned
    *   @return 1) Amount Deposited
    *   @return 2) Bool value that tells if the stake was withdrawed
    *   @return 3) Stake creation time (Unix timestamp)
    *   @return 5) The current amount
    *   @return 6) The penalty of withdraw
    */
    function getStakeInfo(uint _stakeID) external view returns(uint, bool, uint, uint, uint){

        Stake memory selectedStake = stake[msg.sender][_stakeID];

        uint amountToWithdraw = calculateInterest(_stakeID);

        uint penalty = calculatePenalty(selectedStake.deposit_amount);

        return (
            selectedStake.deposit_amount,
            selectedStake.returned,
            selectedStake.stake_creation_time,
            amountToWithdraw,
            penalty
        );
    }


    /**
    *  @dev Get the current pot value
    *  @return The amount of token in the current pot
     */
    function getCurrentPot() external view returns (uint){
        return pot;
    }

    /**
    * @dev Get the number of stake of the caller
    * @return Number of stake
     */
    function getStakeCount() external view returns (uint){
        return stake[msg.sender].length;
    }

    /**
    * @dev Get the number of active stake of the caller
    * @return Number of active stake
     */
    function getActiveStakeCount() external view returns(uint){
        uint stakeCount = stake[msg.sender].length;

        uint count = 0;

        for(uint i = 0; i<stakeCount; i++){
            if(!stake[msg.sender][i].returned){
                count = count + 1;
            }
        }
        return count;
    }

    //--------------------------------------------------------------------
    //-------------------------- INTERNAL -----------------------------------
    //--------------------------------------------------------------------

    /**
     * @dev Calculate the customer reward based on the provided stake
     * param uint _stakeID The stake where the reward should be calculated
     * @return The reward value
     */
    function calculateInterest(uint _stakeID) internal view returns (uint){
        Stake memory _stake = stake[msg.sender][_stakeID];

        uint amount_staked = _stake.deposit_amount;
        uint periods = calculatePeriods(_stakeID);  //Periods for interest calculation

        uint interestPerYear = amount_staked.mul(_INTEREST_RATE).div(100);  // amount * 40/100 
        uint interestPerDay = interestPerYear.div(_INTEREST_RATE_PERIOD);   // IntrestPerYer/365

        uint total_interest = interestPerDay.mul(periods);  //IntrestPerDay * noOfDays

        return total_interest;
    }

    function calculateRewardToWithdraw(address _account, uint _stakeID) internal view returns (uint){
        Stake memory _stake = stake[_account][_stakeID];

        uint amount_staked = _stake.deposit_amount;
        uint periods = calculatePeriods(_stakeID);  //Periods for interest calculation

        uint interestPerYear = amount_staked.mul(_INTEREST_RATE).div(100);  // amount * 40/100 
        uint interestPerDay = interestPerYear.div(_INTEREST_RATE_PERIOD);   // IntrestPerYer/365

        uint total_interest = interestPerDay.mul(periods);  //IntrestPerDay * noOfDays

        return total_interest;
    }


    function calculateTotalRewardToWithdraw(address _account) internal view returns (uint){
        Stake[] memory accountStakes = stake[_account];

        uint stakeNumber = accountStakes.length;
        uint amount = 0;

        for( uint i = 0; i<stakeNumber; i++){
            amount = amount.add(calculateRewardToWithdraw(_account, i));
        }

        return amount;
    }


    function calculatePeriods(uint _stakeID) public view returns (uint){
        Stake memory _stake = stake[msg.sender][_stakeID];
        uint creation_time = _stake.stake_creation_time;
        uint current_time = block.timestamp;

        uint total_period = current_time.sub(creation_time);

        uint periods = total_period.div(_INTEREST_PERIOD); //Default 1 Day

        return periods;
    }

    function calculateAccountStakePeriods(address _account, uint _stakeID) public view returns (uint){
        Stake memory _stake = stake[_account][_stakeID];


        uint creation_time = _stake.stake_creation_time;
        uint current_time = block.timestamp;

        uint total_period = current_time.sub(creation_time);

        uint periods = total_period.div(_INTEREST_PERIOD);

        return periods;
    }

    function calculatePenalty(uint _amountStaked) internal view returns (uint){
        uint tmp_penalty = _amountStaked.mul(_PENALTY_VALUE);   //Take the 5 percent
        return tmp_penalty.div(100);
    }


    function getContractBalance() internal view returns (uint){
        return busdContract.balanceOf(address(this));
    }

    //--------------------------------------------------------------
    //------------------------ DEBUG -------------------------------
    //--------------------------------------------------------------

    function getOwner() external view returns (address){
        return owner();
    }

}