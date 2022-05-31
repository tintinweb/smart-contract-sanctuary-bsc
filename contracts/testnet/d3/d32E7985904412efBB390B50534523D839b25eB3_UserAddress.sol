/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

//SPDX-License-Identifier: UNLICENSED

  pragma solidity ^0.8.0;

    library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
      if (a == 0) {
        return 0;
      }
      uint256 c = a * b;
      assert(c / a == b);
      return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
     
      uint256 c = a / b;
     
      return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a); 
      return c;
    }
  }


  contract UserAddress{

 modifier onlyOwner {
      require(msg.sender==owner," Ownable function call!");
      _;
    }
   
  
  address public owner=msg.sender;
  address  [] public userAddress;
  uint256  [] public userAmount;
  uint256 public roivalue;
  uint256  Roi_Plan_Valid = 2592000;
 
  

  


  struct  Roi{
    uint256 amount;
    uint256  timestamp;
    
  } 
  

  
    mapping(address => uint256) public UserData;
    mapping(address => Roi) public rois;
    
    mapping(address => uint256) public TotalRoiGenrated ;
    uint256  public CheckPoint; 
    mapping(address => uint256) public userCheckPoint;
    uint256 public Set_Roi=5;  
    mapping(address  => uint256) public SetRoi;
    uint256 divider =100;   

    event user_detail(address user_address,  uint256 user_amount );
   

    function UserInfo( address _userAddress  , uint256 _userAmount ) public{
 
       userAddress.push(_userAddress);
        userAmount.push(_userAmount);
        emit user_detail(_userAddress, _userAmount);
         UserData[_userAddress]=_userAmount;
         rois[_userAddress] = Roi(_userAmount,block.timestamp);

}


  function getRoi(address user) public view  returns   (uint256 totalset) {
    

    uint256 dif;
    uint256 amount = rois[user].amount;
    uint256 expiry = rois[user].timestamp+365 days; 
    uint256 share = (Set_Roi*amount)/(divider)*1e18;
      share = share/Roi_Plan_Valid;
      totalset=share;

      if(userCheckPoint[msg.sender]!=0 && expiry >= block.timestamp){

          dif =block.timestamp -CheckPoint;
          totalset =totalset*dif;
          return totalset;


      }else if( expiry >= block.timestamp){
        dif = block.timestamp - rois[user].timestamp;
           totalset = totalset*dif;
           return totalset;

      }


  }

  function harvestToken() public {
     uint256 hold=getRoi(msg.sender);
     payable(msg.sender).transfer(hold);
     userCheckPoint[msg.sender]=block.timestamp; 
        
  }


 
receive () external payable {}

}