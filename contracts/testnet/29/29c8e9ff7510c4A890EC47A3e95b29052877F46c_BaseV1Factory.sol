/**
 * @title Base V1 Factory
 * @dev BaseV1Factory.sol contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

pragma solidity =0.8.17;

import "./BaseV1Pair.sol";

contract BaseV1Factory {
    bool public isPaused;
    address public owner;
    address public pendingOwner;
    address public admin;
    address public feeAmountOwner;

    uint256 public baseStableFee = 2000; // 0.04%
    uint256 public baseVariableFee = 333; // 0.3%

    mapping(address => mapping(address => mapping(bool => address)))
        public getPair;
    address[] public allPairs;
    mapping(address => bool) public isPair; // simplified check if its a pair, given that `stable` flag might not be available in peripherals

    address internal _temp0;
    address internal _temp1;
    bool internal _temp;

    mapping(address => address) public protocolAddresses; // pair => protocolAddress
    address public usdfiMaker;

    bool public shouldGasThrottle;
    uint256 public maxGasPrice; // 1000000000 == 1 gwei

    event PairCreated(
        address indexed token0,
        address indexed token1,
        bool stable,
        address pair,
        uint256 allPairsLength
    );

    constructor() {
        owner = msg.sender;
        feeAmountOwner = msg.sender;
        isPaused = false;
    }

    function setBaseStableFee(uint256 _fee) external {
        require(msg.sender == owner);
        require(_fee >= 10 && _fee <= 10000, "!range");
        baseStableFee = _fee;
    }

    function setBaseVariableFee(uint256 _fee) external {
        require(msg.sender == owner);
        require(_fee >= 10 && _fee <= 10000, "!range");
        baseVariableFee = _fee;
    }

    function setShouldGasThrottleAndMaxGasPrice(bool _bool, uint256 _gas)
        external
    {
        require(msg.sender == owner, "Pair: only owner or admin");
        shouldGasThrottle = _bool;
        maxGasPrice = _gas;
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    function setOwner(address _owner) external {
        require(msg.sender == owner);
        pendingOwner = _owner;
    }

    function acceptOwner() external {
        require(msg.sender == pendingOwner);
        owner = pendingOwner;
    }

    function setPause(bool _state) external {
        require(msg.sender == owner || msg.sender == admin);
        isPaused = _state;
    }

    function setProtocolAddress(address _pair, address _protocolAddress)
        external
    {
        require(msg.sender == owner || msg.sender == admin);
        protocolAddresses[_pair] = _protocolAddress;
    }

    function setAdmins(
        address _usdfiMaker,
        address _feeAmountOwner,
        address _admin
    ) external {
        require(msg.sender == owner || msg.sender == admin);
        usdfiMaker = _usdfiMaker;
        feeAmountOwner = _feeAmountOwner;
        admin = _admin;
    }

    function pairCodeHash() external pure returns (bytes32) {
        return keccak256(type(BaseV1Pair).creationCode);
    }

    function getInitializable()
        external
        view
        returns (
            address,
            address,
            bool
        )
    {
        return (_temp0, _temp1, _temp);
    }

    function createPair(
        address tokenA,
        address tokenB,
        bool stable
    ) external returns (address pair) {
        require(tokenA != tokenB, "IA"); // BaseV1: IDENTICAL_ADDRESSES
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "ZA"); // BaseV1: ZERO_ADDRESS
        require(getPair[token0][token1][stable] == address(0), "PE"); // BaseV1: PAIR_EXISTS - single check is sufficient
        bytes32 salt = keccak256(abi.encodePacked(token0, token1, stable)); // notice salt includes stable as well, 3 parameters
        (_temp0, _temp1, _temp) = (token0, token1, stable);
        pair = address(new BaseV1Pair{salt: salt}());
        getPair[token0][token1][stable] = pair;
        getPair[token1][token0][stable] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        isPair[pair] = true;
        emit PairCreated(token0, token1, stable, pair, allPairs.length);
    }
}