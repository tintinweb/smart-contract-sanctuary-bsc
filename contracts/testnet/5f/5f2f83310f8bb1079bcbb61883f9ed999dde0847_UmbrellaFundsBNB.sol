/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

contract UmbrellaFundsBNB is Ownable,ReentrancyGuard{
    using SafeMath for uint256;

    uint256 public developerFee = 400; // 400 : 4 %. 10000 : 100 %
    uint256 public rewardPeriod = 1 days;
    uint256 public withdrawPeriod = 30 days;
    uint256 public apr = 65; // 65 : 0.65 %. 10000 : 100 %
    uint256 public percentRate = 10000;
    uint256 private MAX_NO_OF_INVESTMENT = 100;
    address private devWallet;
    uint256 public _currentDepositID = 0;

    uint256 public totalInvestors = 0;
    uint256 public totalReward = 0;
    uint256 public totalInvested = 0;


    struct DepositStruct{
        address investor;
        uint256 depositAmount;
        uint256 depositAt; // deposit timestamp
        uint256 claimedAmount; // claimed BNB amount
        bool state; // withdraw capital state. false if withdraw capital
    }

    struct InvestorStruct{
        address investor;
        uint256 totalLocked;
        uint256 startTime;
        uint256 lastCalculationDate;
        uint256 claimableAmount;
        uint256 claimedAmount;
    }

    event NewInvestor(
        address investor,
        uint256 amount,
        uint256 time
    );

    event NewInvestment (
        address investor,
        uint256 amount,
        uint256 time
    );

    event ClaimedReward (
        address investor,
        uint256 amount,
        uint256 time
    );

    event CapitalWithdrawn (
        address investor,
        uint256 amount,
        uint256 id,
        uint256 time
    );

    // mapping from depost Id to DepositStruct
    mapping(uint256 => DepositStruct) public depositState;
    // mapping form investor to deposit IDs
    mapping(address => uint256[]) public ownedDeposits;

    //mapping from address to investor
    mapping(address => InvestorStruct) public investors;

    constructor(address _devWallet) {
        require(_devWallet!=address(0),"Please provide a valid dev wallet address");
        devWallet = _devWallet;
    }

    function resetContract(address _devWallet) public onlyOwner {
        require(_devWallet!=address(0),"Please provide a valid address");
        devWallet = _devWallet;
    }

    function _getNextDepositID() private view returns (uint256) {
        return _currentDepositID + 1;
    }

    function _incrementDepositID() private {
        _currentDepositID++;
    }

    function deposit() external payable{
        require(ownedDeposits[msg.sender].length<MAX_NO_OF_INVESTMENT,"Cannot make more than 100 deposits from a single wallet");
        require(msg.value > 0, "You can deposit more than 0 BNB");
        uint256 _id = _getNextDepositID();
        _incrementDepositID();
        
        uint256 _amount = msg.value;

        uint256 depositFee = _amount.mul(developerFee).div(percentRate);
        payable(devWallet).transfer(depositFee);

        depositState[_id].investor = msg.sender;
        depositState[_id].depositAmount = _amount - depositFee;
        depositState[_id].depositAt = block.timestamp;
        depositState[_id].state = true;

        ownedDeposits[msg.sender].push(_id);

        if(investors[msg.sender].investor==address(0)){
            totalInvestors = totalInvestors.add(1);

            investors[msg.sender].investor = msg.sender;
            investors[msg.sender].startTime = block.timestamp;
            investors[msg.sender].lastCalculationDate = block.timestamp;

            emit NewInvestor(msg.sender, msg.value, block.timestamp);
        }

        investors[msg.sender].totalLocked = investors[msg.sender].totalLocked.add( _amount - depositFee);

        totalInvested = totalInvested.add(_amount);
        
        emit NewInvestment(msg.sender, msg.value, block.timestamp);
    }

    function claimAllReward() public nonReentrant {
        require(ownedDeposits[msg.sender].length > 0, "You can deposit once at least");

        uint256 claimableAmount = getAllClaimableReward(msg.sender);

        investors[msg.sender].claimedAmount = investors[msg.sender].claimedAmount.add(claimableAmount);

        investors[msg.sender].lastCalculationDate = block.timestamp;

        require(
            claimableAmount <= address(this).balance,
            "No enough BNB in pool"
        );

        totalReward = totalReward.add(claimableAmount);

        emit ClaimedReward(msg.sender, claimableAmount, block.timestamp);

        payable(msg.sender).transfer(claimableAmount);
    }

       // withdraw capital by deposit id
    function withdrawCapital(uint256 id) public nonReentrant {
        require(
            depositState[id].investor == msg.sender,
            "Only investor of this id can claim reward"
        );
        require(
            block.timestamp - depositState[id].depositAt > withdrawPeriod,
            "Withdraw lock time is not finished yet"
        );
        require(depositState[id].state, "You already withdrew capital");

        uint256 claimableReward = getAllClaimableReward(msg.sender);

        require(
            depositState[id].depositAmount + claimableReward <= address(this).balance,
            "No enough BNB in pool"
        );

        // transfer capital to the user
        payable(msg.sender).transfer( depositState[id].depositAmount + claimableReward);

        investors[depositState[id].investor].claimedAmount = investors[depositState[id].investor].claimedAmount.add(claimableReward);
        investors[msg.sender].lastCalculationDate = block.timestamp;

        totalReward = totalReward.add(claimableReward);
        depositState[id].state = false;

        emit CapitalWithdrawn(msg.sender,claimableReward , id, block.timestamp);
    }

    function getAllClaimableReward(address _investorAddress) public view returns(uint256 allClaimableAmount){
        for(uint256 i = 0; i < ownedDeposits[_investorAddress].length; i ++) {
            allClaimableAmount += getClaimableReward(ownedDeposits[_investorAddress][i]);
        }
    }

    function getClaimableReward(uint256 _id) public view returns(uint256 reward){
        if(depositState[_id].state == false) return 0;
        address investor = depositState[_id].investor;
        
        uint256 lastROIDate = investors[investor].lastCalculationDate;
        uint256 profit;
        if(lastROIDate>=depositState[_id].depositAt){
            profit = depositState[_id].depositAmount.mul(apr).mul(block.timestamp.sub(lastROIDate)).div(percentRate.mul(rewardPeriod));
        }else{
            profit = depositState[_id].depositAmount.mul(apr).mul(block.timestamp.sub(depositState[_id].depositAt)).div(percentRate.mul(rewardPeriod));
        }

        reward = profit;
    } 

    function getInvestor(address _investorAddress) public view returns(
        address investor,
        uint256 totalLocked,
        uint256 startTime,
        uint256 lastCalculationDate,
        uint256 claimableAmount,
        uint256 claimedAmount 
        ){
        investor = _investorAddress;
        totalLocked = investors[_investorAddress].totalLocked;
        startTime = investors[_investorAddress].startTime;
        lastCalculationDate = investors[_investorAddress].lastCalculationDate;
        claimableAmount = getAllClaimableReward(_investorAddress);
        claimedAmount = investors[_investorAddress].claimedAmount;
    }

    function getDepositState(uint256 _id) public view returns(address investor,uint256 depositAmount,uint256 depositAt, uint256 claimedAmount,bool state){
        investor = depositState[_id].investor;
        depositAmount = depositState[_id].depositAmount;
        depositAt = depositState[_id].depositAt;
        state = depositState[_id].state;
        claimedAmount = getClaimableReward(_id);
    }
    
    // adding pool by owner
    function depositFunds() external payable onlyOwner returns(bool) {
        require(msg.value > 0, "You can deposit more than 0 BNB");
        return true;
    }

    function withdrawFunds(uint256 amount) external onlyOwner nonReentrant {
        // transfer fund
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to withdraw funds");
    }
    
    function getOwnedDeposits(address investor) public view returns (uint256[] memory) {
        return ownedDeposits[investor];
    }
}