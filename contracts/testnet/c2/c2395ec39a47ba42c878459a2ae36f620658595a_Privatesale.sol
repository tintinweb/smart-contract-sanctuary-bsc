// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./context.sol";
import './safeMath.sol';
import './IERC20.sol';

contract Privatesale is Ownable {
    using SafeMath for uint256;

    // A participant in the privatesale
    struct Participant {
        // The amount someone can buy
        uint256 maxPurchaseAmountInBNB;
        // How much he already bought
        uint256 alreadyPurcheasedInBNB;

        uint256 fipiTokenPurcheased;

        uint256 fipiTokenClaimed;

        uint256 releasesClaimed;
    }

    event Bought(address indexed account, uint256 indexed amount);
    event Claimed(address indexed account, uint256 indexed amount);

    uint256 public tokenBNBRatio; //how much tokens for one bnb
    address payable public _BNBReciever;

    uint256 public tolalTokenSold; 
    uint256 public tolalBNBRaised; 
    uint256 public wlPrealeStartDate;
    uint256 public publicPrealeStartDate; 
    uint256 public hardCap; 
    
    //in case something did not work as failsafe
    bool public isWhiteListActive = true;

    function disableWhitelist() external onlyOwner {
        isWhiteListActive = false;
    }


    //uint256[] internal releaseDates = [1646136000,1648814400,1651406400,1654084800,1656676800];
    uint256[10] public releaseDates;
    uint256 public tgeDate;
    
    address payable public _BurnWallet = payable(0x000000000000000000000000000000000000dEaD);

    IERC20 public fiPiToken;

    
    function setListingDate(uint256 listingDateTimestamp) external onlyOwner {
        
        //FLUSH EVERYTHING
        delete releaseDates;
        tgeDate = listingDateTimestamp;
        //WE RELEASE TOKENS FOR 10 MONTHS
        for(uint256 i = 0; i < 10; i++)
        {
            //30 days 2592000
            //6h for tests 21600
            //1h for tests 3600
            listingDateTimestamp = listingDateTimestamp.add(3600);
            releaseDates[i] = listingDateTimestamp;
        }
    }

    mapping(address => Participant) private participants;


    function setTokenAdress(IERC20 _fipiToken) external onlyOwner {
        fiPiToken = _fipiToken;
    }
    function addParticipant(address user, uint256 maxPurchaseAmount) external onlyOwner {
        require(user != address(0));
        participants[user].maxPurchaseAmountInBNB = maxPurchaseAmount;
    }


    function addParticipantBatch(address[] memory _addresses, uint256 maxPurchaseAmount) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) 
        {
            participants[_addresses[i]].maxPurchaseAmountInBNB = maxPurchaseAmount;
        }
    }

    function revokeParticipant(address user) external onlyOwner {
        require(user != address(0));
        participants[user].maxPurchaseAmountInBNB = 0;
    }

    function nextReleaseIn() external view returns (uint256){
        for (uint256 i = 0; i < releaseDates.length; i++) 
        {
            if (releaseDates[i] >= block.timestamp) 
            {
               return releaseDates[i];
            }
        }
        return 0;
    }

    constructor(uint256 _hardcap, uint256 _preSaleStartDate) {

        _BNBReciever = payable(_msgSender());
        tokenBNBRatio = 6666;
        hardCap = _hardcap; //hardcap 200 BNB IN WEI
        //Wed, 5 Jan 2022 15:00:00 GMT - 1641394800
        wlPrealeStartDate = _preSaleStartDate;
        publicPrealeStartDate = _preSaleStartDate.add(120);
    } 



    function claim() public
    {
        require(msg.sender != address(0));
        Participant storage participant = participants[msg.sender];

        require(participant.fipiTokenPurcheased > 0, "You did not bought anything!");

        uint256 unlockedReleasesCount = 0;

        require(tgeDate > 0, "Listing date is not yet provided!");
        require(block.timestamp > tgeDate, "Token is not yet listed");

        //we start from 30% at tge
        uint256 tokenClaimable = participant.fipiTokenPurcheased.mul(4).div(10);

        //70% is vested
        uint256 restTokensVested = participant.fipiTokenPurcheased.sub(tokenClaimable);

        //now we check how many relesaes is done
        for (uint256 i = 0; i < releaseDates.length; i++) 
        {
            if (releaseDates[i] <= block.timestamp) 
            {
               unlockedReleasesCount ++;
            }
        }


        //we add everything released to initial 30%
        tokenClaimable = tokenClaimable.add(restTokensVested.mul(unlockedReleasesCount).div(10));

        require(tokenClaimable > participant.fipiTokenClaimed, "You have nothing left to claim wait for next release.");

        uint256 tokenToBeSendNow = tokenClaimable.sub(participant.fipiTokenClaimed);
        
        fiPiToken.transfer(msg.sender, tokenToBeSendNow);
        participant.fipiTokenClaimed = tokenClaimable;

        emit Claimed(msg.sender, tokenToBeSendNow);

    }

    function buy() payable public 
    {
        uint256 amountTobuy = msg.value;
        require(amountTobuy >= 100000000000000000, "0.1 BNB is minimum contribution");
        require(block.timestamp > wlPrealeStartDate, "Whitelist presale has not started yet!");
        require(tolalBNBRaised.add(amountTobuy) <= hardCap, "Hardcap exceeded");


        require(msg.sender != address(0));
        Participant storage participant = participants[msg.sender];
        
        if((isWhiteListActive == false || block.timestamp > publicPrealeStartDate) && participant.maxPurchaseAmountInBNB == 0){
            participant.maxPurchaseAmountInBNB = 10000000000000000000;
        }

        require(participant.maxPurchaseAmountInBNB > 0, "You are not on whitelist, wait for public presale");
        require(participant.alreadyPurcheasedInBNB.add(amountTobuy) <= participant.maxPurchaseAmountInBNB, "You already bought your limit");
        
        uint256 numTokens = amountTobuy.div(10 ** 9).mul(tokenBNBRatio);
       
        tolalTokenSold = tolalTokenSold.add(numTokens);
        tolalBNBRaised = tolalBNBRaised.add(amountTobuy);
        participant.alreadyPurcheasedInBNB = participant.alreadyPurcheasedInBNB.add(amountTobuy);
        participant.fipiTokenPurcheased = participant.fipiTokenPurcheased.add(numTokens);

        emit Bought(msg.sender, msg.value);
    }   



    function isWhitelisted(address account) external view returns (bool){

        if(isWhiteListActive == true){
            return true;
        }

        Participant storage participant = participants[account];
        return participant.maxPurchaseAmountInBNB > 0;
    }

    function bnbInPrivateSaleSpend(address account) external view returns (uint256){
        Participant storage participant = participants[account];
        return participant.alreadyPurcheasedInBNB;
    }

    function yourFiPiTokens(address account) external view returns (uint256){
        Participant storage participant = participants[account];
        return participant.fipiTokenPurcheased;
    }


    function burnLeftTokens() external onlyOwner {
        fiPiToken.transfer(_BurnWallet, fiPiToken.balanceOf(address(this)));
    }
    
    function withDrawBNB() public {
        require(_msgSender() == _BNBReciever, "Only the bnb reciever can use this function!");
        _BNBReciever.transfer(address(this).balance);
    }

    

}