// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

// import "@openzeppelin/contracts-newone/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-newone/utils/Create2.sol";
import "@openzeppelin/contracts-newone/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "./IBridge.sol";
import "./ISyntERC20.sol";
import "./SyntERC20.sol";
import "../utils/Typecast.sol";
import "./RequestIdLib.sol";
import "../interfaces/ICurveProxy.sol";
import "../interfaces/IWhitelist.sol";

contract Synthesis is Typecast, ContextUpgradeable, OwnableUpgradeable  {
    mapping(address => bytes32) public representationReal;
    mapping(bytes32 => address) public representationSynt;
    mapping(bytes32 => uint8) public tokenDecimals;
    bytes32[] private keys;
    mapping(bytes32 => TxState) public requests;
    mapping(bytes32 => SynthesizeState) public synthesizeStates;
    address public bridge;
    address public proxy;
    address public proxyV2;
    string public versionRecipient;
    address public whitelist;

    bytes public constant sighashUnsynthesize =
        abi.encodePacked(uint8(115), uint8(234), uint8(111), uint8(109), uint8(131), uint8(167), uint8(37), uint8(70));
    bytes public constant sighashEmergencyUnsynthesize =
        abi.encodePacked(uint8(102), uint8(107), uint8(151), uint8(50), uint8(141), uint8(172), uint8(244), uint8(63));

    // enum UnsynthesizePubkeys {
    //     receiveSide,
    //     receiveSideData,
    //     oppositeBridge,
    //     oppositeBridgeData,
    //     txState,
    //     source,
    //     destination,
    //     realToken
    // }

    enum RequestState {
        Default,
        Sent,
        Reverted
    }
    enum SynthesizeState {
        Default,
        Synthesized,
        RevertRequest
    }

    event BurnRequest(bytes32 indexed id, address indexed from, address indexed to, uint256 amount, address token);
    event RevertSynthesizeRequest(bytes32 indexed id, address indexed to);
    event SynthesizeCompleted(bytes32 indexed id, address indexed to, uint256 amount, address token);
    event SynthTransfer(
        bytes32 indexed id,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes32 realToken
    );
    event RevertBurnCompleted(bytes32 indexed id, address indexed to, uint256 amount, address token);
    event CreatedRepresentation(bytes32 indexed rtoken, address indexed stoken);

    function initializeFunc(address _bridge, address _whitelist) public initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();

        versionRecipient = "2.2.3";
        bridge = _bridge;
        whitelist = _whitelist;
    }

    modifier onlyBridge() {
        require(bridge == msg.sender, "Synthesis: bridge only");
        _;
    }

    modifier onlyTrusted() {
        require(bridge == msg.sender || proxy == msg.sender || proxyV2 == msg.sender, "Synthesis: only trusted contract");
        _;
    }

    struct TxState {
        bytes32 from;
        bytes32 to;
        uint256 amount;
        bytes32 token;
        address stoken;
        RequestState state;
    }

    struct SynthParams {
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
    }

    struct SynthParamsMetaSwap {
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
        address swapReceiveSide;
        address swapOppositeBridge;
        uint256 swapChainId;
        address swappedToken;
        address path;
        address to;
        uint256 amountOutMin;
        uint256 deadline;
        address from;
        uint256 initialChainId;
    }

    struct RepresentationParams {
        bytes32 rtoken;
        uint8 decimals;
        string name;
        string symbol;
        uint256 chainId;
        string chainSymbol;
    }

    /**
     * @dev Mints synthetic token. Can be called only by bridge after initiation on a second chain.
     * @param _txID transaction ID
     * @param _tokenReal real token address
     * @param _amount amount to mint
     * @param _to recipient address
     */
    function mintSyntheticToken(
        bytes32 _txID,
        address _tokenReal,
        uint256 _amount,
        address _to
    ) external onlyTrusted {
        require(
            synthesizeStates[_txID] == SynthesizeState.Default,
            "Synthesis: emergencyUnsynthesizedRequest called or tokens have been synthesized"
        );

        ISyntERC20(representationSynt[castToBytes32(_tokenReal)]).mint(_to, _amount);
        synthesizeStates[_txID] = SynthesizeState.Synthesized;

        emit SynthesizeCompleted(_txID, _to, _amount, _tokenReal);
    }

    /**
     * @dev Transfers synthetic token to another chain.
     * @param _tokenSynth synth token address
     * @param _amount amount to transfer
     * @param _to recipient address
     * @param _from msg sender address
     * @param _synthParams synth transfer parameters
     */
    function synthTransfer(
        address _tokenSynth,
        uint256 _amount,
        address _from,
        address _to,
        SynthParams calldata _synthParams
    ) external {
        require(_tokenSynth != address(0), "Synthesis: synth address zero");
        bytes32 tokenReal = representationReal[_tokenSynth];
        require(IWhitelist(whitelist).tokenList(_tokenSynth), "Synth must be whitelisted");
        require(tokenReal != 0, "Synthesis: real token not found");
        require(
            ISyntERC20(_tokenSynth).getChainId() != _synthParams.chainId,
            "Synthesis: can not synthesize in the intial chain"
        );
        ISyntERC20(_tokenSynth).burn(msg.sender, _amount);

        uint256 nonce = IBridge(bridge).getNonce(_from);
        bytes32 txID = RequestIdLib.prepareRqId(
            castToBytes32(_synthParams.oppositeBridge),
            _synthParams.chainId,
            block.chainid,
            castToBytes32(_synthParams.receiveSide),
            castToBytes32(_from),
            nonce
        );

        bytes memory out = abi.encodeWithSelector(
            bytes4(keccak256(bytes("mintSyntheticToken(bytes32,address,uint256,address)"))),
            txID,
            tokenReal,
            _amount,
            _to
        );

        IBridge(bridge).transmitRequestV2(
            out,
            _synthParams.receiveSide,
            _synthParams.oppositeBridge,
            _synthParams.chainId,
            txID,
            _from,
            nonce
        );
        TxState storage txState = requests[txID];
        txState.from = castToBytes32(_from);
        txState.to = castToBytes32(_to);
        txState.stoken = _tokenSynth;
        txState.amount = _amount;
        txState.state = RequestState.Sent;

        emit SynthTransfer(txID, _from, _to, _amount, tokenReal);
    }

    /**
     * @dev Revert synthesize() operation, can be called several times.
     * @param _txID transaction ID
     * @param _receiveSide request recipient address
     * @param _oppositeBridge opposite bridge address
     * @param _chainId opposite chain ID
     * @param _v must be a valid part of the signature from tx owner
     * @param _r must be a valid part of the signature from tx owner
     * @param _s must be a valid part of the signature from tx owner
     */
    function emergencyUnsyntesizeRequest(
        bytes32 _txID,
        address _receiveSide,
        address _oppositeBridge,
        uint256 _chainId,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        require(synthesizeStates[_txID] != SynthesizeState.Synthesized, "Synthesis: synthetic tokens already minted");
        synthesizeStates[_txID] = SynthesizeState.RevertRequest; // close
        bytes memory out = abi.encodeWithSelector(
            bytes4(keccak256(bytes("emergencyUnsynthesize(bytes32,address,uint8,bytes32,bytes32"))),
            _txID,
            msg.sender,
            _v,
            _r,
            _s
        );

        uint256 nonce = IBridge(bridge).getNonce(msg.sender);
        bytes32 txID = RequestIdLib.prepareRqId(
            castToBytes32(_oppositeBridge),
            _chainId,
            block.chainid,
            castToBytes32(_receiveSide),
            castToBytes32(msg.sender),
            nonce
        );
        IBridge(bridge).transmitRequestV2(out, _receiveSide, _oppositeBridge, _chainId, txID, msg.sender, nonce);

        emit RevertSynthesizeRequest(txID, msg.sender);
    }

    /**
     * @dev Burns given synthetic token and unlocks the original one in the destination chain.
     * @param _stoken transaction ID
     * @param _amount amount to burn
     * @param _to recipient address
     * @param _synthParams transfer parameters
     */
    function burnSyntheticToken(
        address _stoken,
        uint256 _amount,
        address _from,
        address _to,
        SynthParams calldata _synthParams
    ) external returns (bytes32 txID) {
        ISyntERC20(_stoken).burn(msg.sender, _amount);
        uint256 nonce = IBridge(bridge).getNonce(_from);
        txID = RequestIdLib.prepareRqId(
            castToBytes32(_synthParams.oppositeBridge),
            _synthParams.chainId,
            block.chainid,
            castToBytes32(_synthParams.receiveSide),
            castToBytes32(_from),
            nonce
        );

        bytes memory out = abi.encodeWithSelector(
            bytes4(keccak256(bytes("unsynthesize(bytes32,address,uint256,address)"))),
            txID,
            representationReal[_stoken],
            _amount,
            _to
        );

        IBridge(bridge).transmitRequestV2(
            out,
            _synthParams.receiveSide,
            _synthParams.oppositeBridge,
            _synthParams.chainId,
            txID,
            _from,
            nonce
        );
        TxState storage txState = requests[txID];
        txState.from = castToBytes32(_from);
        txState.to = castToBytes32(_to);
        txState.stoken = _stoken;
        txState.amount = _amount;
        txState.state = RequestState.Sent;

        emit BurnRequest(txID, _from, _to, _amount, _stoken);
    }

    function burnSyntheticTokenWithSwap(
        address _stoken,
        uint256 _amount,
        address _from,
        address _to,
        SynthParams calldata _synthParams,
        SynthParamsMetaSwap calldata _synthSwapParams,
        SynthParams calldata _finalSynthParams
    ) external returns (bytes32 txID) {
        ISyntERC20(_stoken).burn(msg.sender, _amount);
        uint256 nonce = IBridge(bridge).getNonce(_from);
        txID = RequestIdLib.prepareRqId(
            castToBytes32(_synthParams.oppositeBridge),
            _synthParams.chainId,
            block.chainid,
            castToBytes32(_synthParams.receiveSide),
            castToBytes32(_from),
            nonce
        );

        bytes memory out = abi.encodeWithSelector(
            bytes4(keccak256(bytes("unsynthesizeWithSwap(bytes32,address,uint256,address,(address,address,uint256,address,address,uint256,address,address,address,uint256,uint256,address,uint256),(address,address,uint256))"))),
            txID,
            representationReal[_stoken],
            _amount,
            _to,
            _synthSwapParams,
            _finalSynthParams
        );

        IBridge(bridge).transmitRequestV2(
            out,
            _synthParams.receiveSide,
            _synthParams.oppositeBridge,
            _synthParams.chainId,
            txID,
            _from,
            nonce
        );
        TxState storage txState = requests[txID];
        txState.from = castToBytes32(_from);
        txState.to = castToBytes32(_to);
        txState.stoken = _stoken;
        txState.amount = _amount;
        txState.state = RequestState.Sent;

        emit BurnRequest(txID, _from, _to, _amount, _stoken);
    }

    function burnSyntheticTokenWithSwapWithUnwrap(
        address _stoken,
        uint256 _amount,
        address _from,
        address _to,
        SynthParams calldata _synthParams,
        SynthParamsMetaSwap calldata _synthSwapParams
    ) external returns (bytes32 txID) {
        ISyntERC20(_stoken).burn(msg.sender, _amount);
        uint256 nonce = IBridge(bridge).getNonce(_from);
        txID = RequestIdLib.prepareRqId(
            castToBytes32(_synthParams.oppositeBridge),
            _synthParams.chainId,
            block.chainid,
            castToBytes32(_synthParams.receiveSide),
            castToBytes32(_from),
            nonce
        );

        bytes memory out = abi.encodeWithSelector(
            bytes4(keccak256(bytes("unsynthesizeWithSwapUnwrap(bytes32,address,uint256,address,(address,address,uint256,address,address,uint256,address,address,address,uint256,uint256,address,uint256))"))),
            txID,
            representationReal[_stoken],
            _amount,
            _to,
            _synthSwapParams
        );

        IBridge(bridge).transmitRequestV2(
            out,
            _synthParams.receiveSide,
            _synthParams.oppositeBridge,
            _synthParams.chainId,
            txID,
            _from,
            nonce
        );
        TxState storage txState = requests[txID];
        txState.from = castToBytes32(_from);
        txState.to = castToBytes32(_to);
        txState.stoken = _stoken;
        txState.amount = _amount;
        txState.state = RequestState.Sent;

        emit BurnRequest(txID, _from, _to, _amount, _stoken);
    }

    function burnSyntheticTokenWithMetaExchange(
        IPortal.SynthesizeParams calldata _tokenParams,
        ICurveProxy.tokenSwapWithMetaParams calldata _exchangeParams,
        ICurveProxy.MetaExchangeParams calldata _params,
        IPortal.SynthParams calldata _finalSynthParams,
        IPortal.SynthParams calldata _synthParams,
        ICurveProxy.FeeParams memory _feeParams
    ) external returns (bytes32 txID) {
        require(IWhitelist(whitelist).tokenList(_tokenParams.token), "Token must be whitelisted");
        require(IWhitelist(whitelist).tokenList(_exchangeParams.tokenToSwap), "Token must be whitelisted");
        require(IWhitelist(whitelist).checkDestinationToken(_params.remove, _params.x), "Token must be whitelisted");
        // TODO: commented due gib size. Uncomment.
        // require(IWhitelist(whitelist).dexList(_exchangeParams.uniswapRouterV2), "Dex must be whitelisted");
        ISyntERC20(_tokenParams.token).burn(msg.sender, _tokenParams.amount);
        uint256 nonce = IBridge(bridge).getNonce(_tokenParams.from);
        txID = RequestIdLib.prepareRqId(
            castToBytes32(_synthParams.oppositeBridge),
            _synthParams.chainId,
            block.chainid,
            castToBytes32(_synthParams.receiveSide),
            castToBytes32(_tokenParams.from),
            nonce
        );

        IBridge(bridge).transmitRequestV2(
            abi.encodeWithSelector(
                bytes4(keccak256(bytes("unsynthesizeWithMetaExchange(bytes32,address,uint256,address,(address,uint256,address,uint256,uint256,address,address),(address,address,address,uint256,int128,int128,uint256,int128,uint256,address,address,address,address,uint256),(address,address,uint256),(address,uint256,uint256))"))),
                txID,
                representationReal[_tokenParams.token],
                _tokenParams.amount,
                _tokenParams.to,
                _exchangeParams,
                _params,
                _finalSynthParams,
                _feeParams
            ),
            _synthParams.receiveSide,
            _synthParams.oppositeBridge,
            _synthParams.chainId,
            txID,
            _tokenParams.from,
            nonce
        );
        TxState storage txState = requests[txID];
        txState.from = castToBytes32(_tokenParams.from);
        txState.to = castToBytes32(_tokenParams.to);
        txState.stoken = _tokenParams.token;
        txState.amount = _tokenParams.amount;
        txState.state = RequestState.Sent;

        emit BurnRequest(txID, _tokenParams.from, _tokenParams.to, _tokenParams.amount, _tokenParams.token);
    }

    /**
     * @dev Emergency unburn request. Can be called only by bridge after initiation on a second chain
     * @param _txID transaction ID to use unburn on
     */
    function emergencyUnburn(
        bytes32 _txID,
        address _trustedEmergencyExecuter,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external onlyBridge {
        TxState storage txState = requests[_txID];
        bytes32 emergencyStructHash = keccak256(
            abi.encodePacked(
                _txID,
                _trustedEmergencyExecuter,
                block.chainid,
                "emergencyUnburn(bytes32,address,uint8,bytes32,bytes32)"
            )
        );
        address txOwner = ECDSA.recover(ECDSA.toEthSignedMessageHash(emergencyStructHash), _v, _r, _s);
        require(txState.state == RequestState.Sent, "Synthesis: state not open or tx does not exist");
        require(txState.from == castToBytes32(txOwner), "Synthesis: invalid tx owner");
        txState.state = RequestState.Reverted; // close
        ISyntERC20(txState.stoken).mint(castToAddress(txState.from), txState.amount);

        emit RevertBurnCompleted(_txID, castToAddress(txState.from), txState.amount, txState.stoken);
    }

    //@deprecated due batch func
    /*function createRepresentation(
        bytes32 _rtoken,
        uint8 _decimals,
        string memory _name,
        string memory _symbol,
        uint256 _chainId,
        string memory _chainSymbol
    ) external onlyOwner {
        _createRepresentation(_rtoken, _decimals, _name, _symbol, _chainId, _chainSymbol);
    }*/

    //NOTE: For developer purpose
    function assignRepresentation(
        bytes32 _rtoken,
        address _stoken, 
        uint8 _decimals
    ) external onlyOwner {
            setRepresentation(_rtoken, _stoken, _decimals);
    }

    function _createRepresentation(
        bytes32 _rtoken,
        uint8 _decimals,
        string memory _name,
        string memory _symbol,
        uint256 _chainId,
        string memory _chainSymbol
    ) internal {
        require(representationSynt[_rtoken] == address(0), "Synthesis: representation already exists");
        require(representationReal[castToAddress(_rtoken)] == 0, "Synthesis: representation already exists");
        address stoken = Create2.deploy(
            0,
            keccak256(abi.encodePacked(_rtoken)),
            abi.encodePacked(
                type(SyntERC20).creationCode,
                abi.encode(
                    string(abi.encodePacked("s", _name, "_", _chainSymbol)),
                    string(abi.encodePacked("s", _symbol, "_", _chainSymbol)),
                    _decimals,
                    _chainId,
                    _rtoken,
                    _chainSymbol
                )
            )
        );
        setRepresentation(_rtoken, stoken, _decimals);
        emit CreatedRepresentation(_rtoken, stoken);
    }

    function createRepresentationBatch(
        RepresentationParams[] calldata params
    ) external onlyOwner {
        for(uint256 i; i<params[i].rtoken.length; i++){
            _createRepresentation(params[i].rtoken, params[i].decimals, params[i].name, params[i].symbol, params[i].chainId, params[i].chainSymbol);
        }
    }

    /**
     * @dev Creates a custom representation with the given arguments.
     * @param _rtoken real token address
     * @param _name real token name
     * @param _decimals real token decimals number
     * @param _symbol real token symbol
     * @param _chainId real token chain id
     * @param _chainSymbol real token chain symbol
     */
    function createCustomRepresentation(
        bytes32 _rtoken,
        uint8 _decimals,
        string memory _name,
        string memory _symbol,
        uint256 _chainId,
        string memory _chainSymbol
    ) external onlyOwner {
        require(representationSynt[_rtoken] == address(0), "Synthesis: representation already exists");
        require(representationReal[castToAddress(_rtoken)] == 0, "Synthesis: representation already exists");
        address stoken = Create2.deploy(
            0,
            keccak256(abi.encodePacked(_rtoken)),
            abi.encodePacked(
                type(SyntERC20).creationCode,
                abi.encode(_name, _symbol, _decimals, _chainId, _rtoken, _chainSymbol)
            )
        );
        setRepresentation(_rtoken, stoken, _decimals);
        emit CreatedRepresentation(_rtoken, stoken);
    }

    /**
     * @dev Recreates a custom representation with the given arguments.
     * @param _rtoken real token address
     * @param _name real token name
     * @param _decimals real token decimals number
     * @param _symbol real token symbol
     * @param _chainId real token chain id
     * @param _chainSymbol real token chain symbol
     */
    function recreateCustomRepresentation(
        bytes32 _rtoken,
        uint8 _decimals,
        string memory _name,
        string memory _symbol,
        uint256 _chainId,
        string memory _chainSymbol
    ) external onlyOwner {
        address stoken = Create2.deploy(
            0,
            keccak256(abi.encodePacked(_rtoken)),
            abi.encodePacked(
                type(SyntERC20).creationCode,
                abi.encode(_name, _symbol, _decimals, _chainId, _rtoken, _chainSymbol)
            )
        );
        setRepresentation(_rtoken, stoken, _decimals);
        emit CreatedRepresentation(_rtoken, stoken);
    }

    // TODO should be restricted in mainnets (use DAO)
    /*function changeBridge(address _bridge) external onlyOwner {
        bridge = _bridge;
    }*/

    function setRepresentation(
        bytes32 _rtoken,
        address _stoken,
        uint8 _decimals
    ) internal {
        representationSynt[_rtoken] = _stoken;
        representationReal[_stoken] = _rtoken;
        tokenDecimals[_rtoken] = _decimals;
        keys.push(_rtoken);
    }

    /**
     * @dev Get token representation address
     * @param _rtoken real token address
     */
    function getRepresentation(bytes32 _rtoken) external view returns (address) {
        return representationSynt[_rtoken];
    }

    /**
     * @dev Get real token address
     * @param _stoken synthetic token address
     */
    function getRealTokenAddress(address _stoken) external view returns (bytes32) {
        return representationReal[_stoken];
    }

    /**
     * @dev Get token representation list
     */
    function getListRepresentation() external view returns (bytes32[] memory, address[] memory) {
        uint256 len = keys.length;
        address[] memory sToken = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            sToken[i] = representationSynt[keys[i]];
        }
        return (keys, sToken);
    }

    /**
     * @dev Set new CurveProxy address
     * @param _proxy new contract address
     */
    function setCurveProxy(address _proxy) external onlyOwner {
        proxy = _proxy;
    }

    /**
     * @dev Set new CurveProxyV2 address
     * @param _proxy new contract address
     */
    function setCurveProxyV2(address _proxy) external onlyOwner {
        proxyV2 = _proxy;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address) {
        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        // solhint-disable-next-line no-inline-assembly
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address) {
        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash)
        );
        return address(uint160(uint256(_data)));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            // solhint-disable-next-line no-inline-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            // solhint-disable-next-line no-inline-assembly
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IBridge {
    function transmitRequestV2(
        bytes memory data,
        address receiveSide,
        address oppositeBridge,
        uint256 chainId,
        bytes32 requestId,
        address sender,
        uint256 nonce
    ) external returns (bool);

    // function transmitRequestV2ToSolana(
    //     bytes memory data,
    //     bytes32 receiveSide,
    //     bytes32 oppositeBridge,
    //     uint256 chainId,
    //     bytes32 requestId,
    //     address sender,
    //     uint256 nonce
    // ) external returns (bool);

    function getNonce(address from) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts-newone/token/ERC20/IERC20.sol";

interface ISyntERC20 is IERC20 {
    function mint(address account, uint256 amount) external;

    function mintWithAllowance(
        address account,
        address spender,
        uint256 amount
    ) external;

    function burnWithAllowanceDecrease(
        address account,
        address spender,
        uint256 amount
    ) external;

    function burn(address account, uint256 amount) external;

    function getChainId() external returns (uint256);

    function decimals() external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts-newone/access/Ownable.sol";
import "@openzeppelin/contracts-newone/token/ERC20/extensions/draft-ERC20Permit.sol";

// Synthesis must be owner of this contract
contract SyntERC20 is Ownable, ERC20Permit {
    string public _tokenName;
    bytes32 public _realTokenAddress;
    uint256 public _chainId;
    string public _chainSymbol;
    uint8 public _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimal,
        uint256 chainId,
        bytes32 realTokenAddress,
        string memory chainSymbol
    ) ERC20Permit("EYWA") ERC20(name, symbol) {
        _tokenName = name;
        _realTokenAddress = realTokenAddress;
        _chainId = chainId;
        _chainSymbol = chainSymbol;
        _decimals = decimal;
    }

    function getChainId() external view returns (uint256) {
        return _chainId;
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function mintWithAllowance(
        address account,
        address spender,
        uint256 amount
    ) external onlyOwner {
        _mint(account, amount);
        _approve(account, spender, allowance(account, spender) + amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }

    function burnWithAllowanceDecrease(
        address account,
        address spender,
        uint256 amount
    ) external onlyOwner {
        uint256 currentAllowance = allowance(account, spender);
        require(currentAllowance >= amount, "ERC20: decreased allowance below zero");

        _approve(account, spender, currentAllowance - amount);
        _burn(account, amount);
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

abstract contract Typecast {
    function castToAddress(bytes32 x) public pure returns (address) {
        return address(uint160(uint256(x)));
    }

    function castToBytes32(address a) public pure returns (bytes32) {
        return bytes32(uint256(uint160(a)));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

library RequestIdLib {
    /**
     * @dev Prepares a request ID with the given arguments.
     * @param oppositeBridge padded opposite bridge address
     * @param chainIdTo opposite chain ID
     * @param chainIdFrom current chain ID
     * @param receiveSide padded receive contract address
     * @param from padded sender's address
     * @param nonce current nonce
     */
    function prepareRqId(
        bytes32 oppositeBridge,
        uint256 chainIdTo,
        uint256 chainIdFrom,
        bytes32 receiveSide,
        bytes32 from,
        uint256 nonce
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(from, nonce, chainIdTo, chainIdFrom, receiveSide, oppositeBridge));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./IPortal.sol";
import "./ISynthesis.sol";

interface ICurveProxy {
    struct PermitData {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
        bool approveMax;
    }

    struct MetaMintEUSD {
        //crosschain pool params
        address addAtCrosschainPool;
        uint256 expectedMinMintAmountC;
        //incoming coin index for adding liq to hub pool
        uint256 lpIndex;
        //hub pool params
        address addAtHubPool;
        uint256 expectedMinMintAmountH;
        //recipient address
        address to;
    }

    struct MetaMintEUSDWithSwap {
        //crosschain pool params
        address addAtCrosschainPool;
        uint256 expectedMinMintAmountC;
        //incoming coin index for adding liq to hub pool
        uint256 lpIndex;
        //hub pool params
        address addAtHubPool;
        uint256 expectedMinMintAmountH;
        //recipient address
        address to;
        uint256 amountOutMin;
        address path;
        uint256 deadline;
    }

    struct MetaRedeemEUSD {
        //crosschain pool params
        address removeAtCrosschainPool;
        //outcome index
        int128 x;
        uint256 expectedMinAmountC;
        //hub pool params
        address removeAtHubPool;
        uint256 tokenAmountH;
        //lp index
        int128 y;
        uint256 expectedMinAmountH;
        //recipient address
        address to;
    }

    struct MetaExchangeParams {
        //pool address
        address add;
        address exchange;
        address remove;
        //add liquidity params
        uint256 expectedMinMintAmount;
        //exchange params
        int128 i; //index value for the coin to send
        int128 j; //index value of the coin to receive
        uint256 expectedMinDy;
        //withdraw one coin params
        int128 x; //index value of the coin to withdraw
        uint256 expectedMinAmount;
        //transfer to
        address to;
        //unsynth params
        address chain2address;
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
    }

    struct EmergencyUnsynthParams {
        address initialPortal;
        address initialBridge;
        uint256 initialChainID;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct MetaExchangeSwapParams {
        address swappedToken;
        address path;
        address to;
        uint256 amountOutMin;
        uint256 deadline;
    }

    struct MetaExchangeTokenParams {
        address synthToken;
        uint256 synthAmount;
        bytes32 txId;
    }

    struct tokenSwapWithMetaParams {
        address token;
        uint256 amountToSwap;
        address tokenToSwap;
        uint256 amountOutMin;
        uint256 deadline;
        address from;
        address uniswapRouterV2;
        address uniswapFactoryV2;
    }

    struct TokenInput {
        address token;
        uint256 amount;
        uint256 coinIndex;
    }

    struct FeeParams {
        address worker;
        uint256 fee;
        uint256 coinIndex;
    }

    struct LiteSwap {
        address tokenToSwap;
        address to;
        uint256 amountOutMin;
        address tokenToReceive;
        uint256 deadline;
        address from;
        uint256 amount;
        uint256 fee;
        uint256 aggregationFee;
        address uniswapRouterV2;
    }

    function addLiquidity3PoolMintEUSD(
        MetaMintEUSD calldata params,
        TokenInput calldata tokenParams
    ) external;

    function metaExchange(
        MetaExchangeParams calldata params,
        TokenInput calldata tokenParams
    ) external;

    function redeemEUSD(
        MetaRedeemEUSD calldata params,
        address receiveSide,
        address oppositeBridge,
        uint256 chainId
    ) external;

    function transitSynthBatchMetaExchange(
        MetaExchangeParams calldata _params,
        TokenInput calldata tokenParams,
        bytes32 _txId
    ) external;

    function tokenSwap(
        IPortal.SynthParamsMetaSwap calldata _synthParams,
        IPortal.SynthParams calldata _finalSynthParams,
        uint256 _amount,
        bool stable
    ) external;

    function tokenSwapWithMetaExchange(
        ICurveProxy.tokenSwapWithMetaParams calldata _exchangeParams,
        ICurveProxy.MetaExchangeParams calldata _params,
        IPortal.SynthParams calldata _synthParams,
        ICurveProxy.FeeParams memory _feeParams
    ) external;

    function removeLiquidity(
        address remove,
        int128 x,
        uint256 expectedMinAmount,
        address to,
        ISynthesis.SynthParams calldata synthParams
    ) external;

    function tokenSwapLite(
        address tokenToSwap,
        address to,
        uint256 amountOutMin,
        address tokenToReceive,
        uint256 deadline,
        address from,
        uint256 amount,
        uint256 fee,
        address uniswapRouterV2,
        IPortal.SynthParams calldata _finalSynthParams
    ) external;

    function tokenSwapLiteWithUnwrap(
        address tokenToSwap,
        address to,
        uint256 amountOutMin,
        address tokenToReceive,
        uint256 deadline,
        uint256 amount,
        uint256 aggregationFee,
        address uniswapRouterV2
    ) external;

    function tokenSwapWithUnwrap(
        IPortal.SynthParamsMetaSwap calldata _synthParams,
        uint256 _amount
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IWhitelist {
    
    function tokenList(address token) external returns (bool);

    function poolTokensList(address pool) external returns (address[] calldata);

    function checkDestinationToken(address pool, int128 index) external view returns(bool);

    function nativeReturnAmount() external returns(uint256);

    function stableFee() external returns(uint256);

    function dexList(address dexAddr) external returns (bool);

    function dexFee(address dexAddr) external returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

import "../utils/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./draft-IERC20Permit.sol";
import "../ERC20.sol";
import "../../../utils/cryptography/draft-EIP712.sol";
import "../../../utils/cryptography/ECDSA.sol";
import "../../../utils/Counters.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping (address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {
    }

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _useNonce(owner),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;
    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                block.chainid,
                address(this)
            )
        );
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./ICurveProxy.sol";

interface IPortal {
    struct PermitData {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
        bool approveMax;
    }

    struct SynthParams {
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
    }

    struct SynthParamsMetaSwap {
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
        address swapReceiveSide;
        address swapOppositeBridge;
        uint256 swapChainId;
        address swappedToken;
        address path;
        address to;
        uint256 amountOutMin;
        uint256 deadline;
        address from;
        uint256 initialChainId;
        address uniswapRouterV2;
        address uniswapFactoryV2;
        uint256 aggregationFee;
    }

    struct SynthesizeParams {
        address token;
        uint256 amount;
        address from;
        address to;
    }

    function synthesize(
        address token,
        uint256 amount,
        address from,
        address to,
        SynthParams calldata params
    ) external;

    function emergencyUnburnRequest(
        bytes32 txID,
        address receiveSide,
        address oppositeBridge,
        uint256 chainId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function synthBatchMetaExchange(
        address _from,
        SynthParams memory _synthParams,
        ICurveProxy.MetaExchangeParams memory _metaParams,
        ICurveProxy.TokenInput calldata tokenParams
    ) external;

    function synthBatchAddLiquidity3PoolMintEUSD(
        address _from,
        SynthParams memory _synthParams,
        ICurveProxy.MetaMintEUSD memory _metaParams,
        ICurveProxy.TokenInput calldata tokenParams
    ) external;

    function synthBatchMetaExchangeWithSwap(
        ICurveProxy.TokenInput calldata _tokenParams,
        SynthParamsMetaSwap memory _synthParams,
        SynthParams memory _finalSynthParams,
        ICurveProxy.MetaExchangeParams memory _metaParams
    ) external;

    function synthBatchMetaExchangeWithSwapWithUnwrap(
        ICurveProxy.TokenInput calldata _tokenParams,
        SynthParamsMetaSwap memory _synthParams,
        ICurveProxy.MetaExchangeParams memory _metaParams
    ) external;
    
    //Deprecated: no use in current cases
    // function tokenSwapRequest(
    //     SynthParamsMetaSwap memory _synthParams,
    //     SynthParams memory _finalSynthParams,
    //     uint256 amount
    // ) external;

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./IPortal.sol";
import "./ICurveProxy.sol";

interface ISynthesis {
    struct SynthParams {
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
    }

    struct PermitData {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
        bool approveMax;
    }

    function mintSyntheticToken(
        bytes32 txId,
        address tokenReal,
        uint256 amount,
        address to
    ) external;

    function burnSyntheticToken(
        address _stoken,
        uint256 _amount,
        address _from,
        address _to,
        SynthParams calldata _synthParams
    ) external returns (bytes32 txID);

    function getTxId() external returns (bytes32);

    function synthTransfer(
        address tokenSynth,
        uint256 amount,
        address from,
        address to,
        SynthParams calldata params
    ) external;

    function burnSyntheticTokenToSolana(
        address tokenSynth,
        address from,
        bytes32[] calldata pubkeys,
        uint256 amount,
        uint256 chainId
    ) external;

    function emergencyUnsyntesizeRequest(
        bytes32 txID,
        address receiveSide,
        address oppositeBridge,
        uint256 chainId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function emergencyUnsyntesizeRequestToSolana(
        address from,
        bytes32[] calldata pubkeys,
        bytes1 bumpSynthesizeRequest,
        uint256 chainId
    ) external;

    function burnSyntheticTokenWithSwap(
        address _stoken,
        uint256 _amount,
        address _from,
        address _to,
        SynthParams calldata _synthParams,
        IPortal.SynthParamsMetaSwap calldata _synthSwapParams,
        IPortal.SynthParams calldata _finalSynthParams
    ) external returns (bytes32 txID);

    function burnSyntheticTokenWithSwapWithUnwrap(
        address _stoken,
        uint256 _amount,
        address _from,
        address _to,
        SynthParams calldata _synthParams,
        IPortal.SynthParamsMetaSwap calldata _synthSwapParams
    ) external returns (bytes32 txID);

    function getRepresentation(bytes32 _rtoken) external view returns (address);

    function burnSyntheticTokenWithMetaExchange(
        IPortal.SynthesizeParams calldata _tokenParams,
        ICurveProxy.tokenSwapWithMetaParams calldata _exchangeParams,
        ICurveProxy.MetaExchangeParams calldata _params,
        IPortal.SynthParams calldata _finalSynthParams,
        IPortal.SynthParams calldata _synthParams,
        ICurveProxy.FeeParams memory _feeParams
    ) external;
}