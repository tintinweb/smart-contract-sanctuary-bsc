// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
    Round V4
*/

import "@openzeppelin/contracts/utils/Strings.sol";

interface BankVault {
    function accounts(address user) external view returns (string[] memory);
    function balance(address user, string memory account) external view returns (uint256);
    function balance(address user) external view returns (uint256);
    function credit(address user, string memory account, string memory note) external payable;
    function creditMany(address[] memory users, uint256[] memory amounts, string memory account, string memory note) external payable;
    function debit(string memory account, uint256 amount) external;
    function withdrawAll() external;
    function transferMany(address[] memory users, uint256[] memory amounts, string memory fromAccount, string memory toAccount, string memory note) external;
    function transfer(address to, uint256 amount, string memory fromAccount, string memory toAccount, string memory note) external;
    function escrow(uint256 escrow_id, address user, string memory account, string memory note) external payable;
    function closeEscrow(uint256 escrow_id) external;
    function cancelEscrow(uint256 escrow_id) external;
}

interface Referral {
    function refer(address user, address referrer) external returns (bool);
    function addAdmin(address admin) external view;
    function disableAdmin(address admin) external view;
    function get(address user) external view returns (bool, address);
}

/// @title Round
/// @author 0x6Fa02ed6248A4a78609368441265a5798ebaFC78
/// @notice Represent a single betting round. This contract is deployed by the Round Factory. All the ether received is transfered to the vault to the various recipients.
/// @dev Except for `payoutValue()` & `bet()`, all other methods are expected to be called by the Factory. Round#0 is not playable, will return a "Forbidden" error (gas saving on every bets)
contract Round {

    struct betStruct {
        uint date;
        address wallet;
        uint256 sent;
        uint256 value;
        uint8 bet;
    }
    struct Price {
        uint256 price;
        uint256 priceTimestamp;
        uint256 blockTimestamp;
    }
    
    // Round info
    address public creator;
    string public pair;
    uint256 public minBetValue;
    uint256 public round_id;
    string round_id_str;
    uint public round_created;
    uint public round_init;
    uint public round_start;
    uint public round_end;
    Price public price_start;
    Price public price_end;
    bool public started;
    bool public ended;
    bool public canceled;

    // Liquidity Tracking
    uint256 public betUp;
    uint256 public betDown;
    uint256 public roundValue;

    // Fee Tracking
    uint256 public feeValue; // Fees earned by the Factory
    uint256 public creatorFeeValue; // Fees earned by the round creator

    // Bet tracking
    betStruct[] public bets;
    uint256 public betCount;
    mapping(address=>uint256) public betIds;
    mapping(address=>bool) public hasBet;
    uint256[] betAmounts;
    address[] betAddr;
    address[] upAddr;
    address[] downAddr;

    // Contract
    address public owner;
    uint256 public decimals = 8;
    uint256 public referralFees;
    uint256 public creatorFees;
    uint256 public roundFees;

    // Factory
    RoundFactory factory;
    BankVault vault;

    constructor (address _creator, string memory pairName, uint256 _round_id, uint startTime, uint timeToBet, uint roundDuration, uint256 _minBetValue, uint256 _referralFees, uint256 _creatorFees, uint256 _roundFees) {
        owner         = msg.sender;
        creator       = _creator;
        minBetValue   = _minBetValue;
        pair          = pairName;
        round_id      = _round_id;
        round_id_str  = Strings.toString(round_id);
        round_created = block.timestamp;
        round_init    = startTime;
        round_start   = round_init+timeToBet;
        round_end     = round_init+roundDuration;
        referralFees  = _referralFees;
        creatorFees   = _creatorFees;
        roundFees     = _roundFees;
        factory       = RoundFactory(payable(msg.sender));
        vault         = BankVault(0xfAbEe939647804253B226f9cEE026a6e55C729C0);
    }

    receive() external payable {}
    fallback() external payable {}


    /// @notice Place a bet
    /// @dev Callable by anybody
    /// @param betDirection Direction of the bet: 0->Down, 1->Up
    /// @param referredBy Address of the referrer or 0x0000000000000000000000000000000000000000. A user can only have one referrer, which is attached to that user for life. Referrers earn 1% of that user's bet forever.
    function bet(uint8 betDirection, address referredBy) public payable {
        require(started==false, "Betting is over");
        require(canceled==false, "Canceled");
        require(block.timestamp >= round_init, "Round not started yet");
        require(block.timestamp < round_start, "Betting is now closed");
        require(hasBet[msg.sender]==false, "You can't bet twice");
        require(betDirection<=1, "Invalid bet");
        if (minBetValue==0) {
            require(msg.value > 0, "Bet a bit more");
        } else {
            require(msg.value >= minBetValue, "Bet a bit more");
        }
        // Fees
        // Round Fees
        uint256 _fees = roundFees*msg.value/(10**decimals);
        feeValue += _fees;
        // Creator Fees
        uint256 _creatorFees = creatorFees*msg.value/(10**decimals);
        creatorFeeValue += _creatorFees;
        // Referral Fees
        uint256 _referralFees = referralFees*msg.value/(10**decimals);

        (bool hasReferrer, address referrer, bool isNewReferral) = factory.register_referral(msg.sender, referredBy);
        if (hasReferrer) {
            // The user has a referrer, escrow the fee, since not given if the round is canceled
            vault.escrow{value: _referralFees}(round_id, referrer, "Referral Fees", "User referral");
        } else {
            // No referrer, the round takes the fees
            feeValue += _referralFees;
        }
        if (isNewReferral) {
            factory.logReferral(round_id, msg.sender, referredBy, _referralFees);
        } else if (hasReferrer) {
            factory.logReferralFees(round_id, msg.sender, referredBy, _referralFees);
        }
        uint256 afterFees = msg.value - _fees - _creatorFees - _referralFees;
        bets.push(betStruct(block.timestamp, msg.sender, msg.value, afterFees, betDirection));
        betIds[msg.sender] = betCount;
        hasBet[msg.sender] = true;
        betCount += 1;
        roundValue += afterFees;
        if (betDirection==0) {
            betDown += afterFees;
            downAddr.push(msg.sender);
        } else {
            betUp += afterFees;
            upAddr.push(msg.sender);
        }
        betAmounts.push(msg.value);
        betAddr.push(msg.sender);
        factory.logBet(msg.sender, msg.value, betDirection, round_id);
    }
    

    /// @notice Start the round, locking the start price passed as a parameter
    /// @dev Only callable by the Factory
    /// @param price Locked start price. Immutable once set.
    /// @param priceTimestamp Timestamp at which that price was obtained.
    function start(uint256 price, uint256 priceTimestamp) public {
        require(msg.sender == owner, "Access Denied");
        require(started==false, "Alreaded started");
        require(canceled==false, "Canceled");
        require(block.timestamp >= round_start, "Too early to start");
        if (block.timestamp > round_start+30 || upAddr.length==0 || downAddr.length==0) {
            // We cancel the round and trigger refunds because:
            // - Betting is over and there are no odds (No bet on at least one side)
            // or
            // - The round is over 30sec late to start, the price obtained wouldn't be valid
            cancel(address(this));
        } else {
            price_start = Price(price, priceTimestamp, block.timestamp);
            started = true;
        }
    }
    

    /// @notice End the round, locking the end price passed as a parameter
    /// @dev Only callable by the Factory
    /// @param price Locked end price. Immutable once set.
    /// @param priceTimestamp Timestamp at which that price was obtained.
    /// @return creatorFeeValue Fees the round creator earned (2% of all bets)
    /// @return feeValue Fees the Factory earned (2% of all bets if the user has a referrer, 3% if no referrer)
    function end(uint256 price, uint256 priceTimestamp) public returns (uint256, uint256) {
        require(msg.sender == owner, "Access Denied");
        require(ended==false, "Alreaded ended");
        require(canceled==false, "Canceled");
        require(block.timestamp >= round_end, "Too early to end");
        if (block.timestamp > round_end+30) {
            // The round is over 30sec late to end, the price obtained wouldn't be valid, we cancel the round and trigger refunds
            cancel(address(this));
            return (0, 0);
        } else {
            ended = true;

            uint256[] memory wonValues;
            uint256 wonSum;

            price_end = Price(price, priceTimestamp, block.timestamp);
            uint i;
            uint256 l;
            if (price_end.price>price_start.price) {
                l = upAddr.length;
                for (i=0;i<l;i++) {
                    (uint256 payoutUp, /*uint256 payoutDown*/) = payoutValue(betIds[upAddr[i]]);
                    wonValues[i] = payoutUp;
                    wonSum += payoutUp;
                }
                // Pay the winners
                vault.creditMany{value: wonSum}(upAddr, wonValues, "Won", round_id_str);
                factory.logWins(upAddr, wonValues, round_id);
            } else if (price_end.price<price_start.price) {
                l = downAddr.length;
                for (i=0;i<l;i++) {
                    (/*uint256 payoutUp*/, uint256 payoutDown) = payoutValue(betIds[downAddr[i]]);
                    wonValues[i] = payoutDown;
                    wonSum += payoutDown;
                }
                // Pay the winners
                vault.creditMany{value: wonSum}(downAddr, wonValues, "Won", round_id_str);
                factory.logWins(downAddr, wonValues, round_id);
            } else {
                // The round wins
                // Split the balance 50/50 with the creator
                uint256 splitValue = address(this).balance/2;
                creatorFeeValue = splitValue;
                feeValue = splitValue;
            }
            // Pay out the round creator
            vault.credit{value: creatorFeeValue}(creator, "Creator Fees", round_id_str);

            // Pay out the factory (rest of the balance)
            vault.credit{value: address(this).balance}(owner, "Round Fees", round_id_str);

            // Close the escrow
            vault.closeEscrow(round_id);

            return (creatorFeeValue, feeValue);
        }
    }

    /*function blockTimestamp() public view returns (uint) {
        return block.timestamp;
    }*/


    /// @notice Cancel the round, triger a refund to the Vault
    /// @dev Only callable by the Factory but the round creator is allowed to call the cancel() function on the FactoryContract to trigger th e round cancelation.
    function cancel(address canceledBy) public {
        require(msg.sender==owner, "Forbidden");
        require(canceled==false, "Canceled");
        bool condition = (started==false && block.timestamp > round_start) || 
                         (ended==false && block.timestamp > round_end) || 
                         (block.timestamp > round_start && (
                             upAddr.length==0 ||
                             downAddr.length==0
                         ));
        require(condition, "Cancelation forbidden");

        if (betCount > 0) {
            // Cancel the escrow, get back the referral fees
            vault.cancelEscrow(round_id);
            
            // Refund the users
            vault.creditMany{value: address(this).balance}(betAddr, betAmounts, "Refunds", round_id_str);
        }
        canceled = true;
        factory.logCancelation(round_id, canceledBy);
    }


    /// @notice Returns a bet's expected payout values for both up & down, based on current odds.
    /// @param betId Locked start price. Immutable once set.
    /// @return payoutUp Payout value if you win with a bet up
    /// @return payoutDown Payout value if you win with a bet down
    function payoutValue(uint256 betId) public view returns (uint256, uint256) {
        if (bets[betId].value==0) {
            return (0, 0);
        }
        uint256 payoutUp = roundValue * 10**decimals / betUp;
        uint256 payoutDown = roundValue * 10**decimals / betDown;
        return (bets[betId].value * payoutUp / 10**decimals, bets[betId].value * payoutDown / 10**decimals);
    }
}




