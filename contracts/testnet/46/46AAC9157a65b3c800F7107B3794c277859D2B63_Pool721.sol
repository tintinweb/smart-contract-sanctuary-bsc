// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./IERC20.sol";
contract Pool721 is IERC721Receiver{
    using SafeMath for uint256;
    address private poolOwner;
    uint256 public poolIndex;
    address private rewardAddress;
    uint8 private isToken=0;
    uint256 private rewardAmount=0;

    struct poolDetails721{
        uint256 start;
        uint256 end;
        uint16 minimumStakers;
        uint16 maximumStakers;
        address nftAddress;
    }
    mapping(uint256 => poolDetails721) private mapPoolDetails721;

    enum StakeStatus{
        Active,
        Unstake,
        Claim
    }

    enum RewardStatus{
        Available,
        Claim
    }

    struct Stake{
        uint256 index;
        address stakers;
        uint256 tokenId;
        uint256 stakeTime;
        StakeStatus status;
    }
    mapping(address => mapping(uint256 => Stake)) private mapStakes;
    Stake[] private arrStakes;

    struct Reward{
        uint256 index;
        uint256 tokenId;
        address from;
        RewardStatus status;
    }
    mapping(uint256 => Reward) private mapReward;
    Reward[] private arrRewards;

    modifier onlyPoolOwner(address _caller){
        require(poolOwner == _caller, "Caller is not the owner");
        _;
    }

    /*
        events
    */
    event claimNftRewardEVT(address by, uint256 tokenId, uint256 time);
    event claimTokenRewardEVT(address by, uint256 amount, uint256 time);
    event claimNftEVT(address owner, uint256 tokenId, uint256 time);
    event addTokenRewardEVT(address tokenAddress, uint256 amount, uint256 time);
    event addNftRewardEVT(address nftAddress, uint256 tokenId, uint256 time);

    function setPoolDetails(uint256[] memory _dates, uint16[] memory _data, address _nftAddress, address _poolOwner) external{
        require(_dates[0] < _dates[1], "Invalid date");
        poolDetails721 memory pool = poolDetails721(
            _dates[0],
            _dates[1],
            _data[0],
            _data[1],
            _nftAddress
        );
        poolOwner = _poolOwner;
        mapPoolDetails721[poolIndex] = pool;
    }

    /* 
        reward part
    */

    function addRewards(uint256 _amount, address _rewardAddress) external{
        rewardAddress = _rewardAddress;
        isToken = 1;
        IERC20(_rewardAddress).transferFrom(msg.sender, address(this), _amount);

        emit addTokenRewardEVT(_rewardAddress, _amount, block.timestamp);
    }

    function addNftRewards(uint256 _tokenId) external{
        require(isToken == 0, "POOL:721 Token reward is already active");
        isToken = 2;
        address _nftAddress = mapPoolDetails721[poolIndex].nftAddress;
        IERC721 _nft = IERC721(_nftAddress);
        require(_nft.ownerOf(_tokenId) == msg.sender, "Token not found");
        _nft.safeTransferFrom(msg.sender, address(this), _tokenId, "reward");
    }

    function _nftReward(uint256 _tokenId, address _from) private{
        address _nftAddress = mapPoolDetails721[poolIndex].nftAddress;
        Reward memory _reward = Reward(
            arrRewards.length,
            _tokenId,
            _from,
            RewardStatus.Available
        );
        mapReward[_tokenId] = _reward;
        arrRewards.push(_reward);
        emit addNftRewardEVT(_nftAddress, _tokenId, block.timestamp);
    }

    function getTokenBalance() view external returns(uint256){
        return IERC20(rewardAddress).balanceOf(address(this));
    }

    function getNFTReward() view external returns(Reward[] memory){
        return arrRewards;
    }

    /* 
        for test
    */

    function getRewardAddress() view external returns(address){
        return rewardAddress;
    }

    function getRewardAmount() view external returns(uint256){
        return IERC20(rewardAddress).balanceOf(address(this)).div(arrStakes.length);
    }

    function getCaller() view external returns (address){
        return msg.sender;
    }

    function getCurrentAdress() view external returns (address){
        return address(this);
    }

    function getCurrentBlockTime() view external returns (uint256){
        return block.timestamp;
    }

    /* 
        staking part
    */

    function onERC721Received(
        address to,  
        address from,
        uint256 tokenId,
        bytes calldata _data
    ) external  virtual override returns (bytes4){

        if(keccak256(bytes("reward")) == keccak256(_data))
        {
            _nftReward(tokenId, from);
        }
        else if(keccak256(bytes("stake")) == keccak256(_data))
        {
            _stakeNft(tokenId, from);
        }
        else if(keccak256(bytes("claimRWD")) == keccak256(_data))
        {
            _claimRewardNft(to, tokenId);
        }
        else if(keccak256(bytes("claimSTK")) == keccak256(_data))
        {
            _claimStakeNft(to, tokenId);
        }
        return IERC721Receiver.onERC721Received.selector;
    }

    function  _stakeNft(uint256 _tokenId, address _owner) private {
        Stake memory _stake = Stake(
            arrStakes.length,
            _owner,
            _tokenId,
            block.timestamp,
            StakeStatus.Active
        );
        mapStakes[_owner][_tokenId] = _stake;
        arrStakes.push(_stake);
    }

    function stake(uint256 _tokenId) external{
        address _nftAddress = mapPoolDetails721[poolIndex].nftAddress;
        IERC721 _nft = IERC721(_nftAddress);
        require(_nft.ownerOf(_tokenId) == msg.sender, "Token not found");
        _nft.safeTransferFrom(msg.sender, address(this), _tokenId, "stake");
    }

    function getAllstakers() view external returns(Stake[] memory){
        return arrStakes;
    }

    /* 
        claiming part
    */

    function unStakeTokenReward(uint256 _tokenId) external{
        poolDetails721 memory _mapPoolDetails721 = mapPoolDetails721[poolIndex];
        Stake memory _staker = mapStakes[msg.sender][_tokenId];
        require(_staker.stakers == msg.sender, "ERC721: claim caller is not owner nor approved");
        require(_mapPoolDetails721.end <= block.timestamp, "ERC721: invalid claim date");
        IERC721 _nft = IERC721(_mapPoolDetails721.nftAddress);
        IERC20 _rewardToken = IERC20(rewardAddress);
        if(rewardAmount==0){
            rewardAmount = _rewardToken.balanceOf(address(this)).div(arrStakes.length);
        }
        // _rewardToken.transferFrom(address(this), _staker.stakers, rewardAmount);
        _rewardToken.transfer(_staker.stakers, rewardAmount);
        _nft.safeTransferFrom(address(this), _staker.stakers, _tokenId, "claimSTK");

        emit claimTokenRewardEVT(msg.sender, rewardAmount, block.timestamp);
    }

    function unStakeNftReward(uint256 _tokenId, bool _iswinner, uint256 _rewardId) external{
        poolDetails721 memory _mapPoolDetails721 = mapPoolDetails721[poolIndex];
        Reward memory _reward = mapReward[_rewardId];
        Stake memory _staker = mapStakes[msg.sender][_tokenId];
        IERC721 _nft = IERC721(_mapPoolDetails721.nftAddress);
        require(_staker.stakers == msg.sender, "ERC721: claim caller is not owner nor approved");
        require(_mapPoolDetails721.end <= block.timestamp, "ERC721: invalid claim date");

        if(_iswinner==true){
            require(_reward.status == RewardStatus.Available, "ERC721: reward already claim");
            _nft.safeTransferFrom(address(this), _staker.stakers, _rewardId, "claimRWD");
        }
        _nft.safeTransferFrom(address(this), _staker.stakers, _tokenId, "claimSTK");
    }

    function _claimStakeNft(address _to, uint256 _tokenId) private{
        Stake storage _staker = mapStakes[_to][_tokenId];
        _staker.status = StakeStatus.Claim;
        arrStakes[_staker.index].status = StakeStatus.Claim;
        emit claimNftEVT(_to, _tokenId, block.timestamp);
    }

    function _claimRewardNft(address _to, uint256 _tokenId) private{
        Reward storage _reward = mapReward[_tokenId];
        _reward.status = RewardStatus.Claim;
        arrRewards[_reward.index].status = RewardStatus.Claim;
        emit claimNftRewardEVT(_to, _tokenId, block.timestamp);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {

            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

interface IERC721 is IERC165 {
  
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}