/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
  function allPairsLength() external view returns (uint);

  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);

  function createPair(address tokenA, address tokenB) external returns (address pair);
}

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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Auth {
    using SafeMath for uint256;

    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }
    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    event OwnershipTransferred(address owner);
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function claimDividend(address holder) external;
}

contract DividendDistributor is IDividendDistributor {

    using SafeMath for uint256;
    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IUniswapV2Router02 router;
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IBEP20 RewardToken = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7); 

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 minutes;
    uint256 public minDistribution = 1 * (10 ** 17);

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

    constructor (address _router) {
        router = _router != address(0) ? IUniswapV2Router02(_router) : IUniswapV2Router02(routerAddress);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {

        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {

        uint256 balanceBefore = RewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(RewardToken);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = RewardToken.balanceOf(address(this)).sub(balanceBefore);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while(gasUsed < gas && iterations < shareholderCount) {

            if(currentIndex >= shareholderCount){ currentIndex = 0; }

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
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            RewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }

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
    
    function claimDividend(address holder) external override {
        distributeDividend(holder);
    }
}

contract RewardingALot is IBEP20, Auth {
    using SafeMath for uint256;

    DividendDistributor public dividendDistributor;
    uint256 distributorGas = 300000;

    //BUY fee (10% reward)
    uint256 public BuyFeeTotal = 10;
    function changeBuyFees(uint256 newBuyFeeReward) external authorized {
        BuyFeeTotal = newBuyFeeReward;
        require(BuyFeeTotal <= 10);
    }
    
    //Sell fee (10% reward)
    uint256 public SellFeeTotal = 10;
    function changeSellFees(uint256 newSellFeeReward) external authorized {
        SellFeeTotal = newSellFeeReward;
		require(SellFeeTotal <= 30);
    }

    string constant _name = "Token of Reward";
    string constant _symbol = "Reward";
    uint8 constant _decimals = 18;
    uint256 _totalSupply = 1000000000 * (10 ** _decimals);

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    uint256 public _maxWallet = _totalSupply / 50; //Max wallet 20m
    function changeMaxWallet(uint256 newValue) external authorized{
        _maxWallet = newValue * (10 ** _decimals);
    }
    uint256 public _minimumTokensToSwap = _totalSupply / 250; //4m tokens to swap
    function changeMinimumTokensToSwap(uint256 newValue) external authorized{
        _minimumTokensToSwap = newValue * (10 ** _decimals);
    }

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    //Basic contract variables (router, pair, routeraddress, rewardToken)
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IUniswapV2Router02 public router = IUniswapV2Router02(routerAddress);
    address public pair = IUniswapV2Factory(router.factory()).createPair(router.WETH(), address(this));
    mapping (address => bool) public isMarketPair;
    
    address WBNBaddress = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address BUSDaddress = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
    IBEP20 RewardTokenBUSD = IBEP20(BUSDaddress);
    
    //Exemptions
    mapping(address => bool) public exemptFromMaxWallet;
    function changeExemptFromMaxWallet(address holder, bool newValue) external authorized{
        exemptFromMaxWallet[holder] = newValue;
    }
    mapping(address => bool) public exemptFromFee;
    function changeExemptFromFee(address holder, bool newValue) external authorized{
        exemptFromFee[holder] = newValue;
    }

    mapping (address => bool) public isDividendExempt;
    function changeIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        
        if(exempt){
            dividendDistributor.setShare(holder, 0);
        }else{
            dividendDistributor.setShare(holder, _balances[holder]);
        }
    }
    function changeDistributionCriteria(uint256 newinPeriod, uint256 newMinDistribution) external authorized {
        dividendDistributor.setDistributionCriteria(newinPeriod, newMinDistribution);
    }
    function changeDistributorSettings(uint256 gas) external authorized {
        require(gas < 750000);
        distributorGas = gas;
    }

    //Open trade
    bool tradingOpen;
    function openTrade() public authorized {
        tradingOpen = true;
    }

    constructor() Auth(msg.sender){
        _balances[msg.sender] = _totalSupply; // Transfers all tokens to owner
        emit Transfer(address(0), msg.sender, _totalSupply);
        _allowances[address(this)][address(router)] = type(uint256).max;

        dividendDistributor = new DividendDistributor(address(router));

        isDividendExempt[pair] = true;
        isDividendExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;

        exemptFromMaxWallet[msg.sender] = true;
        exemptFromMaxWallet[address(this)] = true;

        exemptFromFee[msg.sender] = true;
        exemptFromFee[address(this)] = true;
        
        exemptFromMaxWallet[address(pair)] = true;
        isMarketPair[address(pair)] = true;
    }

    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function totalSupply() external view returns (uint256){return _totalSupply;}
    function decimals() external pure returns (uint8){return _decimals;}
    function symbol() external pure returns (string memory){return _symbol;}
    function name() external pure returns (string memory){return _name;}
    function getOwner() external view returns (address){return owner;}
    function balanceOf(address account) public view returns (uint256){return _balances[account];}
    function allowance(address _holder, address spender) external view returns (uint256){return _allowances[_holder][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external returns (bool){

        if(isMarketPair[recipient] || isMarketPair[msg.sender]){
            _transferFrom(msg.sender, recipient, amount);
        }else{
			require(_balances[recipient].add(amount) <= _maxWallet, "Transfer amount exceeds max wallet of recipient!");
            _basicTransfer(msg.sender, recipient, amount);
        }

		return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if(inSwapAndLiquify)
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            if(!authorizations[sender] && !authorizations[recipient]){
                require(tradingOpen, "Trading not open yet");
            }

            //Swap tokens on contract
            if(balanceOf(address(this)) >= _minimumTokensToSwap && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled){swapAndLiquify();}
            
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            uint256 finalAmount = (exemptFromFee[sender] || exemptFromFee[recipient]) ? amount : takeFee(sender, recipient, amount);

            if(!exemptFromMaxWallet[recipient])
                require(_balances[recipient].add(finalAmount) <= _maxWallet, "Transfer amount exceeds max wallet of recipient!");

            _balances[recipient] = _balances[recipient].add(finalAmount);


            // Dividend tracker
            if(!isDividendExempt[sender]) {
                try dividendDistributor.setShare(sender, _balances[sender]) {} catch {}
            }

            if(!isDividendExempt[recipient]) {
                try dividendDistributor.setShare(recipient, _balances[recipient]) {} catch {} 
            }

            try dividendDistributor.process(distributorGas) {} catch {}


            emit Transfer(sender, recipient, finalAmount);
                
            return true;
        }
    }

    function claim() public {
        dividendDistributor.claimDividend(msg.sender);
    }

    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        
        //If its a buy
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(BuyFeeTotal).div(100);
        }
        //If its a sell
        else if(isMarketPair[receiver]) {
            feeAmount = amount.mul(SellFeeTotal).div(100);
        }
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify() internal lockTheSwap{
        swapTokensForEth(balanceOf(address(this)));
        swapEthForBUSD(address(this).balance);
        //deposit dividend
        try dividendDistributor.deposit{value: RewardTokenBUSD.balanceOf(address(this))}() {} catch {}
    }

    function swapTokensForEth(uint256 tokenAmount) internal {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNBaddress;

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    function swapEthForBUSD(uint256 EthAmount) internal {
        // generate the uniswap pair path of weth -> busd
        address[] memory path = new address[](2);
        path[0] = WBNBaddress;
        path[1] = BUSDaddress;

        //router.WETH().approve(address(router), EthAmount);

        // make the swap
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: EthAmount}(
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapETHForBusd(EthAmount, path);
    }
    event SwapETHForBusd(
        uint256 amountIn,
        address[] path
    );
}