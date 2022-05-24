// SPDX-License-Identifier: MIT
// Sports Prediction
// assets: MUFT, MSWAP, BNB
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./libs/IAdminRole.sol";
import "./libs/ILeague.sol";

contract Betting {
    IAdminRole private adminRole; 
    ILeague private league;

    // Base token
    enum BaseToken { BNB, MSWAP, MUFT }
    // Outcome Decision
    enum Position { OutcomeA, OutcomeB, OutcomeC, LIVE, STOP, CANCEL }

    // Admin take fee whenever outcome result exposed
    uint256 public FEE = 30; // 3%
    uint256 public DENOMINATOR = 1000;

    uint16 public MAX_LEVEL = 15;
    uint256 public BASE_REWARD_PERCENT = 10; // 1%
    // If user's level is 30, total reward percent = 1% + 0.1 * 15 = 2.5%;
    
    // MUFT, MSWAP max amount should be 99%
    // MUFT, MSWAP min amount should be 1%
    
    // MUFT 10000 token
    // MSWAP 100 token
    // BNB 0.001 BNB

    // Bet event
    struct BettingItem {
        string title; // Brazil vs Germany
        uint16 options; // 2 or 3 (include draw)
        Position event_result; // Event result
        bool isTreasuryClaimed;
    }

    struct DepopsitedAmount {
        uint256 deposit_a;  // deposited amount : Team A
        uint256 deposit_b;  // deposited amount : Team B
        uint256 deposit_c;  // deposited amount : DRAW
    }

    // User's bet info
    struct BetInfo {
        Position position;
        uint256 deposit_amount;
        bool isClaimed;
    }

    // User Reward token info
    struct RewardInfo {
        uint256 mswap_amount;
        uint256 muft_amount;
        uint256 bnb_amount;
        uint16 betCount; // Level increases every 50bets
    }

    struct TreasuryInfo {
        int256 mswap_amount;
        int256 muft_amount;
        int256 bnb_amount;
    }

    TreasuryInfo public treasuryInfo;

    // reward map
    // Wallet address => Reward info
    mapping (address=>RewardInfo) public rewards;
    // Token Type => IERC20
    mapping(BaseToken => IERC20) public baseTokens;
    // League ID => BetEvent ID
    mapping(uint16 => uint32) public eventCounter;
    // League ID => BetEvent ID => EVENT info
    mapping(uint16 => mapping(uint32 => BettingItem)) public betEvents;
    mapping(uint16 => mapping(uint32 => mapping(BaseToken => DepopsitedAmount))) public betAmounts;
    // League ID => BetEvent ID => user's address => user's info
    mapping(uint16 => mapping(uint32 => mapping(address => mapping(BaseToken => BetInfo)))) public userInfos;

    event BetEventCreated(uint16 leagueId, uint32 eventId, string eventTitle, Position result, bool isTreasuryClaimed);
    event BetDeposited(uint16 leagueId, uint32 eventId, address player, uint256 amount, Position position, BaseToken baseToken);
    event ResultReport(uint16 leagueId, uint32 eventId, Position result);
    event Claimed(uint16 leagueId, uint32 eventId, uint256 amount, Position position, address baseToken);
    event ClaimedTreasury(address sender, address recipient, uint256 bnb_amount, uint256 muft_amount, uint256 mswap_amount);
    event RewardClaimed(address sender, uint256 bnb_amount, uint256 muft_amount, uint256 mswap_amount );

    modifier onlyOwner() {
        require(
            adminRole.isPlatformOwner(msg.sender),
            "This function is restricted to the contract's owner"
        );
        _;
    }

    constructor(
        address _adminRole, 
        address _league,
        address _mswap,
        address _muft
    ) {
        require(_adminRole != address(0x0), "Invalid admin address");
        require(_league != address(0x0), "Invalid league address");
        require(_mswap != address(0x0), "Invalid mswap address");
        require(_muft != address(0x0), "Invalid muft address");

        adminRole = IAdminRole(_adminRole);
        league = ILeague(_league);
        require (adminRole.getFeeAddress() != address(0x0), "Invalid admin role");
        require (league.getLeagueId("Test") >= 0, "Invalid league address");

        baseTokens[BaseToken.MSWAP] = IERC20(_mswap);
        baseTokens[BaseToken.MUFT] = IERC20(_muft);
    }

    receive() external payable {}

    // Create bet event on specific league
    function create_bet(string memory league_title, string memory bet_title) external onlyOwner {
        uint16 leagueId = getLeagueId(league_title);
        uint32 eventId = eventCounter[leagueId];

        BettingItem storage betItem = betEvents[leagueId][eventId];
        betItem.title = bet_title;
        betItem.event_result = Position.STOP;
        betItem.isTreasuryClaimed = false;

        eventCounter[leagueId] += 1;

        emit BetEventCreated(leagueId, eventId, bet_title, Position.STOP, false);
    }

    // Token deposit
    function deposit_token(string memory leagueTitle, uint32 eventId, BaseToken token, uint256 amount, Position position) external {
        uint16 leagueId = getLeagueId(leagueTitle);
        require(amount > 0, "Invalid deposit amount");
        require(userInfos[leagueId][eventId][msg.sender][token].deposit_amount == 0, "You already participated");
        require(betEvents[leagueId][eventId].event_result == Position.LIVE, "You are not able to deposit");

        DepopsitedAmount storage betAmount = betAmounts[leagueId][eventId][token];

        if (position == Position.OutcomeA) {
            betAmount.deposit_a += amount;
        } else if (position == Position.OutcomeB) {
            betAmount.deposit_b += amount;
        } else if (position == Position.OutcomeC) {
            betAmount.deposit_b += amount;
        } else {
            revert("Position is not correct");
        }

        IERC20 baseToken = baseTokens[token];
        baseToken.transferFrom(msg.sender, address(this), amount);

        deposit(leagueId, eventId, token, amount, position);
    }

    // BNB deposit
    function deposit_bnb(string memory leagueTitle, uint32 eventId, Position position) external payable {
        uint16 leagueId = getLeagueId(leagueTitle);
        require(msg.value > 0, "Invalid deposit amount");
        require(userInfos[leagueId][eventId][msg.sender][BaseToken.BNB].deposit_amount == 0, "You already participated");
        require(betEvents[leagueId][eventId].event_result == Position.LIVE, "You are not able to deposit");

        DepopsitedAmount storage betAmount = betAmounts[leagueId][eventId][BaseToken.BNB];

        if (position == Position.OutcomeA) {
            betAmount.deposit_a += msg.value;
        } else if (position == Position.OutcomeB) {
            betAmount.deposit_b += msg.value;
        } else if (position == Position.OutcomeC) {
            betAmount.deposit_c += msg.value;
        } else {
            revert("Position is not correct");
        }

        deposit(leagueId, eventId, BaseToken.BNB, msg.value, position);
    }

    function deposit(uint16 leagueId, uint32 eventId, BaseToken token, uint256 amount, Position position) private {
        RewardInfo storage reward = rewards[msg.sender];
        uint256 percent = getRewardPercent(reward.betCount);

        if (token == BaseToken.BNB) {
            reward.bnb_amount += percent * amount / DENOMINATOR;
            treasuryInfo.bnb_amount -= int256(percent * amount / DENOMINATOR);
        } else if (token == BaseToken.MSWAP) {
            reward.mswap_amount += percent * amount / DENOMINATOR;
            treasuryInfo.mswap_amount -= int256(percent * amount / DENOMINATOR);
        } else if (token == BaseToken.MUFT) {
            reward.muft_amount += percent * amount / DENOMINATOR;
            treasuryInfo.muft_amount -= int256(percent * amount / DENOMINATOR);
        } 

        reward.betCount += 1;

        BetInfo storage userInfo = userInfos[leagueId][eventId][msg.sender][token];
        userInfo.position = position;
        userInfo.deposit_amount += amount;
        userInfo.isClaimed = false;

        emit BetDeposited(leagueId, eventId, msg.sender, amount, position, token);
    }

    function getRewardPercent(uint16 betCount) private view returns(uint256) {
        uint16 lvl = betCount / 50;
        if (lvl > MAX_LEVEL) lvl = MAX_LEVEL;
        uint256 percent = BASE_REWARD_PERCENT + uint256(lvl);
        if (percent > FEE) {
            percent = FEE;
        }
        return percent;
    }


    // User can claim only if he is in winner list
    function claim(string memory leagueTitle, uint32 eventId, BaseToken token) external {
        uint16 leagueId = getLeagueId(leagueTitle);
        BettingItem memory betItem = betEvents[leagueId][eventId];
        BetInfo storage userInfo = userInfos[leagueId][eventId][msg.sender][token];
        require(userInfo.deposit_amount > 0, "You have not amount to claim");
        require(userInfo.isClaimed == false, "You already claimed");
        require(betItem.event_result == userInfo.position, "You are not winner");

        DepopsitedAmount memory betAmount = betAmounts[leagueId][eventId][token];
        uint256 totalAmount = betAmount.deposit_a + betAmount.deposit_b + betAmount.deposit_c;
        uint256 totalClaimableAmount = totalAmount * (DENOMINATOR - FEE) / DENOMINATOR;
        uint256 claimAmount = 0;

        if (betItem.event_result == Position.OutcomeA) {
            claimAmount = totalClaimableAmount * userInfo.deposit_amount / betAmount.deposit_a;
        } else if (betItem.event_result == Position.OutcomeB) {
            claimAmount = totalClaimableAmount * userInfo.deposit_amount / betAmount.deposit_b;
        } else if (betItem.event_result == Position.OutcomeC) {
            claimAmount = totalClaimableAmount * userInfo.deposit_amount / betAmount.deposit_c;
        } else {
            revert("Result has not been reported");
        }

        require(claimAmount > 0, "You have no any amount to claim");

        if (token == BaseToken.BNB) {
            payable(msg.sender).transfer(claimAmount);
        } else {
            IERC20 claimToken = baseTokens[token];
            claimToken.transfer(msg.sender, claimAmount);
        }
        
        userInfo.isClaimed = true;

        emit Claimed(leagueId, eventId, claimAmount, betItem.event_result, address(baseTokens[token]));
    }

    // When event has been canceled, user can claim without any fee
    // Only take gas fee for transaction excution 
    function claim_forcancel(
        string memory leagueTitle, 
        uint32 eventId, 
        BaseToken token
    ) external {
        uint16 leagueId = getLeagueId(leagueTitle);
        BettingItem memory betItem = betEvents[leagueId][eventId];
        require(betItem.event_result == Position.CANCEL, "Event not canceled");
        BetInfo storage userInfo = userInfos[leagueId][eventId][msg.sender][token];
        require(userInfo.deposit_amount > 0, "You have not amount to claim");
        require(userInfo.isClaimed == false, "You already claimed");

        if (token == BaseToken.BNB) {
            payable(msg.sender).transfer(userInfo.deposit_amount);
        } else {
            IERC20 claimToken = baseTokens[token];
            claimToken.transfer(msg.sender, userInfo.deposit_amount);
        }
        
        userInfo.isClaimed = true;

        emit Claimed(leagueId, eventId, userInfo.deposit_amount, betItem.event_result, address(baseTokens[token]));
    }

    // Admin should report the results.
    function report_result(string memory leagueTitle, uint32 eventId, Position result) external onlyOwner {
        uint16 leagueId = getLeagueId(leagueTitle);
        BettingItem storage betItem = betEvents[leagueId][eventId];

        if (betItem.event_result == Position.OutcomeA || 
            betItem.event_result == Position.OutcomeB || 
            betItem.event_result == Position.OutcomeC || 
            betItem.event_result == Position.CANCEL
        ) {
            revert("Result has been already reported");
        }
        require(betItem.event_result != result, "Status is same");
        betItem.event_result = result;

        if (result == Position.OutcomeA || 
            result == Position.OutcomeB || 
            result == Position.OutcomeC
        ) {
            addTreasury(leagueId, eventId);
        }
        emit ResultReport(leagueId, eventId, result);
    }

    function addTreasury(uint16 leagueId, uint32 eventId) private {
        BettingItem memory betItem = betEvents[leagueId][eventId];
        require(betItem.isTreasuryClaimed == false, "Already claimed");

        DepopsitedAmount memory bnbBetAmount = betAmounts[leagueId][eventId][BaseToken.BNB];
        DepopsitedAmount memory muftBetAmount = betAmounts[leagueId][eventId][BaseToken.MUFT];
        DepopsitedAmount memory mswapBetAmount = betAmounts[leagueId][eventId][BaseToken.MSWAP];

        uint256 bnbClaimableAmount = (bnbBetAmount.deposit_a + bnbBetAmount.deposit_b + bnbBetAmount.deposit_c) * FEE / DENOMINATOR;
        uint256 muftClaimableAmount = (muftBetAmount.deposit_a + muftBetAmount.deposit_b + muftBetAmount.deposit_c) * FEE / DENOMINATOR;
        uint256 mswapClaimableAmount = (mswapBetAmount.deposit_a + mswapBetAmount.deposit_b + mswapBetAmount.deposit_c) * FEE / DENOMINATOR;

        if (bnbClaimableAmount > 0) {
            treasuryInfo.bnb_amount += int256(bnbClaimableAmount);
        }

        if (muftClaimableAmount > 0) {
            treasuryInfo.muft_amount += int256(muftClaimableAmount);
        }

        if (mswapClaimableAmount > 0) {
            treasuryInfo.mswap_amount += int256(mswapClaimableAmount);
        }
        betItem.isTreasuryClaimed = true;
    }

    // Admin can claim treasury amount of betting
    function claimTreasury() external onlyOwner {

        address feeAddress = adminRole.getFeeAddress();
        int256 claimBnbAmount = treasuryInfo.bnb_amount;
        int256 claimMuftAmount = treasuryInfo.muft_amount;
        int256 claimMswapAmount = treasuryInfo.mswap_amount;

        if (claimBnbAmount <= 0 && claimMuftAmount <= 0 && claimMswapAmount <= 0) {
            revert("Not enough amount to claim");
        }

        if (claimBnbAmount > 0) {
            payable(feeAddress).transfer(uint256(claimBnbAmount));
            treasuryInfo.bnb_amount = 0;
        }

        if (claimMuftAmount > 0) {
            IERC20 muftToken = baseTokens[BaseToken.MUFT];
            muftToken.transfer(feeAddress, uint256(claimMuftAmount));
            treasuryInfo.muft_amount = 0;
        }

        if (claimMswapAmount > 0) {
            IERC20 mswapToken = baseTokens[BaseToken.MSWAP];
            mswapToken.transfer(feeAddress, uint256(claimMswapAmount));
            treasuryInfo.mswap_amount = 0;
        }

        emit ClaimedTreasury(msg.sender, feeAddress, uint256(claimBnbAmount), uint256(claimMuftAmount), uint256(claimMswapAmount));
    }

    // User can withdraw his rewards
    function withdrawReward() external {
        RewardInfo storage reward = rewards[msg.sender];
        
        uint256 claimBnbAmount = reward.bnb_amount;
        uint256 claimMuftAmount = reward.muft_amount;
        uint256 claimMswapAmount = reward.mswap_amount;

        if (claimBnbAmount == 0 && claimMuftAmount == 0 && claimMswapAmount == 0) {
            revert("Not enough reward amount to withdraw");
        }

        if (claimBnbAmount > 0) {
            payable(msg.sender).transfer(claimBnbAmount);
            reward.bnb_amount = 0;
        }

        if (claimMuftAmount > 0) {
            IERC20 token = baseTokens[BaseToken.MUFT];
            token.transfer(msg.sender, claimMuftAmount);
            reward.muft_amount = 0;
        }

        if (claimMswapAmount > 0) {
            IERC20 token = baseTokens[BaseToken.MSWAP];
            token.transfer(msg.sender, claimMswapAmount);
            reward.mswap_amount = 0;
        }

        emit RewardClaimed(msg.sender, claimBnbAmount, claimMuftAmount, claimMswapAmount);
    }
    
    function update_adminRole(address _adminRole) external onlyOwner {
        require(_adminRole != address(0x0), "Invalid address");
        adminRole = IAdminRole(_adminRole);
        require (adminRole.getFeeAddress() != address(0x0), "Invalid admin role");
    }

    function update_league(address _league) external onlyOwner {
        require(_league != address(0x0), "Invalid league address");
        league = ILeague(_league);
        require (league.getLeagueId("Test") >= 0, "Invalid league address");
    }

    function update_fee(uint256 _FEE) external onlyOwner {
        require(FEE != _FEE, "Same value");
        FEE = _FEE;
    }

    function update_level(uint16 _MAX_LEVEL) external onlyOwner {
        require(MAX_LEVEL != _MAX_LEVEL, "Same value");
        MAX_LEVEL = _MAX_LEVEL;
    }

    function getLeagueId(string memory leagueTitle) private view returns(uint16) {
        return league.getLeagueId(leagueTitle);
    }
    
    function getEventCounter(string memory leagueTitle) external view returns(uint32) {
        return eventCounter[league.getLeagueId(leagueTitle)];
    }

    function getEventInfo(string memory leagueTitle, uint32 eventId, BaseToken token) external view returns(DepopsitedAmount memory depositedAmount) {
        uint16 leagueId = getLeagueId(leagueTitle);
        depositedAmount = betAmounts[leagueId][eventId][token];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// This is for other NFT contract
interface ILeague{
    function getLeagueId(string memory title) external view returns(uint16);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

// This is for other NFT contract
interface IAdminRole{
    function isPlatformOwner(address _admin) external view returns(bool);    
    function getFeeAddress() external view returns(address);
}

// SPDX-License-Identifier: MIT
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