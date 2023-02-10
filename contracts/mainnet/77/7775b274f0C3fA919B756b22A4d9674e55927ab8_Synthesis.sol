// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "./interfaces/IBridge.sol";
import "./interfaces/ISyntFabric.sol";
import "../utils/RelayRecipientUpgradeable.sol";
import "./metarouter/interfaces/IMetaRouter.sol";

/**
 * @title A contract that burns (unsynthesizes) tokens
 * @dev All function calls are currently implemented without side effects
 */
contract Synthesis is RelayRecipientUpgradeable {
    /// ** PUBLIC states **

    uint256 public requestCount;
    bool public paused;
    address public bridge;
    address public fabric;
    mapping(bytes32 => SynthesizeState) public synthesizeStates;
    mapping(bytes32 => TxState) public requests;
    mapping(address => uint256) public tokenThreshold;

    IMetaRouter public metaRouter;

    /// ** STRUCTS **

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
    struct TxState {
        address recipient;
        address chain2address;
        uint256 amount;
        address token;
        address stoken;
        RequestState state;
    }

    /// ** EVENTS **

    event BurnRequest(
        bytes32 id,
        address indexed from,
        uint256 indexed chainID,
        address indexed revertableAddress,
        address to,
        uint256 amount,
        address token
    );

    event RevertSynthesizeRequest(bytes32 indexed id, address indexed to);

    event ClientIdLog(bytes32 requestId, bytes32 indexed clientId);

    event SynthesizeCompleted(
        bytes32 indexed id,
        address indexed to,
        uint256 amount,
        uint256 bridgingFee,
        address token
    );

    event RevertBurnCompleted(
        bytes32 indexed id,
        address indexed to,
        uint256 amount,
        uint256 bridgingFee,
        address token
    );

    event Paused(address account);

    event Unpaused(address account);

    event SetTokenThreshold(address token, uint256 threshold);

    event SetMetaRouter(address metaRouter);

    event SetFabric(address fabric);

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
        IMetaRouter _metaRouter
    )
        public
        virtual
        initializer
    {
        __RelayRecipient_init(_trustedForwarder);
        bridge = _bridge;
        metaRouter = _metaRouter;
    }

    /// ** EXTERNAL PURE functions **

    /**
     * @notice Returns version
     */
    function versionRecipient() external pure returns (string memory) {
        return "2.0.1";
    }

    /// ** EXTERNAL functions **

    /**
     * @notice Synthesis contract subcall with synthesis Parameters
     * @dev Can called only by bridge after initiation on a second chain
     * @param _stableBridgingFee Bridging fee
     * @param _externalID the synthesize transaction that was received from the event when it was originally called burn on the Synthesize contract
     * @param _tokenReal The address of the token that the user wants to synthesize
     * @param _chainID Chain id of the network where synthesization will take place
     * @param _amount Number of tokens to synthesize
     * @param _to The address to which the user wants to receive the synth asset on another network
     */
    function mintSyntheticToken(
        uint256 _stableBridgingFee,
        bytes32 _externalID,
        address _tokenReal,
        uint256 _chainID,
        uint256 _amount,
        address _to
    ) external onlyBridge whenNotPaused {
        require(
            synthesizeStates[_externalID] == SynthesizeState.Default,
            "Symb: revertSynthesizedRequest called or tokens have been already synthesized"
        );

        synthesizeStates[_externalID] = SynthesizeState.Synthesized;
        address syntReprAddr = ISyntFabric(fabric).getSyntRepresentation(_tokenReal, _chainID);

        require(syntReprAddr != address(0), "Symb: There is no synt representation for this token");

        ISyntFabric(fabric).synthesize(
            _to,
            _amount - _stableBridgingFee,
            syntReprAddr
        );

        ISyntFabric(fabric).synthesize(
            bridge,
            _stableBridgingFee,
            syntReprAddr
        );
        emit SynthesizeCompleted(_externalID, _to, _amount - _stableBridgingFee, _stableBridgingFee, _tokenReal);
    }

    /**
     * @notice Mint token assets and call second swap and final call
     * @dev Can called only by bridge after initiation on a second chain
     * @param _metaMintTransaction metaMint offchain transaction data
     */
    function metaMintSyntheticToken(
        MetaRouteStructs.MetaMintTransaction memory _metaMintTransaction
    ) external onlyBridge whenNotPaused {
        require(
            synthesizeStates[_metaMintTransaction.externalID] ==
                SynthesizeState.Default,
            "Symb: revertSynthesizedRequest called or tokens have been already synthesized"
        );

        synthesizeStates[_metaMintTransaction.externalID] = SynthesizeState
            .Synthesized;

        address syntReprAddr = ISyntFabric(fabric).getSyntRepresentation(
            _metaMintTransaction.tokenReal,
            _metaMintTransaction.chainID
        );

        require(syntReprAddr != address(0), "Symb: There is no synt representation for this token");

        ISyntFabric(fabric).synthesize(
            address(this),
            _metaMintTransaction.amount - _metaMintTransaction.stableBridgingFee,
            syntReprAddr
        );

        ISyntFabric(fabric).synthesize(
            bridge,
            _metaMintTransaction.stableBridgingFee,
            syntReprAddr
        );

        _metaMintTransaction.amount = _metaMintTransaction.amount - _metaMintTransaction.stableBridgingFee;

        emit SynthesizeCompleted(
            _metaMintTransaction.externalID,
            _metaMintTransaction.to,
            _metaMintTransaction.amount,
            _metaMintTransaction.stableBridgingFee,
            _metaMintTransaction.tokenReal
        );

        if (_metaMintTransaction.swapTokens.length == 0) {
            TransferHelper.safeTransfer(
                syntReprAddr,
                _metaMintTransaction.to,
                _metaMintTransaction.amount
            );
            return;
        }

        // transfer ERC20 tokens to MetaRouter
        TransferHelper.safeTransfer(
            _metaMintTransaction.swapTokens[0],
            address(metaRouter),
            _metaMintTransaction.amount
        );

        // metaRouter swap
        metaRouter.metaMintSwap(_metaMintTransaction);
    }

    /**
     * @notice Revert synthesize() operation
     * @dev Can called only by bridge after initiation on a second chain
     * @dev Further, this transaction also enters the relay network and is called on the other side under the method "revertSynthesize"
     * @param _stableBridgingFee Bridging fee on another network
     * @param _internalID the synthesize transaction that was received from the event when it was originally called synthesize on the Portal contract
     * @param _receiveSide Synthesis address on another network
     * @param _oppositeBridge Bridge address on another network
     * @param _chainID Chain id of the network
     */
    function revertSynthesizeRequest(
        uint256 _stableBridgingFee,
        bytes32 _internalID,
        address _receiveSide,
        address _oppositeBridge,
        uint256 _chainID,
        bytes32 _clientID
    ) external whenNotPaused {
        bytes32 externalID = keccak256(abi.encodePacked(_internalID, address(this), _msgSender(), block.chainid));

        require(
            synthesizeStates[externalID] != SynthesizeState.Synthesized,
            "Symb: synthetic tokens already minted"
        );
        synthesizeStates[externalID] = SynthesizeState.RevertRequest; // close

        {
            bytes memory out = abi.encodeWithSelector(
                bytes4(keccak256(bytes("revertSynthesize(uint256,bytes32)"))),
                _stableBridgingFee,
                externalID
            );
            IBridge(bridge).transmitRequestV2(
                out,
                _receiveSide,
                _oppositeBridge,
                _chainID
            );
        }

        emit RevertSynthesizeRequest(_internalID, _msgSender());
        emit ClientIdLog(_internalID, _clientID);
    }

    function revertSynthesizeRequestByBridge(
        uint256 _stableBridgingFee,
        bytes32 _internalID,
        address _receiveSide,
        address _oppositeBridge,
        uint256 _chainID,
        address _sender,
        bytes32 _clientID
    ) external whenNotPaused onlyBridge{
        bytes32 externalID = keccak256(abi.encodePacked(_internalID, address(this), _sender, block.chainid));
        require(
            synthesizeStates[externalID] != SynthesizeState.Synthesized,
            "Symb: synthetic tokens already minted"
        );
        synthesizeStates[externalID] = SynthesizeState.RevertRequest; // close

        {
            bytes memory out = abi.encodeWithSelector(
                bytes4(keccak256(bytes("revertSynthesize(uint256,bytes32)"))),
                _stableBridgingFee,
                externalID
            );
            IBridge(bridge).transmitRequestV2(
                out,
                _receiveSide,
                _oppositeBridge,
                _chainID
            );
        }
        emit ClientIdLog(_internalID, _clientID);
        emit RevertSynthesizeRequest(_internalID, _sender);
    }

    /**
     * @notice Sends burn request
     * @dev sToken -> Token on a second chain
     * @param _stableBridgingFee Bridging fee on another network
     * @param _stoken The address of the token that the user wants to burn
     * @param _amount Number of tokens to burn
     * @param _chain2address The address to which the user wants to receive tokens
     * @param _receiveSide Synthesis address on another network
     * @param _oppositeBridge Bridge address on another network
     * @param _revertableAddress An address on another network that allows the user to revert a stuck request
     * @param _chainID Chain id of the network where burning will take place
     */
    function burnSyntheticToken(
        uint256 _stableBridgingFee,
        address _stoken,
        uint256 _amount,
        address _chain2address,
        address _receiveSide,
        address _oppositeBridge,
        address _revertableAddress,
        uint256 _chainID,
        bytes32 _clientID
    ) external whenNotPaused returns (bytes32 internalID) {
        require(_amount >= tokenThreshold[_stoken], "Symb: amount under threshold");
        ISyntFabric(fabric).unsynthesize(_msgSender(), _amount, _stoken);
        if (_revertableAddress == address(0)) {
            _revertableAddress = _chain2address;
        }

        {
            address rtoken = ISyntFabric(fabric).getRealRepresentation(_stoken);
            require(rtoken != address(0), "Symb: incorrect synt");

            internalID = keccak256(
                abi.encodePacked(this, requestCount, block.chainid)
            );
            bytes32 externalID = keccak256(abi.encodePacked(internalID, _receiveSide, _revertableAddress, _chainID));

            bytes memory out = abi.encodeWithSelector(
                bytes4(
                    keccak256(
                        bytes("unsynthesize(uint256,bytes32,address,uint256,address)")
                    )
                ),
                _stableBridgingFee,
                externalID,
                rtoken,
                _amount,
                _chain2address
            );

            requests[externalID] = TxState({
                recipient: _msgSender(),
                chain2address: _chain2address,
                token: rtoken,
                stoken: _stoken,
                amount: _amount,
                state: RequestState.Sent
            });

            requestCount++;

            IBridge(bridge).transmitRequestV2(
                out,
                _receiveSide,
                _oppositeBridge,
                _chainID
            );
        }
        emit BurnRequest(internalID, _msgSender(), _chainID, _revertableAddress, _chain2address, _amount, _stoken);
        emit ClientIdLog(internalID, _clientID);
    }

    /**
     * @notice Sends metaBurn request
     * @dev sToken -> Token -> finalToken on a second chain
     * @param _metaBurnTransaction metaBurn transaction data
     */
    function metaBurnSyntheticToken(
        MetaRouteStructs.MetaBurnTransaction memory _metaBurnTransaction
    ) external whenNotPaused returns (bytes32 internalID) {
        require(_metaBurnTransaction.amount >= tokenThreshold[_metaBurnTransaction.sToken], "Symb: amount under threshold");

        ISyntFabric(fabric).unsynthesize(
            _msgSender(),
            _metaBurnTransaction.amount,
            _metaBurnTransaction.sToken
        );

        if (_metaBurnTransaction.revertableAddress == address(0)) {
            _metaBurnTransaction.revertableAddress = _metaBurnTransaction.chain2address;
        }

        {
            address rtoken = ISyntFabric(fabric).getRealRepresentation(
                _metaBurnTransaction.sToken
            );
            require(rtoken != address(0), "Symb: incorrect synt");

            internalID = keccak256(
                abi.encodePacked(this, requestCount, block.chainid)
            );
            bytes32 externalID = keccak256(abi.encodePacked(internalID, _metaBurnTransaction.receiveSide, _metaBurnTransaction.revertableAddress, _metaBurnTransaction.chainID)); // external ID
            bytes memory out = abi.encodeWithSelector(
                bytes4(
                    keccak256(
                        bytes(
                            "metaUnsynthesize(uint256,bytes32,address,uint256,address,address,bytes,uint256)"
                        )
                    )
                ),
                _metaBurnTransaction.stableBridgingFee,
                externalID,
                _metaBurnTransaction.chain2address,
                _metaBurnTransaction.amount,
                rtoken,
                _metaBurnTransaction.finalReceiveSide,
                _metaBurnTransaction.finalCallData,
                _metaBurnTransaction.finalOffset
            );

            requests[externalID] = TxState({
                recipient: _metaBurnTransaction.syntCaller,
                chain2address: _metaBurnTransaction.chain2address,
                token: rtoken,
                stoken: _metaBurnTransaction.sToken,
                amount: _metaBurnTransaction.amount,
                state: RequestState.Sent
            });

            requestCount++;
            IBridge(bridge).transmitRequestV2(
                out,
                _metaBurnTransaction.receiveSide,
                _metaBurnTransaction.oppositeBridge,
                _metaBurnTransaction.chainID
            );
        }

        emit BurnRequest(
            internalID,
            _metaBurnTransaction.syntCaller,
            _metaBurnTransaction.chainID,
            _metaBurnTransaction.revertableAddress,
            _metaBurnTransaction.chain2address,
            _metaBurnTransaction.amount,
            _metaBurnTransaction.sToken
        );
        emit ClientIdLog(internalID, _metaBurnTransaction.clientID);
    }

    /**
     * @notice Emergency unburn
     * @dev Can called only by bridge after initiation on a second chain
     * @param _stableBridgingFee Bridging fee 
     * @param _externalID the synthesize transaction that was received from the event when it was originally called burn on the Synthesize contract
     */
    function revertBurn(uint256 _stableBridgingFee, bytes32 _externalID) external onlyBridge whenNotPaused {
        TxState storage txState = requests[_externalID];
        require(
            txState.state == RequestState.Sent,
            "Symb: state not open or tx does not exist"
        );
        txState.state = RequestState.Reverted;
        // close
        ISyntFabric(fabric).synthesize(
            txState.recipient,
            txState.amount - _stableBridgingFee,
            txState.stoken
        );
        ISyntFabric(fabric).synthesize(
            bridge,
            _stableBridgingFee,
            txState.stoken
        );
        emit RevertBurnCompleted(
            _externalID,
            txState.recipient,
            txState.amount - _stableBridgingFee,
            _stableBridgingFee,
            txState.stoken
        );
    }

    function revertBurnAndBurn(uint256 _stableBridgingFee, bytes32 _externalID, address _receiveSide, address _oppositeBridge, uint256 _chainID, address _revertableAddress) external onlyBridge whenNotPaused {
        TxState storage txState = requests[_externalID];
        require(
            txState.state == RequestState.Sent,
            "Symb: state not open or tx does not exist"
        );
        txState.state = RequestState.Reverted;
        // close
        ISyntFabric(fabric).synthesize(
            bridge,
            _stableBridgingFee,
            txState.stoken
        );
        uint256 amount = txState.amount - _stableBridgingFee;
        emit RevertBurnCompleted(
            _externalID,
            txState.recipient,
            amount,
            _stableBridgingFee,
            txState.stoken
        );

        if (_revertableAddress == address(0)) {
            _revertableAddress = txState.chain2address;
        }

        address rtoken = ISyntFabric(fabric).getRealRepresentation(txState.stoken);
        bytes32 internalID = keccak256(
            abi.encodePacked(this, requestCount, block.chainid)
        );
        bytes32 externalID = keccak256(abi.encodePacked(internalID, _receiveSide, _revertableAddress, _chainID));

        bytes memory out = abi.encodeWithSelector(
            bytes4(
                keccak256(
                    bytes("unsynthesize(uint256,bytes32,address,uint256,address)")
                )
            ),
            _stableBridgingFee,
            externalID,
            rtoken,
            amount,
            txState.chain2address
        );

        requests[externalID] = TxState({
        recipient: _msgSender(),
        chain2address: txState.chain2address,
        token: rtoken,
        stoken: txState.stoken,
        amount: amount,
        state: RequestState.Sent
        });

        requestCount++;

        IBridge(bridge).transmitRequestV2(
            out,
            _receiveSide,
            _oppositeBridge,
            _chainID
        );

        emit BurnRequest(internalID, _msgSender(), _chainID, _revertableAddress, txState.chain2address, amount, txState.stoken);
    }

    function revertMetaBurn(
        uint256 _stableBridgingFee, 
        bytes32 _externalID, 
        address _router, 
        bytes calldata _swapCalldata,
        address _synthesis,
        address _burnToken,
        bytes calldata _burnCalldata
        ) external onlyBridge whenNotPaused {
        TxState storage txState = requests[_externalID];
        require(
            txState.state == RequestState.Sent,
            "Symb: state not open or tx does not exist"
        );
        txState.state = RequestState.Reverted;
        // close    
        ISyntFabric(fabric).synthesize(
            txState.recipient,
            txState.amount - _stableBridgingFee,
            txState.stoken
        );
        ISyntFabric(fabric).synthesize(
            bridge,
            _stableBridgingFee,
            txState.stoken
        );

        IMetaRouter(metaRouter).returnSwap(txState.stoken, txState.amount - _stableBridgingFee, _router, _swapCalldata, _burnToken, _synthesis, _burnCalldata);

        emit RevertBurnCompleted(
            _externalID,
            txState.recipient,
            txState.amount - _stableBridgingFee,
            _stableBridgingFee,
            txState.stoken
        );
    }

    /// ** ONLYOWNER functions **

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

    /**
     * @notice Sets Fabric address
     * @param _fabric Address of fabric
     */
    function setFabric(address _fabric) external onlyOwner {
        require(fabric == address(0x0), "Symb: Fabric already set");
        fabric = _fabric;
        emit SetFabric(_fabric);
    }
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface ISyntFabric {
    function getRealRepresentation(address _syntTokenAdr)
        external
        view
        returns (address);

    function getSyntRepresentation(address _realTokenAdr, uint256 _chainID)
        external
        view
        returns (address);

    function synthesize(
        address _to,
        uint256 _amount,
        address _stoken
    ) external;

    function unsynthesize(
        address _to,
        uint256 _amount,
        address _stoken
    ) external;
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