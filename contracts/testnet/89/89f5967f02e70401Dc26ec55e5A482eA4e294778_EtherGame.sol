/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

contract EtherGame {
    uint public targetAmount = 0.05 ether;
    address public winner;

    function deposit() public payable {
        require(msg.value == 0.01 ether, "You can only send 1 Ether");

        uint balance = address(this).balance;
        require(balance <= targetAmount, "Game is over");

        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}