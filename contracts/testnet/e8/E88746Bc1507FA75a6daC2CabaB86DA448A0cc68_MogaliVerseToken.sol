/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;




interface IERC20 {
    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




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

interface IV2Factory {
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


interface IV2Pair {
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


    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;


    function initialize(address, address) external;
}


interface IV2Router01 {
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


interface IV2Router02 is IV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

    contract MogaliVerseToken is IERC20, Context {
   
    using AddressUpgradeable for address payable;
    mapping(address => uint256) private  _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) public allowedTransfer;
    mapping(address => bool) private _isBlacklisted;


    address[] private _excluded;


    bool public tradingEnabled=true;
    bool public swapEnabled=true;
    bool private swapping;


    //Anti Dump
    mapping(address => uint256) private _lastSell;
    bool public coolDownEnabled;
    uint256 public coolDownTime;


    IV2Router02 public V2Router;
    address public V2Pair;


    uint8 private constant _decimals = 18;
    uint256 private constant MAX = ~uint256(0);


    uint256 private _tTotal;
    uint256 private _rTotal;


    uint256 public swapTokensAtAmount;
    uint256 public maxBuyLimit;
    uint256 public maxSellLimit;
    uint256 public maxWalletLimit;


    uint256 public genesis_block;
    uint256 private deadline;
   
    address public deadWallet;
    address public marketingWallet;
    address public autoLiquidityReceiver;
   
    string private constant _name = "MOGALI VERSE TOKEN";
    string private constant _symbol = "MVT";

    address[] public owners;

    struct Taxes {
        uint256 rfi;
        uint256 marketing;
        uint256 liquidity;
    }


    Taxes private launchtax =Taxes(0, 0, 0);
    Taxes public taxes = Taxes(0, 0, 0);
    Taxes public sellTaxes = Taxes(2, 1, 2);


    struct TotFeesPaidStruct {
        uint256 rfi;
        uint256 marketing;
        uint256 liquidity;
    }


    TotFeesPaidStruct public totFeesPaid;


    struct valuesFromGetValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rRfi;
        uint256 rMarketing;
        uint256 rLiquidity;
       
        uint256 tTransferAmount;
        uint256 tRfi;
        uint256 tMarketing;
        uint256 tLiquidity;
    }
   
    modifier lockTheSwap() {
        swapping = true;
        _;
        swapping = false;
    }

        // Function EVENTS
    event setExcludeFromRewardTX(address TheFollowingAddressIsExcludedFromRewards);
    event setExcludeFromFeeTX(address TheFollowingAddressIsSetAssetExcludeFromFee);
    event setIncludeFromRewardTX(address TheFollowingAddressIsSetAsIncludeFromReward);
    event rescueAnyBEP20TokensTX(address tokenAddress,address toAddress,uint256 amount);
    event rescueBNBTX(uint256 amount);
    event updateAllowedTransferTX(bool state);
    event UpdateCooldownTX(bool state, uint256 time);
    event UpdateIsBlacklistedTX(bool state);
    event UpdateMarketingWalletTX(address newWallet);
    event UpdateMaxtxLimitTX(uint256 maxBuy, uint256 maxSell);
    event UpdateMaxWalletLimitTX(uint256 amount);
    event UpdateRouterAndPairTX(address newRouter, address newPair);
    event UpdateSwapTokenAtAmountTX(uint256 amount);
    event bulkIsBlacklistedTX(address[] accounts, bool state);
    event bulkupdateAllowedTransferTX(address[] accounts, bool state);
    event FeesChanged(bool status);

    
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }

   
   
function initialize(address routerAddress) public onlyMultiOwner{
       IV2Router02 _V2Router = IV2Router02(routerAddress);
         // Create a uniswap pair for this new token
        V2Pair = IV2Factory(_V2Router.factory())
            .createPair(address(this), _V2Router.WETH());

       // set the rest of the contract variables

        V2Router = _V2Router;
        autoLiquidityReceiver = msg.sender;
        coolDownTime = 60 seconds;
        coolDownEnabled = true;
        _tTotal = 90900000 * 10**_decimals;
        _rTotal = (MAX - (MAX % _tTotal));
        swapTokensAtAmount = 90_900 * 10**_decimals;
        maxBuyLimit = 9_09_000 * 10**_decimals;
        maxSellLimit = 9_09_000 * 10**_decimals;
        maxWalletLimit = 9_09_000 * 10**_decimals;
        genesis_block = block.number;
        deadline = 0;
        deadWallet = 0x000000000000000000000000000000000000dEaD;
        marketingWallet = 0x1C7F0c770E45030DA303728969821f800dd55476;
        
        _isExcludedFromFee[V2Pair] = true;
        _isExcludedFromFee[deadWallet] = true;

        owners=[0x686aC14acc91145a42dEa24DeD14335472aa7B9c,0x370c9120bc57c0F9c4FEda2074410292732a35c6,
        0x1a963858dEeF16cf6B3fD7dC9750A43abfd2938C,0xDb5d0B82028dD1a6C42B1c2143b20CDe39BFeC3C,0x712BD3565c68759E3a396906D7c68a3F18898074];

        for(uint i=0;i<owners.length;i++){
            address owner = owners[i];
            require(owner!=address(0),"invalid owner");
            require(!isOwner[owner],"owner is already there!");
            isOwner[owner]=true;
            _isExcludedFromFee[owner]=true;
            allowedTransfer[owner] = true;
        }


        _rOwned[_msgSender()] = _rTotal;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingWallet] = true;
       
