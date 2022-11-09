/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

 interface IERC20 {
function totalSupply() external view returns (uint256);
function balanceOf(address account) external view returns (uint256);
function transfer(address recipient, uint256 amount) external returns (bool);
function allowance(address owner, address spender) external view returns (uint256);   
function approve(address spender, uint256 amount) external returns (bool);
function transferFrom( address sender, address recipient,uint256 amount) external returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner,address indexed spender,uint256 value);
}


contract MotatoPurchasing {

    
    uint256  motatoLevel1 = 10;
    uint256  motatoLevel2 = 20;
    uint256  motatoLevel3 = 30;
    uint256  motatoLevel4 = 40;
    uint256  motatoLevel5 = 50;
    address  owner = 0xa24aB8E014C4C02c837D25c0Ec4b8540CC94cA87;
    address   _name ;
    IERC20 public token;
    struct userDetail {
        uint256 UserRefId;
        uint256 userTokenBuyed;
        uint256 userCurrentLevel;
        mapping(address => mapping(uint256 => uint256)) AmountPurchasedInLevel;
    }

    struct triangleLeveldetail {
        uint256 triangleCurrentLevel;
        mapping(uint256 => address) CurrentTriangleDetail;
    }



    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;


    mapping(uint256 => userDetail) public userInfo;

    modifier onlyOwner {
    require(msg.sender == owner , "Only Owner Can Perform This Action");
    _;
        }

   constructor(IERC20 _token){
               
               token=_token;
   }     


    function BuyToken(uint256 _amount)payable public  {

    //   uint256  userToPay = 0.01*1e18 ;
    //   require(msg.value >= 10000000000000000 ,"Please check transaction");
      token.transfer(msg.sender,10000000000000000);
                token.approve(msg.sender,_amount);
       token.transferFrom(owner,msg.sender,_amount);

       

    }
      




    receive() external payable {
        
    }
}