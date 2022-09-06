/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

interface IPairInfo {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract PriceLock is Ownable {
    using SafeMath for uint;
    using SafeMath for uint112;

    address private USDT = address(0x55d398326f99059fF775485246999027B3197955);
    address public immutable _pairAddress = address(0x42c38BD2c86C33f742216C0c25c53dF0DDcB2DFc);
    address public immutable _contractAddress = address(0xfECFE20420A3467F7d840461A5F0D504dec1861c);

    uint256 unlockPrice1 = 350*(10**18);
    uint256 unlockPrice2 = 450*(10**18);
    uint256 unlockPrice3 = 550*(10**18);
    uint256 unlockPrice4 = 650*(10**18);
    uint256 unlockPrice5 = 750*(10**18);
    uint256 unlockPrice6 = 850*(10**18);
    uint256 unlockPrice7 = 950*(10**18);

    uint256 unlockFlag1 = 0;
    uint256 unlockFlag2 = 0;
    uint256 unlockFlag3 = 0;
    uint256 unlockFlag4 = 0;
    uint256 unlockFlag5 = 0;
    uint256 unlockFlag6 = 0;
    uint256 unlockFlag7 = 0;

    mapping(address => uint256) public userStake;
    address[] public userStakearr;

    function stake(uint256 _amount) public {
        require(_amount>=10*(10**18), "need to be greater than or equal to 10");
        if (userStake[msg.sender]==0){
            userStakearr.push(msg.sender);
        }
        userStake[msg.sender] = userStake[msg.sender].add(_amount);
        IERC20(_contractAddress).transferFrom(msg.sender, address(this), _amount);
    }

    function release() public {
        uint256 currentprice = getTokenPrice(_pairAddress);
        if (currentprice >= unlockPrice1 && unlockFlag1==0){
            unlock(10);
            unlockFlag1=1;
        }else if (currentprice >= unlockPrice2 && unlockFlag2==0){
            unlock(10);
            unlockFlag2=1;
        }else if (currentprice >= unlockPrice3 && unlockFlag3==0){
            unlock(10);
            unlockFlag3=1;
        }else if (currentprice >= unlockPrice4 && unlockFlag4==0){
            unlock(10);
            unlockFlag4=1;
        }else if (currentprice >= unlockPrice5 && unlockFlag5==0){
            unlock(20);
            unlockFlag5=1;
        }else if (currentprice >= unlockPrice6 && unlockFlag6==0){
            unlock(20);
            unlockFlag6=1;
        }else if (currentprice >= unlockPrice7 && unlockFlag7==0){
            unlock(20);
            unlockFlag7=1;
        }
    }

    function unlock(uint256 rate) private  {
        for (uint256 i = 0; i < userStakearr.length; i++) {
            address user = userStakearr[i];
            IERC20(_contractAddress).transfer(user,userStake[user].mul(rate).div(100));
        }
    }

    function getTokenPrice(address pairAddress) public view returns(uint256){
        if(pairAddress == address(0)){
            return 0;
        }
        IPairInfo pair = IPairInfo(pairAddress);
        address token0 = pair.token0();
        address token1 = pair.token1();
        if(token0 != USDT && token1 != USDT){
            return 0;
        }
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        if(reserve0 == 0 || reserve1 == 0){
            return 0;
        }
        if(USDT == token1){
            uint decimals = ERC20(token0).decimals();
            return uint256(reserve1.div(reserve0.div(10**decimals)));
        } else {
            uint decimals = ERC20(token1).decimals();
            return uint256(reserve0.div(reserve1.div(10**decimals)));
        }
    }
}