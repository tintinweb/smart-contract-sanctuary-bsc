// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../../processing/TokenProcessing.sol";
import "./CustomDTOs.sol";
import "./CustomProcessor.sol";

contract P2PCustomBetProvider is TokenProcessing, CustomDTOs, CustomProcessor {
    mapping(uint => CustomBet) private customBets;
    mapping(uint => CustomMatchingInfo) private matchingInfo;
    mapping(address => mapping(uint => JoinCustomBetClientList)) private clientInfo;
    uint private customBetIdCounter;

    // 2hrs
    uint constant timestampExpirationDelay = 2 * 60 * 60;

    constructor(address mainToken) TokenProcessing(mainToken) {}

    function closeCustomBet(uint betId, string calldata finalValue, bool targetSideWon) external onlyCompany {
        require(keccak256(abi.encodePacked(finalValue)) != keccak256(abi.encodePacked("")), "CustomBetProvider: close error - custom bet can't be closed with empty value");
        CustomBet storage customBet = customBets[betId];
        //require(customBet.expirationTime + timestampExpirationDelay < block.timestamp, "CustomBetProvider: close error - expiration error");

        customBet.finalValue = finalValue;
        customBet.targetSideWon = targetSideWon;

        emit CustomBetClosed(
            betId,
            finalValue,
            targetSideWon
        );
    }

    function takeCustomPrize(uint betId, address client) public {
        CustomBet storage customBet = customBets[betId];
        require(keccak256(abi.encodePacked(customBet.targetValue)) != keccak256(abi.encodePacked("")), "CustomBetProvider: take prize - custom bet wasn't closed");

        (uint wonAmount, uint refundAlterToken) = takePrize(customBet, matchingInfo[betId], clientInfo[client][betId]);

        require(wonAmount > 0, "CustomBetProvider: take prize - nothing");

        withdrawalMainToken(client, wonAmount);

        if (refundAlterToken > 0) {
            withdrawalAlternativeToken(client, refundAlterToken);
        }

        CustomMatchingInfo storage info = matchingInfo[betId];
        if (info.lockedFee > 0) {
            increaseFee(info.lockedFee);
            info.lockedFee = 0;
        }
        if (info.lockedAlterFee > 0) {
            increaseAlterFee(info.lockedAlterFee);
            info.lockedAlterFee = 0;
        }

        emit CustomPrizeTaken(
            betId,
            client,
            wonAmount
        );
    }

    function getCustomWonAmount(uint betId, address client) public view returns (uint) {
        CustomBet storage customBet = customBets[betId];
        if (keccak256(abi.encodePacked(customBet.targetValue)) == keccak256(abi.encodePacked(""))) {
            return 0;
        }

        (uint wonAmount, uint refundAlterToken) = evaluatePrize(customBet, matchingInfo[betId], clientInfo[client][betId]);
        return wonAmount;
    }

    function createCustomBet(CreateCustomRequest calldata createRequest, JoinCustomRequest calldata joinRequest) external returns (uint) {
        // lock - 60 * 5
        // expiration - 60 * 5
        require(createRequest.lockTime >= block.timestamp + 3, "CustomBetProvider: create - lock time");
        require(createRequest.expirationTime >= createRequest.lockTime + 2, "CustomBetProvider: create - expirationTime time");

        uint betId = customBetIdCounter++;
        customBets[betId] = CustomBet(
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

    function getCustomBet(uint betId) external view returns (CustomBet memory, uint, uint, uint, uint) {
        CustomMatchingInfo storage info = matchingInfo[betId];
        return (customBets[betId], info.leftFree, info.leftLocked, info.rightFree, info.rightLocked);
    }

    function getCustomClientJoins(address client, uint betId) external view returns (JoinCustomBetClient[] memory) {
        JoinCustomBetClient[] memory clientList = new JoinCustomBetClient[](clientInfo[client][betId].length);
        for (uint i = 0; i < clientInfo[client][betId].length; i++) {
            clientList[i] = extractCustomJoinBetClientByRef(matchingInfo[betId], clientInfo[client][betId].joinListRefs[i]);
        }
        return clientList;
    }

    function cancelCustomJoin(uint betId, uint joinId) external {
        JoinCustomBetClient storage clientJoin = extractCustomJoinBetClientByRef(matchingInfo[betId], clientInfo[msg.sender][betId].joinListRefs[joinId]);

        require(clientJoin.freeAmount != 0, "CustomBetProvider: cancel - free amount empty");
        require(customBets[betId].lockTime >= block.timestamp, "CustomBetProvider: cancel - lock time");

        (uint mainTokenToRefund, uint alterTokenToRefund) = cancelCustomBet(customBets[betId], matchingInfo[betId], clientJoin);

        if (mainTokenToRefund > 0) {
            withdrawalMainToken(msg.sender, mainTokenToRefund);
        }

        if (alterTokenToRefund > 0) {
            withdrawalAlternativeToken(msg.sender, mainTokenToRefund);
        }

        emit CustomBetCancelled(
            betId,
            joinId,
            mainTokenToRefund,
            alterTokenToRefund
        );
    }


    function joinCustomBet(uint betId, JoinCustomRequest calldata joinRequest) public {
        require(customBets[betId].lockTime >= block.timestamp, "CustomBetProvider: cancel - lock time");

        CustomBet storage bet = customBets[betId];

        // deposit amounts
        DepositedValue memory depositedValue = deposit(msg.sender, joinRequest.amount, joinRequest.useAlterFee);

        // Only mainAmount takes part in the custom bet
        uint mainAmount;
        uint feeAmount;
        if (joinRequest.useAlterFee) {
            mainAmount = depositedValue.mainValue;
            feeAmount = depositedValue.alternativeValue;
        } else {
            feeAmount = applyCompanyFee(depositedValue.mainValue);
            mainAmount = depositedValue.mainValue - feeAmount;
        }

        uint joinId = clientInfo[msg.sender][betId].length;
        JoinCustomBetClient memory joinBetClient = JoinCustomBetClient(
            joinId,
            msg.sender,
            mainAmount,
            0,
            joinRequest.useAlterFee,
            feeAmount,
            0,
            joinRequest.side
        );


        // Custom bet enrichment with matching
        (JoinCustomBetClient storage storedJoinBetClient, uint sidePointer) = joinCustomBet(bet, matchingInfo[betId], joinBetClient);

        // Add to client info
        JoinCustomBetClientList storage clientBetList = clientInfo[msg.sender][betId];
        clientBetList.joinListRefs[storedJoinBetClient.id] = JoinCustomBetClientRef(joinBetClient.targetSide, sidePointer);
        clientInfo[msg.sender][betId].length++;

        emit CustomBetJoined(
            joinRequest.side,
            joinRequest.amount,
            joinRequest.useAlterFee,
            msg.sender,
            betId,
            storedJoinBetClient.id
        );
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../security/Ownable.sol";
import "./CompanyVault.sol";
import "./AlternativeTokenHelper.sol";
import "./FeeConfiguration.sol";

abstract contract TokenProcessing is CompanyVault, AlternativeTokenHelper, FeeConfiguration {
    event FeeTaken(uint amount, address indexed targetAddress);

    struct DepositedValue {
        uint mainValue;
        uint alternativeValue;
    }

    constructor(address mainToken) CompanyVault(mainToken) {}

    // Deposit amount from sender with alternative token for fee or not
    function deposit(address sender, uint amount, bool useAlternative) internal returns (DepositedValue memory) {
        if (useAlternative) {
            require(isAlternativeTokenEnabled(), "TokenProcessing: alternative token disabled");
            return depositWithAlternative(sender, amount);
        } else {
            depositToken(getMainIERC20Token(), sender, amount);
            return DepositedValue(amount, 0);
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
        uint mainPart = amount - alternativePart;

        depositToken(getMainIERC20Token(), sender, mainPart);

        uint alternativePartInAlternativeToken = evaluateAlternativeAmount(alternativePart, getMainToken(), getAlternativeToken());

        depositToken(getAlternativeIERC20Token(), sender, alternativePartInAlternativeToken);

        return DepositedValue(mainPart, alternativePartInAlternativeToken);
    }


    // Deposit amount of tokens from sender to this contract
    function depositToken(IERC20 token, address sender, uint amount) private {
        require(token.allowance(sender, address(this)) >= amount, "TokenProcessing: depositMainToken, not enough funds to deposit token");

        bool result = token.transferFrom(sender, address(this), amount);
        require(result, "TokenProcessing: depositMainToken, transfer from failed");
    }
     
    // Take company fee from main token company balance
    function takeFee(uint amount, address targetAddress) external onlyCompany {
        require(amount <= getCompanyTokenBalance(), "CompanyVault: take fee amount exeeds token balance");
        bool result = getMainIERC20Token().transfer(targetAddress, amount);
        decreaseFee(amount);
        require(result, "TokenProcessing: take fee transfer failed");
        emit FeeTaken(amount, targetAddress);
    }

    // Take any numbers of any tokens except main token
    // (in the most cases for taking alternative fee)
    function takeNotTokenAmount(uint amount, address tokenAddress, address targetAddress) external onlyOwner {
        require(tokenAddress != getMainToken(), "CompanyVault: tokenAddress shouldn't match main token");

        IERC20 otherToken = IERC20(tokenAddress);
        require(otherToken.balanceOf(address(this)) >= amount, "CompanyVault: amount exeeds tokenAddress balance");

        bool result = otherToken.transfer(targetAddress, amount);
        require(result, "TokenProcessing: takeNotTokenAmount transfer failed");

        emit OtherTokensTaken(amount, tokenAddress, targetAddress);
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;


abstract contract CustomDTOs {
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
        uint joinId
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

    event CustomPrizeTaken(
        uint betId,
        address client,
        uint amount
    );

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

abstract contract CustomProcessor is CustomDTOs {
    // Evaluate mainToken for giving prize and modify joins
    // returns (mainToken amount)
    function takePrize(CustomBet storage bet, CustomMatchingInfo storage info, JoinCustomBetClientList storage clientList) internal returns (uint, uint) {
        uint resultAmount;
        uint refundAlterFee;
        for (uint i = 0; i < clientList.length; ++i) {
            JoinCustomBetClient storage joinClient = extractCustomJoinBetClientByRef(info, clientList.joinListRefs[i]);
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
    function evaluatePrize(CustomBet storage bet, CustomMatchingInfo storage info, JoinCustomBetClientList storage clientList) internal view returns (uint, uint) {
        uint resultAmount;
        uint refundAlterFee;
        for (uint i = 0; i < clientList.length; ++i) {
            JoinCustomBetClient storage joinClient = extractCustomJoinBetClientByRef(info, clientList.joinListRefs[i]);
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
    function cancelCustomBet(CustomBet storage bet, CustomMatchingInfo storage info, JoinCustomBetClient storage joinClient) internal returns (uint, uint) {
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

    function joinCustomBet(CustomBet storage bet, CustomMatchingInfo storage info, JoinCustomBetClient memory joinRequest) internal returns (JoinCustomBetClient storage, uint) {
        if (bet.targetSide && joinRequest.targetSide) {
            // left side
            processLeft(info, joinRequest, bet.coefficient);
            return (info.leftSide[info.leftLength - 1], info.leftLength - 1);
        } else {
            // right side
            processRight(info, joinRequest, bet.coefficient);
            return (info.rightSide[info.rightLength - 1], info.rightLength - 1);
        }
    }

    function processLeft(CustomMatchingInfo storage info, JoinCustomBetClient memory joinRequest, uint coefficient) private {
        info.leftSide[info.leftLength++] = joinRequest;
        JoinCustomBetClient storage joinRequestStored = info.leftSide[info.leftLength - 1];
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

    function processRight(CustomMatchingInfo storage info, JoinCustomBetClient memory joinRequest, uint coefficient) private {
        info.rightSide[info.rightLength++] = joinRequest;
        JoinCustomBetClient storage joinRequestStored = info.rightSide[info.rightLength - 1];
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
    function mapToOtherSide(mapping(uint => JoinCustomBetClient) storage otherSide,
        CustomMatchingInfo storage info,
        uint otherLastId, JoinCustomBetClient storage joinRequest,
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

    function extractCustomJoinBetClientByRef(CustomMatchingInfo storage info, JoinCustomBetClientRef storage ref) internal view returns (JoinCustomBetClient storage) {
        if (ref.side) {
            return info.leftSide[ref.id];
        } else {
            return info.rightSide[ref.id];
        }
    }

    uint private constant coefficientDecimals = 10**9;

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
            return (amount * ((coefficientDecimals**2) / (coefficient - coefficientDecimals) + coefficientDecimals))  / coefficientDecimals;
        }
    }

    function updateJoinClientFee(JoinCustomBetClient storage joinToUpdate, CustomMatchingInfo storage info) private {
        uint oldLockedFee = joinToUpdate.feeLockedAmount;
        uint totalFee = joinToUpdate.feeAmount + joinToUpdate.feeLockedAmount;

        if (totalFee == 0) {
            return;
        }

        uint newLockedFee;
        if (joinToUpdate.freeAmount == 0) {
            newLockedFee = totalFee;
        } else {
            newLockedFee = ((totalFee * joinToUpdate.lockedAmount * 10**18) / (joinToUpdate.lockedAmount + joinToUpdate.freeAmount)) / 10**18;
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

abstract contract CompanyVault is Ownable{
    address private _token;
    IERC20 internal _IERC20token;
    address private _alternativeToken;
    IERC20 internal _AlternativeIERC20token;
    uint private _companyTokenBalance;
    uint private _companyAlternativeTokenBalance;
    bool private _alternativeTokenEnabled;

    event AlternativeTokenChanged(address indexed previousAlternativeToken, address indexed newAlternativeToken);
    event OtherTokensTaken(uint amount, address indexed tokenAddress, address indexed targetAddress);
    
    constructor (address mainToken) {
        _token = mainToken;
        _IERC20token = IERC20(mainToken);
    }

    // Get main token
    function getMainToken() public view returns (address) {
        return _token;
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
        return _alternativeToken;
    }

    // Get main IERC20 interface
    function getMainIERC20Token() internal view returns(IERC20) {
        return _IERC20token;
    }

    // Get alternative IERC20 interface
    function getAlternativeIERC20Token() internal view returns(IERC20) {
        return _AlternativeIERC20token;
    }

    // Get main token company balance from fees
    function getCompanyTokenBalance() public view returns (uint) {
        return _companyTokenBalance;
    }

    // Increase main token fee. Calls only from finished bets.
    function increaseFee(uint amount) internal {
        _companyTokenBalance += amount;
    }

    // Decrease main token fee. Calls only from take fee.
    function decreaseFee(uint amount) internal {
        _companyTokenBalance -= amount;
    }

    // Increase alternative token fee. Calls only from finished bets.
    function increaseAlterFee(uint amount) internal {
        _companyAlternativeTokenBalance += amount;
    }

    // Decrease alternative token fee. Calls only from take fee.
    function decreaseAlterFee(uint amount) internal {
        _companyAlternativeTokenBalance -= amount;
    }

    // Set alternative token to pay alternative fee
    function setAlternativeToken(address alternativeToken) external onlyOwner {
        require(alternativeToken != _token, "CompanyVault: alternativeToken shouldn't match main token");
        emit AlternativeTokenChanged(_alternativeToken, alternativeToken);
        _alternativeToken = alternativeToken;
        _AlternativeIERC20token = IERC20(_alternativeToken);
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../security/Ownable.sol";
import "../utils/IUniswapV2Router01.sol";

abstract contract AlternativeTokenHelper is Ownable {
    IUniswapV2Router01 internal _IUniswapV2Router01;

    function setRouter(address router) external {
        _IUniswapV2Router01 = IUniswapV2Router01(router);
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

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}