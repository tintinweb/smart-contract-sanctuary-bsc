/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IBEP20 {
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
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
    function div( uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IPinkAntiBot {
    function setTokenOwner(address owner) external;
    function onPreTransferCheck(address from, address to, uint256 amount) external;
}

contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    IPinkAntiBot public pinkAntiBot;

    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event OwnershipRenounced(address indexed previousOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(ZERO, msgSender);
        // Testnet
        pinkAntiBot = IPinkAntiBot(0xbb06F5C7689eA93d9DeACCf4aF8546C4Fe0Bf1E5);
        // Mainnet
        // pinkAntiBot = IPinkAntiBot(0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002);        
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        emit OwnershipTransferred(_owner, ZERO);
        _owner = ZERO;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != ZERO,
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
        pinkAntiBot.setTokenOwner(_owner);
    }
}

contract FBRNT14 is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    modifier validAccount(address to) {
        require(to != DEAD);
        require(to != ZERO);
        _;
    }

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    uint256 public totalBurned = 0;
    uint256 public tax = 15;
    uint256 public feeDenominator = 100;


    mapping(address => bool) internal taxExepmt;
    mapping(address => bool) internal blacklist;

    constructor() {
        _name = "Final Burn TEST";
        _symbol = "FBRNT14";
        _decimals = 18;
        _totalSupply = 1_000_000_000_000 * (10**_decimals);
        _balances[owner()] = _totalSupply;

        taxExepmt[owner()] = true;
        taxExepmt[address(this)] = true;
        // Mainnet
        /*
        taxExepmt[0x56c54092cE7294EC81b84De221B08063FdF51b05] = true; // FBRN Marketing wallet
        taxExepmt[0x91a31Ad16339F06d021d30648D56b0512FeC122b] = true; // FBRN Team wallet
        taxExepmt[0x1D2f48Fb697f0f798a7828Ccb4c99b3752595B57] = true; // Reserves wallet
        taxExepmt[0xE58032074df5Fd8e02aF166E25882a1dd305C8f9] = true; // Manual Burn wallet
        */
        // Testnet
        taxExepmt[0x11f72ee541D0bC822f34d8158A2387F1FD5Ac967] = true; // FBRN Marketing wallet
        taxExepmt[0x4f3778EAd57eE7AE43047e28Ed268b4199fD54c0] = true; // FBRN Team wallet
        taxExepmt[0xa8FE9Eb028f8b1795D57c23653045286F86140d5] = true; // Reserves wallet
        taxExepmt[0x0554440c0911E96C7c132Ec0df815a7A477d328b] = true; // Manual Burn wallet

        _transferOwnership(owner());

        emit Transfer(ZERO, owner(), _totalSupply);
    }

    function getOwner()
        external view override returns (address) {
        return owner();
    }

    function decimals()
        external view override returns (uint8) {
        return _decimals;
    }

    function symbol()
        external view override returns (string memory) {
        return _symbol;
    }

    function name()
        external view override returns (string memory) {
        return _name;
    }

    function totalSupply()
        external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        external override returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external view override returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external override validAccount(spender) returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        external override validAccount(sender) returns (bool)
    {
        _approve(sender,recipient,amount);
        
        _allowances[sender][recipient].sub(amount,"BEP20: transfer amount exceeds allowance for sender");
        
        _transfer(sender, recipient, amount);
        return true;
    }

    function burnFrom(address sender, uint256 amount) external virtual validAccount(sender) onlyOwner returns (bool)
    {
        totalBurned = totalBurned.add(amount);
        _burn(sender, amount);
        return true;
    }  

    function increaseAllowance(address spender, uint256 addedValue)
        public validAccount(spender) returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public validAccount(spender) returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount)
        internal validAccount(sender)
    {
        require(amount > 0, 'Amount must be greater than 0');
        require(!blacklist[sender], "Sender Blacklisted");
        require(!blacklist[recipient], "Recipient Blacklisted");
        require(_balances[sender] >= amount, "Sender has insufficient balance");

        pinkAntiBot.onPreTransferCheck(sender, recipient, amount);

        bool shouldTax = shouldTakeTax(sender);

        uint256 netAmount = amount;
        
        if (shouldTax) {
            netAmount = netAmount.sub(calcTaxAndBurn(sender, amount), 'Burn amount exceeds amount to send');
        }

        _balances[sender] = _balances[sender].sub(
            netAmount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(netAmount);
        emit Transfer(sender, recipient, netAmount);
    }

    function calcTaxAndBurn(address sender, uint256 amount)
        internal returns (uint256)
    {
        uint256 taxAmount = amount.mul(tax).div(feeDenominator);

        // Burn the tax
        totalBurned = totalBurned.add(taxAmount);
        _burn(sender, taxAmount);

        return taxAmount;
    }

    function shouldTakeTax(address from)
        internal view returns (bool)
    {
        return !taxExepmt[from];
    }

    function _burn(address sender, uint256 amount)
        internal validAccount(sender)
    {
        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: burn amount exceeds balance of sender"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(sender, DEAD, amount);
    }

    function _approve(address owner, address spender, uint256 amount)
        internal validAccount(owner) validAccount(spender)
    {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setTaxExepmt(address _addres, bool _flag)
        external onlyOwner returns (address)
    {
        taxExepmt[_addres] = _flag;

        return _addres;
    }

    function getTaxExepmt(address _addres)
        external view returns (bool)
    {
        return taxExepmt[_addres];
    }

    function setBlacklist(address _addres, bool _flag)
        external onlyOwner returns (address)
    {
        blacklist[_addres] = _flag;

        return _addres;
    }
}