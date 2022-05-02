/**
 *Submitted for verification at BscScan.com on 2022-05-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

interface IERC20_full is IERC20 {
    function decimals() external view returns (uint8);
}

interface IWETH is IERC20 {
    function deposit() external payable;
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (IDEXFactory);

    function WETH() external pure returns (address);

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

interface ITokenConverter {
    function convertViaWETH(
        address _tokenA,
        address _tokenB,
        uint256 _amount
    ) external view returns (uint256);

    function DEFAULT_FACTORY() external view returns (IDEXFactory);
}

abstract contract Auth is Ownable {
    mapping(address => bool) public isAuthorized;

    constructor() {
        isAuthorized[msg.sender] = true;
    }

    function authorize(address adr) external onlyOwner {
        isAuthorized[adr] = true;
    }

    function unauthorize(address adr) external onlyOwner {
        isAuthorized[adr] = false;
    }

    function setAuthorizationMultiple(address[] memory adr, bool value) external onlyOwner {
        for (uint256 i = 0; i < adr.length; i++) {
            isAuthorized[adr[i]] = value;
        }
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        isAuthorized[owner()] = false;
        isAuthorized[newOwner] = true;
        super.transferOwnership(newOwner);
    }
}

contract DividendDistributor is Ownable {
    using SafeERC20 for IERC20;
    IWETH public WETH;
    IERC20 public dividendToken;
    IDEXRouter public router;
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
        uint256 index;
        uint256 lastClaimed;
    }
    mapping(address => Share) public shares;
    address[] shareholders;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public _ACCURACY_ = 1e36;
    uint256 public minPeriod = 30 minutes;
    uint256 public minDistribution;
    uint256 public shareThreshold = 0;

    uint256 public currentIndex;
    uint256 public maxGas = 500000;

    constructor(
        IDEXRouter _router,
        address _dividendToken,
        address _WETH
    ) {
        router = IDEXRouter(_router);
        dividendToken = IERC20(_dividendToken);
        minDistribution = 1 * (10**IERC20_full(_dividendToken).decimals());
        WETH = IWETH(_WETH);
    }

    function setRouter(IDEXRouter _router) external onlyOwner {
        router = _router;
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution,
        uint256 _shareThreshold
    ) external onlyOwner {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
        shareThreshold = _shareThreshold;
    }

    function setMaxGas(uint256 gas) external onlyOwner {
        maxGas = gas;
    }

    function setShare(address shareholder, uint256 amount) external onlyOwner {
        Share storage _S = shares[shareholder];
        if (_S.amount > 0) {
            _sendDividend(shareholder);
            if (amount < shareThreshold) _removeShareholder(shareholder);
        } else if (amount >= shareThreshold) _addShareholder(shareholder);
        totalShares -= _S.amount;
        totalShares += amount;
        _S.amount = amount;
        _S.totalExcluded = _getCumulativeDividends(shareholder);
    }

    function deposit() external payable onlyOwner {
        uint256 gotDividendToken;
        gotDividendToken = dividendToken.balanceOf(address(this));
        if (address(dividendToken) == address(WETH)) {
            WETH.deposit{value: msg.value}();
        } else {
            address[] memory path = new address[](2);
            path[0] = address(WETH);
            path[1] = address(dividendToken);
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
                0,
                path,
                address(this),
                block.timestamp
            );
        }
        gotDividendToken = dividendToken.balanceOf(address(this)) - gotDividendToken;

        totalDividends += gotDividendToken;
        dividendsPerShare += (_ACCURACY_ * gotDividendToken) / totalShares;
    }

    function sendDividends() external onlyOwner {
        uint256 shareholderCount = shareholders.length;
        if (shareholderCount == 0) return;

        uint256 gasUsed;
        uint256 gasLeft = gasleft();

        uint256 _currentIndex = currentIndex;
        for (uint256 i = 0; i < shareholderCount && gasUsed < maxGas; i++) {
            if (_currentIndex >= shareholderCount) _currentIndex = 0;
            address _shareholder = shareholders[_currentIndex];
            if (
                block.timestamp > shares[_shareholder].lastClaimed + minPeriod &&
                getUnpaidEarnings(_shareholder) > minDistribution
            ) {
                _sendDividend(_shareholder);
            }
            gasUsed += gasLeft - gasleft();
            gasLeft = gasleft();
            _currentIndex++;
        }
        currentIndex = _currentIndex;
    }

    function _getCumulativeDividends(address shareholder) internal view returns (uint256) {
        return (shares[shareholder].amount * dividendsPerShare) / _ACCURACY_;
    }

    function _sendDividend(address shareholder) internal {
        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount == 0) return;

        dividendToken.safeTransfer(shareholder, amount);
        totalDistributed += amount;
        shares[shareholder].totalRealised += amount;
        shares[shareholder].totalExcluded = _getCumulativeDividends(shareholder);
        shares[shareholder].lastClaimed = block.timestamp;
    }

    function _addShareholder(address shareholder) internal {
        shares[shareholder].index = shareholders.length;
        shareholders.push(shareholder);
    }

    function _removeShareholder(address shareholder) internal {
        _sendDividend(shareholder);
        shareholders[shares[shareholder].index] = shareholders[shareholders.length - 1];
        shares[shareholders[shareholders.length - 1]].index = shares[shareholder].index;
        delete shares[shareholder];
        shareholders.pop();
    }

    function claimDividend() external {
        _sendDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        uint256 _dividends = _getCumulativeDividends(shareholder);
        uint256 _excluded = shares[shareholder].totalExcluded;
        return _dividends > _excluded ? _dividends - _excluded : 0;
    }
}

contract Gigacoin is Auth {
    address WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address marketing;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    ITokenConverter public TOKEN_CONVERTER;

    string public constant name = 'Gigacoin';
    string public constant symbol = 'GIGACOIN';
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 1e9 ether;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isWalletLimitExempt;
    mapping(address => bool) public isDividendExempt;

    mapping(address => bool) public isPair;
    mapping(address => bool) public isRouter;

    uint256 public walletLimit = (totalSupply * 2) / 100; //2%

    IDEXRouter public router;
    address public pair;
    DividendDistributor public distributor;

    uint256 public launchedAt;
    bool public tradingOpen;

    struct FeeSettings {
        uint256 liquidity;
        uint256 dividends;
        uint256 total;
        uint256 marketingFee;
        uint256 _denominator;
    }
    struct SwapbackSettings {
        bool enabled;
        uint256 amount;
    }

    FeeSettings public fees =
        FeeSettings({liquidity: 200, dividends: 200, marketingFee:200, total: 600, _denominator: 10000});
    SwapbackSettings public swapback = SwapbackSettings({enabled: true, amount: totalSupply / 1000});

    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event AutoLiquify(uint256 amountETH, uint256 amountTKN);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(
        IDEXRouter _router,
        address _marketing,
        ITokenConverter _tokenConverter,
        address _dividendToken,
        IDEXRouter _dividendDistributorRouter
    ) {
        // BSC TOKEN DEFAULT PARAMS:
        // PANCAKE V2 ROUTER 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // BSC MAINNET USD (BUSD) 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
        // BSC MAINNET TOKEN_CONVERTER 0xe2bf8ef5E2b24441d5B2649A3Dc6D81afC1a9517
        // BSC MAINNET dividendToken (SSN) 0x89d453108bD94B497bBB4496729cd26f92Aba533
        // PANCAKE V1 ROUTER 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F

        // ETH TOKEN DEFAULT PARAMS
        // UNISWAP V2 ROUTER 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        // ETH MAINNET USD (USDT) 0xdAC17F958D2ee523a2206206994597C13D831ec7
        // ETH MAINNET TOKEN_CONVERTER 0xe2bf8ef5E2b24441d5B2649A3Dc6D81afC1a9517
        // ETH MAINNET dividendToken (WETH) 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
        // UNISWAP V2 ROUTER 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D

        router = _router;
        WETH = _router.WETH();
        pair = router.factory().createPair(WETH, address(this));
        marketing = _marketing; 
        TOKEN_CONVERTER = _tokenConverter;
        allowance[address(this)][address(router)] = ~uint256(0);

        distributor = new DividendDistributor(_dividendDistributorRouter, _dividendToken, WETH);

        isFeeExempt[DEAD] = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[address(router)] = true;

        isWalletLimitExempt[DEAD] = true;
        isWalletLimitExempt[msg.sender] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[address(router)] = true;

        isDividendExempt[DEAD] = true;
        isDividendExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(router)] = true;

        isDividendExempt[pair] = true;
        isWalletLimitExempt[pair] = true;

        isPair[pair] = true;
        isRouter[address(router)] = true;

        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    receive() external payable {}

    function getOwner() external view returns (address) {
        return owner();
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, ~uint256(0));
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        if (allowance[sender][msg.sender] != ~uint256(0)) allowance[sender][msg.sender] -= amount;
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {

        if (inSwap) return _basicTransfer(sender, recipient, amount);
        if (!tradingOpen) require(isAuthorized[sender], 'Trading not open yet');

        bool _isTradingOperation = isPair[sender] ||
            isPair[recipient] ||
            isPair[msg.sender] ||
            isRouter[sender] ||
            isRouter[recipient] ||
            isRouter[msg.sender];

        // Limit wallet balance
        require(balanceOf[recipient] + amount <= walletLimit, 'Recipient balance limit exceeded');

        // Sells accumulated fee for ETH and distribute
        if (swapback.enabled && (balanceOf[address(this)] >= swapback.amount) && !_isTradingOperation) {
            // (?swapback enabled?) Sells accumulated TKN fees for ETH
            _sellAndDistributeAccumulatedTKNFee();
        }

        // Launch at first liquidity
        if (launchedAt == 0 && isPair[recipient]) {
            require(balanceOf[sender] > 0, 'balance is zero');
            launchedAt = block.timestamp;
        }

        // Take fee; burn;
        // Exchange balances
        balanceOf[sender] -= amount;
        uint256 amountReceived = amount;
        if (!isFeeExempt[sender] && !isFeeExempt[recipient]) {
            if (fees.total > 0) {
                uint256 feeAmount = (amount * fees.total) / fees._denominator;
                balanceOf[address(this)] += feeAmount;
                emit Transfer(sender, address(this), feeAmount);
                amountReceived -= feeAmount;
            }

             if (fees.marketingFee > 0) {
                uint256 marketingAmount = (amount * fees.marketingFee) / fees._denominator;
                balanceOf[marketing] += marketingAmount;
                emit Transfer(sender, marketing, marketingAmount);
                amountReceived -= marketingAmount;
            }
        }
        balanceOf[recipient] += amountReceived;
        emit Transfer(sender, recipient, amountReceived);

        // Dividend tracker.
        if (!isDividendExempt[sender]) {
            distributor.setShare(sender, balanceOf[sender]);
        }
        if (!isDividendExempt[recipient]) {
            distributor.setShare(recipient, balanceOf[recipient]);
        }
        distributor.sendDividends();
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _sellAndDistributeAccumulatedTKNFee() internal swapping {
        // Swap the fee taken above to ETH and distribute to liquidity and dividends;
        // Add some liquidity

        uint256 halfLiquidityFee = fees.liquidity / 2;
        uint256 TKNtoLiquidity = (swapback.amount * halfLiquidityFee) / fees.total;
        uint256 amountToSwap = swapback.amount - TKNtoLiquidity;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 gotETH = address(this).balance;

        

        uint256 totalETHFee = fees.total - halfLiquidityFee;
        uint256 ETHtoLiquidity = (gotETH * halfLiquidityFee) / totalETHFee;
        uint256 amountBNB = address(this).balance - gotETH;
        uint256 amountBNBMarketing = (amountBNB * fees.marketingFee) / totalETHFee;

        (bool MarketingSuccess, /* bytes memory data */) = payable(marketing).call{value: amountBNBMarketing, gas: 30000}("");
        require(MarketingSuccess, "receiver rejected ETH transfer");

        if(TKNtoLiquidity > 0){
            router.addLiquidityETH{value: ETHtoLiquidity}(
                address(this),
                TKNtoLiquidity,
                0,
                0,
                marketing,
                block.timestamp
            );
            emit AutoLiquify(ETHtoLiquidity, TKNtoLiquidity);
        }
    }

    function getCirculatingSupply() public view returns (uint256) {
        return totalSupply - balanceOf[DEAD] - balanceOf[ZERO];
    }

    // SET EXEMPTS

    function setIsFeeExempt(address[] memory holders, bool exempt) public onlyOwner {
        for (uint256 i = 0; i < holders.length; i++) {
            isFeeExempt[holders[i]] = exempt;
        }
    }

    function setIsWalletLimitExempt(address[] memory holders, bool exempt) public onlyOwner {
        for (uint256 i = 0; i < holders.length; i++) {
            isWalletLimitExempt[holders[i]] = exempt;
        }
    }

    function setIsDividendExempt(address[] memory holders, bool exempt) public onlyOwner {
        for (uint256 i = 0; i < holders.length; i++) {
            require(holders[i] != address(this) && !(isPair[holders[i]] && !exempt), 'forbidden address'); // Forbid including back token and pairs
            isDividendExempt[holders[i]] = exempt;
            distributor.setShare(holders[i], exempt ? 0 : balanceOf[holders[i]]);
        }
    }

    function setFullExempt(address[] memory holders, bool exempt) public onlyOwner {
        setIsFeeExempt(holders, exempt);
        setIsWalletLimitExempt(holders, exempt);
        setIsDividendExempt(holders, exempt);
    }

    // SET IS PAIR/ROUTER

    function setIsPair(address[] memory addresses, bool _isPair) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            isPair[addresses[i]] = _isPair;
        }
        setIsDividendExempt(addresses, _isPair);
        setIsWalletLimitExempt(addresses, _isPair);
    }

    function setIsRouter(address[] memory addresses, bool _isRouter) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            isRouter[addresses[i]] = _isRouter;
        }
        setFullExempt(addresses, _isRouter);
    }

    // SET TOKEN SETTINGS

    function setWalletLimitSettings(uint256 amount) external onlyOwner {
        walletLimit = amount;
    }

    function setFees(
        uint256 _liquidity,
        uint256 _dividends,
        uint256 _marketingFee,
        uint256 _denominator
    ) external onlyOwner {
        fees = FeeSettings({
            liquidity: _liquidity,
            dividends: _dividends,
            marketingFee: _marketingFee,
            total: _liquidity + _dividends + _marketingFee,
            _denominator: _denominator
        });
        require(fees.total < fees._denominator / 4);
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        swapback.enabled = _enabled;
        swapback.amount = _amount;
    }

    function setTradingStatus(bool _status) external onlyOwner {
        tradingOpen = _status;
    }

    // SET DISTRIBUTOR SETTINGS

    function deployNewDistributor(IDEXRouter _router, address _dividendToken) external onlyOwner {
        distributor = new DividendDistributor(_router, _dividendToken, WETH);
    }

    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution,
        uint256 _shareThreshold
    ) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution, _shareThreshold);
    }

    function setDistributorGas(uint256 gas) external onlyOwner {
        require(gas <= 750000, 'Max 750000 gas allowed');
        distributor.setMaxGas(gas);
    }

    function setDistributorRouter(IDEXRouter _router) external onlyOwner {
        distributor.setRouter(_router);
    }
}