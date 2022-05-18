//
//              _{\ _{\{\/}/}/}__
//             {/{/\}{/{/\}(\}{/\} _
//            {/{/\}{/{/\}(_)\}{/{/\}  _
//         {\{/(\}\}{/{/\}\}{/){/\}\} /\}
//        {/{/(_)/}{\{/)\}{\(_){/}/}/}/}
//       _{\{/{/{\{/{/(_)/}/}/}{\(/}/}/}
//      {/{/{\{\{\(/}{\{\/}/}{\}(_){\/}\}
//      _{\{/{\{/(_)\}/}{/{/{/\}\})\}{/\}
//     {/{/{\{\(/}{/{\{\{\/})/}{\(_)/}/}\}
//      {\{\/}(_){\{\{\/}/}(_){\/}{\/}/})/}
//       {/{\{\/}{/{\{\{\/}/}{\{\/}/}\}(_)
//      {/{\{\/}{/){\{\{\/}/}{\{\(/}/}\}/}
//       {/{\{\/}(_){\{\{\(/}/}{\(_)/}/}\}
//         {/({/{\{/{\{\/}(_){\/}/}\}/}(\}
//          (_){/{\/}{\{\/}/}{\{\)/}/}(_)
//            {/{/{\{\/}{/{\{\{\(_)/}
//             {/{\{\{\/}/}{\{\\}/}
//              {){/ {\/}{\/} \}\}
//              (_)  \.-'.-/
//          __...--- |'-.-'| --...__
//   _...--"   .-'   |'-.-'|  ' -.  ""--..__
// -"    ' .  . '    |.'-._| '  . .  '   
// .  '-  '    .--'  | '-.'|    .  '  . '
//          ' ..     |'-_.-|
//  .  '  .       _.-|-._ -|-._  .  '  .
//              .'   |'- .-|   '.
//  ..-'   ' .  '.   `-._.-`   .'  '  - .
//   .-' '        '-._______.-'     '  .
//        .      ~,
//       .       .   |\   .    ' '-.
//       ___________/  \____________
//      / Treedefi is the first eco \
//     |  friendly project on the   |
//     |    BSC! treedefi.com       |
//     \___________________________/
//
// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./SafeMath.sol";
import "./Address.sol";
import "./IBEP20.sol";
import "./SafeBEP20.sol";
import "./Ownable.sol";
import "./ICOTReferral.sol";
import "./ICarbonToken.sol";
import "./ReEntrancyGuard.sol";

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// MasterChef is the master of COT. He can make COT and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once COT is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterchefCOT is Ownable, ReEntrancyGuard{
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    using Address for address;

    // Info of each user.
    struct UserInfo {
        uint256 amount;                 // How many LP tokens the user has provided.
        uint256 rewardDebt;             // Reward debt. See explanation below.
        uint256 rewardLockedUp;         // Reward locked up.
        uint256 lastRewardClaimed;      // Last Reward claimed blockNumber
        uint256 lockedRewardPerBlock;   // Rewards per block
        uint256 lastRewardBlock;        // Last blockNumber untill which locked rewards are available
        //
        // We do some fancy math here. Basically, any point in time, the amount of COTs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accCOTPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accCOTPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken;             // Address of LP token contract.
        uint256 allocPoint;         // How many allocation points assigned to this pool. COTs to distribute per block.
        uint256 lastRewardBlock;    // Last block number that COTs distribution occurs.
        uint256 accCOTPerShare;    // Accumulated COTs per share, times 1e12. See below.
        uint16 depositFeeBP;        // Deposit fee in basis points
        bool isHarvestLock;         // Does Pool has harvest Lock 
    }

    // The COT TOKEN!
    ICarbonToken public immutable cot;
    // referral contract address.
    ICOTReferral public cotReferral;
    // COT tokens created per block.
    uint256 public cotPerBlock;
    // start time of MasterChef
    uint256 public immutable startTime;
    // Deposit Fee addresses
    address public feeDonationAddress = address(0x14f375Ba23F52a93CB768e80F0ECA123650C22D9);
    address public feeBuybackAddress = address(0x32232a427A70f8C9019156c12Da9B3c392e07c1D);
    address public feeDevAddress = address(0xdB67A848e237E4855b1BE722b16b7eD956a7210d);
    // NFT Staking Pool address
    address public nftStakingPoolAddress;
    // Treasury address.
    address public treasuryAddress;
    // burn Address
    address constant burnAddress = address(0x000000000000000000000000000000000000dEaD);
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Lptoken amount invested on particular pool Map.
    mapping (uint256 => uint256) internal lpTokenAmount;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when COT mining starts.
    uint256 public immutable startBlock;
    // Total locked up rewards
    uint256 public totalLockedUpRewards;
    // Whitelisted Contract Address map
    mapping (address => bool) public whitelisted;
    // autoStake Pool ID
    uint256 public stakepoolId = 0;
    // Referral commission rate in basis points: 1%.
    uint16 public referralCommissionRate = 100;
    // Max referral commission rate: 10%.
    uint16 public constant MAXIMUM_REFERRAL_COMMISSION_RATE = 1000;
    // true indicate referrak scheme in ON
    // false indicate referral scheme is Paused
    bool internal referralFlag = true;
    uint256 public TREASURY_SHARE = 500; // 5% mint for DEV as harvest Reward
    uint256 public NFT_STAKING_POOL_SHARE = 7000; // 70% mint for NFT Staking Pool as harvest Reward

    uint256 constant WEEK_IN_SECONDS = 604800; 
    uint256 constant BLOCKS_IN_DAY = 28800;
    uint256 constant BLOCKS_IN_WEEK = 7 * BLOCKS_IN_DAY;
    
    uint256 constant HARVEST_LOCKUP_SHARE = 7000; // 70% pending reward will be locked
    uint256 constant HARVEST_CLAIM_SHARE = 3000;  // 30% pending reward will be released
    uint256 constant FRACTION_PRECISION = 10000;
    uint256 constant MAX_EMISSION_RATE = 10 ether; // 10 COT Token

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event SetTreasury(address indexed user, address oldAddress, address newAddress);
    event SetFeeDonationAddress(address indexed user, address newFeeDonationAddress);
    event SetFeeBuybackAddress(address indexed user, address newFeeBuybackAddress);
    event SetFeeDevAddress(address indexed user, address newFeeDevAddress);
    event SetNftStakingPoolAddress(address indexed user, address oldAddress, address newAddress);
    event UpdateEmissionRate(address indexed user, uint256 oldEmissionRate, uint256 newEmissionRate);
    event EmissionRateUpdated(address indexed caller, uint256 previousAmount, uint256 newAmount);
    event ReferralCommissionPaid(address indexed user, address indexed referrer, uint256 commissionAmount);
    event RewardLockedUp(address indexed user, uint256 indexed pid, uint256 amountLockedUp);
    event RewardHarvested(address indexed user, uint256 indexed pid, uint256 rewardAmount);
    event SetCOTReferral(address indexed user, address referralContractAddr, address newReferralContractAddr);
    event SetReferralCommissionRate(address indexed user, uint16 referralCommissionRate, uint16 newReferralCommissionRate);
    event SetNftStakingPoolCommisionRate(address indexed user, uint256 oldRate, uint256 newRate);
    event SetTreasuryCommisionRate(address indexed user, uint256 oldRate, uint256 newRate);
    event UpdateReferralFlag(address indexed user, bool referralFlag, bool newReferralFlag);
    event RewardPaid(address indexed user, uint256 reward);
    event MassHarvest(address indexed user, uint256[] poolsId, uint256 amount);
    event MassHarvestStake(address indexed user, uint256[] poolsId, bool withStake,uint256 amount);
    event UpdateStakePool(address indexed user, uint256 indexed previousId,uint256 newId);
    event RewardClaimed(address indexed user, uint256 reward);
    event AddWhiteListAddress(address indexed user, address indexed whitelistAddress);
    event RemoveWhiteListAddress(address indexed user, address indexed whitelistAddress);

    function validatePoolId(uint256 _pid) internal view{
        require(
            _pid < poolLength(),
            'MasterChef: Pool Doesnot exist'
        );        
    }

    modifier validatePoolByPid(uint256 _pid) {
        validatePoolId(_pid);
        _;
    }

    modifier onlyWhitelistOrEOA() {
        require((_msgSender() == tx.origin && !Address.isContract(_msgSender())) || 
            whitelisted[_msgSender()] , "Caller is not EOA or whitelisted contract");
        _;
    }

    constructor(
        ICarbonToken _cot,
        uint256 _cotPerBlock,
        uint256 _startBlock,
        address _referralContract,
        address _treasuryAddr,
        address _nftStakingPoolAddr
    ) public {
        require (_referralContract != address(0x0),
                '_referralContract should be valid Address');

        require (_treasuryAddr != address(0x0),
                '_treasuryAddr should be valid Address');

        require (_nftStakingPoolAddr != address(0x0),
                '_nftStakingPoolAddr should be valid Address');

        require(_startBlock >= block.number,
                '_startBlock should be future block number');

        require(_cotPerBlock != 0 && 
                 _cotPerBlock <= MAX_EMISSION_RATE,
                '_cotPerBlock should be non-zero and less the max emission rate');

        cot = _cot;
        cotPerBlock = _cotPerBlock;
        startBlock = _startBlock;
        cotReferral = ICOTReferral(_referralContract);
        nftStakingPoolAddress = _nftStakingPoolAddr;
        treasuryAddress = _treasuryAddr;
        startTime = now;
    }


