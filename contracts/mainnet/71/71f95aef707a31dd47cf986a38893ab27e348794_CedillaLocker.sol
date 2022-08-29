/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract CedillaLocker {
    address public owner;
    uint256 public fee = 40;
    uint256 public BNBFee = 100000000000000000;
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    event transferOwnerEvent(address oldOwner, address newOwner);

    function transferOwner(address _add) public onlyOwner{
        emit transferOwnerEvent(owner, _add);
        owner = _add;
    }

    function setfee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function setBNBFee(uint256 _amount) public onlyOwner {
        BNBFee = _amount;
    }

    function getTotalLocked(address _token) public view returns(uint256) {
        return totalLocked[_token];
    }

    uint256 runningCount = 0;
    struct vault {
        uint256 vaultId;
        address owner;
        address token;
        uint256 amount;
        bool closed;
        uint256 end;
    }

    mapping(address => uint256) totalLocked;
    vault[] public vaultArray;

    function findVault(address _owner) public view returns(uint256[] memory) {
        uint256[] memory result = new uint256[](vaultArray.length);
        uint256 counter = 0;
        
        for (uint256 i = 0; i < vaultArray.length; i++) {
            if (vaultArray[i].owner == _owner) {
                result[counter] = i;
                counter++;
            }
        }

        uint256[] memory finalRes = new uint256[](counter);
        for(uint256 i; i < counter; i++) {
            finalRes[i] = result[i];
        }
        return finalRes;
    }

    function VaultInfo(uint256 _vaultId) public view returns(vault memory) {
	    return vaultArray[_vaultId];
    }

    function GetAllVaultInfo(address _ofToken) public view returns(uint256[] memory) {
        uint256[] memory toReturn = new uint256[](vaultArray.length);
         uint256 count = 0;
        for(uint256 i = 0; i < vaultArray.length; i++) {
            if(vaultArray[i].token == _ofToken) {
                toReturn[vaultArray[i].vaultId] = vaultArray[i].vaultId;
                count++;
            }
        }
        
        uint256[] memory toReturn1 = new uint256[](count);
        count = 0;
        for(uint256 i; i < toReturn.length; i++) {
            if(toReturn[i] != 0) {
                toReturn1[count] = toReturn[i];
                count++;
            }
        }
        return toReturn1;
    }

    function lockTokens(address _token, uint256 _time, uint256 _amount) public payable returns(uint256){
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount));
        if(msg.value != 0) {
            require(msg.value >= BNBFee);
            payable(owner).transfer(msg.value);
            vaultArray.push(vault(runningCount, msg.sender, _token, _amount, false, block.timestamp+_time));
            totalLocked[_token] += _amount;
        }
        if(msg.value == 0) {
            IERC20(_token).transfer(owner, (_amount / 10000) * fee);
            vaultArray.push(vault(runningCount, msg.sender, _token, _amount - (_amount / 10000) * fee, false, block.timestamp+_time));
            totalLocked[_token] += _amount - (_amount / 10000) * fee;
        }
        runningCount++;
        return (runningCount-1);
    }

    function extend(uint256 _vaultId, uint256 _timeInBlocks) public {
        require(vaultArray[_vaultId].owner == msg.sender);
        require(vaultArray[_vaultId].closed == false);
        require(block.timestamp < vaultArray[_vaultId].end);
        vaultArray[_vaultId].end += _timeInBlocks;
    }

    function withdraw(uint256 _vaultId) public{
        require(vaultArray[_vaultId].owner == msg.sender);
        require(vaultArray[_vaultId].closed == false);
        require(block.timestamp >= vaultArray[_vaultId].end);
        vaultArray[_vaultId].closed = true;
        uint256 a = vaultArray[_vaultId].amount;
        totalLocked[vaultArray[_vaultId].token] -= vaultArray[_vaultId].amount;
        vaultArray[_vaultId].amount = 0;
        IERC20(vaultArray[_vaultId].token).transfer(msg.sender, a);
    }

    
}