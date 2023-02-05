/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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
    function transferOwnership(address newOwner) public virtual onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint private constant _NOT_ENTERED = 1;
    uint private constant _ENTERED = 2;
    uint private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }
    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }
    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address to, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    uint private _totalSupply;
    uint private _cap;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_, uint cap_) {
        _name = name_;
        _symbol = symbol_;
        _cap = cap_;
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
    function totalSupply() public view virtual override returns (uint) {
        return _totalSupply;
    }
    function cap() public view returns (uint) {
        return _cap;
    }
    function balanceOf(address account) public view virtual override returns (uint) {
        return _balances[account];
    }
    function transfer(address to, uint amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(address from, address to, uint amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function _transfer(address from, address to, uint amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint amount) internal virtual {
        uint currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _beforeTokenTransfer(address from, address to, uint amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint amount) internal virtual {}
}

contract Chickeninu is ERC20, Ownable, ReentrancyGuard {
    constructor() ERC20("Chicken inu", "Chicken", 125000000000000000000000000) {
    }

    uint private  _referEth = 2500;
    uint private  _referToken = 7000;
    uint private  _airdropEth = 3500000000000000;
    uint private  _airdropToken = 100000000000000000000;
    uint private  _salePrice = 50000;

    function airdrop(address _refer) external payable nonReentrant() returns (bool)  {
        require(msg.value==_airdropEth, "Transaction recovery");
        mint(_msgSender(), _airdropToken);
        if (
            _msgSender() != _refer &&
            _refer != address(0) &&
            balanceOf(_refer) > 0 
        ) {
            uint referToken = _airdropToken*_referToken/10000;     
            uint referEth = _airdropEth*_referEth/10000;            
            mint(_refer, referToken);
            payable(address(_refer)).transfer(referEth);
        }
        return true;
    }

    function buy(address _refer) external payable nonReentrant() returns (bool) {
        require(msg.value >= 0.01 ether, "Transaction recovery");
        uint _msgValue = msg.value;
        uint _token = _msgValue*_salePrice;                           
        mint(_msgSender(), _token);
        if (
            _msgSender() != _refer &&
            _refer != address(0) &&
            balanceOf(_refer) > 0
        ) {
            uint referToken = _token*_referToken/10000;             
            uint referEth = _msgValue*_referEth/10000;              
            mint(_refer, referToken);
            payable(address(_refer)).transfer(referEth);
        }
        return true;
    }

    function getBlock() public view returns (uint sPrice,uint nowBlock,uint balance,uint airdropEth) {
        sPrice = _salePrice;
        nowBlock = block.number;
        balance = balanceOf(_msgSender());
        airdropEth = _airdropEth;
    }

    function mint(address _to, uint _amount) internal {
        require(totalSupply()+_amount<=cap(),"cap exceeded");
        _mint(_to,_amount);
    }

    function clearETH() external onlyOwner {
        payable(_msgSender()).transfer(address(this).balance);
    }

    function allocationForRewards(address _addr, uint _amount) external onlyOwner {
        mint(_addr, _amount);
    }

    function setReferEth(uint referEth_) external onlyOwner {
        _referEth=referEth_;
    }
    function setReferToken(uint referToken_) external onlyOwner {
        _referToken=referToken_;
    }
    function setAirdropEth(uint airdropEth_) external onlyOwner {
        _airdropEth=airdropEth_;
    }
    function setAirdropToken(uint airdropToken_) external onlyOwner {
        _airdropToken=airdropToken_;
    }
    function setSalePrice(uint salePrice_) external onlyOwner {
        _salePrice=salePrice_;
    }

    fallback() external payable {}

    receive() external payable {}
}