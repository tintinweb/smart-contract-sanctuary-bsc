/**
 *Submitted for verification at BscScan.com on 2022-08-30
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
	
    function name() external view virtual override returns (string memory) {
        return _name;
    }
	
    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }
	
    function decimals() external view virtual override returns (uint8) {
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
	
    function allowance(address owner, address spender) external view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
	
    function approve(address spender, uint256 amount) external virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
	
    function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);
		
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
	
    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
	
    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
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
	
    function renounceOwnership() external virtual onlyOwner {
        _setOwner(address(0));
    }
	
    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

interface IDividendDistributor {
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
	
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
  
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
   
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
	
    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

library SafeBEP20 {
    using Address for address;
	
    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
	
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

contract DividendDistributor is IDividendDistributor, Ownable{
	using SafeBEP20 for IBEP20;
	
    struct Share {
	  uint256 amount;
	  uint256 totalExcluded;
	  uint256 totalRealised;
    }

    IPancakeSwapV2Router02 public router;
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
    uint256 public constant dividendsPerShareAccuracyFactor = 10 ** 36;
    uint256 public claimWait = 3600;
	uint256 public minimumTokenBalanceForDividends;
    uint256 public currentIndex;
	
    constructor (uint256 tokenBalanceForDividends) {
	    minimumTokenBalanceForDividends = tokenBalanceForDividends;
	    router = IPancakeSwapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }
	
	function updateMinimumTokenBalanceForDividends(uint256 amount) external onlyOwner {
	    require(amount <= IBEP20(owner()).totalSupply() && amount >= 1 * 10**9, "supply is less than `amount` or `amount` is less than `0.000000001`.");
		
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
		if(amount >= minimumTokenBalanceForDividends)
		{   
		    if(shares[shareholder].amount == 0)
			{
			    addShareholder(shareholder);
			}
			totalShares = totalShares- shares[shareholder].amount + amount;
			shares[shareholder].amount = amount;
        }
		else 
		{
		    if(shares[shareholder].amount > 0)
			{
			    removeShareholder(shareholder);
			}
			totalShares = totalShares - shares[shareholder].amount;
			shares[shareholder].amount = 0;
        }
    }
	
    function deposit() external override payable onlyOwner {
        uint256 balanceBefore = IBEP20(HAM).balanceOf(address(this));
		
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(HAM);
		
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );
		
        uint256 amount = IBEP20(HAM).balanceOf(address(this))- balanceBefore;
        totalDividends = totalDividends + amount;
        dividendsPerShare = dividendsPerShare + (dividendsPerShareAccuracyFactor * amount / totalShares);
    }
	
    function process(uint256 gas) external override onlyOwner{
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
		uint256 counter = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex + counter >= shareholderCount){
                currentIndex = 0;
				counter = 0;
            }
			
            if(shouldDistribute(shareholders[currentIndex + counter]))
			{
                distributeDividend(shareholders[currentIndex + counter]);
            }
			
            gasUsed = gasUsed + gasLeft - gasleft();
            gasLeft = gasleft();
			counter++;
            iterations++;
        }
		currentIndex += counter;
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + claimWait < block.timestamp && getUnpaidEarnings(shareholder) > 0;
    }
	
    function distributeDividend(address shareholder) internal{
        if(shares[shareholder].amount == 0){ return; }
		
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDividendsDistributed = totalDividendsDistributed + amount;
            IBEP20(HAM).safeTransfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised + amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
	
    function claimDividend(address payable account) external onlyOwner returns (bool){
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
        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share * dividendsPerShare / dividendsPerShareAccuracyFactor;
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
}

contract BABYTOKEN is BEP20, Ownable {
    using SafeBEP20 for IBEP20;
	
    IPancakeSwapV2Router02 public pancakeSwapV2Router;
    address public pancakeSwapV2Pair;

    bool private swapping;

    DividendDistributor dividendTracker;
	address public immutable distributorAddress;
	
	IBEP20 public HAM = IBEP20(0x679D5b2d94f454c950d683D159b87aa8eae37C9e);
	
    uint256 public swapTokensAtAmount;
    uint256 public tokenRewardsFee;
    uint256 public liquidityFee;
    uint256 public marketingFee;
    uint256 public totalFees;
	
	bool public swapAndLiquifyEnabled = true;

    address public marketingWalletAddress;
    uint256 public gasForProcessing = 300000;

    mapping(address => bool) public isExcludedFromFees;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) public isDividendExempt;

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
	event SwapAndLiquifyEnabledUpdated(bool enabled);
	
    constructor(string memory _name, string memory _symbol, uint256 _totalSupply, address _marketingAddress, uint256 _tokenRewardsFee, uint256 _liquidityFee, uint256 _marketingFee, uint256 _minimumTokenBalanceForDividends) payable BEP20(_name, _symbol) {
		require(_tokenRewardsFee >= 100, "Rewards fee is less than 1%");
		require(_liquidityFee >= 100, "Liquidity fee is less than 1%");
		require(_marketingFee >= 100, "Marketing fee is less than 1%");
		require(_marketingAddress != address(0), "zero-address not allowed");
		
		require(msg.sender != marketingWalletAddress, "Owner and marketing wallet cannot be the same");
		require(_totalSupply > _minimumTokenBalanceForDividends && _minimumTokenBalanceForDividends >= 1 * 10**9, "supply is less than `minimumTokenBalanceForDividends` or limit is less than `0.000000001`");
		
		marketingWalletAddress = _marketingAddress;
		
        tokenRewardsFee = _tokenRewardsFee;
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
		
		totalFees = tokenRewardsFee + liquidityFee + marketingFee;
		require(totalFees <= 2000, "Total fee is over 20%");
		
		swapTokensAtAmount = _totalSupply * 2 / 10**4;
		dividendTracker = new DividendDistributor(_minimumTokenBalanceForDividends);
		distributorAddress = address(dividendTracker);
		
		pancakeSwapV2Router = IPancakeSwapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pancakeSwapV2Pair = IPancakeSwapV2Factory(pancakeSwapV2Router.factory()).createPair(address(this), pancakeSwapV2Router.WETH());
		
        isDividendExempt[address(dividendTracker)] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[owner()] = true;
        isDividendExempt[address(0xdead)] = true;
        isDividendExempt[address(pancakeSwapV2Router)] = true;

        isExcludedFromFees[owner()] = true;
        isExcludedFromFees[marketingWalletAddress] = true;
        isExcludedFromFees[address(this)] = true;
		
        _mint(owner(), _totalSupply);
		_setAutomatedMarketMakerPair(pancakeSwapV2Pair, true);
    }

    receive() external payable {}

    function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
	    require(amount <= totalSupply() && amount >= totalSupply() * 1 /10**8, "supply is less than `amount` or `amount` is less than `0.000002%` of supply");
		emit SwapingAmountUpdated(amount, swapTokensAtAmount);
		
        swapTokensAtAmount = amount;
    }
	
    function updatePancakeSwapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(pancakeSwapV2Router), "The router already has that address");
		require(newAddress != address(0), "zero-address not allowed");
		
		emit UpdatePancakeSwapV2Router(newAddress, address(pancakeSwapV2Router));
		
		isDividendExempt[address(pancakeSwapV2Router)] = false;
		
        pancakeSwapV2Router = IPancakeSwapV2Router02(newAddress);
        address _pancakeSwapV2Pair = IPancakeSwapV2Factory(pancakeSwapV2Router.factory()).createPair(address(this), pancakeSwapV2Router.WETH());
        pancakeSwapV2Pair = _pancakeSwapV2Pair;
		
		isDividendExempt[address(pancakeSwapV2Router)] = true;
    }

    function excludeFromFees(address account, bool excluded) external onlyOwner {
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

        isExcludedFromFees[marketingWalletAddress] = false;
		marketingWalletAddress = wallet;
		isExcludedFromFees[marketingWalletAddress] = true;
    }

    function setTokenRewardsFee(uint256 value) external onlyOwner {
	    require(value >= 100, "New fee is less than 1%");
		require(liquidityFee + marketingFee + value <= 2000 , "Max fee limit reached for fee");
		emit RewardsFeeUpdated(value, tokenRewardsFee);
		
        tokenRewardsFee = value;
        totalFees = tokenRewardsFee + liquidityFee + marketingFee;
    }

    function setLiquiditFee(uint256 value) external onlyOwner {
	    require(value >= 100, "New fee is less than 1%");
		require(tokenRewardsFee + marketingFee + value <= 2000 , "Max fee limit reached for fee");
		emit LiquiditFeeUpdated(value, liquidityFee);
		
        liquidityFee = value;
        totalFees = tokenRewardsFee + liquidityFee + marketingFee;
    }
	
    function setMarketingFee(uint256 value) external onlyOwner {
	    require(value >= 100, "New fee is less than 1%");
	    require(liquidityFee + tokenRewardsFee + value <= 2000 , "Max fee limit reached for fee");
		emit MarketingFeeUpdated(value, marketingFee);
		
        marketingFee = value;
        totalFees = tokenRewardsFee + liquidityFee + marketingFee;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner{
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
	
    function updateGasForProcessing(uint256 newValue) external onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
		
        gasForProcessing = newValue;
    }
	
    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }
	
	function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function getClaimWait() external view returns (uint256) {
        return dividendTracker.claimWait();
    }

    function updateMinimumTokenBalanceForDividends(uint256 amount) external onlyOwner {
	    require(amount <= totalSupply() && amount >= 1 * 10**9, "supply is less than `amount` or `amount` is less than `0.000000001`.");
        dividendTracker.updateMinimumTokenBalanceForDividends(amount);
    }
	
    function getMinimumTokenBalanceForDividends() external view returns (uint256) {
        return dividendTracker.minimumTokenBalanceForDividends();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }
    
    function withdrawableDividendOf(address account) external view returns (uint256) {
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
        return dividendTracker.currentIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function _transfer(address from, address to, uint256 amount ) internal override{
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
		
        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap && !swapping && swapAndLiquifyEnabled && !automatedMarketMakerPairs[from] && from != owner() && to != owner()) {
            swapping = true;
			
			uint256 marketingTokens = swapTokensAtAmount * marketingFee / totalFees;
            swapAndSendMarketingFee(marketingTokens);
			
			uint256 liquidityTokens = swapTokensAtAmount * liquidityFee / totalFees;
			uint256 dividendTokens = swapTokensAtAmount * tokenRewardsFee / totalFees;
			uint256 half = liquidityTokens / 2;
			uint256 tokenForBNB = half + dividendTokens;
			
			uint256 initialBalance = address(this).balance;
			swapTokensForBNB(tokenForBNB);
			uint256 newBalance = address(this).balance - initialBalance;
			
			uint256 liquidityShare = newBalance * half / tokenForBNB;
			uint256 dividendShare = newBalance - liquidityShare;
			
			if(liquidityShare > 0)
			{
			    addLiquidity(liquidityTokens, liquidityShare);
			}
			
			if(dividendShare > 0)
			{
			    try dividendTracker.deposit{value: dividendShare}() {} catch {}
			}
			swapping = false;
        }

        bool takeFee = !swapping;

        if (isExcludedFromFees[from] || isExcludedFromFees[to]) {
            takeFee = false;
        }
		
        if (takeFee) {
            uint256 fees = amount * totalFees / 10000;
            amount = amount - fees;
            super._transfer(from, address(this), fees);
        }
		
        super._transfer(from, to, amount);
		if(!isDividendExempt[from]){ try dividendTracker.setShare(from, balanceOf(from)) {} catch {} }
        if(!isDividendExempt[to]){ try dividendTracker.setShare(to, balanceOf(to)) {} catch {} }
		
        if (!swapping) {
             uint256 gas = gasForProcessing;
			 try dividendTracker.process(gas) {} catch {}
        }
    }
	
    function swapTokensForBNB(uint256 tokenAmount) private{
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
	
    function swapAndSendMarketingFee(uint256 tokenAmount) private{
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = pancakeSwapV2Router.WETH();
        path[2] = address(HAM);
		
        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
        pancakeSwapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(marketingWalletAddress),
            block.timestamp
        );
    }
	
    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private{
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
	
    function clearStuckBalance(address _receiver) external onlyOwner {
	   require(_receiver != address(0), "zero-address not allowed");
       uint256 balance = address(this).balance;
       payable(_receiver).transfer(balance);
    }
	
	function rescueToken(address _receiver, address tokenAddress, uint256 tokens) external onlyOwner returns (bool success){
        require(_receiver != address(0), "zero-address not allowed");
		require(tokenAddress != address(this), "the token address can not be the current contract");
		
		return IBEP20(tokenAddress).transfer(address(_receiver), tokens);
    }
	
	function migrateToken(address _receiver, uint256 tokens) external onlyOwner{
        require(_receiver != address(0), "zero-address not allowed");
		IBEP20(address(this)).transfer(address(_receiver), tokens);
    }
	
	function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");

        isExcludedFromFees[owner()] = false;
        isDividendExempt[owner()] = false;

        _setOwner(newOwner);
		
		isExcludedFromFees[owner()] = true;
        isDividendExempt[owner()] = true;
    }
}