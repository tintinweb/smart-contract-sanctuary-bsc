/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBEP20Metadata is IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract BEP20 is Context, IBEP20, IBEP20Metadata {
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
	
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
	
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
	
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
	
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
	
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
		
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
	
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
	
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }
	
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }
	
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
	
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
	
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	
    constructor() {
        _setOwner(_msgSender());
    }
	
    function owner() public view virtual returns (address) {
        return _owner;
    }
	
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
	
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
	
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
	
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
	
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
	
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
	
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IPancakeSwapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeSwapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
}

library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint256) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int256) {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint256 val ) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

interface IDividendDistributor {
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor, Ownable{
    using SafeMath for uint256;
	
    struct Share {
	  uint256 amount;
	  uint256 totalExcluded;
	  uint256 totalRealised;
    }

    IPancakeSwapV2Router02 router;
    IBEP20 public HAM = IBEP20(0x679D5b2d94f454c950d683D159b87aa8eae37C9e);
	
    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;
    
	event MinimumTokenBalanceForDividendsUpdated(uint256 indexed newValue, uint256 indexed oldValue);
	event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
	
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDividendsDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
	
    uint256 public claimWait;
	uint256 public minimumTokenBalanceForDividends;
    uint256 currentIndex;
	
    constructor (uint256 tokenBalanceForDividends) {
	    minimumTokenBalanceForDividends = tokenBalanceForDividends;
	    router = IPancakeSwapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }
	
	function updateMinimumTokenBalanceForDividends(uint256 amount) external onlyOwner {
	    emit MinimumTokenBalanceForDividendsUpdated(amount, minimumTokenBalanceForDividends);
        minimumTokenBalanceForDividends = amount;
    }
	
	function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }
	
    function setShare(address shareholder, uint256 amount) external override onlyOwner{
        if(amount >= minimumTokenBalanceForDividends) {   
		    if(shares[shareholder].amount == 0) {
			    addShareholder(shareholder);
			}
			totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
			shares[shareholder].amount = amount;
			shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
		else 
		{
		    if(shares[shareholder].amount > 0) {
			    removeShareholder(shareholder);
			}
			totalShares = totalShares.sub(shares[shareholder].amount);
			shares[shareholder].amount = 0;
			shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
		
		if(shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }
    }

    function deposit() external payable override onlyOwner {
        uint256 balanceBefore = HAM.balanceOf(address(this));
		
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(HAM);
		
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );
		
        uint256 amount = HAM.balanceOf(address(this)).sub(balanceBefore);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyOwner {
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
			
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + claimWait < block.timestamp && getUnpaidEarnings(shareholder) > 0;
    }
	
    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }
		
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDividendsDistributed = totalDividendsDistributed.add(amount);
            HAM.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
	
    function claimDividend(address payable account) public onlyOwner returns (bool){
		if(shouldDistribute(account)) {
		   distributeDividend(account);
		   return true;
        }
        return false;		
    }
	
    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }
        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
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
	
	function getNumberOfTokenHolders() external view returns (uint256) {
        return shareholders.length;
    }
	
	function getLastProcessedIndex() external view returns (uint256) {
        return currentIndex;
    }
}

