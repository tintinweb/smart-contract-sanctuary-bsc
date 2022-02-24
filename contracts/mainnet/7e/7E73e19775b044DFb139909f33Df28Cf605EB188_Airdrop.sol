/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
  
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

    event Transfer(address indexed from, address indexed to, uint256 value);

   
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.8.2;


contract Airdrop {

    uint256 public total_ClaimAirdrop;
    uint256 public cost = 3 * 10 ** 15;  //0.003 bnb
    address public owner;

    IERC20 public token;
    uint256 _decimal = 1;
    uint256 public reward = 1000 * 10 ** _decimal;

    mapping(address => uint) public total_claims;
    mapping (uint => address) public _users;

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner,"Caller: Must be Owner!!");
        _;
    }

    function Claim_AirDrop(uint256 _amount) public payable {  //0.003 bnb

        uint amount = _amount * 10 ** 15;

        require(msg.value == amount,"Insufficient Amount Passed!!");

        require(msg.value >= cost,"Insufficient Funds!!");
        
        _users[total_ClaimAirdrop] = msg.sender;
        total_claims[msg.sender] += msg.value;
        total_ClaimAirdrop += 1;

        (bool success,) = payable(owner).call{value: msg.value}("");
        require(success,"Transaction Failed!!");

        token.transfer(msg.sender, reward);
        // token.transferFrom(owner(),msg.sender, reward);

    }

    function Balance() public onlyOwner view returns(uint256){
        return address(this).balance;
    }

    function token_Balance() public onlyOwner view returns(uint256){
        return token.balanceOf(address(this));
    }

    function withdraw() public onlyOwner {
        (bool success,) = payable(owner).call{value: address(this).balance}("");
        require(success,"Transaction Failed!!");
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

}