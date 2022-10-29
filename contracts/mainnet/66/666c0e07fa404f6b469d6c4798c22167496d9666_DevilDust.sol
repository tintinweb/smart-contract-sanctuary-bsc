/**
 *Submitted for verification at BscScan.com on 2022-10-29
*/

/*  
 * Devildust - $DEVIL
 * 
 * https://t.me/ddportal
 * 
 * Written by: MrGreenCrypto
 * Co-Founder of CodeCraftrs.com
 * 
 * SPDX-License-Identifier: None
 */

pragma solidity 0.8.17;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
    function factory() external pure returns (address);

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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

interface IDEXPair {    
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}
contract DevilDust is IBEP20{
	string private constant _name = "DevilDust";
    string private constant _symbol = "DD";
    uint8 constant _decimals = 9;
    uint256 public _totalSupply = 666_666_666 * 10**_decimals;
    
    uint256 public maxWalletAmount = _totalSupply / 100;
    uint256 public maxTxAmount = _totalSupply / 100;

	mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public addressWithoutTax;
    mapping (address => bool) public addressWithoutLimits;
    mapping (address => bool) public addressNotGettingRewards;

    uint256 public tax = 10;
    uint256 private liq = 2;
    uint256 private marketing = 4;
    uint256 public rewards = 4;
    uint256 public taxDivisor = 100;
    uint256 public transferTax = 10;
    uint256 public sellMultiplier = 1;
    uint256 public sellDivisor = 1;

    bool public happyHour;
    uint256 public happyHourEnd;

    bool public rewardsActive;

    IDEXRouter private constant router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IBEP20 private rewardToken = IBEP20(0x0D536B28Cb33226DBab5B3B086b2c257F859E16B);
    address private constant ceo = 0x57daA248938F75A7793598808112aD17684f3d28;
    address private constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant marketingWallet = 0x1E3d91fCB2fadF4f7C042f2f1260C8c5B88939BA;
    address public pair;
    address[] private shareholders;
    address[] private pathForBuyingRewardToken = new address[](2);
    address[] private pathForSelling = new address[](2);
    
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised; 
    }

    mapping (address => uint256) public shareholderIndexes;
    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalRewards;
    uint256 public totalDistributed;
    uint256 public rewardsPerShare;
    uint256 private veryLargeNumber = 10 ** 36;
    uint256 private rewardTokenBalanceBefore;
    uint256 public rewardsToSendPerTx = 5;
    
    uint256 public minTokensForRewards = 10_000 * (10 ** _decimals);
    uint256 public minDistribution = 1 ether;
    uint256 private currentIndex;

    address[] public path = new address[](2);
    bool private isSwapping;

    modifier onlyOwner() {
		if(msg.sender != ceo) return;
		_;
	}

    modifier contractSelling() {
		isSwapping = true;
		_;
        isSwapping = false;
	}

	constructor() {
        pathForBuyingRewardToken[0] = WETH;
        pathForBuyingRewardToken[1] = address(rewardToken);
        pathForSelling[0] = address(this);
        pathForSelling[1] = WETH;

        pair = IDEXFactory(IDEXRouter(router).factory()).createPair(WETH, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        addressNotGettingRewards[pair] = true;
        addressNotGettingRewards[ceo] = true;
        addressNotGettingRewards[address(this)] = true;
        addressWithoutLimits[ceo] = true;
        addressWithoutLimits[address(this)] = true;

        _balances[ceo] = _totalSupply;
        emit Transfer(address(0), ceo, _totalSupply);
    }

	receive() external payable {}
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
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

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

	function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
			require(_allowances[sender][msg.sender] >= amount, "Insufficient Allowance");
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

	function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if
        (   isSwapping ||
            addressWithoutLimits[sender] ||
            addressWithoutLimits[recipient] ||
            sender == ceo ||
            recipient == ceo
        ) return _lowGasTransfer(sender, recipient, amount);


        if(addressWithoutTax[sender] || addressWithoutTax[recipient]) return _basicTransfer(sender, recipient, amount);

        if(conditionsToSwapAreMet(recipient)) letTheContractSell();
        
        amount = takeTax(sender, recipient, amount);

        if(!isPair(recipient)) require(balanceOf(recipient) + amount <= maxWalletAmount, "MaxWallet");
        
        require(amount <= maxTxAmount, "MaxTx");

        return _basicTransfer(sender, recipient, amount);
    }
    
    function takeTax(address sender, address recipient, uint256 amount) internal returns (uint256){
        uint256 taxAmount = amount * transferTax / taxDivisor;

        if(block.timestamp > happyHourEnd) happyHour = false;

        if(isPair(sender)) {
            if(happyHour) return amount;
            taxAmount = amount * tax / taxDivisor;
        } else if(isPair(recipient)) {
            taxAmount  = amount * tax *  sellMultiplier / sellDivisor / taxDivisor;
            if(happyHour) taxAmount *= 2;
        }
        
        if(taxAmount > 0) _lowGasTransfer(sender, address(this), taxAmount);

        return amount - taxAmount;
    }
    function conditionsToSwapAreMet(address recipient) internal view returns (bool) {
        return isPair(recipient) && _balances[address(this)] > 0;
    }                           

	function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);

        if(!addressNotGettingRewards[sender]) handleRewardsDistribution(sender);
        if(!addressNotGettingRewards[recipient]) handleRewardsDistribution(recipient); 

        return true;
    }

    function _lowGasTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function isPair(address addressToCheckIfPair) internal view returns (bool) {
        return addressToCheckIfPair == pair;
    }

    function letTheContractSell() internal {
        uint256 contractTokenBalance = _balances[address(this)] > maxTxAmount ? maxTxAmount : _balances[address(this)];
        if(contractTokenBalance == 0) return;
        uint256 tokensThatTheContractWillSell = contractTokenBalance * (tax - liq) / tax;
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensThatTheContractWillSell,
            0,
            pathForSelling,
            address(this),
            block.timestamp
        );

        _lowGasTransfer(address(this), pair, _balances[address(this)]);
        IDEXPair(pair).sync();

        uint256 bnbToMarketing = (address(this).balance - balanceBefore) * marketing / (marketing + rewards);
        uint256 devShare = bnbToMarketing / marketing;
        uint256 marketingShare = bnbToMarketing - devShare;
        payable(ceo).transfer(devShare);
        payable(marketingWallet).transfer(marketingShare);

        if(rewardsActive) swapForRewardTokenRewards();
    }

    function toggleRewards(bool status) external onlyOwner{
        rewardsActive = status;
        if(rewardsActive) swapForRewardTokenRewards();
    }

    function handleRewardsDistribution(address holder) internal {
        setShare(holder);
        process();
    }

    function setRewardToken(address rewardTokenAddress) external onlyOwner{
        require(!rewardsActive, "Don't");
        rewardToken = IBEP20(rewardTokenAddress);
    }

    function activateHappyHour(uint256 howManyHours) external onlyOwner{
        happyHour = true;
        happyHourEnd = block.timestamp + howManyHours * 1 hours;
    }

    function setMaxWallet(uint256 maxWallet) external onlyOwner{
        maxWalletAmount = maxWallet * 10**_decimals;
        require(maxWalletAmount > _totalSupply / 100,"can not be lower than 1% of the supply");
    }

    function setMaxTx(uint256 maxTx) external onlyOwner{
        maxTxAmount = maxTx * 10**_decimals;
        require(maxTxAmount > _totalSupply / 100,"can not be lower than 1% of the supply");
    }

    function setTax(
        uint256 newTransferTax,
        uint256 newLiq,
        uint256 newRewards,
        uint256 newMarketing,
        uint256 newSellMultiplier,
        uint256 newSellDivisor
    ) external onlyOwner{
        transferTax = newTransferTax;
        liq = newLiq;
        marketing = newMarketing;
        rewards = newRewards;
        sellMultiplier = newSellMultiplier; 
        sellDivisor = newSellDivisor;
        tax = marketing + liq + rewards;        
        require(tax <= taxDivisor / 5 && tax * sellMultiplier / sellDivisor <= 20, "Can't make a honeypot");
    }

    function setAddressWithoutTax(address unTaxedAddress, bool status) external onlyOwner{
        addressWithoutTax[unTaxedAddress] = status;
    }

    function setAddressWithoutRewards(address unRewardedAddress, bool status) external onlyOwner{
        addressNotGettingRewards[unRewardedAddress] = status;
    }

    function rescueBNB() external onlyOwner {
        payable(ceo).transfer(address(this).balance);
    }

