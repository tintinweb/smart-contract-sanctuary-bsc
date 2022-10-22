/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

//SPDX-License-Identifier: MIT

/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(///(@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@                           @@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@,          @@@@@@@@@@@@@@@@&          (@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@(       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@       &@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@.      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      #@@@@@@@@@@@@@
@@@@@@@@@@@     *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@
@@@@@@@@@     @@@@@@@@@@@@@%(@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     @@@@@@@@@
@@@@@@@     @@@@@@@@@@@@@@((#%%%%%%%%%%%%%(%##(/@@@@@@@@@@@@@@@@@@@     @@@@@@@
@@@@@,    @@@@@@@@@@@@@@@(%%%#####/////(*(((*###((((,,@@@@@@@@@@@@@@@    #@@@@@
@@@@    ,@@@@@@@@@@@@@##%%((((((((///*//****((#(//((,,,*@@@@@@@@@@@@@@     @@@@
@@@    @@@@@@@@@@@@@@#%%#(((((((((((((`//////(*((((##(***@@@@@@@@@@@@@@%    @@@
@@    @@@@@@@@@@@@@@..((((((((((((((((((((/,,,,,/`(##((**@@@@@@@@@@@@@@@(    @@
@%    @@@@@@@@@@@@@&*`/(((((/`....../###(##(,,,,,,((((((((*.(#&&&@@@@@@@@    @@
@    @@@@@@@@@&&&&&(((/////((/////////&&&#%///,,,,,#(#((//(/*(,#&&&&@@@@@@    @
@    @@@@@&&@@&%%((//(//#(%#%#/////*&&&&&%%/***,,,/(((###,*(**(((@&&&&@@@@    @
@   ,&%&&&@@@&%.......,,////*(/*`//(&&&&&%#%%%%(((#(((((*****(#&&/***%%%@@    @
@   *%%@@@##%#........,,,*,,,,,,((//&&%&%%%%%%%%((,,*********(&&&&&&&(*.%@    @
@    &#(...(%#&&/***,,,,,,,,,,,///(((#&&%%%%#****(,,,,*,,,(&&&&&&&&&&&&&(/    @
@    .. ..,%#%%&&&((#,,,/##((###(((((#%%%%%#**,,,,,,,,*,,,,,/&&&&&&&&&&&&%    @
@%   /..,/%(,#%(&((,,*##(#%%%%%%%%#%%%%%%%%%(((((**,,,,,/(&&%&&&&&&%#&%#(    @@
@@    *,*%%%,/%%*(,(# .(#%%%%%%%%%###(((((%((((##(,,,.,/..#&&&&&%%%&&&&&%    @@
@@@    ,(,,,,,%(/,,,#.,*((##%%%%((((((((((((((**....,,(,.*,&&&(%&*&&&&&%    @@@
@@@@    (.,,,,,/,,.,,//#((,,%####(((((((((((*... .,,,(/ ,*&&&&#%%&&%##,    @@@@
@@@@@*    ,*,,,,.,,,,*#//,/,***%(((........  ....../(/.. .&&%&&#&&#*#    &@@@@@
@@@@@@@    / ,... ,,(/.,,.,,*****`/,,.   .  .   . .     .,#&&/&%#%&     @@@@@@@
@@@@@@@@@     ,,///((//...,#(//*****,`///, ..   ..,,*,,...(#&(%##     @@@@@@@@@
@@@@@@@@@@@     &&%*.  ..  *.**,,,,,.,...../.......**....(#//&&     @@@@@@@@@@@
@@@@@@@@@@@@@/     %%%    .,(..,,,,.*, . .. ......../(#/..*.     &@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@&       *,,*,,,,,.,., ..(.,.,,........,.      @@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@#         .../,/##/#/,,...,*,         &@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@                           @@@@@@@@@@@@@@@@@@@@@@@@@@

/******************************************************************************\
|  _____         _  _           __   _____  _                                  |
| /  __ \       | || |         / _| /  __ \| |                                 |
| | /  \/  __ _ | || |   ___  | |_  | /  \/| |__    ___   ___  _ __ ___   ___  |
| | |     / _` || || |  / _ \ |  _| | |    | '_ \  / _ \ / _ \| '_ ` _ \ / __| |
| | \__/\| (_| || || | | (_) || |   | \__/\| | | ||  __/|  __/| | | | | |\__ \ |
|  \____/ \__,_||_||_|  \___/ |_|    \____/|_| |_| \___| \___||_| |_| |_||___/ |
\******************************************************************************/                                                                        
                                                                            
pragma solidity >=0.8.12 <0.9.0;

interface IERC20 {
    
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline)
        external
        returns (uint[] memory amounts);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

}

interface IUniswapV2Factory {
  function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract CallofCheems is IERC20 {  
      
    string public constant name = "Call of Cheems";
    string public constant symbol = "COC";
    uint8 public constant decimals = 8;
    uint256 public totalSupply;  

    address public MARKETINGWALLET = 0xf8c80cFf4c49DBfBD2aad7f037B9A07E0e46898E; 
    address public OPERATIONSWALLET = 0xc3eFa4F3119D0075460e97Edba9de289b60BB8AD; 
    uint256 public THRESHOLD;
    uint256 public MAXWALLET;
    uint256 public MAXTRANSACTION;

    address private _deployer;
    Tax private _tax;
  
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private isPair;
    mapping(address => bool) private isExempt;
    mapping(address => bool) private isEarlyTrader;
    
    address private _owner = address(0);
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router01 public uniswapV2Router;
    address public uniswapV2Pair; 
    bool inLiquidate;
    bool tradingOpen;

    event Liquidate(uint256 bnbForMarketing, uint256 bnbForOperations, uint256 bnbForLiquidity, uint256 tokensForLiquidity);
    event SetMarketingWallet(address newMarketingWallet);
    event SetOperationsWallet(address newOperationsWallet);
    event TransferOwnership(address _newDev);
    event UpdateExempt(address _address, bool _isExempt);
    event AddPair(address _pair);
    event OpenTrading(bool tradingOpen);
    event RemoveEarlyTrader(address _earlyTrader);

    constructor() {
        _deployer = msg.sender;
        _update(address(0), msg.sender, 1000000 * 10 ** 8);
        uniswapV2Router = IUniswapV2Router01(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        THRESHOLD = totalSupply * 1 / 400; //0.25% swap threshold
        MAXWALLET = totalSupply * 1 / 50; //2% max wallet
        MAXTRANSACTION = totalSupply * 1 / 100; //1% max transaction

        _tax = Tax(40, 30, 30, 10);//4% marketing, 3% operations, 3% liquidity, 10% total tx fee

        isPair[address(uniswapV2Pair)] = true; 
        isExempt[msg.sender] = true;
        isExempt[address(this)] = true;

        allowance[address(this)][address(uniswapV2Pair)] = totalSupply;
        allowance[address(this)][address(uniswapV2Router)] = totalSupply;

        inLiquidate = false;
        tradingOpen = false;
    } 

    struct Tax {
        uint8 marketingTax;
        uint8 operationsTax;
        uint8 liquidityTax;
        uint16 txFee;
    }

    receive() external payable {}

    modifier protected {
        require(msg.sender == _deployer);
        _;
    }

    modifier lockLiquidate {
        inLiquidate = true;
        _;
        inLiquidate = false;
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
        
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
         _transferFrom(msg.sender, to, amount);   
         return true; 
    } 

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        if (allowance[from][msg.sender] != totalSupply) {            
            allowance[from][msg.sender] -= amount;
        }

        _transferFrom(from, to, amount);
        return true;
    }   

    function _transferFrom(address from, address to, uint256 amount) private returns (bool) {

        if(isExempt[from] || isExempt[to]) {
            _update(from, to, amount);
            return true;
        }

        if(!tradingOpen && !isPair[to]) {
            isEarlyTrader[to] = true;
        }

        require(!isEarlyTrader[from] && !isEarlyTrader[to] && tradingOpen);
        require(amount > 0);
        require(amount <= balanceOf[from]); 

        if(isPair[to] || isPair[from]) {
            require((amount <= MAXTRANSACTION));
        }

        if(!isPair[to]) {
        require((balanceOf[to] + amount) <= MAXWALLET);
        }

        if(balanceOf[address(this)] >= THRESHOLD && !inLiquidate && !isPair[from]) {
            _liquidate();
        }

        uint256 fee = 0; 

        if(isPair[from] || isPair[to]) {
            fee = amount * _tax.txFee / 100;            
        }     

        balanceOf[address(this)] += fee;
        balanceOf[from] -= amount;
        balanceOf[to] += (amount - fee); 

        emit Transfer(from, to, amount);  
        return true;                
    } 

    function _update(address from, address to, uint256 amount) private {
        if(from != address(0)){
            balanceOf[from] -= amount;
        }else{
            totalSupply += amount;
        }
        if(to == address(0)){
            totalSupply -= amount;
        }else{
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function _liquidate() private lockLiquidate {
        
        uint256 tokensForLiquidity = (THRESHOLD * _tax.liquidityTax / 100);
        uint256 half = tokensForLiquidity / 2;
        uint256 tokensToSwap = (THRESHOLD - half);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETH(
            tokensToSwap,
            0,
            path,
            address(this),
            block.timestamp + 15
        );

        uint256 totalBNB = address(this).balance;
        uint256 bnbForMarketing = totalBNB * _tax.marketingTax / 100;

        (bool marketingSent, ) = payable(MARKETINGWALLET).call{value:bnbForMarketing}("");
        require(marketingSent);

        totalBNB = address(this).balance;

        uint256 bnbForOperations = totalBNB / 2;
        uint256 bnbForLiquidity = totalBNB - bnbForOperations;
                 
        (bool OperationsSent, ) = payable(OPERATIONSWALLET).call{value:bnbForOperations}("");
        require(OperationsSent);

        if (tokensForLiquidity > 0) {           
            uniswapV2Router.addLiquidityETH{value: bnbForLiquidity}(
            address(this),
            tokensForLiquidity,
            0,
            0,
            DEAD,
            block.timestamp + 15);
        }

        emit Liquidate(bnbForMarketing, bnbForOperations, bnbForLiquidity, tokensForLiquidity);
          
    }

    function setMarketingWallet(address payable newMarketingWallet) external protected {
        MARKETINGWALLET = newMarketingWallet;
        emit SetMarketingWallet(newMarketingWallet);       
    }

    function setOperationsWallet(address payable newOperationsWallet) external protected {
        OPERATIONSWALLET = newOperationsWallet;
        emit SetOperationsWallet(newOperationsWallet);     
    }

    function transferOwnership(address _newDev) external protected {
        isExempt[_deployer] = false;
        _deployer = _newDev;
        isExempt[_deployer] = true;  
        emit TransferOwnership(_newDev);    
    }

    function clearStuckBNB() external protected {
        uint256 contractBnbBalance = address(this).balance;
        if(contractBnbBalance > 0){          
            (bool sent, ) = payable(MARKETINGWALLET).call{value:contractBnbBalance}("");
            require(sent);
        }
        emit Transfer(address(this), MARKETINGWALLET, contractBnbBalance);
    }

    function manualLiquidate() external protected {
        require(balanceOf[address(this)] >= THRESHOLD);
        _liquidate();
    }

    function setExempt(address _address, bool _isExempt) external protected {
        isExempt[_address] = _isExempt;
        emit UpdateExempt(_address, _isExempt);
    }

    function addPair(address _address) external protected {
        require(isPair[_address] == false);
        isPair[_address] == true;
        emit AddPair(_address);
    }

    function openTrading() external protected {
        tradingOpen = true;
        emit OpenTrading(tradingOpen);
    }

    function removeEarlyTrader(address _earlyTrader) external protected {
        isEarlyTrader[_earlyTrader] = false;
        emit RemoveEarlyTrader(_earlyTrader);
    }

}