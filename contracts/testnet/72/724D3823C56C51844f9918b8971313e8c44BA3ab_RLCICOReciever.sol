// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./Counters.sol";
import "./IERC20.sol";
import "./Ownable.sol";


contract RLCICOReciever is Ownable{
    
    using Counters for Counters.Counter;
    Counters.Counter autoID;

    address USDTAddress;

    struct RLCRecieveToken{
        uint tokenID;
        address senderAddress;
        uint tokenAmount;
        uint dateTime;
    }

    mapping(uint => RLCRecieveToken) incomingTokens;
    mapping(address => uint256) incomingTokenAddresses;
    
    mapping(address => uint256) totalAmount;
    address private tokenAddress ;
    mapping(uint => uint256) private tierMaxAmount;

        constructor(address allowedToken){
        tokenAddress = allowedToken;

        
        // tierMaxAmount[1] = 1500*10**18;
        // tierMaxAmount[2] = 900*10**18;
        // tierMaxAmount[3] = 750*10**18;
        // tierMaxAmount[4] = 600*10**18;
        // tierMaxAmount[5] = 525*10**18;
        // tierMaxAmount[6] = 450*10**18;
        // tierMaxAmount[7] = 375*10**18;
        // tierMaxAmount[8] = 300*10**18;
        // tierMaxAmount[9] = 225*10**18;
        // tierMaxAmount[10] = 150*10**18;
        
    }

    // function testMethod(uint256 number) public {
    //     for(uint256 i = 0 ; i < number ; i++){
    //         recieveTokens(tokenAddress, 10*10**18);
    //     }
    // }

    function recieveTokens(address _token, uint _tokenAmount) public{
        require(_tokenAmount >= 0, "Token amount must be greater than zero");
        require(_token == tokenAddress, "Not a valid token");
        
        uint TokenID = autoID.current();
        uint allowance = IERC20(_token).allowance(msg.sender, address(this));
        require(allowance >= _tokenAmount, "amount must be equal or less than allowance");
        IERC20(_token).transferFrom(msg.sender, address(this), _tokenAmount);
        RLCRecieveToken memory t = RLCRecieveToken(TokenID, msg.sender, _tokenAmount, block.timestamp);
        totalAmount[msg.sender] += _tokenAmount;
        incomingTokens[TokenID] = t;
        incomingTokenAddresses[msg.sender] = TokenID;
        autoID.increment();
    }
    function ownerTokenWithdraw(address destinationAddress) public onlyOwner{
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(destinationAddress,balance);
    }

    function ownerCurrencyWithdraw (address destinationAddress) public onlyOwner{
        payable(destinationAddress).transfer(address(this).balance);
    }

    function getTokenBalance() public view returns(uint256){
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function getCurrencyBalance() public view returns(uint256){
        return address(this).balance;
    } 
    uint tokenID;
        address senderAddress;
        uint tokenAmount;
        uint dateTime;
    function getinvestmentList(uint limit) public view returns(RLCRecieveToken[] memory){
        uint256 numberOfExistingTokens = autoID.current();
        RLCRecieveToken[] memory tokensArray = new RLCRecieveToken[](numberOfExistingTokens);
        for (uint256 x = 0; x < numberOfExistingTokens; x++) {
            tokensArray[x].tokenID = incomingTokens[x].tokenID;
            tokensArray[x].senderAddress = incomingTokens[x].senderAddress;
            tokensArray[x].tokenAmount = incomingTokens[x].tokenAmount;
            tokensArray[x].dateTime = incomingTokens[x].dateTime;
        }
        return tokensArray;
    }
    function setToken(address token) public onlyOwner{
        tokenAddress = token;
    }


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

}