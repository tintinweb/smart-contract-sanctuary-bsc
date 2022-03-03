/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

pragma solidity 0.8.12;

//SPDX-License-Identifier: MIT Licensed

interface IBEP20 {

    function totalSupply() external view returns (uint256);

   function BalanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



abstract contract ReentrancyGuard {
    
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
       
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;

        _;
        _status = _NOT_ENTERED;
    }

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}
contract airDrop is ReentrancyGuard{
     address payable public owner;
    IBEP20 public token;
    uint256 public claimAmount;
    uint256 private fee;
    uint256 public startTime;
    uint256 public endTime;
    
    mapping(address => bool) public isClaim;
    
    modifier onlyOwner(){
        require(msg.sender == owner,"not an owner");
        _;
    } 
    
    event Claimed(address _user);
    
    constructor(address payable _owner, IBEP20 _token) {
        owner = _owner;
        token = _token;
        claimAmount = 10000e18;
        startTime = block.timestamp;
        endTime = block.timestamp + 5 days;
        fee = 0.0007 ether;
    }
    
    receive() payable external{}
    
    function claimAirDrop() public payable isHuman nonReentrant {
        require(msg.value >= fee,"invalid Fee");
        require(isClaim[msg.sender] == false,"can not claim twice");
        require(block.timestamp >= startTime && block.timestamp <= endTime,"time over");
         token.transferFrom(owner, msg.sender, claimAmount);
         isClaim[tx.origin] = true;
        emit Claimed(msg.sender);
    }
    
}