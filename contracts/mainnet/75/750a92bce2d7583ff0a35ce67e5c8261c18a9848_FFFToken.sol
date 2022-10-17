/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

// File: FFFToken.sol



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
    address public leagueAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    mapping(address => bool) public _feeWhiteList;

    mapping(address => address) public recommenders;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    IForceController public _forceController;
    mapping(address => bool) public _swapPairList;


    uint256 private constant MAX = ~uint256(0);

    // uint256 public _buyFundFee = 100;
    // uint256 public _buyNodeFee = 300;
    // uint256 public _buyBurnFee = 600;
    // uint256 public _buyDividendFee = 1000;
    // uint256 public _sellFundFee = 100;
    // uint256 public _sellNodeFee = 300;
    // uint256 public _sellBurnFee = 600;
    // uint256 public _sellDividendFee = 1000;
    // uint256 public _sellFundFee = 200;
    // uint256 public _sellNodeFee = 600;
    // uint256 public _sellBurnFee = 1200;
    // uint256 public _sellDividendFee = 2000;
    // uint256 public _sellLPFee = 0;
    uint256 public _swapFundFee = 100;
    uint256 public _swapNodeFee = 300;
    uint256 public _swapBurnFee = 600;
    uint256 public _swapDividendFee = 1000;

    uint256 public totalSwap;
    uint256 public dividendSwap;

    uint256 private totalBurn;

    uint256 private numTokensCanSwap = 10000 * 10**18;
    uint256 private numTokensToSwap = 5000 * 10**18;
    uint256 private swapCoolDownTime = 60;
    mapping(address => uint256) private lastSwapTime;

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
        // USDT = address(0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47);
        // _usdtPair = address(0x26e364CBF4b51927baA0318bA5fc26F26A1b1658);

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _approve(address(this), address(swapRouter), MAX);

        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDT);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), address(ReceiveAddress), total);
        // _balances[address(0xf2E796B0Fe9634c060FC27B3D06130A9D2a51B75)] = total * (25) / (100);//presell
        // _balances[address(0xf2E796B0Fe9634c060FC27B3D06130A9D2a51B75)] = total * (15) / (100);//LP
        // _balances[address(0xf2E796B0Fe9634c060FC27B3D06130A9D2a51B75)] = total * (5) / (100);//exchange fee
        // _balances[address(0xf2E796B0Fe9634c060FC27B3D06130A9D2a51B75)] = total * (30) / (100);//mining
        // _balances[address(0xf2E796B0Fe9634c060FC27B3D06130A9D2a51B75)] = total * (25) / (100);//burn
        // _balances[address(0xf2E796B0Fe9634c060FC27B3D06130A9D2a51B75)] = total / (100);//burn
        // emit Transfer(address(0), address(0xf2E796B0Fe9634c060FC27B3D06130A9D2a51B75), total);
        // emit Transfer(address(0), address(0xf2E796B0Fe9634c060FC27B3D06130A9D2a51B75), total);
        // emit Transfer(address(0), address(0xf2E796B0Fe9634c060FC27B3D06130A9D2a51B75), total);
        // emit Transfer(address(0), address(0xf2E796B0Fe9634c060FC27B3D06130A9D2a51B75), total);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
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

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 9999 / 10000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        // bool isSell;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (_swapPairList[to]) {
                require(block.timestamp >= lastSwapTime[from] + swapCoolDownTime, "The cool down time is not over");
                lastSwapTime[from] = block.timestamp;
                // isSell = true;
            }else{
                require(block.timestamp >= lastSwapTime[to] + swapCoolDownTime, "The cool down time is not over");
                lastSwapTime[to] = block.timestamp;
            }
            
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
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
        }

        // _tokenTransfer(from, to, amount, takeFee, isSell);
        _tokenTransfer(from, to, amount, takeFee);
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

    bool flag;

    function setFlag(bool _flag) public onlyOwner {
        flag = _flag;
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
        // bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        _takeTransfer(sender, recipient, tAmount);
        uint256 feeAmount;

        if (takeFee) {
            totalSwap += tAmount;
        }else if (!_swapPairList[sender] && !_swapPairList[recipient]) {
            uint256 sAmount = totalSwap - dividendSwap;

            uint256 fundFee = sAmount * _swapFundFee / 10000;
            uint256 nodeFee = sAmount * _swapNodeFee / 10000;
            uint256 burnFee = sAmount * _swapBurnFee / 10000;
            uint256 dividendFee = sAmount * _swapDividendFee / 10000;

            if (fundFee > 0) {
                feeAmount += fundFee;
                _takeTransfer(_mainPair, address(this), fundFee);
            }
            if (nodeFee > 0) {
                feeAmount += nodeFee;
                _takeTransfer(_mainPair, address(dividendAddress), nodeFee);
            }
            if (burnFee > 0) {
                feeAmount += burnFee;
                _takeTransfer(_mainPair, address(deadWallet), burnFee);
            }
            if (dividendFee > 0) {
                feeAmount += dividendFee;
                _takeTransfer(_mainPair, address(dividendAddress), dividendFee);
            }
            if(flag && nodeFee + dividendFee > 0){
                _forceController.addNodeDividend(nodeFee + dividendFee);
            }

            dividendSwap += sAmount;
            _balances[_mainPair] = _balances[_mainPair] - feeAmount;
        }

        // if (takeFee) {
            
        //     if (isSell) {
        //         uint256 sellFundFee = tAmount * _sellFundFee / 10000;
        //         uint256 sellNodeFee = tAmount * _sellNodeFee / 10000;
        //         uint256 sellBurnFee = tAmount * _sellBurnFee / 10000;
        //         uint256 sellDividendFee = tAmount * _sellDividendFee / 10000;

        //         if (sellFundFee > 0) {
        //             feeAmount += sellFundFee;
        //             _takeTransfer(_mainPair, address(this), sellFundFee);
        //         }
        //         if (sellNodeFee > 0) {
        //             feeAmount += sellNodeFee;
        //             _takeTransfer(_mainPair, address(dividendAddress), sellNodeFee);
        //         }
        //         if (sellBurnFee > 0) {
        //             feeAmount += sellBurnFee;
        //             _takeTransfer(_mainPair, address(deadWallet), sellBurnFee);
        //         }
        //         if (sellDividendFee > 0) {
        //             feeAmount += sellDividendFee;
        //             _takeTransfer(_mainPair, address(dividendAddress), sellDividendFee);
        //         }
        //         if(flag && sellNodeFee + sellDividendFee > 0){
        //             _forceController.addNodeDividend(sellNodeFee + sellDividendFee);
        //         }
        //     } else {
        //         uint256 buyFundFee = tAmount * _buyFundFee / 10000;
        //         uint256 buyNodeFee = tAmount * _buyNodeFee / 10000;
        //         uint256 buyBurnFee = tAmount * _buyBurnFee / 10000;
        //         uint256 buyDividendFee = tAmount * _buyDividendFee / 10000;
                
        //         if (buyFundFee > 0) {
        //             feeAmount += buyFundFee;
        //             _takeTransfer(_mainPair, address(this), buyFundFee);
        //         }
        //         if (buyNodeFee > 0) {
        //             feeAmount += buyNodeFee;
        //             _takeTransfer(_mainPair, address(dividendAddress), buyNodeFee);
        //         }
        //         if (buyBurnFee > 0) {
        //             feeAmount += buyBurnFee;
        //             _takeTransfer(_mainPair, address(deadWallet), buyBurnFee);
        //         }
        //         if (buyDividendFee > 0) {
        //             feeAmount += buyDividendFee;
        //             _takeTransfer(_mainPair, address(dividendAddress), buyDividendFee);
        //         }
        //         if(flag && buyNodeFee + buyDividendFee > 0){
        //             _forceController.addNodeDividend(buyNodeFee + buyDividendFee);
        //         }
        //     }
        // }
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

    function test2() external onlyOwner {
        uint256 a = _forceController.addNodeDividend(4000);
        emit Test(a);
    }

    function setForceController(address addr) external onlyOwner {
        _forceController = IForceController(addr);
        dividendAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setLeagueAddress(address addr) external onlyOwner {
        leagueAddress = addr;
        _feeWhiteList[addr] = true;
    }

    // function setBuyFundFee(uint256 fundFee) external onlyOwner {
    //     _buyFundFee = fundFee;
    // }

    // function setBuyLeagueFee(uint256 leagueFee) external onlyOwner {
    //     _buyLeagueFee = leagueFee;
    // }

    // function setBuyNodeFee(uint256 nodeFee) external onlyOwner {
    //     _buyNodeFee = nodeFee;
    // }

    // function setBuyBurnFee(uint256 burnFee) external onlyOwner {
    //     _buyBurnFee = burnFee;
    // }

    // function setBuyDividendFee(uint256 dividendFee) external onlyOwner {
    //     _buyDividendFee = dividendFee;
    // }

    // function setSellFundFee(uint256 fundFee) external onlyOwner {
    //     _sellFundFee = fundFee;
    // }

    // function setSellNodeFee(uint256 nodeFee) external onlyOwner {
    //     _sellNodeFee = nodeFee;
    // }

    // function setSellBurnFee(uint256 burnFee) external onlyOwner {
    //     _sellBurnFee = burnFee;
    // }

    // function setSellDividendFee(uint256 dividendFee) external onlyOwner {
    //     _sellDividendFee = dividendFee;
    // }

    // function setSellLPFee(uint256 lpFee) external onlyOwner {
    //     _sellLPFee = lpFee;
    // }

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

    function setCoolDownTime(uint256 coolDownTime) external onlyOwner {
        swapCoolDownTime = coolDownTime;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function setMainPair(address pair) external onlyFunder {
        _mainPair = pair;
        _swapPairList[pair] = true;
    }

    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
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

    // function bnbEqualsToUsdt(uint256 bnbAmount) public view returns(uint256 usdtAmount) {
        
    //     uint256 tokenOfPair = IERC20(USDT).balanceOf(_usdtPair);

    //     uint256 bnbOfPair = IERC20(_swapRouter.WETH()).balanceOf(_usdtPair);

    //     if(tokenOfPair > 0 && bnbOfPair > 0){
    //         usdtAmount = bnbAmount * tokenOfPair / bnbOfPair;
    //     }

    //     return usdtAmount;
    // }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    receive() external payable {}
}

contract FFFToken is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),//RouterAddress
        // address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3),//RouterAddress
        "FFFToken",//Name
        "FFF",//Symbol
        18,//Decimals
        5000000,//Supply
        address(0xEd703D611df2fef3D0c626B1f688edFeeA8CfcF7),//FundAddress
        address(0x81E4EeAE86da39803529A5bC306AA3cfAe989286)//ReceiveAddress
        // address(0xf34a7238cF9423A5FC6852c8882d774BF08446DE)//ReceiveAddress
    ){

    }
}