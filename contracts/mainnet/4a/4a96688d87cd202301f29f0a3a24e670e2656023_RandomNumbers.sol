/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

/*
            @@@                                                                                   
            @@@@@@@                                                                                 
         &    @@@@@@@@                                                                              
       @@@@@    @@@@@@@@                                                                            
     @@@@@@@@     @@@@@@@@        @@@    @@@  @@@@@@        @@@@@@@^      @@@@@@@     @@  @@@     @@
   @@@@@@@@    @    @@@@@@@@        @@  @@.   @@   @@@    @@@     @@@   @@@     @@@   @@  @@@@    @@
 @@@@@@@     @@@@@    @@@@@@@@       @@@@     @@   @@@    @@           @@@       @@@  @@  @@ @@@  @@
 @@@@@@@~    @@@@@    @@@@@@@@       @@@@     @@@@@@      @@           @@@       @@@  @@  @@   @@ @@
   @@@@@@@@    @    @@@@@@@@       @@@  @@@   @@  @@@     @@@     @@@   @@@     @@@   @@  @@    @@@@
     @@@@@@@@     @@@@@@@@        @@@    @@@  @@    @@@     @@@@@@@.      @@@@@@@     @@  @@     @@@
       @@@@@    @@@@@@@@                                                                            
         ~    @@@@@@@@                                                                              
            @@@@@@@                                                                                 
              @@@                                   

            
            WEBSITE:    ---->   xr-coin.net
            E-MAIL:     ---->   [email protected] */

pragma solidity ^0.8.17;
contract RandomNumbers{
    string public name = "XR COIN - GAMEFI - RANDOM NUMBER";
  
function Random(uint _number) public view returns(uint256) {
    uint256 seed = uint256(keccak256(abi.encodePacked(
        block.timestamp + block.difficulty +
        ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
        block.gaslimit + 
        ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
        block.number
    )));

    return (seed - ((seed / 36) * 36));
}
}