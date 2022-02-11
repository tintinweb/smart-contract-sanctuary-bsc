// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "./PresaleToken.sol";
import "./SafeMath.sol";
contract PresaleVault is PresaleToken{
    using SafeMath for uint256;
    uint256 public presaleAmount;
    mapping (address => uint256) _depositedAmount;
    uint256 t = 0;
    uint256 public endDate;
    uint256 public share;
    uint256 _totalDeposited = 0;
    address _owner;
    uint256 public duration = 3 days;
    constructor() {
        presaleAmount = 100000;
        _owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == _owner, "Sorry you are not the owner!");
        _;
    }
    function deposit(uint256 _amount) public payable {
        require(block.timestamp < endDate);
        require(t == 1, "Depositing is not started yet.");
        require(msg.value == _amount, "Please send same right amount.");
        _depositedAmount[msg.sender] = _depositedAmount[msg.sender].add(msg.value);
        require(_depositedAmount[msg.sender] <= 10 ether, "You cannot commit more than 10 BNB");
        require(10 * _depositedAmount[msg.sender] >= 1 ether, "You cannot commit less than 0.1 BNB");
        _totalDeposited = _totalDeposited.add(msg.value);

    }
    function start() public onlyOwner {
        require(t == 0, "Depositing has been already started");
        t = 1;
        endDate = duration.add(block.timestamp);
    }

    function totalDeposited() public view returns(uint256) {
        return(address(this).balance);
    }

    function remainingTime() public view returns(uint256) {
        require(t == 1, "Depositing hasn't been started yet");
        return(endDate.sub(block.timestamp));
    }   

    function withdraw() public onlyOwner {
        require(block.timestamp > endDate);
        payable(_owner).transfer(address(this).balance);
    }

    function claim() public {
        share = (_depositedAmount[msg.sender].div(_totalDeposited)).mul(100000);
        _transfer(address(this), msg.sender, share);
        _depositedAmount[msg.sender] = 0;
    }
}