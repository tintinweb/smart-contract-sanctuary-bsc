/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }
    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }
    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
contract Airdrop  {
    using Counters for Counters.Counter;
    IERC20 public token;
    address payable owner;
    uint256 public AirdropAmount = 1000000000000000000000000;
    uint256 public _unlockTime = 15765000; // 6months
    uint256 AmountPerUser = 1000000000000000000000;
    uint256 fees = 0.001 ether ;
    Counters.Counter private _claimdropNumber;
    Counters.Counter private _unlockedDropsNumber;
    bool airdropActive = false;
    struct Claim {
        IERC20 token;
        uint256 amount;
        uint256 releasetime;
        bool claimed;
        bool withdrawn;
    }
    mapping (address => Claim) allairdrops;
    event Claimtoken(
        IERC20 token,
        address claimer,
        uint256 amount,
        uint256 unlockTime
    );
    event RewardToken(
        IERC20 token,
        address claimer,
        uint256 amount
    );
    event StartAirdrop(IERC20 token, uint256 airdropamount);
    modifier onlyOwner() {
        require (msg.sender == owner,"owner can call");
        _;
    }
    constructor(address _tokenAddr) {
        owner = payable(msg.sender);
        require(_tokenAddr != address(0));
        token = IERC20(_tokenAddr);
        airdropActive = true; 
        token.transferFrom(msg.sender,address(this),AirdropAmount);
        emit StartAirdrop(token,AirdropAmount);
    }
    function RewardTokens() public {
        require(payable(msg.sender) != owner,"owner cannot claim");
        require(token.balanceOf(address(this)) >= AmountPerUser ,"token amount is less than 1000");
        require(airdropActive = true,"airdrop should be active");
        require(allairdrops[msg.sender].claimed== false,"user already part of airdrop");
        allairdrops[msg.sender] = Claim(token,AmountPerUser,block.timestamp + _unlockTime,true,false);
        allairdrops[msg.sender].claimed = true;
        emit Claimtoken(token,msg.sender,AmountPerUser,block.timestamp + _unlockTime);
    }
    function ClaimReward() public payable{
         require(msg.value == fees,"you should pay 0.001 eth");
         require (block.timestamp >= allairdrops[msg.sender].releasetime);
         require(allairdrops[msg.sender].claimed == true,"user not part of airdrop"); 
         require(allairdrops[msg.sender].withdrawn == false,"user not withdrawn");
         owner.transfer(fees);
         IERC20(token).transfer(msg.sender, AmountPerUser);
         allairdrops[msg.sender].withdrawn = true;
         emit RewardToken( token, msg.sender, AmountPerUser);
    }
    function setAirdropAmount(uint256 value) public onlyOwner{
        AirdropAmount = value ;
    }
    function set_unlockTime(uint256 unlockTime) public onlyOwner {
        _unlockTime = unlockTime ;
    }
    function set_AmountPerUser(uint256 _AmountPerUser) public onlyOwner {
        AmountPerUser = _AmountPerUser;
    }
    function setfees(uint256 _fees) public onlyOwner {
        fees = _fees;
    }
    function getAirDrop(address user) public view returns(uint256,bool,bool) {
        return (allairdrops[user].releasetime, allairdrops[user].claimed, allairdrops[user].withdrawn);
    }
}