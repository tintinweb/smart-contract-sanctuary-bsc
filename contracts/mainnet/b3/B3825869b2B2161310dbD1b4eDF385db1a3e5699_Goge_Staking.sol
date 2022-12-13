// SPDX-License-Identifier: MIT
    pragma solidity ^0.8.4;

    import "IERC721.sol";
    import "IERC721Receiver.sol";
    import "IERC20.sol";
    import "Ownable.sol";
    import "IERC721Enumerable.sol";
    
    contract Goge_Staking is Ownable, IERC721Receiver{

    IERC20 public token;
    IERC721 public nft;

    uint256[] public rewardsReceived;
    address[] public nft_awards_contracts;
    uint256[] public nft_awards_tokenIDs;
        
    uint256 public decimalNumber = 9;
    uint256 public rewardsAmount = 1;
    uint256 public rewardsCircle = 0;
    uint256 public rewardsRate = 86400;
    uint256 public countOfOverallStakers;

    // Contract Addresses
    address _nft_Contract = 0x9c61924d3685B321449D1d150a44A76531f7601A;
    address _token_Contract = 0xb2AF03a018bFD19d9F784909bD1C6D6DD42950b1;

    // Mapping 
    mapping(address => mapping(uint256 => uint256)) public tokenStakedTime;
    mapping(address => mapping(uint256 => uint256)) public tokenStakedDuration;
    mapping(uint256 => address) public stakedTokenOwner;
    mapping(address => uint256[]) public stakedTokens;
    mapping(address => uint256) public countofMyStakedTokens;
    mapping(address => uint256) public totalRewardReleased;
    mapping(uint256 => address) public stakers;  


    constructor(){
    nft = IERC721(_nft_Contract);
    token = IERC20(_token_Contract);
    }

    function stakeNFT(uint256 _tokenID) public {

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
        
         rewardRelease = (tokenStakedDuration[msg.sender][_tokenID] * rewardsAmount * 10 ** decimalNumber) / rewardsRate;
           
        if(token.balanceOf(address(this)) >= rewardRelease){
            token.transfer(msg.sender,rewardRelease);
            tokenStakedTime[msg.sender][_tokenID] = block.timestamp;

            totalRewardReleased[msg.sender] = totalRewardReleased[msg.sender] + rewardRelease;
            
            }
        }
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
    
    function tokenWithdrawal() public onlyOwner{
    token.transfer(msg.sender,token.balanceOf(address(this)));

    }
    
  
    function withdrawal() public onlyOwner {

    (bool main, ) = payable(owner()).call{value: address(this).balance}("");
    require(main);

    }
}