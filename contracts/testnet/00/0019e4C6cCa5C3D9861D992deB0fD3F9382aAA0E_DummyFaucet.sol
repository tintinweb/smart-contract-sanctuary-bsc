/**
 *Submitted for verification at BscScan.com on 2022-09-08
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

// File: faucet.sol

//SPDX-License-Identifier: MIT

pragma solidity 0.8.16;


contract DummyFaucet {
    struct Accounting {
        uint256 netFaucet; // User level NetFaucetValue
        // Detail of netFaucet
        uint256 deposits; // Hard Deposits made
        uint256 rolls; // faucet Compounds
        uint256 rebaseCompounded; // RebaseCompounds
        uint256 airdrops_rcv; // Received Airdrops
        uint256 accFaucet; // accumulated but not claimed faucet due to referrals
        uint256 accRebase; // accumulated but not claimed rebases
        // Total Claims
        uint256 faucetClaims;
        uint256 rebaseClaims;
        uint256 rebaseCount;
        uint256 lastAction;
        bool done;
    }
    struct Team {
        uint256 referrals; // People referred
        address upline; // Who my referrer is
        uint256 upline_set; // Last time referrer set
        uint256 refClaimRound; // Whose turn it is to claim referral rewards
        uint256 match_bonus; // round robin distributed
        uint256 lastAirdropSent;
        uint256 airdrops_sent;
        uint256 structure; // Total users under structure
        uint256 maxDownline;
        // Team Swap
        uint256 referralsToUpdate; // Users who haven't updated if team was switched
        address prevUpline; // If updated team, who the previous upline user was to switch user's referrals
        uint256 leaders;
    }

    IERC20 public token;
    mapping(address => Team) public team;
    mapping(address => Accounting) public userStat;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function deposit(uint256 amount, address _upline) public {
        Accounting storage _u = userStat[msg.sender];
        Team storage _t = team[msg.sender];

        _u.deposits += amount;
        _t.upline = _upline;
    }

    function airdrop(
        address _receiver,
        uint256 _amount,
        uint8 _level
    ) public {
        token.transferFrom(msg.sender, address(this), _amount);
        userStat[_receiver].airdrops_rcv += _amount;
    }
}