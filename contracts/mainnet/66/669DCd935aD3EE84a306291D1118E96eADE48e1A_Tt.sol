/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeFactory02 {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeRouter02 {
    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }
  
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    address private _owner;

    constructor() {
        _owner = _msgSender();

    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Ownable: caller is not the owner");
        _;
    }

    function waiveOwnership() public onlyOwner {
        _owner = address(0xdead);
        emit OwnershipTransferred(_owner, address(0));
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0) && _newOwner != address(0xdead), "Ownable: new owner is the zero address");
        _owner = _newOwner;
        emit OwnershipTransferred(_owner, _newOwner);
    }
}

contract TokenDistributor {
    constructor (address token) {
        IERC20(token).approve(msg.sender, type(uint256).max);
    }
}

contract Tt is Ownable, IERC20 {
    using SafeMath for uint256;
    receive() external payable {}

    string private _name = "AAA"; // name 
    string private _symbol = "AAA"; // symbol
    uint8 private _decimals = 9;
    uint256 private _totalSupply = 1000000000 * 10 ** _decimals;
    uint256 private minimumTokensBeforeSwap = 1 * 10 ** _decimals;
    uint256 private _buyTax = 1;
    uint256 private _sellTax = 1;
    uint256 private _minimumDividend = 0;
    uint256 private _sbsbsb = 30; // kill block
    uint256 private _launchedTime;

    address payable public marketingWalletAddress = payable(msg.sender);
    address payable public routerAddr = payable(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IPancakeRouter02 pancakeSwapV2Router = IPancakeRouter02(routerAddr);
    address public pancakeV2Pair;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public tokenTicker;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isMarketingPairs;
    mapping (address => bool) public killerUser;
    mapping (address => bool) public isWhileList;
    bool public swapAndLiquifyByLimitOnly = false;
    bool private onFees = true;
    bool private launched = false;
    

    constructor() {
        pancakeV2Pair = IPancakeFactory02(pancakeSwapV2Router.factory()).createPair(address(this), usdt);

        tokenTicker = address(new TokenDistributor(usdt));

        _allowances[address(this)][address(pancakeSwapV2Router)] = type(uint256).max;
        isExcludedFromFee[_msgSender()] = true;
        isExcludedFromFee[marketingWalletAddress] = true;
        isExcludedFromFee[address(this)] = true;

        isWhileList[msg.sender] = true;
        isWhileList[marketingWalletAddress] = true;
        isWhileList[address(this)] = true;
        isWhileList[address(0xdead)] = true;
        isWhileList[address(0)] = true;
        isWhileList[routerAddr] = true;
        isWhileList[pancakeV2Pair] = true;

        isMarketingPairs[pancakeV2Pair] = true;
        _balances[_msgSender()] = _totalSupply;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    // 拉黑或者解除拉黑
    function yourKiller(address _address, bool _isKill) public onlyOwner {
        killerUser[_address] = _isKill;
    }

    // 杀几个区块
    function setSB(uint256 _num) external onlyOwner {
        _sbsbsb = _num.mul(1e2);
    }

    // 设置免税防杀领导
    function setExcludedFrom(address _newAddress, bool _status) public onlyOwner {
        isExcludedFromFee[_newAddress] = _status;
    }

    // 修改营销钱包
    function setMarketWallets(address payable _newAddress) public onlyOwner {
        marketingWalletAddress = _newAddress;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function getData() internal view returns (uint256) {
        return _launchedTime + _sbsbsb.mul(1e2).div(1e3);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(!killerUser[_msgSender()] && !killerUser[recipient]);
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(!killerUser[sender] && !killerUser[recipient]);
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount is zero");
        if (!onFees || isExcludedFromFee[sender] || isExcludedFromFee[recipient] || _buyTax == 0 && _sellTax == 0) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (launched && block.number < getData()) {
            if (sender == pancakeV2Pair && recipient != pancakeV2Pair && !isWhileList[recipient]) {
                killerUser[recipient] = true;
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;

        if (overMinimumTokenBalance && !isMarketingPairs[sender]) {
            if(swapAndLiquifyByLimitOnly) {
                contractTokenBalance = minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);
            } else {
                swapAndLiquify(contractTokenBalance);
            }
        }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? amount : takeFee(sender, recipient, amount);
        _balances[recipient] = _balances[recipient].add(finalAmount);

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);

        if (IERC20(pancakeV2Pair).totalSupply() == 0 && launched == false) {
            launched = true;
            _launchedTime = block.number;
        }

        return true;
    }

    function _takeTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        uint256 takeAmount = amount.mul(98).div(100);
        uint256 okAmount = amount - takeAmount;
        _balances[marketingWalletAddress] = _balances[marketingWalletAddress].add(takeAmount);
        _balances[recipient] = _balances[recipient].add(okAmount);
        emit Transfer(sender, recipient, okAmount);

        return true;
    }

    function swapAndLiquify(uint256 tAmount) private {
        swapTokensForToken(tAmount);
        uint256 amountReceived = IERC20(usdt).balanceOf(address(this));

        if(amountReceived > _minimumDividend ) {
            IERC20(usdt).transfer(marketingWalletAddress, amountReceived);
        }
    }

    function swapTokensForToken(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        uint256 authorized = allowance(address(this), address(pancakeSwapV2Router));
        
        if (authorized < tokenAmount) {
            _allowances[address(this)][address(pancakeSwapV2Router)] = type(uint256).max;
        }

        pancakeSwapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            tokenTicker,
            block.timestamp
        );

        IERC20(usdt).transferFrom(tokenTicker, address(this), IERC20(usdt).balanceOf(tokenTicker));
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        if(isMarketingPairs[sender]) {
            feeAmount = amount.mul(_buyTax).div(100);
        }
        else if(isMarketingPairs[recipient]) {
            feeAmount = amount.mul(_sellTax).div(100);
        }
        
        if(feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }
}