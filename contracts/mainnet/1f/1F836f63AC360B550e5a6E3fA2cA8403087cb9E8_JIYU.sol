/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

interface ISwapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

contract JIYU is IERC20, Ownable {
    string private _name = "JIYU";
    string private _symbol = "JIYU";
    uint8 private _decimals = 18;
    uint256 private _tTotal = 10000000 * 10 ** _decimals;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private RouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private USDTAddr = 0x55d398326f99059fF775485246999027B3197955;

    // DAPP挖矿
    address private dapp = 0x18fEfCA174e20024858DDF043D6276EF1546Fd5E;
    // 私募地址
    address private simu = 0x2Ce4751CF64118d48d3f2D1EDb2E36Ead31cAfE8;
    // 加池子地址
    address private chizi;

    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _botWhiteList;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);

    uint256 public _buyFundFee = 0;
    uint256 public _sellFundFee = 30;

    uint256 public startTradeBlock = 0;

    address public _mainPair;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() {
        ISwapRouter swapRouter = ISwapRouter(RouterAddr);
        IERC20(USDTAddr).approve(address(swapRouter), MAX);

        _usdt = USDTAddr;
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddr);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;
        chizi = msg.sender;

        _balances[dapp] = (_tTotal * 88) / 100;
        _balances[simu] = (_tTotal * 2) / 100;
        _balances[chizi] = (_tTotal * 10) / 100;

        emit Transfer(address(0), dapp, (_tTotal * 88) / 100);
        emit Transfer(address(0), simu, (_tTotal * 2) / 100);
        emit Transfer(address(0), chizi, (_tTotal * 10) / 100);

        _feeWhiteList[dapp] = true;
        _feeWhiteList[simu] = true;
        _feeWhiteList[chizi] = true;
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

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        require(!_botWhiteList[from] && !_botWhiteList[to], "bot address");

        bool takeFee;
        bool isSell;

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            if (_swapPairList[from] || _swapPairList[to]) {
                takeFee = true;
                require(startTradeBlock > 0, "not open trade");
                if (
                    _swapPairList[from] &&
                    startTradeBlock + 28800 >= block.number
                ) {
                    require(amount <= 1000 * 10 ** _decimals);
                }

                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance > 0) {
                            uint256 swapFee = _buyFundFee + _sellFundFee;
                            uint256 numTokensSellToFund = (amount * swapFee) /
                                30;
                            if (numTokensSellToFund > contractTokenBalance) {
                                numTokensSellToFund = contractTokenBalance;
                            }
                            swapTokenForFund(numTokensSellToFund);
                        }
                    }
                    isSell = true;
                }
            }
        }

        _tokenTransfer(from, to, amount, takeFee, isSell);
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
            uint256 swapFee = isSell ? _sellFundFee : _buyFundFee;
            uint256 swapAmount = (tAmount * swapFee) / 100;
            feeAmount += swapAmount;
            if (feeAmount > 0) {
                _takeTransfer(sender, address(this), swapAmount);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            owner(),
            block.timestamp
        );
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFees(uint256 buyFee, uint256 sellFee) external onlyOwner {
        _buyFundFee = buyFee;
        _sellFundFee = sellFee;
    }

    function startTrade() external onlyOwner {
        startTradeBlock = block.number;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }

    function setFeeWhiteList(
        address[] calldata addList,
        bool enable
    ) external onlyOwner {
        for (uint256 i = 0; i < addList.length; i++) {
            _feeWhiteList[addList[i]] = enable;
        }
    }

    function setBotWhiteList(
        address[] calldata addList,
        bool enable
    ) public onlyOwner {
        for (uint256 i = 0; i < addList.length; i++) {
            _botWhiteList[addList[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function claimBalance() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function claimToken(
        address token,
        uint256 amount,
        address to
    ) public onlyOwner {
        IERC20(token).transfer(to, amount);
    }

    receive() external payable {}
}