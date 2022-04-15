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
        uint256 maxPurchaseAmountInBUSD;
        // How much he already bought
        uint256 alreadyPurcheasedInBUSD;

        uint256 fipiTokenPurcheased;

        uint256 fipiTokenClaimed;

        bool refparticipant;
    }

    event Bought(address indexed account, uint256 indexed amount);
    event Claimed(address indexed account, uint256 indexed amount);

    uint256 public tokenBUSDPrize;
    uint256 public divisor;
    address payable public _BNBReciever;

    uint256 public tolalTokenSold; 
    uint256 public tolalBUSDRaised; 
    uint256 public privateSaleStartDate; 
    uint256 public hardCap; 
    
    //in case something did not work as failsafe
    bool public isWhiteListActive = true;
    bool public isPresaleActive = true;

    function disableWhitelist() external onlyOwner {
        isWhiteListActive = false;
    }


    //uint256[] internal releaseDates = [1646136000,1648814400,1651406400,1654084800,1656676800];
    uint256[10] public releaseDates;
    uint256 public tgeDate;

    address payable public _BurnWallet = payable(0x000000000000000000000000000000000000dEaD);

    IERC20 public fiPiToken;
    IERC20 public busd;
    
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
            listingDateTimestamp = listingDateTimestamp.add(2592000);
            releaseDates[i] = listingDateTimestamp;
        }
    }

    mapping(address => Participant) private participants;


    function setTokenAdress(address _fipiToken) external onlyOwner {
        fiPiToken = IERC20(_fipiToken);
    }

    function addParticipant(address user, uint256 maxPurchaseAmount, bool isReferalActive) external onlyOwner {
        require(user != address(0));
        participants[user].maxPurchaseAmountInBUSD = maxPurchaseAmount;
        participants[user].refparticipant = isReferalActive;
    }

    function addParticipantBatch(address[] memory _addresses, uint256 maxPurchaseAmount) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++){
            participants[_addresses[i]].maxPurchaseAmountInBUSD = maxPurchaseAmount;
        }
    }

    function revokeParticipant(address user) external onlyOwner {
        require(user != address(0));
        participants[user].maxPurchaseAmountInBUSD = 0;
    }

    function disablePresale() external onlyOwner {
        isPresaleActive = false;
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

    function isWhitelisted(address account) external view returns (bool){
        Participant storage participant = participants[account];
        return participant.maxPurchaseAmountInBUSD > 0;
    }

    function bnbInPrivateSaleSpend(address account) external view returns (uint256){
        Participant storage participant = participants[account];
        return participant.alreadyPurcheasedInBUSD;
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


    function _getTokenAmount(uint256 _busdAmount) internal view returns (uint256) {
        return _busdAmount / tokenBUSDPrize * divisor / (10**9);
    }

    constructor(uint256 _hardcap, uint256 _privateSaleStartDate, address _busd) {
        busd = IERC20(_busd);
        _BNBReciever = payable(_msgSender());
        //its 0,06 so we need to divide by 100 later on
        tokenBUSDPrize = 6;
        divisor = 100;
        hardCap = _hardcap; //hardcap 200 BNB IN WEI
        //Wed, 5 Jan 2022 15:00:00 GMT - 1641394800
        privateSaleStartDate = _privateSaleStartDate;
    } 

    function getRefLink() external {
        Participant storage participant = participants[msg.sender];
        require(msg.sender != address(0));
        require(participant.maxPurchaseAmountInBUSD > 0, "Only whitelisted wallets can get reflink");
        participant.refparticipant = true;
    }

    


    function buyTokens(uint256 _amount, address _referrer) external 
    {
        //lets see if someone is on participants list
        Participant storage participant = participants[msg.sender];
        //if whitelist is already disabled and someon is not on the list we can add him with default value 1500 busd as max buy
        if(isWhiteListActive == false && participant.maxPurchaseAmountInBUSD == 0){
            participant.maxPurchaseAmountInBUSD = 1500 * 10**18;
        }
        //all validations
        require(msg.sender != address(0));
        require(_amount >= 50 * 10**18, "50 BUSD is minimum contribution");
        require(block.timestamp > privateSaleStartDate, "Private sale has not started yet!");
        require(isPresaleActive == true, "Private sale has ended!");
        require(tolalBUSDRaised.add(_amount) <= hardCap, "Hardcap exceeded");
        require(participant.maxPurchaseAmountInBUSD > 0, "You are not on whitelist");
        require(participant.alreadyPurcheasedInBUSD.add(_amount) <= participant.maxPurchaseAmountInBUSD, "You already bought your limit");
        uint256 allowance = busd.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check the token allowance");


        uint256 tokenPurcheased = _getTokenAmount(_amount);
        uint256 tokenToRefferer = 0;


        //if someone pass refferer and refferer declared participation both get extra 10% tokens
        if (_referrer != address(0) && participants[_referrer].refparticipant == true) 
        {
            tokenToRefferer = tokenPurcheased.div(10);
        }

        busd.transferFrom(msg.sender, address(this), _amount);
        
        tolalTokenSold = tolalTokenSold.add(tokenPurcheased);
        tolalBUSDRaised = tolalBUSDRaised.add(_amount);
        participant.alreadyPurcheasedInBUSD = participant.alreadyPurcheasedInBUSD.add(_amount);


        if(tokenToRefferer > 0){
            tokenPurcheased = tokenPurcheased.add(tokenToRefferer);
            participants[_referrer].fipiTokenPurcheased = participants[_referrer].fipiTokenPurcheased.add(tokenToRefferer);
        }
        participant.fipiTokenPurcheased = participant.fipiTokenPurcheased.add(tokenPurcheased);

        emit Bought(msg.sender, _amount);
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
        uint256 tokenClaimable = participant.fipiTokenPurcheased.mul(3).div(10);

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

}