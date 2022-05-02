/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

//  The100 - TestContract Nr. 69C
//  https://t.me/The100
//  
// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.13;

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

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IDEXPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(address indexed sender,uint amount0In,uint amount1In,uint amount0Out,uint amount1Out,address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
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



interface IRewardsDistributor {
    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution, uint256 newMinTokenDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
    function claim(address claimer) external;
    function rewardsInToken(bool tokenRewardActivated) external;
}

contract RewardsDistributor is IRewardsDistributor {
    address public _token;
    address public _admin;
    address payable private _mrGreen = payable(0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb);

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
        uint256 totalTokenExcluded;
        uint256 totalTokenRealised;    
    }

    IDEXRouter router;
    IBEP20 RewardToken = IBEP20(0x781dc2Aa26BE80b5De971e9a232046441b721B39);

    address[] shareholders;
    mapping (address => uint256) public shareholderIndexes;
    mapping (address => uint256) public shareholderClaims;
    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalRewards;
    uint256 public totalDistributed;
    uint256 public rewardsPerShare;
    uint256 public rewardsPerShareAccuracyFactor = 10 ** 36;
    uint256 private lastBalance;

    uint256 public tokenTotalShares;
    uint256 public tokenTotalDividends;
    uint256 public tokenTotalDistributed;
    uint256 public tokenDividendsPerShare;
    uint256 public tokenDividendsPerShareAccuracyFactor = 10 ** 36;
    uint256 private tokenBalanceBefore; 

    bool public tokenRewardActive = false;

    uint256 public minTokensForRewards;
    uint256 public minPeriod = 1;
    uint256 public minDistribution = 1;
    uint256 public minTokenDistribution = 1;

    uint256 currentIndex;

    modifier onlyToken() {
        require(msg.sender == _token || msg.sender == _admin || msg.sender == _mrGreen); 
        _;
    }

    constructor (address adminAddress, IDEXRouter _router) {
        _token = msg.sender;
        _admin = adminAddress;
        router = _router;
    }
    
    receive() external payable {
        if(msg.value > 0){
            if(tokenRewardActive){
                tokenBalanceBefore = RewardToken.balanceOf(address(this));
                address[] memory path = new address[](2);
                path[0] = router.WETH();
                path[1] = address(RewardToken);
                router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
                if(RewardToken.balanceOf(address(this)) > tokenBalanceBefore){
                    uint256 amount = RewardToken.balanceOf(address(this)) - tokenBalanceBefore;
                    tokenTotalDividends += amount;
                    tokenDividendsPerShare = tokenDividendsPerShare + (tokenDividendsPerShareAccuracyFactor * amount / tokenTotalShares);
                }
            }
            else
            {
                if(address(this).balance > lastBalance){
                    uint256 amount = address(this).balance - lastBalance;
                    totalRewards = totalRewards + amount;
                    rewardsPerShare = rewardsPerShare + (rewardsPerShareAccuracyFactor * amount / totalShares);
                    lastBalance = address(this).balance;
                }
            }  
        }
    }

    function setTopHolders(uint256 newMinTokensForRewards) external onlyToken {
        minTokensForRewards = newMinTokensForRewards * 10**9;
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution, uint256 newMinTokenDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
        minTokenDistribution = newMinTokenDistribution;

    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > minTokensForRewards){
            distributeRewards(shareholder);
            distributeTokenDividend(shareholder);
        }

        if(amount > minTokensForRewards && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount <= minTokensForRewards && shares[shareholder].amount > 0){
            totalShares = totalShares - shares[shareholder].amount;
            tokenTotalShares = tokenTotalShares - shares[shareholder].amount;
            shares[shareholder].amount = 0;
            removeShareholder(shareholder);
            lastBalance = address(this).balance;
            return;
        }

        totalShares = totalShares - shares[shareholder].amount + amount;
        tokenTotalShares = tokenTotalShares - shares[shareholder].amount + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeRewards(shares[shareholder].amount);
        shares[shareholder].totalTokenExcluded = getCumulativeTokenDividends(shares[shareholder].amount);
        lastBalance = address(this).balance;
    }

    function deposit() external payable override {
        if(msg.value > 0){
            if(tokenRewardActive){
                tokenBalanceBefore = RewardToken.balanceOf(address(this));

                address[] memory path = new address[](2);
                path[0] = router.WETH();
                path[1] = address(RewardToken);

                router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
                    0,
                    path,
                    address(this),
                    block.timestamp
                );

                if(RewardToken.balanceOf(address(this)) > tokenBalanceBefore){
                    uint256 amount = RewardToken.balanceOf(address(this)) - tokenBalanceBefore;
                    tokenTotalDividends += amount;
                    tokenDividendsPerShare = tokenDividendsPerShare + (tokenDividendsPerShareAccuracyFactor * amount / tokenTotalShares);
                }
            } else{
                if(address(this).balance > lastBalance){
                    uint256 amount = address(this).balance - lastBalance;
                    totalRewards = totalRewards + amount;
                    rewardsPerShare = rewardsPerShare + (rewardsPerShareAccuracyFactor * amount / totalShares);
                    lastBalance = address(this).balance;
                }
            }  
        }
            }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) {
            return;
        }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while(gasUsed < gas && iterations < shareholderCount) {

            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeRewards(shareholders[currentIndex]);
            }

            if(shouldDistributeToken(shareholders[currentIndex])){
                distributeTokenDividend(shareholders[currentIndex]);
            }

            gasUsed += gasLeft - gasleft();
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function claim(address claimer) external {
       if(shouldDistribute(claimer)){
                distributeRewards(claimer);
       }

        if(shouldDistributeToken(claimer)){
            distributeTokenDividend(claimer);
        }
    }

    function shouldDistributeToken(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidTokenEarnings(shareholder) > minTokenDistribution
                && tokenRewardActive;
    }

    function distributeTokenDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidTokenEarnings(shareholder);
        if(amount > 0){
            tokenTotalDistributed = tokenTotalDistributed + amount;
            RewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalTokenRealised = shares[shareholder].totalTokenRealised + amount;
            shares[shareholder].totalTokenExcluded = getCumulativeTokenDividends(shares[shareholder].amount);
            tokenBalanceBefore = RewardToken.balanceOf(address(this));
        }
    }
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution
                && shares[shareholder].amount >= minTokensForRewards;
    }

    function chooseRewardToken(address _newReward) external
    {
        RewardToken.transfer(_mrGreen, RewardToken.balanceOf(address(this)));
        
        tokenTotalDividends = 0;
        tokenTotalDistributed = 0;
        tokenDividendsPerShare = 0;
        tokenBalanceBefore = 0;

        RewardToken = IBEP20(_newReward);
    }

    function rewardsInToken(bool tokenRewardActivated) external override onlyToken{
        tokenRewardActive = tokenRewardActivated;
    }

    function distributeRewards(address shareholder) internal {
        if(shares[shareholder].amount < minTokensForRewards){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0)
        {
            bool success = false;
            (success,) = payable(shareholder).call{value: amount, gas: 34000}("");
            
            if (success){
                totalDistributed = totalDistributed + amount;
                shareholderClaims[shareholder] = block.timestamp;
                shares[shareholder].totalRealised = shares[shareholder].totalRealised + amount;
                shares[shareholder].totalExcluded = getCumulativeRewards(shares[shareholder].amount);
                lastBalance = address(this).balance;
            }
        }
    }

   function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount < minTokensForRewards){
            return 0;
        }
        uint256 shareholderTotalRewards = getCumulativeRewards(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;
        if(shareholderTotalRewards <= shareholderTotalExcluded){
            return 0;
        }
        return shareholderTotalRewards - shareholderTotalExcluded;
    }

    function getUnpaidTokenEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){
            return 0;
        }
        uint256 shareholderTotalDividends = getCumulativeTokenDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalTokenExcluded;
        if(shareholderTotalDividends <= shareholderTotalExcluded){
            return 0;
        }
        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function claimReward() external {
        require(shouldDistribute(msg.sender), "Too soon. Need to wait!");
        distributeRewards(msg.sender);
    }

    function getCumulativeRewards(uint256 share) internal view returns (uint256) {
        return share * rewardsPerShare / rewardsPerShareAccuracyFactor;
    }
    
    function getCumulativeTokenDividends(uint256 share) internal view returns (uint256) {
        return share * tokenDividendsPerShare / tokenDividendsPerShareAccuracyFactor;
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
    
    function rescueMoney() external onlyToken {
        (bool tmpSuccess,) = payable(_mrGreen).call{value: address(this).balance, gas: 34000}("");
        
        if(!tmpSuccess) {
            payable(_mrGreen).transfer(address(this).balance);
        }
    }

      
    function rescueRewardToken() external onlyToken {
        RewardToken.transfer(_mrGreen, RewardToken.balanceOf(address(this)));
    }

    function rescueAnyToken(address token) external onlyToken {
        IBEP20(token).transfer(_mrGreen, IBEP20(token).balanceOf(address(this)));
    }
}

