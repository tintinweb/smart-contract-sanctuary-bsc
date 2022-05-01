/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// File: PreSale_flat.sol


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

// File: contracts/PreSale.sol

pragma solidity 0.8.0;



 

contract AriaPreSale is Ownable {
    using SafeMath for uint256;

    address public BUSD = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); // mainnet address 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    address public devTeamWallet = address(0xA2498eBE2C41cD5209fD59bd54B356049fA8D43a); // mainnet address 0xA2498eBE2C41cD5209fD59bd54B356049fA8D43a
    mapping (address => uint256) public ariaTracker;

    constructor() public {}
    receive() external payable {}
    fallback() external payable {}


    function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }

    struct BuyTracker {
        uint256 aria;
        uint256 busd;
        address addr;
    }
    uint public numberOfItems = 0;
    mapping (uint => BuyTracker) public buyingTracker;

    function setPaymentToken(address token) public onlyOwner {
        BUSD = token;
    }
    
    function updateBuyTracker(uint256 aria, uint256 busd, address addr) private {
        BuyTracker storage latestItem = buyingTracker[numberOfItems];
        latestItem.aria = aria;
        latestItem.busd = busd;
        latestItem.addr = addr;
        numberOfItems++;
    }

    uint256 public constant round1PreSaleRate = 1000; //  1000 per 1 USD 
    uint256 public constant ogMaxBUSD = 500 * (10**18);  // 500 USD
    uint256 public constant wlMaxBUSD = 750 * (10**18); // 750 USD 

    uint256 public round1Tracker; 
    uint256 public constant round1Max = 200000 * (10**18); // 200,000 USD
    
    mapping (address => bool) public round1OGList;
    mapping (address => bool) public round1WhiteList;
    mapping (address => uint256) public round1PurchaseTracker;
    bool public round1PreSaleOpen = false;

    function whiteListMultipleAccountsRound1(address[] calldata accounts, bool whitelisted) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            round1WhiteList[accounts[i]] = whitelisted;
        }
    }

    function ogWhiteListMultipleAccountsRound1(address[] calldata accounts, bool whitelisted) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            round1OGList[accounts[i]] = whitelisted;
        }
    }

    function openRound1Presale() public onlyOwner {
        round1PreSaleOpen = true;
    }

    function closeRound1Presale() public onlyOwner {
        round1PreSaleOpen = false;
    }

    function preSaleRound1(uint256 usdAmount) external payable {
        require(round1PreSaleOpen, "Aria Presale Round 1 is not Open yet");
        require(round1OGList[msg.sender] || round1WhiteList[msg.sender], "You are not part of the WhiteList for Round 1");
        require(round1Tracker.add(usdAmount) <= round1Max, "Round 1 total allocation is $200,000 USD and is now all sold out");

        if (round1OGList[msg.sender]) {
            require(usdAmount <= ogMaxBUSD, "OG can only spend 500 USD");
        } else if (round1WhiteList[msg.sender]) {
            require(usdAmount <= wlMaxBUSD, "WL can only spend 750 USD");
        }

        uint256 tempSenderAmount = round1PurchaseTracker[msg.sender].add(usdAmount);

        if (round1OGList[msg.sender]) {
            require(tempSenderAmount <= ogMaxBUSD, "You have reached the max that you can buy in your wallet which is 500USD");
        } else if (round1WhiteList[msg.sender]) {
            require(tempSenderAmount <= wlMaxBUSD, "You have reached the max that you can buy in your wallet which is 750USD");
        }

        require(IERC20(BUSD).allowance(msg.sender, address(this)) >= usdAmount,"Insuficient Allowance");

        round1Tracker = round1Tracker.add(usdAmount);
        uint256 ariaTokenAmount = round1PreSaleRate.mul(usdAmount);
        ariaTracker[msg.sender] = ariaTracker[msg.sender].add(ariaTokenAmount);
        round1PurchaseTracker[msg.sender] = tempSenderAmount;
        updateBuyTracker(ariaTokenAmount, usdAmount, msg.sender);

        bool success1 = IERC20(BUSD).transferFrom(msg.sender, address(this), usdAmount);

        if (success1) {
            IERC20(BUSD).transfer(devTeamWallet, usdAmount);
        } else {
            round1Tracker = round1Tracker.sub(usdAmount);
            ariaTracker[msg.sender] = ariaTracker[msg.sender].sub(ariaTokenAmount);
            round1PurchaseTracker[msg.sender] = round1PurchaseTracker[msg.sender].sub(tempSenderAmount);
            numberOfItems--;
        }
    }



    uint256 public constant round2PreSaleRate = 952; //  952 per 1 USD 
    uint256 public constant round2WlMaxBUSD = 4000 * (10**18); // 4000 USD 
    uint256 public constant round2WlMinBUSD = 50 * (10**18); // 50 USD 

    uint256 public round2Tracker; 
    uint256 public constant round2Max = 525000 * (10**18); // 525,000 USD
    
    mapping (address => bool) public round2AllWlList;
    mapping (address => uint256) public round2PurchaseTracker;
    bool public round2PreSaleOpen = false;

    function allWhiteListMultipleAccountsRound2(address[] calldata accounts, bool whitelisted) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            round2AllWlList[accounts[i]] = whitelisted;
        }
    }

    function openRound2Presale() public onlyOwner {
        round2PreSaleOpen = true;
    }

    function closeRound2Presale() public onlyOwner {
        round2PreSaleOpen = false;
    }

    function preSaleRound2(uint256 usdAmount) external payable {
        require(round2PreSaleOpen, "Aria Presale Round 2 is not Open yet");
        require(round2AllWlList[msg.sender], "You are not part of the WhiteList for Round 2");
        require(round2Tracker.add(usdAmount) <= round2Max, "Round 2 total allocation is $525,000 USD and is now all sold out");
        require(usdAmount >= round2WlMinBUSD, "You have to spend 50 USD or more");
        require(usdAmount <= round2WlMaxBUSD, "You can only spend 4000 USD");

        uint256 tempSenderAmount = round2PurchaseTracker[msg.sender].add(usdAmount);

        require(tempSenderAmount <= round2WlMaxBUSD, "You have reached the max that you can buy in your wallet which is 4000USD");

        require(IERC20(BUSD).allowance(msg.sender, address(this)) >= usdAmount,"Insuficient Allowance");

        round2Tracker = round2Tracker.add(usdAmount);
        uint256 ariaTokenAmount = round2PreSaleRate.mul(usdAmount);
        ariaTracker[msg.sender] = ariaTracker[msg.sender].add(ariaTokenAmount);
        round2PurchaseTracker[msg.sender] = tempSenderAmount;
        updateBuyTracker(ariaTokenAmount, usdAmount, msg.sender);
        
        bool success1 = IERC20(BUSD).transferFrom(msg.sender, address(this), usdAmount);

        if (success1) {
            IERC20(BUSD).transfer(devTeamWallet, usdAmount);
        } else {
            round2Tracker = round2Tracker.sub(usdAmount);
            ariaTracker[msg.sender] = ariaTracker[msg.sender].sub(ariaTokenAmount);
            round2PurchaseTracker[msg.sender] = round2PurchaseTracker[msg.sender].sub(tempSenderAmount);
            numberOfItems--;
        }
    }


    bool public claimOpen = false;
    address public ariaContractAddress = address(0x1826175169A4aa1C4632563e94F5AB4Eabc94d0F); // mainnet 0x1826175169A4aa1C4632563e94F5AB4Eabc94d0F

    function openClaim() public onlyOwner {
        claimOpen = true;
    }

    function setAriaContractAddress(address token) public onlyOwner {
        ariaContractAddress = token;
    }

    function claimTokens() public {
        require(claimOpen, "Aria Claim is not Open yet");
        require(ariaTracker[msg.sender] > 0, "You already claimed all your Aria Token");
        require(round2AllWlList[msg.sender], "You are not part of the WhiteList that was able to Pre Purchase Aria token");
        require(IERC20(ariaContractAddress).balanceOf(address(this)) > 0, "The contract ran out of Aria Token");

        uint256 amount = ariaTracker[msg.sender];
        ariaTracker[msg.sender] = 0;

        bool success = IERC20(ariaContractAddress).transfer(msg.sender, amount);
        if (!success) {
            ariaTracker[msg.sender] = amount;
        }
    }
}