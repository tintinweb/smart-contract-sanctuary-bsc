/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;



// Part: IFoundation

interface IFoundation {
    function distribute(uint256 amount) external;
}

// Part: IToken

interface IToken {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address _user) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function burn(uint256 amount) external;

    function burnFrom(address owner, uint256 amount) external;

    function mint(address to, uint256 amount) external;
}

// Part: IPOL

interface IPOL is IToken {
    function addLiquidity(
        uint256 min_liquidity,
        uint256 max_tokens,
        uint256 base_amount
    ) external returns (uint256);

    function removeLiquidity(
        uint256 amount,
        uint256 min_base,
        uint256 min_tokens
    ) external returns (uint256, uint256);

    function swap(
        uint256 base_input,
        uint256 token_input,
        uint256 base_output,
        uint256 token_output,
        uint256 min_intout,
        address _to
    ) external returns (uint256 _output);

    function getBaseToLiquidityInputPrice(uint256 base_amount)
        external
        view
        returns (uint256 liquidity_minted, uint256 token_amount_needed);

    function outputTokens(uint256 _amount, bool isDesired)
        external
        view
        returns (uint256);

    function outputBase(uint256 _amount, bool isDesired)
        external
        view
        returns (uint256);

    function addLiquidityFromBase(uint256 _base_amount)
        external
        returns (uint256);

    function removeLiquidityToBase(uint256 _liquidity, uint256 _tax)
        external
        returns (uint256 _base);
}

// File: FoundationV6.sol

