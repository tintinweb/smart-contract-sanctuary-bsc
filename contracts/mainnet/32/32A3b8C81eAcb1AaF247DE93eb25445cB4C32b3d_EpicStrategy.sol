// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;
import "./IERC20.sol";

contract EpicStrategy {
    IERC20 public vault_deposit_token = IERC20(0x55d398326f99059fF775485246999027B3197955);
    // The current chain's ID
    uint256 currentChainId = 56;
    // Return Data From The Latest Low-Level Call
    bytes public latestContractData;
    // The Owner Of The Strategy
    address strategyOwner;
    // The Backend Executor's Address
    address executorAddress = 0xc6EAE321040E68C4152A19Abd584c376dc4d2159;
    // The Factory's Address
    address factoryAddress = 0xc6EAE321040E68C4152A19Abd584c376dc4d2159;
    // The Title Of the Strategy (Set By Creator)
    string public strategyTitle = "EpicStrategy";
    // The Current Active Step
    StepDetails activeStep;
    // The Current Active Divisor For the Steps
    uint256 activeDivisor = 1;
    // The Current Active Step's Custom Arguments (Set By Creator)
    bytes[] current_custom_arguments;
    // Allows Only The Owner Of The Strategy To Call The Function
    modifier onlyOwner() {
        require(msg.sender == strategyOwner);
        _;
    }
    // Allows Only The Address Of Yieldchain's Backend Executor To Call The Function
    modifier onlyExecutor() {
        require(msg.sender == executorAddress);
        _;
    }
    // Allows Only The Address Of The Strategy's Factory To Call The Function
    modifier onlyFactory() {
        require(msg.sender == factoryAddress);
        _;
    }
    // Struct Object Format For Steps, Used To Store The Steps Details,
    // The Divisor Is Used To Divide The Token Balances At Each Step,
    // The Custom Arguments Are Used To Store Any Custom Arguments That The Creator May Want To Pass To The Step
    struct StepDetails {
        uint256 div;
        bytes[] custom_arguments;
    }
    // Stores Whether The Contract Has Been Initialized Or Not
    bool initialized = false;

    // Initiallizes The Contract, Sets Owner, Approves Tokens, Sets Initialized To True
    function initialize(address _owner) public onlyFactory {
        require(!initialized, "Strategy Already Initialized");
        strategyOwner = _owner;
        approveAllTokens();
        initialized = true;
    }

    // Event That Gets Called On Each Callback Function That Requires Offchain Processing
    event CallbackEvent(string functionToEval, string operationOrigin, bytes[] callback_arguments);

    // Update Current Active Step's Details
    function updateActiveStep(StepDetails memory _argStep) internal {
        activeStep = _argStep;
        activeDivisor = _argStep.div;
        current_custom_arguments = _argStep.custom_arguments;
    }

    // Initial Deposit Function, Called By User/EOA, Triggers Callback Event W Amount Params Inputted
    function deposit(uint256 _amount) public onlyOwner {
        require(_amount > 0, "Deposit must be above 0");
        updateBalances();
        vault_deposit_token.transferFrom(msg.sender, address(this), _amount);
        address[] memory to_tokens_arr = new address[](1);
        uint256[] memory to_tokens_divs_arr = new uint256[](1);
        to_tokens_divs_arr[0] = 2;
        to_tokens_arr[0] = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
        bytes[] memory depositEventArr = new bytes[](6);
        bytes[6] memory depositEventArrFixed = [
            abi.encode(currentChainId),
            abi.encode(0x55d398326f99059fF775485246999027B3197955),
            abi.encode(to_tokens_arr),
            abi.encode(_amount),
            abi.encode(to_tokens_divs_arr),
            abi.encode(address(this))
        ];
        for (uint256 i = 0; i < depositEventArrFixed.length; i++) {
            depositEventArr[i] = depositEventArrFixed[i];
        }
        emit CallbackEvent("lifibatchswap", "deposit_post", depositEventArr);
    }

    // Post-Deposit Function (To Be Called By External Offchain executorAddress With Retreived Data As An Array Of bytes)
    // Triggers "Base Strategy" (Swaps + Base Steps)
    function deposit_post(bytes[] memory _arguments) public onlyExecutor {
        uint256 PRE_BALANCE = USDT_BALANCE;
        updateBalances();
        uint256 POST_BALANCE = USDT_BALANCE;
        address[] memory _targets = abi.decode(_arguments[0], (address[]));
        bytes[] memory _callData = abi.decode(_arguments[1], (bytes[]));
        uint256[] memory _nativeValues = abi.decode(_arguments[2], (uint256[]));
        bool success;
        bytes memory result;
        require(_targets.length == _callData.length, "Addresses Amount Does Not Match Calldata Amount");
        for (uint256 i = 0; i < _targets.length; i++) {
            if (keccak256(_callData[i]) == keccak256(abi.encode("0x"))) {
                IERC20(_targets[i]).approve(_targets[i + 1], ((POST_BALANCE - PRE_BALANCE) * 110) / 100);
            } else {
                (success, result) = _targets[i].call{value: _nativeValues[i]}(_callData[i]);
                latestContractData = result;
            }
        }
        uint256 currentIterationBalance = USDT.balanceOf(address(this));
        if (currentIterationBalance == PRE_BALANCE) {
            USDT_BALANCE = 0;
        } else if (currentIterationBalance == POST_BALANCE) {
            USDT_BALANCE = (POST_BALANCE - PRE_BALANCE) * activeDivisor;
        } else if (currentIterationBalance < POST_BALANCE) {
            USDT_BALANCE = (currentIterationBalance - PRE_BALANCE) * activeDivisor;
        } else if (currentIterationBalance > POST_BALANCE) {
            USDT_BALANCE = (currentIterationBalance - POST_BALANCE) * activeDivisor;
        }
        func_4(
            "deposit_post",
            [abi.encode("donotuseparamsever"), abi.encode("donotuseparamsever"), abi.encode("donotuseparamsever")]
        );
        CAKE_BALANCE = (CAKE.balanceOf(address(this)) - CAKE_BALANCE) * activeDivisor;
        func_9("deposit_post", [abi.encode("donotuseparamsever")]);
        updateBalances();
    }

    function withdraw(uint256 _amount) public onlyOwner {
        require(_amount > 0, "Deposit must be above 0");
    }

    function callback_post(bytes[] memory _arguments) internal {
        address[] memory _targets = abi.decode(_arguments[0], (address[]));
        bytes[] memory _callDatas = abi.decode(_arguments[1], (bytes[]));
        uint256[] memory _nativeValues = abi.decode(_arguments[2], (uint256[]));
        require(_targets.length == _callDatas.length, "Lengths of targets and callDatas must match");
        bool success;
        bytes memory result;
        for (uint256 i = 0; i < _targets.length; i++) {
            if (keccak256(_callDatas[i]) == keccak256("0x")) {
                IERC20(_targets[i]).approve(_targets[i + 1], IERC20(_targets[i]).balanceOf(address(this)));
            } else {
                (success, result) = _targets[i].call{value: _nativeValues[i]}(_callDatas[i]);
                latestContractData = result;
            }
        }
        require(success, "Function Call Failed On callback_post, Strategy Execution Aborted");
    }

    IERC20 USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 SUSDT = IERC20(0x9aA83081AA06AF7208Dcc7A4cB72C94d057D2cda);
    IERC20 STG = IERC20(0xB0D502E938ed5f4df2E681fE6E419ff29631d62b);
    IERC20 CAKE = IERC20(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    IERC20 XCAD = IERC20(0x431e0cD023a32532BF3969CddFc002c00E98429d);
    uint256 USDT_BALANCE;
    uint256 SUSDT_BALANCE;
    uint256 STG_BALANCE;
    uint256 CAKE_BALANCE;
    uint256 XCAD_BALANCE;

    function updateBalances() internal {
        USDT_BALANCE = USDT.balanceOf(address(this));
        SUSDT_BALANCE = SUSDT.balanceOf(address(this));
        STG_BALANCE = STG.balanceOf(address(this));
        CAKE_BALANCE = CAKE.balanceOf(address(this));
        XCAD_BALANCE = XCAD.balanceOf(address(this));
    }

    function approveAllTokens() internal {
        STG.approve(0x3052A0F6ab15b4AE1df39962d5DdEFacA86DaB47, type(uint256).max);
        SUSDT.approve(0x3052A0F6ab15b4AE1df39962d5DdEFacA86DaB47, type(uint256).max);
        CAKE.approve(0x68Cc90351a79A4c10078FE021bE430b7a12aaA09, type(uint256).max);
        XCAD.approve(0x68Cc90351a79A4c10078FE021bE430b7a12aaA09, type(uint256).max);
        USDT.approve(0x4a364f8c717cAAD9A442737Eb7b8A55cc6cf18D8, type(uint256).max);
        SUSDT.approve(0x4a364f8c717cAAD9A442737Eb7b8A55cc6cf18D8, type(uint256).max);
    }

    function func_6(string memory _funcToCall, bytes[2] memory _arguments) internal {
        address currentFunctionAddress = 0x3052A0F6ab15b4AE1df39962d5DdEFacA86DaB47;
        bool useCustomParams = keccak256(_arguments[0]) == keccak256(abi.encode("donotuseparamsever"))
            ? false
            : true;
        bytes memory result;
        bool success;
        if (useCustomParams) {
            (success, result) = currentFunctionAddress.call(
                abi.encodeWithSignature(
                    "deposit(uint256,uint256)",
                    abi.decode(_arguments[0], (uint256)),
                    abi.decode(_arguments[1], (uint256))
                )
            );
        } else {
            (success, result) = currentFunctionAddress.call(
                abi.encodeWithSignature("deposit(uint256,uint256)", 0, SUSDT_BALANCE / activeDivisor)
            );
        }
        latestContractData = result;
        require(success, "Function Call Failed On func_6, Strategy Execution Aborted");
    }

    function func_5(string memory _funcToCall, bytes[2] memory _arguments) internal {
        address currentFunctionAddress = 0x3052A0F6ab15b4AE1df39962d5DdEFacA86DaB47;
        bool useCustomParams = keccak256(_arguments[0]) == keccak256(abi.encode("donotuseparamsever"))
            ? false
            : true;
        bytes memory result;
        bool success;
        if (useCustomParams) {
            (success, result) = currentFunctionAddress.call(
                abi.encodeWithSignature(
                    "deposit(uint256,uint256)",
                    abi.decode(_arguments[0], (uint256)),
                    abi.decode(_arguments[1], (uint256))
                )
            );
        } else {
            (success, result) = currentFunctionAddress.call(
                abi.encodeWithSignature("deposit(uint256,uint256)", 0, 0)
            );
        }
        latestContractData = result;
        require(success, "Function Call Failed On func_5, Strategy Execution Aborted");
    }

    function func_10(string memory _funcToCall, bytes[1] memory _arguments) internal {
        address currentFunctionAddress = 0x68Cc90351a79A4c10078FE021bE430b7a12aaA09;
        bool useCustomParams = keccak256(_arguments[0]) == keccak256(abi.encode("donotuseparamsever"))
            ? false
            : true;
        bytes memory result;
        bool success;
        if (useCustomParams) {
            (success, result) = currentFunctionAddress.call(
                abi.encodeWithSignature("deposit(uint256)", abi.decode(_arguments[0], (uint256)))
            );
        } else {
            (success, result) = currentFunctionAddress.call(abi.encodeWithSignature("deposit(uint256)", 0));
        }
        latestContractData = result;
        require(success, "Function Call Failed On func_10, Strategy Execution Aborted");
    }

    function func_14(string memory _funcToCall, bytes[5] memory _arguments) internal {
        address currentFunctionAddress = 0x68Cc90351a79A4c10078FE021bE430b7a12aaA09;
        bool useCustomParams = keccak256(_arguments[0]) == keccak256(abi.encode("donotuseparamsever"))
            ? false
            : true;
        bytes memory result;
        bool success;
        if (useCustomParams) {
            (success, result) = currentFunctionAddress.call(
                abi.encodeWithSignature(
                    "lifiswap(uint256,uint256,address,address,uint256)",
                    abi.decode(_arguments[0], (uint256)),
                    abi.decode(_arguments[1], (uint256)),
                    abi.decode(_arguments[2], (address)),
                    abi.decode(_arguments[3], (address)),
                    abi.decode(_arguments[4], (uint256))
                )
            );
        } else {
            bytes[] memory eventArr = new bytes[](5);
            bytes[5] memory eventArrFixed = [
                abi.encode(currentChainId),
                abi.encode(abi.decode(current_custom_arguments[0], (address))),
                abi.encode(abi.decode(current_custom_arguments[1], (address))),
                abi.encode(abi.decode(current_custom_arguments[2], (uint256))),
                abi.encode(address(this))
            ];
            for (uint256 i = 0; i < eventArrFixed.length; i++) {
                eventArr[i] = eventArrFixed[i];
            }
            emit CallbackEvent("lifiswap", _funcToCall, eventArr);
        }
        latestContractData = result;
    }

    function func_11(string memory _funcToCall, bytes[1] memory _arguments) internal {
        address currentFunctionAddress = 0x68Cc90351a79A4c10078FE021bE430b7a12aaA09;
        bool useCustomParams = keccak256(_arguments[0]) == keccak256(abi.encode("donotuseparamsever"))
            ? false
            : true;
        bytes memory result;
        bool success;
        if (useCustomParams) {
            (success, result) = currentFunctionAddress.call(
                abi.encodeWithSignature("withdraw(uint256)", abi.decode(_arguments[0], (uint256)))
            );
        } else {
            (success, result) = currentFunctionAddress.call(
                abi.encodeWithSignature("withdraw(uint256)", CAKE_BALANCE / activeDivisor)
            );
        }
        latestContractData = result;
        require(success, "Function Call Failed On func_11, Strategy Execution Aborted");
    }

    function func_4(string memory _funcToCall, bytes[3] memory _arguments) internal {
        address currentFunctionAddress = 0x4a364f8c717cAAD9A442737Eb7b8A55cc6cf18D8;
        bool useCustomParams = keccak256(_arguments[0]) == keccak256(abi.encode("donotuseparamsever"))
            ? false
            : true;
        bytes memory result;
        bool success;
        if (useCustomParams) {
            (success, result) = currentFunctionAddress.call(
                abi.encodeWithSignature(
                    "addLiquidity(uint256,uint256,address)",
                    abi.decode(_arguments[0], (uint256)),
                    abi.decode(_arguments[1], (uint256)),
                    abi.decode(_arguments[2], (address))
                )
            );
        } else {
            (success, result) = currentFunctionAddress.call(
                abi.encodeWithSignature(
                    "addLiquidity(uint256,uint256,address)",
                    2,
                    USDT_BALANCE / activeDivisor,
                    address(this)
                )
            );
        }
        latestContractData = result;
        require(success, "Function Call Failed On func_4, Strategy Execution Aborted");
    }

    function func_9(string memory _funcToCall, bytes[1] memory _arguments) internal {
        address currentFunctionAddress = 0x68Cc90351a79A4c10078FE021bE430b7a12aaA09;
        bool useCustomParams = keccak256(_arguments[0]) == keccak256(abi.encode("donotuseparamsever"))
            ? false
            : true;
        bytes memory result;
        bool success;
        if (useCustomParams) {
            (success, result) = currentFunctionAddress.call(
                abi.encodeWithSignature("deposit(uint256)", abi.decode(_arguments[0], (uint256)))
            );
        } else {
            (success, result) = currentFunctionAddress.call(
                abi.encodeWithSignature("deposit(uint256)", CAKE_BALANCE / activeDivisor)
            );
        }
        latestContractData = result;
        require(success, "Function Call Failed On func_9, Strategy Execution Aborted");
    }

    bytes[] step_3_custom_args = new bytes[](0);
    StepDetails step_3 = StepDetails(1, step_3_custom_args);
    bytes[] step_4_custom_args = new bytes[](0);
    StepDetails step_4 = StepDetails(1, step_4_custom_args);
    bytes[] step_5_custom_args = new bytes[](0);
    StepDetails step_5 = StepDetails(1, step_5_custom_args);
    bytes[] step_6_custom_args = [
        abi.encode(0x431e0cD023a32532BF3969CddFc002c00E98429d),
        abi.encode(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82),
        abi.encode(XCAD_BALANCE / activeDivisor)
    ];
    StepDetails step_6 = StepDetails(1, step_6_custom_args);
    bytes[] step_7_custom_args = new bytes[](0);
    StepDetails step_7 = StepDetails(2, step_7_custom_args);

    function runStrategy_0() public onlyExecutor {
        updateBalances();
        updateActiveStep(step_3);
        func_6("runStrategy_1", [abi.encode("donotuseparamsever"), abi.encode("donotuseparamsever")]);
        updateBalances();
        updateActiveStep(step_4);
        func_5("runStrategy_1", [abi.encode("donotuseparamsever"), abi.encode("donotuseparamsever")]);
        updateBalances();
        updateActiveStep(step_5);
        func_10("runStrategy_1", [abi.encode("donotuseparamsever")]);
        updateBalances();
        updateActiveStep(step_6);
        func_14(
            "runStrategy_0",
            [
                abi.encode("donotuseparamsever"),
                abi.encode("donotuseparamsever"),
                abi.encode("donotuseparamsever"),
                abi.encode("donotuseparamsever"),
                abi.encode("donotuseparamsever")
            ]
        );
    }

    function runStrategy_1(bytes[] memory _callBackParams) public onlyExecutor {
        callback_post(_callBackParams);
        updateBalances();
        updateActiveStep(step_7);
        func_11("runStrategy_2", [abi.encode("donotuseparamsever")]);
    }
}