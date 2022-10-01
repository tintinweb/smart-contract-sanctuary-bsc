/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface IERC20 
{
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Samos{
    address payable public devloperAddress;
    address payable public ownerWallet;
    uint256 activeMember = 1;
    uint256 lastId = 1;
     struct UserStruct {
        bool isExist;
        uint id;
        uint childCount;
        address payable userAddress;
        address payable upline;
        uint256 activeLevel;
        uint256 paymentCount;
    }

     mapping(uint => uint) public LEVEL_PRICE;
    uint256 public LAST_LEVEL= 7;
    mapping (address => UserStruct) public users;
    
    mapping(uint => address) public idToAddress;

    //events
    event regLevelEvent(address indexed user,uint userId,address referral, uint time);
    event upgradeLevelEvent(address indexed user,uint level,address referral, uint time);

    constructor(address payable ownerAddress) {

       
        ownerWallet = ownerAddress;
        LEVEL_PRICE[1] = 0.01 ether;
        LEVEL_PRICE[2] = 0.02 ether;
        LEVEL_PRICE[3] = 0.03 ether;
        LEVEL_PRICE[4] = 0.04 ether;
        LEVEL_PRICE[5] = 0.05 ether;
        LEVEL_PRICE[6] = 0.06 ether;        
        LEVEL_PRICE[7] = 0.07 ether;
       
        UserStruct memory _UserStruct;
        
        _UserStruct = UserStruct({
            isExist: true,
            id: lastId,
            childCount : 0,
            userAddress: ownerAddress,
            upline: devloperAddress,
            activeLevel: 1,
            paymentCount : 0
        });

        users[ownerAddress] = _UserStruct;
        idToAddress[lastId] = ownerAddress;
       
        emit regLevelEvent(ownerWallet,lastId, address(0), block.timestamp);
} 


function registration(address payable refAddress)public payable{
       require(users[refAddress].isExist, 'Incorrect referrer Id');
        require(!users[msg.sender].isExist, 'Already registered');
        require(msg.value != LEVEL_PRICE[1], 'Invalid amount');
        regUser(payable(msg.sender),refAddress,msg.value);
        
    }
   
    
       function regUser(address payable userAddress,address payable refAddress,uint256 amount) internal{
          
        users[msg.sender].isExist = true;

        if(users[idToAddress[activeMember]].childCount >= 2) activeMember++;

         UserStruct memory _UserStruct;
        
        _UserStruct = UserStruct({
            isExist: true,
            id: lastId++,
            childCount : 0,
            userAddress: userAddress,
            upline: refAddress,
            activeLevel: 1,
            paymentCount : 0
        });

        
        users[userAddress] = _UserStruct;
       
        idToAddress[lastId] = userAddress;

        emit regLevelEvent(userAddress,lastId,refAddress, block.timestamp);

        upgrade(userAddress,1,amount);
    }

        function upgrade(address payable userAddress, uint level,uint256 amount) internal{
       //require(msg.value == LEVEL_PRICE, 'Incorrect referrer Id');
        address payable _4thGenerationAddress = users[users[users[users[userAddress].upline].upline].upline].upline;
        //address payable _4thGenerationAddress = users[userAddress].upline;
       // address payable _4thGenerationAddress = '0xc7EDf5Ef5a04Df3b0B25dbd8016BcEA9c357eb87';
        users[_4thGenerationAddress].paymentCount++;
        if(users[_4thGenerationAddress].paymentCount == 1)
        {
               devloperAddress.transfer(amount);
            
        }
        else if(users[_4thGenerationAddress].paymentCount > 1 && users[_4thGenerationAddress].paymentCount <= 6)
        {
                _4thGenerationAddress.transfer(amount);
               
        }
        else if(users[_4thGenerationAddress].paymentCount > 6 && users[_4thGenerationAddress].paymentCount <= 16)
        {
            if(users[_4thGenerationAddress].paymentCount == 16 && level ==7)
            {
                _4thGenerationAddress.transfer(amount);
            }
            else if(users[_4thGenerationAddress].paymentCount == 16)
            {
                users[_4thGenerationAddress].activeLevel++;
                emit upgradeLevelEvent(_4thGenerationAddress,users[_4thGenerationAddress].activeLevel,users[_4thGenerationAddress].upline, block.timestamp);
                upgrade(userAddress,level,LEVEL_PRICE[level]);


            }
        }
    }
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b,"mul error");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0,"div error");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a,"sub error");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a,"add error");

        return c;
    }

}