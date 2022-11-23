// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "./IStableSwapPool.sol";
import "../interfaces/IERC20WithPermit.sol";
import "../interfaces/ISynthesis.sol";
import "../IUniswapV2Router01.sol";
import "../UniswapV2Library.sol";
import "../interfaces/IPortal.sol";
import "../interfaces/ICurveProxy.sol";
import "../bridge/core/CurveProxyCore.sol";
import "../interfaces/IWhitelist.sol";

contract CurveProxyV2 is Initializable, CurveProxyCore, ContextUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    string public versionRecipient;
    address public uniswapRouter;
    address public uniswapFactory;

    function initialize(
        address _forwarder,
        address _portal,
        address _synthesis,
        address _bridge,
        address _uniswapRouter,
        address _uniswapFactory,
        address _whitelist,
        address _curveBalancer,
        address _treasury
    ) public initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        portal = _portal;
        synthesis = _synthesis;
        bridge = _bridge;
        versionRecipient = "2.2.3";
        uniswapRouter = _uniswapRouter;
        uniswapFactory = _uniswapFactory;
        whitelist = _whitelist;
        curveBalancer = _curveBalancer;
        treasury = _treasury;
    }

    struct SynthParams {
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
    }

    struct MetaMintEUSDWithSwap {
        //crosschain pool params
        address addAtCrosschainPool;
        uint256 expectedMinMintAmountC;
        //incoming coin index for adding liq to hub pool
        uint256 lpIndex;
        //hub pool params
        address addAtHubPool;
        uint256 expectedMinMintAmountH;
        //recipient address
        address to;
        uint256 amountOutMin;
        address path;
        uint256 deadline;
    }

    struct MetaExchangeParams {
        //pool address
        address add;
        address exchange;
        address remove;
        //add liquidity params
        uint256 expectedMinMintAmount;
        //exchange params
        int128 i; //index value for the coin to send
        int128 j; //index value of the coin to receive
        uint256 expectedMinDy;
        //withdraw one coin params
        int128 x; //index value of the coin to withdraw
        uint256 expectedMinAmount;
        //transfer to
        address to;
        //unsynth params
        address chain2address;
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
    }

    modifier onlyBridge() {
        require(bridge == msg.sender);
        _;
    }
 
    /**
     * @dev Set the corresponding pool data to use proxy with
     * @param _pool pool address
     * @param _lpToken lp token address for the corresponding pool
     * @param _coins listed token addresses
     */
    function setPool(
        address _pool,
        address _lpToken,
        address[] calldata _coins
    ) public onlyOwner {
        for (uint256 i = 0; i < _coins.length; i++) {
            pool[_pool].add(_coins[i]);
        }
        lpToken[_pool] = _lpToken;
    }

    function inconsistencySwapCheck(
        uint256 _balance,
        address[] memory _path,
        uint256 _amountOutMin
    ) internal view returns (bool _result) {
        uint256[] memory amounts = UniswapV2Library.getAmountsOut(uniswapFactory, _balance, _path);
        _result = amounts[1] < _amountOutMin;
    }

    function inconsistencyAddLiquidityCheck(
        address _tokenA,
        address _tokenB,
        uint256 _amountADesired,
        uint256 _amountBDesired,
        uint256 _amountAMin,
        uint256 _amountBMin
    ) internal view returns (bool _result) {
        (uint256 reserveA, uint256 reserveB) = UniswapV2Library.getReserves(uniswapFactory, _tokenA, _tokenB);
        if (reserveA == 0 && reserveB == 0) {
            _result = true;
        } else {
            uint256 amountBOptimal = UniswapV2Library.quote(_amountADesired, reserveA, reserveB);
            if (amountBOptimal <= _amountBDesired) {
                _result = amountBOptimal < _amountBMin;
            } else {
                uint256 amountAOptimal = UniswapV2Library.quote(_amountBDesired, reserveB, reserveA);
                if (amountAOptimal <= _amountADesired) {
                    _result = amountAOptimal < _amountAMin;
                } else {
                    _result = false;
                }
            }
        }
    }

    function transitSynthBatchMetaExchangeWithSwap(
        ICurveProxy.MetaExchangeParams calldata _params,
        TokenInput calldata tokenParams,
        bytes32 _txId,
        IPortal.SynthParams calldata _finalSynthParams,
        IPortal.SynthParamsMetaSwap calldata _synthParams
    ) external onlyBridge {
        uint256 thisBalance;

        if (_params.add != address(0)) {

            _addLiquidityCrosschainPool(
                _params.add,
                tokenParams,
                _txId,
                _params.expectedMinMintAmount,
                _params.to
            );

            if (
                _metaExchangeSwapStage(
                    _params.add,
                    _params.exchange,
                    _params.i,
                    _params.j,
                    _params.expectedMinDy,
                    _params.to
                )
            ) {
                return;
            }

            thisBalance = _metaExchangeRemoveStage(_params.remove, _params.x, _params.expectedMinAmount, _params.to);

            if (thisBalance == 0) {
                return;
            }
        } else {
            if (
                _metaExchangeOneType(
                    _params.i,
                    _params.j,
                    _params.exchange,
                    _params.expectedMinDy,
                    _params.to,
                    tokenParams.token,
                    tokenParams.amount,
                    _txId
                )
            ) {
                return;
            }
            thisBalance = IERC20Upgradeable(pool[_params.remove].at(uint256(int256(_params.x)))).balanceOf(
                address(this)
            );
        }
        //transfer asset to the recipient (unsynth if mentioned)
        if (_params.chainId != 0) {
            IERC20Upgradeable(pool[_params.remove].at(uint256(int256(_params.x)))).approve(synthesis, thisBalance);
            ISynthesis.SynthParams memory synthParams = ISynthesis.SynthParams(
                _params.receiveSide,
                _params.oppositeBridge,
                _params.chainId
            );
            ISynthesis(synthesis).burnSyntheticTokenWithSwap(
                pool[_params.remove].at(uint256(int256(_params.x))),
                thisBalance,
                address(this),
                _params.to,
                synthParams,
                _synthParams,
                _finalSynthParams
            );
        } else {
            tokenSwap(_synthParams, _finalSynthParams, thisBalance);
        }
    }

    function tokenSwap(
        IPortal.SynthParamsMetaSwap calldata _synthParams,
        IPortal.SynthParams calldata _finalSynthParams,
        uint256 _amount
    ) public {
        address[] memory path = new address[](2);
        path[0] = _synthParams.swappedToken;
        path[1] = _synthParams.path;

        //inconsistency
        if (inconsistencySwapCheck(_amount, path, _synthParams.amountOutMin)) {
            IERC20Upgradeable(_synthParams.swappedToken).safeTransfer(_synthParams.to, _amount);
            emit InconsistencyCallback(uniswapRouter, _synthParams.swappedToken, _synthParams.to, _amount);
            return;
        }

        IERC20Upgradeable(_synthParams.swappedToken).approve(uniswapRouter, _amount);

        if (_finalSynthParams.chainId != 0) {
            IUniswapV2Router01(uniswapRouter).swapExactTokensForTokens(
                _amount,
                _synthParams.amountOutMin,
                path,
                address(this),
                _synthParams.deadline
            );
            uint256 swappedBalance = IERC20Upgradeable(_synthParams.path).balanceOf(address(this));
            IERC20Upgradeable(_synthParams.path).safeTransfer(portal, swappedBalance);
            IPortal(portal).synthesize(
                _synthParams.path,
                swappedBalance,
                _synthParams.from,
                _synthParams.to,
                _finalSynthParams
            );
        } else {
            IUniswapV2Router01(uniswapRouter).swapExactTokensForTokens(
                _amount,
                _synthParams.amountOutMin,
                path,
                _synthParams.to,
                _synthParams.deadline
            );
        }
    }

    function tokenSwapLite(
        address tokenToSwap,
        address to,
        uint256 amountOutMin,
        address tokenToReceive,
        uint256 deadline,
        address from,
        uint256 amount,
        uint256 fee,
        address worker,
        IPortal.SynthParams calldata _finalSynthParams
    ) public {
        require(IWhitelist(whitelist).tokenList(tokenToSwap), "Token must be whitelisted");
        require(IWhitelist(whitelist).tokenList(tokenToReceive), "Token must be whitelisted");

        address[] memory path = new address[](2);
        path[0] = tokenToSwap;
        path[1] = tokenToReceive;

        //inconsistency
        if (inconsistencySwapCheck(amount, path, amountOutMin)) {
            IERC20Upgradeable(tokenToSwap).safeTransfer(to, amount);
            emit InconsistencyCallback(uniswapRouter, tokenToSwap, to, amount);
            return;
        }

        IERC20Upgradeable(tokenToSwap).approve(uniswapRouter, amount);

        IUniswapV2Router01(uniswapRouter).swapExactTokensForTokens(amount, amountOutMin, path, address(this), deadline);

        if (fee != 0) {
            IERC20Upgradeable(tokenToReceive).safeTransfer(worker, fee);
        }

        uint256 swappedBalance = IERC20Upgradeable(tokenToReceive).balanceOf(address(this));
        if (_finalSynthParams.chainId != 0) {
            IERC20Upgradeable(tokenToReceive).safeTransfer(portal, swappedBalance);
            IPortal(portal).synthesize(tokenToReceive, swappedBalance, from, to, _finalSynthParams);
        } else {
            IERC20Upgradeable(tokenToReceive).safeTransfer(to, swappedBalance);
        }
    }

    function changeRouter(address _uniswapRouter) external onlyOwner {
        uniswapRouter = _uniswapRouter;
    }

    function changeFactory(address _uniswapFactory) external onlyOwner {
        uniswapFactory = _uniswapFactory;
    }

    function tokenSwapWithMetaExchange(
        ICurveProxy.tokenSwapWithMetaParams calldata _exchangeParams,
        ICurveProxy.MetaExchangeParams calldata _params,
        IPortal.SynthParams calldata _synthParams,
        ICurveProxy.FeeParams memory _feeParams
    ) external {
        require(IWhitelist(whitelist).tokenList(_exchangeParams.token), "Token must be whitelisted");
        require(IWhitelist(whitelist).tokenList(_exchangeParams.tokenToSwap), "Token must be whitelisted");

        address[] memory path = new address[](2);

        path[1] = _exchangeParams.token;
        path[0] = _exchangeParams.tokenToSwap;

        //inconsistency
        if (inconsistencySwapCheck(_exchangeParams.amountToSwap, path, _exchangeParams.amountOutMin)) {
            IERC20Upgradeable(_exchangeParams.tokenToSwap).safeTransfer(_params.to, _exchangeParams.amountToSwap);
            emit InconsistencyCallback(
                uniswapRouter,
                _exchangeParams.tokenToSwap,
                _params.to,
                _exchangeParams.amountToSwap
            );
            return;
        }

        IERC20Upgradeable(_exchangeParams.tokenToSwap).approve(uniswapRouter, _exchangeParams.amountToSwap);
        IUniswapV2Router01(uniswapRouter).swapExactTokensForTokens(
            _exchangeParams.amountToSwap,
            _exchangeParams.amountOutMin,
            path, // Received Token -> Desired Token
            address(this),
            _exchangeParams.deadline
        );
        if (_feeParams.fee != 0) {
            IERC20Upgradeable(_exchangeParams.token).safeTransfer(_feeParams.worker, _feeParams.fee);
        }
        uint256 swappedBalance = IERC20Upgradeable(_exchangeParams.token).balanceOf(address(this));
        ICurveProxy.TokenInput memory tokenParams = ICurveProxy.TokenInput(
            _exchangeParams.token,
            swappedBalance,
            _feeParams.coinIndex
        );
        if (_synthParams.chainId != 0) {
            IERC20Upgradeable(_exchangeParams.token).safeTransfer(portal, swappedBalance);
            IPortal(portal).synthBatchMetaExchange(_exchangeParams.from, _synthParams, _params, tokenParams);
        } else {

            _addLiquidityCrosschainPoolLocal(_params.add, tokenParams, _params.expectedMinMintAmount, _params.to);
        
            //meta-exchange stage
            if (
                _metaExchangeSwapStage(
                    _params.add,
                    _params.exchange,
                    _params.i,
                    _params.j,
                    _params.expectedMinDy,
                    _params.to
                )
            ) {
                return;
            }
            //transfer asset to the recipient (unsynth if mentioned)
            uint256 thisBalance = _metaExchangeRemoveStage(
                _params.remove,
                _params.x,
                _params.expectedMinAmount,
                _params.to
            );

            if (thisBalance == 0) {
                return;
            }

            if (_params.chainId != 0) {
                IERC20Upgradeable(pool[_params.remove].at(uint256(int256(_params.x)))).approve(synthesis, thisBalance);
                ISynthesis.SynthParams memory synthParams = ISynthesis.SynthParams(
                    _params.receiveSide,
                    _params.oppositeBridge,
                    _params.chainId
                );
                ISynthesis(synthesis).burnSyntheticToken(
                    pool[_params.remove].at(uint256(int256(_params.x))),
                    thisBalance,
                    address(this),
                    _params.to,
                    synthParams
                );
            } else {
                IERC20Upgradeable(pool[_params.remove].at(uint256(int256(_params.x)))).safeTransfer(
                    _params.to,
                    thisBalance
                );
            }
        }
    }

    function setWhitelist(address _whitelist) external onlyOwner {
        whitelist = _whitelist;
    }

    function setCurveBalancer(address _curveBalancer) external onlyOwner {
        curveBalancer = _curveBalancer;
    }

    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IStableSwapPool {
    function add_liquidity(uint256[2] memory amounts, uint256 min_mint_amount) external;

    function add_liquidity(uint256[3] memory amounts, uint256 min_mint_amount) external;

    function add_liquidity(uint256[4] memory amounts, uint256 min_mint_amount) external;

    function add_liquidity(uint256[5] memory amounts, uint256 min_mint_amount) external;

    function add_liquidity(uint256[6] memory amounts, uint256 min_mint_amount) external;

    function add_liquidity(uint256[7] memory amounts, uint256 min_mint_amount) external;

    function add_liquidity(uint256[8] memory amounts, uint256 min_mint_amount) external;

    function remove_liquidity(uint256 amounts, uint256[2] memory min_amounts) external;

    function remove_liquidity(uint256 amounts, uint256[3] memory min_amounts) external;

    function remove_liquidity(uint256 amounts, uint256[4] memory min_amounts) external;

    function remove_liquidity(uint256 amounts, uint256[5] memory min_amounts) external;

    function remove_liquidity(uint256 amounts, uint256[6] memory min_amounts) external;

    function remove_liquidity(uint256 amounts, uint256[7] memory min_amounts) external;

    function remove_liquidity(uint256 amounts, uint256[8] memory min_amounts) external;

    function remove_liquidity_imbalance(uint256[2] memory amounts, uint256 max_burn_amount) external;

    function remove_liquidity_imbalance(uint256[3] memory amounts, uint256 max_burn_amount) external;

    function remove_liquidity_imbalance(uint256[4] memory amounts, uint256 max_burn_amount) external;

    function remove_liquidity_imbalance(uint256[5] memory amounts, uint256 max_burn_amount) external;

    function remove_liquidity_imbalance(uint256[6] memory amounts, uint256 max_burn_amount) external;

    function remove_liquidity_imbalance(uint256[7] memory amounts, uint256 max_burn_amount) external;

    function remove_liquidity_imbalance(uint256[8] memory amounts, uint256 max_burn_amount) external;

    function remove_liquidity_one_coin(
        uint256 token_amount,
        int128 i,
        uint256 min_amount
    ) external;

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function calc_withdraw_one_coin(uint256 token_amount, int128 i) external view returns (uint256);

    function calc_token_amount(uint256[2] memory amounts, bool is_deposit) external view returns (uint256);

    function calc_token_amount(uint256[3] memory amounts, bool is_deposit) external view returns (uint256);

    function calc_token_amount(uint256[4] memory amounts, bool is_deposit) external view returns (uint256);

    function calc_token_amount(uint256[5] memory amounts, bool is_deposit) external view returns (uint256);

    function calc_token_amount(uint256[6] memory amounts, bool is_deposit) external view returns (uint256);

    function calc_token_amount(uint256[7] memory amounts, bool is_deposit) external view returns (uint256);

    function calc_token_amount(uint256[8] memory amounts, bool is_deposit) external view returns (uint256);

    function coins(uint256 i) external view returns (address);

    function balances(uint256 i) external view returns (uint256);

    function lp_token() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IERC20WithPermit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./IPortal.sol";
import "./ICurveProxy.sol";

interface ISynthesis {
    struct SynthParams {
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
    }

    struct PermitData {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
        bool approveMax;
    }

    function mintSyntheticToken(
        bytes32 txId,
        address tokenReal,
        uint256 amount,
        address to
    ) external;

    function burnSyntheticToken(
        address _stoken,
        uint256 _amount,
        address _from,
        address _to,
        SynthParams calldata _synthParams
    ) external returns (bytes32 txID);

    function getTxId() external returns (bytes32);

    function synthTransfer(
        address tokenSynth,
        uint256 amount,
        address from,
        address to,
        SynthParams calldata params
    ) external;

    function burnSyntheticTokenToSolana(
        address tokenSynth,
        address from,
        bytes32[] calldata pubkeys,
        uint256 amount,
        uint256 chainId
    ) external;

    function emergencyUnsyntesizeRequest(
        bytes32 txID,
        address receiveSide,
        address oppositeBridge,
        uint256 chainId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function emergencyUnsyntesizeRequestToSolana(
        address from,
        bytes32[] calldata pubkeys,
        bytes1 bumpSynthesizeRequest,
        uint256 chainId
    ) external;

    function burnSyntheticTokenWithSwap(
        address _stoken,
        uint256 _amount,
        address _from,
        address _to,
        SynthParams calldata _synthParams,
        IPortal.SynthParamsMetaSwap calldata _synthSwapParams,
        IPortal.SynthParams calldata _finalSynthParams
    ) external returns (bytes32 txID);

    function getRepresentation(bytes32 _rtoken) external view returns (address);

    function burnSyntheticTokenWithMetaExchange(
        IPortal.SynthesizeParams calldata _tokenParams,
        ICurveProxy.tokenSwapWithMetaParams calldata _exchangeParams,
        ICurveProxy.MetaExchangeParams calldata _params,
        IPortal.SynthParams calldata _finalSynthParams,
        IPortal.SynthParams calldata _synthParams,
        ICurveProxy.FeeParams memory _feeParams
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IUniswapV2Factory {
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

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal view returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(IUniswapV2Factory(factory).getPair(tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./ICurveProxy.sol";

interface IPortal {
    struct PermitData {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
        bool approveMax;
    }

    struct SynthParams {
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
    }

    struct MetaTokenParams {
        address token;
        uint256 amount;
        address from;
    }

    struct SynthParamsMetaSwap {
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
        address swapReceiveSide;
        address swapOppositeBridge;
        uint256 swapChainId;
        address swappedToken;
        address path;
        address to;
        uint256 amountOutMin;
        uint256 deadline;
        address from;
        uint256 initialChainId;
    }

    struct SynthesizeParams {
        address token;
        uint256 amount;
        address from;
        address to;
    }

    function synthesize(
        address token,
        uint256 amount,
        address from,
        address to,
        SynthParams calldata params
    ) external;

    // function synthesizeToSolana(
    //     address token,
    //     uint256 amount,
    //     address from,
    //     bytes32[] calldata pubkeys,
    //     bytes1 txStateBump,
    //     uint256 chainId
    // ) external;

    function emergencyUnburnRequest(
        bytes32 txID,
        address receiveSide,
        address oppositeBridge,
        uint256 chainId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    // function emergencyUnburnRequestToSolana(
    //     bytes32 txID,
    //     address from,
    //     bytes32[] calldata pubkeys,
    //     uint256 chainId
    // ) external;

    function synthBatchMetaExchange(
        address _from,
        SynthParams memory _synthParams,
        ICurveProxy.MetaExchangeParams memory _metaParams,
        ICurveProxy.TokenInput calldata tokenParams
    ) external;

    function synthBatchAddLiquidity3PoolMintEUSD(
        address _from,
        SynthParams memory _synthParams,
        ICurveProxy.MetaMintEUSD memory _metaParams,
        ICurveProxy.TokenInput calldata tokenParams
    ) external;

    function synthBatchMetaExchangeWithSwap(
        ICurveProxy.TokenInput calldata _tokenParams,
        SynthParamsMetaSwap memory _synthParams,
        SynthParams memory _finalSynthParams,
        ICurveProxy.MetaExchangeParams memory _metaParams
    ) external;

    function tokenSwapRequest(
        SynthParamsMetaSwap memory _synthParams,
        SynthParams memory _finalSynthParams,
        uint256 amount
    ) external;

    function synthesizeWithTokenSwap(
        ICurveProxy.tokenSwapWithMetaParams calldata _exchangeParams,
        ICurveProxy.MetaExchangeParams calldata _params,
        IPortal.SynthParams calldata _finalSynthParams,
        SynthesizeParams calldata _synthesizeTokenParams,
        SynthParams calldata _synthParams,
        uint256 coinIndex
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./IPortal.sol";
import "./ISynthesis.sol";

interface ICurveProxy {
    struct PermitData {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
        bool approveMax;
    }

    struct MetaMintEUSD {
        //crosschain pool params
        address addAtCrosschainPool;
        uint256 expectedMinMintAmountC;
        //incoming coin index for adding liq to hub pool
        uint256 lpIndex;
        //hub pool params
        address addAtHubPool;
        uint256 expectedMinMintAmountH;
        //recipient address
        address to;
    }

    struct MetaMintEUSDWithSwap {
        //crosschain pool params
        address addAtCrosschainPool;
        uint256 expectedMinMintAmountC;
        //incoming coin index for adding liq to hub pool
        uint256 lpIndex;
        //hub pool params
        address addAtHubPool;
        uint256 expectedMinMintAmountH;
        //recipient address
        address to;
        uint256 amountOutMin;
        address path;
        uint256 deadline;
    }

    struct MetaRedeemEUSD {
        //crosschain pool params
        address removeAtCrosschainPool;
        //outcome index
        int128 x;
        uint256 expectedMinAmountC;
        //hub pool params
        address removeAtHubPool;
        uint256 tokenAmountH;
        //lp index
        int128 y;
        uint256 expectedMinAmountH;
        //recipient address
        address to;
    }

    struct MetaExchangeParams {
        //pool address
        address add;
        address exchange;
        address remove;
        //add liquidity params
        uint256 expectedMinMintAmount;
        //exchange params
        int128 i; //index value for the coin to send
        int128 j; //index value of the coin to receive
        uint256 expectedMinDy;
        //withdraw one coin params
        int128 x; //index value of the coin to withdraw
        uint256 expectedMinAmount;
        //transfer to
        address to;
        //unsynth params
        address chain2address;
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
    }

    struct EmergencyUnsynthParams {
        address initialPortal;
        address initialBridge;
        uint256 initialChainID;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct MetaExchangeSwapParams {
        address swappedToken;
        address path;
        address to;
        uint256 amountOutMin;
        uint256 deadline;
    }

    struct MetaExchangeTokenParams {
        address synthToken;
        uint256 synthAmount;
        bytes32 txId;
    }

    struct tokenSwapWithMetaParams {
        address token;
        uint256 amountToSwap;
        address tokenToSwap;
        uint256 amountOutMin;
        uint256 deadline;
        address from;
    }

    struct TokenInput {
        address token;
        uint256 amount;
        uint256 coinIndex;
    }

    struct FeeParams {
        address worker;
        uint256 fee;
        uint256 coinIndex;
    }

    function addLiquidity3PoolMintEUSD(
        MetaMintEUSD calldata params,
        TokenInput calldata tokenParams
    ) external;

    function metaExchange(
        MetaExchangeParams calldata params,
        TokenInput calldata tokenParams
    ) external;

    function redeemEUSD(
        MetaRedeemEUSD calldata params,
        address receiveSide,
        address oppositeBridge,
        uint256 chainId
    ) external;

    function transitSynthBatchMetaExchange(
        MetaExchangeParams calldata _params,
        TokenInput calldata tokenParams,
        bytes32 _txId
    ) external;

    function tokenSwap(
        IPortal.SynthParamsMetaSwap calldata _synthParams,
        IPortal.SynthParams calldata _finalSynthParams,
        uint256 _amount
    ) external;

    function tokenSwapWithMetaExchange(
        ICurveProxy.tokenSwapWithMetaParams calldata _exchangeParams,
        ICurveProxy.MetaExchangeParams calldata _params,
        IPortal.SynthParams calldata _synthParams,
        ICurveProxy.FeeParams memory _feeParams
    ) external;

    function removeLiquidity(
        address remove,
        int128 x,
        uint256 expectedMinAmount,
        address to,
        ISynthesis.SynthParams calldata synthParams
    ) external;

    function tokenSwapLite(
        address tokenToSwap,
        address to,
        uint256 amountOutMin,
        address tokenToReceive,
        uint256 deadline,
        address from,
        uint256 amount,
        uint256 fee,
        address worker,
        IPortal.SynthParams calldata _finalSynthParams
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "../../amm_pool/IStableSwapPool.sol";
import "../../interfaces/ISynthesis.sol";
import "../../interfaces/ICurveBalancer.sol";
import "../../interfaces/ITreasury.sol";
import "../../interfaces/IWhitelist.sol";

abstract contract CurveProxyCore {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    address public portal;
    address public synthesis;
    address public bridge;
    address public whitelist;
    address public curveBalancer;
    address public treasury;

    mapping(address => EnumerableSetUpgradeable.AddressSet) internal pool;
    mapping(address => address) internal lpToken;

    struct TokenInput {
        address token;
        uint256 amount;
        uint256 coinIndex;
    }

    event InconsistencyCallback(address pool, address token, address to, uint256 amount);

    function registerNewBalance(address token, uint256 expectedAmount) internal view {
        require(
            IERC20Upgradeable(token).balanceOf(address(this)) >= expectedAmount,
            "CurveProxy: insufficient balance"
        );
    }

    function _addLiquidityCrosschainPool(
        address _add,
        TokenInput calldata tokenParams,
        bytes32 _txId,
        uint256 _expectedMin,
        address _to
    ) internal returns (bool) {
        uint256 size = pool[_add].length();
        address representation = ISynthesis(synthesis).getRepresentation(bytes32(uint256(uint160(tokenParams.token))));
        ISynthesis(synthesis).mintSyntheticToken(_txId, tokenParams.token, tokenParams.amount, address(this));
        IERC20Upgradeable(representation).approve(curveBalancer, tokenParams.amount);

        bool inconsistencyResult = _addLiquidityInconsistency(
            _add,
            _expectedMin,
            _to,
            tokenParams.coinIndex,
            tokenParams.amount,
            representation
        );

        bool result = ICurveBalancer(curveBalancer).addLiqBalancedOut(
            _add,
            size,
            tokenParams.coinIndex,
            tokenParams.amount
        );

        if(!result && !inconsistencyResult) {
            if(tokenParams.amount > IWhitelist(whitelist).stableFee()){
                uint256 amountToReturn = tokenParams.amount - IWhitelist(whitelist).stableFee();
                IERC20Upgradeable(representation).safeTransfer(treasury, IWhitelist(whitelist).stableFee());
                IERC20Upgradeable(representation).safeTransfer(_to, amountToReturn);
                ITreasury(treasury).withdrawNative(IWhitelist(whitelist).nativeReturnAmount(), _to);
                emit InconsistencyCallback(_add, representation, _to, amountToReturn);
            } else {
                IERC20Upgradeable(representation).safeTransfer(_to, tokenParams.amount);
                emit InconsistencyCallback(_add, representation, _to, tokenParams.amount);
            }
        }
    }

    function _addLiquidityCrosschainPoolLocal(
        address _add,
        ICurveProxy.TokenInput memory tokenParams,
        uint256 _expectedMin,
        address _to
    ) internal returns (bool) {
        uint256 size = pool[_add].length();
        IERC20Upgradeable(tokenParams.token).approve(curveBalancer, tokenParams.amount);
        registerNewBalance(tokenParams.token, tokenParams.amount);

        bool inconsistencyResult = _addLiquidityInconsistencyLocal(
            _add,
            _expectedMin,
            _to,
            tokenParams.token,
            tokenParams.amount,
            tokenParams.coinIndex
        );
        
        bool result =  ICurveBalancer(curveBalancer).addLiqBalancedOut(
            _add,
            size,
            tokenParams.coinIndex,
            tokenParams.amount
        );

        if(!result && !inconsistencyResult) {
            if(tokenParams.amount > IWhitelist(whitelist).stableFee()){
                uint256 amountToReturn = tokenParams.amount - IWhitelist(whitelist).stableFee();
                IERC20Upgradeable(tokenParams.token).safeTransfer(treasury, IWhitelist(whitelist).stableFee());
                IERC20Upgradeable(tokenParams.token).safeTransfer(_to, amountToReturn);
                ITreasury(treasury).withdrawNative(IWhitelist(whitelist).nativeReturnAmount(), _to);
                emit InconsistencyCallback(_add, tokenParams.token, _to, amountToReturn);
            } else {
                IERC20Upgradeable(tokenParams.token).safeTransfer(_to, tokenParams.amount);
                emit InconsistencyCallback(_add, tokenParams.token, _to, tokenParams.amount);
            }
        }
    }

    function _addLiquidityHubPoolLocal(
        address _addAtCrosschainPool,
        uint256 _lpIndex,
        address _addAtHubPool,
        uint256 _expectedMinMintAmountH,
        address _to
    ) internal returns (uint256) {
       IERC20Upgradeable(lpToken[_addAtCrosschainPool]).approve(
            _addAtHubPool,
            IERC20Upgradeable(lpToken[_addAtCrosschainPool]).balanceOf(address(this))
        );
        uint256[4] memory amountH;
        amountH[_lpIndex] = IERC20Upgradeable(lpToken[_addAtCrosschainPool]).balanceOf(address(this));

        if (_addLiquidityHubInconsistencyLocal(
            _addAtHubPool,
            _expectedMinMintAmountH,
            _to,
            _lpIndex,
            amountH,
            _addAtCrosschainPool
        )) {
            return 0;
        }

        //add liquidity
        IStableSwapPool(_addAtHubPool).add_liquidity(amountH, 0); 

        return(IERC20Upgradeable(lpToken[_addAtHubPool]).balanceOf(address(this)));
    }

    function _addLiquidityHubPool(
        address _addAtCrosschainPool,
        address _addAtHubPool,
        uint256 _expectedMinMintAmountH,
        address _to,
        uint256 _lpIndex
    ) internal returns (uint256) {
         IERC20Upgradeable(lpToken[_addAtCrosschainPool]).approve(
            _addAtHubPool,
            IERC20Upgradeable(lpToken[_addAtCrosschainPool]).balanceOf(address(this))
        );
        uint256[4] memory amountH;
        amountH[_lpIndex] = IERC20Upgradeable(lpToken[_addAtCrosschainPool]).balanceOf(address(this));

        if (_addLiquidityHubInconsistencyLocal(
            _addAtHubPool,
            _expectedMinMintAmountH,
            _to,
            _lpIndex,
            amountH,
            _addAtCrosschainPool
        )) {
            return 0;
        }

        //add liquidity
        IStableSwapPool(_addAtHubPool).add_liquidity(amountH, 0);

        return IERC20Upgradeable(lpToken[_addAtHubPool]).balanceOf(address(this));
    }

    function _metaExchangeSwapStage(
        address _add,
        address _exchange,
        int128 _i,
        int128 _j,
        uint256 _expectedMinDy,
        address _to
    ) internal returns (bool) {
        address lpLocalPool = lpToken[_add];

        IERC20Upgradeable(lpLocalPool).approve(
            _exchange,
            IERC20Upgradeable(lpLocalPool).balanceOf(address(this))
        );

        (uint256 dx, uint256 min_dy) = _exchangeInconsistency(_exchange, _i, _j, _expectedMinDy, _to, lpLocalPool);

        if(dx == 0 && min_dy == 0) {
            return true;
        }

        //perform an exhange
        IStableSwapPool(_exchange).exchange(_i, _j, dx, min_dy);
    }

    function _metaExchangeOneType(
        int128 _i,
        int128 _j,
        address _exchange,
        uint256 _expectedMinDy,
        address _to,
        address _synthToken,
        uint256 _synthAmount,
        bytes32 _txId
    ) internal returns (bool) {
        address representation;
        //synthesize stage
        representation = ISynthesis(synthesis).getRepresentation(bytes32(uint256(uint160(_synthToken))));
        ISynthesis(synthesis).mintSyntheticToken(_txId, _synthToken, _synthAmount, address(this));
        IERC20Upgradeable(representation).approve(_exchange, _synthAmount);

        (uint256 dx, uint256 min_dy) = _exchangeOneTypeInconsistency(_exchange, _i, _j, _expectedMinDy, _to, representation);

        if(dx == 0 && min_dy == 0) {
            return true;
        }

        IStableSwapPool(_exchange).exchange(_i, _j, dx, min_dy);
    }

    function _metaExchangeOneTypeLocal(
        int128 _i,
        int128 _j,
        address _exchange,
        uint256 _expectedMinDy,
        address _to,
        address _token,
        uint256 _amount
    ) internal returns (bool) {
        //synthesize stage
        registerNewBalance(_token, _amount);
        IERC20Upgradeable(_token).approve(_exchange, _amount);

        (uint256 dx, uint256 min_dy) = _exchangeOneTypeInconsistency(_exchange, _i, _j, _expectedMinDy, _to, _token);

        if(dx == 0 && min_dy == 0) {
            return true;
        }

        IStableSwapPool(_exchange).exchange(_i, _j, dx, min_dy);
    }

    function _addLiquidityHubInconsistencyLocal(
        address _addAtHubPool,
        uint256 _expectedMinMintAmountH,
        address _to,
        uint256 _lpIndex,
        uint256[4] memory amountH,
        address _addAtCrosschainPool
    ) internal returns (bool) {
        uint256 minMintAmountH = IStableSwapPool(_addAtHubPool).calc_token_amount(amountH, true);
        if (_expectedMinMintAmountH > minMintAmountH) {
            if(amountH[_lpIndex] > IWhitelist(whitelist).stableFee()) {
                uint256 amountToSend = amountH[_lpIndex] - IWhitelist(whitelist).stableFee();
                IERC20Upgradeable(lpToken[_addAtCrosschainPool]).safeTransfer(treasury, IWhitelist(whitelist).stableFee());
                IERC20Upgradeable(lpToken[_addAtCrosschainPool]).safeTransfer(_to, amountToSend);
                ITreasury(treasury).withdrawNative(IWhitelist(whitelist).nativeReturnAmount(), _to);
                emit InconsistencyCallback(
                    _addAtHubPool,
                    lpToken[_addAtCrosschainPool],
                    _to,
                    amountToSend
                );
                return true;
            } else {
                IERC20Upgradeable(lpToken[_addAtCrosschainPool]).safeTransfer(_to, amountH[_lpIndex]);
                emit InconsistencyCallback(
                    _addAtHubPool,
                    lpToken[_addAtCrosschainPool],
                    _to,
                    amountH[_lpIndex]
                );
                return true;
            }
        } else {
            return false;
        }
    }

    function _exchangeInconsistency(
        address _exchange,
        int128 _i,
        int128 _j,
        uint256 _expectedMinDy,
        address _to,
        address _token
    ) internal returns (uint256 dx, uint256 min_dy) {

        dx = IERC20Upgradeable(_token).balanceOf(address(this)); //amount to swap
        min_dy = IStableSwapPool(_exchange).get_dy(_i, _j, dx);

        if (_expectedMinDy > min_dy) {
            if(IERC20Upgradeable(pool[_exchange].at(uint256(int256(_i)))).balanceOf(address(this)) > IWhitelist(whitelist).stableFee()){
                uint256 amountToSend = IERC20Upgradeable(pool[_exchange].at(uint256(int256(_i)))).balanceOf(address(this)) - IWhitelist(whitelist).stableFee();
                
                IERC20Upgradeable(pool[_exchange].at(uint256(int256(_i)))).safeTransfer(
                    treasury,
                    IWhitelist(whitelist).stableFee()
                );
                IERC20Upgradeable(pool[_exchange].at(uint256(int256(_i)))).safeTransfer(
                    _to,
                    amountToSend
                );
                ITreasury(treasury).withdrawNative(IWhitelist(whitelist).nativeReturnAmount(), _to);
                emit InconsistencyCallback(
                    _exchange,
                    pool[_exchange].at(uint256(int256(_i))),
                    _to,
                    amountToSend
                );
                return (0,0);
            } else {
                uint256 amountToSend = IERC20Upgradeable(pool[_exchange].at(uint256(int256(_i)))).balanceOf(address(this));
                IERC20Upgradeable(pool[_exchange].at(uint256(int256(_i)))).safeTransfer(
                    _to,
                    amountToSend
                );
                emit InconsistencyCallback(
                    _exchange,
                    pool[_exchange].at(uint256(int256(_i))),
                    _to,
                    amountToSend
                );
                return (0,0);
            }
        }
    }

    function _exchangeOneTypeInconsistency(
        address _exchange,
        int128 _i,
        int128 _j,
        uint256 _expectedMinDy,
        address _to,
        address _token
    ) internal returns (uint256 dx, uint256 min_dy) {

        dx = IERC20Upgradeable(_token).balanceOf(address(this)); //amount to swap
        min_dy = IStableSwapPool(_exchange).get_dy(_i, _j, dx);

        if (_expectedMinDy > min_dy) {
            if(IERC20Upgradeable(_token).balanceOf(address(this)) > IWhitelist(whitelist).stableFee()){
                uint256 amountToSend = IERC20Upgradeable(_token).balanceOf(address(this)) - IWhitelist(whitelist).stableFee();

                IERC20Upgradeable(_token).safeTransfer(
                    treasury,
                    IWhitelist(whitelist).stableFee()
                );
                
                IERC20Upgradeable(_token).safeTransfer(
                    _to,
                    amountToSend
                );
                ITreasury(treasury).withdrawNative(IWhitelist(whitelist).nativeReturnAmount(), _to);
                emit InconsistencyCallback(
                    _exchange,
                    pool[_exchange].at(uint256(int256(_i))),
                    _to,
                    amountToSend
                );
                return (0,0);
            } else {
                uint256 amountToSend = IERC20Upgradeable(_token).balanceOf(address(this));
                IERC20Upgradeable(_token).safeTransfer(
                    _to,
                    amountToSend
                );
                emit InconsistencyCallback(
                    _exchange,
                    pool[_exchange].at(uint256(int256(_i))),
                    _to,
                    amountToSend
                );
                return (0,0);
            }
        }
    }

    function _metaExchangeRemoveStage(
        address _remove,
        int128 _x,
        uint256 _expectedMinAmount,
        address _to
    ) internal returns (uint256) {
        address thisLpToken = lpToken[_remove];
        IERC20Upgradeable(thisLpToken).approve(
            _remove,
            IERC20Upgradeable(thisLpToken).balanceOf(address(this))
        );

        uint256 tokenAmount = IERC20Upgradeable(thisLpToken).balanceOf(address(this));
        uint256 minAmount = IStableSwapPool(_remove).calc_withdraw_one_coin(tokenAmount, _x);

        //inconsistency check
        if (_expectedMinAmount > minAmount) {
            if(tokenAmount > IWhitelist(whitelist).stableFee()) {
                uint256 amountToSend = tokenAmount - IWhitelist(whitelist).stableFee();
                IERC20Upgradeable(thisLpToken).safeTransfer(treasury, IWhitelist(whitelist).stableFee());
                IERC20Upgradeable(thisLpToken).safeTransfer(_to, amountToSend);
                ITreasury(treasury).withdrawNative(IWhitelist(whitelist).nativeReturnAmount(), _to);
                emit InconsistencyCallback(_remove, thisLpToken, _to, amountToSend);
                return 0;
            } else {
                IERC20Upgradeable(thisLpToken).safeTransfer(_to, tokenAmount);
                emit InconsistencyCallback(_remove, thisLpToken, _to, tokenAmount);
                return 0;
            }
        }

        //remove liquidity
        IStableSwapPool(_remove).remove_liquidity_one_coin(tokenAmount, _x, 0);

        //transfer asset to the recipient (unsynth if mentioned)
        return IERC20Upgradeable(pool[_remove].at(uint256(int256(_x)))).balanceOf(
            address(this)
        );
    }

    function _addLiquidityInconsistency(
        address _add,
        uint256 _expectedMinMintAmount,
        address _to,
        uint256 _coinIndex,
        uint256 _amount,
        address _representation
    ) internal returns (bool) {
        uint256 size = pool[_add].length();
        uint256 minMintAmount;
        if(size == 2){
            uint256[2] memory amount;
            amount[_coinIndex] = _amount;
            minMintAmount = IStableSwapPool(_add).calc_token_amount(amount, true);
        }
        if(size == 3){
            uint256[3] memory amount;
            amount[_coinIndex] = _amount;
            minMintAmount = IStableSwapPool(_add).calc_token_amount(amount, true);
        }
        if(size == 4){
            uint256[4] memory amount;
            amount[_coinIndex] = _amount;
            minMintAmount = IStableSwapPool(_add).calc_token_amount(amount, true);
        }
        if(size == 5){
            uint256[5] memory amount;
            amount[_coinIndex] = _amount;
            minMintAmount = IStableSwapPool(_add).calc_token_amount(amount, true);
        }
        if(size == 6){
            uint256[6] memory amount;
            amount[_coinIndex] = _amount;
            minMintAmount = IStableSwapPool(_add).calc_token_amount(amount, true);
        }
        if(size == 7){
            uint256[7] memory amount;
            amount[_coinIndex] = _amount;
            minMintAmount = IStableSwapPool(_add).calc_token_amount(amount, true);
        }
        if(size == 8){
            uint256[8] memory amount;
            amount[_coinIndex] = _amount;
            minMintAmount = IStableSwapPool(_add).calc_token_amount(amount, true);
        }

        //inconsistency check
        if (_expectedMinMintAmount > minMintAmount) {
            return false;
        } else {
            return true;
        }
    }

    function _addLiquidityInconsistencyLocal(
        address _addAtCrosschainPool,
        uint256 _expectedMinMintAmountC,
        address _to,
        address _token,
        uint256 _amount,
        uint256 _coinIndex
    ) internal returns (bool) {
        uint256 size = pool[_addAtCrosschainPool].length();
        uint256 minMintAmountC;
        if(size == 2){
            uint256[2] memory amount;
            amount[_coinIndex] = _amount;
            minMintAmountC = IStableSwapPool(_addAtCrosschainPool).calc_token_amount(amount, true);
        }
        if(size == 3){
            uint256[3] memory amount;
            amount[_coinIndex] = _amount;
            minMintAmountC = IStableSwapPool(_addAtCrosschainPool).calc_token_amount(amount, true);
        }
        if(size == 4){
            uint256[4] memory amount;
            amount[_coinIndex] = _amount;
            minMintAmountC = IStableSwapPool(_addAtCrosschainPool).calc_token_amount(amount, true);
        }
        if(size == 5){
            uint256[5] memory amount;
            amount[_coinIndex] = _amount;
            minMintAmountC = IStableSwapPool(_addAtCrosschainPool).calc_token_amount(amount, true);
        }
        if(size == 6){
            uint256[6] memory amount;
            amount[_coinIndex] = _amount;
            minMintAmountC = IStableSwapPool(_addAtCrosschainPool).calc_token_amount(amount, true);
        }
        if(size == 7){
            uint256[7] memory amount;
            amount[_coinIndex] = _amount;
            minMintAmountC = IStableSwapPool(_addAtCrosschainPool).calc_token_amount(amount, true);
        }
        if(size == 8){
            uint256[8] memory amount;
            amount[_coinIndex] = _amount;
            minMintAmountC = IStableSwapPool(_addAtCrosschainPool).calc_token_amount(amount, true);
        }

        //inconsistency check
        if (_expectedMinMintAmountC > minMintAmountC) {
            return false;
        } else {
            return true;
        }
    }


}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IWhitelist {
    
    function tokenList(address token) external returns (bool);

    function poolTokensList(address pool) external returns (address[] calldata);

    function checkDestinationToken(address pool, int128 index) external view returns(bool);

    function nativeReturnAmount() external returns(uint256);

    function stableFee() external returns(uint256);

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
pragma solidity 0.8.10;

interface ICurveBalancer {

    function addLiqBalancedOut(
        address pool,
        uint256 slotsCount,
        uint256 incomePosition,
        uint256 amountIn
    ) external returns (bool success);

    function removeLiqBalancedOut(
        address pool,
        address lp,
        uint256 slotsCount,
        uint256 incomePosition,
        uint256 amountInLp
    ) external returns (bool success);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface ITreasury {
    
    function withdrawNative(uint256 msgValue, address to) external payable;
    
}