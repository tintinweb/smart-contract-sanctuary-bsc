/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// File @openzeppelin/contracts/utils/[email protected]
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


// File @openzeppelin/contracts/access/[email protected]
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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


// File @openzeppelin/contracts/token/ERC20/[email protected]
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


// File @openzeppelin/contracts/utils/math/[email protected]
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


// File contracts/abstracts/core/Tokenomics.sol

pragma solidity ^0.8.9;



abstract contract Tokenomics is IERC20, Ownable {
	using SafeMath for uint256;
    mapping (address => bool) private _isBot;

	// Global toggle to avoid trigger loops
	bool internal inTriggerProcess;

/* ---------------------------------- Token --------------------------------- */

	string internal constant NAME = "JATAKA";
	string internal constant SYMBOL = "JTK";

	uint8 internal constant DECIMALS = 8;
	uint256 internal constant ZEROES = 10 ** DECIMALS;

	uint256 private constant MAX = ~uint256(0);
	uint256 internal constant _tTotal = 1000000000000 * ZEROES;
	uint256 internal _rTotal = (MAX - (MAX % _tTotal));

	address public deadAddr = 0x000000000000000000000000000000000000dEaD;

/* ---------------------------------- EXEMPTION --------------------------------- */

	// Sometimes you just have addresses which should be exempt from any 
	// limitations and fees.
	mapping(address => bool) public specialAddresses;

	// Toggle multiple exemptions from transaction limits.
	struct LimitExemptions {
		bool fees;
	}

	// Keeps a record of addresses with limitation exemptions
	mapping(address => LimitExemptions) internal limitExemptions;

/* ---------------------------------- Transactions ---------------------------------- */

	// To keep track of all LPs.
	mapping(address => bool) public liquidityPools;

	// Convenience enum to differentiate transaction limit types.
	enum TransactionLimitType { TRANSACTION, WALLET, SELL }
	// Convenience enum to differentiate transaction types.
	enum TransactionType { REGULAR, SELL, BUY }

	/**
	* @notice Adds address to a liquidity pool map. Can be called externaly.
	*/
	function addAddressToLPs(address lpAddr) public onlyOwner {
		liquidityPools[lpAddr] = true;
	}

	/**
	* @notice Removes address from a liquidity pool map. Can be called externaly.
	*/
	function removeAddressFromLPs(address lpAddr) public onlyOwner {
		liquidityPools[lpAddr] = false;
	}

	function getTransactionType(address from, address to) 
		internal view returns(TransactionType)
	{
		if (liquidityPools[from] && !liquidityPools[to]) {
			// LP -> addr
			return TransactionType.BUY;
		} else if (!liquidityPools[from] && liquidityPools[to]) {
			// addr -> LP
			return TransactionType.SELL;
		}
		return TransactionType.REGULAR;
	}

/* ---------------------------------- Fees ---------------------------------- */
	uint256 internal _tFeeTotal;

	// To be collected for tax
	uint256 public _taxFee = 75;
	uint256 public _reflectionFee = 25;
	// Used to cache fee when removing fee temporarily.
	uint256 internal _previousTaxFee = _taxFee;
	// Used to cache fee when removing fee temporarily.
	uint256 internal _previousReflectionFee = _reflectionFee;
	// Will keep tabs on the amount which should be taken from wallet for taxes.
	uint256 public accumulatedForTax = 0;

	/**
	 * @notice Allows setting Tax fee.
	 */
	function setTaxFee(uint256 fee)
		external 
		onlyOwner
		sameValue(_taxFee, fee)
	{
		require(fee <= 100, "fee cannot be more than 100%");
		_taxFee = fee;
	}

	function setReflectionFee(uint256 fee)
		external 
		onlyOwner
		sameValue(_reflectionFee, fee)
	{
		require(fee <= 100, "fee cannot be more than 100%");
		_reflectionFee = fee;
	}

	/**
	 * @notice Allows temporarily set all feees to 0. 
	 * It can be restored later to the previous fees.
	 */
	function disableAllFeesTemporarily()
		external
		onlyOwner
	{
		removeAllFee();
	}

	/**
	 * @notice Restore all fees from previously set.
	 */
	function restoreAllFees()
		external
		onlyOwner
	{
		restoreAllFee();
	}

	/**
	 * @notice Temporarily stops all fees. Caches the fees into secondary variables,
	 * so it can be reinstated later.
	 */
	function removeAllFee() internal {
		if (_reflectionFee == 0 && _taxFee == 0) return;

		_previousTaxFee = _taxFee;
		_previousReflectionFee = _reflectionFee;
		_taxFee = 0;
		_reflectionFee = 0;
	}

	/**
	 * @notice Restores all fees removed previously, using cached variables.
	 */
	function restoreAllFee() internal {
		_reflectionFee = _previousReflectionFee;
		_taxFee = _previousTaxFee;
	}

	function calculateTaxFee(
		uint256 amount,
		uint8 multiplier
	) internal view returns(uint256) {
		return amount.mul(_taxFee).mul(multiplier).div(10 ** 2);
	}

	function calculateReflectionFee(
		uint256 amount,
		uint8 multiplier
	) internal view returns(uint256) {
		return amount.mul(_reflectionFee).mul(multiplier).div(10 ** 2);
	}

/* --------------------------- Exemption Utilities -------------------------- */

	/**
	* @notice External function allowing owner to toggle various limit exemptions
	* for any address.
	*/
	function toggleLimitExemptions(
		address addr, 
		bool feesToggle
	) 
		public 
		onlyOwner
	{
		LimitExemptions memory ex = limitExemptions[addr];
		ex.fees = feesToggle;
		limitExemptions[addr] = ex;
	}

	/**
	* @notice Updates old and new wallet fee exemptions.
	*/
	function swapExcludedFromFee(address newWallet, address oldWallet) internal {
		if (oldWallet != address(0)) {
			toggleLimitExemptions(oldWallet, false);
		}
		toggleLimitExemptions(newWallet, true);
	}

/* --------------------------- Triggers and limits -------------------------- */

	// One contract accumulates 0.01% of total supply, trigger tax wallet sendout.
	uint256 public minToTax = _tTotal.mul(1).div(10000);

	/**
	@notice External function allowing to set minimum amount of tokens which trigger
	* tax send out.
	*/
	function setMinToTax(uint256 minTokens) 
		external 
		onlyOwner 
		supplyBounds(minTokens)
	{
		minToTax = minTokens * 10 ** 9;
	}

/* --------------------------------- IERC20 --------------------------------- */
	function totalSupply() external pure override returns(uint256) {
		return _tTotal;
	}

	function totalFees() external view returns(uint256) { 
		return _tFeeTotal; 
	}

/* ---------------------------- Anti Bot System --------------------------- */

    function setAntibot(address account, bool _bot) external onlyOwner{
        require(_isBot[account] != _bot, "Value already set");
        _isBot[account] = _bot;
    }

    function isBot(address account) public view returns(bool){
        return _isBot[account];
    }

/* -------------------------------- Helpers ------------------------------- */

    // Use this in case BNB are sent to the contract by mistake
    function rescueBNB(uint256 weiAmount) external onlyOwner{
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }

    function rescueBEP20Tokens(address tokenAddress) external lockTheProcess onlyOwner{
        IERC20(tokenAddress).transfer(msg.sender, IERC20(tokenAddress).balanceOf(address(this)));
		if(tokenAddress == address(this)) {
			// Reset the accumulator, only if tokens actually sent, otherwise we keep
			// acumulating until above mentioned things are fixed.
			accumulatedForTax = 0;
		}
    }

/* -------------------------------- Modifiers ------------------------------- */

	modifier supplyBounds(uint256 minTokens) {
		require(minTokens * 10 ** 9 > 0, "Amount must be more than 0");
		require(minTokens * 10 ** 9 <= _tTotal, "Amount must be not bigger than total supply");
		_;
	}

	modifier sameValue(uint256 firstValue, uint256 secondValue) {
		require(firstValue != secondValue, "Already set to this value.");
		_;
	}

	modifier lockTheProcess {
		inTriggerProcess = true;
		_;
		inTriggerProcess = false;
	}
}


