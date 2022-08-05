/**
 * @title USDFI Factory
 * @dev USDFIFactory contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: MIT
 *
 * Forkt from address 0x858E3312ed3A876947EA49d572A7C42DE08af7EE
 *
 **/

pragma solidity = 0.5.16;

import './USDFIPair.sol';

contract USDFIFactory {
    address public baseFeeTo;
    address public feeToSetter;
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(USDFIPair).creationCode));

    uint32 public baseSwapFee = 30;
    uint32 public baseProtocolFee = 5;
    uint32 public baseGrowthFee = 25;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
      feeToSetter = _feeToSetter;
    }  

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'USDFI: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'USDFI: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'USDFI: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(USDFIPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUSDFIPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
        USDFIPair(pair).setSwapFee(baseSwapFee);
        USDFIPair(pair).setProtocolFee(baseProtocolFee);
        USDFIPair(pair).setGrowthFee(baseGrowthFee);
        USDFIPair(pair).setFeeTo(baseFeeTo);
    }

    function setBaseFeeTo(address _baseFeeTo) external {
        require(msg.sender == feeToSetter, 'USDFI: FORBIDDEN');
        baseFeeTo = _baseFeeTo;
    }

    function setFeeTo(address _pair, address _FeeTo) external {
        require(msg.sender == feeToSetter, 'USDFI: FORBIDDEN');
        USDFIPair(_pair).setFeeTo(_FeeTo);
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'USDFI: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function setBaseFees(uint32 _baseSwapFee, uint32 _baseProtocolFee, uint32 _baseGrowthFee) external {
        require(msg.sender == feeToSetter, 'USDFI: FORBIDDEN');
        require(_baseSwapFee > 0, 'USDFI: FORBIDDEN_SWAP_FEE');
        require(_baseProtocolFee > 0, 'USDFI: FORBIDDEN_PROTOCOL_FEE');
        require(_baseGrowthFee > 0, 'USDFI: FORBIDDEN_GROWTH_FEE');
        require(_baseSwapFee == _baseProtocolFee + _baseGrowthFee, 'USDFI: FORBIDDEN_FEE');
        baseSwapFee = _baseSwapFee;
        baseProtocolFee = _baseProtocolFee;
        baseGrowthFee = _baseGrowthFee;
    }

    function setSwapFeeAndProtocolFeeAndGrowthFee(address _pair, uint32 _swapFee, uint8 _protocolFee, uint8 _growth) external {
        require(msg.sender == feeToSetter, 'USDFI: FORBIDDEN');
        require(_swapFee > 0, 'USDFI: FORBIDDEN_SWAP_FEE');
        require(_protocolFee > 0, 'USDFI: FORBIDDEN_PROTOCOL_FEE');
        require(_growth > 0, 'USDFI: FORBIDDEN_GROWTH_FEE');
        require(_swapFee == _protocolFee + _growth, 'USDFI: FORBIDDEN_FEE');
        USDFIPair(_pair).setSwapFee(_swapFee);
        USDFIPair(_pair).setGrowthFee(_growth);
        USDFIPair(_pair).setProtocolFee(_protocolFee);
    }
}