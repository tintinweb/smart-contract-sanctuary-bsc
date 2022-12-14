/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
contract owned
{
    address internal owner;
    address internal newOwner;
    address public signer;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor()  {
        owner = msg.sender;
        signer = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }


    modifier onlySigner {
        require(msg.sender == signer, 'caller must be signer');
        _;
    }


    function changeSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //the reason for this flow is to protect owners from sending ownership to unintended address due to human error
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract pool is owned {


    mapping(address => uint[5]) public entryTime;

    mapping(address => uint[5]) public holdingAmount;    

    uint[5] public lastRewardTime;
    uint[5] public totalSystemToken;

    //last reward time => reflectionPercentSum[tokenType]
    mapping( uint => uint[5]) public reflectionPercentSum;

    address public nftMinterAddress;
    address public nftTradeAddress;

    function setNftMinterAddress(address _nftMinterAddress, address _nftTradeAddress) public onlyOwner returns(bool)
    {
        nftMinterAddress = _nftMinterAddress;
        nftTradeAddress = _nftTradeAddress;
        return true;
    }

    function addToken(uint _tokenType) public returns(bool) {
        require(_tokenType > 0 &&_tokenType <= 4, "not a valid tokenType");
        require(msg.sender == nftMinterAddress || msg.sender == nftTradeAddress, "invalid caller");
        if(holdingAmount[tx.origin][_tokenType] > 0 ) withdrawStakeReward(_tokenType);
        else entryTime[tx.origin][_tokenType] = lastRewardTime[_tokenType];
        holdingAmount[tx.origin][_tokenType]++;
        totalSystemToken[_tokenType]++;
        return true;
    }

    function removeToken(uint _tokenType) public returns(bool) {
        require(_tokenType > 0 &&_tokenType <= 4, "not a valid tokenType");
        require(msg.sender == nftMinterAddress || msg.sender == nftTradeAddress, "invalid caller");
        if(holdingAmount[tx.origin][_tokenType] > 0 ) withdrawStakeReward(_tokenType);
        else entryTime[tx.origin][_tokenType] = lastRewardTime[_tokenType];
        holdingAmount[tx.origin][_tokenType]--;
        totalSystemToken[_tokenType]--;
        return true;
    }

    function calculateReflectionPercent(uint _totalAmount, uint _rewardAmount) private pure returns(uint){
        return (_rewardAmount * 100000000000000000000 / _totalAmount);
    }

    function distributeReward(uint _tokenType) public payable onlyOwner returns (bool){
        require(_tokenType > 0 &&_tokenType <= 4, "not a valid tokenType");
        uint lastRewardHold = reflectionPercentSum[lastRewardTime[_tokenType]][_tokenType];
        lastRewardTime[_tokenType] = block.timestamp;
        reflectionPercentSum[lastRewardTime[_tokenType]][_tokenType] = lastRewardHold + calculateReflectionPercent(totalSystemToken[_tokenType], msg.value);
        return true;
    }

    function withdrawStakeReward(uint _tokenType) public returns (bool){
        require(entryTime[tx.origin][_tokenType] > 0 , "nothing staked");
        uint validPercent = reflectionPercentSum[lastRewardTime[_tokenType]][_tokenType] - reflectionPercentSum[entryTime[tx.origin][_tokenType]][_tokenType];
        if(validPercent > 0)
        {
            entryTime[tx.origin][_tokenType] = lastRewardTime[_tokenType];
            uint reward = holdingAmount[tx.origin][_tokenType] * validPercent / 100000000000000000000  ;
            payable(tx.origin).transfer(reward);    
        }
        return true;
    }


    function viewStakeReward(address _staker, uint _tokenType) public view returns(uint){
        
        uint validPercent = reflectionPercentSum[lastRewardTime[_tokenType]][_tokenType] - reflectionPercentSum[entryTime[tx.origin][_tokenType]][_tokenType];

        uint reward = holdingAmount[_staker][_tokenType] * validPercent / 100000000000000000000  ;   
        return reward;
    }

}