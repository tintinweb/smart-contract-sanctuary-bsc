// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./access/Ownable.sol";
import "./interfaces/IERC721.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IERC1155.sol";
import "./interfaces/IPriceConsumerV3.sol";

contract OnChainRewardsManagement is Ownable {
    enum RewardType { ERC20, ERC721, ERC1155 }

    struct RewardInfo {
        RewardType rewardType;
        address rewardAddress;
        uint amount;
        uint tokenId;
        uint fee;
        uint maxClaims;
        uint maxClaimsPerUser;
        bool isSet;

        uint totalClaims;
        mapping (address => uint) allowedUserClaims;
        mapping (address => uint) userClaimed;
    }

    address public gameMaster;
    address public treasury;
    IPriceConsumerV3 public priceConsumer;

    mapping (uint => RewardInfo) rewards;

    event RewardClaimed(address player, uint id, address reward);

    constructor(address _gameMaster, address _treasury, address _priceConsumer) {
        gameMaster = _gameMaster;
        treasury = _treasury;
        priceConsumer = IPriceConsumerV3(_priceConsumer);
    }

    function feeInBnb(uint _id) public view returns (uint256) { return priceConsumer.usdToBnb(rewards[_id].fee); }

    function setGameMaster(address _gameMaster) public {
        _requireOwner();
        gameMaster = _gameMaster;
    }

    function setTreasury(address _treasury) public {
        _requireOwner();
        treasury = _treasury;
    }

    function setPriceConsumer(address _priceConsumer) public {
        _requireOwner();
        priceConsumer = IPriceConsumerV3(_priceConsumer);
    }

    function checkReward(uint _id, address _wallet) public view returns (bool hasClaimed, bool canClaim) {
        RewardInfo storage reward = rewards[_id];
        require(reward.isSet, 'Reward is not set');
        uint claimed = reward.userClaimed[_wallet];
        hasClaimed = claimed > 0;
        canClaim = reward.allowedUserClaims[_wallet] > claimed;
        return (hasClaimed, canClaim);
    }

    function setReward(
        uint _id, 
        RewardType _type, 
        address _rewardAddress, 
        uint _amount, 
        uint _tokenId,
        uint _fee, 
        uint _maxClaims, 
        uint _maxClaimsPerUser
    ) public {
        _requireOwner();
        require(rewards[_id].totalClaims == 0, 'Reward cannot be changed after being claimed');
        rewards[_id].rewardType = _type;
        rewards[_id].rewardAddress = _rewardAddress;
        rewards[_id].amount = _amount;
        rewards[_id].tokenId = _tokenId;
        rewards[_id].fee = _fee;
        rewards[_id].maxClaims = _maxClaims;
        rewards[_id].maxClaimsPerUser = _maxClaimsPerUser;
    }

    function allowClaim(uint _id, address _wallet, uint _claims) public {
        require(rewards[_id].isSet, 'Reward is not set');
        require(msg.sender == gameMaster, 'Must be called by game master');
        require(rewards[_id].allowedUserClaims[_wallet] + _claims <= rewards[_id].maxClaimsPerUser, 'User has maximum claims');
        rewards[_id].allowedUserClaims[_wallet] += _claims;
    }

    function claim(uint _id) public payable {
        RewardInfo storage reward = rewards[_id];
        require(reward.allowedUserClaims[msg.sender] > reward.userClaimed[msg.sender], 'No claims available');
        require(msg.value >= feeInBnb(_id));
        require(reward.totalClaims < reward.maxClaims || reward.maxClaims == 0, 'Maximum claims for this reward have been issued');
        
        _safeTransfer(treasury, msg.value);

        if (reward.rewardType == RewardType.ERC20) _claimERC20(reward.rewardAddress, reward.amount);
        else if (reward.rewardType == RewardType.ERC721) _claimERC721(reward.rewardAddress);
        else _claimERC1155(reward.rewardAddress, reward.tokenId, reward.amount);

        reward.totalClaims++;
        reward.userClaimed[msg.sender]++;
    }

    function _claimERC20(address _reward, uint _amount) private {
        IERC20 token = IERC20(_reward);
        require(token.balanceOf(address(this)) >= _amount, 'Insufficient token balance');
        token.approve(msg.sender, _amount);
        token.transferFrom(address(this), msg.sender, _amount);
    }

    function _claimERC721(address _reward) private {
        IERC721 nft = IERC721(_reward);
        nft.mint(msg.sender);
    }

    function _claimERC1155(address _reward, uint _tokenId, uint _amount) private {
        IERC1155 nft = IERC1155(_reward);
        nft.mint(msg.sender, _tokenId, _amount);
    }

    function _safeTransfer(address _recipient, uint _amount) private {
        (bool _success, ) = _recipient.call{value: _amount}("");
        require(_success, "transfer failed");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Ownable {
    address public owner;
    event OwnershipTransferred(address previousOwner, address newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    function renounceOwnership() public {
        _requireOwner();
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public {
        _requireOwner();
        require(newOwner != address(0), 'Ownable: new owner cannot be zero address - renounce contract instead');
        _transferOwnership(newOwner);
    }

    function _requireOwner() internal view {
        require(msg.sender == owner, 'Ownable: caller is not contract owner');
    }

    function _transferOwnership(address newOwner) private {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, owner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./IERC165.sol";

interface IERC721 is IERC165 {
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function approve(address _to, uint256 _tokenId) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external;
    event Transfer(address _from, address _to, uint256 _tokenId);
    event Approval(address _owner, address _approved, uint256 _tokenId);
    event ApprovalForAll(address _owner, address _operator, bool _approved);

    function mint(address _to) external returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address _account) external view returns (uint256);
    function transfer(address _recipient, uint256 _amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transferFrom(address _sender, address _recipient, uint256 _amount) external returns (bool);
    event Transfer(address _from, address _to, uint256 _value);
    event Approval(address _owner, address _spender, uint256 _value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./IERC165.sol";

interface IERC1155 is IERC165 {
    function balanceOf(address _account, uint256 _id) external view returns (uint256);
    function balanceOfBatch(address[] calldata _accounts, uint256[] calldata _ids) external view returns (uint256[] memory);
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _account, address _operator) external view returns (bool);
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;
    event TransferSingle(address _operator, address _from, address _to, uint256 _id, uint256 _value);
    event TransferBatch(address _operator, address _from, address _to, uint256[] _ids, uint256[] _values);
    event ApprovalForAll(address _account, address _operator, bool _approved);
    event URI(string _value, uint256 _id);

    function mint(address _to, uint256 _id, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IPriceConsumerV3 {
    function getLatestPrice() external view returns (uint);
    function unlockFeeInBnb(uint) external view returns (uint);
    function usdToBnb(uint) external view returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC165 {
    function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}