// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "./interfaces/IBridge.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "../utils/RelayRecipientUpgradeable.sol";
import "./interfaces/IWrapper.sol";
import "./metarouter/interfaces/IMetaRouter.sol";

/**
 * @title A contract that synthesizes tokens
 * @notice In order to create a synthetic representation on another network, the user must call synthesize function here
 * @dev All function calls are currently implemented without side effects
 */
contract Portal is RelayRecipientUpgradeable {
    /// ** PUBLIC states **

    address public wrapper;
    address public bridge;
    uint256 public requestCount;
    bool public paused;
    mapping(bytes32 => TxState) public requests;
    mapping(bytes32 => UnsynthesizeState) public unsynthesizeStates;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public tokenThreshold;
    mapping(address => bool) public tokenWhitelist;

    IMetaRouter public metaRouter;

    /// ** STRUCTS **

    enum RequestState {
        Default,
        Sent,
        Reverted
    }
    enum UnsynthesizeState {
        Default,
        Unsynthesized,
        RevertRequest
    }

    struct TxState {
        address recipient;
        address chain2address;
        uint256 amount;
        address rtoken;
        RequestState state;
    }

    struct SynthesizeWithPermitTransaction {
        uint256 stableBridgingFee;
        bytes approvalData;
        address token;
        uint256 amount;
        address chain2address;
        address receiveSide;
        address oppositeBridge;
        address revertableAddress;
        uint256 chainID;
        bytes32 clientID;
    }

    /// ** EVENTS **

    event SynthesizeRequest(
        bytes32 id,
        address indexed from,
        uint256 indexed chainID,
        address indexed revertableAddress,
        address to,
        uint256 amount,
        address token
    );

    event RevertBurnRequest(bytes32 indexed id, address indexed to);

    event ClientIdLog(bytes32 requestId, bytes32 indexed clientId);

    event MetaRevertRequest(bytes32 indexed id, address indexed to);

    event BurnCompleted(
        bytes32 indexed id,
        address indexed to,
        uint256 amount,
        uint256 bridgingFee,
        address token
    );

    event RevertSynthesizeCompleted(
        bytes32 indexed id,
        address indexed to,
        uint256 amount,
        uint256 bridgingFee,
        address token
    );

    event Paused(address account);

    event Unpaused(address account);

    event SetWhitelistToken(address token, bool activate);

    event SetTokenThreshold(address token, uint256 threshold);

    event SetMetaRouter(address metaRouter);

    /// ** MODIFIERs **

    modifier onlyBridge() {
        require(bridge == msg.sender, "Symb: caller is not the bridge");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Symb: paused");
        _;
    }

    /// ** INITIALIZER **

    /**
     * init
     */
    function initialize(
        address _bridge,
        address _trustedForwarder,
        address _wrapper,
        address _whitelistedToken,
        IMetaRouter _metaRouter
    ) public virtual initializer {
        __RelayRecipient_init(_trustedForwarder);
        bridge = _bridge;
        wrapper = _wrapper;
        metaRouter = _metaRouter;

        if (_whitelistedToken != address(0)) {
            tokenWhitelist[_whitelistedToken] = true;
        }
    }

    /// ** EXTERNAL PURE functions **

    /**
     * @notice Returns version
     */
    function versionRecipient() external pure returns (string memory) {
        return "2.0.1";
    }

    // ** EXTERNAL functions **

    /**
     * @notice Sends synthesize request
     * @dev Token -> sToken on a second chain
     * @param _stableBridgingFee Bridging fee on another network
     * @param _token The address of the token that the user wants to synthesize
     * @param _amount Number of tokens to synthesize
     * @param _chain2address The address to which the user wants to receive the synth asset on another network
     * @param _receiveSide Synthesis address on another network
     * @param _oppositeBridge Bridge address on another network
     * @param _revertableAddress An address on another network that allows the user to revert a stuck request
     * @param _chainID Chain id of the network where synthesization will take place
     */
    function synthesize(
        uint256 _stableBridgingFee,
        address _token,
        uint256 _amount,
        address _chain2address,
        address _receiveSide,
        address _oppositeBridge,
        address _revertableAddress,
        uint256 _chainID,
        bytes32 _clientID
    ) external whenNotPaused returns (bytes32) {
        require(tokenWhitelist[_token], "Symb: unauthorized token");
        require(_amount >= tokenThreshold[_token], "Symb: amount under threshold");
        TransferHelper.safeTransferFrom(
            _token,
            _msgSender(),
            address(this),
            _amount
        );

        return
        sendSynthesizeRequest(
            _stableBridgingFee,
            _token,
            _amount,
            _chain2address,
            _receiveSide,
            _oppositeBridge,
            _revertableAddress,
            _chainID,
            _clientID
        );
    }

    /**
     * @notice Sends metaSynthesizeOffchain request
     * @dev Token -> sToken on a second chain -> final token on a second chain
     * @param _metaSynthesizeTransaction metaSynthesize offchain transaction data
     */
    function metaSynthesize(
        MetaRouteStructs.MetaSynthesizeTransaction
        memory _metaSynthesizeTransaction
    ) external whenNotPaused returns (bytes32) {
        require(tokenWhitelist[_metaSynthesizeTransaction.rtoken], "Symb: unauthorized token");
        require(_metaSynthesizeTransaction.amount >= tokenThreshold[_metaSynthesizeTransaction.rtoken],
            "Symb: amount under threshold");

        TransferHelper.safeTransferFrom(
            _metaSynthesizeTransaction.rtoken,
            _msgSender(),
            address(this),
            _metaSynthesizeTransaction.amount
        );

        return sendMetaSynthesizeRequest(_metaSynthesizeTransaction);
    }

    /**
     * @notice Native -> sToken on a second chain
     * @param _stableBridgingFee Bridging fee on another network
     * @param _chain2address The address to which the user wants to receive the synth asset on another network
     * @param _receiveSide Synthesis address on another network
     * @param _oppositeBridge Bridge address on another network
     * @param _chainID Chain id of the network where synthesization will take place
     */
    function synthesizeNative(
        uint256 _stableBridgingFee,
        address _chain2address,
        address _receiveSide,
        address _oppositeBridge,
        address _revertableAddress,
        uint256 _chainID,
        bytes32 _clientID
    ) external payable whenNotPaused returns (bytes32) {
        require(tokenWhitelist[wrapper], "Symb: unauthorized token");
        require(msg.value >= tokenThreshold[wrapper], "Symb: amount under threshold");

        IWrapper(wrapper).deposit{value : msg.value}();

        return
        sendSynthesizeRequest(
            _stableBridgingFee,
            wrapper,
            msg.value,
            _chain2address,
            _receiveSide,
            _oppositeBridge,
            _revertableAddress,
            _chainID,
            _clientID
        );
    }

    /**
     * @notice Token -> sToken on a second chain withPermit
     * @param _syntWithPermitTx SynthesizeWithPermit offchain transaction data
     */
    function synthesizeWithPermit(
        SynthesizeWithPermitTransaction memory _syntWithPermitTx
    ) external whenNotPaused returns (bytes32) {
        require(tokenWhitelist[_syntWithPermitTx.token], "Symb: unauthorized token");
        require(_syntWithPermitTx.amount >= tokenThreshold[_syntWithPermitTx.token], "Symb: amount under threshold");
        {
            (
            address owner,
            uint256 value,
            uint256 deadline,
            uint8 v,
            bytes32 r,
            bytes32 s
            ) = abi.decode(
                _syntWithPermitTx.approvalData,
                (address, uint256, uint256, uint8, bytes32, bytes32)
            );
            IERC20Permit(_syntWithPermitTx.token).permit(
                owner,
                address(this),
                value,
                deadline,
                v,
                r,
                s
            );
        }

        TransferHelper.safeTransferFrom(
            _syntWithPermitTx.token,
            _msgSender(),
            address(this),
            _syntWithPermitTx.amount
        );

        return
        sendSynthesizeRequest(
            _syntWithPermitTx.stableBridgingFee,
            _syntWithPermitTx.token,
            _syntWithPermitTx.amount,
            _syntWithPermitTx.chain2address,
            _syntWithPermitTx.receiveSide,
            _syntWithPermitTx.oppositeBridge,
            _syntWithPermitTx.revertableAddress,
            _syntWithPermitTx.chainID,
            _syntWithPermitTx.clientID
        );
    }

    /**
     * @notice Emergency unsynthesize
     * @dev Can called only by bridge after initiation on a second chain
     * @dev If a transaction arrives at the synthesization chain with an already completed revert synthesize contract will fail this transaction,
     * since the state was changed during the call to the desynthesis request
     * @param _stableBridgingFee Bridging fee
     * @param _externalID the synthesize transaction that was received from the event when it was originally called synthesize on the Portal contract
     */
    function revertSynthesize(uint256 _stableBridgingFee, bytes32 _externalID) external onlyBridge whenNotPaused {
        TxState storage txState = requests[_externalID];
        require(
            txState.state == RequestState.Sent,
            "Symb: state not open or tx does not exist"
        );
        txState.state = RequestState.Reverted;
        // close
        balanceOf[txState.rtoken] = balanceOf[txState.rtoken] - txState.amount;

        TransferHelper.safeTransfer(
            txState.rtoken,
            txState.recipient,
            txState.amount - _stableBridgingFee
        );

        TransferHelper.safeTransfer(
            txState.rtoken,
            bridge,
            _stableBridgingFee
        );

        emit RevertSynthesizeCompleted(
            _externalID,
            txState.recipient,
            txState.amount - _stableBridgingFee, 
            _stableBridgingFee,
            txState.rtoken
        );
    }

    /**
     * @notice Revert synthesize
     * @dev After revertSynthesizeRequest in Synthesis this method is called
     * @param _stableBridgingFee Bridging fee
     * @param _externalID the burn transaction that was received from the event when it was originally called burn on the Synthesis contract
     * @param _token The address of the token to unsynthesize
     * @param _amount Number of tokens to unsynthesize
     * @param _to The address to receive tokens
     */
    function unsynthesize(
        uint256 _stableBridgingFee,
        bytes32 _externalID,
        address _token,
        uint256 _amount,
        address _to
    ) external onlyBridge whenNotPaused {
        require(
            unsynthesizeStates[_externalID] == UnsynthesizeState.Default,
            "Symb: synthetic tokens emergencyUnburn"
        );
        balanceOf[_token] = balanceOf[_token] - _amount;
        unsynthesizeStates[_externalID] = UnsynthesizeState.Unsynthesized;
        TransferHelper.safeTransfer(_token, _to, _amount - _stableBridgingFee);
        TransferHelper.safeTransfer(_token, bridge, _stableBridgingFee);
        emit BurnCompleted(_externalID, _to, _amount - _stableBridgingFee, _stableBridgingFee, _token);
    }

    /**
     * @notice Unsynthesize and final call on second chain
     * @dev Token -> sToken on a first chain -> final token on a second chain
     * @param _stableBridgingFee Number of tokens to send to bridge (fee)
     * @param _externalID the metaBurn transaction that was received from the event when it was originally called metaBurn on the Synthesis contract
     * @param _to The address to receive tokens
     * @param _amount Number of tokens to unsynthesize
     * @param _rToken The address of the token to unsynthesize
     * @param _finalReceiveSide router for final call
     * @param _finalCalldata encoded call of a final function
     * @param _finalOffset offset to patch _amount to _finalCalldata
     */
    function metaUnsynthesize(
        uint256 _stableBridgingFee,
        bytes32 _externalID,
        address _to,
        uint256 _amount,
        address _rToken,
        address _finalReceiveSide,
        bytes memory _finalCalldata,
        uint256 _finalOffset
    ) external onlyBridge whenNotPaused {
        require(
            unsynthesizeStates[_externalID] == UnsynthesizeState.Default,
            "Symb: synthetic tokens emergencyUnburn"
        );

        balanceOf[_rToken] = balanceOf[_rToken] - _amount;
        unsynthesizeStates[_externalID] = UnsynthesizeState.Unsynthesized;
        TransferHelper.safeTransfer(_rToken, bridge, _stableBridgingFee);
        _amount = _amount - _stableBridgingFee;

        if (_finalCalldata.length == 0) {
            TransferHelper.safeTransfer(_rToken, _to, _amount);
            emit BurnCompleted(_externalID, address(this), _amount, _stableBridgingFee, _rToken);
            return;
        }

        // transfer ERC20 tokens to MetaRouter
        TransferHelper.safeTransfer(
            _rToken,
            address(metaRouter),
            _amount
        );

        // metaRouter call
        metaRouter.externalCall(_rToken, _amount, _finalReceiveSide, _finalCalldata, _finalOffset);

        emit BurnCompleted(_externalID, address(this), _amount, _stableBridgingFee, _rToken);
    }

    /**
     * @notice Revert burnSyntheticToken() operation
     * @dev Can called only by bridge after initiation on a second chain
     * @dev Further, this transaction also enters the relay network and is called on the other side under the method "revertBurn"
     * @param _stableBridgingFee Bridging fee on another network
     * @param _internalID the synthesize transaction that was received from the event when it was originally called burn on the Synthesize contract
     * @param _receiveSide Synthesis address on another network
     * @param _oppositeBridge Bridge address on another network
     * @param _chainId Chain id of the network
     */
    function revertBurnRequest(
        uint256 _stableBridgingFee,
        bytes32 _internalID,
        address _receiveSide,
        address _oppositeBridge,
        uint256 _chainId,
        bytes32 _clientID
    ) external whenNotPaused {
        bytes32 externalID = keccak256(abi.encodePacked(_internalID, address(this), _msgSender(), block.chainid));

        require(
            unsynthesizeStates[externalID] != UnsynthesizeState.Unsynthesized,
            "Symb: Real tokens already transfered"
        );
        unsynthesizeStates[externalID] = UnsynthesizeState.RevertRequest;

        {
            bytes memory out = abi.encodeWithSelector(
                bytes4(keccak256(bytes("revertBurn(uint256,bytes32)"))),
                _stableBridgingFee,
                externalID
            );
            IBridge(bridge).transmitRequestV2(
                out,
                _receiveSide,
                _oppositeBridge,
                _chainId
            );
        }

        emit RevertBurnRequest(_internalID, _msgSender());
        emit ClientIdLog(_internalID, _clientID);
    }

     function metaRevertRequest(
        MetaRouteStructs.MetaRevertTransaction memory _metaRevertTransaction
    ) external whenNotPaused {
         if (_metaRevertTransaction.swapCalldata.length != 0){
            bytes32 externalID = keccak256(abi.encodePacked(_metaRevertTransaction.internalID, address(this), _msgSender(), block.chainid));

            require(
                unsynthesizeStates[externalID] != UnsynthesizeState.Unsynthesized,
                "Symb: Real tokens already transfered"
            );

            unsynthesizeStates[externalID] = UnsynthesizeState.RevertRequest;

            {
                bytes memory out = abi.encodeWithSelector(
                    bytes4(keccak256(bytes("revertMetaBurn(uint256,bytes32,address,bytes,address,address,bytes)"))),
                        _metaRevertTransaction.stableBridgingFee,
                        externalID,
                        _metaRevertTransaction.router,
                        _metaRevertTransaction.swapCalldata,
                        _metaRevertTransaction.sourceChainSynthesis,
                        _metaRevertTransaction.burnToken,
                        _metaRevertTransaction.burnCalldata
                );

                IBridge(bridge).transmitRequestV2(
                    out,
                    _metaRevertTransaction.receiveSide,
                    _metaRevertTransaction.managerChainBridge,
                    _metaRevertTransaction.managerChainId
                );
                emit RevertBurnRequest(_metaRevertTransaction.internalID, _msgSender());
                emit ClientIdLog(_metaRevertTransaction.internalID, _metaRevertTransaction.clientID);
            }
         } else {
             if (_metaRevertTransaction.burnCalldata.length != 0){
                 bytes32 externalID = keccak256(abi.encodePacked(_metaRevertTransaction.internalID, address(this), _msgSender(), block.chainid));

                 require(
                     unsynthesizeStates[externalID] != UnsynthesizeState.Unsynthesized,
                     "Symb: Real tokens already transfered"
                 );

                 unsynthesizeStates[externalID] = UnsynthesizeState.RevertRequest;

                 bytes memory out = abi.encodeWithSelector(
                     bytes4(keccak256(bytes("revertBurnAndBurn(uint256,bytes32,address,address,uint256,address)"))),
                        _metaRevertTransaction.stableBridgingFee,
                         externalID,
                         address(this),
                        _metaRevertTransaction.sourceChainBridge,
                        block.chainid,
                        _msgSender()
                 );

                 IBridge(bridge).transmitRequestV2(
                     out,
                     _metaRevertTransaction.sourceChainSynthesis,
                     _metaRevertTransaction.managerChainBridge,
                     _metaRevertTransaction.managerChainId
                 );
                 emit RevertBurnRequest(_metaRevertTransaction.internalID, _msgSender());
                 emit ClientIdLog(_metaRevertTransaction.internalID, _metaRevertTransaction.clientID);
             } else {
                 bytes memory out = abi.encodeWithSelector(
                     bytes4(keccak256(bytes("revertSynthesizeRequestByBridge(uint256,bytes32,address,address,uint256,address,bytes32)"))),
                        _metaRevertTransaction.stableBridgingFee,
                        _metaRevertTransaction.internalID,
                        _metaRevertTransaction.receiveSide,
                        _metaRevertTransaction.sourceChainBridge,
                        block.chainid,
                        _msgSender(),
                        _metaRevertTransaction.clientID
                 );

                 IBridge(bridge).transmitRequestV2(
                     out,
                     _metaRevertTransaction.sourceChainSynthesis,
                     _metaRevertTransaction.managerChainBridge,
                     _metaRevertTransaction.managerChainId
                 );
             }
         }
         emit MetaRevertRequest(_metaRevertTransaction.internalID, _msgSender());
    }

    // ** ONLYOWNER functions **

    /**
     * @notice Set paused flag to true
     */
    function pause() external onlyOwner {
        paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @notice Set paused flag to false
     */
    function unpause() external onlyOwner {
        paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @notice Sets token to tokenWhitelist
     * @param _token Address of token to add to whitelist
     * @param _activate true - add to whitelist, false - remove from whitelist
     */
    function setWhitelistToken(address _token, bool _activate) external onlyOwner {
        tokenWhitelist[_token] = _activate;
        emit SetWhitelistToken(_token, _activate);
    }

    /**
     * @notice Sets minimal price for token
     * @param _token Address of token to set threshold
     * @param _threshold threshold to set
     */
    function setTokenThreshold(address _token, uint256 _threshold) external onlyOwner {
        tokenThreshold[_token] = _threshold;
        emit SetTokenThreshold(_token, _threshold);
    }

    /**
     * @notice Sets MetaRouter address
     * @param _metaRouter Address of metaRouter
     */
    function setMetaRouter(IMetaRouter _metaRouter) external onlyOwner {
        require(address(_metaRouter) != address(0), "Symb: metaRouter cannot be zero address");
        metaRouter = _metaRouter;
        emit SetMetaRouter(address(_metaRouter));
    }

    /// ** INTERNAL functions **

    /**
     * @dev Sends synthesize request
     * @dev Internal function used in synthesize, synthesizeNative, synthesizeWithPermit
     */
    function sendSynthesizeRequest(
        uint256 _stableBridgingFee,
        address _token,
        uint256 _amount,
        address _chain2address,
        address _receiveSide,
        address _oppositeBridge,
        address _revertableAddress,
        uint256 _chainID,
        bytes32 _clientID
    ) internal returns (bytes32 internalID) {
        balanceOf[_token] = balanceOf[_token] + _amount;

        if (_revertableAddress == address(0)) {
            _revertableAddress = _chain2address;
        }

        internalID = keccak256(abi.encodePacked(this, requestCount, block.chainid));
        {
            bytes32 externalID = keccak256(abi.encodePacked(internalID, _receiveSide, _revertableAddress, _chainID));

            {
                bytes memory out = abi.encodeWithSelector(
                    bytes4(
                        keccak256(
                            bytes(
                                "mintSyntheticToken(uint256,bytes32,address,uint256,uint256,address)"
                            )
                        )
                    ),
                    _stableBridgingFee,
                    externalID,
                    _token,
                    block.chainid,
                    _amount,
                    _chain2address
                );

                requests[externalID] = TxState({
                recipient : _msgSender(),
                chain2address : _chain2address,
                rtoken : _token,
                amount : _amount,
                state : RequestState.Sent
                });

                requestCount++;
                IBridge(bridge).transmitRequestV2(
                    out,
                    _receiveSide,
                    _oppositeBridge,
                    _chainID
                );
            }
        }

        emit SynthesizeRequest(
            internalID,
            _msgSender(),
            _chainID,
            _revertableAddress,
            _chain2address,
            _amount,
            _token
        );
        emit ClientIdLog(internalID, _clientID);
    }

    /**
     * @dev Sends metaSynthesizeOffchain request
     * @dev Internal function used in metaSynthesizeOffchain
     */
    function sendMetaSynthesizeRequest(
        MetaRouteStructs.MetaSynthesizeTransaction
        memory _metaSynthesizeTransaction
    ) internal returns (bytes32 internalID) {
        balanceOf[_metaSynthesizeTransaction.rtoken] =
        balanceOf[_metaSynthesizeTransaction.rtoken] +
        _metaSynthesizeTransaction.amount;

        if (_metaSynthesizeTransaction.revertableAddress == address(0)) {
            _metaSynthesizeTransaction.revertableAddress = _metaSynthesizeTransaction.chain2address;
        }

        internalID = keccak256(abi.encodePacked(this, requestCount, block.chainid));
        bytes32 externalID = keccak256(
            abi.encodePacked(internalID, _metaSynthesizeTransaction.receiveSide, _metaSynthesizeTransaction.revertableAddress, _metaSynthesizeTransaction.chainID)
        );

        MetaRouteStructs.MetaMintTransaction
        memory _metaMintTransaction = MetaRouteStructs.MetaMintTransaction(
            _metaSynthesizeTransaction.stableBridgingFee,
            _metaSynthesizeTransaction.amount,
            externalID,
            _metaSynthesizeTransaction.rtoken,
            block.chainid,
            _metaSynthesizeTransaction.chain2address,
            _metaSynthesizeTransaction.swapTokens,
            _metaSynthesizeTransaction.secondDexRouter,
            _metaSynthesizeTransaction.secondSwapCalldata,
            _metaSynthesizeTransaction.finalReceiveSide,
            _metaSynthesizeTransaction.finalCalldata,
            _metaSynthesizeTransaction.finalOffset
        );

        {
            bytes memory out = abi.encodeWithSignature(
            "metaMintSyntheticToken((uint256,uint256,bytes32,address,uint256,address,address[],"
            "address,bytes,address,bytes,uint256))",
            _metaMintTransaction
            );

            requests[externalID] = TxState({
            recipient : _metaSynthesizeTransaction.syntCaller,
            chain2address : _metaSynthesizeTransaction.chain2address,
            rtoken : _metaSynthesizeTransaction.rtoken,
            amount : _metaSynthesizeTransaction.amount,
            state : RequestState.Sent
            });

            requestCount++;
            IBridge(bridge).transmitRequestV2(
                out,
                _metaSynthesizeTransaction.receiveSide,
                _metaSynthesizeTransaction.oppositeBridge,
                _metaSynthesizeTransaction.chainID
            );
        }

        emit SynthesizeRequest(
            internalID,
            _metaSynthesizeTransaction.syntCaller,
            _metaSynthesizeTransaction.chainID,
            _metaSynthesizeTransaction.revertableAddress,
            _metaSynthesizeTransaction.chain2address,
            _metaSynthesizeTransaction.amount,
            _metaSynthesizeTransaction.rtoken
        );
        emit ClientIdLog(internalID, _metaSynthesizeTransaction.clientID);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
    constructor() {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

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
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IBridge {
  function transmitRequestV2(
    bytes memory _callData,
    address _receiveSide,
    address _oppositeBridge,
    uint256 _chainId
  ) external;
  
  function receiveRequestV2(
    bytes memory _callData,
    address _receiveSide
  ) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract RelayRecipientUpgradeable is OwnableUpgradeable {
    address private _trustedForwarder;

    function __RelayRecipient_init(address trustedForwarder)
        internal
        onlyInitializing
    {
        __Ownable_init();
        _trustedForwarder = trustedForwarder;
    }

    function isTrustedForwarder(address forwarder)
        public
        view
        virtual
        returns (bool)
    {
        return forwarder == _trustedForwarder;
    }

    function _msgSender()
        internal
        view
        virtual
        override
        returns (address sender)
    {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData()
        internal
        view
        virtual
        override
        returns (bytes calldata)
    {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IWrapper {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "../MetaRouteStructs.sol";

interface IMetaRouter {
    function metaRoute(
        MetaRouteStructs.MetaRouteTransaction calldata _metarouteTransaction
    ) external payable;

    function externalCall(
        address _token,
        uint256 _amount,
        address _receiveSide,
        bytes calldata _calldata,
        uint256 _offset
    ) external;

    function returnSwap(
        address _token,
        uint256 _amount,
        address _router,
        bytes calldata _swapCalldata,
        address _burnToken,
        address _synthesis,
        bytes calldata _burnCalldata
    ) external;

    function metaMintSwap(
        MetaRouteStructs.MetaMintTransaction calldata _metaMintTransaction
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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
        __Context_init_unchained();
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
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

library MetaRouteStructs {
    struct MetaBurnTransaction {
        uint256 stableBridgingFee;
        uint256 amount;
        address syntCaller;
        address finalReceiveSide;
        address sToken;
        bytes finalCallData;
        uint256 finalOffset;
        address chain2address;
        address receiveSide;
        address oppositeBridge;
        address revertableAddress;
        uint256 chainID;
        bytes32 clientID;
    }

    struct MetaMintTransaction {
        uint256 stableBridgingFee;
        uint256 amount;
        bytes32 externalID;
        address tokenReal;
        uint256 chainID;
        address to;
        address[] swapTokens;
        address secondDexRouter;
        bytes secondSwapCalldata;
        address finalReceiveSide;
        bytes finalCalldata;
        uint256 finalOffset;
    }

    struct MetaRouteTransaction {
        bytes firstSwapCalldata;
        bytes secondSwapCalldata;
        address[] approvedTokens;
        address firstDexRouter;
        address secondDexRouter;
        uint256 amount;
        bool nativeIn;
        address relayRecipient;
        bytes otherSideCalldata;
    }

    struct MetaSynthesizeTransaction {
        uint256 stableBridgingFee;
        uint256 amount;
        address rtoken;
        address chain2address;
        address receiveSide;
        address oppositeBridge;
        address syntCaller;
        uint256 chainID;
        address[] swapTokens;
        address secondDexRouter;
        bytes secondSwapCalldata;
        address finalReceiveSide;
        bytes finalCalldata;
        uint256 finalOffset;
        address revertableAddress;
        bytes32 clientID;
    }

    struct MetaRevertTransaction {
        uint256 stableBridgingFee;
        bytes32 internalID;
        address receiveSide;
        address managerChainBridge;
        address sourceChainBridge;
        uint256 managerChainId;
        uint256 sourceChainId;
        address router;
        bytes swapCalldata;
        address sourceChainSynthesis;
        address burnToken;
        bytes burnCalldata;
        bytes32 clientID;
    }
}