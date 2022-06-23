/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {

    //Implementado (mais ou menos)
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address recipient, uint256 amount) external returns(bool);

    //Não implementados (ainda)
    //function allowence(address owner, address spender) external view returns(uint256);
    //function approve(address spender, uint256 amount) external returns(bool);
    //function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

    //Implementado
    event Transfer(address from, address to, uint256 value);

    //Não está implementado (ainda)
    //event Approval(address owner, address spender, uint256 value);

}

contract GlaxStarDrop  {

    // Using Libs

    // Structs
    struct Subscriber {
        uint256 amountReceived;
        bool isRegistered;
    }

    // Enum
    enum Status { ACTIVE, PAUSED, CANCELLED } // mesmo que uint8


    // Properties
    address private owner;
    address public tokenAddress;
    address[] private subscribers;
    Status contractState;
    uint256 private balance;

    mapping(address => Subscriber) private addressToSubscriber;

    // Modifiers
    modifier isOwner() {
        require(msg.sender == owner , "Sender is not owner!");
        _;
    }

    // Events
    event NewSubscriber(address beneficiary, uint amount);

    // Constructor
    constructor(address token) {
        owner = msg.sender;
        tokenAddress = token;
        contractState = Status.ACTIVE;
        balance = IERC20(tokenAddress).balanceOf(address(this));
        // requestBalance();
    }


    // Public Functions
    function getBalance() public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function getAmountReceived() public view returns (uint256) {
        return (addressToSubscriber[msg.sender].amountReceived);
    }

    function getState() public view returns(Status) {
        return contractState;
    }

    function subscribe() public returns(address) {
        require(hasSubscribed(msg.sender) == false, "Address already registered");
        require(contractState == Status.ACTIVE, "Contract not activate.");
        addressToSubscriber[msg.sender] = Subscriber(0,true);
        subscribers.push(msg.sender);
        return msg.sender;
    }

    function execute() public isOwner returns(bool) {
        require(contractState == Status.ACTIVE, "Contract not activate.");
        uint256 amountToTransfer = balance / subscribers.length;
        for (uint i = 0; i < subscribers.length; i++) {
            require(subscribers[i] != address(0));
            require(IERC20(tokenAddress).transfer(subscribers[i], amountToTransfer));
            addressToSubscriber[subscribers[i]].amountReceived += IERC20(tokenAddress).balanceOf(subscribers[i]);
        }
        return true;
    }

    function changeStatus(uint256 status) public isOwner {
        // ACTIVE = 0, PAUSED = 1, CANCELLED = 2
        if(status == 0){
            contractState = Status.ACTIVE;
        } else if (status == 1){
            contractState = Status.PAUSED;
        } else if (status == 2){
            contractState = Status.CANCELLED;
        }
    }

    function hasSubscribed(address subscriber) public view returns(bool) {
        if(addressToSubscriber[subscriber].isRegistered){
            return true;
        }
        return false;
    }

    // Private Functions
    //Criar função para receber 50% dos fundos na criação do airdrop
    // function requestBalance() public isOwner {
    //     uint256 value = IERC20(tokenAddress).totalSupply() * 5/10;
    //     require(IERC20(tokenAddress).transferFrom(tokenAddress, address(this), value));
    //     balance = value;            
    // }

    // Kill
    function kill(address redeem) public isOwner {
        require(contractState == Status.CANCELLED, "Contract not cancelled.");
        require(IERC20(tokenAddress).transfer(redeem, balance), "Funds transferred and contract destroyed");
        selfdestruct(payable(owner));
    }   
}