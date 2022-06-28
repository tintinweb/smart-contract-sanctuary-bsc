/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/*
* Link: OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)
* contracts/utils/math/SafeMath.sol
*/
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

/*
* Link: OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
* contracts/utils/Context.sol
*/
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/*
* Link: OpenZeppelin Contracts v4.4.1 (access/Ownable.sol) 
* contracts/access/Ownable.sol
*/

abstract contract Ownable is Context {
    address private _owner;
    address private _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

    function acceptOwnership() public virtual{
        require(_msgSender() == _newOwner, "Ownable: only new owner can accept ownership");
        address oldOwner = _owner;
        _owner = _newOwner;
        _newOwner = address(0);
        emit OwnershipTransferred(oldOwner, _owner);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        _newOwner = newOwner;
    }
}

/*
* Link: OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)
* contracts/security/Pausable.sol
*/
abstract contract Pausable is Context {
   
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


/*
* Link: OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
* contracts/token/ERC20/IERC20.sol
*/
interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function maxSupply() external view returns (uint256);

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

/*
* Link: OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)
* contracts/token/ERC20/extensions/IERC20Metadata.sol
*/

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

abstract contract BlackList  is Ownable{
    
    mapping(address => BlackListUser) private _BlackListUser;
    
    event BlackListActive(address account);

    modifier checkBlackList{
        address own = _msgSender();
        require(!getStatusBlackListUser(own) ,"BlackList: User refused. Receiver is on blacklist");
        _;
    }

    struct BlackListUser{
        address     addressUser; 
        string      desUser;
        bool        statusUser;
    }

    function createBlackListUser(
        address _addressUser,
        string memory _desUser,
        bool _statusUser)
        public onlyOwner virtual returns(bool){
            BlackListUser memory newUser = BlackListUser({
                addressUser: _addressUser,
                desUser:     _desUser,
                statusUser: _statusUser
            });
            _BlackListUser[_addressUser] = newUser;
            emit BlackListActive(_addressUser);
            return true;
    }

    function getInfoBlackListUser(address _addressUser) public view returns(address, string memory, bool){
        address addressUser     = _BlackListUser[_addressUser].addressUser;
        string memory desUser   = _BlackListUser[_addressUser].desUser;
        bool statusUser = _BlackListUser[_addressUser].statusUser;
        return (addressUser, desUser, statusUser);
    }

    function getAddressBlackListUser(address _addressUser) public view returns(address) {
        address addressUser = _BlackListUser[_addressUser].addressUser;
        return (addressUser);
    }

    function getStatusBlackListUser(address _addressUser) public view returns(bool) {
        bool statusUser = _BlackListUser[_addressUser].statusUser;
        return (statusUser);
    }

    function changeInfoBlackListUser(
        address _addressUser,
        string memory _desUser,
        bool _statusUser) 
        public onlyOwner virtual returns(bool){
            BlackListUser storage user = _BlackListUser[_addressUser];
            user.desUser            = _desUser;
            user.statusUser    = _statusUser;
            emit BlackListActive(_addressUser);
            return true;
    }

}

/*
* Link: 
* 
*/
abstract contract LibBKC is Context, Ownable, Pausable, IERC20{

    function setStatusPause() public whenNotPaused onlyOwner {
        _pause();
    }

    function setStatusUnPause() public whenPaused onlyOwner {
        _unpause();
    }

}

/*
* Link: OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)
* contracts/token/ERC20/ERC20.sol
*/
contract ERC20 is Context, Ownable, IERC20, IERC20Metadata , LibBKC, BlackList{
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint256 private _maxSupply;
    string  private _name;
    string  private _symbol;
    uint8   private _decimals;

    event Deposit(address indexed _to, uint _amount);
    event Withdrawal(address indexed _from, uint _amount);
    event MintToken(address indexed _owner , uint _amount);
    event BurnToken(address indexed _owner , uint _amount);

    constructor() {
        _name           = "BKCenter";
        _symbol         = "BKC3";
        _decimals       = 18;
        _maxSupply      = 100000000 * 10 ** 18;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function maxSupply() public view virtual override returns (uint256) {
        return _maxSupply;
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
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_totalSupply + amount <= _maxSupply, "ERC20: mint amount exceeds max supply");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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
    ) internal whenNotPaused checkBlackList virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


contract TokenBKC is ERC20{

    function mintToken(uint256 amount) public virtual onlyOwner{
        _mint(_msgSender(), amount);
    }

    function burnToken(uint256 amount) public virtual{
        _burn(_msgSender(), amount);
    }

    function burnTokenFrom(address from, uint256 amount) public virtual
    {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _burn(from, amount);
    }

    function burnTokenBlackList(address account, uint256 amount) public onlyOwner virtual{
        _burn(account, amount);
    }
}