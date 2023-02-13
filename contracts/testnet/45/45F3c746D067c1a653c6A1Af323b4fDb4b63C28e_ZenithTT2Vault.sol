// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { VaultBase } from "../../base/VaultBase.sol";
import { LibUniswapV2Pair } from "../../protocols/uniswap_v2/LibUniswapV2Pair.sol";
import { Math } from "../../utils/Math.sol";

contract ZenithTT2Vault is VaultBase
{
	using SafeERC20 for IERC20;
	using LibUniswapV2Pair for LibUniswapV2Pair.Self;

	struct Options {
		uint256 ratePerSec;
		uint256 entryDiscountRate;
		uint256 amountPerSec;
		uint256 minimumEntryAmount;
	}

	LibUniswapV2Pair.Self public pool;

	Options public options;

	address public quoteToken;
	address public baseToken;

	uint256 public lastTime;
	uint256 public lastBuyTime;
	uint256 public totalAmount;
	uint256 public totalExpectedAmount;
	uint256 public positionAmount;
	uint256 public positionSize;
	uint256 public priceCumulative;

	function _initialize(bytes memory _data) internal override
	{
		(quoteToken, options, pool) = abi.decode(_data, (address, Options, LibUniswapV2Pair.Self));
		lastTime = block.timestamp;
		lastBuyTime = block.timestamp;
		totalAmount = 0;
		totalExpectedAmount = 0;
		positionAmount = 0;
		positionSize = 0;
		if (quoteToken == pool.token0) {
			baseToken = pool.token1;
			priceCumulative = pool._price0CumulativeLatest();
		}
		else
		if (quoteToken == pool.token1) {
			baseToken = pool.token0;
			priceCumulative = pool._price1CumulativeLatest();
		}
		else {
			revert("panic");
		}
	}

	function setOptions(Options memory _options) external onlyWhitelisted
	{
		options = _options;
	}

	function tokens() external view override returns (address[] memory _tokens)
	{
		_tokens = new address[](2);
		_tokens[0] = pool.token0;
		_tokens[1] = pool.token1;
		return _tokens;
	}

	function totalReserve(address _token) public view override returns (uint256 _totalReserve)
	{
		if (_token == quoteToken) {
			if (_token == pool.token0) {
				_totalReserve = (totalAmount - positionAmount) + pool._price0of1(positionSize);
			}
			else
			if (_token == pool.token1) {
				_totalReserve = (totalAmount - positionAmount) + pool._price1of0(positionSize);
			}
			else {
				revert("panic");
			}
		}
		else
		if (_token == baseToken) {
			if (_token == pool.token0) {
				_totalReserve = pool._price0of1(totalAmount - positionAmount) + positionSize;
			}
			else
			if (_token == pool.token1) {
				_totalReserve = pool._price1of0(totalAmount - positionAmount) + positionSize;
			}
			else {
				revert("panic");
			}
		}
		else {
			revert("invalid token");
		}
		return _totalReserve;
	}

	function deposit(address _token, uint256 _amount, uint256 _minShares) external override nonEmergency nonReentrant returns (uint256 _shares)
	{
		require(_token == quoteToken, "invalid token");
		_updateTotalExpectedAmount();
		uint256 _totalReserve = totalExpectedAmount;
		uint256 _totalSupply = totalSupply();
		_shares = _calcSharesFromAmount(_totalReserve, _totalSupply, _amount);
		require(_shares >= _minShares, "high slippage");
		totalAmount += _amount;
		totalExpectedAmount += _amount;
		_mint(msg.sender, _shares);
		IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
		return _shares;
	}

	function withdraw(address _token, uint256 _shares, uint256 _minAmount) external override nonReentrant returns (uint256 _amount)
	{
		require(_token == quoteToken, "invalid token");
		require(positionAmount == 0, "open position");
		_updateTotalExpectedAmount();
		uint256 _totalReserve = totalExpectedAmount;
		uint256 _totalSupply = totalSupply();
		uint256 _expectedAmount = _calcAmountFromShares(_totalReserve, _totalSupply, _shares);
		_amount = totalAmount * _expectedAmount / totalExpectedAmount;
		require(_amount >= _minAmount, "high slippage");
		totalAmount -= _amount;
		totalExpectedAmount -= _expectedAmount;
		_burn(msg.sender, _shares);
		IERC20(_token).safeTransfer(msg.sender, _amount);
		return _amount;
	}

	function withdraw(uint256 _shares, uint256 _minExpectedAmount) external nonReentrant returns (uint256 _amount, uint256 _size)
	{
		_updateTotalExpectedAmount();
		uint256 _totalReserve = totalExpectedAmount;
		uint256 _totalSupply = totalSupply();
		uint256 _expectedAmount = _calcAmountFromShares(_totalReserve, _totalSupply, _shares);
		require(_expectedAmount >= _minExpectedAmount, "high slippage");
		uint256 _availableAmount = totalAmount - positionAmount;
		_amount = _availableAmount * _expectedAmount / totalExpectedAmount;
		_size = positionSize * _expectedAmount / totalExpectedAmount;
		uint256 _positionAmount = positionAmount * _expectedAmount / totalExpectedAmount;
		totalAmount -= _amount + _positionAmount;
		totalExpectedAmount -= _expectedAmount;
		positionAmount -= _positionAmount;
		positionSize -= _size;
		_burn(msg.sender, _shares);
		IERC20(quoteToken).safeTransfer(msg.sender, _amount);
		IERC20(baseToken).safeTransfer(msg.sender, _size);
		return (_amount, _size);
	}

	function compound(uint256 _minShares) external override onlyWhitelisted nonReentrant returns (uint256 _shares)
	{
		uint256 _balance = IERC20(quoteToken).balanceOf(address(this));
		uint256 _amount = _balance - (totalAmount - positionAmount);
		if (_amount == 0) {
			require(_minShares == 0, "high slippage");
			return 0;
		}
		_updateTotalExpectedAmount();
		uint256 _totalReserve = totalExpectedAmount;
		uint256 _totalSupply = totalSupply();
		_shares = _calcSharesFromAmount(_totalReserve, _totalSupply, _amount);
		require(_shares >= _minShares, "high slippage");
		totalAmount += _amount;
		totalExpectedAmount += _amount;
		if (commission > 0) {
			_mint(owner(), _shares * commission / 1e18);
		}
		return _shares;
	}

	function buy() external onlyWhitelisted nonEmergency nonReentrant
	{
		uint256 _timeElapsed = block.timestamp - lastBuyTime;
		uint256 _amount = options.amountPerSec * _timeElapsed;
		uint256 _availableAmount = totalAmount - positionAmount;
		if (_amount > _availableAmount) {
			_amount = _availableAmount;
		}
		require(_amount >= options.minimumEntryAmount, "invalid amount");
		uint256 _size;
		uint256 _averagePriceSize;
		if (quoteToken == pool.token0) {
			_size = pool._swap0(_amount, address(this));
			_averagePriceSize = pool._averagePrice1of0(priceCumulative, lastBuyTime, _amount);
			priceCumulative = pool._price0CumulativeLatest();
		}
		else
		if (quoteToken == pool.token1) {
			_size = pool._swap1(_amount, address(this));
			_averagePriceSize = pool._averagePrice0of1(priceCumulative, lastBuyTime, _amount);
			priceCumulative = pool._price1CumulativeLatest();
		}
		else {
			revert("panic");
		}
		require(_size * options.entryDiscountRate >= _averagePriceSize * 100e16, "insufficient price");
		lastBuyTime = block.timestamp;
		positionAmount += _amount;
		positionSize += _size;
	}

	function sell() external onlyWhitelisted nonReentrant
	{
		_updateTotalExpectedAmount();
		uint256 _amount;
		if (quoteToken == pool.token0) {
			_amount = pool._swap1(positionSize, address(this));
			priceCumulative = pool._price0CumulativeLatest();
		}
		else
		if (quoteToken == pool.token1) {
			_amount = pool._swap0(positionSize, address(this));
			priceCumulative = pool._price1CumulativeLatest();
		}
		else {
			revert("panic");
		}
		require(totalAmount - positionAmount + _amount >= totalExpectedAmount, "insufficient price");
		lastBuyTime = block.timestamp;
		totalExpectedAmount = totalAmount;
		positionAmount = 0;
		positionSize = 0;
	}

	function _updateTotalExpectedAmount() internal
	{
		uint256 _timeElapsed = block.timestamp - lastTime;
		uint256 _rate = Math._exp(100e16 + options.ratePerSec, _timeElapsed);
		totalExpectedAmount = totalExpectedAmount * _rate / 100e16;
		lastTime = block.timestamp;
	}
}

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { OwnableUpgradeable as Ownable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ReentrancyGuardUpgradeable as ReentrancyGuard } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { ERC20Upgradeable as ERC20 } from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import { EmergencyControl } from "../utils/EmergencyControl.sol";
import { Whitelistable } from "../utils/Whitelistable.sol";

