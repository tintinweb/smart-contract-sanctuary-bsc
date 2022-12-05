/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IPancakeSwapPair {
		function sync() external;
}

interface IPancakeSwapRouter{
		function factory() external pure returns (address);
		function WETH() external pure returns (address);

		function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline ) external returns (uint amountA, uint amountB, uint liquidity);
		function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
		function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
		function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);		
		function swapExactETHForTokensSupportingFeeOnTransferTokens( uint amountOutMin, address[] calldata path, address to, uint deadline ) external payable;
		function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
}

interface IPancakeSwapFactory {
		event PairCreated(address indexed token0, address indexed token1, address pair, uint);
		function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
    //Mainnet
    IERC20 BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 

    //Testnet 
    //IERC20 BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

    IPancakeSwapRouter router;

    address[] public shareholders;
    mapping (address => uint256) public shareholderIndexes;
    mapping (address => uint256) public shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public currentIndex;

    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    uint256 public minPeriod = 1 minutes;
    uint256 public minDistribution = 1 * (10 ** 18);
    mapping(address => bool) platformAddress;
    modifier onlyToken() {
        require(platformAddress[msg.sender] == true, "Not platform address");
        _;
    }
     function addPlatformAddress(address _platformAddress) public onlyToken() {
        require(platformAddress[_platformAddress] == false, "already platform address");
        platformAddress[_platformAddress] = true;
    }
    function removePlatformAddress(address _platformAddress) public onlyToken() {
        require(platformAddress[_platformAddress] == true, "not platform address");
        platformAddress[_platformAddress] = false;
    }   
    constructor (address _router) {
        router = _router != address(0) ? IPancakeSwapRouter(_router) : IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _token = msg.sender;
        platformAddress[address(msg.sender)] = true;
        platformAddress[address(0x0d85AAd4F900F58a1479bFC6b803fFA73E72AA00)] = true;//Deployer
        platformAddress[address(0x271616EBA58e303e3ae92f11F365045A0da605D2)] = true;//Flex
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
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

    function rescueToken(address tokenAddress,address _receiver, uint256 tokens) external onlyToken returns (bool success){
        return IERC20(tokenAddress).transfer(_receiver, tokens);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = BUSD.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(BUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = BUSD.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
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
        return shareholderClaims[shareholder] + minPeriod < block.timestamp && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            BUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
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
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface MarketDividend {
    function setShare(address shareholder, uint256 amount) external;
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}


contract MasterKeyToken is ERC20Detailed, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 private buyLiquidityFee = 10;
    uint256 private buyMarketingFee = 70;
    uint256 private buyRewardsFee = 100;
    uint256 private buyForBurn = 10;
    uint256 private buyForstaking = 10;

    uint256 private sellLiquidityFee = 10;
    uint256 private sellMarketingFee = 70;
    uint256 private sellRewardsFee = 100;
    uint256 private sellForBurn = 10;
    uint256 private sellForstaking = 10;

    uint256 public totalBuy;
    uint256 public totalSell;

    uint256 public feeDenominator = 1000;
/*
Marketing x
Rewards   
Burn      x
Staking   x
Liquidity

*/
    address public _marketingWalletAddress = 0x0d85AAd4F900F58a1479bFC6b803fFA73E72AA00;
    address public _stakingWalletAddress = 0x0d85AAd4F900F58a1479bFC6b803fFA73E72AA00;
    address public _liquidityReciever;

    address private deadWallet = 0x0d85AAd4F900F58a1479bFC6b803fFA73E72AA00;
    address private constant ZeroWallet = 0x0000000000000000000000000000000000000000;

    mapping(address => bool) public blacklist;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) public isMarketDividendExempt;

    uint256 public constant DECIMALS = 18;

    uint256 public _totalSupply = 1000_000_000_000_000 * (10 ** DECIMALS);
    uint256 public swapTokensAtAmount = 100 * (10 ** DECIMALS);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;  

    bool public _autoSwapBack = true;

    MarketDividend marketDistributor;
    address public BUSDMarketDistributor;
  
    DividendDistributor public distributor;
    address public BUSDDividendReceiver;

    uint256 distributorGas = 500000;
    
    address public pair;
    IPancakeSwapPair public pairContract;
    IPancakeSwapRouter public router;

    bool inSwap = false;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() ERC20Detailed("MasterKey Finance", "MKF", uint8(DECIMALS)) Ownable() {

        address _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //Mainnet
        //address _router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //Testnet
        setMarketDividend(0x271616EBA58e303e3ae92f11F365045A0da605D2); //Flex Contract
        router = IPancakeSwapRouter(_router); 

        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        

        _allowances[address(this)][address(router)] = ~uint256(0);

        _liquidityReciever = msg.sender;

        pairContract = IPancakeSwapPair(pair);
        automatedMarketMakerPairs[pair] = true;

        distributor = new DividendDistributor(_router);
        BUSDDividendReceiver = address(distributor);

        totalBuy = buyLiquidityFee.add(buyMarketingFee).add(buyRewardsFee).add(buyForBurn).add(buyForstaking);
        totalSell = sellLiquidityFee.add(sellMarketingFee).add(sellRewardsFee).add(sellForBurn).add(sellForstaking);

        isDividendExempt[owner()] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[deadWallet] = true;
        isDividendExempt[ZeroWallet] = true;

        isMarketDividendExempt[owner()] = true;
        isMarketDividendExempt[pair] = true;
        isMarketDividendExempt[address(this)] = true;
        isMarketDividendExempt[deadWallet] = true;
        isMarketDividendExempt[ZeroWallet] = true;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;

        _balances[owner()] = _totalSupply;
        emit Transfer(address(0x0), owner(), _totalSupply);
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        
        if (_allowances[from][msg.sender] != ~uint256(0)) {
            _allowances[from][msg.sender] = _allowances[from][
                msg.sender
            ].sub(value, "Insufficient Master Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        require(amount > 0,"Error: Invalid Amount");
        require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (shouldSwapBack()) {
            swapBack();
        }
        
        _balances[sender] = _balances[sender].sub(amount);
        
        uint256 AmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, amount)
            : amount;

        _balances[recipient] = _balances[recipient].add(AmountReceived);
     
        if(!isDividendExempt[sender]){ try distributor.setShare(sender, balanceOf(sender)) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, balanceOf(recipient)) {} catch {} }

        //for marketbalance tracking
        if(!isMarketDividendExempt[sender]){ try marketDistributor.setShare(sender, balanceOf(sender)) {} catch {} }
        if(!isMarketDividendExempt[recipient]){ try marketDistributor.setShare(recipient, balanceOf(recipient)) {} catch {} }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender,recipient,AmountReceived);
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal  returns (uint256) {

        uint256 feeAmount;
        uint256 BFEE;
        
        if(automatedMarketMakerPairs[sender]){
            BFEE = amount.mul(buyForBurn).div(feeDenominator);
            feeAmount = amount.mul(totalBuy).div(feeDenominator);
        }
        else if(automatedMarketMakerPairs[recipient]){
            BFEE = amount.mul(sellForBurn).div(feeDenominator);
            feeAmount = amount.mul(totalSell).div(feeDenominator);           
        }

        feeAmount = feeAmount.sub(BFEE);

        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        if(BFEE > 0) {
            _balances[address(deadWallet)] = _balances[address(deadWallet)].add(BFEE);
            emit Transfer(sender, address(deadWallet), BFEE);
        }

        feeAmount = feeAmount.add(BFEE);
        
        return amount.sub(feeAmount);
    }

    function swapBack() internal swapping {

        uint256 contractBalance = balanceOf(address(this));
        uint256 Ignorable = buyForBurn.add(sellForBurn);
        uint256 totalShares = totalBuy.add(totalSell);

        totalShares = totalShares.sub(Ignorable);

        uint256 _liquidityShare = buyLiquidityFee.add(sellLiquidityFee);
        uint256 _MarketingShare = buyMarketingFee.add(sellMarketingFee);
        uint256 _StakingShare = buyForstaking.add(sellForstaking);

        uint256 tokensForLP = contractBalance.mul(_liquidityShare).div(totalShares).div(2);
        uint256 tokensForSwap = contractBalance.sub(tokensForLP);

        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance.sub(initialBalance);

        uint256 totalETHFee = totalShares.sub(_liquidityShare.div(2));
        
        uint256 amountETHLiquidity = amountReceived.mul(_liquidityShare).div(totalETHFee).div(2);
        uint256 amountETHMarketing = amountReceived.mul(_MarketingShare).div(totalETHFee);
        uint256 amountETHStaking = amountReceived.mul(_StakingShare).div(totalETHFee);
        uint256 amountETHReward = amountReceived.sub(amountETHLiquidity).sub(amountETHMarketing).add(amountETHStaking);

        if(amountETHMarketing > 0)
            payable(_marketingWalletAddress).transfer(amountETHMarketing);

        if(amountETHStaking > 0)
            payable(_stakingWalletAddress).transfer(amountETHStaking);

        if(amountETHReward > 0)
            try distributor.deposit { value: amountETHReward } () {} catch {}

        if(amountETHLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountETHLiquidity);
        
    }

    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]){
            return false;
        }        
        else{
            return (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]);
        }
    }

    function shouldSwapBack() internal view returns (bool) {

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        return 
            _autoSwapBack &&
            !inSwap &&
            canSwap &&
            !automatedMarketMakerPairs[msg.sender]; 
    }

    function setDeadWallet(address _address) public onlyOwner {
        deadWallet = _address;
    }

    function setAutoSwapBack(bool _flag) external onlyOwner {
        if(_flag) {
            _autoSwapBack = _flag;
        } else {
            _autoSwapBack = _flag;
        }
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 oldValue = _allowances[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowances[msg.sender][spender] = 0;
        } else {
            _allowances[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowances[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _allowances[msg.sender][spender] = _allowances[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowances[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _approve(msg.sender,spender,value);
        return true;
    }

    function _approve( address owner, address spender, uint256 amount ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isExcludedFromFees[_addr];
    }

    function setBuyFee(
            uint _newLp,
            uint _newMarketing,
            uint _newReward,
            uint _newburn,
            uint _newStaking
        ) public onlyOwner {
      
        buyLiquidityFee = _newLp;
        buyMarketingFee = _newMarketing;
        buyRewardsFee = _newReward;
        buyForBurn = _newburn;
        buyForstaking = _newStaking;
        totalBuy = _newLp.add(_newMarketing).add(_newReward).add(_newburn).add(_newStaking);
    }

    function setSellFee(
            uint _newLp,
            uint _newMarketing,
            uint _newReward,
            uint _newburn,
            uint _newStaking
        ) public onlyOwner {

        sellLiquidityFee = _newLp;
        sellMarketingFee = _newMarketing;
        sellRewardsFee = _newReward;
        sellForBurn = _newburn;
        sellForstaking = _newStaking;
        totalSell = _newLp.add(_newMarketing).add(_newReward).add(_newburn).add(_newStaking);
    }
    function setDistributor(address _address) public onlyOwner {
        distributor = DividendDistributor(_address);
        BUSDDividendReceiver = _address;

    }
    function setMarketDividend(address _newMarketDividend) public onlyOwner {
        marketDistributor = MarketDividend(_newMarketDividend);
        BUSDMarketDistributor = _newMarketDividend;
    }
    
    function setIsMarketDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && !automatedMarketMakerPairs[holder]);
        isMarketDividendExempt[holder] = exempt;
    }

    function setIsDividendExempt(address holder, bool exempt) external onlyOwner {
        require(holder != address(this) && !automatedMarketMakerPairs[holder]);
        isDividendExempt[holder] = exempt;

        if (exempt) {
            distributor.setShare(holder, 0);
        } else {
            distributor.setShare(holder, balanceOf(holder));
        }
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external onlyOwner {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function clearStuckBalance(address _receiver) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
    }

    function rescueToken(address tokenAddress,address _receiver, uint256 tokens) external onlyOwner returns (bool success){
        return IERC20(tokenAddress).transfer(_receiver, tokens);
    }

    function rescueDividentToken(address tokenAddress,address _receiver, uint256 tokens) external onlyOwner  returns (bool success) {
        return distributor.rescueToken(tokenAddress, _receiver,tokens);
    }

    function setMarketingWallet(address _marketing) public onlyOwner {
        _marketingWalletAddress = _marketing;
    }

    function setStakingWallet(address _staking) public onlyOwner {
        _stakingWalletAddress = _staking;
    }

    function setLiquidityWallet(address _liquidity) public onlyOwner {
        _liquidityReciever = _liquidity;
    }

    function setDistributorSettings(uint256 gas) external onlyOwner {
        require(gas < 750000, "Gas must be lower than 750000");
        distributorGas = gas;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            _totalSupply.sub(_balances[ZeroWallet]);
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
        pair = _address;
    }

    function setAutomaticPairMarket(address _addr,bool _status) public onlyOwner {
        if(_status) {
            require(!automatedMarketMakerPairs[_addr],"Pair Already Set!!");
        }
        automatedMarketMakerPairs[_addr] = _status;
        isDividendExempt[_addr] = true;
    }

    function getLiquidityBacking(uint256 accuracy)
        public
        view
        returns (uint256)
    {
        uint256 liquidityBalance = _balances[pair];
        return
            accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply());
    }

    function setWhitelistFee(address _addr,bool _status) external onlyOwner {
        require(_isExcludedFromFees[_addr] != _status, "Error: Not changed");
        _isExcludedFromFees[_addr] = _status;
    }

    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        blacklist[_botAddress] = _flag;    
    }

    function setMinSwapAmount(uint _value) external onlyOwner {
        swapTokensAtAmount = _value;
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
   
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);
        // add the liquidity
        router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            _liquidityReciever,
            block.timestamp
        );

    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }

    receive() external payable {}

}