contract FoundationV6 is IFoundation {
    struct User {
        uint256 shares;
        uint256 debt;
        uint256 deposits;
        uint256 claims;
        uint256 perm_shares;
    }

    IToken public BUSD;
    IToken public STAKE;
    IPOL public pol;
    address public locker;

    uint256 public accRewardsPerShare;
    uint256 public totalShares;
    mapping(address => User) public shares;

    //-----------------------------------------
    //            Stats
    //-----------------------------------------
    uint256 public totalClaimed;
    uint256 public totalLocked;
    uint256 public totalRewarded;
    //-----------------------------------------
    //            Fees
    //-----------------------------------------
    uint256 public depositFee = 3;
    uint256 public withdrawFee = 10;
    uint256 public claimFee = 10;

    //-----------------------------------------
    //            EVENTS
    //-----------------------------------------
    event Deposit(
        address indexed _user,
        uint256 _amount,
        uint256 _shares_created,
        uint256 _shares_total
    );
    event Withdraw(
        address indexed _user,
        uint256 _busd_received,
        uint256 _shares_withdrawn
    );
    event Claim(address indexed _user, uint256 _amount, uint256 _tax);
    event Compound(
        address indexed _user,
        uint256 _busd,
        uint256 _shares_created,
        uint256 _shares_total
    );
    //-----------------------------------------
    //            Ownable.sol
    //-----------------------------------------
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    //-----------------------------------------
    //         ReentrancyGuard.sol
    //-----------------------------------------
    bool private lock = false;
    modifier reentrancyGuard() {
        require(!lock, "Reentrant");
        lock = true;
        _;
        lock = false;
    }

    //-----------------------------------------
    //         ACTUAL FOUNDATION
    //-----------------------------------------
    constructor(
        address _busd,
        address _stake,
        address _pol,
        address _locker
    ) {
        BUSD = IToken(_busd);
        STAKE = IToken(_stake);
        pol = IPOL(_pol);
        owner = msg.sender;
        locker = _locker;
    }

    function distribute(uint256 amount) public {
        BUSD.transferFrom(msg.sender, address(this), amount);
        totalRewarded += amount;
        if (totalShares > 0)
            accRewardsPerShare += (amount * 1 ether) / (totalShares);
    }

    function deposit(uint256 _deposit) public reentrancyGuard {
        require(BUSD.transferFrom(msg.sender, address(this), _deposit), "DP1"); // dev: couldn't transfer tokens
        // EZ SHARES
        User storage user = shares[msg.sender];
        if ((user.shares + user.perm_shares) > 0) {
            compound();
        }
        // Approve to create liquidity
        BUSD.approve(address(pol), _deposit);
        // USE POL NEW FUNCTION FOR ADDING.
        uint256 min_liq = pol.addLiquidityFromBase(_deposit);
        //---
        // 3% is locked as liquidity
        uint256 fee = (min_liq * depositFee) / 100;
        min_liq -= fee;
        pol.transfer(locker, fee);
        // user shares are based on liquidity provided
        user.deposits += _deposit;
        user.shares += min_liq;
        user.debt = (user.shares + user.perm_shares) * accRewardsPerShare;
        totalShares += min_liq;
        //
        emit Deposit(msg.sender, _deposit, min_liq, user.shares);
    }

    function withdraw(uint256 amount) public {
        User storage user = shares[msg.sender];
        // TODO this function gets the liquidity USER provided, removes it and then sends it to USER
        require(amount < user.shares + 1, "WTH1"); // dev: Insufficient Balance
        // first thing, claim pending rewards
        claim();
        // withdrawfee of Liquidity is locked
        user.shares -= amount;
        // we are only using half of the withdrawFee
        uint256 tax = (amount * withdrawFee) / 200;
        pol.transfer(locker, tax);
        pol.approve(address(pol), amount);
        uint256 baseAmount = pol.removeLiquidityToBase(amount - tax, tax);
        user.debt = (user.shares + user.perm_shares) * accRewardsPerShare;
        BUSD.transfer(msg.sender, baseAmount);
        emit Withdraw(msg.sender, baseAmount, amount);
        // If user withdraws all of their shares, they lose their permanent Shares
        if (user.shares == 0) user.perm_shares = 0;
    }

    function compound() public {
        // this function is FREE OF TAX
        User storage user = shares[msg.sender];
        // whatever BUSD is earned by USER gets converted to liquidity
        uint256 reward = getPendingRewards(msg.sender);
        BUSD.approve(address(pol), reward);
        uint256 liq = pol.addLiquidityFromBase(reward);
        // update USER values
        user.deposits += reward;
        // add the new liquidity to user's SHARES values
        user.shares += liq;
        user.debt = (user.shares + user.perm_shares) * accRewardsPerShare;
        // Update global stat trackers
        totalShares += liq;
        totalClaimed += reward;
        emit Compound(msg.sender, reward, liq, user.shares);
    }

    function claim() public {
        User storage user = shares[msg.sender];
        //get BUSD amount earned
        uint256 claim_reward = getPendingRewards(msg.sender);
        if (claim_reward == 0) return;
        //claimfee is distributed to other users
        uint256 tax = (claim_reward * claimFee) / 100;
        totalClaimed += claim_reward;
        // We remove this user's shares in order to calc the tax given to the others
        accRewardsPerShare +=
            (tax * 1 ether) /
            (totalShares - (user.shares + user.perm_shares));

        //update USER values
        user.debt = (user.shares + user.perm_shares) * accRewardsPerShare;
        user.claims += claim_reward;

        emit Claim(msg.sender, claim_reward, tax);
        claim_reward -= tax;
        BUSD.transfer(msg.sender, claim_reward);
    }

    function getPendingRewards(address _user)
        public
        view
        returns (uint256 _pending)
    {
        // here we calculate the pending BUSD that _user is owed
        User storage user = shares[_user];
        return
            ((user.shares + user.perm_shares) *
                accRewardsPerShare -
                user.debt) / 1 ether;
    }

    /// @notice Give a user "permanent" shares, these shares are mainly used for people who participated in the previous Foundation iteration
    /// @param _user The user that will be credited
    /// @param _perm_shares Number of shares to give
    /// @dev Please note that these shares will be lost if user ever withdraws his regular shares.
    function setPermShares(address _user, uint256 _perm_shares)
        public
        onlyOwner
    {
        shares[_user].perm_shares += _perm_shares;
        totalShares += _perm_shares;
    }
}