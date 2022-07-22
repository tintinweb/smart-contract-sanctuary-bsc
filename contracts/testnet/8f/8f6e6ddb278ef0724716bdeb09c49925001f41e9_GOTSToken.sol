/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
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


contract GOTSToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    address public lpPoolAddress;
    string private _name = "GOTS";
    string private _symbol = "GOTS";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1000000000 * 10**18;
    mapping(address => bool) private whiteList;
    address public feeAddress1 = 0xA41d4e94861D5415B9070F964f98D290E3CbD95B;
    address public feeAddress2 = 0xF1792f52E0f5d7505C3A1d64242f131F8bf47bCb;
    address public feeAddress3 = 0x1cBe6d3Cc5505f3F318E779D8C0e3244d27366d5;

    constructor () {
        whiteList[owner()] = true;
        whiteList[address(this)] = true;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    receive() external payable {}

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
 
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
  
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender,_msgSender(), currentAllowance.sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }

    function isWhite(address addr) public view returns (bool){
        return whiteList[addr];
    }

    function setWhite(address addr) external onlyOwner returns (bool){
        whiteList[addr] = true;
        return true;
    }
    function unWhite(address addr) external onlyOwner returns (bool){
        whiteList[addr] = false;
        return true;
    }

    function setLpPool(address _lpPoolAddress) public onlyOwner {
        lpPoolAddress = _lpPoolAddress;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        // require(sender != address(0), "ERC20: transfer from the zero address");
        // require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 realRecipientAmount=amount;
        if(lpPoolAddress != address(0) && !whiteList[sender] && (lpPoolAddress == recipient || lpPoolAddress == sender)){
            if(lpPoolAddress == recipient){ 
                // sell 
                uint256 feeAmount1 = amount.mul(2).div(100);
                _balances[feeAddress1] = _balances[feeAddress1].add(feeAmount1);
                emit Transfer(sender, feeAddress1, feeAmount1);

                uint256 feeAmount2 = amount.mul(3).div(100);
                _balances[feeAddress2] = _balances[feeAddress2].add(feeAmount2);
                emit Transfer(sender, feeAddress2, feeAmount2);

                uint256 feeAmount3 = amount.mul(5).div(100);
                _balances[feeAddress3] = _balances[feeAddress3].add(feeAmount3);
                emit Transfer(sender, feeAddress3, feeAmount3);

                realRecipientAmount=realRecipientAmount.sub(feeAmount1).sub(feeAmount2).sub(feeAmount3);
            }else{ 
                uint256 feeAmount1 = amount.mul(1).div(100);
                _balances[feeAddress1] = _balances[feeAddress1].add(feeAmount1);
                emit Transfer(sender, feeAddress1, feeAmount1);

                uint256 feeAmount2 = amount.mul(2).div(100);
                _balances[feeAddress2] = _balances[feeAddress2].add(feeAmount2);
                emit Transfer(sender, feeAddress2, feeAmount2);

                uint256 feeAmount3 = amount.mul(5).div(100);
                _balances[feeAddress3] = _balances[feeAddress3].add(feeAmount3);
                emit Transfer(sender, feeAddress3, feeAmount3);

                realRecipientAmount=realRecipientAmount.sub(feeAmount1).sub(feeAmount2).sub(feeAmount3);
            }
        }
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(realRecipientAmount);
        emit Transfer(sender, recipient, realRecipientAmount);
    }
    
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _balances[address(0)] = _balances[address(0)].add(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}