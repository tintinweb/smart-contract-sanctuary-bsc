// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.8;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';
import './OXFIvault.sol';
import './IPancakeRouter.sol';
import './IPancakePair.sol';
import './IPancakeFactory.sol';

/*

     ____   __   __  ______   _____ 
    / __ \  \ \ / / |  ____| |_   _|
   | |  | |  \ V /  | |__      | |  
   | |  | |   > <   |  __|     | |  
   | |__| |  / . \  | |       _| |_ 
    \____/  /_/ \_\ |_|      |_____|

   Build by: KISHIELD.com                
   Contract: OXFI.sol

   STATE: LAST CHANGES BEFORE PRODUCTION
*/

contract OXFI is IERC20, Ownable, AccessControl {
	using SafeMath for uint256;

	string constant _name = 'oxfinance'; // Name
	string constant _symbol = 'OXFI'; // Symbol
	uint8 constant _decimals = 18; // Decimals

	uint256 _totalSupply = 1_000_000 ether; // Total Supply
	uint256 _fixedTotalSupply = 1_000_000 ether; // Fixed Total Supply to manage static allowances
	uint256 public _maxTxAmount = _totalSupply.div(100); // 1%

	mapping(address => uint256) _balances;
	mapping(address => mapping(address => uint256)) _allowances;

	mapping(address => bool) isFeeExempt;
	mapping(address => bool) isTxLimitExempt; // NOT ON USE FOR TESTING
	mapping(address => bool) isSniper; // NOT ON USE FOR TESTING

	// OXFI Buy Taxes
	uint256 public vaultFee = 70; // 7% will be added to the Vault as BUSD
	uint256 public marketFee = 30; // 3% will go to the market wallet address

	// OXFI Sell Taxes
	uint256 public destroyFee = 50; // 5% will be destroyed decreasing the total supply
	uint256 public liquidityFee = 50; // 5% will be added to the liquidity pool

	// OXFI Trackers
	uint256 public vaultFeeTracker;
	uint256 public liquidityFeeTracker;

	// OXFI Counters
	uint256 public destroyedTokenCount;

	// Contract Use
	uint256 feeDenominator = 1000;

	// External wallets
	address public autoLiquidityReceiver;
	address public marketingFeeReceiver;

	// Self Explanatory
	OXFIvault public immutable vault;
	IPancakeRouter public router;
	address public pair;

	// ERC20s
	// BUSD testnet 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
	// BUSD mainnet 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
	address private WBNB;
	IERC20 constant BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
	//IERC20 constant BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

	// Access Control (Vault can destroy tokens)
	bytes32 public constant DESTROYER_ROLE = keccak256('DESTROYER_ROLE');

	// Threshold for vault deposit and liquidity injection
	uint256 public swapThreshold = _totalSupply / 2000; // 0.05%

	// Handle Swap state
	bool inSwap;

	modifier swapping() {
		inSwap = true;
		_;
		inSwap = false;
	}

	event AutoLiquify(uint256 indexed amountBNB, uint256 indexed amountOXFI);
	event VaultDeposit(uint256 indexed deposited);

	bool public swapEnabled; // for swap between OXFI and BUSD (not trading)
	bool public tradingOpen;

	// Antibot measures
	uint256 public launchedAt;
	uint256 public antiSnipingBlocks = 3;

	constructor() {
		// mainet router 0x10ED43C718714eb63d5aA57B78B54704E256024E
		// testnet router 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3

		// Set the owner to OXFI
		//transferOwnership(0xE67d07170Fe31Aa31c8304f5ebCEA8CB209309D6);
		// Create vault and set role
		vault = new OXFIvault(address(this), 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3, owner());
		_setupRole(DESTROYER_ROLE, address(vault));

		// set up router and create pair WBNB -> OXFI
		router = IPancakeRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
		WBNB = router.WETH();
		pair = IPancakeFactory(router.factory()).createPair(WBNB, address(this));

		// Allow the router to use all the tokens
		_allowances[address(this)][address(router)] = _fixedTotalSupply;

		// Set up external wallets
		// Hardhat accunt for test 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
		// Testnet 0x0600061016d090f004925000D80008e0fA1610c0
		marketingFeeReceiver = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
		autoLiquidityReceiver = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

		// Exemptions and limits
		//isFeeExempt[msg.sender] = true;
		// TESTING isFeeExempt[marketingFeeReceiver] = true;
		//isTxLimitExempt[msg.sender] = true;

		isFeeExempt[owner()] = true;
		isTxLimitExempt[owner()] = true;

		// Required allowances
		approve(address(router), _fixedTotalSupply);
		approve(address(pair), _fixedTotalSupply);

		// Mint the tokens
		_balances[owner()] = _totalSupply;
		emit Transfer(address(0), owner(), _totalSupply);
	}

	receive() external payable {}

	/*  
        OXFI Unique function, Users can redeem BUSD using OXFI,
        the tokens used are destroyed, to avoid an extra approve
        OXFI Vault alters the balance in low-level, Only the vault
        can call this function.
    */
	function destroy(address user, uint256 amount) external returns (bool) {
		require(hasRole(DESTROYER_ROLE, msg.sender), 'OXFI: Caller is not OXFI vault');
		// destroy tokens
		_totalSupply = _totalSupply.sub(amount);
		// remove tokens from user
		_balances[user] = _balances[user].sub(amount);
		emit Transfer(user, address(0), amount);
		// update total destroyed tokens tracker
		destroyedTokenCount = destroyedTokenCount.add(amount);

		return true;
	}

	function totalSupply() external view returns (uint256) {
		return _totalSupply;
	}

	function decimals() external pure returns (uint8) {
		return _decimals;
	}

	function symbol() external pure returns (string memory) {
		return _symbol;
	}

	function name() external pure returns (string memory) {
		return _name;
	}

	function balanceOf(address account) public view override returns (uint256) {
		return _balances[account];
	}

	function allowance(address holder, address spender) external view override returns (uint256) {
		return _allowances[holder][spender];
	}

	function approve(address spender, uint256 amount) public override returns (bool) {
		_allowances[msg.sender][spender] = amount;
		emit Approval(msg.sender, spender, amount);
		return true;
	}

	function approveMax(address spender) external returns (bool) {
		return approve(spender, _fixedTotalSupply);
	}

	function transfer(address recipient, uint256 amount) external override returns (bool) {
		return _transferFrom(msg.sender, recipient, amount);
	}

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external override returns (bool) {
		if (_allowances[sender][msg.sender] != _fixedTotalSupply) {
			_allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(
				amount,
				'Insufficient Allowance'
			);
		}

		return _transferFrom(sender, recipient, amount);
	}

	function _transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) internal returns (bool) {

		if (!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
            // Trading is disabled until launch
            if (!tradingOpen) {
                require(
                    sender != pair && recipient != pair,
                    "Trading is not enabled yet"
                );
            }
			// Max tx amount
			require(amount <= _maxTxAmount, "OXFI: tx limit exceeded");

            // antibot for the first 3 blocks after launch
            if (
                block.number < launchedAt + antiSnipingBlocks &&
                sender != address(router)
            ) {
                if (sender == pair) {
                    isSniper[recipient] = true;
                } else if (recipient == pair) {
                    isSniper[sender] = true;
                }
            }
        }

		if (inSwap) {
			return _basicTransfer(sender, recipient, amount);
		}

		if (shouldDepositToVault()) {
			_depositToVault();
		}

		if (shouldAddLiquidity()) {
			_addLiquidity();
		}

		_balances[sender] = _balances[sender].sub(amount, 'Insufficient Balance');

		uint256 tFee;
		if (isFeeExempt[sender] || isFeeExempt[recipient]) {
			_balances[recipient] = _balances[recipient].add(amount);
			emit Transfer(sender, recipient, amount);
		}
		// SELL handler
		else if (recipient == pair) {
			// calculate fee amount for sell
			tFee = amount.mul(destroyFee.add(liquidityFee)).div(feeDenominator);
			// sent the tokens to the recipient
			_balances[recipient] = _balances[recipient].add(amount.sub(tFee));
			emit Transfer(sender, recipient, amount.sub(tFee));
			// take the fee
			_takeSellFee(sender, amount);
		}
		// BUY && TRANSFER
		else {
			// calculate fee amount for buy or transfer
			tFee = amount.mul(vaultFee.add(marketFee)).div(feeDenominator);
			// sent the tokens to the recipient
			_balances[recipient] = _balances[recipient].add(amount.sub(tFee));
			emit Transfer(sender, recipient, amount.sub(tFee));
			// take the fee
			_takeBuyFee(sender, amount);
		}
		return true;
	}

	function _basicTransfer(
		address sender,
		address recipient,
		uint256 amount
	) internal returns (bool) {
		_balances[sender] = _balances[sender].sub(amount, 'Insufficient Balance');
		_balances[recipient] = _balances[recipient].add(amount);
		emit Transfer(sender, recipient, amount);
		return true;
	}

	function _takeBuyFee(address sender, uint256 tAmount) internal {
		require(!isSniper[sender], "OXFI: Sniper detected");
		uint256 vFee = tAmount.mul(vaultFee).div(1e3);
		uint256 mFee = tAmount.mul(marketFee).div(1e3);
		_balances[address(this)] = _balances[address(this)].add(vFee);
		// marketing fee
		_balances[marketingFeeReceiver] = _balances[marketingFeeReceiver].add(mFee);
		// vault tracker
		vaultFeeTracker = vaultFeeTracker.add(vFee);
		emit Transfer(sender, address(this), vFee);
		emit Transfer(sender, marketingFeeReceiver, mFee);
	}

	function _takeSellFee(address sender, uint256 tAmount) internal {
		require(!isSniper[sender], "OXFI: sniper detected");
		uint256 dFee = tAmount.mul(destroyFee).div(1e3);
		uint256 lFee = tAmount.mul(liquidityFee).div(1e3);
		_balances[address(this)] = _balances[address(this)].add(lFee);
		// destroy tokens
		_totalSupply = _totalSupply.sub(dFee);
		// liquidity tracker
		liquidityFeeTracker = liquidityFeeTracker.add(lFee);
		// total destroyed tokens tracker
		destroyedTokenCount = destroyedTokenCount.add(dFee);
		emit Transfer(sender, address(this), lFee);
		emit Transfer(sender, address(0), dFee);
	}

	function shouldDepositToVault() internal view returns (bool) {
		// always deposit if the balance is > 0.
		return msg.sender != pair && !inSwap && swapEnabled && vaultFeeTracker > swapThreshold;
	}

	function shouldAddLiquidity() internal view returns (bool) {
		// add liquidity once the liquidityFeeTracker is equal or over 0.005% of the supply
		return msg.sender != pair && !inSwap && swapEnabled && liquidityFeeTracker >= swapThreshold;
	}

	function _depositToVault() internal swapping {
		// get the number of tokens from vault fee
		uint256 amountToSwap = vaultFeeTracker;
		// reset the tracker
		vaultFeeTracker = 0;

		// capture the vault contract current BUSD balance.
		// this is so that we can capture exactly the amount of BUSD that the
		// we are depositing to the Vault
		uint256 balanceBefore = BUSD.balanceOf(address(vault));

		// swap tokens for BUSD
		// generate the uniswap pair path of token -> busd
		address[] memory path = new address[](3);
		path[0] = address(this);
		path[1] = WBNB;
		path[2] = address(BUSD);

		// make the swap and send the tokens to the vault
		router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
			amountToSwap,
			0,
			path,
			address(vault),
			block.timestamp
		);

		// how much BUSD did we just deposited?
		uint256 balanceAfter = BUSD.balanceOf(address(vault));
		uint256 deposited = balanceAfter.sub(balanceBefore);

		emit VaultDeposit(deposited);
	}
	function _addLiquidity() internal swapping {
		// split the contract balance into halves
		uint256 half = liquidityFeeTracker.div(2);
		uint256 otherHalf = liquidityFeeTracker.sub(half);
		// reset the tracker
		liquidityFeeTracker = 0;

		// capture the contract's current BNB balance.
		// this is so that we can capture exactly the amount of BNB that the
		// swap creates, and not make the liquidity event include any BNB that
		// has been manually sent to the contract
		uint256 initialBalance = address(this).balance;

		// swap tokens for BNB
		// generate the uniswap pair path of token -> wbnb
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = router.WETH();

		// make the swap
		router.swapExactTokensForETHSupportingFeeOnTransferTokens(
			half,
			0, // accept any amount of BNB
			path,
			address(this),
			block.timestamp
		);

		// how much BNB did we just swap into?
		uint256 newBalance = address(this).balance.sub(initialBalance);

		// add liquidity to PancakeSwap
		router.addLiquidityETH{value: newBalance}(
			address(this),
			otherHalf,
			0, // slippage is unavoidable
			0, // slippage is unavoidable
			autoLiquidityReceiver,
			block.timestamp
		);

		emit AutoLiquify(newBalance, otherHalf);
	}

	function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
		isFeeExempt[holder] = exempt;
	}

	function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
		isTxLimitExempt[holder] = exempt;
	}

	//only owner can change BuyFeePercentages any time after deployment
	function setBuyFeePercent(uint256 _vaultFee, uint256 _marketFee) external onlyOwner {
		require(_vaultFee.add(_marketFee) <= 100, 'OXFI: Buy fees cannot be over 10%');
		vaultFee = _vaultFee;
		marketFee = _marketFee;
	}

	//only owner can change SellFeePercentages any time after deployment
	function setSellFeePercent(uint256 _destroyFee, uint256 _liquidityFee) external onlyOwner {
		require(_destroyFee.add(_liquidityFee) <= 100, 'OXFI: Sell fees cannot be over 10%');
		destroyFee = _destroyFee;
		liquidityFee = _liquidityFee;
	}

	function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver)
		external
		onlyOwner
	{
		autoLiquidityReceiver = _autoLiquidityReceiver;
		marketingFeeReceiver = _marketingFeeReceiver;
	}

	function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
		swapEnabled = _enabled; 
		swapThreshold = _amount;
	}

	function getOxfiPrice() external view returns (uint[] memory amounts) {
		// generate the uniswap pair path of busd -> token
		address[] memory path = new address[](3);
		path[0] = address(BUSD);
		path[1] = WBNB;
		path[2] = address(this);

		return router.getAmountsOut(1 ether, path);

        // address token0 = IPancakePair(pair).token0();

		// return token0;
	}

	function launch() public onlyOwner {
		require(launchedAt == 0, 'OXFI: token already launched');
		tradingOpen = true;
		swapEnabled = true;
		launchedAt = block.number;
	}

	function setTxLimit(uint256 amount) external onlyOwner {
		require(amount >= _totalSupply / 1000);
		_maxTxAmount = amount;
	}

	function removeSniperFromList(address _account) external onlyOwner {
		require(isSniper[_account], 'OXFI: Not a sniper');
		isSniper[_account] = false;
	}

}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IPancakeRouterVault.sol";
import "./IOXFIERC20.sol";


