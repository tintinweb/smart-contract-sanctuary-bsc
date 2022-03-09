// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./ReentrancyGuard.sol";
import "./IERC1155.sol";

contract NFT_Farm_Pokelon is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 poolBal;
        uint256 pool_deposit_time;
        uint256 total_deposits;
        uint256 pool_payouts;
        uint256 rewardEarned;
        uint256 amount;         
        uint256 lastUpdateAt;   
        uint256 pointsDebt;     
    }

    struct PoolInfo {
        IERC20 stakeToken;
        IERC20 rewardToken;
        uint256 poolNumber;
        uint256 poolRewardPercent;
        uint256 perWalletLimit;
        uint256 minStake;
        uint256 maxStake;
        uint256 poolStaked;
        bool active;
    }

    struct NFTInfo {
        address contractAddress;
        uint256 id;             // NFT id
        uint256 remaining;      // NFTs remaining to farm
        uint256 price;          // points required to claim NFT
    }

    uint256 public totalPools = 0;
    uint256 public totalStaked;
    uint256 public totalSyarlClaimed;
    address public nftAddress;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    NFTInfo[] public nftInfo;


    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event TokenTransfer(address beneficiary, uint256 amount);
    event PoolTransfer(address beneficiary, uint256 amount);
    event RewardClaimed(address beneficiary, uint256 amount);

    mapping(address => uint256) public balances;

    constructor(address _nftAddress) {
        nftAddress = _nftAddress;
    }

    /* Recieve Accidental BNB Transfers */
    receive() external payable {}

    function add(
        IERC20 _stakeToken,
        IERC20 _rewardToken,
        uint256 _poolRewardPercent,
        uint256 _minStake,
        uint256 _maxStake,
        uint256 _perWalletLimit
    ) external onlyOwner {
        require(
            isContract(address(_stakeToken)),
            "Enter correct Staking contract address"
        );
        require(
            isContract(address(_rewardToken)),
            "Enter correct Reward contract address"
        );
        require(
            _stakeToken.decimals() == _rewardToken.decimals(),
            "Decimals should be equal"
        );

        poolInfo.push(
            PoolInfo({
                stakeToken: _stakeToken,
                rewardToken: _rewardToken,
                poolNumber: totalPools,
                poolRewardPercent: _poolRewardPercent,
                perWalletLimit: _perWalletLimit * 10**_stakeToken.decimals(),
                minStake: _minStake * 10**_stakeToken.decimals(),
                maxStake: _maxStake * 10**_stakeToken.decimals(),
                poolStaked: 0,
                active: true
            })
        );
        totalPools = totalPools + 1;
    }

    function poolActivation(uint256 _poolId, bool status) external onlyOwner {
        PoolInfo storage pool = poolInfo[_poolId];
        pool.active = status;
    }

    function changeMinMaxStakeLimit(uint256 _poolId, uint256 _minStake, uint256 _maxStake) external onlyOwner{
        PoolInfo storage pool = poolInfo[_poolId];
        IERC20 _stakeToken = pool.stakeToken;
        pool.minStake = _minStake * 10**_stakeToken.decimals();
        pool.maxStake = _maxStake * 10**_stakeToken.decimals();
    }
    
    function changePerWalletLimit(uint256 _poolId, uint256 walletLimit) external onlyOwner{
        PoolInfo storage pool = poolInfo[_poolId];
        IERC20 _stakeToken = pool.stakeToken;
        pool.perWalletLimit = walletLimit * 10**_stakeToken.decimals();
    }

    /* Stake Token Function */
    function stakePool(uint256 _poolId, uint256 _amount)
        external
        nonReentrant
        returns (bool)
    {
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][msg.sender];
        
        require(pool.active, "Pool not Active");
        require(
            _amount <= IERC20(pool.stakeToken).balanceOf(msg.sender),
            "Token Balance of user is less"
        );
        require(_amount >= pool.minStake,"Stake Min Token");
        require(_amount <= pool.maxStake,"Stake Max Token Exceeded");

        pool.stakeToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        pool.poolStaked += _amount;
        totalStaked += _amount;
        user.poolBal += _amount;
        user.total_deposits += _amount;
        user.pool_deposit_time = uint40(block.timestamp);
        // already deposited before
        if(user.amount != 0) {
            user.pointsDebt = rewardsCalculate(_poolId, msg.sender);
        }
        user.amount = user.amount.add(_amount);
        user.lastUpdateAt = block.timestamp;
        emit PoolTransfer(msg.sender, _amount);
        return true;
    }

    /* Claims Principal Token and Rewards Collected */
    function claimPool(uint256 _poolId) external nonReentrant returns (bool) {
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][msg.sender];

        require(
            user.poolBal > 0,
            "There is no deposit for this address in Pool"
        );
        uint256 calculatedRewards = rewardsCalculate(_poolId, msg.sender);

        uint256 amount = user.poolBal;
        uint256 totalReward = calculatedRewards;
        user.rewardEarned += totalReward;
        emit RewardClaimed(msg.sender, totalReward);
        uint256 principalBalance = user.poolBal;
        user.poolBal = 0;
        user.pool_deposit_time = 0;
        user.pool_payouts += amount;
        totalSyarlClaimed += totalReward;

        pool.stakeToken.safeTransfer(
            address(msg.sender),
            principalBalance
        );
        pool.rewardToken.safeTransfer(
            address(msg.sender),
            totalReward
        );

        emit TokenTransfer(msg.sender, amount);
        return true;
    }

    function addNFT(
        uint256 id,
        uint256 total,              
        uint256 price
    ) external onlyOwner {
        IERC1155(nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            id,
            total,
            ""
        );
        nftInfo.push(NFTInfo({
            contractAddress: nftAddress,
            id: id,
            remaining: total,
            price: price
        }));
    }

    function addMoreNFT(
        uint256 _nftIndex,
        uint256 total               
    ) external onlyOwner {
        NFTInfo storage nft = nftInfo[_nftIndex];

        IERC1155(nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            nft.id,
            total,
            ""
        );

        nft.remaining += total;
    }

    function changeNFTPrice(uint256 _newPrice, uint256 _nftIndex) external onlyOwner {
        NFTInfo storage nft = nftInfo[_nftIndex];
        nft.price = _newPrice;
    }

    // claim nft if points threshold reached
    function claim(uint256 poolId, uint256 _nftIndex, uint256 _quantity) public {
        NFTInfo storage nft = nftInfo[_nftIndex];
        require(nft.remaining > 0, "All NFTs farmed");
        require(rewardsCalculate(poolId, msg.sender) >= nft.price.mul(_quantity), "Insufficient Points");
        UserInfo storage user = userInfo[poolId][msg.sender];
        
        // deduct points
        user.pointsDebt = rewardsCalculate(poolId, msg.sender).sub(nft.price.mul(_quantity));
        user.lastUpdateAt = block.timestamp;
        totalSyarlClaimed += nft.price.mul(_quantity);

        // transfer nft
        IERC1155(nft.contractAddress).safeTransferFrom(
            address(this),
            msg.sender,
            nft.id,
            _quantity,
            ""
        );
        
        nft.remaining = nft.remaining.sub(_quantity);
    }
    
    function claimMultiple(uint256 _poolId,uint256[] calldata _nftIndex, uint256[] calldata _quantity) external {
        require(_nftIndex.length == _quantity.length, "Incorrect array length");
        for(uint64 i=0; i< _nftIndex.length; i++) {
            claim(_poolId,_nftIndex[i], _quantity[i]);
        }
    }
    
    // claim random nft's from available balance
    function claimRandom(uint256 poolId) public {
        for(uint64 i; i < nftCount(); i++) {
            NFTInfo storage nft = nftInfo[i];
            uint256 userBalance = rewardsCalculate(poolId,msg.sender);
            uint256 maxQty = userBalance.div(nft.price);        // max quantity of nfts user can claim
            if(nft.remaining > 0 && maxQty > 0) {
                if(maxQty <= nft.remaining) {
                    claim(poolId,i, maxQty);
                } else {
                    claim(poolId,i, nft.remaining);
                }
            }
        }
    }

    function withdraw(uint256 poolId, uint256 _amount) public {
        UserInfo storage user = userInfo[poolId][msg.sender];
        PoolInfo storage pool = poolInfo[poolId];

        require(user.amount >= _amount, "Insufficient staked");
        // update userInfo
        user.pointsDebt = rewardsCalculate(poolId,msg.sender);
        user.amount = user.amount.sub(_amount);
        user.lastUpdateAt = block.timestamp;
        user.poolBal = user.poolBal.sub(_amount);
        user.pool_deposit_time = block.timestamp;
        user.pool_payouts += _amount;
        
        pool.stakeToken.safeTransfer(
            msg.sender,
            _amount
        );
    }
    
    // claim random NFTs and withdraw all staked tokens
    function exit(uint256 poolId) external {
        UserInfo storage user = userInfo[poolId][msg.sender];
        claimRandom(poolId);
        withdraw(poolId,user.amount);
    }

    function calculateRewards(
        uint256 _poolId,
        uint256 _amount,
        address userAdd
    ) internal view returns (uint256) {
        UserInfo storage user = userInfo[_poolId][userAdd];
        PoolInfo storage pool = poolInfo[_poolId];
        return ((_amount* (pool.poolRewardPercent) * ((block.timestamp - user.lastUpdateAt) / 60 minutes))/100);
    }

    function rewardsCalculate(uint256 _poolId, address userAddress)
        public
        view
        returns (uint256)
    {
        uint256 rewards;
        UserInfo storage user = userInfo[_poolId][userAddress];

        uint256 max_payout = this.maxPayoutOf(_poolId);
        uint256 calculatedRewards = calculateRewards(
            _poolId,
            user.poolBal,
            userAddress
        );
        if (user.poolBal > 0) {
            if (calculatedRewards + user.pointsDebt > max_payout) {
                rewards = max_payout;
            } else {
                rewards = calculatedRewards + user.pointsDebt;
            }
        }
        return rewards;
    }

    function maxPayoutOf(uint256 _poolId)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_poolId];
        return
            pool.perWalletLimit;
    }

    /* Check Token Balance inside Contract */
    function tokenBalance(address tokenAddr) public view returns (uint256) {
        return IERC20(tokenAddr).balanceOf(address(this));
    }

    function nftCount() public view returns (uint256) {
        return nftInfo.length;
    }

    /* Check BSC Balance inside Contract */
    function bnbBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function retrieveBnbStuck(address payable wallet)
        public
        nonReentrant
        onlyOwner
        returns (bool)
    {
        wallet.transfer(address(this).balance);
        return true;
    }

    function retrieveBEP20TokenStuck(
        address _tokenAddr,
        uint256 amount,
        address toWallet
    ) public nonReentrant onlyOwner returns (bool) {
        IERC20(_tokenAddr).transfer(toWallet, amount);
        return true;
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

     // required function to allow receiving ERC-1155
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure returns (bytes4) {
        operator;
        from;
        id;
        value;
        data;
        return (
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            )
        );
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure returns (bytes4) {
        operator;
        from;
        ids;
        values;
        data;
        return (
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            )
        );
    }
}