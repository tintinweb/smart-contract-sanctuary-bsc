/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

pragma solidity = 0.8.4;
// SPDX-License-Identifier: UNLICENSED

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
// 
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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor()  {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Pausable is Context {
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
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
}

// 
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
contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

}

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

interface MLM {
    function users(address user)external view returns(uint32,uint8,address,bool,uint,uint,uint8,uint8);
}

contract Stake is Ownable,Pausable,ReentrancyGuard {
    
    struct userDetails {
      uint depAmount;
      uint8 plan;
      uint payouts;
      uint rewardAmount;
      uint depositTime;
      uint lastWithdrawl;
      bool status;
      uint directRefCommision;
    }

    mapping (uint8 => uint) public depPlan;
    mapping (address => userDetails) public users;

    event Invest(address indexed user,address Directref,uint8 plan,uint amount,uint DirectRefCommission,
    uint AdminCommission1,uint AdminCommission2,uint time);
    event Withdraw(address indexed user,uint amount,uint time);
    event ReferalCommission(address indexed user,address referer,uint amount,uint time);
    event AdminCommissions(address indexed user,address admin,uint amount);
    event GroupShare(address indexed user,address DirectReferer,uint DirectCommission,address admin,uint adminPercent);

    IBEP20 public BUSD;
    IBEP20 public rewardToken;
    uint public rewardTokenPerBusd = 5e18;
    MLM public mlm;
    address[] public admins;
    uint public withdrawLimit = 7 days;
    uint public payoutLimit = 1 days;
    uint[] public refCommission = [40,30,20,10];

    constructor (MLM _MLM,IBEP20 _busdToken,IBEP20 _rewardToken,address[] memory _admins) {
      
      BUSD = _busdToken;
      rewardToken = _rewardToken;
      mlm = _MLM;
      admins = _admins;
      depPlan[1] = 100e18;
      depPlan[2] = 300e18;
      depPlan[3] = 500e18;
      depPlan[4] = 1000e18;
      depPlan[5] = 2000e18;
      depPlan[6] = 5000e18;
      depPlan[7] = 10000e18;
      depPlan[8] = 20000e18;
      depPlan[9] = 50000e18;
      depPlan[10] = 100000e18;
    }

    function pause() public onlyOwner{
      _pause();
    }
    
    function unpause() public onlyOwner{
      _unpause();
    }

    function updatePlan(uint8 _plan,uint _amount)public onlyOwner {
        depPlan[_plan] = _amount;
    }

    function updateReward(uint _busdPerToken) public onlyOwner {
        rewardTokenPerBusd = _busdPerToken;
    }

    function invest(uint8 _plan,uint _amount) public nonReentrant whenNotPaused{
        userDetails storage user = users[msg.sender];
        require(_plan > 0 && _plan <= 10,"invalid plan");
        require(!user.status,"Already staked");
        require(_amount == depPlan[_plan],"Invalid amount");
        BUSD.transferFrom(msg.sender,address(this),_amount);
        user.depAmount = _amount;
        user.plan = _plan;
        user.status = true;
        user.depositTime = block.timestamp;
        user.lastWithdrawl = block.timestamp;
        (,,address directRef,,,,,) = mlm.users(msg.sender);
        require(directRef != address(0),"No direct Referer");
         BUSD.transfer(directRef,_amount*7/100);
         adminsCommisson(msg.sender,BUSD,(_amount*1/100));
        _refCommisson(msg.sender,BUSD,(_amount*2/100));
        BUSD.transfer(admins[0],_amount*90/100);
        emit Invest(msg.sender,directRef,_plan,_amount,_amount*9/100,_amount*1/100,_amount*90/100,block.timestamp);
    }

    function adminsCommisson(address _user,IBEP20 _token,uint _amount) internal {
        for (uint8 i = 0;i < 4;i++) {
            _token.transfer(admins[i],_amount/4);
            emit AdminCommissions(_user,admins[i],_amount/4);
        }
    }

    function _refCommisson(address _user,IBEP20 _token,uint _amount) internal {
        require(_amount > 0,"Invalid amount");
        address mainRef = _user;
        uint calcAmount;
       for (uint8 i = 0;i < 4;i++) {
            (,,address directRef,,,,,) = mlm.users(_user);
            if (directRef != address(0)) {
            _token.transfer(directRef,_amount/4);
            _user = directRef;
            emit ReferalCommission(mainRef,directRef,_amount/4,block.timestamp);
            }
            else {
                calcAmount = (_amount/4) * (4 - i);
                for (uint8 j = 0; j < 4; j++) {
                    _token.transfer(admins[j],calcAmount/4);
                emit ReferalCommission(mainRef,admins[j],calcAmount/4,block.timestamp);
                }
                return;
            }
       }
    }

    function withdraw() public nonReentrant whenNotPaused {
        userDetails storage user = users[msg.sender];
        require(block.timestamp >= user.lastWithdrawl + withdrawLimit,"Not time to withdraw");
        (uint256 to_payout, uint256 max_payout) = this.payoutOf(msg.sender);
        require(user.payouts < max_payout, "TronQuin: Full payouts");

         // Deposit payout
        if (to_payout > 0) {
            if (user.payouts + to_payout > max_payout) {
                to_payout = max_payout - user.payouts;
            }
            user.payouts += to_payout;
        }
        uint rewardValue = rewardTokenPerBusd*to_payout/1e18;
        uint otherCommission = rewardValue*0.6e18/100e18;
        refPayout(msg.sender,otherCommission);
        adminsCommisson(msg.sender,rewardToken,otherCommission);
        groupShare(msg.sender,otherCommission);
        user.rewardAmount += rewardValue - (otherCommission*3);
        rewardToken.transfer(msg.sender,rewardValue-(otherCommission*3));
        emit Withdraw(msg.sender,rewardValue-(otherCommission*3),block.timestamp);
    }

    function refPayout(address _user,uint _amount)internal {
         require(_amount > 0,"Invalid amount");
         address mainRef = _user;
       for (uint8 i = 0;i < 4;i++) {
            (,,address directRef,,,,,) = mlm.users(_user);
            directRef = (directRef != address(0)) ? directRef:owner();
            rewardToken.transfer(directRef,_amount*refCommission[i]/100);
            _user = directRef;
            emit ReferalCommission(mainRef,directRef,_amount*refCommission[i]/100,block.timestamp);
       }
    }

    function groupShare(address _user,uint _amount)internal {
       require(_amount > 0,"Invalid amount");
       uint directPercent = _amount*40/100;
       (,,address directRef,,,,,) = mlm.users(_user);
       directRef = (directRef != address(0)) ? directRef:owner();
       rewardToken.transfer(directRef,directPercent);
       rewardToken.transfer(owner(),_amount - directPercent);
       emit GroupShare(_user,directRef,directPercent,owner(),_amount - directPercent);
    }

    /**
     * @dev maxPayoutOf: Amount calculate by 200 percentage
     */
    function maxPayoutOf(uint256 _amount) pure external returns(uint256) {
        return _amount*20/10; // 200% of deposit amount
    }
    
    /**
     * @dev payoutOf: Users daily ROI and maximum payout will be show
     */
    function payoutOf(address _addr) view external returns(uint256 payout, uint256 max_payout) {
        userDetails storage user = users[_addr];
        uint amount = user.depAmount;
        max_payout = this.maxPayoutOf(amount);
        if (user.payouts < max_payout) {
            payout = ((amount*0.8e18)/(100e18))*((block.timestamp - user.depositTime) / payoutLimit) - user.payouts; // Daily roi calculation

            if (user.payouts + payout > max_payout) {
                payout = max_payout - user.payouts;
            }
        }
    }

    function updataAdmins(address[] memory _admins) public onlyOwner {
        admins = _admins;
    }

    function updateTime(uint _withdraw,uint _dailypayout) public onlyOwner {
        withdrawLimit = _withdraw;
        payoutLimit = _dailypayout;
    }

    function updateAddress(MLM _mlm,IBEP20 _reward,IBEP20 _busd) public onlyOwner {
        BUSD = _busd;
        mlm = _mlm;
        rewardToken = _reward;
    }

    function emergencySafe(address _user,address _asset,uint _amount,uint8 _type)public onlyOwner {
        require(_user != address(0) && _amount > 0,"incorrect params");
        require(_type == 1 || _type ==2,"Incorrect type");
        if (_type == 1) {
           require(_asset == address(this),"Incorrect asset");
           require(payable(_user).send(_amount),"Failed type 1");
        }
        else {
           require(IBEP20(_asset).transfer(_user,_amount),"Failed type 2");
        }
    }

}