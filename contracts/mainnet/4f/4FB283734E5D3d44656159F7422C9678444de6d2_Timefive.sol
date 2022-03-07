/**
 *Submitted for verification at BscScan.com on 2022-03-07
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11; 

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Timefive is Ownable {
    event Stake(
        address indexed account,
        uint amount,
        uint lockup
    );

    event UnStake(
        address indexed account,
        uint amount
    );

    event Claim (
        address indexed account,
        uint rewardAmount
    );

    IBEP20 public token;

    mapping(address => userStruct) public user;

    struct userStruct {
        uint lockUp;
        uint amount;
        uint lockEndTime;
        uint lockTime;
        uint totalRewards;
    }

    uint[6] public lockUps = [7 days,30 days,90 days,180 days, 360 days, 1 days];
    uint[2] public total; // 0- total deposited, 1- total withdrawn
    uint public reward = 1700000000000000000;
    

    function setToken( IBEP20 token_) external onlyOwner  {
        token = token_;
    }

    function setReward( uint reward_) external onlyOwner {
        reward = reward_;
    }

    function setLockUpTime( uint8 index, uint time) external onlyOwner {
        require(index >= 0 && (index <= 5), "index should <= 5");
        lockUps[index] = time;
    }

    function stake( uint amount, uint8 lockUp) external {        
        require((lockUp == 0) || (lockUp == 1) || (lockUp == 2) || (lockUp == 3) || (lockUp == 4), "lockup should be 0,1,2,3,4");
        require(user[msg.sender].amount == 0, "user.amount == 0");
        require(amount > 0, "amount > 0");
        require(token.balanceOf(msg.sender) >= amount, "insufficient balance");
        require(token.allowance(msg.sender, address(this)) >= amount, "insufficient allowance");

        user[msg.sender] = userStruct(
            lockUp,
             amount,
             (block.timestamp + lockUps[lockUp]),
             block.timestamp,
             0
        );

        total[0] += amount;
        token.transferFrom(msg.sender, address(this), amount);

        emit Stake (
            msg.sender,
            amount,
            lockUp
        );
    }

    function unstake() external {
        require(user[msg.sender].amount > 0, "user.amount > 0");
        require(user[msg.sender].lockEndTime < block.timestamp, "wait till lockup period end");
        
        bool success = claim(); // claims all pending rewards

        uint amountToSend = user[msg.sender].amount;
        delete user[msg.sender];
        total[1] += amountToSend;

        token.transfer(msg.sender, amountToSend);

        emit UnStake (
            msg.sender,
            amountToSend
        );
    }

    function claim() public returns (bool){
        (uint amount, uint claimTime) = getReward(msg.sender);

        if(amount == 0)
            return false;
        
        user[msg.sender].lockTime += claimTime;
        user[msg.sender].totalRewards += amount;
        token.transfer(msg.sender, amount);

        emit Claim(
         msg.sender,
         amount
        );

        return true;
    }

    function getReward( address account) public view returns (uint, uint) {
        userStruct memory user_ = user[account];
        uint currentBlock = block.timestamp;
        
        if(user_.amount == 0) 
            return (0,0);

        if(currentBlock > user_.lockEndTime) 
            currentBlock = user_.lockEndTime;

        uint totalday_ = (currentBlock - user_.lockTime) / lockUps[5];
        uint reward_ = (user_.amount * (reward * totalday_)) / 100e18;
        return (reward_, (lockUps[5] * totalday_));
    }

    function emergencyWithdrawal( address tokenAdd, uint amount) external onlyOwner{
        address self = address(this);
        if(tokenAdd == address(0)) {
            require(self.balance >= amount, "token : insufficient balance");
            require(payable(owner()).send(amount), "token : transfer failed");
        }
        else {
            require(IBEP20(tokenAdd).balanceOf(self) >= amount, "token : insufficient balance");
            if(tokenAdd == address(token)){
                if(total[0] > total[1]) {
                    uint unClaimed = total[0] - total[1];
                    if(IBEP20(tokenAdd).balanceOf(self) > unClaimed) {
                        uint claimable = IBEP20(tokenAdd).balanceOf(self) - unClaimed;
                        if(amount > claimable) {
                            amount = 0;
                        }
                    } else {
                        amount = 0;
                    }
                }
                   require(amount > 0, "no available tokens to claim");
            }


            require(IBEP20(tokenAdd).transfer(owner(),amount), "token : transfer failed");
        }
    }
}