/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

pragma solidity ^0.8.11;

// SPDX-License-Identifier: MIT

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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
contract ERC20 is Context, IERC20, IERC20Metadata {
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        _transfer(sender, recipient, amount);

        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

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

contract SBT is ERC20 {
    using SafeMath for uint256;
    mapping(address => bool) public exclidedFromTax;
    address public owner;
    uint adminAmount;
    uint burnAmount;

    struct Tax_Burn {
        uint Buy_Burn;
        uint Transfer_Burn;
        uint Whale1_Burn;
        uint Whale2_Burn;
        uint Whale3_Burn;
        uint Whale4_Burn;
        uint Whale5_Burn;
    }
    Tax_Burn tb;

    struct Tax_Fee {
        uint Buy_Tax;
        uint Transfer_Tax;
        uint Whale1_Tax;
        uint Whale2_Tax;
        uint Whale3_Tax;
        uint Whale4_Tax;
        uint Whale5_Tax;
    }
    Tax_Fee tf;

    struct FreeTaxFee {
        address adr;
        address adr1;
        address adr2;
        address adr3;
        address adr4;
    }
    FreeTaxFee ft;

    struct swap_address {
        address swap_adr;
        address swap_adr1;
        address swap_adr2;
        address swap_adr3;
        address swap_adr4;
    }
    swap_address sa;

    constructor() ERC20('Simba Lion', 'SBT') {
        tb.Whale1_Burn = tf.Whale1_Tax = 3;
        tb.Whale2_Burn = 16;
        tf.Whale2_Tax = 4;
        tb.Whale3_Burn = 30;
        tf.Whale3_Tax = 5;
        tb.Whale4_Burn = 36;
        tf.Whale4_Tax = 6;
        tb.Whale5_Burn = 38;
        tf.Whale5_Tax = 17;
        tb.Buy_Burn = tf.Buy_Tax = 3;
        tb.Transfer_Burn = tf.Transfer_Tax = 2;
        _mint(msg.sender, 20000000000000 * 10 ** 18);
        owner = msg.sender;
        exclidedFromTax[msg.sender] = true;
    }
    function Get_Owner() public view returns(address){
        return owner;
    }
    function Get_Swap_Address() public view returns(address){
        return sa.swap_adr;
    }
    function Get_Swap_Address1() public view returns(address){
        return sa.swap_adr1;
    }
    function Get_Swap_Address2() public view returns(address){
        return sa.swap_adr2;
    }
    function Get_Swap_Address3() public view returns(address){
        return sa.swap_adr3;
    }
    function Get_Swap_Address4() public view returns(address){
        return sa.swap_adr4;
    }
    function Get_Address() public view returns(address){
        return ft.adr;
    }
    function Get_Address1() public view returns(address){
        return ft.adr1;
    }
    function Get_Address2() public view returns(address){
        return ft.adr2;
    }
    function Get_Address3() public view returns(address){
        return ft.adr3;
    }
    function Get_Address4() public view returns(address){
        return ft.adr4;
    }
    function Get_Buy_Burn() public view returns(uint){
        return tb.Buy_Burn;
    }
    function Get_Buy_Tax() public view returns(uint){
        return tf.Buy_Tax;
    }
    function Get_Transfer_Burn() public view returns(uint){
        return tb.Transfer_Burn;
    }
    function Get_Transfer_Tax() public view returns(uint){
        return tf.Transfer_Tax;
    }
    function Get_Whale1_Burn() public view returns(uint){
        return tb.Whale1_Burn;
    }
    function Get_Whale1_Tax() public view returns(uint){
        return tf.Whale1_Tax;
    }
    function Get_Whale2_Burn() public view returns(uint){
        return tb.Whale2_Burn;
    }
    function Get_Whale2_Tax() public view returns(uint){
        return tf.Whale2_Tax;
    }
    function Get_Whale3_Burn() public view returns(uint){
        return tb.Whale3_Burn;
    }
    function Get_Whale3_Tax() public view returns(uint){
        return tf.Whale3_Tax;
    }
    function Get_Whale4_Burn() public view returns(uint){
        return tb.Whale4_Burn;
    }
    function Get_Whale4_Tax() public view returns(uint){
        return tf.Whale4_Tax;
    }
    function Get_Whale5_Burn() public view returns(uint){
        return tb.Whale5_Burn;
    }
    function Get_Whale5_Tax() public view returns(uint){
        return tf.Whale5_Tax;
    }
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    function Set_Swap_Address(address _swap_adr, address _swap_adr1, address _swap_adr2, address _swap_adr3, address _swap_adr4) public onlyOwner {
        sa = swap_address(_swap_adr, _swap_adr1, _swap_adr2, _swap_adr3, _swap_adr4);
    }
    function Set_Free_Tax_Address(address _adr, address _adr1, address _adr2, address _adr3, address _adr4) public onlyOwner {
        ft = FreeTaxFee(_adr, _adr1, _adr2, _adr3, _adr4);
    }
    function Set_Tax_Burn(uint _Buy_Burn, uint _Transfer_Burn, uint _Whale1_Burn, uint _Whale2_Burn, uint _Whale3_Burn, uint _Whale4_Burn, uint _Whale5_Burn) public onlyOwner {
        tb = Tax_Burn(_Buy_Burn, _Transfer_Burn, _Whale1_Burn, _Whale2_Burn, _Whale3_Burn, _Whale4_Burn, _Whale5_Burn);
    }
    function Set_Tax_Fee(uint _Buy_Tax, uint _Transfer_Tax, uint _Whale1_Tax, uint _Whale2_Tax, uint _Whale3_Tax, uint _Whale4_Tax, uint _Whale5_Tax)  public onlyOwner {
        tf = Tax_Fee(_Buy_Tax, _Transfer_Tax, _Whale1_Tax, _Whale2_Tax, _Whale3_Tax, _Whale4_Tax, _Whale5_Tax);
    }

    function transfer(address recipient,uint256 amount) public override returns (bool) {
        if(recipient == address(0x000000000000000000000000000000000000dEaD)) {
            burnAmount = amount;
            _burn(_msgSender(), burnAmount);
            _transfer(_msgSender(), owner, adminAmount);
            _transfer(_msgSender(), recipient, amount.sub(burnAmount).sub(adminAmount));
        }
        else if(exclidedFromTax[msg.sender] == true || msg.sender == ft.adr || msg.sender == ft.adr1 || recipient == ft.adr2 || msg.sender == ft.adr3 || msg.sender == ft.adr4 || recipient == ft.adr || recipient == ft.adr1 || recipient == ft.adr2 || recipient == ft.adr3 || recipient == ft.adr4) {
            _transfer(_msgSender(), recipient, amount);
        }
        else if(msg.sender == sa.swap_adr || msg.sender == sa.swap_adr1 || msg.sender == sa.swap_adr2 || msg.sender == sa.swap_adr3 || msg.sender == sa.swap_adr4) {
            burnAmount = amount.mul(tb.Buy_Burn) / 100;
            adminAmount = amount.mul(tf.Buy_Tax) / 100;
            _burn(_msgSender(), burnAmount);
            _transfer(_msgSender(), owner, adminAmount);
            _transfer(_msgSender(), recipient, amount.sub(burnAmount).sub(adminAmount));
        }
        else if(recipient == sa.swap_adr || recipient == sa.swap_adr1 || recipient == sa.swap_adr2 || recipient == sa.swap_adr3 || recipient == sa.swap_adr4) {
            if(amount >= 1 && amount <= 10000000000 * 10 ** 18) {
                burnAmount = amount.mul(tb.Whale1_Burn) / 100;
                adminAmount = amount.mul(tf.Whale1_Tax) / 100;
            }
            else if(amount > 10000000000 * 10 ** 18 && amount <= 100000000000 * 10 ** 18) {
                burnAmount = amount.mul(tb.Whale2_Burn) / 100;
                adminAmount = amount.mul(tf.Whale2_Tax) / 100;
            }
            else if(amount > 100000000000 * 10 ** 18 && amount <= 500000000000 * 10 ** 18) {
                burnAmount = amount.mul(tb.Whale3_Burn) / 100;
                adminAmount = amount.mul(tf.Whale3_Tax) / 100;
            }
            else if(amount > 500000000000 * 10 ** 18 && amount <= 1000000000000 * 10 ** 18) {
                burnAmount = amount.mul(tb.Whale4_Burn) / 100;
                adminAmount = amount.mul(tf.Whale4_Tax) / 100;
            }
            else {
                burnAmount = amount.mul(tb.Whale5_Burn) / 100;
                adminAmount = amount.mul(tf.Whale5_Tax) / 100;
            }
            _burn(_msgSender(), burnAmount);
            _transfer(_msgSender(), owner, adminAmount);
            _transfer(_msgSender(), recipient, amount.sub(burnAmount).sub(adminAmount));
        }
        else {
            burnAmount = amount.mul(tb.Transfer_Burn) / 100;
            adminAmount = amount.mul(tf.Transfer_Tax) / 100;
            _burn(_msgSender(), burnAmount);
            _transfer(_msgSender(), owner, adminAmount);
            _transfer(_msgSender(), recipient, amount.sub(burnAmount).sub(adminAmount));
        }
        return true;
    }
}