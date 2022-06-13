/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// File: Tako.sol

//SPDX-License-Identifier: Unlicensed
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
    event RenounceOwnership( address owner );
    address internal owner;
    
    constructor ( address _owner ) { owner = _owner; }
    
    function isOwner( address account ) public view returns (bool) { return account == owner; }
    function renounceOwnership() public virtual onlyOwner { owner = address(0); }
    
    modifier onlyOwner() { require( isOwner(msg.sender), "No eres Owner" ); _;}
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

interface IBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
}

contract ERC20 is IBEP20, Auth{
    using SafeMath for uint256;
        //mapping
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => uint256) private balance; //Direcciones con Supply repartido
    mapping(address => bool) internal sinTax; //Direcciones sin Tax
    mapping(address => bool) public isPair;
        
        //addresses
    DEXRouter internal dexRouter;
    address internal PAIR; //Direccion de la LiquidityPool
    address internal DEXROUTER; //Contrato del DEX

    address internal SUPPORT; //Creador de This Contract
    address internal MARKETING; //Wallet de Marketing
    address internal DEV; //Wallet de los DEVS

        //strings
    string _name; //Nombre del ERC20
    string _symbol; //Simbolo del ERC20
    uint8 _decimals; //Decimales del ERC20
    
        //uint
    uint8 buyTax = 8;
    uint8 sellTax = 8;

    uint8 transferTax = 30;
    uint8 liquidityTax = 200;
    uint16 projectTax = 800;

    uint256 constant TAX_DENOMINATOR = 1000;
    uint256 constant MAXTAXDENOMINATOR = 10;
    
    uint256 public swapTreshold = 4;
    uint256 public overLiquifyTreshold = 550;

    uint256 _totalSupply; //Supply del ERC20
    uint256 _circulatingSupply =_totalSupply;
    uint256 maxTransactionAmount; //3% max tx
    uint256 maxWalletBalance; //3% max wallet

    uint256 private LaunchTimestamp = 0;
    uint256 antiSniper;
    
    //bool
    bool internal inSwap;
    bool public manualSwap;

    constructor(
        string memory name_, //Settear Nombre durante el Deploy
        string memory symbol_, //Settear Simbolo durante el Deploy
        uint8 decimals_, //Settear Decimales durante el Deploy
        uint256 totalSupply_ //Settear Supply durante el Deploy
        ) Auth(msg.sender) {
        MARKETING = 0xAe4b63a31e5B7479538BDd3e76e8a99f7b7C1f5A;
        DEV = 0x4bbCEecd0C6f9Fc509Ca2621Defef28937a40E5d;
        DEXROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

        dexRouter = DEXRouter(DEXROUTER);
        PAIR = DEXFactory(dexRouter.factory()).createPair(address(this), dexRouter.WETH());
        allowances[address(this)][address(dexRouter)] = type(uint256).max;
        allowances[address(this)][msg.sender] = type(uint256).max;
        isPair[PAIR]=true;

        sinTax[msg.sender] = true;
        sinTax[DEXROUTER] = true;
        sinTax[address(this)] = true;
        
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * 10**_decimals;

        maxWalletBalance = _totalSupply.mul(4).div(100);
        
        balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    modifier swapping() { inSwap = true; _; inSwap = false; }

    function removeAntiSnipe() external onlyOwner {
        require( LaunchTimestamp == 0 );
        LaunchTimestamp = block.timestamp;
    } 

    //Eventos del ERC20
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed wallet, address indexed spender, uint256 amount);

    //Información del ERC20 - Custom views
    function name() public view returns (string memory) {return _name;}
    function symbol() public view returns (string memory) { return _symbol; }
    function decimals() public view returns (uint8) {return _decimals;}
    function totalSupply() public view returns (uint256) { return _totalSupply; }
    function balanceOf(address wallet) public view returns (uint256) { return balance[wallet]; }
    function allowance(address _owner, address spender) external view returns (uint) { return allowances[_owner][spender]; }
    function isOverLiquified() public view returns(bool){ return balance[PAIR] > _circulatingSupply * overLiquifyTreshold/1000; } 

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

        if( sinTax[sender] || sinTax[recipient] ) _transferSinTax(sender, recipient, amount);
        else { require( LaunchTimestamp > 0 ); _transferConTax(sender,recipient,amount); }
    }

    function _transferSinTax( address sender, address recipient, uint amount ) private{
        require( balance[sender] >= amount, "Transfer exceeds balance" );
        
        balance[sender] -= amount;
        balance[recipient] += amount;      
        
        emit Transfer(sender,recipient,amount);
    }

    function _transferConTax(address sender, address recipient, uint amount) private{
        require( balance[sender] >= amount, "Transfer exceeds balance" );
        bool _isBuy = isPair[sender];
        bool _isSell = isPair[recipient];
        uint _tax;
        antiSniper = 27 seconds;

        if( block.timestamp < LaunchTimestamp + antiSniper ){
            _tax = ( amount * 40 ) / 100;
        } else if( _isBuy ) {
            require( balanceOf(recipient) + amount <= maxWalletBalance, "Exceeds maxWalletBalance" );
            _tax = ( amount * buyTax ) / 100;
        } else if( _isSell ) { 
            _tax = ( amount * sellTax ) / 100; 
        } else _tax = ( amount * transferTax ) / 100;
        
        uint _amountConTax = amount.sub(_tax);

        balance[sender] -= amount;
        balance[address(this)] += _tax;
        if( ( sender != PAIR ) && ( !manualSwap ) && ( !inSwap ) ) _swapContractToken( true );
        balance[recipient] += _amountConTax;
        
        emit Transfer( sender, recipient, _amountConTax );
    }

    //Swap
    function SwapContractToken() public onlyOwner{
        _swapContractToken(true);
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
        (bool sent2, ) = DEV.call{ value: devBNB }("");
        sent = true;
        sent2 = true;
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
    }

    //Setter
    function setSwapTreshold(uint newSwapTresholdPermille) public onlyOwner{
        require( newSwapTresholdPermille <= 10);//MaxTreshold = 1%
        swapTreshold = newSwapTresholdPermille;
    }

    function SetOverLiquifiedTreshold(uint newOverLiquifyTresholdPermille) public onlyOwner{
        require(newOverLiquifyTresholdPermille <= 1000);
        overLiquifyTreshold = newOverLiquifyTresholdPermille;
    }

    function setSinTax(address account, bool noTax) public onlyOwner{ sinTax[account] = noTax; }

    function SetManualSwap( bool manual ) public onlyOwner{ manualSwap = manual; }
}