////////////////////////////////////// Rewards functions //////////////////////////

    function swapForRewardTokenRewards() internal {
        uint256 bnbForRewards = address(this).balance;
        if(bnbForRewards == 0) return;
        rewardTokenBalanceBefore = rewardToken.balanceOf(address(this));
        
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbForRewards}(
            0,
            pathForBuyingRewardToken,
            address(this),
            block.timestamp
        );

        uint256 newrewardTokenBalance = rewardToken.balanceOf(address(this));
        if(newrewardTokenBalance <= rewardTokenBalanceBefore) return;
        
        uint256 amount = newrewardTokenBalance - rewardTokenBalanceBefore;
        totalRewards += amount;
        rewardsPerShare = rewardsPerShare + (veryLargeNumber * amount / totalShares);
    }

    function setShare(address shareholder) internal {
        // rewards for the past are paid out   //maybe replace with return for small holder to save gas
        if(shares[shareholder].amount >= minTokensForRewards) distributeRewards(shareholder);

        // hello shareholder
        if(
            shares[shareholder].amount == 0 
            && _balances[shareholder] >= minTokensForRewards
        ) 
        addShareholder(shareholder);
        
        // goodbye shareholder
        if(
            shares[shareholder].amount >= minTokensForRewards
            && _balances[shareholder] < minTokensForRewards
        ){
            totalShares = totalShares - shares[shareholder].amount;
            shares[shareholder].amount = 0;
            removeShareholder(shareholder);
            return;
        }

        // already shareholder, just different balance
        if(_balances[shareholder] >= minTokensForRewards){
        totalShares = totalShares - shares[shareholder].amount + _balances[shareholder];
        shares[shareholder].amount = _balances[shareholder];
        shares[shareholder].totalExcluded = getTotalRewardsOf(shares[shareholder].amount);
        }
    }

    function process() internal {
        uint256 shareholderCount = shareholders.length;
        if(shareholderCount <= rewardsToSendPerTx) return;

        for(uint256 rewardsSent = 0; rewardsSent < rewardsToSendPerTx; rewardsSent++) {
            if(currentIndex >= shareholderCount) currentIndex = 0;
            distributeRewards(shareholders[currentIndex]);
            currentIndex++;
        }
    }

    function claim() external {
       if(getUnpaidEarnings(msg.sender) > 0) distributeRewards(msg.sender);
    }

    function distributeRewards(address shareholder) internal {
        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount < minDistribution) return;

        rewardToken.transfer(shareholder,amount);
        totalDistributed = totalDistributed + amount;
        shares[shareholder].totalRealised = shares[shareholder].totalRealised + amount;
        shares[shareholder].totalExcluded = getTotalRewardsOf(shares[shareholder].amount);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        uint256 shareholderTotalRewards = getTotalRewardsOf(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if(shareholderTotalRewards <= shareholderTotalExcluded) return 0;
        return shareholderTotalRewards - shareholderTotalExcluded;
    }

    function getTotalRewardsOf(uint256 share) internal view returns (uint256) {
        return share * rewardsPerShare / veryLargeNumber;
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


 function airdropSomePeopleBeforeLaunch(address[] memory airdropWallets, uint256[] memory amount) external onlyOwner{
        for (uint256 i = 0; i < airdropWallets.length; i++) {
            address wallet = airdropWallets[i];
            uint256 airdropAmount = amount[i] * (10**_decimals);
            _basicTransfer(msg.sender, wallet, airdropAmount);
        }
    }
}