/**
 *Submitted for verification at BscScan.com on 2022-02-05
*/

//SPDX-License-Identifier: MIT
//
// _____ ______   _______  _________  ________      ________      ________  ________  ________  ________  ________          
//|\   _ \  _   \|\  ___ \|\___   ___\\   __  \    |\   ____\    |\   ____\|\   __  \|\   __  \|\   ___ \|\   ____\         
//\ \  \\\__\ \  \ \   __/\|___ \  \_\ \  \|\  \   \ \  \___|    \ \  \___|\ \  \|\  \ \  \|\  \ \  \_|\ \ \  \___|_        
// \ \  \\|__| \  \ \  \_|/__  \ \  \ \ \   __  \   \ \  \  ___   \ \  \    \ \   __  \ \   _  _\ \  \ \\ \ \_____  \       
//  \ \  \    \ \  \ \  \_|\ \  \ \  \ \ \  \ \  \   \ \  \|\  \   \ \  \____\ \  \ \  \ \  \\  \\ \  \_\\ \|____|\  \      
//   \ \__\    \ \__\ \_______\  \ \__\ \ \__\ \__\   \ \_______\   \ \_______\ \__\ \__\ \__\\ _\\ \_______\____\_\  \     
//    \|__|     \|__|\|_______|   \|__|  \|__|\|__|    \|_______|    \|_______|\|__|\|__|\|__|\|__|\|_______|\_________\    
//                                                                                                          \|_________|    
// Always Keep the FOMO high - @FlyingCok                                                                          

pragma solidity ^0.8.10;

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
// contracts
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
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
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

