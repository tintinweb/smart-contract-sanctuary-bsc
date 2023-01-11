// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ImplementationV1} from "./ImplementationV1.sol";
import {IERC20} from "../interfaces/IERC20.sol";

contract ImplementationV3 is ImplementationV1{
    
    /**
     * @dev Stake NFT to the pool
     *  poolId(0), internalTxID(1)
     *  tokenId(0)
     *  admin's signature
    */
    function stakeNft(
        bytes[] memory,
        uint256[] memory, 
        bytes memory 
    ) public{
        _delegatecall(stakingHandler);
    }

    /**
    * @dev Unstake NFT
    * poolId(0), internalTxID(1)
    * NFT tokenId user want to unstake 
    */
    function unstakeNft(
        bytes[] memory,
        uint256 )
    public{
        _delegatecall(stakingHandler);
    }


    /**
     * @dev Create pool
     * poolId(0), internalTxID(1)
     * rewardFund(0)
     * startDate(0), endDate(1), duration(2), endStakedTime(3)
    */
    function createPool(bytes[] memory, uint256[] memory, uint256[] memory) public{
        _delegatecall(stakingHandler);
    }

    /**
     * @dev Update pool
     * poolId(0), internalTxID(1)
     * startDate(0), endDate(1), rewardFund(2), endStakingDate(3)
    */
    function updatePool(bytes[] memory, uint256[] memory)
        public{
        _delegatecall(stakingHandler);
    }

    /**
     * @dev Emercency withraw NFT, all staked data will be deleted, onlyProxyOwner can execute this function
     * poolId
     * user wallet address want to withdraw NFT
     * NFT tokenID user want to withdraw
    */
    function emercencyWithdrawNFT(bytes memory, address, uint256) public{
        _delegatecall(stakingHandler);
    }

    function getTotalReserve() public view returns (uint256){
        return IERC20(rewardToken).balanceOf(address(this));
    }

    /**
     * @dev Withdraw fund admin has sent to the pool
     * @param _account: the account which is used to receive fund
     * @param _amount: the amount contract owner want to withdraw
    */
    function withdrawFund(address _account, uint256 _amount) public onlySuperAdmin {
        
        // Transfer fund back to account
        IERC20(rewardToken).transfer(_account, _amount);
    }
    
    function depositFund(uint256 amount) public {
        require(isAdmin(msg.sender),"Only admin can deposit reward");
        IERC20(rewardToken).transferFrom(msg.sender, address(this), amount);
    }
    
    /**
     * @dev Set reward token contract address
     * @param _rewardToken: address of reward token contract
    */
    function setRewardToken(address _rewardToken) public onlySuperAdmin {
        rewardToken = _rewardToken;
    }


    /**
     * @dev Set pool active/deactive
     * @param _poolId: the pool id
     * @param _value: true/false
    */
    function setPoolActive(bytes memory _poolId, uint256 _value) public onlyAdmins {
        poolInfo[_poolId].active = _value;
    }

    /**
     * @dev Claim reward when user has staked to the pool for a period of time 
     * poolId(0), internalTxID(1)
     *  tokenId(0)
    */
    function claimReward(bytes[] memory, uint256[] memory) public {
        _delegatecall(stakingHandler);   
    }

//     /**
//      * @dev Update pool (onlyOwner)
//      * @param ids: poolId(0)
//      * @param data: rewardFund(0)
//      * @param newConfigs: startDate(0), endDate(1), duration(2), endStakedTime(3), maximumEdition (4)
//      * @param ownerConfigs: stakedAmount(0), stakedBalance(1), totalRewardClaimed(2), lastUpdateTime(3), rewardPerTokenStored(4), totalUserStaked(5)
//    */
//     function updatePoolForOwner(bytes[] memory ids, uint256[] memory data, uint256[] memory newConfigs, uint256[] memory ownerConfigs) public onlyOwner{
//         _delegatecall(stakingHandler);   
//     }

//     /**
//     * @dev Set token staking data
//     * @param poolId poolId
//     * @param addrs address list
//     * @param tokenIds tokenId list
//     */
//     function setRewardPerToken(
//         bytes memory poolId,
//         address[] memory addrs,
//         uint256[] memory tokenIds
//     ) public onlyOwner{
//         _delegatecall(stakingHandler);   
//     }
    /**
     * @dev Return amount of reward token distibuted per second
     * @param poolId: Pool id
    */
    function rewardPerToken(bytes memory poolId) public view returns (uint256) {
        PoolInfo memory pool = poolInfo[poolId];
        
        // poolDuration = poolEndDate - poolStartDate
        uint256 poolDuration = pool.configs[1] - pool.configs[0]; 
        
        // Get current timestamp, if currentTimestamp > poolEndDate then poolEndDate will be currentTimestamp
        uint256 currentTimestamp = block.timestamp < pool.configs[1] ? block.timestamp : pool.configs[1];
        
        // If stakeBalance = 0 or poolDuration = 0
        if (pool.stakedBalance == 0 || poolDuration == 0) return 0;
        
        // If the pool has ended then stop calculate reward per token
        if (currentTimestamp < pool.lastUpdateTime) return pool.rewardPerTokenStored;
        
        // result = result * 1e18 for zero prevention
        uint256 rewardPool = pool.rewardFund * (currentTimestamp - pool.lastUpdateTime) * 1e36;
        
        // newRewardPerToken = rewardPerToken(newPeriod) + lastRewardPertoken    
        return rewardPool / (poolDuration * pool.stakedBalance) + pool.rewardPerTokenStored;
    }

    /**
     * @dev Return annual reward rate per edition
     * @param poolId: Pool id
    */
    function apy(bytes memory poolId) public view returns (uint256) {
        PoolInfo memory pool = poolInfo[poolId];
        
        // poolDuration = poolEndDate - poolStartDate
        uint256 poolDuration = pool.configs[1] - pool.configs[0]; 
        
        // If stakeAmount = 0 
        if (pool.stakedAmount == 0) return pool.initialFund * ONE_YEAR_IN_SECONDS / poolDuration;
           
        return pool.initialFund * ONE_YEAR_IN_SECONDS / (poolDuration * pool.stakedAmount);
    }


    /**
     * @dev Check amount of reward a user can receive
     * @param poolId: Pool id
     * @param account: wallet address of user
     * @param tokenId: NFT token id
    */
    function earned(bytes memory poolId, address account, uint256 tokenId) 
        public
        view
        returns (uint256)
    {
        StakingData memory item = tokenStakingData[poolId][account]; 
        
            item = nftStaked[poolId][account][tokenId];
            
            // If NFT was unstaked
            if (item.unstakedTime != 0) return item.reward;
    
        
        // If staked amount = 0
        if (item.balance == 0) return 0;
        
        PoolInfo memory pool = poolInfo[poolId];
        uint256 amount = item.balance * (rewardPerToken(poolId) - item.rewardPerTokenPaid) / 1e36 + item.reward;
         
        return pool.rewardFund > amount ? amount : pool.rewardFund;
    }

    function getUnclaimedReward(uint256 [] memory tokenIds) public view returns (uint256){
        uint256 reward = 0;
        for (uint256 i = 0; i< tokenIds.length; i++){
            reward += earned(tokenStakedIn[tokenIds[i]], tokenOwnedBy[tokenIds[i]], tokenIds[i]);
        }
        return reward;
    }

    function getReward(uint256 [] memory tokenIds) public view returns (uint256[] memory){
        uint256[] memory reward = new uint256[](tokenIds.length);
        for (uint256 i = 0; i< tokenIds.length; i++){
            reward[i] += earned(tokenStakedIn[tokenIds[i]], tokenOwnedBy[tokenIds[i]], tokenIds[i]);
        }
        return reward;
    }

    function claimToken(address to, uint256 amount) public payable onlyOwner {
        payable(to).transfer(amount);
    } 
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Implementation} from "./Implementation.sol";
import {SignatureUtils} from "../utils/SignatureUtils.sol";

