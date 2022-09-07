/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function burn(uint256 value) external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}


contract like{

 IERC20 public inrXToken;

    constructor(IERC20 _inrX) {
        
        inrXToken = _inrX;

            setAward[1].totalReward=2500000;
            setAward[1].ownerReward=75;
            setAward[1].likerReward=25;

            setAward[2].totalReward=5000000;
            setAward[2].ownerReward=75;
            setAward[2].likerReward=25;

            setAward[3].totalReward=7500000;
            setAward[3].ownerReward=75;
            setAward[3].likerReward=25;


            setAward[4].totalReward=10000000;
            setAward[4].ownerReward=75;
            setAward[4].likerReward=25;

            setAward[5].totalReward=15000000;
            setAward[5].ownerReward=75;
            setAward[5].likerReward=25;

            setAward[6].totalReward=12500000;
            setAward[6].ownerReward=75;
            setAward[6].likerReward=25;

            setAward[7].totalReward=17500000;
            setAward[7].ownerReward=75;
            setAward[7].likerReward=25;
    }


    struct videoStaged{
    
    uint256 VideoLvl1Likes;
    string Videolvl1;

    uint256 VideoLvl2Likes;
    string Videolvl2;

    uint256 VideoLvl3Likes;
    string Videolvl3;

    uint256 [] VideoLvl4Likes;
    string [] Videolvl4;

    } 


    struct SetAwardedPrice{
        uint256 totalReward;
        uint256 ownerReward;
        uint256 likerReward;
    }


    struct LikeCounts{

    address  LikedVideoOwneer;
    address [] LikerAddress;
    uint256  totalLikes;

    }
       struct Links {
       
        string [] links;
    }


    mapping(address => Links) private  usersLink;

//    mapping(string =>  videoStaged ) public VideoPerformance;

    mapping(uint256 => SetAwardedPrice) public setAward;
    mapping(uint256 => videoStaged) public PhaseLike;
    mapping (string => LikeCounts) public LikeCounted;

        function setLikes( string memory VideoLink ,address ReferedBy , uint256 PhaseDeterminer )   public {

        LikeCounted[VideoLink].LikerAddress.push(msg.sender);
        LikeCounted[VideoLink].LikedVideoOwneer=ReferedBy;
        LikeCounted[VideoLink].totalLikes++;
                // if(LikeCounted[VideoLink].totalLikes >= 5000 ) {

                            if( LikeCounted[VideoLink].totalLikes > PhaseLike[PhaseDeterminer].VideoLvl1Likes){
                                PhaseLike[PhaseDeterminer].Videolvl1= VideoLink;
                                PhaseLike[PhaseDeterminer].VideoLvl1Likes=  LikeCounted[VideoLink].totalLikes;
                            }
                            else if(LikeCounted[VideoLink].totalLikes > PhaseLike[PhaseDeterminer].VideoLvl2Likes){
                            PhaseLike[PhaseDeterminer].Videolvl2= VideoLink;
                            PhaseLike[PhaseDeterminer].VideoLvl2Likes=  LikeCounted[VideoLink].totalLikes;
                            }
                    
                            else if(LikeCounted[VideoLink].totalLikes > PhaseLike[PhaseDeterminer].VideoLvl3Likes){
                                PhaseLike[PhaseDeterminer].VideoLvl3Likes=  LikeCounted[VideoLink].totalLikes;
                                    PhaseLike[PhaseDeterminer].Videolvl3= VideoLink;

                            }

                            else if(  LikeCounted[VideoLink].totalLikes >  PhaseLike[PhaseDeterminer].VideoLvl4Likes[0] ||  LikeCounted[VideoLink].totalLikes > PhaseLike[PhaseDeterminer].VideoLvl4Likes[1] || LikeCounted[VideoLink].totalLikes > PhaseLike[PhaseDeterminer].VideoLvl4Likes[2] || LikeCounted[VideoLink].totalLikes > PhaseLike[PhaseDeterminer].VideoLvl4Likes[3] || LikeCounted[VideoLink].totalLikes > PhaseLike[PhaseDeterminer].VideoLvl4Likes[4] || LikeCounted[VideoLink].totalLikes >  PhaseLike[PhaseDeterminer].VideoLvl4Likes[5] || LikeCounted[VideoLink].totalLikes >  PhaseLike[PhaseDeterminer].VideoLvl4Likes[6]  ){
                                uint256 min;
                                uint256 setI;


                                    for( uint8 i=0; i<=6 ;i++ ){

                            if( PhaseLike[PhaseDeterminer].VideoLvl4Likes[i] == 0){
                                PhaseLike[PhaseDeterminer].Videolvl4[i]= VideoLink;
                                PhaseLike[PhaseDeterminer].VideoLvl4Likes[i]=LikeCounted[VideoLink].totalLikes ;
                            }
                        }
                             

                        for( uint8 i=0; i<=6 ;i++ ){

                        if(min > PhaseLike[PhaseDeterminer].VideoLvl4Likes[i]) {
                            min = PhaseLike[PhaseDeterminer].VideoLvl4Likes[i];
                            setI =i;

                        
                }
                        if(i== 6 ){

                        if(LikeCounted[VideoLink].totalLikes > min ){
                            PhaseLike[PhaseDeterminer].VideoLvl4Likes[setI]=LikeCounted[VideoLink].totalLikes;
                         PhaseLike[PhaseDeterminer].Videolvl4[setI]=VideoLink;
                            } 
                            }
                            }  
               }

                
}

                        function getLink(string memory _videoLink ) public view returns(address [] memory ){
                            return LikeCounted[_videoLink].LikerAddress;
                        }


                        function getTotalLinkOfPhase (uint256 _phase) public view returns(string [] memory) {
                                                    return PhaseLike[_phase].Videolvl4;
                         }


function TransferTokenOfLikepercentage( uint256 runningPhase, uint256 GetPhase , string  memory VideoUrl ) public {

    // for(uint8 i = 0;i>=LikeCounted[VideoUrl].LikerAddress.length; i++){
    //     if(msg.sender == LikeCounted[VideoUrl].LikerAddress[i]){
    //        uint256 value = ((2500000*25/100)*1e18)/LikeCounted[VideoUrl].totalLikes;
    //         inrXToken.transfer(msg.sender, value);
    
    // }
    // }

    if(runningPhase >GetPhase){
    for(uint8 i = 0;i>=LikeCounted[VideoUrl].LikerAddress.length; i++){
        if(msg.sender == LikeCounted[VideoUrl].LikerAddress[i]){
            uint256 value  = ((setAward[GetPhase].totalReward*setAward[GetPhase].likerReward/100)*1e18)/LikeCounted[VideoUrl].totalLikes;
            inrXToken.transfer(msg.sender, value);

        }
        }
}

      
 



}

  function setLink (string memory link ) external returns(bool) {
                    usersLink[msg.sender].links.push(link);
                    return true;
                }

                function getOwnerTotalLink (address VideoOf) public view returns(string [] memory) {
                    return usersLink[VideoOf].links;
                }








 receive() external payable {
       
}







}