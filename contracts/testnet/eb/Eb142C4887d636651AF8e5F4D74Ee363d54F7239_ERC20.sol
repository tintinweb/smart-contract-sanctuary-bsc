/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

pragma solidity ^0.8.14;
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

    function isOwner( address account ) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized( address adr ) public view returns (bool) {
        return authorizations[adr];
    }

    modifier onlyOwner() {
        require( isOwner(msg.sender), "No eres Owner" ); _;
    }

    modifier authorized() {
        require( isAuthorized(msg.sender), "!AUTHORIZED" );
        _;
    }
}

interface DEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface DexRouter {
    function factory() external pure returns ( address );
    function WETH() external pure returns ( address ) ;
    function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
}

contract ERC20 is Auth{
    using SafeMath for uint256;
    
    DexRouter internal dexRouter;

        //mapping
    mapping( address => mapping(address => uint256) ) private allowances;
    mapping( address => uint256 ) private balance;
    mapping( address => bool ) private sinTax;
    mapping( address => bool ) private sinTxLimit;
    mapping( address => bool ) public isPair;

        //addresses
    address internal PAIR;
    address internal DEXROUTER;
    address internal MARKETING;
    address internal DEV;

        //strings
    string _name;
    string _symbol;
    uint8 _decimals;

        //uint
    uint8 buyTax = 8;
    uint8 sellTax = 8;
    uint8 transferTax = 30;

    uint256 _totalSupply;
    uint256 maxTransactionAmount;
    uint256 maxWalletBalance;

        //bool
    bool internal inSwap;

    bool public antiSniper = true;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_
    ) Auth( msg.sender ) {
        MARKETING = 0xAe4b63a31e5B7479538BDd3e76e8a99f7b7C1f5A;
        DEV = 0x4bbCEecd0C6f9Fc509Ca2621Defef28937a40E5d;

        //Testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        //Mainet:  0x10ED43C718714eb63d5aA57B78B54704E256024E
        dexRouter = DexRouter( 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 );
        PAIR = DEXFactory( dexRouter.factory()).createPair( address(this), dexRouter.WETH() );
        allowances[ address(this) ][ address(dexRouter) ] = type(uint256).max;
        allowances[ address(this) ][ msg.sender ] = type(uint256).max;
        
        isPair[PAIR] = true;

        sinTax[ msg.sender ] = true;
        sinTax[ address(this) ] = true;

        sinTxLimit[ msg.sender ] = true;
        sinTxLimit[ address(this) ] = true;

        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_* 10**_decimals;

        maxWalletBalance = _totalSupply.mul(3).div(100);
        maxTransactionAmount = _totalSupply.mul(2).div(100);

        balance[ msg.sender ] = _totalSupply;
        emit Transfer( address(0), msg.sender, _totalSupply );
    }

    modifier swapping() { 
        inSwap = true; 
        _; 
        inSwap = false; 
    }

    function removeAntiSnipe() external onlyOwner {
        antiSniper = false;
    }

        //Setter
    function SetTaxes( uint8 _buyTax, uint8 _sellTax, uint8 _transferTax ) public onlyOwner{
        require( _buyTax <= 100 && _sellTax <= 100 && _transferTax <= 100, "Tax exceeds maxTax" );
        
        buyTax = _buyTax;
        sellTax = _sellTax;
        transferTax = _transferTax;
    }

    function SetPair( address NewPair, bool Add ) public onlyOwner{
        require(NewPair != PAIR,"can't change pancake");
        isPair[NewPair] = Add;
    }

    function SetNewRouter( address _newdex ) public onlyOwner{
        DEXROUTER = _newdex;
    }

    function setSinTax( address account, bool noTax ) public onlyOwner{
        sinTax[account] = noTax;
    }
    
    function setSinTxLimit( address account, bool noLimit ) public onlyOwner{
        sinTxLimit[account] = noLimit;
    }

        //TAX
    function _calculateFee( uint amount, uint tax ) private pure returns (uint) {
        return ( ( amount * tax ) / 100);
    }
        
        //Emergency
    function withdrawBNBemergency( uint256 amountPercentage ) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable( DEV ).transfer( amountBNB * amountPercentage / 100 );
        emit RecoverBNB();
    }

        //Swap
    function SwapContractToken() public onlyOwner{
        _swapContractToken();
    }

    function _swapTokenForBNB( uint amount ) private {
        _approve( address(this), address( DEXROUTER ), amount );
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        try dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens( amount, 0, path, address(this), block.timestamp ){}
        catch{}
    }

    //Información del ERC20 - Custom views
    function name() public view returns ( string memory ) { return _name; }
    function symbol() public view returns ( string memory ) { return _symbol; }
    function decimals() public view returns (uint8) { return _decimals; }
    function totalSupply() public view returns (uint256) { return _totalSupply; }
    function balanceOf( address wallet ) public view returns (uint256) { return balance[wallet]; }
    function allowance( address wallet, address spender ) external view returns (uint) { return allowances[wallet][spender]; }

    //Eventos del ERC20
    event Approval( address indexed wallet, address indexed spender, uint256 amount );
    event Transfer( address indexed sender, address indexed recipient, uint256 amount );
    event OnSetTaxes( uint buy, uint sell, uint transfer_, uint project,uint liquidity ); 
    event FeeSent( address indexed to, uint amount );
    event RecoverBNB();

    function approve( address spender, uint amount ) external returns (bool) {
        _approve( msg.sender, spender, amount );
        return true;
    }

    function _approve( address wallet, address spender, uint amount ) private {
        require( wallet != address(0), "Approve from zero" );
        require( spender != address(0), "Approve to zero" );
        
        allowances[ wallet ][ spender ] = amount;
        emit Approval( wallet, spender, amount );
    }

    function transfer( address recipient, uint amount ) external returns (bool) {
        _transfer( msg.sender, recipient, amount );
        return true;
    }

    function transferFrom( address sender, address recipient, uint amount ) external returns (bool) {
        _transfer( sender, recipient, amount );
        
        require( allowances[sender][msg.sender] >= amount, "Transfer > allowance" );
        _approve( sender, msg.sender, allowances[sender][msg.sender] - amount );
        return true;
    }

    function _transfer(address sender, address recipient, uint amount) private{
        require( sender != address(0), "Transfer from zero" );
        require( recipient != address(0), "Transfer to zero" );

        if( sinTax[sender] || sinTax[recipient] ) _transferSinTax( sender, recipient, amount );
        else { _transferConTax( sender, recipient, amount ); }
    }

    function _transferSinTax( address sender, address recipient, uint amount ) private{
        require( balance[sender] >= amount, "Transfer exceeds balance" );
        
        balance[sender] -= amount;
        balance[recipient] += amount;      
        
        emit Transfer( sender, recipient, amount );
    }

    function _transferConTax( address sender, address recipient, uint amount ) private{
        require( balance[sender] >= amount, "Transfer exceeds balance" );
        bool _noLimit = sinTxLimit[sender] || sinTxLimit[recipient];
        bool _isBuy = isPair[sender];
        bool _isSell = isPair[recipient];
        uint _tax;
        
        if( antiSniper ){
            _tax = 99;
        } else if( _isBuy ) {
            if( !_noLimit ) { 
                require( amount <= maxTransactionAmount, "Exceeds the maxTransactionAmount" );
                require( balanceOf(recipient) + amount <= maxWalletBalance, "Exceeds maxWalletBalance" );
            }

            _tax = buyTax;
            } else if( _isSell ) { 
                if( !_noLimit ) { 
                    require( amount <= maxTransactionAmount, "Exceeds the maxTransactionAmount" );
                }

                _tax = sellTax; 
            } else _tax = transferTax;

        if( ( sender != PAIR ) && ( !inSwap ) ) _swapContractToken( );
        
        uint _fee = _calculateFee( amount, _tax );
        uint _amountConTax = amount.sub( _fee );

        balance[ sender ] -= amount;
        balance[ address(this) ] += _fee;
        balance[ recipient ] += _amountConTax;
        
        emit Transfer( sender, recipient, _amountConTax );
    }

    function _swapContractToken() private swapping{
        uint contractBalance = balance[ address(this) ];
        
        _swapTokenForBNB( contractBalance );

        uint balanceBNB = address(this).balance;
        uint devBNB = ( balanceBNB ).div(10);
        uint marketingBNB = ( balanceBNB ).sub( devBNB );

        ( bool sent, ) = MARKETING.call{ value: marketingBNB }("");
        sent=true;
        emit FeeSent( MARKETING, marketingBNB );

        ( bool Success, ) = DEV.call{ value: devBNB }("");
        require(Success, "Failed to send funds to TEAM");
        emit FeeSent( DEV, devBNB );
    }

    receive() external payable {
    }
}