////////////////////////////////View Functions ////////////////////////////////////////

    // returns total number of pool available
    function poolLength() public view returns (uint256) {
        return poolInfo.length;
    }
    
    // View function to see pending COTs on frontend.
    function pendingCOT(
        uint256 _pid, 
        address _user
    ) 
        external view
        validatePoolByPid(_pid) 
        returns (uint256) 
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accCOTPerShare = pool.accCOTPerShare;
        uint256 lpSupply = lpTokenAmount[_pid];
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 calcblocks = getCurrentPerBlock();
            uint256 cotReward = multiplier.mul(calcblocks).mul(pool.allocPoint).div(totalAllocPoint);
             
            uint256 poolCOTReward = cotReward.sub(cotReward.mul(TREASURY_SHARE.add(NFT_STAKING_POOL_SHARE)).div(FRACTION_PRECISION));

            accCOTPerShare = accCOTPerShare.add(poolCOTReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accCOTPerShare).div(1e12).sub(user.rewardDebt);
    }

    // returns referral scheme status ON/OFF
    function getReferralFlag()
        public view
        returns (bool)
    {
        return referralFlag;
    }

    // return current reward per block
    function getCurrentPerBlock() 
        public view 
        returns (uint256)
    {
        uint16 i;
        uint256 calcblocks = cotPerBlock;
        uint256 duration = now - startTime;
        uint256 mulNum = duration.div(WEEK_IN_SECONDS);
        
        for (i = 1; i < mulNum; i++) {
            calcblocks = calcblocks.mul(985000000).div(1000000000);
        }
        
        return calcblocks;
    }

    // return locked reward Details, amount of locked rewards
    // and amount of claimable rewards
    function getLockedRewardDetails(
        uint256 _pid,
        address _user
    ) 
        public view
        validatePoolByPid(_pid)
        returns (uint256 lockedAmount, uint256 claimableAmount)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        if (!pool.isHarvestLock)
            return(0,0);

        if ((block.number > user.lastRewardClaimed) && (user.rewardLockedUp != 0))
        {
            uint256 endBlock = block.number > user.lastRewardBlock ?
                                    user.lastRewardBlock :
                                    block.number;
                                        
            uint256 blockDiff = endBlock.sub(user.lastRewardClaimed);
            claimableAmount = user.lockedRewardPerBlock.mul(blockDiff);
            lockedAmount = user.rewardLockedUp.sub(claimableAmount);
        }
    }


    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(
        uint256 _from, 
        uint256 _to
    ) 
        public pure 
        returns (uint256)
    {
        return _to.sub(_from);
    }