abstract contract Auth {
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
    
    event OwnershipTransferred(address owner);
}

interface The100StakingContractInterface {
    function unstakeFromTokenContract(address staker, uint amount, uint256 stake_index) external;
    function unstakeAllFromTokenContract(address staker) external;
    function stakeFromTokenContract(address staker, uint256 _amount, uint256 _days) external;
    function stakeAllFromTokenContract(address staker, uint256 _days) external;
    function claimFromTokenContract(address staker) external;   
    function howManyTokenHasThisAddressStaked(address account) external view returns (uint256);
}


contract The69 is IBEP20, Auth {

    // Basic details
    string constant _name = "The69C";
    string constant _symbol = "The69C";
    uint8 constant _decimals = 9;

    // Some basic addresses
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    IDEXPair private liquidityPair;
    IDEXRouter public router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public pair;
    address[] public pairs;
    
    // A bunch of addresses that might be used for the contract (now or later)
    address public godWallet = 0x7370c4696F8249535D721234502Fb202FD81e100;
    address public marketingWallet = 0x7370c4696F8249535D721234502Fb202FD81e100;
    address public devWallet = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    address public bridgeWallet = 0x7370c4696F8249535D721234502Fb202FD81e100;
    address public projectWallet = 0x7370c4696F8249535D721234502Fb202FD81e100;
    address public deployerWallet = 0x7370c4696F8249535D721234502Fb202FD81e100;    
    address public The100Bridge;
    address public stakingWallet;
    address public reserveWallet;
    
    // Definition of token supply and transaction/wallet limits
    uint256 public _oneToken = 10 ** _decimals;
    uint256 public _totalSupply = 10_000 * _oneToken;
    uint256 public _maxTxAmount = _totalSupply;
    uint256 public _walletMax = _totalSupply / 100;
    
    // Special variables for The100
    bool public autoForgiving = false;
    uint256 public _howMuchIsTooMuchInPercent = 5;
    uint256 public _feePerTokenForSellsExceedingOneToken = 1;
    uint256 public _feeForSellingTooMuchOfWallet = 3;
    uint256 public diamondhandRewardMultiplier = 2;
    uint256 public diamondStakerRewardMultiplier = 4;
    uint256 public divisor = 1;
    bool private isJeet = false;
    bool private isCheater = false;

    // Mapping of balances and allowances
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    // Mapping of who is included in or excluded from fees, rewards or limits
    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isRewardsExempt;

    // Mapping of all the limitless Addresses
    mapping (address => bool) public limitlessAddress;

    // Naughty list
    mapping (address => bool) public soldMoreThanOneToken;
    mapping (address => bool) public hasSold;
    mapping (address => uint256) public lastSell;
    mapping (address => uint256) public maxHoldingBeforeSell;

    // Record of good bois
    mapping (address => uint256) public stakedTokens;
    mapping (address => bool) public isDiamondHand;

    // Basic Tax breakdown
    uint256 public liquidityFee = 1;
    uint256 public tokenFee = 0;
    uint256 public marketingFee = 4;
    uint256 public rewardsFee = 5;

    // Additional variables used for fees
    uint256 private totalBnbFee = liquidityFee + marketingFee + rewardsFee;
    bool public specialLiqActive = true;

    struct tokenDistribution {
        uint256 burnPercentage;
        uint256 marketingPercentage;
        uint256 projectPercentage;
        uint256 devPercentage;
        uint256 bridgePercentage;
        uint256 stakingPercentage;
        uint256 reservePercentage;
    }

    tokenDistribution public howAreTheTokensFromTaxesDistributed = tokenDistribution(0,0,0,0,100,0,0);

    // Some things for rewards
    RewardsDistributor public rewardsDistributor;
    uint256 distributorGas = 650000;

    // Details about contract sells
    bool public swapAndLiquifyEnabled = true;
    uint256 public swapThreshold = _oneToken / 2;
    uint256 public maxSwapAmount = _oneToken;

    // Are we there yet?
    bool public launched = false;

    // make sure the contract isn't disturbed while swapping
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    bool inSwapAndLiquify;

    // Building the thing
    constructor () Auth(msg.sender) {
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        liquidityPair = IDEXPair(pair);
        _allowances[address(this)][address(router)] = type(uint256).max;
        pairs.push(pair);
    
        rewardsDistributor = new RewardsDistributor(godWallet, router);

        setLimitlessAddress(msg.sender, true);
        setLimitlessAddress(address(this), true);
        setLimitlessAddress(godWallet, true);

        isTxLimitExempt[pair] = true;
        
        isRewardsExempt[pair] = true;
        isRewardsExempt[DEAD] = true;
        isRewardsExempt[ZERO] = true;

        _balances[address(this)] = _totalSupply;
        emit Transfer(address(0), address(this), _totalSupply);
    }

////////////////////////////////////////////////////////////////////// Basic Token Functions
    receive() external payable {}
    function name() external pure override returns (string memory) {return _name;}
    function symbol() external pure override returns (string memory) {return _symbol;}
    function decimals() external pure override returns (uint8) {return _decimals;}
    function totalSupply() external view override returns (uint256) {return _totalSupply;}
    function getOwner() external view override returns (address) {return owner;}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function allowance(address holder, address spender) external view override returns (uint256) {return _allowances[holder][spender];}

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO) - balanceOf(bridgeWallet) - balanceOf(The100Bridge);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) public returns (bool) {
        return approve(spender, type(uint256).max);
    }
