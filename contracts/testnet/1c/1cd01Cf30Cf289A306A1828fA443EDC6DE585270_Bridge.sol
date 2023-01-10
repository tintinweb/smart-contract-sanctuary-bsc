/**
 *Submitted for verification at BscScan.com on 2023-01-09
*/

pragma solidity ^0.8.9;

interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
}

contract Bridge {
    struct Deposit { 
        address sender;
        address receiver;
        address token;
        uint256 chain;
        uint256 amount;
        uint256 timestamp;
    }
    address public owner;
    uint256 public lastDepositId;
    mapping (uint256 => Deposit) public deposits;

    event TokenDeposit(uint256 indexed _depositId);

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function get(uint256 id) public view returns (Deposit memory _deposit) {
        return deposits[id];
    }

    function deposit(address token, uint256 amount, uint256 chain, address receiver) public returns (uint256 _depositId) {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        lastDepositId++;
        deposits[lastDepositId] = Deposit(msg.sender, receiver, token, chain, amount, block.timestamp);
        emit TokenDeposit(lastDepositId);
        return lastDepositId;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function withdraw(address token, uint256 amount, address receiver) public onlyOwner {
        IERC20(token).transfer(receiver, amount);
    }
}