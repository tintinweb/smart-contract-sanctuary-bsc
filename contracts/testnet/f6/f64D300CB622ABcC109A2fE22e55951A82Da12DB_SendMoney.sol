pragma solidity ^0.8.0;

contract SendMoney {
    address owner;

    event Paid(address indexed _from, uint _amount, uint _timestamp);

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        pay();
    }

    function pay() public payable {
        emit Paid(msg.sender, msg.value, block.timestamp);
    }

    function balance() public returns (uint256){
    return (address(this)).balance;
  }
    modifier onlyOwner(address _to) {
        require(msg.sender == owner, "you are not an owner!");
        require(_to != address(0), "incorrect address!");
        _;
    }

    function withdraw(address payable _to, uint _transfer_amount) external onlyOwner(_to) {
        _to.transfer(_transfer_amount);
    }
}