pragma solidity =0.5.16;

import "./IUSDFIFactory.sol";
import "./USDFIPair.sol";

contract USDFIFactory is IUSDFIFactory {
    bytes32 public constant INIT_CODE_PAIR_HASH =
        keccak256(abi.encodePacked(type(USDFIPair).creationCode));

    address public owner;
    address public feeAmountOwner;

    uint256 public baseFeeAmount;
    uint256 public baseOwnerFeeShare;
    uint256 public baseProtocolFeeShare;
    address public baseProtocolVault;
    address public baseFeeTo;

    uint256 public constant FEE_DENOMINATOR = 100000; // = 100%
    uint256 public constant MAX_FEE_AMOUNT = 300; // = 0.3%
    uint256 public constant MIN_FEE_AMOUNT = 10; // = 0.01%
    uint256 public constant PROTOCOL_FEE_SHARE_MAX = 90000; // = 90%
    uint256 public constant OWNER_FEE_SHARE_MAX = 90000; // = 90%

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event FeeToTransferred(address indexed prevFeeTo, address indexed newFeeTo);
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );
    event OwnershipTransferred(
        address indexed prevOwner,
        address indexed newOwner
    );
    event FeeAmountOwnershipTransferred(
        address indexed prevOwner,
        address indexed newOwner
    );
    event BaseFeesUpdated(
        uint256 prevBaseFeeAmount,
        uint256 indexed _baseFeeAmount,
        uint256 prevBaseProtocolFeeShare,
        uint256 indexed _baseProtocolFeeShare,
        uint256 prevBaseOwnerFeeShare,
        uint256 indexed _baseOwnerFeeShare
    );
    event BaseProtocolVaultUpdated(
        address baseProtocolVault,
        address indexed _baseProtocolVault
    );
    event BaseFeeToUpdated(address baseFeeTo, address indexed _baseFeeTo);

    constructor(
        uint256 _baseFeeAmount,
        uint256 _baseOwnerFeeShare,
        uint256 _baseProtocolFeeShare,
        address _baseProtocolVault,
        address baseFeeTo_
    ) public {
        owner = msg.sender;
        feeAmountOwner = msg.sender;
        baseFeeAmount = _baseFeeAmount; // 300 default = 0.30%
        baseOwnerFeeShare = _baseOwnerFeeShare; // 5000 default value = 5%
        baseProtocolFeeShare = _baseProtocolFeeShare; // 90000 default = 90%
        baseProtocolVault = _baseProtocolVault;
        baseFeeTo = baseFeeTo_;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner == msg.sender, "USDFIFactory: caller is not the owner");
        _;
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair)
    {
        require(tokenA != tokenB, "USDFIFactory: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "USDFIFactory: ZERO_ADDRESS");
        require(
            getPair[token0][token1] == address(0),
            "USDFIFactory: PAIR_EXISTS"
        ); // single check is sufficient
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
    }

    function setOwner(address _owner) external onlyOwner {
        require(_owner != address(0), "USDFIFactory: zero address");
        emit OwnershipTransferred(owner, _owner);
        owner = _owner;
    }

    function setFeeAmountOwner(address _feeAmountOwner) external onlyOwner {
        require(_feeAmountOwner != address(0), "USDFIFactory: zero address");
        emit FeeAmountOwnershipTransferred(feeAmountOwner, _feeAmountOwner);
        feeAmountOwner = _feeAmountOwner;
    }

    //////

    function setBaseFees(
        uint256 _baseFeeAmount,
        uint256 _baseOwnerFeeShare,
        uint256 _baseProtocolFeeShare
    ) external onlyOwner {
        require(
            _baseFeeAmount <= MAX_FEE_AMOUNT,
            "USDFIPair: feeAmount mustn't exceed the maximum"
        );
        require(
            _baseFeeAmount >= MIN_FEE_AMOUNT,
            "USDFIPair: feeAmount mustn't exceed the minimum"
        );
        uint256 prevBaseFeeAmount = baseFeeAmount;
        baseFeeAmount = _baseFeeAmount;

        require(
            _baseOwnerFeeShare + _baseProtocolFeeShare < FEE_DENOMINATOR,
            "USDFIPair: fees mustn't exceed maximum (FEE_DENOMINATOR)"
        );

        require(
            _baseProtocolFeeShare <= PROTOCOL_FEE_SHARE_MAX,
            "USDFIPair: protocolFeeShare mustn't exceed maximum"
        );
        uint256 prevBaseProtocolFeeShare = baseProtocolFeeShare;
        baseProtocolFeeShare = _baseProtocolFeeShare;

        require(
            _baseOwnerFeeShare > 0,
            "USDFIPair: ownerFeeShare mustn't exceed minimum"
        );
        require(
            _baseOwnerFeeShare <= OWNER_FEE_SHARE_MAX,
            "USDFIPair: ownerFeeShare mustn't exceed maximum"
        );
        uint256 prevBaseOwnerFeeShare = baseOwnerFeeShare;
        baseOwnerFeeShare = _baseOwnerFeeShare;

        emit BaseFeesUpdated(
            prevBaseFeeAmount,
            _baseFeeAmount,
            prevBaseProtocolFeeShare,
            _baseProtocolFeeShare,
            prevBaseOwnerFeeShare,
            _baseOwnerFeeShare
        );
    }

    //////

    function setBaseProtocolVault(address _baseProtocolVault)
        external
        onlyOwner
    {
        require(_baseProtocolVault != address(0), "USDFIFactory: zero address");
        emit BaseProtocolVaultUpdated(baseProtocolVault, _baseProtocolVault);
        baseProtocolVault = _baseProtocolVault;
    }

    function setBaseFeeTo(address _baseFeeTo) external onlyOwner {
        require(_baseFeeTo != address(0), "USDFIFactory: zero address");
        emit BaseFeeToUpdated(baseFeeTo, _baseFeeTo);
        baseFeeTo = _baseFeeTo;
    }
}