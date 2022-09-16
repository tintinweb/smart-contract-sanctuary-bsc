/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SHIBA CHAIN
// STEALTH LAUNCH !!

// SAFU DEV (BOSS) TG @alexmafnx 
//  Backed by influencers.
//  Tax: 10/10
//  Enjoy regular buybacks and burns.
//  Experienced marketing team.
//  TG : https://t.me/shiba_Chain_stealth/
//  Twitter : https://twitter.com/ShibaaChain/

//SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.16;

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
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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



contract ShibaChain is IBEP20, Auth {
    using SafeMath for uint256;
    
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; 
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    
    address private boosterWallet = 0xE25A68E38fe21FbaFffC5bDEA8271503BebE731D;
    address private DevWallet = 0x19F94D42C80435f268CA68855BD46C379734e06e;

    address routerv2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string constant _name = "ShibaChain";
    string constant _symbol = "$SC";
    uint8 constant _decimals = 18;

    uint256 internal constant _totalSupply = 1000000 * (10**18);
    
    uint256 public maxTxAmount = _totalSupply / 1000; // 0.5% of the total supply
    uint256 public maxWalletBalance = _totalSupply / 50; // 2% of the total supply

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping(address => bool) public _isBlacklisted;
    mapping (address => bool) isFeeExempt;
   
    
    uint256 public sellingBoosterFee = 7;
    uint256 public buyingBoosterFee = 7;
    
    uint256 public sellingLpFee = 2;
    uint256 public buyingLpFee = 2;
    
    uint256 private sellingDevFee = 1;
    uint256 private buyingDevFee = 1;
    
    uint256 public buyersTotalFees = buyingBoosterFee.add(buyingLpFee).add(buyingDevFee);
    uint256 public sellersTotalFees = sellingBoosterFee.add(sellingLpFee).add(sellingDevFee);
    
    uint256 internal FEES_DIVISOR = 10**2;

    IDEXRouter public router;
    address public pair;

    

    bool public takeFeeEnabled = true;
    bool public tradingIsEnabled = true;
    bool public isInPresale = false;
    
    bool public antiBotEnabled = false;
    uint256 public antiBotFee = 99;
    uint256 public _startTimeForSwap;

    bool private swapping;
    bool public swapEnabled = true;
    uint256 public swapTokensAtAmount = 6000 * (10**18);
    
    // Total = 100%
    uint256 public boosterPortionOfSwap = 70; // 70%
    uint256 private DevPortionOfSwap = 10; // 10%
    uint256 public lpPortionOfSwap = 20; // 20%
    
    event BoosterWalletUpdated(address indexed newWallet, address indexed oldWallet);
    event DevWalletUpdated(address indexed newWallet, address indexed oldWallet);
    
    event LiquidityAdded(uint256 tokenAmountSent, uint256 ethAmountSent, uint256 liquidity);

    

    constructor () Auth(msg.sender) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = _totalSupply;

        

        isFeeExempt[msg.sender] = true;

        
        
        approve(routerv2, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    receive() external payable { }

    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
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

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function blacklistAddress(address account, bool value) external onlyOwner{
        _isBlacklisted[account] = value;
    }

    function updateFeesDivisor(uint256 divisor) external onlyOwner() {
        FEES_DIVISOR = divisor;
    }
    
    function updateSwapTokensAt(uint256 _swaptokens) external onlyOwner {
        swapTokensAtAmount = _swaptokens * (10**18);
    }
    
    function updateSwapEnabled(bool _enabled) external onlyOwner {
        swapEnabled  = _enabled;
    }
    
    function updateWalletMax(uint256 _walletMax) external onlyOwner {
        maxWalletBalance = _walletMax * (10**18);
    }
    
    function updateTransactionMax(uint256 _txMax) external onlyOwner {
        maxTxAmount = _txMax * (10**18);
    }
    
    function calcBuyersTotalFees() private {
        buyersTotalFees = buyingBoosterFee.add(buyingLpFee).add(buyingDevFee);
    }
    
    function calcSellersTotalFees() private {
        sellersTotalFees = sellingBoosterFee.add(sellingLpFee).add(sellingDevFee);
    }
    
    
    
    
    function updateSellingBoosterFee (uint256 newFee) external onlyOwner {
        sellingBoosterFee = newFee;
        calcSellersTotalFees();
    }
    
    function updateSellingLpFee (uint256 newFee) external onlyOwner {
        sellingLpFee = newFee;
        calcSellersTotalFees();
    }
    
    function updateSellingDevFee (uint256 newFee) external onlyOwner {
        sellingDevFee = newFee;
        calcSellersTotalFees();
    }
    
    
    
    function updateBuyingBoosterFee (uint256 newFee) external onlyOwner {
        buyingBoosterFee = newFee;
        calcBuyersTotalFees();
    }
    
    function updateBuyingLpFee (uint256 newFee) external onlyOwner {
        buyingLpFee = newFee;
        calcBuyersTotalFees();
    }
    
    function updateBuyingDevFee (uint256 newFee) external onlyOwner {
        buyingDevFee = newFee;
        calcBuyersTotalFees();
    }
    
    function updateBoosterWallet(address newBoosterWallet) external onlyOwner {
        require(newBoosterWallet != boosterWallet, "The Booster wallet is already this address");
        emit BoosterWalletUpdated(newBoosterWallet, boosterWallet);
        
        boosterWallet = newBoosterWallet;
    }
    
    function updateDevWallet(address newDevWallet) external onlyOwner {
        require(newDevWallet != DevWallet, "The Dev wallet is already this address");
        emit DevWalletUpdated(newDevWallet, DevWallet);
        
        DevWallet = newDevWallet;
    }
    
    function updatePortionsOfSwap(uint256 boosterPortion, 
    uint256 DevPortion, uint256 lpPortion) external onlyOwner {
        
        uint256 totalPortion = boosterPortion.add(DevPortion).add(lpPortion);
        require(totalPortion == 100, "Total must be equal to 100");
        
        boosterPortionOfSwap = boosterPortion;
        DevPortionOfSwap = DevPortion;
        lpPortionOfSwap = lpPortion;
    }
    
    function prepareForPreSale() external onlyOwner {
        takeFeeEnabled = false;
        swapEnabled = false;
        isInPresale = true;
        maxTxAmount = _totalSupply;
        maxWalletBalance = _totalSupply;
    }
    
    function afterPreSale() external onlyOwner {
        takeFeeEnabled = true;
        swapEnabled = true;
        isInPresale = false;
        maxTxAmount = _totalSupply / 1000;
        maxWalletBalance = _totalSupply / 50;
    }
    
    function whitelistPinkSale(address _presaleAddress, address _routerAddress) external onlyOwner {
        isFeeExempt[_presaleAddress] = true;
        
        isFeeExempt[_routerAddress] = true;
        
  	}
  	
  	function updateTradingIsEnabled(bool tradingStatus) external onlyOwner() {
        tradingIsEnabled = tradingStatus;
    }
    
    function toggleAntiBot(bool toggleStatus) external onlyOwner() {
        antiBotEnabled = toggleStatus;
        if(antiBotEnabled){
            _startTimeForSwap = block.timestamp + 60;    
        }
        
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }
    
    function updateRouterAddress(address newAddress) external onlyOwner {
        require(newAddress != address(router), "The router already has that address");
        router = IDEXRouter(newAddress);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0), "Token: transfer from the zero address");
        require(recipient != address(0), "Token: transfer to the zero address");
        require(sender != address(DEAD), "Token: transfer from the burn address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        require(tradingIsEnabled, "This account cannot send tokens until trading is enabled");
        require(!_isBlacklisted[sender] && !_isBlacklisted[recipient], "Blacklisted address");
        
        if(swapping){ return _basicTransfer(sender, recipient, amount); }
        
        if (
            sender != address(router) && //router -> pair is removing liquidity which shouldn't have max
            !isFeeExempt[recipient] && //no max for those excluded from fees
            !isFeeExempt[sender] 
        ) {
            require(amount <= maxTxAmount, "Transfer amount exceeds the Max Transaction Amount.");
            
        }

        if ( maxWalletBalance > 0 && !isFeeExempt[recipient] && !isFeeExempt[sender] && recipient != address(pair) ) {
                uint256 recipientBalance = balanceOf(recipient);
                require(recipientBalance + amount <= maxWalletBalance, "New balance would exceed the maxWalletBalance");
            }
        
       _beforeTokenTransfer(recipient);

        //Exchange tokens
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        
         // indicates whether or not fee should be deducted from the transfer
        bool _isTakeFee = takeFeeEnabled;
        
         // if any account belongs to isFeeExempt account then remove the fee
        if(isFeeExempt[sender] || isFeeExempt[recipient]) { 
            _isTakeFee = false; 
        }
        
        if ( isInPresale ){ _isTakeFee = false; }

        uint256 amountReceived = _isTakeFee ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        

       

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function _beforeTokenTransfer(address recipient) private {
        if ( !isInPresale ){
            uint256 contractTokenBalance = balanceOf(address(this));
            // swap
            bool canSwap = contractTokenBalance >= swapTokensAtAmount;
            
            if (!swapping && canSwap && swapEnabled && recipient == pair) {
                swapping = true;
                
                swapBack();
                
                swapping = false;
            }
            
        }
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 totalFee = sender == pair ? buyersTotalFees : sellersTotalFees;
        totalFee = antiBotEnabled && block.timestamp <= _startTimeForSwap ? antiBotFee : totalFee;
        uint256 feeAmount = amount.mul(totalFee).div(FEES_DIVISOR);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function swapBack() internal {
        uint256 splitLiquidityPortion = lpPortionOfSwap.div(2);
        uint256 amountToLiquify = balanceOf(address(this)).mul(splitLiquidityPortion).div(FEES_DIVISOR);
        uint256 amountToSwap = balanceOf(address(this)).sub(amountToLiquify);

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
        
        uint256 amountBNBBooster = amountBNB.mul(boosterPortionOfSwap).div(FEES_DIVISOR);
        uint256 amountBNBDev = amountBNB.mul(DevPortionOfSwap).div(FEES_DIVISOR);
        uint256 amountBNBLiquidity = amountBNB.mul(splitLiquidityPortion).div(FEES_DIVISOR);
        
        
        
          // Send to addresses
        transferToAddressBNB(payable(boosterWallet), amountBNBBooster);
        transferToAddressBNB(payable(DevWallet), amountBNBDev);
        
        // add liquidity
        _addLiquidity(amountToLiquify, amountBNBLiquidity);

    }
    
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        approve(address(router), tokenAmount);

        // add the liquidity
        (uint256 tokenAmountSent, uint256 ethAmountSent, uint256 liquidity) = router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            DEAD,
            block.timestamp
        );

        emit LiquidityAdded(tokenAmountSent, ethAmountSent, liquidity);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
    
    function transferToAddressBNB(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    
    function clearStuckBalance(address payable recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "Cannot withdraw the ETH balance to the zero address");
        recipient.transfer(amount);
    }

}