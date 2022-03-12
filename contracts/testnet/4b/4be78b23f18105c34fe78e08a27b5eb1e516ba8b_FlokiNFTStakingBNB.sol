// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7.0;

import "./IERC721.sol";
import "./IERC165.sol";

contract FlokiNFTStakingBNB {

    IERC721 nftContract;

    address private _adminAddress;

    uint public olympiaStakingRate = 0.01 ether;
    uint  public arnoldStakingRate = 0.005 ether;
    uint public trenStakingRate = 0.002 ether;
    uint public  zyzzStakingRate = 0.06 ether;
    uint public  mininumStakingDays = 14;
    uint public  maxPerWallet = 5;

    constructor(address nftAddress, address adminAddress){
        nftContract  = IERC721(nftAddress);
        _adminAddress = adminAddress;
    }

    

    mapping(address=>uint[]) public nftsStakedByUser;
    mapping(uint =>bool) public isNftStaked;
    mapping(uint=>uint) public timeNftWasStaked;
    mapping(uint=>uint) public nftStakingPeroid;
    mapping(uint=>address) public originalOwnerOfNft;

    


    function stakeNft(uint nftTokenId, uint stakingPeriod )public{
        bool isUserOwnerOfNft =  nftContract.ownerOf(nftTokenId) == msg.sender;
        bool canNFtBeStaked = checkIfNFTCanBeStaked(nftTokenId);
        require(isNftStaked[nftTokenId] == false, "Token Currently Staked in Contract");
        require(stakingPeriod > 0 , "Invalid Staking Period");
        require(isUserOwnerOfNft, "Not Owner of Nft");
        require(stakingPeriod >= mininumStakingDays, "Can't stake less than the minuim staking days");
        require(nftsStakedByUser[msg.sender].length < maxPerWallet, "Can't Stake More than the Max Per Wallet" );
        require( canNFtBeStaked == true, "This NFT Can't be staked " );
        nftContract.transferFrom(msg.sender, address(this), nftTokenId);
        timeNftWasStaked[nftTokenId] = block.timestamp;
        isNftStaked[nftTokenId] = true;
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
            rewardRate = olympiaStakingRate;
        }
        else if (groupId == 3){
            rewardRate = arnoldStakingRate;
        }
        else if (groupId == 0){
            rewardRate = trenStakingRate;
        }
        else if(groupId  == 2){
            rewardRate = zyzzStakingRate;
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

        addressToRecievePayment.transfer(stakingreward);

        originalOwnerOfNft[nftTokenId] = address(0);

        nftContract.transferFrom(address(this), msg.sender, nftTokenId);

    }


    function ChangeOlympiaStakingRate(uint newRate) public{
        require(msg.sender == _adminAddress, "Not Authorized");
        olympiaStakingRate = newRate;
    }
    function ChangeArnoldStakingRate(uint newRate) public{
        require(msg.sender == _adminAddress, "Not Authorized");
        arnoldStakingRate = newRate;
    }
    function ChangeTrenStakingRate(uint newRate) public{
      require(msg.sender == _adminAddress, "Not Authorized");
        trenStakingRate = newRate;
    }

    function ChangeZyzzStakingRate(uint newRate) public{
      require(msg.sender == _adminAddress, "Not Authorized");
        zyzzStakingRate = newRate;
    }

    function ChangeMinimuimStakingDays(uint stakingDays) public{
        require(msg.sender == _adminAddress, "Not Authorized");
        mininumStakingDays = stakingDays;
    }

    function recieveEther() public payable  returns (uint){
        return 2;
    }

    function changeMaxPerWallet(uint newMaxPerWallet) public  {
        require(msg.sender == _adminAddress, "Not Authorized");
        maxPerWallet = newMaxPerWallet;
    }

    function changeAdminAddress(address newAdminAddress) public {
        require(msg.sender == _adminAddress, "Not Authorized");
        _adminAddress = newAdminAddress;
    }

}