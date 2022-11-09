// SPDX-License-Identifier: Unlicensed

//TG: soon
pragma solidity 0.8.16;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Context.sol";
import "./Address.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router01.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Router01.sol";

contract DeerRun is Context, IERC20 {
    
    using SafeMath for uint256;
    using Address for address;

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner(){
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee;
    mapping (address => bool) public _isExcludedFromMaxTx;
    mapping (address => bool) public _isExcludedFromMaxWallet;


    address[] public monitored;



    address payable public Wallet_Marketing;
    address payable public Wallet_Dev;
    address payable public constant Wallet_Airdrop = payable(0x4D0197738056452467401B11a8479Ba3a417a9F6);


    uint256 private constant MAX = ~uint256(0);
    uint8 private constant _decimals = 9;
    uint256 private _tTotal = 10**6 * 10**_decimals;
    string private _name = "DeerRun";
    string private _symbol = "DER";

    uint8 private txCount = 0;
    uint8 private swapTrigger = 10;

    uint256 public _Tax_On_Buy = 3;
    uint256 public _Tax_On_Sell = 5;

    uint256 public Percent_Marketing = 20;

    uint256 public Percent_Dev  = 20;

    uint256 public Percent_Airdrop = 40;

    uint256 public Percent_AutoLP  = 20;


    uint256 public _maxWalletToken = _tTotal * 2 / 100;

    uint256 public _maxTxAmount = _tTotal * 2 / 100;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    event SwapAndLiquifyEnabledUpdated(bool true_or_false);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity

    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    //decimals = 9, _tTotal = 10**6 * 10**_decimals
    constructor ()  {

        _owner = msg.sender;

        Wallet_Dev = payable(msg.sender);
        emit OwnershipTransferred(address(0), msg.sender);

        _tOwned[owner()] = _tTotal;

        Wallet_Marketing = payable(0x9De707f4f074C886258F9A33334510cAf9cf1707);

       // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // Testnet

        _allowances[owner()][address(_uniswapV2Router)] = MAX;

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromMaxTx[owner()] = true;
        _isExcludedFromMaxWallet[owner()] = true;

        _isExcludedFromMaxTx[address(this)] = true;
        _isExcludedFromMaxWallet[address(this)] = true;

        _isExcludedFromMaxTx[Wallet_Marketing] = true;
        _isExcludedFromMaxWallet[Wallet_Marketing] = true;

        _isExcludedFromMaxTx[Wallet_Airdrop] = true;
        _isExcludedFromMaxWallet[Wallet_Airdrop] = true;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[Wallet_Marketing] = true;

         emit Transfer(address(0), owner(), _tTotal);

    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address theOwner, address theSpender) public view override returns (uint256) {
        return _allowances[theOwner][theSpender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    receive() external payable {}

    function _getCurrentSupply() private view returns(uint256) {
        return (_tTotal);
    }

    



    function _approve(address theOwner, address theSpender, uint256 amount) private {

        require(theOwner != address(0) && theSpender != address(0), "ERR: zero address");
        _allowances[theOwner][theSpender] = amount;
        emit Approval(theOwner, theSpender, amount);

    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        if (to != owner() &&
        !_isExcludedFromMaxWallet[to]&&
        to != Wallet_Airdrop &&
        to != address(this) &&
        to != uniswapV2Pair &&
            from != owner()){
            monitored.push(to);
            
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _maxWalletToken,"Over wallet limit.");}

        if (!_isExcludedFromMaxTx[to] && !_isExcludedFromMaxTx[from])
            require(amount <= _maxTxAmount, "Over transaction limit.");

        require(from != address(0) && to != address(0), "ERR: Using 0 address!");
        
        require(amount > 0, "Token value must be higher than zero.");

        if(
            txCount >= swapTrigger &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        )
        {
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > _maxTxAmount) {contractTokenBalance = _maxTxAmount;}
            txCount = 0;
            swapAndLiquify(contractTokenBalance);
        }

        bool takeFee = true;
        bool isBuy;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        } else {

            if(from == uniswapV2Pair){
                isBuy = true;
            }

            txCount++;
        }

        _tokenTransfer(from, to, amount, takeFee, isBuy);

    }

    function sendToWallet(address payable wallet, uint256 amount) private {
        wallet.transfer(amount);
    }

    function _changeTax(uint256  buyTax,  uint256 sellTax,
            uint256 percentToMarketing, 
            uint256 percentToDev, 
            uint256 percentToLp,
            uint256 percentToAirdrop) public onlyOwner {

        _Tax_On_Buy = buyTax;
        _Tax_On_Sell = sellTax;

        Percent_Marketing = percentToMarketing;
        Percent_Dev = percentToDev;
        Percent_Airdrop = percentToAirdrop;
        Percent_AutoLP = percentToLp;
    }


    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

        uint256 tokens_for_Airdrop = contractTokenBalance * Percent_Airdrop / 100;
        uint256 tokens_to_M = contractTokenBalance * Percent_Marketing / 100;
        uint256 tokens_to_D = contractTokenBalance * Percent_Dev / 100;
        uint256 tokens_to_LP_Half = contractTokenBalance * Percent_AutoLP / 200;

        uint256 tokens_Tax =  tokens_for_Airdrop + tokens_to_M + tokens_to_D + tokens_to_LP_Half;

        uint256 balanceBeforeSwap = address(this).balance;
        swapTokensForBNB(tokens_Tax);
        uint256 BNB_Total = address(this).balance - balanceBeforeSwap;

        uint256 BNB_M = BNB_Total * Percent_Marketing / 100;

        uint256 BNB_D = BNB_Total * Percent_Dev / 100;

        uint256 BNB_Airdrop = BNB_Total * Percent_Airdrop / 100;



        addLiquidity(tokens_to_LP_Half, (BNB_Total - BNB_M - BNB_D - BNB_Airdrop));
        emit SwapAndLiquify(tokens_to_LP_Half, (BNB_Total - BNB_M - BNB_D - BNB_Airdrop), tokens_to_LP_Half);

        sendToWallet(Wallet_Marketing, BNB_M);
        sendToWallet(Wallet_Airdrop, BNB_Airdrop);

        BNB_Total = address(this).balance;
        sendToWallet(Wallet_Dev, BNB_Total);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }


    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            0x0000000000000000000000000000000000000000,
            block.timestamp
        );
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isBuy) private {


        if(!takeFee){

            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tAmount;
            emit Transfer(sender, recipient, tAmount);


        } else if (isBuy){

            uint256 buyFEE = tAmount*_Tax_On_Buy/100;
            uint256 tTransferAmount = tAmount-buyFEE;

            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tTransferAmount;
            _tOwned[address(this)] = _tOwned[address(this)]+buyFEE;
            emit Transfer(sender, recipient, tTransferAmount);

        } else {

            uint256 sellFEE = tAmount*_Tax_On_Sell/100;
            uint256 tTransferAmount = tAmount-sellFEE;

            _tOwned[sender] = _tOwned[sender]-tAmount;
            _tOwned[recipient] = _tOwned[recipient]+tTransferAmount;
            _tOwned[address(this)] = _tOwned[address(this)]+sellFEE;
            emit Transfer(sender, recipient, tTransferAmount);
        }
    }
}