        _isExcludedFromFee[deadWallet] = true;
        _isExcludedFromFee[0xD152f549545093347A162Dce210e7293f1452150] = true;
        _isExcludedFromFee[0x7ee058420e5937496F5a2096f04caA7721cF70cc] = true;  


        allowedTransfer[address(this)] = true;
        allowedTransfer[V2Pair] = true;
        allowedTransfer[marketingWallet] = true;
       
        allowedTransfer[0xD152f549545093347A162Dce210e7293f1452150] = true;
        allowedTransfer[0x7ee058420e5937496F5a2096f04caA7721cF70cc] = true;


       
        emit Transfer(address(0), _msgSender(), _tTotal);
    }





    //std ERC20:
    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }


    function decimals() public pure returns (uint8) {
        return _decimals;
    }


    //override ERC20:
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }


    function balanceOf(address account) public view override returns (uint256) {
        if(_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }


    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }
   
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool){
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }


    function transfer(address recipient, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, recipient, amount);
        return true;
    }


    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }


    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi) public view returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true, false, false);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true, false, false);
            return s.rTransferAmount;
        }
    }
 
    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }


    function excludeFromFee(uint256 _trnxId) public onlyMultiOwner {
        Transaction storage _transactions = transactions[_trnxId];
        require(_transactions.data != address(0),"invalid address");
        _isExcludedFromFee[_transactions.data] = true;
        executeTransaction(_trnxId, 1);
        emit setExcludeFromFeeTX(_transactions.data);
    }


    //@dev kept original RFI naming -> "reward" as in reflection
    function excludeFromReward(uint256 _trnxId) public onlyMultiOwner {
        Transaction storage _transactions = transactions[_trnxId];
        require(!_isExcluded[_transactions.data], "Account is already excluded");
        if (_rOwned[_transactions.data] > 0) {
            _tOwned[_transactions.data] = tokenFromReflection(_rOwned[_transactions.data]);
        }
        _isExcluded[_transactions.data] = true;
        _excluded.push(_transactions.data);
        executeTransaction(_trnxId, 2);
        emit setExcludeFromRewardTX(_transactions.data);
    }


    function includeInReward(uint256 _trnxId) external onlyMultiOwner {
        Transaction storage _transactions = transactions[_trnxId];
        require(_isExcluded[_transactions.data], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == _transactions.data) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _rOwned[_transactions.data] = _tOwned[_transactions.data]*(_getRate());
                _tOwned[_transactions.data] = 0;
                _isExcluded[_transactions.data] = false;
                _excluded.pop();
                executeTransaction(_trnxId, 3);
                emit setIncludeFromRewardTX(_transactions.data);
                break;
            }
        }
    }






    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }


    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal -= rRfi;
        totFeesPaid.rfi += tRfi;
    }


    function _takeLiquidity(uint256 rLiquidity, uint256 tLiquidity) private {
        totFeesPaid.liquidity += tLiquidity;


        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] += tLiquidity;
        }
        _rOwned[address(this)] += rLiquidity;
    }


    function _takeMarketing(uint256 rMarketing, uint256 tMarketing) private {
        totFeesPaid.marketing += tMarketing;


        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] += tMarketing;
        }
        _rOwned[address(this)] += rMarketing;
    }


    function _getValues(
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool useLaunchTax
    ) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, isSell, useLaunchTax);
        (
            to_return.rAmount,
            to_return.rTransferAmount,
            to_return.rRfi,
            to_return.rMarketing,
            to_return.rLiquidity
        ) = _getRValues1(to_return, tAmount, takeFee, _getRate());
       
       return to_return;
    }


    function _getTValues(
        uint256 tAmount,
        bool takeFee,
        bool isSell,
        bool useLaunchTax
    ) private view returns (valuesFromGetValues memory s) {
        if (!takeFee) {
            s.tTransferAmount = tAmount;
            return s;
        }
        Taxes memory temp;
        if (isSell && !useLaunchTax) temp = sellTaxes;
        else if (!useLaunchTax) temp = taxes;
        else temp = launchtax;


        s.tRfi = (tAmount * temp.rfi) / 100;
        s.tMarketing = (tAmount * temp.marketing) / 100;
        s.tLiquidity = (tAmount * temp.liquidity) / 100;
        s.tTransferAmount =
            tAmount -
            s.tRfi -
            s.tMarketing -
            s.tLiquidity;
        return s;
    }


    function _getRValues1(
        valuesFromGetValues memory s,
        uint256 tAmount,
        bool takeFee,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rRfi,
            uint256 rMarketing,
            uint256 rLiquidity
        )
    {
        rAmount = tAmount * currentRate;


        if (!takeFee) {
            return (rAmount, rAmount, 0, 0, 0);
        }


        rRfi = s.tRfi * currentRate;
        rMarketing = s.tMarketing * currentRate;
        rLiquidity = s.tLiquidity * currentRate;
       
        rTransferAmount =
            rAmount -
            rRfi -
            rMarketing -
            rLiquidity ;
        return (rAmount, rTransferAmount, rRfi, rMarketing, rLiquidity);
    }


   function _getRate() private view returns (uint256) {
       (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }


    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        address[] memory _excludedMem = _excluded;
        for (uint256 i = 0; i < _excludedMem.length; i++) {
            if (_rOwned[_excludedMem[i]] > rSupply || _tOwned[_excludedMem[i]] > tSupply)
                return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excludedMem[i]];
            tSupply = tSupply - _tOwned[_excludedMem[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }


    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            amount <= balanceOf(from),
            "You are trying to transfer more than your balance"
        );
   
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "You are a bot");


        if (from == V2Pair && !_isExcludedFromFee[to] && !swapping) {
            require(amount <= maxBuyLimit, "You are exceeding maxBuyLimit");
            require(
                balanceOf(to) + amount <= maxWalletLimit,
                "You are exceeding maxWalletLimit"
            );
        }


        if (
            from != V2Pair && !_isExcludedFromFee[to] && !_isExcludedFromFee[from] && !swapping
        ) {
            require(amount <= maxSellLimit, "You are exceeding maxSellLimit");
            if (to != V2Pair) {
                require(
                    balanceOf(to) + amount <= maxWalletLimit,
                    "You are exceeding maxWalletLimit"
                );
            }
            if (coolDownEnabled) {
                uint256 timePassed = block.timestamp - _lastSell[from];
                require(timePassed >= coolDownTime, "Cooldown enabled");
                _lastSell[from] = block.timestamp;
            }
        }


        bool canSwap = balanceOf(address(this)) >= swapTokensAtAmount;
        if (
            !swapping &&
            swapEnabled &&
            canSwap &&
            from != V2Pair &&
            !_isExcludedFromFee[from] &&
            !_isExcludedFromFee[to]
        ) {
            if (to == V2Pair) swapAndLiquify(swapTokensAtAmount, sellTaxes);
            else swapAndLiquify(swapTokensAtAmount, taxes);
        }
        bool takeFee = true;
        bool isSell = false;
        if (swapping || _isExcludedFromFee[from] || _isExcludedFromFee[to]) takeFee = false;
        if (to == V2Pair) isSell = true;


        _tokenTransfer(from, to, amount, takeFee, isSell);


    }


    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        bool useLaunchTax = !_isExcludedFromFee[sender] &&
            !_isExcludedFromFee[recipient] &&
            block.number <= genesis_block + deadline;


        valuesFromGetValues memory s = _getValues(tAmount, takeFee, isSell, useLaunchTax);


        if (_isExcluded[sender]) {
            //from excluded
            _tOwned[sender] = _tOwned[sender] - tAmount;
        }
        if (_isExcluded[recipient]) {
            //to excluded
            _tOwned[recipient] = _tOwned[recipient] + s.tTransferAmount;
        }


        _rOwned[sender] = _rOwned[sender] - s.rAmount;
        _rOwned[recipient] = _rOwned[recipient] + s.rTransferAmount;


        if (s.rRfi > 0 || s.tRfi > 0) _reflectRfi(s.rRfi, s.tRfi);
        if (s.rLiquidity > 0 || s.tLiquidity > 0) {
            _takeLiquidity(s.rLiquidity, s.tLiquidity);
            emit Transfer(
                sender,
                address(this),
                s.tLiquidity + s.tMarketing
            );
        }
        if (s.rMarketing > 0 || s.tMarketing > 0) _takeMarketing(s.rMarketing, s.tMarketing);
        emit Transfer(sender, recipient, s.tTransferAmount);
       
    }


    function swapAndLiquify(uint256 contractBalance, Taxes memory temp) private lockTheSwap {
        uint256 denominator = (temp.liquidity +
            temp.marketing
           ) * 2;
        uint256 tokensToAddLiquidityWith = (contractBalance * temp.liquidity) / denominator;
        uint256 toSwap = contractBalance - tokensToAddLiquidityWith;


        uint256 initialBalance = address(this).balance;


        swapTokensForBNB(toSwap);


        uint256 deltaBalance = address(this).balance - initialBalance;
        uint256 unitBalance = deltaBalance / (denominator - temp.liquidity);
        uint256 bnbToAddLiquidityWith = unitBalance * temp.liquidity;


        if (bnbToAddLiquidityWith > 0) {
            // Add liquidity to pancake
            addLiquidity(tokensToAddLiquidityWith, bnbToAddLiquidityWith);
        }
        uint256 marketingAmt = unitBalance * 2 * temp.marketing;
        if (marketingAmt > 0) {
            payable(marketingWallet).sendValue(marketingAmt);
        }
    }




    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(V2Router), tokenAmount);


        // add the liquidity
        V2Router.addLiquidityETH{ value: bnbAmount }(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable    
            autoLiquidityReceiver,
            block.timestamp
        );
    }


    function swapTokensForBNB(uint256 tokenAmount) private {
        // generate the pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = V2Router.WETH();


        _approve(address(this), address(V2Router), tokenAmount);


        // make the swap
        V2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }


    function updateMarketingWallet(address newWallet,uint256 _trnxId) external onlyMultiOwner {
        require(newWallet != address(0),"marketingwallet address can not be zero");
        marketingWallet = newWallet;
        executeTransaction(_trnxId, 9);
        emit UpdateMarketingWalletTX(newWallet);
    }




    function updateCooldown(bool state, uint256 time,uint256 _trnxId) external onlyMultiOwner {
        coolDownTime = time * 1 seconds;
        coolDownEnabled = state;
        executeTransaction(_trnxId, 7);
        emit UpdateCooldownTX(state,time);
    }


    function updateSwapTokensAtAmount(uint256 amount,uint256 _trnxId) external onlyMultiOwner {
       swapTokensAtAmount = amount * 10**_decimals;
       executeTransaction(_trnxId, 13);
       emit UpdateSwapTokenAtAmountTX(amount);
    }
 
   function updateIsBlacklisted(uint256 _trnxId, bool state) external onlyMultiOwner {
        Transaction storage _transactions = transactions[_trnxId];
        _isBlacklisted[_transactions.data] = state;
        executeTransaction(_trnxId, 8);
        emit UpdateIsBlacklistedTX(state);
    }


    function bulkIsBlacklisted(address[] memory accounts, bool state, uint256 _trnxId) external onlyMultiOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isBlacklisted[accounts[i]] = state;
        }
        executeTransaction(_trnxId, 14);
        emit bulkIsBlacklistedTX(accounts,state);
    }


    function updateAllowedTransfer(uint256 _trnxId , bool state) external onlyMultiOwner {
        Transaction storage _transactions = transactions[_trnxId];
        allowedTransfer[_transactions.data] = state;
        executeTransaction(_trnxId, 6);
        emit updateAllowedTransferTX(state);
    }


    function bulkupdateAllowedTransfer(address[] memory accounts, bool state,uint _trnxId) external onlyMultiOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            allowedTransfer[accounts[i]] = state;
        }
        executeTransaction(_trnxId, 15);
        emit bulkupdateAllowedTransferTX(accounts,state);
    }


    function updateMaxTxLimit(uint256 maxBuy, uint256 maxSell,uint _trnxId) external onlyMultiOwner {
        maxBuyLimit = maxBuy * 10**decimals();
        maxSellLimit = maxSell * 10**decimals();
        executeTransaction(_trnxId, 10);
        emit UpdateMaxtxLimitTX(maxBuy,maxSell);
    }


    function updateMaxWalletlimit(uint256 amount,uint _trnxId) external onlyMultiOwner {
        maxWalletLimit = amount * 10**decimals();
        executeTransaction(_trnxId, 11);
        emit UpdateMaxWalletLimitTX(amount);
    }


    function updateRouterAndPair(address newRouter, address newPair,uint _trnxId) external onlyMultiOwner {
        V2Router = IV2Router02(newRouter);
        require(newPair != address(0),"New pair address can not be zero");
        V2Pair = newPair;
        executeTransaction(_trnxId, 12);
        emit UpdateRouterAndPairTX(newRouter,newPair);
    }


    function setSellTaxes(bool state,uint _trnxId) public onlyMultiOwner {
        if(state==true){
        sellTaxes = Taxes(2, 1, 2);
        }
        else{
        sellTaxes = Taxes(0, 0, 0);  
        }
        executeTransaction(_trnxId, 16);
        emit FeesChanged(state);
    }


    function setTaxes(bool state,uint _trnxId) public onlyMultiOwner {
        if(state == true){
        taxes = Taxes(2, 1, 2);
        }
        else{
        taxes = Taxes(0, 0, 0);  
        }
        executeTransaction(_trnxId, 17);
        emit FeesChanged(state);
    }


    //Use this in case BNB are sent to the contract by mistake
    function rescueBNB(uint256 weiAmount,uint _trnxId) external onlyMultiOwner {
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).sendValue(weiAmount);
        executeTransaction(_trnxId, 5);
        emit rescueBNBTX(weiAmount);
    }


    function rescueAnyBEP20Tokens(
        address _tokenAddr,
        address _to,
        uint256 _amount,
        uint256 _trnxId
    ) public onlyMultiOwner {
        require(_tokenAddr != address(0), "tokenAddress can not be zero address");
        require(_to != address(0), "receiver can not be zero address");
        require(_amount > 0 , "amount should be more than zero address");
        IERC20(_tokenAddr).transfer(_to, _amount);
        executeTransaction(_trnxId, 4);
        emit rescueAnyBEP20TokensTX(_tokenAddr,_to,_amount);
    }
    receive() external payable {}


    //-------------------MULTISiGn-------------------------







    mapping(address=>bool) public isOwner;


    uint public walletPermission =3;
    Transaction[] public transactions;
    mapping(uint=> mapping(address=>bool)) public approved;


    struct Transaction{
     
        bool  isExecuted;
        uint methodID;
        address data;


        // 1 for Set excludeFromFee
        // 2 for Set excludeFromReward
        // 3 for Set includeFromReward
        // 4 for rescueAnyBEP20Tokens
        // 5 for rescueBNB
        // 6 for updateAllowedTransfer
        // 7 for UpdateCooldown
        // 8 for UpdateIsBlacklisted
        // 9 for UpdateMarketingWallet
        // 10 for UpdateMaxtxLimit
        // 11 for UpdateMaxWalletLimit
        // 12 for UpdateRouterAndPair
        // 13 for UpdateSwapTokenAtAmount
        // 14 for bulkIsBlacklisted
        // 15 for bulkupdateAllowedTransfer
        // 16 for setSellTaxes
        // 17 for setTaxes
    }




    //-----------------------EVENTS-------------------


    event assignTrnx(uint trnx);
    event Approve(address owner, uint trnxId);
    event Revoke(address owner, uint trnxId);
    event Execute(uint trnxId);




    //----------------------Modifier-------------------


    // YOU CAN REMOVE THIS OWNER MODIFIER IF YOU ALREADY USING OWNED LIB


    modifier onlyMultiOwner(){
        require(isOwner[msg.sender],"not an owner");
        _;
    }


    modifier trnxExists(uint _trnxId){
        require(_trnxId<transactions.length,"trnx does not exist");
        _;
    }


    modifier notApproved(uint _trnxId){


        require(!approved[_trnxId][msg.sender],"trnx has already done");
        _;
    }


    modifier notExecuted(uint _trnxId){
        Transaction storage _transactions = transactions[_trnxId];
        require(!_transactions.isExecuted,"trnx has already executed");
        _;
    }






 // ADD NEW TRANSACTION


    function newTransaction(uint _methodID, address _data) external onlyMultiOwner returns(uint){
        // check last transaction
        uint lastIndex;


        require(_methodID<=17 && _methodID>0,"invalid method id");
        if(transactions.length>0){


            lastIndex = transactions.length-1;
            require(transactions[lastIndex].isExecuted==true,"Please Execute Queue Transaction First");
        }
        transactions.push(Transaction({
            isExecuted:false,
            methodID:_methodID,
            data:_data
        }));


        approved[transactions.length-1][msg.sender]=true;
        emit Approve(msg.sender,transactions.length-1);


        emit assignTrnx(transactions.length-1);
        return transactions.length-1;
    }


    function setData(address newData,uint _trnxId) external trnxExists(_trnxId) onlyMultiOwner{
        Transaction storage _transactions = transactions[_trnxId];
        require(newData != address(0),"Data address can not be zero");
        _transactions.data = newData;
    }


    function getCurrentRunningTransactionId() external view returns(uint){


        if ( transactions.length>0){


            return transactions.length-1;
        }
        revert();
    }


    // APPROVE TRANSACTION BY ALL OWNER WALLET FOR EXECUTE CALL
    function approveTransaction(uint _trnxId)
        external onlyMultiOwner
        trnxExists(_trnxId)
        notApproved(_trnxId)
        notExecuted(_trnxId)
    {    
        approved[_trnxId][msg.sender]=true;
        emit Approve(msg.sender,_trnxId);
     }


    // GET APPROVAL COUNT OF TRANSACTION
    function _getAprrovalCount(uint _trnxId) public view returns(uint ){
        uint count;
        for(uint i=0; i<owners.length;i++){


            if (approved[_trnxId][owners[i]]){


                count+=1;
            }
        }
        return count;
    }


    // EXECUTE TRANSACTION
    function executeTransaction(uint _trnxId,uint _mID) internal trnxExists(_trnxId) notExecuted(_trnxId){


        require(_getAprrovalCount(_trnxId)>=walletPermission,"you don't have sufficient approval");
        Transaction storage _transactions = transactions[_trnxId];
        require(_transactions.methodID==_mID,"invalid Function call");
        _transactions.isExecuted = true;
        emit Execute(_trnxId);


    }
 
    // USE THIS FUNCTION WITHDRAW/REJECT TRANSACTION
    function revoke(uint _trnxId) external
        onlyMultiOwner
        trnxExists(_trnxId)
        notExecuted(_trnxId)
    {
        require(approved[_trnxId][msg.sender],"trnx has not been approve");
        approved[_trnxId][msg.sender]=false;
        emit Revoke(msg.sender,_trnxId);
    }


}