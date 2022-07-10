//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import './IERC20.sol';


contract PayRole{

/// @notice You can use this contract to set hourly payments
/// @dev This contract were write in test-based

address owner;
IERC20 BUSD = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
mapping(address => bool) allowed;
mapping(address => uint) allowance;
mapping(address => uint) moment;
mapping(address => uint) residual;

event devAdded(address);
event allowanceAdded(address, uint);
event allowanceChanged(address, uint);
event claimed(address, uint);
event ownershipTransfered(address);
event ownerClaimned(uint);
event hasResidual(address, uint);
event residualClaimed(address, uint);


constructor ()  {
       owner = msg.sender;
   }

/// @dev Owner access modifier

modifier onlyOwner() {
require(
    msg.sender == owner, "This function is residualricted to the contract's owner");
_;
}

/// @dev return the status of the address

function getStatus(address _address) view external onlyOwner returns(bool){
    return allowed[_address];
}

/// @notice Returns the claimable amount for an specific address
/// @param _address The address in which you wanna know how much does per hour

function checkReward(address _address) view external returns(uint){
    uint _moment = moment[_address];
    uint _allowance = allowance[_address];
     uint result = (((block.timestamp - _moment) / 1 hours) * _allowance) + residual[_address];
    return result;
}

/** 
/// @notice write function to claim the value from the contract to msg.sender
/// @dev It checks if there's balance on the contract for the whole payment 
    if it does he claims, else we store the residual in a mapping for each address 
*/

function claim() external {
    uint _moment = moment[msg.sender];
    uint _allowance = allowance[msg.sender];
    uint amount = (((block.timestamp - _moment) / 1 hours) * _allowance) + residual[msg.sender];
    require(allowed[msg.sender] == true, 'This address is not allowed to perform withdrawns');
    require(amount > 0 ,'No value to be claimned');
        if(BUSD.balanceOf(address(this)) < amount){
            uint _residual = amount - BUSD.balanceOf(address(this));
            BUSD.transfer(msg.sender, BUSD.balanceOf(address(this)));
            moment[msg.sender] = block.timestamp;
            residual[msg.sender] = _residual;
            emit hasResidual(msg.sender, _residual);
            emit claimed(msg.sender, amount);        
        }else{
            BUSD.transfer(msg.sender, amount);
            moment[msg.sender] = block.timestamp;
            emit residualClaimed(msg.sender, residual[msg.sender]);
            residual[msg.sender] = 0;
            emit claimed(msg.sender, amount);
        }
}

/// @notice Owner is able to add a dev along with his allowance per hour
/// @param _address Address in which you wanna add in the payrole
/// @param _allowance How much per hour this address should be making

function addDev(address _address, uint _allowance) external onlyOwner {
    allowed[_address] = true;
    moment[_address] = block.timestamp;
    allowance[_address] = _allowance * 1 ether;
    emit devAdded(_address);
    emit allowanceAdded(_address, _allowance);
}

/// @notice Update the allowance
/// @param _address Address in which you wanna change the allowance
/// @param _amount The amount per hour that you wanna make this address available to claim

function setAllowance(address _address, uint _amount) external onlyOwner{
    allowance[_address] = _amount * 1 ether;
    emit allowanceChanged(_address, _amount);
}

/// @notice Pass the ownership for someone else
/// @param _address Address that you wanna make the new owner

function transferOwnership(address _address) external onlyOwner {
    owner = _address;
}
}