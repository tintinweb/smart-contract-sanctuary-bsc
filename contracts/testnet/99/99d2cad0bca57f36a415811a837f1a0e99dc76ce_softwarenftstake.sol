/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

 

     function getBankOwner() external view returns (address);

    

    function mint(uint256 amount) external;

    function burn(uint256 amount) external;

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
interface IsoftwareNFT {
         
 struct softwareNftInfo {
        string licenseNo;
        uint256 baseValue;
        uint256 cLFIValue;
        uint256 emissionDate;
        uint256 licensePurchaseDate;
        uint256 licenseExpiryDate;
        uint256 baseTokenEmmission;
        string fileUri;
        address nftHolder;
        bool isAvailable;
    }


         function safeMint( string calldata _licenseNo , 
                        uint256 _emissionDate ,
                        uint256 _baseValue,
                        uint256 _baseTokenEmmission  , 
                        string calldata imageUri_,
                        string calldata metadataUri_) external;

                         function updateInfo (uint256 id ,string calldata _licenseNo , uint256 _emissionDate , uint256 _baseValue,uint256 _baseTokenEmmission  ,uint256 _licenseExpiryDate, string calldata imageUri_,string calldata metadataUri_) external;

                          function tokenURI(uint256 tokenId)
        external
        view
        returns (string memory);

         function burnNft(uint256 id  ) external;
         function getUriList(address _address) external view returns (string [] memory);
          function getSoftwareNftInfo(uint256 _tokenId) external view returns(softwareNftInfo memory);
            function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function getBaseTokenEmmission(uint256 _tokenId) external view returns(uint256);
    function getBaseValue(uint256 _tokenId) external view returns(uint256);
    function getTotalSupply() external view returns(uint256);
    function getlicensePurchaseDate(uint256 _tokenId) external view returns(uint256);
     function getlicenseExpiryDate(uint256 _tokenId) external view returns(uint256);
     function getEmmissionDate(uint256 _tokenId) external view returns(uint256);
     function getcLFIValue(uint256 _tokenId) external view returns(uint256);
     function getlicenseNum(uint256 _tokenId) external view returns(string memory);
     function getMintCount() external view returns (uint256);
     function totalSupply() external view returns (uint256);


 }