//////////////////////////////// View Function Ends ///////////////////////////////////////////

/////////////////////////////// Internal Functions ////////////////////////////////////////////

    // Update reward variables of the given pool to be up-to-date. 
    // Internal function used for massHarvestStake for gas optimization
    function internalUpdatePool(
        uint256 _pid
    ) 
        internal 
        returns(uint256) 
    {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return 0;
        }
        uint256 lpSupply = lpTokenAmount[_pid];
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return 0;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 calcblocks = getCurrentPerBlock();
        uint256 cotReward = multiplier.mul(calcblocks).mul(pool.allocPoint).div(totalAllocPoint);
        
        uint256 poolCOTReward = cotReward.sub(cotReward.mul(TREASURY_SHARE.add(NFT_STAKING_POOL_SHARE)).div(FRACTION_PRECISION));

        pool.accCOTPerShare = pool.accCOTPerShare.add(poolCOTReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
        return cotReward;
    }

    
    //Avoid nonReentrant only for massHarvestStake autoStake method
    function internalDeposit(
        uint256 _pid, 
        uint256 _amount
    ) 
        internal
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];

        updatePool(_pid);

        if (user.amount > 0) {
            payOrLockupPendingCOT(_pid, false);
        }
        
        if(_amount > 0) {
            _amount = deflacionaryDeposit(pool.lpToken,_amount);
            if(pool.depositFeeBP > 0){
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                uint256 depositFee13 = depositFee.div(3);
                pool.lpToken.safeTransfer(feeDonationAddress, depositFee13);
                pool.lpToken.safeTransfer(feeBuybackAddress, depositFee13);
                pool.lpToken.safeTransfer(feeDevAddress, depositFee.sub(depositFee13).sub(depositFee13));
                user.amount = user.amount.add(_amount).sub(depositFee);
                lpTokenAmount[_pid] = lpTokenAmount[_pid].add(_amount.sub(depositFee));
            } else {
                user.amount = user.amount.add(_amount);
                lpTokenAmount[_pid] = lpTokenAmount[_pid].add(_amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accCOTPerShare).div(1e12);
        emit Deposit(_msgSender(), _pid, _amount);
    }

    // send deposit and check the final amount deposited by a user and if deflation occurs update amount
    function deflacionaryDeposit(
        IBEP20 token,
        uint256 _amount
    )  
        internal 
        returns(uint256)
    {
        uint256 balanceBeforeDeposit = token.balanceOf(address(this));
        token.safeTransferFrom(address(_msgSender()), address(this), _amount);
        uint256 balanceAfterDeposit = token.balanceOf(address(this));
        _amount = balanceAfterDeposit.sub(balanceBeforeDeposit);

        return _amount;
    }

    // Pay harvest and check the final amount harvested by a user and if deflation occurs update amount * used by massHarvestStake
    function deflacionaryHarvest(
        IBEP20 token,
        address to,
        uint256 _amount
    )  
        internal 
        returns(uint256)
    {
        uint256 balanceBeforeHarvest = token.balanceOf(to);
        safeCOTTransfer(to, _amount);
        uint256 balanceAfterHarvest = token.balanceOf(to);
        _amount = balanceAfterHarvest.sub(balanceBeforeHarvest);

        return _amount;
    }

    // Pay or lockup pending COT's.
    function payOrLockupPendingCOT(
        uint256 _pid,
        bool isMassHarvest
    ) 
        internal
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        uint256 totalRewards;

        uint256 pending = user.amount.mul(pool.accCOTPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            if (pool.isHarvestLock) {            
                if ((user.rewardLockedUp > 0) &&
                            (block.number > user.lastRewardClaimed))
                {
                    uint256 endBlock = block.number > user.lastRewardBlock ?
                                            user.lastRewardBlock :
                                            block.number;
                    uint256 blockDiff = endBlock.sub(user.lastRewardClaimed);
                    totalRewards = user.lockedRewardPerBlock.mul(blockDiff);
                    user.rewardLockedUp = user.rewardLockedUp.sub(totalRewards);
                    totalLockedUpRewards = totalLockedUpRewards.sub(totalRewards);
                }

                uint256 claimShare = pending.mul(HARVEST_CLAIM_SHARE)
                                        .div(FRACTION_PRECISION);

                uint256 lockupShare = pending.sub(claimShare);   

                totalRewards += claimShare;
                user.rewardLockedUp += lockupShare;
                user.lockedRewardPerBlock = user.rewardLockedUp.div(BLOCKS_IN_WEEK);
                user.lastRewardClaimed = block.number;
                user.lastRewardBlock = block.number + BLOCKS_IN_WEEK;
                totalLockedUpRewards = totalLockedUpRewards.add(lockupShare);

                if (!isMassHarvest) {
                    // send rewards
                    safeCOTTransfer(_msgSender(), totalRewards);
                    if (referralFlag) {
                        payReferralCommission(_msgSender(), totalRewards);
                    }
                    emit RewardHarvested(_msgSender(), _pid, totalRewards);
                }
                emit RewardLockedUp(_msgSender(), _pid, lockupShare);
                return totalRewards;
            }else{
                if (!isMassHarvest) {
                    safeCOTTransfer(_msgSender(), pending);
                    if (referralFlag) {
                        payReferralCommission(_msgSender(), pending);
                    }
                    emit RewardHarvested(_msgSender(), _pid, pending);
                }
                return pending;
            }
        }
    }

    // Safe cot transfer function, just in case if rounding error causes pool to not have enough COTs.
    function safeCOTTransfer(
        address _to,
        uint256 _amount
    ) 
        internal 
    {
        uint256 cotBal = cot.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > cotBal) {
            transferSuccess = cot.transfer(_to, cotBal);
        } else {
            transferSuccess = cot.transfer(_to, _amount);
        }

        require(
            transferSuccess == true,
            'safeCOTTransfer: transfer failed'
        );
    }

    // Pay referral commission to the referrer who referred this user.
    function payReferralCommission(
        address _user, 
        uint256 _pending
    ) 
        internal
    {
        if (address(cotReferral) != address(0) && referralCommissionRate > 0) {
            address referrer = cotReferral.getReferrer(_user);
            uint256 commissionAmount = _pending.mul(referralCommissionRate).div(FRACTION_PRECISION);

            if (referrer != address(0) && commissionAmount > 0) {
                cot.mint(referrer, commissionAmount);
                cotReferral.recordReferralCommission(referrer, commissionAmount);
                emit ReferralCommissionPaid(_user, referrer, commissionAmount);
            }
        }
    }

