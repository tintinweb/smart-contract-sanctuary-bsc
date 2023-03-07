/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// File: @openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
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

// File: contracts/TreeDefiTokenSwapTest.sol


// Treedefi Token Swap v. 1.12
// Code: SCSE-01
// Usage Testnet
// Author: Treedefi 

pragma solidity 0.8.17; 

// OpenZeppelin templates 


//All the legacy tokens implement ERC20 standard

//CarbonToken


// this contract should be deployed after the deployment of the three contracts 
// TreeDefiToken, TreeDefiSEED, GreenBond

contract TreeDefiTokenSwapV1x12  is ReentrancyGuard {
    using SafeMath for uint256;

    address payable admin;
    //ratioTREECAR is the percentage of how many TREE is worth one CarbonToken
    uint256 public ratioTREEtoCAR;
    //ratioSEEDCAR is the percentage of how many SEED is worth one CarbonToken
    uint256 public ratioSEEDtoCAR;
    //ratioTTCO2CAR is the percentage of how many TCO2 is worth one CarbonToken
    uint256 public ratioTCO2toCAR;
    // same fees for each token exchange
    uint256 public fees;

    // Legacy tokens + COT
    address treeToken;
    address tco2Token;
    address seedToken;
    address carbonToken;

    uint256 public constant VESTING_PERIOD = 3 minutes;
    uint256 public constant ONE_MONTH = 3 minutes;
    uint256 public constant TWO_MONTHS = 6 minutes;
    uint256 public constant THREE_MONTHS = 9 minutes;
    uint256 public constant FOUR_MONTHS = 12 minutes;

    uint256 public constant WITHDRAW_PERCENTAGE = 25; // 25% per month
    uint256 public constant DECIMALS = 18;            // used for exchange ratios
    
    struct KV{
        uint tS;        //Key
        uint amount;    //Value
        uint8 lastWithdrawInPeriod; 
    }
    // mapping (mapping from address to deposits array)
    // swapHistory[addr] is an array of swapped legacy tokens, converted in COT, ordered by timestamp;
    mapping(address => KV[]) public swapHistory;

    KV[] public swapTimeAmount;

    bool private _stopped = false;
   
    constructor(
        address seedToken_, 
        address tco2Token_, 
        address treeToken_, 
        address carbonToken_) {
        
        require(
            seedToken_ != address(0x0) && 
            tco2Token_ != address(0x0) &&
            treeToken_ != address(0x0) &&
            carbonToken_ != address(0x0)
        );
        
        admin = payable(msg.sender);

        treeToken = treeToken_;
        tco2Token = tco2Token_;
        seedToken = seedToken_;
        carbonToken = carbonToken_;
        
        // due to openzeppelin implementation, transferFrom function implementation expects _msgSender() to be the beneficiary from the caller
        // but in this use case we are using this contract to transfer so its always checking the allowance of SELF
        //treeToken.approve(address(this), treeToken.totalSupply());
        //tco2Token.approve(address(this), tco2Token.totalSupply());
        //seedToken.approve(address(this), seedToken.totalSupply());
        IERC20Upgradeable(carbonToken).approve(address(this), IERC20Upgradeable(carbonToken).totalSupply());

    }

    modifier onlyAdmin() {
        payable(msg.sender) == admin;
        _;
    }

    function getLength(address _of) public view returns(uint256) {
		// read array length and return
		return swapHistory[_of].length;
	}

    function getDeposits(address _of) public view returns (KV[] memory) {
        // You can get values from an array mapping 
        return swapHistory[_of];
    }

    function setDeposit(address _of, uint _amount) private {
        //withdrawn counter is set to 0 at the first deposit 
        swapHistory[_of].push(KV(uint(block.timestamp), uint(_amount), uint8(0)));
    }
    
    // Exchange Rates
    function setRatioTREEtoCAR(uint256 _ratio) public onlyAdmin {
        // 10 ** 18 is ratio 1:1
        ratioTREEtoCAR = _ratio;
    }

    function setRatioSEEDtoCAR(uint256 _ratio) public onlyAdmin {
        // 10 ** 18 is ratio 1:1
        ratioSEEDtoCAR = _ratio;
    }
    
    function setRatioTCO2toCAR(uint256 _ratio) public onlyAdmin {
        // 10 ** 18 is ratio 1:1
        ratioTCO2toCAR = _ratio;
    }
    
    function getRatioTREEtoCAR() public view onlyAdmin returns (uint256) {
        return ratioTREEtoCAR;
    }

    function getRatioSEEDtoCAR() public view onlyAdmin returns (uint256) {
        return ratioSEEDtoCAR;
    }
    
    function getRatioTCO2toCAR() public view onlyAdmin returns (uint256) {
        return ratioTCO2toCAR;
    }
    
    // FEES
    function setFees(uint256 _fees) public onlyAdmin {
        fees = _fees;
    }

    function getFees() public view onlyAdmin returns (uint256) {
        return fees;
    }

    // SWAP & LOCK FUNCTIONS 
    // accepts amount of TreeDefiSEED tokens and exchange them for CarbonToken
    //
    function depositSEED(uint256 _amountInSEED) public nonReentrant returns (uint256) {
        //check if amount given is not 0
        // check if current contract has the necessary amout of Tokens to exchange
        require(_amountInSEED > 0, "amount of SEED must be greater then zero");
        require(ratioSEEDtoCAR > 0, "exchange rate must be greater then zero");
        require(
            IERC20(seedToken).balanceOf(msg.sender) >= _amountInSEED,
            "sender doesn't have enough Tokens"
        );
        //
        require(
            IERC20(seedToken).transferFrom(msg.sender, address(this), _amountInSEED),
            "SEED transferFrom failed"
        );

        uint256 exchangeRate = _amountInSEED.mul(ratioSEEDtoCAR).div(10**DECIMALS);
        //In case of fees the amount received is a bit less ==> amount = exchangeRate - fees
        uint256 amountOut = exchangeRate.sub(exchangeRate.mul(fees).div(100));
        require(
            amountOut > 0,
            "exchanged Amount must be greater then zero"
        );
        
        // stores Exchanged amount and timestamp 
        setDeposit(msg.sender, amountOut);

        return amountOut;
    }

    // accepts amount of TCO2 tokens and exchange them for CarbonToken
    //
    function depositTCO2(uint256 _amountInTCO2) public nonReentrant returns (uint256) {
        //check if amount given is not 0
        // check if current contract has the necessary amout of Tokens to exchange
        require(_amountInTCO2 > 0, "amount of TCO2 must be greater then zero");
        require(ratioTCO2toCAR > 0, "exchange rate must be greater then zero");
        require(
            IERC20(tco2Token).balanceOf(msg.sender) >= _amountInTCO2,
            "sender doesn't have enough Tokens"
        );
        //
        require(
            IERC20(tco2Token).transferFrom(msg.sender, address(this), _amountInTCO2),
            'SEED transferFrom failed'
        );

        uint256 exchangeRate = _amountInTCO2.mul(ratioTCO2toCAR).div(10**DECIMALS);
        //In case of fees the amount received is a bit less ==> amount = exchangeRate - fees
        uint256 amountOut = exchangeRate.sub(exchangeRate.mul(fees).div(100));
        require(
            amountOut > 0,
            "exchanged Amount must be greater then zero"
        );

        // stores Exchanged amount and timestamp 
        setDeposit(msg.sender, amountOut);

        return amountOut;
    }

    // accepts amount of TCO2 tokens and exchange them for CarbonToken
    //
    function depositTreeDefi(uint256 _amountInTree) public nonReentrant returns (uint256) {
        //check if amount given is not 0
        // check if current contract has the necessary amout of Tokens to exchange
        require(_amountInTree > 0, "amount of TCO2 must be greater then zero");
        require(ratioTREEtoCAR > 0, "exchange rate must be greater then zero");
        require(
            IERC20(treeToken).balanceOf(msg.sender) >= _amountInTree,
            "sender doesn't have enough Tokens"
        );
        //
        require(
            IERC20(treeToken).transferFrom(msg.sender, address(this), _amountInTree),
            'SEED transferFrom failed'
        );

        uint256 exchangeRate = _amountInTree.mul(ratioTREEtoCAR).div(10**DECIMALS);
        //amount = exchangeRate - fees
        uint256 amountOut = exchangeRate.sub(exchangeRate.mul(fees).div(100));
        require(
            amountOut > 0,
            "exchanged Amount must be greater then zero"
        );

        // stores Exchanged amount and timestamp 
        setDeposit(msg.sender, amountOut);

        return amountOut;
    }

    // Check amoung all deposits made by msg.sender
    // Check the elapsed time. If the vesting period is over
    // calculate the allowed amount to withdraw (25%, 50%, 75% or 100%)
    // decrease the quantity left to withdraw
    function withdraw() public {
        uint j = 0;
        uint _now = block.timestamp;
        uint allowedAmount;
        uint8 wP;
        uint8 multiplier;

        KV[] memory _h = getDeposits(msg.sender);

        require(_h.length > 0, "nothing to check for this address");

        // check amoung all deposits made by msg.sender
        while (j < _h.length) {
            allowedAmount = 0;
            wP = 0;
            multiplier = 0;
            
            if ((_now - _h[j].tS > VESTING_PERIOD) && (_now - _h[j].tS < VESTING_PERIOD + ONE_MONTH)) {
                wP = 1;
            }
            if ((_now - _h[j].tS > VESTING_PERIOD + ONE_MONTH) && (_now - _h[j].tS < VESTING_PERIOD + TWO_MONTHS)) {
                wP = 2;
            }
            if ((_now - _h[j].tS > VESTING_PERIOD + TWO_MONTHS) && (_now - _h[j].tS < VESTING_PERIOD + THREE_MONTHS)) {
                wP = 3;
            }
            if (_now - _h[j].tS > VESTING_PERIOD + THREE_MONTHS) {
                wP = 4;
            }

            multiplier = wP - swapHistory[msg.sender][j].lastWithdrawInPeriod;
            swapHistory[msg.sender][j].lastWithdrawInPeriod = wP;
            allowedAmount += _h[j].amount * multiplier / 4;
            j++;
        }
        require(
            IERC20Upgradeable(carbonToken).balanceOf(address(this)) > allowedAmount,
            "the exchange does not have enough CarbonToken, please retry later"
        );
        require(IERC20Upgradeable(carbonToken).transfer(msg.sender, allowedAmount), "Transfer of released tokens failed");
    }

    function terminateSwap () public payable onlyAdmin {
        // Selfdestruct works by erasing the contract bytecode from the chain, 
        // sending any liquidity to a specified address, and then, 
        // refunding a portion of the gas fees to developers. 
        // (ref. https://www.alchemy.com/overviews/selfdestruct-solidity)
        selfdestruct(admin);
    }

    function transferOwnership(address payable newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "New admin address cannot be zero");
        require(!isContract(newAdmin), "New admin address cannot be a contract");
        admin = newAdmin;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


}