// SPDX-License-Identifier: MIT
    pragma solidity ^0.8.4;

    import "IERC721.sol";
    import "IERC721Receiver.sol";
    import "IERC20.sol";
    import "Ownable.sol";
    import "IERC721Enumerable.sol";
    
    contract PROJECT_EXO_PET is Ownable, IERC721Receiver{

    IERC20 public token;
    IERC721 public nft;

    uint256[] public rewardsReceived;
    address[] public nft_awards_contracts;
    uint256[] public nft_awards_tokenIDs;
        
    uint256 public bnbAwards = 0.03 ether;

    uint256 public decimalNumber = 9;
    uint256 public rewardsAmount = 1;
    uint256 public rewardsCircle = 86400;
    uint256 public rewardsRate = 86400;
    uint256 public countOfOverallStakers;

    uint256 public rarityCount = 250;
    uint256 public rarityMode = 0;
    uint256 public awardTransferOutCount = 0;

    uint256 public actionFigure1Count = 0;
    uint256 public actionFigure2Count = 0;

    uint256 public launchTime = 1665100800; // Friday, October 7, 2022 12:00:00 AM

    // Contract Addresses
    address _nft_Contract = 0xCaF8e9D1349e58155781e4B2D35aF61cA8EFDd7d;
    address _token_Contract = 0x7D744c20ebB28fbBD2D303eb37bf0B5b7572dB5D;

    // Mapping 
    mapping(address => mapping(uint256 => uint256)) public tokenStakedTime;
    mapping(address => mapping(uint256 => uint256)) public tokenStakedDuration;
    mapping(uint256 => address) public stakedTokenOwner;
    mapping(address => uint256[]) public stakedTokens;
    mapping(address => uint256) public countofMyStakedTokens;
    mapping(address => uint256) public totalRewardReleased;
    mapping(uint256 => address) public stakers;
    mapping(uint256 => uint256) public rarityScores;
    mapping(address => uint256) public milestone;
    mapping(address => uint256) public deposit;
    mapping(address => uint256) public actionFigure;
    mapping(uint256 => address) public actionFigureList1;
    mapping(uint256 => address) public actionFigureList2;
    mapping(address => string) public eml;



    constructor(){
    nft = IERC721(_nft_Contract);
    token = IERC20(_token_Contract);
    }

    function stakeNFT(uint256 _tokenID) public {
        require(launchTime <= block.timestamp, "Not yet launched");
        require(nft.ownerOf(_tokenID) == msg.sender, "Not the owner");
        stakedTokens[msg.sender].push(_tokenID);
        countofMyStakedTokens[msg.sender]++;

        uint256 length = stakedTokens[msg.sender].length;

        if(stakedTokens[msg.sender].length != countofMyStakedTokens[msg.sender]){
            stakedTokens[msg.sender][countofMyStakedTokens[msg.sender]-1] = stakedTokens[msg.sender][length-1];
            delete stakedTokens[msg.sender][length-1];
        }
    
        stakedTokenOwner[_tokenID] = msg.sender;
        tokenStakedTime[msg.sender][_tokenID] = block.timestamp;
        nft.safeTransferFrom(msg.sender,address(this),_tokenID,"0x00");

        stakers[countOfOverallStakers] = msg.sender;    
        countOfOverallStakers++;
    }

    function batchStakeNFT(uint256[] memory _tokenIDs) public {
        
        for(uint256 x = 0; x <  _tokenIDs.length ; x++){
            stakeNFT(_tokenIDs[x]);

        }

    }
        
    function unstakeNFT(uint256 _tokenID) public {

        nft.safeTransferFrom(address(this), msg.sender, _tokenID,"0x00");
        claimRewards(_tokenID);

        delete tokenStakedTime[msg.sender][_tokenID];
        delete stakedTokenOwner[_tokenID]; 

        for(uint256 i = 0; i < countofMyStakedTokens[msg.sender]; i++){
            if(stakedTokens[msg.sender][i] == _tokenID){    
            countofMyStakedTokens[msg.sender] = countofMyStakedTokens[msg.sender] - 1;


                for(uint256 x = i; x < countofMyStakedTokens[msg.sender]; x++){                   
                stakedTokens[msg.sender][x] = stakedTokens[msg.sender][x+1];
                }

                delete stakedTokens[msg.sender][countofMyStakedTokens[msg.sender]];

                           
            }
        }
    } 

    function batchUnstakeNFT(uint256[] memory _tokenIDs) public{

        for(uint256 x = 0; x <  _tokenIDs.length ; x++){
            unstakeNFT(_tokenIDs[x]);

        }
    }

    function batchClaimRewards(uint256[] memory _tokenIDs) public {

        for(uint256 x = 0; x <  _tokenIDs.length ; x++){
            claimRewards(_tokenIDs[x]);
        }
        
    }


    function claimRewards(uint256 _tokenID) public {

        uint256 rewardRelease;

        tokenStakedDuration[msg.sender][_tokenID] = (block.timestamp - tokenStakedTime[msg.sender][_tokenID]);

        if (tokenStakedDuration[msg.sender][_tokenID] >= rewardsCircle){

            if(rarityMode == 1){

              rewardRelease = (tokenStakedDuration[msg.sender][_tokenID] * rewardsAmount * ((rarityScores[_tokenID] + rarityCount) / rarityCount) * 10 ** decimalNumber) / rewardsRate;
              } else {
              rewardRelease = (tokenStakedDuration[msg.sender][_tokenID] * rewardsAmount * 10 ** decimalNumber) / rewardsRate;
            }

        if(token.balanceOf(address(this)) >= rewardRelease){
            token.transfer(msg.sender,rewardRelease);
            tokenStakedTime[msg.sender][_tokenID] = block.timestamp;

            totalRewardReleased[msg.sender] = totalRewardReleased[msg.sender] + rewardRelease;
            
            }
        }
    }

    function awardsTransferIn(address[] calldata contractAddress, uint256[] calldata _tokenID) public onlyOwner {
    
    uint256 x;

        for (x = 0 ; x < contractAddress.length; x++){

            IERC721 nftAwards = IERC721(contractAddress[x]);
            nftAwards.safeTransferFrom(msg.sender,address(this),_tokenID[x],"0x00");
            nft_awards_contracts.push(contractAddress[x]);
            nft_awards_tokenIDs.push(_tokenID[x]);

        }

    }

    function claimAwards() public {
            
          uint256 x;

          for (x = awardTransferOutCount ; x < nft_awards_contracts.length; x++){

          IERC721 nftAwards = IERC721(nft_awards_contracts[x]);

          if(nftAwards.ownerOf(nft_awards_tokenIDs[x]) == address(this)){

          if(totalRewardReleased[msg.sender] >= 20000000000 && totalRewardReleased[msg.sender] < 40000000000 ) {
          require(milestone[msg.sender] < 1);
          milestone[msg.sender] = 1;
 
          nftAwards.safeTransferFrom(address(this),msg.sender,nft_awards_tokenIDs[x],"0x00");
          awardTransferOutCount++;
          break;

            }

          if(totalRewardReleased[msg.sender] >= 40000000000 && totalRewardReleased[msg.sender] < 60000000000 ) {
          require(milestone[msg.sender] < 2);
          milestone[msg.sender] = 2;
 
          (bool main, ) = payable(msg.sender).call{value: bnbAwards}("");
          require(main);
          break;

            }

          if(totalRewardReleased[msg.sender] >= 60000000000 && totalRewardReleased[msg.sender] < 80000000000 ) {
          require(milestone[msg.sender] < 3);
          milestone[msg.sender] = 3;
 
          nftAwards.safeTransferFrom(address(this),msg.sender,nft_awards_tokenIDs[x],"0x00");
          awardTransferOutCount++;
          break;

            }

          if(totalRewardReleased[msg.sender] >= 80000000000 && totalRewardReleased[msg.sender] < 100000000000 ) {
          require(milestone[msg.sender] < 4);
          milestone[msg.sender] = 4;
 
          (bool main, ) = payable(msg.sender).call{value: bnbAwards}("");
          require(main);
          break;

          }

          if(totalRewardReleased[msg.sender] >= 100000000000 && totalRewardReleased[msg.sender] < 120000000000 ) {
          require(milestone[msg.sender] < 5);
          milestone[msg.sender] = 5;
 
          nftAwards.safeTransferFrom(address(this),msg.sender,nft_awards_tokenIDs[x],"0x00");
          awardTransferOutCount++;
          break;

            }

          if(totalRewardReleased[msg.sender] >= 120000000000 && totalRewardReleased[msg.sender] < 150000000000 ) {
          require(milestone[msg.sender] < 6);
          milestone[msg.sender] = 6;
 
          (bool main, ) = payable(msg.sender).call{value: bnbAwards}("");
          require(main);
          break;

            }

          if(totalRewardReleased[msg.sender] >= 150000000000 && totalRewardReleased[msg.sender] < 180000000000 ) {
          require(milestone[msg.sender] < 7);
          milestone[msg.sender] = 7;
 
          nftAwards.safeTransferFrom(address(this),msg.sender,nft_awards_tokenIDs[x],"0x00");
          awardTransferOutCount++;
          break;

            }

          if(totalRewardReleased[msg.sender] >= 180000000000 && totalRewardReleased[msg.sender] < 200000000000 ) {
          require(milestone[msg.sender] < 8);
          milestone[msg.sender] = 8;
 
          (bool main, ) = payable(msg.sender).call{value: bnbAwards}("");
          require(main);
          break;

            }

          if(totalRewardReleased[msg.sender] >= 200000000000 && totalRewardReleased[msg.sender] < 250000000000 ) {
          require(milestone[msg.sender] < 9);
          milestone[msg.sender] = 9;
 
          nftAwards.safeTransferFrom(address(this),msg.sender,nft_awards_tokenIDs[x],"0x00");
          awardTransferOutCount++;
          break;

            }

          if(totalRewardReleased[msg.sender] >= 250000000000 && totalRewardReleased[msg.sender] < 270000000000 ) {
          require(milestone[msg.sender] < 10);
          milestone[msg.sender] = 10;
 
          actionFigureList1[actionFigure1Count] = msg.sender;
          actionFigure1Count++;

          break;

            }

          if(totalRewardReleased[msg.sender] >= 270000000000 && totalRewardReleased[msg.sender] < 290000000000 ) {
          require(milestone[msg.sender] < 11);
          milestone[msg.sender] = 11;

          nftAwards.safeTransferFrom(address(this),msg.sender,nft_awards_tokenIDs[x],"0x00");
          awardTransferOutCount++;
          break;

            }

          if(totalRewardReleased[msg.sender] >= 290000000000 && totalRewardReleased[msg.sender] < 310000000000 ) {
          require(milestone[msg.sender] < 12);
          milestone[msg.sender] = 12;
 
          (bool main, ) = payable(msg.sender).call{value: bnbAwards}("");
          require(main);
          break;

          }

          if(totalRewardReleased[msg.sender] >= 310000000000 && totalRewardReleased[msg.sender] < 330000000000 ) {
          require(milestone[msg.sender] < 13);
          milestone[msg.sender] = 13;
 
          nftAwards.safeTransferFrom(address(this),msg.sender,nft_awards_tokenIDs[x],"0x00");
          awardTransferOutCount++;
          break;

            }

          if(totalRewardReleased[msg.sender] >= 330000000000 && totalRewardReleased[msg.sender] < 350000000000 ) {
          require(milestone[msg.sender] < 14);
          milestone[msg.sender] = 14;
 
          (bool main, ) = payable(msg.sender).call{value: bnbAwards}("");
          require(main);
          break;

            }

          if(totalRewardReleased[msg.sender] >= 350000000000 && totalRewardReleased[msg.sender] < 370000000000 ) {
          require(milestone[msg.sender] < 15);
          milestone[msg.sender] = 15;
 
          nftAwards.safeTransferFrom(address(this),msg.sender,nft_awards_tokenIDs[x],"0x00");
          awardTransferOutCount++;
          break;

            }

          if(totalRewardReleased[msg.sender] >= 370000000000 && totalRewardReleased[msg.sender] < 390000000000 ) {
          require(milestone[msg.sender] < 16);
          milestone[msg.sender] = 16;
 
          (bool main, ) = payable(msg.sender).call{value: bnbAwards}("");
          require(main);
          break;

            }

          if(totalRewardReleased[msg.sender] >= 390000000000 && totalRewardReleased[msg.sender] < 420000000000 ) {
          require(milestone[msg.sender] < 17);  
          milestone[msg.sender] = 17;
 
          nftAwards.safeTransferFrom(address(this),msg.sender,nft_awards_tokenIDs[x],"0x00");
          awardTransferOutCount++;
          break;

            }

          if(totalRewardReleased[msg.sender] >= 420000000000 && totalRewardReleased[msg.sender] < 450000000000 ) {
          require(milestone[msg.sender] < 18);
          milestone[msg.sender] = 18;
 
          (bool main, ) = payable(msg.sender).call{value: bnbAwards}("");
          require(main);
          break;

          }

          if(totalRewardReleased[msg.sender] >= 450000000000 && totalRewardReleased[msg.sender] < 500000000000 ) {
          require(milestone[msg.sender] < 19);  
          milestone[msg.sender] = 19;
 
          nftAwards.safeTransferFrom(address(this),msg.sender,nft_awards_tokenIDs[x],"0x00");
          awardTransferOutCount++;
          break;

          }

          if(totalRewardReleased[msg.sender] >= 500000000000 ) {
          require(milestone[msg.sender] < 20);
          milestone[msg.sender] = 20;

          actionFigureList2[actionFigure2Count] = msg.sender;
          actionFigure2Count++;

          break;

          }

          } 

        }
    
    }


    function rarityInjecter(uint256[] calldata _tokenId, uint256[] calldata _rarityScore) public onlyOwner {

        require(_tokenId.length == _rarityScore.length);

        uint256 x;

        for (x = 0 ; x < _tokenId.length; x++){
            rarityScores[_tokenId[x]] = _rarityScore[x];
        }
    }

    function register(string memory _eml) public{

      eml[msg.sender] = _eml;
    }


  
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4){
    return this.onERC721Received.selector;
    }

    function setNFTContract(address _nftContract) public onlyOwner{
    nft = IERC721(_nftContract);

    }
  
    function setTokenContract(address _tokenContract) public onlyOwner{
    token = IERC20(_tokenContract);

    }
    
    function setDecimalNumber(uint256 _decimalNumber) public onlyOwner{
    decimalNumber = _decimalNumber;

    }

    function setRewardsCircle(uint256 _rewardsCircle) public onlyOwner{
    rewardsCircle = _rewardsCircle;

    }

    function setRewardsAmount(uint256 _rewardsAmount) public onlyOwner{
    rewardsAmount = _rewardsAmount;

    }

    function setRewardsRate(uint256 _rewardsRate) public onlyOwner{
    rewardsRate = _rewardsRate;

    }
    
    function setRarityMode(uint256 _rarityMode) public onlyOwner{
    rarityMode = _rarityMode;

    }

    function setbnbAwards(uint256 _bnbAwards) public onlyOwner{
    bnbAwards = _bnbAwards;

    }
    
    function setRarityCount(uint256 _rarityCount) public onlyOwner{
    rarityCount = _rarityCount;

    }

    function tokenWithdrawal() public onlyOwner{
    token.transfer(msg.sender,token.balanceOf(address(this)));

    }
       
    function depositToContract() public payable onlyOwner{
    require(msg.value > 0);
    deposit[msg.sender] = msg.value;
    //payable(address(this)).transfer(msg.value);

    }

    
    function setLaunchTime(uint256 _launchTime) public onlyOwner {
        launchTime = _launchTime;
    }

    function withdrawal() public onlyOwner {

    (bool main, ) = payable(owner()).call{value: address(this).balance}("");
    require(main);

    }
}