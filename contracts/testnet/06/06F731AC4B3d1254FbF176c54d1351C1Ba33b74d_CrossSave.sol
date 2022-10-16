// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "IAxelarExecutable.sol";
import "IAxelarGasService.sol";

import "AggregatorV3Interface.sol";

contract CrossSave is IAxelarExecutable {
    AggregatorV3Interface public PriceFeed;
    IAxelarGasService public gasService;

    uint256 public minimumSavingTime;
    uint256 public minimumSavingAmount;

    uint256 public totalCrossChainSavingTime;
    uint256 public totalCrossChainDefaultBalance;

    uint256 public savingMethod = 1;
    uint256 public breakSaveEarlyMethod = 2;
    uint256 public unlockSavingsMethod = 3;

    uint256 public penaltyPercent = 10;

    // CHAIN DETAILS

    // BINANCE
    uint256 public bnbChainId = 97;
    string public bnbDestinationChain = "binance";
    string public bnbDestinationAddress;

    // POLYGON
    uint256 public polygonChainId = 80001;
    string public polygonDestinationChain = "Polygon";
    string public polygonDestinationAddress;

    struct Savings {
        uint256 balance;
        uint256 startTime;
        uint256 interval;
        uint256 stopTime;
        bool option; // flexible(true) and locked(false)
        bool exist;
        bool locked;
        uint256 chainConfirmations;
    }

    mapping(address => Savings) public savings;

    constructor(
        address _gateway,
        address _gasService,
        address _priceFeedAddress,
        uint256 _minSavingTime,
        uint256 _minSavingAmt
    ) IAxelarExecutable(_gateway) {
        gasService = IAxelarGasService(_gasService);
        minimumSavingTime = _minSavingTime;
        minimumSavingAmount = _minSavingAmt;

        PriceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    function save(
        uint256 _savingTime,
        bool _option,
        uint256 _estimateGasCost
    ) public payable {
        if (_savingTime < minimumSavingTime) {
            revert("Saving time too short");
        }

        if (msg.value < (_estimateGasCost)) {
            revert("Not enough gass");
        }

        // IF THE USER HAS PREVIOUSLY SAVED IN THE PAST
        if (!savings[msg.sender].exist) {
            uint256 stopTime = block.timestamp + _savingTime;

            uint256 actualSavings = msg.value - (_estimateGasCost);

            if (actualSavings < 0) {
                revert("Insufficient savings");
            }

            savings[msg.sender].balance += actualSavings;
            savings[msg.sender].interval = _savingTime;
            savings[msg.sender].startTime = block.timestamp;
            savings[msg.sender].stopTime = stopTime;
            savings[msg.sender].option = _option;
            savings[msg.sender].locked = true;

            // IF THE OPTION FOR SAVING IS FLEXIBLE(6) OR LOCKED(5)
            if (_option) {
                bytes memory payload = abi.encode(
                    savingMethod,
                    _savingTime,
                    address(0)
                );

                if (block.chainid == bnbChainId) {
                    _handleBNBSaving(payload, _estimateGasCost);
                }

                if (block.chainid == polygonChainId) {
                    _handlePOLYGONSaving(payload, _estimateGasCost);
                }
            }
        }
    }

    function breakSaveEarly(uint256 _estimateGasCost) public payable {
        if (!savings[msg.sender].exist) {
            revert("savings ! exist");
        }
        if (msg.value < (_estimateGasCost)) {
            revert("Not enough gass");
        }

        if (
            (savings[msg.sender].startTime - savings[msg.sender].stopTime) <
            savings[msg.sender].interval
        ) {
            if (!savings[msg.sender].option) {
                revert("Locked");
            } else {
                uint256 userAmount = savings[msg.sender].balance;
                uint256 returnAmount = ((100 - penaltyPercent) * userAmount) /
                    100;

                uint256 defaultBalanceIncrease = (penaltyPercent * userAmount) /
                    100;

                // THE USD PRICE OF THE DEFAULT BALANCE
                uint256 defaulltBalanceIncreaseInUsd = (getNativeAssetPrice() *
                    defaultBalanceIncrease) / 10e18;

                totalCrossChainDefaultBalance += defaulltBalanceIncreaseInUsd;

                bytes memory payload = abi.encode(
                    breakSaveEarlyMethod,
                    defaulltBalanceIncreaseInUsd,
                    address(0)
                );

                if (block.chainid == bnbChainId) {
                    _handleBNBSaving(payload, _estimateGasCost);
                }

                if (block.chainid == polygonChainId) {
                    _handlePOLYGONSaving(payload, _estimateGasCost);
                }

                (bool ok, ) = msg.sender.call{value: returnAmount}("");
                require(ok, "!ok");
            }
        }
    }

    function unlockSavings(uint256 _estimateGasCost) public payable {
        if (
            (savings[msg.sender].startTime - savings[msg.sender].stopTime) >
            savings[msg.sender].interval
        ) {
            savings[msg.sender].locked = false;
            if (!savings[msg.sender].option) {
                uint256 userAmount = savings[msg.sender].balance;
                (bool ok, ) = msg.sender.call{value: userAmount}("");
                require(ok, "!ok");
            } else if (savings[msg.sender].option) {
                // TO calculate the users interest
                // we take the user total saving period (TU)
                uint256 userSavingPeriod = savings[msg.sender].interval;
                // we take the total saving period accross all the chains (TE)

                // we take the total default balance accross all chains in USD (DB)
                // uint256 userInterest = TU/TE * DB
                uint256 interestInUSD = (userSavingPeriod /
                    totalCrossChainSavingTime) * totalCrossChainDefaultBalance;

                bytes memory payload = abi.encode(
                    unlockSavingsMethod,
                    interestInUSD,
                    msg.sender
                );

                if (msg.value < _estimateGasCost) {
                    revert("Not enough gass");
                }

                if (block.chainid == bnbChainId) {
                    _handleBNBSaving(payload, _estimateGasCost);
                }

                if (block.chainid == polygonChainId) {
                    _handlePOLYGONSaving(payload, _estimateGasCost);
                }

                savings[msg.sender].balance += ((interestInUSD * 10e18) /
                    getNativeAssetPrice());
            }
        }
        // WITHDRAWAL REQUIRES A TWO WAY CALL
        // THIS IS BECAUSE WHEN YOU WITHDRAW ON ONE CHAIN YOU TECHNICALLY REDUCE THE DEFAULT BALANCE ON THAT CHAIN
        // THE OTHER TWO CHAINS WILL TAKE ABOUT TWO MINUTES TO BE UPDATED(REDUCED)
        // IN THAT TWO MINUTES BEFORE REDUCTION SOMEONE CAN MAKE A WITHDRAWAL WITH AN EXCESS BALANCE
        // I.E THE BALANCE THAT HASN'T BEEN REDUCED AND EARN MORE THAN EXPECTED
        ///
        ////
        //SOLUTION
        // THE USER MAKES A WITHDRWAL ON THE MAIN CHAIN WHICH LOCKS HIS FUNDS FROM BEING WITHDRAWN
        // THIS SAME TRANSACTIN GOES TO UPDATE THE DEFAULT BALANCE ACCROSS THE TWO CHAINS AND UPDATES HIS BALANCE WITH INTEREST
        // THE TWO CHAINS COME WITH INDIVIDUAL MESSAGES AFFIRMING THAT THE BALANCE HAS BEEN ADJUSTED
        // ONCE CONFIRMED THE USER WILL BE ABLE TO TAKE HIS FUNDS AND THE INTEREST CONVERTED INTO THE NATIVE ASSET
    }

    function withdrawSavings() public {
        if (savings[msg.sender].locked) {
            revert("Savings hasn't been unlocked yet");
        }
        if (savings[msg.sender].chainConfirmations == 1) {
            revert("Not enough chain confirmation");
        }

        uint256 userBalancePlusInterest = savings[msg.sender].balance;

        savings[msg.sender].chainConfirmations = 0;

        (bool ok, ) = msg.sender.call{value: userBalancePlusInterest}("");
        require(ok, "!ok");
    }

    // INTERNAL FUNCTIONS

    function getNativeAssetPrice() public view returns (uint256) {
        (, int price, , , ) = PriceFeed.latestRoundData();
        // 8 DECIMALS
        // ASSUMING 1 MATIC IS 5 USD
        // THE PRICE WOULD RETURN 500000000
        return uint256(price);
    }

    function _handleFTMSaving(
        bytes memory payload,
        uint256 _estimateGasCost1,
        uint256 _estimateGasCost2
    ) internal {
        // ON FTM CHAIN - ESTIMATE1 = BNB || ESTIMATE2 = POLYGON

        gasService.payNativeGasForContractCall{value: _estimateGasCost1}(
            address(this),
            bnbDestinationChain,
            bnbDestinationAddress,
            payload,
            msg.sender
        );

        gateway.callContract(
            bnbDestinationChain,
            bnbDestinationAddress,
            payload
        );

        gasService.payNativeGasForContractCall{value: _estimateGasCost2}(
            address(this),
            polygonDestinationChain,
            polygonDestinationAddress,
            payload,
            msg.sender
        );

        gateway.callContract(
            polygonDestinationChain,
            polygonDestinationAddress,
            payload
        );
    }

    function _handleBNBSaving(bytes memory payload, uint256 _estimateGasCost)
        internal
    {
        // ON BNB CHAIN - ESTIMATE1 = FTM || ESTIMATE2 = POLYGON

        gasService.payNativeGasForContractCall{value: _estimateGasCost}(
            address(this),
            polygonDestinationChain,
            polygonDestinationAddress,
            payload,
            msg.sender
        );

        gateway.callContract(
            polygonDestinationChain,
            polygonDestinationAddress,
            payload
        );
    }

    function _handlePOLYGONSaving(
        bytes memory payload,
        uint256 _estimateGasCost
    ) internal {
        // ON POLYGON CHAIN - ESTIMATE1 = FTM || ESTIMATE2 = BNB

        gasService.payNativeGasForContractCall{value: _estimateGasCost}(
            address(this),
            bnbDestinationChain,
            bnbDestinationAddress,
            payload,
            msg.sender
        );

        gateway.callContract(
            bnbDestinationChain,
            bnbDestinationAddress,
            payload
        );
    }

    function _execute(
        string memory sourceChain,
        string memory sourceAddress,
        bytes calldata payload
    ) internal override {
        // METHODS
        // 1 = SAVINGS
        // 2 = WITHDRAWAL
        // 3 = UPDATE THE TOTAL BALANCE IN USD ON THE OTHER TWO CHAIN AND  CALL BACK THE SOURCE CHAIN
        // 4 = UNLOCK THE SAVINGS FOR WITHDRAWAL FROM THE TWO CHAINS ON THE SOURCE CHAIN
        (uint256 method, uint256 secondVar, address user) = abi.decode(
            payload,
            (uint256, uint256, address)
        );
        if (method == 1) {
            totalCrossChainSavingTime += secondVar;
        }
        if (method == 2) {
            totalCrossChainDefaultBalance += secondVar;
        }
        if (method == 3) {
            totalCrossChainDefaultBalance -= secondVar;
            uint256 methodThree = 4;
            uint256 confirmation = 1;
            bytes memory unlockPayload = abi.encode(
                methodThree,
                confirmation,
                user
            );
            gateway.callContract(sourceChain, sourceAddress, unlockPayload);
        }
        if (method == 4) {
            savings[user].chainConfirmations += secondVar;
        }
    }

    // MAKE THIS FUNCTION EITHER ACCESS CONTROLLED OR LOCK AFTER CALL
    function updateDestinationAddresses(
        string memory _bnbaddr,
        string memory _polygonaddr
    ) public {
        bnbDestinationAddress = _bnbaddr;
        polygonDestinationAddress = _polygonaddr;
    }

    function withdraw() public {
        (bool ok, ) = msg.sender.call{value: address(this).balance}("");
        require(ok, "");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import { IAxelarGateway } from "IAxelarGateway.sol";

abstract contract IAxelarExecutable {
    error NotApprovedByGateway();

    IAxelarGateway public gateway;

    constructor(address gateway_) {
        gateway = IAxelarGateway(gateway_);
    }

    function execute(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload
    ) external {
        bytes32 payloadHash = keccak256(payload);
        if (!gateway.validateContractCall(commandId, sourceChain, sourceAddress, payloadHash)) revert NotApprovedByGateway();
        _execute(sourceChain, sourceAddress, payload);
    }

    function executeWithToken(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) external {
        bytes32 payloadHash = keccak256(payload);
        if (!gateway.validateContractCallAndMint(commandId, sourceChain, sourceAddress, payloadHash, tokenSymbol, amount))
            revert NotApprovedByGateway();

        _executeWithToken(sourceChain, sourceAddress, payload, tokenSymbol, amount);
    }

    function _execute(
        string memory sourceChain,
        string memory sourceAddress,
        bytes calldata payload
    ) internal virtual {}

    function _executeWithToken(
        string memory sourceChain,
        string memory sourceAddress,
        bytes calldata payload,
        string memory tokenSymbol,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IAxelarGateway {
    /**********\
    |* Errors *|
    \**********/

    error NotSelf();
    error NotProxy();
    error InvalidCodeHash();
    error SetupFailed();
    error InvalidAuthModule();
    error InvalidTokenDeployer();
    error InvalidAmount();
    error InvalidChainId();
    error InvalidCommands();
    error TokenDoesNotExist(string symbol);
    error TokenAlreadyExists(string symbol);
    error TokenDeployFailed(string symbol);
    error TokenContractDoesNotExist(address token);
    error BurnFailed(string symbol);
    error MintFailed(string symbol);
    error InvalidSetMintLimitsParams();
    error ExceedMintLimit(string symbol);

    /**********\
    |* Events *|
    \**********/

    event TokenSent(address indexed sender, string destinationChain, string destinationAddress, string symbol, uint256 amount);

    event ContractCall(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload
    );

    event ContractCallWithToken(
        address indexed sender,
        string destinationChain,
        string destinationContractAddress,
        bytes32 indexed payloadHash,
        bytes payload,
        string symbol,
        uint256 amount
    );

    event Executed(bytes32 indexed commandId);

    event TokenDeployed(string symbol, address tokenAddresses);

    event ContractCallApproved(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        address indexed contractAddress,
        bytes32 indexed payloadHash,
        bytes32 sourceTxHash,
        uint256 sourceEventIndex
    );

    event ContractCallApprovedWithMint(
        bytes32 indexed commandId,
        string sourceChain,
        string sourceAddress,
        address indexed contractAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        bytes32 sourceTxHash,
        uint256 sourceEventIndex
    );

    event TokenMintLimitUpdated(string symbol, uint256 limit);

    event OperatorshipTransferred(bytes newOperatorsData);

    event Upgraded(address indexed implementation);

    /********************\
    |* Public Functions *|
    \********************/

    function sendToken(
        string calldata destinationChain,
        string calldata destinationAddress,
        string calldata symbol,
        uint256 amount
    ) external;

    function callContract(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload
    ) external;

    function callContractWithToken(
        string calldata destinationChain,
        string calldata contractAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount
    ) external;

    function isContractCallApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash
    ) external view returns (bool);

    function isContractCallAndMintApproved(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        address contractAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external view returns (bool);

    function validateContractCall(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash
    ) external returns (bool);

    function validateContractCallAndMint(
        bytes32 commandId,
        string calldata sourceChain,
        string calldata sourceAddress,
        bytes32 payloadHash,
        string calldata symbol,
        uint256 amount
    ) external returns (bool);

    /***********\
    |* Getters *|
    \***********/

    function authModule() external view returns (address);

    function tokenDeployer() external view returns (address);

    function tokenMintLimit(string memory symbol) external view returns (uint256);

    function tokenMintAmount(string memory symbol) external view returns (uint256);

    function allTokensFrozen() external view returns (bool);

    function implementation() external view returns (address);

    function tokenAddresses(string memory symbol) external view returns (address);

    function tokenFrozen(string memory symbol) external view returns (bool);

    function isCommandExecuted(bytes32 commandId) external view returns (bool);

    function adminEpoch() external view returns (uint256);

    function adminThreshold(uint256 epoch) external view returns (uint256);

    function admins(uint256 epoch) external view returns (address[] memory);

    /*******************\
    |* Admin Functions *|
    \*******************/

    function setTokenMintLimits(string[] calldata symbols, uint256[] calldata limits) external;

    function upgrade(
        address newImplementation,
        bytes32 newImplementationCodeHash,
        bytes calldata setupParams
    ) external;

    /**********************\
    |* External Functions *|
    \**********************/

    function setup(bytes calldata params) external;

    function execute(bytes calldata input) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "IUpgradable.sol";

// This should be owned by the microservice that is paying for gas.
interface IAxelarGasService is IUpgradable {
    error NothingReceived();
    error TransferFailed();
    error InvalidAddress();
    error NotCollector();
    error InvalidAmounts();

    event GasPaidForContractCall(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasPaidForContractCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForContractCall(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event NativeGasPaidForContractCallWithToken(
        address indexed sourceAddress,
        string destinationChain,
        string destinationAddress,
        bytes32 indexed payloadHash,
        string symbol,
        uint256 amount,
        uint256 gasFeeAmount,
        address refundAddress
    );

    event GasAdded(bytes32 indexed txHash, uint256 indexed logIndex, address gasToken, uint256 gasFeeAmount, address refundAddress);

    event NativeGasAdded(bytes32 indexed txHash, uint256 indexed logIndex, uint256 gasFeeAmount, address refundAddress);

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payGasForContractCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payNativeGasForContractCall(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        address refundAddress
    ) external payable;

    // This is called on the source chain before calling the gateway to execute a remote contract.
    function payNativeGasForContractCallWithToken(
        address sender,
        string calldata destinationChain,
        string calldata destinationAddress,
        bytes calldata payload,
        string calldata symbol,
        uint256 amount,
        address refundAddress
    ) external payable;

    function addGas(
        bytes32 txHash,
        uint256 txIndex,
        address gasToken,
        uint256 gasFeeAmount,
        address refundAddress
    ) external;

    function addNativeGas(
        bytes32 txHash,
        uint256 logIndex,
        address refundAddress
    ) external payable;

    function collectFees(
        address payable receiver,
        address[] calldata tokens,
        uint256[] calldata amounts
    ) external;

    function refund(
        address payable receiver,
        address token,
        uint256 amount
    ) external;

    function gasCollector() external returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

// General interface for upgradable contracts
interface IUpgradable {
    error NotOwner();
    error InvalidOwner();
    error InvalidCodeHash();
    error InvalidImplementation();
    error SetupFailed();
    error NotProxy();

    event Upgraded(address indexed newImplementation);
    event OwnershipTransferred(address indexed newOwner);

    // Get current owner
    function owner() external view returns (address);

    function contractId() external pure returns (bytes32);

    function implementation() external view returns (address);

    function upgrade(
        address newImplementation,
        bytes32 newImplementationCodeHash,
        bytes calldata params
    ) external;

    function setup(bytes calldata data) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}