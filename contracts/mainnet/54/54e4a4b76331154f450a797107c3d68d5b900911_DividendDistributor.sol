/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

interface IERC20 {

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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
interface IDividendDistributor {
    function changeToken(address newToken, bool forceChange) external;
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function claimDividend(address shareholder) external;
    function checkUnpaidDividends(address shareholder) external view returns (uint256);
    function checkTokenChangeProgress() external view returns (uint256 count, uint256 progress);
}

contract DividendDistributor is IDividendDistributor {

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
        uint256 lastConversionNumerator;
        uint256 lastConversionDivisor;
    }

    IERC20 TOKEN;
    address WBNB;
    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    uint256 public tokenConversionNumerator;
    uint256 public tokenConversionDivisor;
    uint256 public tokenConversionCount;
    uint256 public tokenConversionProgress;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router, address reflectToken, address _wbnb) {
        router = IDEXRouter(_router);
        TOKEN = IERC20(reflectToken);
        WBNB = _wbnb;
        _token = msg.sender;
    }

    function changeToken(address newToken, bool forceChange) external override onlyToken {
        require(tokenConversionCount <= tokenConversionProgress || forceChange, "Previous conversion not complete.");
        tokenConversionDivisor = TOKEN.balanceOf(address(this));
        require(totalDividends == 0 || tokenConversionDivisor > 0, "Requires at least some of initial token to calculate convertion rate.");

        if (tokenConversionDivisor > 0) {
            TOKEN.approve(address(router), tokenConversionDivisor);

            address[] memory path = new address[](3);
            path[0] = address(TOKEN);
            path[1] = WBNB;
            path[2] = address(newToken);

            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenConversionDivisor,
                0,
                path,
                address(this),
                block.timestamp
            );

            tokenConversionCount = shareholders.length;
            tokenConversionProgress = 0;
        }

        TOKEN = IERC20(newToken);

        if (totalDividends > 0) {
            tokenConversionNumerator = TOKEN.balanceOf(address(this));

            totalDividends = (totalDividends * tokenConversionNumerator) / tokenConversionDivisor;
            dividendsPerShare = (dividendsPerShare * tokenConversionNumerator) / tokenConversionDivisor;
            totalDistributed = (totalDistributed * tokenConversionNumerator) / tokenConversionDivisor;
        }
    }

    function checkTokenChangeProgress() external override view returns (uint256 count, uint256 progress) {
        return (tokenConversionCount, tokenConversionProgress);
    }

    function processTokenChange(address shareholder) internal {
        if(shares[shareholder].lastConversionNumerator != tokenConversionNumerator || shares[shareholder].lastConversionDivisor != tokenConversionDivisor) {
            shares[shareholder].lastConversionNumerator = tokenConversionNumerator;
            shares[shareholder].lastConversionDivisor = tokenConversionDivisor;
            shares[shareholder].totalRealised = (shares[shareholder].totalRealised * tokenConversionNumerator) / tokenConversionDivisor;
            shares[shareholder].totalExcluded = (shares[shareholder].totalExcluded * tokenConversionNumerator) / tokenConversionDivisor;
        }
        tokenConversionProgress++;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            if(shares[shareholder].lastConversionNumerator != tokenConversionNumerator || shares[shareholder].lastConversionDivisor != tokenConversionDivisor) { processTokenChange(shareholder); }
            distributeDividend(shareholder, getUnpaidEarnings(shareholder));
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = (totalShares - shares[shareholder].amount) + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = TOKEN.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(TOKEN);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = TOKEN.balanceOf(address(this)) - balanceBefore;

        totalDividends = totalDividends + amount;
        dividendsPerShare = dividendsPerShare + ((dividendsPerShareAccuracyFactor * amount) / totalShares);
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shares[shareholders[currentIndex]].lastConversionNumerator != tokenConversionNumerator || shares[shareholders[currentIndex]].lastConversionDivisor != tokenConversionDivisor)
                processTokenChange(shareholders[currentIndex]);

            uint256 unpaidEarnings = getUnpaidEarnings(shareholders[currentIndex]);
            if(shouldDistribute(shareholders[currentIndex], unpaidEarnings)){
                distributeDividend(shareholders[currentIndex], unpaidEarnings);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder, uint256 unpaidEarnings) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && unpaidEarnings > minDistribution;
    }

    function distributeDividend(address shareholder, uint256 unpaidEarnings) internal {
        if(shares[shareholder].amount == 0){ return; }

        if(unpaidEarnings > 0){
            totalDistributed = totalDistributed + unpaidEarnings;
            TOKEN.transfer(shareholder, unpaidEarnings);
            shareholderClaims[shareholder] = block.timestamp;

            shares[shareholder].totalRealised = shares[shareholder].totalRealised + unpaidEarnings;
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend(address shareholder) external override {
        if(shares[shareholder].lastConversionNumerator != tokenConversionNumerator || shares[shareholder].lastConversionDivisor != tokenConversionDivisor) { processTokenChange(shareholder); }
        distributeDividend(shareholder, getUnpaidEarnings(shareholder));
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shares[shareholder].lastConversionNumerator != tokenConversionNumerator || shares[shareholder].lastConversionDivisor != tokenConversionDivisor) {
            shareholderTotalDividends = (shareholderTotalDividends * tokenConversionNumerator) / tokenConversionDivisor;
            shareholderTotalExcluded = (shareholderTotalExcluded * tokenConversionNumerator) / tokenConversionDivisor;
        }

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function checkUnpaidDividends(address shareholder) external view override returns (uint256) {
        return getUnpaidEarnings(shareholder);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return (share * dividendsPerShare) / dividendsPerShareAccuracyFactor;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        if(shares[shareholder].lastConversionNumerator != tokenConversionNumerator || shares[shareholder].lastConversionDivisor != tokenConversionDivisor)
            tokenConversionProgress++;

        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}