// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./RebaseToken.sol";
import "./SafeMath.sol";
import "./INFTLocker.sol";

contract rebasewithpool is RebaseToken{
    using SafeMath for uint256;


    event rewardsclaimed(address investor, uint256 amount);


    address private  _wbnb = 0x6cfB4Daf6b2AbbfE7c0db97F0013bfB76E43D276;
    address private _strbusdlp;
    address private NFTvalidatorContract = 0x883Bb7B20C6a8959B5e272c13C0dC5746d5f5bBE; // Game market place NFT contract for NFT validationa nd locking; 

//////////////////////////////////////////////////////////////////////////////////////////////
///////////// Initial Pools Setup ////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
    //uint256 private constant intialpoollimit = 75000*10**DECIMALS;
    uint256 private goldNFTlimit = 409550*10**DECIMALS;
    uint256 private silverNFTlimit = 6500*10**DECIMALS;
    uint256 private bronzeNFTlimit = 1300*10**DECIMALS;
    uint256 private topstrBusdlimit = 13000*10**DECIMALS;
    uint256 private wbnblimit = 3250*10**DECIMALS;
    uint256 private partnershipWallets = 10000*10**DECIMALS;
    uint256 private priceofgoldNFT = 800 *10**DECIMALS;
    uint256 private priceofsilverNFT = 320 *10 **DECIMALS;
    uint256 private priceofbronzeNFT = 150*10**DECIMALS;
    uint256 private wbnbclaimed =0;
    uint256 private topstrBusdclaimed = 0 ;
    uint256 private goldNftclaimed =0 ;
    uint256 private silverNftclaimed = 0 ; 
    uint256 private bronzeNftclaimed = 0 ;
    bool private ispoolInitiated = false;  
    uint256 private poolduration;
    uint256 private topstrBusdrewardperminute;
    uint256 private wbnbrewardsperminute;
    uint256 private goldNFTapy = 12;
    uint256 private silverNFTapy = 5;
    uint256 private bronzeNFTapy = 2;
    uint256 private wbnbapy = 3;
    uint256 private topstrBusdapy =5;
    uint256 private afterpoolapy = 3; 

// This struct is used during the pool. 
    struct assetInvestment{
        address userAddress;
        address tokenAddress;
        uint256 amount;
        uint256 totaltransferedRewards;
        uint256 timeofstake;
        uint256 lastclaimtime;
    }

// NFT staking struct 
    struct nftInvestment {
        address userAddress;
        uint256 tokenId; 
        uint catagory;
        uint256 totaltransferedRewards;
        uint256 timeofstake;
        uint256 lastclaimtime;
    }

// This will be used after the pool is ended.
    struct strLpInvestment {
        address userAddress;
        uint256 amount;
        uint256 totaltransferedRewards;
        uint256 timeofstake;
        uint256 lastclaimtime;
    }
// ENUM of Player NFt catagories

    enum nftCatagory {Bronze, Silver, Gold}

    address[] private tokeninvestors;
    mapping (bytes32 => assetInvestment) public assetInvestments;
    mapping (bytes32 => strLpInvestment) public lpInvestments;
    mapping (bytes32 => nftInvestment) public nftInvestments;
///////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////LP Setup//////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

    address private lpaddress;
    uint256 private stakinglpapy;

    constructor (string memory tname, string memory tsymbol, address nftValidator) RebaseToken(tname,tsymbol){
        NFTvalidatorContract= nftValidator;
    }

    // function setLpstaking(address pair,uint lpApy) public {
    //     lpaddress = pair;
    //     stakinglpapy= lpApy;
    // }

    // function to start the Genesis Pool of the token
    function setstarbusdAddress(address starbusd ) public onlyOwner{
        _strbusdlp = starbusd;
    }

    function setWBNBAddress(address wbnb) public onlyOwner{
        _wbnb= wbnb;
    }
    function startPool(uint numberofdays) public onlyOwner{
        poolduration = block.timestamp +(numberofdays * 1 days);
        ispoolInitiated = true;
    }

    function getpoolRemainingTime() public view returns(uint256 totalhours){
        return totalhours = (poolduration-block.timestamp).div(1 hours);
    }
    // Get Key to store Investments
    function getPrivateUniqueKey(address contractAddress, address userAddress) private pure returns (bytes32){
        return keccak256(abi.encodePacked(contractAddress, userAddress));
    }
    function getNftUniqueKey(address userAddress, uint256 tokenId) private pure returns(bytes32){
        return keccak256(abi.encodePacked(userAddress, tokenId));
    }

    function getInvestment(bytes32 uniqueKey) private view returns (assetInvestment memory){
        return assetInvestments[uniqueKey];
    }
    function getnftInvestment(bytes32 uniqueKey) private view returns (nftInvestment memory){
        return nftInvestments[uniqueKey];
    }

    function getLpInvestment(bytes32 uniqueKey) private view returns(strLpInvestment memory){
        return lpInvestments[uniqueKey];
    }    

    function updateInvestment(assetInvestment memory investment, bytes32 uniqueKey ) private returns (assetInvestment memory){
        assetInvestments[uniqueKey] = investment;

        return investment;
    }
    function updateNftInvestments(nftInvestment memory nftinvestment, bytes32 uniqueKey) private returns (nftInvestment memory){
        nftInvestments[uniqueKey] = nftinvestment;
        return nftinvestment;
    }

    function updateLpInvestment(strLpInvestment memory investment, bytes32 uniqueKey ) private returns (strLpInvestment memory){
        lpInvestments[uniqueKey] = investment;

        return investment;
    }

    function setNFTValidator(address nftContract) public onlyOwner{
        NFTvalidatorContract = nftContract;
    }
    function stakeNFTpool (uint256 tokenid, uint8 tokencatagory) public {
        require(ispoolInitiated,"ICO not yet started");
        require (block.timestamp<poolduration, "Genesis Pool ended");
        require (tokencatagory>=uint(nftCatagory.Bronze)&&tokencatagory<=uint(nftCatagory.Gold),"Invalid Token Catagory");
        if(tokencatagory == uint(nftCatagory.Gold)){
            require (goldNftclaimed<goldNFTlimit,"Gold NFT Pool is depleted"); 
        }
        else if(tokencatagory == uint(nftCatagory.Silver)) {
            require(silverNftclaimed < silverNFTlimit, "Silver NFT pool is depleted");
        }
        else{
            require (bronzeNftclaimed < bronzeNFTlimit, " Bronze NFT pool is depleted");
        }
        
        bytes32 uniqueKey = getNftUniqueKey(msg.sender, tokenid);
        nftInvestment memory nftinv = getnftInvestment(uniqueKey);
        require (nftinv.tokenId==0,"This token is already staked");
        INFTLocker(NFTvalidatorContract)._lockNft(tokenid);
        nftinv.userAddress = msg.sender;
        nftinv.tokenId = tokenid;
        nftinv.totaltransferedRewards = 0;
        nftinv.timeofstake = block.timestamp;
        nftinv.lastclaimtime = block.timestamp;
        nftinv.catagory= tokencatagory;

        updateNftInvestments(nftinv,uniqueKey);
    }
    function staketokenspool(address tokenaddress, uint256 amount) public{
        require(ispoolInitiated,"ICO not yet started");
        require (block.timestamp<poolduration, "Genesis Pool ended");
        require (amount > 0 , "Amount cannot be Zero");
        require (tokenaddress==_wbnb|| tokenaddress == _strbusdlp,"Invalid Token");
        if(tokenaddress == _wbnb)        {
            require (wbnbclaimed < wbnblimit, "This pool is depleted" );
        }
        else{
            require (topstrBusdclaimed < topstrBusdlimit, "This pool is depleted"); 
        }

        bytes32 uniqueKey = getPrivateUniqueKey(tokenaddress, msg.sender);
        assetInvestment memory investment = getInvestment(uniqueKey);

        IERC20(tokenaddress).transferFrom(msg.sender, address(this), amount);

        if(investment.amount == 0)
        {
            investment.userAddress= msg.sender;
            investment.tokenAddress=tokenaddress;
            investment.amount= amount;
            investment.totaltransferedRewards = 0; 
            investment.timeofstake= block.timestamp;
            investment.lastclaimtime = block.timestamp;
        }
        else
        {
            claimRewards(tokenaddress);
            investment.userAddress= msg.sender;
            investment.tokenAddress=tokenaddress;
            investment.amount += amount; 
        }

        updateInvestment(investment, uniqueKey);

    }

    function stakeStarLp(uint256 amount) public {
        require (IERC20(_strbusdlp).allowance(msg.sender,address(this))>=amount,"Please Approve the required amount of Star tokens");
        require (amount>0, "amount cannot be 0");
        require (ispoolInitiated&&block.timestamp>poolduration,"Cannot Stake As ICO is still running or not intiated yet");

        bytes32 uniqueKey = getPrivateUniqueKey(_strbusdlp, msg.sender);
        strLpInvestment memory investment = getLpInvestment(uniqueKey);

        IERC20(_strbusdlp).transferFrom(msg.sender, address(this), amount);

         if(investment.amount == 0)
        {
            investment.userAddress= msg.sender;
            investment.amount= amount;
            investment.totaltransferedRewards = 0; 
            investment.timeofstake= block.timestamp;
            investment.lastclaimtime = block.timestamp;
        }
        else
        {
            //claimRewards(tokenaddress);
            investment.userAddress= msg.sender;
            investment.amount += amount; 
        }

        updateLpInvestment(investment, uniqueKey);
    }

    function getEarnedRewardstoken(address tokenAddress, address investor) public view returns (uint256 rewards){
        require (tokenAddress==_wbnb|| tokenAddress == _strbusdlp,"Invalid Token");
       if(tokenAddress== _strbusdlp)
       { 
            return  calculateRewards(tokenAddress, investor, topstrBusdapy);
       }
       else
       {
            return calculateRewards(tokenAddress, investor, wbnbapy);
       }

    }
    function getLpEarnedRewardstoken(address investor) public view returns (uint256 rewards){
        require (investor != address(0), "invalid address"); 
        return  calculateLpRewards(investor , afterpoolapy);
    }

    function getNftEarnedRewards(uint256 tokenid, address investor) public view returns(uint256 rewards){
        return calculateNftRewards(tokenid, investor);
    }

    function claimRewards(address tokenAddress) public {
        require (tokenAddress==_wbnb|| tokenAddress == _strbusdlp,"Invalid Token");
        bytes32 uniqueKey = getPrivateUniqueKey(tokenAddress, msg.sender);
        assetInvestment memory investment = getInvestment(uniqueKey);
        uint256 timenow = block.timestamp;
        uint256 numofminutes = (timenow-investment.lastclaimtime).div(1 minutes);
        //require (numofminutes >= 1,"Rewards are distributed every minute");
        if(numofminutes>=1)
        {
            uint256 rewards=1;
            if(tokenAddress== lpaddress){ 
                rewards = calculateRewards(tokenAddress, msg.sender, topstrBusdapy);
                topstrBusdclaimed +=rewards;
        }
        else{
                rewards = calculateRewards(tokenAddress, msg.sender, wbnbapy);
                wbnbclaimed +=rewards;
        }
            uint256 dingValue = rewards.mul(_dingsPerFragment);
            _transfer(address(this),msg.sender,dingValue);
            investment.lastclaimtime=block.timestamp;
            investment.totaltransferedRewards +=rewards;
            updateInvestment(investment, uniqueKey);
            emit rewardsclaimed(investment.userAddress, rewards);
        }
    }

    function claimLpRewards() public {
        bytes32 uniqueKey = getPrivateUniqueKey(_strbusdlp, msg.sender);
        strLpInvestment memory investment = getLpInvestment(uniqueKey);
        uint256 timenow = block.timestamp;
        uint256 numofminutes = (timenow-investment.lastclaimtime).div(1 minutes);
        //require (numofminutes >= 1,"Rewards are distributed every minute");
        if(numofminutes>=1)
        {
            uint256 rewards=1;
            rewards = calculateLpRewards(msg.sender, afterpoolapy);
            uint256 dingValue = rewards.mul(_dingsPerFragment);
            _transfer(address(this),msg.sender,dingValue);
            investment.lastclaimtime=block.timestamp;
            investment.totaltransferedRewards +=rewards;
            updateLpInvestment(investment, uniqueKey);
            emit rewardsclaimed(investment.userAddress, rewards);
        }
    }

    function claimNFTRewards(uint256 tokenId) public {
        bytes32 uniqueKey = getNftUniqueKey(msg.sender,tokenId);
        nftInvestment memory nftinv = getnftInvestment(uniqueKey);
        require(nftinv.tokenId !=0, "Invalid Token Id");
        uint256 rewards = 1;
        rewards = calculateNftRewards(nftinv.tokenId, msg.sender);
        if(rewards >0)
        {
            uint256 dingValue = rewards.mul(_dingsPerFragment);
            _transfer(address(this),msg.sender,dingValue);
            if(nftinv.catagory == uint(nftCatagory.Gold)){
                goldNftclaimed+=rewards; 
            }
            else if(nftinv.catagory == uint(nftCatagory.Silver)) {
                silverNftclaimed+=rewards; 
            }
            else{
                bronzeNftclaimed+=rewards; 
            }
            nftinv.lastclaimtime=block.timestamp;
            nftinv.totaltransferedRewards +=rewards;
            updateNftInvestments(nftinv, uniqueKey);
            emit rewardsclaimed(nftinv.userAddress, rewards);
        }

    }
    function calculateNftRewards(uint256 tokenId, address investor) private view returns(uint256 rewards){
        bytes32 uniqueKey = getNftUniqueKey(investor,tokenId);
        nftInvestment memory nftinv = getnftInvestment(uniqueKey);
        uint256 timenow = block.timestamp;

        uint256 numofminutes = (timenow-nftinv.lastclaimtime).div(1 minutes);
        //require (numofminutes >= 1,"Rewards are distributed every minute");
        if(numofminutes<1)
        {
            return 0;
        }
        if(nftinv.catagory == uint(nftCatagory.Bronze)){
            return ((priceofbronzeNFT.mul(bronzeNFTapy)).div(100))*numofminutes;
        }
        else if(nftinv.catagory == uint(nftCatagory.Silver)){
            return ((priceofsilverNFT.mul(silverNFTapy)).div(100))*numofminutes;
        }
        else if(nftinv.catagory == uint(nftCatagory.Gold)){
            return ((priceofgoldNFT.mul(goldNFTapy)).div(100))*numofminutes;
        }
        revert ("Wrong Catagory");

    }
    function calculateRewards(address tokenAddress, address investor, uint256 apy) private view returns(uint256 rewards){

        bytes32 uniqueKey = getPrivateUniqueKey(tokenAddress, investor);
        assetInvestment memory investment = getInvestment(uniqueKey);

        uint256 timenow = block.timestamp;

        uint256 numofminutes = (timenow-investment.lastclaimtime).div(1 minutes);
        //require (numofminutes >= 1,"Rewards are distributed every minute");
        if(numofminutes<1)
        {
            return 0;
        }
        return ((investment.amount.mul(apy)).div(100))*numofminutes;
    }
    function calculateLpRewards(address investor, uint256 apy) private view returns(uint256 rewards){

        bytes32 uniqueKey = getPrivateUniqueKey(_strbusdlp, investor);
        strLpInvestment memory investment = getLpInvestment(uniqueKey);

        uint256 timenow = block.timestamp;

        uint256 numofminutes = (timenow-investment.lastclaimtime).div(1 minutes);
        //require (numofminutes >= 1,"Rewards are distributed every minute");
        if(numofminutes<1)
        {
            return 0;
        }
        return ((investment.amount.mul(apy)).div(100))*numofminutes;
    }

    function withdrawInvestmentpool(address tokenAddress, uint256 withdrawAmount) public {

        bytes32 uniqueKey = getPrivateUniqueKey(tokenAddress, msg.sender);
        assetInvestment memory investment = getInvestment(uniqueKey);
        require (withdrawAmount <= investment.amount, "Invalid amount");
        claimRewards(tokenAddress);
        IERC20(tokenAddress).transfer(msg.sender,withdrawAmount);
        investment.amount -= withdrawAmount;
        updateInvestment(investment, uniqueKey);
    }

    function withdrawInvestmentLP(uint256 amount) public {
        bytes32 uniqueKey = getPrivateUniqueKey(_strbusdlp, msg.sender);
        strLpInvestment memory investment = getLpInvestment(uniqueKey);
        require (investment.amount >=amount, "Invalid Amount");

        claimLpRewards();

        IERC20(_strbusdlp).transfer(msg.sender,amount);
        investment.amount -=amount;
        updateLpInvestment(investment, uniqueKey);
    }

    function withdrawNFT(uint256 tokenId) public {
        bytes32 uniqueKey = getNftUniqueKey(msg.sender, tokenId);
        nftInvestment memory nftinv = getnftInvestment(uniqueKey);
        require(nftinv.tokenId !=0, "Invalid Token Id");
        claimNFTRewards(tokenId);

        INFTLocker(NFTvalidatorContract)._unlockNft(tokenId);
        nftinv.tokenId=0;
        updateNftInvestments(nftinv, uniqueKey);
    }

    function getInvestment(address tokenAddress, address investorAddress) public view returns(assetInvestment memory){
        
        bytes32 uniqueKey = getPrivateUniqueKey(tokenAddress, investorAddress);
        return getInvestment(uniqueKey);

    }

    function getLpInvestment () public view returns (strLpInvestment memory){
        bytes32 uniqueKey = getPrivateUniqueKey(_strbusdlp, msg.sender);
        return getLpInvestment(uniqueKey);
    }
}