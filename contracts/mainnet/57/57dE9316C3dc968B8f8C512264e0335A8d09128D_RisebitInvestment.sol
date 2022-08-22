/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

// SPDX-License-Identifier: MIT

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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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

// File: minerLand.sol


pragma solidity ^0.8.4;




contract RisebitInvestment is ReentrancyGuard, Ownable {

    using SafeMath for uint256;

    address risebitInvestmentWallet;
    address marketingFeeWallet;
    address landMinerWallet;
    address minerWallet;
    address communityFeeWallet;
    address developmentFeeWallet;

    mapping (address => investor) investors;

    struct investor {
        address wallet;
        uint256 plan;
        uint256 balance;
        uint256 rewards;
        uint256 lastClaim;
        uint256 lastCompound;
        address referral;
    }

    receive() external payable {}  // anyone can send funds to this contract

    constructor() {
        risebitInvestmentWallet = 0x898C1D37c0d52c2af9241E7ac7A693f1292b3875;
        marketingFeeWallet = 0xfeEa1c5e1C3F5900e0e8450D232d8e367F52c4B6;
        landMinerWallet = 0x1619b9E1d57E8c83Dc0D30A9FEDA2828b4006aD3;
        minerWallet = 0xc63f742991f8E4167e199b7eF23af31629db843d;
        communityFeeWallet = 0xa20c1663035D9684feF6eC9b8081608AD00544BC;
        developmentFeeWallet = 0x5aD487E40DD70414149edDaeee7501Dd6e1193a3;
    }
    //DESCENTRALIZED INVESTMENT

    function investCoin() external payable nonReentrant {
        
        require(investors[msg.sender].wallet == msg.sender, "You need sign up"); 
        require(investors[msg.sender].plan >= 1 && investors[msg.sender].plan <= 3, "You need sign up and choose a plan"); 
        require(msg.value > 0, "Value needs to be > 0");

        uint256 hasRewards = getRewards(msg.sender);

        uint256 liquidityFee = 0;
        uint256 marketingFee = 0;
        uint256 entranceFee = 0;

        if(investors[msg.sender].plan == 1) {
            entranceFee = msg.value.div(100).mul(5);
            liquidityFee = entranceFee.div(100).mul(60);
            marketingFee = entranceFee.div(100).mul(40);
        }
        else if(investors[msg.sender].plan == 2) {
            entranceFee = msg.value.div(100).mul(7);
            liquidityFee = entranceFee.div(100).mul(60);
            marketingFee = entranceFee.div(100).mul(40);
        }
        else {
            entranceFee = msg.value.div(100).mul(10);
            liquidityFee = entranceFee.div(100).mul(60);
            marketingFee = entranceFee.div(100).mul(40);
        }


        uint256 investment = msg.value - liquidityFee - marketingFee;

        payable(risebitInvestmentWallet).transfer(liquidityFee);
        payable(marketingFeeWallet).transfer(marketingFee);

        investors[msg.sender].balance =  investors[msg.sender].balance + investment + hasRewards;
        investors[msg.sender].rewards = 0;
        investors[msg.sender].lastClaim = block.timestamp;
        investors[msg.sender].lastCompound = block.timestamp;


    }

    function claimRewards() external nonReentrant {

        uint256 rewards = investors[msg.sender].rewards + getRewards(msg.sender);

        require(investors[msg.sender].wallet == msg.sender, "You need sign up and choose a plan"); 
        require(rewards > 0, "You have not investment");
          
          
        uint lastClaim = investors[msg.sender].lastClaim;
        uint256 plan = investors[msg.sender].plan;

        uint daysDiff = (block.timestamp - lastClaim) / 60 / 60 / 24; // days
        uint256 landMinerFee = 0;
        uint256 minerFee = 0;
        uint256 communityFee = 0;
        uint256 developmentFee = 0;
        uint256 claimFee = 0;

        if(plan == 1) {
            require(daysDiff >= 7, "You can't claim until the 7 days");
            claimFee = rewards.div(100).mul(5);

            landMinerFee = claimFee.div(100).mul(14); //14% OF 5
            minerFee = claimFee.div(100).mul(24); // 24%
            communityFee = claimFee.div(100).mul(4);// 4%
            developmentFee = claimFee.div(100).mul(58); // 58%
        }
        else if(plan == 2) {
            require(daysDiff >= 14, "You can't claim until the 14 days");
            claimFee = rewards.div(100).mul(7);
            landMinerFee = claimFee.div(100).mul(14); 
            minerFee = claimFee.div(100).mul(24);
            communityFee = claimFee.div(100).mul(4);
            developmentFee = claimFee.div(100).mul(58); 
        }
        else {
            require(daysDiff >= 28, "You can't claim until the 28 days");
            claimFee = rewards.div(100).mul(10);
            landMinerFee = claimFee.div(100).mul(14); 
            minerFee = claimFee.div(100).mul(24);
            communityFee = claimFee.div(100).mul(4);
            developmentFee = claimFee.div(100).mul(58); 
        }

      
        uint256 referralAmount = 0;

        if(investors[msg.sender].referral != address(0)) {
            referralAmount = rewards.div(100).mul(10);
            payable(investors[msg.sender].referral).transfer(referralAmount);
        }
        uint256 claimAmount = rewards - landMinerFee - minerFee - communityFee - developmentFee - referralAmount;
        investors[msg.sender].rewards = 0;
        investors[msg.sender].lastClaim = block.timestamp;
        investors[msg.sender].lastCompound = block.timestamp;

        payable(landMinerWallet).transfer(landMinerFee);
        payable(minerWallet).transfer(minerFee);
        payable(communityFeeWallet).transfer(communityFee);
        payable(developmentFeeWallet).transfer(developmentFee);
        payable(msg.sender).transfer(claimAmount);

    }

    function compound() external nonReentrant{

        uint256 rewards = investors[msg.sender].rewards + getRewards(msg.sender);
        
        require(investors[msg.sender].wallet == msg.sender, "You need sign up and choose a plan"); 
        require(investors[msg.sender].plan >= 1 && investors[msg.sender].plan <= 3, "You need sign up and choose a plan"); 
        require(rewards > 0, "You have not investment");
          
          
        uint lastCompound = investors[msg.sender].lastCompound;

        uint daysDiff = (block.timestamp - lastCompound) / 60 / 60 / 24; // days
        require(daysDiff >= 1, "You can't compound until 1 day");
      
        uint256 compoundFee = rewards.div(100).mul(2);

        uint256 compoundAmount = rewards - compoundFee;
        
        investors[msg.sender].balance = investors[msg.sender].balance + compoundAmount;
        investors[msg.sender].rewards = 0;
        investors[msg.sender].lastCompound = block.timestamp;

    }


    //OTHER FUNCTIONS

    function setLandMinerwallet(address wallet) external onlyOwner {
        landMinerWallet = wallet;
    }

    function setMinerwallet(address wallet) external onlyOwner {
        minerWallet = wallet;
    }

    
    //VIEW FUNCTIONS

    function getRewards(address wallet) public view returns(uint256){ 
        uint256 rewards = 0;
        uint256 daysDiff = (block.timestamp - investors[wallet].lastCompound) / 60 / 60 / 24; // days;
        if(investors[wallet].plan == 1) {
            rewards = investors[wallet].balance.div(200).mul(2) * daysDiff;
        }
        else if(investors[wallet].plan == 2) {
            rewards = investors[wallet].balance.div(200).mul(3) * daysDiff;
        }
        else {
            rewards = investors[wallet].balance.div(200).mul(4) * daysDiff;
        }

        return rewards;
    }

    function getMyCurrentInfo() public view returns(investor memory) {
        return investors[msg.sender];
    }

    //CHOOSE PLANS
    function choosePlan(uint256 plan, address referral) external nonReentrant {

        require(plan == 1 || plan == 2 || plan == 3, "Plan needs to be 1 or 2 or 3");
        require(plan >  investors[msg.sender].plan, "Plan can't be equal or less to the current plan");

        if(investors[msg.sender].wallet == msg.sender) {
            uint256 rewards = investors[msg.sender].rewards + getRewards(msg.sender);
            uint256 balance = investors[msg.sender].balance + rewards;
            uint256 newBalance = 0;

            if(plan == 1) {
                newBalance = balance - (balance.div(100).mul(5));
               
            }
            else if(plan == 2) {
                newBalance = balance - (balance.div(100).mul(7));
            }
            else {
                newBalance = balance - (balance.div(100).mul(10));
            }

            investors[msg.sender].balance = newBalance;
            investors[msg.sender].rewards = 0;
            investors[msg.sender].lastCompound = block.timestamp;
            investors[msg.sender].lastClaim = block.timestamp;
            investors[msg.sender].plan = plan;
        

        }

        else {
            investors[msg.sender] = investor(
                msg.sender,
                plan,
                0,
                0,
                block.timestamp,
                block.timestamp,
                referral
            );
        }
    }

}