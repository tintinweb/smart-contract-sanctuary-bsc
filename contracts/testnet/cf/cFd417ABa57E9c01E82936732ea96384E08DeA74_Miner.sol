/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

interface ILotto {
    function deposit(address token, uint256 amount) external;
    function register(address user, uint256 amount) external;
}

contract Miner is Ownable {

    // Token
    IERC20 public immutable token;

    // Number Of Seconds To Recoup Balance
    uint256 public immutable nBlocks;

    // Fees
    uint256 public poolFee         = 900;
    uint256 public rewardFee       = 50;
    uint256 public referrerFee     = 25;
    uint256 public treasuryFee     = 10;
    uint256 public lottoFee        = 15;
    uint256 public claimFee        = 50;
    uint256 private constant DENOM = 1000;

    // External Addresses / Contracts
    address public treasury;
    ILotto public lotto;

    // Contract value tracking
    uint256 public totalShares;
    uint256 private constant precision = 10**18;

    // Maximum Profit Tracking
    uint256 public MAX_PROFIT = 3 * 10**18;

    // User Data
    struct User {
        uint256 balance;              // shares of the system
        uint256 index;                // index in allUsers array
        uint256 totalClaimed;         // total tokens claimed by user
        uint256 totalTokenBalance;    // total tokens deposited
        uint256 totalShareBalance;    // total shares attributed
        uint256 trackedTokenBalance;  // tracked tokens deposited for profit calculation
        uint256 trackedShareBalance;  // tracked shares attributed for profit calculation
        uint256 claimPerBlock;       // tokens to claim per second
        uint256 lastClaim;            // last claim second
        uint256 profitsAssassinated;  // number of times user has assassinated another
        address referrer;             // referrer address
        uint256 referrerFees;         // total referrer fees gained by user
    }
    mapping ( address => User ) public userInfo;
    address[] public allUsers;
    address[] public allAssassins;

    // Data Tracking
    uint256 public totalDeposited;
    uint256 public totalReferrerFees;
    uint256 public totalRewards;
    uint256 public totalClaimed;

    // Function Events
    event Claim(address user, uint256 numTokens);
    event Compound(address user, uint256 pendingTokens);
    event Deposit(address user, uint256 numTokens, uint256 numShares);
    event Assassinated(address victim, address assassin, uint256 profitGained);

    // State Change Events
    event SetLotto(ILotto lotto_);
    event SetTreasury(address treasury_);
    event SetMaxProfit(uint256 maxProfit);
    event FeesSet(uint poolFee, uint rewardFee, uint referr, uint treasury, uint lotto, uint claim);

    constructor(
        address token_,
        address treasury_,
        uint256 nDays_
    ) {
        require(
            token_ != address(0) &&
            nDays_ > 0,
            'Invalid Inputs'
        );

        token = IERC20(token_);
        treasury = treasury_;
        nBlocks = nDays_ * 28800;
    }

    ////////////////////////////////////////////////
    ///////////   RESTRICTED FUNCTIONS   ///////////
    ////////////////////////////////////////////////

    function setFees(
        uint poolFee_,
        uint rewardFee_,
        uint referrer_,
        uint treasury_,
        uint lotto_,
        uint claimFee_
    ) external onlyOwner {
        require(
            poolFee_ + rewardFee_ + referrer_ + treasury_ + lotto_ == DENOM,
            'Invalid Fees'
        );
        require(
            poolFee_ > 0 && rewardFee_ > 0 && treasury_ > 0 && lotto_ > 0,
            'Zero Checks'
        );
        require(
            claimFee_ <= 250,
            'Claim Fee Too High'
        );
        
        poolFee = poolFee_;
        rewardFee = rewardFee_;
        referrerFee = referrer_;
        treasuryFee = treasury_;
        lottoFee = lotto_;
        claimFee = claimFee_;

        emit FeesSet(poolFee_, rewardFee_, referrer_, treasury_, lotto_, claimFee_);
    }

    function setLotto(ILotto lotto_) external onlyOwner {
        require(
            address(lotto_) != address(0),
            'Zero Address'
        );
        lotto = lotto_;
        emit SetLotto(lotto_);
    }

    function setTreasury(address treasury_) external onlyOwner {
        require(
            treasury_ != address(0),
            'Zero Address'
        );
        treasury = treasury_;
        emit SetTreasury(treasury_);
    }

    function setMaxProfit(uint256 maxProfit) external onlyOwner {
        require(
            maxProfit >= 10**18,
            'Max Profit Too Low'
        );
        MAX_PROFIT = maxProfit;
        emit SetMaxProfit(maxProfit);
    }


    ////////////////////////////////////////////////
    ///////////     PUBLIC FUNCTIONS     ///////////
    ////////////////////////////////////////////////


    /**
        Deposits `amount` of Token into system, Must have prior `approval` from `msg.sender` to move Token
        Takes Fee Equal To `100 - poolFee`
            Reward Fee Inflates Daily Claim For Holders
            Treasury Fee Is Sent To The Treasury
            Lotto Fee Is Sent To Lottery Contract
            Referrer Fee Is Sent To the referrer for `msg.sender`
                if `ref` is not `msg.sender`, registers `ref` as `msg.sender`'s referrer
                if `msg.sender` already has a registered referrer, ref is not checked and can be arbitrary
                if no registered referrer, and `ref` is `msg.sender`, Referrer Fee is added to reward fee
     */
    function deposit(address ref, uint256 amount) external {
        _deposit(msg.sender, ref, amount);
    }

    /**
        Adds Current Pending Balance To `msg.sender`'s tracked balance and shares
        Reduces their tracked profit so they do not get forced out,
        but forfeits the current pending rewards they have waiting
     */
    function compound() public {
        _compound(msg.sender);
    }

    /**
        Claims Pending Rewards, sending to caller
        Decrementing Shares and Balances
        Resetting the claim timer
     */
    function claim() external {
        _claim(msg.sender);
    }

    /**
        Forces `user` out of the system if they have exceeded the MAXIMUM_PROFIT
        Can be called by anyone for any user
        Caller gains the excess rewards from the MAXIMUM_PROFIT, incentivizing community
        To keep an eye on over-due members
     */
    function assassinate(address user) external {        
        require(
            user != address(0),
            'Zero Address'
        );

        // calculate user's current profit
        uint currentProfit = calculateTrackedProfit(user);
        uint trackedBalance = userInfo[user].trackedTokenBalance;
        require(
            currentProfit > 0 && trackedBalance > 0,
            'Invalid User Data'
        );

        // ensure `user` is above profit ratio
        uint profitRatio = ( currentProfit * precision ) / trackedBalance;
        require(
            profitRatio >= MAX_PROFIT,
            'MAX PROFIT NOT REACHED'
        );

        // calculate profit for user if they stopped earning at MAX PROFIT
        uint expectedProfit = ( trackedBalance * MAX_PROFIT ) / precision;
        require(
            expectedProfit <= currentProfit,
            'Not over Maximum Profit'   
        );

        // find difference in profit
        uint profitDifference = currentProfit - expectedProfit;

        // remove profit from user
        uint userShares = userInfo[user].balance;
        uint userTokens = valueOf(userShares);
        require(
            userShares > 0 && userTokens > 0 && userTokens >= profitDifference,
            'Something Went Wrong'
        );

        // update state
        totalShares -= userShares;
        _removeUser(user);

        // tokens to send to user
        uint256 adjustedUserTokens = adjustWithClaimFee(userTokens - profitDifference);
        uint256 adjustedProfitDifference = adjustWithClaimFee(profitDifference);

        // send tokens to user
        _send(user, adjustedUserTokens);

        // send bounty to caller
        _send(msg.sender, adjustedProfitDifference);

        // add to assassin array if new assassin
        if (userInfo[msg.sender].profitsAssassinated == 0) {
            allAssassins.push(msg.sender);
        }

        // update assassin tracker
        userInfo[msg.sender].profitsAssassinated += profitDifference;
        emit Assassinated(user, msg.sender, profitDifference);
    }


    ////////////////////////////////////////////////
    ///////////     READ FUNCTIONS       ///////////
    ////////////////////////////////////////////////


    function calculatePrice() public view returns (uint256) {
        uint shares  = totalShares == 0 ? 1 : totalShares;
        uint backing = token.balanceOf(address(this));
        return ( backing * precision ) / shares;
    }

    function calculateTrackedProfitRatio(address user) public view returns (uint256) {
        uint currentProfit = calculateTrackedProfit(user);
        uint trackedBalance = userInfo[user].trackedTokenBalance;
        if (currentProfit == 0 || trackedBalance == 0) {
            return 0;
        }

        // profit percentage = profit / trackedBalance I.E. 600 tokens profit / 200 tokens staked = 3x profit
        return ( currentProfit * precision ) / trackedBalance;
    }

    function calculateTrackedProfit(address user) public view returns (uint256) {
        uint tokens = userInfo[user].trackedTokenBalance;
        uint current_tokens = valueOf(userInfo[user].trackedShareBalance);
        return tokens < current_tokens ? current_tokens - tokens : 0;
    }

    function calculateProfit(address user) external view returns (uint256) {
        uint tokens = userInfo[user].totalTokenBalance;
        uint current_tokens = valueOf(userInfo[user].totalShareBalance);
        return tokens < current_tokens ? current_tokens - tokens : 0;
    }

    function valueOf(uint balance) public view returns (uint256) {
        return ( balance * calculatePrice() ) / precision;
    }

    function valueOfAccount(address account) public view returns (uint256) {
        return valueOf(userInfo[account].balance);
    }

    function minPayout(address account) public view returns (uint256) {
        return valueOf(userInfo[account].totalShareBalance);
    }

    function rewardsPerDay(address user) public view returns (uint256) {
        return valueOf(userInfo[user].claimPerBlock) * 28800;
    }

    function pendingRewards(address user) public view returns (uint256) {
        return valueOf(pendingShares(user));
    }

    function pendingShares(address user) public view returns (uint256) {
        
        if (userInfo[user].balance == 0 || userInfo[user].lastClaim >= block.number) {
            return 0;
        }

        // difference in blocks
        uint diff = block.number - userInfo[user].lastClaim;

        // shares to claim
        uint toClaim = diff * userInfo[user].claimPerBlock;

        return toClaim > userInfo[user].balance ? userInfo[user].balance : toClaim;
    }

    function fetchAllUsers() external view returns (address[] memory) {
        return allUsers;
    }

    function fetchAllAssassins() external view returns (address[] memory) {
        return allAssassins;
    }

    function fetchAllUsersNearAssassination(uint256 threshold) external view returns (address[] memory) {
        uint length = allUsers.length;
        uint count = 0;
        uint profitThreshold = ( MAX_PROFIT * threshold / 1000 );
        
        for (uint i = 0; i < length;) {
            if ( calculateTrackedProfitRatio(allUsers[i]) >= profitThreshold ) {
                count++;
            }
            unchecked { ++i; }
        }
        
        address[] memory usersNearAssassination = new address[](count);
        if (count == 0) {
            return usersNearAssassination;
        }

        uint index = 0;
        for (uint i = 0; i < length;) {
            if ( calculateTrackedProfitRatio(allUsers[i]) >= profitThreshold ) {
                usersNearAssassination[index] = allUsers[i];
                index++;
            }
            unchecked { ++i; }
        }
        return usersNearAssassination;
    }

    function fetchMaxPayout(address user) external view returns (uint256) {
        if (userInfo[user].balance == 0) {
            return 0;
        }

        return userInfo[user].totalTokenBalance  + ( userInfo[user].trackedTokenBalance * MAX_PROFIT ) / precision;
    }

    ////////////////////////////////////////////////
    ///////////    INTERNAL FUNCTIONS    ///////////
    ////////////////////////////////////////////////

    
    function _deposit(address user, address ref, uint256 amount) internal {
        require(
            ref != address(0) &&
            amount > 0,
            'Zero Amount'
        );

        // compound pending shares if any exist
        if (pendingShares(user) > 0) {
            _compound(user);
        }

        // if first deposit
        uint previousBalance = token.balanceOf(address(this));

        // add user if first time depositing, else compound pending rewards
        if (userInfo[user].balance == 0) {
            _addUser(user);
        }

        // transfer in tokens
        uint received = _transferFrom(token, address(this), amount);
        totalDeposited += received;

        // split up amounts
        uint forPool     = (received * poolFee) / DENOM;
        uint forRewards  = (received * rewardFee) / DENOM;
        uint forTreasury = (received * treasuryFee) / DENOM;
        uint forLotto    = (received * lottoFee) / DENOM;
        uint forReferrer = received - ( forPool + forRewards + forTreasury + forLotto );        

        // deposit fees
        _takeFee(forLotto, forTreasury);

        // register buy within lottery
        lotto.register(user, received);

        // register referrer
        forRewards += _addReferrerReward(user, ref, forReferrer);
        totalRewards += forRewards;
        
        // add share of pool to user
        _mintShares(user, forPool, previousBalance, forRewards);
    }

    function _claim(address user) internal {
        
        // pending shares
        uint pending = pendingShares(user);
        if (pending == 0) {
            return;
        }

        if (pending > userInfo[user].balance) {
            pending = userInfo[user].balance;
        }

        // pending Tokens
        uint pendingTokens = valueOf(pending);

        // decrement total shares
        totalShares -= pending;

        // increment total claimed
        totalClaimed += pendingTokens;

        // if pending equal to balance, wipe all user data
        if (pending >= userInfo[user].balance) {
            _removeUser(user);
        } else {
            userInfo[user].balance -= pending;
            userInfo[user].lastClaim = block.number;
        }

        // tax claim amount
        uint256 adjustedPendingTokens = adjustWithClaimFee(pendingTokens);

        // increment users total claimed amount
        userInfo[user].totalClaimed += adjustedPendingTokens;

        // transfer token to recipient
        _send(user, adjustedPendingTokens);
        emit Claim(user, adjustedPendingTokens);
    }

    /**
        Adds Current Pending Balance To `user`'s tracked balance and shares
        Reduces their tracked profit so they do not get forced out,
        but forfeits the current pending rewards they have waiting
     */
    function _compound(address user) internal {

        if (userInfo[user].balance == 0) {
            return;
        }

        uint pending = pendingShares(user);
        uint pendingTokens = valueOf(pending);
        if (pending == 0 || pendingTokens == 0) {
            return;
        }

        // reset claim
        userInfo[user].lastClaim = block.number;

        // increment token balance and share balance to offset profits
        userInfo[user].trackedTokenBalance += pendingTokens;
        userInfo[user].trackedShareBalance += pending;

        emit Compound(user, pendingTokens);
    }

    function _mintShares(address user, uint256 share, uint256 previousBalance, uint256 feesTaken) internal {
        
        userInfo[user].totalTokenBalance += share;
        userInfo[user].trackedTokenBalance += share;

        if (totalShares == 0 || previousBalance == 0) {

            userInfo[user].balance += share;
            userInfo[user].claimPerBlock += ( share / nBlocks );
            userInfo[user].totalShareBalance += share;
            userInfo[user].trackedShareBalance += share;
            totalShares += share;

            emit Deposit(user, share, share);
        } else {

            uint sharesToMint = ( totalShares * share ) / ( previousBalance + feesTaken );
            userInfo[user].balance += sharesToMint;
            userInfo[user].totalShareBalance += sharesToMint;
            userInfo[user].trackedShareBalance += sharesToMint;
            userInfo[user].claimPerBlock += ( sharesToMint / nBlocks );
            totalShares += sharesToMint;

            emit Deposit(user, share, sharesToMint);
        }
    }

    function _addReferrerReward(address depositor, address ref, uint256 value) internal returns (uint256) {

        // register referrer if not yet registered
        if (userInfo[depositor].referrer == address(0)) {
            if (ref != depositor) {
                userInfo[depositor].referrer = ref;
            }
        }

        address ref1 = userInfo[depositor].referrer;
        // send cut to referrer, if no referrer add to rewards
        if (ref1 != address(0) && value > 0) {
            _send(ref1, value);
            userInfo[ref1].referrerFees += value;
            totalReferrerFees += value;
            return 0;
        }
        return value;
    }

    function adjustWithClaimFee(uint256 claimAmount) public view returns (uint256) {
        uint tax = ( claimAmount * claimFee ) / DENOM;
        return claimAmount - tax;
    }

    function _takeFee(uint lottoFee_, uint treasuryFee_) internal {

        // for lotto
        token.approve(address(lotto), lottoFee_);
        lotto.deposit(address(token), lottoFee_);

        // for treasury
        _send(treasury, treasuryFee_);
    }

    function _transferFrom(IERC20 token_, address destination, uint amount) internal returns (uint256) {
        uint before = token_.balanceOf(destination);
        bool s = token_.transferFrom(
            msg.sender,
            destination,
            amount
        );
        uint received = token_.balanceOf(destination) - before;
        require(
            s &&
            received > 0 &&
            received <= amount,
            'Error TransferFrom'
        );
        return received;
    }

    function _send(address user, uint amount) internal {
        uint bal = token.balanceOf(address(this));
        if (amount > bal) {
            amount = bal;
        }
        if (amount > 0) {
            require(
                token.transfer(user, amount),
                'Failure On Token Transfer'
            );
        }
    }

    function _addUser(address user) internal {
        userInfo[user].index = allUsers.length;
        userInfo[user].lastClaim = block.number;
        allUsers.push(user);
    }

    function _removeUser(address user) internal {
        require(
            allUsers[userInfo[user].index] == user,
            'User Not Present'
        );

        userInfo[
            allUsers[allUsers.length - 1]
        ].index = userInfo[user].index;

        allUsers[
            userInfo[user].index
        ] = allUsers[allUsers.length - 1];

        allUsers.pop();
        delete userInfo[user];
    }


}