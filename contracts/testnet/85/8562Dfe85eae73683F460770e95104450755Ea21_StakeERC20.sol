/**
 *Submitted for verification at BscScan.com on 2022-02-14
*/

// File: contracts/utils/Access.sol

pragma solidity ^0.8.0;

contract Access {
    bool private _contractCallable = false;
    bool private _pause = false;
    address private _owner;
    address private _pendingOwner;

    event NewOwner(address indexed owner);
    event NewPendingOwner(address indexed pendingOwner);
    event SetContractCallable(bool indexed able,address indexed owner);

    constructor(){
        _owner = msg.sender;
    }

    // ownership
    modifier onlyOwner() {
        require(owner() == msg.sender, "Access: caller is not the owner");
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }
    function setPendingOwner(address account) public onlyOwner {
        require(account != address(0),"Access: zero address");
        require(_pendingOwner == address(0), "Access: pendingOwner already exist");
        _pendingOwner = account;
        emit NewPendingOwner(_pendingOwner);
    }
    function becomeOwner() external {
        require(msg.sender == _pendingOwner,"Access: not pending owner");
        _owner = _pendingOwner;
        _pendingOwner = address(0);
        emit NewOwner(_owner);
    }

    // pause
    modifier checkPaused() {
        require(!paused(), "Access: paused");
        _;
    }
    function paused() public view virtual returns (bool) {
        return _pause;
    }
    function setPaused(bool p) external onlyOwner{
        _pause = p;
    }


    // contract call
    modifier checkContractCall() {
        require(contractCallable() || msg.sender == tx.origin, "Access: non contract");
        _;
    }
    function contractCallable() public view virtual returns (bool) {
        return _contractCallable;
    }
    function setContractCallable(bool able) external onlyOwner {
        _contractCallable = able;
        emit SetContractCallable(able,_owner);
    }

}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

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

// File: contracts/Stake.sol

pragma solidity ^0.8.0;



interface IComptroller {
    function getInviter(address account) view external returns(address);
}


