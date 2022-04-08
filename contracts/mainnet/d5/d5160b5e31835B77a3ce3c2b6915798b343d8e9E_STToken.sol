/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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
    address private _owner;

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
        require(_owner == msg.sender, "not owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "0 owner");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private fundAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private startTradeBlock;
    mapping(address => bool) private _feeWhiteList;
    mapping(address => bool) private _blackList;

    mapping(address => address) private _invitor;

    mapping(address => bool) private _swapPairList;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    bool private inSwap;
    uint256 private numTokensSellToFund;

    uint256 private constant MAX = ~uint256(0);
    address private fist;
    TokenDistributor _tokenDistributor;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address FundAddress, uint256 MaxNumTokensSellToFund, address ReceiveAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address usdt = address(0x55d398326f99059fF775485246999027B3197955);
        fist = address(0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A);

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), _swapRouter.WETH());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        address fistPair = swapFactory.createPair(address(this), fist);

        _swapPairList[mainPair] = true;
        _swapPairList[usdtPair] = true;
        _swapPairList[fistPair] = true;
        _allowances[address(this)][address(_swapRouter)] = MAX;

        IERC20(fist).approve(address(_swapRouter), MAX);

        _tTotal = Supply * 10 ** _decimals;
        _balances[ReceiveAddress] = _tTotal;
        emit Transfer(address(0), ReceiveAddress, _tTotal);

        fundAddress = FundAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        numTokensSellToFund = MaxNumTokensSellToFund * 10 ** _decimals;
        _tokenDistributor = new TokenDistributor(fist);
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

    function totalSupply() external view override returns (uint256) {
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
        require(owner != address(0), "from 0");
        require(spender != address(0), "to 0");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "from 0");
        require(to != address(0), "to 0");
        require(amount > 0, "0 amount");

        require(!_blackList[from], "blackList");

        uint256 txFee;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "not trading");
            }

            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                txFee = 12;

                if (block.number <= startTradeBlock + 3) {
                    if (!_swapPairList[to]) {
                        _blackList[to] = true;
                    }
                }

                uint256 contractTokenBalance = balanceOf(address(this));
                if (
                    contractTokenBalance >= numTokensSellToFund &&
                    !inSwap &&
                    _swapPairList[to]
                ) {
                    swapTokenForFund(numTokensSellToFund);
                }
            }
        } else {
            if (address(0) == _invitor[to] && !_feeWhiteList[to] && 0 == _balances[to]) {
                _invitor[to] = from;
            }
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                txFee = 3;
            }
        }
        _tokenTransfer(from, to, amount, txFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 fee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * fee / 100;
        uint256 taxAmount = feeAmount;
        if (fee > 3) {
            address current;
            if (_swapPairList[sender]) {
                current = recipient;
            } else {
                current = sender;
            }
            uint256 inviterAmount;
            for (uint256 i; i < 5; ++i) {
                address inviter = _invitor[current];
                if (address(0) == inviter) {
                    break;
                }
                if (0 == i) {
                    inviterAmount = tAmount / 25;
                } else {
                    inviterAmount = tAmount / 100;
                }
                feeAmount -= inviterAmount;
                _takeTransfer(sender, inviter, inviterAmount);
                current = inviter;
            }
            uint256 lpAmount = tAmount / 50;
            feeAmount -= lpAmount;
            _takeTransfer(sender, address(this), lpAmount);
        }
        if (feeAmount > 0) {
            _takeTransfer(
                sender,
                fundAddress,
                feeAmount
            );
        }
        _takeTransfer(sender, recipient, tAmount - taxAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 halfAmount = tokenAmount / 2;

        IERC20 Fist = IERC20(fist);
        uint256 initialBalance = Fist.balanceOf(address(_tokenDistributor));

        swapTokensForFist(tokenAmount - halfAmount);

        uint256 newBalance = Fist.balanceOf(address(_tokenDistributor)) - initialBalance;
        Fist.transferFrom(address(_tokenDistributor), address(this), newBalance);

        addLiquidityFist(halfAmount, newBalance);
    }

    function addLiquidityFist(uint256 tokenAmount, uint256 fistAmount) private {
        _swapRouter.addLiquidity(
            address(this),
            fist,
            tokenAmount,
            fistAmount,
            0,
            0,
            fundAddress,
            block.timestamp
        );
    }

    function swapTokensForFist(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = fist;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
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

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function setFundSellAmount(uint256 amount) external onlyOwner {
        numTokensSellToFund = amount;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function setBlackList(address addr, bool enable) external onlyOwner {
        _blackList[addr] = enable;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function isFeeWhiteList(address addr) external view returns (bool){
        return _feeWhiteList[addr];
    }

    function isBlackList(address addr) external view returns (bool){
        return _blackList[addr];
    }

    receive() external payable {}

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(fundAddress, amount);
    }

    function getInviter(address account) external view returns (address){
        return _invitor[account];
    }

    function getFundAddress() external view returns (address){
        return fundAddress;
    }

    function getNumTokensSellToFund() external view returns (uint256){
        return numTokensSellToFund;
    }

}

contract STToken is AbsToken {
    constructor() AbsToken(
        "five card stud",
        "ST",
        18,
        12888,
        address(0x3286c41c203F89EF007e29E77A4d3D0642431aC2),
        1,
        address(0x9ce015bDf8F9ce9F9B0aa0Fb01D19e89B0d673B3)
    ){

    }
}