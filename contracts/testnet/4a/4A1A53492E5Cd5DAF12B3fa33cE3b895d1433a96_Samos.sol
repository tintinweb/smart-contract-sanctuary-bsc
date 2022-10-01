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

contract Samos {
   // address payable public devloperAddress;
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
        LEVEL_PRICE[1] = 0.001 ether;
        LEVEL_PRICE[2] = 0.002 ether;
        LEVEL_PRICE[3] = 0.003 ether;
        LEVEL_PRICE[4] = 0.004 ether;
        LEVEL_PRICE[5] = 0.005 ether;
        LEVEL_PRICE[6] = 0.006 ether;        
        LEVEL_PRICE[7] = 0.007 ether;
       
        UserStruct memory _UserStruct;
        
        _UserStruct = UserStruct({
            isExist: true,
            id: lastId,
            childCount : 0,
            userAddress: ownerAddress,
            upline: ownerAddress,
            activeLevel: 1,
            paymentCount : 0
        });

        users[ownerAddress] = _UserStruct;
        idToAddress[lastId] = ownerAddress;
       
        emit regLevelEvent(ownerWallet,lastId, ownerAddress, block.timestamp);
} 


    function registration(address payable refAddress)public payable {
       require(users[refAddress].isExist, 'Incorrect referrer Id');
        require(!users[msg.sender].isExist, 'Already registered');
        require(msg.value == LEVEL_PRICE[1], 'Invalid amount');
        regUser(payable(msg.sender),refAddress);
        
    }
   
    
       function regUser(address payable userAddress,address payable refAddress) internal{
          
        users[msg.sender].isExist = true;

        if(users[idToAddress[activeMember]].childCount >= 2) activeMember++;

         UserStruct memory _UserStruct;
        
        lastId++;
        _UserStruct = UserStruct({
            isExist: true,
            id: lastId,
            childCount : 0,
            userAddress: userAddress,
            upline: refAddress,
            activeLevel: 1,
            paymentCount : 0
        });

        
        users[userAddress] = _UserStruct;
       
        idToAddress[lastId] = userAddress;

        users[idToAddress[activeMember]].childCount++;
        emit regLevelEvent(userAddress,lastId,refAddress, block.timestamp);

        upgrade(userAddress,1);
    }

        function upgrade(address payable userAddress, uint level) internal{
       //require(msg.value == LEVEL_PRICE, 'Incorrect referrer Id');
        address payable _4thGenerationAddress = users[users[users[users[userAddress].upline].upline].upline].upline;

        
        if(_4thGenerationAddress == address(0))
        {
            _4thGenerationAddress = ownerWallet;
            _4thGenerationAddress.transfer(LEVEL_PRICE[level]);
        }
        else
        {   
       
        users[_4thGenerationAddress].paymentCount++;
        if(users[_4thGenerationAddress].paymentCount == 1)
        {
               ownerWallet.transfer(LEVEL_PRICE[level]);
        }
        else if(users[_4thGenerationAddress].paymentCount > 1 && users[_4thGenerationAddress].paymentCount <= 6)
        {
                _4thGenerationAddress.transfer(LEVEL_PRICE[level]);      
        }
        else if(users[_4thGenerationAddress].paymentCount > 6 && users[_4thGenerationAddress].paymentCount <= 16)
        {
            if(users[_4thGenerationAddress].paymentCount == 16 && level == 7)
            {
                _4thGenerationAddress.transfer(LEVEL_PRICE[level]);
            }
            else if(users[_4thGenerationAddress].paymentCount == 16)
            {
                users[_4thGenerationAddress].activeLevel++;
                emit upgradeLevelEvent(_4thGenerationAddress,users[_4thGenerationAddress].activeLevel,users[_4thGenerationAddress].upline, block.timestamp);
                upgrade(userAddress,level);

            }
        }
    }
    }
}