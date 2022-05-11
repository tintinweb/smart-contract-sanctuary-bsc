// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./CPool.sol";
import "./utils/SafeERC20.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/ICopyStaking.sol";
import "./interfaces/ICRules.sol";
import "./interfaces/IPancakeRouter.sol";
import "./interfaces/IPriceProvider.sol";

contract CPoolFactory {
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    IERC20 public stableCoin;
    ICopyStaking public stakingContract;
    ICRules public rulesContract;
    IPancakeRouter public pancakeRouter;
    IPriceProvider public priceProvider;

    /* ========== CONSTRUCTOR ========== */
    constructor(
        address _stableCoinAddress,
        address _stakingContract,
        address _rulesContract,
        address _pancakeRouter,
        address _priceProviderContract
    ) {
        stableCoin = IERC20(_stableCoinAddress);
        stakingContract = ICopyStaking(_stakingContract);
        rulesContract = ICRules(_rulesContract);
        pancakeRouter = IPancakeRouter(_pancakeRouter);
        priceProvider = IPriceProvider(_priceProviderContract);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
    function createCPool(
        address _trader,
        uint256 _initialParticipationPrice,
        uint8 _traderParticipations,
        uint8 _maxParticipationPerParticipan,
        uint8 _performanceFee
    )
        external
        validateCreation(
            _traderParticipations,
            _initialParticipationPrice,
            _trader
        )
    {
        CPool newPool = new CPool(
            _trader,
            _traderParticipations,
            _maxParticipationPerParticipan,
            _performanceFee,
            _initialParticipationPrice,
            address(stakingContract),
            address(pancakeRouter),
            address(stableCoin),
            address(rulesContract),
            address(priceProvider)
        );

        stableCoin.safeTransferFrom(
            msg.sender,
            address(this),
            _initialParticipationPrice * _traderParticipations
        );

        stableCoin.safeTransfer(
            address(newPool),
            _initialParticipationPrice * _traderParticipations
        );

        rulesContract.addPoolToWhiteList(address(newPool));
    }

    /* ========== MODIFIERS ========== */

    modifier validateCreation(
        uint256 _traderParticipations,
        uint256 _initialParticipationPrice,
        address _trader
    ) {
        require(
            _traderParticipations != 0,
            "Must provide at least one participation."
        );
        require(
            _initialParticipationPrice != 0,
            "The initial price cannot be zero."
        );

        require(
            rulesContract.isTraderInWhiteList(_trader),
            "Trader must be on the whitelist"
        );
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./utils/SafeERC20.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IPancakeRouter.sol";
import "./interfaces/ICopyStaking.sol";
import "./interfaces/ICRules.sol";
import "./interfaces/IPriceProvider.sol";

/**
    - Dividir el contrato de reglas - Contrato ParticipationManager.sol
    - Agregar el mapping con los balances de los tokens que entran
    - Validar el swap: token de entrada en el balance y el token de salida en la whitelist
    - Participation price es privada ahora
    - Validacion en la suscripcion que el copier no sea un trader en la whitelist
 */
contract CPool {
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    address public trader;
    uint256 public traderParticipations;
    uint8 public maxParticipationsPerParticipant;
    uint8 public performanceFee;
    uint256 public totalParticipations;
    uint256 public initialParticipationPrice;
    ICopyStaking public stakingContract;
    IPancakeRouter public pancakeRouter;
    IERC20 public stableCoin;
    ICRules public rulesContract;
    IPriceProvider public priceProvider;
    IERC20[] public tokens;

    mapping(address => uint256) public participants;
    mapping(address => uint256) public tokenAddressesIndex;
    uint256 private lastIndexOfToken = 1000;

    mapping(address => uint256) private internalBalances;

    /* ========== CONSTRUCTOR ========== */
    constructor(
        address _trader,
        uint256 _traderParticipations,
        uint8 _maxParticipationPerParticipan,
        uint8 _performanceFee,
        uint256 _initialParticipationPrice,
        address _stakingContract,
        address _routerContract,
        address _stableCoin,
        address _rulesContract,
        address _priceProviderContract
    ) {
        trader = _trader;
        traderParticipations = _traderParticipations;
        maxParticipationsPerParticipant = _maxParticipationPerParticipan;
        performanceFee = _performanceFee;
        initialParticipationPrice = _initialParticipationPrice;
        stakingContract = ICopyStaking(_stakingContract);
        pancakeRouter = IPancakeRouter(_routerContract);
        stableCoin = IERC20(_stableCoin);
        rulesContract = ICRules(_rulesContract);
        priceProvider = IPriceProvider(_priceProviderContract);

        totalParticipations += _traderParticipations;

        tokens.push(stableCoin);
        tokenAddressesIndex[_stableCoin] = lastIndexOfToken;
        lastIndexOfToken++;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function closePool() external onlyTrader {
        address[] memory path = new address[](2);
        path[1] = address(stableCoin);
        for (uint256 i = 0; i < tokens.length; i++) {
            path[0] = address(tokens[i]);
            uint256 balance = tokens[i].balanceOf(address(this));
            uint256[] memory amountOutMin = pancakeRouter.getAmountsOut(
                balance,
                path
            );
            swap(
                address(tokens[i]),
                address(stableCoin),
                balance,
                amountOutMin[path.length - 1]
            );
        }
    }

    function _addTokens(address _tokenA, address _tokenB) private {
        if (tokenAddressesIndex[_tokenA] == 0) {
            tokenAddressesIndex[_tokenA] = lastIndexOfToken;
            tokens.push(IERC20(_tokenA));
            lastIndexOfToken++;
        }
        if (tokenAddressesIndex[_tokenB] == 0) {
            tokenAddressesIndex[_tokenB] = lastIndexOfToken;
            tokens.push(IERC20(_tokenB));
            lastIndexOfToken++;
        }
    }

    function swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin
    ) public onlyTrader validateTokens(_tokenIn, _tokenOut) {
        address[] memory path;
        path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;

        IERC20(_tokenIn).approve(address(pancakeRouter), _amountIn);

        pancakeRouter.swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            path,
            address(this),
            block.timestamp
        );
    }

    function subscribe(uint256 _amount, address _copierAddress)
        external
        validateSubscribe(_amount, _copierAddress)
    {
        uint256 participations = _amount / getParticipationPrice();

        stableCoin.safeTransferFrom(msg.sender, address(this), _amount);
        participants[msg.sender] += participations;
        totalParticipations += participations;
    }

    function unsubscribe(uint256 _amount, address _copierAddress)
        external
        validateUnsubscribe(_amount, _copierAddress)
    {
        uint256 amount = participants[msg.sender] * getParticipationPrice();

        require(_amount <= amount, "Insufficient balance in pool.");

        stableCoin.safeTransfer(msg.sender, (amount / 100) * performanceFee);
        totalParticipations -= participants[msg.sender];
        participants[msg.sender] = 0;
    }

    /* ========== VIEWS ========== */

    function getPoolPerformance() public view returns (int256) {
        return
            int256(
                (getParticipationPrice() - initialParticipationPrice) /
                    initialParticipationPrice
            ) * 100;
    }

    function getParticipationPrice() private view returns (uint256) {
        uint256 cPoolValue;
        if (totalParticipations - traderParticipations == 0) {
            return initialParticipationPrice;
        } else {
            for (uint256 i = 0; i < tokens.length; i++) {
                uint256 balance = tokens[i].balanceOf(address(this));
                uint256 price = priceProvider.getPrice(address(tokens[i]));
                cPoolValue += balance * price;
            }
            return cPoolValue / totalParticipations;
        }
    }

    /* ========== MODIFIERS ========== */

    modifier validateSubscribe(uint256 _amount, address _copierAddress) {
        _validateIsNotTrader(_copierAddress);
        _validateAmountToSubscribe(_amount);
        _;
    }

    modifier validateUnsubscribe(uint256 _amount, address _copierAddress) {
        _validateIsNotTrader(_copierAddress);
        _;
    }

    modifier validateTokens(address _tokenA, address _tokenB) {
        require(
            internalBalances[_tokenA] >= 0,
            "Token not allowed to operate."
        );
        require(
            rulesContract.isTokenInWhiteList(_tokenB),
            "Token not allowed to operate."
        );
        _;
        _addTokens(_tokenA, _tokenB);
    }

    modifier onlyTrader() {
        _onlyTrader();
        _;
    }

    function _validateIsNotTrader(address _copierAddress) private view {
        require(
            !rulesContract.isTraderInWhiteList(_copierAddress),
            "A trader cannot enter a pool as a copier."
        );
    }

    function _validateAmountToSubscribe(uint256 _amount) private view {
        uint256 stakedTokens = stakingContract.balanceOf(msg.sender);
        require(
            stakedTokens >= (1000 * (10**18)),
            "Insufficient staked tokens."
        );
        (
            uint256 maxAllocationAvailable,
            uint256 maxPoolsAvailable
        ) = rulesContract.getMaxInvestmentAvailable(msg.sender);

        if (participants[msg.sender] == 0) {
            require(maxPoolsAvailable != 0, "You cannot invest in more pools.");
        }

        require(
            _amount <= maxAllocationAvailable,
            "Maximum amount per tier exceeded."
        );
    }

    function _onlyTrader() private view {
        require(
            msg.sender == trader,
            "Only the trader may perform this action"
        );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "./Address.sol";

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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICopyStaking {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function stakingToken() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface ICRules {
    function getMaxAllocationPerStaking(address copier)
        external
        view
        returns (uint256, uint256);

    function getMaxInvestmentAvailable(address _copier)
        external
        view
        returns (uint256 maxAllocationAvailable, uint256 maxPoolsAvailable);

    function isTokenInWhiteList(address _tokenAddress)
        external
        view
        returns (bool);

    function isTraderInWhiteList(address _traderAddress)
        external
        view
        returns (bool);

    function isPoolInWhiteList(address _poolAddress)
        external
        view
        returns (bool);

    function addPoolToWhiteList(address _poolAddress) external;
}

//SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.2;
interface IPancakeRouter{
  function factory() external pure returns (address);
  function WETH() external pure returns (address);

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

  function swapExactETHForTokens(
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external payable;

  function swapExactTokensForTokens(
      uint amountIn,
      uint amountOutMin,
      address[] calldata path,
      address to,
      uint deadline
  ) external returns (uint[] memory amounts);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IPriceProvider {
    function getPrice(address _tokenAddress) external view returns (uint256);
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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