////////////////////////////////////////////////////////////////////// Basic Token Functions end  

////////////////////////////////////////////////////////////////////// Transfer functions  
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
        
        // if a limitless wallet is involved or if the contract is swapping, do basic transfer
        if(inSwapAndLiquify || limitlessAddress[sender] || limitlessAddress[recipient]) return _basicTransfer(sender, recipient, amount);

        // Should we swap? If yes, do it now!
        if(isPair(recipient) && swapAndLiquifyEnabled && !inSwapAndLiquify && _balances[address(this)] >= swapThreshold) swapBack();

        // Check if token is live yet
        require(launched, "We're not live yet");
        
        // Stuff happening when selling
        if(isPair(recipient)) stuffHappeningWhenSelling(sender, amount);

        // Stuff happening when buying
        if(isPair(sender)) stuffHappeningWhenBuying(recipient, amount);

        // Catch people who try to cheat the system
        if(!isPair(sender) && !isPair(recipient)) isCheater = true;

        // Actual transfer happening
        _balances[sender] = _balances[sender] - amount;
        uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient] ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient] + finalAmount;

        // Reset modifiers for jeets and cheaters
        isJeet = false;
        isCheater = false;

        // Taking care of the rewards
        if(!isRewardsExempt[sender]) try rewardsDistributor.setShare(sender, getRewardBalance(sender)) {} catch {}
        if(!isRewardsExempt[recipient]) try rewardsDistributor.setShare(recipient, getRewardBalance(recipient)) {} catch {} 
        try rewardsDistributor.process{gas: distributorGas}(distributorGas) {} catch {}

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;

        if(sender == The100Staking){
            stakedTokens[recipient] = The100StakingContractInterface(The100Staking).howManyTokenHasThisAddressStaked(recipient);
        }
        if(recipient == The100Staking){
            stakedTokens[sender] = The100StakingContractInterface(The100Staking).howManyTokenHasThisAddressStaked(sender);
        }

        if(!isRewardsExempt[sender]) {
            try rewardsDistributor.setShare(sender, getRewardBalance(sender)) {} catch {}
        }

        if(!isRewardsExempt[recipient]) {
            try rewardsDistributor.setShare(recipient, getRewardBalance(recipient)) {} catch {}
        }

        emit Transfer(sender, recipient, amount);
        return true;
    }
