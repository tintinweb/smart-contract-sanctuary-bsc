/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// File: SRDToken.sol

/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/


pragma solidity ^0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public dividendAddress;
    address public fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    mapping(address => bool) public _feeList;

    mapping(address => address) public recommenders;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyFundFee = 200;
    uint256 public _buyBurnFee = 100;
    uint256 public _buyDividendFee = 0;
    uint256 public _sellFundFee = 200;
    uint256 public _sellBurnFee = 100;
    uint256 public _sellDividendFee = 200;
    uint256 public _sellLPFee = 0;

    uint256 private totalBurn;

    uint256 private numTokensCanSwap = 10000 * 10**18;
    uint256 private numTokensToSwap = 5000 * 10**18;

    uint256 public startTradeBlock;

    address public USDT;

    address public _mainPair;

    address public _usdtPair;

    uint256 public mimTokenForReward;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address DividendAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _approve(address(this), address(swapRouter), MAX);

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), swapRouter.WETH());
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        USDT = address(0x55d398326f99059fF775485246999027B3197955);
        _usdtPair = address(0x20bCC3b8a0091dDac2d0BC30F68E6CBb97de59Cd);

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[address(0x7C696921BCE40Dad85025CAEA892dEA90f1353dd)] = total * (25) / (100);//presell
        _balances[address(0xD1eE7941aB323aCe6b79508E8B04C7E6dB6C28B5)] = total * (15) / (100);//LP
        _balances[address(0xFEb3A4CCF24C6e8208F1c44f89c2060394a132a4)] = total * (5) / (100);//exchange fee
        _balances[address(ReceiveAddress)] = total * (30) / (100);//mining
        _balances[address(deadWallet)] = total * (25) / (100);//burn
        emit Transfer(address(0), address(0x7C696921BCE40Dad85025CAEA892dEA90f1353dd), total * (25) / (100));
        emit Transfer(address(0), address(0xD1eE7941aB323aCe6b79508E8B04C7E6dB6C28B5), total * (15) / (100));
        emit Transfer(address(0), address(0xFEb3A4CCF24C6e8208F1c44f89c2060394a132a4),  total * (5) / (100));
        emit Transfer(address(0), address(ReceiveAddress), total * (30) / (100));
        emit Transfer(address(0), address(deadWallet), total * (25) / (100));

        dividendAddress = DividendAddress;
        fundAddress = FundAddress;
        
        _feeList[address(0x7C696921BCE40Dad85025CAEA892dEA90f1353dd)] = true;
        _feeList[address(0xD1eE7941aB323aCe6b79508E8B04C7E6dB6C28B5)] = true;
        _feeList[address(0xFEb3A4CCF24C6e8208F1c44f89c2060394a132a4)] = true;
        _feeList[dividendAddress] = true;
        _feeList[FundAddress] = true;
        _feeList[ReceiveAddress] = true;
        _feeList[address(this)] = true;
        _feeList[address(swapRouter)] = true;
        _feeList[msg.sender] = true;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
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

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");

        if (!_feeList[from] && !_feeList[to]) {
            uint256 maxSellAmount = balance * 9999 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeList[from] && !_feeList[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && _swapPairList[to], "!startAddLP");
                }
                if (block.number < startTradeBlock + 2) {
                    _funTransfer(from, to, amount);
                    return;
                }

                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance >= numTokensCanSwap) {
                            swapTokenForFund(numTokensToSwap);
                        }
                    }
                }
                takeFee = true;
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 75 / 100;
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            
            if (isSell) {
                uint256 sellFundFee = tAmount * _sellFundFee / 10000;
                uint256 sellBurnFee = tAmount * _sellBurnFee / 10000;
                uint256 sellDividendFee = tAmount * _sellDividendFee / 10000;
                if (sellFundFee > 0) {
                    feeAmount += sellFundFee;
                    _takeTransfer(sender, address(this), sellFundFee);
                }
                if (sellBurnFee > 0) {
                    feeAmount += sellBurnFee;
                    _takeTransfer(sender, address(deadWallet), sellBurnFee);
                }
                if (sellDividendFee > 0) {
                    feeAmount += sellDividendFee;
                    _takeTransfer(sender, address(dividendAddress), sellDividendFee);
                }
            } else {
                uint256 buyFundFee = tAmount * _buyFundFee / 10000;
                uint256 buyBurnFee = tAmount * _buyBurnFee / 10000;
                uint256 buyDividendFee = tAmount * _buyDividendFee / 10000;
                
                if (buyFundFee > 0) {
                    feeAmount += buyFundFee;
                    _takeTransfer(sender, address(this), buyFundFee);
                }
                if (buyBurnFee > 0) {
                    feeAmount += buyBurnFee;
                    _takeTransfer(sender, address(deadWallet), buyBurnFee);
                }
                if (buyDividendFee > 0) {
                    feeAmount += buyDividendFee;
                    _takeTransfer(sender, address(dividendAddress), buyDividendFee);
                }
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _swapRouter.WETH();

        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(fundAddress),
            block.timestamp
        );
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        if(to == address(0) || to == deadWallet){
            totalBurn += tAmount;
        }
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeList[addr] = true;
    }

    function setBuyFundFee(uint256 fundFee) external onlyOwner {
        _buyFundFee = fundFee;
    }

    function setBuyBurnFee(uint256 burnFee) external onlyOwner {
        _buyBurnFee = burnFee;
    }

    function setBuyDividendFee(uint256 dividendFee) external onlyOwner {
        _buyDividendFee = dividendFee;
    }

    function setSellFundFee(uint256 fundFee) external onlyOwner {
        _sellFundFee = fundFee;
    }

    function setSellBurnFee(uint256 burnFee) external onlyOwner {
        _sellBurnFee = burnFee;
    }

    function setSellDividendFee(uint256 dividendFee) external onlyOwner {
        _sellDividendFee = dividendFee;
    }

    function setSellLPFee(uint256 lpFee) external onlyOwner {
        _sellLPFee = lpFee;
    }

    function setNumTokensCanSwap(uint256 amount) external onlyOwner {
        numTokensCanSwap = amount;
    }

    function setNumTokensToSwap(uint256 amount) external onlyOwner {
        numTokensToSwap = amount;
    }

    uint256 public startAddLPBlock;

    function startAddLP() external onlyOwner {
        require(0 == startAddLPBlock, "startedAddLP");
        startAddLPBlock = block.number;
    }

    function closeAddLP() external onlyOwner {
        startAddLPBlock = 0;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }

    function setMimTokenForReward(uint256 _mimTokenForReward) external onlyOwner {
        mimTokenForReward = _mimTokenForReward;
    }

    function setFeeList(address addr, bool enable) external onlyFunder {
        _feeList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
    }

    function set_usdtPair(address _pair) public onlyOwner {
        _usdtPair = address(_pair);
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyFunder {
        IERC20(token).transfer(to, amount);
    }

    function tokenData() public view returns (uint256 supply, uint256 circulation, uint256 burn, uint256 marketValue) {
        supply = _tTotal / (10 ** 14);
        circulation = (_tTotal - totalBurn) / (10 ** 14);
        burn = totalBurn / (10 ** 14);
        marketValue = bnbEqualsToUsdt(tokenEqualsToBnb(circulation));
    }

    function tokenEqualsToBnb(uint256 tokenAmount) public view returns(uint256 bnbAmount) {
        
        uint256 tokenOfPair = balanceOf(_mainPair);

        uint256 bnbOfPair = IERC20(_swapRouter.WETH()).balanceOf(_mainPair);

        if(tokenOfPair > 0 && bnbOfPair > 0){
            bnbAmount = tokenAmount * bnbOfPair / tokenOfPair;
        }

        return bnbAmount;
    }

    function bnbEqualsToUsdt(uint256 bnbAmount) public view returns(uint256 usdtAmount) {
        
        uint256 tokenOfPair = IERC20(USDT).balanceOf(_usdtPair);

        uint256 bnbOfPair = IERC20(_swapRouter.WETH()).balanceOf(_usdtPair);

        if(tokenOfPair > 0 && bnbOfPair > 0){
            usdtAmount = bnbAmount * tokenOfPair / bnbOfPair;
        }

        return usdtAmount;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    receive() external payable {}
}

contract SRDToken is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),//RouterAddress
        address(0x9B649A331a97f14f6DA20A383b731504Aa40CFD8),//DividendAddress;
        "SpaceRobotDao",//Name
        "SRD",//Symbol
        18,//Decimals
        60000000,//Supply
        address(0x6D1D73040EFD0d9E8f07A1c8d8D0b887218D65Ee),//FundAddress
        address(0x27f7109935953B71dD98368201cAC26fcF8B59a1)//ReceiveAddress
    ){

    }
}