// File contracts/abstracts/core/RFI.sol


pragma solidity ^0.8.9;




abstract contract RFI is IERC20, Ownable, Tokenomics {
	using SafeMath for uint256;
	uint256 public taxBuy = 3;
    uint256 public taxSell = 3;
	mapping(address => uint256) internal _rOwned;
	mapping(address => uint256) internal _tOwned;
	mapping(address => mapping(address => uint256)) private _allowances;

	struct TValues {
		uint256 tTransferAmount;
		uint256 tFee;
		uint256 trFee;
	}

	struct RValues {
		uint256 rAmount;
		uint256 rTransferAmount;
		uint256 rFee;
	}

	constructor() {
		// Assigns all reflected tokens to the deployer on creation
		_rOwned[_msgSender()] = _rTotal;

		emit Transfer(address(0), _msgSender(), _tTotal);
	}

	/**
	* @notice External function allowing owner toggle any address as special address.
	*/
	function toggleSpecialWallets(address specialAddr, bool toggle) 
		external 
		onlyOwner 
	{
		specialAddresses[specialAddr] = toggle;
	}

/* --------------------------- TAX -------------------------- */

	 //Set tax buy on percent
	function setTaxBuy(uint256 _percent)external onlyOwner{
		require(_percent <= 90, "Should be lower than 90%");
		taxBuy = _percent;
	}

	//Set tax sale on percent
	function setTaxSell(uint256 _percent)external onlyOwner{
		require(_percent <= 90, "Should be lower than 90%");
		taxSell = _percent;
	}

	function _getValues(
		uint256 tAmount,
        bool isSellType
	) private view returns(
		TValues memory tValues, RValues memory rValues
	) {
		uint256 taxAmount;
        if(isSellType){
            taxAmount = tAmount.mul(taxSell).div(10 ** 2); 
        }else{
            taxAmount = tAmount.mul(taxBuy).div(10 ** 2);
        }
		TValues memory tV = _getTValues(tAmount,taxAmount);
		RValues memory rV = _getRValues(
			tAmount,
			tV.tFee,
			tV.trFee,
			_getRate()
		);
		return (tV, rV);
	}

	/**
	 * @notice Calculates values for "total" states.
	 * @param tAmount Token amount related to which, total values are calculated.
	 */
	function _getTValues(
		uint256 tAmount,
        uint256 amountAfterTax
	) private view returns(TValues memory tValues) {
		TValues memory tV;
		tV.trFee = calculateReflectionFee(amountAfterTax, 1);
		tV.tFee = calculateTaxFee(amountAfterTax, 1);

		uint256 fees = tV.tFee.add(tV.trFee);
		tV.tTransferAmount = tAmount.sub(fees);
		return tV;
	}

	/**
	 * @notice Calculates values for "reflected" states.
	 * @param tAmount Token amount related to which, reflected values are calculated.
	 * @param tFee Total fee related to which, reflected values are calculated.
	 * @param currentRate Rate used to calculate reflected values.
	 */
	function _getRValues(
		uint256 tAmount,
		uint256 tFee,
		uint256 trFee,
		uint256 currentRate
	) private pure returns(RValues memory rValues) {
		RValues memory rV;
		rV.rAmount = tAmount.mul(currentRate);
		rV.rFee = trFee.mul(currentRate);
		uint256 rFee = tFee.mul(currentRate);
		uint256 fees = rV.rFee + rFee;
		rV.rTransferAmount = rV.rAmount.sub(fees);
		return rV;
	}

	/**
	 * @notice Calculates the rate of total suply to reflected supply.
	 */
	function _getRate() private view returns(uint256) {
		(uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
		return rSupply.div(tSupply);
	}

	function _reflectFee(
		uint256 rFee,
		uint256 tFee
	) private {
		_rTotal = _rTotal.sub(rFee);
		_tFeeTotal = _tFeeTotal.add(tFee);
	}

	/**
	 * @notice Returns totals for "total" supply and "reflected" supply.
	 */
	function _getCurrentSupply() private view returns(uint256, uint256) {
		uint256 rSupply = _rTotal;
		uint256 tSupply = _tTotal;
		if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
		return (rSupply, tSupply);
	}

	function tokenFromReflection(
		uint256 rAmount
	) public view returns(uint256) {
		require(rAmount <= _rTotal, "Amount must be less than total reflections");
		uint256 currentRate = _getRate();
		return rAmount.div(currentRate);
	}

/* --------------------------------- Custom --------------------------------- */

	/**
	 * @notice ERC20 token transaction approval with allowance.
	 */
	function rfiApprove(
		address ownr,
		address spender,
		uint256 amount
	) internal {
		require(ownr != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");

		_allowances[ownr][spender] = amount;
		emit Approval(ownr, spender, amount);
	}

	function _transfer(
		address from,
		address to,
		uint256 amount
	) internal {
		// To flag the address is bot or not
		require(!isBot(msg.sender), "Bot account has been detected, contact admin for further information");
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");
		require(amount > 0, "Transfer amount must be greater than zero");

		// Override this in the main contract to plug your features inside transactions.
		beforeTokenTransfer(from, to, amount);

		// Transfer amount, it will take tax, liquidity fee
		bool take = takeFee(from, to);
		_tokenTransfer(from, to, amount, take);
	}

	/**
	 * @notice Performs token transfer with fees.
	 * @param sender Address of the sender.
	 * @param recipient Address of the recipient.
	 * @param amount Amount of tokens to send.
	 * @param take Toggle on/off fees.
	 */
	function _tokenTransfer(
		address sender,
		address recipient,
		uint256 amount,
		bool take
	) private {
		bool isSellType = getTransactionType(sender, recipient) == TransactionType.SELL;
		// Remove fees for this transaction if needed.
		if (!take)
			removeAllFee();

		// Calculate all reflection magic...
		(TValues memory tV, RValues memory rV) = _getValues(amount,isSellType);

		// Adjust reflection states
		_rOwned[sender] = _rOwned[sender].sub(rV.rAmount);
		_rOwned[recipient] = _rOwned[recipient].add(rV.rTransferAmount);

		// Calcuate fees. If above fees were removed, then these will obviously
		// not take any fees.
		_takeTax(tV.tFee);
		_reflectFee(rV.rFee, tV.trFee);

		emit Transfer(sender, recipient, tV.tTransferAmount);

		// Reinstate fees if they were removed for this transaction.
		if (!take)
			restoreAllFee();
	}

	/**
	* @notice Override this function to intercept the transaction and perform 
	* additional checks or perform certain functions before allowing transaction
	* to complete. You can prevent transaction to complete here too.
	*/
	function beforeTokenTransfer(
		address from, 
		address to, 
		uint256 amount
	) virtual internal {


	}

	function takeFee(address from, address to) virtual internal returns(bool) {


		return true;
	}

/* ---------------------------------- Fees ---------------------------------- */

	function canTakeFee(address from, address to) 
		internal view returns(bool) 
	{	
		bool take = true;
		if (
			limitExemptions[from].fees 
			|| limitExemptions[to].fees 
			|| specialAddresses[from] 
			|| specialAddresses[to]
		) { take = false; }

		return take;
	}

/* ------------------------------- Custom fees ------------------------------ */
	/**
	* @notice Collects tokens from tax fee. Accordingly adjusts "reflected" 
	amounts. 
	*/
	function _takeTax(
		uint256 tFee
	) private {
		uint256 currentRate = _getRate();
		uint256 rFee = tFee.mul(currentRate);
		_rOwned[address(this)] = _rOwned[address(this)].add(rFee);
		// Keep tabs, so when processing is triggered, we know how much should we take.
		accumulatedForTax = accumulatedForTax.add(tFee);
	}

/* --------------------------------- IERC20 --------------------------------- */

	function balanceOf(
		address account
	) public view override returns(uint256) {
		return tokenFromReflection(_rOwned[account]);
	}

	function transfer(
		address recipient,
		uint256 amount
	) public override returns(bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(
		address ownr,
		address spender
	) public view override returns(uint256) {
		return _allowances[ownr][spender];
	}

	function approve(
		address spender,
		uint256 amount
	) public override returns(bool) {
		rfiApprove(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) public override returns(bool) {
		_transfer(sender, recipient, amount);
		rfiApprove(
			sender,
			_msgSender(),
			_allowances[sender][_msgSender()].sub(
				amount,
				"ERC20: transfer amount exceeds allowance"
			)
		);
		return true;
	}

	function increaseAllowance(
		address spender,
		uint256 addedValue
	) public virtual returns(bool) {
		rfiApprove(
			_msgSender(),
			spender,
			_allowances[_msgSender()][spender].add(addedValue)
		);
		return true;
	}

	function decreaseAllowance(
		address spender,
		uint256 subtractedValue
	) public virtual returns(bool) {
		rfiApprove(
			_msgSender(),
			spender,
			_allowances[_msgSender()][spender]
			.sub(subtractedValue, "ERC20: decreased allowance below zero")
		);
		return true;
	}

/* -------------------------------- Modifiers ------------------------------- */

	modifier onlyOwnerOrHolder {
		require(
			owner() == _msgSender() || balanceOf(_msgSender()) > 0, 
			"Only the owner and the holder can use this feature."
			);
		_;
	}

	modifier onlyHolder {
		require(
			balanceOf(_msgSender()) > 0, 
			"Only the holder can use this feature."
			);
		_;
	}

}


// File contracts/abstracts/features/Expensify.sol


pragma solidity ^0.8.9;




abstract contract Expensify is Ownable, Tokenomics, RFI {
	using SafeMath for uint256;
	address public buybackWallet;
	address public treasuryWallet;
	address public marketingWallet;
	// Expenses fee accumulated amount will be divided using these.
	uint256 public buybackShare = 33; // 33%
	uint256 public treasuryShare = 33; // 33%
	uint256 public marketingShare = 34; // 34%

	/**
	* @notice External function allowing to set/change buyback wallet.
	* @param wallet: this wallet will receive buyback share.
	* @param share: multiplier will be divided by 100. 30 -> 30%, 3 -> 3% etc.
	*/
	function setBuybackWallet(address wallet, uint256 share) 
		external onlyOwner legitWallet(wallet) 
	{
		buybackWallet = wallet;
		buybackShare = share;
		swapExcludedFromFee(wallet, buybackWallet);
	}

	/**
	* @notice External function allowing to set/change treasury wallet.
	* @param wallet: this wallet will receive treasury share.
	* @param share: multiplier will be divided by 100. 30 -> 30%, 3 -> 3% etc.
	*/
	function setTreasuryWallet(address wallet, uint256 share) 
		external onlyOwner legitWallet(wallet)
	{
		treasuryWallet = wallet;
		treasuryShare = share;
		swapExcludedFromFee(wallet, treasuryWallet);
	}

	/**
	* @notice External function allowing to set/change marketing wallet.
	* @param wallet: this wallet will receive marketing share.
	* @param share: multiplier will be divided by 100. 30 -> 30%, 3 -> 3% etc.
	*/
	function setMarketingWallet(address wallet, uint256 share) 
		external onlyOwner legitWallet(wallet)
	{
		marketingWallet = wallet;
		marketingShare = share;
		swapExcludedFromFee(wallet, marketingWallet);
	}

	/** 
	* @notice Checks if all required prerequisites are met for us to trigger 
	* taxes send out event.
	*/
	function canTax(
		uint256 contractTokenBalance
	) 
		internal 
		view
		returns(bool) 
	{
		return contractTokenBalance >= accumulatedForTax
            && accumulatedForTax >= minToTax;
	}

	/**
	* @notice Splits tokens into pieces for product dev, dev and marketing wallets 
	* and sends them out.
	* Note: Shares must add up to 100, otherwise tax fee will not be 
		distributed properly. And that can invite many other issues.
		So we can't proceed. You will see "Taxify" event triggered on 
		the blockchain with "0, 0, 0" then. This will guide you to check and fix
		your share setup.
		Wallets must be set. But we will not use "require", so not to trigger 
		transaction failure just because someone forgot to set up the wallet 
		addresses. If you see "Taxify" event with "0, 0, 0" values, then 
		check if you have set the wallets.
		@param tokenAmount amount of tokens to take from balance and send out.
	*/
	function taxify(
		uint256 tokenAmount
	) internal lockTheProcess {
		uint256 buybackPiece;
		uint256 treasuryPiece;
		uint256 marketingPiece;

		if (
			buybackShare.add(treasuryShare).add(marketingShare) == 100
			&& buybackWallet != address(0) 
			&& treasuryWallet != address(0)
			&& marketingWallet != address(0)
		) {
			buybackPiece = tokenAmount.mul(buybackShare).div(100);
			treasuryPiece = tokenAmount.mul(treasuryShare).div(100);
			// Make sure all tokens are distributed.
			marketingPiece = tokenAmount.sub(buybackPiece).sub(treasuryPiece);
			_transfer(address(this), buybackWallet, buybackPiece);
			_transfer(address(this), treasuryWallet, treasuryPiece);
			_transfer(address(this), marketingWallet, marketingPiece);
			// Reset the accumulator, only if tokens actually sent, otherwise we keep
			// acumulating until above mentioned things are fixed.
			accumulatedForTax = 0;
		}
		
 		emit TaxifyDone(buybackPiece, treasuryPiece, marketingPiece);
	}

/* --------------------------------- Events --------------------------------- */
	event TaxifyDone(
		uint256 tokensSentToBuyback,
		uint256 tokensSentToTreasury,
		uint256 tokensSentToMarketing
	);


/* -------------------------------- Modifiers ------------------------------- */

	modifier legitWallet(address wallet) {
		require(wallet != address(0), "Wallet address must be set!");
		require(wallet != address(this), "Wallet address can't be this contract.");
		_;
	}
}


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// File contracts/JATAKA.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract JATAKA is 
	IERC20Metadata, 
	Context, 
	Ownable,
	Tokenomics, 
	RFI,
	Expensify
{
	using SafeMath for uint256;

	constructor() {
		// Set special addresses
		specialAddresses[owner()] = true;
		specialAddresses[address(this)] = true;
		specialAddresses[deadAddr] = true;
		// Set limit exemptions
		LimitExemptions memory exemptions;
		exemptions.fees = true;
		limitExemptions[owner()] = exemptions;
		limitExemptions[address(this)] = exemptions;
	}

/* ------------------------------- IERC20 Meta ------------------------------ */

	function name() external pure override returns(string memory) { return NAME;}
	function symbol() external pure override returns(string memory) { return SYMBOL;}
	function decimals() external pure override returns(uint8) { return DECIMALS; }	

/* ---------------------------------- Circulating Supply ---------------------------------- */

	function totalCirculatingSupply() public view returns(uint256) {
		return _tTotal.sub(balanceOf(deadAddr));
	}

/* -------------------------------- Overrides ------------------------------- */

	function beforeTokenTransfer(address from, address to, uint256 amount) 
		internal 
		override
	{
		// Try to execute all our accumulator features.
		triggerFeatures(from);
	}

	function takeFee(address from, address to) 
		internal 
		view 
		override 
		returns(bool) 
	{
		return canTakeFee(from, to);
	}

/* -------------------------- Accumulator Triggers -------------------------- */

	/**
	* @notice Convenience wrapper function which tries to trigger our custom 
	* features.
	*/
	function triggerFeatures(address from) private {
		uint256 contractTokenBalance = balanceOf(address(this));
		// First determine which triggers can be triggered.
		if (!liquidityPools[from]) {
			// Avoid falling into a tx loop.
			if (!inTriggerProcess) {
				if (canTax(contractTokenBalance)) {
					_triggerTax();
				}
			}
		}
	}

/* ---------------------------- Internal Triggers --------------------------- */

	/**
	* @notice Triggers tax and updates triggerLog
	*/
	function _triggerTax() internal {
		taxify(accumulatedForTax);
	}

/* ---------------------------- External Triggers --------------------------- */

	/**
	* @notice Allows to trigger tax manually.
	*/
	function triggerTax() external onlyOwner {
		uint256 contractTokenBalance = balanceOf(address(this));
		require(canTax(contractTokenBalance), "Not enough tokens accumulated.");
		_triggerTax();
	}
}