contract StakeERC20 is Access{

    IERC20      public constant LP = IERC20(0x91ea756FFCd7810c7463E80AeB2F2672BA864f74);
    IERC20      public constant Token = IERC20(0x0807FC0d83a170D4eFc0E0d52a35D721e0E86dB0);
    IComptroller public Comptroller;
    uint public blockSupply;
    uint public dailySupply;
    uint public lastUpdate;
    uint public rewardsPerToken;
    uint public bonusPerToken;
    uint public totalPledge;

    struct User {
        uint pledge;
        uint rewards;
        uint rewardsPerToken;
        uint bonus;
        uint bonusPerToken;
        uint totalClaim;
        uint inviteRewards;
    }
    mapping(address=>User) public users;

    event Bind(address indexed inviter, address indexed invitee);
    event SetBlockSupply(uint blockSupply);
    event Pledge(address indexed user, uint amount, uint rewards);
    event Claim(address indexed user, address indexed inviter, uint pledges, uint rewards, uint bonus);
    event Redemption(address indexed user, uint indexed amount);

    constructor () {
        lastUpdate = block.number;
        setPendingOwner(0x449F8492FA10bcB4d1017FD306da649EB81D1c99);
        setDailySupply(1000e18);
    }

    modifier update() {

        if (blockSupply > 0 && totalPledge > 0){
            rewardsPerToken = calRewardsPerToken();
        }
        lastUpdate = block.number;

        _;
    }

    function calRewardsPerToken() public view returns(uint) {
        return (block.number - lastUpdate) * blockSupply * 1e10 / totalPledge + rewardsPerToken;
    }


    function calRewards(uint perToken, address account) internal view returns(uint){
        uint rewards = (perToken - users[account].rewardsPerToken) * users[account].pledge;

        if (rewards > 0) {
            rewards = rewards / 1e10;
        }
        rewards += users[account].rewards;
        return rewards;
    }

    function calBonus(address account) internal view returns(uint){
        uint bonus = (bonusPerToken - users[account].bonusPerToken) * users[account].pledge;

        if (bonus > 0) {
            bonus = bonus / 1e10;
        }
        bonus += users[account].bonus;
        return bonus;
    }

    function setDailySupply(uint supply) public update onlyOwner {
        dailySupply = supply;
        blockSupply = supply / 21600;
    }


    // pledge
    function pledge(uint amount) external update checkPaused checkContractCall {

        require(amount > 0, "Stake: The amount must be greater than 0");

        uint balanceBefore = LP.balanceOf(address(this));
        LP.transferFrom(msg.sender, address(this), amount);
        uint balanceAfter = LP.balanceOf(address(this));
        require(balanceBefore + amount == balanceAfter,"bad erc20");

        if (users[msg.sender].pledge > 0) {
            users[msg.sender].rewards = calRewards(rewardsPerToken, msg.sender);
            users[msg.sender].bonus = calBonus(msg.sender);
        }

        users[msg.sender].rewardsPerToken = rewardsPerToken;
        users[msg.sender].bonusPerToken = bonusPerToken;
        users[msg.sender].pledge += amount;
        totalPledge += amount;

        emit Pledge(msg.sender, users[msg.sender].pledge, users[msg.sender].rewards);
    }


    // claimAble
    function claimAble(address account) public view returns (uint rewards, uint bonus) {

        if (users[account].pledge == 0) {
            return (0,0);
        }

        if (blockSupply > 0){
            uint perToken = calRewardsPerToken();
            rewards = calRewards(perToken, account);
        }else {
            rewards = calRewards(rewardsPerToken, account);
        }

        bonus = calBonus(account);
        return (rewards, bonus);
    }

    function claim() external checkPaused checkContractCall returns (bool) {
        require(users[msg.sender].pledge > 0, "You can claim rewards only after pledge");

        _claim();
        return true;
    }

    function dividend(uint amount) external {
        require(msg.sender == address(Comptroller), "Stake: not comptroller");
        if (totalPledge > 0) {
            bonusPerToken += amount * 1e10 / totalPledge;
        }
    }

    // claim
    function _claim() internal update {

        uint rewards = calRewards(rewardsPerToken, msg.sender);
        users[msg.sender].rewards = 0;
        users[msg.sender].rewardsPerToken = rewardsPerToken;

        uint bonus = calBonus(msg.sender);
        users[msg.sender].bonus = 0;
        users[msg.sender].bonusPerToken = bonusPerToken;

        users[msg.sender].totalClaim += bonus + rewards;

        address inviter = Comptroller.getInviter(msg.sender);
        if (rewards > 0) {
            Token.transfer(inviter, rewards / 10);
            Token.transfer(msg.sender, rewards * 9 / 10);
            users[inviter].inviteRewards += rewards / 10;
        }

        if (bonus > 0) {
            Token.transfer(msg.sender, bonus);
        }
        emit Claim(msg.sender, inviter, users[msg.sender].pledge, rewards, bonus);
    }

    // redemption
    function redemption(uint amount) external update checkContractCall returns (bool) {

        require(amount > 0, "Stake: illegal amount (1)");
        require(users[msg.sender].pledge >= amount, "Stake: illegal amount (2)");

        _claim();
        LP.transfer(msg.sender, amount);

        totalPledge -= amount;
        users[msg.sender].pledge -= amount;

        emit Redemption(msg.sender, amount);
        return true;
    }

    // emergencyWithdraw
    function emergencyWithdraw() external returns (bool) {
        require(users[msg.sender].pledge > 0, "Stake20: You can withdraw only after pledge");

        LP.transfer(msg.sender, users[msg.sender].pledge);

        totalPledge -= users[msg.sender].pledge;
        users[msg.sender].pledge = 0;
        return true;
    }

    function getBaseInfo(address account) external view returns (uint blockSupply_, uint totalPledge_, uint userPledge_, uint rewardsToClaim_, uint bonusToClaim_, uint totalClaim_, uint inviteRewards_) {

        blockSupply_ = blockSupply;
        totalPledge_ = totalPledge;
        userPledge_ = users[account].pledge;
        (rewardsToClaim_, bonusToClaim_) = claimAble(account);
        totalClaim_ = users[account].totalClaim;
        inviteRewards_ = users[account].inviteRewards;
    }

    function setComptroller(address c) external onlyOwner{
        Comptroller = IComptroller(c);
    }
}