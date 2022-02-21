/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

// SPDX-License-Identifier: unlicensed

pragma solidity ^0.8.6;

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
    event CallbackPanel(address sender, address recipient, uint256 status, string subject, string message, uint256 data, uint256 time);
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
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

/* Router */

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

/* Contract */

contract MobNodeC is IBEP20, Auth {

    using SafeMath for uint256;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "MobNodeC";
    string constant _symbol = "MNODC"; 
    uint8 constant _decimals = 9;
    uint256 _totalSupply = 10 ** 12 * 10 ** _decimals;

    mapping (address => uint256) _balances;
    mapping (address => uint256) BuyCooldownTimer;
    mapping (address => uint256) SellCooldownTimer;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isBlacklisted;
    mapping (address => bool) isDogHoused;
    mapping (address => bool) isWhitelisted;
    mapping (address => uint256) lockTimeSellperAddress;
    mapping (address => uint256) lockTimeBuyperAddress;
    mapping (address => uint) maxSellperAddress;
    mapping (address => uint) amountSellperAddress;
    mapping (address => uint) currentSellLockTime;
    mapping (address => uint) maxBuyperAddress;
    mapping (address => uint) amountBuyperAddress;
    mapping (address => uint) currentBuyLockTime;

    // Default Fees
    uint256 liquidityFee    = 3;
    uint256 treasuryFee     = 2;
    uint256 marketingFee    = 6;
    uint256 buybackFee      = 2;
    uint256 totalFee        = 13;

    // Limits
    uint256 maxWalletHold = _totalSupply.mul(2).div(100);
    uint256 supplyAvailable = _totalSupply;
    uint256 maxTxSell = _totalSupply.div(1000);
    uint256 maxTxBuy = _totalSupply.div(100);
    uint256 lockTimeSellGap = 3600; // In seconds
    uint256 lockTimeBuyGap = 20; // In seconds
    
    // Ajustable Fees
    uint256 BuyliquidityFee     = 3;
    uint256 BuytreasuryFee      = 2;
    uint256 BuymarketingFee     = 6;
    uint256 BuybuybackFee       = 2;
    uint256 BuytotalFee         = 13;
    uint256 SellliquidityFee    = 3;
    uint256 SelltreasuryFee     = 4;
    uint256 SellmarketingFee    = 9;
    uint256 SellbuybackFee      = 2;
    uint256 SelltotalFee        = 18;
    uint256 BuyliquidityDHFee   = 3;
    uint256 BuytreasuryDHFee    = 3;
    uint256 BuymarketingDHFee   = 8;
    uint256 BuybuybackDHFee     = 2;
    uint256 BuytotalDHFee       = 16;
    uint256 SellliquidityDHFee  = 4;
    uint256 SelltreasuryDHFee   = 5;
    uint256 SellmarketingDHFee  = 10;
    uint256 SellbuybackDHFee    = 2;
    uint256 SelltotalDHFee      = 21;

    // Presale
    uint256 isPresaleTime;
    bool isPresalebuyfees = false;
    bool isPresalesellfees = true;
    uint256 isPresalebonus = 50;  

    // Fees receivers
    address private liquidityPool;
    address private marketingPool;
    address private treasuryPool;

    // Liquidity
    uint256 targetLiquidity = 25;
    uint256 targetLiquidityDenominator = 100;

    // BuyBack
    uint256 buybackMultiplierNumerator = 200;
    uint256 buybackMultiplierDenominator = 100;
    uint256 buybackMultiplierTriggeredAt;
    uint256 buybackMultiplierLength = 30 minutes;
    bool public autoBuybackEnabled = false;
    bool public autoBuybackMultiplier = true;
    uint256 autoBuybackCap;
    uint256 autoBuybackAccumulator;
    uint256 autoBuybackAmount;
    uint256 autoBuybackBlockPeriod;
    uint256 autoBuybackBlockLast;

    // Router
    IDEXRouter public router;
    address public pair;

    // Swap settings
    bool public swapEnabled = true;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    uint256 public swapThreshold = _totalSupply.div(1000); // 0.1%
  
    constructor() Auth(msg.sender) {
        // router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // mainnet
        router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // testnet
        //pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        pair = IDEXFactory(router.factory()).createPair(address(this),router.WETH());

        _allowances[address(this)][address(router)] = type(uint256).max;
        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        liquidityPool = 0x6d364052FA694DC94AD8890D36AA8eb43490e23d;
        marketingPool = 0xf7098c958d53B68988207b8ca4534a431AB4B9C7;
        treasuryPool = 0xf7098c958d53B68988207b8ca4534a431AB4B9C7; // Owner
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }
      
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function approveMax(address spender) public returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(!isBlacklisted[recipient], "This address is blacklisted");
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(!isBlacklisted[sender] && !isBlacklisted[recipient], "This address is blacklisted");
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (isBlacklisted[sender]) {
            emit CallbackPanel(sender, address(0), 2, "blacklist", "sender", amount, block.timestamp);
        }
        if (isBlacklisted[recipient]) {
            emit CallbackPanel(address(0), recipient, 2, "blacklist", "recipient", amount, block.timestamp);
        }
        require(!isBlacklisted[sender] && !isBlacklisted[recipient], "blacklisted");
        if(inSwap){ 
            return _basicTransfer(sender, recipient, amount); 
        }
        uint256 newAmountSell;
        uint256 newAmountBuy;
        uint256 txAmount;
        uint256 amountReceived;

        if (sender == pair) {

            // Check total owned
            uint256 contractBalanceRecipient = balanceOf(recipient);
            if (contractBalanceRecipient >= maxWalletHold) {
                emit CallbackPanel(sender, recipient, 2, "maxwallet", "maxhold", contractBalanceRecipient, block.timestamp);
            }
            require( contractBalanceRecipient < maxWalletHold, "maxhold");
            uint256 currentMarginToMaxWallet = maxWalletHold.sub(contractBalanceRecipient);

            // Check limits and get the TX amount
            uint256 lockTimePeriod = lockTimeBuyperAddress[recipient] > 0 ? lockTimeBuyperAddress[recipient] : lockTimeBuyGap;
            uint256 myMaxBuy = maxBuyperAddress[recipient] > 0 ? maxBuyperAddress[recipient] : maxTxBuy;

            if ( currentBuyLockTime[recipient] > block.timestamp) {

                // Wallet Limits apply
                if (amountBuyperAddress[recipient] > myMaxBuy && myMaxBuy > 0) {
                    emit CallbackPanel(sender, recipient, 2, "maxwallet", "maxbuy", myMaxBuy, block.timestamp);
                }
                require( amountBuyperAddress[recipient] <= myMaxBuy || myMaxBuy == 0, "maxbuy");
                newAmountBuy = amountBuyperAddress[recipient].add(amount);
                if (newAmountBuy > myMaxBuy && newAmountBuy <= currentMarginToMaxWallet && myMaxBuy > 0) {
                    txAmount = myMaxBuy.sub(amountBuyperAddress[recipient]);
                    amountBuyperAddress[recipient] = myMaxBuy;
                } else if (newAmountBuy > currentMarginToMaxWallet) {                   
                    txAmount = currentMarginToMaxWallet;
                    amountBuyperAddress[recipient] = myMaxBuy;
                    emit CallbackPanel(sender, recipient, 1, "maxwallet", "maxbuyrev", currentMarginToMaxWallet, block.timestamp);
                } else {
                    txAmount = amount;
                    amountBuyperAddress[recipient] = newAmountBuy;
                }
            } else {

                // No limits in place yet
                if (amount > myMaxBuy && myMaxBuy <= currentMarginToMaxWallet && myMaxBuy > 0) {
                    txAmount = myMaxBuy;
                    amountBuyperAddress[recipient] = myMaxBuy;
                    emit CallbackPanel(sender, recipient, 1, "maxwallet", "maxbuyrev", myMaxBuy, block.timestamp);
                } else if (myMaxBuy > currentMarginToMaxWallet) {
                    txAmount = currentMarginToMaxWallet;
                    amountBuyperAddress[recipient] = myMaxBuy;
                    emit CallbackPanel(sender, recipient, 1, "maxwallet", "maxbuyrev", currentMarginToMaxWallet, block.timestamp);
                } else {
                    txAmount = amount;
                    amountBuyperAddress[recipient] = txAmount;
                    currentBuyLockTime[recipient] = block.timestamp.add(lockTimePeriod);
                }
            }

            // Get the proper fees
            if (isWhitelisted[recipient] && isPresaleTime > block.timestamp && !isPresalebuyfees) {
                noTradeFees();
            } else if (isDogHoused[recipient]) {
                buyDHFees();
            } else {
                buyFees();
            }
            supplyAvailable = supplyAvailable.sub(txAmount);
        }

        if (recipient == pair) {

            // Check limits and get the TX amount
            uint256 lockTimePeriod = lockTimeSellperAddress[sender] > 0 ? lockTimeSellperAddress[sender] : lockTimeSellGap;
            uint256 myMaxSell = maxSellperAddress[sender] > 0 ? maxSellperAddress[sender] : maxTxSell;

            if ( currentSellLockTime[sender] > block.timestamp) {
                if (amountSellperAddress[sender] >= myMaxSell && myMaxSell > 0) {
                    emit CallbackPanel(sender, recipient, 1, "maxwallet", "maxsell", myMaxSell, block.timestamp);
                }
                require( amountSellperAddress[sender] < myMaxSell || myMaxSell == 0,"Exceeds maximum sell limit. Please try again later.");
                newAmountSell = amountSellperAddress[sender].add(amount);              
                if (newAmountSell > myMaxSell && myMaxSell > 0) {
                    txAmount = myMaxSell.sub(amountSellperAddress[sender]);
                    amountSellperAddress[sender] = myMaxSell;
                    emit CallbackPanel(sender, recipient, 1, "maxwallet", "maxsellrev", myMaxSell, block.timestamp);
                } else {
                    txAmount = amount;
                    amountSellperAddress[sender] = newAmountSell;
                }
            } else {
                if (amount > myMaxSell && myMaxSell > 0) {
                    txAmount = myMaxSell;
                    amountSellperAddress[sender] = myMaxSell;
                    emit CallbackPanel(sender, recipient, 1, "maxwallet", "maxsellrev", myMaxSell, block.timestamp);
                } else {
                    txAmount = amount;
                    amountSellperAddress[sender] = txAmount;
                    currentSellLockTime[sender] = block.timestamp.add(lockTimePeriod);
                }
            }
            
            // Get the proper fees
            if (isWhitelisted[sender] && isPresaleTime > block.timestamp && !isPresalesellfees) {
                noTradeFees();
            } else if (isDogHoused[sender]) {
                sellDHFees();
            } else {
                sellFees();
            }            
            supplyAvailable = supplyAvailable.add(txAmount);
        }

        //Exchange tokens
        if(shouldSwapBack()){ swapBack(); }
        if(shouldAutoBuyback()){ triggerAutoBuyback(); }

        // Transfer amount
        _balances[sender] = txAmount > 0 ? _balances[sender].sub(txAmount) : _balances[sender].sub(amount);
        if (txAmount > 0 ) {
            amountReceived = shouldTakeFee(sender,recipient) ? takeFee(sender, recipient, txAmount) : txAmount;
        } else {
            amountReceived = amount;
        }
        // Check Presale
        if (sender == pair && isWhitelisted[recipient] && isPresaleTime > block.timestamp) {
            uint bonus = amountReceived.mul(isPresalebonus).div(100);
            //amountReceived = amountReceived.add(bonus);
            _basicTransfer(treasuryPool,recipient,bonus);
            _balances[recipient] = _balances[recipient].add(bonus);
            emit CallbackPanel(sender, recipient, 0, "bonus", "success", amountReceived, block.timestamp);
        }

        _balances[recipient] = _balances[recipient].add(amountReceived);
        require(amountReceived > 0, "something's wrong");
        emit Transfer(sender, recipient, amountReceived);
        emit CallbackPanel(sender, recipient, 0, "buy", "success", amount, block.timestamp);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (isBlacklisted[sender]) {
            emit CallbackPanel(sender, address(0), 2, "blacklist", "sender", amount, block.timestamp);
        }
        if (isBlacklisted[recipient]) {
            emit CallbackPanel(address(0), recipient, 2, "blacklist", "recipient", amount, block.timestamp);
        }
        require(!isBlacklisted[sender] && !isBlacklisted[recipient], "This address is blacklisted");
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        emit CallbackPanel(sender, recipient, 0, "transfer", "success", amount, block.timestamp);
        return true;
    }

    function Mint(address account, uint256 amount) external onlyOwner returns (uint256) {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        supplyAvailable = supplyAvailable.add(amount);
        //emit Transfer(address(0), account, amount);
        emit CallbackPanel(address(0),account, 0, "mint", "success", amount, block.timestamp);
        return amount;
    }

    function Burn(address account, uint256 amount) external onlyOwner returns (uint256){
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance.sub(amount);
        }
        _totalSupply = _totalSupply.sub(amount);
        supplyAvailable = supplyAvailable.sub(amount);
        //emit Transfer(account, address(0), amount);
        emit CallbackPanel(account, address(0), 0, "burn", "success", amount, block.timestamp);
        return amount;
    }
    
    // Internal Functions

     function noTradeFees() internal{
        liquidityFee    = 0;
        treasuryFee     = 0;
        marketingFee    = 0;
        buybackFee      = 0;
        totalFee        = 0;
    }
    function buyFees() internal{
        liquidityFee    = BuyliquidityFee;
        treasuryFee     = BuytreasuryFee;
        marketingFee    = BuymarketingFee;
        buybackFee      = BuybuybackFee;
        totalFee        = BuytotalFee;
    }
    function sellFees() internal{
        liquidityFee    = SellliquidityFee;
        treasuryFee     = SelltreasuryFee;
        marketingFee    = SellmarketingFee;
        buybackFee      = SellbuybackFee;
        totalFee        = SelltotalFee;
    }
    function buyDHFees() internal{
        liquidityFee    = BuyliquidityDHFee;
        treasuryFee     = BuytreasuryDHFee;
        marketingFee    = BuymarketingDHFee;
        buybackFee      = BuybuybackDHFee;
        totalFee        = BuytotalDHFee;
    }
    function sellDHFees() internal{
        liquidityFee    = SellliquidityDHFee;
        treasuryFee     = SelltreasuryDHFee;
        marketingFee    = SellmarketingDHFee;
        buybackFee      = SellbuybackDHFee;
        totalFee        = SelltotalDHFee;
    }
    function setBuyFees(uint256 _lq, uint256 _rf, uint256 _mk, uint256 _bb) external onlyOwner { 
        BuyliquidityFee = _lq;
        BuytreasuryFee = _rf;
        BuymarketingFee = _mk;
        BuybuybackFee = _bb;
        BuytotalFee = _lq.add(_rf).add(_mk).add(_bb);
        require(BuytotalFee <= 50, "Fees are too high");
    }
    function setSellFees(uint256 _lq, uint256 _rf, uint256 _mk, uint256 _bb) external onlyOwner {
        SellliquidityFee = _lq;
        SelltreasuryFee = _rf;
        SellmarketingFee = _mk;
        SellbuybackFee = _bb;
        SelltotalFee = _lq.add(_rf).add(_mk).add(_bb);
        require(SelltotalFee <= 50, "Fees are too high");
    }
    function setBuyDHFees(uint256 _lq, uint256 _rf, uint256 _mk, uint256 _bb) external onlyOwner {
        BuyliquidityDHFee = _lq;
        BuytreasuryDHFee = _rf;
        BuymarketingDHFee = _mk;
        BuybuybackDHFee = _bb;
        BuytotalDHFee = _lq.add(_rf).add(_mk).add(_bb);
        require(BuytotalDHFee <= 50, "Fees are too high");
    }
    function setSellDHFees(uint256 _lq, uint256 _rf, uint256 _mk, uint256 _bb) external onlyOwner {
        SellliquidityDHFee = _lq;
        SelltreasuryDHFee = _rf;
        SellmarketingDHFee = _mk;
        SellbuybackDHFee = _bb;
        SelltotalDHFee = _lq.add(_rf).add(_mk).add(_bb);
        require(SelltotalDHFee <= 50, "Fees are too high");
    }
    function getBuyFees() external view returns (uint256,uint256,uint256,uint256,uint256) {
        return(BuyliquidityFee,BuytreasuryFee,BuymarketingFee,BuybuybackFee,BuytotalFee);
    }
    function getSellFees() external view returns (uint256,uint256,uint256,uint256,uint256) {
        return(SellliquidityFee,SelltreasuryFee,SellmarketingFee,SellbuybackFee,SelltotalFee);
    }
    function getBuyDHFees() external view returns (uint256,uint256,uint256,uint256,uint256) {
        return(BuyliquidityDHFee,BuytreasuryDHFee,BuymarketingDHFee,BuybuybackDHFee,BuytotalDHFee);
    }
    function getSellDHFees() external view returns (uint256,uint256,uint256,uint256,uint256) {
        return(SellliquidityDHFee,SelltreasuryDHFee,SellmarketingDHFee,SellbuybackDHFee,SelltotalDHFee);
    }
    function shouldTakeFee(address _sender, address _recipient) internal view returns (bool) {
        if ((_sender == pair && isWhitelisted[_recipient] && isPresaleTime > block.timestamp && !isPresalebuyfees) || isFeeExempt[_recipient]) {
            return false;
        } 
        else if ((_recipient == pair && isWhitelisted[_sender] && isPresaleTime > block.timestamp && !isPresalesellfees) || isFeeExempt[_sender]) {
            return false;
        } else {
            return true;
        }
    }
    function getTotalFee(bool selling) public view returns (uint256) {
        if(selling && buybackMultiplierTriggeredAt.add(buybackMultiplierLength) > block.timestamp){ return getMultipliedFee(); }
        return totalFee;
    }
    function getMultipliedFee() public view returns (uint256) {
        uint256 remainingTime = buybackMultiplierTriggeredAt.add(buybackMultiplierLength).sub(block.timestamp);
        uint256 feeIncrease = totalFee.mul(buybackMultiplierNumerator).div(buybackMultiplierDenominator).sub(totalFee);
        return totalFee.add(feeIncrease.mul(remainingTime).div(buybackMultiplierLength));
    }
    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(getTotalFee(receiver == pair)).div(100);
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        //emit Transfer(sender, address(this), feeAmount);
        emit CallbackPanel(sender, address(this), 0, "fees", "success", feeAmount, block.timestamp);
        return amount.sub(feeAmount);
    }
  
    // Limits

    function setWalletLimits(uint256 _maxHold, uint256 _maxSell, uint256 _maxBuy) external onlyOwner {
        maxWalletHold = _maxHold;
        maxTxSell = _maxSell;
        maxTxBuy = _maxBuy;
    }
    function getWalletLimits() external view returns (uint256,uint256,uint256) {
        return(maxWalletHold,maxTxSell,maxTxBuy);
    }
    function shouldSwapBack() internal view returns (bool) { //  add View if not working
        // if (_balances[address(this)] < swapThreshold) {
        //     emit CallbackPanel(msg.sender, pair, 2, "swap", "threshold", swapThreshold, block.timestamp);
        // }
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }
    function setLockTimeSellGap(uint256 _inSeconds) external onlyOwner {
        require(_inSeconds <= 172800,"Gap is too high. 172800 (48hrs) max");
        lockTimeSellGap = _inSeconds;
    }
    function getLockTimeSellGap() external view returns (uint256) {
        return(lockTimeSellGap);
    }
   function setLockTimeBuyGap(uint256 _inSeconds) external onlyOwner {
       require(_inSeconds <= 172800,"Gap is too high. 172800 (48hrs) max");
        lockTimeBuyGap = _inSeconds;
    }
    function getLockTimeBuyGap() external view returns (uint256) {
        return(lockTimeBuyGap);
    }
    function setMaxSellperAddress(address _maxAddress, uint256 _maxSell) external onlyOwner {
        maxSellperAddress[_maxAddress] = _maxSell;
    }
    function getMaxSellperAddress(address _maxAddress) external view returns (uint256) {
        return(maxSellperAddress[_maxAddress]);
    }
    function setLockTimeperAddress(address _lockAddress, uint256 _sellLockTime, uint256 _buyLockTime) external onlyOwner {
        require(_sellLockTime <= 172800 && _buyLockTime <= 172800,"One of the 2 gaps is too high. 172800 (48hrs) max");
        lockTimeSellperAddress[_lockAddress] = _sellLockTime;
        lockTimeBuyperAddress[_lockAddress] = _buyLockTime;
    }
    function getLockTimeperAddress(address _lockAddress) external view returns (uint256, uint256) {
        return(lockTimeSellperAddress[_lockAddress],lockTimeBuyperAddress[_lockAddress]);
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    // External Functions
    function swapBack() internal swapping {
        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;
        uint256 balanceBefore = address(this).balance;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        if (totalFee > 0) {
            uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));
            uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);

            uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);
            (bool successMarketing,/* bytes memory data */) = payable(marketingPool).call{value: amountBNBMarketing, gas: 30000}("");
            require(successMarketing, "receiver rejected the transfer");
            emit CallbackPanel(address(this), marketingPool, 0, "marketing", "success", amountBNBMarketing, block.timestamp);

            uint256 amountBNBTreasury = amountBNB.mul(treasuryFee).div(totalBNBFee);
            (bool successTreasury,/* bytes memory data */) = payable(treasuryPool).call{value: amountBNBTreasury, gas: 30000}("");
            require(successTreasury, "receiver rejected the transfer");
            emit CallbackPanel(address(this), treasuryPool, 0, "treasury", "success", amountBNBTreasury, block.timestamp);

            if(amountToLiquify > 0){
                router.addLiquidityETH{value: amountBNBLiquidity}(
                    address(this),
                    amountToLiquify,
                    0,
                    0,
                    liquidityPool,
                    block.timestamp
                );
                //emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
                emit CallbackPanel(address(this), liquidityPool, 0, "liquidity", "success", amountBNBLiquidity, block.timestamp);
            }
            
        }
        emit CallbackPanel(address(this), address(this), 0, "sell", "success", amountToSwap, block.timestamp);
    }
  
    function shouldAutoBuyback() internal view returns (bool) {
        // if (address(this).balance < autoBuybackAmount) {
        //     emit CallbackPanel(address(this), address(this), 1, "buyback", "no", address(this).balance, block.timestamp);
        // }
        return msg.sender != pair
            && !inSwap
            && autoBuybackEnabled
            && autoBuybackBlockLast.add(autoBuybackBlockPeriod) <= block.number
            && address(this).balance >= autoBuybackAmount;
    }

    function triggerManualBuyback(uint256 amount, bool triggerBuybackMultiplier) public authorized {
        buyTokens(amount, DEAD);
        if(triggerBuybackMultiplier){
            buybackMultiplierTriggeredAt = block.timestamp;
            //emit BuybackMultiplierActive(buybackMultiplierLength);
            emit CallbackPanel(address(this), DEAD, 0, "buyback", "multi", buybackMultiplierLength, block.timestamp);
        }
    }
    
    function clearBuybackMultiplier() external authorized {
        buybackMultiplierTriggeredAt = 0;
    }

    function triggerAutoBuyback() internal {
        buyTokens(autoBuybackAmount, DEAD);
        if(autoBuybackMultiplier){
            buybackMultiplierTriggeredAt = block.timestamp;
            //emit BuybackMultiplierActive(buybackMultiplierLength);
            emit CallbackPanel(address(this), DEAD, 0, "buyback", "multi", buybackMultiplierLength, block.timestamp);
        }
        autoBuybackBlockLast = block.number;
        autoBuybackAccumulator = autoBuybackAccumulator.add(autoBuybackAmount);
        if(autoBuybackAccumulator > autoBuybackCap){ autoBuybackEnabled = false; }
        emit CallbackPanel(address(this), DEAD, 0, "buyback", "success", autoBuybackAmount, block.timestamp);
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
        emit CallbackPanel(address(this), to, 0, "buyback", "success", amount, block.timestamp);
    }

    function setAutoBuybackSettings(bool _enabled, uint256 _cap, uint256 _amount, uint256 _period, bool _autoBuybackMultiplier) external authorized {
        autoBuybackEnabled = _enabled;
        autoBuybackCap = _cap;
        autoBuybackAccumulator = 0;
        autoBuybackAmount = _amount;
        autoBuybackBlockPeriod = _period;
        autoBuybackBlockLast = block.number;
        autoBuybackMultiplier = _autoBuybackMultiplier;
    }

    function setBuybackMultiplierSettings(uint256 numerator, uint256 denominator, uint256 length) external authorized {
        require(numerator.div(denominator) <= 2 && numerator > denominator);
        buybackMultiplierNumerator = numerator;
        buybackMultiplierDenominator = denominator;
        buybackMultiplierLength = length;
    }
    function airdrop(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {
        uint256 TAD = 0;
        require(addresses.length == tokens.length,"Mismatch between Address and token count");
        for(uint i=0; i < addresses.length; i++){
            TAD = TAD.add(tokens[i]);
        }
        require(balanceOf(from) >= TAD, "Not enough tokens to airdrop");
        for(uint i=0; i < addresses.length; i++){
            _basicTransfer(from,addresses[i],tokens[i]);
            emit CallbackPanel(from, addresses[i], 0, "airdrop", "success", tokens[i], block.timestamp);
        }
    }

    function checkSwapThreshold() external view returns (uint256) {
        return swapThreshold;
    }
    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }
    function setLiquidityPool(address _liquidityPool) external onlyOwner {
        liquidityPool = _liquidityPool;
    }
    function setMarketingPool(address _marketingPool) external onlyOwner {
        marketingPool = _marketingPool;
    }
    function setTreasuryPool(address _treasuryPool) external onlyOwner {
        treasuryPool = _treasuryPool;
    }
    function getPools() external view returns (address,address,address) {
        return(marketingPool,liquidityPool,treasuryPool);
    }
    function getTargetLiquidity() external view returns (uint256,uint256) {
        return(targetLiquidity,targetLiquidityDenominator);
    }
    function setSwapBackSettings(bool _enabled, uint256 _num, uint256 _denom) external onlyOwner {
        swapEnabled = _enabled;
        swapThreshold = _totalSupply.div(_denom).mul(_num);
    }
    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }
    function addToBlackList(address[] calldata addresses) external authorized {
        for (uint256 i; i < addresses.length; ++i) {
            require(
                    addresses[i] != owner && 
                    addresses[i] != marketingPool && 
                    addresses[i] != treasuryPool && 
                    addresses[i] != liquidityPool
                    ,"Can't add internal addresses"
                );
            isBlacklisted[addresses[i]] = true;
        }
    }
    function removeFromBlackList(address account) external authorized {
        isBlacklisted[account] = false;
    }
    function addToDogHouse(address[] calldata addresses) external authorized {
        for (uint256 i; i < addresses.length; ++i) {
            require(
                addresses[i] != owner && 
                addresses[i] != treasuryPool && 
                addresses[i] != marketingPool && 
                addresses[i] != liquidityPool
                ,"Can't add internal addresses"
            );
            isDogHoused[addresses[i]] = true;
        }
    }
    function removeFromDogHouse(address account) external authorized {
        isDogHoused[account] = false;
    }
    function addWhitelist(address[] calldata _addresses) external authorized {
        for (uint256 i; i < _addresses.length; ++i) {
            isWhitelisted[_addresses[i]] = true;
        }
    }
    function remWhitelist(address _addresses) external authorized {
        isWhitelisted[_addresses] = false;
    }

    function setPresaleDetails(uint _presaleEnd, bool _presalebuyfees, bool _presalesellfees, uint256 _presalebonus) external authorized {
        isPresaleTime = _presaleEnd;
        isPresalebuyfees = _presalebuyfees;
        isPresalesellfees = _presalesellfees;
        isPresalebonus = _presalebonus;
    }
    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    // Stuck Balances Functions
    function rescueBNB(uint256 amount) external onlyOwner{
      payable(msg.sender).transfer(amount);
    }
    function rescueAnyBEP20Tokens(address _tokenAddr, address _to, uint _amount ) public onlyOwner {
        if (_tokenAddr == address(this)){
            emit CallbackPanel(_tokenAddr, _to, 2, "rescue", "failed", _amount, block.timestamp);
        }
        require(_tokenAddr != address(this), "failed");
        IBEP20(_tokenAddr).transfer(_to, _amount);
        emit CallbackPanel(_tokenAddr, _to, 0, "rescue", "success", _amount, block.timestamp);
    }
    function ClearStuckBalance(uint256 amountPercentage) external onlyOwner {
        require(amountPercentage < 10 && amountPercentage > 0,"Percentage too high");
        uint256 contractBNBBalance = address(this).balance.mul(amountPercentage).div(100);
        payable(liquidityPool).transfer(contractBNBBalance);
        emit CallbackPanel(address(this), liquidityPool, 0, "stuck", "success", contractBNBBalance, block.timestamp);
    }
}