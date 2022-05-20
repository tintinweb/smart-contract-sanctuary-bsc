/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * BEP20 standard interface.
 */
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
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
}

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
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

contract XPASS is IBEP20, Auth {
    using SafeMath for uint256;

    struct buybackShare {
        uint256 amount;
        uint256 totalRealised;
        uint256 holderSince;
    }

    address[] buybackShareHolders;
    address public REWARD = 0x337C218f16dBc290fB841Ee8B97A74DCdAbfeDe8;
    address WBNB          = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD          = 0x000000000000000000000000000000000000dEaD;
    address ZERO          = 0x0000000000000000000000000000000000000000;

    string _name = "X-PASS";
    string _symbol = "XPASS";
    uint8 _decimals = 0;

    uint256 _totalSupply = 1;

    //MAX BUY/SELL SET TO 100% *** CHANGE THIS IF NEEDED ***
    uint256 public _maxTxAmount            = (_totalSupply * 100) / 100;

    //MAX WALLET HOLDING OF 100% *** CHANGE THIS IF NEEDED ***
    uint256 public _maxWalletToken         = (_totalSupply * 100) / 100;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) public _isBlacklisted;
    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isTimelockExempt;
    mapping (address => bool) public isDividendExempt;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => buybackShare) public buybackShares;

    uint256 public totalBurned            = 0;

    //LIQUIDITY SETTINGS
    uint256 targetLiquidity               = 20;
    uint256 targetLiquidityDenominator    = 100;

    //EXTERNAL BUYBACK CONFIG
    uint256 public totalShares = _totalSupply;
    bool public shouldDistributeBuyback   = true;
    uint256 currentIndex;
    
    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    bool public tradingOpen = false;

    //BURNING MECHANISM
    bool public realBurn = false;

    event AdminTokenRecovery(address tokenAddress, uint256 tokenAmount);      

    uint256 distributorGas = 500000;

    //COOLDOWN & TIMER FUNCTIONALITY
    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 30;
    mapping (address => uint) private cooldownTimer;

    //HOLDER SINCE MECHANISM
    uint256 public holderSinceMinimum = _totalSupply * 1 / 10000; // 0.001% of supply

    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        //router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // TESTNET ONLY
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // MAINNET ONLY
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = uint256(-1);      
        _balances[msg.sender]     = _totalSupply;

        emit Transfer(ZERO, msg.sender, _totalSupply); 

        isDividendExempt[pair]          = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD]          = true;

        totalShares = getCirculatingSupply();
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external view override returns (uint8) { return _decimals; }
    function symbol() external view override returns (string memory) { return _symbol; }
    function name() external view override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }


    function buybackPercentageShares(address shareholder) public view returns (uint256) {
        if (!isDividendExempt[shareholder]) {
            uint _numerator  = buybackShares[shareholder].amount * 10 ** (5);
            uint _quotient =  ((_numerator / totalShares) + 5) / 10;
            uint256 percentageOfThisGuy = _quotient;
            return percentageOfThisGuy;
        } else { return 0; }
    }

    function getUserIndex(uint256 _index) public view returns (address) {
        address userIndex = buybackShareHolders[_index];
        return userIndex;
    }

    function partialBuybackPercentageShares(address shareholder, uint256 _partialTotalShares) public view returns (uint256) {
        if (!isDividendExempt[shareholder]) {
            uint _numerator  = buybackShares[shareholder].amount * 10 ** (5);
            uint _quotient =  ((_numerator / _partialTotalShares) + 5) / 10;
            uint256 percentageOfThisGuy = _quotient;
            return percentageOfThisGuy;
        } else { return 0; }
    }
    
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = buybackShareHolders.length;
        buybackShareHolders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        buybackShareHolders[shareholderIndexes[shareholder]] = buybackShareHolders[buybackShareHolders.length-1];
        shareholderIndexes[buybackShareHolders[buybackShareHolders.length-1]] = shareholderIndexes[shareholder];
        buybackShareHolders.pop();
    }

    function resetTotalShares() internal {
        totalShares = 0;
        uint256 shareholderCount = buybackShareHolders.length;
        uint256 iterations = 0;
        while(iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
            address thisGuy = buybackShareHolders[currentIndex];
            totalShares = totalShares.add(buybackShares[thisGuy].amount);
            currentIndex++;
            iterations++;
        }
    }

    function setHolderSince(address shareholder, uint256 _blockNumber) internal {
        buybackShares[shareholder].holderSince = _blockNumber;
        resetTotalShares();
    }

    function setShare(address shareholder, uint256 amount) public onlyOwner {
        if(amount > 0 && buybackShares[shareholder].amount == 0) {
            addShareholder(shareholder);
        }else if(amount == 0 && buybackShares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }
        buybackShares[shareholder].amount = amount;
        resetTotalShares();
    }

    function buyBackNow(uint256 _amountBNBToLiquify) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = REWARD;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amountBNBToLiquify}(
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function setShouldDistributeBuyback(bool _shouldDistribute) public onlyOwner {
        shouldDistributeBuyback = _shouldDistribute;
    }

    //HERE IS WHERE THE MAGIC HAPPENS
    function externalBuyBack(uint256 amountPercentage, uint256 _fromHolder, uint256 _toHolder) external onlyOwner {
        //CHECKS SHAREHOLDERS LENGTH
        uint256 shareholderCount = 0;
        uint256 iterations = 0;
        uint256 partialTotalAmount = 0;
        
        if (_fromHolder == 0 && _toHolder == 0) { 
            shareholderCount = buybackShareHolders.length;
            iterations = 0;
            currentIndex = 0;
        }   
        else if (_fromHolder > 0 || _toHolder > 0) { 
            require(_fromHolder < _toHolder && _toHolder <= buybackShareHolders.length);
            iterations = _fromHolder;
            currentIndex = _fromHolder;
            shareholderCount = _toHolder;
            while(
                iterations < shareholderCount) {
                address thisGuy = buybackShareHolders[currentIndex];
                uint256 amountOfThisGuy = buybackShares[thisGuy].amount;
                if (!isDividendExempt[thisGuy]) { 
                    partialTotalAmount = partialTotalAmount.add(amountOfThisGuy);
                }
                currentIndex++;
                iterations++;
            }
            iterations = _fromHolder;
            currentIndex = _fromHolder;
            shareholderCount = _toHolder;
        }

        //CHECKS IF PERCENTAGE OR SHAREHOLDERS COUNT GREATER THAN ZERO
        require(amountPercentage > 0, "amountPercentage cannot be ZERO.");
        require(shareholderCount > 0, "There are no shareholders to distribute.");

        uint256 amountBNB = address(this).balance;
        uint256 amountBNBToLiquify = amountBNB.mul(amountPercentage).div(100);

        //CHECKS BALANCE BEFORE THE EXTERNAL BUYBACK HAPPENS
        uint256 tokenBalanceBefore = IBEP20(REWARD).balanceOf(address(this));

        //BUYBACK HAPPENS HERE
        buyBackNow(amountBNBToLiquify);
        
        //CHECKS NEW BALANCE AND DEFINE HOW MANY TOKENS SHOULD BE DISTRIBUTED
        uint256 tokenBalanceNow = IBEP20(REWARD).balanceOf(address(this));
        uint256 tokensToDistribute = tokenBalanceNow.sub(tokenBalanceBefore);

        tokenBalanceNow = _balances[address(this)];
        if (shouldDistributeBuyback) {
            //WHILE STARTS HERE
            
            while(
                iterations < shareholderCount 
                && IBEP20(REWARD).balanceOf(address(this)) > tokenBalanceBefore
                && tokensToDistribute > 0
                ) {
                if(currentIndex >= shareholderCount){
                    currentIndex = 0;
                }
                address thisGuy = buybackShareHolders[currentIndex];

                uint256 percentageOfThisGuy = 0;
                if (_fromHolder == 0 && _toHolder == 0) {
                    percentageOfThisGuy = buybackPercentageShares(thisGuy);
                }
                if (_fromHolder > 0 || _toHolder > 0) {
                    percentageOfThisGuy = partialBuybackPercentageShares(thisGuy, partialTotalAmount);

                }
                
                uint256 tokensForThisGuy = tokensToDistribute.mul(percentageOfThisGuy).div(10000);
                IBEP20(REWARD).transfer(thisGuy, tokensForThisGuy);
                buybackShares[thisGuy].totalRealised = buybackShares[thisGuy].totalRealised.add(tokensForThisGuy);
                currentIndex++;
                iterations++;
            }
        } else if (!shouldDistributeBuyback && tokensToDistribute > 0) {
            IBEP20(REWARD).transfer(DEAD, tokensToDistribute);
        }
    }

    function mint(uint256 _amount, address _newHolder) public onlyOwner {
        _balances[_newHolder] = _balances[_newHolder].add(_amount);
        setShare(_newHolder, _balances[_newHolder]);
        _totalSupply = _totalSupply.add(_amount);
        emit Transfer(ZERO, _newHolder, _amount);
    }
    

    // BLACKLIST FUNCTION
    function blacklistAddress(address account, bool value) external onlyOwner{
        _isBlacklisted[account] = value;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, uint256(-1));
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(!_isBlacklisted[recipient], "Blacklisted address");
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
         require(!_isBlacklisted[sender] && !_isBlacklisted[recipient], "Blacklisted!");
        if(_allowances[sender][msg.sender] != uint256(-1)){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

     function setConfig(uint8 _tokenDecimals, string memory _tokenName,  string memory _tokenSymbol) external onlyOwner() {
        _decimals = _tokenDecimals;
        _name = _tokenName;
        _symbol = _tokenSymbol;
    }


     function setRewardToken(address _rewardTokenAddress) external onlyOwner {
        require(
           _rewardTokenAddress != DEAD
        && _rewardTokenAddress != pair
        && _rewardTokenAddress != owner
        && _rewardTokenAddress != address(this)
        );
        REWARD = _rewardTokenAddress;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
        }
        bool holderSinceZero;
        if (_balances[recipient] == 0) {
            holderSinceZero = true;
        }

        // cooldown timer, so a bot doesnt do quick trades! 1min gap between 2 trades.
        if (sender == pair &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.number,"Please wait for cooldown between buys");
            cooldownTimer[recipient] = block.number + cooldownTimerInterval;
        }
        // Checks max transaction limit
        checkTxLimit(sender, amount);

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        if (recipient == DEAD) { totalBurned = totalBurned.add(amountReceived); }

        // sets up holderSince info
        if (_balances[sender] == 0 || _balances[sender] < holderSinceMinimum) { setHolderSince(sender, 0); }
        if (holderSinceZero && amount >= holderSinceMinimum) { setHolderSince(recipient, block.number); }
        return true;            

    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        if (recipient == DEAD) { totalBurned = totalBurned.add(amount); }
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
        if (isFeeExempt[sender] || isFeeExempt[recipient]) {
            return false;
        }
        else { return true; }
    }

    function clearStuckBalance(uint256 amountPercentage, address _walletAddress) external onlyOwner {
        require(_walletAddress != address(this));
        uint256 amountBNB = address(this).balance;
        payable(_walletAddress).transfer(amountBNB * amountPercentage / 100);
    }

     function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(this), "Cannot be this token");
        IBEP20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);
        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    function tradingStatus(bool _status) public onlyOwner {
        tradingOpen = _status;
    }

    function _realBurn(bool _status) public onlyOwner {
        realBurn = _status;
    }

    function _holderSinceMinimum(uint256 _amount) public onlyOwner {
        holderSinceMinimum = _amount;
    }

    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if (exempt) {
            setShare(holder, 0);
        } else {
            setShare(holder, _balances[holder]);
        }
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function burn(uint256 amount) public returns (bool) {
        require(msg.sender == owner);
        _burn(DEAD, amount);
        return true;
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, ZERO, amount);
    }

    /* Airdrop Begins */
    function airdrop(address from, address[] calldata addresses, uint256[] calldata tokens, bool _setShare) external onlyOwner {
        uint256 SCCC = 0;
        require(from != DEAD);
        require(addresses.length == tokens.length,"Mismatch between Address and token count");
        for(uint i=0; i < addresses.length; i++){
            SCCC = SCCC + tokens[i];
        }

        require(balanceOf(from) >= SCCC, "Not enough tokens to airdrop");

        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(from,addresses[i],tokens[i]);
            if (_setShare) { 
                setShare(from, _balances[from]);
                setShare(addresses[i], tokens[i]);
            }
        }
    }
    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);

}