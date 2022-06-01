/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

pragma solidity ^0.4.17; //>=0.5.0 < 0.9.0; // definition of the compiler version 

contract LotteryEGO
{
    address     public manager; //Variable for storing the deployers address
    address[]   public players; //Variable for storing player's addresses
    address     public winner;  //Variable for storing the winner's address

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function Lottery()          //This constructor function reads and assign the deployer address to the manager
        public
            {
            manager = msg.sender;
            }

    function Enter()            //Function that allows receving >0.01 ETH into the contract  
        public
        payable
            {
        require(msg.value > 100000000000000000);

            players.push(msg.sender);
            }

    function ShowAll()          //Function that shows all participants
        public
        view
        returns(address[])
            {
            return players;
            }

    function PlayersNo()        //Function that shows the total number of participants
        public
        view
        returns(uint)
            {
            return players.length;
            }
    function Random()           //Function generates pseudo random number, never specified exact time prior to a draw to make it random. Maybe give 2 minutes range.
        private
        view
        returns(uint)
            {
            return uint(keccak256(block.difficulty,now,players));
            }

    function PickWinner()       //FUnction picks the winner's wallet, sends the rewards ballance to the wallet and resets the players array
        public
        restricted
        minimumPlayers
            {
            uint index = Random() % players.length;
            players[index].transfer(this.balance);
            winner = players[index];
            players = new address[](0);                 
            }

    function ShowWinner()       //Function shows the winner
        public
        view
        returns(address)
            {
            return winner;
            }

    modifier restricted()       //Function modifier that restricts the execution of the function until the condition is met, in this case only manager can execute a function
            {
            require(msg.sender == manager);
            _;
            }

    modifier minimumPlayers()   //Function modifier that restricts the execution of the function until the condition is met, in this case minumum amount of participants
            {
            require(players.length >1);
            _;
            }
}