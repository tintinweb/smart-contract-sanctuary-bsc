// SPDX-License-Identifier: Apache-2.0

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../../processing/TokenProcessing.sol";
import "./JackpotDTOs.sol";
import "./JackpotProcessor.sol";

contract P2PJackpotBetProvider is TokenProcessing, JackpotProcessor {
    mapping(uint => JackpotDTOs.JackpotBet) private jackpotBets;
    mapping(uint => JackpotDTOs.JackpotMatchingInfo) private matchingInfo;
    mapping(address => mapping(uint => JackpotDTOs.JoinJackpotBetClientList)) private clientInfo;
    mapping(address => uint[]) private clientBets;
    mapping(address => uint) public clientBetsLength;
    uint public jackpotBetIdCounter;
    bool public cancelEnabled = false;

    constructor(address mainToken, address alternativeToken) TokenProcessing(mainToken, alternativeToken) {}

    function setCancelEnabled(bool enable) public onlyOwner {
        cancelEnabled = enable;
    }

    function getClientBets(address client, uint offset, uint size) external view returns (uint[] memory) {
        uint resultSize = size;
        for (uint i = offset; i < offset + size; i++) {
            if (clientBets[client].length <= i) {
                resultSize = i - offset;
                break;
            }
        }
        uint[] memory result = new uint[](resultSize);
        for (uint i = offset; i < offset + resultSize; i++) {
            result[i - offset] = clientBets[client][i];
        }
        return result;
    }

    function getJackpotBet(uint betId) external view returns (JackpotDTOs.JackpotBet memory, uint) {
        return (jackpotBets[betId], matchingInfo[betId].totalAmount);
    }


    function getJackpotClientJoins(address client, uint betId) external view returns (JackpotDTOs.JoinJackpotBetClient[] memory) {
        JackpotDTOs.JoinJackpotBetClient[] memory clientList = new JackpotDTOs.JoinJackpotBetClient[](clientInfo[client][betId].length);
        for (uint i = 0; i < clientInfo[client][betId].length; i++) {
            clientList[i] = matchingInfo[betId].joins[clientInfo[client][betId].joinListRefs[i]];
        }
        return clientList;
    }


    function refundJackpotBet(uint betId, address client) public {
        JackpotDTOs.JackpotBet storage jackpotBet = jackpotBets[betId];
        require(keccak256(abi.encodePacked(jackpotBet.finalJackpotValue)) == keccak256(abi.encodePacked("")), "P2PJackpotBetProvider.refundJackpotBet: jackpot haven't to be open");
        require(jackpotBet.expirationTime + getTimestampExpirationDelay() < block.timestamp, "P2PJackpotBetProvider.refundJackpotBet: expiration error");

        (uint mainTokenToRefund, uint alterTokenToRefund) = processRefundingJackpotBet(matchingInfo[betId], clientInfo[client][betId]);
        require(mainTokenToRefund > 0 || alterTokenToRefund > 0, "P2PJackpotBetProvider.refundJackpotBet: nothing");
        withdrawal(mainTokenToRefund, alterTokenToRefund, client);

        emit JackpotBetRefunded(
            betId,
            client,
            mainTokenToRefund,
            alterTokenToRefund
        );
    }

    function takeJackpotPrize(uint betId, address client) external {
        JackpotDTOs.JackpotBet storage jackpotBet = jackpotBets[betId];
        JackpotDTOs.JackpotMatchingInfo storage info = matchingInfo[betId];
        require(keccak256(abi.encodePacked(jackpotBet.finalJackpotValue)) != keccak256(abi.encodePacked("")), "P2PJackpotBetProvider.takeJackpotPrize: jackpot bet wasn't closed");

        uint wonAmount = getJackpotWonAmount(betId, client);
        markAsPrizeTaken(info, clientInfo[client][betId]);
        require(wonAmount > 0, "P2PJackpotBetProvider.takeJackpotPrize: nothing");

        withdrawalMainToken(client, wonAmount);

        emit JackpotPrizeTaken(
            betId,
            client,
            wonAmount
        );
    }


    function getJackpotWonAmount(uint betId, address client) public view returns (uint) {
        JackpotDTOs.JackpotBet storage jackpotBet = jackpotBets[betId];
        if (keccak256(abi.encodePacked(jackpotBet.finalJackpotValue)) == keccak256(abi.encodePacked(""))) {
            return 0;
        }

        return evaluateWonAmount(matchingInfo[betId], clientInfo[client][betId], jackpotBets[betId]);
    }

    function closeJackpotBet(uint betId, string calldata finalValue) external onlyCompany {
        require(keccak256(abi.encodePacked(finalValue)) != keccak256(abi.encodePacked("")), "P2PJackpotBetProvider.closeJackpotBet: jackpot bet can't be closed with empty final value");
        JackpotDTOs.JackpotBet storage jackpotBet = jackpotBets[betId];
        JackpotDTOs.JackpotMatchingInfo storage info = matchingInfo[betId];
        require(jackpotBet.expirationTime < block.timestamp, "P2PJackpotBetProvider.closeJackpotBet: expiration error");
        require(jackpotBet.expirationTime + getTimestampExpirationDelay() > block.timestamp, "P2PJackpotBetProvider.closeJackpotBet: expiration delay error");
        require(keccak256(abi.encodePacked(jackpotBet.finalJackpotValue)) == keccak256(abi.encodePacked("")), "P2PJackpotBetProvider.closeJackpotBet: bet already closed");

        // Form final bank
        uint finalTotalBank = jackpotBet.startBank + info.totalAmount;
        jackpotBet.finalJackpotValue = finalValue;
        jackpotBet.finalBank = finalTotalBank;
        (uint firstSize, uint secondSize, uint thirdSize) = getWinnersByAmount(info, finalValue);
        if (thirdSize > 0) {
            jackpotBet.finalBank -= applyThirdModifier(finalTotalBank);
        }
        if (secondSize > 0) {
            jackpotBet.finalBank -= applySecondModifier(finalTotalBank);
        }
        if (firstSize > 0) {
            jackpotBet.finalBank -= applyFirstModifier(finalTotalBank);
        }

        // Take fee to vault
        if (info.fee > 0) {
            increaseFee(info.fee, false);
            info.fee = 0;
        }
        if (info.alterFee > 0) {
            increaseFee(info.alterFee, true);
            info.alterFee = 0;
        }

        emit JackpotBetClosed(
            betId,
            finalValue,
            firstSize,
            secondSize,
            thirdSize,
            finalTotalBank - jackpotBet.finalBank
        );
    }

    function cancelJackpotJoin(uint betId, uint joinRefId) external {
        require(cancelEnabled, "P2PJackpotBetProvider.cancelJackpotJoin: cancel disabled");
        JackpotDTOs.JoinJackpotBetClient storage clientJoin = matchingInfo[betId].joins[clientInfo[msg.sender][betId].joinListRefs[joinRefId]];

        require(clientJoin.amount != 0, "P2PJackpotBetProvider.cancelJackpotJoin: free amount empty");
        require(jackpotBets[betId].lockTime >= block.timestamp, "P2PJackpotBetProvider.cancelJackpotJoin: lock time");

        (uint mainTokenToRefund, uint alterTokenToRefund) = cancelJackpotBet(matchingInfo[betId], clientJoin);
        withdrawal(mainTokenToRefund, alterTokenToRefund, msg.sender);

        emit JackpotBetCancelled(
            betId,
            msg.sender,
            joinRefId,
            mainTokenToRefund,
            alterTokenToRefund
        );
    }


    function createJackpotBet(JackpotDTOs.CreateJackpotRequest calldata createRequest) external onlyCompany returns (uint) {
        // lock - 60 * 5
        // expiration - 60 * 5
        require(createRequest.lockTime >= block.timestamp + 3 * 60, "P2PJackpotBetProvider.createJackpotBet: lock time");
        require(createRequest.expirationTime >= createRequest.lockTime + 3 * 60, "P2PJackpotBetProvider.createJackpotBet: expirationTime time");
        JackpotDTOs.JackpotBet storage previousJackpot = jackpotBets[jackpotBetIdCounter];
        require((previousJackpot.expirationTime < block.timestamp && keccak256(abi.encodePacked(previousJackpot.finalJackpotValue)) != keccak256(abi.encodePacked("")))
            || previousJackpot.expirationTime + getTimestampExpirationDelay() < block.timestamp, "P2PJackpotBetProvider.createJackpotBet: active jackpot found");

        uint betId = ++jackpotBetIdCounter;

        uint startBank;
        if (keccak256(abi.encodePacked(previousJackpot.finalJackpotValue)) == keccak256(abi.encodePacked(""))) {
            // expired
            startBank = previousJackpot.startBank;
        } else {
            // success close
            startBank = previousJackpot.finalBank;
        }


        jackpotBets[betId] = JackpotDTOs.JackpotBet(
            betId,
            createRequest.eventId,
            createRequest.requestAmount,
            createRequest.lockTime,
            createRequest.expirationTime,
            startBank,
            0,
            ""
        );

        emit JackpotBetCreated(
            betId,
            createRequest.eventId,
            createRequest.lockTime,
            createRequest.expirationTime,
            msg.sender,
            jackpotBets[betId].startBank,
            createRequest.requestAmount
        );

        return betId;
    }

    function massJoinJackpotBet(JackpotDTOs.MassJoinJackpotRequest calldata massJoinRequest) external {
        // deposit amounts
        DepositedValue memory depositedValue = deposit(msg.sender, jackpotBets[massJoinRequest.betId].requestAmount * massJoinRequest.targetValues.length, massJoinRequest.useAlterFee);

        // Only mainAmount takes part in the jackpot bet
        uint mainAmount = depositedValue.mainAmount / massJoinRequest.targetValues.length;
        uint feeAmount = depositedValue.feeAmount / massJoinRequest.targetValues.length;

        for (uint i = 0; i < massJoinRequest.targetValues.length; ++i) {
            executeJoinJackpotBet(massJoinRequest.betId, massJoinRequest.useAlterFee, massJoinRequest.targetValues[i], mainAmount, feeAmount);
        }
    }

    function joinJackpotBet(JackpotDTOs.JoinJackpotRequest calldata joinRequest) external {
        // deposit amounts
        DepositedValue memory depositedValue = deposit(msg.sender, jackpotBets[joinRequest.betId].requestAmount, joinRequest.useAlterFee);

        // Only mainAmount takes part in the jackpot bet
        uint mainAmount = depositedValue.mainAmount;
        uint feeAmount = depositedValue.feeAmount;

        executeJoinJackpotBet(joinRequest.betId, joinRequest.useAlterFee, joinRequest.targetValue, mainAmount, feeAmount);
    }

    function executeJoinJackpotBet(uint betId, bool useAlterFee, string calldata targetValue, uint mainAmount, uint feeAmount) private {
        require(jackpotBets[betId].lockTime >= block.timestamp, "P2PJackpotBetProvider.joinJackpotBet: lock time");
        clientBets[msg.sender].push(betId);
        clientBetsLength[msg.sender]++;


        JackpotDTOs.JoinJackpotBetClientList storage clientBetList = clientInfo[msg.sender][betId];


        JackpotDTOs.JackpotMatchingInfo storage info = matchingInfo[betId];
        uint joinId = info.joinsLength++;

        JackpotDTOs.JoinJackpotBetClient memory joinBetClient = JackpotDTOs.JoinJackpotBetClient(
            joinId,
            msg.sender,
            mainAmount,
            useAlterFee,
            feeAmount,
            targetValue,
            clientBetList.length,
            false
        );


        // Custom bet enrichment with matching
        joinJackpotBet(info, joinBetClient);

        // Add to client info sidePointer
        clientBetList.joinListRefs[clientBetList.length++] = joinId;

        emit JackpotBetJoined(
            useAlterFee,
            msg.sender,
            betId,
            joinBetClient.id,
            clientBetList.length - 1,
            targetValue
        );
    }

    event JackpotBetCreated(
        uint id,
        string eventId,
        uint lockTime,
        uint expirationTime,
        address indexed creator,
        uint startBank,
        uint requestAmount
    );

    event JackpotBetJoined(
        bool useAlterFee,
        address indexed client,
        uint betId,
        uint joinId,
        uint joinRefId,
        string targetValue
    );

    event JackpotBetCancelled(
        uint betId,
        address indexed client,
        uint joinIdRef,
        uint mainTokenRefunded,
        uint alterTokenRefunded
    );

    event JackpotBetClosed(
        uint betId,
        string finalValue,
        uint firstWonSize,
        uint secondWonSize,
        uint thirdWonSize,
        uint totalRaffled
    );

    event JackpotPrizeTaken(
        uint betId,
        address indexed client,
        uint amount
    );

    event JackpotBetRefunded(
        uint betId,
        address indexed client,
        uint mainTokenRefunded,
        uint alterTokenRefunded
    );
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../security/Ownable.sol";
import "./CompanyVault.sol";
import "./AlternativeTokenHelper.sol";
import "./FeeConfiguration.sol";

abstract contract TokenProcessing is CompanyVault, AlternativeTokenHelper, FeeConfiguration {
    event FeeTaken(uint amount, address indexed targetAddress, bool isAlternative);

    struct DepositedValue {
        uint mainAmount;
        uint feeAmount;
    }

    constructor(address mainToken, address alternativeToken) CompanyVault(mainToken, alternativeToken) {}

    // Deposit amount from sender with alternative token for fee or not
    function deposit(address sender, uint amount, bool useAlternative) internal returns (DepositedValue memory) {
        if (useAlternative) {
            require(isAlternativeTokenEnabled(), "TokenProcessing: alternative token disabled");
            return depositWithAlternative(sender, amount);
        } else {
            uint feePart = applyCompanyFee(amount);
            depositToken(getMainIERC20Token(), sender, amount + feePart);
            return DepositedValue(amount, feePart);
        }
    }

    // Withdrawal main and alter tokens to client
    function withdrawal(uint mainTokenToRefund, uint alterTokenToRefund, address client) internal {
        if (mainTokenToRefund > 0) {
            withdrawalMainToken(client, mainTokenToRefund);
        }

        if (alterTokenToRefund > 0) {
            withdrawalAlternativeToken(client, alterTokenToRefund);
        }
    }

    // Withdrawal main tokens to user
    // Used only in take prize and bet cancellation
    function withdrawalMainToken(address recipient, uint amount) internal {
        withdrawalToken(getMainIERC20Token(), recipient, amount);
    }

    // Withdrawal alternative tokens to user
    // Used only in bet cancellation
    function withdrawalAlternativeToken(address recipient, uint amount) internal {
        withdrawalToken(getAlternativeIERC20Token(), recipient, amount);
    }

    // Withdtawal amount of tokens to recipient
    function withdrawalToken(IERC20 token, address recipient, uint amount) private {
        bool result = token.transfer(recipient, amount);
        require(result, "TokenProcessing: withdrawal token failed");
    }

    // Evaluate alternative part with UniswapRouter and transferFrom main part and transferFrom equal alternative part
    function depositWithAlternative(address sender, uint amount) private returns (DepositedValue memory) {
        uint alternativePart = applyAlternativeFee(amount);

        depositToken(getMainIERC20Token(), sender, amount);

        uint alternativePartInAlternativeToken = evaluateAlternativeAmount(alternativePart, getMainToken(), getAlternativeToken());

        depositToken(getAlternativeIERC20Token(), sender, alternativePartInAlternativeToken);

        return DepositedValue(amount, alternativePartInAlternativeToken);
    }


    // Deposit amount of tokens from sender to this contract
    function depositToken(IERC20 token, address sender, uint amount) private {
        require(token.allowance(sender, address(this)) >= amount, "TokenProcessing: depositMainToken, not enough funds to deposit token");

        bool result = token.transferFrom(sender, address(this), amount);
        require(result, "TokenProcessing: depositMainToken, transfer from failed");
    }

    // Start take company fee from main token company balance
    function takeFeeStart(uint amount, address targetAddress, bool isAlternative) external onlyOwner {
        if (isAlternative) {
            require(amount <= getCompanyAlternativeTokenBalance(), "CompanyVault: take fee amount exeeds alter token balance");
        } else {
            require(amount <= getCompanyTokenBalance(), "CompanyVault: take fee amount exeeds token balance");
        }

        uint votingCode = startVoting("TAKE_FEE");
        takeFeeVoting = SecurityDTOs.TakeFee(
            amount,
            targetAddress,
            isAlternative,
            block.timestamp,
            votingCode
        );
    }

    function acquireTakeFee() external onlyOwner {
        pass(takeFeeVoting.votingCode);

        IERC20 token;
        if (takeFeeVoting.isAlternative) {
            token = getAlternativeIERC20Token();
        } else {
            token = getMainIERC20Token();
        }

        bool result = token.transfer(takeFeeVoting.targetAddress, takeFeeVoting.amount);
        decreaseFee(takeFeeVoting.amount, takeFeeVoting.isAlternative);
        require(result, "TokenProcessing: take fee transfer failed");
        emit FeeTaken(takeFeeVoting.amount, takeFeeVoting.targetAddress, takeFeeVoting.isAlternative);
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;


library JackpotDTOs {
    struct JackpotBet {
        uint id;
        string eventId;
        uint requestAmount;
        uint lockTime;
        uint expirationTime;
        uint startBank;

        uint finalBank;
        string finalJackpotValue;
    }

    struct JackpotMatchingInfo {
        mapping(uint => JoinJackpotBetClient) joins;
        uint joinsLength;

        mapping(string => mapping(uint => uint)) firstJoinLevel;
        mapping(string => uint) firstJoinSize;
        mapping(string => uint) firstJoinActual;
        mapping(string => mapping(uint => uint)) secondJoinLevel;
        mapping(string => uint) secondJoinSize;
        mapping(string => uint) secondJoinActual;
        mapping(string => mapping(uint => uint)) thirdJoinLevel;
        mapping(string => uint) thirdJoinSize;
        mapping(string => uint) thirdJoinActual;

        uint totalAmount;
        uint fee;
        uint alterFee;
    }

    struct JoinJackpotBetClientList {
        mapping(uint => uint) joinListRefs;
        uint length;
    }

    struct JoinJackpotBetClient {
        uint id;
        address client;
        uint amount;
        bool useAlterFee;
        uint feeAmount;
        string targetValue;
        uint joinIdRef;
        bool prizeTaken;
    }

    struct CreateJackpotRequest {
        string eventId;
        uint lockTime;
        uint expirationTime;
        uint requestAmount;
    }

    struct JoinJackpotRequest {
        uint betId;
        bool useAlterFee;
        string targetValue;
    }

    struct MassJoinJackpotRequest {
        bool useAlterFee;
        uint betId;
        string[] targetValues;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../../utils/strings.sol";
import "./JackpotDTOs.sol";


abstract contract JackpotProcessor {
    using strings for *;

    function markAsPrizeTaken(JackpotDTOs.JackpotMatchingInfo storage info, JackpotDTOs.JoinJackpotBetClientList storage clientList) internal {
        for (uint i = 0; i < clientList.length; ++i) {
            JackpotDTOs.JoinJackpotBetClient storage joinClient = info.joins[clientList.joinListRefs[i]];
            joinClient.prizeTaken = true;
        }
    }

    function evaluateWonAmount(JackpotDTOs.JackpotMatchingInfo storage info, JackpotDTOs.JoinJackpotBetClientList storage clientList, JackpotDTOs.JackpotBet storage bet) internal view returns (uint) {
        (string memory firstWon, string memory secondWon, string memory thirdWon) = processStringValue(bet.finalJackpotValue);
        uint resultAmount;
        for (uint i = 0; i < clientList.length; ++i) {
            JackpotDTOs.JoinJackpotBetClient storage joinClient = info.joins[clientList.joinListRefs[i]];
            // already taken
            if (joinClient.prizeTaken) {
                continue;
            }
            // canceled
            if (joinClient.amount == 0) {
                continue;
            }
            // process won amount
            (string memory first, string memory second, string memory third) = processStringValue(joinClient.targetValue);

            if (keccak256(abi.encodePacked(firstWon)) == keccak256(abi.encodePacked(first))) {
                resultAmount += applyFirstModifier(bet.startBank + info.totalAmount) / info.firstJoinActual[firstWon];
            }
            if (keccak256(abi.encodePacked(secondWon)) == keccak256(abi.encodePacked(second))) {
                resultAmount += applySecondModifier(bet.startBank + info.totalAmount) / info.secondJoinActual[secondWon];
            }
            if (keccak256(abi.encodePacked(thirdWon)) == keccak256(abi.encodePacked(third))) {
                resultAmount += applyThirdModifier(bet.startBank + info.totalAmount) / info.thirdJoinActual[thirdWon];
            }
        }

        return resultAmount;
    }

    // Refund main token and alter token(if pay alter fee)
    // Only after expiration + expirationDelay call without bet closed action
    function processRefundingJackpotBet(JackpotDTOs.JackpotMatchingInfo storage info, JackpotDTOs.JoinJackpotBetClientList storage clientList) internal returns (uint, uint) {
        uint resultAmount;
        uint refundAlterFee;
        for (uint i = 0; i < clientList.length; ++i) {
            JackpotDTOs.JoinJackpotBetClient storage joinClient = info.joins[clientList.joinListRefs[i]];
            resultAmount += joinClient.amount;

            if (joinClient.useAlterFee) {
                refundAlterFee += joinClient.feeAmount;
            } else {
                resultAmount += joinClient.feeAmount;
            }

            joinClient.amount = 0;
            joinClient.feeAmount = 0;
        }

        return (resultAmount, refundAlterFee);
    }

    // Evaluate mainToken and alternativeToken for refunding
    // returns (mainToken amount, alternativeToken amount)
    function cancelJackpotBet(JackpotDTOs.JackpotMatchingInfo storage info, JackpotDTOs.JoinJackpotBetClient storage joinClient) internal returns (uint, uint) {
        uint amount = joinClient.amount;
        uint feeAmount = joinClient.feeAmount;

        info.totalAmount -= amount;

        if (joinClient.useAlterFee) {
            info.alterFee -= feeAmount;
        } else {
            info.fee -= feeAmount;
        }

        (string memory first, string memory second, string memory third) = processStringValue(joinClient.targetValue);
        info.firstJoinActual[first]--;
        info.secondJoinActual[second]--;
        info.thirdJoinActual[third]--;

        joinClient.amount = 0;
        joinClient.feeAmount = 0;

        if (joinClient.useAlterFee) {
            // Return all free and feeAmount in alternative
            return (amount, feeAmount);
        } else {
            // Return all in main
            return (amount + feeAmount, 0);
        }
    }

    function joinJackpotBet(JackpotDTOs.JackpotMatchingInfo storage info, JackpotDTOs.JoinJackpotBetClient memory joinJackpotRequestBet) internal {
        if (joinJackpotRequestBet.useAlterFee) {
            info.alterFee += joinJackpotRequestBet.feeAmount;
        } else {
            info.fee += joinJackpotRequestBet.feeAmount;
        }

        info.joins[joinJackpotRequestBet.id] = joinJackpotRequestBet;
        info.totalAmount += joinJackpotRequestBet.amount;

        (string memory first, string memory second, string memory third) = processStringValue(joinJackpotRequestBet.targetValue);
        info.firstJoinLevel[first][info.firstJoinSize[first]++] = joinJackpotRequestBet.id;
        info.firstJoinActual[first]++;
        info.secondJoinLevel[second][info.secondJoinSize[second]++] = joinJackpotRequestBet.id;
        info.secondJoinActual[second]++;
        info.thirdJoinLevel[third][info.thirdJoinSize[third]++] = joinJackpotRequestBet.id;
        info.thirdJoinActual[third]++;
    }

    function getWinnersByAmount(JackpotDTOs.JackpotMatchingInfo storage info, string memory value) internal view returns (uint, uint, uint) {
        (string memory first, string memory second, string memory third) = processStringValue(value);
        return (info.firstJoinSize[first], info.secondJoinSize[second], info.thirdJoinSize[third]);
    }

    function processStringValue(string memory value) private pure returns (string memory, string memory, string memory) {
        strings.slice memory slicedValue = value.toSlice();
        strings.slice memory delimiter = ".".toSlice();

        strings.slice[] memory parts = new strings.slice[](slicedValue.count(delimiter) + 1);

        require(parts.length == 2, "JackpotProcessor.processStringValue: wrong value");

        parts[0] = slicedValue.split(delimiter);
        parts[1] = slicedValue;

        require(parts[0].len() > 0, "JackpotProcessor.processStringValue: main part too short");
        require(parts[1].len() == 2, "JackpotProcessor.processStringValue: fractional part not equals 2");

        strings.slice memory firstFractionalDigit = parts[1].nextRune();
        strings.slice memory secondFractionalDigit = parts[1].nextRune();

        string memory firstValue = parts[0].copy().toString();
        string memory secondValue = parts[0].copy().concat(firstFractionalDigit.copy());
        string memory thirdValue = parts[0].copy().concat(firstFractionalDigit.copy()).toSlice().concat(secondFractionalDigit);

        return (firstValue, secondValue, thirdValue);
    }

    // 0.7%
    function applyFirstModifier(uint amount) internal pure returns (uint) {
        return (amount * 7) / 10 ** 3;
    }

    // 7%
    function applySecondModifier(uint amount) internal pure returns (uint) {
        return (amount * 7) / 10 ** 2;
    }

    // 70%
    function applyThirdModifier(uint amount) internal pure returns (uint) {
        return (amount * 7) / 10;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../utils/Context.sol";
import "./SecurityDTOs.sol";

abstract contract Ownable is Context {
    mapping(address => bool) public owners;
    address private _company;
    uint totalOwners;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event CompanyTransferred(address indexed previousCompany, address indexed newCompany);

    event AddOwner(address indexed newOwner);
    event RemoveOwner(address indexed ownerToRemove);

    constructor () {
        address msgSender = _msgSender();
        addOwner(msgSender);
    }


    modifier onlyOwner() {
        require(owners[_msgSender()], "Security: caller is not the owner");
        _;
    }

    function removeOwner(address ownerToRemove) internal {
        require(owners[ownerToRemove], "Security: now owner");

        owners[ownerToRemove] = false;
        totalOwners--;
        emit RemoveOwner(ownerToRemove);
    }

    function addOwner(address newOwner) internal {
        require(newOwner != address(0), "Security: new owner is the zero address");
        require(!owners[newOwner], "Security: already owner");

        owners[newOwner] = true;
        totalOwners++;
        emit AddOwner(newOwner);
    }



    /**
     * @dev Returns the address of the current company.
     */
    function company() public view virtual returns (address) {
        return _company;
    }

    /**
     * @dev Throws if called by any account other than the company.
     */
    modifier onlyCompany() {
        require(company() == _msgSender(), "Security: caller is not the company");
        _;
    }

    /**
     * @dev Transfers company rights of the contract to a new account (`newCompany`).
     * Can only be called by the current owner.
     */
    function transferCompany(address newCompany) internal {
        require(newCompany != address(0), "Security: new company is the zero address");

        emit CompanyTransferred(_company, newCompany);
        _company = newCompany;
    }

}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../security/Security.sol";
import "../utils/IERC20.sol";

abstract contract CompanyVault is Security {
    IERC20 internal _IERC20token;
    IERC20 internal _AlternativeIERC20token;
    uint private _companyTokenBalance;
    uint private _companyAlternativeTokenBalance;
    bool private _alternativeTokenEnabled;
    uint private _timestampExpirationDelay;

    event OtherTokensTaken(uint amount, address indexed tokenAddress, address indexed targetAddress);

    constructor (address mainToken, address alternativeToken) {
        _IERC20token = IERC20(mainToken);
        _AlternativeIERC20token = IERC20(alternativeToken);
        _timestampExpirationDelay = 2 * 60 * 60;
    }

    // Set expiration delay
    function setTimestampExpirationDelay(uint timestampExpirationDelay) external onlyOwner {
        _timestampExpirationDelay = timestampExpirationDelay;
    }

    // Get expiration delay to refund
    function getTimestampExpirationDelay() public view returns (uint) {
        return _timestampExpirationDelay;
    }

    // Get main token
    function getMainToken() public view returns (address) {
        return address(_IERC20token);
    }

    // Enable/disable alternative token usage
    function enableAlternativeToken(bool enable) external {
        _alternativeTokenEnabled = enable;
    }

    // Status of alternative token
    function isAlternativeTokenEnabled() public view returns (bool) {
        return _alternativeTokenEnabled;
    }

    // Get alternative token to pay fee
    function getAlternativeToken() public view returns (address) {
        return address(_AlternativeIERC20token);
    }

    // Get main IERC20 interface
    function getMainIERC20Token() internal view returns (IERC20) {
        return _IERC20token;
    }

    // Get alternative IERC20 interface
    function getAlternativeIERC20Token() internal view returns (IERC20) {
        return _AlternativeIERC20token;
    }

    // Get main token company balance from fees
    function getCompanyTokenBalance() public view returns (uint) {
        return _companyTokenBalance;
    }

    // Get alternative token company balance from fees
    function getCompanyAlternativeTokenBalance() public view returns (uint) {
        return _companyAlternativeTokenBalance;
    }

    // Increase main or alter token fee. Calls only from finished bets.
    function increaseFee(uint amount, bool isAlternative) internal {
        if (isAlternative) {
            _companyAlternativeTokenBalance += amount;
        } else {
            _companyTokenBalance += amount;
        }
    }

    // Decrease main or alter token fee. Calls only from take fee.
    function decreaseFee(uint amount, bool isAlternative) internal {
        if (isAlternative) {
            _companyAlternativeTokenBalance -= amount;
        } else {
            _companyTokenBalance -= amount;
        }
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../security/Security.sol";
import "../utils/IPancakeRouter01.sol";

abstract contract AlternativeTokenHelper is Security {
    IPancakeRouter01 internal _IUniswapV2Router01;

    function setRouter(address router) external {
        _IUniswapV2Router01 = IPancakeRouter01(router);
    }

    function evaluateAlternativeAmount(uint mainAmount, address  mainToken, address alternativeToken) internal view returns(uint) {
        address[] memory path = new address[](2);
        path[0] = mainToken;
        path[1] = alternativeToken;
        return _IUniswapV2Router01.getAmountsOut(mainAmount, path)[0];
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../security/Security.sol";

abstract contract FeeConfiguration is Security{
    //DECIMALS 6 for 100%
    uint private _companyFee;
    //DECIMALS 6 for 100%
    uint private _alternativeFee;

    event CompanyFeeChanged(uint previousCompanyFee, uint newCompanyFee);
    event CompanyAlterFeeChanged(uint previousAlternativeFee, uint newAlternativeFee);

    // Set company fee for all bets with main token fee
    function setCompanyFee(uint companyFee) external onlyOwner {
        require(companyFee <= 10**6);
        emit CompanyFeeChanged(_companyFee, companyFee);
        _companyFee = companyFee;
    }

    // Set company fee for all bets with alternative token fee
    function setAlternativeFeeFee(uint alternativeFee) external onlyOwner {
        require(alternativeFee <= 10 ** 6);
        emit CompanyAlterFeeChanged(_alternativeFee, alternativeFee);
        _alternativeFee = alternativeFee;
    }

    // Get company fee(main token)
    function getCompanyFee() external view returns (uint) {
        return _companyFee;
    }

    // Get alternative company fee(alternative token)
    function getAlternativeFee() external view returns (uint) {
        return _alternativeFee;
    }

    // Apply company fee and return company fee part
    function applyCompanyFee(uint amount) internal view returns(uint) {
        return (amount * _companyFee) / 10**6;
    }

    // Apply alternative company fee and return alternative fee part
    function applyAlternativeFee(uint amount) internal view returns(uint) {
        return (amount * _alternativeFee) / 10**6;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

library SecurityDTOs {
    struct AddOwner {
        address newOwner;
        uint createdDate;
        uint votingCode;
    }

    struct RemoveOwner {
        address ownerToRemove;
        uint createdDate;
        uint votingCode;
    }

    struct TransferCompany {
        address newCompanyAddress;
        uint createdDate;
        uint votingCode;
    }

    struct TakeFee {
        uint amount;
        address targetAddress;
        bool isAlternative;
        uint createdDate;
        uint votingCode;
    }

    struct VotingInfo {
        address initiator;
        uint currentNumberOfVotesPositive;
        uint currentNumberOfVotesNegative;
        uint startedDate;
        string votingCode;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "./Voting.sol";

abstract contract Security is Voting {
    SecurityDTOs.AddOwner public addOwnerVoting;
    SecurityDTOs.TransferCompany public transferCompanyVoting;
    SecurityDTOs.RemoveOwner public removeOwnerVoting;
    SecurityDTOs.TakeFee public takeFeeVoting;


    // Start voting for add owner
    function ownerAddStart(address newOwner) external onlyOwner {
        require(!owners[newOwner], "Security: already owner");

        uint votingCode = startVoting("ADD_OWNER");
        addOwnerVoting = SecurityDTOs.AddOwner(
            newOwner,
            block.timestamp,
            votingCode
        );
    }

    function acquireNewOwner() external onlyOwner {
        pass(addOwnerVoting.votingCode);
        addOwner(addOwnerVoting.newOwner);
    }

    function transferCompanyStart(address newCompany) public virtual onlyOwner {
        require(newCompany != address(0), "Security: new company is the zero address");

        uint votingCode = startVoting("TRANSFER_COMPANY");
        transferCompanyVoting = SecurityDTOs.TransferCompany(
            newCompany,
            block.timestamp,
            votingCode
        );
    }

    function acquireTransferCompany() external onlyOwner {
        pass(transferCompanyVoting.votingCode);
        transferCompany(transferCompanyVoting.newCompanyAddress);
    }

    // Start voting removing owner
    function ownerToRemoveStart(address ownerToRemove) external onlyOwner {
        require(owners[ownerToRemove], "Security: is not owner");

        uint votingCode = startVoting("REMOVE_OWNER");
        removeOwnerVoting = SecurityDTOs.RemoveOwner(
            ownerToRemove,
            block.timestamp,
            votingCode
        );
    }

    function acquireOwnerToRemove() external onlyOwner {
        pass(removeOwnerVoting.votingCode);
        removeOwner(removeOwnerVoting.ownerToRemove);
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

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

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "./Ownable.sol";

abstract contract Voting is Ownable {
    event VotingStarted(string code, uint votingNumber, address indexed initiator);
    event VotingResult(string code, uint votingNumber, bool passed);

    bool public votingActive;
    SecurityDTOs.VotingInfo public votingInfo;
    uint private votingNumber;
    mapping(uint => mapping(address => bool)) public voted;


    function startVoting(string memory votingCode) internal returns (uint) {
        require(!votingActive, "Voting: there is active voting already");
        votingInfo = SecurityDTOs.VotingInfo(
            _msgSender(),
            0,
            0,
            block.timestamp,
            votingCode
        );
        votingActive = true;
        votingNumber++;

        votePositive();
        emit VotingStarted(
            votingCode,
            votingNumber,
            _msgSender()
        );

        return votingNumber;
    }

    // End voting with success
    function pass(uint toCheckVotingNumber) internal {
        require(votingActive, "Voting: there is no active voting");
        require(toCheckVotingNumber == votingNumber, "Voting: old voting found");
        require(votingInfo.startedDate + 60 * 60 * 72 < block.timestamp || votingInfo.currentNumberOfVotesPositive == totalOwners, "Voting: 72 hours have not yet passed");
        require(votingInfo.currentNumberOfVotesPositive > totalOwners / 2, "Voting: not enough positive votes");

        votingActive = false;
        emit VotingResult(
            votingInfo.votingCode,
            votingNumber,
            true
        );
    }


    // Close voting
    function close() external onlyOwner {
        require(votingActive, "Voting: there is no active voting");
        require(votingInfo.startedDate + 144 * 60 * 60 < block.timestamp || votingInfo.currentNumberOfVotesNegative > totalOwners / 2, "Voting: condition close error");
        votingActive = false;
        emit VotingResult(
            votingInfo.votingCode,
            votingNumber,
            false
        );
    }

    function votePositive() public onlyOwner {
        vote();
        votingInfo.currentNumberOfVotesPositive++;
    }

    function voteNegative() external onlyOwner {
        vote();
        votingInfo.currentNumberOfVotesNegative++;
    }

    function vote() private {
        require(votingActive, "Voting: there is no active voting");
        require(!voted[votingNumber][_msgSender()], "Voting: already voted");
        voted[votingNumber][_msgSender()] = true;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

interface IPancakeRouter01 {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library strings {
    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private pure {
        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = type(uint).max;
        if (len > 0) {
            mask = 256 ** (32 - len) - 1;
        }
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    /*
     * @dev Returns a slice containing the entire string.
     * @param self The string to make a slice from.
     * @return A newly allocated slice containing the entire string.
     */
    function toSlice(string memory self) internal pure returns (slice memory) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    /*
     * @dev Returns the length of a null-terminated bytes32 string.
     * @param self The value to find the length of.
     * @return The length of the string, from 0 to 32.
     */
    function len(bytes32 self) internal pure returns (uint) {
        uint ret;
        if (self == 0)
            return 0;
        if (uint(self) & type(uint128).max == 0) {
            ret += 16;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);
        }
        if (uint(self) & type(uint64).max == 0) {
            ret += 8;
            self = bytes32(uint(self) / 0x10000000000000000);
        }
        if (uint(self) & type(uint32).max == 0) {
            ret += 4;
            self = bytes32(uint(self) / 0x100000000);
        }
        if (uint(self) & type(uint16).max == 0) {
            ret += 2;
            self = bytes32(uint(self) / 0x10000);
        }
        if (uint(self) & type(uint8).max == 0) {
            ret += 1;
        }
        return 32 - ret;
    }


    /*
     * @dev Returns a new slice containing the same data as the current slice.
     * @param self The slice to copy.
     * @return A new slice containing the same data as `self`.
     */
    function copy(slice memory self) internal pure returns (slice memory) {
        return slice(self._len, self._ptr);
    }

    /*
     * @dev Copies a slice to a new string.
     * @param self The slice to copy.
     * @return A newly allocated string containing the slice's text.
     */
    function toString(slice memory self) internal pure returns (string memory) {
        string memory ret = new string(self._len);
        uint retptr;
        assembly {retptr := add(ret, 32)}

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    /*
     * @dev Returns the length in runes of the slice. Note that this operation
     *      takes time proportional to the length of the slice; avoid using it
     *      in loops, and call `slice.empty()` if you only need to know whether
     *      the slice is empty or not.
     * @param self The slice to operate on.
     * @return The length of the slice in runes.
     */
    function len(slice memory self) internal pure returns (uint l) {
        // Starting at ptr-31 means the LSB will be the byte we care about
        uint ptr = self._ptr - 31;
        uint end = ptr + self._len;
        for (l = 0; ptr < end; l++) {
            uint8 b;
            assembly {b := and(mload(ptr), 0xFF)}
            if (b < 0x80) {
                ptr += 1;
            } else if (b < 0xE0) {
                ptr += 2;
            } else if (b < 0xF0) {
                ptr += 3;
            } else if (b < 0xF8) {
                ptr += 4;
            } else if (b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
    }

    /*
     * @dev Extracts the first rune in the slice into `rune`, advancing the
     *      slice to point to the next rune and returning `self`.
     * @param self The slice to operate on.
     * @param rune The slice that will contain the first rune.
     * @return `rune`.
     */
    function nextRune(slice memory self, slice memory rune) internal pure returns (slice memory) {
        rune._ptr = self._ptr;

        if (self._len == 0) {
            rune._len = 0;
            return rune;
        }

        uint l;
        uint b;
        // Load the first byte of the rune into the LSBs of b
        assembly {b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF)}
        if (b < 0x80) {
            l = 1;
        } else if (b < 0xE0) {
            l = 2;
        } else if (b < 0xF0) {
            l = 3;
        } else {
            l = 4;
        }

        // Check for truncated codepoints
        if (l > self._len) {
            rune._len = self._len;
            self._ptr += self._len;
            self._len = 0;
            return rune;
        }

        self._ptr += l;
        self._len -= l;
        rune._len = l;
        return rune;
    }

    /*
     * @dev Returns the first rune in the slice, advancing the slice to point
     *      to the next rune.
     * @param self The slice to operate on.
     * @return A slice containing only the first rune from `self`.
     */
    function nextRune(slice memory self) internal pure returns (slice memory ret) {
        nextRune(self, ret);
    }

    // Returns the memory address of the first byte of the first occurrence of
    // `needle` in `self`, or the first byte after `self` if not found.
    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr = selfptr;
        uint idx;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask;
                if (needlelen > 0) {
                    mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));
                }

                bytes32 needledata;
                assembly {needledata := and(mload(needleptr), mask)}

                uint end = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly {ptrdata := and(mload(ptr), mask)}

                while (ptrdata != needledata) {
                    if (ptr >= end)
                        return selfptr + selflen;
                    ptr++;
                    assembly {ptrdata := and(mload(ptr), mask)}
                }
                return ptr;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly {hash := keccak256(needleptr, needlelen)}

                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly {testHash := keccak256(ptr, needlelen)}
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and `token` to everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function split(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and returning everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` up to the first occurrence of `delim`.
     */
    function split(slice memory self, slice memory needle) internal pure returns (slice memory token) {
        split(self, needle, token);
    }

    /*
     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return The number of occurrences of `needle` found in `self`.
     */
    function count(slice memory self, slice memory needle) internal pure returns (uint cnt) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            cnt++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }

    /*
     * @dev Returns a newly allocated string containing the concatenation of
     *      `self` and `other`.
     * @param self The first slice to concatenate.
     * @param other The second slice to concatenate.
     * @return The concatenation of the two strings.
     */
    function concat(slice memory self, slice memory other) internal pure returns (string memory) {
        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly {retptr := add(ret, 32)}
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }
}