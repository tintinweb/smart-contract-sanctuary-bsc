/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed to);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Ownable: Caller is not the owner");
        _;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function transferOwnership(address transferOwner) external onlyOwner {
        require(transferOwner != newOwner);
        newOwner = transferOwner;
    }

    function acceptOwnership() virtual external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

interface IStakingSet {
    function buyStakingSet(uint256 amount) external;
    function withdrawUserRewards(uint256 id, address tokenOwner) external;
    function burnStakingSet(uint256 id, address tokenOwner) external;
    function getTotalAmountsOfRewards(uint256 id) external returns(uint256);
}

contract HubRouting is Ownable {
    address private StakingMain;
    uint256 private stakingSetCount;

    event BnbReceived(address sender, uint BNB);

    mapping(uint256 => bool) public listActive;
    mapping(uint256 => address) public listMap; // stakingSet id => address
    mapping(uint256 => address) public smartByNFT; // nft id => stakingSet address

    constructor(address _StakingMain) {
        StakingMain = _StakingMain;
    }

    function stake(uint256 _setNum, uint256 _amount, uint _tokenId) external payable {
        require(msg.sender == StakingMain, "HubRouting::caller is not the Staking Main contract");
        emit BnbReceived(msg.sender, msg.value);
       // IStakingSet StakingSet;
      //  address payable stakingSet = listMap[_setNum];
        (bool success,) = listMap[_setNum].call{value: msg.value}(abi.encodeWithSignature("buyStakingSet(uint256)",_amount));
        require(success, "HubRouting::buySmartStaker failed");
        smartByNFT[_tokenId] = listMap[_setNum];
    }

    function balance() public view returns (uint256){
        return address(this).balance;
    }

    function withdrawReward(uint256 _id, address _tokenOwner) external {
        require(msg.sender == StakingMain, "HubRouting::caller is not the Staking Main contract");
        address stakingSet = smartByNFT[_id];
        IStakingSet(stakingSet).withdrawUserRewards(_id, _tokenOwner);
    }

    function burn(uint256 _id, address _tokenOwner) external {
        require(msg.sender == StakingMain, "HubRouting::caller is not the Staking Main contract");
        address stakingSet = smartByNFT[_id];
        IStakingSet(stakingSet).burnStakingSet(_id, _tokenOwner);
    }

    
    function totalAmountsOfRewards(uint256 _id) external returns (uint256) {
        return IStakingSet(listMap[_id]).getTotalAmountsOfRewards(_id);
    }

 


    function registrationSet(address _stakingSet) external {
        require(msg.sender == StakingMain, "HubRouting::caller is not the Staking Main contract");
        listMap[stakingSetCount] = _stakingSet;
        listActive[stakingSetCount] = true;
        stakingSetCount++;
    }

    function updateSet(uint256 _setNum, address _stakingSet) external {
        require(msg.sender == StakingMain, "HubRouting::caller is not the Staking Main contract");
        listMap[_setNum] = _stakingSet;
    }

    function deactivateSet(uint256 _setNum) external onlyOwner {
        listActive[_setNum] = false;
    }

    function activateSet(uint256 _setNum) external onlyOwner {
        listActive[_setNum] = true;
    }

    function getCount() external view returns(uint256) {
        return stakingSetCount;
    }

}