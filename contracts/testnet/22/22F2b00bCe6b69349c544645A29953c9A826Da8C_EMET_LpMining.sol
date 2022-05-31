// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../contracts/other/EMET_NFT.sol";
import "../contracts/other/random_generator.sol";
import "./interface/router2.sol";

// interface nftCons {
//     function tokenURI(uint256) external view returns (string memory);
//     function tokenOfOwnerByIndex(address, uint) external view returns(uint);
// }

interface EMET {
   function whoIsYourInvitor (address) external view returns (address);
}

contract EMET_LpMining is ERC721Holder, Ownable, RandomGenerator{
    event AddPool(uint indexed _type, address indexed LP, address indexed outputToken);
    event Deposit(address indexed user, uint256 indexed pid, uint256 indexed amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 indexed amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 indexed amount);

    // using SafeMath for uint;
    using SafeERC20 for IERC20;
    EMET_NFT public IBox721;
    uint private lenPos=10;
    uint private lenShare=100;
    uint private lenBox=1000;

    address public EMETToken;
    address public EMETNft;
    address public blackHold = 0x000000000000000000000000000000000000dEaD;

    uint public boxCardId;
    uint public lockCoe = 7;
    uint public randomCoe = 50;
    uint public sustainedReleaseTime = 60 days;
    uint public constant Acc = 1e18;
    uint[4] public bonusCoe = [50, 25, 15, 10]; // /1000

    struct PoolInfo_Pos {
        bool status;
        uint lpTVL;
        uint dailyOut; // How many daily output from this pool.
        uint debtInPool; // debt
        uint claimedAmount;
        uint lastRewardTime;
        uint startTime;
        uint endTime;
        uint lp_LockTime;
        address lpToken;
        address outputToken;
    }
    mapping (uint256 => mapping(address => UserInfo_Pos)) public userInfo_Pos;

    struct UserInfo_Pos {
        uint amount;     // How many LP tokens the user has provided.
        uint userDebt; // Reward debt. See explanation below.
        uint toClaim;
        uint claimed;
        uint lockReward;

        uint depositTime;
        uint lastClaimtTime;
        uint rewardLockTime;
    }
    mapping (uint256 => PoolInfo_Pos) public poolInfo_Pos;

    struct PoolInfo_Share {
        bool status;
        uint lpTVL;
        uint share;
        uint claimedAmount;
        uint lastRewardTime;
        uint startTime;
        uint endTime;
        uint lp_LockTime;
        uint updataTime;
        address lpToken;
        address outputToken;
    }
    mapping (uint256 => PoolInfo_Share) public poolInfo_Share;

    struct UserInfo_Share {
        uint amount;     // How many LP tokens the user has provided.
        uint toClaim;
        uint claimed;
        uint lockReward;

        uint depositTime;
        uint rewrdTime;
        uint lastClaimtTime;
        uint rewardLockTime;
    }
    mapping(uint256 => mapping(address => UserInfo_Share)) public userInfo_Share;

    struct PoolInfo_Box {
        bool status;
        bool randomBoxStatus;
        uint lpTVL;
        uint share;
        uint claimedSweepstakesForAll;
        uint lastRewardTime;
        uint startTime;
        uint endTime;
        // uint reward_ReleaseTime;
        uint updataTime;
        address lpToken;
    }
    struct UserInfo_Box {
        uint amount;     // How many LP tokens the user has provided.
        uint toClaim;
        uint depositTime;
        uint rewrdTime;
        uint lastClaimtTime;

        uint claimedSweepstakes;
        uint usedSweepstakes;
        uint boxAmount;
    }
    mapping (uint256 => PoolInfo_Box) public poolInfo_Box;
    mapping (uint256 => mapping(address => UserInfo_Box)) public userInfo_Box;


    mapping(address => bool) public isAdmin;
    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Admin: caller is not the Admin");
        _;
    }

    function setAdmin(address add_, bool b) public onlyOwner {
        isAdmin[add_] = b;
    }

    constructor(address token_, address nft_){
        setAddress(30000, nft_, token_);
        isAdmin[msg.sender] = true;
    }
    // ----------------------------------------  Dev add  --------------------------------------------

    function addPoolPos(address LP_, address outputToken_, uint dailyOut_, uint startTime_, uint endTime_,uint lp_LockTime) public onlyAdmin returns(uint pid){
        pid = lenPos;
        require(block.timestamp < startTime_ && startTime_ < endTime_, "out of time");

        poolInfo_Pos[pid] = PoolInfo_Pos(true,0,dailyOut_,0,0,startTime_,startTime_,endTime_,lp_LockTime,LP_,outputToken_);
        lenPos += 1;
        uint type_ = 0;
        emit AddPool(type_, address(LP_), address(outputToken_));
    }

    function addPoolShare(address LP_, address outputToken_, uint share_, uint startTime_, uint endTime_,uint lp_LockTime, uint updataTime_) public onlyAdmin returns(uint pid){
        pid = lenShare;
        require(block.timestamp < startTime_ && startTime_ < endTime_, "out of time");

        poolInfo_Share[pid] = PoolInfo_Share(true, 0, share_, 0, startTime_, startTime_, endTime_, lp_LockTime, updataTime_, LP_, outputToken_);
        lenShare += 1;
        uint type_ = 1;
        emit AddPool(type_, address(LP_), address(outputToken_));
    }

    function addPoolBox(address LP_, uint share_, uint startTime_, uint endTime_, uint updataTime_) public onlyAdmin returns(uint pid){
        pid = lenBox;
        require(block.timestamp < startTime_ && startTime_ < endTime_, "out of time");
        poolInfo_Box[pid] = PoolInfo_Box(true, true, 0, share_, 0, startTime_,startTime_,endTime_, updataTime_, LP_);
        lenBox +=1;
         uint type_ = 2;
        emit AddPool(type_, address(LP_), address(0));
    }

    // ----------------------------------------  Dev set  --------------------------------------------
    function setAddress(uint boxCardId_, address nft_, address token_) public onlyOwner {
        boxCardId = boxCardId_;
        EMETNft = nft_;
        IBox721 = EMET_NFT(nft_);
        EMETToken = token_;
    }

    function setTimeSustainedReleaseTime(uint time_) public onlyAdmin {
        sustainedReleaseTime = time_;
    }

    function setRandomBoxStatus(uint pid_, bool b) public onlyAdmin {
        poolInfo_Box[pid_].randomBoxStatus = b;
    }

    function setClosePool(uint type_, uint pid_)  public onlyAdmin {
        if(type_ == 0) {
            poolInfo_Pos[pid_].status = false;
            poolInfo_Pos[pid_].endTime = block.timestamp;
        } else if (type_ == 1) {
            poolInfo_Share[pid_].status = false;
            poolInfo_Share[pid_].endTime = block.timestamp;
        } else if (type_ == 2) {
            poolInfo_Box[pid_].status = false;
            poolInfo_Box[pid_].endTime = block.timestamp;
        }
    }

    function setBonusCoe(uint[4] calldata bonus_) public onlyAdmin {
        require(bonus_[0] + bonus_[1] + bonus_[2] + bonus_[3] == 100,"amount worng");
        bonusCoe = bonus_;
    }
    // ----------------------------------------  Check  --------------------------------------------

    function checkInvitor(address user_) public view returns(address[10] memory _inv) {
        address inv = user_;
        for(uint i = 0; i<10; i++) {
            _inv[i] = EMET(EMETToken).whoIsYourInvitor(inv);
        }
    }

    function poolIds() public view returns(uint[3] memory){
        return [lenPos, lenShare, lenBox];
    }

    function teamBonus(address outputToken, uint bonus) internal {
       
        uint _bonus = bonus;
        address[10] memory _invitor = checkInvitor(msg.sender);
        
        for (uint i=0; i<10; i++) {
            if (_invitor[i] == address(0)) {
                ERC20(outputToken).transfer(blackHold, bonus);    
                break;
            } else if (_invitor[i] != address(0)) {
                if(i == 0) {
                    ERC20(outputToken).transfer(_invitor[i], _bonus * bonusCoe[0] / 1000);
                    bonus -= _bonus * bonusCoe[0] / 1000;
                } else if (1 <= i && i < 4) {
                    ERC20(outputToken).transfer(_invitor[i], _bonus * bonusCoe[1] / 3000);     
                    bonus -= _bonus * bonusCoe[1] / 3000;
                } else if (4 <= i && i < 7) {
                    ERC20(outputToken).transfer(_invitor[i], _bonus * bonusCoe[2] / 3000);     
                    bonus -= _bonus * bonusCoe[2] / 3000; 
                } else if (7<= i && i< 9) {
                    ERC20(outputToken).transfer(_invitor[i], _bonus * bonusCoe[3] / 3000);
                    bonus -= _bonus * bonusCoe[3] / 3000;  
                } else if (i == 9) {
                    ERC20(outputToken).transfer(_invitor[i], bonus);
                    bonus = 0;
                }
            }
        }
    }

    // ----------------------------------------  Pos  --------------------------------------------
    // calculate debt
    function updataPoolDebt_Pos(uint pid_) public view returns (uint _debt){
        PoolInfo_Pos storage pool = poolInfo_Pos[pid_];
        uint _rate = pool.dailyOut / 1 days;
        if (block.timestamp < pool.endTime){
            // daily
            _debt = pool.lpTVL > 0 ? _rate * (block.timestamp - pool.lastRewardTime) * Acc / pool.lpTVL + pool.debtInPool : 0 + pool.debtInPool;
        } else if (block.timestamp >= pool.endTime) {
            if (pool.lastRewardTime >= pool.endTime) {
                // end 
                _debt = pool.debtInPool;
            } else if (pool.lastRewardTime < pool.endTime) {
                // first, updata
                _debt = pool.lpTVL > 0 ? _rate * (pool.endTime - pool.lastRewardTime) * Acc / pool.lpTVL + pool.debtInPool : 0 + pool.debtInPool;
            }
        }
    }
    
    // calculate user reward
    function updataUserReward_Pos(uint pid_, address user_) view public returns (uint _reward) {
        UserInfo_Pos storage user = userInfo_Pos[pid_][user_];
        uint _debt;

        _debt = updataPoolDebt_Pos(pid_);
        _reward = (_debt - user.userDebt) * user.amount / Acc;
    }
    
    function updataLockReward_Pos(uint pid_, address user_) view public returns (uint _temp) {
        UserInfo_Pos storage user = userInfo_Pos[pid_][user_];
        if(user.lockReward != 0) {
            _temp = user.lockReward * (block.timestamp - user.lastClaimtTime) / (user.rewardLockTime - user.lastClaimtTime);
        }

    } 

    // Update reward variables of the given pool to be up-to-date.
    function updatePool_Pos(uint pid_) public {
        PoolInfo_Pos storage pool = poolInfo_Pos[pid_];
        if (block.timestamp <= pool.lastRewardTime || block.timestamp <= pool.startTime) {
            return;
        }
        if (!pool.status){
            return;
        }
        uint _lpSupply = ICnnPair(pool.lpToken).balanceOf(address(this));
        if (_lpSupply == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }
        uint _debt = updataPoolDebt_Pos(pid_);
        pool.debtInPool = _debt;
        pool.lastRewardTime = block.timestamp;

        if (block.timestamp > pool.endTime){
            pool.status = false;
        }
    }

    // Deposit LP tokens to Contract .
    function deposit_Pos(uint256 pid_, uint256 amountIn_) public {
        PoolInfo_Pos storage pool = poolInfo_Pos[pid_];
        UserInfo_Pos storage user = userInfo_Pos[pid_][msg.sender];

        require(amountIn_ > 0, '0 is not good');
        require (pool.status && block.timestamp >= pool.startTime && block.timestamp < pool.endTime, 'deposit no good, status');

        if (user.amount > 0) {
            uint pending = updataUserReward_Pos(pid_, msg.sender);
            user.toClaim += pending;
        }
        user.userDebt = updataPoolDebt_Pos(pid_);
        updatePool_Pos(pid_);
        // user
        user.amount += amountIn_;
        user.depositTime = block.timestamp;
        user.lastClaimtTime = user.depositTime;
        // pool
        pool.lpTVL += amountIn_;

        ICnnPair(pool.lpToken).transferFrom(msg.sender, address(this), amountIn_);

        emit Deposit(msg.sender, pid_, amountIn_);
    }

    // Claim rewards from designated pool
    function claim_Pos(uint256 pid_) public {
        PoolInfo_Pos storage pool = poolInfo_Pos[pid_];
        UserInfo_Pos storage user = userInfo_Pos[pid_][msg.sender];
        require (user.amount > 0 || user.lockReward > 0, 'no amount');
        
        uint _reward = updataUserReward_Pos(pid_, msg.sender);
        uint reward = _reward;
        // to claim
        if (user.toClaim > 0) {
            uint _temp2 = user.toClaim;
            _reward += _temp2;
            reward = _reward;
            user.toClaim = 0;
        }
        // new lock reward
        if (reward > 0) {
            uint lock = _reward * lockCoe / 10;
            _reward -= lock; 
            reward = _reward;
            // user lock
            user.lockReward += lock;
        }
        // sustained release
        if (user.lockReward != 0) {
            uint _temp1 = updataLockReward_Pos(pid_, msg.sender);
            user.lockReward -= _temp1;
            _reward += _temp1;
            reward = _reward;
        }
        // team
        uint bonus = _reward / 10;
        teamBonus(pool.outputToken, bonus);
        reward -= bonus;
        // user
        user.claimed += reward;
        user.userDebt = updataPoolDebt_Pos(pid_);
        user.lastClaimtTime = block.timestamp;

        if (user.amount > 0) {
            user.rewardLockTime = block.timestamp + sustainedReleaseTime;
        }

        // pool
        pool.claimedAmount += _reward;
        if(reward > 0) {
            ERC20(pool.outputToken).transfer(address(msg.sender), reward);
        }

        emit Claim(msg.sender, pid_, reward);
    }

    // Withdraw LP tokens from Contract.
    function withdraw_Pos(uint256 pid_, uint256 amountOut_) public {
        PoolInfo_Pos storage pool = poolInfo_Pos[pid_];
        UserInfo_Pos storage user = userInfo_Pos[pid_][msg.sender];     
        require (amountOut_ > 0, '0 is not good');
        require(user.amount >= amountOut_, "withdraw: amount not good");
        bool _withdraw;
        if (pool.lp_LockTime == 0) {
            _withdraw = true;
        } else {
            if (block.timestamp >= (user.depositTime + pool.lp_LockTime) || block.timestamp > pool.endTime){
                _withdraw = true;
            }
        }
        require(_withdraw, "withdraw: not yet time");
        claim_Pos(pid_);
        if (amountOut_ > 0 ){
            user.amount -= amountOut_;
            ICnnPair(pool.lpToken).transfer(address(msg.sender), amountOut_);
        }
        updatePool_Pos(pid_);
        pool.lpTVL -= amountOut_;

        emit Withdraw(msg.sender, pid_, amountOut_);
    }

    // ----------------------------------------  Share  --------------------------------------------
    
    // calculate user reward
    function updataUserReward_Share(uint pid_, address user_) view public returns (uint _reward) {
        UserInfo_Share storage user = userInfo_Share[pid_][user_];
        PoolInfo_Share storage pool = poolInfo_Share[pid_];
        if (pool.share !=0 && pool.updataTime != 0) {
            if ((block.timestamp - user.rewrdTime) > pool.updataTime) {
                _reward = ((block.timestamp - user.rewrdTime) / pool.updataTime) * 1 ether * (user.amount / pool.share);
            } else {
                _reward = 0;
            }
        }
    }

    function updataLockReward_Share(uint pid_, address user_) view public returns(uint _temp){
        UserInfo_Share storage user = userInfo_Share[pid_][user_];
        if (user.lockReward != 0){
            _temp = user.lockReward * (block.timestamp - user.lastClaimtTime) / (user.rewardLockTime - user.lastClaimtTime);
        }
    }
    
    function updataUserRewardTime_Share(uint pid_, address user_) internal {
        UserInfo_Share storage user = userInfo_Share[pid_][user_];
        PoolInfo_Share storage pool = poolInfo_Share[pid_];
        while ((block.timestamp - user.rewrdTime) > pool.updataTime) {
            user.rewrdTime += pool.updataTime;
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool_Share(uint pid_) public {
        PoolInfo_Share storage pool = poolInfo_Share[pid_];   
        if (block.timestamp <= pool.lastRewardTime || block.timestamp <= pool.startTime) {
            return;
        }
        if (!pool.status){
            return;
        }

        // while(block.timestamp - pool.lastRewardTime > pool.updataTime){
        //     pool.lastRewardTime += pool.updataTime;
        // }
        pool.lastRewardTime = block.timestamp;
        if (block.timestamp > pool.endTime){
            pool.status = false;
        }
    }

    // Deposit LP tokens to Contract .
    function deposit_Share(uint256 pid_, uint256 amountIn_)public returns(bool){
        UserInfo_Share storage user = userInfo_Share[pid_][msg.sender];
        PoolInfo_Share storage pool = poolInfo_Share[pid_];
        
        require(amountIn_ > 0, '0 is not good');
        require (pool.status && block.timestamp >= pool.startTime && block.timestamp < pool.endTime, 'deposit no good, status');

        if (user.amount > 0) {
            uint pending = updataUserReward_Share(pid_, msg.sender);
            user.toClaim += pending;
            updataUserRewardTime_Share(pid_, msg.sender);
        } else {
            user.rewrdTime = block.timestamp;
        }
        // user
        user.amount += amountIn_;
        user.depositTime = block.timestamp;
        user.lastClaimtTime = user.depositTime;

        // pool
        pool.lpTVL += amountIn_;
        updatePool_Share(pid_);
        

        emit Deposit(msg.sender, pid_, amountIn_);
        return true;
    }

    // Claim rewards from designated pool
    function claim_Share(uint256 pid_)public returns(bool){
        UserInfo_Share storage user = userInfo_Share[pid_][msg.sender];
        PoolInfo_Share storage pool = poolInfo_Share[pid_];
        require (user.amount > 0 || user.lockReward > 0, 'no amount');
        updatePool_Share(pid_);
        uint _reward = updataUserReward_Share(pid_, msg.sender);
        uint reward = _reward;
        // to claim
        if (user.toClaim > 0) {
            uint _temp2 = user.toClaim;
            _reward += _temp2;
            reward = _reward;
            user.toClaim = 0;
        }
        // new lock reward
        uint lock;
        if (reward > 0) {
            lock = _reward * lockCoe / 10;
            _reward -= lock; 
            reward = _reward;
        }
        // sustained release
        if (user.lockReward != 0) {
            uint _temp1 = updataLockReward_Share(pid_, msg.sender);
            user.lockReward -= _temp1;
            _reward += _temp1;
            reward = _reward;
        }
        // team
        uint bonus = _reward / 10;
        teamBonus(pool.outputToken, bonus);
        reward -= bonus;
        // user
        user.claimed += reward;
        user.lastClaimtTime = block.timestamp;
        // user.rewrdTime = block.timestamp;
        
        user.lockReward += lock;
        updataUserRewardTime_Share(pid_, msg.sender);

        if (user.amount > 0) {
            user.rewardLockTime = block.timestamp + sustainedReleaseTime;
        }

        // pool
        pool.claimedAmount += _reward;
        
        if(reward > 0){
            ERC20(pool.outputToken).transfer(address(msg.sender), reward);
        }

        emit Claim(msg.sender, pid_, reward);    
        return true;
    }

    // Withdraw LP tokens from Contract.
    function withdraw_Share(uint256 pid_, uint256 amountOut_) public returns(bool){
        UserInfo_Share storage user = userInfo_Share[pid_][msg.sender];
        PoolInfo_Share storage pool = poolInfo_Share[pid_];   
        require (amountOut_ > 0, '0 is not good');
        require(user.amount >= amountOut_, "withdraw: amount not good");
        bool _withdraw;
        if (pool.lp_LockTime == 0) {
            _withdraw = true;
        } else {
            if (block.timestamp >= (user.depositTime + pool.lp_LockTime) || block.timestamp > pool.endTime){
                _withdraw = true;
            }
        }
        require(_withdraw, "withdraw: not yet time");
        claim_Share(pid_);
        if (amountOut_ > 0 ){
            user.amount -= amountOut_;
            ICnnPair(pool.lpToken).transfer(address(msg.sender), amountOut_);
        }

        pool.lpTVL -= amountOut_;

        emit Withdraw(msg.sender, pid_ , amountOut_);
        return true;
    }

    // ----------------------------------------  Box Box  --------------------------------------------

    function updataUserReward_Box(uint pid_, address user_)public view returns(uint _reward) {
        UserInfo_Box storage user = userInfo_Box[pid_][user_];
        PoolInfo_Box storage pool = poolInfo_Box[pid_];
        if (pool.updataTime != 0 && pool.share != 0) {
            if ((block.timestamp - user.rewrdTime) > pool.updataTime) {
                _reward = ((block.timestamp - user.rewrdTime) / pool.updataTime) * (user.amount / pool.share);
            } else {
                _reward = 0;
            }
        }
    }

    function updataUserRewardTime_Box(uint pid_, address user_) internal {
        UserInfo_Box storage user = userInfo_Box[pid_][user_];
        PoolInfo_Box storage pool = poolInfo_Box[pid_];
        while ((block.timestamp - user.rewrdTime) > pool.updataTime) {
            user.rewrdTime += pool.updataTime;
        }
    }
    // Update reward variables of the given pool to be up-to-date.
    function updatePool_Box(uint pid_) public {
        PoolInfo_Box storage pool = poolInfo_Box[pid_];
        if (block.timestamp <= pool.lastRewardTime || block.timestamp <= pool.startTime) {
            return;
        }
        if (!pool.status){
            return;
        }

        // pool
        // while(block.timestamp - pool.lastRewardTime > pool.updataTime){
            // pool.lastRewardTime += pool.updataTime;
        // }
        pool.lastRewardTime = block.timestamp;
        if (block.timestamp > pool.endTime){
            pool.status = false;
        }
    }

    function deposit_Box(uint pid_ ,uint256 amountIn_)public returns(bool){
        UserInfo_Box storage user = userInfo_Box[pid_][msg.sender];
        PoolInfo_Box storage pool = poolInfo_Box[pid_];
        require(amountIn_ > 0, '0 is not good');
        require(pool.status && block.timestamp >= pool.startTime && block.timestamp < pool.endTime, 'deposit no good, status');
        if (user.amount > 0) {
            uint pending = updataUserReward_Box(pid_, msg.sender);
            user.toClaim += pending;
            updataUserRewardTime_Box(pid_, msg.sender);
        } else {
            user.rewrdTime = block.timestamp;
        }
        // user
        user.amount += amountIn_;
        user.depositTime = block.timestamp;
        user.lastClaimtTime = user.depositTime;
        // pool
        pool.lpTVL += amountIn_;
        updatePool_Box(pid_);
        
        emit Deposit(msg.sender, pid_, amountIn_);
        return true;
    }

    function claim_Box(uint256 pid_)public returns(uint){
        UserInfo_Box storage user = userInfo_Box[pid_][msg.sender];
        PoolInfo_Box storage pool = poolInfo_Box[pid_];
        require (user.amount > 0, 'no amount');
        updatePool_Box(pid_);

        uint _reward;
        uint reward;
        // cycle
        if (pool.lastRewardTime > user.rewrdTime) {
            _reward = updataUserReward_Box(pid_, msg.sender);
            reward = _reward;
        }
        // to claim
        if (user.toClaim > 0) {
            uint _temp = user.toClaim;
            _reward += _temp;
            reward = _reward;
            user.toClaim = 0;
        }
        if (reward > 0) {
            // user
            user.claimedSweepstakes += reward;

            user.lastClaimtTime = block.timestamp;
            updataUserRewardTime_Box(pid_, msg.sender);
            // pool
            pool.claimedSweepstakesForAll += reward;

        }

        emit Claim(msg.sender, pid_, reward);
        return reward;
    }

    // Withdraw LP tokens from Contract.
    function withdraw_Box(uint256 pid_, uint256 amountOut_) public returns(bool){
        UserInfo_Box storage user = userInfo_Box[pid_][msg.sender];
        PoolInfo_Box storage pool = poolInfo_Box[pid_]; 
        require (amountOut_ > 0, '0 is not good');
        require(user.amount >= amountOut_, "withdraw: amount not good");

        claim_Box(pid_);
        if (amountOut_ > 0 ){
            user.amount -= amountOut_;
            ERC20(pool.lpToken).transfer(address(msg.sender), amountOut_);
        }

        pool.lpTVL -= amountOut_;

        emit Withdraw(msg.sender, pid_ , amountOut_);
        return true;
    }

    function randomBox(uint pid_, uint time_) public returns(uint boxs) {
        UserInfo_Box storage user = userInfo_Box[pid_][msg.sender];
        require(poolInfo_Box[pid_].randomBoxStatus == true);
        require(time_ <= (user.claimedSweepstakes - user.usedSweepstakes));
        uint level = randomCeil(100);
        for (uint i=0; i< time_; i++) {
            level = randomCeil(100);
            if (level >= randomCoe) {
                IBox721.mint(msg.sender, boxCardId);
                user.boxAmount += 1;
                user.usedSweepstakes += 1;
                boxs += 1;
            } else {
                user.usedSweepstakes += 1;
            }
        }
    }

    // ----------------------------------------  Front  --------------------------------------------

    function checkUserReward(uint type_, uint pid_, address user_) public view returns(uint _re) {
        UserInfo_Box storage user_Box = userInfo_Box[pid_][msg.sender];
        UserInfo_Pos storage user_Pos = userInfo_Pos[pid_][user_];
        UserInfo_Share storage user_Share = userInfo_Share[pid_][user_];
        uint _temp1;
        if (type_ == 0 ) {
            _re = updataUserReward_Pos(pid_, user_) + user_Pos.toClaim;
            if (user_Pos.lockReward != 0) {
                _temp1 = user_Share.lockReward * (block.timestamp - user_Pos.lastClaimtTime) / (user_Pos.rewardLockTime - user_Pos.lastClaimtTime);
                _re += _temp1;
            }
        } else if (type_ == 1 ) {
            _re = updataUserReward_Share(pid_, user_) + user_Share.toClaim;
            if (user_Share.lockReward != 0) {
                _temp1 = user_Share.lockReward * (block.timestamp - user_Share.lastClaimtTime) / (user_Share.rewardLockTime - user_Share.lastClaimtTime);
                _re += _temp1;
            }
        } else if (type_ == 2) {
            _re = updataUserReward_Box(pid_, user_) + user_Box.toClaim;
        }
    }

    function checkAblePool() public view returns(uint[] memory pools, bool[] memory bools){
        uint len = (lenPos-10)+(lenShare-100)+(lenBox-1000);
        pools = new uint[](len);
        bools = new bool[](len);
        uint x;
        for(uint a=10; a<lenPos;a++) {
            pools[x] = a;
            bools[x] = poolInfo_Pos[a].status;
            x+=1;
        }
        for(uint b=100; b<lenPos;b++) {
            pools[x] = b;
            bools[x] = poolInfo_Pos[b].status;
            x+=1;
        }
        for(uint c=1000; c<lenPos;c++) {
            pools[x] = c;
            bools[x] = poolInfo_Pos[c].status;
            x+=1;
        }
        return(pools, bools);
    }

    function checkInfoAllType (uint[] calldata pid_, address user_)
    public view returns ( bool[] memory statuss, address[] memory lpToken, uint[] memory depositTimes, uint[] memory amounts, uint[] memory toClaims, uint[] memory claimeds, string[2][] memory symbels) {
        uint len = pid_.length;

        statuss = new bool[](len);
        depositTimes = new uint[](len);
        amounts = new uint[](len);
        toClaims = new uint[](len);
        claimeds = new uint[](len);
        symbels = new string[2][](len);
        // uint x = 0;                                           
        for (uint i=0; i<len; i++) {
            if(pid_[i]>=10 && pid_[i]<100) {
                (statuss[i], lpToken[i], depositTimes[i], amounts[i], toClaims[i], claimeds[i], symbels[i]) = checkPosInfo(pid_[i], user_);
            } else if (pid_[i]>=100 && pid_[i]<1000) {
                (statuss[i], lpToken[i], depositTimes[i], amounts[i], toClaims[i], claimeds[i], symbels[i]) = checkShareInfo(pid_[i], user_);
            } else if (pid_[i]>=1000) {
                (statuss[i], lpToken[i], depositTimes[i], amounts[i], toClaims[i], claimeds[i], symbels[i]) = checkBoxInfo(pid_[i], user_);
            }
        }
    }

    function checkPosInfo(uint pid_, address user_) public view 
    returns(bool _status, address _lpToken, uint _depositTimes, uint _amounts, uint _toClaims, uint _claimed, string[2] memory _symbel) {
        PoolInfo_Pos storage pool = poolInfo_Pos[pid_];
        UserInfo_Pos storage user = userInfo_Pos[pid_][user_];
        _symbel = ["null", "null"];
        _lpToken = pool.lpToken;
        if(_lpToken != address(0)){
            address _t0 = ICnnPair(_lpToken).token0();
            address _t1 = ICnnPair(_lpToken).token1();
            _symbel[0] = ERC20(_t0).symbol();
            _symbel[1] = ERC20(_t1).symbol();
        }

        _status = pool.status;
        _depositTimes = user.depositTime;
        _amounts = user.amount;
        _claimed = user.claimed;
        uint temp1 =  updataUserReward_Pos(pid_, user_);
        uint temp2=0;
        if(user.lockReward > 0) {
            temp2 =  updataLockReward_Share(pid_, msg.sender);
        }
        _toClaims = user.toClaim + temp1 + temp2;
    }

    function checkShareInfo(uint pid_, address user_) public view 
    returns(bool _status, address _lpToken, uint _depositTimes, uint _amounts, uint _toClaims, uint _claimed, string[2] memory _symbel ) {
        PoolInfo_Share storage pool = poolInfo_Share[pid_];
        UserInfo_Share storage user = userInfo_Share[pid_][user_];
        _symbel = ["null", "null"];
        _lpToken = pool.lpToken;
        if(_lpToken != address(0)){
            address _t0 = ICnnPair(_lpToken).token0();
            address _t1 = ICnnPair(_lpToken).token1();
            _symbel[0] = ERC20(_t0).symbol();
            _symbel[1] = ERC20(_t1).symbol();
        }

        _status = pool.status;
        _depositTimes = user.depositTime;
        _amounts = user.amount;
        _claimed = user.claimed;

        uint temp1 =  updataUserReward_Share(pid_, user_);
        uint temp2=0;
        if(user.lockReward > 0) {
            temp2 =  updataLockReward_Share(pid_, msg.sender);
        }
        _toClaims = user.toClaim + temp1 + temp2;
    }

    function checkBoxInfo(uint pid_, address user_) public view 
    returns(bool _status, address _lpToken, uint _depositTimes, uint _amounts, uint _toClaims, uint _claimed, string[2] memory _symbel) {
        PoolInfo_Box storage pool = poolInfo_Box[pid_];
        UserInfo_Box storage user = userInfo_Box[pid_][user_];
        _symbel = ["null", "null"];
        _lpToken = pool.lpToken;
        if(_lpToken != address(0)){
            address _t0 = ICnnPair(_lpToken).token0();
            address _t1 = ICnnPair(_lpToken).token1();
            _symbel[0] = ERC20(_t0).symbol();
            _symbel[1] = ERC20(_t1).symbol();
        }
        _status = pool.status;
        _depositTimes = user.depositTime;
        _amounts = user.amount;
        _claimed = user.claimedSweepstakes;
        uint temp1 =  updataUserReward_Box(pid_, user_);
        _toClaims = user.toClaim + temp1;
    }

    function checkUserNftTime(uint pid_, address user_) public view returns (uint usableTimes, uint usedTimes, uint allTimes){
        UserInfo_Box storage user = userInfo_Box[pid_][user_];
        allTimes = user.claimedSweepstakes;
        usedTimes = user.usedSweepstakes;
        usableTimes = allTimes - usedTimes;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RandomGenerator {
    uint private randNonce = 0;

    function random(uint256 seed) internal returns (uint256) {
        randNonce += 1;
        return uint256(keccak256(abi.encodePacked(
                blockhash(block.number - 1),
                blockhash(block.number - 2),
                blockhash(block.number - 3),
                blockhash(block.number - 4),
                blockhash(block.number - 5),
                blockhash(block.number - 6),
                blockhash(block.number - 7),
                blockhash(block.number - 8),
                block.timestamp,
                msg.sender,
                randNonce,
                seed
            )));
    }

    function randomCeil(uint256 q) internal returns (uint256) {
        return (random(gasleft()) % q) + 1;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract EMET_NFT is Ownable, ERC721Enumerable, ERC721URIStorage {
    using Address for address;
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct CardInfo {
        uint cardId;
        string name;
        uint currentAmount;
        uint burnedAmount;
        uint maxAmount;
        string tokenURI;
    }

    mapping (address => bool) public superMinters;
    mapping(uint => CardInfo) public cardInfoes;  
    mapping(uint => uint) public cardIdMap;
    mapping(address => mapping(uint => uint)) public minters;
    address public superMinter;
    string public myBaseURI;
    uint public burned;
    

    // for inherit
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        ERC721._burn(tokenId);
    }
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        ERC721Enumerable._beforeTokenTransfer(from, to, tokenId);
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return interfaceId == type(IERC721).interfaceId
        || interfaceId == type(IERC721Enumerable).interfaceId
        || interfaceId == type(IERC721Metadata).interfaceId
        || super.supportsInterface(interfaceId);
    }

    function setTokenId(uint number_) public onlyOwner {
        for (uint i = 0; i < number_; i++) {
            _tokenIds.increment();
        }
    }

    function setSuperMinter(address newSuperMinter_, bool b) public onlyOwner returns (bool) {
        superMinters[newSuperMinter_] = b;
        return true;
    }

    function setMinterBatch(address newMinter_, uint[] calldata ids_, uint[] calldata amounts_) public onlyOwner returns (bool) {
        require(ids_.length > 0 && ids_.length == amounts_.length,"ids and amounts length mismatch");
        for (uint i = 0; i < ids_.length; ++i) {
            minters[newMinter_][ids_[i]] = amounts_[i];
        }
        return true;
    }

    event Divest(address token, address payee, uint value);
    function divest(address token_, address payee_, uint value_) external onlyOwner {
        if (token_ == address(0)) {
            payable(payee_).transfer(value_);
            emit Divest(address(0), payee_, value_);
        } else {
            IERC20(token_).transfer(payee_, value_);
            emit Divest(address(token_), payee_, value_);
        }
    }

    constructor(string memory name_, string memory symbol_, string memory myBaseURI_) ERC721(name_, symbol_) {
        myBaseURI = myBaseURI_;
        superMinter = msg.sender;
    }

    function setMyBaseURI(string calldata uri_) public onlyOwner {
        myBaseURI = uri_;
    }

    event NewCard(uint indexed cardId, uint indexed maxAmount);
    function newCard(string calldata name_, uint cardId_, uint maxAmount_, string calldata tokenURI_) public onlyOwner {
        require(cardId_ != 0 && cardInfoes[cardId_].cardId == 0, "K: wrong cardId");

        cardInfoes[cardId_] = CardInfo({
        cardId : cardId_,
        name : name_,
        currentAmount : 0,
        burnedAmount : 0,
        maxAmount : maxAmount_,
        tokenURI : tokenURI_
        });
    }

    function newCardMulti(string[] calldata names_, uint[] calldata cardIds_, uint[] calldata maxAmounts_, string[] calldata tokenURIs_)public onlyOwner {
        // require(cardId_ != 0 && cardInfoes[cardId_].cardId == 0, "K: wrong cardId");
        uint len = cardIds_.length;
        for (uint i=0; i<len; i++) {
            newCard(names_[i], cardIds_[i], maxAmounts_[i], tokenURIs_[i]);
        }
    }


    function newBurnedCard(string calldata name_, uint cardId_, uint maxAmount_, string calldata tokenURI_, uint burnedAmount_) public onlyOwner {
        require(cardId_ != 0 && cardInfoes[cardId_].cardId == 0, "K: wrong cardId");

        cardInfoes[cardId_] = CardInfo({
        cardId : cardId_,
        name : name_,
        currentAmount : burnedAmount_,
        burnedAmount : burnedAmount_,
        maxAmount : maxAmount_,
        tokenURI : tokenURI_
        });
    }

    // 编辑卡片
    function editCard(string calldata name_, uint cardId_, uint maxAmount_, string calldata tokenURI_) public onlyOwner {
        require(cardId_ != 0 && cardInfoes[cardId_].cardId == cardId_, "K: wrong cardId");

        cardInfoes[cardId_] = CardInfo({
        cardId : cardId_,
        name : name_,
        currentAmount : cardInfoes[cardId_].currentAmount,
        burnedAmount : cardInfoes[cardId_].burnedAmount,
        maxAmount : maxAmount_,
        tokenURI : tokenURI_
        });
    }

    // 
    function getNextTokenId() public returns(uint) {
       _tokenIds.increment();
       return  _tokenIds.current();
    }
   
    // 铸造
    function mint(address player_, uint cardId_) public returns (uint) {
        require(cardId_ != 0 && cardInfoes[cardId_].cardId != 0, "K: wrong cardId");

        if (superMinter != _msgSender() || !superMinters[_msgSender()]) {
            require(minters[_msgSender()][cardId_] > 0, "K: not minter");
            minters[_msgSender()][cardId_] -= 1;
        }

        require(cardInfoes[cardId_].currentAmount < cardInfoes[cardId_].maxAmount, "k: amount out of limit");
        cardInfoes[cardId_].currentAmount += 1;

        uint tokenId = getNextTokenId();
        cardIdMap[tokenId] = cardId_;
        _safeMint(player_, tokenId);

        return tokenId;
    }

    // 批量铸造-1
    function mintMulti(address player_, uint cardId_, uint amount_) public returns (uint[] memory) {
        require(amount_ > 0, "K: missing amount");
        require(cardId_ != 0 && cardInfoes[cardId_].cardId != 0, "K: wrong cardId");

        if (superMinter != _msgSender()) {
            require(minters[_msgSender()][cardId_] >= amount_, "K: not minter");
            minters[_msgSender()][cardId_] -= amount_;
        }

        require(cardInfoes[cardId_].maxAmount - cardInfoes[cardId_].currentAmount >= amount_, "K: amount out of limit");
        cardInfoes[cardId_].currentAmount += amount_;

        uint tokenId;
        uint[] memory info = new uint[](amount_);
        for (uint i = 0; i < amount_; ++i) {
            tokenId = getNextTokenId();
            cardIdMap[tokenId] = cardId_;
            _safeMint(player_, tokenId);
            info[i] = tokenId;
        }
        return info;
    }

    // 批量铸造-2
    function mintBatch(address player_, uint[] calldata ids_, uint[] calldata amounts_) public returns (bool) {
        require(ids_.length > 0 && ids_.length == amounts_.length, "length mismatch");
        for (uint i = 0; i < ids_.length; ++i) {
            mintMulti(player_, ids_[i], amounts_[i]);
        }
        return true;
    }

    // 销毁
    function burn(uint tokenId_) public returns (bool){
        require(_isApprovedOrOwner(_msgSender(), tokenId_), "K: burner isn't owner");

        uint cardId = cardIdMap[tokenId_];
        cardInfoes[cardId].burnedAmount += 1;
        burned += 1;

        _burn(tokenId_);
        return true;
    }

    // 批量销毁
    function burnMulti(uint[] calldata tokenIds_) public returns (bool) {
        for (uint i = 0; i < tokenIds_.length; ++i) {
            burn(tokenIds_[i]);
        }
        return true;
    }

    function exists(uint tokenId_) public view returns (bool) {
        return _exists(tokenId_);
    }

    // 查看某个tokenid 的 tokenUrls
    function tokenURI(uint tokenId_) override(ERC721URIStorage, ERC721) public view returns (string memory) {
        require(_exists(tokenId_), "K: nonexistent token");

        return string(abi.encodePacked(_myBaseURI(), '/', cardInfoes[cardIdMap[tokenId_]].tokenURI));
    }

    // 查看地址的所有tokenUrls
    function batchTokenURI(address account_) public view returns (string[] memory) {
        uint amount = balanceOf(account_);
        uint tokenId;
        string[] memory info = new string[](amount);
        for (uint i = 0; i < amount; i++) {
            tokenId = tokenOfOwnerByIndex(account_, i);
            info[i] = tokenURI(tokenId);
        }
        return info;
    }

    // 查看 baseUrl
    function _myBaseURI() internal view returns (string memory) {
        return myBaseURI;
    }


    function tokenOfOwnerForAll(address addr_) public view returns(uint[] memory, uint[] memory) {
        uint len = balanceOf(addr_);
        uint id;
        uint[] memory _TokenIds = new uint[](len);
        uint[] memory _CardIds = new uint[](len);
        for(uint i=0; i<len;i++) {
            id = tokenOfOwnerByIndex(addr_, i);
            _TokenIds[i] = id;
            _CardIds[i] = cardIdMap[id];
        }
        return (_TokenIds, _CardIds);

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ICnnRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ICnnRouter02 is ICnnRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ICnnFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface ICnnPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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
interface IERC165 {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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