// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

import "../../processing/TokenProcessing.sol";
import "./BinaryDTOs.sol";
import "./BinaryProcessor.sol";

contract P2PBinaryBetProvider is TokenProcessing, BinaryProcessor {
    mapping(uint => BinaryDTOs.BinaryBet) private binaryBets;
    mapping(uint => BinaryDTOs.BinaryMatchingInfo) private matchingInfo;
    mapping(address => mapping(uint => BinaryDTOs.JoinBinaryBetClientList)) private clientInfo;
    mapping(address => uint[]) private clientBets;
    mapping(address => uint) public clientBetsLength;
    uint public binaryBetIdCounter;

    constructor(address mainToken, address[] memory owners) TokenProcessing(mainToken) {
        for (uint i = 0; i < owners.length; i++) {
            addOwner(owners[i]);
        }
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

    function getBinaryBet(uint betId) external view returns (BinaryDTOs.BinaryBet memory, uint, uint) {
        BinaryDTOs.BinaryMatchingInfo storage info = matchingInfo[betId];
        return (binaryBets[betId], info.leftAmount, info.rightAmount);
    }

    function getBinaryClientJoins(address client, uint betId) external view returns (BinaryDTOs.JoinBinaryBetClient[] memory) {
        BinaryDTOs.JoinBinaryBetClient[] memory clientList = new BinaryDTOs.JoinBinaryBetClient[](clientInfo[client][betId].length);
        for (uint i = 0; i < clientInfo[client][betId].length; i++) {
            clientList[i] = extractJoinBinaryBetClientByRef(matchingInfo[betId], clientInfo[client][betId].joinListRefs[i]);
        }
        return clientList;
    }

    function refundBinaryBet(uint betId, address client) public {
        BinaryDTOs.BinaryBet storage binaryBet = binaryBets[betId];
        require(keccak256(abi.encodePacked(binaryBet.finalValue)) == keccak256(abi.encodePacked("")), "P2PBinaryBetProvider: refund - binary haven't to be open");
        require(keccak256(abi.encodePacked(binaryBet.lockedValue)) == keccak256(abi.encodePacked("")), "P2PBinaryBetProvider: refund - binary haven't to be open");
        require(binaryBet.expirationTime + getTimestampExpirationDelay() < block.timestamp, "P2PBinaryBetProvider: refund - expiration error");

        uint mainTokenToRefund = processRefundingBinaryBet(matchingInfo[betId], clientInfo[client][betId]);
        require(mainTokenToRefund > 0, "P2PBinaryBetProvider: refund - nothing");
        withdrawalMainToken(client, mainTokenToRefund);

        emit BinaryBetRefunded(
            betId,
            client,
            mainTokenToRefund
        );
    }

    function takeBinaryPrize(uint betId, address client, bool useAlterFee) public {
        BinaryDTOs.BinaryBet storage binaryBet = binaryBets[betId];
        require(keccak256(abi.encodePacked(binaryBet.finalValue)) != keccak256(abi.encodePacked("")), "P2PBinaryBetProvider: take prize - binary bet wasn't closed");
        require(keccak256(abi.encodePacked(binaryBet.lockedValue)) != keccak256(abi.encodePacked("")), "P2PBinaryBetProvider: take prize - binary bet wasn't closed");

        uint wonAmount = takePrize(binaryBet, matchingInfo[betId], clientInfo[client][betId]);

        require(wonAmount > 0, "P2PBinaryBetProvider: take prize - nothing");

        uint wonAmountAfterFee = takeFeeFromAmount(msg.sender, wonAmount, useAlterFee);

        withdrawalMainToken(client, wonAmountAfterFee);

        emit BinaryPrizeTaken(
            betId,
            client,
            wonAmountAfterFee,
            useAlterFee
        );
    }

    function getBinaryWonAmount(uint betId, address client) public view returns (uint) {
        BinaryDTOs.BinaryBet storage binaryBet = binaryBets[betId];
        if (keccak256(abi.encodePacked(binaryBet.finalValue)) == keccak256(abi.encodePacked(""))) {
            return 0;
        }

        return evaluatePrize(binaryBet, matchingInfo[betId], clientInfo[client][betId]);
    }

    function closeBinaryBet(uint betId, string calldata lockedValue, string calldata finalValue, bool sideWon) external onlyCompany {
        require(keccak256(abi.encodePacked(finalValue)) != keccak256(abi.encodePacked("")), "P2PBinaryBetProvider: close error - binary bet can't be closed with empty final value");
        require(keccak256(abi.encodePacked(lockedValue)) != keccak256(abi.encodePacked("")), "P2PBinaryBetProvider: close error - binary bet can't be closed with empty locked value");
        BinaryDTOs.BinaryBet storage binaryBet = binaryBets[betId];
        require(binaryBet.expirationTime < block.timestamp, "P2PBinaryBetProvider: close error - expiration error");
        require(binaryBet.expirationTime + getTimestampExpirationDelay() > block.timestamp, "P2PBinaryBetProvider: close error - expiration error with delay");
        require(keccak256(abi.encodePacked(binaryBet.finalValue)) == keccak256(abi.encodePacked("")), "P2PBinaryBetProvider: close error - bet already closed");

        binaryBet.finalValue = finalValue;
        binaryBet.lockedValue = lockedValue;
        binaryBet.sideWon = sideWon;

        emit BinaryBetClosed(
            betId,
            lockedValue,
            finalValue,
            sideWon
        );
    }

    function cancelBinaryJoin(uint betId, uint joinIdRef) external {
        BinaryDTOs.JoinBinaryBetClient storage clientJoin = extractJoinBinaryBetClientByRef(matchingInfo[betId], clientInfo[msg.sender][betId].joinListRefs[joinIdRef]);

        require(clientJoin.amount != 0, "P2PBinaryBetProvider: cancel - free amount empty");
        require(binaryBets[betId].lockTime >= block.timestamp, "P2PBinaryBetProvider: cancel - lock time");

        uint mainTokenToRefund = cancelBinaryBet(matchingInfo[betId], clientJoin);
        withdrawalMainToken(msg.sender, mainTokenToRefund);

        emit BinaryBetCancelled(
            betId,
            msg.sender,
            joinIdRef,
            mainTokenToRefund
        );
    }

    function createBinaryBet(BinaryDTOs.CreateBinaryRequest calldata createRequest) external onlyCompany returns (uint) {
        // lock - 60 * 3
        // expiration - 60 * 3
        require(createRequest.lockTime >= block.timestamp + 3 * 60, "P2PBinaryBetProvider: create - lock time");
        require(createRequest.expirationTime >= createRequest.lockTime + 3 * 60, "P2PBinaryBetProvider: create - expirationTime time");

        uint betId = binaryBetIdCounter++;
        binaryBets[betId] = BinaryDTOs.BinaryBet(
            betId,
            createRequest.eventId,
            createRequest.lockTime,
            createRequest.expirationTime,
            "",
            "",
            false
        );

        emit BinaryBetCreated(
            betId,
            createRequest.eventId,
            createRequest.lockTime,
            createRequest.expirationTime,
            msg.sender
        );

        return betId;
    }

    function joinBinaryBet(uint betId, BinaryDTOs.JoinBinaryRequest calldata joinRequest) public {
        require(binaryBets[betId].lockTime >= block.timestamp, "CustomBetProvider: cancel - lock time");
        clientBets[msg.sender].push(betId);
        clientBetsLength[msg.sender]++;

        BinaryDTOs.JoinBinaryBetClientList storage clientBetList = clientInfo[msg.sender][betId];

        // deposit amounts
        DepositedValue memory depositedValue = deposit(msg.sender, joinRequest.amount);

        uint mainAmount = depositedValue.mainAmount;

        BinaryDTOs.JoinBinaryBetClient memory joinBetClient = BinaryDTOs.JoinBinaryBetClient(
            0,
            msg.sender,
            mainAmount,
            joinRequest.side,
            clientBetList.length
        );


        // Custom bet enrichment with matching
        uint sidePointer = joinBinaryBet(matchingInfo[betId], joinBetClient);

        // Add to client info sidePointer
        clientBetList.joinListRefs[clientBetList.length++] = BinaryDTOs.JoinBinaryBetClientRef(joinBetClient.side, sidePointer);

        emit BinaryBetJoined(
            joinRequest.side,
            joinRequest.amount,
            msg.sender,
            betId,
            joinBetClient.id,
            clientBetList.length - 1
        );
    }

    event BinaryBetCreated(
        uint id,
        string eventId,
        uint lockTime,
        uint expirationTime,
        address indexed creator
    );

    event BinaryBetJoined(
        bool side,
        uint mainAmount,
        address indexed client,
        uint betId,
        uint joinId,
        uint joinRefId
    );

    event BinaryBetCancelled(
        uint betId,
        address indexed client,
        uint joinIdRef,
        uint mainTokenRefunded
    );

    event BinaryBetClosed(
        uint betId,
        string lockedValue,
        string finalValue,
        bool sideWon
    );

    event BinaryPrizeTaken(
        uint betId,
        address indexed client,
        uint amount,
        bool useAlterFee
    );

    event BinaryBetRefunded(
        uint betId,
        address indexed client,
        uint mainTokenRefunded
    );
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

import "../security/Ownable.sol";
import "./CompanyVault.sol";
import "./AlternativeTokenHelper.sol";
import "./FeeConfiguration.sol";

abstract contract TokenProcessing is CompanyVault, AlternativeTokenHelper, FeeConfiguration {
    event FeeTaken(uint amount, address indexed targetAddress, bool isAlternative);

    struct DepositedValue {
        uint mainAmount;
    }

    constructor(address mainToken) CompanyVault(mainToken) {}

    // Deposit amount from sender
    function deposit(address sender, uint amount) internal returns (DepositedValue memory) {
        depositToken(getMainIERC20Token(), sender, amount);
        return DepositedValue(amount);
    }

    // Withdrawal main tokens to user
    // Used only in take prize and bet cancellation
    function withdrawalMainToken(address recipient, uint amount) internal {
        bool result = getMainIERC20Token().transfer(recipient, amount);
        require(result, "TokenProcessing: withdrawal token failed");
    }


    // Evaluate fee from amount and take it. Return the rest of it.
    function takeFeeFromAmount(address winner, uint amount, bool useAlternativeFee) internal returns (uint) {
        if (useAlternativeFee) {
            require(isAlternativeTokenEnabled(), "TokenProcessing: alternative token disabled");
            uint alternativeFeePart = applyAlternativeFee(amount);
            uint feeInAlternativeToken = evaluateAlternativeAmount(alternativeFeePart, getMainToken(), getAlternativeToken());
            depositToken(getAlternativeIERC20Token(), winner, feeInAlternativeToken);
            increaseFee(feeInAlternativeToken, getAlternativeToken());
            return amount;
        } else {
            uint feePart = applyCompanyFee(amount);
            increaseFee(feePart, getMainToken());
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
            require(amount <= getCompanyFeeBalance(getAlternativeToken()), "CompanyVault: take fee amount exeeds alter token balance");
        } else {
            require(amount <= getCompanyFeeBalance(getMainToken()), "CompanyVault: take fee amount exeeds token balance");
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
            decreaseFee(takeFeeVoting.amount, getAlternativeToken());
        } else {
            token = getMainIERC20Token();
            decreaseFee(takeFeeVoting.amount, getMainToken());
        }

        bool result = token.transfer(takeFeeVoting.targetAddress, takeFeeVoting.amount);
        require(result, "TokenProcessing: take fee transfer failed");
        emit FeeTaken(takeFeeVoting.amount, takeFeeVoting.targetAddress, takeFeeVoting.isAlternative);
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

library BinaryDTOs {
    struct BinaryBet {
        uint id;
        string eventId;
        uint lockTime;
        uint expirationTime;

        string lockedValue;
        string finalValue;
        bool sideWon;
    }

    struct BinaryMatchingInfo {
        // side == true
        mapping(uint => JoinBinaryBetClient) leftSide;
        uint leftLength;
        // side == false
        mapping(uint => JoinBinaryBetClient) rightSide;
        uint rightLength;

        uint leftAmount;
        uint rightAmount;
    }

    struct JoinBinaryBetClientList {
        mapping(uint => JoinBinaryBetClientRef) joinListRefs;
        uint length;
    }

    struct JoinBinaryBetClientRef {
        bool side;
        uint id;
    }

    struct JoinBinaryBetClient {
        uint id;
        address client;
        uint amount;
        bool side;
        uint joinRefId;
    }

    struct CreateBinaryRequest {
        string eventId;
        uint lockTime;
        uint expirationTime;
    }

    struct JoinBinaryRequest {
        bool side;
        uint amount;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

import "./BinaryDTOs.sol";

abstract contract BinaryProcessor {
    // Refund main token and alter token(if pay alter fee)
    // Only after expiration + expirationDelay call without bet closed action
    function processRefundingBinaryBet(BinaryDTOs.BinaryMatchingInfo storage info, BinaryDTOs.JoinBinaryBetClientList storage clientList) internal returns (uint) {
        uint resultAmount;
        for (uint i = 0; i < clientList.length; ++i) {
            BinaryDTOs.JoinBinaryBetClient storage joinClient = extractJoinBinaryBetClientByRef(info, clientList.joinListRefs[i]);
            resultAmount += joinClient.amount;

            joinClient.amount = 0;
        }

        return resultAmount;
    }

    // Evaluate mainToken for giving prize and modify joins
    // returns (mainToken amount)
    function takePrize(BinaryDTOs.BinaryBet storage bet, BinaryDTOs.BinaryMatchingInfo storage info, BinaryDTOs.JoinBinaryBetClientList storage clientList) internal returns (uint) {
        uint resultAmount;
        for (uint i = 0; i < clientList.length; ++i) {
            BinaryDTOs.JoinBinaryBetClient storage joinClient = extractJoinBinaryBetClientByRef(info, clientList.joinListRefs[i]);
            if (joinClient.side) {
                // left side
                if (bet.sideWon) {
                    resultAmount += applyCoefficient(joinClient.amount, info.leftAmount, info.rightAmount, true);
                }
            } else {
                // right side
                if (!bet.sideWon) {
                    resultAmount += applyCoefficient(joinClient.amount, info.leftAmount, info.rightAmount, false);
                }
            }

            joinClient.amount = 0;
        }

        return resultAmount;
    }

    // Evaluate mainToken for giving prize
    // returns (mainToken amount)
    function evaluatePrize(BinaryDTOs.BinaryBet storage bet, BinaryDTOs.BinaryMatchingInfo storage info, BinaryDTOs.JoinBinaryBetClientList storage clientList) internal view returns (uint) {
        uint resultAmount;
        for (uint i = 0; i < clientList.length; ++i) {
            BinaryDTOs.JoinBinaryBetClient storage joinClient = extractJoinBinaryBetClientByRef(info, clientList.joinListRefs[i]);
            if (joinClient.side) {
                // left side
                if (bet.sideWon) {
                    resultAmount += applyCoefficient(joinClient.amount, info.leftAmount, info.rightAmount, true);
                }
            } else {
                // right side
                if (!bet.sideWon) {
                    resultAmount += applyCoefficient(joinClient.amount, info.leftAmount, info.rightAmount, false);
                }
            }
        }

        return resultAmount;
    }


    // Evaluate mainToken and alternativeToken for refunding
    // returns (mainToken amount, alternativeToken amount)
    function cancelBinaryBet(BinaryDTOs.BinaryMatchingInfo storage info, BinaryDTOs.JoinBinaryBetClient storage joinClient) internal returns (uint) {
        uint amount = joinClient.amount;
        if (joinClient.side) {
            // left side
            info.leftAmount -= amount;
        } else {
            // right side
            info.rightAmount -= amount;
        }

        joinClient.amount = 0;

        return amount;
    }

    function joinBinaryBet(BinaryDTOs.BinaryMatchingInfo storage info, BinaryDTOs.JoinBinaryBetClient memory joinBinaryRequestBet) internal returns (uint) {
        if (joinBinaryRequestBet.side) {
            // left side
            joinBinaryRequestBet.id = info.leftLength;
            info.leftSide[info.leftLength++] = joinBinaryRequestBet;
            info.leftAmount += joinBinaryRequestBet.amount;
            return info.leftLength - 1;
        } else {
            // right side
            joinBinaryRequestBet.id = info.rightLength;
            info.rightSide[info.rightLength++] = joinBinaryRequestBet;
            info.rightAmount += joinBinaryRequestBet.amount;
            return info.rightLength - 1;
        }
    }

    function extractJoinBinaryBetClientByRef(BinaryDTOs.BinaryMatchingInfo storage info, BinaryDTOs.JoinBinaryBetClientRef storage ref) internal view returns (BinaryDTOs.JoinBinaryBetClient storage) {
        if (ref.side) {
            return info.leftSide[ref.id];
        } else {
            return info.rightSide[ref.id];
        }
    }

    function applyCoefficient(uint amountToEvaluate, uint leftAmount, uint rightAmount, bool direct) private pure returns (uint) {
        uint totalAmount = leftAmount + rightAmount;
        if (direct) {
            return ((amountToEvaluate * totalAmount * 10 ** 18) / leftAmount) / 10 ** 18;
        } else {
            return ((amountToEvaluate * totalAmount * 10 ** 18) / rightAmount) / 10 ** 18;
        }
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

import "../utils/Context.sol";
import "./SecurityDTOs.sol";

abstract contract Ownable is Context {
    mapping(address => bool) public owners;
    address private _company;
    uint public totalOwners;

    event CompanyTransferred(address indexed previousCompany, address indexed newCompany);

    event AddOwner(address indexed newOwner);
    event RemoveOwner(address indexed ownerToRemove);

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
pragma solidity 0.8.2;

import "../security/Security.sol";
import "../utils/IERC20.sol";

abstract contract CompanyVault is Security {
    SecurityDTOs.ChangeAlterToken public changeAlterToken;
    IERC20 internal _IERC20token;
    IERC20 internal _AlternativeIERC20token;
    mapping(address => uint) private feeBalance;
    bool private _alternativeTokenEnabled;
    uint private _timestampExpirationDelay;

    event ChangeAlterToken(address indexed newAlterToken);

    constructor (address mainToken) {
        _IERC20token = IERC20(mainToken);
        _timestampExpirationDelay = 2 * 60 * 60;
    }

    // Set expiration delay
    function setTimestampExpirationDelay(uint timestampExpirationDelay) external onlyOwner {
        _timestampExpirationDelay = timestampExpirationDelay;
    }

    // Change alter token start voting
    function changeAlternativeTokenStart(address alternativeToken) external onlyOwner {
        uint votingCode = startVoting("CHANGE_ALTER_TOKEN");
        changeAlterToken = SecurityDTOs.ChangeAlterToken(
            alternativeToken,
            block.timestamp,
            votingCode
        );
    }

    // Acquire alter token start voting
    function acquireNewAlternativeToken() external onlyOwner {
        pass(changeAlterToken.votingCode);
        _AlternativeIERC20token = IERC20(changeAlterToken.newAlterToken);
        emit ChangeAlterToken(changeAlterToken.newAlterToken);
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

    // Get fee company balance
    function getCompanyFeeBalance(address token) public view returns (uint) {
        return feeBalance[token];
    }

    // Increase main or alter token fee. Calls only from take prize.
    function increaseFee(uint amount, address token) internal {
        feeBalance[token] += amount;
    }

    // Decrease main or alter token fee. Calls only from take fee.
    function decreaseFee(uint amount, address token) internal {
        feeBalance[token] -= amount;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

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
pragma solidity 0.8.2;

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
        require(companyFee <= 2 * 10 ** 5);
        emit CompanyFeeChanged(_companyFee, companyFee);
        _companyFee = companyFee;
    }

    // Set company fee for all bets with alternative token fee
    function setAlternativeFeeFee(uint alternativeFee) external onlyOwner {
        require(alternativeFee <= 2 * 10 ** 5);
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
    function applyCompanyFee(uint amount) internal view returns (uint) {
        return (amount * _companyFee) / 10 ** 6;
    }

    // Apply alternative company fee and return alternative fee part
    function applyAlternativeFee(uint amount) internal view returns (uint) {
        return (amount * _alternativeFee) / 10 ** 6;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

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
pragma solidity 0.8.2;

library SecurityDTOs {
    struct ChangeAlterToken {
        address newAlterToken;
        uint createdDate;
        uint votingCode;
    }

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
pragma solidity 0.8.2;

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
pragma solidity 0.8.2;

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
pragma solidity 0.8.2;

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
        require(totalOwners >= 3, "Voting: not enough owners for starting new vote");
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
        require(votingInfo.currentNumberOfVotesPositive > totalOwners / 2, "Voting: not enough positive votes");
        require(votingInfo.startedDate + 60 * 60 * 72 < block.timestamp || votingInfo.currentNumberOfVotesPositive == totalOwners, "Voting: 72 hours have not yet passed");

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
pragma solidity 0.8.2;

interface IPancakeRouter01 {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}