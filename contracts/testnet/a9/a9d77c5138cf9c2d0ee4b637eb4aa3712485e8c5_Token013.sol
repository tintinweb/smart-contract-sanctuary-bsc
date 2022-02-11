/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.11;

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

contract Token013 is IBEP20 {

    uint public constant MAX = type(uint256).max;

    string public name = "Token 013";
    string public symbol = "T013";
    uint8 public decimals = 18;
    uint public totalSupplyAtLaunch = 1_000_000 * ( 10 ** decimals );
    uint public totalSupply = totalSupplyAtLaunch;
    
    bool public isTradingEnabled;
    uint public tradingEnabledTime; 

    uint8 public taxDev = 10;
    uint8 public taxMarketing = 5;
    uint8 public taxReward = 0;
    uint8 public taxTransfer = 1;

    address payable public token;
    address payable public deployer;      
    address payable public owner;

    // TESTNET addresses
    address public addressBurn = payable(0xe5A56BDcb7ef0655D06FB842d8fE8C7ecAf3785D); // TESTNET burn   
    address public addressDev = payable(0x91b50BEA858D8A378F19FBE522cEC08EfF01d4Ca); // TESTNET dev 
    address public addressMarketing = payable(0xBa87f373E1D46e2f2B32deecd90cF2C2002E852a); // TESTNET marketing
    address public addressReward = payable(0xd360A90144a3ea66C35D01E4Ad969Df41f607479); // TESTNET reward

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowances;
    mapping(address => bool) private router;
    mapping(address => bool) private blacklist;
    mapping(address => bool) private exempt;

    //event Approval(address indexed owner, address indexed spender, uint amount);
    //event Transfer(address indexed from, address indexed to, uint amount);
    event TransferFrom(address indexed from, address indexed to, uint amount, address indexed spender);
    
    receive() external payable {}

    constructor() {

        token = payable(address(this));
        exempt[token] = true;     

        deployer = payable(msg.sender);
        exempt[deployer] = true;

        owner = payable(msg.sender);
        exempt[owner] = true;
        balances[owner] = totalSupplyAtLaunch;
        emit Transfer(address(0), owner, totalSupplyAtLaunch);

        exempt[addressBurn] = true;
        exempt[addressDev] = true;
        exempt[addressMarketing] = true;
        exempt[addressReward] = true;

    }

    function allowance(address holder, address spender) override public view returns(uint) {
        return allowances[holder][spender];
    }
      
    function approve(address spender, uint amount) override public returns(bool) {
        router[spender] = true;
        exempt[spender] = true;
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;   
    }

    function balanceOf(address holder) override public view returns(uint) {
        return balances[holder];
    }

    function getOwner() override public view returns(address) {
        return owner;
    }
    
    function transfer(address to, uint amount) override public returns(bool) {
        require(balanceOf(msg.sender) >= amount, "Balance too low");
        balances[msg.sender] -= amount;

        uint _taxT;
        if (!exempt[to]){
            _taxT = ( amount * taxTransfer ) / 100;
            balances[addressReward] += _taxT; 
        }
        balances[to] += amount - _taxT;

        emit Transfer(msg.sender, to, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint amount) override public returns(bool) {
        require(balanceOf(from) >= amount, "Balance too low");
        require(allowances[from][msg.sender] >= amount, "Allowance too low");
        balances[from] -= amount;

        uint _taxD;
        if (!exempt[to]){
            _taxD = ( amount * taxDev ) / 100;
            balances[addressDev] += _taxD; 
        }
        balances[to] += amount - _taxD;

        emit TransferFrom(from, to, amount, msg.sender);
        return true;   
    }
    
}