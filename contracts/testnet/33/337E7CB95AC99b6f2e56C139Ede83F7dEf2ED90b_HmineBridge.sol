// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { HmineMain1 } from "./HmineMain1.sol";

interface IUniswapV2Router
{
	function WETH() external pure returns (address _WETH);
	function getAmountsOut(uint256 _amountIn, address[] calldata _path) external view returns (uint256[] memory _amounts);

	function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable returns (uint256[] memory amounts);
	function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
}

contract HmineBridge
{
	using SafeERC20 for IERC20;

	address public immutable hmineMain1;
	address public immutable currencyToken;

	address public immutable router;
	address public immutable wrapperToken;

	constructor(address _hmineMain1, address _router)
	{
		hmineMain1 = _hmineMain1;
		router = _router;
		currencyToken = HmineMain1(hmineMain1).currencyToken();
		wrapperToken = IUniswapV2Router(router).WETH();
	}

	function estimateBuy(address _token, uint256 _amount, bool _directRoute) external view returns (uint256 _value)
	{
		address[] memory _path;
		if (_directRoute) {
			_path = new address[](2);
			_path[0] = _token;
			_path[1] = currencyToken;
		} else {
			_path = new address[](3);
			_path[0] = _token;
			_path[1] = wrapperToken;
			_path[2] = currencyToken;
		}
		uint256 _currencyAmount = IUniswapV2Router(router).getAmountsOut(_amount, _path)[_path.length - 1];
		return HmineMain1(hmineMain1).calculateSwap(_currencyAmount, true);
	}

	function buy(uint256 _hmineMinAmount) external payable
	{
		address[] memory _path = new address[](2);
		_path[0] = wrapperToken;
		_path[1] = currencyToken;
		uint256 _currencyAmount = IUniswapV2Router(router).swapExactETHForTokens{value: msg.value}(1, _path, address(this), block.timestamp)[_path.length - 1];
		IERC20(currencyToken).safeApprove(hmineMain1, _currencyAmount);
		uint256 _hmineAmount = HmineMain1(hmineMain1).buyOnBehalfOf(_currencyAmount, msg.sender);
		require(_hmineAmount >= _hmineMinAmount, "high slippage");
	}

	function buy(address _token, uint256 _amount, bool _directRoute, uint256 _hmineMinAmount) external
	{
		IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
		IERC20(_token).safeApprove(router, _amount);
		address[] memory _path;
		if (_directRoute) {
			_path = new address[](2);
			_path[0] = _token;
			_path[1] = currencyToken;
		} else {
			_path = new address[](3);
			_path[0] = _token;
			_path[1] = wrapperToken;
			_path[2] = currencyToken;
		}
		uint256 _currencyAmount = IUniswapV2Router(router).swapExactTokensForTokens(_amount, 1, _path, address(this), block.timestamp)[_path.length - 1];
		IERC20(currencyToken).safeApprove(hmineMain1, _currencyAmount);
		uint256 _hmineAmount = HmineMain1(hmineMain1).buyOnBehalfOf(_currencyAmount, msg.sender);
		require(_hmineAmount >= _hmineMinAmount, "high slippage");
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { HmineMain2 } from "./HmineMain2.sol";

contract HmineMain1 is Ownable, ReentrancyGuard
{
	using SafeERC20 for IERC20;

	address constant DEFAULT_BANKROLL = 0x25be1fcF5F51c418a0C30357a4e8371dB9cf9369; // multisig
	address constant DEFAULT_SAFE_HOLDERS = 0xcD8dDeE99C0c4Be4cD699661AE9c00C69D1Eb4A8;
	address constant DEFAULT_MANAGEMENT_0 = 0x5C9dE63470D0D6d8103f7c83F1Be4F55998706FC; // loft
	address constant DEFAULT_MANAGEMENT_1 = 0x2165fa4a32B9c228cD55713f77d2e977297D03e8; // ghost
	address constant DEFAULT_MANAGEMENT_2 = 0x70F5FB6BE943162545a496eD120495B05dC5ce07; // mike
	address constant DEFAULT_MANAGEMENT_3 = 0x36b13280500AEBC5A75EbC1e9cB9Bf1b6A78a95e; // miko
	address constant DEFAULT_LIQUIDITY_TAKER = 0x2165fa4a32B9c228cD55713f77d2e977297D03e8; // ghost

	uint256 constant MAX_SUPPLY = 200_000e18;
	uint256 constant ROUND_INCREMENT = 250e18;
	uint256 constant FIRST_ROUND = 100_000e18;
	uint256 constant SECOND_ROUND = FIRST_ROUND + ROUND_INCREMENT;
	uint256 constant MIN_PRICE = 7e18;
	uint256 constant PRICE_INCREMENT = 0.75e18;

	address public immutable hmineToken; // HMINE
	address public immutable currencyToken; // BUSD
	address public immutable hmineMain2;

	address public bankroll = DEFAULT_BANKROLL;
	address public safeHolders = DEFAULT_SAFE_HOLDERS;
	address[4] public management = [DEFAULT_MANAGEMENT_0, DEFAULT_MANAGEMENT_1, DEFAULT_MANAGEMENT_2, DEFAULT_MANAGEMENT_3];
	address public liquidityTaker = DEFAULT_LIQUIDITY_TAKER;

	uint256 public totalSold;
	uint256 public currentPrice;

	modifier onlyLiquidityTaker()
	{
		require(msg.sender == liquidityTaker, "access denied");
		_;
	}

	constructor(address _hmineToken, address _currenctyToken, address _hmineMain2, uint256 _totalSold)
	{
		require(_currenctyToken != _hmineToken, "invalid token");
		require(_totalSold <= MAX_SUPPLY, "invalid amount");
		hmineToken = _hmineToken;
		currencyToken = _currenctyToken;
		hmineMain2 = _hmineMain2;

		totalSold = _totalSold;
		currentPrice = MIN_PRICE;
		if (totalSold > FIRST_ROUND) {
			currentPrice += PRICE_INCREMENT * ((totalSold - FIRST_ROUND) / ROUND_INCREMENT);
		}
		IERC20(hmineToken).safeTransferFrom(msg.sender, address(this), MAX_SUPPLY - totalSold);
	}

	function setBankroll(address _bankroll) external onlyOwner
	{
		require(_bankroll != address(0), "invalid address");
		bankroll = _bankroll;
	}

	function setSafeHolders(address _safeHolders) external onlyOwner
	{
		require(_safeHolders != address(0), "invalid address");
		safeHolders = _safeHolders;
	}

	function setManagement(uint256 _i, address _management) external onlyOwner
	{
		require(_i < management.length, "invalid index");
		require(_management != address(0), "invalid address");
		management[_i] = _management;
	}

	function setLiquidityTaker(address _liquidityTaker) external onlyOwner
	{
		liquidityTaker = _liquidityTaker;
	}

	function recoverReserve(uint256 _amount) external onlyLiquidityTaker nonReentrant
	{
		uint256 _reserve = IERC20(currencyToken).balanceOf(address(this));
		require(_amount <= _reserve, "insufficient balance");
		IERC20(currencyToken).safeTransfer(msg.sender, _amount);
	}

	function calculateSwap(uint256 _amount, bool _isBuy) external view returns (uint256 _value)
	{
		(_value, ) = _isBuy ? _getBuyValue(_amount) : _getSellValue(_amount);
		return _value;
	}

	function buy(uint256 _amount) external nonReentrant returns (uint256 _value)
	{
		require(_amount > 0, "invalid amount");

		(uint256 _hmineValue, uint256 _price) = _getBuyValue(_amount);

		_buy(msg.sender, _amount, _hmineValue, _price, msg.sender);

		emit Buy(msg.sender, _hmineValue, _price);

		return _hmineValue;
	}

	function buyOnBehalfOf(uint256 _amount, address _account) external nonReentrant returns (uint256 _value)
	{
		require(_amount > 0, "invalid amount");

		(uint256 _hmineValue, uint256 _price) = _getBuyValue(_amount);

		_buy(msg.sender, _amount, _hmineValue, _price, _account);

		emit Buy(msg.sender, _hmineValue, _price);

		return _hmineValue;
	}

	function compound() external nonReentrant
	{
		uint256 _amount = HmineMain2(hmineMain2).claimOnBehalfOf(msg.sender);

		(uint256 _hmineValue, uint256 _price) = _getBuyValue(_amount);

		_buy(address(this), _amount, _hmineValue, _price, msg.sender);

		emit Compound(msg.sender, _hmineValue, _price);
	}

	function _buy(address _sender, uint256 _amount, uint256 _hmineValue, uint256 _price, address _account) internal
	{
		require(totalSold + _hmineValue <= MAX_SUPPLY, "exceeds supply");

		uint256 _managementAmount = (_amount * 7.5e16 / 100e16) / management.length;
		uint256 _safeHoldersAmount = _amount * 2.5e16 / 100e16;
		uint256 _bankrollAmount = _amount * 80e16 / 100e16;
		uint256 _amountToStakers = _amount - (management.length * _managementAmount + _safeHoldersAmount + _bankrollAmount);

		if (_sender == address(this)) {
			for (uint256 _i = 0; _i < management.length; _i++) {
				IERC20(currencyToken).safeTransfer(management[_i], _managementAmount);
			}
			IERC20(currencyToken).safeTransfer(safeHolders, _safeHoldersAmount);
			IERC20(currencyToken).safeTransfer(bankroll, _bankrollAmount);
		} else {
			for (uint256 _i = 0; _i < management.length; _i++) {
				IERC20(currencyToken).safeTransferFrom(_sender, management[_i], _managementAmount);
			}
			IERC20(currencyToken).safeTransferFrom(_sender, safeHolders, _safeHoldersAmount);
			IERC20(currencyToken).safeTransferFrom(_sender, bankroll, _bankrollAmount);
			IERC20(currencyToken).safeTransferFrom(_sender, address(this), _amountToStakers);
		}

		IERC20(currencyToken).safeApprove(hmineMain2, _amountToStakers);
		HmineMain2(hmineMain2).rewardAll(_amountToStakers);

		IERC20(hmineToken).safeApprove(hmineMain2, _hmineValue);
		HmineMain2(hmineMain2).depositOnBehalfOf(_hmineValue, _account);

		totalSold += _hmineValue;

		currentPrice = _price;
	}

	function sell(uint256 _amount) external nonReentrant returns (uint256 _value)
	{
		require(_amount > 0, "invalid amount");

		(uint256 _sellValue, uint256 _price) = _getSellValue(_amount);

		uint256 _60percent = (_sellValue * 60e18) / 100e18;

		uint256 _reserve = IERC20(currencyToken).balanceOf(address(this));
		require(_60percent <= _reserve, "insufficient balance");

		IERC20(hmineToken).safeTransferFrom(msg.sender, address(this), _amount);

		IERC20(currencyToken).safeTransfer(msg.sender, _60percent);

		totalSold -= _amount;

		currentPrice = _price;

		emit Sell(msg.sender, _amount, _price);

		return _sellValue;
	}

	function _getBuyValue(uint256 _amount) internal view returns (uint256 _hmineValue, uint256 _price)
	{
		_price = currentPrice;
		_hmineValue = _amount * 1e18 / _price;
		if (totalSold + _hmineValue <= SECOND_ROUND) {
			if (totalSold + _hmineValue == SECOND_ROUND) {
				_price += PRICE_INCREMENT;
			}
		}
		else {
			_hmineValue = 0;
			uint256 _amountLeftOver = _amount;
			uint256 _roundAvailable = ROUND_INCREMENT - totalSold % ROUND_INCREMENT;

			// If short of first round, adjust up to first round
			if (totalSold < FIRST_ROUND) {
				_hmineValue += FIRST_ROUND - totalSold;
				_amountLeftOver -= _hmineValue * _price / 1e18;
				_roundAvailable = ROUND_INCREMENT;
			}

			uint256 _valueOfLeftOver = _amountLeftOver * 1e18 / _price;
			if (_valueOfLeftOver < _roundAvailable) {
				_hmineValue += _valueOfLeftOver;
			} else {
				_hmineValue += _roundAvailable;
				_amountLeftOver = (_valueOfLeftOver - _roundAvailable) * _price / 1e18;
				_price += PRICE_INCREMENT;
				while (_amountLeftOver > 0) {
					_valueOfLeftOver = _amountLeftOver * 1e18 / _price;
					if (_valueOfLeftOver >= ROUND_INCREMENT) {
						_hmineValue += ROUND_INCREMENT;
						_amountLeftOver = (_valueOfLeftOver - ROUND_INCREMENT) * _price / 1e18;
						_price += PRICE_INCREMENT;
					} else {
						_hmineValue += _valueOfLeftOver;
						_amountLeftOver = 0;
					}
				}
			}
		}
		return (_hmineValue, _price);
	}

	function _getSellValue(uint256 _amount) internal view returns (uint256 _sellValue, uint256 _price)
	{
		_price = currentPrice;
		uint256 _roundAvailable = totalSold % ROUND_INCREMENT;
		if (_amount <= _roundAvailable) {
			_sellValue = _amount * _price / 1e18;
		}
		else {
			_sellValue = _roundAvailable * _price / 1e18;
			uint256 _amountLeftOver = _amount - _roundAvailable;
			while (_amountLeftOver > 0) {
				if (_price > MIN_PRICE) {
					_price -= PRICE_INCREMENT;
				}
				if (_amountLeftOver > ROUND_INCREMENT) {
					_sellValue += ROUND_INCREMENT * _price / 1e18;
					_amountLeftOver -= ROUND_INCREMENT;
				} else {
					_sellValue += _amountLeftOver * _price / 1e18;
					_amountLeftOver = 0;
				}
			}
		}
		return (_sellValue, _price);
	}

	event Buy(address indexed _account, uint256 _amount, uint256 _price);
	event Sell(address indexed _account, uint256 _amount, uint256 _price);
	event Compound(address indexed _account, uint256 _amount, uint256 _price);
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
}

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
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract HmineMain2 is Ownable, ReentrancyGuard
{
	using SafeERC20 for IERC20;

	struct AccountInfo {
		string nickname;
		uint256 amount;
		uint256 reward;
		uint256 accRewardDebt;
		uint16 period;
		uint64 day;
		bool whitelisted;
	}

	struct PeriodInfo {
		uint256 amount;
		uint256 fee;
		bool available;
		bool privileged;
		mapping(uint64 => DayInfo) dayInfo;
	}

	struct DayInfo {
		uint256 accRewardPerShare;
		uint256 expiringReward;
	}

	address constant FURNACE = 0x000000000000000000000000000000000000dEaD;

	address constant DEFAULT_BANKROLL = 0x25be1fcF5F51c418a0C30357a4e8371dB9cf9369; // multisig
	address constant DEFAULT_BUYBACK = 0x7674D2a14076e8af53AC4ba9bBCf0c19FeBe8899;

	uint256 constant DAY = 1 days;
	uint256 constant TZ_OFFSET = 23 hours; // UTC-1

	uint16 constant MAX_PERIOD = type(uint16).max;

	address public immutable hmineToken; // HMINE
	address public immutable rewardToken; // BUSD
	address public immutable hmineMain1;

	address public bankroll = DEFAULT_BANKROLL;
	address public buyback = DEFAULT_BUYBACK;

	bool public whitelistAll = false;

	uint256 public totalStaked = 0;
	uint256 public totalReward = 0;

	uint64 public day = today();

	uint16[] public periodIndex;
	mapping(uint16 => PeriodInfo) public periodInfo;

	mapping(address => AccountInfo) public accountInfo;

	function dayInfo(uint16 _period, uint64 _day) external view returns (DayInfo memory _dayInfo)
	{
		return periodInfo[_period].dayInfo[_day];
	}

	function today() public view returns (uint64 _today)
	{
		return uint64((block.timestamp + TZ_OFFSET) / DAY);
	}

	constructor(address _hmineToken, address _rewardToken, address _hmineMain1)
	{
		require(_rewardToken != _hmineToken, "invalid token");
		hmineToken = _hmineToken;
		rewardToken = _rewardToken;
		hmineMain1 = _hmineMain1;

		periodIndex.push(1); periodInfo[1].fee = 0e16; periodInfo[1].available = true;
		periodIndex.push(2); periodInfo[2].fee = 10e16; periodInfo[2].available = true;
		periodIndex.push(4); periodInfo[4].fee = 15e16; periodInfo[4].available = true;
		periodIndex.push(7); periodInfo[7].fee = 20e16; periodInfo[7].available = true;
		periodIndex.push(30); periodInfo[30].fee = 50e16; periodInfo[30].available = true;
		periodIndex.push(MAX_PERIOD); periodInfo[MAX_PERIOD].fee = 0e16; periodInfo[MAX_PERIOD].available = true; periodInfo[MAX_PERIOD].privileged = true;
	}

	function migrate(address[] calldata _accounts, uint256[] calldata _amounts, string[] calldata _nicknames) external onlyOwner nonReentrant
	{
		require(_accounts.length == _amounts.length || _accounts.length == _nicknames.length, "lenght mismatch");

		_updateDay();

		uint16 _period = 1;

		PeriodInfo storage _periodInfo = periodInfo[_period];
		DayInfo storage _dayInfo = _periodInfo.dayInfo[day];

		uint256 _amount = 0;

		for (uint256 _i = 0; _i < _accounts.length; _i++) {
			address _account = _accounts[_i];
			AccountInfo storage _accountInfo = accountInfo[_account];

			require(_accountInfo.period == 0, "duplicate account");

			_accountInfo.nickname = _nicknames[_i];
			_accountInfo.amount = _amounts[_i];
			_accountInfo.accRewardDebt = _accountInfo.amount * _dayInfo.accRewardPerShare / 1e18;
			_accountInfo.period = _period;
			_accountInfo.day = day;

			emit Deposit(_account, hmineToken, _accountInfo.amount);

			_amount += _accountInfo.amount;
		}

		if (_amount > 0) {
			_periodInfo.amount += _amount;

			totalStaked += _amount;

			IERC20(hmineToken).safeTransferFrom(msg.sender, address(this), _amount);
		}
	}

	function setBankroll(address _bankroll) external onlyOwner
	{
		require(_bankroll != address(0), "invalid address");
		bankroll = _bankroll;
	}

	function setBuyback(address _buyback) external onlyOwner
	{
		require(_buyback != address(0), "invalid address");
		buyback = _buyback;
	}

	function updateWhitelistAll(bool _whitelistAll) external onlyOwner
	{
		whitelistAll = _whitelistAll;
	}

	function updateWhitelist(address _account, bool _whitelisted) external onlyOwner
	{
		accountInfo[_account].whitelisted = _whitelisted;
	}

	function recoverFunds(address _token) external onlyOwner nonReentrant
	{
		uint256 _amount = IERC20(_token).balanceOf(address(this));
		if (_token == hmineToken) _amount -= totalStaked;
		else
		if (_token == rewardToken) _amount -= totalReward;
		if (_amount > 0) {
			IERC20(_token).safeTransfer(msg.sender, _amount);
		}
	}

	function updateNickname(string calldata _nickname) external
	{
		accountInfo[msg.sender].nickname = _nickname;
	}

	function updatePeriod(address _account, uint16 _newPeriod) external nonReentrant
	{
		PeriodInfo storage _periodInfo = periodInfo[_newPeriod];
		require(_periodInfo.available, "unavailable");
		require(msg.sender == _account && !_periodInfo.privileged || msg.sender == owner(), "access denied");

		_updateDay();

		_updateAccount(_account, 0);

		AccountInfo storage _accountInfo = accountInfo[_account];
		uint16 _oldPeriod = _accountInfo.period;
		require(_newPeriod != _oldPeriod, "no change");

		periodInfo[_oldPeriod].amount -= _accountInfo.amount;
		_periodInfo.amount += _accountInfo.amount;

		DayInfo storage _dayInfo = _periodInfo.dayInfo[day];
		_accountInfo.accRewardDebt = _accountInfo.amount * _dayInfo.accRewardPerShare / 1e18;
		_accountInfo.period = _newPeriod;
	}

	function deposit(uint256 _amount) external
	{
		depositOnBehalfOf(_amount, msg.sender);
	}

	function depositOnBehalfOf(uint256 _amount, address _account) public nonReentrant
	{
		require(_amount > 0, "invalid amount");

		_updateDay();

		_updateAccount(_account, int256(_amount));

		totalStaked += _amount;

		IERC20(hmineToken).safeTransferFrom(msg.sender, address(this), _amount);

		emit Deposit(_account, hmineToken, _amount);
	}

	function withdraw(uint256 _amount) external
	{
		require(_amount > 0, "invalid amount");

		AccountInfo storage _accountInfo = accountInfo[msg.sender];
		require(_amount <= _accountInfo.amount, "insufficient balance");

		_updateDay();

		_updateAccount(msg.sender, -int256(_amount));

		totalStaked -= _amount;

		if (_accountInfo.whitelisted || whitelistAll) {
			IERC20(hmineToken).safeTransfer(msg.sender, _amount);
		} else {
			uint256 _10percent = _amount * 10e16 / 100e16;
			uint256 _netAmount = _amount - 2 * _10percent;
			IERC20(hmineToken).safeTransfer(FURNACE, _10percent);
			IERC20(hmineToken).safeTransfer(bankroll, _10percent);
			IERC20(hmineToken).safeTransfer(msg.sender, _netAmount);
		}

		emit Withdraw(msg.sender, hmineToken, _amount);
	}

	function claim() external returns (uint256 _amount)
	{
		return claimOnBehalfOf(msg.sender);
	}

	function claimOnBehalfOf(address _account) public nonReentrant returns (uint256 _amount)
	{
		require(msg.sender == _account || msg.sender == hmineMain1, "access denied");

		_updateDay();

		_updateAccount(_account, 0);

		AccountInfo storage _accountInfo = accountInfo[_account];
		_amount = _accountInfo.reward;
		_accountInfo.reward = 0;

		if (_amount > 0) {
			totalReward -= _amount;

			IERC20(rewardToken).safeTransfer(msg.sender, _amount);
		}

		emit Claim(_account, rewardToken, _amount);

		return _amount;
	}

	function reward(address[] calldata _accounts, uint256[] calldata _amounts) external nonReentrant
	{
		require(_accounts.length == _amounts.length, "lenght mismatch");

		uint256 _amount = 0;

		for (uint256 _i = 0; _i < _accounts.length; _i++) {
			address _account = _accounts[_i];
			AccountInfo storage _accountInfo = accountInfo[_account];

			_accountInfo.reward += _amounts[_i];

			emit Reward(_account, rewardToken, _amounts[_i]);

			_amount += _amounts[_i];
		}

		if (_amount > 0) {
			totalReward += _amount;

			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
		}
	}

	function rewardAll(uint256 _amount) external nonReentrant
	{
		require(_amount > 0, "invalid amount");

		if (totalStaked == 0) {
			IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
			return;
		}

		_updateDay();

		for (uint256 _i = 0; _i < periodIndex.length; _i++) {
			uint16 _period = periodIndex[_i];
			PeriodInfo storage _periodInfo = periodInfo[_period];

			uint256 _subamount = _amount * _periodInfo.amount / totalStaked;
			if (_subamount == 0) continue;

			DayInfo storage _dayInfo = _periodInfo.dayInfo[day];
			_dayInfo.accRewardPerShare += _subamount * 1e18 / _periodInfo.amount;
			_dayInfo.expiringReward += _subamount;
		}

		totalReward += _amount;

		IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);

		emit RewardAll(msg.sender, rewardToken, _amount);
	}

	function _updateDay() internal
	{
		uint64 _today = today();

		if (day == _today) return;

		uint256 _amount = 0;

		for (uint256 _i = 0; _i < periodIndex.length; _i++) {
			uint16 _period = periodIndex[_i];
			PeriodInfo storage _periodInfo = periodInfo[_period];

			for (uint64 _day = day; _day < _today; _day++) {
				{
					_periodInfo.dayInfo[_day + 1].accRewardPerShare = _periodInfo.dayInfo[_day].accRewardPerShare;
				}

				if (_period < MAX_PERIOD) {
					DayInfo storage _dayInfo = _periodInfo.dayInfo[_day - _period];
					_amount += _dayInfo.expiringReward;
					_dayInfo.expiringReward = 0;
				}
			}
		}

		day = _today;

		if (_amount > 0) {
			totalReward -= _amount;

			IERC20(rewardToken).safeTransfer(buyback, _amount);
		}
	}

	function _updateAccount(address _account, int256 _amount) internal
	{
		AccountInfo storage _accountInfo = accountInfo[_account];
		uint16 _period = _accountInfo.period;
		if (_period == 0) {
			_period = 1;
			_accountInfo.period = _period;
			_accountInfo.day = day - (_period + 1);
		}
		PeriodInfo storage _periodInfo = periodInfo[_period];

		uint256 _rewardBefore = _accountInfo.reward;

		if (_period < MAX_PERIOD) {
			if (_accountInfo.day < day - _period) {
				DayInfo storage _dayInfo = _periodInfo.dayInfo[day - 1];
				_accountInfo.accRewardDebt = _accountInfo.amount * _dayInfo.accRewardPerShare / 1e18;
			} else {
				for (uint64 _day = _accountInfo.day; _day < day; _day++) {
					DayInfo storage _dayInfo = _periodInfo.dayInfo[_day];
					uint256 _accRewardDebt = _accountInfo.amount * _dayInfo.accRewardPerShare / 1e18;
					uint256 _reward = _accRewardDebt - _accountInfo.accRewardDebt;
					_dayInfo.expiringReward -= _reward;
					_accountInfo.reward += _reward;
					_accountInfo.accRewardDebt = _accRewardDebt;
				}
			}
		}

		{
			DayInfo storage _dayInfo = _periodInfo.dayInfo[day];
			uint256 _reward = _accountInfo.amount * _dayInfo.accRewardPerShare / 1e18 - _accountInfo.accRewardDebt;
			_dayInfo.expiringReward -= _reward;
			_accountInfo.reward += _reward;
			if (_amount > 0) {
				_accountInfo.amount += uint256(_amount);
				_periodInfo.amount += uint256(_amount);
			}
			else
			if (_amount < 0) {
				_accountInfo.amount -= uint256(-_amount);
				_periodInfo.amount -= uint256(-_amount);
			}
			_accountInfo.accRewardDebt = _accountInfo.amount * _dayInfo.accRewardPerShare / 1e18;
		}

		_accountInfo.day = day;

		if (_periodInfo.fee > 0) {
			uint256 _rewardAfter = _accountInfo.reward;

			uint256 _reward = _rewardAfter - _rewardBefore;
			uint256 _fee = _reward * _periodInfo.fee / 1e18;
			if (_fee > 0) {
				_accountInfo.reward -= _fee;

				totalReward -= _fee;

				IERC20(rewardToken).safeTransfer(buyback, _fee);
			}
		}
	}

	event Deposit(address indexed _account, address indexed _hmineToken, uint256 _amount);
	event Withdraw(address indexed _account, address indexed _hmineToken, uint256 _amount);
	event Claim(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event Reward(address indexed _account, address indexed _rewardToken, uint256 _amount);
	event RewardAll(address indexed _account, address indexed _rewardToken, uint256 _amount);
}

// SPDX-License-Identifier: MIT

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