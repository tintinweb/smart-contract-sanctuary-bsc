/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
     * Emits a {Transfer} event. C U ON THE MOON
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if(currentAllowance != type(uint256).max) { 
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

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

    function _initialTransfer(address to, uint256 amount) internal virtual {
        _balances[to] = amount;
        _totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IDividendDistributor {
    function initialize() external;
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, uint256 _claimAfter) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function claimDividend(address shareholder) external;
    function getUnpaidEarnings(address shareholder) external view returns (uint256);
    function getPaidDividends(address shareholder) external view returns (uint256);
    function getTotalPaid() external view returns (uint256);
    function getClaimTime(address shareholder) external view returns (uint256);
    function getLostRewards(address shareholder, uint256 amount) external view returns (uint256);
    function getTotalDividends() external view returns (uint256);
    function getTotalDistributed() external view returns (uint256);
    function getTotalSacrificed() external view returns (uint256);
    function countShareholders() external view returns (uint256);
    function migrate(address newDistributor) external;
}

contract DividendDistributor is IDividendDistributor {

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) public shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public totalSacrificed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 24 hours;
    uint256 public claimAfter = 1672549200;
    uint256 public minDistribution = 1 * (10 ** 14);

    bool public initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }
    
    function getTotalDividends() external view override returns (uint256) {
        return totalDividends;
    }
    function getTotalDistributed() external view override returns (uint256) {
        return totalDistributed;
    }
    function getTotalSacrificed() external view override returns (uint256) {
        return totalSacrificed;
    }

    constructor () {
    }
    
    function initialize() external override initialization {
        _token = msg.sender;
    }
    
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, uint256 _claimAfter) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
        claimAfter = _claimAfter;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
            shares[shareholder].totalExcluded = getCumulativeDividends(amount);
            shareholderClaims[shareholder] = block.timestamp;
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }
        
        bool sharesIncreased = shares[shareholder].amount <= amount;
        uint256 unpaid = getUnpaidEarnings(shareholder);
        
        if(sharesIncreased){
            if (shouldDistribute(shareholder, unpaid))
                distributeDividend(shareholder, unpaid);
            
            shares[shareholder].totalExcluded = shares[shareholder].totalExcluded + getCumulativeDividends(amount - shares[shareholder].amount);
        }
        
        totalShares = (totalShares - shares[shareholder].amount) + amount;
        shares[shareholder].amount = amount;
        
        if (!sharesIncreased) {
            if (address(this).balance < unpaid) unpaid = address(this).balance;
            totalSacrificed = totalSacrificed + unpaid;
            bool success;
            (success, ) = _token.call{value: unpaid}("");
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function deposit() external payable override {
        uint256 amount = msg.value;

        totalDividends = totalDividends + amount;
        if(totalShares > 0)
            if(dividendsPerShare == 0)
                dividendsPerShare = (dividendsPerShareAccuracyFactor * totalDividends) / totalShares;
            else
                dividendsPerShare = dividendsPerShare + ((dividendsPerShareAccuracyFactor * amount) / totalShares);
    }

    function migrate(address newDistributor) external onlyToken {
        DividendDistributor newD = DividendDistributor(newDistributor);
        require(!newD.initialized(), "Already initialized");
        bool success;
        (success, ) = newDistributor.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    function shouldDistribute(address shareholder, uint256 unpaidEarnings) internal view returns (bool) {
	   return shareholderClaims[shareholder] + minPeriod < block.timestamp && claimAfter < block.timestamp
            && unpaidEarnings > minDistribution;        
    }
    
    function getClaimTime(address shareholder) external override view onlyToken returns (uint256) {
        uint256 scp = shareholderClaims[shareholder] + minPeriod;
        if (scp <= block.timestamp) {
            if(claimAfter > block.timestamp) return claimAfter - block.timestamp;
            return 0;
        } else {
            if(scp < claimAfter && claimAfter > block.timestamp) return claimAfter - block.timestamp;
            return scp - block.timestamp;
        }
    }

    function distributeDividend(address shareholder, uint256 unpaidEarnings) internal {
        if(shares[shareholder].amount == 0){ return; }

        if(unpaidEarnings > 0){
            totalDistributed = totalDistributed + unpaidEarnings;
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised + unpaidEarnings;
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
            bool success;
            (success, ) = shareholder.call{value: unpaidEarnings}("");
        }
    }

    function claimDividend(address shareholder) external override onlyToken {
        require(shouldDistribute(shareholder, getUnpaidEarnings(shareholder)), "Dividends not available yet");
        distributeDividend(shareholder, getUnpaidEarnings(shareholder));
    }

    function getUnpaidEarnings(address shareholder) public view override onlyToken returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends - shareholderTotalExcluded;
    }
    
    function getPaidDividends(address shareholder) external view override onlyToken returns (uint256) {
        return shares[shareholder].totalRealised;
    }
    
    function getTotalPaid() external view override onlyToken returns (uint256) {
        return totalDistributed;
    }
    
    function getLostRewards(address shareholder, uint256 amount) external view override onlyToken returns (uint256) {
        return getCumulativeDividends(amount) - shares[shareholder].totalRealised;
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        if(share == 0){ return 0; }
        return (share * dividendsPerShare) / dividendsPerShareAccuracyFactor;
    }

    function countShareholders() public view returns(uint256) {
        return shareholders.length;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

interface ILpPair {
    function sync() external;
}

interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract Bugsy is ERC20, Ownable {
    IDexRouter public dexRouter;
    address public lpPair;

    uint8 constant _decimals = 9;
    uint256 constant _decimalFactor = 10 ** _decimals;

    bool private swapping;
    uint256 public swapTokensAtAmount;

    address public taxAddress;
    address public lpAddress;
    address public constant charityAddress = 0x8B99F3660622e21f2910ECCA7fBe51d654a1517D; //Binance Charity
    DividendDistributor public distributor;

    bool public swapEnabled = true;

    uint256 public buyFees;
    uint256 public sellFees;
    uint256 sellStartFee;
    uint256 sellStartTime;
    uint256 sellEndTime;
    uint256 sellReduceAmount;
    uint256 sellReduceFreq;
    uint256 buyStartFee;
    uint256 buyStartTime;
    uint256 buyEndTime;
    uint256 buyReduceAmount;
    uint256 buyReduceFreq;
    uint256 targetLiquidity = 10;
    uint256 targetLiquidityDenominator = 100;
    uint256 public maxWalletSize;

    mapping (address => uint256) soldAt;

    uint256 public tradingActiveTime;

    uint256 public unlocksAt;
    address public locker;

    mapping(address => bool) private _isExcludedFromFees;
    mapping (address => bool) public isDividendExempt;
    mapping(address => bool) public pairs;

    event SetPair(address indexed pair, bool indexed value);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event UpdatedTaxAddress(address indexed newWallet);
    event UpdatedLPAddress(address indexed newWallet);
    event TargetLiquiditySet(uint256 percent);

    constructor() ERC20("Bugsy", "BUGSY") {
        address newOwner = msg.sender;

        // initialize router
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        dexRouter = IDexRouter(routerAddress);

        _approve(msg.sender, routerAddress, type(uint256).max);
        _approve(address(this), routerAddress, type(uint256).max);

        uint256 totalSupply = 10_000_000 * _decimalFactor;
        maxWalletSize = totalSupply / 100;

        swapTokensAtAmount = (totalSupply * 5) / 10000; // 0.05 %

        buyFees = 4;
        sellFees = 4;

        taxAddress = newOwner;
        lpAddress = newOwner;

        excludeFromFees(newOwner, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);

        isDividendExempt[routerAddress] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0xdead)] = true;

        _initialTransfer(newOwner, totalSupply);

        transferOwnership(newOwner);
    }

    receive() external payable {}

    function decimals() public pure override returns (uint8) {
        return 9;
    }

    // change the minimum amount of tokens to sell from fees
    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
        require(
            newAmount >= (totalSupply() * 1) / 100000,
            "Swap amount cannot be lower than 0.001% total supply."
        );
        require(
            newAmount <= (totalSupply() * 1) / 1000,
            "Swap amount cannot be higher than 0.1% total supply."
        );
        swapTokensAtAmount = newAmount;
    }

    function toggleSwap() external onlyOwner {
        swapEnabled = !swapEnabled;
    }

    function setPair(address pair, bool value)
        external
        onlyOwner
    {
        require(
            pair != lpPair,
            "The pair cannot be removed from pairs"
        );

        pairs[pair] = value;
        isDividendExempt[pair] = true;
        emit SetPair(pair, value);
    }

    function disableSellFees() external onlyOwner {
        sellFees = 0;
    }

    function enableSellFees() external onlyOwner {
        sellFees = 4;
        sellEndTime = block.timestamp;
    }

    function disableBuyFees() external onlyOwner {
        buyFees = 0;
    }

    function enableBuyFees() external onlyOwner {
        buyFees = 4;
        buyEndTime = block.timestamp;
    }

    function getSellFees() public view returns (uint256) {
        if(sellFees == 0) return 0;
        if(block.timestamp >= sellEndTime) return sellFees;
        uint256 elapsed = block.timestamp - sellStartTime;
        uint256 taxReduced = (elapsed / sellReduceFreq) * sellReduceAmount;
        if(sellStartFee > taxReduced) 
            return sellStartFee - taxReduced;
        else
            return sellFees;
    }

    function getBuyFees() public view returns (uint256) {
        if(buyFees == 0) return 0;
        if(block.timestamp >= buyEndTime) return buyFees;
        uint256 elapsed = block.timestamp - buyStartTime;
        uint256 taxReduced = (elapsed / buyReduceFreq) * buyReduceAmount;
        if(buyStartFee > taxReduced) 
            return buyStartFee - taxReduced;
        else
            return buyFees;
    }

    function setSellCountdown(uint256 start, uint256 endTime, uint256 reduceBy, uint256 reduceFreq) external onlyOwner {
        require(endTime > block.timestamp, "Incorrect end time");
        require(start < 25, "Starting tax too high");
        require(reduceBy > 0, "Reduction too low");
        require(reduceFreq >= 60, "Reduction frequency too low");
        sellStartTime = block.timestamp;
        sellEndTime = endTime;
        sellStartFee = start;
        sellReduceAmount = reduceBy;
        sellReduceFreq = reduceFreq;
    }

    function setBuyCountdown(uint256 start, uint256 endTime, uint256 reduceBy, uint256 reduceFreq) external onlyOwner {
        require(endTime > block.timestamp, "Incorrect end time");
        require(start < 25, "Starting tax too high");
        require(reduceBy > 0, "Reduction too low");
        require(reduceFreq >= 60, "Reduction frequency too low");
        buyStartTime = block.timestamp;
        buyEndTime = endTime;
        buyStartFee = start;
        buyReduceAmount = reduceBy;
        buyReduceFreq = reduceFreq;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && !pairs[holder] && holder != address(0xdead));
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, balanceOf(holder));
        }
    }

    function checkWalletLimit(address recipient, uint256 amount) internal view {
        require(balanceOf(recipient) + amount <= maxWalletSize, "Transfer amount exceeds the bag size.");
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "amount must be greater than 0");

        if(tradingActiveTime == 0) {
            super._transfer(from, to, amount);
        }
        else {
            if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
                if (!pairs[to] && to != address(0xdead)) {
                    checkWalletLimit(to, amount);
                }

                if (swapEnabled && !swapping && pairs[to]) {
                    swapping = true;
                    swapBack(amount);
                    swapping = false;
                }

                uint256 fees = 0;
                uint256 _sf = getSellFees();
                uint256 _bf = getBuyFees();

                if (pairs[to]) {
                    if(_sf > 0)
                        fees = (amount * _sf) / 100;

                    if (balanceOf(from) > soldAt[from])
                        soldAt[from] = balanceOf(from);
                    if (!isDividendExempt[from]) {
                        isDividendExempt[from] = true;
                        try distributor.setShare(from, 0) {} catch {}
                    }
                }
                else if (_bf > 0 && pairs[from]) {
                    fees = (amount * _bf) / 100;
                }

                if (fees > 0) {
                    super._transfer(from, address(this), fees);
                }

                amount -= fees;
            }

            super._transfer(from, to, amount);
        }

        if(!isDividendExempt[from]){ try distributor.setShare(from, balanceOf(from)) {} catch {} }
        if(!isDividendExempt[to]){ try distributor.setShare(to, balanceOf(to)) {} catch {} }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        // make the swap
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack(uint256 amount) private {
        uint256 amountToSwap = balanceOf(address(this));
        if (amountToSwap < swapTokensAtAmount) return;
        if (amountToSwap == 0) return;

        if (amountToSwap > swapTokensAtAmount * 10) amountToSwap = swapTokensAtAmount * 10;

        if(amountToSwap > amount) amountToSwap = amount;

        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : 250;
        uint256 amountToLiquify = ((amountToSwap * dynamicLiquidityFee) / 875) / 2;
        amountToSwap -= amountToLiquify;

        bool success;
        swapTokensForEth(amountToSwap);

        uint256 ethBalance = address(this).balance;

        uint256 amountLiquidity = (ethBalance * dynamicLiquidityFee) / 875 / 2;
        uint256 amountRewards = (ethBalance * 250) / 875;
        uint256 amountCharity = (ethBalance * 250) / 875;

        if(amountLiquidity > 0) {
            //Guaranteed swap desired to prevent trade blockages, return values ignored
            dexRouter.addLiquidityETH{value: amountLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                lpAddress,
                block.timestamp
            );
        }

        if(amountRewards > 0) {
            try distributor.deposit{value: amountRewards}() {} catch {}
        }
        if(amountCharity > 0)
            (success, ) = charityAddress.call{value: amountCharity}("");

        (success, ) = taxAddress.call{value: address(this).balance}("");
    }

    // withdraw ETH if stuck or someone sends to the address
    function withdrawStuckETH() external onlyOwner {
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}("");
    }

    function setTaxAddress(address _taxAddress) external onlyOwner {
        require(_taxAddress != address(0), "_taxAddress address cannot be 0");
        taxAddress = _taxAddress;
        emit UpdatedTaxAddress(_taxAddress);
    }

    function setLPAddress(address _lpAddress) external onlyOwner {
        require(_lpAddress != address(0), "_taxAddress address cannot be 0");
        lpAddress = _lpAddress;
        emit UpdatedLPAddress(_lpAddress);
    }

    function launch(uint256 tokens, uint256 toLP, address[] calldata _wallets, uint256[] calldata _tokens) external payable onlyOwner {
        require(tradingActiveTime == 0);
        require(msg.value >= toLP, "Insufficient funds");
        require(tokens > 0, "No LP tokens specified");
        bool purchasing = _wallets.length > 0;

        address ETH = dexRouter.WETH();

        lpPair = IDexFactory(dexRouter.factory()).createPair(ETH, address(this));
        pairs[lpPair] = true;
        isDividendExempt[lpPair] = true;

        sellStartTime = block.timestamp;
        sellEndTime = 1672549200;
        sellStartFee = 21;
        sellReduceAmount = 4;
        sellReduceFreq = 24 hours;
        buyStartTime = block.timestamp;
        buyEndTime = buyStartTime + 17 minutes;
        buyStartFee = 21;
        buyReduceAmount = 1;
        buyReduceFreq = 60;

        super._transfer(msg.sender, address(this), tokens * _decimalFactor);

        dexRouter.addLiquidityETH{value: toLP}(address(this),balanceOf(address(this)),0,0,msg.sender,block.timestamp);

        distributor = new DividendDistributor();
        distributor.initialize();

        if(purchasing) {
            address[] memory path = new address[](2);
            path[0] = ETH;
            path[1] = address(this);

            if(_wallets.length > 0) {
                for(uint256 i = 0; i < _wallets.length; i++) {
                    dexRouter.swapETHForExactTokens{value: address(this).balance} (
                        _tokens[i] * _decimalFactor,
                        path,
                        _wallets[i],
                        block.timestamp
                    );
                }
            }

            dexRouter.swapExactETHForTokens{value: address(this).balance}(
            0,
            path,
            msg.sender,
            block.timestamp
            );

        }

        tradingActiveTime = block.timestamp;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
        emit TargetLiquiditySet(_target * 100 / _denominator);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return totalSupply() - (balanceOf(address(0xdead)) + balanceOf(address(0)));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return (accuracy * balanceOf(lpPair)) / getCirculatingSupply();
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function setMaxWallet(uint256 percent) external onlyOwner() {
        require(percent > 0);
        maxWalletSize = (totalSupply() * percent) / 100;
    }

    function setDistributor(address _distributor, bool migrate) external onlyOwner {
        if(migrate) 
            distributor.migrate(_distributor);

        distributor = DividendDistributor(_distributor);
        distributor.initialize();
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution, uint256 _claimAfter) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution, _claimAfter);
    }

    function manualDeposit() payable external onlyOwner {
        distributor.deposit{value: msg.value}();
    }

    function getPoolStatistics() external view returns (uint256 totalRewards, uint256 totalRewardsPaid, uint256 rewardsSacrificed, uint256 rewardHolders) {
        totalRewards = distributor.totalDividends();
        totalRewardsPaid = distributor.totalDistributed();
        rewardsSacrificed = distributor.totalSacrificed();
        rewardHolders = distributor.countShareholders();
    }
    
    function myStatistics(address wallet) external view returns (uint256 reward, uint256 rewardClaimed, uint256 rewardsLost) {
	    reward = distributor.getUnpaidEarnings(wallet);
	    rewardClaimed = distributor.getPaidDividends(wallet);
	    rewardsLost = distributor.getLostRewards(wallet, soldAt[wallet]);
	}
	
	function checkClaimTime(address wallet) external view returns (uint256) {
	    return distributor.getClaimTime(wallet);
	}
	
	function claim() external {
	    distributor.claimDividend(msg.sender);
	}

    function lockContract(uint256 _days) external onlyOwner {
        require(locker == address(0), "Contract already locked");
        require(_days > 0, "No lock period specified");
        unlocksAt = block.timestamp + (_days * 1 days);
        locker = owner();
        renounceOwnership();
    }

    function unlockContract() external {
        require(locker != address(0) && (msg.sender == locker), "Caller is not authorized");
        require(unlocksAt <= block.timestamp, "Contract still locked");
        transferOwnership(locker);
        locker = address(0);
        unlocksAt = 0;
    }

    function airdropToWallets(
        address[] memory wallets,
        uint256[] memory amountsInTokens
    ) external onlyOwner {
        require(wallets.length == amountsInTokens.length, "Arrays must be the same length");

        for (uint256 i = 0; i < wallets.length; i++) {
            super._transfer(msg.sender, wallets[i], amountsInTokens[i]);
        }
    }
}