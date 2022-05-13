// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "./libraries/PersonalContractLibrary.sol";
import "./../Interfaces/IStrategy.sol";
import "./../Interfaces/IUniswapV2Pair.sol";
import "./interfaces/IExecutable.sol";

import "./UnstakeLogic.sol";
import "./StakeLogic.sol";

contract ExecuteClaimProfit is UnstakeLogic, StakeLogic, IExecutable {
  enum ClaimProfitTypes {
    Native,
    Yield,
    Stake
  }

  event ProfitNativeClaimed(uint256 toBurn, uint256 toDevelopment, uint256 yieldAmount);
  event ProfitYieldClaimed(uint256 toBurn, uint256 toDevelopment, uint256 yieldAmount);
  event ProfitStaked(uint256 amount);

  /**
  @notice IExecutable api interface
  @param data data for internal logic
  */
  function execute(bytes calldata data) strategistOrInvestor external {
    (
      UnstakeSet memory _un,
      VaultToLiquiditySet memory _vl,
      WithdrawLiquiditySet memory _wl,
      address[] memory _rewards,
      ClaimProfitTypes _claimProfitType,
      bool exit
    ) = abi.decode(data, (UnstakeSet, VaultToLiquiditySet, WithdrawLiquiditySet, address[], ClaimProfitTypes, bool));

    if (exit) {
      claimProfitAndExit(_un, _vl, _wl, _rewards, _claimProfitType);
    } else {
      claimProfit(_un, _vl, _wl, _rewards, _claimProfitType);
    }
  }

  /**
  @notice Claim profit in claim profit type, withdraw liquidity and send it to investor
  @param _un used in unstakeAndWithdrawLiquidity
  @param _vl used in unstakeAndWithdrawLiquidity
  @param _wl used in unstakeAndWithdrawLiquidity
  @param _rewards array of reward token addresses to claim
  @param _claimProfitType type of claim profit
  */
  function claimProfitAndExit(
    UnstakeSet memory _un,
    VaultToLiquiditySet memory _vl,
    WithdrawLiquiditySet memory _wl,
    address[] memory _rewards,
    ClaimProfitTypes _claimProfitType
  ) internal {
    _wl.toWhomToIssue = address(this);
    _wl.toTokenAddress = investment.token;
    uint256 withdrawn = unstakeAndWithdrawLiquidity(_un, _vl, _wl, true);
    emit LiquidityUnstakedAndWithdrawn(_un.stakeContractAddress, _un.pid);

    for (uint256 i; i < _rewards.length; i++) {
      uint256 _balance =  IERC20(_rewards[i]).balanceOf(address(this));
      if(_balance == 0) continue;

      withdrawn += PersonalContractLibrary.convertTokenToToken(
        factory,
        address(this),
        _rewards[i],
        _wl.toTokenAddress,
        _balance,
        1
      );
    }

    uint256 profit = withdrawn > investment.initialAmount ? withdrawn - investment.initialAmount : 0; 

    if (profit > 0) {
      calculateAndSendProfitInType(_wl.toTokenAddress, withdrawn, _claimProfitType);
    }

    IERC20(_wl.toTokenAddress).transfer(investor, IERC20(_wl.toTokenAddress).balanceOf(address(this)));
  }

  /**
  @notice Claim profit in claim profit type
  @param _un used in unstakeAndWithdrawLiquidity
  @param _vl used in unstakeAndWithdrawLiquidity
  @param _wl used in unstakeAndWithdrawLiquidity
  @param _rewards array of reward token addresses to claim
  @param _claimProfitType type of claim profit
  */
  function claimProfit(
    UnstakeSet memory _un,
    VaultToLiquiditySet memory _vl,
    WithdrawLiquiditySet memory _wl,
    address[] memory _rewards,
    ClaimProfitTypes _claimProfitType
  ) internal {
    uint256 profit = claimProfitInToken(_un, _vl, _wl, _rewards, investment.token);
    calculateAndSendProfitInType(investment.token, profit, _claimProfitType);
  }

  /**
  @notice Claim profit in token 
  @param _un used in unstakeAndWithdrawLiquidity
  @param _vl used in unstakeAndWithdrawLiquidity
  @param _wl used in unstakeAndWithdrawLiquidity
  @param _rewards addresses of possible _rewards
  @param token address of token in which profit will be withdrawn
  */
  function claimProfitInToken(
    UnstakeSet memory _un,
    VaultToLiquiditySet memory _vl,
    WithdrawLiquiditySet memory _wl,
    address[] memory _rewards,
    address token
  ) internal returns(uint256 out) {
    claimRewards(_un);

    (ITokenConversionLibrary tokenConversion, ITokenConversionStorage conversionStorage) = factory.getTokenConversion();

    (uint256 estimatedLiquidity, uint256 estimatedRewards) = PersonalContractLibrary.estimateInvestment(
      tokenConversion,
      address(conversionStorage),
      IUniswapV2Pair(_wl.fromliquidityPoolAddress),
      _un.amount,
      _rewards,
      token
    );

    uint256 profit = 
      estimatedLiquidity + estimatedRewards > investment.initialAmount ? 
      estimatedLiquidity + estimatedRewards - investment.initialAmount : 
      0;
    if (profit == 0) return 0;

    uint256 rewardsProfit = profit > estimatedRewards ? estimatedRewards : profit;
    out += claimRewardsInProfit(
      tokenConversion,
      address(conversionStorage),
      rewardsProfit,
      _rewards,
      token
    );

    if (profit - rewardsProfit > 0) {
      _un.amount = _un.amount * (profit - rewardsProfit) / estimatedLiquidity;
      _wl.toWhomToIssue = address(this);
      _wl.toTokenAddress = token;
      out += unstakeAndWithdrawLiquidity(_un, _vl, _wl, false);
    }
  }

  /**
  @notice Calculate profit and fee in claim ptofit type
  @param _token token which profit collected
  @param _profit amount of profit
  @param _claimProfitType claim profit type
  */
  function calculateAndSendProfitInType(
    address _token,
    uint256 _profit,
    ClaimProfitTypes _claimProfitType
  ) internal {
    if (_profit == 0) return;

    if (_claimProfitType == ClaimProfitTypes.Native) {
      calculateAndSendNativeProfit(_token, _profit);
    } else if (_claimProfitType == ClaimProfitTypes.Yield) {
      calculateAndSendYieldProfit(_token, _profit);
    } else if (_claimProfitType == ClaimProfitTypes.Stake) {
      stakeToYieldPool(_token, _profit);
    } else {
      revert();
    }
  }

  /**
  @notice Claim profit in native invested token
  @param token token which profit collected
  @param profit amount of profit
  */
  function calculateAndSendNativeProfit(
    address token,
    uint256 profit
  ) internal {
    if (profit == 0) return;
    IFactory _factory = factory;

    (uint256 toDevelopment, uint256 toBurn, address toToken, address to) = _factory.claimInNativeSettings();
    toDevelopment = profit - ((profit * (percentageDecimals - toDevelopment)) / percentageDecimals);
    toBurn = profit - ((profit * (percentageDecimals - toBurn)) / percentageDecimals);

    profit = profit - toDevelopment - toBurn;
    toDevelopment = PersonalContractLibrary.convertTokenToToken(
      _factory,
      address(this),
      token,
      toToken,
      toDevelopment,
      1
    );
    toBurn = PersonalContractLibrary.convertTokenToToken(_factory, address(this), token, yieldToken, toBurn, 1);

    IERC20(toToken).transfer(to, toDevelopment);
    ERC20Burnable(yieldToken).burn(toBurn);
    IERC20(token).transfer(investor, profit);
    emit ProfitNativeClaimed(toBurn, toDevelopment, profit);
  }

  /**
  @notice Claim profit in yield token
  @param token token which profit collected
  @param profit amount of profit
  */
  function calculateAndSendYieldProfit(
    address token,
    uint256 profit
  ) internal {
    if (profit == 0) return;
    
    IFactory _factory = factory;
    address _yieldToken = yieldToken;

    (uint256 toDevelopment, uint256 toBurn, address toToken, address to) = _factory.claimInYieldSettings();
    toDevelopment = profit - ((profit * (percentageDecimals - toDevelopment)) / percentageDecimals);
    toBurn = profit - ((profit * (percentageDecimals - toBurn)) / percentageDecimals);

    profit = profit - toDevelopment - toBurn;
    toDevelopment = PersonalContractLibrary.convertTokenToToken(
      _factory,
      address(this),
      token,
      toToken,
      toDevelopment,
      1
    );
    uint256 yieldAmount = PersonalContractLibrary.convertTokenToToken(
      _factory,
      address(this),
      token,
      _yieldToken,
      profit + toBurn,
      1
    );

    uint256 toBurnYield = yieldAmount * toBurn / (profit + toBurn);
    yieldAmount -= toBurnYield;

    IERC20(toToken).transfer(to, toDevelopment);
    ERC20Burnable(_yieldToken).burn(toBurnYield);
    IERC20(_yieldToken).transfer(investor, yieldAmount);
    emit ProfitYieldClaimed(toBurnYield, toDevelopment, yieldAmount);
  }

  /**
  @notice Stake tokens to yield liquidity pool
  @param profitToken token in which profit collected
  @param amount amount of tokens
  */
  function stakeToYieldPool(address profitToken, uint256 amount) internal {
    if (amount == 0) return;

    (
      address yieldStakeContract, 
      address yieldStakePair, 
      address yieldStakeRouter, 
      address yieldStakeFactory, 
      uint256 yieldStakeStrategy,
      uint256 yieldStakeLockSeconds,
    ) = factory.getYieldStakeSettings();

    address exchange = factory.exchange();
    IERC20(profitToken).transfer(exchange, amount);

    amount = IExchange(exchange).addLiquidityDefaultPath(
      address(this),
      profitToken,
      IUniswapV2Pair(yieldStakePair).token0(),
      IUniswapV2Pair(yieldStakePair).token1(),
      yieldStakeRouter,
      yieldStakeFactory,
      amount,
      1
    );

    _stake(
      yieldStakeStrategy,
      yieldStakeContract,
      yieldStakePair,
      amount,
      0,
      bytes("")
    );

    stakedRewards[yieldStakeContract][0].push(
      StakedReward(amount, block.timestamp, block.timestamp + yieldStakeLockSeconds)
    );

    emit ProfitStaked(amount);
  }

  function claimRewardsInProfit(
    ITokenConversionLibrary tokenConversion,
    address conversionStorage,
    uint256 rewardsProfit,
    address[] memory _rewards,
    address token
  ) internal returns(uint256 out) {
    if (rewardsProfit == 0) return 0;

    uint256 rewardsCollected = 0;

    for (uint256 i = 0; i < _rewards.length; i++) {
      uint256 balance = IERC20(_rewards[i]).balanceOf(address(this));
      if (balance == 0) continue;
      if (_rewards[i] == token) {
        out = balance;
        continue;
      }

      uint256 estimate = tokenConversion.estimateTokenToToken(conversionStorage, _rewards[i], token, balance);
      uint256 withdrawAmount = 
            rewardsProfit - rewardsCollected > estimate ? estimate : rewardsProfit - rewardsCollected;
      rewardsCollected += withdrawAmount;
      withdrawAmount = withdrawAmount * balance / estimate;

      out += PersonalContractLibrary.convertTokenToToken(factory, address(this), _rewards[i], token, withdrawAmount, 1);
    }
  }

  function claimRewards(UnstakeSet memory _un) internal {
    IStrategy strategy = IStrategy(factory.getStrategy(_un.poolTemplate));
    PersonalContractLibrary.claimRewards(strategy, _un.stakeContractAddress, _un.pid);
  }
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
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

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

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
contract ERC20 is Context, IERC20, IERC20Metadata {
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
    constructor(string memory name_, string memory symbol_) {
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
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./../../Interfaces/IFactory.sol";
import "./../../Interfaces/IUniswapV2Pair.sol";
import "./../../Interfaces/ITokenConversionLibrary.sol";
import "./../../Interfaces/ITokenConversionStorage.sol";
import "./../../Interfaces/IStrategy.sol";

library PersonalContractLibrary {
  /**
  @notice Estimates current value after claim pending rewards of investment in invetment.token tokens
  @param tokenConversionLibrary library with ITokenConversion interface
  @param tokenConversionStorage store of pathes for exchage
  @param _lpPool pool in which investment currently
  @param _lpAmount expected amount of liquidity pool tokens
  @param _rewards addresses of possible rewards
  @param _toToken pool in which investment currently
  @return estimatedLiquidity estimated output of liquidity pool tokens in invetment.token
  @return estimatedRewards estimated output of rewards in invetment.token
  */
  function estimateInvestment(
    ITokenConversionLibrary tokenConversionLibrary,
    address tokenConversionStorage,
    IUniswapV2Pair _lpPool,
    uint256 _lpAmount,
    address[] calldata _rewards,
    address _toToken
  ) external view returns (
    uint256 estimatedLiquidity,
    uint256 estimatedRewards
  ) {
    for (uint256 i = 0; i < _rewards.length; i++) {
      uint256 balance = IERC20(_rewards[i]).balanceOf(address(this));
      estimatedRewards += tokenConversionLibrary.estimateTokenToToken(
        tokenConversionStorage,
        _rewards[i],
        _toToken,
        balance
      );
    }

    estimatedLiquidity = tokenConversionLibrary.estimatePoolOutput(
      tokenConversionStorage,
      _lpPool,
      _toToken,
      _lpAmount
    );
  }

  /**
  @notice Claim rewards from staking pool
  @param _strategy contract with claim rewards logic
  @param _stakeContractAddress address of staking contract
  @param _pid masterchef pid
  */
  function claimRewards(
    IStrategy _strategy,
    address _stakeContractAddress,
    uint256 _pid
  ) internal {
    (bool status, ) = address(_strategy).delegatecall(
      abi.encodeWithSelector(_strategy.claimRewards.selector, _stakeContractAddress, _pid)
    );
    require(status, 'claimRewards call failed');
  }

  /**
  @notice convert any tokens to any tokens.
  @param _toWhomToIssue is address of personal contract for this user
  @param _tokenToExchange address of token witch will be converted
  @param _tokenToConvertTo address of token witch will be returned
  @param _amount how much will be converted
  */
  function convertTokenToToken(
    IFactory _factory,
    address _toWhomToIssue,
    address _tokenToExchange,
    address _tokenToConvertTo,
    uint256 _amount,
    uint256 _minOutputAmount
  ) internal returns (uint256) {       
    (
      ITokenConversionLibrary tokenConversion,
      ITokenConversionStorage conversionStorage
    ) = _factory.getTokenConversion();

    (bool status, bytes memory result) = address(tokenConversion).delegatecall(
      abi.encodeWithSelector(
        tokenConversion.convertTokenToToken.selector,
        conversionStorage,
        _toWhomToIssue,
        _tokenToExchange,
        _tokenToConvertTo,
        _amount,
        _minOutputAmount
      )
    );

    require(status, 'convertTokenToToken call failed');
    return abi.decode(result, (uint256));
  }

  function approve(address _token, address _spender, uint256 _amount) internal {
    // in case SafeERC20: approve from non-zero to non-zero allowance
    IERC20(_token).approve(_spender, 0);
    IERC20(_token).approve(_spender, _amount);
  }
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

import "./../../Interfaces/IExchange.sol";

interface IUnstakeLogic {
  event LiquidityUnstakedAndWithdrawn(address stakeContractAddress, uint256 pid);

  struct WithdrawLiquiditySet {
    address toWhomToIssue;
    address toTokenAddress;
    address fromTokenAddress;
    address fromliquidityPoolAddress;
    uint256 minTokensRec;
    address router;
    IExchange.LiquidityTrade trade;
  }

  struct VaultToLiquiditySet {
    address vaultAddress;
  }

  struct UnstakeSet {
    uint256 poolTemplate;
    address stakeContractAddress; 
    uint256 amount;
    uint256 pid;
    bytes extraBytes;
  }
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

import "./../../Interfaces/IExchange.sol";

interface IStakeLogic {
  event LiquidityToVault(address stakeContractAddress, address pairAddress, uint256 balance);

  struct ProvideLiquiditySet {
    address tokenAddress;
    address pairAddress;
    address liquidityPoolOutputTokenAddress;
    uint256 amount;
    uint256 minPoolTokens;
    address router;
    address factory;
    IExchange.LiquidityTrade trade;
  }

  struct LiquidityToVaultSet {
    uint256 poolTemplate;
    address vaultAddresses;
    uint256 pid;
  }

  struct StakeSet {
    uint256 poolTemplate; 
    address stakeContractAddress; 
    address tokenToStake;
    uint256 pid;
    bytes extraBytes;
  }
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

interface IExecutable {
  function execute(bytes calldata data) external;
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./libraries/PersonalContractLibrary.sol";
import "./ExecutableParams.sol";
import "./interfaces/IUnstakeLogic.sol";
import "./../Interfaces/IVaultProxy.sol";
import "./../Interfaces/IExchange.sol";
import "./../Interfaces/IStrategy.sol";

abstract contract UnstakeLogic is ExecutableParams, IUnstakeLogic {
  /**
  @notice This function is used to unstake and withdraw liquidity with one transaction [harvest]
  @param _un data about staking pool to exit staking
  @param _vl data about vault to withdraw tokens
  @param _wl data about liquidity pool to withdraw tokens
  */
  function unstakeAndWithdrawLiquidity(
    UnstakeSet memory _un,
    VaultToLiquiditySet memory _vl,
    WithdrawLiquiditySet memory _wl,
    bool _updateInitialAmount
  ) internal returns(uint256) {
    if (_updateInitialAmount) {
      require(_wl.toTokenAddress == investment.token, "Wrong token");
      investment.initialAmount = 0;
      currentPool.stakeContract = address(0);
      currentPool.liquidityPool = address(0);
    }

    return exitPool(_un, _vl, _wl);
  }

  /**
  @notice Withdraw tokens from stake contract and exchange to token
  @param _un data about staking pool to exit staking
  @param _vl data about vault to withdraw tokens
  @param _wl data about liquidity pool to withdraw tokens
  */
  function exitPool(
    UnstakeSet memory _un,
    VaultToLiquiditySet memory _vl,
    WithdrawLiquiditySet memory _wl
  ) internal returns(uint256) {
    if (_un.stakeContractAddress != address(0)) {
      bool yieldPool = stakedRewards[_un.stakeContractAddress][_un.pid].length > 0;
      _unstake(_un.poolTemplate, _un.stakeContractAddress, _un.amount, _un.pid, _un.extraBytes);

      if (yieldPool) {
        IERC20(_wl.fromliquidityPoolAddress).transfer(investor, _un.amount);
      }
    }

    if (_vl.vaultAddress != address(0)) {
      _vaultToLiquidity(_vl.vaultAddress);
    }

    return _withdrawLiquidity(
      address(this),
      _wl.toTokenAddress,
      _wl.fromTokenAddress,
      _wl.router,
      IERC20(_wl.fromliquidityPoolAddress).balanceOf(address(this)),
      _wl.minTokensRec,
      _wl.trade
    );
  }

  /**
  @notice This function is used to unstake tokens
  @param _poolTemplate template of the pool. 0 = STAKE, 1 = DEPOSIT and so on..
  @param _stakeContractAddress The stake contract address
  @param _amount The amount of tokens to withdraw
  @param _pid id of the pool in masterchef contract..
  @param extraBytes set of bytes for any extra data !! skipped till gas limit improved !!
  */
  function _unstake(
    uint256 _poolTemplate,
    address _stakeContractAddress,
    uint256 _amount,
    uint256 _pid,
    bytes memory extraBytes
  ) internal {
    (bool status, ) = factory.getStrategy(_poolTemplate).delegatecall(
      abi.encodeWithSelector(
        IStrategy.unstake.selector,
        _stakeContractAddress,
        _amount,
        _pid,
        extraBytes
      )
    );
    assert(status);
  }

  /**
  @notice This function is used to unfarm flp tokens, example: f3Crv -> 3Crv
  @notice Didn't add _poolTemplate, cause all known use same withdraw function
  @param vaultAddress source of farmed tokens
  */
  function _vaultToLiquidity(address vaultAddress) internal {
    IVaultProxy(vaultAddress).withdraw(IERC20(vaultAddress).balanceOf(address(this)));
  }
  
  /**
  @notice This function is used to withdraw liquidity from pool
  @param _ToWhomToIssue is address of personal contract for this user
  @param _ToTokenContractAddress The ERC20 token to withdraw in (address(0x00) if ether)
  @param _fromPairAddress The pair address to withdraw from
  @param _amount The amount of liquidity pool tokens (LP)
  @param _minTokensRec Reverts if less tokens received than this
  @return the amount of eth/tokens received after withdraw
  */
  function _withdrawLiquidity(
    address _ToWhomToIssue,
    address _ToTokenContractAddress,
    address _fromPairAddress,
    address _poolRouter,
    uint256 _amount,
    uint256 _minTokensRec,
    IExchange.LiquidityTrade memory _trade
  ) internal returns (uint256) {
    require(_ToWhomToIssue == address(this) || _ToWhomToIssue == investor, "!allowed");

    address exchange = factory.exchange();
    PersonalContractLibrary.approve(_fromPairAddress, exchange, _amount);

    return IExchange(exchange).removeLiquidity(
      _ToWhomToIssue,
      _ToTokenContractAddress,
      _fromPairAddress,
      _poolRouter,
      _amount,
      _minTokensRec,
      _trade
    );
  }
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./libraries/PersonalContractLibrary.sol";
import "./ExecutableParams.sol";
import "./interfaces/IStakeLogic.sol";
import "./../Interfaces/IExchange.sol";

abstract contract StakeLogic is ExecutableParams, IStakeLogic {
  /**
  @notice provides liquidity and stake it to pool
  @param _pl data about liquidity to pool to became liquidity provider
  @param _lv data about vault to deposit to vault
  @param _st data about staking pool to stake tokens
  */
  function provideLiquidityAndStake(
    ProvideLiquiditySet memory _pl,
    LiquidityToVaultSet memory _lv,
    StakeSet memory _st,
    bool _updateInitialAmount
  ) internal {
    updateCurrentPool(_st.stakeContractAddress, _pl.pairAddress);

    uint256 balance = _provideLiquidity(_pl);

    if (_lv.vaultAddresses != address(0)) {
      emit LiquidityToVault(_st.stakeContractAddress, _pl.pairAddress, balance);
      _stake(_lv.poolTemplate, _lv.vaultAddresses, _pl.liquidityPoolOutputTokenAddress, balance, _lv.pid, bytes(""));
      balance = IERC20(_st.tokenToStake).balanceOf(address(this));
    }

    if (_st.stakeContractAddress != address(0)) {
      _stake(_st.poolTemplate, _st.stakeContractAddress, _st.tokenToStake, balance, _st.pid, _st.extraBytes);
    }

    if (_updateInitialAmount) {
      require(_pl.tokenAddress == investment.token, "Wrong token");
      investment.initialAmount += _pl.amount;
    }
  }

  function updateCurrentPool(address stakeContractAddress, address pairAddress) internal {
    factory.assertPoolApproved(stakeContractAddress, pairAddress, riskLevel);
    if (currentPool.liquidityPool != address(0)) {
      require(
        currentPool.liquidityPool == pairAddress &&
        currentPool.stakeContract == stakeContractAddress,
        "Stake to wrong pool"
      );
    } else {
      currentPool.liquidityPool = pairAddress;
      currentPool.stakeContract = stakeContractAddress;
    }
  }

  /**
  @notice This function is used to invest in given LP pair through ETH/ERC20 Tokens
  @return Amount of LP bought
  */
  function _provideLiquidity(ProvideLiquiditySet memory _pl) internal returns (uint256) {
    address exchange = factory.exchange();
    PersonalContractLibrary.approve(_pl.tokenAddress, exchange, _pl.amount);

    return IExchange(exchange).addLiquidity(
      address(this),
      _pl.tokenAddress,
      _pl.pairAddress,
      _pl.router,
      _pl.factory,
      _pl.amount,
      _pl.minPoolTokens,
      _pl.trade
    );
  }

  /**
  @notice the function stakes token into provided pool.
  @notice pool's "stake" function must match one of hardcoded template
  @param _poolTemplate template of the pool. 0 = STAKE, 1 = DEPOSIT and so on..
  @param _stakeContractAddress The stake contract address
  @param _tokenToStake is address of a token or lp/flp pair to be staked
  @param _amount The amount of _fromTokenAddress to invest
  @param _pid id of the pool in masterchef contract..
  @param extraBytes set of bytes for any extra data !! skipped till gas limit improved !!
  */
  function _stake(
    uint256 _poolTemplate,
    address _stakeContractAddress,
    address _tokenToStake,
    uint256 _amount,
    uint256 _pid,
    bytes memory extraBytes
  ) internal {
    PersonalContractLibrary.approve(_tokenToStake, _stakeContractAddress, _amount);

    (bool status, ) = factory.getStrategy(_poolTemplate).delegatecall(abi.encodeWithSignature(
        "stake(address,address,uint256,uint256,bytes)",
        _stakeContractAddress, _tokenToStake, _amount, _pid, extraBytes
    ));

    require(status, 'stake call failed');
  }
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./../Interfaces/IFactory.sol";

abstract contract ExecutableParams {
  using SafeERC20 for IERC20;

  struct Investment {
    address token;
    uint256 initialAmount;
  }

  struct StakedReward {
    uint256 amount;
    uint256 createdAt;
    uint256 unlockAt;
  }

  struct Pool {
    address stakeContract;
    address liquidityPool;
  }

  uint256 internal constant percentageDecimals = 10000;

  Investment public investment;
  Pool public currentPool;
  mapping (address => mapping (uint256 => StakedReward[])) public stakedRewards;

  IFactory internal factory;
  address internal investor;
  address internal strategist;
  address internal yieldToken;
  uint8 internal riskLevel;
  bool public compoundEnabled;

  /**
  * @dev Throws if called by any account other than the strategist.
  */
  modifier onlyStrategist() {
      require(msg.sender == strategist, "not allowed");
      _;
  }

  modifier onlyInvestor() {
    require(msg.sender == investor, "not allowed");
    _;
  }

  modifier strategistOrInvestor() {
    require(msg.sender == strategist || msg.sender == investor, "not allowed");
    _;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IVaultProxy {
  function deposit(uint256 amount) external;
  function withdraw(uint256 amount) external;
  function userInfo(address user) external returns(uint256, uint256);
  function pendingRewards() external returns(uint256);
  function mint(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IUniswapV2Pair {
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

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

interface ITokenConversionStorage {
  function exchangesInfo(uint256 index) external returns(
    string memory name,
    address router,
    address factory
  );
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IUniswapV2Pair.sol";

interface ITokenConversionLibrary {
  function convertTokenToToken(
    address _storageAddress,
    address payable _toWhomToIssue,
    address _fromToken,
    address _toToken,
    uint256 _amount,
    uint256 _minOutputAmount
  ) external returns (uint256);
  function convertArrayOfTokensToToken(
    address _storageAddress,
    address[] memory _tokens,
    address _convertToToken,
    address payable _toWhomToIssue,
    uint256 _minTokensRec
  ) external returns (uint256);
  function estimateTokenToToken(
    address _storageAddress,
    address _fromToken,
    address _toToken,
    uint256 _amount
  ) external view returns (uint256);
  function estimatePoolOutput(
    address _storageAddress,
    IUniswapV2Pair _lpPool,
    address _toToken,
    uint256 _lpAmount
  ) external view returns (uint256 amountOut);
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

interface IStrategy {
  function stake(address, address, uint256, uint256, bytes memory) external;
  function unstake(address, uint256, uint256, bytes memory) external;
  function claimRewards(address, uint256) external;
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

import "./ITokenConversionLibrary.sol";
import "./ITokenConversionStorage.sol";

interface IFactory {
  struct Exchange{
    string name;
    address inContractAddress;
    address outContractAddress;
  }

  struct RiskLevel {
    uint8 value;
    bool wholePlatform;
  }

  function yieldToken() external returns(address yieldToken);
  function isWhitelisted(address _target) external returns(bool isWhitelisted);
  function assertPoolApproved(address _stakeContract, address _liqudityPool, uint8 _riskLevel) external view;
  function enableApproveAssert() external;
  function claimInNativeSettings() external view returns(
    uint256 toDevelopment,
    uint256 toBurn,
    address toToken,
    address to
  );
  function claimInYieldSettings() external view returns(
    uint256 toDevelopment,
    uint256 toBurn,
    address toToken,
    address to
  );
  function getStrategy(uint256 _index) external view returns(address strategy);
  function getYieldStakeSettings() view external returns(
    address yieldStakeContract,
    address yieldStakePair,
    address yieldStakeRouter,
    address yieldStakeFactory,
    uint256 yieldStakeStrategy,
    uint256 yieldStakeLockSeconds,
    address yieldStakeRewardToken
  );
  function getTokenConversion() external view returns(
    ITokenConversionLibrary _library,
    ITokenConversionStorage _storage
  );
  function exchange() external view returns(address);
}

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;

interface IExchange {
  struct TokenTrade {
		address[] routers;
		address[][] paths;
  }

  struct LiquidityTrade {
    TokenTrade token0;
    TokenTrade token1;
  }

  function addLiquidity(
    address _toWhomToIssue,
    address _fromTokenAddress,
    address _toPairAddress,
    address _poolRouter,
    address _poolFactory,
    uint256 _amount,
    uint256 _minPoolTokens,
    LiquidityTrade calldata _trade
  ) external returns(uint256);

  function addLiquidityDefaultPath(
    address _toWhomToIssue,
    address _FromTokenContractAddress,
    address _ToUnipoolToken0,
    address _ToUnipoolToken1,
    address _poolRouter,
    address _poolFactory,
    uint256 _amount,
    uint256 _minPoolTokens
  ) external returns(uint256);

  function removeLiquidity(
    address _toWhomToIssue,
    address _toToken,
    address _poolAddress,
    address _poolRouter,
    uint256 _amount,
    uint256 _minTokensRec,
    LiquidityTrade calldata _trade
  ) external returns(uint256);
}