/// @title Round Factory
/// @author 0x6Fa02ed6248A4a78609368441265a5798ebaFC78
/// @notice This is the main contract, exposing functions to create, start, end & cancel rounds. Also exposes logging methods callable only by the rounds' contracts.
contract RoundFactory {

    // Contract
    address public owner;
    uint256 public decimals = 8;

    // Fees
    uint256 public creationFees = 10000000000000000; //0.01 ethers;
    uint256 public referralFees = 1*(10**(decimals-2)); // 1%
    uint256 public creatorFees  = 2*(10**(decimals-2)); // 2%
    uint256 public roundFees    = 2*(10**(decimals-2)); // 2%

    // Rounds
    address[] public rounds; // id->address
    mapping(address=>uint256) public roundIds; // address->id
    mapping(uint256=>uint256) private feesPaid;
    uint256 public roundCount; // Total number of rounds
    mapping(uint256=>address) private roundOwners;

    // Maintenance
    bool public isPaused;


    // Events
    event roundCreated(uint256 round_id, string pair, uint start_time, uint bet_time, uint duration, address creator, uint256 minBetValue, uint256 creationFees);
    event roundStarted(uint256 round_id, uint256 price, uint256 priceTimestamp);
    event roundEnded(uint256 round_id, uint256 creatorFees, uint256 roundFees, uint256 price, uint256 priceTimestamp);
    event roundCanceled(uint256 round_id, address canceledBy);
    event newBet(uint256 round_id, uint256 amount, uint8 direction, address user);
    event newWinners(uint256 round_id, address[] winners, uint256[] winValues);
    event newReferral(uint256 roundId, address user, address referrer, uint256 feesEarned);
    event newReferralFees(uint256 roundId, address user, address referrer, uint256 feesEarned);
    event creationPaused(string reason);
    event creationResumed();
    event ownershipChanged(address newOwner);
    event feeChanged(uint256 creationFees, uint256 referralFees, uint256 creatorFees, uint256 roundFees);

    address referralContract;

    BankVault vault;

    constructor (address _referralContract) {
        referralContract = _referralContract;
        owner            = msg.sender;
        vault            = BankVault(0xfAbEe939647804253B226f9cEE026a6e55C729C0);
    }



    /// @notice Change the round creation fees. Restricted.
    /// @param fees New creation fees
    function setCreationFees(uint256 fees) public {
        require(msg.sender == owner, "Access Denied");
        creationFees = fees;
        emit feeChanged(creationFees, referralFees, creatorFees, roundFees);
    }

    /// @notice Change the various round fees, expressed in percents with 8 digits (1% -> 0.1*10**8 -> 10000000). Restricted.
    /// @param _referralFees New referral fees
    /// @param _creatorFees New round creator fees
    /// @param _roundFees New Factory fees
    function setRoundFees(uint256 _referralFees, uint256 _creatorFees, uint256 _roundFees) public {
        require(msg.sender == owner, "Access Denied");
        referralFees = _referralFees;
        creatorFees  = _creatorFees;
        roundFees    = _roundFees;
        emit feeChanged(creationFees, referralFees, creatorFees, roundFees);
    }

    /// @notice Pause the creation of new rounds. Only called before server maintenance. Existing rounds are not affected. Restricted.
    /// @param reason Reason for the pause (propagated by event)
    function pause(string memory reason) public {
        require(msg.sender == owner, "Access Denied");
        require(isPaused==false, "Already paused");
        isPaused = true;
        emit creationPaused(reason);
    }

    /// @notice Resume the creation of new rounds. Only called after server maintenance. Restricted.
    function resume() public {
        require(msg.sender == owner, "Access Denied");
        require(isPaused==true, "Not paused");
        isPaused = false;
        emit creationResumed();
    }

    /// @notice Transfer the ownership of the Factory to a new address. Restricted.
    /// @param newOwner New Factory owner
    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Access Denied");
        owner = newOwner;
        emit ownershipChanged(newOwner);
    }
    
    /// @notice Create a new betting round. Creation fees must be paid.
    /// @dev This function will deploy a new instance of the Round contract.
    /// @param pair Pair, format [A-Z]+/[A-Z]+ (BTC/USD)
    /// @param start_time Timestamp, time at which bets can be placed
    /// @param bet_time For how long users are allowed to bet once the round has started, in seconds (5min to bet: 5*60->300)
    /// @param duration Total duration of the round, in seconds
    /// @param minBetValue Minimum bet accepted on this round, in wei
    /// @return roundAddr The address of the deployed Round
    function createRound(string memory pair, uint start_time, uint bet_time, uint duration, uint256 minBetValue) public payable returns (address) {
        require(msg.value >= creationFees, "Payment required");
        require(!isPaused, "Paused for maintenance, try again later");
        Round round = new Round(msg.sender, pair, roundCount, start_time, bet_time, duration, minBetValue, referralFees, creatorFees, roundFees);
        address roundAddr = address(round);
        roundOwners[roundCount] = msg.sender; // roundId->Owner
        roundIds[roundAddr] = roundCount;     // roundAddr->roundId
        feesPaid[roundCount] = creationFees;  // roundId->creation fees paid
        rounds.push(roundAddr);               // roundId->roundAddr
        emit roundCreated(roundCount, pair, start_time, bet_time, duration, msg.sender, minBetValue, creationFees);
        if (msg.value>creationFees) {
            // Refund the extra is the crezator overpays the fees
            vault.credit{value: msg.value-creationFees}(msg.sender, "Overpaid", Strings.toString(roundCount));
        }
        roundCount++;
        return roundAddr;
    }

    /// @notice Attach a referrer to a user account. Restricted, called by Round.
    /// @param user User address
    /// @param referrer Referrer address
    /// @return hasReferrer True if the user now has a referrer attached
    /// @return referrerAddress The address of the user's referrer or 0x0000000000000000000000000000000000000000
    /// @return referralSuccess True if this referral was a success. Failure could be due to: The user already has a referrer or the referrer is 0x0000000000000000000000000000000000000000 or 0x000000000000000000000000000000000000dEaD
    function register_referral(address user, address referrer) public returns (bool, address, bool) {
        require(roundIds[msg.sender]>0, "Forbidden");
        Referral referral    = Referral(referralContract);
        (bool hasReferrer, address userReferrer) = referral.get(user);
        //bool newReferal = referral.refer(user, referrer);
        if (hasReferrer==true) {
            return (true, userReferrer, false);
        } else {
            if (referrer==address(0)||referrer==0x000000000000000000000000000000000000dEaD) {
                return (false, address(0), false);
            } else {
                referral.refer(user, referrer);
                return (true, referrer, true);
            }
        }
    }


    /// @notice Start a betting round. Restricted, called by the Factory owner via a CRON job.
    /// @param roundId Round ID
    /// @param price Locked start price. Immutable once set.
    /// @param priceTimestamp Timestamp at which that price was obtained.
    function start(uint256 roundId, uint256 price, uint256 priceTimestamp) public {
        require(msg.sender == owner, "Access Denied");
        Round round = Round(payable(rounds[roundId]));
        round.start(price, priceTimestamp);
        emit roundStarted(roundId, price, priceTimestamp);
    }

    /// @notice End a betting round. Restricted, called by the Factory owner via a CRON job.
    /// @param roundId Round ID
    /// @param price Locked end price. Immutable once set.
    /// @param priceTimestamp Timestamp at which that price was obtained.
    function end(uint256 roundId, uint256 price, uint256 priceTimestamp) public {
        require(msg.sender == owner, "Access Denied");
        Round round = Round(payable(rounds[roundId]));
        (uint256 creatorFeeValue, uint256 feeValue) = round.end(price, priceTimestamp);
        // Factory fees transfer
        vault.credit{value: feesPaid[roundId]}(owner, "Round Fees", Strings.toString(roundId));
        emit roundEnded(roundId, creatorFeeValue, feeValue, price, priceTimestamp);
    }

    /// @notice Cancel a round
    /// @param roundId Round ID
    function cancel(uint256 roundId) public {
        require(msg.sender == owner || msg.sender==roundOwners[roundId], "Access Denied");
        Round round = Round(payable(rounds[roundId]));
        round.cancel(msg.sender);
    }


    /// @notice Event emitter called by a Round when it is canceled
    /// @dev Only callable by the round contract
    /// @param roundId Round ID
    /// @param canceledBy Address of the wallet who requested the cancelation (factory owner, round creator or round contract)
    function logCancelation(uint256 roundId, address canceledBy) public {
        require(msg.sender==rounds[roundId], "Forbidden");
        Round round = Round(payable(rounds[roundId]));
        string memory round_id_str = Strings.toString(roundId);
        // Refund half the creation fees to the creator
        vault.credit{value: feesPaid[roundId]/2}(round.owner(), "Creation Fees Refunds", round_id_str);
        // Factory keeps the rest to pay for gas fees
        vault.credit{value: feesPaid[roundId]/2}(owner, "Round Fees", round_id_str);
        emit roundCanceled(roundId, canceledBy);
    }
    /// @notice Event emitter called by a Round when a new referral has been made.
    /// @dev Fees are put into escrow and only transfered to the Vault on successful completion of a round. Monitor the `roundCanceled(uint256 round_id, address canceledBy)` event to know when to invalidate that fee.
    /// @param roundId Round ID
    /// @param user User address
    /// @param referrer Referrer address
    /// @param feesEarned Fees earned in wei.
    function logReferral(uint256 roundId, address user, address referrer, uint256 feesEarned) public {
        require(msg.sender==rounds[roundId], "Forbidden");
        emit newReferral(roundId, user, referrer, feesEarned);
    }
    /// @notice Event emitter called by a Round when a new referral fee has been earned.
    /// @dev Fees are put into escrow and only transfered to the Vault on successful completion of a round. Monitor the `roundCanceled(uint256 round_id, address canceledBy)` event to know when to invalidate that fee.
    /// @param roundId Round ID
    /// @param user User address
    /// @param referrer Referrer address
    /// @param feesEarned Fees earned in wei.
    function logReferralFees(uint256 roundId, address user, address referrer, uint256 feesEarned) public {
        require(msg.sender==rounds[roundId], "Forbidden");
        emit newReferralFees(roundId, user, referrer, feesEarned);
    }
    /// @notice Event emitter called by a Round when a bet has been made.
    /// @param wallet User address
    /// @param amount Bet amount (before fees)
    /// @param direction Bet direction. 0->down, 1->up
    /// @param roundId Round ID
    function logBet(address wallet, uint256 amount, uint8 direction, uint256 roundId) public {
        require(msg.sender==rounds[roundId], "Forbidden");
        emit newBet(roundId, amount, direction, wallet);
    }
    /// @notice Event emitter called by a Round when the winners of a round have been paid.
    /// @param winners Array of addresses
    /// @param winValues Array of amounts won
    /// @param roundId Round ID
    function logWins(address[] memory winners, uint256[] memory winValues, uint256 roundId) public {
        require(msg.sender==rounds[roundId], "Forbidden");
        emit newWinners(roundId, winners, winValues);
    }

    receive() external payable {
        
    }
    
    fallback() external payable {
        
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}