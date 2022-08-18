/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: MIT
// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
}

// File: lotzedbusd.sol



pragma solidity ^0.8.3;


contract Clusterfock69 {
    address public owner;
    address public BUSD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee;
    address payable[] public players;
    uint256 decimals;
    uint public lotteryId;
    mapping (uint => address payable) public lotteryHistory;
    address payable winner;

    receive() external payable {}
    
    constructor() {
        owner = msg.sender;
        lotteryId = 1;
        decimals = 1 * 10 **18;
    }

    function getWinnerByLottery(uint lottery) public view returns (address payable) {
        return lotteryHistory[lottery];
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function enter() external payable{
        IERC20(BUSD).transferFrom(msg.sender, address(this), 2 ether);
        
        // address of player entering lottery
        players.push(payable(msg.sender));
    }

    function getRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }

    function pickWinner() public onlyOwner {
        uint index = getRandomNumber() % players.length;

        winner = players[index];

        lotteryHistory[lotteryId] = players[index];
        lotteryId++;

        // reset the state of the contract
        players = new address payable[](0);
    }

    function payoutWinnings(uint256 _amount) external {
      require(msg.sender == owner, "Not authorized");
        uint256 _winnings = _amount / 2;
      IERC20(BUSD).transfer(winner, _winnings);
      IERC20(BUSD).transfer(owner, (address(this).balance));
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}