contract MetaGCards is ERC20, Ownable {
    IUniswapV2Router02 public uniswapV2Router;
    
    address public uniswapV2Pair;
    address public marketingAddress = 0xa37Dd784778669Ec764B3A0FE89b232e718f0A96;
    address public DevelopmentAddress = 0x2CD7c1A66D5E948c01AF1CD4AeeDE93eb052933a;
    bool public limitMaxAmount = true;    //max wallet is 3%
    bool public limitMaxBuyAmount = true; //max buy is 1%
    bool public multiBuys = true;
    bool public antiSnipersActive = true;
    bool public sendToMarketingWallet = true;
    bool public sendToDevelopmentWallet = true;
    bool public tradeIsActive = false;    //Marketing Disabled at start
    bool private internalTransaction = false;
    bool public swapAndLiquifyEnabled = true;
    bool public feeStatus = true;
    bool public buyStatus = true;
    bool public feeStatusActive = true;
    bool public buyFeeStatusActive = true;
    bool public sellFeeStatusActive = true;
    uint public minimumWeiForTokenomics = 1 * 10**16; // 0.01 BNB
    uint public buyMarketingFees = 3;
    uint public buyDevelopmentFees = 5;
    uint public sellMarketingFees = 7;
    uint public sellDevelopmentFees = 5;
    uint public totalSell = buyMarketingFees + buyDevelopmentFees;
    uint public totalBuy = sellMarketingFees + sellDevelopmentFees;
    uint public maxBuy;
    uint public maxWallet; 
    uint public minimumTokensBeforeSwap = 2500000000000 * 10 ** decimals();
    uint public tokensToSwap = 2500000000000 * 10 ** decimals();
    uint public intervalSecondsForSwap = 60;
    uint private startTimeForSwap;
    uint private marketActiveAt;

    struct userLastBuy {uint lastBuyTime;}

    mapping (address => userLastBuy) public userLastTradeData;
    mapping (address => bool) public premarketUser;
    mapping (address => bool) public excludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => bool) public isInSniperList; //dev or owner can manually block sniper bots before public launch

    constructor() ERC20("Meta G Cards", "MTG") { 
        
        uint totalSupplyAmount = 1000000 * 10 ** 9 * 10 ** decimals();

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        maxWallet = (totalSupplyAmount / 100) * 3; // 3% supply
        maxBuy = totalSupplyAmount / 100;          // 1% supply
        excludedFromFees[address(this)] = true;
        isInSniperList[address(this)] = true;
        excludedFromFees[owner()] = true;
        excludedFromFees[DevelopmentAddress] = true;
        excludedFromFees[marketingAddress] = true;
        premarketUser[owner()] = true;
        automatedMarketMakerPairs[uniswapV2Pair] = true;
        _mint(msg.sender, totalSupplyAmount);
    }        
    // accept bnb for autoswap
    receive() external payable {}

    //base functions
    function updateUniswapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "The router already has that address");
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }
    function transferForeignToken(address _token, address _to, uint _value) external onlyOwner returns(bool _sent){
        if(_value == 0) {
            _value = IERC20(_token).balanceOf(address(this));
        } 
        _sent = IERC20(_token).transfer(_to, _value);
    }
    function sweep() external onlyOwner {
        uint balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    //Owner Bool Functions
    function enableTrades(bool _state) external onlyOwner {
        tradeIsActive = _state;
        if(_state) {
            marketActiveAt = block.timestamp;
        }
    }
    //the check is true by default, snipers will be automatically blocked after they buy
    function enableAntiSnipersList(bool _state) external onlyOwner {
        antiSnipersActive = _state;
    }
    function enableMultiBuys(bool _state) external onlyOwner {
        multiBuys = _state;
    }
    function enableMaxBuyAmount(bool _state) external onlyOwner {
        limitMaxBuyAmount = _state;
    }
    function enableMaxWallet(bool _state) external onlyOwner {
        limitMaxAmount = _state;
    }
    function setSendFeeActive(bool _marketingActive, bool _developmentActive) external onlyOwner {
        sendToMarketingWallet = _marketingActive;
        sendToDevelopmentWallet = _developmentActive;
    }
    
    //Owner Mappings Functions
    function editPremarketUser(address _target, bool _status) external onlyOwner {
        premarketUser[_target] = _status;
    }
    function editExcludedFromFees(address _target, bool _status) external onlyOwner {
        excludedFromFees[_target] = _status;
    }
    function editIncludeInSnipersList(address _target, bool _status) external onlyOwner {
        isInSniperList[_target] = _status;
    }
    function editAutomatedMarketMakerPairs(address _target, bool _status) external onlyOwner {
        automatedMarketMakerPairs[_target] = _status;
    }
    
    //Owner Fees management
    function setBuyTaxes(uint marketing, uint development) external onlyOwner {
        buyMarketingFees = marketing;
        buyDevelopmentFees = development;
        totalBuy = buyMarketingFees + buyDevelopmentFees;
    }
    function setFeesStatus(bool buy, bool sell, bool _state) external onlyOwner {
        feeStatus = _state;
        buyFeeStatusActive = buy;
        sellFeeStatusActive = sell;
    }
    function setSellTaxes(uint marketing, uint development) external onlyOwner {
        sellMarketingFees = marketing;
        sellDevelopmentFees = development;
        totalSell = sellMarketingFees + sellDevelopmentFees; 
    }    
    function setActiveAndTimeSwapLiquify(bool _state, uint _intervalSecondsForSwap) external onlyOwner {
        swapAndLiquifyEnabled = _state;
        intervalSecondsForSwap = _intervalSecondsForSwap;

    }
    function setAmountSwapAndLiquify(uint _minimumTokensBeforeSwap, uint _tokensToSwap) external onlyOwner {
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
        tokensToSwap = _tokensToSwap;
    }
    function setminimumWeiForTokenomics(uint _value) external onlyOwner {
        minimumWeiForTokenomics = _value;
    }
    // TRADES FUNCTIONS
    function swapTokensForEth(uint256 tokenAmount) private {
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
    function swapTokens(uint256 contractTokenBalance) private {
        internalTransaction = true;
        swapTokensForEth(contractTokenBalance);
        internalTransaction = false;
    }
    function _transfer(address from, address to, uint256 amount) internal override {
        uint transfer_type = 0;
        bool overMinimumTokenBalance = balanceOf(address(this)) >= minimumTokensBeforeSwap;
        if(!tradeIsActive) {
            require(premarketUser[from],"cannot trade before the market opening");
        }
        if(!internalTransaction) {
            //Buy
            if(automatedMarketMakerPairs[from]) {
                transfer_type = 1;
                 if(!excludedFromFees[to]) {
                    // maxWallet-maxBuyTx
                    if(limitMaxBuyAmount) {
                        require(amount <= maxBuy, "maxBuyTxAmount Limit Exceeded");
                    }
                    if(limitMaxAmount) {
                        require(balanceOf(to) + amount <= maxWallet, "maxWalletAmount Limit Exceeded");
                    }
                    // multibuysLimit
                    if(multiBuys) {
                        //prevent buys in the first block 
                        require(marketActiveAt + 3 < block.timestamp,"Launch delay protection revert.");
                        require(userLastTradeData[to].lastBuyTime + 3 <= block.timestamp,"Multi-buy orders disabled.");
                        userLastTradeData[to].lastBuyTime = block.timestamp;
                    }
                }
            }
            //Sell
            else if(automatedMarketMakerPairs[to]) {
                transfer_type = 2;
                // marketing auto-bnb
                if (swapAndLiquifyEnabled && balanceOf(uniswapV2Pair) > 0) {
                    if (overMinimumTokenBalance && startTimeForSwap + intervalSecondsForSwap <= block.timestamp) {
                        startTimeForSwap = block.timestamp;
                        // sell to bnb
                        swapTokens(tokensToSwap);
                    }
                }
                // limits
                if(!excludedFromFees[from]) {
                    //Snipers that buy before contract release will be included in SNIPER LIST :D
                    if(antiSnipersActive){
                        require(!isInSniperList[from], "Account is BlackListed");
                    }
                }
            }
            //Fees management
            if(address(this).balance > minimumWeiForTokenomics) {
                //Marketing FEES
                if(sendToMarketingWallet) {
                    uint256 marketingTokens = minimumWeiForTokenomics * sellMarketingFees / totalSell;
                    (bool success,) = address(marketingAddress).call{value: marketingTokens}("");
                }
                //Development FEES
                if(sendToDevelopmentWallet) {
                    uint256 DevelopmentTokens = minimumWeiForTokenomics * sellDevelopmentFees / totalSell;
                    (bool success,) = address(DevelopmentAddress).call{value: DevelopmentTokens}("");
                }
            }
            if(feeStatus) {
                // buy
                if(transfer_type == 1 && buyFeeStatusActive && !excludedFromFees[to]) {
                	uint txFees = amount * totalBuy / 100;
                	amount -= txFees;
                    super._transfer(from, address(this), txFees);
                }
                //sell
                if(transfer_type == 2 && sellFeeStatusActive && !excludedFromFees[from]) {
                	uint txFees = amount * totalSell / 100;
                	amount -= txFees;
                    super._transfer(from, address(this), txFees);
                }
            }
        }
        super._transfer(from, to, amount);
    }
}