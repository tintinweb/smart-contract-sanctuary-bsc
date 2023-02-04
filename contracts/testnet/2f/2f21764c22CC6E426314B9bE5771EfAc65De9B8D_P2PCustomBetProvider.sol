// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../../processing/TokenProcessing.sol";
import "./CustomProcessor.sol";

contract P2PCustomBetProvider is TokenProcessing, CustomProcessor {
    mapping(uint => CustomDTOs.CustomBet) private customBets;
    mapping(uint => CustomDTOs.CustomMatchingInfo) private matchingInfo;
    mapping(address => mapping(uint => CustomDTOs.JoinCustomBetClientList)) private clientInfo;
    mapping(address => uint[]) private clientBets;
    mapping(address => uint) public clientBetsLength;
    uint public customBetIdCounter;

    constructor(address mainToken, address alternativeToken) TokenProcessing(mainToken, alternativeToken) {}

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

    function closeCustomBet(uint betId, string calldata finalValue, bool targetSideWon) external onlyCompany {
        require(keccak256(abi.encodePacked(finalValue)) != keccak256(abi.encodePacked("")), "P2PCustomBetProvider: close error - custom bet can't be closed with empty value");
        CustomDTOs.CustomBet storage customBet = customBets[betId];
        require(customBet.expirationTime < block.timestamp, "P2PCustomBetProvider: close error - expiration error");
        require(customBet.expirationTime + getTimestampExpirationDelay() > block.timestamp, "P2PCustomBetProvider: close error - expiration error with delay");
        require(keccak256(abi.encodePacked(customBet.finalValue)) == keccak256(abi.encodePacked("")), "P2PCustomBetProvider: close error - bet already closed");

        customBet.finalValue = finalValue;
        customBet.targetSideWon = targetSideWon;

        CustomDTOs.CustomMatchingInfo storage info = matchingInfo[betId];

        emit CustomBetClosed(
            betId,
            finalValue,
            targetSideWon
        );
    }

    function refundCustomBet(uint betId, address client) external {
        CustomDTOs.CustomBet storage customBet = customBets[betId];
        require(keccak256(abi.encodePacked(customBet.finalValue)) == keccak256(abi.encodePacked("")), "P2PCustomBetProvider: refund - custom haven't to be open");
        require(customBet.expirationTime + getTimestampExpirationDelay() < block.timestamp, "P2PCustomBetProvider: refund - expiration error");

        uint mainTokenToRefund = processRefundingCustomBet(matchingInfo[betId], clientInfo[client][betId]);
        require(mainTokenToRefund > 0, "P2PCustomBetProvider: refund - nothing");
        withdrawalMainToken(client, mainTokenToRefund);

        emit CustomBetRefunded(
            betId,
            client,
            mainTokenToRefund
        );
    }

    function takeCustomPrize(uint betId, address client, bool useAlterFee) external {
        CustomDTOs.CustomBet storage customBet = customBets[betId];
        require(keccak256(abi.encodePacked(customBet.finalValue)) != keccak256(abi.encodePacked("")), "P2PCustomBetProvider: take prize - custom bet wasn't closed");

        uint wonAmount = takePrize(customBet, matchingInfo[betId], clientInfo[client][betId]);

        require(wonAmount > 0, "P2PCustomBetProvider: take prize - nothing");

        uint wonAmountAfterFee = takeFeeFromAmount(msg.sender, wonAmount, useAlterFee);

        withdrawalMainToken(client, wonAmountAfterFee);

        emit CustomPrizeTaken(
            betId,
            client,
            wonAmountAfterFee,
            useAlterFee
        );
    }

    function getCustomWonAmount(uint betId, address client) public view returns (uint) {
        CustomDTOs.CustomBet storage customBet = customBets[betId];
        if (keccak256(abi.encodePacked(customBet.targetValue)) == keccak256(abi.encodePacked(""))) {
            return 0;
        }
        return evaluatePrize(customBet, matchingInfo[betId], clientInfo[client][betId]);
    }

    function createCustomBet(CustomDTOs.CreateCustomRequest calldata createRequest, CustomDTOs.JoinCustomRequest calldata joinRequest) external returns (uint) {
        // lock - 60 * 5
        // expiration - 60 * 5
        require(createRequest.lockTime >= block.timestamp + 60 * 3, "P2PCustomBetProvider: create - lock time test");
        require(createRequest.expirationTime >= createRequest.lockTime + 60 * 3, "P2PCustomBetProvider: create - expirationTime time");

        uint betId = customBetIdCounter++;
        customBets[betId] = CustomDTOs.CustomBet(
            betId,
            createRequest.eventId,
            createRequest.hidden,
            createRequest.lockTime,
            createRequest.expirationTime,
            createRequest.targetValue,
            createRequest.targetSide,
            createRequest.coefficient,
            "",
            false
        );

        emit CustomBetCreated(
            betId,
            createRequest.eventId,
            createRequest.hidden,
            createRequest.lockTime,
            createRequest.expirationTime,
            createRequest.targetValue,
            createRequest.targetSide,
            createRequest.coefficient,
            msg.sender
        );

        joinCustomBet(betId, joinRequest);

        return betId;
    }

    function cancelCustomJoin(uint betId, uint joinIdRef) external {
        CustomDTOs.JoinCustomBetClient storage clientJoin = extractCustomJoinBetClientByRef(matchingInfo[betId], clientInfo[msg.sender][betId].joinListRefs[joinIdRef]);

        require(clientJoin.freeAmount != 0, "P2PCustomBetProvider: cancel - free amount empty");
        require(customBets[betId].lockTime >= block.timestamp, "P2PCustomBetProvider: cancel - lock time");

        uint mainTokenToRefund = cancelCustomBet(matchingInfo[betId], clientJoin);
        withdrawalMainToken(msg.sender, mainTokenToRefund);

        emit CustomBetCancelled(
            betId,
            msg.sender,
            joinIdRef,
            mainTokenToRefund
        );
    }


    function joinCustomBet(uint betId, CustomDTOs.JoinCustomRequest calldata joinRequest) public {
        require(customBets[betId].lockTime >= block.timestamp, "P2PCustomBetProvider: cancel - lock time");
        clientBets[msg.sender].push(betId);
        clientBetsLength[msg.sender]++;

        CustomDTOs.CustomBet storage bet = customBets[betId];
        CustomDTOs.JoinCustomBetClientList storage clientBetList = clientInfo[msg.sender][betId];

        // deposit amounts
        DepositedValue memory depositedValue = deposit(msg.sender, joinRequest.amount);

        // Only mainAmount takes part in the custom bet
        CustomDTOs.JoinCustomBetClient memory joinBetClient = CustomDTOs.JoinCustomBetClient(
            0,
            msg.sender,
            depositedValue.mainAmount,
            0,
            joinRequest.side,
            clientBetList.length
        );

        // Custom bet enrichment with matching
        (CustomDTOs.JoinCustomBetClient storage storedJoinBetClient, uint sidePointer) = joinCustomBet(bet, matchingInfo[betId], joinBetClient);

        // Add to client info
        clientBetList.joinListRefs[clientBetList.length++] = CustomDTOs.JoinCustomBetClientRef(joinBetClient.targetSide, sidePointer);

        emit CustomBetJoined(
            joinRequest.side,
            joinRequest.amount,
            msg.sender,
            betId,
            storedJoinBetClient.id,
            clientBetList.length - 1
        );
    }

    event CustomBetCreated(
        uint id,
        string eventId,
        bool hidden,
        uint lockTime,
        uint expirationTime,
        string targetValue,
        bool targetSide,
        uint coefficient,
        address indexed creator
    );

    event CustomBetJoined(
        bool side,
        uint mainAmount,
        address indexed client,
        uint betId,
        uint joinId,
        uint joinIdRef
    );

    event CustomBetCancelled(
        uint betId,
        address indexed client,
        uint joinIdRef,
        uint mainTokenRefunded
    );

    event CustomBetClosed(
        uint betId,
        string finalValue,
        bool targetSideWon
    );

    event CustomBetRefunded(
        uint betId,
        address indexed client,
        uint mainTokenRefunded
    );

    event CustomPrizeTaken(
        uint betId,
        address indexed client,
        uint amount,
        bool useAlterFee
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
    }

    constructor(address mainToken, address alternativeToken) CompanyVault(mainToken, alternativeToken) {}

    // Deposit amount from sender
    function deposit(address sender, uint amount) internal returns (DepositedValue memory) {
        depositToken(getMainIERC20Token(), sender, amount);
        return DepositedValue(amount);
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

    // Evaluate fee from amount and take it. Return the rest of it.
    function takeFeeFromAmount(address winner, uint amount, bool useAlternativeFee) internal returns (uint) {
        if (useAlternativeFee) {
            uint alternativeFeePart = applyAlternativeFee(amount);
            depositToken(getAlternativeIERC20Token(), winner, alternativeFeePart);
            increaseFee(alternativeFeePart, true);
            return amount;
        } else {
            uint feePart = applyCompanyFee(amount);
            increaseFee(feePart, false);
            return amount - feePart;
        }
    }


    // Deposit amount of tokens from sender to this contract
    function depositToken(IERC20 token, address sender, uint amount) internal {
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

import "./CustomDTOs.sol";

abstract contract CustomProcessor {
    // Refund main token and alter token(if pay alter fee)
    // Only after expiration + expirationDelay call without bet closed action
    function processRefundingCustomBet(CustomDTOs.CustomMatchingInfo storage info, CustomDTOs.JoinCustomBetClientList storage clientList) internal returns (uint) {
        uint resultAmount;
        uint refundAlterFee;
        for (uint i = 0; i < clientList.length; ++i) {
            CustomDTOs.JoinCustomBetClient storage joinClient = extractCustomJoinBetClientByRef(info, clientList.joinListRefs[i]);
            resultAmount += joinClient.freeAmount;
            resultAmount += joinClient.lockedAmount;

            joinClient.freeAmount = 0;
            joinClient.lockedAmount = 0;
        }

        return resultAmount;
    }

    // Evaluate mainToken for giving prize and modify joins
    // returns (mainToken amount)
    function takePrize(CustomDTOs.CustomBet storage bet, CustomDTOs.CustomMatchingInfo storage info, CustomDTOs.JoinCustomBetClientList storage clientList) internal returns (uint) {
        uint resultAmount;
        for (uint i = 0; i < clientList.length; ++i) {
            CustomDTOs.JoinCustomBetClient storage joinClient = extractCustomJoinBetClientByRef(info, clientList.joinListRefs[i]);
            if (joinClient.targetSide) {
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

            joinClient.freeAmount = 0;
        }

        return resultAmount;
    }

    // Evaluate mainToken for giving prize
    // returns (mainToken amount)
    function evaluatePrize(CustomDTOs.CustomBet storage bet, CustomDTOs.CustomMatchingInfo storage info, CustomDTOs.JoinCustomBetClientList storage clientList) internal view returns (uint) {
        uint resultAmount;
        for (uint i = 0; i < clientList.length; ++i) {
            CustomDTOs.JoinCustomBetClient storage joinClient = extractCustomJoinBetClientByRef(info, clientList.joinListRefs[i]);
            if (joinClient.targetSide) {
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
        }

        return resultAmount;
    }

    // Evaluate mainToken and alternativeToken for refunding
    // returns (mainToken amount, alternativeToken amount)
    function cancelCustomBet(CustomDTOs.CustomMatchingInfo storage info, CustomDTOs.JoinCustomBetClient storage joinClient) internal returns (uint) {
        uint freeAmount = joinClient.freeAmount;
        if (joinClient.targetSide) {
            // left side
            info.leftFree -= freeAmount;
        } else {
            // right side
            info.rightFree -= freeAmount;
        }

        joinClient.freeAmount = 0;

        return freeAmount;
    }

    function joinCustomBet(CustomDTOs.CustomBet storage bet, CustomDTOs.CustomMatchingInfo storage info, CustomDTOs.JoinCustomBetClient memory joinCustomRequestBet) internal returns (CustomDTOs.JoinCustomBetClient storage, uint) {
        // not xor
        if (joinCustomRequestBet.targetSide) {
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

        info.rightFree -= applyPureCoefficientMapping(joinRequestStored.lockedAmount, coefficient, true);
        info.rightLocked += applyPureCoefficientMapping(joinRequestStored.lockedAmount, coefficient, true);
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
        }

        info.rightFree += joinRequestStored.freeAmount;
        info.rightLocked += joinRequestStored.lockedAmount;

        info.leftFree -= applyPureCoefficientMapping(joinRequestStored.lockedAmount, coefficient, false);
        info.leftLocked += applyPureCoefficientMapping(joinRequestStored.lockedAmount, coefficient, false);
    }

    // Match joinRequest amount with otherSides values
    // recursion call(iteration by otherSide array)
    function mapToOtherSide(mapping(uint => CustomDTOs.JoinCustomBetClient) storage otherSide,
        CustomDTOs.CustomMatchingInfo storage info,
        uint otherLastId, CustomDTOs.JoinCustomBetClient storage joinRequest,
        uint coefficient, bool direct) private returns (uint) {

        // End of other side
        if (otherSide[otherLastId].client == address(0)) {
            return otherLastId;
        }

        // Found cancelled bet or fully bet
        if (otherSide[otherLastId].freeAmount == 0) {
            return mapToOtherSide(otherSide, info, otherLastId + 1, joinRequest, coefficient, direct);
        }

        uint freeAmountWithCoefficient = applyPureCoefficientMapping(joinRequest.freeAmount, coefficient, direct);

        // Other side fully locked current joinRequest
        // end of recursion
        if (otherSide[otherLastId].freeAmount >= freeAmountWithCoefficient) {
            otherSide[otherLastId].freeAmount -= freeAmountWithCoefficient;
            otherSide[otherLastId].lockedAmount += freeAmountWithCoefficient;

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

    function setRouter(address router) onlyOwner external {
        _IUniswapV2Router01 = IPancakeRouter01(router);
    }

    function evaluateAlternativeAmount(uint mainAmount, address mainToken, address alternativeToken) internal view returns (uint) {
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

abstract contract FeeConfiguration is Security {
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

// solhint-disable-next-line
pragma solidity ^0.8.15;


library CustomDTOs {
    struct CustomBet {
        uint id;
        string eventId;
        bool hidden;
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
        bool targetSide;
        uint joinRefId;
    }

    struct CreateCustomRequest {
        string eventId;
        bool hidden;
        uint lockTime;
        uint expirationTime;
        string targetValue;
        bool targetSide;
        uint coefficient;
    }

    struct JoinCustomRequest {
        bool side;
        uint amount;
    }
}