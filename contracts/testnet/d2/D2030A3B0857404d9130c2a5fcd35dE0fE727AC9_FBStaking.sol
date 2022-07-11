/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

// File: contracts/9_Staking.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;


contract FBStaking {

    struct Reward {
        address     crypto;
        uint256     amount;
        uint        dateFrom;
        uint        ratio;// 1 FBL/ amount crypto
    } 
    Reward[]                                            public  rewards;
    uint                                                public  rewardNo;
    mapping(uint => uint256)                            public  totals;             //  rewardid    =>  total deposit

    mapping(address => mapping(uint => uint256))        public  stakerPeriods;      //  staker      =>  rewardId    =>  amount
    mapping(address => uint256)                         public  stakerDeposits;     //  staker      =>  total deposit 
    mapping(address => mapping(uint => Reward))         public  stakerRewards;      //  staker      =>  rewardId    =>  amount,crypto

    /* management */
    address                         private _FBL;
    uint                            private _FBLDecimal;
    uint256                         public  FBLAmount;
    address                         private _owner;
    bool                            private _ownerLock = false;
    mapping(address => bool)        private _operators;
    
    constructor(address FBL_, uint decimal_ , uint256 amount_) {
        _FBL        = FBL_;
        _FBLDecimal = decimal_;
        FBLAmount  = amount_;
        _owner      = msg.sender;
    }

    modifier chkOperator() {
        require(_operators[msg.sender], "only for operator");
        _;
    }
    modifier chkOwnerLock() {
        require( _owner     ==  msg.sender, "only for owner");
        require( _ownerLock ==  false, "lock not open");
        _;
    }
    function opSetOwnerLock(bool val_) public chkOperator {
        _ownerLock   = val_;
    }

    /* operator */    
    function opSetReward(address crypto_, uint256 amount_, uint ratio_) public  chkOperator {
        _cryptoTransferFrom(msg.sender, address(this), crypto_, amount_);
        Reward memory vRev;
        vRev.crypto            =   crypto_;
        vRev.amount            =   amount_;
        vRev.dateFrom          =   block.timestamp;
        vRev.ratio             =   ratio_;
        rewards.push(vRev);
        rewardNo++;
        totals[rewardNo]       =   totals[rewardNo-1];
    }

    /* staker */    
    function setDeposit(uint256 amount_) public  {
        require(stakerDeposits[msg.sender] + amount_ >= FBLAmount, "invalid amount");
        _cryptoTransferFrom(msg.sender, address(this), _FBL, amount_);
        stakerDeposits[msg.sender]                  += amount_;
        totals[rewardNo]                            += amount_;
        stakerPeriods[msg.sender][rewardNo]         =  stakerDeposits[msg.sender];
    }
    function getDeposit(uint256 amount_) public {
        require(stakerDeposits[msg.sender] >= amount_,"invalid amount");
        stakerDeposits[msg.sender]                  -= amount_;
        totals[rewardNo]                            -= amount_;
        stakerPeriods[msg.sender][rewardNo]         =  stakerDeposits[msg.sender];
        _cryptoTransfer(msg.sender, _FBL, amount_);
    }
    function getRevenue(uint rewardId_) public {
        require(rewards[rewardId_].amount                       >  0,"invalid reward");
        require(stakerPeriods[msg.sender][rewardId_]            >  0,"invalid deposit");
        require(stakerRewards[msg.sender][rewardId_].dateFrom   == 0,"got revenue");
        
        uint256 vReward                                 =  (stakerPeriods[msg.sender][rewardId_]/10**_FBLDecimal)*rewards[rewardId_].ratio;
        require(rewards[rewardId_].amount               >= vReward,"empty");
        stakerRewards[msg.sender][rewardId_].amount     =  vReward;
        stakerRewards[msg.sender][rewardId_].crypto     =  rewards[rewardId_].crypto;
        stakerRewards[msg.sender][rewardId_].dateFrom   =  block.timestamp;
        stakerRewards[msg.sender][rewardId_].ratio      =  rewards[rewardId_].ratio;
        
        rewards[rewardId_].amount                       -= vReward;
        if(stakerPeriods[msg.sender][rewardId_+1] == 0)
            stakerPeriods[msg.sender][rewardId_+1]      =  stakerPeriods[msg.sender][rewardId_];
        _cryptoTransfer(msg.sender, rewards[rewardId_].crypto, stakerRewards[msg.sender][rewardId_].amount);
    }
 
    /* payment */    
    function _cryptoTransferFrom(address from_, address to_, address crypto_, uint256 amount_) internal returns (uint256) { 
        if(amount_ == 0) return 0;  
        // use native
        if(crypto_ == address(0)) {
            require( msg.value == amount_, "invalid amount");
            return 1;
        } 
        // use token    
        IERC20(crypto_).transferFrom(from_, to_, amount_);
        return 2;
    }
    function _cryptoTransfer(address to_,  address crypto_, uint256 amount_) internal returns (uint256) { 
        if(amount_ == 0) return 0;
        // use native
        if(crypto_ == address(0)) {
            payable(to_).transfer( amount_);
            return 1;
        }
        // use token
        IERC20(crypto_).transfer(to_, amount_);
        return 2;
    }

    /* Owner */
    function owCloseDeposit(uint id_, address staker_) public chkOwnerLock {        
        require(stakerDeposits[staker_] == id_, "invalid staker");
        require(stakerDeposits[staker_] >  0, "withdrawed");
        stakerDeposits[staker_]         =  0;
        _cryptoTransfer(staker_,  _FBL, stakerDeposits[staker_]);
    }
    function owCloseAll(address crypto_, uint256 value_) public chkOwnerLock {
        _cryptoTransfer(msg.sender,  crypto_, value_);
    }
    function owSetFBL(address FBL_, uint256 decimal_) public chkOwnerLock {
        _FBL        = FBL_;
        _FBLDecimal = decimal_;
    }
    function owSetOperator(address opr_, bool val_) public {
        _operators[opr_] = val_;
    }
}