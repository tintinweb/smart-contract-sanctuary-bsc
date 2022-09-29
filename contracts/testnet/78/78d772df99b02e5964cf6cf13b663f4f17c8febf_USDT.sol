/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// File: sappchat/Charging.sol



pragma solidity 0.8.17;

contract Charging {

    address private owner;

    IERC20 private USDT;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    event Deposit(address _address, string userId);

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor(address _usdtAddress) {
        owner = msg.sender;
        emit OwnerSet(address(0), owner);
        USDT = IERC20(_usdtAddress);
    }

    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function deposit(uint amount, string memory userId) public {
        require(amount > 0, "Amount is greater than 0");
        uint256 allowance = USDT.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        USDT.transferFrom(msg.sender, address(this), amount);
        emit Deposit(msg.sender, userId);
    }

    function withdraw(uint amount) public isOwner {
        uint balance = USDT.balanceOf(address(this));
        require(amount <= balance);
        USDT.transferFrom(address(this), owner, balance);
    }

}


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract USDT is IERC20 {

    string public constant name = "USDT";
    string public constant symbol = "USDT";
    uint8 public constant decimals = 18;


    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_ = 10 ether;

    address private owner;

    constructor() {
        balances[msg.sender] = totalSupply_;
        owner = msg.sender;
    }

    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender]-numTokens;
        balances[receiver] = balances[receiver]+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner]-numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender]-numTokens;
        balances[buyer] = balances[buyer]+numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }


}