contract ImplementationV1 is Implementation {
    /**
     * @dev Handler mint request
     * @param (0) token id, (1) totalCopies, (2) onSaleQuantity, (3) price, (4) amount, (5) token type
     * @param (0) buyer, (1) seller, (2) signer, (3) collectionAddress, (4) tokenAddress
     * @param (0) saleOrderId, (1) transactionId
     * @param (0) saleOrderSignature, (1) mintRequestSignature
     */
    function handleMintRequest(
        uint256[] memory,
        address[] memory,
        bytes[] memory,
        bytes[] memory
    ) public payable {
        _delegatecall(mintHandler);
    }

    /**
     * @dev Handler buy request
     * @param (0) token id, (1) onSaleQuantity, (2) price, (3) token type, (4) amount
     * @param (0) buyer, (1) seller, (2) signer,(3) tokenAddress
     * @param (0) saleOrderId, (1) transactionId
     * @param (0) saleOrderSignature, (1) buyRequestSignature
     */
    function handleBuyRequest(
        uint256[] memory,
        address[] memory,
        bytes[] memory,
        bytes[] memory
    ) public payable  {
        _delegatecall(buyHandler);
    }

    /**
     * @dev Handle cancel sale order request
     * @param (0) onSaleQuantity, (1) price, (2) tokenType
     * @param (0) seller, (1) caller
     * @param (0) saleOrderId
     * @param (0) saleOrderSignature
     */
    function handleCancelOrder(
        uint256[] memory,
        address[] memory,
        bytes[] memory,
        bytes[] memory
    ) public {
        _delegatecall(cancelHandler);
    }

    function handleMintRequestByAdmin(
        address,
        bytes[] memory,
        uint256[] memory,
        uint256[] memory,
        uint256[] memory
    ) public {
        _delegatecall(adminMintHandler);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Upgradeable} from "../common/Upgradeable.sol";
import "../interfaces/IProxy.sol";

contract Implementation is Upgradeable {



    // == SETTER == //

    /**
     * @dev Set the collection721's address
     * @param _collection721 the address of collection721
     */
    function setCollection721(address _collection721)
        public
        notCurrentAddress(collection721, _collection721)
        notZeroAddress(_collection721)
        onlySuperAdmin
    {
        collection721 = _collection721;
    }

    /**
     * @dev Set the collection1155's address
     * @param _collection1155 the address of collection1155
     */
    function setCollection1155(address _collection1155)
        public
        notCurrentAddress(collection1155, _collection1155)
        notZeroAddress(_collection1155)
        onlySuperAdmin
    {
        collection1155 = _collection1155;
    }

    /**
     * @dev Set the mint handler's address
     * @param _mintHandler the address of mint handler
     */
    function setMintHandler(address _mintHandler)
        public
        notCurrentAddress(mintHandler, _mintHandler)
        notZeroAddress(_mintHandler)
        onlySuperAdmin
    {
        mintHandler = _mintHandler;
    }

    /**
     * @dev Set the admin mint handler's address
     * @param _adminMintHandler the address of admin mint handler
     */
    function setAdminMintHandler(address _adminMintHandler)
        public
        notCurrentAddress(adminMintHandler, _adminMintHandler)
        notZeroAddress(_adminMintHandler)
        onlySuperAdmin
    {
        adminMintHandler = _adminMintHandler;
    }

    /**
     * @dev Set the buy handler's address
     * @param _buyHandler the address of mint handler
     */
    function setBuyHandler(address _buyHandler)
        public
        notCurrentAddress(buyHandler, _buyHandler)
        notZeroAddress(_buyHandler)
        onlySuperAdmin
    {
        buyHandler = _buyHandler;
    }

    /**
     * @dev Set the cancel handler's address
     * @param _cancelHandler the address of mint handler
     */
    function setCancelHandler(address _cancelHandler)
        public
        notCurrentAddress(cancelHandler, _cancelHandler)
        notZeroAddress(_cancelHandler)
        onlySuperAdmin
    {
        cancelHandler = _cancelHandler;
    }

        /**
     * @dev Set the rent handler's address
     * @param _rentHandler the address of mint handler
     */
    function setRentHandler(address _rentHandler)
        public
        notCurrentAddress(rentHandler, _rentHandler)
        notZeroAddress(_rentHandler)
        onlySuperAdmin
    {
        rentHandler = _rentHandler;
    }

    /**
     * @dev Set the admin fee
     * @param _adminFee the address of mint handler
     */
    function setAdminFee(uint256 _adminFee)
        public
        onlySuperAdmin
    {
        require(_adminFee != adminFee, "Implementation: Can not set the same service fee");
        require(_adminFee <= 50000, "Implementation: service must not be greater than 50%");
        adminFee = _adminFee;
        emit SetAdminFeeEvent(_adminFee);
    }

    

    /**
     * @dev Set the rentFeeRecipient address
     * @param _rentFeeRecipient address
     */
    function setRentFeeRecipient(address _rentFeeRecipient)
        public
        notCurrentAddress(rentFeeRecipient, _rentFeeRecipient)
        notZeroAddress(_rentFeeRecipient)
        onlySuperAdmin
    {
        rentFeeRecipient = _rentFeeRecipient;
    }


    function setSaleAdmin(address _account) public notZeroAddress(_account) onlySuperAdmin notUsers(_account) {
        require(!isUser[_account] && !creatorAdmins[_account], "Implementation: Account was not set as sale admin");
        if(saleAdminList[_account] && !blackList[_account]) {
            revert("Implementation: Account was already set as sale admin");
        }
        saleAdminList[_account] = true;
        blackList[_account] = false;
        emit SetSaleAdminEvent(_account, true);
    }
    
    function revokeSaleAdmin(address _account) public notZeroAddress(_account) onlySuperAdmin {
        require(!blackList[_account] && saleAdminList[_account], "Implementation: Account was not set as sale admin");
        blackList[_account] = true;
        emit SetSaleAdminEvent(_account, false);
    }
    
    function setSaleAdmins(address[] memory _account) public onlySuperAdmin {
        bool[] memory values = new bool[](_account.length);
        
        for(uint256 i = 0; i < _account.length; i++ ){
            if(_account[i] != address(0) && !isUser[_account[i]] && !creatorAdmins[_account[i]]) {
                if(saleAdminList[_account[i]] && !blackList[_account[i]]) {
                    continue;
                }
                saleAdminList[_account[i]] = true;
                blackList[_account[i]] = false;
                values[i] = true;
            }
        }

        emit SetSaleAdminsEvent(_account, values);
    }
    
    function revokeSaleAdmins(address[] memory _account) public onlySuperAdmin {
        bool[] memory values = new bool[](_account.length);
        
        for(uint256 i = 0; i < _account.length; i++ ){
            if(saleAdminList[_account[i]] && !blackList[_account[i]]) {
                blackList[_account[i]] = true;
                values[i] = false;
            }
        }

        emit SetSaleAdminsEvent(_account, values);
    }
    
    function setCreatorAdmin(address _account) public notZeroAddress(_account) onlySuperAdmin notUsers(_account) {
        require(!isUser[_account] && !saleAdminList[_account], "Implementation: Account was not set as creator admin");
        if(creatorAdmins[_account] && !blackList[_account]) {
            revert("Implementation: Account was already set as creator admin");
        }
        creatorAdmins[_account] = true;
        blackList[_account] = false;
        emit SetCreatorAdminEvent(_account, true);
    }
    
    function revokeCreatorAdmin(address _account) public notZeroAddress(_account) onlySuperAdmin {
        require(!blackList[_account] && creatorAdmins[_account], "Implementation: Account was not set as creator admin");
        blackList[_account] = true;
        emit SetCreatorAdminEvent(_account, false);
    }
    
    function setCreatorAdmins(address[] memory _account) public onlySuperAdmin {
        bool[] memory values = new bool[](_account.length);
        
        for(uint256 i = 0; i < _account.length; i++ ){
            if(_account[i] != address(0) 
            && !isUser[_account[i]] && !saleAdminList[_account[i]] 
            ) {
                if(creatorAdmins[_account[i]] && !blackList[_account[i]]) {
                    continue;
                }
                creatorAdmins[_account[i]] = true;
                blackList[_account[i]] = false;
                values[i] = true;
            }
        }

        emit SetCreatorAdminsEvent(_account, values);
    }
    
    function revokeCreatorAdmins(address[] memory _account) public onlySuperAdmin {
        bool[] memory values = new bool[](_account.length);
        
        for(uint256 i = 0; i < _account.length; i++ ){
            if(creatorAdmins[_account[i]] && !blackList[_account[i]]) {
                blackList[_account[i]] = true;
                values[i] = false;
            }
        }

        emit SetCreatorAdminsEvent(_account, values);
    }

    /**
     * @dev Add or remove an account from the blacklist
     * @param _account the wallet address
     * @param _value true/false
     */
    function setBlackList(address _account, bool _value) public onlyOwner {
        blackList[_account] = _value;
    }

    /**
     * @dev Add or remove an account from the signer list
     * @param _account the wallet address
     */
    function setSigner(address _account)
        public
        notCurrentAddress(signer, _account)
        notZeroAddress(_account)
        onlySuperAdmin
    {
        signer = _account;
        emit SetSignerEvent(_account);
    }
    
    /**
     * @dev Add or remove an account from the signer list
     * @param _account the wallet address
     */
    function setRecipient(address _account)
        public
        notCurrentAddress(recipient, _account)
        notZeroAddress(_account)
        onlySuperAdmin
    {
        recipient = _account;
    }

    /**
     * @dev Add an account as super admin
     * @param _addr the wallet address
     */
    function setSuperAdmin(address _addr) public 
        notCurrentAddress(superAdmin, _addr)
        notZeroAddress(_addr)
        notUsers(_addr)
        onlyOwner
    {
        require(!blackList[_addr], "Implementation: Account was revoked");
        superAdmin = _addr;
        emit SetSuperAdminEvent(_addr);
    }




    // == GETTER == //
    /**
     * @dev Return an account is admin or not
     */
    function isSaleAdmin(address _account) public view returns (bool) {
        return saleAdminList[_account] || _account == owner();
    }
    
    function isCreatorAdmin(address _account) public view returns (bool) {
        return creatorAdmins[_account] || _account == owner();
    }

    /**
     * @dev Return an account is blacklisted or not
     */
    function isBlacklisted(address _account) public view returns (bool) {
        return blackList[_account];
    }

    /**
     * @dev Return an account is signer or not
     */
    function isSigner(address _account) public view returns (bool) {
        return signer == _account;
    }

    function isAdmin(address _account) public view returns (bool role) {
        if(_account == owner()) {
            role = true;
        } else if (saleAdminList[_account] && !blackList[_account]) {
            role = true;
        } else if (creatorAdmins[_account] && !blackList[_account]) {
            role = true;
        } else if (_account == superAdmin) {
            role = true;
        } else {
            role = false;
        }

    }

    /**
     * @dev Set the buy handler's address
     * @param _stakingHandler the address of mint handler
     */
    function setStakingHandler(address _stakingHandler)
        public
        notCurrentAddress(stakingHandler, _stakingHandler)
        notZeroAddress(_stakingHandler)
        onlySuperAdmin
    {
        stakingHandler = _stakingHandler;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SaleOrder, MintRequest, BuyRequest, RentOrder, RentRequest, StakeRequest} from "../common/Structs.sol";
import {HashUtils} from "./HashUtils.sol";

library SignatureUtils {
    using HashUtils for bytes32;
    using HashUtils for SaleOrder;
    using HashUtils for MintRequest;
    using HashUtils for BuyRequest;
    using HashUtils for RentOrder;
    using HashUtils for RentRequest;
    using HashUtils for StakeRequest;



    /**
     * @dev Returns the result of comparision between the recovered address and the input address
     * @param _saleOrder the sale order item
     * @param _signature the signature of the sale order
     * @param _signer the input address
     * @return result true/false
     */
    function verifySaleOrder(
        SaleOrder memory _saleOrder,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        bytes32 hash = _saleOrder.hashSaleOrder();
        bytes32 ethSignedHash = hash.getEthSignedHash();

        return ethSignedHash.recoverSigner(_signature) == _signer;
    }

    /**
     * @dev Returns the result of comparision between the recovered address and the input address
     * @param _rentOrder the rent order item
     * @param _signature the signature of the rent order
     * @param _signer the input address
     * @return result true/false
     */
    function verifyRentOrder(
        RentOrder memory _rentOrder,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        bytes32 hash = _rentOrder.hashRentOrder();
        bytes32 ethSignedHash = hash.getEthSignedHash();

        return ethSignedHash.recoverSigner(_signature) == _signer;
    }
    /**
     * @dev Returns the result of comparision between the recovered address and the input address
     * @param _buyRequest the buy request item
     * @param _signature the signature of the buy request
     * @param _signer the input address
     * @return result true/false
     */
    function verifyBuyRequest(
        BuyRequest memory _buyRequest,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        bytes32 hash = _buyRequest.hashBuyRequest();
        bytes32 ethSignedHash = hash.getEthSignedHash();

        return ethSignedHash.recoverSigner(_signature) == _signer;
    }

     /**
     * @dev Returns the result of comparision between the recovered address and the input address
     * @param _mintRequest the mint request item
     * @param _signature the signature of the mint request
     * @param _signer the input address
     * @return result true/false
     */
    function verifyMintRequest(
        MintRequest memory _mintRequest,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        bytes32 hash = _mintRequest.hashMintRequest();
        bytes32 ethSignedHash = hash.getEthSignedHash();

        return ethSignedHash.recoverSigner(_signature) == _signer;
    }

    /**
     * @dev Returns the result of comparision between the recovered address and the input address
     * @param _rentRequest the rent request item
     * @param _signature the signature of the rent request
     * @param _signer the input address
     * @return result true/false
     */
    function verifyRentRequest(
        RentRequest memory _rentRequest,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        bytes32 hash = _rentRequest.hashRentRequest();
        bytes32 ethSignedHash = hash.getEthSignedHash();

        return ethSignedHash.recoverSigner(_signature) == _signer;
    }

     /**
     * @dev Returns the result of comparision between the recovered address and the input address
     * @param _stakeRequest the stake request item
     * @param _signature the signature of the rent request
     * @param _signer the input address
     * @return result true/false
     */
    function verifyStakeRequest(
        StakeRequest memory _stakeRequest,
        bytes memory _signature,
        address _signer
    ) public pure returns (bool) {
        bytes32 hash = _stakeRequest.hashStakeRequest();
        bytes32 ethSignedHash = hash.getEthSignedHash();

        return ethSignedHash.recoverSigner(_signature) == _signer;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Upgradeable is Ownable, ReentrancyGuard, IERC721Receiver {

    // == VARIABLES == //
    address public collection721;
    address public collection1155;
    address public mintHandler;
    address public buyHandler;
    address public cancelHandler;
    address public adminMintHandler;
    address public recipient;
    address public signer;
    uint64 constant public DAY_TO_SECOND = 86400;
    address public rentHandler;
    uint256 public adminFee;
    address public superAdmin;
    address public rentFeeRecipient;
    
    mapping(address => bool) saleAdminList;
    mapping(address => bool) blackList;
    mapping(address => bool) creatorAdmins;

    mapping(bytes => bool) public invalidSaleOrder;
    mapping(bytes => uint256) public soldQuantityBySaleOrder;   // signature sale order -> sold quantity
    mapping(bytes => uint256) public soldQuantity;              // nftId -> sold quantity
    mapping(bytes => bool) public invalidRentOrder;
    
    mapping(address => bool) public isUser;

    uint256 constant ONE_DAY_IN_SECONDS = 86400;
    uint256 constant ONE_YEAR_IN_SECONDS = 31536000;
    uint256 public totalAmountStaked; // balance of nft and token staked to the pools
    uint256 public totalRewardClaimed; // total reward user has claimed
    uint256 public totalPoolCreated; // total pool created by admin
    uint256 public totalRewardFund; // total pools reward fund
    uint256 public totalUserStaked; // total user has staked to pools
    address public rewardToken; // reward token address
    mapping(bytes => PoolInfo) public poolInfo; // poolId => data: pools info
    mapping(address => uint256) public totalStakedBalancePerUser; // userAddr => amount: total value users staked to the pool
    mapping(address => uint256) public totalRewardClaimedPerUser; // userAddr => amount: total reward users claimed
    mapping(bytes => mapping(address => StakingData)) public tokenStakingData; // poolId => user => token staked data
    mapping(bytes => mapping(address => mapping(uint256 => StakingData))) public nftStaked; // poolId => owner => tokenId => data
    mapping(bytes => mapping(address => uint256)) public stakedBalancePerUser; // poolId => userAddr => amount: total value each user staked to the pool
    mapping(bytes => mapping(address => uint256)) public rewardClaimedPerUser; // poolId => userAddr => amount: reward each user has claimed
    mapping(bytes => mapping(address => uint256)) public totalNftStakedInPool; // poolId => userAddr => amount: totalNftStakedInPool by user 

    address public stakingHandler;
    mapping(uint256 => bytes) tokenStakedIn;
    mapping(uint256 => address) tokenOwnedBy;


    struct StakingData {
        uint256 balance; // staked value
        uint256 stakedTime; // staked time
        uint256 unstakedTime; // unstaked time
        uint256 reward; // the total reward
        uint256 rewardPerTokenPaid; // reward per token paid
        address account; // staked account
    }
    
    struct PoolInfo {
        // address stakingToken; // nft reward token or token staking of the pool
        uint256 stakedAmount; // amount of nfts staked to the pool
        uint256 stakedBalance; // total balance staked the pool
        uint256 totalRewardClaimed; // total reward user has claimed
        uint256 rewardFund; // pool amount for reward token available
        uint256 initialFund; // initial reward fund
        uint256 lastUpdateTime; // last update time
        uint256 rewardPerTokenStored; // reward distributed
        uint256 totalUserStaked; // total user staked
        // uint256 poolType; // 0: nft, 1: token
        uint256 active; // pool activation status, 0: disable, 1: active
        uint256[] configs; // startDate(0), endDate(1), duration(2), endStakeDate(3)
    }



    modifier onlyAdmins() {
        require(
            saleAdminList[msg.sender] || msg.sender == owner() || msg.sender == superAdmin,
            "Implementation: Only admins"
        );
        _;
    }

    modifier notBlocked() {
        require(!blackList[msg.sender], "Implementation: Caller was blocked");
        _;
    }

    modifier notZeroAddress(address _addr) {
        require(_addr != address(0), "Implemenation: Receive a zero address");
        _;
    }

    modifier notCurrentAddress(address _current, address _target) {
        require(
            _target != _current,
            "Implementation: Cannot set to the current address"
        );
        _;
    }

    modifier notAdmins() {
        require(!saleAdminList[msg.sender], "Implementation: Not for sale admins");
        _;
    }

    modifier onlySuperAdmin(){
        require(msg.sender == superAdmin || msg.sender == owner());
        _;
    }


    modifier notUsers(address _addr) {
        require(!isUser[_addr], "Implementation: Not for user");
        _;
    }

    modifier poolExist(bytes memory poolId) {
        require(poolInfo[poolId].initialFund != 0, "Pool is not exist");
        require(poolInfo[poolId].active == 1, "Pool has been disabled");
        _;
    }



    // == EVENTS == //
    event SetSaleAdminEvent(address indexed account, bool value);
    
    event SetSaleAdminsEvent(address[] accounts, bool[] values);
    
    event SetCreatorAdminEvent(address indexed account, bool value);
    
    event SetCreatorAdminsEvent(address[] accounts, bool[] values);

    event SetSignerEvent(address indexed account);

    event SetSuperAdminEvent( address indexed account);

    event SetAdminFeeEvent(uint256 fee);

    event RentNFTEvent(
        uint256 tokenId,
        uint256 totalFee,
        uint256 expDate,
        uint256 startDate,
        address owner,
        address renter,
        bytes transactionId
    );

    event PutUpForRentEvent(
        uint256 tokenId,
        uint256 expDate,
        uint256 startDate,
        uint256 fee,
        address tokenAddress,
        address owner,
        bytes transactionId
    );

    event CancelPutUpForRentEvent(
        uint256 tokenId,
        uint256 expDate,
        uint256 fee,
        address tokenAddress,
        address owner,
        bytes transactionId
    );

    event StakingEvent(
        uint256 amount, 
        address indexed account,
        bytes poolId,
        bytes internalTxID,
        uint256 eventType // (0) stake, (1) unstake(not claim), (2) claimReward (3) unstake(claim)
    );
    
    event PoolUpdated(
        uint256 rewardFund,
        address indexed creator,
        bytes poolId,
        bytes internalTxID,
        uint256 eventType // (0) createPool, (1) updatePool
    );

    // == COMMON FUNCTIONS == //
    function _delegatecall(address _impl) internal virtual {
        require(
            _impl != address(0),
            "Implementation: impl address is zero address"
        );
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(
                sub(gas(), 10000),
                _impl,
                0,
                calldatasize(),
                0,
                0
            )
            let size := returndatasize()
            returndatacopy(0, 0, size)
            switch result
            case 0 {
                revert(0, size)
            }
            default {
                return(0, size)
            }
        }
    }


    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override pure returns (bytes4){
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IProxy {
    function collection721() external view returns (address);

    function collection1155() external view returns (address);

    function invalidSaleOrder(bytes calldata saleOrderSignature)
        external
        view
        returns (bool);

    function isSigner(address account) external view returns (bool);

    function isAdmin(address account) external view returns (bool);

    function soldQuantityBySaleOrder(bytes calldata saleOrderSignature)
        external
        view
        returns (uint256);

    function proxyOwner() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


struct SaleOrder {
    uint256 onSaleQuantity;
    uint256 price;
    uint256 tokenType;
    address seller;
    bytes saleOrderId;      // internalTxId
}

struct MintRequest {
    uint256 totalCopies;
    uint256 amount;
    uint256 priceConvert;
    address buyer;
    address tokenAddress;
    bytes nftId;
    bytes saleOrderSignature;
    bytes transactionId;    // internalTxId
}

struct BuyRequest {
    uint256 tokenId;
    uint256 amount;
    uint256 royaltyFee;
    address buyer;
    address tokenAddress;
    bytes saleOrderSignature;
    bytes transactionId;    // internalTxId
}

struct RentOrder {
    uint256 tokenId;
    uint256 fee; //per day
    uint256 expirationDate;
    uint256 deadline;
    address owner;
    address tokenAddress;
    bytes transactionId;    // internalTxId
}

struct RentRequest {
    uint256 tokenId;
    uint256 expDate;
    uint256 totalPrice;
    uint256 deadline;
    address renter;
    address tokenAddress;
    bytes transactionId;    // internalTxId
}


struct StakeRequest {
    uint256 tokenId;
    address owner;
    bytes poolId;
    bytes internalTxId;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Utils} from "./Utils.sol";
import {AssemblyUtils} from "./AssemblyUtils.sol";
import {SaleOrder, MintRequest, BuyRequest, RentOrder, RentRequest, StakeRequest} from "../common/Structs.sol";

library HashUtils {
    using Utils for MintRequest;
    using Utils for SaleOrder;
    using Utils for BuyRequest;
    using Utils for RentOrder;
    using Utils for RentRequest;
    using Utils for StakeRequest;
    using AssemblyUtils for uint256;


    /**
     * @dev Returns the hash of a mint request
     * @param _mintRequest the mint request item
     * @return hash the hash of mint request
     */
    function hashMintRequest(MintRequest memory _mintRequest)
        internal
        pure
        returns (bytes32 hash)
    {
        uint256 size = _mintRequest.sizeOfMintRequest();
        bytes memory array = new bytes(size);
        uint256 index;

        assembly {
            index := add(array, 0x20)
        }

        index = index.writeUint256(_mintRequest.totalCopies);
        index = index.writeUint256(_mintRequest.amount);
        index = index.writeUint256(_mintRequest.priceConvert);
        index = index.writeAddress(_mintRequest.buyer);
        index = index.writeAddress(_mintRequest.tokenAddress);
        index = index.writeBytes(_mintRequest.nftId);
        index = index.writeBytes(_mintRequest.saleOrderSignature);
        index = index.writeBytes(_mintRequest.transactionId);

        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }

    /**
     * @dev Returns the hash of a buy request
     * @param _buyRequest the buy request item
     * @return hash the hash of buy request
     */
    function hashBuyRequest(BuyRequest memory _buyRequest)
        internal
        pure
        returns (bytes32 hash)
    {
        uint256 size = _buyRequest.sizeOfBuyRequest();
        bytes memory array = new bytes(size);
        uint256 index;

        assembly {
            index := add(array, 0x20)
        }
        index = index.writeUint256(_buyRequest.tokenId);
        index = index.writeUint256(_buyRequest.amount);
        index = index.writeUint256(_buyRequest.royaltyFee);
        index = index.writeAddress(_buyRequest.buyer);
        index = index.writeAddress(_buyRequest.tokenAddress);
        index = index.writeBytes(_buyRequest.saleOrderSignature);
        index = index.writeBytes(_buyRequest.transactionId);

        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }

    /**
     * @dev Returns the hash of a rent request
     * @param _rentRequest the rent request item
     * @return hash the hash of rent request
     */
    function hashRentRequest(RentRequest memory _rentRequest)
        internal
        pure
        returns (bytes32 hash)
    {
        uint256 size = _rentRequest.sizeOfRentRequest();
        bytes memory array = new bytes(size);
        uint256 index;

        assembly {
            index := add(array, 0x20)
        }
        index = index.writeUint256(_rentRequest.tokenId);
        index = index.writeUint256(_rentRequest.expDate);
        index = index.writeUint256(_rentRequest.totalPrice);
        index = index.writeUint256(_rentRequest.deadline);
        index = index.writeAddress(_rentRequest.renter);
        index = index.writeAddress(_rentRequest.tokenAddress);
        index = index.writeBytes(_rentRequest.transactionId);

        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }

    /**
     * @dev Returns the hash of a rent order
     * @param _rentOrder the rent request item
     * @return hash the hash of rent order
     */
    function hashRentOrder(RentOrder memory _rentOrder)
        internal
        pure
        returns (bytes32 hash)
    {
        uint256 size = _rentOrder.sizeOfRentOrder();
        bytes memory array = new bytes(size);
        uint256 index;

        assembly {
            index := add(array, 0x20)
        }
        index = index.writeUint256(_rentOrder.tokenId);
        index = index.writeUint256(_rentOrder.fee);
        index = index.writeUint256(_rentOrder.expirationDate);
        index = index.writeUint256(_rentOrder.deadline);
        index = index.writeAddress(_rentOrder.owner);
        index = index.writeAddress(_rentOrder.tokenAddress);
        index = index.writeBytes(_rentOrder.transactionId);

        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }
    
    /**
     * @dev Returns the hash of a sale order
     * @param _saleOrder the mint request item
     * @return hash the hash of sale order
     */
    function hashSaleOrder(SaleOrder memory _saleOrder)
        internal
        pure
        returns (bytes32 hash)
    {
        uint256 size = _saleOrder.sizeOfSaleOrder();
        bytes memory array = new bytes(size);
        uint256 index;

        assembly {
            index := add(array, 0x20)
        }

        index = index.writeUint256(_saleOrder.onSaleQuantity);
        index = index.writeUint256(_saleOrder.price);
        index = index.writeUint256(_saleOrder.tokenType);
        index = index.writeAddress(_saleOrder.seller);
        index = index.writeBytes(_saleOrder.saleOrderId);

        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }

    /**
     * @dev Returns the hash of a rent request
     * @param _stakeRequest the rent request item
     * @return hash the hash of stake request
     */
    function hashStakeRequest(StakeRequest memory _stakeRequest)
        internal
        pure
        returns (bytes32 hash)
    {
        uint256 size = _stakeRequest.sizeOfStakeRequest();
        bytes memory array = new bytes(size);
        uint256 index;

        assembly {
            index := add(array, 0x20)
        }
        index = index.writeUint256(_stakeRequest.tokenId);
        index = index.writeAddress(_stakeRequest.owner);
        index = index.writeBytes(_stakeRequest.poolId);
        index = index.writeBytes(_stakeRequest.internalTxId);


        assembly {
            hash := keccak256(add(array, 0x20), size)
        }
    }


    /**
     * @dev Returns the eth-signed hash of the hash data
     * @param hash the input hash data
     * @return ethSignedHash the eth signed hash of the input hash data
     */
    function getEthSignedHash(bytes32 hash) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    /**
     * @dev Returns the address which is recovered from the signature and the hash data
     * @param _hash the eth-signed hash data
     * @param _signature the signature which was signed by the admin
     * @return signer the address recovered from the signature and the hash data
     */
    function recoverSigner(bytes32 _hash, bytes memory _signature)
        internal
        pure
        returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (_signature.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(_hash, v, r, s);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {SaleOrder, MintRequest, BuyRequest, RentOrder, RentRequest, StakeRequest} from "../common/Structs.sol";

library Utils {
    /**
     * @dev Returns the size of a sale order struct
     */
    function sizeOfSaleOrder(SaleOrder memory _item)
        internal
        pure
        returns (uint256)
    {
        return ((0x20 * 3) + (0x14 * 1) + _item.saleOrderId.length);
    }

    /**
     * @dev Returns the size of a mint request struct
     */
    function sizeOfMintRequest(MintRequest memory _item)
        internal
        pure
        returns (uint256)
    {
        return ((0x20 * 3) +
            (0x14 * 2) +
            _item.nftId.length +
            _item.saleOrderSignature.length +
            _item.transactionId.length);
    }

    /**
     * @dev Returns the size of a buy request struct
     */
    function sizeOfBuyRequest(BuyRequest memory _item)
        internal
        pure
        returns (uint256)
    {
        return ((0x20 * 3) +
            (0x14 * 2) +
            _item.saleOrderSignature.length +
            _item.transactionId.length);
    }

    /**
     * @dev Returns the size of a rent order struct
     */
    function sizeOfRentOrder(RentOrder memory _item)
        internal
        pure
        returns (uint256)
    {
        return ((0x20 * 4) +
            (0x14 * 2) +
            _item.transactionId.length);
    }

    /**
     * @dev Returns the size of a rent request struct
     */
    function sizeOfRentRequest(RentRequest memory _item)
        internal
        pure
        returns (uint256)
    {
        return ((0x20 * 4) +
            (0x14 * 2) +
            _item.transactionId.length);
    }

    /**
     * @dev Returns the size of a sale order struct
     */
    function sizeOfStakeRequest(StakeRequest memory _item)
        internal
        pure
        returns (uint256)
    {
        return ((0x20 * 1) + (0x14 * 1) + _item.poolId.length 
        + _item.internalTxId.length);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library AssemblyUtils {
    function writeUint8(uint256 index, uint8 source)
        internal
        pure
        returns (uint256)
    {
        assembly {
            mstore8(index, source)
            index := add(index, 0x1)
        }
        return index;
    }

    function writeAddress(uint256 index, address source)
        internal
        pure
        returns (uint256)
    {
        uint256 conv = uint256(uint160(source)) << 0x60;
        assembly {
            mstore(index, conv)
            index := add(index, 0x14)
        }
        return index;
    }

    function writeUint256(uint256 index, uint256 source)
        internal
        pure
        returns (uint256)
    {
        assembly {
            mstore(index, source)
            index := add(index, 0x20)
        }
        return index;
    }

    function writeUint64(uint256 index, uint64 source)
        internal
        pure
        returns (uint256)
    {
        assembly {
            mstore(index, source)
            index := add(index, 0x8)
        }
        return index;
    }


    function writeBytes(uint256 index, bytes memory source)
        internal
        pure
        returns (uint256)
    {
        if (source.length > 0) {
            assembly {
                let length := mload(source)
                let end := add(source, add(0x20, length))
                let arrIndex := add(source, 0x20)
                let tempIndex := index
                for {

                } eq(lt(arrIndex, end), 1) {
                    arrIndex := add(arrIndex, 0x20)
                    tempIndex := add(tempIndex, 0x20)
                } {
                    mstore(tempIndex, mload(arrIndex))
                }
                index := add(index, length)
            }
        }
        return index;
    }
}