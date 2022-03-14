// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
import "./IUFXReferral.sol";
import "./UFXToken.sol";
import './IBEP20.sol';
import './SafeBEP20.sol';
import './Ownable.sol';
import './ReentrancyGuard.sol';


// MasterChef is the master of UFX. He can make UFX and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once UFX is sufxiciently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterChef is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;         // How many LP tokens the user has provided.
        uint256 rewardDebt;     // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of UFXs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accUFXPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accUFXPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. UFX to distribute per block.
        uint256 lastRewardBlock;  // Last block number that UFX distribution occurs.
        uint256 accUfxPerShare;   // Accumulated UFX per share, times 1e12. See below.
        uint16 withdrawFeeBP;      // Withdraw fee in basis points
        uint16 depositFeeBP;
    }

    // The operator is NOT the owner, is the operator of the machine	
    address private _operator;	

    // The UFX TOKEN!
    UFXToken public ufx;
    // UFX tokens created per block.
    uint256 public ufxPerBlock;
    // Bonus muliplier for early UFX makers.
    uint256 public constant BONUS_MULTIPLIER = 1;
    // Deposit Fee address / Dev Address and BuyBack Wallet
    // address public feeAddBb;
    address public feeAddDev;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when UFX mining starts.
    uint256 public startBlock;
    uint16 public feeDevRate = 1200;

    // UFX referral contract address.
    
    //-----------------------------------------------------------------AlexChange
    // IUFXReferral public ufxReferral;

    // Referral commission rate in basis points.
    //-----------------------------------------------------------------AlexChange
    // uint16 public referralCommissionRate = 300;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmissionRateUpdated(address indexed user, uint256 ufxPerBlock);
    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);	
    // event ReferralCommissionPaid(address indexed user, address indexed referrer, uint256 commissionAmount);

    //emergency
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);


    constructor(
        UFXToken _ufx,
        //-----------------------------------------------------------------AlexChange
        // IUFXReferral _ufxReferral,
        // address _feeAddBb,
        address _feeAddDev,
        uint256 _ufxPerBlock,
        uint256 _startBlock
    ) public {
        ufx = _ufx;
        //-----------------------------------------------------------------AlexChange
        // ufxReferral = _ufxReferral;
        // feeAddBb = _feeAddBb;
        feeAddDev = _feeAddDev;
        ufxPerBlock = _ufxPerBlock;
        startBlock = _startBlock;
        _operator = msg.sender;	
    }

    // Operator CAN do modifier	
    modifier onlyOperator() {	
        require(_operator == msg.sender, "operator: caller is not the operator");	
        _;	
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    mapping(IBEP20 => bool) public poolExistence;

    modifier nonDuplicated(IBEP20 _lpToken) {
        require(poolExistence[_lpToken] == false, "nonDuplicated: duplicated");
        _;
    }

    modifier poolExists(uint256 pid) {
        require(pid < poolInfo.length, "pool inexistent");
        _;
    }

    modifier lpProtection(uint256 pid, uint256 _amount) {
        PoolInfo storage pool = poolInfo[pid];
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        uint256 maxWithdraw = lpSupply.mul(1500).div(10000);
        require(_amount < maxWithdraw, "withdraw: _amount is higher than maximum LP withdraw");
        _;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    function add(uint256 _allocPoint, IBEP20 _lpToken, uint16 _withdrawFeeBP, uint16 _depositFeeBP, bool _withUpdate) public onlyOwner nonDuplicated(_lpToken) {
        require(_withdrawFeeBP <= 800, "add: invalid deposit fee basis points");
        require(_depositFeeBP <= 400, "add: invalid deposit fee basis points");

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolExistence[_lpToken] = true;
        poolInfo.push(PoolInfo({
            lpToken : _lpToken,
            allocPoint : _allocPoint,
            lastRewardBlock : lastRewardBlock,
            accUfxPerShare : 0,
            withdrawFeeBP : _withdrawFeeBP,
            depositFeeBP: _depositFeeBP
        }));
    }

    // Update the given pool's UFX allocation point and deposit fee. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, uint16 _withdrawFeeBP, uint16 _depositFeeBP, bool _withUpdate) public onlyOwner poolExists(_pid) {
        require(_withdrawFeeBP <= 800, "set: invalid deposit fee basis points");
        require(_depositFeeBP <= 400, "set: invalid deposit fee basis points");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].withdrawFeeBP = _withdrawFeeBP;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;

    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending UFXs on frontend.
    function pendingUfx(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accUfxPerShare = pool.accUfxPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 ufxReward = multiplier.mul(ufxPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accUfxPerShare = accUfxPerShare.add(ufxReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accUfxPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 ufxReward = multiplier.mul(ufxPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        ufx.mint(feeAddDev, ufxReward.mul(feeDevRate).div(10000));
        ufx.mint(address(this), ufxReward);
        pool.accUfxPerShare = pool.accUfxPerShare.add(ufxReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for UFX allocation.
    //-----------------------------------------------------------------AlexChange
    //function deposit(uint256 _pid, uint256 _amount, address _referrer) public nonReentrant poolExists(_pid) {
    function deposit(uint256 _pid, uint256 _amount) public nonReentrant poolExists(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);

        // Record referral if all below applies
        //-----------------------------------------------------------------AlexChange
        // if (_amount > 0 && address(ufxReferral) != address(0) && _referrer != address(0) && _referrer != msg.sender) {
        //     ufxReferral.recordReferral(msg.sender, _referrer);
        // }

        // Try to harvest
        if (user.amount > 0) {
            harvest(_pid);
        }

        // Thanks for RugDoc advice
        // Add user.amount
        if (_amount > 0) {
            if (pool.depositFeeBP > 0) {
                //--------------------------depositfee handling--------------------------------
                //ex 100LP -> (4%) 4ufx// 100 % 400 -> 40000 / 10000 => 4ufx
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000); //4ufx
                // uint256 depositFeeHalf = depositFee.div(2);//2ufx

                // pool.lpToken.safeTransfer(feeAddDev, depositFee); 
                //4ufx -> (x) this pool send ufx to feeAddDev..(x) 
                
                //it must be sender to feeAddDev
                pool.lpToken.safeTransferFrom(address(msg.sender), feeAddDev, depositFee);

                // pool.lpToken.safeTransfer(feeAddBb, withdrawFeeHalf);
                _amount = _amount.sub(depositFee); // 96
                // pool.lpToken.safeTransfer(address(msg.sender), _amount);               
                //----------------------------------------------------------------------------
            }
                //--------------------------------Transfer except Fee-------------------------
                // LP ammount before
                uint256 before = pool.lpToken.balanceOf(address(this));
                // Transafer from user
                pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
                // LP ammount after
                uint256 _after = pool.lpToken.balanceOf(address(this));
                // Real amount of LP transfer to this address
                _amount = _after.sub(before);
                user.amount = user.amount.add(_amount);
                //----------------------------------------------------------------------------
        }

        // Update user reward debt and emit Deposit
        user.rewardDebt = user.amount.mul(pool.accUfxPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public nonReentrant poolExists(_pid) lpProtection(_pid, _amount){
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: Amount to withdraw higher than LP balance.");
        updatePool(_pid);
        
        // Harvest before withdraw
        harvest(_pid);

        // Withdraw procedure
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            // Remove fee 
            if (pool.withdrawFeeBP > 0) {
                uint256 withdrawFee = _amount.mul(pool.withdrawFeeBP).div(10000);
                // uint256 withdrawFeeHalf = withdrawFee.div(2);
                pool.lpToken.safeTransfer(feeAddDev, withdrawFee);
                // pool.lpToken.safeTransfer(feeAddBb, withdrawFeeHalf);
                _amount = _amount.sub(withdrawFee);
                pool.lpToken.safeTransfer(address(msg.sender), _amount);
            }
        }

        user.rewardDebt = user.amount.mul(pool.accUfxPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Safe UFX transfer function, just in case if rounding error causes pool to not have enough UFXs.
    function safeUfxTransfer(address _to, uint256 _amount) internal {
        uint256 ufxBal = ufx.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > ufxBal) {
            transferSuccess = ufx.transfer(_to, ufxBal);
        } else {
            transferSuccess = ufx.transfer(_to, _amount);
        }
        require(transferSuccess, "safeUfxTransfer: transfer failed");
    }

    // Harvest UFXs.
    function harvest(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 pending = user.amount.mul(pool.accUfxPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            // send rewards
            safeUfxTransfer(msg.sender, pending);
            // payReferralCommission(msg.sender, pending);
        }
    }

    // Pay referral commission to the referrer who referred this user.
    //-----------------------------------------------------------------AlexChange
    // function payReferralCommission(address _user, uint256 _pending) internal {
    //     if (address(ufxReferral) != address(0) && referralCommissionRate > 0) {
    //         address referrer = ufxReferral.getReferrer(_user);
    //         uint256 commissionAmount = _pending.mul(referralCommissionRate).div(10000);

    //         if (referrer != address(0) && commissionAmount > 0) {
    //             ufx.mint(referrer, commissionAmount);
    //             ufxReferral.recordReferralCommission(referrer, commissionAmount);
    //             emit ReferralCommissionPaid(_user, referrer, commissionAmount);
    //         }
    //     }
    // }
    
    /**	
     * @dev Returns the address of the current operator.	
     */	
    function operator() public view returns (address) {	
        return _operator;	
    }

    /**	
     * @dev Transfers operator of the contract to a new account (`newOperator`).	
     * Can only be called by the current operator.	
     */	
    function transferOperator(address newOperator) public onlyOperator {	
        require(lockerState() == false, "Locker must be unlocked");
        require(newOperator != address(0), "transferOperator: new operator is the zero address");	
        emit OperatorTransferred(_operator, newOperator);	
        _operator = newOperator;	
    }


    // Pancake has to add hidden dummy pools in order to alter the emission, here we make it simple and transparent to all.
    function updateEmissionRate(uint256 _ufxPerBlock) public onlyOperator {
        massUpdatePools();
        emit EmissionRateUpdated(msg.sender, _ufxPerBlock);
        ufxPerBlock = _ufxPerBlock;
    }


    // update dev fee rate	
    function updateFeeDevRate(uint16 _newFeeDevRate) public onlyOperator {	
        require(_newFeeDevRate <= 1200, "update: fee dev rate is over 20%");	
        feeDevRate = _newFeeDevRate;	
    }

    // update deposit fee rate	
    // function updateDepositFeeRate(uint16 _newFeeDevRate) public onlyOperator {	
    //     require(_newDepositFeeRate <= 800, "update: fee dev rate is over 20%");	
    //     feeDevRate = _newDepositFeeRate;	
    // }

    // update fee address dev	
    function updateFeeAddDev(address _newFeeAddDev) public onlyOperator {	
        require(_newFeeAddDev != address(0), "update: fee address dev is zero");	
        feeAddDev = _newFeeAddDev;	
    }

    function updateStartBlock(uint256 _newStartBlock) public onlyOperator {	
        startBlock = _newStartBlock;	
    }

       // allow owner to finalize the presale once the presale is ended
    function updateUFXOwner(address newOwner) public onlyOwner {
        ufx.transferOwnership(newOwner);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];//ex 100 Lp
        
        if (pool.withdrawFeeBP >= 0) {
            //ex) user has 100lp
            uint256 withdrawFee = user.amount.mul(pool.withdrawFeeBP).div(10000); // 8 Lp
            pool.lpToken.safeTransfer(feeAddDev, withdrawFee);// send 8ufx


            uint256 afterFee = user.amount.sub(withdrawFee); // 100 - 8 => 92 Lp
            pool.lpToken.safeTransfer(address(msg.sender), afterFee); 
            emit EmergencyWithdraw(msg.sender, _pid, afterFee);
            user.amount = 0;
            user.rewardDebt = 0;
        }    
    }
}