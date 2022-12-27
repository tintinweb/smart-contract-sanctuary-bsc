// SPDX-License-Identifier: UNLICENSED

//contracts/core/Stakepool.sol

pragma solidity 0.8.16;

// ==========  External imports    ==========
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {IERC20Upgradeable, SafeERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {IERC721ReceiverUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";

// ==========  Internal imports    ==========
import {IStakePool} from "../interfaces/IStakePool.sol";
import {StakepoolControl} from "./control/StakepoolControl.sol";

import {IAtpadNft} from "../interfaces/IAtpadNft.sol";

import {DataTypes} from "../lib/DataTypes.sol";
import {Helpers} from "../lib/Helpers.sol";

contract Stakepool is
    Initializable,
    IStakePool,
    StakepoolControl,
    ReentrancyGuardUpgradeable,
    IERC721ReceiverUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    //constructor
    // constructor() {
    //     _disableInitializers();
    // }

    //receive function (if exists)
    //fallback function (if exists)

    //  *******************************************************
    //                    EXTERNAL FUNCTIONS
    //  *******************************************************

    //Transaction
    function initialize(address _stakeToken) external initializer {
        stakeToken = IERC20Upgradeable(_stakeToken);
        decimals = 18;
        __Ownable_init();
        __Pausable_init();

        // addTier(20000 ether, 750, 0);
        // addTier(10000 ether, 300, 0);
        // addTier(5000 ether, 130, 0);
        // addTier(2000 ether, 40, 0);
        // addTier(1000 ether, 15, 0);

        stakeOn = true;
        withdrawOn = true;
        userOn = true;

        __Pausable_init();
        __Ownable_init();
    }

    /**
        @notice This function is used to stake Atompad to the stakepool.
        @dev It can be called by anyone so it is safe against reentrancy 
        attacks and can be paused or unpaused by admin.
        @param _amount - The amount of Atompad to stake.
     */

    function stake(uint256 _amount)
        external
        stakeEnabled
        nonReentrant
    // whenNotPaused
    {
        //if amount is less than required amount, throw error
        require(
            _amount > (10 * 10**decimals),
            "Stake amount must be greater than 10"
        );

        //if staked and staking amount is less than required amount, throw error
        require(
            (_amount + tokenBalances[msg.sender]) >= (1000 * 10**decimals),
            "Minimum staking amount is 1000"
        );

        //update staking balance of the staker in storage
        tokenBalances[msg.sender] += _amount;

        //store current allocation point of the staker in memory
        uint256 _allocPoints = allocPoints[msg.sender];

        //calculate the new allocation point of the staker and store it in memory
        uint256 _newAllocPoints = _reBalance(tokenBalances[msg.sender]);

        //update the allocation point of the staker in storage
        allocPoints[msg.sender] = _newAllocPoints;

        //update staking time of the staker to current time in storage
        timeLocks[msg.sender] = block.timestamp;

        //update storage variable which keeps track of total allocation points
        totalAllocPoint += (_newAllocPoints - _allocPoints);

        //update storage variable which keeps track of total tokens staked
        totalStaked += _amount;

        //add user to the list of stakers
        if (userOn) _checkOrAddUser(msg.sender);

        //transfer tokens from staker to this contract.
        stakeToken.safeTransferFrom(msg.sender, address(this), _amount);

        //emit event
        emit Staked(msg.sender, _amount);
    }

    /**
        @notice This function is used to unstake Atompad from the stakepool.
        @dev It can be called by anyone so it is safe against reentrancy 
        attacks and can be paused or unpaused by admin.
        @param _amount - The amount of Atompad to unstake.
     */
    function withdraw(uint256 _amount)
        public
        withdrawEnabled
        nonReentrant
        whenNotPaused
    {
        //if amount is less than staked amount, throw error
        require(
            tokenBalances[msg.sender] >= _amount,
            "Insufficient staking balance"
        );

        require(_amount > 0, "!amount");

        //calculate the withraw fee of the staker and store it in memory
        uint256 _fee = calculateWithdrawFees(_amount, msg.sender);

        //update staking balance of the staker in storage
        tokenBalances[msg.sender] -= _amount;

        //store current allocation point of the staker in memory
        uint256 _points = allocPoints[msg.sender];

        //calculate the new allocation point of the staker and store it in memory
        uint256 _newPoints = _reBalance(tokenBalances[msg.sender]);

        //store new allocation point of the staker in storage
        allocPoints[msg.sender] = _newPoints;

        //calculate the amount to be transferred to the staker and store it in memory
        uint256 _transferAmount = _amount - _fee;

        //update storage variable which keeps track of total allocation points
        totalAllocPoint -= (_points - _newPoints);

        //update storage variable which keeps track of total fee collected
        collectedFee += _fee;

        //update storage variable which keeps track of total tokens staked
        totalStaked -= _amount;

        //transfer tokens from this contract to staker.
        stakeToken.safeTransfer(msg.sender, _transferAmount);

        //emit event
        emit Withdrawn(msg.sender, _amount);
    }

    /**
        @notice This function is used to withdraw all the Atompad staked by this staker.
        @dev It can be called by anyone so it is safe against reentrancy attacks and 
        can be paused or unpaused by admin.
     */
    function withdrawAll() external withdrawEnabled nonReentrant whenNotPaused {
        withdraw(tokenBalances[msg.sender]);
    }

    /**
        @notice This function is used to stake nft to the stakepool.
        @dev It can be called by anyone so it is safe against reentrancy attacks and  can be paused or unpaused by admin.
        @param _tokenId - The id of the nft to stake.
     */
    function stakeNft(uint256 _tokenId, uint256 _tierIndex)
        external
        nonReentrant
        whenNotPaused
        stakeEnabled
    {
        //if token id is invalid, throw error
        require(_tokenId != 0, "!tokenID");

        require(_tierIndex < tiers.length, "Tier does not exists !");

        DataTypes.Tier memory _tier = tiers[_tierIndex];

        address _collection = _tier.collection;

        uint256 _weight = _tier.weight;

        //keep track of nft owners in this contract
        nftOwners[_collection][_tokenId] = msg.sender;

        nftBalances[_collection][msg.sender]++;

        //store new allocation point of the staker in storage
        allocPoints[msg.sender] += _weight;

        //update staking time of the staker to current time in storage
        timeLocks[msg.sender] = block.timestamp;

        //update storage variable which keeps track of total allocation points
        totalAllocPoint += _weight;

        //update storage variable which keeps track of total nft staked
        totalStakedNft++;

        //add user to the list of stakers
        if (userOn) _checkOrAddUser(msg.sender);

        //transfer nft from staker to this contract.
        IAtpadNft(_tier.collection).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );

        //emit event
        emit NFTStaked(msg.sender, _tokenId);
    }

    /**
        @notice This function is used to unstake nft from the stakepool.
        @dev It can be called by anyone so it is safe against reentrancy attacks and  can be paused or unpaused by admin.
        @param _tokenId - The id of the nft to unstake.
     */

    function withdrawNft(uint256 _tokenId, uint256 _tierIndex)
        external
        nonReentrant
        whenNotPaused
        withdrawEnabled
    {
        //if token id is invalid, throw error
        require(_tokenId != 0, "!tokenID");
        require(_tierIndex < tiers.length, "Tier does not exists !");

        //if staker is not the owner of the nft, throw error

        DataTypes.Tier memory _tier = tiers[_tierIndex];

        address _collection = _tier.collection;

        require(nftOwners[_collection][_tokenId] == msg.sender, "!staked");

        uint256 _weight = _tier.weight;

        //update the allocation point of the staker in storage
        allocPoints[msg.sender] -= _weight;

        //delete nft owner of this nft from this contract
        nftOwners[_collection][_tokenId] = address(0);

        //
        nftBalances[_collection][msg.sender]--;

        //update storage variable which keeps track of total allocation points
        totalAllocPoint -= _weight;

        //update storage variable which keeps track of total nft staked
        totalStakedNft--;

        //transfer nft from this contract to staker.
        IAtpadNft(_tier.collection).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        //emit event
        emit NFTWithdrawn(msg.sender, _tokenId);
    }

    /**
        @notice This function is used to stake multiple nfts to the stakepool.
        @dev It can be called by anyone so it is safe against reentrancy attacks and  can be paused or unpaused by admin.
        @param _tokenIds - The ids of the nfts to stake.
        @param _tierIndex - The index of the tier to stake nfts.
     */

    function batchStakeNfts(uint256[] memory _tokenIds, uint256 _tierIndex)
        external
        nonReentrant
        whenNotPaused
        stakeEnabled
        returns (bool)
    {
        uint256 _tokenIdsLength = _tokenIds.length;

        require(_tokenIdsLength > 1, "!tokenIDs");

        require(_tokenIdsLength <= 10, "Max 10 NFTs at a time");

        require(_tierIndex < tiers.length, "Tier does not exists !");

        DataTypes.Tier memory _tier = tiers[_tierIndex];

        address _collection = _tier.collection;

        uint256 _weight = _tier.weight;

        uint256 _totalWeight = _weight * _tokenIdsLength;

        nftBalances[_collection][msg.sender] += _tokenIdsLength;

        //store new allocation point of the staker in storage
        allocPoints[msg.sender] += _totalWeight;

        //update staking time of the staker to current time in storage
        timeLocks[msg.sender] = block.timestamp;

        //update storage variable which keeps track of total allocation points
        totalAllocPoint += _totalWeight;

        //update storage variable which keeps track of total nft staked
        totalStakedNft += _tokenIdsLength;

        //keep track of nft owners in this contract
        for (uint256 i; i < _tokenIds.length; i++) {
            nftOwners[_collection][_tokenIds[i]] = msg.sender;
            //transfer nft from staker to this contract.
            IAtpadNft(_tier.collection).safeTransferFrom(
                msg.sender,
                address(this),
                _tokenIds[i]
            );
        }

        //add user to the list of stakers
        if (userOn) _checkOrAddUser(msg.sender);

        //emit event
        emit BatchStakedNfts(msg.sender, _tokenIds);

        return true;
    }

    /**
        @notice This function is used to unstake multiple nfts from the stakepool.
        @dev It can be called by anyone so it is safe against reentrancy attacks and  can be paused or unpaused by admin.
        @param _tokenIds - The ids of the nfts to unstake.
        @param _tierIndex - The index of the tier to unstake nfts.
     */

    function batchWithdrawNfts(uint256[] memory _tokenIds, uint256 _tierIndex)
        external
        returns (bool)
    {
        uint256 _tokenIdsLength = _tokenIds.length;

        //if token id length is invalid, throw error
        require(_tokenIdsLength > 1, "!tokenIDs");

        //if staker requesting to unstake more than 10 nfts at a time, throw error
        require(_tokenIdsLength <= 10, "Max 10 NFTs at a time");

        //if tier index is invalid, throw error
        require(_tierIndex < tiers.length, "Tier does not exists !");

        DataTypes.Tier memory _tier = tiers[_tierIndex];

        address _collection = _tier.collection;

        //if staker is not the owner of the nft, throw error
        for (uint256 i; i < _tokenIdsLength; i++) {
            require(
                nftOwners[_collection][_tokenIds[i]] == msg.sender,
                "!staked"
            );
        }

        uint256 _totalWeight = _tier.weight * _tokenIdsLength;

        //update the allocation point of the staker in storage
        allocPoints[msg.sender] -= _totalWeight;

        //update nft balance of the staker
        nftBalances[_collection][msg.sender] -= _tokenIdsLength;

        //update storage variable which keeps track of total allocation points
        totalAllocPoint -= _totalWeight;

        //update storage variable which keeps track of total nft staked
        totalStakedNft -= _tokenIdsLength;

        for (uint256 i; i < _tokenIdsLength; i++) {
            //delete nft owner of this nft from this contract
            nftOwners[_collection][_tokenIds[i]] = address(0);

            //transfer nfts from this contract to staker.
            IAtpadNft(_tier.collection).safeTransferFrom(
                address(this),
                msg.sender,
                _tokenIds[i]
            );
        }

        //emit event
        emit BatchWithdrawnNfts(msg.sender, _tokenIds);

        return true;
    }

    ///@dev Function to get balance of staker in stakepool.
    function balanceOf(address _sender) external view returns (uint256) {
        return tokenBalances[_sender];
    }

    ///@dev Function to the staking time of the staker in stakepool.
    function lockOf(address _sender) external view returns (uint256) {
        return timeLocks[_sender];
    }

    ///@dev Function to get allocation point of the staker in stakepool.
    function allocPointsOf(address _sender) external view returns (uint256) {
        return allocPoints[_sender];
    }

    ///@dev Function to get allocation perecentage of the staker in stakepool.
    function allocPercentageOf(address _sender)
        external
        view
        returns (uint256)
    {
        uint256 points = allocPoints[_sender] * 10**6;

        uint256 millePercentage = points / totalAllocPoint;

        return millePercentage;
    }

    ///@dev Function to get owner of the nft staked in stakepool.
    function ownerOf(uint256 _tokenId, address _collection)
        external
        view
        returns (address)
    {
        return nftOwners[_collection][_tokenId];
    }

    ///@dev Function to get fee collected
    function viewCollectedFee() external view returns (uint256) {
        return collectedFee;
    }

    ///@dev Function to get all the tiers
    function getTiers() external view returns (DataTypes.Tier[] memory) {
        return tiers;
    }

    ///@dev Function to get all the users
    function users() external view returns (address[] memory) {
        return userAdresses;
    }

    function user(uint256 _index) external view returns (address) {
        return userAdresses[_index];
    }

    function getNfts(
        address _collection,
        address _sender,
        uint256 _limit
    ) external view returns (uint256[] memory) {
        uint256 _balance = nftBalances[_collection][_sender];
        uint256[] memory _tokenIds = new uint256[](_balance);
        uint256 j;
        for (uint256 i; i <= _limit; i++) {
            if (nftOwners[_collection][i] == _sender) {
                _tokenIds[j] = i;
                j++;
            }
        }

        return _tokenIds;
    }

    function getNftBalance(address _collection, address _sender)
        external
        view
        returns (uint256)
    {
        return nftBalances[_collection][_sender];
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721ReceiverUpgradeable.onERC721Received.selector;
    }

    //  *******************************************************
    //                    PUBLIC FUNCTIONS
    //  *******************************************************

    ///@dev function to calculate unstaking fee
    function calculateWithdrawFees(uint256 _amount, address _account)
        public
        view
        returns (uint256 _fee)
    {
        uint256 _timeLock = timeLocks[_account];
        _fee = calculateWithdrawFees(_amount, _timeLock);
    }

    //  *******************************************************
    //                    INTERNAL FUNCTIONS
    //  *******************************************************

    //  *******************************************************
    //                    PRIVATE FUNCTIONS
    //  *******************************************************

    ///@dev function to calculate allocation points
    /// @dev reBalance
    /// @param _balance is the number of tokens staked
    /// @return _points this is the allocation points calculated based on number of tokens
    function _reBalance(uint256 _balance)
        public
        view
        returns (uint256 _points)
    {
        /// @dev initiate
        _points = 0;

        /// @dev uint _smallest = 1000;    // tier 4 staked
        uint256 _smallest = tiers[tiers.length - 1].stake; // use former routine if this fails

        /// @dev take the biggest tier possible
        /// @dev we can keep of numbers per tier in later stage like tier{god}++
        while (_balance >= _smallest) {
            for (uint256 i = 0; i < tiers.length; i++) {
                /// iterate over tiers, order by biggest tier
                if (_balance >= tiers[i].stake) {
                    /// check if we have enough stake left for this tier
                    _points += tiers[i].weight; /// add weight points
                    _balance -= tiers[i].stake; /// redduce balance of stakes
                    i = tiers.length; /// exit iteration loopo
                }
            }
        }
        return _points;
    }

    ///@dev function to add user to stakepool
    function _checkOrAddUser(address _user) internal returns (bool) {
        bool _new = true;
        for (uint256 i = 0; i < userAdresses.length; i++) {
            if (userAdresses[i] == _user) {
                _new = false;
                i = userAdresses.length;
            }
        }
        if (_new) {
            userAdresses.push(_user);
        }
        return _new;
    }

    ///@dev function to calculate unstaking fee
    ///@param _amount - amount to withdraw
    ///@param _timeLock - time when staker last staked
    function calculateWithdrawFees(uint256 _amount, uint256 _timeLock)
        private
        view
        returns (uint256 _fee)
    {
        _fee = 0;

        uint256 _now = block.timestamp;

        if (_now > _timeLock + uint256(8 weeks)) {
            _fee = 0;
        }

        if (_now <= _timeLock + uint256(8 weeks)) {
            _fee = (_amount * 2) / 100;
        }

        if (_now <= _timeLock + uint256(6 weeks)) {
            _fee = (_amount * 5) / 100;
        }

        if (_now <= _timeLock + uint256(4 weeks)) {
            _fee = (_amount * 10) / 100;
        }

        if (_now <= _timeLock + uint256(2 weeks)) {
            _fee = (_amount * 20) / 100;
        }

        return _fee;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

interface IStakePool {
    function allocPercentageOf(address _sender) external view returns (uint256);

    function getNfts(
        address _collection,
        address _sender,
        uint256 _limit
    ) external view returns (uint256[] memory);

    function stake(uint256 _amount) external;

    function withdraw(uint256 _amount) external;

    function stakeNft(uint256 _tokenId, uint256 _tierIndex) external;

    function withdrawNft(uint256 _tokenId, uint256 _tierIndex) external;

    function batchStakeNfts(uint256[] memory _tokenIds, uint256 _tierIndex)
        external
        returns (bool);

    function batchWithdrawNfts(uint256[] memory _tokenIds, uint256 _tierIndex)
        external
        returns (bool);
}

// SPDX-License-Identifier: UNLICENSED

//contracts/interfaces/IAtpadNft.sol

pragma solidity 0.8.16;

import {IERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface IAtpadNft is IERC721Upgradeable {
    function getWeight(uint256 _tokenId) external returns (uint256);
}

// SPDX-License-Identifier: UNLICENSED

//contracts/core/control/StakepoolControl.sol

pragma solidity 0.8.16;

// ==========  External imports    ==========

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import {IERC20Upgradeable, SafeERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

// ==========  Internal imports    ==========
import {StakepoolStorage} from "../storage/StakepoolStorage.sol";
import {IAtpadNft} from "../../interfaces/IAtpadNft.sol";

import {DataTypes} from "../../lib/DataTypes.sol";

contract StakepoolControl is
    StakepoolStorage,
    OwnableUpgradeable,
    PausableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    //Interface
    IERC20Upgradeable public stakeToken;
    // IAtpadNft public nft;

    //Events
    event Staked(address indexed user, uint256 amount);
    event NFTStaked(address indexed user, uint256 indexed tokenId);
    event BatchStakedNfts(address indexed user, uint256[] tokenIds);
    event Withdrawn(address indexed user, uint256 amount);
    event NFTWithdrawn(address indexed user, uint256 indexed tokenId);
    event BatchWithdrawnNfts(address indexed user, uint256[] tokenIds);
    event FeeWithdrawn(address indexed user, uint256 amount);

    // Routines

    ///@dev Admin can withdraw collected fee from the pool using it
    function withdrawCollectedFee() external onlyOwner {
        /// @dev do some checks
        require(collectedFee > 0, "!Fee");

        uint256 _amount = collectedFee;
        collectedFee = 0;

        stakeToken.transfer(msg.sender, _amount);
        emit FeeWithdrawn(msg.sender, _amount);
    }

    //Setters
    function resetStakeToken(address _stakeToken) external onlyOwner {
        require(_stakeToken != address(0), "!StakeToken");
        stakeToken = IERC20Upgradeable(_stakeToken);
    }

    ///@dev Admin can add new tier to the pool
    function addTier(
        string memory _name,
        address _collection,
        uint256 _stake,
        uint256 _weight
    ) public onlyOwner {
        tiers.push(
            DataTypes.Tier({
                name: _name,
                collection: _collection,
                stake: _stake,
                weight: _weight
            })
        );
    }

    function updateTier(DataTypes.Tier memory _tier, uint256 _tierIndex)
        external
        onlyOwner
    {
        require(_tierIndex < tiers.length, "!index");

        tiers[_tierIndex] = _tier;
    }

    function updateStakingReq(uint256 _stake, uint256 _tierIndex)
        external
        onlyOwner
    {
        require(_tierIndex < tiers.length, "!index");
        require(_stake > 0, "!stake");
        tiers[_tierIndex].stake = _stake;
    }

    function updateCollection(address _collection, uint256 _tierIndex)
        external
        onlyOwner
    {
        require(_tierIndex < tiers.length, "!index");
        require(_collection != address(0), "!collection");
        tiers[_tierIndex].collection = _collection;
    }

    function setAllocPoints(address _account, uint256 _points)
        external
        onlyOwner
    {
        require(_points > 0, "!points");
        require(_account != address(0), "!account");

        allocPoints[_account] = _points;
    }

    //StakepoolNFT

    ///@dev Admin can enable or disable NFT staking
    function setDisableStake(bool _flag) external onlyOwner {
        stakeOn = _flag;
    }

    ///@dev Admin can enable or disable NFT withdraw
    function setDisableWithdraw(bool _flag) external onlyOwner {
        withdrawOn = _flag;
    }

    function setDecimals(uint8 _decimals) external onlyOwner {
        require(_decimals > 0, "!decimals");
        decimals = _decimals;
    }

    function setUserOn(bool _flag) external onlyOwner {
        userOn = _flag;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // Tier control

    // Modifiers
    modifier stakeEnabled() {
        require(stakeOn == true, "Staking is paused !");
        _;
    }

    modifier withdrawEnabled() {
        require(withdrawOn == true, "Withdrawing is paused !");
        _;
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

contract Helpers {
    function calculateWithdrawFees(uint256 _amount, uint256 _timeLock)
        internal
        view
        returns (uint256 _fee)
    {
        _fee = 0;

        uint256 _now = block.timestamp;

        if (_now > _timeLock + uint256(8 weeks)) {
            _fee = 0;
        }

        if (_now <= _timeLock + uint256(8 weeks)) {
            _fee = (_amount * 2) / 100;
        }

        if (_now <= _timeLock + uint256(6 weeks)) {
            _fee = (_amount * 5) / 100;
        }

        if (_now <= _timeLock + uint256(4 weeks)) {
            _fee = (_amount * 10) / 100;
        }

        if (_now <= _timeLock + uint256(2 weeks)) {
            _fee = (_amount * 20) / 100;
        }

        return _fee;
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.16;

library DataTypes {
    ///@dev Struct
    struct Tier {
        string name;
        address collection;
        uint256 stake;
        uint256 weight;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: UNLICENSED

//contracts/core/storage/StakepoolStorage.sol

pragma solidity 0.8.16;

import {DataTypes} from "../../lib/DataTypes.sol";

contract StakepoolStorage {
    // State Vars

    //variable to keep track of total allocpoints
    uint256 public totalAllocPoint;

    //variable to keep track of total collected fee
    uint256 public collectedFee;

    //variable to keep track of total no of tokens staked
    uint256 public totalStaked;

    //
    uint256 public totalStakedNft;

    //boolean representing whether the staking is paused or not
    bool public stakeOn;

    //boolean representing whether the withdraw is paused or not
    bool public withdrawOn;

    //
    bool public userOn;

    //helper var
    uint8 public decimals;

    ///@dev This is an upgradeable contract. This variable is used to avoid storage clashes while upgrading the contract. It 'll take next 50 slots from the storage
    uint256[50] private __gap;

    // Mapping

    //map to store the alocpoints allocated to each staker
    mapping(address => uint256) internal allocPoints;

    //map to store the staking time of each staker
    mapping(address => uint256) internal timeLocks;

    //map to store the staking balance of each staker
    mapping(address => uint256) internal tokenBalances;

    //map to store nft owner of each nft
    mapping(address => mapping(uint256 => address)) internal nftOwners;

    //map to store nft balance of each staker
    mapping(address => mapping(address => uint256)) internal nftBalances;

    //

    /**
    @dev map to store value assigned to each weight. it will represent how much each tier worth of. So admin can assign fee on unstaking nfts.

    Example: 
        -   Hawking
            weight: 15

    Hawking weight will be assigned a fixed value. So whenever a staker unstakes a nft, he can be charged.         

    Example:

        value: 100  
     */

    // Arrays

    //array to store all the tiers
    DataTypes.Tier[] internal tiers;

    //map to store the users who have staked
    address[] internal userAdresses;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}