import { IVault } from "./IVault.sol";

abstract contract VaultBase is Initializable, Ownable, ReentrancyGuard, ERC20, EmergencyControl, Whitelistable, IVault
{
	uint256 public commission;

	function initialize(string memory _name, string memory _symbol, bytes memory _data) public initializer
	{
		__Ownable_init_unchained();
		__ReentrancyGuard_init_unchained();
		__ERC20_init_unchained(_name, _symbol);
		_initialize(_data);
	}

	function _initialize(bytes memory _data) internal virtual;

	function declareEmergency() external onlyOwner nonEmergency
	{
		_declareEmergency();
	}

	function setWhitelist(address _account, bool _enabled) external onlyOwner
	{
		_setWhitelist(_account, _enabled);
	}

	function setCommission(uint256 _commission) external onlyOwner
	{
		require(_commission <= 1e18, "invalid commission");
		commission = _commission;
		emit CommissionUpdated(_commission);
	}

	function _calcSharesFromAmount(uint256 _totalReserve, uint256 _totalSupply, uint256 _amount) internal pure virtual returns (uint256 _shares)
	{
		if (_totalReserve == 0) return _amount;
		return _amount * _totalSupply / _totalReserve;
	}

	function _calcAmountFromShares(uint256 _totalReserve, uint256 _totalSupply, uint256 _shares) internal pure virtual returns (uint256 _amount)
	{
		if (_totalSupply == 0) return _totalReserve;
		return _shares * _totalReserve / _totalSupply;
	}

	event CommissionUpdated(uint256 _commission);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { Math } from "../../utils/Math.sol";

import { IUniswapV2Pair } from "./IUniswapV2Pair.sol";

library LibUniswapV2Pair
{
	using SafeERC20 for IERC20;

	struct Self {
		address pair;
		address token0;
		address token1;
		uint256[2] fee;
	}

	function _new(address _pair, uint256[2] memory _fee) internal view returns (Self memory _self)
	{
		address _token0 = IUniswapV2Pair(_pair).token0();
		address _token1 = IUniswapV2Pair(_pair).token1();
		return Self({ pair: _pair, token0: _token0, token1: _token1, fee: _fee });
	}

	function _balanceOf(Self storage _self, address _account) internal view returns (uint256 _balance)
	{
		return IERC20(_self.pair).balanceOf(_account);
	}

	function _mint2(Self storage _self, uint256 _amount0, uint256 _amount1, address _to) internal returns (uint256 _amount2)
	{
		IERC20(_self.token0).safeTransfer(_self.pair, _amount0);
		IERC20(_self.token1).safeTransfer(_self.pair, _amount1);
		return IUniswapV2Pair(_self.pair).mint(_to);
	}

	function _burn2(Self storage _self, uint256 _amount2, address _to) internal returns (uint256 _amount0, uint256 _amount1)
	{
		IERC20(_self.pair).safeTransfer(_self.pair, _amount2);
		return IUniswapV2Pair(_self.pair).burn(_to);
	}

	function _swap0(Self storage _self, uint256 _amount0, address _to) internal returns (uint256 _amount1)
	{
		(uint256 _reserve0, uint256 _reserve1,) = IUniswapV2Pair(_self.pair).getReserves();
		_amount1 = _calcSwapOut(_self.fee, _reserve0, _reserve1, _amount0);
		IERC20(_self.token0).safeTransfer(_self.pair, _amount0);
		IUniswapV2Pair(_self.pair).swap(0, _amount1, _to, new bytes(0));
		return _amount1;
	}

	function _swap1(Self storage _self, uint256 _amount1, address _to) internal returns (uint256 _amount0)
	{
		(uint256 _reserve0, uint256 _reserve1,) = IUniswapV2Pair(_self.pair).getReserves();
		_amount0 = _calcSwapOut(_self.fee, _reserve1, _reserve0, _amount1);
		IERC20(_self.token1).safeTransfer(_self.pair, _amount1);
		IUniswapV2Pair(_self.pair).swap(_amount0, 0, _to, new bytes(0));
		return _amount0;
	}

	function _zapin0(Self storage _self, uint256 _amount0, address _to) internal returns (uint256 _swapInAmount0, uint256 _swapOutAmount1)
	{
		(uint256 _reserve0, uint256 _reserve1,) = IUniswapV2Pair(_self.pair).getReserves();
		_swapInAmount0 = _calcZapin(_self.fee, _reserve0, _amount0);
		_swapOutAmount1 = _calcSwapOut(_self.fee, _reserve0, _reserve1, _swapInAmount0);
		IERC20(_self.token0).safeTransfer(_self.pair, _swapInAmount0);
		IUniswapV2Pair(_self.pair).swap(0, _swapOutAmount1, _to, new bytes(0));
		return (_swapInAmount0, _swapOutAmount1);
	}

	function _zapin1(Self storage _self, uint256 _amount1, address _to) internal returns (uint256 _swapInAmount1, uint256 _swapOutAmount0)
	{
		(uint256 _reserve0, uint256 _reserve1,) = IUniswapV2Pair(_self.pair).getReserves();
		_swapInAmount1 = _calcZapin(_self.fee, _reserve1, _amount1);
		_swapOutAmount0 = _calcSwapOut(_self.fee, _reserve1, _reserve0, _swapInAmount1);
		IERC20(_self.token1).safeTransfer(_self.pair, _swapInAmount1);
		IUniswapV2Pair(_self.pair).swap(_swapOutAmount0, 0, _to, new bytes(0));
		return (_swapInAmount1, _swapOutAmount0);
	}

	function _price1of0(Self storage _self, uint256 _amount0) internal view returns (uint256 _amount1)
	{
		(uint256 _reserve0, uint256 _reserve1,) = IUniswapV2Pair(_self.pair).getReserves();
		return _calcSpot(_reserve0, _reserve1, _amount0);
	}

	function _price0of1(Self storage _self, uint256 _amount1) internal view returns (uint256 _amount0)
	{
		(uint256 _reserve0, uint256 _reserve1,) = IUniswapV2Pair(_self.pair).getReserves();
		return _calcSpot(_reserve1, _reserve0, _amount1);
	}

	function _price0of2(Self storage _self, uint256 _amount2) internal view returns (uint256 _amount0)
	{
		(uint256 _reserve0,,) = IUniswapV2Pair(_self.pair).getReserves();
		uint256 _totalSupply = IUniswapV2Pair(_self.pair).totalSupply();
		return _calcSpot(_totalSupply, 2 * _reserve0, _amount2);
	}

	function _price1of2(Self storage _self, uint256 _amount2) internal view returns (uint256 _amount1)
	{
		(,uint256 _reserve1,) = IUniswapV2Pair(_self.pair).getReserves();
		uint256 _totalSupply = IUniswapV2Pair(_self.pair).totalSupply();
		return _calcSpot(_totalSupply, 2 * _reserve1, _amount2);
	}

	function _price2of0(Self storage _self, uint256 _amount0) internal view returns (uint256 _amount2)
	{
		(uint256 _reserve0,,) = IUniswapV2Pair(_self.pair).getReserves();
		uint256 _totalSupply = IUniswapV2Pair(_self.pair).totalSupply();
		return _calcSpot(_reserve0, _totalSupply, _amount0) / 2;
	}

	function _price2of1(Self storage _self, uint256 _amount1) internal view returns (uint256 _amount2)
	{
		(,uint256 _reserve1,) = IUniswapV2Pair(_self.pair).getReserves();
		uint256 _totalSupply = IUniswapV2Pair(_self.pair).totalSupply();
		return _calcSpot(_reserve1, _totalSupply, _amount1) / 2;
	}

	function _averagePrice1of0(Self storage _self, uint256 _price0Cumulative0Last, uint256 _blockTimestampLast, uint256 _amount0) internal view returns (uint256 _amount1)
	{
		return (_price0CumulativeLatest(_self) - _price0Cumulative0Last) * _amount0 / (block.timestamp - _blockTimestampLast) >> 112;
	}

	function _averagePrice0of1(Self storage _self, uint256 _price1Cumulative0Last, uint256 _blockTimestampLast, uint256 _amount1) internal view returns (uint256 _amount0)
	{
		return (_price1CumulativeLatest(_self) - _price1Cumulative0Last) * _amount1 / (block.timestamp - _blockTimestampLast) >> 112;
	}

	function _price0CumulativeLatest(Self storage _self) internal view returns (uint256 _price0Cumulative)
	{
		_price0Cumulative = IUniswapV2Pair(_self.pair).price0CumulativeLast();
		(uint256 _reserve0, uint256 _reserve1, uint256 _blockTimestamp) = IUniswapV2Pair(_self.pair).getReserves();
		if (block.timestamp > _blockTimestamp) {
			_price0Cumulative += (_reserve1 << 112 / _reserve0) * (block.timestamp - _blockTimestamp);
		}
		return _price0Cumulative;
	}

	function _price1CumulativeLatest(Self storage _self) internal view returns (uint256 _price1Cumulative)
	{
		_price1Cumulative = IUniswapV2Pair(_self.pair).price1CumulativeLast();
		(uint256 _reserve0, uint256 _reserve1, uint256 _blockTimestamp) = IUniswapV2Pair(_self.pair).getReserves();
		if (block.timestamp > _blockTimestamp) {
			_price1Cumulative += (_reserve0 << 112 / _reserve1) * (block.timestamp - _blockTimestamp);
		}
		return _price1Cumulative;
	}

	function _calcSpot(uint256 _reserveIn, uint256 _reserveOut, uint256 _amountIn) private pure returns (uint256 _amountOut)
	{
		return _reserveOut * _amountIn / _reserveIn;
	}

	function _calcZapin(uint256[2] memory _fee, uint256 _reserveIn, uint256 _amountIn) private pure returns (uint256 _amountSwapIn)
	{
		return (Math._sqrt(_reserveIn * (_amountIn * 4 * _fee[0] * _fee[1] + _reserveIn * (_fee[0] * _fee[0] + _fee[1] * (_fee[1] + 2 * _fee[0])))) - _reserveIn * (_fee[1] + _fee[0])) / (2 * _fee[1]);
	}

	function _calcSwapOut(uint256[2] memory _fee, uint256 _reserveIn, uint256 _reserveOut, uint256 _amountIn) private pure returns (uint256 _amountOut)
	{
		uint256 _amountInWithFee = _amountIn * _fee[0];
		return (_reserveOut * _amountInWithFee) / (_reserveIn * _fee[1] + _amountInWithFee);
	}
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

library Math
{
	function _sqrt(uint256 _x) internal pure returns (uint256 _y)
	{
		_y = _x;
		uint256 _z = (_x + 1) / 2;
		while (_z < _y) {
			_y = _z;
			_z = (_x / _z + _z) / 2;
		}
		return _y;
	}

	function _exp(uint256 _x, uint256 _n) internal pure returns (uint256 _y)
	{
		_y = 1e18;
		while (_n > 0) {
			if (_n & 1 != 0) _y = _y * _x / 1e18;
			_n >>= 1;
			_x = _x * _x / 1e18;
		}
		return _y;
	}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    uint256[45] private __gap;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

contract EmergencyControl
{
	bool public emergencyMode = false;

	modifier inEmergency
	{
		require(emergencyMode, "unavailable");
		_;
	}

	modifier nonEmergency
	{
		require(!emergencyMode, "unavailable");
		_;
	}

	function _declareEmergency() internal
	{
		_beforeEmergencyDeclared();
		emergencyMode = true;
		emit EmergencyDeclared();
		_afterEmergencyDeclared();
	}

	function _beforeEmergencyDeclared() internal virtual {}
	function _afterEmergencyDeclared() internal virtual {}

	event EmergencyDeclared();
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

contract Whitelistable
{
	mapping(address => bool) public whitelist;

	modifier onlyWhitelisted
	{
		require(whitelist[msg.sender], "access denied");
		_;
	}

	function _setWhitelist(address _account, bool _enabled) internal
	{
		whitelist[_account] = _enabled;
		emit Whitelisted(_account, _enabled);
	}

	event Whitelisted(address indexed _account, bool indexed _enabled);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import { IERC20MetadataUpgradeable as IERC20Metadata } from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

interface IVault is IERC20Metadata
{
	function tokens() external view returns (address[] memory _tokens);
	function totalReserve(address _token) external view returns (uint256 _totalReserve);

	function deposit(address _token, uint256 _amount, uint256 _minShares) external returns (uint256 _shares);
	function withdraw(address _token, uint256 _shares, uint256 _minAmount) external returns (uint256 _amount);
	function compound(uint256 _minShares) external returns (uint256 _shares);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Returns the amount of tokens in existence.
     */
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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.9;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniswapV2Pair is IERC20
{
	function factory() external view returns (address _factory);
	function token0() external view returns (address _token0);
	function token1() external view returns (address _token1);
	function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
	function price0CumulativeLast() external view returns (uint256 _price0CumulativeLast);
	function price1CumulativeLast() external view returns (uint256 _price1CumulativeLast);

	function mint(address _to) external returns (uint256 _liquidity);
	function burn(address _to) external returns (uint256 _amount0, uint256 _amount1);
	function swap(uint256 _amount0Out, uint256 _amount1Out, address _to, bytes calldata _data) external;
}