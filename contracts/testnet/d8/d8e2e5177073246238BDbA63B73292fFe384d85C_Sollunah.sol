/**
 *Submitted for verification at BscScan.com on 2022-07-18
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {

    // Functions
    function TotalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address receiver, uint256 quantity) external returns(bool);  
    function allowance(address tokenOwner, address spender) external view returns(uint256);
    function approve(address delegate, uint256 numTokens) external returns(bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);


    // Events
    event Transfer(address from, address to, uint256 value);
    event Minted(address to, uint256 value);
    event Burned(address from, uint256 value);
    event Killed(address killedBy);
    event Approval(address owner, address spender, uint256 value);

}

contract Sollunah is IERC20 {

    //  Libs
    using Math for uint256;

    // Enums
    enum status { ACTIVE, PAUSED, CANCELLED }

    //Properties
    string public constant name = "Sollunah";
    string public constant symbol = "SNA";
    uint8 public constant decimals = 18;
    address payable private owner;
    uint256 private totalsupply;
    status contractState;

    //Mapping
    mapping(address => uint256) private addressToBalance;
    mapping(address => mapping(address => uint)) private allowed;

    // Modifiers
    modifier isOwner() {
        require(msg.sender == owner, "Sender is not owner!");
        _;
    }

    modifier isActive() {
        require(contractState == status.ACTIVE, "The contract is not active!");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
        totalsupply = 21000000; //Implementar decimais ( 8)
        addressToBalance[msg.sender] = totalsupply;
        contractState = status.ACTIVE;
    }

    //Public Functions
    function TotalSupply() external override view returns(uint256) {
        return totalsupply;
    }

    function balanceOf(address tokenOwner) public override view returns(uint256) {
        return addressToBalance[tokenOwner];
    }

    function state() public view returns(status) {
        return contractState;
    }

    function transfer(address receiver, uint256 quantity) external override isActive returns(bool) {
        require(address(receiver) != address(0), "Account address can not be 0");
        require(quantity <= addressToBalance[msg.sender], "Insufficient Balance to Transfer");
        addressToBalance[msg.sender] = addressToBalance[msg.sender].sub(quantity);
        addressToBalance[receiver] = addressToBalance[receiver].add(quantity);

        emit Transfer(msg.sender, receiver, quantity);
        return true;
    }

    function allowance(address tokenOwner, address spender) external override view returns (uint256){
       return allowed[tokenOwner][spender];
    }


    function approve(address delegate, uint256 numTokens) external override isActive  returns (bool) {
        require(delegate != address(0), "Invalid wallet address");
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
      
    function transferFrom(address from, address to, uint256 value) public override
  isActive returns(bool) {
        require(value <= allowed[from][msg.sender],"Amount to transfer exceeds the allowance");        require(addressToBalance[from] >= value,"Insuficient balance from address");
        require(from != address(0), "Invalid owner wallet address");
        require(to != address(0), "Invalid target wallet adress");

        addressToBalance[from] = addressToBalance[from].sub(value);
        addressToBalance[to] = addressToBalance[to].add(value);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        emit Transfer(from, to, value);

        return true;
    }

    function toMint(uint256 amount) public isOwner isActive returns(bool) {
        require(amount > 0, "Amount has to be greater than 0");
        totalsupply += amount;
        addressToBalance[msg.sender] = addressToBalance[msg.sender].add(amount);
        emit Minted(msg.sender, amount);

        return true;
    }

    function toBurn(uint256 amount) public isOwner isActive returns(bool) {
        totalsupply -= amount;
        addressToBalance[msg.sender] = addressToBalance[msg.sender].sub(amount);

        emit Burned(msg.sender, amount);

        return true;
    }

    function changeState(uint8 newState) public isOwner returns(bool) {
        require(newState < 3, "Invalid status option!");

        if (newState == 0) {
            require(contractState != status.ACTIVE, "The status is already ACTIVE");
            contractState = status.ACTIVE;
        } else if (newState == 1) {
            require(contractState != status.PAUSED, "The status is already PAUSED");
            contractState = status.PAUSED;
        } else {
            require(contractState != status.CANCELLED, "The status is already CANCELLED");
            contractState = status.CANCELLED;
        }

        return true;
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function changeOwner(address payable newOwnerContract) public isOwner returns (bool){
        owner = newOwnerContract;
        //emit OwnerChanged(owner, newOwnerContract);

        return true;
    }


    // Kill
    function kill() public isOwner {
        require(contractState == status.CANCELLED, "It's necessary to cancel the contract before to kill it!");
        address payable to = payable(msg.sender);
        to.transfer(getBalance());
        emit Killed(msg.sender);
        selfdestruct(owner);
    }

}

library Math {

    function add(uint256 a, uint256 b) internal pure returns(uint256){
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256){
        assert(b <= a);
        return a - b;
    }

}