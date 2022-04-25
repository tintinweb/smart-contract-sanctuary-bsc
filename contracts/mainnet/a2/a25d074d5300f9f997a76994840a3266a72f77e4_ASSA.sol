/**
 *Submitted for verification at BscScan.com on 2022-04-25
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

library Math {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if(a == 0) { return 0; }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20Token {
    
    using Math for uint256;
    
    event Burn(address indexed burner, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 totalSupply_;
    mapping(address => uint256) balances_;
    mapping (address => mapping (address => uint256)) internal allowed_;

    function totalSupply() external view returns (uint256) { return totalSupply_; }

    function transfer(address to, uint256 value) external returns (bool) {
        require(to != address(0), "To should not be null.");
        require(value <= balances_[msg.sender], "Not enough balance.");

        balances_[msg.sender] = balances_[msg.sender].sub(value);
        balances_[to] = balances_[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function balanceOf(address owner) external view returns (uint256 balance) { return balances_[owner]; }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {

        require(to != address(0), "To should not be null.");
        require(value <= balances_[from], "Not enough balance.");
        require(value <= allowed_[from][msg.sender], "Not enough balance.");

        balances_[from] = balances_[from].sub(value);
        balances_[to] = balances_[to].add(value);
        emit Transfer(from, to, value);
        
        allowed_[from][msg.sender] = allowed_[from][msg.sender].sub(value);
        emit Approval(from, msg.sender, allowed_[from][msg.sender]);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowed_[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return allowed_[owner][spender];
    }

    function burn(uint256 value) external {
        require(value <= balances_[msg.sender], "Not enough balance.");
        address burner = msg.sender;
        balances_[burner] = balances_[burner].sub(value);
        emit Transfer(burner, address(0), value);
        totalSupply_ = totalSupply_.sub(value);
        emit Burn(burner, value);
    }    
}

contract ASSA is ERC20Token {

    using Math for uint;

    address private _owner;
    uint8 constant public _decimals = 18;
    string constant public _symbol = "ASSA";
    string constant public _name = "ASSA";
    
    constructor(address company, uint amount) {
        
        _owner = company;
        totalSupply_ = amount * (10 ** uint256(_decimals));
        initSetting(company, totalSupply_);
    }

    function initSetting(address addr, uint amount) internal returns (bool) {
        
        balances_[addr] = amount;
        emit Transfer(address(0x0), addr, balances_[addr]);
        return true;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function getOwner() external view returns (address) {
        return _owner;
    }    
}