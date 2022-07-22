// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./Counters.sol";
import "./IERC20.sol";
import "./Ownable.sol";


contract RLCICOReciever is Ownable{
    
    using Counters for Counters.Counter;
    Counters.Counter autoID;



    struct RLCRecieveToken{
        uint tokenID;
        address senderAddress;
        uint tokenAmount;
        uint dateTime;
        uint tier;
    }

    mapping(uint => RLCRecieveToken) incomingTokens;
    mapping(address => uint256) incomingTokenAddresses;
    mapping(uint => uint256) tierMaxAmount;
    mapping(address => uint256) totalAmount;
    address private tokenAddress;

        constructor(address allowedToken){
        tokenAddress = allowedToken;
        tierMaxAmount[1] = 1500*10**18;
        tierMaxAmount[2] = 900*10**18;
        tierMaxAmount[3] = 750*10**18;
        tierMaxAmount[4] = 600*10**18;
        tierMaxAmount[5] = 525*10**18;
        tierMaxAmount[6] = 450*10**18;
        tierMaxAmount[7] = 375*10**18;
        tierMaxAmount[8] = 300*10**18;
        tierMaxAmount[9] = 225*10**18;
        tierMaxAmount[10] = 150*10**18;
    }

    function testMethod(uint256 number) public {
        for(uint256 i = 0 ; i < number ; i++){
            recieveTokens(tokenAddress, 10*10**18, 1);
        }
    }

    function setTierAmount(uint tierNumber, uint tierLimit) public onlyOwner{
        require(tierMaxAmount[tierNumber] != tierLimit, "Tier Limit Already Exist");
        tierMaxAmount[tierNumber] = tierLimit;
    }
    function getTierAmount(uint tierNumber) public view onlyOwner returns(uint limit){
        return tierMaxAmount[tierNumber];
    }
    
    function recieveTokens(address _token, uint _tokenAmount, uint tier) public{
        require(_tokenAmount >= 0, "Token amount must be greater than zero");
        require(_token == tokenAddress, "Not a valid token");
        

        require(totalAmount[msg.sender]+_tokenAmount <= tierMaxAmount[tier], "Not allowed to invest beyond your tier limit");
        uint TokenID = autoID.current();
        //uint allowance = IERC20(_token).allowance(msg.sender, address(this));
        //require(allowance >= _tokenAmount, "amount must be equal or less than allowance");
        //IERC20(_token).transferFrom(msg.sender, address(this), _tokenAmount);
        RLCRecieveToken memory t = RLCRecieveToken(TokenID, msg.sender, _tokenAmount, block.timestamp, tier);
        totalAmount[msg.sender] += _tokenAmount;
        incomingTokens[TokenID] = t;
        incomingTokenAddresses[msg.sender] = TokenID;
        autoID.increment();
    }
    function ownerWithdraw(address destinationAddress) public onlyOwner{
        uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(destinationAddress,balance);
    }

    function getBalance() public view returns(uint256){
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function getinvestmentList() public view returns(RLCRecieveToken[] memory){
        uint256 numberOfExistingTokens = autoID.current();
        RLCRecieveToken[] memory tokensArray = new RLCRecieveToken[](numberOfExistingTokens);
        for (uint256 x = 0; x < numberOfExistingTokens; x++) {
            tokensArray[x] = incomingTokens[x];
        }
        return tokensArray;
    }



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

}