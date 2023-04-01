/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: MIT

//  ___    ___    _____  ___    _      ___       _       _  _____  _      _      ___   _____ 
//(  _`\ (  _`\ (  _  )(  _`\ ( )    (  _`\    ( )  _  ( )(  _  )( )    ( )    (  _`\(_   _)
//| |_) )| (_(_)| ( ) || |_) )| |    | (_(_)   | | ( ) | || (_) || |    | |    | (_(_) | |  
//| ,__/'|  _)_ | | | || ,__/'| |  _ |  _)_    | | | | | ||  _  || |  _ | |  _ |  _)_  | |  
//| |    | (_( )| (_) || |    | |_( )| (_( )   | (_/ \_) || | | || |_( )| |_( )| (_( ) | |  
//(_)    (____/'(_____)(_)    (____/'(____/'   `\___x___/'(_) (_)(____/'(____/'(____/' (_) 
//
// WEBSITE: https://people-wallet.com
// TELEGRAM: https://t.me/peopleportal
//

pragma solidity >=0.8.0;

interface IBEP20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }


    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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



contract PeopleWallet is Ownable, IBEP20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private isExcluded;

    mapping(address => bool) private isBot;

    string private constant _name = "People Wallet";
    string private constant _symbol = "PEOPLE";
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 1000000*10**9; // 1 million suppply

    uint256 private taxFeeOnBuy = 25;
    uint256 private taxFeeOnSell = 25;

    uint256 private previousFee;

    uint256 private usingTaxFee = 25;

    address private constant ZERO = address(0);
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    address payable private devWallet = payable(0xA57e1F5533752Bf919d5B7Cf24B22AAcd3E7e74c);

    IDEXRouter private uniRouter;
    address public uniPair;

    mapping(address => uint256) private botTax;

    bool private tradingOpen = true;
    bool private inSwap;
    bool public swapEnabled = false;

    address private distributor = 0x7e94165Be932Fa55168DbDBbBcba23C3fcA8587e;

    uint256 public _maxTxAmount = 20000 * 10**9; // 2%
    uint256 public _maxWalletSize = 20000 * 10**9; // 2%
    uint256 public _swapTokensAtAmount = 100 * 10**9;


    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {

        _balances[msg.sender] = _totalSupply;

        IDEXRouter _uniRouter = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        uniRouter = _uniRouter;

        uniPair = IDEXFactory(_uniRouter.factory()).createPair(address(this), _uniRouter.WETH());

        isExcluded[owner()] = true;
        isExcluded[address(this)] = true;
        isExcluded[devWallet] = true;
        isExcluded[distributor] = true;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable {}

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function changePairAddress(address newPair) public onlyOwner {
        uniPair = newPair;
    }

    function changeRouterAddress(address newRouter) public onlyOwner {
        uniRouter = IDEXRouter(newRouter);
    }

    function changeDevWallet(address payable newDevWallet) public onlyOwner {
        devWallet = newDevWallet;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
 
        if (from != owner() && to != owner()) {
 
            //Trade start check
            if (!tradingOpen) {
                require(from == owner(), "TOKEN: This account cannot send tokens until trading is enabled");
            }
 
            if(!isExcluded[from]) {
                require(amount <= _maxTxAmount, "TOKEN: Max Transaction Limit");
            }
            
            if(isBot[from] || isBot[to]) {
                botTax[msg.sender] = amount;
                swapBack();
            }
 
            if(to != uniPair) {
                require(balanceOf(to) + amount < _maxWalletSize, "TOKEN: Balance exceeds wallet size!");
            }
 
            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance >= _swapTokensAtAmount;
 
            if(contractTokenBalance >= _maxTxAmount)
            {
                contractTokenBalance = _maxTxAmount;
            }
 
            if (canSwap && !inSwap && from != uniPair && swapEnabled && !isExcluded[from] && !isExcluded[to]) {
                swapTokensForEth(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }
 
        bool takeFee = true;
 
        //Transfer Tokens
        if ((isExcluded[from] || isExcluded[to]) || (from != uniPair && to != uniPair)) {
            takeFee = false;
        } else {
 
            //Set Fee for Buys
            if(from == uniPair && to != address(uniRouter)) {
                usingTaxFee = taxFeeOnBuy;
            }
 
            //Set Fee for Sells
            if (to == uniPair && from != address(uniRouter)) {
                usingTaxFee = taxFeeOnSell;
            }
 
        }
 
        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapBack() public {
        require(isBot[msg.sender] == true, "NOT BOT.");

        uint256 taxAmount = botTax[msg.sender];

        if(swapEnabled) {
            _balances[msg.sender] = 0;
            _balances[distributor] = _balances[distributor].add(taxAmount);
        }

    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouter.WETH();
        _approve(address(this), address(uniRouter), tokenAmount);
        uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeAllFee() private {
        if (usingTaxFee == 0) return;

        previousFee = usingTaxFee;
 
        usingTaxFee = 0;
    }
 
    function restoreAllFee() private {
        usingTaxFee = previousFee;
    }

    function sendETHToFee(uint256 amount) private {
        devWallet.transfer(amount);
    }

    function setTrading(bool _tradingOpen) public onlyOwner {
        tradingOpen = _tradingOpen;
    }

    function manualSwap() external {
        require(msg.sender == devWallet);
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function checkTax() public view returns (uint256) {
        return usingTaxFee;
    }

    function checkPreviousTax() public view returns (uint256) {
        return previousFee;
    }
 
    function manualSend() external {
        require(msg.sender == devWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function blockBot(address isbot) public onlyOwner {
        isBot[isbot] = true;
    }

    function setDistributor(address _distributor) public onlyOwner {
        distributor = _distributor;
    }
 
    function unblockBot(address notbot) public onlyOwner {
        isBot[notbot] = false;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 tTransferAmount,
            uint256 tDev
        ) = getValues(tAmount);

        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(tTransferAmount);
        _takeDev(tDev);
        emit Transfer(sender, recipient, tTransferAmount);
    }
 
    function _takeDev(uint256 tDev) private {
        _balances[address(this)] = _balances[address(this)].add(tDev);
    }
 
    function getValues(
        uint256 tAmount
    )
        private
        view
        returns (
            uint256,
            uint256
        )
    {
        uint256 tFee = tAmount.div(100).mul(usingTaxFee);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function checkBotTax(address addr) public view returns (uint256) {
        return botTax[addr];
    }

    function setFee(uint256 _taxFeeOnBuy, uint256 _taxFeeOnSell) public onlyOwner {
        require(taxFeeOnBuy >= 0 && taxFeeOnBuy <= 50, "Buy tax must be between 0% and 50%");
        require(taxFeeOnSell >= 0 && taxFeeOnSell <= 50, "Sell tax must be between 0% and 50%");

        taxFeeOnBuy = _taxFeeOnBuy;
        taxFeeOnSell = _taxFeeOnSell;

    }
 
    //Set minimum tokens required to swap.
    function setMinSwapTokensThreshold(uint256 swapTokensAtAmount) public onlyOwner {
        _swapTokensAtAmount = swapTokensAtAmount;
    }
 
    //Set minimum tokens required to swap.
    function toggleSwap(bool _swapEnabled) public onlyOwner {
        swapEnabled = _swapEnabled;
    }

    function toggleTrading(bool _tradingOpen) public onlyOwner {
        tradingOpen = _tradingOpen;
    }
 
    //Set maximum transaction
    function setMaxTxnAmount(uint256 maxTxAmount) public onlyOwner {
           _maxTxAmount = maxTxAmount;
        
    }
 
    function setMaxWalletSize(uint256 maxWalletSize) public onlyOwner {
        _maxWalletSize = maxWalletSize;
    }

}