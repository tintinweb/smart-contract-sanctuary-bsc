/**
 *Submitted for verification at BscScan.com on 2022-08-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// File: Disbursement.sol


pragma solidity ^0.8.0;


// NO users can withdraw anytime they have $50 in their accounts. 
// The only difference between the two contracts is users in contract
//  A can only withdraw until they receive a specific amount. 
//  In contract B users can withdraw anytime they have $50 in their accounts forever. 
//  There is no cap on them at all.

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view  returns (uint8);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract disbursement1 {
    AggregatorV3Interface internal priceFeed;
    address public Admin;
    mapping(address=>uint256) public withdrawable;
    mapping(address=>uint256) public withdrawn;
    mapping(address=>uint256) public owed;
    address[] public userArray;
    mapping(address=>uint256) public userArrayIndex;
    uint256 public Index;
    uint256 public TotalOwed;
    uint256 public threshold = 0.2 ether;
    uint256 public withdrawFee = 5; 
     
    constructor(){
        Admin = 0x0f3De10966a4372fE2f90E2C30ae66ce3F02804C;//0x77547F859Ca0F1114c25Db094Bb0f682dD47512D;//
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
    }

    modifier onlyAdmin() {
        require(msg.sender == Admin, "Ownable: caller is not the owner");
        _;
    } 

    function addOwed(address _user, uint256 amount) public onlyAdmin {

        owed[_user] += amount;
        userArray.push(_user);
        userArrayIndex[_user]=Index;
        Index++;
        TotalOwed+=amount;
    }


    function addOwedBulk(address[] memory _user, uint256[] memory amounts) public payable onlyAdmin {

        for(uint256 i = 0 ; i < _user.length ; i ++){
            addOwed(_user[i],amounts[i]);
        }
    }

    IERC20 token = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);

    function addFunds(uint256 amount) public onlyAdmin {
        require(token.allowance(msg.sender,address(this))>=amount,"Insufficient allowance");
        token.transferFrom(msg.sender,address(this),amount);
        uint256 remain = amount; 
        for(uint256 i = 0 ; i < userArray.length ; i ++){
            if(owed[userArray[i]]<=threshold && remain>=owed[userArray[i]]){
            withdrawable[userArray[i]]=owed[userArray[i]];
            }

        }

        for(uint256 i = 0 ; i < userArray.length ; i ++){
            if(owed[userArray[i]]>threshold){
               withdrawable[userArray[i]]+=remain*owed[userArray[i]]/TotalOwed;
            }
 
        }
    }



    function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price/100000000;
    }

    function withdraw() public {
        uint256 amount = Withdrawable();
        // uint256 dollar = amount;
//        require(dollar>= 50 ether,"Amount is less than 50USD");
        withdrawn[msg.sender]+=amount;
        uint256 fee = amount*withdrawFee/100;
        uint256 balance = amount-fee;
        token.transfer(msg.sender,balance);
        token.transfer(Admin,fee);


    }

    function Withdrawable() public view returns(uint256){
        return withdrawable[msg.sender]-withdrawn[msg.sender];
    }


    function balanceRemaining() public view returns(uint256){
        return owed[msg.sender]-withdrawn[msg.sender];
    }

    function withdrawbyAdmin() public onlyAdmin{
        payable(Admin).transfer(address(this).balance);
    }


}