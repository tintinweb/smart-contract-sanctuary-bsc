/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

// File: contracts/interface/IGenericHandlerMapper.sol


pragma solidity ^0.8.4;

abstract contract IGenericHandlerMapper {
    struct RouterLinker {
        address _rSyncContract;
        uint8 _chainID;
        address _linkedContract;
    }

    function mapContract(RouterLinker calldata linker) external virtual {}

    function unMapContract(RouterLinker calldata linker) external virtual {}
}
// File: @routerprotocol/router-crosstalk/contracts/interfaces/iGenericHandler.sol


pragma solidity ^0.8.0;

/// @title GenericHandler contract interface for router Crosstalk
/// @author Router Protocol
interface iGenericHandler {

    struct RouterLinker {
        address _rSyncContract;
        uint8 _chainID;
        address _linkedContract;
        uint8 linkerType;
    }

    /// @notice UnMapContract Unmaps the contract from the RouterCrossTalk Contract
    /// @dev This function is used to map contract from router-crosstalk contract
    /// @param linker The Data object consisting of target Contract , CHainid , Contract to be Mapped and linker type.
    /// @param _sign Signature of Linker data object signed by linkerSetter address.
    function MapContract( RouterLinker calldata linker , bytes memory _sign ) external;

    /// @notice UnMapContract Unmaps the contract from the RouterCrossTalk Contract
    /// @dev This function is used to unmap contract from router-crosstalk contract
    /// @param linker The Data object consisting of target Contract , CHainid , Contract to be unMapped and linker type.
    /// @param _sign Signature of Linker data object signed by linkerSetter address.
    function UnMapContract(RouterLinker calldata linker , bytes memory _sign ) external;

    /// @notice generic deposit on generic handler contract
    /// @dev This function is called by router crosstalk contract while initiating crosschain transaction
    /// @param _destChainID Chain id to be transacted
    /// @param _selector Selector for the crosschain interface
    /// @param _data Data to be transferred
    /// @param _hash Hash of the data sent to the contract
    /// @param _gas Gas Specified for the contract function
    /// @param _feeToken Fee Token Specified for the contract function
    function genericDeposit( uint8 _destChainID, bytes4 _selector, bytes memory _data, bytes32 _hash, uint256 _gas, address _feeToken) external;

    /// @notice Fetches ChainID for the native chain
    function fetch_chainID( ) external view returns ( uint8 );

}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @routerprotocol/router-crosstalk/contracts/interfaces/iRouterCrossTalk.sol


pragma solidity ^0.8.0;


/// @title iRouterCrossTalk contract interface for router Crosstalk
/// @author Router Protocol
interface iRouterCrossTalk is IERC165 {

    /// @notice Link event is emitted when a new link is created.
    /// @param ChainID Chain id the contract is linked to.
    /// @param linkedContract Contract address linked to.
    event Linkevent( uint8 indexed ChainID , address indexed linkedContract );

    /// @notice UnLink event is emitted when a link is removed.
    /// @param ChainID Chain id the contract is unlinked to.
    /// @param linkedContract Contract address unlinked to.
    event Unlinkevent( uint8 indexed ChainID , address indexed linkedContract );

    /// @notice CrossTalkSend Event is emited when a request is generated in soruce side when cross chain request is generated.
    /// @param sourceChain Source ChainID.
    /// @param destChain Destination ChainID.
    /// @param sourceAddress Source Address.
    /// @param destinationAddress Destination Address.
    /// @param _selector Selector to interface on destination side.
    /// @param _data Data to interface on Destination side.
    /// @param _hash Hash of the data sent.
    event CrossTalkSend(uint8 indexed sourceChain , uint8 indexed destChain , address sourceAddress , address destinationAddress ,bytes4 indexed _selector, bytes _data , bytes32 _hash );

    /// @notice CrossTalkReceive Event is emited when a request is recived in destination side when cross chain request accepted by contract.
    /// @param sourceChain Source ChainID.
    /// @param destChain Destination ChainID.
    /// @param sourceAddress Source Address.
    /// @param destinationAddress Destination Address.
    /// @param _selector Selector to interface on destination side.
    /// @param _data Data to interface on Destination side.
    /// @param _hash Hash of the data sent.
    event CrossTalkReceive(uint8 indexed sourceChain , uint8 indexed destChain , address sourceAddress , address destinationAddress ,bytes4 indexed _selector, bytes _data , bytes32 _hash );

    /// @notice routerSync This is a public function and can only be called by Generic Handler of router infrastructure
    /// @param srcChainID Source ChainID.
    /// @param srcAddress Destination ChainID.
    /// @param _selector Selector to interface on destination side.
    /// @param _data Data to interface on Destination side.
    /// @param hash Hash of the data sent.
    function routerSync(uint8 srcChainID , address srcAddress , bytes4 _selector , bytes calldata _data , bytes32 hash ) external returns ( bool , bytes memory );

