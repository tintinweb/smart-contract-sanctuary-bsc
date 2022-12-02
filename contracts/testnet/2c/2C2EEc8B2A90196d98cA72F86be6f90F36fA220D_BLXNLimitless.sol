/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        // require(isContract(target), "Address: call to non-contract"); //discuss this line
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

abstract contract ReentrancyGuard {
    bool internal locked;
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        require(msgSender != address(0), "Owner is address(0).");
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() external view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

struct PlayerStats {// This is global user information that will update.
    address userID; // User address global
    uint256 totalPlayed; // User played all time global
    uint256 totalClaimed; // User claimed all time global
    uint256 vipCount; // # of VIPs the user has purchased
    bool vvip; // if user has > 5 VIPs, they are VVIP
    ReferralInfo[] refList; // List of all users that player has referred + additional info.
}

struct Round {// Each round will have different sets of information.
    bool vipOpen; // Is VIP open for purchase right now? (before viplaunch)
    uint256 vipStartTime; // vipLaunch of round
    uint256 vipRewardsRate; // vip daily % of round
    uint256 publicStartTime; // pubLaunch of round
    uint256 publicRewardsRate; // pub daily # of round
    bool complete; // Is the round finished?
    uint256 endTime; // endtime of round when it's complete and a new round starts
    uint256 totalPlayed; // total sum of BUSD played this round
    uint256 transactions; // # of transactions
    uint256 maxTVL; // Tracker for the max TVL this round (used to calculate stop threshold)
    address[] vipUserList; // List of all VIP addresses this round
    address[] regUserList; // List of all reg addresses this round
    mapping(address => Player) playerList; // Structs of player information participating in this round.
    uint256 roundStart;
}

struct Player {// Players are added to each round as they join. New round, blank player.
    address userID; // Player address
    uint256 totalEntryValue; // Total amount entered into round by player.
    uint256 refEarned; // Total referral earned by player (added to their totalEntryValue to get rewards only)
    uint256 startTime; // When did the player start?
    uint256 calculationMilestone; // The last time we calculated users' rewards.
    uint256 claimableAmount; // Rewards available to claim right now by player in current round.
    uint256 claimedAmount; // Total rewards claimed this round by player.
    bool existingUser; // Is the player already playing in this round?
    bool vipStatus; // Is the player a VIP?
}

struct ReferralInfo {// Users will be able to see who they referred & more.
    uint256 amount; // The amount the player entered with while using your referral.
    address referral; // Address of the player that used referral.
    uint256 earning; // How much a player is making from this referral.
    uint256 round; // The round in which the referral was used.
}

contract BLXNLimitless is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public testMode; // Allows us to test
    address public devWallet; // BLXN wallet address
    IERC20 public BUSD; // BUSD contract

    uint256 public currentRewardRate; // Global tracking of regular user Reward Rate.
    uint256 public currentVIPRewardRate; // Global tracking of VIP user Reward Rate.
    uint256 public contractStartTimestamp; // When did the contract start? Helps us calculate runtime.

    uint256 constant public BLXN_FEE = 500; // 5% fee to Team BLXN
    uint256 public REWARD_DURATION = 1 days; // Earnings are at a daily rate
    uint256 public VIP_DURATION = 1 days; // VIP users can deposit for 1 day before public launch.
    uint256 public VIP_WINDOW = 7 days; // VIP is available for purchase for 7 days between rounds.
    uint256 constant public MULTIPLIER = 10000; // For math
    uint256 constant public TVL_CARRYOVER = 500; // 5% of max TVL will be tracked per round to carry over and start the next round with.

    uint256 public vipLaunch; // Tracking the time of VIP launch for current round.
    uint256 public publicLaunch; // Tracking the time of public launch for current round.

    uint256 public uniqueUsers = 0; // Tracking all unique wallet addresses (summed up each round)
    uint256 public allTimeRewards = 0; // Global tracking of all claims.
    uint256 public allTimePlayed = 0; // Global tracking of all played amounts.
    uint256 public allTimeVIPs = 0; // Global tracking of VIPs purchased.
    uint256 public currentRound; // Global tracking of which round we're in.
    uint256 public resetThreshold; // Global tracking of the contract balance that will be used to stop a round and start a new round.

    mapping(uint256 => Round) public roundProperties;

    mapping(address => PlayerStats) public playerStats;

    constructor(bool _test) {
        devWallet = 0x052E9FB338F18170edA1F69fDC546183e1e4474E;
        if (_test == true) {
            BUSD = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
            VIP_WINDOW = 15 minutes;
            VIP_DURATION = 10 minutes;
            testMode = true;
            REWARD_DURATION = 1 minutes;
        } else if (_test == false) {
            BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
            testMode = false;
        }
        contractStartTimestamp = block.timestamp;
    }

    event Participate(address indexed user, uint256 amount, uint256 indexed round, bool vip);
    event Compound(address indexed user, uint256 amount, uint256 indexed round, bool vip);
    event Collect(address indexed user, uint256 amount, uint256 indexed round, bool vip);
    event TVLChange(uint256 timestamp, uint256 tvl);
    event NewVIP(address indexed user, uint256 round);

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    // This function will allow the owner to start the dapp. We start the first round and immediately renounce ownership.
    // There are no more owner-only functions going forward.
    function StartLimitlessExperience() external onlyOwner {
        BLXNStartNextRound();
        renounceOwnership();
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    // This function (only used internally) is used to start the next round.
    // This will only be kicked off if players are claiming rewards and balance hits resetThreshold.
    // We semi-randomly select the next earnings rates for pub and vip users.
    // We then increment the round and full it with info like start times, etc.
    function BLXNStartNextRound() internal {
        // ROUND-LEVEL TRACKING
        roundProperties[currentRound].endTime = block.timestamp;
        roundProperties[currentRound].complete = true;

        uint256 calculatedBaseRewards = returnRandomNumber(8).mul(100);
        if (calculatedBaseRewards == 0) {
            calculatedBaseRewards = 100;
        }
        uint256 vipBonus = returnRandomNumber(2).mul(100);
        if (vipBonus == 0) {
            vipBonus = 100;
        }

        currentRound++;

        roundProperties[currentRound].vipOpen = true;
        roundProperties[currentRound].roundStart = block.timestamp;
        roundProperties[currentRound].vipStartTime = block.timestamp + VIP_WINDOW;
        roundProperties[currentRound].publicStartTime = block.timestamp + VIP_WINDOW + VIP_DURATION;
        roundProperties[currentRound].publicRewardsRate = calculatedBaseRewards;
        roundProperties[currentRound].vipRewardsRate = calculatedBaseRewards + vipBonus;
        roundProperties[currentRound].maxTVL = returnContractBalance();
        calculateStopThreshold();

        // GLOBAL-LEVEL TRACKING
        currentRewardRate = calculatedBaseRewards;
        currentVIPRewardRate = calculatedBaseRewards + vipBonus;
        vipLaunch = roundProperties[currentRound].vipStartTime;
        publicLaunch = roundProperties[currentRound].publicStartTime;
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    // This is where users can get started. We add their address to the round list.
    // Contract receives user BUSD, sends BLXN dev fee, and populates user info.
    function BLXNParticipate(uint256 _entryAmount, address _ref) external {
        Round storage round = roundProperties[currentRound];

        PlayerStats storage player = playerStats[msg.sender];

        // We need to be in at least Round 1 to start.
        require(currentRound > 0, "BLXN Limitless hasn't started yet!");

        // Check if public launch has happened, if not, user needs to be VIP.
        require(block.timestamp >= round.publicStartTime || round.playerList[msg.sender].vipStatus == true, "You are not a VIP member.");

        // Check if VIP launch time has passed.
        require(block.timestamp >= round.vipStartTime, "App did not launch yet.");

        // Minimum deposit is 50 BUSD.
        if (testMode == false) {
            require(_entryAmount >= 50 ether, "Minimum participation requires 50 BUSD");
        }

        // If the current time is past the VIP Start Time, close VIP purchases.
        if (block.timestamp >= round.vipStartTime) {
            round.vipOpen = false;
        } else {
            revert("Round is not open to VIPs yet.");
        }

        // Players cannot use themselves as a referral.
        require(_ref != msg.sender, "You cannot refer yourself.");

        // Sends BUSD from player to contract.
        if (testMode == false) {
            BUSD.safeTransferFrom(msg.sender, address(this), _entryAmount);
        }

        // Calculate BLXN fee and subtract it from user entry.
        uint256 fee = (_entryAmount * BLXN_FEE).div(MULTIPLIER);
        uint256 netEntry = _entryAmount - fee;

        // Send team BLXN our fee.
        if (testMode == false) {
            BUSD.safeTransfer(devWallet, fee);
        }

        // If the player was referred, the referrer needs to already be playing this round.
        // The referrer can now see who used their link, amount, earnings, round.
        // The referrer gets 2% added to their total entry this round.
        if (_ref != 0x000000000000000000000000000000000000dEaD && round.playerList[_ref].totalEntryValue > 0) {
            playerStats[_ref].refList.push(
                ReferralInfo({
                    amount: netEntry,
                    referral: msg.sender,
                    earning: netEntry.mul(20).div(MULTIPLIER),
                    round: currentRound
                })
            );
            // If we're adding to a referrer's total entry value, we need to calculate their existing rewards first.
            calculateRewards(_ref);
            // Add 2% referral to the total entry value of the referrer.
            round.playerList[_ref].totalEntryValue += netEntry.mul(20).div(MULTIPLIER);
        }

        // ROUND PLAYER-LEVEL TRACKING

        // If the player isn't already in this round, we add their start time, etc.
        if (round.playerList[msg.sender].existingUser == false) {
            // If the player is not VIP, we add them to reg user list for this round. VIPs are added when they buy VIP.
            if (round.playerList[msg.sender].vipStatus == false) {
                round.regUserList.push(msg.sender);
            }
            uniqueUsers++;
            round.playerList[msg.sender].userID = msg.sender;
            round.playerList[msg.sender].startTime = block.timestamp;
            round.playerList[msg.sender].calculationMilestone = block.timestamp;
            round.playerList[msg.sender].existingUser = true;
        }

        // When users enter more, we calculate their accrued rewards first.
        calculateRewards(msg.sender);
        // Then we add the users new amount to their total.
        round.playerList[msg.sender].totalEntryValue += netEntry;

        // ROUND-LEVEL TRACKING
        round.transactions++;
        round.totalPlayed += netEntry;

        // PLAYER-LEVEL TRACKING
        if (player.userID != msg.sender) {
            player.userID = msg.sender;
        }
        player.totalPlayed += netEntry;

        // GLOBAL TRACKING
        allTimePlayed += _entryAmount;

        // As more users join this round, track TVL and adjust the stop threshold.
        calculateStopThreshold();

        emit Participate(msg.sender, netEntry, currentRound, round.playerList[msg.sender].vipStatus);
        emit TVLChange(block.timestamp, returnContractBalance());
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    // This function will calculate user rewards. If the user reward is too high, new round will start.
    // If the users reward is higher than contract balance OR if the remaining contract balance goes below
    // resetThreshold, user has trigged the start of the next round!
    function BLXNCollect() external {
        Round storage round = roundProperties[currentRound];

        PlayerStats storage player = playerStats[msg.sender];

        // Calculate the users accrued rewards.
        calculateRewards(msg.sender);

        // Calculate our fee and users transfer amount minus fee.
        uint256 baseClaimAmount = round.playerList[msg.sender].claimableAmount;
        uint256 fee = (baseClaimAmount * BLXN_FEE).div(MULTIPLIER);
        uint256 amountToSend = baseClaimAmount - fee;

        // Check contract balance
        uint256 currentTVL = returnContractBalance();

        // If the amount to send to user is higher than balance or reset threshold gets passed, next round starts.
        // revert should prevent safeTransfers from happening.
        if (currentTVL < amountToSend || currentTVL - amountToSend < resetThreshold) {
            BLXNStartNextRound();
        } else {
            // ROUND PLAYER-LEVEL TRACKING
            round.playerList[msg.sender].claimableAmount -= amountToSend;
            round.playerList[msg.sender].claimedAmount += amountToSend;

            // Send user and Team BLXN respective amounts.
            if (testMode == false) {
                BUSD.safeTransfer(msg.sender, amountToSend);
                BUSD.safeTransfer(devWallet, fee);
            }

            // ROUND-LEVEL TRACKING
            roundProperties[currentRound].transactions++;

            // PLAYER-LEVEL TRACKING
            player.totalClaimed += amountToSend;

            // GLOBAL TRACKING
            allTimeRewards += amountToSend;
            emit Collect(msg.sender, amountToSend, currentRound, round.playerList[msg.sender].vipStatus);
            emit TVLChange(block.timestamp, currentTVL);
        }
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    // Similar to BLXNCollect() except we just move values to the player struct within round instead of safeTransfering to user.
    // Fees are still sent.
    function BLXNCompound() external {
        Round storage round = roundProperties[currentRound];

        PlayerStats storage player = playerStats[msg.sender];

        calculateRewards(msg.sender);

        uint256 baseClaimAmount = round.playerList[msg.sender].claimableAmount;
        uint256 fee = (baseClaimAmount * BLXN_FEE).div(MULTIPLIER);
        uint256 amountToCompound = baseClaimAmount - fee;

        uint256 currentTVL = returnContractBalance();
        emit TVLChange(block.timestamp, currentTVL);

        if (currentTVL < amountToCompound || currentTVL - amountToCompound < resetThreshold) {
            BLXNStartNextRound();
        } else {
            // ROUND PLAYER-LEVEL TRACKING
            round.playerList[msg.sender].claimableAmount -= amountToCompound;
            // Compounding means the user has claimed and then entered the amount.
            round.playerList[msg.sender].claimedAmount += amountToCompound;
            round.playerList[msg.sender].totalEntryValue += amountToCompound;

            // Send Team BLXN fee.
            if (testMode == false) {
                BUSD.safeTransfer(devWallet, fee);
            }

            // ROUND-LEVEL TRACKING
            roundProperties[currentRound].transactions++;

            // PLAYER-LEVEL TRACKING
            player.totalClaimed += amountToCompound;
            player.totalPlayed += amountToCompound;
            emit Compound(msg.sender, amountToCompound, currentRound, round.playerList[msg.sender].vipStatus);
        }
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    // This is where we check the contract balance and set the resetThreshold.
    // When users claim / compound, we check this resetThreshold to determine if we will start a new round.
    function calculateStopThreshold() internal {
        Round storage round = roundProperties[currentRound];

        //Get current TVL number
        uint256 currentTVL = returnContractBalance();
        emit TVLChange(block.timestamp, currentTVL);

        // If current TVL greater than our previously recorded max, update it.
        if (currentTVL > round.maxTVL) {
            round.maxTVL = currentTVL;
        }

        // Our threshold to start a new round from scratch is 5% of the round MAX.
        resetThreshold = round.maxTVL.mul(TVL_CARRYOVER).div(MULTIPLIER);
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    // This is where we calculate user rewards. Max time rewards can accrue is 1 day.
    // When users claim / compound, we check this resetThreshold to determine if we will start a new round.
    function calculateRewards(address _userWallet) internal {
        Round storage round = roundProperties[currentRound];
        uint256 earningsRate = currentRewardRate;

        // If user is VIP, use vip reward rate.
        if (round.playerList[_userWallet].vipStatus == true) {
            earningsRate = round.vipRewardsRate;
            // Else user is pub, use pub reward rate.
        } else {
            earningsRate = round.publicRewardsRate;
        }

        uint256 elapsedTime = block.timestamp - round.playerList[_userWallet].calculationMilestone;

        // Rewards only accrue for 48 hours.
        if (elapsedTime > 2 days) {
            elapsedTime = 2 days;
        }
        uint256 accruedRewards = (elapsedTime * round.playerList[_userWallet].totalEntryValue * earningsRate)
            .div(MULTIPLIER * REWARD_DURATION);

        // Update the users last calculation time so we can pick up from there next time this is called.
        round.playerList[_userWallet].calculationMilestone = block.timestamp;
        round.playerList[_userWallet].claimableAmount += accruedRewards;
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    // Function to join whitelist and get early access.
    function joinVIP() external payable {
        // Sets variable to access Round Struct.
        Round storage round = roundProperties[currentRound];

        PlayerStats storage player = playerStats[msg.sender];

        // Requires that the current time is after the Whitelist launch date.
        require(block.timestamp < round.vipStartTime, "You can only join VIP before the VIP launch");

        require(round.vipOpen == true, "VIP isn't open yet.");

        // Ensures users cannot accidentally purchase VIP more than once.
        require(round.playerList[msg.sender].vipStatus == false, "You already have VIP!");

        // Requires the amount to join Whitelist is 0.05BNB.
        if (player.vvip == false && testMode == false) {
            require(msg.value == 0.05 ether, "VIP launch price is 0.05 BNB");
        }

        // Sends whitelist fees to dev wallet
        payable(devWallet).transfer(msg.value);

        // ROUND PLAYER-LEVEL TRACKING
        // Sets Whitelist struct mapped to User to true so they access the dapp early.
        round.playerList[msg.sender].vipStatus = true;
        round.vipUserList.push(msg.sender);
        emit NewVIP(msg.sender, currentRound);

        // PLAYER-LEVEL TRACKING
        player.vipCount++;
        if (player.vipCount > 5) {
            player.vvip = true;
        } // TODO: What does VVIP do?

        // GLOBAL-LEVEL TRACKING
        // Adds to all time total VIPs.
        allTimeVIPs++;
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    //VIEW-ONLY FUNCTIONS TO RETURN VALUES
    function returnUserRewards(address _userWallet) public view returns (uint256) {
        Round storage round = roundProperties[currentRound];

        uint256 earningsRate = currentRewardRate;

        if (round.playerList[_userWallet].vipStatus == true) {
            earningsRate = round.vipRewardsRate;
        } else {
            earningsRate = round.publicRewardsRate;
        }

        uint256 elapsedTime = block.timestamp - round.playerList[_userWallet].calculationMilestone;
        if (elapsedTime > 2 days) {
            elapsedTime = 2 days;
        }
        uint256 accruedRewards = (elapsedTime * round.playerList[_userWallet].totalEntryValue * currentRewardRate)
            .div(MULTIPLIER * REWARD_DURATION);

        return accruedRewards;
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    function returnContractBalance() public view returns (uint256) {
        if (testMode) {
            return allTimePlayed - allTimeRewards;
        } else {
            return BUSD.balanceOf(address(this));
        }
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    function returnUserReferrals(address userWallet) external view returns (ReferralInfo[] memory) {
        PlayerStats storage player = playerStats[userWallet];
        return player.refList;
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    function returnPlayerInfoByRound(uint256 roundNumber, address userWallet) external view returns (Player memory) {
        Round storage round = roundProperties[roundNumber];
        return round.playerList[userWallet];
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    function returnVIPsByRound(uint256 roundNumber) external view returns (address[] memory, uint256) {
        Round storage round = roundProperties[roundNumber];
        return (round.vipUserList, round.vipUserList.length);
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    function returnRegUsersByRound(uint256 roundNumber) external view returns (address[] memory, uint256) {
        Round storage round = roundProperties[roundNumber];
        return (round.regUserList, round.regUserList.length);
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    function returnGlobalsTogether()
        external view returns (
            uint256 unique,
            uint256 reward,
            uint256 played,
            uint256 vipCount,
            uint256 round,
            uint256 publicRate,
            uint256 vipRate
        )
    {
        return (
            uniqueUsers,
            allTimeRewards,
            allTimePlayed,
            allTimeVIPs,
            currentRound,
            currentRewardRate,
            currentVIPRewardRate
        );
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    function returnTotalClaimableByRound(uint256 roundNumber) external view returns (uint256) {
        Round storage round = roundProperties[roundNumber];

        uint256 vipUserCount = round.vipUserList.length;
        uint256 pubUserCount = round.regUserList.length;
        uint256 vipClaimable;
        uint256 pubClaimable;

        for (uint256 i = 0; i < vipUserCount; i++) {
            vipClaimable += returnUserRewards(round.vipUserList[i]);
        }
        for (uint256 i = 0; i < pubUserCount; i++) {
            pubClaimable += returnUserRewards(round.regUserList[i]);
        }

        uint256 totalClaimable = vipClaimable + pubClaimable;

        return totalClaimable;
    }

    // NOTE: IF YOU FORK US, PLEASE FORWARD SOME FEES TO US!
    // WALLET: 0x052E9FB338F18170edA1F69fDC546183e1e4474E
    function returnRandomNumber(uint256 _modulus) public view returns (uint256){
        uint256 randNonce = 0;
        randNonce++;
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
    }
}