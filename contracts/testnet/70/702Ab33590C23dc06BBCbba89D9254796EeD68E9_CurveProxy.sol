// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "../interfaces/IERC20WithPermit.sol";
import "../bridge/core/CurveProxyCore.sol";
import "../interfaces/IWhitelist.sol";

contract CurveProxy is Initializable, CurveProxyCore, ContextUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    string public versionRecipient;

    function initialize(
        address _forwarder,
        address _portal,
        address _synthesis,
        address _bridge,
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
        whitelist = _whitelist;
        curveBalancer = _curveBalancer;
        treasury = _treasury;
    }

    struct SynthParams {
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
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

    /**
     * @dev Mint EUSD local case (hub chain only)
     * @param _params MetaMintEUSD params
     * @param tokenParams token address, amount, token index
     */
    function addLiquidity3PoolMintEUSD(MetaMintEUSD calldata _params, ICurveProxy.TokenInput calldata tokenParams)
        external
    {
        require(IWhitelist(whitelist).tokenList(tokenParams.token), "Token must be whitelisted");

        _addLiquidityCrosschainPoolLocal(
            _params.addAtCrosschainPool,
            tokenParams,
            _params.expectedMinMintAmountC,
            _params.to
        );

        uint256 thisBalance = _addLiquidityHubPoolLocal(
            _params.addAtCrosschainPool,
            _params.lpIndex,
            _params.addAtHubPool,
            _params.expectedMinMintAmountH,
            _params.to
        );

        if (thisBalance != 0) {
            IERC20Upgradeable(lpToken[_params.addAtHubPool]).safeTransfer(_params.to, thisBalance);
        }
    }

    /**
     * @dev Mint EUSD from external chains
     * @param _params meta mint EUSD params
     * @param tokenParams token address, amount, token index
     * @param _txId transaction IDs
     */
    function transitSynthBatchAddLiquidity3PoolMintEUSD(
        MetaMintEUSD calldata _params,
        TokenInput calldata tokenParams,
        bytes32 _txId
    ) external onlyBridge {

        _addLiquidityCrosschainPool(
            _params.addAtCrosschainPool,
            tokenParams,
            _txId,
            _params.expectedMinMintAmountC,
            _params.to
        );

        uint256 thisBalance = _addLiquidityHubPool(
            _params.addAtCrosschainPool,
            _params.addAtHubPool,
            _params.expectedMinMintAmountH,
            _params.to,
            _params.lpIndex
        );

        if (thisBalance != 0) {
            IERC20Upgradeable(lpToken[_params.addAtHubPool]).safeTransfer(_params.to, thisBalance);
        }
    }

    /**
     * @dev Meta exchange local case (hub chain execution only)
     * @param _params meta exchange params
     * @param tokenParams token address, amount, token index
     */
    function metaExchange(MetaExchangeParams calldata _params, ICurveProxy.TokenInput calldata tokenParams) external {
        require(IWhitelist(whitelist).tokenList(tokenParams.token), "Token must be whitelisted");

        uint256 thisBalance;
        if (_params.add != address(0)) {
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
            thisBalance = _metaExchangeRemoveStage(_params.remove, _params.x, _params.expectedMinAmount, _params.to);

            if (thisBalance == 0) {
                return;
            }

        } else {
            if (
                _metaExchangeOneTypeLocal(
                    _params.i,
                    _params.j,
                    _params.exchange,
                    _params.expectedMinDy,
                    _params.to,
                    tokenParams.token,
                    tokenParams.amount
                )
            ) {
                return;
            }
            thisBalance = IERC20Upgradeable(pool[_params.remove].at(uint256(int256(_params.x)))).balanceOf(
                address(this)
            );
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

    function removeLiquidity(
        address remove,
        int128 x,
        uint256 expectedMinAmount,
        address to,
        ISynthesis.SynthParams calldata synthParams
    ) external {
        require(IWhitelist(whitelist).tokenList(lpToken[remove]), "Token must be whitelisted");
        require(
            IWhitelist(whitelist).checkDestinationToken(remove, x),
            "Destination token must be whitelisted"
        );
        address thisLpToken = lpToken[remove];
        IERC20Upgradeable(thisLpToken).approve(
            remove,
            IERC20Upgradeable(thisLpToken).balanceOf(address(this))
        );

        uint256 tokenAmount = IERC20Upgradeable(thisLpToken).balanceOf(address(this));
        require(tokenAmount > 0, "Wrong pool address");
        uint256 minAmount = IStableSwapPool(remove).calc_withdraw_one_coin(tokenAmount, x);

        //inconsistency check
        if (expectedMinAmount > minAmount) {
            IERC20Upgradeable(thisLpToken).safeTransfer(to, tokenAmount);
            return;
        }

        //remove liquidity
        IStableSwapPool(remove).remove_liquidity_one_coin(tokenAmount, x, 0);

        uint256 thisBalance = IERC20Upgradeable(pool[remove].at(uint256(int256(x)))).balanceOf(address(this));

        if (synthParams.chainId != 0) {
            IERC20Upgradeable(pool[remove].at(uint256(int256(x)))).approve(synthesis, thisBalance);
            ISynthesis(synthesis).burnSyntheticToken(
                pool[remove].at(uint256(int256(x))),
                thisBalance,
                address(this),
                to,
                synthParams
            );
        } else {
            IERC20Upgradeable(pool[remove].at(uint256(int256(x)))).safeTransfer(to, thisBalance);
        }
    }


    /**
     * @dev Performs a meta exchange on request from external chains
     * @param _params meta exchange params
     * @param tokenParams token address, amount, token index
     * @param _txId synth transaction IDs
     */
    function transitSynthBatchMetaExchange(
        MetaExchangeParams calldata _params,
        TokenInput calldata tokenParams,
        bytes32 _txId
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

    /**
     * @dev Redeem EUSD with unsynth operation (hub chain execution only)
     * @param _params meta redeem EUSD params
     * @param _receiveSide calldata recipient address for unsynth operation
     * @param _oppositeBridge opposite bridge contract address
     * @param _chainId opposite chain ID
     */
    function redeemEUSD(
        MetaRedeemEUSD calldata _params,
        address _receiveSide,
        address _oppositeBridge,
        uint256 _chainId
    ) external {
        {
            address hubLpToken = lpToken[_params.removeAtHubPool];

            //hub pool remove_liquidity_one_coin stage
            // IERC20Upgradeable(hubLpToken).safeTransferFrom(_msgSender(), address(this), _params.tokenAmountH);
            registerNewBalance(hubLpToken, _params.tokenAmountH);
            // IERC20Upgradeable(hubLpToken).approve(_params.removeAtHubPool, 0); //CurveV2 token support
            IERC20Upgradeable(hubLpToken).approve(_params.removeAtHubPool, _params.tokenAmountH);

            //inconsistency check
            uint256 hubLpTokenBalance = IERC20Upgradeable(hubLpToken).balanceOf(address(this));
            uint256 minAmountsH = IStableSwapPool(_params.removeAtHubPool).calc_withdraw_one_coin(
                _params.tokenAmountH,
                _params.y
            );

            IStableSwapPool(_params.removeAtHubPool).remove_liquidity_one_coin(_params.tokenAmountH, _params.y, 0);
        }
        {
            //crosschain pool remove_liquidity_one_coin stage
            uint256 hubCoinBalance = IERC20Upgradeable(pool[_params.removeAtHubPool].at(uint256(int256(_params.y))))
                .balanceOf(address(this));
            uint256 min_amounts_c = IStableSwapPool(_params.removeAtCrosschainPool).calc_withdraw_one_coin(
                hubCoinBalance,
                _params.x
            );

            // IERC20Upgradeable(pool[_params.removeAtCrosschainPool].at(uint256(int256(_params.x)))).approve(_params.removeAtCrosschainPool, 0); //CurveV2 token support
            IERC20Upgradeable(pool[_params.removeAtCrosschainPool].at(uint256(int256(_params.x)))).approve(
                _params.removeAtCrosschainPool,
                hubCoinBalance
            );
            IStableSwapPool(_params.removeAtCrosschainPool).remove_liquidity_one_coin(hubCoinBalance, _params.x, 0);

            //transfer outcome to the recipient (unsynth if mentioned)
            uint256 thisBalance = IERC20Upgradeable(pool[_params.removeAtCrosschainPool].at(uint256(int256(_params.x))))
                .balanceOf(address(this));
            if (_chainId != 0) {
                IERC20Upgradeable(pool[_params.removeAtCrosschainPool].at(uint256(int256(_params.x)))).approve(
                    synthesis,
                    thisBalance
                );
                ISynthesis.SynthParams memory synthParams = ISynthesis.SynthParams(
                    _receiveSide,
                    _oppositeBridge,
                    _chainId
                );
                ISynthesis(synthesis).burnSyntheticToken(
                    pool[_params.removeAtCrosschainPool].at(uint256(int256(_params.x))),
                    thisBalance,
                    address(this),
                    _params.to,
                    synthParams
                );
            } else {
                IERC20Upgradeable(pool[_params.removeAtCrosschainPool].at(uint256(int256(_params.x)))).safeTransfer(
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

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "../../amm_pool/IStableSwapPool.sol";
import "../../interfaces/ISynthesis.sol";
import "../../interfaces/ICurveBalancer.sol";
import "../../interfaces/ITreasury.sol";
import "../../interfaces/IWhitelist.sol";

interface IERC20Decimals {
    function decimals() external view returns (uint8);
}

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
            tokenParams.coinIndex,
            tokenParams.amount
        );

        bool result = ICurveBalancer(curveBalancer).addLiqBalancedOut(
            _add,
            size,
            tokenParams.coinIndex,
            tokenParams.amount,
            inconsistencyResult
        );

        if(!result && !inconsistencyResult) {
            inconsistencyTokenReturn(representation, tokenParams.amount, _to, _add);
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
            tokenParams.amount,
            tokenParams.coinIndex
        );
        
        bool result =  ICurveBalancer(curveBalancer).addLiqBalancedOut(
            _add,
            size,
            tokenParams.coinIndex,
            tokenParams.amount,
            inconsistencyResult
        );

        if(!result && !inconsistencyResult) {
            inconsistencyTokenReturn(tokenParams.token, tokenParams.amount, _to, _add);
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
            inconsistencyTokenReturn(lpToken[_addAtCrosschainPool], amountH[_lpIndex], _to, _addAtHubPool);
            return true;
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
            inconsistencyTokenReturn(
                pool[_exchange].at(uint256(int256(_i))),
                IERC20Upgradeable(pool[_exchange].at(uint256(int256(_i)))).balanceOf(address(this)),
                _to,
                _exchange
            );
            return (0,0);
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
            inconsistencyTokenReturn(_token, dx, _to, _exchange);
            return (0,0);
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
            inconsistencyTokenReturn(thisLpToken, tokenAmount, _to, _remove);
            return 0;
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
        uint256 _coinIndex,
        uint256 _amount
    ) view internal returns (bool) {
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
        uint256 _amount,
        uint256 _coinIndex
    ) view internal returns (bool) {
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

    function inconsistencyTokenReturn(
        address token,
        uint256 tokenAmount,
        address to,
        address _pool
    ) internal {
        if(IERC20Decimals(token).decimals() == 18){
            uint256 fee = IWhitelist(whitelist).stableFee();
            if(tokenAmount > fee || treasury.balance < IWhitelist(whitelist).nativeReturnAmount()) {
                uint256 amountToSend = tokenAmount - fee;
                IERC20Upgradeable(token).safeTransfer(treasury, fee);
                IERC20Upgradeable(token).safeTransfer(to, amountToSend);
                ITreasury(treasury).withdrawNative(IWhitelist(whitelist).nativeReturnAmount(), to);
                emit InconsistencyCallback(_pool, token, to, amountToSend);
            } else {
                IERC20Upgradeable(token).safeTransfer(to, tokenAmount);
                emit InconsistencyCallback(_pool, token, to, tokenAmount);
            }
        } else if (IERC20Decimals(token).decimals() == 6){
            uint256 fee = IWhitelist(whitelist).stableFee() / (10**12);
            if(tokenAmount > fee || treasury.balance < IWhitelist(whitelist).nativeReturnAmount()) {
                uint256 amountToSend = tokenAmount - fee;
                IERC20Upgradeable(token).safeTransfer(treasury, fee);
                IERC20Upgradeable(token).safeTransfer(to, amountToSend);
                ITreasury(treasury).withdrawNative(IWhitelist(whitelist).nativeReturnAmount(), to);
                emit InconsistencyCallback(_pool, token, to, amountToSend);
            } else {
                IERC20Upgradeable(token).safeTransfer(to, tokenAmount);
                emit InconsistencyCallback(_pool, token, to, tokenAmount);
            }
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

    function dexList(address dexAddr) external returns (bool);

    function dexFee(address dexAddr) external returns (uint256);
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

    function burnSyntheticTokenWithSwapWithUnwrap(
        address _stoken,
        uint256 _amount,
        address _from,
        address _to,
        SynthParams calldata _synthParams,
        IPortal.SynthParamsMetaSwap calldata _synthSwapParams
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
pragma solidity 0.8.10;

interface ICurveBalancer {

    function addLiqBalancedOut(
        address pool,
        uint256 slotsCount,
        uint256 incomePosition,
        uint256 amountIn,
        bool forceAdd
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
        address uniswapRouterV2;
        address uniswapFactoryV2;
        uint256 aggregationFee;
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

    function emergencyUnburnRequest(
        bytes32 txID,
        address receiveSide,
        address oppositeBridge,
        uint256 chainId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

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

    function synthBatchMetaExchangeWithSwapWithUnwrap(
        ICurveProxy.TokenInput calldata _tokenParams,
        SynthParamsMetaSwap memory _synthParams,
        ICurveProxy.MetaExchangeParams memory _metaParams
    ) external;
    
    //Deprecated: no use in current cases
    // function tokenSwapRequest(
    //     SynthParamsMetaSwap memory _synthParams,
    //     SynthParams memory _finalSynthParams,
    //     uint256 amount
    // ) external;

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
        address uniswapRouterV2;
        address uniswapFactoryV2;
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

    struct LiteSwap {
        address tokenToSwap;
        address to;
        uint256 amountOutMin;
        address tokenToReceive;
        uint256 deadline;
        address from;
        uint256 amount;
        uint256 fee;
        uint256 aggregationFee;
        address uniswapRouterV2;
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
        uint256 _amount,
        bool stable
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
        address uniswapRouterV2,
        IPortal.SynthParams calldata _finalSynthParams
    ) external;

    function tokenSwapLiteWithUnwrap(
        address tokenToSwap,
        address to,
        uint256 amountOutMin,
        address tokenToReceive,
        uint256 deadline,
        uint256 amount,
        uint256 aggregationFee,
        address uniswapRouterV2
    ) external;

    function tokenSwapWithUnwrap(
        IPortal.SynthParamsMetaSwap calldata _synthParams,
        uint256 _amount
    ) external;
}