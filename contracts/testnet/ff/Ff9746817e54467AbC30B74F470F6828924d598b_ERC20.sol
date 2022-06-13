/**
 *Submitted for verification at BscScan.com on 2022-06-13
*/

// File: Tako.sol

//SPDX-License-Identifier: Unlicensed
pragma solidity >=0.8.0 <0.9.0;
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) return 0;
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
    function renounceOwnership() public virtual onlyOwner {
        owner = address(0);
        emit RenounceOwnership( owner );
    }
    
    modifier onlyOwner() { require( isOwner(msg.sender), "No eres Owner" ); _; }
}

interface DEXFactory { function createPair(address tokenA, address tokenB) external returns (address pair); }

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens( uint amountOutMin, address[] calldata path, address to, uint deadline ) external payable;
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

    struct Share { uint256 amount; uint256 totalExcluded; uint256 totalRealised; }

    IDEXRouter router;
    address routerAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    IBEP20 RewardBUSD = IBEP20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 minutes ;
    uint256 public minDistribution = 1 / 100000 * (10 ** 18);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() { require(!initialized); _; initialized = true; }

    modifier onlyToken() { require(msg.sender == _token); _; }

    constructor (address _router) {
        router = _router != address(0) ? IDEXRouter(_router) : IDEXRouter(routerAddress);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0) distributeDividend(shareholder);

        if(amount > 0 && shares[shareholder].amount == 0)addShareholder(shareholder);
        else if(amount == 0 && shares[shareholder].amount > 0)removeShareholder(shareholder);

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = RewardBUSD.balanceOf( address(this) );

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(RewardBUSD);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}( 0, path, address(this), block.timestamp );

        uint256 amount = RewardBUSD.balanceOf(address(this)).sub(balanceBefore);
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount) currentIndex = 0; 

            if(shouldDistribute(shareholders[currentIndex])) distributeDividend(shareholders[currentIndex]);

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
            RewardBUSD.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend() external {
        require(shouldDistribute(msg.sender), "Too soon. Need to wait!");
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0) return 0; 

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded) return 0; 

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
        //Interfaces
    IDEXRouter internal dexRouter;
    DividendDistributor public dividendDistributor;

        //mapping
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => uint256) private balance; //Direcciones con Supply repartido
    mapping(address => bool) internal sinTax; //Direcciones sin Tax
    mapping(address => bool) public isDividendExempt;
    mapping(address => bool) public isPair;
    mapping(address => bool) public Blacklist;
        
        //addresses
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
    uint8 internal buyTax = 8;
    uint8 internal sellTax = 8;
    uint8 internal transferTax = 30;
    
    uint8 internal liquidityFee = 1;
    uint8 internal marketingFee = 7;
    uint8 internal rewardBUSDFee = 1;
    uint8 internal devFee = 1;
    uint8 internal totalFee = liquidityFee + marketingFee + rewardBUSDFee + devFee;

    uint256 distributorGas = 300000;

    uint256 _totalSupply; //Supply del ERC20
    uint256 _circulatingSupply =_totalSupply;
    uint256 maxWalletBalance; //3% max wallet
    uint256 private LaunchTimestamp;
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

        dexRouter = IDEXRouter( DEXROUTER );
        dividendDistributor = DividendDistributor( DEXROUTER );
        PAIR = DEXFactory( dexRouter.factory() ).createPair( address(this), dexRouter.WETH() );
        allowances[address(this)][address(dexRouter)] = type(uint256).max;
        allowances[address(this)][msg.sender] = type(uint256).max;
        isPair[PAIR]=true;

        sinTax[msg.sender] = true;
        sinTax[DEXROUTER] = true;
        sinTax[address(this)] = true;

        isDividendExempt[PAIR] = true;
        isDividendExempt[msg.sender] = true;
        isDividendExempt[address(this)] = true;
        
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_ * 10**_decimals;

        maxWalletBalance = _totalSupply.mul(4).div(100);
        
        balance[msg.sender] = _totalSupply;
        emit Transfer( address(0), msg.sender, _totalSupply );
    }

    receive() external payable {}

    modifier swapping() { inSwap = true; _; inSwap = false; }

    function removeAntiSnipe() external onlyOwner {
        require( LaunchTimestamp == 0 );
        LaunchTimestamp = block.timestamp;
    } 

    //BlackList
    function addBlackList( address[] calldata addresses ) public onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            Blacklist[addresses[i]] = true;
        }
    }

    function removeFromBlackList(address account) external onlyOwner {
    Blacklist[account] = false;
    }

    //Eventos del ERC20
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed wallet, address indexed spender, uint256 amount);
    event BlacklistUsers();
    event FeeSent( address indexed to, uint amount );
    event RecoverBNB();

    //Información del ERC20 - Custom views
    function name() public view returns (string memory) {return _name;}
    function symbol() public view returns (string memory) { return _symbol; }
    function decimals() public view returns (uint8) {return _decimals;}
    function totalSupply() public view returns (uint256) { return _totalSupply; }
    function balanceOf(address wallet) public view returns (uint256) { return balance[wallet]; }
    function allowance(address _owner, address spender) external view returns (uint) { return allowances[_owner][spender]; }

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

        if( sinTax[sender] || sinTax[recipient] ) _transferSinTax( sender, recipient, amount );
        else { require( LaunchTimestamp > 0 ); _transferConTax( sender,recipient,amount ); }

        // Dividend tracker
        if( !isDividendExempt[sender] )    { try dividendDistributor.setShare(sender, balance[sender]) {} catch {} }
        if( !isDividendExempt[recipient] ) { try dividendDistributor.setShare(recipient, balance[recipient]) {} catch {} }
        try dividendDistributor.process(distributorGas) {} catch {}
    }

    function _transferSinTax( address sender, address recipient, uint amount ) private {
        require( balance[sender] >= amount, "Transfer exceeds balance" );
        
        balance[sender] -= amount;
        balance[recipient] += amount;      
        
        emit Transfer(sender,recipient,amount);
    }

    function _transferConTax(address sender, address recipient, uint amount) private {
        uint256 holdtoken = balance[ sender ];
        require( holdtoken >= amount );
        bool _isBuy = isPair[sender];
        bool _isSell = isPair[recipient];
        uint _tax;
        antiSniper = 27 seconds;

        if( block.timestamp < LaunchTimestamp + antiSniper ){
            _tax = ( amount * 99 ) / 100;
        } else if( _isBuy ) {
            require( holdtoken + amount <= maxWalletBalance, "Exceeds maxWalletBalance" );
            _tax = ( amount * buyTax ) / 100;
        } else if( _isSell ) { 
            _tax = ( amount * sellTax ) / 100; 
        } else _tax = ( amount * transferTax ) / 100;
        
        uint _amountConTax = amount.sub(_tax);

        balance[sender] -= amount;
        balance[address(this)] += _tax;
        if( ( sender != PAIR ) && ( !manualSwap ) && ( !inSwap ) ) _swapContractToken( );
        balance[recipient] += _amountConTax;
        
        emit Transfer( sender, recipient, _amountConTax );
    }

    //Swap
    function SwapContractToken() public onlyOwner{ _swapContractToken(); }

    function _swapContractToken( ) private swapping {
        uint256 balanceERC20 = balance[address(this)];
        uint256 liquifyERC20 = balanceERC20.mul( liquidityFee ).div( totalFee ).div(2);
        uint256 ERC20ToSwap = balanceERC20.sub( liquifyERC20 );
        
        _swapTokenForBNB( ERC20ToSwap );
        
        uint256 balanceBNB = address(this).balance;
        uint256 totalBNBFee = totalFee - ( liquidityFee / 2 );

        uint liquifyBNB = balanceBNB.mul( liquidityFee ).div( totalBNBFee ).div(2);
        uint BUSDBNB = balanceBNB.mul( rewardBUSDFee ).div( totalBNBFee );
        uint marketingBNB = balanceBNB.mul( marketingFee ).div( totalBNBFee );
        uint devBNB = balanceBNB.sub( liquifyBNB ).sub( BUSDBNB ).sub( marketingBNB );

        try dividendDistributor.deposit{ value: BUSDBNB }() {} catch {}
    
        ( bool send, ) = MARKETING.call{ value: marketingBNB }("");
        ( bool send2, ) = DEV.call{ value: devBNB }("");
        send = true;
        send2 = true;

        if( liquifyERC20 > 0 ) _addLiquidity( liquifyERC20, liquifyBNB ); 
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
        _approve( address(this), address(DEXROUTER), ERC20amount );
        dexRouter.addLiquidityETH{value: BNBamount}( address(this), ERC20amount, 0, 0, address(this), block.timestamp );
    }

        //Emergency
    function withdrawBNBemergency(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer( amountBNB * amountPercentage / 100 );
        emit RecoverBNB();
    }

    //Setter
    function SetTax( uint8 _buyTax, uint8 _sellTax, uint8 _transferTax ) public onlyOwner{
        require( _buyTax <= 100 && _sellTax <= 100 && _transferTax <= 100, "Tax exceeds maxTax" );
        
        buyTax = _buyTax;
        sellTax = _sellTax;
        transferTax = _transferTax;
    }

    function changeFees( uint8 newLiqFee, uint8 newRewardFee, uint8 newMarketingFee, uint8 newDevFee ) external onlyOwner {
        liquidityFee = newLiqFee;
        rewardBUSDFee = newRewardFee;
        marketingFee = newMarketingFee;
        devFee = newDevFee;
        
        totalFee = liquidityFee + marketingFee + rewardBUSDFee + devFee;
    }
    
    function setSinTax( address[] calldata addresses ) public onlyOwner {
        for ( uint256 i; i < addresses.length; ++i ) {
            sinTax[addresses[i]] = true;
        }
    }

    function SetManualSwap( bool manual ) public onlyOwner{ manualSwap = manual; }

    //Reflecciones de BUSD
    function changeIsDividendExempt( address holder, bool exempt ) external onlyOwner {
        require( holder != address(this) && holder != PAIR );
        isDividendExempt[holder] = exempt;
        
        if( exempt ) dividendDistributor.setShare( holder, 0 ); 
        else dividendDistributor.setShare( holder, balance[holder] );
    }

    function changeDistributionCriteria( uint256 newinPeriod, uint256 newMinDistribution ) external onlyOwner {
        dividendDistributor.setDistributionCriteria( newinPeriod, newMinDistribution );
    }

    function changeDistributorSettings( uint256 gas ) external onlyOwner {
        require( gas < 300000 );
        distributorGas = gas;
    }
}