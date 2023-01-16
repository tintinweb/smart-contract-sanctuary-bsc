/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

pragma solidity ^0.8.0;

contract Nice2Win {
    uint256 public houseEdgePercent = 1;
    uint256 public houseEdgeMinimumAmount = 0.001 ether;
    uint256 public minJackpotBet = 0.05 ether;
    uint256 public jackpotModulo = 1000;
    uint256 public jackpotFee = 0.005 ether;
    uint256 public minBet = 0.05 ether;

    uint256 constant MAX_AMOUNT = 300000 ether;
    uint256 constant MAX_MODULO = 100;
    uint256 constant MAX_MASK_MODULO = 40;
    uint256 constant MAX_BET_MASK = 2**MAX_MASK_MODULO;
    uint256 constant BET_EXPIRATION_BLOCKS = 250;
    address constant DUMMY_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public owner;
    address private nextOwner;

    uint256 public maxProfit;

    address public secretSigner;

    uint128 public jackpotSize;

    uint128 public lockedInBets;

    struct Bet {
        uint256 amount;
        uint8 modulo;
        uint8 rollUnder;
        uint40 placeBlockNumber;
        uint40 mask;
        address payable gambler;
    }

    mapping(uint256 => Bet) public bets;

    address public croupier;

    event FailedPayment(address beneficiary, uint256 amount);
    event Payment(address beneficiary, uint256 amount);
    event JackpotPayment(address beneficiary, uint256 amount);

    event Commit(uint256 commit, uint256 blockNumber);
    event BetSettled(
        address gambler,
        uint256 amount,
        uint256 betMask,
        uint256 modulo,
        uint256 dice,
        uint256 diceWin,
        uint256 jackpotAmount
    );

    constructor() {
        owner = msg.sender;
        secretSigner = DUMMY_ADDRESS;
        croupier = DUMMY_ADDRESS;
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }

    modifier onlyCroupier() {
        require(
            msg.sender == croupier,
            "OnlyCroupier methods called by non-croupier."
        );
        _;
    }

    function approveNextOwner(address _nextOwner) external onlyOwner {
        require(_nextOwner != owner, "Cannot approve current owner.");
        nextOwner = _nextOwner;
    }

    function acceptNextOwner() external {
        require(
            msg.sender == nextOwner,
            "Can only accept preapproved new owner."
        );
        owner = nextOwner;
    }

    function setHouseEdgePercent(uint256 _houseEdgePercent) public {
        houseEdgePercent = _houseEdgePercent;
    }

    function setHouseEdgeMinimumAmount(uint256 _houseEdgeMinimumAmount) public {
        houseEdgeMinimumAmount = _houseEdgeMinimumAmount;
    }

    function setMinJackpotBet(uint256 _minJackpotBet) public {
        minJackpotBet = _minJackpotBet;
    }

    function setJackpotModulo(uint256 _jackpotModulo) public {
        jackpotModulo = _jackpotModulo;
    }

    function setJackpotFee(uint256 _jackpotFee) public {
        jackpotFee = _jackpotFee;
    }

    function setMinBet(uint256 _minBet) public {
        minBet = _minBet;
    }

    function setSecretSigner(address newSecretSigner) external onlyOwner {
        secretSigner = newSecretSigner;
    }

    function setCroupier(address newCroupier) external onlyOwner {
        croupier = newCroupier;
    }

    function setMaxProfit(uint256 _maxProfit) public onlyOwner {
        require(_maxProfit < MAX_AMOUNT, "maxProfit should be a sane number.");
        maxProfit = _maxProfit;
    }

    function increaseJackpot(uint256 increaseAmount) external onlyOwner {
        require(
            increaseAmount <= address(this).balance,
            "Increase amount larger than balance."
        );
        require(
            jackpotSize + lockedInBets + increaseAmount <=
                address(this).balance,
            "Not enough funds."
        );
        jackpotSize += uint128(increaseAmount);
    }

    function withdrawFunds(address payable beneficiary, uint256 withdrawAmount)
        external
        onlyOwner
    {
        require(
            withdrawAmount <= address(this).balance,
            "Increase amount larger than balance."
        );
        require(
            jackpotSize + lockedInBets + withdrawAmount <=
                address(this).balance,
            "Not enough funds."
        );
        sendFunds(beneficiary, withdrawAmount, withdrawAmount);
    }

    function kill() external onlyOwner {
        require(
            lockedInBets == 0,
            "All bets should be processed (settled or refunded) before self-destruct."
        );
        selfdestruct(payable(owner));
    }

    function placeBet(
        uint256 betMask,
        uint256 modulo,
        uint256 commitLastBlock,
        uint256 commit,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable {
        Bet storage bet = bets[commit];
        require(bet.gambler == address(0), "Bet should be in a 'clean' state.");

        uint256 amount = msg.value;
        require(
            modulo > 1 && modulo <= MAX_MODULO,
            "Modulo should be within range."
        );
        require(
            amount >= minBet && amount <= MAX_AMOUNT,
            "Amount should be within range."
        );
        require(
            betMask > 0 && betMask < MAX_BET_MASK,
            "Mask should be within range."
        );

        require(block.number <= commitLastBlock, "Commit has expired.");

        requireValidECDSASignature(commitLastBlock, commit, v, r, s);

        uint256 rollUnder;
        uint256 mask;

        if (modulo <= MAX_MASK_MODULO) {
            rollUnder = ((betMask * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO;
            mask = betMask;
        } else {
            require(
                betMask > 0 && betMask <= modulo,
                "High modulo range, betMask larger than modulo."
            );
            rollUnder = betMask;
        }

        uint256 possibleWinAmount;
        uint256 _jackpotFee;

        (possibleWinAmount, _jackpotFee) = getDiceWinAmount(
            amount,
            modulo,
            rollUnder
        );

        require(
            possibleWinAmount <= amount + maxProfit,
            "maxProfit limit violation."
        );

        lockedInBets += uint128(possibleWinAmount);
        jackpotSize += uint128(_jackpotFee);

        require(
            jackpotSize + lockedInBets <= address(this).balance,
            "Cannot afford to lose this bet."
        );

        emit Commit(commit, block.number);

        bet.amount = amount;
        bet.modulo = uint8(modulo);
        bet.rollUnder = uint8(rollUnder);
        bet.placeBlockNumber = uint40(block.number);
        bet.mask = uint40(mask);
        bet.gambler = payable(msg.sender);
    }

    function requireValidECDSASignature(
        uint256 commitLastBlock,
        uint256 commit,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) private view {
        bytes32 payloadHash = keccak256(
            abi.encode(uint40(commitLastBlock), commit)
        );

        bytes32 messageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", payloadHash)
        );

        require(v == 27 || v == 28, "v is not valid.");
        require(
            secretSigner == ecrecover(messageHash, v, r, s),
            "ECDSA signature is not valid."
        );
    }

    function settleBet(uint256 reveal, bytes32 blockHash)
        external
        onlyCroupier
    {
        uint256 commit = uint256(keccak256(abi.encodePacked(reveal)));

        Bet storage bet = bets[commit];
        uint256 placeBlockNumber = bet.placeBlockNumber;

        require(
            block.number > placeBlockNumber,
            "settleBet in the same block as placeBet, or before."
        );
        require(
            block.number <= placeBlockNumber + BET_EXPIRATION_BLOCKS,
            "Blockhash can't be queried by EVM."
        );
        require(blockhash(placeBlockNumber) == blockHash);

        settleBetCommon(bet, reveal, blockHash);
    }

    function settleBetCommon(
        Bet storage bet,
        uint256 reveal,
        bytes32 entropyBlockHash
    ) private {
        uint256 amount = bet.amount;
        uint256 modulo = bet.modulo;
        uint256 rollUnder = bet.rollUnder;
        address payable gambler = bet.gambler;

        require(amount != 0, "Bet should be in an 'active' state");

        bet.amount = 0;

        bytes32 entropy = keccak256(abi.encodePacked(reveal, entropyBlockHash));

        uint256 dice = uint256(entropy) % modulo;

        uint256 diceWinAmount;
        uint256 _jackpotFee;
        (diceWinAmount, _jackpotFee) = getDiceWinAmount(
            amount,
            modulo,
            rollUnder
        );

        uint256 diceWin = 0;
        uint256 jackpotWin = 0;

        if (modulo <= MAX_MASK_MODULO) {
            if ((2**dice) & bet.mask != 0) {
                diceWin = diceWinAmount;
            }
        } else {
            if (dice < rollUnder) {
                diceWin = diceWinAmount;
            }
        }

        lockedInBets -= uint128(diceWinAmount);

        if (amount >= minJackpotBet) {
            uint256 jackpotRng = (uint256(entropy) / modulo) % jackpotModulo;

            if (jackpotRng == 0) {
                jackpotWin = jackpotSize;
                jackpotSize = 0;
            }
        }

        if (jackpotWin > 0) {
            emit JackpotPayment(gambler, jackpotWin);
        }

        sendFunds(
            gambler,
            diceWin + jackpotWin == 0 ? 1 wei : diceWin + jackpotWin,
            diceWin
        );

        emitBetSettled(bet, dice, diceWin, jackpotWin);
    }

    function emitBetSettled(
        Bet memory bet,
        uint256 dice,
        uint256 diceWin,
        uint256 jackpotWin
    ) private {
        emit BetSettled(
            msg.sender,
            bet.amount,
            bet.mask,
            bet.modulo,
            dice,
            diceWin,
            jackpotWin
        );
    }

    function refundBet(uint256 commit) external {
        Bet storage bet = bets[commit];
        uint256 amount = bet.amount;

        require(amount != 0, "Bet should be in an 'active' state");

        require(
            block.number > bet.placeBlockNumber + BET_EXPIRATION_BLOCKS,
            "Blockhash can't be queried by EVM."
        );

        bet.amount = 0;

        uint256 diceWinAmount;
        uint256 _jackpotFee;
        (diceWinAmount, _jackpotFee) = getDiceWinAmount(
            amount,
            bet.modulo,
            bet.rollUnder
        );

        lockedInBets -= uint128(diceWinAmount);
        jackpotSize -= uint128(_jackpotFee);

        sendFunds(bet.gambler, amount, amount);
    }

    function getDiceWinAmount(
        uint256 amount,
        uint256 modulo,
        uint256 rollUnder
    ) private view returns (uint256 winAmount, uint256 _jackpotFee) {
        require(
            0 < rollUnder && rollUnder <= modulo,
            "Win probability out of range."
        );

        _jackpotFee = amount >= minJackpotBet ? jackpotFee : 0;

        uint256 houseEdge = (amount * houseEdgePercent) / 100;

        if (houseEdge < houseEdgeMinimumAmount) {
            houseEdge = houseEdgeMinimumAmount;
        }

        require(
            houseEdge + _jackpotFee <= amount,
            "Bet doesn't even cover house edge."
        );
        winAmount = ((amount - houseEdge - _jackpotFee) * modulo) / rollUnder;
    }

    function sendFunds(
        address payable beneficiary,
        uint256 amount,
        uint256 successLogAmount
    ) private {
        if (beneficiary.send(amount)) {
            emit Payment(beneficiary, successLogAmount);
        } else {
            emit FailedPayment(beneficiary, amount);
        }
    }

    uint256 constant POPCNT_MULT =
        0x0000000000002000000000100000000008000000000400000000020000000001;
    uint256 constant POPCNT_MASK =
        0x0001041041041041041041041041041041041041041041041041041041041041;
    uint256 constant POPCNT_MODULO = 0x3F;
}