    /// @notice Link This is a public function and can only be called by Generic Handler of router infrastructure
    /// @notice This function links contract on other chain ID's.
    /// @notice This is an administrative function and can only be initiated by linkSetter address.
    /// @param _chainID network Chain ID linked Contract linked to.
    /// @param _linkedContract Linked Contract address.
    function Link(uint8 _chainID , address _linkedContract) external;

    /// @notice UnLink This is a public function and can only be called by Generic Handler of router infrastructure
    /// @notice This function unLinks contract on other chain ID's.
    /// @notice This is an administrative function and can only be initiated by linkSetter address.
    /// @param _chainID network Chain ID linked Contract linked to.
    function Unlink(uint8 _chainID ) external;

    /// @notice fetchLinkSetter This is a public function and fetches the linksetter address.
    function fetchLinkSetter( ) external view returns( address );

    /// @notice fetchLinkSetter This is a public function and fetches the address the contract is linked to.
    /// @param _chainID Chain ID information.
    function fetchLink( uint8 _chainID ) external view returns( address );

    /// @notice fetchLinkSetter This is a public function and fetches the generic handler address.
    function fetchHandler( ) external view returns ( address );

    /// @notice fetchFeetToken This is a public function and fetches the fee token set by admin.
    function fetchFeetToken(  ) external view returns( address );

}


// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/interfaces/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File: @routerprotocol/router-crosstalk/contracts/RouterCrossTalk.sol


pragma solidity ^0.8.0;






/// @title RouterCrossTalk contract
/// @author Router Protocol
abstract contract RouterCrossTalk is Context , iRouterCrossTalk, ERC165 {

    iGenericHandler private handler;

    address private linkSetter;

    address private feeToken;

    mapping ( uint8 => address ) private Chain2Addr; // CHain ID to Address

    modifier isHandler(){
        require(_msgSender() == address(handler) , "RouterCrossTalk : Only GenericHandler can call this function" );
        _;
    }

    modifier isLinkSet(uint8 _chainID){
        require(Chain2Addr[_chainID] == address(0) , "RouterCrossTalk : Cross Chain Contract to Chain ID set" );
        _;
    }

    modifier isLinkUnSet(uint8 _chainID){
        require(Chain2Addr[_chainID] != address(0) , "RouterCrossTalk : Cross Chain Contract to Chain ID is not set" );
        _;
    }

    modifier isLinkSync( uint8 _srcChainID, address _srcAddress ){
        require(Chain2Addr[_srcChainID] == _srcAddress , "RouterCrossTalk : Source Address Not linked" );
        _;
    }

    modifier isSelf(){
        require(_msgSender() == address(this) , "RouterCrossTalk : Can only be called by Current Contract" );
        _;
    }

    constructor( address _handler ) {
        handler = iGenericHandler(_handler);
    }

    /// @notice Used to set linker address, this function is internal and can only be set by contract owner or admins
    /// @param _addr Address of linker.
    function setLink( address _addr ) internal {
        linkSetter = _addr;
    }

    /// @notice Used to set fee Token address, this function is internal and can only be set by contract owner or admins
    /// @param _addr Address of linker.
    function setFeeToken( address _addr ) internal {
        feeToken = _addr;
    }

    function fetchHandler( ) external override view returns ( address ) {
        return address(handler);
    }

    function fetchLinkSetter( ) external override view returns( address) {
        return linkSetter;
    }

    function fetchLink( uint8 _chainID ) external override view returns( address) {
        return Chain2Addr[_chainID];
    }

    function fetchFeetToken(  ) external override view returns( address) {
        return feeToken;
    }

    /// @notice routerSend This is internal function to generate a cross chain communication request.
    /// @param destChainId Destination ChainID.
    /// @param _selector Selector to interface on destination side.
    /// @param _data Data to be sent on Destination side.
    /// @param _gas Gas provided for cross chain send.
    function routerSend( uint8 destChainId , bytes4 _selector , bytes memory _data , uint256 _gas) internal isLinkUnSet( destChainId ) returns (bool success) {
        uint8 cid = handler.fetch_chainID();
        bytes32 hash = _hash(address(this),Chain2Addr[destChainId],destChainId, _selector, _data);
        handler.genericDeposit(destChainId , _selector , _data, hash , _gas , feeToken );
        emit CrossTalkSend( cid , destChainId , address(this), Chain2Addr[destChainId] ,_selector, _data , hash );
        return true;
    }

    function routerSync(uint8 srcChainID , address srcAddress , bytes4 _selector , bytes memory _data , bytes32 hash ) external override isLinkSync( srcChainID , srcAddress ) isHandler returns ( bool , bytes memory ) {
        uint8 cid = handler.fetch_chainID();
        bytes32 Dhash = _hash(Chain2Addr[srcChainID],address(this),cid, _selector, _data);
        require( Dhash == hash , "RouterSync : Valid Hash" );
        ( bool success , bytes memory _returnData ) = _routerSyncHandler( _selector , _data );
        emit CrossTalkReceive( srcChainID , cid , srcAddress , address(this), _selector, _data , hash );
        return ( success , _returnData );
    }

    /// @notice _hash This is internal function to generate the hash of all data sent or received by the contract.
    /// @param _srcAddress Source Address.
    /// @param _destAddress Destination Address.
    /// @param _destChainId Destination ChainID.
    /// @param _selector Selector to interface on destination side.
    /// @param _data Data to interface on Destination side.
    function _hash(address _srcAddress , address _destAddress , uint8 _destChainId , bytes4 _selector , bytes memory _data) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            _srcAddress,
            _destAddress,
            _destChainId,
            _selector,
            keccak256(_data)
        ));
    }

    function Link(uint8 _chainID , address _linkedContract) external override isHandler isLinkSet(_chainID) {
        Chain2Addr[_chainID] = _linkedContract;
        emit Linkevent( _chainID , _linkedContract );
    }

    function Unlink(uint8 _chainID ) external override isHandler {
        emit Unlinkevent( _chainID , Chain2Addr[_chainID] );
        Chain2Addr[_chainID] = address(0);
    }

    function approveFees(address _feeToken , uint256 _value) external {
        IERC20 token = IERC20(_feeToken);
        token.approve( address(handler) , _value );
    }

    /// @notice _routerSyncHandler This is internal function to control the handling of various selectors and its corresponding .
    /// @param _selector Selector to interface.
    /// @param _data Data to be handled.
    function _routerSyncHandler( bytes4 _selector , bytes memory _data ) internal virtual returns ( bool ,bytes memory );
    uint256[100] private __gap;

}