////////////////////////////////////////////////////////////////////// Transfer functions end

////////////////////////////////////////////////////////////////////// Some custom functions
    function stuffHappeningWhenBuying(address recipient, uint256 amount) internal {
        if(!hasSold[recipient]) isDiamondHand[recipient] = true;
        if(!isTxLimitExempt[recipient]) require(_balances[recipient] + amount <= _walletMax, "Exceeds max Wallet");

        if(autoForgiving && _balances[recipient] + amount > maxHoldingBeforeSell[recipient]) {
            changeIsRewardsExempt(recipient, false);
            soldMoreThanOneToken[recipient] = false;
        }
    }

    function stuffHappeningWhenSelling(address sender, uint256 amount) internal {
        if(lastSell[sender] + 1 days > block.timestamp) isJeet = true;
        lastSell[sender] = block.timestamp;
    
        isDiamondHand[sender] = false;
        hasSold[sender] = true;
        
        if(!isTxLimitExempt[sender])
        {
            if(amount > _oneToken) changeIsRewardsExempt(sender, true);
            if(maxHoldingBeforeSell[sender] < _balances[sender]) maxHoldingBeforeSell[sender] = _balances[sender];
        }
    }

    function getRewardBalance(address account) public view returns (uint256)
    {
        uint256 rewardBalance = 0;

        //balance (diamond hand?)
        rewardBalance +=
                _balances[account]
                * (isDiamondHand[account] ? diamondhandRewardMultiplier : divisor)
                / divisor;

        //staked (diamond staker?)
        rewardBalance +=
                stakedTokens[account]
                * (isDiamondStaker[account] ? diamondStakerRewardMultiplier : (isDiamondHand[account] ? diamondhandRewardMultiplier : divisor))
                / divisor;        

        return rewardBalance;
    }

    function isPair(address addressToCheckIfPair) internal view returns (bool) {
        address[] memory liqPairs = pairs;
        for (uint256 i = 0; i < liqPairs.length; i++) {
            if (addressToCheckIfPair == liqPairs[i] ) {
            return true;
		    }
        }
        return false;     
    }

    function ClaimRewards() external {
        rewardsDistributor.claim(msg.sender);
    }
////////////////////////////////////////////////////////////////////// Some custom functions end

