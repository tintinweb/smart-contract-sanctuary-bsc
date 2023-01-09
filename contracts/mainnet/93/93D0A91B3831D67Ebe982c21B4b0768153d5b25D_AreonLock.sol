// SPDX-License-Identifier: MIT

/*

▄▀█ █▀█ █▀▀ █▀█ █▄░█   █▄░█ █▀▀ ▀█▀ █░█░█ █▀█ █▀█ █▄▀
█▀█ █▀▄ ██▄ █▄█ █░▀█   █░▀█ ██▄ ░█░ ▀▄▀▄▀ █▄█ █▀▄ █░█

THIS SMART CONTRACT IS PREPARED TO LOCK AREON TOKENS. IT CAN ONLY BE USED FOR THIS PURPOSE.     
                                                                                                                                             
*/

pragma solidity ^0.8.0;

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

}

abstract contract Ownable is Context {

    address private _owner = _msgSender();

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

}

interface BEP20 {    
    function transfer(address recipient, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint);
}

contract AreonLock is Context, Ownable, BEP20 {

    event Withdraw(address indexed from, address indexed to, uint value);
    event AddGroup(string indexed _name);
    event RemoveGroup(uint indexed _groupId);

    uint public groupCount = 0;
    address public tokenContractAddress = 0x3Cb26F04223e948B8D810a7bd170620AFbD42e67;
    address public tokenOwnerAddress = 0xBf31fff1Bb77097Dd9B9BF1f2749e19fED669bC4;

    struct GroupSchema {
        uint id;
        string name;
        uint periodAmount;
        uint fullAmount;
        uint endLocking;
        uint percent;
        bool closed;
        bool exists;
    }

    mapping(uint => GroupSchema) private tokenGroup;
    mapping(address => uint) private balances;

    constructor() {
        createDefaultGroups();
    }

    function withdraw(address _tokenContractAddress, uint _groupId, uint _amount) external onlyOwner {
        uint endLockDate = tokenGroup[_groupId].endLocking;
        uint groupPeriodAmount = tokenGroup[_groupId].periodAmount;
        bool closed = tokenGroup[_groupId].closed;
        uint percent = tokenGroup[_groupId].percent;
        require(tokenGroup[_groupId].exists, "Group does not exist.");
        require(closed == false, "Group is closed.");
        require(block.timestamp >= endLockDate, "You cant withdraw amount before end locking time.");
        require(groupPeriodAmount >= _amount, "Amount cannot be greater than the period amount.");
        require(groupPeriodAmount > 0, "Amount must be greater than zero.");
        uint sendAmount = _amount*10**18;
        uint newGroupPeriodAmount = groupPeriodAmount - _amount;
        tokenGroup[_groupId].periodAmount = newGroupPeriodAmount;
        BEP20(_tokenContractAddress).transfer(tokenOwnerAddress, sendAmount);
        if(newGroupPeriodAmount == 0 && percent == 0){
            tokenGroup[_groupId].closed = true;
        }else{
            updatePeriod(_groupId);
        }
        emit Withdraw(_tokenContractAddress, tokenOwnerAddress, _amount);
    }

    function addGroup(string memory _name, bool _closed, uint _periodAmount, uint _fullAmount, uint _freeTime, uint _percent) external onlyOwner {
        require(_freeTime > block.timestamp + 30 days, "Locking time cannot be smaller than 1 month.");
        tokenGroup[groupCount] = GroupSchema(groupCount, _name, _periodAmount, _fullAmount, _freeTime, _percent, _closed, true);
        groupCount++;
        emit AddGroup(_name);
    }

    function removeGroup(uint _groupId) external onlyOwner {
        require(tokenGroup[_groupId].exists, "Group does not exist.");
        delete tokenGroup[_groupId];
        groupCount--;
        emit RemoveGroup(_groupId);
    }

    function getAllGroups() external view returns (GroupSchema[] memory) {
        require(groupCount > 0, "Group does not exist.");
        GroupSchema[] memory allGroups = new GroupSchema[](groupCount);
        for (uint i = 0; i < groupCount; i++) {
            GroupSchema storage group = tokenGroup[i];
            allGroups[i] = group;
        }
        return allGroups;
    }

    function getGroup(uint _groupId) external view returns (GroupSchema memory) {
        require(groupCount > 0, "Group does not exist.");
        require(tokenGroup[_groupId].exists, "Group does not exist.");
        return tokenGroup[_groupId];
    }

    function changeTokenContractAddress(address _newAddress) external onlyOwner{
        tokenContractAddress = _newAddress;
    }

    function changeTokenOwnerAddress(address _newAddress) external onlyOwner{
        tokenOwnerAddress = _newAddress;
    }

    function createDefaultGroups() private onlyOwner{
        tokenGroup[0] = GroupSchema(0,"MarketingAndAirdrops", 1250000, 25000000, 1681370829, 5, false, true);
        tokenGroup[1] = GroupSchema(1,"EcosystemDevelopment", 5000000, 50000000, 1676111343, 10, false, true);
        tokenGroup[2] = GroupSchema(2,"Team", 5000000, 50000000, 1689260058, 10, false, true);
        tokenGroup[3] = GroupSchema(3,"CompanyReserve", 7500000, 75000000, 1676111343, 10, false, true);
        tokenGroup[4] = GroupSchema(4,"ListingAndLiqidity", 10000000, 100000000, 1676111343, 10, false, true);
        tokenGroup[5] = GroupSchema(5,"SteakingRewards", 6250000, 125000000, 1676111343, 5, false, true);
        groupCount = 6;
    }

    function updatePeriod(uint _groupId) private onlyOwner(){
        uint percent = tokenGroup[_groupId].percent;
        uint groupPeriodAmount = tokenGroup[_groupId].periodAmount;
        uint groupFullAmount = tokenGroup[_groupId].fullAmount;
        
        if(groupPeriodAmount == 0){
            uint endDate = tokenGroup[_groupId].endLocking;
            tokenGroup[_groupId].endLocking = endDate + 30 days; 
            tokenGroup[_groupId].periodAmount = groupFullAmount * percent / 100;
        }
    }

    function currentTimestamp() external view returns(uint){
        return block.timestamp;
    }
    
    function isWithdrawal(uint _groupId) external view returns(bool) {
        require(tokenGroup[_groupId].exists, "Group does not exist.");
        if(block.timestamp >= tokenGroup[_groupId].endLocking && tokenGroup[_groupId].closed == false){
            return true;
        }else{
            return false;
        }
    }

    function getTotalTokenBalance() public view returns(uint) {
        BEP20 token = BEP20(tokenContractAddress);
        uint tokenBalance = token.balanceOf(address(this));
        return tokenBalance/10**18;
    }

    function transfer(address _recipient, uint _amount) external onlyOwner override returns (bool) {}

    function balanceOf(address _account) public onlyOwner view virtual override returns (uint) {
        return balances[_account];
    }

}