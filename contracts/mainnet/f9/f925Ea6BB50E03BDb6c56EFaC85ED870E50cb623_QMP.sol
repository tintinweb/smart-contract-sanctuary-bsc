/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// SPDX-License-Identifier: MIT

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

contract TokenDistributor {
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!owner");
        IERC20(token).transfer(to, amount);
    }
}

interface IDividendPool {
    function addTokenReward(uint256 rewardAmount) external;
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyFee = 3;
    uint256[3][] private _sellFeeConfig;
    uint256 public _transferFee = 15;

    uint256 public startTradeBlock;
    address public _usdtPair;

    address public _daoAddress;

    mapping(address => uint256) public _lastTxTime;

    uint256 public numTokensSellToFund;

    TokenDistributor public _tokenDistributor;
    address public _dividendPoolAddress;
    uint256 public _dividendPoolRate;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _usdt = USDTAddress;
        _swapRouter = swapRouter;
        _allowances[address(this)][RouterAddress] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address usdtPair = swapFactory.createPair(address(this), USDTAddress);
        _usdtPair = usdtPair;
        _swapPairList[usdtPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[address(0)] = true;

        _sellFeeConfig.push([90 days, 0, 0]);
        _sellFeeConfig.push([30 days, 1, 2]);
        _sellFeeConfig.push([15 days, 3, 5]);
        _sellFeeConfig.push([0, 3, 12]);

        numTokensSellToFund = 100000 * 10 ** Decimals;
        _tokenDistributor = new TokenDistributor(USDTAddress);
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
        bool takeFee;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            takeFee = true;
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "!Trading");
                if (_usdtPair == to && IERC20(to).totalSupply() == 0) {
                    startTradeBlock = block.number;
                }
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount, 99);
                    return;
                }
            }
        } else {
            if (balanceOf(to) == 0 && amount > 0) {
                _lastTxTime[to] = block.timestamp;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 100;
        if (feeAmount > 0) {
            _takeTransfer(sender, address(this), feeAmount);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        if (!takeFee) {
            _funTransfer(sender, recipient, tAmount, 0);
            return;
        }
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount;
        if (_swapPairList[sender]) {//Buy
            feeAmount = tAmount * _buyFee / 100;
            if (feeAmount > 0) {
                _takeTransfer(sender, address(this), feeAmount);
            }
            _lastTxTime[recipient] = block.timestamp;
        } else if (_swapPairList[recipient]) {//Sell
            uint256[2] memory sellFeeConfig = getSellFeeConfig(sender);
            uint256 destroyAmount = tAmount * sellFeeConfig[0] / 100;
            if (destroyAmount > 0) {
                feeAmount += destroyAmount;
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyAmount);
            }

            uint256 sellDaoAmount = tAmount * sellFeeConfig[1] / 100;
            if (sellDaoAmount > 0) {
                feeAmount += sellDaoAmount;
                _takeTransfer(sender, address(this), sellDaoAmount);
            }

            _lastTxTime[sender] = block.timestamp;

            if (!inSwap) {
                swapTokenForFund();
            }
        } else {//Transfer
            feeAmount = tAmount * _transferFee / 100;
            if (feeAmount > 0) {
                _takeTransfer(sender, address(this), feeAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function getSellFeeConfig(address account) public view returns (uint256[2] memory sellFeeConfig){
        uint256 len = _sellFeeConfig.length;
        uint256[3] memory feeConfig;
        uint256 lastTxTime = _lastTxTime[account];
        uint256 blockTime = block.timestamp;
        uint256 lastTxDay = blockTime - lastTxTime;
        for (uint256 i; i < len;) {
            feeConfig = _sellFeeConfig[i];
            if (lastTxDay >= feeConfig[0]) {
                sellFeeConfig[0] = feeConfig[1];
                sellFeeConfig[1] = feeConfig[2];
                break;
            }
        unchecked{
            ++i;
        }
        }
    }

    function swapTokenForFund() private lockTheSwap {
        uint256 tokenAmount = numTokensSellToFund;
        if (balanceOf(address(this)) >= tokenAmount) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            address usdt = _usdt;
            path[1] = usdt;
            address tokenDistributor = address(_tokenDistributor);
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                tokenDistributor,
                block.timestamp
            );

            IERC20 USDT = IERC20(usdt);
            uint256 usdtBalance = USDT.balanceOf(tokenDistributor);

            uint256 dividendPoolAmount = usdtBalance * _dividendPoolRate / 100;
            if (dividendPoolAmount > 0) {
                address dividendPoolAddress = _dividendPoolAddress;
                if (dividendPoolAddress != address(0)) {
                    usdtBalance -= dividendPoolAmount;
                    USDT.transferFrom(tokenDistributor, dividendPoolAddress, dividendPoolAmount);
                    IDividendPool(dividendPoolAddress).addTokenReward(dividendPoolAmount);
                }
            }

            if (usdtBalance > 0) {
                address daoAddress = _daoAddress;
                if (address(0) != daoAddress) {
                    USDT.transferFrom(tokenDistributor, daoAddress, usdtBalance);
                }
            }
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setFundSellAmount(uint256 amount) external onlyOwner {
        numTokensSellToFund = amount * 10 ** _decimals;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setDaoAddress(address adr) external onlyOwner {
        _daoAddress = adr;
        _feeWhiteList[adr] = true;
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimToken(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    function claimContractToken(address token, address to, uint256 amount) external onlyOwner {
        _tokenDistributor.claimToken(token, to, amount);
    }

    function setBuyFee(uint256 fee) external onlyOwner {
        _buyFee = fee;
    }

    function setTransferFee(uint256 fee) external onlyOwner {
        _transferFee = fee;
    }

    function setSellFeeConfigs(uint256[3][] memory feeConfig) external onlyOwner {
        _sellFeeConfig = feeConfig;
    }

    function getSellFeeConfigs() external view returns (uint256[3][] memory feeConfigs) {
        feeConfigs = _sellFeeConfig;
    }

    function setSellFeeConfig(uint256 i, uint256 times, uint256 fee1, uint256 fee2) external onlyOwner {
        _sellFeeConfig[i][0] = times;
        _sellFeeConfig[i][1] = fee1;
        _sellFeeConfig[i][2] = fee2;
    }

    function setLastTxTime(address account, uint256 time) external onlyOwner {
        _lastTxTime[account] = time;
    }

    function setDividendPoolRate(uint256 rate) external onlyOwner {
        _dividendPoolRate = rate;
    }

    function setDividendPoolAddress(address dividendPoolAddress) external onlyOwner {
        _dividendPoolAddress = dividendPoolAddress;
    }

    receive() external payable {}
}

contract QMP is AbsToken {
    constructor() AbsToken(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
        "QMP",
        "QMP",
        18,
        10000000000,
    //Received
        address(0x6A89FCCAE4d627903108308B251e869812E8eF2E)
    ){

    }
}