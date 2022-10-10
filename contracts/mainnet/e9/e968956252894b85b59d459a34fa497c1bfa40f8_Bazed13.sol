/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}  
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin,
                            uint amountETHMin, address to, uint deadline) 
                            external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired,
                          uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline)
                          external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path,
                                                                address to,uint deadline) external payable;
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path,
                                      address to, uint256 deadline) 
                                      external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(uint256 amountOut, uint256 amountInMax, address[] calldata path,
                                      address to, uint256 deadline) 
                                      external returns (uint256[] memory amounts);

    function swapExactETHForTokens(uint256 amountOutMin, address[] calldata path, address to,
                                   uint256 deadline) 
                                   external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(uint256 amountOut, uint256 amountInMax, address[] calldata path,
                                   address to, uint256 deadline) 
                                   external returns (uint256[] memory amounts);

    function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path,
                                   address to, uint256 deadline) 
                                   external returns (uint256[] memory amounts);

    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to,
                                   uint256 deadline) 
                                   external payable returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin,
                                                                address[] calldata path,
                                                                address to,
                                                                uint deadline) external;
}


interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
        function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract Bazed13 is IERC20,Ownable { // CONTRACT NAME FOR YOUR CUSTOM CONTRACT
    IRouter public Router;
    address public Pair;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    address public USD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //WRITE THE USD ADDRESS YOU WANT (USDC/BUSD..)
    bool public tradingEnabled = false;
    uint256 private totalSellFees;
    uint256 private totalBuyFees;
    string private _name = "Bazed13Token"; // Token Name
    string private _symbol = "B13T"; // Token Symbol
    uint8 private _decimals = 18;
    uint256 private _totalSupply;

    address payable public marketingWallet; //IF YOU CHANGE THIS NAME U MUST CHANGE IT EVERYWHERE ELSE
    address payable public devWallet; //IF YOU CHANGE THIS NAME U MUST CHANGE IT EVERYWHERE ELSE
    uint256 public maxWallet;
    bool public maxWalletEnabled = true;
    uint256 public swapTokensAtAmount;
    uint256 public sellMarketingFees;
    uint256 public sellBurnFee;
    uint256 public buyMarketingFees;
    uint256 public buyBurnFee;
    uint256 public buyDevFee;
    uint256 public sellDevFee;
    uint256 public buyLp;
    uint256 public sellLp;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isBot;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) private canTransferBeforeTradingIsEnabled;

    bool public limitsInEffect = true; 
    mapping(address => uint256) private _holderLastTransferBlock; // FOR 1TX PER BLOCK
    mapping(address => uint256) private _holderLastTransferTimestamp; // FOR COOLDOWN
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 public launchblock; // FOR DEADBLOCKS
    uint256 public launchtimestamp; // FOR LAUNCH TIMESTAMP 
    uint256 public cooldowntimer = 30; // DEFAULT COOLDOWN TIMER

    event SetPreSaleWallet(address wallet);
    event updateMarketingWallet(address wallet);
    event updateDevWallet(address wallet);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event TradingEnabled();

    event UpdateFees(uint256 sellMarketingFees, uint256 sellBurnFee, uint256 buyMarketingFees,
                     uint256 buyBurnFee, uint256 buyDevFee, uint256 sellDevFee, uint256 buyLp, uint256 sellLp);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event blackList(address);
    event unblackList(address);
    event transferUSD(uint256 amountUSD);

    constructor() { 
        marketingWallet = payable(0x0D16211701B8da7caef6b6D66Aa5E80Cf7AA6763); // CHANGE THIS TO YOURS
        devWallet = payable(0x0D16211701B8da7caef6b6D66Aa5E80Cf7AA6763); // CHANGE THIS TO YOURS
        address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; /// This is the PancakeSwap Router

        //INITIAL FEE VALUES HERE
        buyMarketingFees = 1;
        sellMarketingFees = 3;
        buyBurnFee = 1;
        sellBurnFee = 3;
        buyDevFee = 1;
        sellDevFee = 3;
        buyLp=2;
        sellLp=4;

        // TOTAL BUY AND TOTAL SELL FEE CALCS
        totalBuyFees = buyMarketingFees+buyDevFee;
        totalSellFees = sellMarketingFees+sellDevFee;

        Router = IRouter(router);
        Pair = IFactory(Router.factory()).createPair(
                address(this), USD);


        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[msg.sender] = true;
        _isExcludedFromFees[marketingWallet] = true;
        _isExcludedFromFees[devWallet] = true;

        _totalSupply = 1_000_000_000 * (10**18); // Total Supply
        canTransferBeforeTradingIsEnabled[owner()] = true;
        canTransferBeforeTradingIsEnabled[address(this)] = true;
        _balances[msg.sender] = _totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    receive() external payable {}

    function enableTrading() external onlyOwner {
        require(!tradingEnabled);
        tradingEnabled = true;
        launchblock = block.number;
        launchtimestamp = block.timestamp;
        emit TradingEnabled();
    }
    
    function setMarketingWallet(address wallet) external onlyOwner {
        _isExcludedFromFees[wallet] = true;
        marketingWallet = payable(wallet);
        emit updateMarketingWallet(wallet);
    }

    function setDevWallet(address wallet) external onlyOwner {
        _isExcludedFromFees[wallet] = true;
        devWallet = payable(wallet);
        emit updateDevWallet(wallet);
    }
    
    function setExcludeFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function addBot(address[] memory accounts ) public onlyOwner {
        for (uint i=0; i < (accounts.length); i++) {
            _isBot[accounts[i]] = true;
            emit blackList(accounts[i]);
        }
    }
    function removeBot(address account) public onlyOwner {
        _isBot[account] = false;
        emit unblackList(account);
    }

    // TAKES ALL ETH (BNB) FROM THE CONTRACT ADDRESS AND SENDS IT TO OWNERS WALLET
    function SendETH() external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(msg.sender).transfer(amountETH);
    }

    function SendUSD() external onlyOwner {
        uint256 amountUSD = IERC20(USD).balanceOf(address(this));
        IERC20(USD).approve(address(this), amountUSD*10);
        IERC20(USD).transferFrom(address(this),msg.sender,amountUSD);
        emit transferUSD(amountUSD);
    }

    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
        swapTokensAtAmount = amount * (10**18);
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);        
        return true;
    }

    function updateFees(uint256 marketingBuy, uint256 marketingSell, uint256 burnBuy,
                        uint256 burnSell, uint256 devBuy, uint256 devSell, uint256 lpBuy,uint256 lpSell) public onlyOwner {

        buyMarketingFees = marketingBuy;
        buyBurnFee = burnBuy;
        sellMarketingFees = marketingSell;
        sellBurnFee = burnSell;
        buyDevFee = devBuy;
        sellDevFee = devSell;
        buyLp = lpBuy;
        sellLp = lpSell;

        totalSellFees = sellMarketingFees+sellDevFee+buyLp;
        totalBuyFees = buyMarketingFees+buyDevFee+sellLp;

        emit UpdateFees(sellMarketingFees, sellBurnFee, sellDevFee, buyMarketingFees,
                        buyBurnFee, buyDevFee, buyLp, sellLp);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function isBot(address account) public view returns (bool) {
        return _isBot[account];
    }

    function swapTokensForUSD(uint256 tokenAmount, address destAddr) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USD;
        _approve(address(this), address(Router), tokenAmount);
        Router.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of USD
            path,
            destAddr,
            block.timestamp
        );
    }

    function forceSwapAndSendUSD(uint256 tokens) public onlyOwner {
        payWallets(tokens);
    }

    function forceSwapAndAddLiquidity(uint256 tokens, address to) public onlyOwner {
        swapAndAddLiquidity(tokens, to);
    }
    /*
    function forceSwapAndAddLiquidityETH(uint256 tokens, address to) public onlyOwner {
        swapAndAddLiquidityETH(tokens, to);
    }
    */

    // in this function, the contract sells his tokens and send USD to marketing and dev wallets
    function payWallets(uint256 tokensFromFees) private {

        uint256 totalMarketingFees = sellMarketingFees+buyMarketingFees;
        uint256 totalDevFees = sellDevFee + buyDevFee;
        uint256 totalLpFees = sellLp + buyLp;
        uint256 totalFees = totalMarketingFees+totalDevFees+totalLpFees;
        uint256 partMarketing = (totalMarketingFees*100)/(totalFees); //*100 because uint256
        uint256 partDev = (totalDevFees*100)/(totalFees); //*100 because uint256
        uint256 partLp = (totalLpFees*100)/(totalFees); //*100 because uint256

        uint256 marketingPayout = (tokensFromFees * partMarketing)/(100);
        uint256 devPayout = (tokensFromFees * partDev)/(100);
        uint256 toLP = (tokensFromFees * partLp)/(100);
        if (marketingPayout > 0) {
            swapTokensForUSD(marketingPayout, marketingWallet);
        }
        if (devPayout > 0) {
            swapTokensForUSD(devPayout, devWallet);
        }
        if (toLP > 0) {
            swapAndAddLiquidity(toLP, address(0));
            //swapAndAddLiquidityETH(toLP, address(0));
        }
        
    }

    function _transfer(address from, address to, uint256 amount) private returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBot[from] && !_isBot[to], "You are a bot");
        if (!canTransferBeforeTradingIsEnabled[from]) {
            require(tradingEnabled, "Trading is not enabled");          
        }
        uint256 fees;
        uint256 burnTokens;
        uint256 newAmount;
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]){
            if (to==(Pair)) {
                //sell
                fees=((sellMarketingFees+sellDevFee)*amount)/100;
                burnTokens=(sellBurnFee*amount)/100;
                uint256 balanceContract = _balances[address(this)];
                if (balanceContract>swapTokensAtAmount) {
                    payWallets(balanceContract);
                }
            }
            if (from==(Pair)) {
                //buy
                fees=((buyMarketingFees+buyDevFee)*amount)/100;
                burnTokens=(buyBurnFee*amount)/100;
            }
            newAmount=amount-fees-burnTokens;
            _basicTransfer(from,to,newAmount);
            _doubleTransfer(from,DEAD,address(this),burnTokens,fees);
        }
        else {
        _basicTransfer(from,to,amount);
        }
        //if (msg.sender!=from){
        emit Transfer(from, to, amount);
        //}
        return true;
    }
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender]-(amount);
        _balances[recipient] = _balances[recipient]+(amount);
        return true;
    }
    function _doubleTransfer(address sender, address recipient1, address recipient2, uint256 amount1, uint256 amount2) internal returns (bool) {
        _balances[sender] = _balances[sender]-(amount1+amount2);
        _balances[recipient1] = _balances[recipient1]+(amount1);
        _balances[recipient2] = _balances[recipient2]+(amount2);
        //emit Transfer(sender, recipient1, amount1);
        return true;
    }

    function swapAndAddLiquidity(uint256 toLP, address destAddr) private returns (bool) {
        uint256 halfTokens=toLP/2;
        uint256 otherHalf=toLP-halfTokens;
        swapTokensForUSD(halfTokens,address(this));
        uint256 balanceUSD = IERC20(USD).balanceOf(address(this));
        //approvals
        _approve(address(this), address(Router), otherHalf);
        IERC20(USD).approve(address(Router), balanceUSD);
        
        Router.addLiquidity(
            address(this), 
            USD,
            otherHalf, 
            balanceUSD, 
            0, 
            0, 
            destAddr,
            block.timestamp);
        return true;
    }
    /*
    function swapAndAddLiquidityETH(uint256 toLP, address destAddr) private returns (bool) {
        uint256 halfTokens=toLP/2;
        uint256 otherHalf=toLP-halfTokens;
        swapTokensForUSD(halfTokens,address(this));
        uint256 balanceUSD = IERC20(USD).balanceOf(address(this));
        //approvals
        _approve(address(this), address(Router), otherHalf);
        IERC20(USD).approve(address(Router), balanceUSD);
        Router.addLiquidityETH(
            address(this),
            otherHalf, 
            0,                
            0, 
            destAddr, 
            block.timestamp);
        return true;
    }
    function swapTokensForETH(uint256 tokenAmount, address destAddr) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = USD;
        path[2] = Router.WETH();
        _approve(address(this), address(Router), tokenAmount);
        Router.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            destAddr,
            block.timestamp
        );
    }
    */


}