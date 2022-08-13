/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

/**
* 
* 
*           _                 _        
*          /\ \              / /\      
*         /  \ \            / /  \     
*        / /\ \ \          / / /\ \    
*       / / /\ \_\        / / /\ \ \   
*      / /_/_ \/_/       / / /\ \_\ \  
*     / /____/\         / / /\ \ \___\ 
*    / /\____\/        / / /  \ \ \__/ 
*   / / /______       / / /____\_\ \   
*  / / /_______\     / / /__________\  
* / /__________/    / /_____________/  
*  
*   ─────────────────────────────────────────────────────────────────
*
*           Get 100 EB for free                                             
*           Indefinitely Earn BNB                                               
*                       
*                                                                          
*   ───────────────────────────────────────────────────────────────── 
*
*
*                          
* 
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

contract ZZTN_Token is Ownable {

    string private _name = "ZZTOKEN.io";
    string private _symbol = "ZZTN"; 
    uint8 private _decimals = 18;

    uint256 public constant MAX_TAX_LIMIT = 3;

    uint private _totalSupply = 1_000_000_000 * 10 ** _decimals;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address taxCollector = 0x8c2671faA0E6e7a7e90626B93D7d950C834977dA;
    mapping (address => bool) public _ExcludeFee;
    uint taxFee = 1;

    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor(){
        _balances[msg.sender] = _totalSupply;
        _ExcludeFee[msg.sender] = true;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

     function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = msg.sender;
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
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        bool takefee = true;
        uint tax;
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        _balances[from] = fromBalance - amount;

        if(_ExcludeFee[from] || _ExcludeFee[to]) {
            takefee = false;
        }
        
        if(takefee) {
            tax = amount * (taxFee) / 100;
        }

        if(tax > 0){
            _balances[taxCollector] += tax;
            emit Transfer(from, taxCollector, tax);
        }
        
        uint subtotal = amount - tax;
        _balances[to] += subtotal;
        emit Transfer(from, to, subtotal);
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function totalCirculationSupply() public view returns (uint256) {
        return _totalSupply - _balances[DEAD] - _balances[ZERO];
    }

    function setTaxCollectior(address _adr) public onlyOwner {
        taxCollector = _adr;
    }

    function setFeeExclude(address _adr, bool _status) public onlyOwner {
        _ExcludeFee[_adr] = _status;
    }

    function setTaxFee(uint _value) public onlyOwner {
        require(_value <= MAX_TAX_LIMIT,"Max Tax limit is 3%!!");
        taxFee = _value;
    }

}