/////////////////////////////// Internal Function Ends ////////////////////////////////////////

    // Add a new lp to the pool. Can only be called by the owner.
    // Onwer can add multiple pool with LP token.
    function add(
        uint256 _allocPoint, 
        IBEP20 _lpToken, 
        uint16 _depositFeeBP, 
        bool _withUpdate,
        bool _isHarvestLock
    ) 
        external
        onlyOwner
    {
        // if _depositFeeBP = 500 then 5% discount, 
        // if _depositFeeBP = 0 , no fee
        require(_depositFeeBP <= 500, "add: invalid deposit fee basis points");

        if (_withUpdate) {
            massUpdatePools();
        }

        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accCOTPerShare: 0,
            depositFeeBP: _depositFeeBP,
            isHarvestLock: _isHarvestLock
        }));
    }

    // Update the given pool's COT allocation point and deposit fee. Can only be called by the owner.
    function set(
        uint256 _pid, 
        uint256 _allocPoint, 
        uint16 _depositFeeBP, 
        bool _withUpdate
    ) 
        external
        onlyOwner
        validatePoolByPid(_pid)
    { 
        // if _depositFeeBP = 500 then 5% discount, 
        // if _depositFeeBP = 0 , no fee
        require(_depositFeeBP <= 500, "set: invalid deposit fee basis points");

        if (_withUpdate) {
            massUpdatePools();
        }

        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() 
        public 
    {
        uint256 length = poolLength();
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(
        uint256 _pid
    ) 
        public 
        validatePoolByPid(_pid)
    {
        PoolInfo storage pool = poolInfo[_pid];

        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        uint256 lpSupply = lpTokenAmount[_pid];
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 calcblocks = getCurrentPerBlock();
        uint256 cotReward = multiplier.mul(calcblocks).mul(pool.allocPoint).div(totalAllocPoint);

        cot.mint(address(this), cotReward);

        // harvest reward distrubution

        // 5% token will be transfered for dev team
        uint256 treasuryShare = cotReward.mul(TREASURY_SHARE).div(FRACTION_PRECISION);
        cot.transfer(treasuryAddress, treasuryShare);

        // 70% token will be transfered for NFT STaking Pool
        uint256 stakingPoolShare = cotReward.mul(NFT_STAKING_POOL_SHARE).div(FRACTION_PRECISION);
        cot.transfer(nftStakingPoolAddress, stakingPoolShare);

        // remaining 25% token will be distribute to Materchef Pool
        cotReward = cotReward.sub(treasuryShare.add(stakingPoolShare)); 

        pool.accCOTPerShare = pool.accCOTPerShare.add(cotReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for COT allocation.
    function deposit(
        uint256 _pid, 
        uint256 _amount,
        address _referrer
    ) 
        external
        nonReentrant
        onlyWhitelistOrEOA
        validatePoolByPid(_pid)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];

        updatePool(_pid);
        if (referralFlag && 
            _amount > 0 && 
            address(cotReferral) != address(0) && 
            _referrer != address(0) && 
            _referrer != _msgSender()) {
            cotReferral.recordReferral(_msgSender(), _referrer);
        }

        if (user.amount > 0) {
            payOrLockupPendingCOT(_pid, false);
        }
        
        if(_amount > 0) {
            _amount = deflacionaryDeposit(pool.lpToken,_amount);
            if(pool.depositFeeBP > 0){
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                uint256 depositFee13 = depositFee.div(3);
                pool.lpToken.safeTransfer(feeDonationAddress, depositFee13);
                pool.lpToken.safeTransfer(feeBuybackAddress, depositFee13);
                pool.lpToken.safeTransfer(feeDevAddress, depositFee.sub(depositFee13).sub(depositFee13));
                user.amount = user.amount.add(_amount).sub(depositFee);
                lpTokenAmount[_pid] = lpTokenAmount[_pid].add(_amount.sub(depositFee));
            }else{
                user.amount = user.amount.add(_amount);
                lpTokenAmount[_pid] = lpTokenAmount[_pid].add(_amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accCOTPerShare).div(1e12);
        emit Deposit(_msgSender(), _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(
        uint256 _pid, 
        uint256 _amount
    ) 
        external
        nonReentrant
        validatePoolByPid(_pid)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];

        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);
        payOrLockupPendingCOT(_pid, false);

        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(_msgSender()), _amount);
            lpTokenAmount[_pid] = lpTokenAmount[_pid].sub(_amount);
        }

        user.rewardDebt = user.amount.mul(pool.accCOTPerShare).div(1e12);
        emit Withdraw(_msgSender(), _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(
        uint256 _pid
    ) 
        external
        validatePoolByPid(_pid)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        uint256 amount = user.amount;

        if (user.rewardLockedUp > 0) {
            // Burn the unclaimed reward
            safeCOTTransfer(burnAddress, user.rewardLockedUp);
            totalLockedUpRewards = totalLockedUpRewards.sub(user.rewardLockedUp);
        }
        user.amount = 0;
        user.rewardDebt = 0;
        user.rewardLockedUp = 0;
        user.lastRewardClaimed = 0;
        user.lockedRewardPerBlock = 0;
        user.lastRewardBlock = 0;
        pool.lpToken.safeTransfer(address(_msgSender()), amount);
        lpTokenAmount[_pid] = lpTokenAmount[_pid].sub(amount);
        emit EmergencyWithdraw(_msgSender(), _pid, amount);
    }

    // Harvest all non-harvest guard and harvest guard pools in single transcation
    // _ids[] list of pools id to harvest, [] to harvest all
    function harvestAll(
        uint256[] memory _ids
    )
        external
        nonReentrant
    {
        bool zeroLength = _ids.length==0;
        uint256 idxlength = _ids.length;

        //if empty check all
        if(zeroLength)
              idxlength = poolInfo.length;

        uint256 totalPending = 0;

        for (uint256 i = 0; i < idxlength;  i++) {
            uint256 pid = zeroLength ? i :  _ids[i];
            require (pid < poolLength(),"Pool does not exist");

            PoolInfo storage pool = poolInfo[pid];
            UserInfo storage user = userInfo[pid][_msgSender()];
            if (user.amount > 0) {
                updatePool(pid);
                totalPending = totalPending.add(payOrLockupPendingCOT(pid, true));
                user.rewardDebt = user.amount.mul(pool.accCOTPerShare).div(1e12);
            }
        }

        safeCOTTransfer(_msgSender(), totalPending);
        if (referralFlag) {
            payReferralCommission(_msgSender(), totalPending);
        }

        emit MassHarvest(_msgSender(), _ids, totalPending);
    }
    
    
    // Harvest non-harvest guards pools where user has pending balance at same time!
    // _ids[] list of pools id to harvest, [0] to harvest all
    // _stake if true all pending balance is staked To Stake Pool  (stakepoolId)
    // Note: Be careful of gas spending!
    function massHarvestStake(
        uint256[] memory _ids,
        bool _stake
    ) 
        external
        nonReentrant
    {
        bool zeroLength = _ids.length == 0;
        uint256 idxlength = _ids.length;

        //if empty check all
        if(zeroLength)
              idxlength = poolLength();

        uint256 totalPending = 0;
        uint256 accumulatedCOTReward = 0;

        for (uint256 i = 0; i < idxlength;  i++) {
            uint256 pid = zeroLength ? i :  _ids[i];
            require (pid < poolLength(),"Pool does not exist");
            PoolInfo storage pool = poolInfo[pid];
            UserInfo storage user = userInfo[pid][_msgSender()];

            if (user.amount > 0 && 
                    !pool.isHarvestLock) {
                // updated updatePool to gas optimization
                accumulatedCOTReward = accumulatedCOTReward.add(internalUpdatePool(pid));

                uint256 pending = user.amount.mul(pool.accCOTPerShare).div(1e12).sub(user.rewardDebt);
                if(pending > 0) {
                    totalPending = totalPending.add(pending);
                }
                user.rewardDebt = user.amount.mul(pool.accCOTPerShare).div(1e12);
            }
        }

        if ((accumulatedCOTReward == 0) && (totalPending == 0))
            return;
        
        cot.mint(address(this), accumulatedCOTReward);

        // harvest reward distrubution
        // 5% token will be transfered for dev team
        uint256 treasuryShare = accumulatedCOTReward.mul(TREASURY_SHARE).div(FRACTION_PRECISION);
        cot.transfer(treasuryAddress, treasuryShare);

        // 70% token will be transfered for NFT STaking Pool
        uint256 stakingPoolShare = accumulatedCOTReward.mul(NFT_STAKING_POOL_SHARE).div(FRACTION_PRECISION);
        cot.transfer(nftStakingPoolAddress, stakingPoolShare);
        
        uint256 totalHarvested;
        if(totalPending > 0)
        {
            if (referralFlag) {
                payReferralCommission(_msgSender(), totalPending);
            }
            totalHarvested = deflacionaryHarvest(cot, _msgSender(), totalPending);
            emit RewardPaid(_msgSender(), totalPending);

            if( _stake && stakepoolId != 0)
            {
                internalDeposit(stakepoolId, totalHarvested);
            }
        }
        emit MassHarvestStake(_msgSender(), _ids, _stake, totalHarvested);
    }

    function claimLockedRewardsAll(
        uint256[] memory _ids
    )
        external
    {
        require(_ids.length != 0, "_ids cann't ne zero");

        uint256 _pid;
        for (uint256 i = 0; i < _ids.length;  i++) {
            _pid = _ids[i];
            validatePoolId(_pid);
            UserInfo storage user = userInfo[_pid][_msgSender()];
            
            if (user.rewardLockedUp == 0) {
                continue;
            }
            
            if (block.number > user.lastRewardClaimed)
            {
                uint256 endBlock = block.number > user.lastRewardBlock ?
                                        user.lastRewardBlock :
                                        block.number;
                uint256 blockDiff = endBlock.sub(user.lastRewardClaimed);
                uint256 claimableAmount = user.lockedRewardPerBlock.mul(blockDiff);
                if (user.rewardLockedUp > claimableAmount){
                    user.rewardLockedUp = user.rewardLockedUp.sub(claimableAmount);
                } else {
                    claimableAmount = user.rewardLockedUp;
                    user.rewardLockedUp = 0;
                }
                user.lastRewardClaimed = block.number;
                totalLockedUpRewards = totalLockedUpRewards.sub(claimableAmount);

                safeCOTTransfer(_msgSender(), claimableAmount);
                if (referralFlag) {
                    payReferralCommission(_msgSender(), claimableAmount);
                }

                emit RewardClaimed(_msgSender(), claimableAmount);
            }
        }
    }

    // function to claim locked rewards.
    function claimLockedRewards(
        uint256 _pid
    )
        external
        validatePoolByPid(_pid)
    {
        UserInfo storage user = userInfo[_pid][_msgSender()];
        
        require(user.rewardLockedUp != 0, 
                    'No pending locked rewards available');
        
        if (block.number > user.lastRewardClaimed)
        {
            uint256 endBlock = block.number > user.lastRewardBlock ?
                                    user.lastRewardBlock :
                                    block.number;
            uint256 blockDiff = endBlock.sub(user.lastRewardClaimed);
            uint256 claimableAmount = user.lockedRewardPerBlock.mul(blockDiff);
            if (user.rewardLockedUp > claimableAmount){
                user.rewardLockedUp = user.rewardLockedUp.sub(claimableAmount);
            } else {
                claimableAmount = user.rewardLockedUp;
                user.rewardLockedUp = 0;
            }
            user.lastRewardClaimed = block.number;
            totalLockedUpRewards = totalLockedUpRewards.sub(claimableAmount);

            safeCOTTransfer(_msgSender(), claimableAmount);
            if (referralFlag) {
                payReferralCommission(_msgSender(), claimableAmount);
            }

            emit RewardClaimed(_msgSender(), claimableAmount);
        }
    }

    // claim locked reward with 50% penality
    function claimLockedRewardsWithPenalty(
        uint256 _pid
    )
        external
        validatePoolByPid(_pid)
    {
        UserInfo storage user = userInfo[_pid][_msgSender()];
        
        require(user.rewardLockedUp != 0,
                    'No pending locked rewards available');

        (uint256 lockedAmount, uint256 claimableAmount) = getLockedRewardDetails(_pid, _msgSender());
        claimableAmount = claimableAmount.add(lockedAmount.div(2));
        totalLockedUpRewards = totalLockedUpRewards.sub(user.rewardLockedUp);
        user.rewardLockedUp = 0;
        user.lockedRewardPerBlock = 0;
        user.lastRewardClaimed = block.number;
        
        // Transfer 50% amount to user
        safeCOTTransfer(_msgSender(), claimableAmount);
        // burn another 50% penalty.
        safeCOTTransfer(burnAddress, lockedAmount.sub(lockedAmount.div(2)));
        if (referralFlag) {
            payReferralCommission(_msgSender(), claimableAmount);
        }

        emit RewardClaimed(_msgSender(), claimableAmount);
    }

    // Update Treasury address by the previous dev.
    function setTreasury(
        address _treasuryAddress
    ) 
        external 
        onlyOwner
    {
        require(_treasuryAddress != address(0x0), 
            "_devadd    r should be non-zero");

        emit SetTreasury(_msgSender(), treasuryAddress, _treasuryAddress);
        treasuryAddress = _treasuryAddress;
    }

    // update fee donation Address to which fee donation reward to be sent
    function setFeeDonationAddress(
        address _feeAddress
    ) 
        external 
    {
        require(_msgSender() == feeDonationAddress,
            "setFeeAddress: FORBIDDEN");

        require(_feeAddress != address(0x0), 
            "_feeAddress should be non-zero");

        emit SetFeeDonationAddress(feeDonationAddress, _feeAddress);
        feeDonationAddress = _feeAddress;
    }

    // update feeBuyback Address to which feeBuyBack reward to be sent
    function setFeeBuybackAddress(
        address _feeAddress
    ) 
        external
    {
        require(_msgSender() == feeBuybackAddress, 
            "setFeeAddress: FORBIDDEN");

        require(_feeAddress != address(0x0), 
            "_feeAddress should be non-zero");

        emit SetFeeBuybackAddress(feeBuybackAddress, _feeAddress);
        feeBuybackAddress = _feeAddress;
    }

    // update dev Address to which dev reward to be sent
    function setFeeDevAddress(
        address _feeAddress
    ) 
        external
    {
        require(_msgSender() == feeDevAddress,
            "setFeeAddress: FORBIDDEN");

        require(_feeAddress != address(0x0), 
            "_feeAddress should be non-zero");

        emit SetFeeDevAddress(feeDevAddress, _feeAddress);
        feeDevAddress = _feeAddress;
    }

    // update NFT Staking Pool Address to which dev reward to be sent
    function setNftStakingPoolAddress(
        address _address
    ) 
        external
        onlyOwner
    {
        require(_address != address(0x0), 
            "_address should be non-zero");

        emit SetNftStakingPoolAddress(msg.sender ,nftStakingPoolAddress, _address);
        nftStakingPoolAddress = _address;
    }

    // Pancake has to add hidden dummy pools inorder to alter the emission, 
    // here we make it simple and transparent to all.
    function updateEmissionRate(
        uint256 _cotPerBlock
    ) 
        external
        onlyOwner
    {
        require(_cotPerBlock != 0 && 
                 _cotPerBlock <= MAX_EMISSION_RATE,
                '_cotPerBlock should be non-zero and less the max emission rate');

        massUpdatePools();

        emit UpdateEmissionRate(_msgSender(), cotPerBlock, _cotPerBlock);
        cotPerBlock = _cotPerBlock;
    }

    //set what will be the stake pool
    function setStakePoolId(
        uint256 _id
    )  
        external
        onlyOwner  
    {

        emit UpdateStakePool(_msgSender() ,stakepoolId, _id);
        stakepoolId = _id;
    }
    
    // update referral scheme state ON/OFF
    function updateReferralFlag(
        bool _flag
    )
        external
        onlyOwner
    {
        require (referralFlag != _flag, "Invalid state update");
        emit UpdateReferralFlag(_msgSender(), referralFlag, _flag);
        referralFlag = _flag;
    }

    // Update the COT referral contract address by the owner
    function setCOTReferral(
        address _cotReferral
    ) 
        external 
        onlyOwner
    {
        require(_cotReferral != address(0x0),
            "_cotReferral should be non-zero");
        
        emit SetCOTReferral(_msgSender(), address(cotReferral), _cotReferral);
        cotReferral = ICOTReferral(_cotReferral);

        require(cotReferral.isReferralContract(), "not cot referral");
    }

    // Update referral commission rate by the owner
    function setReferralCommissionRate(
        uint16 _referralCommissionRate
    )
        external 
        onlyOwner
    {
        require(_referralCommissionRate <= MAXIMUM_REFERRAL_COMMISSION_RATE, "setReferralCommissionRate: invalid referral commission rate basis points");
        emit SetReferralCommissionRate(_msgSender(), referralCommissionRate, _referralCommissionRate);
        referralCommissionRate = _referralCommissionRate;
    }

    // Update Treasury Commssion Rate
    function setTreasuryCommisionRate(
        uint256 _rate
    )
        external 
        onlyOwner
    {
        require(_rate.add(NFT_STAKING_POOL_SHARE) <= 9000, "setTreasuryCommisionRate: invalid treasury commission rate");
        emit SetTreasuryCommisionRate(_msgSender(), TREASURY_SHARE, _rate);
        TREASURY_SHARE = _rate;
    }

    // Update NFT STaking Pool Commssion Rate
    function setNftStakingPoolCommisionRate(
        uint256 _rate
    )
        external 
        onlyOwner
    {
        require(_rate.add(TREASURY_SHARE) <= 9000, "setNftStakingPoolCommisionRate: invalid treasury commission rate");
        emit SetNftStakingPoolCommisionRate(_msgSender(), NFT_STAKING_POOL_SHARE, _rate);
        NFT_STAKING_POOL_SHARE = _rate;
    }

    // Add trusted 3rd party contract as whitelist, 
    // who can invest on treedefi platform
    function addWhiteList(
        address _whitelistAddress
    ) 
        public 
        onlyOwner
    {
        require(_whitelistAddress != address(0x0),
                        'Invalid requested whitelisted Address');
        
        whitelisted[_whitelistAddress] = true;
        emit AddWhiteListAddress(_msgSender(), _whitelistAddress);
    }

    // remove 3rd party contract from  whitelist, 
    // then onward contract address will not be 
    // allowed to invest on treedefi platform
    function removeWhiteList(
        address _whitelistAddress
    ) 
        public
        onlyOwner
    {
        require(_whitelistAddress != address(0x0),
                        'Invalid requested whitelisted Address');

        whitelisted[_whitelistAddress] = false;
        emit RemoveWhiteListAddress(_msgSender(), _whitelistAddress);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity >=0.6.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Address.sol";

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeBEP20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";
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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface ICOTReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;
    
    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(address referrer, uint256 commission) external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);

    /**
     * @dev Referral Contract Validator
     */
    function isReferralContract() external pure returns(bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.4;

import "./IBEP20.sol";

interface ICarbonToken is IBEP20 {
    // Mints Carbon tokens
    function mint(address user, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReEntrancyGuard` will make the {nonReentrant} modifier
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
abstract contract ReEntrancyGuard {
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

    constructor() public {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}