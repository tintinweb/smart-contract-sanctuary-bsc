pragma solidity = 0.5.16;

import "./IUSDFIFactory.sol";
import "./USDFIPair.sol";

contract USDFIFactory is IUSDFIFactory {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(USDFIPair).creationCode));

    address public owner;
    address public feeAmountOwner;
    address public feeTo;
    address public baseProtocolVault;

    //uint public constant FEE_DENOMINATOR = 100000;
    uint public constant OWNER_FEE_SHARE_MAX = 95000; // 95%
    uint public ownerFeeShare = 5000; // default value = 5%

    uint public constant PROTOCOL_FEE_SHARE_MAX = 95000; // 95%
    mapping(address => uint) public protocolsFeeShare; // fees are taken from the user input

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event FeeToTransferred(address indexed prevFeeTo, address indexed newFeeTo);
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    event OwnerFeeShareUpdated(uint prevOwnerFeeShare, uint ownerFeeShare);
    event OwnershipTransferred(address indexed prevOwner, address indexed newOwner);
    event FeeAmountOwnershipTransferred(address indexed prevOwner, address indexed newOwner);
    event ProtocolFeeShareUpdated(address protocol, uint prevProtocolFeeShare, uint protocolFeeShare);

    constructor(address feeTo_, address _baseProtocolVault) public {
        owner = msg.sender;
        feeAmountOwner = msg.sender;
        feeTo = feeTo_;
        baseProtocolVault = _baseProtocolVault;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner == msg.sender, "USDFIFactory: caller is not the owner");
        _;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "USDFIFactory: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "USDFIFactory: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), "USDFIFactory: PAIR_EXISTS"); // single check is sufficient
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

    function setFeeTo(address _feeTo) external onlyOwner {
        emit FeeToTransferred(feeTo, _feeTo);
        feeTo = _feeTo;
    }

    function setProtocolVaultFeeTo(address _pair, address _protocolFeeTo) external onlyOwner {
        require(_protocolFeeTo != address(0), "USDFIFactory: zero address");
         USDFIPair(_pair).setProtocolFeeTo(_protocolFeeTo);
    }

    function setBaseProtocolVault(address _baseProtocolVault) external onlyOwner {
        require(_baseProtocolVault != address(0), "USDFIFactory: zero address");
        baseProtocolVault = _baseProtocolVault;
    }

    /**
     * @dev Updates the share of fees attributed to the owner (FeeManager)
     *
     * Must only be called by owner
     */
    function setOwnerFeeShare(uint newOwnerFeeShare) external onlyOwner {
        require(newOwnerFeeShare > 0, "USDFIFactory: ownerFeeShare mustn't exceed minimum");
        require(newOwnerFeeShare <= OWNER_FEE_SHARE_MAX, "USDFIFactory: ownerFeeShare mustn't exceed maximum");
        uint prevOwnerFeeShare = ownerFeeShare;
        ownerFeeShare = newOwnerFeeShare;
        emit OwnerFeeShareUpdated(prevOwnerFeeShare, ownerFeeShare);
    }

    /**
     * @dev Updates the share of fees attributed to the given protocol when a swap went through him
     *
     * Must only be called by owner
     */
    function setProtocolFeeShare(address protocol, uint protocolFeeShare) external onlyOwner {
        require(protocolFeeShare <= PROTOCOL_FEE_SHARE_MAX, "USDFIFactory: protocolFeeShare mustn't exceed maximum");
        uint prevProtocolFeeShare = protocolsFeeShare[protocol];
        protocolsFeeShare[protocol] = protocolFeeShare;
        emit ProtocolFeeShareUpdated(protocol, prevProtocolFeeShare, protocolFeeShare);
    }
}