/*

     ____   __   __  ______   _____ 
    / __ \  \ \ / / |  ____| |_   _|
   | |  | |  \ V /  | |__      | |  
   | |  | |   > <   |  __|     | |  
   | |__| |  / . \  | |       _| |_ 
    \____/  /_/ \_\ |_|      |_____|

   Build by: KISHIELD.com                
   Contract: OXFIvault.sol

   STATE: TESTING
*/

contract OXFIvault is ReentrancyGuard {

    address public owner;
    uint256 public totalOxfiDeposited;
    uint256 public totalBusdRedeemed;

    // Lock variables
    uint256 private immutable creationTime;
    uint256 private lockTime = 30 days;

    // ERC20s
    IOXFIERC20 immutable OXFI;
	IERC20 constant BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
	//IERC20 constant BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    constructor(address _token, address _router, address _owner) {
        OXFI = IOXFIERC20(_token);
        BUSD.approve(address(this), type(uint256).max);
        BUSD.approve(address(_router), type(uint256).max);
        owner = _owner;
        creationTime = block.timestamp;
    }

    function balanceBUSD() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    function userBalanceBUSD(address user) public view returns (uint256) {
        return BUSD.balanceOf(user);
    }

    function oxfiSupply() public view returns (uint256) {
        return OXFI.totalSupply();
    }

    function rate(uint256 amount) public view returns (uint256) {
        return (amount * balanceBUSD()) / oxfiSupply();
    }

    function userOxfiBalance(address user) public view returns (uint256) {
        return OXFI.balanceOf(user);
    }

    function redeemBUSD(uint256 amount) external nonReentrant {
        require(userOxfiBalance(msg.sender) >= amount, "OXFIvault: Not enough OXFI");

        require(OXFI.destroy(msg.sender, amount), "OXFIvault: Tokens not destroyed");

        uint busdForTransfer = rate(amount);

        require(balanceBUSD() >= busdForTransfer, "OXFIvault: Not enough BUSD in vault");
        BUSD.transferFrom(address(this), msg.sender, busdForTransfer);

        totalOxfiDeposited += amount;
        totalBusdRedeemed += busdForTransfer;
    }

    function previewRedeemBUSD(uint256 amount) external view returns(uint256) {
        uint busdForTransfer = rate(amount);
        return busdForTransfer;
    }

    function transferOwnership(address _newOwner) external {
        require(msg.sender == owner, "OFXI: You are not the owner");
        require(_newOwner != address(0), "OFXI: Ownership cannot be transfered to the zero address");
        owner = _newOwner;
    } 

    function renounceOwnership() external {
        require(msg.sender == owner, "OFXI: You are not the owner");
        owner = address(0);
    } 

    function withdrawBUSD() external {
        require(msg.sender == owner, "OFXI: You are not the owner");
        require(block.timestamp > creationTime + lockTime, "OXFI: lock time not over");
        BUSD.transferFrom(address(this), msg.sender, BUSD.balanceOf(address(this)));
    }

}

interface IPancakeRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
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

interface IPancakeRouterVault {
    function factory() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);


    function WETH() external pure returns (address);

    
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
        ) external;

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IOXFIERC20 {
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
     * @dev Destroys the tokens sent.
     */
    function destroy(address user, uint256 amount) external returns (bool);

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