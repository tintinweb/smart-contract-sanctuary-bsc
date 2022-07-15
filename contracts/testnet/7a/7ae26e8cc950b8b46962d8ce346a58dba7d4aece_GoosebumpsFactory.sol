/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

contract GoosebumpsFactory {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(GoosebumpsPair).creationCode));
    address public feeTo;
    /**
     * @dev Must be Multi-Signature Wallet.
     */
    address public multiSigFeeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event LogSetFeeTo(address feeTo);
    event LogSetFeeToSetter(address multiSigFeeToSetter);

    constructor (address _multiSigFeeToSetter) {
        require(_multiSigFeeToSetter != address(0), "GoosebumpsFactory: ZERO_ADDRESS");
        multiSigFeeToSetter = _multiSigFeeToSetter;
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'GoosebumpsFactory: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'GoosebumpsFactory: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'GoosebumpsFactory: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(GoosebumpsPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        GoosebumpsPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == multiSigFeeToSetter, 'GoosebumpsFactory: FORBIDDEN');
        require(_feeTo != address(0), "GoosebumpsFactory: ZERO_ADDRESS");
        require(_feeTo != feeTo, "GoosebumpsFactory: SAME_ADDRESS");
        feeTo = _feeTo;

        emit LogSetFeeTo(_feeTo);
    }

    function setFeeToSetter(address _multiSigFeeToSetter) external {
        require(msg.sender == multiSigFeeToSetter, 'GoosebumpsFactory: FORBIDDEN');
        require(_multiSigFeeToSetter != address(0), "GoosebumpsFactory: ZERO_ADDRESS");
        require(_multiSigFeeToSetter != multiSigFeeToSetter, "GoosebumpsFactory: SAME_ADDRESS");
        multiSigFeeToSetter = _multiSigFeeToSetter;

        emit LogSetFeeToSetter(_multiSigFeeToSetter);
    }
}

contract GoosebumpsPair {
    uint256 public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;
    address public token0;
    address public token1;

    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint256 public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'GoosebumpsPair: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint256 value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'GoosebumpsPair: TRANSFER_FAILED');
    }

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );

    constructor() {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, 'GoosebumpsPair: FORBIDDEN'); // sufficient check
        require(_token0 != address(0), "GoosebumpsPair: ZERO_ADDRESS");
        require(_token1 != address(0), "GoosebumpsPair: ZERO_ADDRESS");
        token0 = _token0;
        token1 = _token1;
    }
}