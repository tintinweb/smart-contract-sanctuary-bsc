// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;
import "./IERC20.sol";
contract CakeToXcadCompounder {
    IERC20 public vault_deposit_token = IERC20(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    // The current chain's ID
    uint currentChainId = 56;
    // Return Data From The Latest Low-Level Call
    bytes public latestContractData;
    // The Backend Executor's Address
    address executorAddress = 0xc6EAE321040E68C4152A19Abd584c376dc4d2159;
    // The Factory's Address
    address factoryAddress = 0xc6EAE321040E68C4152A19Abd584c376dc4d2159;
    // The Title Of the Strategy (Set By Creator)
    string public strategyTitle = "CakeToXcadCompounder";
    // The Current Active Step
    StepDetails activeStep;
    // The Current Active Divisor For the Steps
        uint activeDivisor = 1;
    // The Current Active Step's Custom Arguments (Set By Creator)
    bytes[] current_custom_arguments;
    // Allows Only The Address Of Yieldchain's Backend Executor To Call The Function
    modifier onlyExecutor() {
        require(msg.sender == executorAddress);
        _;
    }
    // Struct Object Format For Steps, Used To Store The Steps Details,
      // The Divisor Is Used To Divide The Token Balances At Each Step,
      // The Custom Arguments Are Used To Store Any Custom Arguments That The Creator May Want To Pass To The Step
    struct StepDetails {
        uint div;
        bytes[] custom_arguments;
    }
    // Initiallizes The Contract, Sets Owner, Approves Tokens
    constructor() {
    approveAllTokens();
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
    function deposit(uint256 _amount) public {
        require(_amount > 0, "Deposit must be above 0");
        updateBalances();
        vault_deposit_token.transferFrom(msg.sender, address(this), _amount);
        address[] memory to_tokens_arr = new address[](0);
        uint[] memory to_tokens_divs_arr = new uint[](0);
        bytes[] memory depositEventArr = new bytes[](6);
        bytes[6] memory depositEventArrFixed = [abi.encode(currentChainId), abi.encode(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82), abi.encode(to_tokens_arr), abi.encode(_amount), abi.encode(to_tokens_divs_arr), abi.encode(address(this))];
        for (uint256 i = 0; i < depositEventArrFixed.length; i++) {
            depositEventArr[i] = depositEventArrFixed[i];
        }
        emit CallbackEvent("lifibatchswap", "deposit_post", depositEventArr);
    }


    // Post-Deposit Function (To Be Called By External Offchain executorAddress With Retreived Data As An Array Of bytes)
            // Triggers "Base Strategy" (Swaps + Base Steps)
    function deposit_post(bytes[] memory _arguments) public onlyExecutor {
    uint256 PRE_BALANCE = CAKE_BALANCE;
    updateBalances();
    uint256 POST_BALANCE = CAKE_BALANCE;
        address[] memory _targets = abi.decode(_arguments[0], (address[]));
        bytes[] memory _callData = abi.decode(_arguments[1], (bytes[]));
        uint[] memory _nativeValues = abi.decode(_arguments[2], (uint[]));
        bool success;
        bytes memory result;
        require(_targets.length == _callData.length, "Addresses Amount Does Not Match Calldata Amount");
        for (uint i = 0; i < _targets.length; i++) {
            if (keccak256(_callData[i]) == keccak256(abi.encode("0x"))) {
                IERC20(_targets[i]).approve(_targets[i + 1], ((POST_BALANCE - PRE_BALANCE) * 110) / 100);
            } else {
                (success, result) = _targets[i].call{value: _nativeValues[i]}(_callData[i]);
                latestContractData = result;
            }
        }
        updateStepsDetails();
        updateActiveStep(step_0);
        uint256 currentIterationBalance = CAKE.balanceOf(address(this));
        if(currentIterationBalance == PRE_BALANCE) {
            CAKE_BALANCE = 0;
        } else if (currentIterationBalance == POST_BALANCE) {
            CAKE_BALANCE = (POST_BALANCE - PRE_BALANCE) * activeDivisor;
        } else if (currentIterationBalance < POST_BALANCE) {
            CAKE_BALANCE = (currentIterationBalance - PRE_BALANCE) * activeDivisor;
        } else if (currentIterationBalance > POST_BALANCE) {
            CAKE_BALANCE = (currentIterationBalance - POST_BALANCE) * activeDivisor;
        }
        func_9("deposit_post", [abi.encode("donotuseparamsever")]);
        updateBalances();
    }
    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Deposit must be above 0");
    }


    function callback_post(bytes[] memory _arguments) internal {
        address[] memory _targets = abi.decode(_arguments[0], (address[]));
        bytes[] memory _callDatas = abi.decode(_arguments[1], (bytes[]));
        uint256[] memory _nativeValues = abi.decode(_arguments[2], (uint256[]));
        require(_targets.length == _callDatas.length, "Lengths of targets and callDatas must match");
        bool success;
        bytes memory result;
        for (uint i = 0; i < _targets.length; i++) {
            if (keccak256(_callDatas[i]) == keccak256(abi.encode("0x"))) {
                IERC20(_targets[i]).approve(_targets[i + 1], IERC20(_targets[i]).balanceOf(address(this)));
            } else {
                (success, result) = _targets[i].call{value: _nativeValues[i]}(_callDatas[i]);
                latestContractData = result;
            }
        }
        require(success, "Function Call Failed On callback_post, Strategy Execution Aborted");
    }
    IERC20 CAKE = IERC20(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    IERC20 XCAD = IERC20(0x431e0cD023a32532BF3969CddFc002c00E98429d);
    uint256 CAKE_BALANCE;
    uint256 XCAD_BALANCE;
    function updateBalances() internal {
        CAKE_BALANCE = CAKE.balanceOf(address(this));
        XCAD_BALANCE = XCAD.balanceOf(address(this));
    }
    function approveAllTokens() internal {
        CAKE.approve(0x68Cc90351a79A4c10078FE021bE430b7a12aaA09, type(uint256).max);
        XCAD.approve(0x68Cc90351a79A4c10078FE021bE430b7a12aaA09, type(uint256).max);
    }
    


    function func_9(string memory _funcToCall, bytes[1] memory _arguments) internal {
        address currentFunctionAddress = 0x68Cc90351a79A4c10078FE021bE430b7a12aaA09;
        bool useCustomParams = keccak256(_arguments[0]) == keccak256(abi.encode("donotuseparamsever")) ? false : true;
        bytes memory result;
        bool success;
        if (useCustomParams) {
            (success, result) = 
            currentFunctionAddress.call(abi.encodeWithSignature("deposit(uint256)", abi.decode(_arguments[0], (uint256))));
        } else {
            (success, result) = currentFunctionAddress.call(abi.encodeWithSignature("deposit(uint256)", CAKE_BALANCE / activeDivisor));
        }
        latestContractData = result;
        require(success, "Function Call Failed On func_9, Strategy Execution Aborted");
    }
    


    function func_10(string memory _funcToCall, bytes[1] memory _arguments) internal {
        address currentFunctionAddress = 0x68Cc90351a79A4c10078FE021bE430b7a12aaA09;
        bool useCustomParams = keccak256(_arguments[0]) == keccak256(abi.encode("donotuseparamsever")) ? false : true;
        bytes memory result;
        bool success;
        if (useCustomParams) {
            (success, result) = 
            currentFunctionAddress.call(abi.encodeWithSignature("deposit(uint256)", abi.decode(_arguments[0], (uint256))));
        } else {
            (success, result) = currentFunctionAddress.call(abi.encodeWithSignature("deposit(uint256)", 0));
        }
        latestContractData = result;
        require(success, "Function Call Failed On func_10, Strategy Execution Aborted");
    }
    function func_14(string memory _funcToCall, bytes[5] memory _arguments) internal {
        address currentFunctionAddress = 0x1231DEB6f5749EF6cE6943a275A1D3E7486F4EaE;
        bool useCustomParams = keccak256(_arguments[0]) == keccak256(abi.encode("donotuseparamsever")) ? false : true;
        bytes memory result;
        bool success;
        if (useCustomParams) {
            (success, result) = 
            currentFunctionAddress.call(abi.encodeWithSignature("lifiswap(uint256,uint256,address,address,uint256)", abi.decode(_arguments[0], (uint256)), abi.decode(_arguments[1], (uint256)), abi.decode(_arguments[2], (address)), abi.decode(_arguments[3], (address)), abi.decode(_arguments[4], (uint256))));
        } else {
            bytes[] memory eventArr = new bytes[](5);
            bytes[5] memory eventArrFixed = [abi.encode(currentChainId), abi.encode(abi.decode(current_custom_arguments[0], (address))), abi.encode(abi.decode(current_custom_arguments[1], (address))), abi.encode(abi.decode(current_custom_arguments[2], (uint256))), abi.encode(address(this))];
            for (uint256 i = 0; i < eventArrFixed.length; i++) {
            eventArr[i] = eventArrFixed[i];
        }
            emit CallbackEvent("lifiswap", _funcToCall, eventArr);
        }
        latestContractData = result;
    }
    function updateStepsDetails() internal {
        step_0 = StepDetails(1, step_0_custom_args);
        step_1 = StepDetails(1, step_1_custom_args);
        step_2_custom_args = [abi.encode(0x431e0cD023a32532BF3969CddFc002c00E98429d), abi.encode(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82), abi.encode(XCAD_BALANCE)];
        step_2 = StepDetails(1, step_2_custom_args);
        step_3 = StepDetails(1, step_3_custom_args);
        }
        bytes[] step_0_custom_args;
        StepDetails step_0;
        bytes[] step_1_custom_args;
        StepDetails step_1;
        bytes[] step_2_custom_args = [abi.encode(0x431e0cD023a32532BF3969CddFc002c00E98429d), abi.encode(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82), abi.encode(XCAD_BALANCE)];
        StepDetails step_2;
        bytes[] step_3_custom_args;
        StepDetails step_3;


    function runStrategy_0() public onlyExecutor {
        updateBalances();
        updateStepsDetails();
        updateActiveStep(step_0);
        func_9("runStrategy_1", [abi.encode("donotuseparamsever")]);
        updateBalances();
        updateStepsDetails();
        updateActiveStep(step_1);
        func_10("runStrategy_1", [abi.encode("donotuseparamsever")]);
        updateBalances();
        updateStepsDetails();
        updateActiveStep(step_2);
        func_14("runStrategy_0", [abi.encode("donotuseparamsever"), abi.encode("donotuseparamsever"), abi.encode("donotuseparamsever"), abi.encode("donotuseparamsever"), abi.encode("donotuseparamsever")]);
    }


    function runStrategy_1(bytes[] memory _callBackParams) public onlyExecutor {
        callback_post(_callBackParams);
        updateBalances();
        updateStepsDetails();
        updateActiveStep(step_3);
        func_9("runStrategy_2", [abi.encode("donotuseparamsever")]);
    }
}