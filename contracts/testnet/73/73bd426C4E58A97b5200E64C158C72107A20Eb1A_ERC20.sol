/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

// File: .deps/Tako.sol


pragma solidity >=0.8.0 <0.9.0;
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b; // assert(a == b * c + a % b);
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;
    
    constructor ( address _owner ) {
        owner = _owner;
        authorizations[_owner] = true;
    }
    
    function authorize( address adr ) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner( address account ) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized( address adr ) public view returns (bool) {
        return authorizations[adr];
    }

    function renounceOwnership() public virtual onlyOwner {
        owner = address(0);
        emit OwnershipTransferred( owner );
    }

    modifier onlyOwner() {
        require( isOwner(msg.sender), "No eres Owner" ); _;
    }

    modifier onlySupport() {
        require( isAuthorized(msg.sender), "No eres Support" );
        _;
    }

    event OwnershipTransferred(address owner);
}


interface DEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface DEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
}

contract ERC20 is Auth{
    using SafeMath for uint256;
        //mapping
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => uint256) private balance; //Direcciones con Supply repartido
    mapping(address => bool) internal sinTax; //Direcciones sin Tax
    mapping(address => bool) sinTxLimit;
    mapping(address => bool) public Blacklist;
    mapping(address => bool) public isPair;
        
        //addresses
    DEXRouter internal dexRouter;
    address internal PAIR; //Direccion de la LiquidityPool
    address internal DEXROUTER; //Contrato del DEX
    address internal DEXROUTER_GAS;
    address internal DEAD;
    address internal ZERO;
    address internal SUPPORT; //Creador de This Contract
    address internal MARKETING; //Wallet de Marketing
    address internal DEV; //Wallet de los DEVS

        //strings
    string _name; //Nombre del ERC20
    string _symbol; //Simbolo del ERC20
    uint8 _decimals; //Decimales del ERC20
    
        //uint
    uint8 liquidityFee = 2;
    uint8 devFee = 1;
    uint8 marketingFee = 1;

    uint8 buyTax = 80;
    uint8 sellTax = 80;

    uint8 transferTax = 30;
    uint8 liquidityTax = 200;
    uint16 projectTax = 800;

    uint256 constant TAX_DENOMINATOR = 1000;
    uint256 constant MAXTAXDENOMINATOR = 10;
    
    uint256 public swapTreshold = 4;
    uint256 public overLiquifyTreshold = 55;

    uint256 _totalSupply; //Supply del ERC20
    uint256 _circulatingSupply =_totalSupply;
    uint256 maxTransactionAmount; //3% max tx
    uint256 maxWalletBalance; //3% max wallet
    
    //bool
    bool internal inSwap;
    bool public manualSwap;

    constructor(
        string memory name_, //Settear Nombre durante el Deploy
        string memory symbol_, //Settear Simbolo durante el Deploy
        uint8 decimals_, //Settear Decimales durante el Deploy
        uint256 totalSupply_, //Settear Supply durante el Deploy
        address marketing_, //Settear Wallet de Marketing durante el Deploy
        address dev_ //Settear Wallet de Team durante el Deploy
        ) Auth(msg.sender) {
        MARKETING = marketing_;
        DEV = dev_;
        DEXROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        DEAD = 0x000000000000000000000000000000000000dEaD;
        ZERO = 0x0000000000000000000000000000000000000000;

        dexRouter = DEXRouter(DEXROUTER);
        PAIR = DEXFactory(dexRouter.factory()).createPair(address(this), dexRouter.WETH());
        allowances[address(this)][address(dexRouter)] = type(uint256).max;
        allowances[address(this)][msg.sender] = type(uint256).max;
        isPair[PAIR]=true;

        sinTax[msg.sender] = true;
        sinTax[DEXROUTER] = true;
        sinTax[address(this)] = true;
        sinTxLimit[msg.sender] = true;
        sinTxLimit[address(this)] = true;
        
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * 10**_decimals;
        
        balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    modifier swapping() { 
        inSwap = true; 
        _; 
        inSwap = false; 
    }

    //BlackList
    function setBlacklist( address[] calldata addresses, bool status ) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            Blacklist[addresses[i]] = status;
        }
        emit BlacklistUsers();
    }

    //Setter
    function setSwapTreshold(uint newSwapTresholdPermille) public onlyOwner{
        require( newSwapTresholdPermille <= 10);//MaxTreshold = 1%
        
        swapTreshold = newSwapTresholdPermille;
        emit SwapThresholdChange(newSwapTresholdPermille);
    }

    function SetOverLiquifiedTreshold(uint newOverLiquifyTresholdPermille) public onlyOwner{
        require(newOverLiquifyTresholdPermille <= 1000);
        
        overLiquifyTreshold = newOverLiquifyTresholdPermille;
        emit OverLiquifiedThresholdChange(newOverLiquifyTresholdPermille);
    }

    function SetTaxes(uint8 buy, uint8 sell, uint8 transfer_, uint16 project, uint8 liquidity) public onlyOwner{
        uint maxTax = TAX_DENOMINATOR.div( MAXTAXDENOMINATOR );
        require( buy <= maxTax && sell <= maxTax && transfer_ <= maxTax,"Tax exceeds maxTax" );
        require(project + liquidity == TAX_DENOMINATOR,"Taxes don't add up to denominator" );
        
        buyTax = buy;
        sellTax = sell;
        transferTax = transfer_;
        projectTax = project;
        liquidityTax = liquidity;

        emit OnSetTaxes(buy, sell, transfer_, project, liquidity);
    }

    function SetPair(address NewPair, bool Add) public onlyOwner{
        require(NewPair != PAIR,"can't change pancake");
        isPair[NewPair] = Add;
        emit NewPairSet( NewPair, Add );
    }

    function SetNewRouter(address _newdex) public onlyOwner{
        DEXROUTER = _newdex;
        emit NewRouterSet( _newdex );
    }

    function setMaxWalletBalancePercent(uint256 percent) external onlyOwner {
        require( percent >= 1, "min 1%" );
        require( percent <= 100, "max 100%" );

        maxWalletBalance = _totalSupply * percent / 100;
        emit MaxWalletBalanceUpdated(percent);
    }
    
    function setMaxTransactionAmount(uint256 percent) public onlyOwner {
        require(percent >= 25, "min 0.25%");
        require(percent <= 10000, "max 100%");

        maxTransactionAmount = _totalSupply * percent / 10000;
        emit MaxTransactionAmountUpdated(percent);
    }

    function setSinTax(address account, bool noTax) public onlyOwner{
        sinTax[account] = noTax;
        emit SetSinTax( account, noTax );
    }
    
    function setSinTxLimit(address account, bool noLimit) public onlyOwner{
        sinTxLimit[account] = noLimit;
        emit SetSinTxLimit(account, noLimit);
    }

    function SetBeginTrade() public onlyOwner{
        maxWalletBalance = _totalSupply * 2 / 100;
        maxTransactionAmount = _totalSupply * 1 / 100;
        emit BeginTrade();
    }

    function SetManualSwap( bool manual ) public onlyOwner{
        manualSwap = manual;
        emit OnSetManualSwap(manual);
    }

        //TAX
    function _calculateFee(uint amount, uint tax, uint taxPercent) private pure returns (uint) {
        return (amount * tax * taxPercent) / (TAX_DENOMINATOR * TAX_DENOMINATOR);
    }

    function isOverLiquified() public view returns(bool){
        return balance[PAIR] > _circulatingSupply * overLiquifyTreshold/1000;
    } 

        //Swap
    function SwapContractToken() public onlyOwner{
        _swapContractToken(true);
        emit OwnerSwap();
    }

    function _swapTokenForBNB(uint amount) private {
        _approve( address(this), address( DEXROUTER ), amount );
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        try dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens( amount, 0, path, address(this), block.timestamp ){}
        catch{}
    }

    function _addLiquidity(uint ERC20amount, uint BNBamount) private {
        _approve(address(this), address(DEXROUTER), ERC20amount);
        
        dexRouter.addLiquidityETH{value: BNBamount}( address(this), ERC20amount, 0, 0, address(this), block.timestamp );
    }

        //Emergency
    function withdrawBNBemergency(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
        emit RecoverBNB();
    }

    //Información del ERC20 - Custom views
    function name() public view returns (string memory) {return _name;}
    function symbol() public view returns (string memory) { return _symbol; }
    function decimals() public view returns (uint8) {return _decimals;}
    function totalSupply() public view returns (uint256) { return _totalSupply; }
    function balanceOf(address wallet) public view returns (uint256) { return balance[wallet]; }
    function allowance(address _owner, address spender) external view returns (uint) { return allowances[_owner][spender]; }

    //Eventos del ERC20
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed wallet, address indexed spender, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    event BlacklistUsers();
    
    event SwapThresholdChange(uint threshold); //SETTER
    event OverLiquifiedThresholdChange(uint threshold); //SETTER
    
    event OnSetTaxes(uint buy, uint sell, uint transfer_, uint project,uint liquidity); //SETTER
    event NewPairSet(address Pair, bool Add); //SETTER
    event NewRouterSet(address _newdex); //SETTER
    event MaxWalletBalanceUpdated(uint256 percent); //SETTER
    event MaxTransactionAmountUpdated(uint256 percent); //SETTER
    event SetSinTax(address account, bool exclude);
    event SetSinTxLimit(address account, bool exclude);

    event BeginTrade(); //SETTER
    event OnSetManualSwap(bool status);

    event OwnerSwap();
    event Address1Change( address newaddress );
    event FeeSent( address indexed to, uint amount );
    event RecoverBNB();

    function approve( address spender, uint amount ) external returns (bool) {
        _approve( msg.sender, spender, amount );
        return true;
    }

    function _approve(address wallet, address spender, uint amount) private {
        require(wallet != address(0), "Approve from zero");
        require(spender != address(0), "Approve to zero");
        
        allowances[wallet][spender] = amount;
        emit Approval(wallet, spender, amount);
    }

    function transfer(address recipient, uint amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        
        require(allowances[sender][msg.sender] >= amount, "Transfer > allowance");
        _approve(sender, msg.sender, allowances[sender][msg.sender] - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint amount) private{
        require( sender != address(0), "Transfer from zero" );
        require( recipient != address(0), "Transfer to zero" );
        require( !Blacklist[sender] && !Blacklist[recipient],"Blacklisted" );

        if( sinTax[sender] || sinTax[recipient] ) _transferSinTax(sender, recipient, amount);
        else { _transferConTax(sender,recipient,amount); }
    }

    function _transferSinTax( address sender, address recipient, uint amount ) private{
        require( balance[sender] >= amount, "Transfer exceeds balance" );
        
        balance[sender] -= amount;
        balance[recipient] += amount;      
        
        emit Transfer(sender,recipient,amount);
    }

    function _transferConTax(address sender, address recipient, uint amount) private{
        require( balance[sender] >= amount, "Transfer exceeds balance" );
        bool _noLimit = sinTxLimit[sender] || sinTxLimit[recipient];
        bool _isBuy = isPair[sender];
        bool _isSell = isPair[recipient];
        uint _tax;
        
        if ( _isBuy && !_noLimit ) {
            require(amount <= maxTransactionAmount,"Transfer amount exceeds the maxTxAmount.");
            require( balanceOf(recipient) + amount <= maxWalletBalance, "Exceeds maximum wallet token amount." );
        } else if ( _isSell && !_noLimit ) {
            require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxSellTransactionAmount.");
        }

        if( _isSell ) _tax = sellTax; 
        else if( _isBuy ) _tax = buyTax; 
            else _tax = transferTax;

        if( ( sender != PAIR ) && ( !manualSwap ) && ( !inSwap ) ) _swapContractToken( true );
        
        uint _fee = _calculateFee( amount, _tax, projectTax + liquidityTax );
        uint _amountConTax = amount.sub(_fee);

        balance[sender] -= amount;
        balance[address(this)] += _fee;
        balance[recipient] += _amountConTax;
        
        emit Transfer( sender, recipient, _amountConTax );
    }

    function _swapContractToken(bool ignoreLimits) private swapping{
        uint contractBalance = balance[address(this)];
        uint totalTax = liquidityTax + projectTax;
        uint tokenToSwap = balance[PAIR] * swapTreshold/1000;
        
        if( totalTax == 0 )return;
        if( ignoreLimits ) tokenToSwap = balance[address(this)];
        else if( contractBalance < tokenToSwap ) return;
        
        uint balanceBNB = address(this).balance;
        uint tokenForLiquidity = isOverLiquified() ? 0:( tokenToSwap*liquidityTax )/totalTax;
        uint LiqERC20 = tokenForLiquidity.div(2);
        
        tokenToSwap -= tokenForLiquidity;
        tokenToSwap += LiqERC20;
        
        _swapTokenForBNB(tokenToSwap);
        
        uint newBNB = ( address(this).balance - balanceBNB );
        
        if( tokenForLiquidity > 0 ){
            uint liqBNB = ( newBNB * LiqERC20 )/tokenToSwap;
            _addLiquidity( LiqERC20, liqBNB );
        }
        
        uint devBNB = (address(this).balance).div(10);
        uint marketingBNB = (address(this).balance).sub(devBNB);

        (bool sent,) = MARKETING.call{value: marketingBNB }("");
        sent=true;
        emit FeeSent(MARKETING, marketingBNB);

        (bool Success, ) = DEV.call{ value: devBNB }("");
        require(Success, "Failed to send funds to TEAM");
        emit FeeSent(DEV, devBNB);
    }

    receive() external payable {
    }
}