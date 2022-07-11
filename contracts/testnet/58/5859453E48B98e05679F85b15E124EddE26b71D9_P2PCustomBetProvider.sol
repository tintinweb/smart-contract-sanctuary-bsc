// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../../processing/TokenProcessing.sol";
import "./CustomDTOs.sol";
import "./CustomProcessor.sol";

contract P2PCustomBetProvider is TokenProcessing, CustomProcessor {
    mapping(uint => CustomDTOs.CustomBet) private customBets;
    mapping(uint => CustomDTOs.CustomMatchingInfo) private matchingInfo;
    mapping(address => mapping(uint => CustomDTOs.JoinCustomBetClientList)) private clientInfo;
    uint private customBetIdCounter;

    constructor(address mainToken, address alternativeToken) TokenProcessing(mainToken, alternativeToken) {}

    function closeCustomBet(uint betId, string calldata finalValue, bool targetSideWon) external onlyCompany {
        require(keccak256(abi.encodePacked(finalValue)) != keccak256(abi.encodePacked("")), "P2PCustomBetProvider: close error - custom bet can't be closed with empty value");
        CustomDTOs.CustomBet storage customBet = customBets[betId];
        require(customBet.expirationTime < block.timestamp, "P2PCustomBetProvider: close error - expiration error");
        require(customBet.expirationTime + getTimestampExpirationDelay() > block.timestamp, "P2PCustomBetProvider: close error - expiration error with delay");

        customBet.finalValue = finalValue;
        customBet.targetSideWon = targetSideWon;

        CustomDTOs.CustomMatchingInfo storage info = matchingInfo[betId];
        if (info.lockedFee > 0) {
            increaseFee(info.lockedFee, false);
            info.lockedFee = 0;
        }
        if (info.lockedAlterFee > 0) {
            increaseFee(info.lockedAlterFee, true);
            info.lockedAlterFee = 0;
        }

        emit CustomBetClosed(
            betId,
            finalValue,
            targetSideWon
        );
    }

    function refundCustomBet(uint betId, address client) public {
        CustomDTOs.CustomBet storage customBet = customBets[betId];
        require(keccak256(abi.encodePacked(customBet.finalValue)) == keccak256(abi.encodePacked("")), "P2PCustomBetProvider: refund - custom haven't to be open");
        require(customBet.expirationTime + getTimestampExpirationDelay() < block.timestamp, "P2PCustomBetProvider: refund - expiration error");

        (uint mainTokenToRefund, uint alterTokenToRefund) = processRefundingCustomBet(matchingInfo[betId], clientInfo[client][betId]);
        withdrawal(mainTokenToRefund, alterTokenToRefund, client);

        emit CustomBetRefunded(
            betId,
            client,
            mainTokenToRefund,
            alterTokenToRefund
        );
    }

    function takeCustomPrize(uint betId, address client) public {
        CustomDTOs.CustomBet storage customBet = customBets[betId];
        require(keccak256(abi.encodePacked(customBet.finalValue)) != keccak256(abi.encodePacked("")), "P2PCustomBetProvider: take prize - custom bet wasn't closed");

        (uint wonAmount, uint refundAlterToken) = takePrize(customBet, matchingInfo[betId], clientInfo[client][betId]);

        require(wonAmount > 0, "P2PCustomBetProvider: take prize - nothing");
        withdrawal(wonAmount, refundAlterToken, client);

        emit CustomPrizeTaken(
            betId,
            client,
            wonAmount
        );
    }

    function getCustomWonAmount(uint betId, address client) public view returns (uint) {
        CustomDTOs.CustomBet storage customBet = customBets[betId];
        if (keccak256(abi.encodePacked(customBet.targetValue)) == keccak256(abi.encodePacked(""))) {
            return 0;
        }

        (uint wonAmount,) = evaluatePrize(customBet, matchingInfo[betId], clientInfo[client][betId]);
        return wonAmount;
    }

    function createCustomBet(CustomDTOs.CreateCustomRequest calldata createRequest, CustomDTOs.JoinCustomRequest calldata joinRequest) external returns (uint) {
        // lock - 60 * 5
        // expiration - 60 * 5
        require(createRequest.lockTime >= block.timestamp + 60 * 3, "P2PCustomBetProvider: create - lock time");
        require(createRequest.expirationTime >= createRequest.lockTime + 60 * 3, "P2PCustomBetProvider: create - expirationTime time");

        uint betId = customBetIdCounter++;
        customBets[betId] = CustomDTOs.CustomBet(
            betId,
            createRequest.eventId,
            createRequest.lockTime,
            createRequest.expirationTime,
            createRequest.targetValue,
            createRequest.targetSide,
            createRequest.coefficient,
            "",
            false
        );

        joinCustomBet(betId, joinRequest);

        emit CustomBetCreated(
            betId,
            createRequest.eventId,
            createRequest.lockTime,
            createRequest.expirationTime,
            createRequest.targetValue,
            createRequest.targetSide,
            createRequest.coefficient,
            msg.sender
        );

        return betId;
    }

    function getCustomBet(uint betId) external view returns (CustomDTOs.CustomBet memory, uint, uint, uint, uint) {
        CustomDTOs.CustomMatchingInfo storage info = matchingInfo[betId];
        return (customBets[betId], info.leftFree, info.leftLocked, info.rightFree, info.rightLocked);
    }

    function getCustomClientJoins(address client, uint betId) external view returns (CustomDTOs.JoinCustomBetClient[] memory) {
        CustomDTOs.JoinCustomBetClient[] memory clientList = new CustomDTOs.JoinCustomBetClient[](clientInfo[client][betId].length);
        for (uint i = 0; i < clientInfo[client][betId].length; i++) {
            clientList[i] = extractCustomJoinBetClientByRef(matchingInfo[betId], clientInfo[client][betId].joinListRefs[i]);
        }
        return clientList;
    }

    function cancelCustomJoin(uint betId, uint joinIdRef) external {
        CustomDTOs.JoinCustomBetClient storage clientJoin = extractCustomJoinBetClientByRef(matchingInfo[betId], clientInfo[msg.sender][betId].joinListRefs[joinIdRef]);

        require(clientJoin.freeAmount != 0, "P2PCustomBetProvider: cancel - free amount empty");
        require(customBets[betId].lockTime >= block.timestamp, "P2PCustomBetProvider: cancel - lock time");

        (uint mainTokenToRefund, uint alterTokenToRefund) = cancelCustomBet(customBets[betId], matchingInfo[betId], clientJoin);
        withdrawal(mainTokenToRefund, alterTokenToRefund, msg.sender);

        emit CustomBetCancelled(
            betId,
            clientJoin.id,
            mainTokenToRefund,
            alterTokenToRefund
        );
    }


    function joinCustomBet(uint betId, CustomDTOs.JoinCustomRequest calldata joinRequest) public {
        require(customBets[betId].lockTime >= block.timestamp, "P2PCustomBetProvider: cancel - lock time");

        CustomDTOs.CustomBet storage bet = customBets[betId];

        // deposit amounts
        DepositedValue memory depositedValue = deposit(msg.sender, joinRequest.amount, joinRequest.useAlterFee);

        // Only mainAmount takes part in the custom bet
        uint mainAmount = depositedValue.mainAmount;
        uint feeAmount = depositedValue.feeAmount;

        CustomDTOs.JoinCustomBetClient memory joinBetClient = CustomDTOs.JoinCustomBetClient(
            0,
            msg.sender,
            mainAmount,
            0,
            joinRequest.useAlterFee,
            feeAmount,
            0,
            joinRequest.side
        );


        // Custom bet enrichment with matching
        (CustomDTOs.JoinCustomBetClient storage storedJoinBetClient, uint sidePointer) = joinCustomBet(bet, matchingInfo[betId], joinBetClient);

        // Add to client info
        CustomDTOs.JoinCustomBetClientList storage clientBetList = clientInfo[msg.sender][betId];
        clientBetList.joinListRefs[clientBetList.length] = CustomDTOs.JoinCustomBetClientRef(joinBetClient.targetSide, sidePointer);
        clientBetList.length++;

        emit CustomBetJoined(
            joinRequest.side,
            joinRequest.amount,
            joinRequest.useAlterFee,
            msg.sender,
            betId,
            storedJoinBetClient.id,
            clientBetList.length - 1
        );
    }

    event CustomBetCreated(
        uint id,
        string eventId,
        uint lockTime,
        uint expirationTime,
        string targetValue,
        bool targetSide,
        uint coefficient,
        address creator);

    event CustomBetJoined(
        bool side,
        uint mainAmount,
        bool useAlterFee,
        address client,
        uint betId,
        uint joinId,
        uint joinIdRef
    );

    event CustomBetCancelled(
        uint betId,
        uint joinId,
        uint mainTokenRefunded,
        uint alterTokenRefunded
    );

    event CustomBetClosed(
        uint betId,
        string finalValue,
        bool targetSideWon
    );

    event CustomBetRefunded(
        uint betId,
        address client,
        uint mainTokenRefunded,
        uint alterTokenRefunded
    );

    event CustomPrizeTaken(
        uint betId,
        address client,
        uint amount
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

    // Take company fee from main token company balance
    function takeFee(uint amount, address targetAddress, bool isAlternative) external onlyCompany {
        IERC20 token;
        if (isAlternative) {
            require(amount <= getCompanyAlternativeTokenBalance(), "CompanyVault: take fee amount exeeds alter token balance");
            token = getAlternativeIERC20Token();
        } else {
            require(amount <= getCompanyTokenBalance(), "CompanyVault: take fee amount exeeds token balance");
            token = getMainIERC20Token();
        }
        bool result = token.transfer(targetAddress, amount);
        decreaseFee(amount, isAlternative);
        require(result, "TokenProcessing: take fee transfer failed");
        emit FeeTaken(amount, targetAddress, isAlternative);
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;


library CustomDTOs {
    struct CustomBet {
        uint id;
        string eventId;
        uint lockTime;
        uint expirationTime;
        string targetValue;
        bool targetSide;
        uint coefficient;

        string finalValue;
        bool targetSideWon;

    }

    struct CustomMatchingInfo {
        // targetSide == true
        mapping(uint => JoinCustomBetClient) leftSide;
        uint leftLength;
        uint leftLastId;
        // targetSide == false
        mapping(uint => JoinCustomBetClient) rightSide;
        uint rightLength;
        uint rightLastId;
        uint leftFree;
        uint rightFree;
        uint leftLocked;
        uint rightLocked;
        uint lockedFee;
        uint lockedAlterFee;
    }

    struct JoinCustomBetClientList {
        mapping(uint => JoinCustomBetClientRef) joinListRefs;
        uint length;
    }

    struct JoinCustomBetClientRef {
        bool side;
        uint id;
    }

    struct JoinCustomBetClient {
        uint id;
        address client;
        uint freeAmount;
        uint lockedAmount;
        bool useAlterFee;
        uint feeAmount;
        uint feeLockedAmount;
        bool targetSide;
    }

    struct CreateCustomRequest {
        string eventId;
        uint lockTime;
        uint expirationTime;
        string targetValue;
        bool targetSide;
        uint coefficient;
    }

    struct JoinCustomRequest {
        bool side;
        uint amount;
        bool useAlterFee;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "./CustomDTOs.sol";

abstract contract CustomProcessor {
    // Refund main token and alter token(if pay alter fee)
    // Only after expiration + expirationDelay call without bet closed action
    function processRefundingCustomBet(CustomDTOs.CustomMatchingInfo storage info, CustomDTOs.JoinCustomBetClientList storage clientList) internal returns (uint, uint) {
        uint resultAmount;
        uint refundAlterFee;
        for (uint i = 0; i < clientList.length; ++i) {
            CustomDTOs.JoinCustomBetClient storage joinClient = extractCustomJoinBetClientByRef(info, clientList.joinListRefs[i]);
            resultAmount += joinClient.freeAmount;
            resultAmount += joinClient.lockedAmount;

            if (joinClient.useAlterFee) {
                refundAlterFee += joinClient.feeAmount;
                refundAlterFee += joinClient.feeLockedAmount;
            } else {
                resultAmount += joinClient.feeAmount;
                resultAmount += joinClient.feeLockedAmount;
            }

            joinClient.freeAmount = 0;
            joinClient.lockedAmount = 0;
            joinClient.feeAmount = 0;
            joinClient.feeLockedAmount = 0;
        }

        return (resultAmount, refundAlterFee);
    }

    // Evaluate mainToken for giving prize and modify joins
    // returns (mainToken amount)
    function takePrize(CustomDTOs.CustomBet storage bet, CustomDTOs.CustomMatchingInfo storage info, CustomDTOs.JoinCustomBetClientList storage clientList) internal returns (uint, uint) {
        uint resultAmount;
        uint refundAlterFee;
        for (uint i = 0; i < clientList.length; ++i) {
            CustomDTOs.JoinCustomBetClient storage joinClient = extractCustomJoinBetClientByRef(info, clientList.joinListRefs[i]);
            if (bet.targetSide && joinClient.targetSide) {
                // left side
                if (bet.targetSideWon) {
                    resultAmount += applyCoefficient(joinClient.lockedAmount, bet.coefficient, true);
                    joinClient.lockedAmount = 0;
                }
            } else {
                // right side
                if (!bet.targetSideWon) {
                    resultAmount += applyCoefficient(joinClient.lockedAmount, bet.coefficient, false);
                    joinClient.lockedAmount = 0;
                }
            }
            resultAmount += joinClient.freeAmount;

            if (joinClient.useAlterFee) {
                refundAlterFee += joinClient.feeAmount;
            } else {
                resultAmount += joinClient.feeAmount;
            }

            joinClient.freeAmount = 0;
            joinClient.feeAmount = 0;
        }

        return (resultAmount, refundAlterFee);
    }

    // Evaluate mainToken for giving prize
    // returns (mainToken amount)
    function evaluatePrize(CustomDTOs.CustomBet storage bet, CustomDTOs.CustomMatchingInfo storage info, CustomDTOs.JoinCustomBetClientList storage clientList) internal view returns (uint, uint) {
        uint resultAmount;
        uint refundAlterFee;
        for (uint i = 0; i < clientList.length; ++i) {
            CustomDTOs.JoinCustomBetClient storage joinClient = extractCustomJoinBetClientByRef(info, clientList.joinListRefs[i]);
            if (bet.targetSide && joinClient.targetSide) {
                // left side
                if (bet.targetSideWon) {
                    resultAmount += applyCoefficient(joinClient.lockedAmount, bet.coefficient, true);
                }
            } else {
                // right side
                if (!bet.targetSideWon) {
                    resultAmount += applyCoefficient(joinClient.lockedAmount, bet.coefficient, false);
                }
            }
            resultAmount += joinClient.freeAmount;
            if (joinClient.useAlterFee) {
                refundAlterFee += joinClient.feeAmount;
            } else {
                resultAmount += joinClient.feeAmount;
            }
        }

        return (resultAmount, refundAlterFee);
    }

    // Evaluate mainToken and alternativeToken for refunding
    // returns (mainToken amount, alternativeToken amount)
    function cancelCustomBet(CustomDTOs.CustomBet storage bet, CustomDTOs.CustomMatchingInfo storage info, CustomDTOs.JoinCustomBetClient storage joinClient) internal returns (uint, uint) {
        uint freeAmount = joinClient.freeAmount;
        uint freeFeeAmount = joinClient.feeAmount;
        if (bet.targetSide && joinClient.targetSide) {
            // left side
            info.leftFree -= freeAmount;
        } else {
            // right side
            info.rightFree -= freeAmount;
        }

        joinClient.freeAmount = 0;
        joinClient.feeAmount = 0;

        if (joinClient.useAlterFee) {
            // Return all free and feeAmount in alternative
            return (freeAmount, freeFeeAmount);
        } else {
            // Return all in main
            return (freeAmount + freeFeeAmount, 0);
        }
    }

    function joinCustomBet(CustomDTOs.CustomBet storage bet, CustomDTOs.CustomMatchingInfo storage info, CustomDTOs.JoinCustomBetClient memory joinCustomRequestBet) internal returns (CustomDTOs.JoinCustomBetClient storage, uint) {
        if (bet.targetSide && joinCustomRequestBet.targetSide) {
            // left side
            processLeft(info, joinCustomRequestBet, bet.coefficient);
            return (info.leftSide[info.leftLength - 1], info.leftLength - 1);
        } else {
            // right side
            processRight(info, joinCustomRequestBet, bet.coefficient);
            return (info.rightSide[info.rightLength - 1], info.rightLength - 1);
        }
    }

    function processLeft(CustomDTOs.CustomMatchingInfo storage info, CustomDTOs.JoinCustomBetClient memory joinRequest, uint coefficient) private {
        joinRequest.id = info.leftLength;
        info.leftSide[info.leftLength++] = joinRequest;
        CustomDTOs.JoinCustomBetClient storage joinRequestStored = info.leftSide[info.leftLength - 1];
        if (info.leftFree > 0) {
            // if there are free amounts
            // just add to the end of left bet queue
        } else {
            // recursion update with other side
            // update right last id
            info.rightLastId = mapToOtherSide(info.rightSide, info, info.rightLastId, joinRequestStored, coefficient, true);
        }

        info.leftFree += joinRequestStored.freeAmount;
        info.leftLocked += joinRequestStored.lockedAmount;

        info.rightFree -= applyPureCoefficientMapping(joinRequestStored.lockedAmount, coefficient, false);
        info.rightLocked += applyPureCoefficientMapping(joinRequestStored.lockedAmount, coefficient, false);
    }

    function processRight(CustomDTOs.CustomMatchingInfo storage info, CustomDTOs.JoinCustomBetClient memory joinRequest, uint coefficient) private {
        joinRequest.id = info.rightLength;
        info.rightSide[info.rightLength++] = joinRequest;
        CustomDTOs.JoinCustomBetClient storage joinRequestStored = info.rightSide[info.rightLength - 1];
        if (info.rightFree > 0) {
            // if there are free amounts
            // just add to the end of right bet queue
        } else {
            // recursion update with other side
            // update left last id
            info.leftLastId = mapToOtherSide(info.leftSide, info, info.leftLastId, joinRequestStored, coefficient, false);
            updateJoinClientFee(joinRequestStored, info);
        }

        info.rightFree += joinRequestStored.freeAmount;
        info.rightLocked += joinRequestStored.lockedAmount;

        info.leftFree -= applyPureCoefficientMapping(joinRequestStored.lockedAmount, coefficient, true);
        info.leftLocked += applyPureCoefficientMapping(joinRequestStored.lockedAmount, coefficient, true);
    }

    // Match joinRequest amount with otherSides values
    // recursion call(iteration by otherSide array)
    function mapToOtherSide(mapping(uint => CustomDTOs.JoinCustomBetClient) storage otherSide,
        CustomDTOs.CustomMatchingInfo storage info,
        uint otherLastId, CustomDTOs.JoinCustomBetClient storage joinRequest,
        uint coefficient, bool direct) private returns (uint) {

        // Found cancelled bet or fully bet
        if (otherSide[otherLastId].freeAmount == 0 && otherSide[otherLastId].lockedAmount != 0) {
            return mapToOtherSide(otherSide, info, otherLastId + 1, joinRequest, coefficient, direct);
        }

        // if freeAmount empty, end recursion call
        // end of array
        if (otherSide[otherLastId].freeAmount == 0) {
            return otherLastId;
        }

        uint freeAmountWithCoefficient = applyPureCoefficientMapping(joinRequest.freeAmount, coefficient, direct);

        // Other side fully locked current joinRequest
        // end of recursion
        if (otherSide[otherLastId].freeAmount >= freeAmountWithCoefficient) {
            otherSide[otherLastId].freeAmount -= freeAmountWithCoefficient;
            otherSide[otherLastId].lockedAmount += freeAmountWithCoefficient;
            updateJoinClientFee(otherSide[otherLastId], info);

            joinRequest.lockedAmount += joinRequest.freeAmount;
            joinRequest.freeAmount = 0;
            return otherLastId;
        }

        // Current joinRequest more than otherSide bet
        // Continue with next bet by other side recursive iteration
        uint otherFreeAmount = applyPureCoefficientMapping(otherSide[otherLastId].freeAmount, coefficient, !direct);

        joinRequest.lockedAmount += otherFreeAmount;
        joinRequest.freeAmount -= otherFreeAmount;

        otherSide[otherLastId].lockedAmount += otherSide[otherLastId].freeAmount;
        otherSide[otherLastId].freeAmount = 0;
        updateJoinClientFee(otherSide[otherLastId], info);
        // recursion call with next otherLastId
        return mapToOtherSide(otherSide, info, otherLastId + 1, joinRequest, coefficient, direct);
    }

    function extractCustomJoinBetClientByRef(CustomDTOs.CustomMatchingInfo storage info, CustomDTOs.JoinCustomBetClientRef storage ref) internal view returns (CustomDTOs.JoinCustomBetClient storage) {
        if (ref.side) {
            return info.leftSide[ref.id];
        } else {
            return info.rightSide[ref.id];
        }
    }

    uint private constant coefficientDecimals = 10 ** 9;

    function applyPureCoefficientMapping(uint amount, uint coefficient, bool direct) private pure returns (uint) {
        if (amount == 0) {
            return 0;
        }
        return applyCoefficient(amount, coefficient, direct) - amount;
    }

    function applyCoefficient(uint amount, uint coefficient, bool direct) private pure returns (uint) {
        if (amount == 0) {
            return 0;
        }

        if (direct) {
            return (amount * coefficient) / coefficientDecimals;
        } else {
            return (amount * ((coefficientDecimals ** 2) / (coefficient - coefficientDecimals) + coefficientDecimals)) / coefficientDecimals;
        }
    }

    function updateJoinClientFee(CustomDTOs.JoinCustomBetClient storage joinToUpdate, CustomDTOs.CustomMatchingInfo storage info) private {
        uint oldLockedFee = joinToUpdate.feeLockedAmount;
        uint totalFee = joinToUpdate.feeAmount + joinToUpdate.feeLockedAmount;

        if (totalFee == 0) {
            return;
        }

        uint newLockedFee;
        if (joinToUpdate.freeAmount == 0) {
            newLockedFee = totalFee;
        } else {
            newLockedFee = ((totalFee * joinToUpdate.lockedAmount * 10 ** 18) / (joinToUpdate.lockedAmount + joinToUpdate.freeAmount)) / 10 ** 18;
        }

        if (joinToUpdate.useAlterFee) {
            info.lockedAlterFee += (newLockedFee - oldLockedFee);
        } else {
            info.lockedFee += (newLockedFee - oldLockedFee);
        }
        joinToUpdate.feeLockedAmount = newLockedFee;
        joinToUpdate.feeAmount = totalFee - newLockedFee;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../utils/Context.sol";

abstract contract Ownable is Context {
    address private _company;
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event CompanyTransferred(address indexed previousCompany, address indexed newCompany);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Security: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Security: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
    function transferCompany(address newCompany) public virtual onlyOwner {
        require(newCompany != address(0), "Security: new company is the zero address");
        emit CompanyTransferred(_company, newCompany);
        _company = newCompany;
    }

}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../security/Ownable.sol";
import "../utils/IERC20.sol";

abstract contract CompanyVault is Ownable {
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

import "../security/Ownable.sol";
import "../utils/IPancakeRouter01.sol";

abstract contract AlternativeTokenHelper is Ownable {
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

import "../security/Ownable.sol";

abstract contract FeeConfiguration is Ownable{
    //DECIMALS 6 for 100%
    uint private _companyFee;
    //DECIMALS 6 for 100%
    uint private _alternativeFee;

    event CompanyFeeChanged(uint previousCompanyFee, uint newCompanyFee);
    event CompanyTransferred(uint previousAlternativeFee, uint newAlternativeFee);

    // Set company fee for all bets with main token fee
    function setCompanyFee(uint companyFee) external onlyOwner {
        require(companyFee <= 10**6);
        emit CompanyFeeChanged(_companyFee, companyFee);
        _companyFee = companyFee;
    }

    // Set company fee for all bets with alternative token fee
    function setAlternativeFeeFee(uint alternativeFee) external onlyOwner {
        require(alternativeFee <= 10**6);
        emit CompanyTransferred(_alternativeFee, alternativeFee);
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

interface IPancakeRouter01 {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}