// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

contract Lottery {
    
    address public immutable OWNER;
    
    address[] public players;

    uint private counter; 

    uint public lotteryId;
  
    mapping (uint => address ) public lotteryHistory;
    
    constructor() {
        OWNER = msg.sender;
        lotteryId = 1;
    }

    modifier onlyOwner{
        require(OWNER == msg.sender, "Only Owner");
        _;
    }

    function enter() public payable {
        require(msg.value == 0.1 ether, "You must pay at least 0.1 bnb per ticket");
        players.push(msg.sender);

    }

    function getPlayers() public view returns (address[] memory) {
        return players;
    }
    
    function getLotteryId() public view returns (uint) {
        return lotteryId;
    }

    function balance() public view returns(uint256){
        return address(this).balance;
    }

    function getLastWinnerByLottery(uint lottery) public view returns (address) {
        return lotteryHistory[lottery];
    }

    function random() private view returns (uint256) {
        return 
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp, 
                        block.difficulty, 
                        players, 
                        counter 
                    )
                )
            );
    }

    function pickWinner() public onlyOwner returns(address payable){
        require(address(this).balance >= 0.2 * 1e18);
        uint index = random() % players.length;

        address payable winner = payable (players[index]);
        address payable donation = payable (OWNER);

        donation.transfer(address(this).balance / 20);  // 5% of amount lottery
        
        winner.transfer(address(this).balance);
        
        lotteryHistory[lotteryId] = players[index];

        counter = counter + 1;
        lotteryId++;
        players = new address[](0);

        return winner;
    } 

}