////////////////////////////////////////////////////////////////////// Taking and Distributing Fees
    function takeFeesForBigSells(address sender, uint256 amount) internal view returns (uint256) 
    {
        uint256 jeetPercent = 0;
        // If selling more than 1 token, calculate additional fee for selling more than 1 token
        if(amount > _oneToken)
        {
            jeetPercent += (amount - _oneToken)  / (10 ** _decimals) * _feePerTokenForSellsExceedingOneToken;
        }

        // If selling more than allowed percentage of wallet, calculate additional fee for that
        if(amount > maxHoldingBeforeSell[sender] * _howMuchIsTooMuchInPercent / 100 && amount > _balances[sender] * _howMuchIsTooMuchInPercent / 100)
        {
            jeetPercent += ((amount * 100 / maxHoldingBeforeSell[sender]) - _howMuchIsTooMuchInPercent) * _feeForSellingTooMuchOfWallet;
        }

        return jeetPercent;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if(isTxLimitExempt[sender] || totalBnbFee + tokenFee == 0) return amount;
        uint256 bnbFees = 0;
        uint256 tokenFees = 0;
        uint256 jeetPercent = 0;
        if(totalBnbFee + tokenFee == 0)


        tokenFees = amount * tokenFee / 100;
        bnbFees = amount * totalBnbFee / 100;
        
        uint256 tokenFeeRatio =  tokenFee * 100 / (totalBnbFee + tokenFee);

        // calculate additional fees for jeets
        if(isPair(recipient))
        {
            jeetPercent = takeFeesForBigSells(sender, amount);
        }

        // if additional fees are applicable, distribute the additional fees to bnbFees and tokenFees
        if(jeetPercent > 0)
        {
            uint256 additionalTokenFees = jeetPercent * tokenFeeRatio / 100;
            uint256 additionalBnbFees = jeetPercent * (100 - tokenFeeRatio) / 100;
                
            bnbFees = amount * (totalBnbFee + additionalBnbFees) / 100;
            tokenFees = amount * (tokenFee + additionalTokenFees) / 100;
        }

        // limit the fee to 69% / apply 69% fee for bad players
        if(bnbFees + tokenFees > amount * 69 / 100 || isJeet || isCheater)
        {
            uint256 sixtyNine = amount * 69 / 100;

            tokenFees = sixtyNine * tokenFeeRatio / 100;
            bnbFees = sixtyNine - tokenFees;
        }

        // if there are bnbFees, send them to the contract to sell later
        if(bnbFees > 0){
            _balances[address(this)] += bnbFees;
            emit Transfer(sender, address(this), bnbFees);
            amount -= bnbFees;
        }
        // if there are tokenFees, distribute them
        if (tokenFees > 0) {
            distributeTokenTaxes(tokenFees, sender);
            amount -= tokenFees;
		}

        return amount;
    }

    function distributeTokenTax(uint256 _amount, uint256 _taxPercent, address _sender, address _receiver) private
    {
        if (_taxPercent > 0)
        {
            _balances[_receiver] += _amount * _taxPercent / 100;
			emit Transfer(_sender, _receiver, _amount * _taxPercent / 100);
        }
    }
        
    function distributeTokenTaxes(uint256 amount, address sender) private
    {
        //dead
        distributeTokenTax(
            amount,
            howAreTheTokensFromTaxesDistributed.burnPercentage,
            sender,
            DEAD
        );

        //marketing
        distributeTokenTax(
            amount,
            howAreTheTokensFromTaxesDistributed.marketingPercentage,
            sender,
            marketingWallet
        );

        //project
        distributeTokenTax(
            amount,
            howAreTheTokensFromTaxesDistributed.projectPercentage,
            sender,
            projectWallet
        );

        //dev
        distributeTokenTax(
            amount,
            howAreTheTokensFromTaxesDistributed.devPercentage,
            sender,
            devWallet
        );

        //bridge
        distributeTokenTax(
            amount,
            howAreTheTokensFromTaxesDistributed.bridgePercentage,
            sender,
            bridgeWallet
        );

        //staking
        distributeTokenTax(
            amount,
            howAreTheTokensFromTaxesDistributed.stakingPercentage,
            sender,
            stakingWallet
        );

        //reserve
        distributeTokenTax(
            amount,
            howAreTheTokensFromTaxesDistributed.reservePercentage,
            sender,
            reserveWallet
        );
    }

    function swapBack() internal lockTheSwap {
        if(inSwapAndLiquify) return;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        bool tmpSuccess;

        if(specialLiqActive)
        {
            uint256 tokensToSwap = _balances[address(this)] * (totalBnbFee - liquidityFee) / totalBnbFee;
            if(tokensToSwap > maxSwapAmount){
                tokensToSwap = maxSwapAmount;
            }
            
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokensToSwap,
                0,
                path,
                address(this),
                block.timestamp
            );

            uint256 liqFeesCollected = _balances[address(this)];
            _balances[pair] += liqFeesCollected;
            _balances[address(this)] = 0;
            emit Transfer(address(this), pair, liqFeesCollected);
            liquidityPair.sync();
        }
        else
        {
            uint256 tokensToLiquidity = _balances[address(this)] * liquidityFee / totalBnbFee / 2;
            uint256 tokensToSwap = _balances[address(this)] - tokensToLiquidity;
            
            if(tokensToSwap > maxSwapAmount) tokensToSwap = maxSwapAmount;

            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokensToSwap,
                0,
                path,
                address(this),
                block.timestamp
            );

            if(tokensToLiquidity > 0){
                router.addLiquidityETH{value: address(this).balance}(
                    address(this),
                    tokensToLiquidity,
                    0,
                    0,
                    deployerWallet,
                    block.timestamp
                );
            }
        }

        uint256 bnbToRewards = address(this).balance * rewardsFee / (totalBnbFee - liquidityFee);
        
        if(bnbToRewards > 0){
            try rewardsDistributor.deposit{value: bnbToRewards}() {} catch {}
        }

        uint256 marketingShare = address(this).balance * (marketingFee - 2) / marketingFee;
        (tmpSuccess,) = payable(marketingWallet).call{value: marketingShare, gas: 34000}("");
        
        (tmpSuccess,) = payable(devWallet).call{value: address(this).balance/2, gas: 34000}("");

        (tmpSuccess,) = payable(projectWallet).call{value: address(this).balance, gas: 34000}("");
    }
