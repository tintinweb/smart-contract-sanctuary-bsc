/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

/*

    Website: https://ashows.com.br
    Telegram: https://t.me/AshowOficial
    

    dev blockchain: @gamer_noob_blockchain
    twitter: https://twitter.com/Italoh_SA

    
*/

//SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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

    function renounceOwnership() public virtual onlyOwner() {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner() {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract ASHOW is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    address public maketingWallet = 0x0c53A8938269cA78435E8D43d66b0cC0C26BD23E;
    address public icoAndPresaleWallet = 0x0F046436338C333e809585BeFABc76478f1Ee175;
    address public devWallet = 0x1ae62887066802B303fc98b5939c77abd3d257B0;
    address public fundsWallet = 0x6FAba8fB79EcD288d3B84C85B2f9eeb59079EcD9;
    address public liquidityWallet = 0xF3890A764F987E8E66D6980f96C1bD8F87BcC9cD;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    constructor() {
        _name = "ASHOW";
        _symbol = "ASHOW";
        _decimals = 8;

        _create(liquidityWallet, 1000000 * 10 ** 8);
        _create(maketingWallet, 2000000 * 10 ** 8);
        _create(icoAndPresaleWallet, 3000000 * 10 ** 8);
        _create(devWallet, 4000000 * 10 ** 8);
        _create(fundsWallet, 10000000 * 10 ** 8);

    }

    receive() external payable {}

    function getOwner() external view override returns (address) {
        return owner();
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender, 
        address recipient, 
        uint256 amount) 
        external override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /*
        _create is an internal function in ERC20.sol that is only called here,
        and CANNOT be called ever again
    */

    function _create(address account, uint256 amount) internal {

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function sendToZeroAddress(uint256 amount) external onlyOwner() {

        _balances[_msgSender()] = _balances[_msgSender()].sub(amount, "BEP20: burn amount exceeds balance");
        _balances[address(0x0)] = _balances[address(0x0)].add(amount);

        emit Transfer(_msgSender(), address(0), amount);
    }

    function burnTokens(uint256 amount) external onlyOwner() {

        _balances[_msgSender()] = _balances[_msgSender()].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);

    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function recoverBNB() external onlyOwner() {
        payable(msg.sender).transfer(address(this).balance);
    }

    function recoverERC20 (address _address) external onlyOwner() {
        IERC20(_address).transfer(msg.sender, IERC20(_address).balanceOf(address(this)));
    }

}