// File: contracts/MyContract.sol


pragma solidity ^0.8.4;




contract MyContract is RouterCrossTalk, IGenericHandlerMapper {
    uint256 public value;
    address public owner;
    uint256 public gasAmount;

    constructor ( address _genericHandler ) RouterCrossTalk(_genericHandler){
        owner = msg.sender;
    }
   
    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
 
    function ExternalSetValue(uint8 _chainID , uint256 _value)
        public returns( bool )
    {
        bytes memory data = abi.encode( _value);
        bytes4 _interface = bytes4(keccak256("SetValue(uint256)"));
        // ChainID - Selector - Data - Gas Usage
        bool success = routerSend(_chainID, _interface, data, gasAmount );
        return success;
    }
   
    function _routerSyncHandler(
        bytes4 _interface ,
        bytes memory _data
        ) internal virtual override  returns ( bool , bytes memory )
    {
            (uint256 _v) = abi.decode(_data, ( uint256 ));
            (bool success, bytes memory returnData) =
                address(this).call( abi.encodeWithSelector(_interface, _v) );
            return (success, returnData);
    }
 
    function SetValue( uint256 _value ) external isSelf  {
        value = _value;
    }
   
    function setLinker ( address _linker ) external onlyOwner()  {
        setLink(_linker);
    }
 
    function setFeeAddress ( address _feeAddress ) external onlyOwner() {
        setFeeToken(_feeAddress);
    }

    function setGasAmount ( uint256 _gasAmount ) external onlyOwner() {
        gasAmount = _gasAmount;
    }

    function getBackTokens(address tokenAddress) public onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function getBackNativeTokens() public onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "TRANSFER_FAILED");
    }

    function mapContract(
        address _srcGenericHandler, 
        uint8 _destChainId, 
        address _destContract
    ) external onlyOwner {
        RouterLinker memory linker = RouterLinker({
            _rSyncContract: address(this),
            _chainID: _destChainId,
            _linkedContract: _destContract
        });
        IGenericHandlerMapper(_srcGenericHandler).mapContract(linker);
    }

    function unmapContract(
        address _srcGenericHandler, 
        uint8 _destChainId, 
        address _destContract
    ) external onlyOwner {
        RouterLinker memory linker = RouterLinker({
            _rSyncContract: address(this),
            _chainID: _destChainId,
            _linkedContract: _destContract
        });
        IGenericHandlerMapper(_srcGenericHandler).unMapContract(linker);
    }

    receive() external payable {}
    
}