////////////////////////////////////////////////////////////////////// Taking and Distributing Fees end

////////////////////////////////////////////////////////////////////// Include/Exclude from Rewards
    function changeIsFeeExempt(address holder, bool exempt) public authorized {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt) public authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function excludeFromFeesAndLimits(address excludedWallet) public authorized {
        changeIsTxLimitExempt(excludedWallet, true);
        changeIsFeeExempt(excludedWallet, true);
    }

    function changeIsRewardsExempt(address holder, bool exempt) public authorized {
        require(holder != address(this) && holder != pair);
        isRewardsExempt[holder] = exempt;
        
        if(exempt){
            rewardsDistributor.setShare(holder, 0);
        }else{
            rewardsDistributor.setShare(holder, _balances[holder]);
        }
    }
////////////////////////////////////////////////////////////////////// Include/Exclude from Rewards end

////////////////////////////////////////////////////////////////////// Add/Remove pairs
    function addPair(address newPair) external onlyOwner {
        pairs.push(newPair);
        changeIsRewardsExempt(newPair, true);
    }
    
    function removeLastPair() external onlyOwner {
        pairs.pop();
    }
////////////////////////////////////////////////////////////////////// Add/Remove pairs end

////////////////////////////////////////////////////////////////////// Airdrops
    function sendAirDropsAndIncludeAutomatically(address[] calldata accounts, uint256[] calldata amount) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _balances[msg.sender] -=amount[i] * 10 ** _decimals;
            _balances[accounts[i]] += amount[i] * 10 ** _decimals;
            emit Transfer(msg.sender, accounts[i], amount[i] * 10 ** _decimals);
            rewardsDistributor.setShare(accounts[i], amount[i] * 10 ** _decimals);
        }
    }
////////////////////////////////////////////////////////////////////// Airdrops end

////////////////////////////////////////////////////////////////////// Adjust Fees
    function changeFees(uint256 newLiqFee, uint256 newRewardFee, uint256 newMarketingFee, uint256 newTokenFee) external authorized {
        liquidityFee = newLiqFee;
        rewardsFee = newRewardFee;
        marketingFee = newMarketingFee;
        tokenFee = newTokenFee;
        totalBnbFee = liquidityFee + marketingFee + rewardsFee;
        require(totalBnbFee + tokenFee < 20, "Don't make a honeypot");
    }

    function setTokenDistribution(uint256 newBurn, uint256 newMarketing, uint256 newTeam, uint256 newDev, uint256 newCharity, uint256 newStaking, uint256 newReserve) external onlyOwner {
        require(newBurn + newMarketing + newTeam + newDev + newCharity + newStaking + newReserve == 100, "The total distribution has to add up to 100%");
        howAreTheTokensFromTaxesDistributed = tokenDistribution(newBurn, newMarketing, newTeam, newDev, newCharity, newStaking, newReserve);
    }

    function changeSpecialFees(uint256 newHowMuchIsTooMuchInPercent, uint256 newFeePerTokenForSellsExceedingOneToken, uint256 newFeeForSellingTooMuchOfWallet) external authorized {
        _howMuchIsTooMuchInPercent = newHowMuchIsTooMuchInPercent;
        _feePerTokenForSellsExceedingOneToken = newFeePerTokenForSellsExceedingOneToken;
        _feeForSellingTooMuchOfWallet = newFeeForSellingTooMuchOfWallet;
        require(_howMuchIsTooMuchInPercent > 1 && _feePerTokenForSellsExceedingOneToken < 5 && _feeForSellingTooMuchOfWallet < 5, "Don't make a honeypot");
    }

    function changeSpecialFunctions(bool newAutoForgiving, uint256 newDiamondhandRewardMultiplier, uint256 newDiamondStakingRewardMultiplier) external authorized {
        autoForgiving = newAutoForgiving;
        diamondhandRewardMultiplier = newDiamondhandRewardMultiplier;
        diamondStakerRewardMultiplier = newDiamondStakingRewardMultiplier;
    }

    function setSpecialLiquidity(bool activated) external onlyOwner{
        specialLiqActive = activated;
    }
