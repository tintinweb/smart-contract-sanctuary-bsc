pragma solidity ^0.5.2;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function allowance(address _owner, address _spender) public view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// * https://tomodice.com/ - fair games that pay Tomochain's coins - 100% decentralized
//
// * Tomodice's smart contract, deployed at 0xd8f983d903bad3df5a3b641683cc63ce785cc714 (Tomochain's mainnet).
//
// * Uses hybrid commit-reveal + block hash random number generation that is immune
//   to tampering by players, house and miners. Apart from being fully transparent,
//   this also allows arbitrarily high bets.
//
// * Refer to https://github.com/tomodice/contracts/whitepaper.pdf for detailed description and proofs.
contract TomoDice {
    /// *** Constants section

    // Each bet is deducted [houseEdgePermille]‰ in favour of the house, but no less than some minimum.
    // The lower bound is dictated by gas costs of the settleBet transaction, providing headroom for up to 10 Gwei prices.
    uint public houseEdgePermille; // Per-mille = per-thousand
    uint public houseEdgeMinimumAmount;

    // Bets lower than this amount do not participate in jackpot rolls (and are not deducted jackpotFee).
    uint public minJackpotBet;
    uint public jackpotFee;

    // There is minimum and maximum bets.
    uint public minBet;
    uint public maxBet;

    // Max bet profit. Used to cap bets against dynamic odds.
    uint public maxProfit;

    // Chance to win jackpot (currently 0.1%) and fee deducted into jackpot fund.
    uint constant JACKPOT_MODULO = 1000;

    // Modulo is a number of equiprobable outcomes in a game:
    //  - 2 for coin flip
    //  - 6 for dice
    //  - 6*6 = 36 for double dice
    //  - 37 for roulette
    //  - 100 for tomorain
    //  - 200 for tomoroll
    //  - 1000 for tomolotto
    //  etc.
    // It's called so because 256-bit entropy is treated like a huge integer and
    // the remainder of its division by modulo is considered bet outcome.
    uint constant MAX_MODULO = 65535;

    uint16 constant TOMOROLL_MODULO = 200;
    uint16 constant TOMOLOTTO_3D_MODULO = 1000;
    uint16 constant TOMOLOTTO_4D_MODULO = 10000;

    // For modulos below this threshold rolls are checked against a bit mask,
    // thus allowing betting on any combination of outcomes. For example, given
    // modulo 6 for dice, 101000 mask (base-2, big endian) means betting on
    // 4 and 6; for games with modulos higher than threshold (Tomoroll), a simple
    // limit is used, allowing betting on any outcome in [0, N) range.
    //
    // The specific value is dictated by the fact that 256-bit intermediate
    // multiplication result allows implementing population count efficiently
    // for numbers that are up to 42 bits, and 40 is the highest multiple of
    // eight below 42.
    uint256 constant MAX_MASK_SMALL_MODULO = 40;

    // This is a check on bet mask overflow.
    uint256 constant MAX_BET_MASK_SMALL_MODULO = 2 ** MAX_MASK_SMALL_MODULO;

    // bigger modulo, use normal bit count algorithm (slower).
    uint256 constant MAX_MASK_BIG_MODULO = 249;
    uint256 constant MAX_BET_MASK_BIG_MODULO = 2 ** MAX_MASK_BIG_MODULO;

    // EVM BLOCKHASH opcode can query no further than 256 blocks into the
    // past. Given that settleBet uses block hash of placeBet as one of
    // complementary entropy sources, we cannot process bets older than this
    // threshold. On rare occasions tomodice's croupier may fail to invoke
    // settleBet in this timespan due to technical issues or extreme Tomochain
    // congestion; such bets can be refunded via invoking refundBet.
    uint constant BET_EXPIRATION_BLOCKS = 250;

    // Some deliberately invalid address to initialize the secret signer with.
    // Forces maintainers to invoke setSecretSigner before processing any bets.
    address constant DUMMY_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // Standard contract ownership transfer.
    address payable public owner;
    address payable private nextOwner;

    // The address corresponding to a private key used to sign placeBet commits.
    address public secretSigner;

    // Croupier account.
    address public croupier;

    // Accumulated jackpot fund.
    uint128 public jackpotSize;

    // Funds that are locked in potentially winning bets. Prevents contract from
    // committing to bets it cannot pay out.
    uint128 public lockedInBets;

    // A structure representing a single bet.
    struct Bet {
        // Wager amount in wei.
        uint amount;
        // Modulo of a game.
        uint16 modulo;
        // Number of winning outcomes, used to compute winning payment (* modulo/rollUnder),
        // and used instead of mask for games with modulo > MAX_MASK_BIG_MODULO.
        uint16 rollUnder;
        // Block number of placeBet tx.
        uint40 placeBlockNumber;
        // Bit mask representing winning bet outcomes (see MAX_MASK_SMALL_MODULO comment).
        uint256 mask;
        // Address of a gambler, used to pay out winning bets.
        address payable gambler;
    }

    // Mapping from commits to all currently active & processed bets.
    mapping(uint => Bet) bets;

    // Mapping from wallet address to its.
    mapping(address => address payable) affiliates;

    // Commissions for referrer (5 levels) - in percent from house edge fee collected.
    uint8[] public referCommissionPrecents = [16, 8, 4, 2, 1];

    // Lotto prize structures (3-digits and 4-digits).
    uint[] public lottoPrize3D = [0, 14, 160, 1000]; // 0x, 1.4x, 16x, 100x
    uint[] public lottoPrize4D = [0, 15, 40, 400, 10000]; // 0x, 1.5x, 4x, 40x, 1000x

    // Events that are issued to make statistic recovery easier.
    event FailedPayment(address indexed beneficiary, uint amount);
    event Payment(address indexed beneficiary, uint amount);
    event JackpotPayment(address indexed beneficiary, uint amount);
    event AffiliatePayment(uint8 level, address indexed referrer, address indexed gambler, uint houseEdge, uint commission);
    event FailedAffiliatePayment(uint8 level, address indexed referrer, address indexed gambler, uint houseEdge, uint commission);

    // These events are emitted in placeBet to record commit & affiliate in the logs.
    event Commit(uint commit);
    event Affiliate(address indexed referrer, address indexed gambler);

    // Constructor. Deliberately does not take any parameters.
    constructor (uint _houseEdgePermille, uint _houseEdgeMinimumAmount,
        uint _minJackpotBet, uint _jackpotFee,
        uint _minBet, uint _maxBet, uint _maxProfit) public {
        owner = msg.sender;
        secretSigner = DUMMY_ADDRESS;
        croupier = DUMMY_ADDRESS;
        setHouseEdgeSettings(_houseEdgePermille, _houseEdgeMinimumAmount);
        setJackpotSettings(_minJackpotBet, _jackpotFee);
        setBetAmountSettings(_minBet, _maxBet);
        setMaxProfit(_maxProfit);
    }

    // Standard modifier on methods invokable only by contract owner.
    modifier onlyOwner {
        require(msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }

    // Standard modifier on methods invokable only by contract owner.
    modifier onlyCroupier {
        require(msg.sender == croupier, "OnlyCroupier methods called by non-croupier.");
        _;
    }

    // Standard contract ownership transfer implementation,
    function approveNextOwner(address payable _nextOwner) external onlyOwner {
        require(_nextOwner != owner, "Cannot approve current owner.");
        nextOwner = _nextOwner;
    }

    function acceptNextOwner() external {
        require(msg.sender == nextOwner, "Can only accept preapproved new owner.");
        owner = nextOwner;
    }

    // Fallback function deliberately left empty. It's primary use case
    // is to top up the bank roll.
    function() external payable {
    }

    // See comment for "secretSigner" variable.
    function setSecretSigner(address newSecretSigner) external onlyOwner {
        secretSigner = newSecretSigner;
    }

    // Change the croupier address.
    function setCroupier(address newCroupier) external onlyOwner {
        croupier = newCroupier;
    }

    // Change house edge settings
    function setHouseEdgeSettings(uint _houseEdgePermille, uint _houseEdgeMinimumAmount) public onlyOwner {
        require(_houseEdgePermille <= 100, "houseEdgePermille should not be over than 10%.");
        require(_houseEdgeMinimumAmount >= 0.001 ether, "houseEdgeMinimumAmount should be at least 0.001 tomo.");
        houseEdgePermille = _houseEdgePermille;
        houseEdgeMinimumAmount = _houseEdgeMinimumAmount;
    }

    // Change jackpot settings
    function setJackpotSettings(uint _minJackpotBet, uint _jackpotFee) public onlyOwner {
        require(_minJackpotBet >= 1 ether, "minJackpotBet should be at least 1.0 tomo.");
        require(_jackpotFee >= 0.01 ether, "jackpotFee should be at least 0.01 tomo.");
        minJackpotBet = _minJackpotBet;
        jackpotFee = _jackpotFee;
    }

    // Change bet amount settings
    function setBetAmountSettings(uint _minBet, uint _maxBet) public onlyOwner {
        require(_minBet >= 0.01 ether, "minBet should be at least 0.01 tomo.");
        require(_maxBet <= 100000 ether, "maxBet should be at most 100,000 tomo.");
        require(_minBet < _maxBet, "minBet should be less than maxBet.");
        minBet = _minBet;
        maxBet = _maxBet;
    }

    // Change max bet reward. Setting this to zero effectively disables betting.
    function setMaxProfit(uint _maxProfit) public onlyOwner {
        require(_maxProfit < maxBet * 10000, "maxProfit should be a sane number.");
        maxProfit = _maxProfit;
    }

    // Change refer commissions. Setting one level to zero will disable that level.
    function setReferCommissionPrecents(uint8[] memory _referCommissionPrecents) public onlyOwner {
        require(_referCommissionPrecents.length == 5, "referCommissionPrecents should have 5 elements");
        referCommissionPrecents = _referCommissionPrecents;
    }

    // This function is used to bump up the jackpot fund. Cannot be used to lower it.
    function increaseJackpot(uint increaseAmount) external onlyOwner {
        require(increaseAmount <= address(this).balance, "Increase amount larger than balance.");
        require(jackpotSize + lockedInBets + increaseAmount <= address(this).balance, "Not enough funds.");
        jackpotSize += uint128(increaseAmount);
    }

    // Funds withdrawal to cover costs of tomodice.com operation.
    function withdrawFunds(address payable beneficiary, uint withdrawAmount) external onlyOwner {
        require(withdrawAmount <= address(this).balance, "Increase amount larger than balance.");
        require(jackpotSize + lockedInBets + withdrawAmount <= address(this).balance, "Not enough funds.");
        sendFunds(beneficiary, withdrawAmount, withdrawAmount, 0);
    }

    // Contract may be destroyed only when there are no ongoing bets,
    // either settled or refunded. All funds are transferred to contract owner.
    function kill() external onlyOwner {
        require(lockedInBets == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(owner);
    }

    /// *** Betting logic

    // Bet states:
    //  amount == 0 && gambler == 0 - 'clean' (can place a bet)
    //  amount != 0 && gambler != 0 - 'active' (can be settled or refunded)
    //  amount == 0 && gambler != 0 - 'processed' (can clean storage)
    //
    //  NOTE: Storage cleaning is not implemented in this contract version; it will be added
    //        with the next upgrade to prevent polluting Tomochain state with expired bets.

    // Bet placing transaction - issued by the player.
    //  betMask         - bet outcomes bit mask for modulo <= MAX_MASK_MODULO,
    //                    [0, betMask) for larger modulos.
    //  modulo          - game modulo.
    //  commitLastBlock - number of the maximum block where "commit" is still considered valid.
    //  commit          - Keccak256 hash of some secret "reveal" random number, to be supplied
    //                    by the tomodice.com croupier bot in the settleBet transaction. Supplying
    //                    "commit" ensures that "reveal" cannot be changed behind the scenes
    //                    after placeBet have been mined.
    //  r, s            - components of ECDSA signature of (commitLastBlock, commit). v is
    //                    guaranteed to always equal 27.
    //  affWallet       - wallet to receive commission if this sender is new
    // Commit, being essentially random 256-bit number, is used as a unique bet identifier in
    // the 'bets' mapping.
    //
    // Commits are signed with a block limit to ensure that they are used at most once - otherwise
    // it would be possible for a miner to place a bet with a known commit/reveal pair and tamper
    // with the blockhash. Croupier guarantees that commitLastBlock will always be not greater than
    // placeBet block number plus BET_EXPIRATION_BLOCKS. See whitepaper for details.
    function placeBet(uint256 betMask, uint16 modulo, uint commitLastBlock, uint commit, bytes32 r, bytes32 s, address payable affWallet) external payable {
        // Check that the bet is in 'clean' state.
        Bet storage bet = bets[commit];
        require(bet.gambler == address(0), "Bet should be in a 'clean' state.");

        // Validate input data ranges.
        uint amount = msg.value;
        require(modulo > 1 && modulo <= MAX_MODULO, "Modulo should be within range.");
        require(amount >= minBet && amount <= maxBet, "Amount should be within range.");

        // Check that commit is valid - it has not expired and its signature is valid.
        require(block.number <= commitLastBlock, "Commit has expired.");
        bytes32 signatureHash = keccak256(abi.encodePacked(uint40(commitLastBlock), commit));
        require(secretSigner == ecrecover(signatureHash, 27, r, s), "ECDSA signature is not valid.");

        uint rollUnder;
        uint mask;

        if (modulo == TOMOROLL_MODULO || modulo > MAX_MASK_BIG_MODULO) { // or TOMOLOTTO_3D or TOMOLOTTO_4D
            // Larger modulos or specific games specify the right edge of half-open interval of winning bet outcomes.
            if (modulo == TOMOLOTTO_3D_MODULO || modulo == TOMOLOTTO_4D_MODULO) {
                require(betMask >= 0 && betMask < modulo, "High modulo range, betMask larger than modulo.");
            } else {
                require(betMask > 0 && betMask < modulo, "High modulo range, betMask larger than modulo.");
            }
            rollUnder = betMask;
        } else if (modulo <= MAX_MASK_SMALL_MODULO) {
            require(betMask > 0 && betMask < MAX_BET_MASK_SMALL_MODULO, "Mask should be within range.");
            // Small modulo games specify bet outcomes via bit mask.
            // rollUnder is a number of 1 bits in this mask (population count).
            // This magic looking formula is an efficient way to compute population
            // count on EVM for numbers below 2**40. For detailed proof consult
            // the tomodice.com whitepaper.
            rollUnder = ((betMask * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO;
            mask = betMask;
        } else if (modulo <= MAX_MASK_BIG_MODULO) {
            require(betMask > 0 && betMask < MAX_BET_MASK_BIG_MODULO, "Mask should be within range.");
            rollUnder = popcount64a(betMask);
            mask = betMask;
        }

        // Winning amount and jackpot increase.
        uint _possibleWinAmount;
        uint _jackpotFee;
        uint _houseEdge;

        (_possibleWinAmount, _jackpotFee, _houseEdge) = getDiceWinAmount(amount, modulo, rollUnder);

        // Enforce max profit limit.
        require(_possibleWinAmount <= amount + maxProfit, "maxProfit limit violation.");

        // Lock funds.
        lockedInBets += uint128(_possibleWinAmount);
        jackpotSize += uint128(_jackpotFee);

        // Check whether contract has enough funds to process this bet.
        require(jackpotSize + lockedInBets <= address(this).balance, "Cannot afford to lose this bet.");

        // Record commit in logs.
        emit Commit(commit);

        // Store bet parameters on blockchain.
        bet.amount = amount;
        bet.modulo = uint16(modulo);
        bet.rollUnder = uint16(rollUnder);
        bet.placeBlockNumber = uint40(block.number);
        bet.mask = uint256(mask);
        bet.gambler = msg.sender;

        if (affiliates[msg.sender] == address(0)) {
            if (affWallet != address(0)) {
                affiliates[msg.sender] = affWallet;
                emit Affiliate(affWallet, msg.sender);
            } else {
                affiliates[msg.sender] = owner;
                emit Affiliate(owner, msg.sender);
            }
        }
    }

    // This is the method used to settle 99% of bets. To process a bet with a specific
    // "commit", settleBet should supply a "reveal" number that would Keccak256-hash to
    // "commit". "blockHash" is the block hash of placeBet block as seen by croupier; it
    // is additionally asserted to prevent changing the bet outcomes on Tomochain reorgs.
    function settleBet(uint reveal, bytes32 blockHash) external onlyCroupier {
        uint commit = uint(keccak256(abi.encodePacked(reveal)));

        Bet storage bet = bets[commit];
        uint placeBlockNumber = bet.placeBlockNumber;

        // Check that bet has not expired yet (see comment to BET_EXPIRATION_BLOCKS).
        require(block.number > placeBlockNumber, "settleBet in the same block as placeBet, or before.");
        require(block.number <= placeBlockNumber + BET_EXPIRATION_BLOCKS, "Blockhash can't be queried by EVM.");
        require(blockhash(placeBlockNumber) == blockHash);

        // Settle bet using reveal and blockHash as entropy sources.
        settleBetCommon(bet, reveal, blockHash);
    }

    // This is the method used to settle 1% of bets left with passed blockHash seen by croupier
    // It needs player to trust croupier and can only be executed after between [BET_EXPIRATION_BLOCKS, 10*BET_EXPIRATION_BLOCKS]
    function settleBetLate(uint reveal, bytes32 blockHash) external onlyCroupier {
        uint commit = uint(keccak256(abi.encodePacked(reveal)));

        Bet storage bet = bets[commit];
        uint placeBlockNumber = bet.placeBlockNumber;

        require(block.number >= placeBlockNumber + BET_EXPIRATION_BLOCKS, "block.number needs to be after BET_EXPIRATION_BLOCKS");
        require(block.number <= placeBlockNumber + 20 * BET_EXPIRATION_BLOCKS, "block.number needs to be before 10*BET_EXPIRATION_BLOCKS");

        // Settle bet using reveal and blockHash as entropy sources.
        settleBetCommon(bet, reveal, blockHash);
    }

    // Common settlement code for settleBet.
    function settleBetCommon(Bet storage bet, uint reveal, bytes32 entropyBlockHash) private {
        // Fetch bet parameters into local variables (to save gas).
        uint amount = bet.amount;
        uint modulo = bet.modulo;
        uint rollUnder = bet.rollUnder;
        address payable gambler = bet.gambler;

        // Check that bet is in 'active' state.
        require(amount != 0, "Bet should be in an 'active' state");

        // Move bet into 'processed' state already.
        bet.amount = 0;

        // The RNG - combine "reveal" and blockhash of placeBet using Keccak256. Miners
        // are not aware of "reveal" and cannot deduce it from "commit" (as Keccak256
        // preimage is intractable), and house is unable to alter the "reveal" after
        // placeBet have been mined (as Keccak256 collision finding is also intractable).
        bytes32 entropy = keccak256(abi.encodePacked(reveal, entropyBlockHash));

        // Do a roll by taking a modulo of entropy. Compute winning amount.
        uint256 dice = uint256(entropy) % modulo;

        uint diceWinAmount;
        uint _jackpotFee;
        uint _houseEdge;

        (diceWinAmount, _jackpotFee, _houseEdge) = getDiceWinAmount(amount, modulo, rollUnder);

        uint diceWin = 0;

        // Determine dice outcome.
        if (modulo == TOMOLOTTO_3D_MODULO || modulo == TOMOLOTTO_4D_MODULO) {
            diceWin = getLottoWinAmount(modulo, rollUnder, dice, amount - _houseEdge - _jackpotFee);
        } else if (modulo == TOMOROLL_MODULO || modulo > MAX_MASK_BIG_MODULO) {
            // For larger modulos or tomoroll, check inclusion into half-open interval.
            if (dice < rollUnder) {
                diceWin = diceWinAmount;
            }
        } else if (modulo <= MAX_MASK_BIG_MODULO) {
            // For small modulo games, check the outcome against a bit mask.
            if ((uint256(2) ** dice) & bet.mask != 0) {
                diceWin = diceWinAmount;
            }
        }

        uint jackpotWin = 0;

        // Unlock the bet amount, regardless of the outcome.
        lockedInBets -= uint128(diceWinAmount);

        // Roll for a jackpot (if eligible).
        if (amount >= minJackpotBet) {
            // The second modulo, statistically independent from the "main" dice roll.
            // Effectively you are playing two games at once!
            uint jackpotRng = (uint(entropy) / modulo) % JACKPOT_MODULO;

            // Bingo!
            if (jackpotRng == 0) {
                jackpotWin = jackpotSize;
                jackpotSize = 0;
            }
        }

        // Log jackpot win.
        if (jackpotWin > 0) {
            emit JackpotPayment(gambler, jackpotWin);
        }

        // Send the funds to gambler.
        uint sentAmount = diceWin + jackpotWin == 0 ? 1 wei : diceWin + jackpotWin;
        sendFunds(gambler, sentAmount, diceWin, _houseEdge);
    }

    // Refund transaction - return the bet amount of a roll that was not processed in a
    // due timeframe. Processing such blocks is not possible due to EVM limitations (see
    // BET_EXPIRATION_BLOCKS comment above for details). In case you ever find yourself
    // in a situation like this, just contact the tomodice.com support, however nothing
    // precludes you from invoking this method yourself.
    function refundBet(uint commit) external {
        // Check that bet is in 'active' state.
        Bet storage bet = bets[commit];
        uint amount = bet.amount;

        require(amount != 0, "Bet should be in an 'active' state");

        // Check that bet has already expired long ago.
        require(block.number > bet.placeBlockNumber + 20 * BET_EXPIRATION_BLOCKS, "Blockhash can't be queried by EVM.");

        // Move bet into 'processed' state, release funds.
        bet.amount = 0;

        uint _diceWinAmount;
        uint _jackpotFee;
        uint _houseEdge;

        (_diceWinAmount, _jackpotFee, _houseEdge) = getDiceWinAmount(amount, bet.modulo, bet.rollUnder);

        lockedInBets -= uint128(_diceWinAmount);
        jackpotSize -= uint128(_jackpotFee);

        // Send the refund.
        sendFunds(bet.gambler, amount, amount, 0);
    }

    // Get the expected win amount after house edge is subtracted.
    function getDiceWinAmount(uint amount, uint modulo, uint rollUnder) private view returns (uint winAmount, uint _jackpotFee, uint _houseEdge) {
        require(0 <= rollUnder && rollUnder <= modulo, "Win probability out of range.");

        _jackpotFee = (amount >= minJackpotBet) ? jackpotFee : 0;

        _houseEdge = amount * houseEdgePermille / 1000;

        if (_houseEdge < houseEdgeMinimumAmount) {
            _houseEdge = houseEdgeMinimumAmount;
        }

        require(_houseEdge + _jackpotFee <= amount, "Bet doesn't even cover house edge.");
        if (modulo == TOMOLOTTO_3D_MODULO) {
            winAmount = (amount - _houseEdge - _jackpotFee) * lottoPrize3D[3] / 10;
        } else if (modulo == TOMOLOTTO_4D_MODULO) {
            winAmount = (amount - _houseEdge - _jackpotFee) * lottoPrize4D[4] / 10;
        } else {
            winAmount = (amount - _houseEdge - _jackpotFee) * modulo / rollUnder;
        }
    }

    // get lotto win
    function getLottoWinAmount(uint modulo, uint rollUnder, uint dice, uint betAmount) private view returns (uint winAmount) {
        require(modulo == TOMOLOTTO_3D_MODULO || modulo == TOMOLOTTO_4D_MODULO, "Calculate lotto win amount only.");

        uint8 digitMatch = 0;
        if (rollUnder % 10 == dice % 10) ++digitMatch;
        if ((rollUnder % 100) / 10 == (dice % 100) / 10) ++digitMatch;
        if ((rollUnder % 1000) / 100 == (dice % 1000) / 100) ++digitMatch;
        if (modulo == TOMOLOTTO_3D_MODULO) {
            winAmount = betAmount * lottoPrize3D[digitMatch] / 10;
        } else {
            if (rollUnder / 1000 == dice / 1000) ++digitMatch;
            winAmount = betAmount * lottoPrize4D[digitMatch] / 10;
        }
        return winAmount;
    }

    // Helper routine to process the payment.
    function sendFunds(address payable beneficiary, uint amount, uint successLogAmount, uint houseEdge) private {
        if (beneficiary.send(amount)) {
            emit Payment(beneficiary, successLogAmount);
        } else {
            emit FailedPayment(beneficiary, amount);
        }

        // Send affiliate commissions
        address prevBeneficiary2 = address(0);
        address prevBeneficiary = address(0);
        if (houseEdge != 0) {
            for (uint8 level = 1; level <= 5; level++) {
                address payable referrer = affiliates[beneficiary];
                if (referrer == address(0) || referrer == beneficiary || referrer == prevBeneficiary || referrer == prevBeneficiary2) {
                    break;
                }
                uint commission = houseEdge * referCommissionPrecents[level - 1] / 100;
                if (commission == 0) {
                    break;
                }
                if (referrer.send(commission)) {
                    emit AffiliatePayment(level, referrer, beneficiary, houseEdge, commission);
                } else {
                    emit FailedAffiliatePayment(level, referrer, beneficiary, houseEdge, commission);
                }
                prevBeneficiary2 = prevBeneficiary;
                prevBeneficiary = beneficiary;
                beneficiary = referrer;
            }
        }
    }

    event EmergencyERC20Drain(address token, address owner, uint256 amount);

    // owner can drain tokens that are sent here by mistake
    function emergencyERC20Drain(ERC20 token, uint amount) external onlyOwner {
        emit EmergencyERC20Drain(address(token), owner, amount);
        token.transfer(owner, amount);
    }

    // This are some constants making O(1) population count in placeBet possible.
    // See whitepaper for intuition and proofs behind it.
    uint constant POPCNT_MULT = 0x0000000000002000000000100000000008000000000400000000020000000001;
    uint constant POPCNT_MASK = 0x0001041041041041041041041041041041041041041041041041041041041041;
    uint constant POPCNT_MODULO = 0x3F;

    // uint64_t is an unsigned 64-bit integer variable type (defined in C99 version of C language)
    uint256 constant m1 = 0x5555555555555555555555555555555555555555555555555555555555555555;
    //binary: 0101...
    uint256 constant m2 = 0x3333333333333333333333333333333333333333333333333333333333333333;
    //binary: 00110011..
    uint256 constant m4 = 0x0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f;
    //binary:  4 zeros,  4 ones ...
    uint256 constant m8 = 0x00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff;
    //binary:  8 zeros,  8 ones ...
    uint256 constant m16 = 0x0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff;
    //binary: 16 zeros, 16 ones ...
    uint256 constant m32 = 0x00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff;
    //binary: 32 zeros, 32 ones
    uint256 constant m64 = 0x0000000000000000ffffffffffffffff0000000000000000ffffffffffffffff;
    uint256 constant m128 = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;

    // This is a naive implementation, shown for comparison,
    // and to help in understanding the better functions.
    // This algorithm uses 24 arithmetic operations (shift, add, and)
    function popcount64a(uint256 x) public pure returns (uint256) {
        x = (x & m1) + ((x >> 1) & m1);
        x = (x & m2) + ((x >> 2) & m2);
        x = (x & m4) + ((x >> 4) & m4);
        x = (x & m8) + ((x >> 8) & m8);
        x = (x & m16) + ((x >> 16) & m16);
        x = (x & m32) + ((x >> 32) & m32);
        x = (x & m64) + ((x >> 64) & m64);
        x = (x & m128) + ((x >> 128) & m128);
        return x;
    }
}