/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ERC20 is IERC20 {
    
    string private _name; // ไม่ให้ลูกใช้
    string private _symbol;
    uint private _totalSupply;

    //owner => balance
    mapping(address => uint) _balances; 
    //owner => (spender => allowance)
    mapping(address => mapping(address => uint)) _allowances; 

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) { //ระบุเงินทั้งหมดใน supply เป็นการจำกัดจำนวนเงินไม่ให้เกิดเงินเฟ้อ
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function transfer(address to, uint256 amount) public returns (bool) { 
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "approve to zero address");
        require(amount <= _balances[msg.sender], "amount exceed balance");
        
        _approve(msg.sender, spender, amount);
        return true;
    }
     function transferFrom(address from, address to, uint256 amount) public returns(bool) {
        if(from != msg.sender) {
            uint allowanceAmount = _allowances[from][msg.sender];
            require(amount <= allowanceAmount, "amount exceed allowance");
            _approve(from, msg.sender, allowanceAmount - amount);
        }

        _transfer(from,to,amount);

        return true;
    }

    //========== Private Function ============

    function _transfer(address from, address to, uint amount) private { //ใช้ _ ข้างหน้าบอกว่าเป็น private function
        require(from != address(0), "transfer from zero address");
        require(to != address(0), "transfer to aero address");
        require(amount <= _balances[from], "amount exceed balance");
        
        _balances[from] -= amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _approve(address owner,address spender,uint256 amount) private {
        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _mint(address to, uint amount) internal {
        require(to != address(0), "transfer to sero address");

        _balances[to] += amount;
        _totalSupply += amount;

        emit Transfer(address(0), to, amount);

    }

     function _burn(address from, uint amount) internal {
       require(from != address(0), "transfer from zero address");
       require(amount <= _balances[from], "amount exceeds balances");

        _balances[from] -= amount;
        _totalSupply -= amount;

        emit Transfer(from,address(0),amount);
    }
}

contract BondToken is ERC20, Ownable {

    address admin;
    bool pause;

    constructor() ERC20("Bond Token", "Bon") {
    }

    function mint(address to, uint amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint amount) public onlyOwner {
        _burn(from, amount);
    }
}