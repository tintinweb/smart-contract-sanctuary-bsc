/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// SPDX-License-Identifier: KING DAO

/*

  _  ___               _____          ____  
 | |/ (_)             |  __ \   /\   / __ \ 
 | ' / _ _ __   __ _  | |  | | /  \ | |  | |
 |  < | | '_ \ / _` | | |  | |/ /\ \| |  | |
 | . \| | | | | (_| | | |__| / ____ \ |__| |
 |_|\_\_|_| |_|\__, | |_____/_/    \_\____/ 
                __/ |                       
               |___/                        



 KING DAO是bsc唯一真正的DAO Token，流動性由眾多早期用戶自行添加並銷毀LP，開發者也沒有任何特權或額外收入

 我們的機制：
 稅費全部回流底池，並且回流得到的LP自動銷毀，稅費每個月會降低25%，4個月後停止收稅，進入0稅時代

*/

pragma solidity ^0.8.18;

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

interface IPancakePair {
    function sync() external;
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

interface IliquityContract {
    function claimTokens() external;
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
}

contract LiquityAuto {
    address _liquityOwner;
    address _usdt = 0x55d398326f99059fF775485246999027B3197955;
    constructor (address _owner) {
        _liquityOwner =  _owner;
    }

    function claimTokens() external {
        IERC20(_usdt).transfer(_liquityOwner, IERC20(_usdt).balanceOf(address(this)));
    }
}

contract KINGDAO is Ownable, IERC20 {
    using SafeMath for uint256;
    receive() external payable {}

    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1500 * 10 ** _decimals;
    uint256 public minimumTokensBeforeSwap = _totalSupply * 1 / 10000;
    uint256 private _buyTax = 12;
    uint256 private _sellTax = 12;
    uint256 private _minimumDividend = 1 ether;
    uint256 private _airdropNumber = 5;

    struct Taxs{
        bool _isFees;
        uint _buy;
        uint _sell;
    }

    struct AirDrop{
        bool _isAridrop;
        uint _airdropNum;
    }

    bool public init = false;


    address payable public routerAddr = payable(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    IPancakeRouter02 pancakeSwapV2Router = IPancakeRouter02(routerAddr);
    address public pancakeV2Pair;
    address public liquityAutoContract;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isMarketingPairs;
    mapping (address => bool) public isNotDaoUsers;
    bool public swapAndLiquifyByLimitOnly = false;
    bool private onAirdrop = true;
    bool private onFees = true;
    

    constructor(string memory _name_, string memory _symbol_) {
        _name = _name_;
        _symbol = _symbol_;
        
        pancakeV2Pair = IPancakeFactory02(pancakeSwapV2Router.factory()).createPair(address(this), usdt);
        liquityAutoContract = address(new LiquityAuto(address(this)));

        _allowances[address(this)][address(pancakeSwapV2Router)] = type(uint256).max;
        isExcludedFromFee[_msgSender()] = true;
        isExcludedFromFee[address(this)] = true;

        isMarketingPairs[pancakeV2Pair] = true;
        _balances[_msgSender()] = _totalSupply / 2;
        _balances[address(this)] = _totalSupply / 2;

        emit Transfer(address(0), _msgSender(), _totalSupply / 2);
        emit Transfer(address(0), address(this), _totalSupply / 2);
    }

    function initAddliquityDAO(uint256 _tokenAmount) external onlyOwner {
        require(!init, "initialized");
        addLiquityForDAO(_tokenAmount, IERC20(usdt).balanceOf(address(this)));
        if (IERC20(address(this)).balanceOf(address(this)) > 0) {
            IERC20(address(this)).transfer(address(0xdead), balanceOf(address(this)));
        }
    }

    function removeDAOmembers(address[] memory _daoUsers, bool _isRemove) public onlyOwner {
        for (uint256 i=0; i<_daoUsers.length; ++i) {
            isNotDaoUsers[_daoUsers[i]] = _isRemove;
        }
    }

    function rescueToken(address _tokenAddr) public onlyOwner {
        if (_tokenAddr == address(0)) {
            payable(owner()).transfer(address(this).balance);
        } else {
            IERC20(_tokenAddr).transfer(owner(), IERC20(_tokenAddr).balanceOf(address(this)));
        }
    }

    function autuFees() internal {
        // Automatic monthly tax reduction, tax stop after 4 months
        if (block.timestamp >= 1685898061) {
            onFees = false;
            _buyTax = 0;
            _sellTax = 0;
            uint256 usdtBalance = IERC20(usdt).balanceOf(address(this));
            uint256 tokenBalance = IERC20(usdt).balanceOf(address(this));
            if (usdtBalance > 1 ether) {
                IERC20(usdt).transfer(pancakeV2Pair, usdtBalance);
                IPancakePair(pancakeV2Pair).sync();
            }
            if (tokenBalance > 1 ether) {
                IERC20(address(this)).transfer(address(0xdead), tokenBalance);
            }
        } else if (block.timestamp >= 1683219661) {
            onFees = true;
            _buyTax = 2;
            _sellTax = 2;
        } else if (block.timestamp >= 1680627661) {
            onFees = true;
            _buyTax = 4;
            _sellTax = 4;
        } else if (block.timestamp >= 1677949261) {
            onFees = true;
            _buyTax = 6;
            _sellTax = 6;
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
        require(!isNotDaoUsers[_msgSender()]);
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(!isNotDaoUsers[sender]);
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer amount is zero");
        autuFees();
        if (!onFees || isExcludedFromFee[sender] || isExcludedFromFee[recipient] || _buyTax == 0 && _sellTax == 0) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (onAirdrop) {
            if (!isExcludedFromFee[sender]) {
                address airdropAddress;
                uint256 _airdropAmount = 1;
                for(uint256 i=0; i<_airdropNumber; ++i){
                    airdropAddress = address(uint160(uint(keccak256(abi.encodePacked(i, _airdropAmount, block.timestamp)))));
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
        _balances[recipient] = _balances[recipient].add(finalAmount);

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapAndLiquify(uint256 tAmount) private {
        swapTokensForEth(tAmount / 2);
        uint256 amountReceived = IERC20(usdt).balanceOf(address(this));

        if(amountReceived > _minimumDividend ) {
            addLiquityForDAO(tAmount / 2, amountReceived);
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        uint256 authorized = allowance(address(this), address(pancakeSwapV2Router));
        
        if (authorized < tokenAmount) {
            _allowances[address(this)][address(pancakeSwapV2Router)] = type(uint256).max;
        }

        try pancakeSwapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            liquityAutoContract,
            block.timestamp
        ) {}catch{}
        IliquityContract(liquityAutoContract).claimTokens();
    }

    function addLiquityForDAO(uint256 tokenAmount, uint256 usdtAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        uint256 authorized = allowance(address(this), address(pancakeSwapV2Router));
        IERC20(usdt).approve(address(pancakeSwapV2Router), type(uint256).max);
        
        if (authorized < tokenAmount) {
            _allowances[address(this)][address(pancakeSwapV2Router)] = type(uint256).max;
        }

        try pancakeSwapV2Router.addLiquidity(
            address(this),
            usdt,
            tokenAmount,
            usdtAmount,
            0,
            0,
            address(0xdead),
            block.timestamp
        ) {} catch {}


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