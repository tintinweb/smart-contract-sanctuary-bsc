/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

pragma solidity ^0.4.17;

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Lottery2 {
    address public manager;
    address[] public players;
    address public tokenAddress = 0x7d995920cd166E6278435aCed3B47B9cFc42c9f2;

    function Lottery() public {
        manager = msg.sender;
    }

    function enter() public payable {
        require(msg.value > .01 ether);

        players.push(msg.sender);
    }

    function provideService() external payable {
        uint amount = msg.value;
        ERC20Interface tokenContract = ERC20Interface(tokenAddress);
        require(tokenContract.transferFrom(msg.sender, this, amount));
        //Add person to the contract if the send Aether
        players.push(msg.sender);
    }

    function random() private view returns (uint) {
        return uint(keccak256(block.difficulty, now, players));
    }

    function pickWinner() public restricted {
        ERC20Interface tokenContract = ERC20Interface(tokenAddress);
        // gets token balance of the lottery contract
        uint contractBalance = tokenContract.balanceOf(address(this)); 
        uint index = random() % players.length;
        require(contractBalance >= 1);
        //gets psuedo random number and sends to the player at that index
        tokenContract.transfer( players[index], contractBalance / 2 );
        // sends the remaining balance to a treasury
        address treasury;
        tokenContract.transfer( treasury, contractBalance / 2 );
        //resets player list
        players = new address[](0);
    }

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    function getPlayers() public view returns (address[]) {
        return players;
    }
}