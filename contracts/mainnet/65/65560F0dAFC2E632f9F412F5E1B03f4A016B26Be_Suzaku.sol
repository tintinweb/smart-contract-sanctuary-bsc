/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: @openzeppelin/contracts/utils/Address.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: cryptonite.sol

/*
Suzaku $SUZ

https://suzakuofficial.com
https://twitter.com/SuzakuOfficial

*/


pragma solidity 0.8.16;




interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external view returns (address);

    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountDCMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (
            uint amountToken,
            uint amountDC,
            uint liquidity
        );

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
        uint amountDCMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountDC);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountDCMin,
        address to,
        uint deadline
    ) external returns (uint amountDC);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountDCMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountDC);

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

interface IDexPair {
    event Sync(uint112 reserve0, uint112 reserve1);
    function sync() external;
}

contract DividendDistributor {

    address _mainToken;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
    IERC20 TOKEN;
    address ETH;
    IDEXRouter router;

    address[] public shareholders;
    mapping (address => uint256) public shareholderIndexes;
    mapping (address => uint256) public shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1000000 * (10 ** 9);
    uint256 public gas = 500000;
    
    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _mainToken || _mainToken == address(0)); _;
    }

    constructor (address routerAddress, address _reflectionToken) {
        router = IDEXRouter(routerAddress);
        TOKEN = IERC20(_reflectionToken);
        ETH = router.WETH();
        _mainToken = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, uint256 _gas) external onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
        gas = _gas;
    }

    function setShare(address shareholder, uint256 amount) external onlyToken {
        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }
        
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }
        
        totalShares = (totalShares - shares[shareholder].amount) + amount;
        shares[shareholder].amount = amount;
        
        shares[shareholder].totalExcluded = getCumulativeDividends(amount);
    }

    function deposit() external payable {
        bool native = address(TOKEN) == address(0);
        uint256 balanceBefore = native ? address(this).balance : TOKEN.balanceOf(address(this));

        if (!native) {
            address[] memory path = new address[](2);
            path[0] = ETH;
            path[1] = address(TOKEN);

            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
                0,
                path,
                address(this),
                block.timestamp
            );
        }

        uint256 amount = native ? msg.value : TOKEN.balanceOf(address(this)) - balanceBefore;

        totalDividends = totalDividends + amount;
        dividendsPerShare = dividendsPerShare + (dividendsPerShareAccuracyFactor * amount) / totalShares;
    }

    function process() public onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
            
            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }
    
    function getClaimTime(address shareholder) external view returns (uint256) {
        if (shareholderClaims[shareholder] + minPeriod <= block.timestamp)
            return 0;
        else
            return (shareholderClaims[shareholder] + minPeriod) - block.timestamp;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }
        
        uint256 unpaidEarnings = getUnpaidEarnings(shareholder);
        if(unpaidEarnings > 0){
            uint256 previousExcluded = shares[shareholder].totalExcluded;

            totalDistributed += unpaidEarnings;
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised += unpaidEarnings;
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);

            if(address(TOKEN) == address(0)) {
                (bool sent, ) = shareholder.call{value: unpaidEarnings}("");
                if (!sent) {
                    totalDistributed -= unpaidEarnings;
                    shares[shareholder].totalRealised -= unpaidEarnings;
                    shares[shareholder].totalExcluded = previousExcluded;
                }
            } else {
                TOKEN.transfer(shareholder, unpaidEarnings);
            }
        }
    }

    function claimDividend(address shareholder) external onlyToken {
        distributeDividend(shareholder);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends - shareholderTotalExcluded;
    }
    
    function getPaidDividends(address shareholder) external view returns (uint256) {
        return shares[shareholder].totalRealised;
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        if(share == 0){ return 0; }
        return (share * dividendsPerShare) / dividendsPerShareAccuracyFactor;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function countShareholders() external view returns (uint256) {
        return shareholders.length;
    }
    
    function getTotalRewarded() external view returns (uint256) {
        return totalDistributed;
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

interface IAntiSnipe {
  function setTokenOwner(address owner, address pair) external;

  function onPreTransferCheck(
    address sender,
    address from,
    address to,
    uint256 amount
  ) external returns (bool checked);
}

contract Suzaku is IERC20, Ownable {
    using Address for address;
    
    address ETH;

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    string constant _name = "Suzaku";
    string constant _symbol = "SUZ";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 100_000_000 * (10 ** _decimals);
    uint256 _maxBuyTxAmount = (_totalSupply * 1) / 100;
    uint256 _maxSellTxAmount = (_totalSupply * 1) / 100;
    uint256 _maxWalletSize = (_totalSupply * 2) / 100;
    uint256 minimumBalance = 1;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) liquidityCreator;

    mapping (address => bool) public whitelist;
    bool public whitelistEnabled = true;

    uint256 marketingFee = 300;
    uint256 marketingSellFee = 300;
    uint256 rewardsFee = 100;
    uint256 rewardsSellFee = 100;
    uint256 liquidityFee = 100;
    uint256 liquiditySellFee = 100;
    uint256 teamFee = 0;
    uint256 teamSellFee = 0;
    uint256 totalBuyFee = marketingFee + liquidityFee + teamFee + rewardsFee;
    uint256 totalSellFee = marketingSellFee + liquiditySellFee + teamSellFee + rewardsSellFee;
    uint256 feeDenominator = 10000;

    address public liquidityFeeReceiver = DEAD;
    address payable teamFeeReceiver;
    address payable marketingFeeReceiver;

    IDEXRouter public router;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    mapping (address => bool) liquidityPools;

    address public pair;

    uint256 public launchedAt;
    uint256 public launchedTime;
    uint256 public deadBlocks;
    bool startBullRun = false;

    IAntiSnipe public antisnipe;
    bool public protectionEnabled = true;
    bool public protectionDisabled = false;

    DividendDistributor public rewards;
    bool public autoProcess = true;

    mapping (address => address) public stakedIn;

    bool public swapEnabled = false;
    uint256 public swapThreshold = _totalSupply / 400;
    uint256 public swapMinimum = _totalSupply / 10000;
    uint256 public maxSwapPercent = 75;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor (address _newOwner, address _marketing, address _team) {
        isFeeExempt[_newOwner] = true;
        liquidityCreator[_newOwner] = true;
        _allowances[_newOwner][routerAddress] = type(uint256).max;
        _allowances[address(this)][routerAddress] = type(uint256).max;

        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[_newOwner] = true;
        isTxLimitExempt[routerAddress] = true;

        isDividendExempt[_newOwner] = true;
        isDividendExempt[routerAddress] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        isDividendExempt[address(0)] = true;

        uint256 half = _totalSupply * 50 / 100;
        _balances[_newOwner] = half;
        _balances[DEAD] = _totalSupply - half;

        rewards = new DividendDistributor(routerAddress, address(0));

        marketingFeeReceiver = payable(_marketing);
        isFeeExempt[_marketing] = true;
        isTxLimitExempt[_marketing] = true;
        teamFeeReceiver = payable(_team);

        emit Transfer(address(0), _newOwner, half);
        emit Transfer(address(0), DEAD, _totalSupply - half);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply - balanceOf(DEAD); }
    function decimals() external pure returns (uint8) { return _decimals; }
    function symbol() external pure returns (string memory) { return _symbol; }
    function name() external pure returns (string memory) { return _name; }
    function getOwner() external view returns (address) { return owner(); }
    function maxBuyTxTokens() external view returns (uint256) { return _maxBuyTxAmount / (10 ** _decimals); }
    function maxSellTxTokens() external view returns (uint256) { return _maxSellTxAmount / (10 ** _decimals); }
    function maxWalletTokens() external view returns (uint256) { return _maxWalletSize / (10 ** _decimals); }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function setProtectionEnabled(bool _protect) external onlyOwner {
        if (_protect)
            require(!protectionDisabled);
        protectionEnabled = _protect;
    }
    
    function setProtection(address _protection, bool _call) external onlyOwner {
        if (_protection != address(antisnipe)){
            require(!protectionDisabled);
            antisnipe = IAntiSnipe(_protection);
        }
        if (_call)
            antisnipe.setTokenOwner(address(this), pair);
    }
    
    function disableProtection() external onlyOwner {
        protectionDisabled = true;
    }
    
    function airdrop(address[] memory addresses, uint256[] memory amounts) external onlyOwner {
        require(addresses.length > 0 && addresses.length == amounts.length, "Length mismatch");
        address from = msg.sender;

        for (uint i = 0; i < addresses.length; i++) {
            if(!liquidityPools[addresses[i]] && !liquidityCreator[addresses[i]]) {
                _transferFrom(from, addresses[i], amounts[i] * (10 ** _decimals));
            }
        }
    }
    
    function launch(uint256 _deadBlocks, bool _whitelistMode) external payable onlyOwner {
        require(!startBullRun && _deadBlocks < 7);
        require(msg.value > 0, "Insufficient funds");
        uint256 toLP = msg.value;

        router = IDEXRouter(routerAddress);
        ETH = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(ETH, address(this));
        liquidityPools[pair] = true;
        isDividendExempt[pair] = true;

        isFeeExempt[address(this)] = true;
        liquidityCreator[address(this)] = true;

        router.addLiquidityETH{value: toLP}(address(this),balanceOf(address(this)),0,0,msg.sender,block.timestamp);

        deadBlocks = _whitelistMode ? 0 : _deadBlocks;
        startBullRun = !_whitelistMode;
        whitelistEnabled = _whitelistMode;
        launchedAt = block.number;
        launchedTime = block.timestamp;
    }

    function endWhitelist(uint256 _deadBlocks) external onlyOwner {
        require(!startBullRun && _deadBlocks < 7);
        deadBlocks = _deadBlocks;
        startBullRun = true;
        whitelistEnabled = false;
        launchedAt = block.number;
    }

    function extractTokens() external onlyOwner {
        require(!startBullRun);
        _transferFrom(address(this), msg.sender, balanceOf(address(this)));
    }

    function setAutoProcess(bool _enabled) external onlyOwner {
        autoProcess = _enabled;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(amount > 0, "No tokens sent");
        require(sender != address(0) && recipient != address(0), "invalid transfer address");
        require(_balances[sender] >= amount, "Insufficient balance");
        if(!launched() && liquidityPools[recipient]){ require(liquidityCreator[sender], "Liquidity not added yet."); launch(); }
        if(!startBullRun){ require(liquidityCreator[sender] || liquidityCreator[recipient] || whitelist[recipient], "Trading not open yet."); }

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient])
            checkTxLimit(sender, amount);
        
        if (!liquidityPools[recipient] && recipient != DEAD) {
            if (!isTxLimitExempt[recipient]) {
                checkWalletLimit(recipient, amount);
            }
        }

        _balances[sender] -= amount;

        uint256 amountReceived = shouldTakeFee(sender) && shouldTakeFee(recipient) ? takeFee(recipient, sender, amount) : amount;
        
        if(shouldSwapBack(sender, recipient)){ swapBack(amount); }
        
        _balances[recipient] += amountReceived;

        if(!liquidityPools[sender] && shouldTakeFee(sender) && minimumBalance > 0 && _balances[sender] == 0) {
            _balances[sender] = minimumBalance;
            _balances[recipient] -= minimumBalance;
        }

        if (startBullRun && protectionEnabled && shouldTakeFee(sender))
            antisnipe.onPreTransferCheck(msg.sender, sender, recipient, amount);

        if(!isDividendExempt[sender]){ try rewards.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try rewards.setShare(recipient, _balances[recipient]) {} catch {} }

        if(autoProcess) { try rewards.process() {} catch {} }

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() internal {
        launchedAt = block.number;
        launchedTime = block.timestamp;
        swapEnabled = true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function checkWalletLimit(address recipient, uint256 amount) internal view {
        uint256 walletLimit = _maxWalletSize;
        require(_balances[recipient] + amount <= walletLimit, "Transfer amount exceeds the bag size.");
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= (liquidityPools[sender] ? _maxBuyTxAmount : _maxSellTxAmount), "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getTotalFee(bool selling) public view returns (uint256) {
        if(launchedAt + deadBlocks > block.number){ return feeDenominator - 1; }
        if (selling) return totalSellFee;
        return totalBuyFee;
    }

    function takeFee(address recipient, address sender, uint256 amount) internal returns (uint256) {
        bool selling = liquidityPools[recipient];
        uint256 feeAmount = (amount * getTotalFee(selling)) / feeDenominator;
        
        _balances[address(this)] += feeAmount;
        emit Transfer(sender, address(this), feeAmount);
    
        return amount - feeAmount;
    }

    function shouldSwapBack(address sender, address recipient) internal view returns (bool) {
        return !liquidityPools[sender]
        && !inSwap
        && swapEnabled
        && liquidityPools[recipient]
        && !isFeeExempt[sender]
        && _balances[address(this)] >= swapMinimum 
        && totalBuyFee + totalSellFee > 0;
    }

    function swapBack(uint256 amount) internal swapping {
        uint256 totalFee = totalBuyFee + totalSellFee;
        uint256 amountToSwap = amount - (amount * maxSwapPercent / 100) <= swapThreshold ? amount * maxSwapPercent / 100 : swapThreshold;
        if (_balances[address(this)] < amountToSwap) amountToSwap = _balances[address(this)];
        
        uint256 amountToLiquify = ((amountToSwap * (liquidityFee + liquiditySellFee)) / totalFee) / 2;
        amountToSwap -= amountToLiquify;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ETH;
        
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 balance = address(this).balance;
        uint256 fees = totalFee - ((liquidityFee + liquiditySellFee) / 2);

        uint256 amountLiquidity = (balance * (liquidityFee + liquiditySellFee)) / fees / 2;
        uint256 amountTeam = (balance * (teamFee + teamSellFee)) / fees;
        uint256 amountRewards = (balance * (rewardsFee + rewardsSellFee)) / fees;
        uint256 amountMarketing = balance - (amountLiquidity + amountTeam + amountRewards);
        
        if (amountTeam > 0) {
            (bool sentTeam, ) = teamFeeReceiver.call{value: amountTeam}("");
            require(sentTeam, "Failed to transfer to team");
        }

        if (amountMarketing > 0) {
            (bool sentMk, ) = marketingFeeReceiver.call{value: amountMarketing}("");
            require(sentMk, "Failed to transfer to marketing");
        }

        if (amountRewards > 0)
            try rewards.deposit{value: amountRewards}() {} catch {}

        if(amountLiquidity > 0){
            router.addLiquidityETH{value: amountLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                liquidityFeeReceiver,
                block.timestamp
            );
        }

        emit FundsDistributed(amountLiquidity, amountMarketing, amountTeam);
    }

    function updateRewards(address _contract) external onlyOwner {
        rewards = DividendDistributor(_contract);
        isFeeExempt[_contract] = true;
        isTxLimitExempt[_contract] = true;
        emit UpdatedSettings('rewards Updated', [Log(toString(abi.encodePacked(_contract)), 1), Log('', 0), Log('', 0)]);
    }
    
    function addLiquidityPool(address lp, bool isPool) external onlyOwner {
        require(lp != pair, "Can't alter current liquidity pair");
        liquidityPools[lp] = isPool;
        isDividendExempt[lp] = true;
        emit UpdatedSettings(isPool ? 'Liquidity Pool Enabled' : 'Liquidity Pool Disabled', [Log(toString(abi.encodePacked(lp)), 1), Log('', 0), Log('', 0)]);
    }
    
    function switchRouter(address newRouter) external onlyOwner {
        router = IDEXRouter(newRouter);
        ETH = router.WETH();
        isTxLimitExempt[newRouter] = true;
        emit UpdatedSettings('Exchange Router Updated', [Log(concatenate('New Router: ',toString(abi.encodePacked(newRouter))), 1),Log('', 0), Log('', 0)]);
    }
    
    function setLiquidityCreator(address preSaleAddress) external onlyOwner {
        liquidityCreator[preSaleAddress] = true;
        isTxLimitExempt[preSaleAddress] = true;
        isDividendExempt[preSaleAddress] = true;
        isFeeExempt[preSaleAddress] = true;
        emit UpdatedSettings('Presale Setup', [Log(concatenate('Presale Address: ',toString(abi.encodePacked(preSaleAddress))), 1),Log('', 0), Log('', 0)]);
    }
    
    function getPoolStatistics() external view returns (uint256 totalClaimed, uint256 holders) {
        totalClaimed = rewards.getTotalRewarded();
        holders = rewards.countShareholders();
    }
    
    function getWalletStatistics(address wallet) external view returns (uint256 pending, uint256 claimed) {
	    pending = rewards.getUnpaidEarnings(wallet);
	    claimed = rewards.getPaidDividends(wallet);
	}

    function resetShares(address shareholder) external onlyOwner {
        if(!isDividendExempt[shareholder]){ rewards.setShare(shareholder, _balances[shareholder]); }
        else rewards.setShare(shareholder, 0);
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && !liquidityPools[holder] && holder != owner());
        isDividendExempt[holder] = exempt;
        if(exempt){
            rewards.setShare(holder, 0);
        }else{
            rewards.setShare(holder, _balances[holder]);
        }
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, uint256 gas) external onlyOwner {
        require(gas < 750000);
        rewards.setDistributionCriteria(_minPeriod, _minDistribution, gas);
    }

    function setTxLimit(uint256 buyNumerator, uint256 sellNumerator, uint256 divisor) external onlyOwner {
        require(buyNumerator > 0 && sellNumerator > 0 && divisor > 0 && divisor <= 10000);
        _maxBuyTxAmount = (_totalSupply * buyNumerator) / divisor;
        _maxSellTxAmount = (_totalSupply * sellNumerator) / divisor;
        emit UpdatedSettings('Maximum Transaction Size', [Log('Max Buy Tokens', _maxBuyTxAmount / (10 ** _decimals)), Log('Max Sell Tokens', _maxSellTxAmount / (10 ** _decimals)), Log('', 0)]);
    }
    
    function setMaxWallet(uint256 numerator, uint256 divisor) external onlyOwner() {
        require(numerator > 0 && divisor > 0 && divisor <= 10000);
        _maxWalletSize = (_totalSupply * numerator) / divisor;
        emit UpdatedSettings('Maximum Wallet Size', [Log('Tokens', _maxWalletSize / (10 ** _decimals)), Log('', 0), Log('', 0)]);
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
        emit UpdatedSettings(exempt ? 'Fees Removed' : 'Fees Enforced', [Log(toString(abi.encodePacked(holder)), 1), Log('', 0), Log('', 0)]);
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
        emit UpdatedSettings(exempt ? 'Transaction Limit Removed' : 'Transaction Limit Enforced', [Log(toString(abi.encodePacked(holder)), 1), Log('', 0), Log('', 0)]);
    }

    function updateWhitelist(address[] calldata _addresses, bool _enabled) external onlyOwner {
        require(whitelistEnabled, "Whitelist disabled");
        for (uint256 i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = _enabled;
        }
    }

    function setFees(uint256 _rewardsFee, uint256 _rewardsSellFee, uint256 _liquidityFee, uint256 _liquiditySellFee, uint256 _marketingFee, uint256 _marketingSellFee, uint256 _teamFee, uint256 _teamSellFee, uint256 _feeDenominator) external onlyOwner {
        require((_rewardsFee + _liquidityFee + _marketingFee + _teamFee) * 100 / feeDenominator <= 10, "Purchase fees too high");
        require((_rewardsSellFee + _liquiditySellFee + _marketingSellFee + _teamSellFee) * 100 / feeDenominator <= 10, "Sell fees too high");
        rewardsFee = _rewardsFee;
        rewardsSellFee = _rewardsSellFee;
        liquidityFee = _liquidityFee;
        liquiditySellFee = _liquiditySellFee;
        marketingFee = _marketingFee;
        marketingSellFee = _marketingSellFee;
        teamFee = _teamFee;
        teamSellFee = _teamSellFee;

        totalBuyFee = teamFee + liquidityFee + marketingFee + rewardsFee;
        totalSellFee = teamSellFee + liquiditySellFee + marketingSellFee + rewardsSellFee;
        feeDenominator = _feeDenominator;
        require(totalBuyFee + totalSellFee < feeDenominator / 2);

        emit UpdatedSettings('Fees', [Log('Total Buy Fee Percent', totalBuyFee * 100 / feeDenominator), Log('Total Sell Fee Percent', totalSellFee * 100 / feeDenominator), Log('Distribution Percent', (_rewardsFee + _rewardsSellFee) * 100 / feeDenominator)]);
    }

    function setMinimumBalance(uint256 _minimum) external onlyOwner {
        require(_minimum < 100);
        minimumBalance = _minimum;
        emit UpdatedSettings('Minimum Balance', [Log('Minimum: ', _minimum), Log('', 0), Log('', 0)]);
    }

    function setFeeReceivers(address _marketingFeeReceiver, address _teamFeeReceiver) external onlyOwner {
        marketingFeeReceiver = payable(_marketingFeeReceiver);
        teamFeeReceiver = payable(_teamFeeReceiver);

        emit UpdatedSettings('Fee Receivers', [Log(concatenate('Marketing Receiver: ',toString(abi.encodePacked(_marketingFeeReceiver))), 1), Log(concatenate('Team Receiver: ',toString(abi.encodePacked(_teamFeeReceiver))), 1), Log('', 0)]);
    }

    function setSwapBackSettings(bool _enabled, uint256 _denominator, uint256 _swapMinimum) external onlyOwner {
        require(_denominator > 0);
        swapEnabled = _enabled;
        swapThreshold = _totalSupply / _denominator;
        swapMinimum = _swapMinimum * (10 ** _decimals);
        emit UpdatedSettings('Swap Settings', [Log('Enabled', _enabled ? 1 : 0),Log('Swap Maximum', swapThreshold), Log('', 0)]);
    }

    function setMaxSwapPercent(uint256 _percent) external onlyOwner {
        require(_percent <= 100, "Percent too high");
        maxSwapPercent = _percent;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - (balanceOf(DEAD) + balanceOf(address(0)));
    }
	
	function toString(bytes memory data) internal pure returns(string memory) {
        bytes memory alphabet = "0123456789abcdef";
    
        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }
    
    function concatenate(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }

	struct Log {
	    string name;
	    uint256 value;
	}

    event FundsDistributed(uint256 liquidity, uint256 marketing, uint256 team);
    event UpdatedSettings(string name, Log[3] values);
}