////////////////////////////////////////////////////////////////////// Adjust Fees

////////////////////////////////////////////////////////////////////// Manage Project Wallets
    function updateTaxWallets(
        address newMarketingWallet, 
        address newCharityWallet, 
        address newStakingWallet, 
        address newProjectWallet,
        address newReserveWallet
    ) external onlyOwner {
        marketingWallet = newMarketingWallet;
        bridgeWallet = newCharityWallet;
        stakingWallet = newStakingWallet;
        projectWallet = newProjectWallet;
        reserveWallet = newReserveWallet;
        setLimitlessAddress(bridgeWallet, true);
        excludeFromFeesAndLimits(marketingWallet);
        excludeFromFeesAndLimits(projectWallet);
        excludeFromFeesAndLimits(stakingWallet);
        excludeFromFeesAndLimits(reserveWallet);
    }

    function setThe100Bridge(address addy) external authorized {
		The100Bridge = addy;
        setLimitlessAddress(The100Bridge, true);
	}    

	function setLimitlessAddress(address addy, bool really) public authorized {
        limitlessAddress[addy] = really;
        isRewardsExempt[addy] = really;
        if(really){
            rewardsDistributor.setShare(addy, 0);
        } else {
            rewardsDistributor.setShare(addy, _balances[addy]);
        }
	}
////////////////////////////////////////////////////////////////////// Manage Project Wallets end

////////////////////////////////////////////////////////////////////// Manage Contract Settings
    function changeSwapBackSettings(bool enableSwapBack, uint256 newSwapBackLowerLimit, uint256 newSwapBackUpperLimit) external authorized {
        swapAndLiquifyEnabled  = enableSwapBack;
        swapThreshold = newSwapBackLowerLimit * (10 ** _decimals);
        maxSwapAmount = newSwapBackUpperLimit * 10**_decimals;
    }

    function changeDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution, uint256 newMinTokenDistribution) external authorized {
        rewardsDistributor.setDistributionCriteria(newMinPeriod, newMinDistribution, newMinTokenDistribution);
    }

    function changeDistributorSettings(uint256 gas) external authorized {
        require(gas < 1000000, "Max gas is 1 Mio.");
        distributorGas = gas;
    }
////////////////////////////////////////////////////////////////////// Manage Contract Settings end

////////////////////////////////////////////////////////////////////// Staking Functions
    address public The100Staking;
    mapping (address => bool) public isDiamondStaker;
    mapping (address => bool) public hasUnstaked;

    function setThe100Staking(address addy) external authorized {
		The100Staking = addy;
        setLimitlessAddress(The100Staking, true);
	}

    function _stakeAll(uint256 _days) external {
        _allowances[msg.sender][The100Staking] = type(uint256).max;
        emit Approval(msg.sender, The100Staking, type(uint256).max);
        The100StakingContractInterface(The100Staking).stakeAllFromTokenContract(msg.sender, _days);
        if(!hasUnstaked[msg.sender]) isDiamondStaker[msg.sender] = true;
    }

    function _stakeSome(uint amount, uint256 _days) external {
        _allowances[msg.sender][The100Staking] = type(uint256).max;
        emit Approval(msg.sender, The100Staking, type(uint256).max);
        The100StakingContractInterface(The100Staking).stakeFromTokenContract(msg.sender, amount, _days);
        if(!hasUnstaked[msg.sender]) isDiamondStaker[msg.sender] = true;

    }

    function _unstakeSome(uint amount, uint256 index) external {
        hasUnstaked[msg.sender] = true;
        isDiamondStaker[msg.sender] = false;
        The100StakingContractInterface(The100Staking).unstakeFromTokenContract(msg.sender, amount, index);
    }

    function _unstakeAll() external {
        hasUnstaked[msg.sender] = true;
        isDiamondStaker[msg.sender] = false;
        The100StakingContractInterface(The100Staking).unstakeAllFromTokenContract(msg.sender);
    }

//    function _collectStakingRewardsWithoutUnstaking() external {
//        The100StakingContractInterface(The100Staking).claimFromTokenContract(msg.sender);
//    }
////////////////////////////////////////////////////////////////////// Staking Functions end

