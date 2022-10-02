/**
 *Submitted for verification at BscScan.com on 2022-10-01
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
    address public ownerWallet;
    uint256 activeMember = 1;
    uint256 lastId = 1;

     struct UserStruct {
        bool isExist;
        uint id;
        uint childCount;
        address userAddress;
        uint256 referralId;
        uint256 activeLevel;
        uint256 paymentCount;
        }

    mapping(uint => uint) public LEVEL_PRICE;
    uint256 public LAST_LEVEL= 7;
    mapping (address => UserStruct) public users;
    
    mapping(uint => address) public idToAddress;

    //events
    event regLevelEvent(address indexed user,uint userId,uint256 referralId, uint time);
    event upgradeLevelEvent(address indexed user,uint level,uint256 referralId, uint time);

    constructor(address ownerAddress) {

       
        ownerWallet = ownerAddress;
        LEVEL_PRICE[1] = 0.00001 ether;
        LEVEL_PRICE[2] = 0.00002 ether;
        LEVEL_PRICE[3] = 0.00003 ether;
        LEVEL_PRICE[4] = 0.00004 ether;
        LEVEL_PRICE[5] = 0.00005 ether;
        LEVEL_PRICE[6] = 0.00006 ether;        
        LEVEL_PRICE[7] = 0.00007 ether;
       
        UserStruct memory _UserStruct;
        
        _UserStruct = UserStruct({
            isExist: true,
            id: lastId,
            childCount : 0,
            userAddress: ownerAddress,
            referralId: lastId,
            activeLevel: 1,
            paymentCount : 0
        });

        users[ownerAddress] = _UserStruct;
        idToAddress[lastId] = ownerAddress;
       
        emit regLevelEvent(ownerWallet,lastId,lastId, block.timestamp);
} 


    function registration(address payable refAddress)public payable {
       require(users[refAddress].isExist, 'Incorrect referrer Id');
        require(!users[msg.sender].isExist, 'Already registered');
        require(msg.value == LEVEL_PRICE[1], 'Invalid amount');
        regUser(payable(msg.sender));
        
    }
   
    
       function regUser(address payable userAddress) internal{
          
        users[msg.sender].isExist = true;

        if(users[idToAddress[activeMember]].childCount >= 2) activeMember++;

         UserStruct memory _UserStruct;
        
        lastId++;
        _UserStruct = UserStruct({
            isExist: true,
            id: lastId,
            childCount : 0,
            userAddress: userAddress,
            referralId: activeMember,
            activeLevel: 1,
            paymentCount : 0
        });

        
        users[userAddress] = _UserStruct;
       
        idToAddress[lastId] = userAddress;

        users[idToAddress[activeMember]].childCount++;
        emit regLevelEvent(userAddress,lastId,activeMember, block.timestamp);

        upgrade(userAddress,1);
    }

        function upgrade(address payable userAddress, uint level) internal{
       //require(msg.value == LEVEL_PRICE, 'Incorrect referrer Id');
       // address payable _4thGenerationAddress = idToAddress[users[users[users[users[userAddress].referralId].referralId].referralId].referralId];
            uint256 _4thUpline = users[userAddress].referralId;
            address  _4thGenerationAddress = idToAddress[users[idToAddress[users[idToAddress[users[idToAddress[_4thUpline]].referralId]].referralId]].referralId];

              //  address payable _4thGenerationAddress = idToAddress[_4thGenerationId];
        
        if(_4thGenerationAddress == address(0))
        {
            _4thGenerationAddress = ownerWallet;
            payable(_4thGenerationAddress).transfer(LEVEL_PRICE[level]);
        }
        else
        {   
       
        users[_4thGenerationAddress].paymentCount++;
        if(users[_4thGenerationAddress].paymentCount == 1)
        {
               payable(ownerWallet).transfer(LEVEL_PRICE[level]);
        }
        else if(users[_4thGenerationAddress].paymentCount > 1 && users[_4thGenerationAddress].paymentCount <= 6)
        {
                payable(_4thGenerationAddress).transfer(LEVEL_PRICE[level]);      
        }
        else if(users[_4thGenerationAddress].paymentCount > 6 && users[_4thGenerationAddress].paymentCount <= 16)
        {
            if(users[_4thGenerationAddress].paymentCount == 16 && level == 7)
            {
                payable(_4thGenerationAddress).transfer(LEVEL_PRICE[level]);
            }
            
            else if(users[_4thGenerationAddress].paymentCount == 16)
            {
                users[_4thGenerationAddress].activeLevel++;
                emit upgradeLevelEvent(_4thGenerationAddress,users[_4thGenerationAddress].activeLevel,users[_4thGenerationAddress].referralId, block.timestamp);
                upgrade(userAddress,level+1);

            }
        }
    }
 }
}