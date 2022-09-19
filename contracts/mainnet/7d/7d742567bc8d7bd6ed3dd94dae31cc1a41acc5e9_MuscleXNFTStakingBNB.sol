// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7.0;

import "./Ownable.sol";


import "./IERC721.sol";
import "./IERC20.sol";

contract MuscleXNFTStakingBNB is Ownable  {

    IERC721 nftContract;

    IERC20 rewardToken;

    address private _adminAddress;

    event Received(address, uint);


    uint public XStakingRate = 0.15 ether;
    uint  public batXStakingRate = 0.07 ether;
    uint public  captainXStakingRate = 0.07 ether;
    uint public xStakingCoinRate = 60000 * ( 10 ** 18 );
    uint public batXStakingCoinRate  = 30000 * ( 10 ** 18 );
    uint public captainXStakingCoinRate = 30000 * ( 10 ** 18 );
    uint public  mininumStakingDays = 30;

    bool public isStakingActive;

    constructor(address nftAddress, address tokenAddress, address adminAddress){
        nftContract  = IERC721(nftAddress);
        rewardToken = IERC20(tokenAddress);
        _adminAddress = adminAddress;
        isStakingActive = true;
    }


    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    

    mapping(address=>uint[]) public nftsStakedByUser;
    mapping(uint =>bool) public isNftStaked;
    mapping(uint=>uint) public timeNftWasStaked;
    mapping(uint=>uint) public nftStakingPeroid;
    mapping(uint=>address) public originalOwnerOfNft;
    mapping(uint=>bool) public isNFTRewardBNB;

    


    function stakeNft(uint nftTokenId, uint stakingPeriod, bool rewardWithBNB )public{
        bool isUserOwnerOfNft =  nftContract.ownerOf(nftTokenId) == msg.sender;
        bool canNFtBeStaked = checkIfNFTCanBeStaked(nftTokenId);
        require(isNftStaked[nftTokenId] == false, "Token Currently Staked in Contract");
        require(isStakingActive == true, "Staking not currently active, try again later");
        require(stakingPeriod > 0 , "Invalid Staking Period");
        require(isUserOwnerOfNft, "Not Owner of Nft");
        require(stakingPeriod >= mininumStakingDays, "Can't stake less than the minuim staking days");
        require( canNFtBeStaked == true, "This NFT Can't be staked " );
        nftContract.transferFrom(msg.sender, address(this), nftTokenId);
        timeNftWasStaked[nftTokenId] = block.timestamp;
        isNftStaked[nftTokenId] = true;
        isNFTRewardBNB[nftTokenId] = rewardWithBNB;
        uint[] storage currentNftsStaked = nftsStakedByUser[msg.sender];
        currentNftsStaked.push(nftTokenId);
        nftStakingPeroid[nftTokenId] = stakingPeriod;
        originalOwnerOfNft[nftTokenId] = msg.sender;
    }

    function checkUserNftStaked(address userAddress) public view returns (uint[] memory) {
            return nftsStakedByUser[userAddress];
    }

    function getNFTGroupId(uint tokenId) public pure returns (uint) {

         if(tokenId >= 0 && tokenId <  800){
                return 0;
            }
            else if (tokenId >= 800 && tokenId < 1600){
                return 1;
            }
            else if (tokenId >= 1600 && tokenId < 2000){
                return 2;
            }
            else if(tokenId >=2000 && tokenId < 2300){
                return 3;
            }
            else if (tokenId >= 2300 && tokenId < 2400){
                return 4;
            }else{
                return 5;
            }
    }

    function checkIfNFTCanBeStaked(uint tokenId) public pure  returns (bool){
        uint groupId = getNFTGroupId(tokenId);
        bool canNFtBeStaked = false;
        if(groupId == 5){
            canNFtBeStaked = true;
        }
        else if (groupId == 4){
           canNFtBeStaked = true;

        }
        else if (groupId == 3){
            canNFtBeStaked = true;
        }

        return canNFtBeStaked;
        
    }


    function calculateRewards(uint tokenId) public view  returns (uint) {
        uint groupId = getNFTGroupId(tokenId);
        uint rewardRate;
        if(groupId == 5){
            if (isNFTRewardBNB[tokenId]){
             rewardRate = XStakingRate;
            }
            else{
                rewardRate = xStakingCoinRate;
            }
        }
        else if (groupId == 4){
            if(isNFTRewardBNB[tokenId]){
            rewardRate = batXStakingRate;
            }
            else{
                rewardRate = batXStakingCoinRate;
            }
        }
        else if(groupId  == 3){
            if(isNFTRewardBNB[tokenId]){
                 rewardRate = captainXStakingRate;
            }
            else{
                rewardRate = captainXStakingCoinRate;
            }
        }

        uint timeSpentStaking = block.timestamp -  timeNftWasStaked[tokenId];
        uint numberOfDaysStaked = timeSpentStaking / 86400;
        uint timeDurationForStaking = nftStakingPeroid[tokenId];
        uint reward = numberOfDaysStaked * rewardRate / timeDurationForStaking ;
        return reward ;
    }

    function UnstakeAndClaimRewards(uint nftTokenId) public  {
        bool isUserOwnerOfNft =  originalOwnerOfNft[nftTokenId] == msg.sender;
        uint timeSpentStaking = block.timestamp -  timeNftWasStaked[nftTokenId];
        uint numberOfDaysStaked = timeSpentStaking / 86400;
        require(isUserOwnerOfNft, "Not Owner of Nft");
        require(isNftStaked[nftTokenId] == true, "Can't Unstake an nft that is not staked ");
        require(numberOfDaysStaked > 0 , "NFT Can't be Unstaked Less than 24 HRS of Staking");
        uint stakingreward = calculateRewards(nftTokenId);
        isNftStaked[nftTokenId] = false;
        timeNftWasStaked[nftTokenId] = 0;
        nftStakingPeroid[nftTokenId] = 0;

        uint[] storage previousNftsStaked = nftsStakedByUser[msg.sender];

        uint[] memory newNftsStakedList = new uint[](previousNftsStaked.length -1);
        uint newNFtListIndexer = 0;
        for (uint i=0; i < previousNftsStaked.length; i++ ){
            if(previousNftsStaked[i] != nftTokenId){
                newNftsStakedList[newNFtListIndexer] = previousNftsStaked[i];
                newNFtListIndexer++;
            }
        }

        nftsStakedByUser[msg.sender] = newNftsStakedList;

        address payable addressToRecievePayment = payable(originalOwnerOfNft[nftTokenId]);

        if(isNFTRewardBNB[nftTokenId]){
        addressToRecievePayment.transfer(stakingreward);
        }else{
            // Implement Erc20 transfer 
            rewardToken.transfer(addressToRecievePayment, stakingreward);
        }

        

        originalOwnerOfNft[nftTokenId] = address(0);

        nftContract.transferFrom(address(this), msg.sender, nftTokenId);

    }

    function EmergencyUnstake(uint nftTokenId) public {
       bool isUserOwnerOfNft =  originalOwnerOfNft[nftTokenId] == msg.sender;
       require(isNftStaked[nftTokenId] == true, "Can't Unstake an nft that is not staked ");
       require(isUserOwnerOfNft, "Not Owner of Nft");


        uint[] storage previousNftsStaked = nftsStakedByUser[msg.sender];

        uint[] memory newNftsStakedList = new uint[](previousNftsStaked.length -1);
        uint newNFtListIndexer = 0;
        for (uint i=0; i < previousNftsStaked.length; i++ ){
            if(previousNftsStaked[i] != nftTokenId){
                newNftsStakedList[newNFtListIndexer] = previousNftsStaked[i];
                newNFtListIndexer++;
            }
        }

        nftsStakedByUser[msg.sender] = newNftsStakedList;

        originalOwnerOfNft[nftTokenId] = address(0);

        isNftStaked[nftTokenId] = false;

        timeNftWasStaked[nftTokenId] = 0;

        nftStakingPeroid[nftTokenId] = 0;

        nftContract.transferFrom(address(this), msg.sender, nftTokenId);

    }


    function ChangeXStakingRate(uint newRate) public{
        require(msg.sender == _adminAddress, "Not Authorized");
        XStakingRate = newRate;
    }

    function ChangeXCoinStakingRate(uint newRate) public{
        require(msg.sender == _adminAddress, "Not Authorized");
        xStakingCoinRate = newRate ;
    }

    function ChangeBatXStakingRate(uint newRate) public{
        require(msg.sender == _adminAddress, "Not Authorized");
        batXStakingRate = newRate;
    }
    
    function ChangeBatXCoinStakingRate(uint newRate) public{
        require(msg.sender == _adminAddress, "Not Authorized");
        batXStakingCoinRate = newRate;
    }




    function ChangeCaptainXStakingRate(uint newRate) public{
      require(msg.sender == _adminAddress, "Not Authorized");
        captainXStakingRate = newRate;
    }

    function ChangeCaptainXCoinStakingRate(uint newRate) public{
      require(msg.sender == _adminAddress, "Not Authorized");
        captainXStakingCoinRate = newRate;
    }

    function ChangeMinimuimStakingDays(uint stakingDays) public{
        require(msg.sender == _adminAddress, "Not Authorized");
        mininumStakingDays = stakingDays;
    }

    function recieveBNB() public payable  returns (uint){
        return 2;
    }

    function changeAdminAddress(address newAdminAddress) public {
        require(msg.sender == _adminAddress, "Not Authorized");
        _adminAddress = newAdminAddress;
    }

    function ChangeStakingRewardToken(address newTokenAddress) public {
        require(msg.sender == _adminAddress, "Not Authorized");
        rewardToken = IERC20(newTokenAddress);
    }

    function pauseStaking() public {
      require(msg.sender == _adminAddress, "Not Authorized");
      isStakingActive = false;
    }

    function resumeStaking() public {
      require(msg.sender == _adminAddress, "Not Authorized");
      isStakingActive = true;
    }
}