/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

// SPDX-License-Identifier: MIT

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


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */

library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /*
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /*
     * @dev Transfers ownership of the contract to a new account (newOwner).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract constructorLibrary {
    
    struct parameter {
        string nameOfProject;

        uint256 _saleStartTime;
        uint256 _saleEndTime;

        address payable _projectOwner;
        address payable _tokenSender;
        uint256 maxAllocTierOne;
        uint256 maxAllocTierTwo;
        uint256 maxAllocTierThree;
        
        uint256 minAllocTierOne;
        uint256 minAllocTierTwo;
        uint256 minAllocTierThree;

        //min BUSD required to enter Tier
        uint256 minBUSDvalue_TierOne;
        uint256 minBUSDvalue_TierTwo;
        uint256 minBUSDvalue_TierThree;
        
        address tokenToIDO;
        uint256 tokenDecimals;
        uint256 _numberOfIdoTokensToSell;
        uint256 _tokenPriceInBUSD;

        uint256 _tierOneMaxCap;
        uint256 _tierTwoMaxCap;
        uint256 _tierThreeMaxCap;
        
        uint256 _softCapPercentage;
        uint256 _numberOfVestings;
        uint256[] _vestingPercentages;
        uint256[] _vestingUnlockTimes;
    }

}



contract ProjectStarterLaunchPad is Ownable, constructorLibrary, ReentrancyGuard {
    using SafeMath for uint256;

    //token attributes
    string public NAME_OF_PROJECT; //name of the contract

    // IERC20 public nativeToken; //native token of IDO
    IERC20 public BUSDToken;   // BUSD address

    IERC20 public token; //token to do IDO of
    
    uint256 public maxCap; // Max cap in BUSD       //18 decimals
    uint256 public numberOfIdoTokensToSell; //18 decimals
    uint256 public tokenPriceInBUSD; //18 decimals

    uint256 public saleStartTime; // start sale time

    uint256 public saleEndTime; // end sale time

    uint256 public totalBUSDReceivedInAllTier; // total BUSD received

    uint256 public softCapInAllTiers; // softcap if not reached IDO Fails
    uint256 public softCapPercentage;   //softcap percentage of entire sale

    uint256 public totalBUSDInTierOne; // total BUSD for tier One
    uint256 public totalBUSDInTierTwo; // total BUSD for tier Two
    uint256 public totalBUSDInTierThree; // total BUSD for tier Three

    address payable public projectOwner; // project Owner

    // max cap per tier in BUSD
    uint256 public tierOneMaxCap;
    uint256 public tierTwoMaxCap;
    uint256 public tierThreeMaxCap;

    //max allocations per user in a tier BUSD
    uint256 public maxAllocaPerUserTierOne;
    uint256 public maxAllocaPerUserTierTwo;
    uint256 public maxAllocaPerUserTierThree;
    
    //min allocations per user in a tier BUSD
    uint256 public minAllocaPerUserTierOne;
    uint256 public minAllocaPerUserTierTwo;
    uint256 public minAllocaPerUserTierThree;

    //min BUSD required to enter Tier
    uint256 public minBUSDvalue_TierOne;
    uint256 public minBUSDvalue_TierTwo;
    uint256 public minBUSDvalue_TierThree;

    //mapping the user purchase per tier
    mapping(address => uint256) public buyInOneTier;
    mapping(address => uint256) public buyInTwoTier;
    mapping(address => uint256) public buyInThreeTier;

    bool public tierTransfer = false;

    bool public successIDO = false;
    bool public failedIDO = false;

    address public tokenSender; // the owner who sends the token in the contract

    uint256 public decimals; //decimals of the IDO token

    bool public finalizedDone = false; //check if sale is finalized and both BUSD and tokens locked in contract to distribute afterwards

    mapping( address => mapping(uint256 => bool) ) public alreadyClaimed;     // tracks the vesting of each user

    uint256 public numberOfVestings;        // Number of vestings in the IDO (first vesting is the TGE)
    uint256[] public vestingPercentages;    // Vesting Percentages in the IDO (first vesting is the TGE)
    uint256[] public vestingUnlockTimes;     // Vesting StartTimes in the IDO (first vesting is the TGE)

    bool public initialized;

    event Participated(address wallet, uint256 value);
    event SaleFinalized(uint256 timestamp, bool successIDO); 
    event ClaimedTokens(uint256 timestamp, uint256 vesting, uint256 amount);
    event ClaimedBUSD(uint256 timestamp, uint256 amount);

    // CONSTRUCTOR
    constructor() {
        initialized = false;
    }

    function setup(address seedToken) public onlyOwner {
        require(initialized == false, "Already Initialized");

        NAME_OF_PROJECT = "Project Starter Seed Sale"; // name of the project to do IDO of

        token = IERC20(seedToken); //token to ido
        BUSDToken = IERC20(0x55d398326f99059fF775485246999027B3197955);

        decimals = 18; //decimals of ido token (no decimals)

        numberOfIdoTokensToSell = 15000000; //No decimals
        tokenPriceInBUSD = 50000000000000000; //18 decimals (0.05 in wei)

        maxCap = numberOfIdoTokensToSell * tokenPriceInBUSD; //18 decimals

        saleStartTime = block.timestamp; //main sale start time

        saleEndTime = block.timestamp + 365 days; //main sale end time

        projectOwner =  payable(0x0B6c8fc902b05Ef70E6D65d863311EE35Ba74713);
        tokenSender = 0x0B6c8fc902b05Ef70E6D65d863311EE35Ba74713;

        // total distribution in tiers of all BUSD participation
        tierOneMaxCap = 15000000 ether; //  maxCap
        tierTwoMaxCap = 15000000 ether; //  maxCap
        tierThreeMaxCap = 15000000 ether; //  maxCap

        //give values in wei amount 18 decimals BUSD
        maxAllocaPerUserTierOne = 15000000 ether;
        maxAllocaPerUserTierTwo = 15000000 ether;
        maxAllocaPerUserTierThree = 15000000 ether;

        //give values in wei amount 18 decimals BUSD
        minAllocaPerUserTierOne = 1 ether;
        minAllocaPerUserTierTwo = 1 ether;
        minAllocaPerUserTierThree = 1 ether;

        //min BUSD required to enter Tier
        minBUSDvalue_TierOne = 50000 ether;
        minBUSDvalue_TierTwo = 30000 ether;
        minBUSDvalue_TierThree = 10000 ether;

        softCapPercentage = 0;
        softCapInAllTiers = maxCap.div(100).mul(softCapPercentage);

        numberOfVestings = 20;
        vestingPercentages = [
            5,5,5,5,5,
            5,5,5,5,5,
            5,5,5,5,5,
            5,5,5,5,5
        ];
        uint256 firstVesting = saleEndTime;
        uint256 month = 30 days;
        vestingUnlockTimes = [
            firstVesting + (month * 1), firstVesting + (month * 2), firstVesting + (month * 3), firstVesting + (month * 4), firstVesting + (month * 5),
            firstVesting + (month * 6), firstVesting + (month * 7), firstVesting + (month * 8), firstVesting + (month * 9), firstVesting + (month * 10), 
            firstVesting + (month * 11), firstVesting + (month * 12), firstVesting + (month * 13), firstVesting + (month * 14), firstVesting + (month * 15), 
            firstVesting + (month * 16), firstVesting + (month * 17), firstVesting + (month * 18), firstVesting + (month * 19), firstVesting + (month * 20)
        ];

        initialized = true;

    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require( address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function sendBUSD(address payable recipient, uint256 amount) internal {
        require( BUSDToken.balanceOf(address(this)) >= amount, "BUSD: Insufficient Balance" );
        BUSDToken.transfer(recipient, amount);
    }

    function set_minBUSDvaluePerTier(uint256 _minBUSDvalue_TierOne, uint256 _minBUSDvalue_TierTwo, uint256 _minBUSDvalue_TierThree ) public onlyOwner{
        minBUSDvalue_TierOne = _minBUSDvalue_TierOne;
        minBUSDvalue_TierTwo = _minBUSDvalue_TierTwo;
        minBUSDvalue_TierThree = _minBUSDvalue_TierThree;
    }

    //send BUSD to the contract address
    //used to participate in the public sale according to your tier
    //main logic of IDO called and implemented here
    function participateAndPay(uint256 value, uint256 _tierID) public {
        require(block.timestamp >= saleStartTime, "Sale is not yet started"); // solhint-disable
        require(block.timestamp <= saleEndTime, "Sale is closed"); // solhint-disable
        require( totalBUSDReceivedInAllTier.add(value) <= maxCap, "buyTokens: purchase would exceed max cap");
        require(finalizedDone == false, "Already Sale has Been Finalized And Cannot Participate Now");
        require( BUSDToken.allowance(msg.sender, address(this)) >= value, "Not enough allowance given for value to participate" );

        if ( _tierID == 3 ) { // Adding to Tier 3
            require( value >= minBUSDvalue_TierThree , "Value sent less than Tier 3" );
            require( buyInThreeTier[msg.sender].add(value) <= maxAllocaPerUserTierThree,"buyTokens:You are investing more than your tier-3 limit!" );
            require( buyInThreeTier[msg.sender].add(value) >= minAllocaPerUserTierThree, "buyTokens:You are investing less than your tier-3 limit!" );
            
            BUSDToken.transferFrom(msg.sender, address(this), value);
            buyInThreeTier[msg.sender] = buyInThreeTier[msg.sender].add(value);
            totalBUSDReceivedInAllTier = totalBUSDReceivedInAllTier.add(
                value
            );
            totalBUSDInTierThree = totalBUSDInTierThree.add(value);
            emit Participated(msg.sender, value);
            return;
        }

        else if ( _tierID == 2 ) { // Adding to Tier 2
            require( value >= minBUSDvalue_TierTwo , "Value sent less than Tier 2" );
            require( buyInTwoTier[msg.sender].add(value) <= maxAllocaPerUserTierTwo, "buyTokens:You are investing more than your tier-2 limit!");
            require( buyInTwoTier[msg.sender].add(value) >= minAllocaPerUserTierTwo, "buyTokens:You are investing less than your tier-2 limit!");
            
            BUSDToken.transferFrom(msg.sender, address(this), value);
            buyInTwoTier[msg.sender] = buyInTwoTier[msg.sender].add(value);
            totalBUSDReceivedInAllTier = totalBUSDReceivedInAllTier.add( value );
            totalBUSDInTierTwo = totalBUSDInTierTwo.add(value);
            emit Participated(msg.sender, value);
            return;
        }

        else if ( _tierID == 1 ) { // Adding to Tier 1
            require( value >= minBUSDvalue_TierOne , "Value sent less than Tier 1" );
            require( buyInOneTier[msg.sender].add(value) <= maxAllocaPerUserTierOne, "buyTokens:You are investing more than your tier-1 limit!");
            require( buyInOneTier[msg.sender].add(value) >= minAllocaPerUserTierOne, "buyTokens:You are investing less than your tier-1 limit!");
            
            BUSDToken.transferFrom(msg.sender, address(this), value);
            buyInOneTier[msg.sender] = buyInOneTier[msg.sender].add( value );
            totalBUSDReceivedInAllTier = totalBUSDReceivedInAllTier.add( value );
            totalBUSDInTierOne = totalBUSDInTierOne.add(value);
            emit Participated(msg.sender, value);
            return;
        }
        else 
            revert("No Tier with that id");
        
    }

    function finalizeSale() public onlyOwner {
        require(finalizedDone == false, "Alread Sale has Been Finalized");

        if (totalBUSDReceivedInAllTier > softCapInAllTiers) {
            // allow tokens to be claimable
            // send BUSD to investor or the owner
            // success IDO use case

            uint256 participationBalanceBUSD = totalBUSDReceivedInAllTier;
            uint256 participationBalanceTokens = totalBUSDReceivedInAllTier.div(tokenPriceInBUSD).mul( 10 ** (decimals) );

            require( token.balanceOf( address(this) ) >= participationBalanceTokens, "Not Enough Tokens to Finalize, Kindly add more tokens to finalize sale!");

            successIDO = true;
            failedIDO = false;

            uint256 toReturn = maxCap.sub(participationBalanceBUSD);
            toReturn = toReturn.div(tokenPriceInBUSD);

            token.transfer(tokenSender, toReturn.mul(10**(decimals))); //converting to 9 decimals from 18 decimals //extra tokens

            sendBUSD(projectOwner, BUSDToken.balanceOf(address(this)) ); //sending amount spent by user to projectOwner wallet

            finalizedDone = true;
            emit SaleFinalized(block.timestamp, true);
        } else {
            //allow BUSD to be claimed back
            // send tokens back to token owner
            //failed IDO use case
            successIDO = false;
            failedIDO = true;

            uint256 toReturn = token.balanceOf(address(this));
            token.transfer(tokenSender, toReturn); //converting to 9 decimals from 18 decimals

            finalizedDone = true;
            emit SaleFinalized(block.timestamp, false);
        }
    }

    function claim() public nonReentrant() {
        require ( finalizedDone == true, "The Sale has not been Finalized Yet!" );

        uint256 amountSpent = buyInOneTier[msg.sender].add(buyInTwoTier[msg.sender]).add(buyInThreeTier[msg.sender]);

        if(amountSpent == 0) {
            revert("You have not participated hence cannot claim tokens");
        }

        if (successIDO == true && failedIDO == false) {
            
            require( alreadyClaimed[msg.sender][numberOfVestings-1] == false, "All Vestings Claimed Already");

            for (uint256 i = 0; i < numberOfVestings; i++) {
                
                if (block.timestamp >= vestingUnlockTimes[i]){
                    if(alreadyClaimed[msg.sender][i] != true){
                        
                        //success case
                        //send token according to rate*amountspend
                        uint256 toSend = amountSpent.div(tokenPriceInBUSD).mul(vestingPercentages[i]).div(100); //only first iteration percentage tokens to distribute rest are vested
                        token.transfer(msg.sender, toSend.mul(10**(decimals))); //converting to 9 decimals from 18 decimals
                        //send BUSD to wallet
                        alreadyClaimed[msg.sender][i] = true;
                        emit ClaimedTokens( block.timestamp, i, toSend.mul(10**(decimals)) );
                    }
                }
            }

        }
        if (successIDO == false && failedIDO == true) {
            //failure case
            //send BUSD back as amountSpent
            sendBUSD(payable(msg.sender), amountSpent);

            for (uint256 i = 0; i < numberOfVestings; i++){
                alreadyClaimed[msg.sender][i] = true;
            }

            emit ClaimedBUSD(block.timestamp, amountSpent);
        }
    }

    function setTokenSenderAddress(address _tokenSender) public onlyOwner {
        tokenSender = _tokenSender;
    }

    function changeBUSDToken(address _newToken) public onlyOwner {
        BUSDToken = IERC20(_newToken);
    }

}