contract softwarenftstake {
    IERC20 public CLFI;
    IERC20 public LFI;
    IsoftwareNFT public nftContract;
    address public owner;
    uint256 public contractCount;
    mapping(address=>uint256) stakedAmount;
    uint256 public p1 = 2;
    uint256 public p2 = 1;
    bool public isTimeBasedReward = true;

    struct stakingContract {
        uint256 contractNumber;
        uint256 nftNumber;
        uint256 emissionDate;
        uint256 baseValue;
        uint256 baseTokenEmission;
        uint256 mimValue;
        address staker;
        bool active;       
    }

    struct rewardDetails {
        uint256 tokenId;
        uint256 rewardStart;
        uint256 lastRewardClaim;
        uint256 rewardEnd;
        uint256 currentReward;
        uint256 claimedReward;
        uint256 softwarePurchaseTime;
        uint256 softwareExpiryTime;
    }

 

    mapping(string => uint256) clfiRequiredPerSoftware;  //how much clfi required for each software
    mapping(address => stakingContract) public contractOfStaking; //each users contract details
    mapping(address => mapping(uint256 => rewardDetails)) public stakingRewards; //each  users reward details per contract 
    mapping(address => uint256[]) public contractsJoinedByAddress; // users joined contract's identification number.
    mapping(uint256=>stakingContract) stakingContractDetails;
    mapping(address =>uint256) public ownerNFTCount;
    mapping(address=>uint256) stakingCount; // mapping of count per user stsking

    constructor(
        address _clfi,
        address _lfi,
        address _nftContract
    ) {
        CLFI = IERC20(_clfi);
        LFI = IERC20(_lfi);
       nftContract = IsoftwareNFT(_nftContract);
        owner = msg.sender;
    }
    function viewClfiValue(uint256 _tokenId) public view returns(uint256){
        return nftContract.getcLFIValue(_tokenId);
    }

    function stake(uint256 _tokenId ) public {
  
        require(
        CLFI.balanceOf(msg.sender) >= nftContract.getcLFIValue(_tokenId),
        "not enough amount for staking");      
    nftContract.transferFrom(msg.sender, address(this), _tokenId);
        CLFI.transferFrom(
            msg.sender,
            address(this),
            nftContract.getcLFIValue(_tokenId)
        );
        uint256 index = ownerNFTCount[msg.sender];
        stakingContractDetails[index] = stakingContract(
           contractCount,
          _tokenId,
          nftContract.getEmmissionDate(_tokenId),
          nftContract.getBaseValue(_tokenId),
          nftContract.getBaseTokenEmmission(_tokenId),
          mimValue(msg.sender ,_tokenId),
          msg.sender,
          true
         );
         
          stakingRewards[msg.sender][index] =  rewardDetails(_tokenId,block.timestamp,0,block.timestamp + 15 minutes,0,0,block.number,0);
          ownerNFTCount[msg.sender]++;
        contractCount++;
      
    }

    function ownerofNFTCount( address _add) public view returns(uint256){

    }

function mintProduction(address _add,uint256 _tokenId) public view returns(uint256 ){
uint256 baseTokenEmission =(stakingContractDetails[_tokenId].baseTokenEmission);
uint256 _mimValue = mimValue(_add ,_tokenId)  ;
uint256 mintProductionValue;
if(p2>p1){
mintProductionValue = (baseTokenEmission * ( _mimValue - carryingCapacity())  * p2/p1 / 10) ;

}
else{
mintProductionValue =( baseTokenEmission * ( _mimValue - carryingCapacity()) / 10);
}
    return (mintProductionValue);
}

function ShowmintProduction(address _add, uint256 _tokenId) public view returns(uint256 ,uint256){
uint256 baseTokenEmission =(stakingContractDetails[_tokenId].baseTokenEmission);
uint256 _mimValue = mimValue(_add ,_tokenId)  ;
uint256 mintProductionValue;
if(p2>p1){
mintProductionValue = (baseTokenEmission * ( _mimValue - carryingCapacity())  * p2/p1  / 10);

}
else{
mintProductionValue = (baseTokenEmission * ( _mimValue - carryingCapacity())  / 10) ;
}
    return (mintProductionValue, baseTokenEmission);
}


    function claim(uint256 _tokenId) public {
        uint256 amount = mintProduction(msg.sender ,_tokenId);
        require(amount > 0, " amount greater than 0");
        LFI.transfer(msg.sender, amount);
    }


function setTimeBasedReward( bool  _isTimeBasedReward) public {
    require(owner==msg.sender,"NOT A OWNER");
    isTimeBasedReward =_isTimeBasedReward;
}

function setValue ( uint256 _p1 , uint256 _p2) public  {
    require(owner == msg.sender, " only owner use this");
p1 = _p1;
p2 = _p2;

}


function mimValue(address _add,uint256 _index) public view  returns(uint256 ){

uint256 _tokenId =  stakingRewards[_add][_index].tokenId;
uint256 emissionDate = nftContract.getEmmissionDate(_tokenId);
uint256 currentDate = block.timestamp  ;
uint256 diff = currentDate - emissionDate ;
uint256 cal = 0.00027778 * 10e8;
uint256 mimValue_ = nftContract.getBaseValue(_tokenId) * (10e8 - (diff * cal)) ;

return (mimValue_ );
}

function ShowMimValue(uint256 _tokenId) public view  returns(uint256 , uint256){

uint256 emissionDate = nftContract.getEmmissionDate(_tokenId);
uint256 currentDate = block.timestamp  ;
uint256 diff = currentDate - emissionDate ;
uint256 cal = 0.00027778 * 10e8;
uint256 mimValue_ = nftContract.getBaseValue(_tokenId) * (10e8 - (diff * cal)) ;

return (mimValue_ , diff);
}

function  carryingCapacity() public view returns(uint256){
    uint256 cc = (15  * ( nftContract.totalSupply() / 250000)/10**3);
     return cc;

}

function showcarryingCapacity() public view returns(uint256){
uint256 cc = (150 *100 /25 *  nftContract.totalSupply()) ;
     return cc;
}

function nftHashRate() public view returns(uint256){
    return ((3695 *  nftContract.getTotalSupply()) );

}


}