contract BABYTOKEN is BEP20, Ownable {
    using SafeMath for uint256;
	
    IPancakeSwapV2Router02 public pancakeSwapV2Router;
    address public pancakeSwapV2Pair;

    bool private swapping;

    DividendDistributor dividendTracker;
	address public distributorAddress;
	
	IBEP20 public HAM = IBEP20(0x679D5b2d94f454c950d683D159b87aa8eae37C9e);
	
	bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    uint256 public swapTokensAtAmount;

    uint256 public tokenRewardsFee;
    uint256 public liquidityFee;
    uint256 public marketingFee;
    uint256 public totalFees;

    address public marketingWalletAddress;
    uint256 public gasForProcessing = 300000;

    mapping(address => bool) public isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) public isDividendExempt;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event UpdatePancakeSwapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    event GasForProcessingUpdated(uint256 indexed newValue,uint256 indexed oldValue);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event SendDividends(uint256 tokensSwapped, uint256 amount);
    event ProcessedDividendTracker(uint256 gas);
	event SwapingAmountUpdated(uint256 indexed newValue, uint256 indexed oldValue);
	event DividendTrackerUpdated(address indexed newAddress, address indexed oldAddress);
	event RewardsFeeUpdated(uint256 indexed newValue, uint256 indexed oldValue);
	event LiquiditFeeUpdated(uint256 indexed newValue, uint256 indexed oldValue);
	event MarketingFeeUpdated(uint256 indexed newValue, uint256 indexed oldValue);
	event MarketingWalletUpdated(address indexed newAddress, address indexed oldAddress);
	
    constructor(string memory _name, string memory _symbol, uint256 _totalSupply, address _marketingAddress, uint256 _tokenRewardsFee, uint256 _liquidityFee, uint256 _marketingFee, uint256 _minimumTokenBalanceForDividends) payable BEP20(_name, _symbol) {
		require(msg.sender != marketingWalletAddress, "Owner and marketing wallet cannot be the same");
		require(_totalSupply > _minimumTokenBalanceForDividends, "supply is less than `minimumTokenBalanceForDividends`");
		
		marketingWalletAddress = _marketingAddress;
		
        tokenRewardsFee = _tokenRewardsFee;
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
		
		totalFees = tokenRewardsFee.add(liquidityFee).add(marketingFee);
		require(totalFees <= 20, "Total fee is over 20%");
		
		swapTokensAtAmount = _totalSupply.mul(2).div(10**6);
		dividendTracker = new DividendDistributor(_minimumTokenBalanceForDividends);
		distributorAddress = address(dividendTracker);
		
		pancakeSwapV2Router = IPancakeSwapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pancakeSwapV2Pair = IPancakeSwapV2Factory(pancakeSwapV2Router.factory()).createPair(address(this), pancakeSwapV2Router.WETH());

        isDividendExempt[address(dividendTracker)] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[owner()] = true;
        isDividendExempt[address(0xdead)] = true;
        isDividendExempt[address(pancakeSwapV2Router)] = true;
		
        excludeFromFees(owner(), true);
        excludeFromFees(marketingWalletAddress, true);
        excludeFromFees(address(this), true);
		
        _mint(owner(), _totalSupply);
		_setAutomatedMarketMakerPair(pancakeSwapV2Pair, true);
    }

    receive() external payable {}

    function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
	    require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		emit SwapingAmountUpdated(amount, swapTokensAtAmount);
		
        swapTokensAtAmount = amount;
    }

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(newAddress != address(dividendTracker), "The dividend tracker already has that address");
		emit DividendTrackerUpdated(newAddress, address(dividendTracker));
		
		isDividendExempt[newAddress] = true;
		DividendDistributor newDividendTracker = DividendDistributor(payable(newAddress));
        dividendTracker = newDividendTracker;
		distributorAddress = address(dividendTracker);
		require(dividendTracker.owner() == address(this), "The new dividend tracker must be owned by the BABYTOKEN token contract");
	}

    function updatePancakeSwapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(pancakeSwapV2Router), "The router already has that address");
		emit UpdatePancakeSwapV2Router(newAddress, address(pancakeSwapV2Router));
		
        pancakeSwapV2Router = IPancakeSwapV2Router02(newAddress);
        address _pancakeSwapV2Pair = IPancakeSwapV2Factory(pancakeSwapV2Router.factory()).createPair(address(this), pancakeSwapV2Router.WETH());
        pancakeSwapV2Pair = _pancakeSwapV2Pair;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(isExcludedFromFees[account] != excluded, "Account is already the value of 'excluded'");
        isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
	
	function setIsDividendExempt(address account, bool exempt) external onlyOwner {
        require(account != address(this));
        isDividendExempt[account] = exempt;
        if(exempt)
		{
            dividendTracker.setShare(account, 0);
        }
		else
		{
            dividendTracker.setShare(account, balanceOf(account));
        }
    }
    
    function setMarketingWallet(address payable wallet) external onlyOwner {
        require(wallet != address(0), "zero-address not allowed");
		emit MarketingWalletUpdated(wallet, marketingWalletAddress);
		
		marketingWalletAddress = wallet;
    }

    function setTokenRewardsFee(uint256 value) external onlyOwner {
	    require(liquidityFee.add(marketingFee).add(value) <= 2000 , "Max fee limit reached for fee");
		emit RewardsFeeUpdated(value, tokenRewardsFee);
		
        tokenRewardsFee = value;
        totalFees = tokenRewardsFee.add(liquidityFee).add(marketingFee);
    }

    function setLiquiditFee(uint256 value) external onlyOwner {
	    require(tokenRewardsFee.add(marketingFee).add(value) <= 2000 , "Max fee limit reached for fee");
		emit LiquiditFeeUpdated(value, liquidityFee);
		
        liquidityFee = value;
        totalFees = tokenRewardsFee.add(liquidityFee).add(marketingFee);
    }
	
    function setMarketingFee(uint256 value) external onlyOwner {
	    require(liquidityFee.add(tokenRewardsFee).add(value) <= 2000 , "Max fee limit reached for fee");
		emit MarketingFeeUpdated(value, marketingFee);
		
        marketingFee = value;
        totalFees = tokenRewardsFee.add(liquidityFee).add(marketingFee);
    }

    function setAutomatedMarketMakerPair(address pair, bool value)public onlyOwner{
        require(pair != pancakeSwapV2Pair, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }
	
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        if(value) {
		   isDividendExempt[pair] = true;
        }
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
		
        gasForProcessing = newValue;
    }
	
    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns (uint256) {
        return dividendTracker.claimWait();
    }

    function updateMinimumTokenBalanceForDividends(uint256 amount)external onlyOwner {
        dividendTracker.updateMinimumTokenBalanceForDividends(amount);
    }

    function getMinimumTokenBalanceForDividends() external view returns (uint256) {
        return dividendTracker.minimumTokenBalanceForDividends();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }
    
    function withdrawableDividendOf(address account) public view returns (uint256) {
        return dividendTracker.getUnpaidEarnings(account);
    }
	
    function processDividendTracker(uint256 gas) external {
	   try dividendTracker.process(gas) {} catch {}
       emit ProcessedDividendTracker(gas);
    }
	
    function claim() external {
        dividendTracker.claimDividend(payable(msg.sender));
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function _transfer(address from, address to, uint256 amount ) internal override {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap && !swapping && !automatedMarketMakerPairs[from] && from != owner() && to != owner()) {
            swapping = true;

            uint256 marketingTokens = contractTokenBalance.mul(marketingFee) .div(totalFees);
            swapAndSendToFee(marketingTokens);

            uint256 swapTokens = contractTokenBalance.mul(liquidityFee).div(totalFees);
            swapAndLiquify(swapTokens);

            uint256 sellTokens = balanceOf(address(this));
            swapAndSendDividends(sellTokens);
			
            swapping = false;
        }

        bool takeFee = !swapping;

        if (isExcludedFromFees[from] || isExcludedFromFees[to]) {
            takeFee = false;
        }
		
        if (takeFee) {
            uint256 fees = amount.mul(totalFees).div(100);
            if(automatedMarketMakerPairs[to]) 
			{
                fees += amount.mul(1).div(100);
            }
            amount = amount.sub(fees);
            super._transfer(from, address(this), fees);
        }
		
        super._transfer(from, to, amount);
		
		if(!isDividendExempt[from]){ try dividendTracker.setShare(payable(from), balanceOf(from)) {} catch {} }
        if(!isDividendExempt[to]){ try dividendTracker.setShare(payable(to), balanceOf(to)) {} catch {} }
		
        if (!swapping) {
             uint256 gas = gasForProcessing;
			 try dividendTracker.process(gas) {} catch {}
        }
    }
	
    function swapAndSendToFee(uint256 tokens) private {
        uint256 initialBalance = IBEP20(HAM).balanceOf(address(this));
        swapTokensForHAM(tokens);
        uint256 newBalance = (IBEP20(HAM).balanceOf(address(this))).sub(initialBalance);
        IBEP20(HAM).transfer(marketingWalletAddress, newBalance);
    }
	
    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);
		
        uint256 initialBalance = address(this).balance;
        swapTokensForBNB(half);
        uint256 newBalance = address(this).balance.sub(initialBalance);
		
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeSwapV2Router.WETH();
		
        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
        pancakeSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForHAM(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = pancakeSwapV2Router.WETH();
        path[2] = address(HAM);
		
        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
        pancakeSwapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
        pancakeSwapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            address(0),
            block.timestamp
        );
    }
	
    function swapAndSendDividends(uint256 tokens) private {
	   uint256 initialBalance = address(this).balance;
       swapTokensForBNB(tokens);
       uint256 newBalance = address(this).balance.sub(initialBalance);
       try dividendTracker.deposit{value: newBalance}() {} catch {}
    }
    
    function clearStuckBalance(address _receiver) external onlyOwner {
       uint256 balance = address(this).balance;
       payable(_receiver).transfer(balance);
    }
}