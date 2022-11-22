/**
 *Submitted for verification at BscScan.com on 2022-11-22
*/

// SPDX-License-Identifier: MIT

// File: minerBUSD.sol



// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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

// File: minerBUSD.sol


pragma solidity ^0.8.4;





interface UniswapForkV2Router {
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
}

contract RisebitInvestment is ReentrancyGuard, Ownable {

    using SafeMath for uint256;

    address busd;
    address risebitInvestmentWallet;
    address marketingFeeWallet;
    address landMinerWallet;
    address minerWallet;
    address communityFeeWallet;
    address developmentFeeWallet;

    address PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //PANCAKE
    address risecoin = 0x6e22BFc7236E95C3AEF6AcdBd7218bCF59A483aC;

    uint256 daysLockBasic = 7;
    uint256 daysLockPremium = 14;
    uint256 daysLockVIP = 28;

    mapping(address => Transaction[]) transactions;

    struct Transaction {
        uint256 amount;
        uint256 transactionType;
        string description;
        uint256 timestamp;
    }

    mapping(address => address) referralByWallet;
    
    mapping (address => Investor[]) investors;
    
    struct Investor {
        uint256 id;
        address wallet;
        uint256 plan;
        uint256 balance;
        uint256 claimedRewards;
        uint256 lastClaim;
        uint256 lastCompound;
        address referral;
        uint256 maxCompound;
        uint256 maxRewards;
        bool isActivate;
    }

    mapping(address => ReferralDeposit[]) referralDepositsPerWallet;

    struct ReferralDeposit {
        address from;
        uint256 amount;
    }

    event choosePlanEvent(address sender, uint256 plan);
    event investCoinEvent(address sender, uint256 amount);
    event claimCoinEvent(address sender, uint256 amount);
    event compoundEvent(address sender, uint256 amount);

    // anyone can send funds to this contract
    receive() external payable {}  

    constructor() {
        busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        risebitInvestmentWallet = 0x898C1D37c0d52c2af9241E7ac7A693f1292b3875;
        marketingFeeWallet = 0xfeEa1c5e1C3F5900e0e8450D232d8e367F52c4B6;
        landMinerWallet = 0x1619b9E1d57E8c83Dc0D30A9FEDA2828b4006aD3;
        minerWallet = 0xc63f742991f8E4167e199b7eF23af31629db843d;
        communityFeeWallet = 0xa20c1663035D9684feF6eC9b8081608AD00544BC;
        developmentFeeWallet = 0x5aD487E40DD70414149edDaeee7501Dd6e1193a3;
    }

    //DESCENTRALIZED INVESTMENT

    //CHOOSE PLANS


    function changePlan(uint256 plan, uint256 _index) external nonReentrant {

        require(plan == 1 || plan == 2 || plan == 3, "Plan needs to be 1 or 2 or 3");
        require(plan >  investors[msg.sender][_index].plan, "Plan can't be equal or less to the current plan");

        uint256 rewards = getRewards(msg.sender, _index);
        uint256 balance = investors[msg.sender][_index].balance + rewards;
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

        investors[msg.sender][_index].balance = newBalance;
        investors[msg.sender][_index].claimedRewards += rewards;
        investors[msg.sender][_index].lastCompound = block.timestamp;
        investors[msg.sender][_index].lastClaim = block.timestamp;
        investors[msg.sender][_index].plan = plan;

        emit choosePlanEvent(msg.sender, plan);
    }

    function investCoin(uint256 _plan, uint256 _amount, address _referral) external nonReentrant {

        require(_plan == 1 || _plan == 2 || _plan == 3, "Plan needs to be 1 or 2 or 3");
        require(IERC20(busd).balanceOf(msg.sender) >= _amount, "Value needs to be > 0");
          
        uint256 liquidityFee = 0;
        uint256 marketingFee = 0;
        uint256 entranceFee = 0;
        uint256 referralAmount = 0;
        uint256 referralAmountTwo = 0;
        bool hasReferral =  referralByWallet[msg.sender] != address(0) ? true: _referral != address(0) ? true: false;
        

        if(_plan == 1) {
            entranceFee = hasReferral ? _amount.div(200).mul(9) : _amount.div(100).mul(5);
            liquidityFee = entranceFee.div(100).mul(60);
            marketingFee = entranceFee.div(100).mul(40);
        }
        else if(_plan == 2) {
            entranceFee =  hasReferral ?  _amount.div(400).mul(25) : _amount.div(100).mul(7);
            liquidityFee = entranceFee.div(100).mul(60);
            marketingFee = entranceFee.div(100).mul(40);
        }
        else {
            entranceFee =  hasReferral ?  _amount.div(100).mul(9) : _amount.div(100).mul(10);
            liquidityFee = entranceFee.div(100).mul(60);
            marketingFee = entranceFee.div(100).mul(40);
        }

        if(hasReferral) {
            referralByWallet[msg.sender] = referralByWallet[msg.sender] != address(0) ? referralByWallet[msg.sender]:  _referral;

            if(referralByWallet[referralByWallet[msg.sender]] != address(0)) {
                referralAmount = _plan == 1 ? _amount.div(500).mul(2): _plan == 2 ? _amount.div(500).mul(3): _amount.div(1000).mul(8);
                referralAmountTwo = _plan == 1 ? _amount.div(1000).mul(1): _plan == 2 ? _amount.div(2000).mul(3): _amount.div(1000).mul(2);
                IERC20(busd).transferFrom(msg.sender, referralByWallet[msg.sender] != address(0) ? referralByWallet[msg.sender]:  _referral, referralAmount);
                IERC20(busd).transferFrom(msg.sender, referralByWallet[referralByWallet[msg.sender]], referralAmountTwo);

                referralDepositsPerWallet[referralByWallet[msg.sender] != address(0) ? referralByWallet[msg.sender]:  _referral].push(
                    ReferralDeposit(
                        msg.sender,
                        referralAmount
                    )
                );

                referralDepositsPerWallet[referralByWallet[referralByWallet[msg.sender]]].push(
                    ReferralDeposit(
                        msg.sender,
                        referralAmountTwo
                    )
                );

            }
            else {
                referralAmount = _plan == 1 ? _amount.div(200).mul(1): _plan == 2 ? _amount.div(400).mul(3): _amount.div(100).mul(1);
                IERC20(busd).transferFrom(msg.sender, referralByWallet[msg.sender] != address(0) ? referralByWallet[msg.sender]:  _referral, referralAmount);

                referralDepositsPerWallet[referralByWallet[msg.sender] != address(0) ? referralByWallet[msg.sender]:  _referral].push(
                    ReferralDeposit(
                        msg.sender,
                        referralAmount
                    )
                );
            }
           
        }

        uint256 investment = _amount - referralAmount - referralAmountTwo;

        IERC20(busd).transferFrom(msg.sender, address(this), investment);

        swap(entranceFee);

        transactions[msg.sender].push(
            Transaction(
                investment - liquidityFee - marketingFee,
                1,
                "Investment of BUSD",
                block.timestamp
            )
        );

    
        emit investCoinEvent(msg.sender, investment);

          investors[msg.sender].push(
                Investor(
                    investors[msg.sender].length,
                    msg.sender,
                    _plan,
                    investment - liquidityFee - marketingFee,
                    0,
                    block.timestamp,
                    block.timestamp,
                    _referral,
                    _amount * 4,
                    investment * 2,
                    true
                )
            );
    }

    function claimRewards(uint256 _index) external nonReentrant {
        
        uint256 rewards =  getRewards(msg.sender, _index);
        
        require(investors[msg.sender][_index].wallet == msg.sender, "You need sign up and choose a plan"); 
        require(rewards > 0, "You have not investment");
          
          
        uint lastClaim = investors[msg.sender][_index].lastClaim;
        uint256 plan = investors[msg.sender][_index].plan;

        uint daysDiff = (block.timestamp - lastClaim) / 60 / 60 / 24; // days
        uint256 landMinerFee = 0;
        uint256 minerFee = 0;
        uint256 communityFee = 0;
        uint256 developmentFee = 0;
        uint256 claimFee = 0;

        if(plan == 1) {
            require(daysDiff >= daysLockBasic, "You can't claim until the 7 days");
            claimFee = rewards.div(100).mul(5);
            landMinerFee = claimFee.div(100).mul(14); //14% OF 5
            minerFee = claimFee.div(100).mul(24); // 24%
            communityFee = claimFee.div(100).mul(4);// 4%
            developmentFee = claimFee.div(100).mul(58); // 58%
        }
        else if(plan == 2) {
            require(daysDiff >= daysLockPremium, "You can't claim until the 14 days");
            claimFee = rewards.div(100).mul(7);
            landMinerFee = claimFee.div(100).mul(14); 
            minerFee = claimFee.div(100).mul(24);
            communityFee = claimFee.div(100).mul(4);
            developmentFee = claimFee.div(100).mul(58); 
        }
        else {
            require(daysDiff >= daysLockVIP, "You can't claim until the 28 days");
            claimFee = rewards.div(100).mul(10);
            landMinerFee = claimFee.div(100).mul(14); 
            minerFee = claimFee.div(100).mul(24);
            communityFee = claimFee.div(100).mul(4);
            developmentFee = claimFee.div(100).mul(58); 
        }


        uint256 claimAmount = rewards - landMinerFee - minerFee - communityFee - developmentFee;
        

        investors[msg.sender][_index].lastClaim = block.timestamp;
        investors[msg.sender][_index].lastCompound = block.timestamp;
        investors[msg.sender][_index].claimedRewards += rewards;   
        investors[msg.sender][_index].isActivate = false;   

        IERC20(busd).transfer(landMinerWallet, landMinerFee);
        IERC20(busd).transfer(minerWallet, minerFee);
        IERC20(busd).transfer(communityFeeWallet, communityFee);
        IERC20(busd).transfer(developmentFeeWallet, developmentFee);
        IERC20(busd).transfer(msg.sender, claimAmount);

        transactions[msg.sender].push(
            Transaction(
                claimAmount,
                2,
                "BUSD Withdrawal",
                block.timestamp
            )
        );

        emit claimCoinEvent(msg.sender, claimAmount);
    }

    function compound(uint256 _index) external nonReentrant{

        uint256 rewards = getRewards(msg.sender, _index);
        
        require(investors[msg.sender][_index].wallet == msg.sender, "You need sign up and choose a plan"); 
        require(investors[msg.sender][_index].plan >= 1 && investors[msg.sender][_index].plan <= 3, "You need sign up and choose a plan"); 
        require(rewards + (investors[msg.sender][_index].balance) <= investors[msg.sender][_index].maxCompound, "You can't compound more"); 
        require(rewards > 0, "You have not investment");
        
        uint lastCompound = investors[msg.sender][_index].lastCompound;

        uint daysDiff = (block.timestamp - lastCompound) / 60 / 60 / 24; // days
        require(daysDiff >= 1, "You can't compound until 1 day");

        uint256 compoundFee = rewards.div(100).mul(5);

        uint256 compoundAmount = rewards - compoundFee;

        if(compoundAmount + (investors[msg.sender][_index].balance) <= investors[msg.sender][_index].balance * 2) {
        
       
            investors[msg.sender][_index].balance = investors[msg.sender][_index].balance + compoundAmount;
            investors[msg.sender][_index].lastCompound = block.timestamp;

            transactions[msg.sender].push(
                Transaction(
                    compoundAmount,
                    1,
                    "BUSD Compound",
                    block.timestamp
                )
            );

            emit compoundEvent(msg.sender, compoundAmount);

        }

        else {
            
            investors[msg.sender][_index].balance = investors[msg.sender][_index].balance * 2;
            investors[msg.sender][_index].lastCompound = block.timestamp;

            transactions[msg.sender].push(
                Transaction(
                    compoundAmount,
                    1,
                    "BUSD Compound",
                    block.timestamp
                )
            );

            emit compoundEvent(msg.sender, compoundAmount);
        }
        
   

     

    }

    function activate(uint256 _index) external nonReentrant {
       

        require(!investors[msg.sender][_index].isActivate, "You can't activate yet");

        if(investors[msg.sender][_index].plan == 1) {
            investors[msg.sender][_index].balance = investors[msg.sender][_index].balance.div(100).mul(95);
        }
        else if(investors[msg.sender][_index].plan == 2) {
            investors[msg.sender][_index].balance = investors[msg.sender][_index].balance.div(100).mul(93);
        }
        else {
            investors[msg.sender][_index].balance = investors[msg.sender][_index].balance.div(100).mul(90);
        }

        investors[msg.sender][_index].isActivate = true;
        investors[msg.sender][_index].lastClaim = block.timestamp;
        investors[msg.sender][_index].lastCompound = block.timestamp;

    }

    //OTHER FUNCTIONS

    function setLandMinerwallet(address wallet) external onlyOwner {
        landMinerWallet = wallet;
    }

    function setMinerwallet(address wallet) external onlyOwner {
        minerWallet = wallet;
    }

    
    //VIEW FUNCTIONS

    function getRewards(address wallet, uint256 _index) public view returns(uint256){ 

        uint256 rewards = 0;
        uint256 rewardsToClaim = 0;
        Investor memory stake =  investors[wallet][_index];
        uint256 minutesDiff = (block.timestamp - stake.lastCompound) / 60; // minutes;
        uint256 minutesSinceStake =  (block.timestamp  - stake.lastClaim) / 60; // minutes
        uint256 lockTime = stake.plan == 1 ? daysLockBasic : stake.plan == 2 ? daysLockPremium: daysLockVIP;
        
        if(stake.plan == 1) {
            rewards = stake.balance.div(200).mul(2).mul(minutesDiff).div(60).div(24);
        }
        else if(stake.plan == 2) {
            rewards = stake.balance.div(200).mul(3).mul(minutesDiff).div(60).div(24);
        }
        else {
            rewards = stake.balance.div(200).mul(4).mul(minutesDiff).div(60).div(24);
        }

        if(minutesSinceStake <= lockTime * 60 * 24) {
        

            if(stake.claimedRewards >=  (stake.balance * 2)) {
                rewardsToClaim = 0;
            }

            else if(stake.claimedRewards + rewards <= (stake.balance * 2)) {
                rewardsToClaim = rewards;
            }
            
            else if(stake.claimedRewards <= (stake.balance * 2)) {
                rewardsToClaim = (stake.balance * 2) - stake.claimedRewards;
            }

            else {
                rewardsToClaim = 0;
            }

        }
        
        else {
        
            

            if(stake.claimedRewards >=  (stake.balance * 2)) {
                rewardsToClaim = 0;
            }

            else if(stake.claimedRewards + rewards <= (stake.balance * 2)) {
                rewardsToClaim = rewards;
            }
            
            else if(stake.claimedRewards <= (stake.balance * 2)) {
                rewardsToClaim = (stake.balance * 2) - stake.claimedRewards;
            }

            else {
                rewardsToClaim = 0;
            }
            
        }
        
        if(!stake.isActivate) rewardsToClaim = 0;

        return rewardsToClaim;
        
    }


    function getMyCurrentInfo(uint256 _index) public view returns(Investor memory) {
        return investors[msg.sender][_index];
    }

    function getMyCurrentInvestments() public view returns(Investor[] memory) {
        return investors[msg.sender];
    }

    function getLiquidity() external view returns(uint256) {
        return IERC20(busd).balanceOf(address(this));
    }

    function getLastTransactions(address wallet) external view returns(Transaction[] memory) {
        
        Transaction[] memory items;
        uint totalItemCount =  transactions[wallet].length;
        uint currentIndex = 0;

        for(uint i = 0; i < totalItemCount; i++) {
            items[currentIndex] = transactions[wallet][i];
            currentIndex += 1;
        }

        return items;
    }

     function getAllTransactions(address wallet) external view returns(Transaction[] memory) {
        return transactions[wallet];
    }

    function getIsActivate(address wallet, uint256 _index) public view returns(bool) {
        return investors[wallet][_index].isActivate;
    }

    function getReferralDepositsPerWallet(address wallet) external view returns(ReferralDeposit[] memory) {
        return referralDepositsPerWallet[wallet];
    }


    //DEX FUNCTIONALITIES

    
    function swap(uint256 amount) internal {
      
        address[] memory path;
        address _tokenIn = busd; //RISECOIN
        address _tokenOut = risecoin; //BUSD


        uint256 slippagePercentage = 5;
        uint256 amountOutMin = amount - (amount.mul(slippagePercentage).div(100));

        uint256 _amountIn = amount;
        uint256 _amountOutMin = getAmountOutMin(_tokenIn, _tokenOut, amountOutMin);
      
        path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;

        IERC20(busd).approve(PANCAKE_ROUTER, _amountIn);

        UniswapForkV2Router(PANCAKE_ROUTER).swapExactTokensForTokens(_amountIn, _amountOutMin, path, risebitInvestmentWallet, block.timestamp);

    }

  
        //this function will return the minimum amount from a swap
        //input the 3 parameters below and it will return the minimum amount out
        //this is needed for the swap function above
    function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) public view returns (uint256) {

        //path is an array of addresses.
        //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
        //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path;


        path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
  
        
        try UniswapForkV2Router(PANCAKE_ROUTER).getAmountsOut(_amountIn, path) returns ( uint256[] memory) 
        { 
            uint256[] memory amountOutMins = UniswapForkV2Router(PANCAKE_ROUTER).getAmountsOut(_amountIn, path);
            return amountOutMins[path.length -1];  
        }
        catch

        {
             return 0;
        }
    
       
    }  
}