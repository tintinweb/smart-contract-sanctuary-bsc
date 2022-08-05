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

        
    }


    function recieveTokens(address _token, uint256 _tokenAmount) public{
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
    function getTotalListCount() public view returns(uint256){
        return autoID.current();
    }
   
    function getinvestmentList(uint256 page , uint256 size) public view returns(RLCRecieveToken[] memory){
        uint256 ToSkip = page*size;  //to skip
        uint256 count = 0 ; 
        uint256 EndAt=autoID.current()>ToSkip+size?ToSkip+size:autoID.current();
        require(ToSkip<autoID.current(), "Overflow Page");
        require(EndAt>ToSkip,"Overflow page");
        RLCRecieveToken[] memory tokensArray = new RLCRecieveToken[](EndAt-ToSkip);
        for (uint256 i = ToSkip ; i < EndAt; i++) {
            tokensArray[count].tokenID = incomingTokens[i].tokenID;
            tokensArray[count].senderAddress = incomingTokens[i].senderAddress;
            tokensArray[count].tokenAmount = incomingTokens[i].tokenAmount;
            tokensArray[count].dateTime = incomingTokens[i].dateTime;
            count++;
        }
        return tokensArray;
    }
    function setToken(address token) public onlyOwner{
        tokenAddress = token;
    }
    function getToken() public view returns(address){
        return tokenAddress;
    }


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

}