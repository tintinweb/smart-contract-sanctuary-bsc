// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7.0;

import "./IERC721.sol";
import "./IERC165.sol";

import "./IERC20.sol";

contract FlokiNFTStakingBNB {

    IERC721 nftContract;

    IERC20 flokiRewardToken;

    address private _adminAddress;

    uint public olympiaStakingRate = 0.15 ether;
    uint  public arnoldStakingRate = 0.07 ether;
    uint public trenStakingRate = 0.04 ether;
    uint public  zyzzStakingRate = 0.07 ether;
    uint public olympiaCoinRate = 60000 * ( 10 ** 18 );
    uint public arnoldStakingCoinRate  = 30000 * ( 10 ** 18 );
    uint public trenStakingCoinRate = 10000 *( 10 ** 18 );
    uint public zyzzStakingCoinRate = 30000 * ( 10 ** 18 );
    uint public  mininumStakingDays = 30;

    bool public isStakingActive;

    constructor(address nftAddress, address tokenAddress, address adminAddress){
        nftContract  = IERC721(nftAddress);
        flokiRewardToken = IERC20(tokenAddress);
        _adminAddress = adminAddress;
        isStakingActive = true;
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

         if(tokenId >= 0 && tokenId <  300){
                return 0;
            }
            else if (tokenId >= 300 && tokenId < 900){
                return 1;
            }
            else if (tokenId >= 900 && tokenId < 1100){
                return 2;
            }
            else if(tokenId >=1100 && tokenId < 1300){
                return 3;
            }
            else if (tokenId >= 1300 && tokenId < 1900){
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
        else if (groupId == 3){
           canNFtBeStaked = true;

        }
        else if (groupId == 0){
            canNFtBeStaked = true;
        }
        else if(groupId  == 2){
            canNFtBeStaked = true;
        }

        return canNFtBeStaked;
        
    }


    function calculateRewards(uint tokenId) public view  returns (uint) {
        uint groupId = getNFTGroupId(tokenId);
        uint rewardRate;
        if(groupId == 5){
            if (isNFTRewardBNB[tokenId]){
             rewardRate = olympiaStakingRate;
            }
            else{
                rewardRate = olympiaCoinRate;
            }
        }
        else if (groupId == 3){
            if(isNFTRewardBNB[tokenId]){
            rewardRate = arnoldStakingRate;
            }
            else{
                rewardRate = arnoldStakingCoinRate;
            }
        }
        else if (groupId == 0){
            if(isNFTRewardBNB[tokenId]){
              rewardRate = trenStakingRate;
            }
            else{
                rewardRate = trenStakingCoinRate;
            }
        }
        else if(groupId  == 2){
            if(isNFTRewardBNB[tokenId]){
                 rewardRate = zyzzStakingRate;
            }
            else{
                rewardRate = zyzzStakingCoinRate;
            }
        }

        uint timeSpentStaking = block.timestamp -  timeNftWasStaked[tokenId];
        uint numberOfDaysStaked = timeSpentStaking / 60;
        uint timeDurationForStaking = nftStakingPeroid[tokenId];
        uint reward = numberOfDaysStaked * rewardRate / timeDurationForStaking ;
        return reward ;
    }

    function UnstakeAndClaimRewards(uint nftTokenId) public  {
        bool isUserOwnerOfNft =  originalOwnerOfNft[nftTokenId] == msg.sender;
        uint timeSpentStaking = block.timestamp -  timeNftWasStaked[nftTokenId];
        uint numberOfDaysStaked = timeSpentStaking / 60;
        require(isUserOwnerOfNft, "Not Owner of Nft");
        require(isNftStaked[nftTokenId] == true, "Can't Unstake an nft that is not staked ");
        require(numberOfDaysStaked > 0 , "NFT Can't be Unstaked Less than 24 HRS of Staking");
        require(isNftStaked[nftTokenId] == true, "Cannot Unstake an NFT that is not staked" );
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
            flokiRewardToken.transfer(addressToRecievePayment, stakingreward);
        }


        originalOwnerOfNft[nftTokenId] = address(0);

        nftContract.transferFrom(address(this), msg.sender, nftTokenId);

    }


    function ChangeOlympiaStakingRate(uint newRate) public{
        require(msg.sender == _adminAddress, "Not Authorized");
        olympiaStakingRate = newRate;
    }

    function ChangeOlympiaCoinStakingRate(uint newRate) public{
        require(msg.sender == _adminAddress, "Not Authorized");
        olympiaCoinRate = newRate ;
    }

    function ChangeArnoldStakingRate(uint newRate) public{
        require(msg.sender == _adminAddress, "Not Authorized");
        arnoldStakingRate = newRate;
    }
    
    function ChangeArnoldCoinStakingRate(uint newRate) public{
        require(msg.sender == _adminAddress, "Not Authorized");
        arnoldStakingCoinRate = newRate;
    }

    function ChangeTrenStakingRate(uint newRate) public{
      require(msg.sender == _adminAddress, "Not Authorized");
        trenStakingRate = newRate;
    }

    function ChangeTrenCoinStakingRate(uint newRate) public{
      require(msg.sender == _adminAddress, "Not Authorized");
        trenStakingCoinRate = newRate;
    }

    function ChangeZyzzStakingRate(uint newRate) public{
      require(msg.sender == _adminAddress, "Not Authorized");
        zyzzStakingRate = newRate;
    }

    function ChangeZyzzCoinStakingRate(uint newRate) public{
      require(msg.sender == _adminAddress, "Not Authorized");
        zyzzStakingRate = newRate;
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


    function pauseStaking() public {
      require(msg.sender == _adminAddress, "Not Authorized");
      isStakingActive = false;
    }

    function resumeStaking() public {
      require(msg.sender == _adminAddress, "Not Authorized");
      isStakingActive = true;
    }
}