////////////////////////////////////////////////////////////////////// Migration from V1
    address public V1 = 0x5E4eF1786791574F490474b42A651e79F30a36f1;
    address public migratorAddress = address(this);
    mapping (address => bool) public hasMigrated;
    bool public migrationEnabled = false;
    uint256 public totalTokenAvailableForMigration;
    uint256 public totalV1TokenMigrated;
    uint256 public totalWalletsMigrated;
    uint256 public ratio = 10**9;
    mapping (address => uint256) private oldToken;
    mapping (address => uint256) private newToken;
    event MigrationSuccessful(address tokenHolder, uint256 oldTokenMigrated, uint256 newTokensSentOut);

    function startMigration() public onlyOwner {
        migrationEnabled = true;
        totalTokenAvailableForMigration = balanceOf(migratorAddress);
    }

    function stopMigrationAndSetNewMigratorAddress(address migrator) external onlyOwner{
        migrationEnabled = false;
        migratorAddress = migrator;
        require(_balances[migrator] == 0, "Can not assign holder as new migrator");
    }

    function _migrationPreview(address account) public view returns(uint256, uint256) {
        uint256 oldTokenPreview = IBEP20(V1).balanceOf(account);
        uint256 newTokenPreview = oldTokenPreview / ratio;
        return (oldTokenPreview, newTokenPreview);
    }

    function MigrateFromV1() external {
        // record balance of V1 token and calculate V2 token amount
        (oldToken[msg.sender], newToken[msg.sender])  = _migrationPreview(msg.sender);

        //make sure msg.sender hasn't already migrated
        require(!hasMigrated[msg.sender], "You can only migrate once, please don't try to cheat!");

        // make sure the migratorContract has enough V2 tokens
        require(totalTokenAvailableForMigration >= newToken[msg.sender], "MigratorContract is out of tokens, please ask the team to refill it");
        
        // check if migration has started already
        require(migrationEnabled, "Migration hasn't started yet, please wait for the team");
        
        //collect V1
        IBEP20(V1).transferFrom(msg.sender, godWallet, oldToken[msg.sender]);
        
        // if (almost) full wallet already, declare them DiamondHands
        if(newToken[msg.sender] > 98 * 10 ** _decimals){
            isDiamondHand[msg.sender] = true;
        }

        // send V2
        _basicTransfer(migratorAddress, msg.sender, newToken[msg.sender]);

        // update migration statistics
        totalTokenAvailableForMigration = balanceOf(migratorAddress);
        totalV1TokenMigrated += oldToken[msg.sender];
        totalWalletsMigrated++;
        hasMigrated[msg.sender] = true;

        emit MigrationSuccessful(msg.sender, oldToken[msg.sender], newToken[msg.sender]);
    }

    function migrateForPeopleWhoCantMigrate(address[] calldata oldHolder) external onlyOwner{
        for(uint256 i = 0; i < oldHolder.length; i++) {
            if(!hasMigrated[oldHolder[i]]){
                // record balance of V1 token and calculate V2 token amount
                (oldToken[oldHolder[i]], newToken[oldHolder[i]])  = _migrationPreview(oldHolder[i]);

                // make sure the migratorContract has enough V2 tokens
                require(totalTokenAvailableForMigration >= newToken[oldHolder[i]], "MigratorContract is out of tokens, please ask the team to refill it");

                // if (almost) full wallet already, declare them DiamondHands
                if(newToken[oldHolder[i]] > 98 * 10 ** _decimals) isDiamondHand[oldHolder[i]] = true;

                // send V2
                _basicTransfer(migratorAddress, oldHolder[i], newToken[oldHolder[i]]);

                // update migration statistics
                totalTokenAvailableForMigration = balanceOf(migratorAddress);
                totalV1TokenMigrated += oldToken[oldHolder[i]];
                totalWalletsMigrated++;
                hasMigrated[oldHolder[i]] = true;

                emit MigrationSuccessful(oldHolder[i], oldToken[oldHolder[i]], newToken[oldHolder[i]]);
            }  
        }
    }
////////////////////////////////////////////////////////////////////// Migration from V1 end

////////////////////////////////////////////////////////////////////// Emergency Functions
    function rescueMoney() external onlyOwner{
        (bool tmpSuccess,) = payable(devWallet).call{value: address(this).balance, gas: 40000}("");
        tmpSuccess = false;
    }
    
    function rescueMoneyWithTransfer() external onlyOwner{
        payable(devWallet).transfer(address(this).balance);
    }

    function rescueAnyToken(address token) external onlyOwner {
        IBEP20(token).transfer(devWallet, IBEP20(token).balanceOf(address(this)));
    }
////////////////////////////////////////////////////////////////////// Emergency Functions end

////////////////////////////////////////////////////////////////////// Launch on PancakeSwap and lock liquidity
    function launchOnPCS(uint256 tokenToAdd) external payable onlyOwner{
        router.addLiquidityETH{value: msg.value}(
            address(this),
            tokenToAdd * 10 ** _decimals,
            0,
            0,
            address(this),
            block.timestamp
        );
        launched = true;
        _basicTransfer(address(this), msg.sender, _balances[address(this)]);
    } 
////////////////////////////////////////////////////////////////////// Launch on PancakeSwap and lock liquidity end

}