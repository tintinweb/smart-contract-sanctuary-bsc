// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "../../processing/TokenProcessing.sol";
import "./BinaryDTOs.sol";
import "./BinaryProcessor.sol";

contract P2PBinaryBetProvider is TokenProcessing, BinaryProcessor {
    mapping(uint => BinaryDTOs.BinaryBet) private binaryBets;
    mapping(uint => BinaryDTOs.BinaryMatchingInfo) private matchingInfo;
    mapping(address => mapping(uint => BinaryDTOs.JoinBinaryBetClientList)) private clientInfo;
    uint private binaryBetIdCounter;

    constructor(address mainToken, address alternativeToken) TokenProcessing(mainToken, alternativeToken) {}

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

        (uint mainTokenToRefund, uint alterTokenToRefund) = processRefundingBinaryBet(matchingInfo[betId], clientInfo[client][betId]);
        withdrawal(mainTokenToRefund, alterTokenToRefund, client);

        emit BinaryBetRefunded(
            betId,
            client,
            mainTokenToRefund,
            alterTokenToRefund
        );
    }

    function takeBinaryPrize(uint betId, address client) public {
        BinaryDTOs.BinaryBet storage binaryBet = binaryBets[betId];
        require(keccak256(abi.encodePacked(binaryBet.finalValue)) != keccak256(abi.encodePacked("")), "P2PBinaryBetProvider: take prize - binary bet wasn't closed");
        require(keccak256(abi.encodePacked(binaryBet.lockedValue)) != keccak256(abi.encodePacked("")), "P2PBinaryBetProvider: take prize - binary bet wasn't closed");

        uint wonAmount = takePrize(binaryBet, matchingInfo[betId], clientInfo[client][betId]);

        require(wonAmount > 0, "P2PBinaryBetProvider: take prize - nothing");

        withdrawalMainToken(client, wonAmount);


        BinaryDTOs.BinaryMatchingInfo storage info = matchingInfo[betId];
        if (info.fee > 0) {
            increaseFee(info.fee, false);
            info.fee = 0;
        }
        if (info.alterFee > 0) {
            increaseFee(info.alterFee, true);
            info.alterFee = 0;
        }

        emit BinaryPrizeTaken(
            betId,
            client,
            wonAmount
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

    function cancelBinaryJoin(uint betId, uint joinId) external {
        BinaryDTOs.JoinBinaryBetClient storage clientJoin = extractJoinBinaryBetClientByRef(matchingInfo[betId], clientInfo[msg.sender][betId].joinListRefs[joinId]);

        require(clientJoin.amount != 0, "P2PBinaryBetProvider: cancel - free amount empty");
        require(binaryBets[betId].lockTime >= block.timestamp, "P2PBinaryBetProvider: cancel - lock time");

        (uint mainTokenToRefund, uint alterTokenToRefund) = cancelBinaryBet(matchingInfo[betId], clientJoin);
        withdrawal(mainTokenToRefund, alterTokenToRefund, msg.sender);

        emit BinaryBetCancelled(
            betId,
            joinId,
            mainTokenToRefund,
            alterTokenToRefund
        );
    }

    function createBinaryBet(BinaryDTOs.CreateBinaryRequest calldata createRequest) external onlyCompany returns (uint) {
        // lock - 60 * 5
        // expiration - 60 * 5
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

        // deposit amounts
        DepositedValue memory depositedValue = deposit(msg.sender, joinRequest.amount, joinRequest.useAlterFee);

        uint mainAmount = depositedValue.mainAmount;
        uint feeAmount = depositedValue.feeAmount;

        BinaryDTOs.JoinBinaryBetClient memory joinBetClient = BinaryDTOs.JoinBinaryBetClient(
            0,
            msg.sender,
            mainAmount,
            joinRequest.useAlterFee,
            feeAmount,
            joinRequest.side
        );


        // Custom bet enrichment with matching
        uint sidePointer = joinBinaryBet(matchingInfo[betId], joinBetClient);

        // Add to client info sidePointer
        BinaryDTOs.JoinBinaryBetClientList storage clientBetList = clientInfo[msg.sender][betId];
        clientBetList.joinListRefs[clientBetList.length] = BinaryDTOs.JoinBinaryBetClientRef(joinBetClient.side, sidePointer);
        clientBetList.length++;

        emit BinaryBetJoined(
            joinRequest.side,
            joinRequest.amount,
            joinRequest.useAlterFee,
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
        address creator
    );

    event BinaryBetJoined(
        bool side,
        uint mainAmount,
        bool useAlterFee,
        address client,
        uint betId,
        uint joinId,
        uint joinRefId
    );

    event BinaryBetCancelled(
        uint betId,
        uint joinId,
        uint mainTokenRefunded,
        uint alterTokenRefunded
    );

    event BinaryBetClosed(
        uint betId,
        string lockedValue,
        string finalValue,
        bool sideWon
    );

    event BinaryPrizeTaken(
        uint betId,
        address client,
        uint amount
    );

    event BinaryBetRefunded(
        uint betId,
        address client,
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
        uint fee;
        uint alterFee;
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
        bool useAlterFee;
        uint feeAmount;
        bool side;
    }

    struct CreateBinaryRequest {
        string eventId;
        uint lockTime;
        uint expirationTime;
    }

    struct JoinBinaryRequest {
        bool side;
        uint amount;
        bool useAlterFee;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity ^0.8.15;

import "./BinaryDTOs.sol";

abstract contract BinaryProcessor {
    // Refund main token and alter token(if pay alter fee)
    // Only after expiration + expirationDelay call without bet closed action
    function processRefundingBinaryBet(BinaryDTOs.BinaryMatchingInfo storage info, BinaryDTOs.JoinBinaryBetClientList storage clientList) internal returns (uint, uint) {
        uint resultAmount;
        uint refundAlterFee;
        for (uint i = 0; i < clientList.length; ++i) {
            BinaryDTOs.JoinBinaryBetClient storage joinClient = extractJoinBinaryBetClientByRef(info, clientList.joinListRefs[i]);
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
    function cancelBinaryBet(BinaryDTOs.BinaryMatchingInfo storage info, BinaryDTOs.JoinBinaryBetClient storage joinClient) internal returns (uint, uint) {
        uint amount = joinClient.amount;
        uint feeAmount = joinClient.feeAmount;
        if (joinClient.side) {
            // left side
            info.leftAmount -= amount;
        } else {
            // right side
            info.rightAmount -= amount;
        }

        if (joinClient.useAlterFee) {
            info.alterFee -= feeAmount;
        } else {
            info.fee -= feeAmount;
        }

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

    function joinBinaryBet(BinaryDTOs.BinaryMatchingInfo storage info, BinaryDTOs.JoinBinaryBetClient memory joinBinaryRequestBet) internal returns (uint) {
        if (joinBinaryRequestBet.useAlterFee) {
            info.alterFee += joinBinaryRequestBet.feeAmount;
        } else {
            info.fee += joinBinaryRequestBet.feeAmount;
        }

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