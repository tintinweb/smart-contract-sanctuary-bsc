/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

pragma solidity ^0.6.2;

// SPDX-License-Identifier: UNLICENSED
// (c) Oleksii Vynogradov 2021, All rights reserved, contact [email protected] if you like to use code
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

pragma solidity ^0.6.2;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.6.2;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

pragma solidity ^0.6.2;
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}


pragma solidity ^0.6.2;

contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.6.2;

library Address {
 
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

pragma solidity ^0.6.2;

contract ReentrancyGuard {
    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}


pragma solidity >=0.5.0 <0.8.0;

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}


pragma solidity >=0.5.0 <0.7.0;

contract Staking is Ownable, ReentrancyGuard, IERC721Receiver {
    using SafeMath for uint;
    using SafeMath for uint256;
    using SafeMath for uint8;

    struct Stake{
        uint startTime;
        uint8 stakeSeason;
        uint8 stakeType;
        uint alreadyWithdrawedAmount;
        address staker;
    }

    event PotUpdated( uint newPot );
    event PotExhausted();
    event staked( address nftaddress, uint256 tokenId );
    event unstaked( address nftaddress, uint256 tokenId, uint256 withdrawAmount );
    event referralRewardSent( address account, uint reward );
    event rewardWithdrawed( address account );
    event machineStopped( );
    event subscriptionStopped( );

    mapping (uint256 => Stake) private stake; /// @dev Map that contains account's stakes

    address private tokenAddress;
    uint private pot;                           //The pot where token are take

    constructor() public {
        pot = 0;
        tokenAddress = address(0);
    }

    function setTokenAddress(address _tokenAddress) external onlyOwner {
        require(Address.isContract(_tokenAddress), "The address does not point to a contract");
        tokenAddress = _tokenAddress;
    }

    function isTokenSet() external view returns (bool) {
        if(tokenAddress == address(0))
            return false;
        return true;
    }

    function getTokenAddress() external view returns (address){
        return tokenAddress;
    }

    function depositPot(uint256 _amount) external onlyOwner nonReentrant {
        require(tokenAddress != address(0), "The Token Contract is not specified");
        pot = pot.add(_amount);
        if(IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount)){
            emit PotUpdated(pot);
        }else{
            revert("Unable to tranfer funds");
        }
    }

    function withdrawPot(uint _amount) external onlyOwner nonReentrant{
        require(tokenAddress != address(0), "The Token Contract is not specified");
        require(pot.sub(_amount) >= 0, "Not enough token");
        pot = pot.sub(_amount);
        if(IERC20(tokenAddress).transfer(msg.sender, _amount)){
            emit PotUpdated(pot);
        }else{
            revert("Unable to tranfer funds");
        }
    }

    function stakeNFT( address _nftAddress, uint256 _tokenId, uint8 _stakeType ) external {

        require(tokenAddress != address(0), "No contract set");

        require(IERC721(_nftAddress).ownerOf(_tokenId) == msg.sender, "You must stake your own NFT");
        IERC721(_nftAddress).safeTransferFrom(msg.sender, address(this), _tokenId);

        Stake memory newStake;
        newStake.staker = msg.sender;
        newStake.startTime = now;
        newStake.stakeType = _stakeType;
        newStake.stakeSeason = 1;
        newStake.alreadyWithdrawedAmount = 0;

        stake[uint256(_nftAddress).add(_tokenId)] = newStake;

        emit staked(_nftAddress, _tokenId);
    }

    function unStakeNFT( address _nftAddress, uint256 _tokenId ) external nonReentrant returns (bool){
        Stake storage selectedStake = stake[uint256(_nftAddress).add(_tokenId)];

        //Check if the stake were already withdraw
        require(selectedStake.startTime != 0 , "Stake were already returned.");
        require(selectedStake.staker == msg.sender, "You can not unstake this NFT.");
        
        IERC721(_nftAddress).safeTransferFrom(address(this), msg.sender, _tokenId);

        uint256 withdrawAmount = (now.sub(selectedStake.startTime)).div(60);
        if (withdrawAmount > 0) {
            if(selectedStake.stakeType == 1) {
                withdrawAmount = withdrawAmount.mul(137500000);
            }
            if(selectedStake.stakeType == 2) withdrawAmount = withdrawAmount.mul(17083333330);
            if(selectedStake.stakeType == 3) withdrawAmount = withdrawAmount.mul(4750000000);
            if(selectedStake.stakeType == 4) withdrawAmount = withdrawAmount.mul(9213473316);

            withdrawAmount = withdrawAmount.sub(selectedStake.alreadyWithdrawedAmount);

            IERC20(tokenAddress).transfer(msg.sender, withdrawAmount);
        }
        
        delete stake[uint256(_nftAddress).add(_tokenId)];
        delete stake[uint256(_nftAddress).add(_tokenId)];
        
        emit unstaked(_nftAddress, _tokenId, withdrawAmount);
        return true;
    }


    function claimRewards(address _nftAddress, uint256 _tokenId) external nonReentrant returns (bool){
        Stake storage selectedStake = stake[uint256(_nftAddress).add(_tokenId)];

        require(selectedStake.staker == msg.sender, "You are not a owner of this NFT!");

        uint256 withdrawAmount = (now.sub(selectedStake.startTime)).div(60);
        require(withdrawAmount > 0, "Can not claim");
        if(selectedStake.stakeType == 1) withdrawAmount = withdrawAmount.mul(137500000);
        if(selectedStake.stakeType == 2) withdrawAmount = withdrawAmount.mul(17083333330);
        if(selectedStake.stakeType == 3) withdrawAmount = withdrawAmount.mul(4750000000);
        if(selectedStake.stakeType == 4) withdrawAmount = withdrawAmount.mul(9213473316);

        withdrawAmount = withdrawAmount.sub(selectedStake.alreadyWithdrawedAmount);

        IERC20(tokenAddress).transfer(msg.sender, withdrawAmount);

        stake[uint256(_nftAddress).add(_tokenId)].alreadyWithdrawedAmount = stake[uint256(_nftAddress).add(_tokenId)].alreadyWithdrawedAmount.add(withdrawAmount);
        return true;
    }

    function getCurrentPot() external view returns (uint){
        return pot;
    }

    function checkPotBalance(uint _amount) internal view returns (bool){
        if(pot >= _amount){
            return true;
        }
        return false;
    }

    function getMachineBalance() internal view returns (uint){
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function getOwner() external view returns (address){
        return owner();
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}