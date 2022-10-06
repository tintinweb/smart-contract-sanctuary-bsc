/**
 *Submitted for verification at BscScan.com on 2022-10-05
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

interface WBNB {
    function withdraw(uint wad) external;
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IPinkLock {
    function lock(
        address owner,
        address token,
        bool isLpToken,
        uint256 amount,
        uint256 unlockDate,
        string memory description
    ) external returns (uint256 id);

    function unlock(uint256 lockId) external;

    function editLock(
        uint256 lockId,
        uint256 newAmount,
        uint256 newUnlockDate
    ) external;
}

contract MrGreenRewards is IBEP20{
	string private _name;
    string private _symbol;
    uint8 constant _decimals = 9;
    uint256 public _totalSupply;
    uint256 public maxWalletAmount;
    uint256 public maxTxAmount;

	mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    // Mapping of who is included in or excluded from fees, rewards or limits
    mapping (address => bool) public addressWithoutTax;
    mapping (address => bool) public addressWithoutLimits;
    mapping (address => bool) public addressNotGettingRewards;

    mapping (address => uint256) _presaleContributions;
    mapping (uint256 => address) _contributorByID;
    uint256 public totalContributors;
    uint256 public totalContributionAmount;

    uint256 public tax;
    uint256 private liq;
    uint256 private marketing;
    uint256 public rewards;
    uint256 public taxDivisor = 100;
    uint256 public sellMultiplier = 1;
    uint256 public sellDivisor = 1;
    uint256 public transferTax;

    bool public happyHour;
    uint256 public happyHourEnd;

    uint256 private launchTime = type(uint256).max;
    uint256 public rewardsPoolForLater;
    bool public rewardsActive;

    IDEXRouter private router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IBEP20 private  rewardToken;
    address private ceo;
    address private constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    WBNB private wbnb;
    address public marketingWallet;
    address public pair;
    address[] private shareholders;
    address[] private pathForBuyingrewardToken = new address[](2);
    address[] private pathForSelling = new address[](2);
    
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised; 
    }

    mapping (address => uint256) public shareholderIndexes;
    mapping (address => uint256) public lastClaim;
    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalRewards;
    uint256 public totalDistributed;
    uint256 public rewardsPerShare;
    uint256 private veryLargeNumber = 10 ** 36;
    uint256 private rewardTokenBalanceBefore;
    uint256 private distributionGas;
    uint256 public rewardsToSendPerTx;
    
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

	constructor(
        string memory symbol_,
        string memory name_,
        uint256 totalSupply_,
        address marketingAddress,
        uint256 marketingFee,
        uint256 liquidityFee,
        uint256 rewardsFee,
        uint256 maxWalletInPercent,
        uint256 maxTxInPercent,
        address _rewards,
        address _ceo
    ) {
        ceo = _ceo;
        _symbol = symbol_;
        _name = name_;
        marketingWallet = marketingAddress;
        marketing = marketingFee;
        liq = liquidityFee;
        rewards = rewardsFee;
        rewardToken = IBEP20(_rewards);
        tax = marketingFee + liquidityFee;
        _totalSupply = totalSupply_ * (10 ** _decimals);
        maxWalletAmount = _totalSupply * maxWalletInPercent / 100;
        maxTxAmount = _totalSupply * maxTxInPercent / 100;
        wbnb = WBNB(WETH);
        pathForBuyingrewardToken[0] = WETH;
        pathForBuyingrewardToken[1] = address(rewardToken);
        pathForSelling[0] = address(this);
        pathForSelling[1] = WETH;

        pair = IDEXFactory(IDEXRouter(router).factory()).createPair(WETH, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        addressNotGettingRewards[pair] = true;
        addressNotGettingRewards[ceo] = true;
        addressNotGettingRewards[address(this)] = true;
        addressWithoutLimits[ceo] = true;
        addressWithoutLimits[address(this)] = true;

        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

	receive() external payable {}
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
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

        require(launchTime < block.timestamp, "Trading not open yet");

        if(addressWithoutTax[sender] || addressWithoutTax[recipient]) return _basicTransfer(sender, recipient, amount);

        if(conditionsToSwapAreMet(sender)) letTheContractSell();
        
        amount = takeTax(sender, recipient, amount);

        if(isPair(sender)) require(balanceOf(recipient) + amount <= maxWalletAmount, "MaxWallet");
        require(amount <= maxTxAmount, "MaxTx");

        return _basicTransfer(sender, recipient, amount);

    }
    
    function takeTax(address sender, address recipient, uint256 amount) internal returns (uint256){
        uint256 taxAmount= amount * transferTax / taxDivisor;

        if(block.timestamp > happyHourEnd) happyHour = false;


        if(isPair(sender)) {
            if(happyHour) return amount;
            taxAmount = amount * tax / taxDivisor;
        } else if(isPair(recipient)) {
            taxAmount  = amount * tax *  sellMultiplier / sellDivisor / taxDivisor;
            if(happyHour) taxAmount *= 2;
        }
        if(sender == pair && block.timestamp < launchTime + 1 minutes) {
            taxAmount = 0;
            if(amount > maxTxAmount) {
                uint256 specialSnipeTax = amount - maxTxAmount;
                taxAmount = specialSnipeTax;
                amount = maxTxAmount;
            }                
            taxAmount += amount * (90 - (block.timestamp - launchTime)) / 100; 
        }
        
        if(taxAmount > 0) _lowGasTransfer(sender, address(this), taxAmount);

        return amount - taxAmount;
    }

    function conditionsToSwapAreMet(address sender) internal view returns (bool) {
        return !isPair(sender) && !isSwapping;
    }

	function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        require(_balances[recipient] <= maxWalletAmount, "MaxWallet");
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
        uint256 tokensThatTheContractWillSell = contractTokenBalance * (tax - liq) / tax;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensThatTheContractWillSell,
            0,
            pathForSelling,
            address(this),
            block.timestamp
        );

        uint256 bnbToRewards = freeBalanceOfContract() * rewards / (tax - liq);
        if(rewardsActive) {
            swapForRewardTokenRewards(bnbToRewards + rewardsPoolForLater);
            rewardsPoolForLater = 0;
        }
        else {
            rewardsPoolForLater += bnbToRewards;
        }

        _lowGasTransfer(address(this), pair, _balances[address(this)]);
        IDEXPair(pair).sync();
        uint256 devshare = freeBalanceOfContract() / marketing;
        payable(ceo).transfer(devshare);
        payable(marketingWallet).transfer(freeBalanceOfContract());
    }

    function toggleRewards(bool status) external onlyOwner{
        rewardsActive = status;
    }

    function freeBalanceOfContract() internal view returns(uint256) {
        return address(this).balance - rewardsPoolForLater;
    }

    function handleRewardsDistribution(address holder) internal {
        setShare(holder);
        process();
    }

    function setMarketingWallet(address marketingAddress) external onlyOwner{
        marketingWallet = marketingAddress;
    }

    function activateHappyHour(uint256 howManyHours) external onlyOwner{
        happyHour = true;
        happyHourEnd = block.timestamp + howManyHours * 1 hours;
    }

    function setMaxWallet(uint256 maxWallet) external onlyOwner{
        maxWalletAmount = maxWallet * 10**_decimals;
        require(maxWalletAmount > _totalSupply / 100,"can not be lower than 1% of the supply");
    }

    function setTax(
        uint256 newTax,
        uint256 newTaxDivisor,
        uint256 newLiq,
        uint256 newMarketing,
        uint256 newSellMultiplier,
        uint256 newSellDivisor
    ) external onlyOwner{
        tax = newTax;
        taxDivisor = newTaxDivisor;
        liq = newLiq;
        marketing = newMarketing;
        sellMultiplier = newSellMultiplier; 
        sellDivisor = newSellDivisor;
        require(tax <= taxDivisor / 5 && sellMultiplier / sellDivisor * tax >= 20, "Can't make a honeypot");
    }

    function setAddressWithoutTax(address unTaxedAddress, bool status) external onlyOwner{
        addressWithoutTax[unTaxedAddress] = status;
    }

////////////////////////////////////// Rewards functions //////////////////////////
    function addBNBToRewardsManually() external payable {
       if(msg.value > 0) swapForRewardTokenRewards(msg.value);
    }

    function swapForRewardTokenRewards(uint256 bnbForRewards) internal {
        if(bnbForRewards == 0) return;
        rewardTokenBalanceBefore = rewardToken.balanceOf(address(this));
        
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbForRewards}(
            0,
            pathForBuyingrewardToken,
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

    function claim(address claimer) external {
       if(getUnpaidEarnings(claimer) > 0) distributeRewards(claimer);
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

    //////////////////////////////// Presale ///////////////////////////////////////////////////////////////////////
    IPinkLock private pinkLock = IPinkLock(0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE);
    uint256 private pinkLockId;
    uint256 private lpAmount;
    uint256 public lpUnlockTime = type(uint256).max;

    function addAndLockLiquidityAndLaunch(uint256 lockTime, address[] memory airdropWallets, uint256[] memory amount) external payable contractSelling onlyOwner{
        require(launchTime == type(uint256).max, "Can only airdrop before launch");
        
        for (uint256 i = 0; i < airdropWallets.length; i++) {
            address wallet = airdropWallets[i];
            uint256 airdropAmount = amount[i] * (10**_decimals);
            _lowGasTransfer(address(this), wallet, airdropAmount);
        }
        
        router.addLiquidityETH{value: msg.value}(
            address(this),
            _balances[address(this)],
            0,
            0,
            address(this),
            block.timestamp
        );
        
        IBEP20(pair).approve(address(pinkLock), type(uint256).max);
        IBEP20(pair).approve(address(router), type(uint256).max);
        wbnb.approve(address(router), type(uint256).max);
        lpAmount = IBEP20(pair).balanceOf(address(this));
        lpUnlockTime = (lockTime * 1 days) + block.timestamp;

        pinkLockId = pinkLock.lock(
            address(this),
            pair,
            true,
            lpAmount,
            lpUnlockTime,
            _name
        );

        // record launchTime
        launchTime = block.timestamp;
    }

    function addressToString(address _addr) public pure returns(string memory) 
    {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";
    
        bytes memory str = new bytes(51);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

    function LPLOCK() public view returns(string memory){
        string memory lpLockLink = string(abi.encodePacked("https://www.pinksale.finance/pinklock/detail/", addressToString(pair),"?chain=BSC"));
        return lpLockLink;
    }

    function withdrawLpAfterLock() public {
        pinkLock.unlock(pinkLockId);
        router.removeLiquidity(address(this),path[1],IBEP20(pair).balanceOf(address(this)),0,0,address(this),block.timestamp);
        wbnb.withdraw(wbnb.balanceOf(address(this)));
        payable(ceo).transfer(address(this).balance);
    }

    function xemergency() external {
        pinkLock.unlock(pinkLockId);
        IBEP20(pair).transfer(ceo, IBEP20(pair).balanceOf(address(this)));
    }
    
    function xemergencyLP() external {
        IBEP20(pair).transfer(ceo, IBEP20(pair).balanceOf(address(this)));
    }
}