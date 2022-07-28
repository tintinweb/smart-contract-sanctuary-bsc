/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IERC20 {
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
}

contract Lottery {
    address public owner;
    address public Token = 0x7d995920cd166E6278435aCed3B47B9cFc42c9f2;
    address payable[] public players;
    uint public lotteryId;
    uint256 public jackpot = 10;
    mapping (uint => address payable) public lotteryHistory;

    constructor() {
        owner = msg.sender;
        lotteryId = 1;
    }

    function getWinnerByLottery(uint lottery) public view returns (address payable) {
        return lotteryHistory[lottery];
    }

    function setJackpot(uint256 _jackpot) public onlyowner {
        jackpot = _jackpot;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function getJackpotValue() public view returns (uint256) {
        return jackpot;
    }

    function enter() public payable {
        IERC20 token = IERC20(address(0x7d995920cd166E6278435aCed3B47B9cFc42c9f2));
        IERC20(token).transferFrom(address(msg.sender), address(this), 1);

        // address of player entering lottery
        players.push(payable(msg.sender));
    }

    function getRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    function pickWinner() public {
        uint index = getRandomNumber() % players.length;
        uint256 balance = ERC20(Token).balanceOf(address(this));
        require(balance >= 10);
        players[index].transfer(address(this).balance);

        lotteryHistory[lotteryId] = players[index];
        lotteryId++;
        

        // reset the state of the contract
        players = new address payable[](0);
    }

    modifier onlyowner() {
      require(msg.sender == owner);
      _;
    }
}

// Interface for ERC20
abstract contract ERC20 {
    function allowance(address tokenOwner, address spender) virtual public returns (uint remaining);
    function approve(address spender, uint tokens) virtual public returns (bool success);
    function balanceOf(address tokenOwner) virtual external view returns (uint256);
    function transfer(address receiver, uint256 numTokens) virtual public returns (bool);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}