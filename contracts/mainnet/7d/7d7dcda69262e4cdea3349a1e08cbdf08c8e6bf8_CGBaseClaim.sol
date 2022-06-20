/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// Sources flattened with hardhat v2.9.7 https://hardhat.org

// File contracts/0_standards/interfaces/IERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9; // solhint-disable-line


interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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


// File contracts/1_lib/TransferHelper.sol

// License-Identifier: MIT

pragma solidity ^0.8.9; // solhint-disable-line

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    bytes4 constant public APROVE_SELECTOR =            bytes4(keccak256(bytes("approve(address,uint256)")));  // 0x095ea7b3
    bytes4 constant public TRANSFER_SELECTOR =          bytes4(keccak256(bytes("transfer(address,uint256)"))); // 0xa9059cbb
    bytes4 constant public TRANSFER_FROM_SELECTOR =     bytes4(keccak256(bytes("transferFrom(address,address,uint256)"))); // 0x23b872dd

    function safeApprove(IERC20 token, address to, uint value) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(APROVE_SELECTOR, to, value)); // solhint-disable-line
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TH_APPROVE_FAILED");
    }

    function safeTransfer(IERC20 token, address to, uint value) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(TRANSFER_SELECTOR, to, value)); // solhint-disable-line
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TH_TRANSFER_FAILED");
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(TRANSFER_FROM_SELECTOR, from, to, value)); // solhint-disable-line
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TH_TRANSFER_FROM_FAILED");
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0)); // solhint-disable-line
        require(success, "TH_ETH_TRANSFER_FAILED");
    }
}


// File contracts/0_standards/interfaces/IOwnable.sol

// License-Identifier: MIT

pragma solidity ^0.8.9; // solhint-disable-line


interface IOwnable {

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external;

    
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address _newOwner) external;

    function claimOwnership() external;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}


// File contracts/1_lib/Ownable.sol

// License-Identifier: MIT

pragma solidity ^0.8.9; // solhint-disable-line

abstract contract Ownable is IOwnable {
	
    address public owner;
    address public pendingOwner;

	modifier onlyOwner() {
      require (isOwner(), "NOT_OWNER");
      _;
    }

    constructor() {
        owner = msg.sender;
    }

    function hasOwner() public view returns ( bool ){
        return  owner != address(0);
    }
    
    function isOwner() public view returns ( bool ){
        return owner == msg.sender;
    }

    // function owner() public view returns (address){
    //     return _owner;
    // }

    function renounceOwnership() external onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(msg.sender, address(0));
    }

    function transferOwnership(address _newOwner) external override onlyOwner{
        require(_newOwner != address(0), "ZERO_ADDRESS_NOT_ALLOWED");
        pendingOwner = _newOwner;
    }

    function claimOwnership() external override {
        require(pendingOwner == msg.sender, "NOT_NEXT_OWNER");
        owner = pendingOwner;
        emit OwnershipTransferred(msg.sender, pendingOwner);
    }
}


// File contracts/1_lib/Abilitable.sol

// License-Identifier: MIT

pragma solidity ^0.8.9; // solhint-disable-line


/**
    Smart-Contract used by SealKey squad (https://sealkey.io)

    Smart-Contract designed by SealKey squad (https://sealkey.io)
    
    Let a sub-contract manage user's abilities.
 */
 abstract contract Abilitable is Ownable {
	//FIXME: uint8 or uint256 ? > Chose optimised gas consumption.
    uint8 public constant SLOT_EMPTY = 0x00;
    uint8 public constant SLOT_ALL = 0xFF;


    uint8 public abilitiesAdmin;
	mapping (address => uint8) public abilitiesMap; 

    event AbilitiesChange(address indexed _user, uint8 _oldAbilities, uint8 _newAbilities);

    /**
        Main decorator for sub-contract security check.
        Throw 'NOT_ABILITED' if msg.sender is not the owner AND if msg.sender has misssing given _abilities

        Let execution process for every sender that is has every abilitation flaged in _abilities
        @param _abilities given abilities flags.
     */
	modifier onlyAbilited(uint8 _abilities) {
      abilited(_abilities);
      _;
    }

    /**
        Construct Abilitable.
        @param _abilitiesAdmin Given abilities flags that can use the changeAbilities function on other user (concidered as Admins).
    */
    constructor (uint8 _abilitiesAdmin) {
        abilitiesAdmin = _abilitiesAdmin;
    }

    /**
        Return all user abilities.
        if the given user is the owner of this smart contract, return every flags to true (I.E.: <code>SLOT_ALL</code>)

        @param _user Given user
        @return all user abilities.
    */
	function getAbilities(address _user) public view returns (uint8){
        if(owner == _user){
            return SLOT_ALL;
        }
        return abilitiesMap[_user];
    }


    /**
        Base function for abilities check on sender.
        @param _abilities Given abilities to check
        @return true if and only if current msg.sender is the owner OR if users abilities has at least every given _abilities flags, false otherwise.
     */
	function hasAbilities(uint8 _abilities) public view returns (bool){
        return (getAbilities(msg.sender) & _abilities) == _abilities;
    }


    /**
        Base function for abilities check on sender.
        hrow if current msg.sender is not the owner AND if at least a given _abilities flags is missing in users , false otherwise.
        @param _abilities Given abilities to check
     */
    function abilited(uint8 _abilities) public view {
      require (hasAbilities(_abilities), "NOT_ABILITED");
    }

	/**
    Internal function for abilities change.
    Sub-SmartContract must ensure themself the security logic concerning direct call to this function, has there is no abilities check here.

    @param _user given user to change
    @param _newAbilities new user's abilities
     */
    function _changeAbilities(address _user, uint8 _newAbilities) internal {
        // require((_newAbilities & SLOT_ALL) == _newAbilities, "ILLEGAL_ABILITIES"); // uint8 do auto-mask.

        uint8 oldAbilities = abilitiesMap[_user];
        if(oldAbilities == _newAbilities){
            return;
        }

        if(_newAbilities == SLOT_EMPTY){
            delete abilitiesMap[_user];
        }else{
            abilitiesMap[_user] = _newAbilities ;
        }

        emit AbilitiesChange(_user, oldAbilities, _newAbilities);
    }


	/**
    Main function for administrating abilities.

    The function will throws:
     - "NOT_ABILITED" if current msg.sender doesn't match given _newAbilities
     - "OPERATOR_CHANGE" if current msg.sender is not an admin (see constructor)
     - "ADMIN_CHANGE" if given _user is an admin 

    @param _user given user to change
    @param _newAbilities new user's abilities
     */
    function changeAbilities(address _user, uint8 _newAbilities) public onlyAbilited(_newAbilities) {
        if(msg.sender != _user && msg.sender != owner){
            require( (getAbilities(msg.sender) & abilitiesAdmin) != 0, "OPERATOR_CHANGE");
            require( (getAbilities(_user) & abilitiesAdmin) == 0, "ADMIN_CHANGE");
        }
        _changeAbilities(_user, _newAbilities);
    }

    /**
     Function for abilities renouncment.

     Remove every abilities from msg.sender.
    */
    function renounceAbilities() external {
        _changeAbilities(msg.sender, SLOT_EMPTY);
    }


    /**
     Function for abilities transfer.

     Set every abilities from msg.sender to _to
     Remove every abilities from msg.sender.

     @param _from Address 
     @param _to Address 
    */
    function _transferAbilities(address _from, address _to) internal {
        require(_from != owner, "FROM_OWNER_UNSUPORTED");
        require(_to != owner, "TO_OWNER_UNSUPORTED");

        uint8 abilities = getAbilities(_from);
        require(abilities != 0, "NO_ABILITIES"); // FIXME: Necessary check ?

        _changeAbilities(_to, abilities);
        _changeAbilities(_from, SLOT_EMPTY);
    }


    function transferAbilities( address _to) public {
        _transferAbilities(msg.sender, _to);
    }

    /**
     Function for abilities transfer.

     Remove every abilities from msg.sender.
    */
    function _delegateAbilities(Abilitable parent, address _to) internal {
        parent.transferAbilities(_to);
    }
}


// File contracts/1_lib/NoCyclic.sol

// License-Identifier: MIT

pragma solidity ^0.8.9; // solhint-disable-line


contract NoCyclic {
	
    bool private called;

	modifier unique() {
        require (!called, "Cyclic.");
        called = true;
        _;
        called = false;
    }

    // constructor() {
    // }

}


// File contracts/2_app/IBaseClaimable.sol

// License-Identifier: MIT

pragma solidity ^0.8.9; // solhint-disable-line

/**
    Smart-Contract used by CryptoGouv Capital (https://cryptogouv.capital)

    Smart-Contract designed by SealKey squad (https://sealkey.io)

    Investment pool tools for rewards divitions between each NFT possesor
*/
interface IBaseClaimable  {
    function claimableToken() external view returns ( IERC20 );
}


// File contracts/2_app/IBaseDeposit.sol

// License-Identifier: MIT

pragma solidity ^0.8.9; // solhint-disable-line

/**
    Smart-Contract used by CryptoGouv Capital (https://cryptogouv.capital)

    Smart-Contract designed by SealKey squad (https://sealkey.io)

    Investment pool tools for rewards divitions between each NFT possesor
*/
interface IBaseDeposit is IBaseClaimable {

    function canDeposit() external view returns ( bool );
    function deposit(uint256 _amount) external returns( uint256 );
}


// File contracts/2_app/IBaseClaim.sol

// License-Identifier: MIT

pragma solidity ^0.8.9; // solhint-disable-line

/**
    Smart-Contract used by CryptoGouv Capital (https://cryptogouv.capital)

    Smart-Contract designed by SealKey squad (https://sealkey.io)

    Investment pool tools for rewards divitions between each NFT possesor
*/
interface IBaseClaim is IBaseClaimable {
    
    event Withdraw(address indexed _user, uint256 _value);

    function claimRewards() external returns ( uint256 );
    function claimRewardsFor(address _user) external returns ( uint256 );
    function getClaimableAmount(address _user) external view returns( uint256 );
}


// File contracts/0_standards/interfaces/erc721.sol

// License-Identifier: MIT

pragma solidity ^0.8.6;

/**
 * @dev ERC-721 non-fungible token standard.
 * See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md.
 */
interface ERC721
{

  /**
   * @dev Emits when ownership of any NFT changes by any mechanism. This event emits when NFTs are
   * created (`from` == 0) and destroyed (`to` == 0). Exception: during contract creation, any
   * number of NFTs may be created and assigned without emitting Transfer. At the time of any
   * transfer, the approved address for that NFT (if any) is reset to none.
   */
  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );

  /**
   * @dev This emits when the approved address for an NFT is changed or reaffirmed. The zero
   * address indicates there is no approved address. When a Transfer event emits, this also
   * indicates that the approved address for that NFT (if any) is reset to none.
   */
  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );

  /**
   * @dev This emits when an operator is enabled or disabled for an owner. The operator can manage
   * all NFTs of the owner.
   */
  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  /**
   * @dev Transfers the ownership of an NFT from one address to another address.
   * @notice Throws unless `msg.sender` is the current owner, an authorized operator, or the
   * approved address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is
   * the zero address. Throws if `_tokenId` is not a valid NFT. When transfer is complete, this
   * function checks if `_to` is a smart contract (code size > 0). If so, it calls
   * `onERC721Received` on `_to` and throws if the return value is not
   * `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`.
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   * @param _data Additional data with no specified format, sent in call to `_to`.
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  )
    external;

  /**
   * @dev Transfers the ownership of an NFT from one address to another address.
   * @notice This works identically to the other function with an extra data parameter, except this
   * function just sets data to ""
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;

  /**
   * @dev Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
   * address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is the zero
   * address. Throws if `_tokenId` is not a valid NFT.
   * @notice The caller is responsible to confirm that `_to` is capable of receiving NFTs or else
   * they may be permanently lost.
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;

  /**
   * @dev Set or reaffirm the approved address for an NFT.
   * @notice The zero address indicates there is no approved address. Throws unless `msg.sender` is
   * the current NFT owner, or an authorized operator of the current owner.
   * @param _approved The new approved NFT controller.
   * @param _tokenId The NFT to approve.
   */
  function approve(
    address _approved,
    uint256 _tokenId
  )
    external;

  /**
   * @dev Enables or disables approval for a third party ("operator") to manage all of
   * `msg.sender`'s assets. It also emits the ApprovalForAll event.
   * @notice The contract MUST allow multiple operators per owner.
   * @param _operator Address to add to the set of authorized operators.
   * @param _approved True if the operator is approved, false to revoke approval.
   */
  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external;

  /**
   * @dev Returns the number of NFTs owned by `_owner`. NFTs assigned to the zero address are
   * considered invalid, and this function throws for queries about the zero address.
   * @param _owner Address for whom to query the balance.
   * @return Balance of _owner.
   */
  function balanceOf(
    address _owner
  )
    external
    view
    returns (uint256);

  /**
   * @dev Returns the address of the owner of the NFT. NFTs assigned to zero address are considered
   * invalid, and queries about them do throw.
   * @param _tokenId The identifier for an NFT.
   * @return Address of _tokenId owner.
   */
  function ownerOf(
    uint256 _tokenId
  )
    external
    view
    returns (address);

  /**
   * @dev Get the approved address for a single NFT.
   * @notice Throws if `_tokenId` is not a valid NFT.
   * @param _tokenId The NFT to find the approved address for.
   * @return Address that _tokenId is approved for.
   */
  function getApproved(
    uint256 _tokenId
  )
    external
    view
    returns (address);

  /**
   * @dev Returns true if `_operator` is an approved operator for `_owner`, false otherwise.
   * @param _owner The address that owns the NFTs.
   * @param _operator The address that acts on behalf of the owner.
   * @return True if approved for all, false otherwise.
   */
  function isApprovedForAll(
    address _owner,
    address _operator
  )
    external
    view
    returns (bool);

}


// File contracts/0_standards/interfaces/erc721-metadata.sol

// License-Identifier: MIT

pragma solidity ^0.8.6;

/**
 * @dev Optional metadata extension for ERC-721 non-fungible token standard.
 * See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md.
 */
interface ERC721Metadata
{

  /**
   * @dev Returns a descriptive name for a collection of NFTs in this contract.
   * @return _name Representing name.
   */
  function name()
    external
    view
    returns (string memory _name);

  /**
   * @dev Returns a abbreviated name for a collection of NFTs in this contract.
   * @return _symbol Representing symbol.
   */
  function symbol()
    external
    view
    returns (string memory _symbol);

  /**
   * @dev Returns a distinct Uniform Resource Identifier (URI) for a given asset. It Throws if
   * `_tokenId` is not a valid NFT. URIs are defined in RFC3986. The URI may point to a JSON file
   * that conforms to the "ERC721 Metadata JSON Schema".
   * @return URI of _tokenId.
   */
  function tokenURI(uint256 _tokenId)
    external
    view
    returns (string memory);

}


// File contracts/0_standards/interfaces/erc721-enumerable.sol

// License-Identifier: MIT

pragma solidity ^0.8.6;

/**
 * @dev Optional enumeration extension for ERC-721 non-fungible token standard.
 * See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md.
 */
interface ERC721Enumerable
{

  /**
   * @dev Returns a count of valid NFTs tracked by this contract, where each one of them has an
   * assigned and queryable owner not equal to the zero address.
   * @return Total supply of NFTs.
   */
  function totalSupply()
    external
    view
    returns (uint256);

  /**
   * @dev Returns the token identifier for the `_index`th NFT. Sort order is not specified.
   * @param _index A counter less than `totalSupply()`.
   * @return Token id.
   */
  function tokenByIndex(
    uint256 _index
  )
    external
    view
    returns (uint256);

  /**
   * @dev Returns the token identifier for the `_index`th NFT assigned to `_owner`. Sort order is
   * not specified. It throws if `_index` >= `balanceOf(_owner)` or if `_owner` is the zero address,
   * representing invalid NFTs.
   * @param _owner An address where we are interested in NFTs owned by them.
   * @param _index A counter less than `balanceOf(_owner)`.
   * @return Token id.
   */
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    external
    view
    returns (uint256);

}


// File contracts/0_standards/interfaces/erc721-token-receiver.sol

// License-Identifier: MIT

pragma solidity ^0.8.6;

/**
 * @dev ERC-721 interface for accepting safe transfers.
 * See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md.
 */
interface ERC721TokenReceiver
{

  /**
   * @dev Handle the receipt of a NFT. The ERC721 smart contract calls this function on the
   * recipient after a `transfer`. This function MAY throw to revert and reject the transfer. Return
   * of other than the magic value MUST result in the transaction being reverted.
   * Returns `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))` unless throwing.
   * @notice The contract address is always the message sender. A wallet/broker/auction application
   * MUST implement the wallet interface if it will accept safe transfers.
   * @param _operator The address which called `safeTransferFrom` function.
   * @param _from The address which previously owned the token.
   * @param _tokenId The NFT identifier which is being transferred.
   * @param _data Additional data with no specified format.
   * @return Returns `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
   */
  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
    returns(bytes4);

}


// File contracts/0_standards/interfaces/erc165.sol

// License-Identifier: MIT

pragma solidity ^0.8.6;

/**
 * @dev A standard for detecting smart contract interfaces.
 * See: https://eips.ethereum.org/EIPS/eip-165.
 */
interface ERC165
{

  /**
   * @dev Checks if the smart contract implements a specific interface.
   * This function uses less than 30,000 gas.
   * @param _interfaceID The interface identifier, as specified in ERC-165.
   */
  function supportsInterface(
    bytes4 _interfaceID
  )
    external
    view
    returns (bool);

}


// File contracts/1_lib/utils/supports-interface.sol

// License-Identifier: MIT

pragma solidity ^0.8.6;

/**
 * @dev Implementation of standard to publish supported interfaces.
 */
contract SupportsInterface is
  ERC165
{

  /**
   * @dev Mapping of supported intefraces.
   * You must not set element 0xffffffff to true.
   */
  mapping(bytes4 => bool) internal supportedInterfaces;

  /**
   * @dev Contract constructor.
   */
  constructor()
  {
    supportedInterfaces[0x01ffc9a7] = true; // ERC165
  }

  /**
   * @dev Function to check which interfaces are supported by this contract.
   * @param _interfaceID Id of the interface.
   */
  function supportsInterface(
    bytes4 _interfaceID
  )
    external
    override
    view
    returns (bool)
  {
    return supportedInterfaces[_interfaceID];
  }

}


// File contracts/1_lib/utils/address-utils.sol

// License-Identifier: MIT
pragma solidity ^0.8.6;

/**
 * @dev Utility library of inline functions on addresses.
 */
library AddressUtils
{

  /**
   * @dev Returns whether the target address is a deployed contract.
   * If a contract constructor calls this method with its own address the returned value
   * will be false. If you want to check if an address is a contract (in whatever state) you can do
   * so using extcodehash after constantinople fork.
   * @param _addr Address to check.
   * @return addressCheck True if _addr is a deployed contract, false if not.
   */
  function isDeployedContract(
    address _addr
  )
    internal
    view
    returns (bool addressCheck)
  {
    uint256 size;
    assembly { size := extcodesize(_addr) } // solhint-disable-line
    addressCheck = size > 0;
  }

}


// File contracts/0_standards/erc721/nf-token-metadata-enumerable.sol

// License-Identifier: MIT

pragma solidity ^0.8.6;






/**
 * @dev Optional metadata enumerable implementation for ERC-721 non-fungible token standard.
 */
contract NFTokenMetadataEnumerable is
  ERC721,
  ERC721Metadata,
  ERC721Enumerable,
  SupportsInterface
{
  using AddressUtils for address;

  /**
   * @dev Error constants.
   */
  string public constant ZERO_ADDRESS = "006001";
  string public constant NOT_VALID_NFT = "006002";
  string public constant NOT_OWNER_OR_OPERATOR = "006003";
  string public constant NOT_OWNER_APPROWED_OR_OPERATOR = "006004";
  string public constant NOT_ABLE_TO_RECEIVE_NFT = "006005";
  string public constant NFT_ALREADY_EXISTS = "006006";
  string public constant INVALID_INDEX = "006007";

  /**
   * @dev Magic value of a smart contract that can recieve NFT.
   * Equal to: bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")).
   */
  bytes4 public constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

  /**
   * @dev A descriptive name for a collection of NFTs.
   */
  string internal nftName;

  /**
   * @dev An abbreviated name for NFTs.
   */
  string internal nftSymbol;

  /**
   * @dev URI prefix for NFT metadata. NFT URI is made from prefix + NFT id + postfix.
   */
  string public uriPrefix;

  /**
   * @dev URI postfix for NFT metadata. NFT URI is made from prefix + NFT ID + postfix.
   */
  string public uriPostfix;

  /**
   * @dev Array of all NFT IDs.
   */
  uint256[] internal tokens;

  /**
   * @dev Mapping from token ID its index in global tokens array.
   */
  mapping(uint256 => uint256) internal idToIndex;

  /**
   * @dev Mapping from owner to list of owned NFT IDs.
   */
  mapping(address => uint256[]) internal ownerToIds;

  /**
   * @dev Mapping from NFT ID to its index in the owner tokens list.
   */
  mapping(uint256 => uint256) internal idToOwnerIndex;

  /**
   * @dev A mapping from NFT ID to the address that owns it.
   */
  mapping (uint256 => address) internal idToOwner;

  /**
   * @dev Mapping from NFT ID to approved address.
   */
  mapping (uint256 => address) internal idToApproval;

  /**
   * @dev Mapping from owner address to mapping of operator addresses.
   */
  mapping (address => mapping (address => bool)) internal ownerToOperators;

  /**
   * @dev Contract constructor.
   * @notice When implementing this contract, don't forget to set nftName, nftSymbol, uriPrefix and
   * uriPostfix.
   */
  constructor()
  {
    supportedInterfaces[0x80ac58cd] = true; // ERC721
    supportedInterfaces[0x5b5e139f] = true; // ERC721Metadata
    supportedInterfaces[0x780e9d63] = true; // ERC721Enumerable
  }

  /**
   * @dev Transfers the ownership of an NFT from one address to another address.
   * @notice Throws unless `msg.sender` is the current owner, an authorized operator, or the
   * approved address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is
   * the zero address. Throws if `_tokenId` is not a valid NFT. When transfer is complete, this
   * function checks if `_to` is a smart contract (code size > 0). If so, it calls
   * `onERC721Received` on `_to` and throws if the return value is not
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   * @param _data Additional data with no specified format, sent in call to `_to`.
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
    override
  {
    _safeTransferFrom(_from, _to, _tokenId, _data);
  }

  /**
   * @dev Transfers the ownership of an NFT from one address to another address.
   * @notice This works identically to the other function with an extra data parameter, except this
   * function just sets data to "".
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    override
  {
    _safeTransferFrom(_from, _to, _tokenId, "");
  }

  /**
   * @dev Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
   * address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is the zero
   * address. Throws if `_tokenId` is not a valid NFT.
   * @notice The caller is responsible to confirm that `_to` is capable of receiving NFTs or else
   * they may be permanently lost.
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    override
  {
    _transferFrom(_from, _to, _tokenId);
  }

  /**
   * @dev Set or reaffirm the approved address for an NFT.
   * @notice The zero address indicates there is no approved address. Throws unless `msg.sender` is
   * the current NFT owner, or an authorized operator of the current owner.
   * @param _approved Address to be approved for the given NFT ID.
   * @param _tokenId ID of the token to be approved.
   */
  function approve(
    address _approved,
    uint256 _tokenId
  )
    external
    override
  {
    // can operate
    address tokenOwner = idToOwner[_tokenId];
    require(
      tokenOwner == msg.sender || ownerToOperators[tokenOwner][msg.sender],
      NOT_OWNER_OR_OPERATOR
    );

    idToApproval[_tokenId] = _approved;
    emit Approval(tokenOwner, _approved, _tokenId);
  }

  /**
   * @dev Enables or disables approval for a third party ("operator") to manage all of
   * `msg.sender`'s assets. It also emits the ApprovalForAll event.
   * @notice This works even if sender doesn't own any tokens at the time.
   * @param _operator Address to add to the set of authorized operators.
   * @param _approved True if the operator is approved, false to revoke approval.
   */
  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external
    override
  {
    ownerToOperators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  /**
   * @dev Returns the number of NFTs owned by `_owner`. NFTs assigned to the zero address are
   * considered invalid, and this function throws for queries about the zero address.
   * @param _owner Address for whom to query the balance.
   * @return Balance of _owner.
   */
  function balanceOf(
    address _owner
  )
    external
    override
    view
    returns (uint256)
  {
    require(_owner != address(0), ZERO_ADDRESS);
    return ownerToIds[_owner].length;
  }

  /**
   * @dev Returns the address of the owner of the NFT. NFTs assigned to zero address are considered
   * invalid, and queries about them do throw.
   * @param _tokenId The identifier for an NFT.
   * @return _owner Address of _tokenId owner.
   */
  function ownerOf(
    uint256 _tokenId
  )
    external
    override
    view
    returns (address _owner)
  {
    _owner = idToOwner[_tokenId];
    require(_owner != address(0), NOT_VALID_NFT);
  }

  /**
   * @dev Get the approved address for a single NFT.
   * @notice Throws if `_tokenId` is not a valid NFT.
   * @param _tokenId ID of the NFT to query the approval of.
   * @return Address that _tokenId is approved for.
   */
  function getApproved(
    uint256 _tokenId
  )
    external
    override
    view
    returns (address)
  {
    require(idToOwner[_tokenId] != address(0), NOT_VALID_NFT);
    return idToApproval[_tokenId];
  }

  /**
   * @dev Checks if `_operator` is an approved operator for `_owner`.
   * @param _owner The address that owns the NFTs.
   * @param _operator The address that acts on behalf of the owner.
   * @return True if approved for all, false otherwise.
   */
  function isApprovedForAll(
    address _owner,
    address _operator
  )
    external
    override
    view
    returns (bool)
  {
    return ownerToOperators[_owner][_operator];
  }

  /**
   * @dev Returns the count of all existing NFTs.
   * @return Total supply of NFTs.
   */
  function totalSupply()
    external
    override
    view
    returns (uint256)
  {
    return tokens.length;
  }

  /**
   * @dev Returns NFT ID by its index.
   * @param _index A counter less than `totalSupply()`.
   * @return Token id.
   */
  function tokenByIndex(
    uint256 _index
  )
    external
    override
    view
    returns (uint256)
  {
    require(_index < tokens.length, INVALID_INDEX);
    return tokens[_index];
  }

  /**
   * @dev returns the n-th NFT ID from a list of owner's tokens.
   * @param _owner Token owner's address.
   * @param _index Index number representing n-th token in owner's list of tokens.
   * @return Token id.
   */
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    external
    override
    view
    returns (uint256)
  {
    require(_index < ownerToIds[_owner].length, INVALID_INDEX);
    return ownerToIds[_owner][_index];
  }

  /**
   * @dev Returns a descriptive name for a collection of NFTs.
   * @return _name Representing name.
   */
  function name()
    external
    override
    view
    returns (string memory _name)
  {
    _name = nftName;
  }

  /**
   * @dev Returns an abbreviated name for NFTs.
   * @return _symbol Representing symbol.
   */
  function symbol()
    external
    override
    view
    returns (string memory _symbol)
  {
    _symbol = nftSymbol;
  }

  /**
   * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
   * @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC 3986. The URI may point
   * to a JSON file that conforms to the "ERC721 Metadata JSON Schema".
   * @param _tokenId Id for which we want URI.
   * @return URI of _tokenId.
   */
  function tokenURI(
    uint256 _tokenId
  )
    public
    virtual
    view
    returns (string memory)
  {
    require(idToOwner[_tokenId] != address(0), NOT_VALID_NFT);
    string memory uri = "";
    if (bytes(uriPrefix).length > 0)
    {
      uri = string(abi.encodePacked(uriPrefix, _uint2str(_tokenId)));
      if (bytes(uriPostfix).length > 0)
      {
        uri = string(abi.encodePacked(uri, uriPostfix));
      }
    }
    return uri;
  }

  /**
   * @dev Set a distinct URI (RFC 3986) base for all nfts.
   * @notice this is a internal function which should be called from user-implemented external
   * function. Its purpose is to show and properly initialize data structures when using this
   * implementation.
   * @param _prefix String representing RFC 3986 URI prefix.
   * @param _postfix String representing RFC 3986 URI postfix.
   */
  function _setUri(
    string memory _prefix,
    string memory _postfix
  )
    internal
  {
    uriPrefix = _prefix;
    uriPostfix = _postfix;
  }

  /**
   * @dev Creates a new NFT.
   * @notice This is a private function which should be called from user-implemented external
   * function. Its purpose is to show and properly initialize data structures when using this
   * implementation.
   * @param _to The address that will own the created NFT.
   * @param _tokenId of the NFT to be created by the msg.sender.
   */
  function _create(
    address _to,
    uint256 _tokenId
  )
    internal
  {
    require(_to != address(0), ZERO_ADDRESS);
    require(idToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);

    // add NFT
    idToOwner[_tokenId] = _to;

    ownerToIds[_to].push(_tokenId);
    idToOwnerIndex[_tokenId] = ownerToIds[_to].length - 1;

    // add to tokens array
    tokens.push(_tokenId);
    idToIndex[_tokenId] = tokens.length - 1;

    emit Transfer(address(0), _to, _tokenId);
  }

  /**
   * @dev Destroys an NFT.
   * @notice This is a private function which should be called from user-implemented external
   * destroy function. Its purpose is to show and properly initialize data structures when using
   * this implementation.
   * @param _tokenId ID of the NFT to be destroyed.
   */
  function _destroy(
    uint256 _tokenId
  )
    internal
  {
    // valid NFT
    address _owner = idToOwner[_tokenId];
    require(_owner != address(0), NOT_VALID_NFT);

    // clear approval
    delete idToApproval[_tokenId];

    // remove NFT
    assert(ownerToIds[_owner].length > 0);

    uint256 tokenToRemoveIndex = idToOwnerIndex[_tokenId];
    uint256 lastTokenIndex = ownerToIds[_owner].length - 1;
    uint256 lastToken;
    if (lastTokenIndex != tokenToRemoveIndex)
    {
      lastToken = ownerToIds[_owner][lastTokenIndex];
      ownerToIds[_owner][tokenToRemoveIndex] = lastToken;
      idToOwnerIndex[lastToken] = tokenToRemoveIndex;
    }

    delete idToOwner[_tokenId];
    delete idToOwnerIndex[_tokenId];
    ownerToIds[_owner].pop();

    // remove from tokens array
    assert(tokens.length > 0);

    uint256 tokenIndex = idToIndex[_tokenId];
    lastTokenIndex = tokens.length - 1;
    lastToken = tokens[lastTokenIndex];

    tokens[tokenIndex] = lastToken;

    tokens.pop();
    // Consider adding a conditional check for the last token in order to save GAS.
    idToIndex[lastToken] = tokenIndex;
    idToIndex[_tokenId] = 0;

    emit Transfer(_owner, address(0), _tokenId);
  }

  /**
   * @dev Helper method that actually does the transfer.
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   */
  function _transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    internal
    virtual
  {
    // valid NFT
    require(_from != address(0), ZERO_ADDRESS);
    require(idToOwner[_tokenId] == _from, NOT_VALID_NFT);
    require(_to != address(0), ZERO_ADDRESS);

    // can transfer
    require(
      _from == msg.sender
      || idToApproval[_tokenId] == msg.sender
      || ownerToOperators[_from][msg.sender],
      NOT_OWNER_APPROWED_OR_OPERATOR
    );

    // clear approval
    delete idToApproval[_tokenId];

    // remove NFT
    assert(ownerToIds[_from].length > 0);

    uint256 tokenToRemoveIndex = idToOwnerIndex[_tokenId];
    uint256 lastTokenIndex = ownerToIds[_from].length - 1;

    if (lastTokenIndex != tokenToRemoveIndex)
    {
      uint256 lastToken = ownerToIds[_from][lastTokenIndex];
      ownerToIds[_from][tokenToRemoveIndex] = lastToken;
      idToOwnerIndex[lastToken] = tokenToRemoveIndex;
    }

    ownerToIds[_from].pop();

    // add NFT
    idToOwner[_tokenId] = _to;
    ownerToIds[_to].push(_tokenId);
    idToOwnerIndex[_tokenId] = ownerToIds[_to].length - 1;

    emit Transfer(_from, _to, _tokenId);
  }

  /**
   * @dev Helper function that actually does the safeTransferFrom.
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   * @param _data Additional data with no specified format, sent in call to `_to`.
   */
  function _safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data
  )
    internal
    virtual
  {
    if (_to.isDeployedContract())
    {
      require(
        ERC721TokenReceiver(_to)
          .onERC721Received(msg.sender, _from, _tokenId, _data) == MAGIC_ON_ERC721_RECEIVED,
        NOT_ABLE_TO_RECEIVE_NFT
      );
    }

    _transferFrom(_from, _to, _tokenId);
  }

  /**
   * @dev Helper function that changes uint to string representation.
   * @return str String representation.
   */
  function _uint2str(
    uint256 _i
  )
    internal
    pure
    returns (string memory str)
  {
    if (_i == 0)
    {
      return "0";
    }
    uint256 j = _i;
    uint256 length;
    while (j != 0)
    {
      length++;
      j /= 10;
    }
    bytes memory bstr = new bytes(length);
    uint256 k = length;
    j = _i;
    while (j != 0)
    {
      bstr[--k] = bytes1(uint8(48 + j % 10));
      j /= 10;
    }
    str = string(bstr);
  }

}


// File contracts/CGBaseNFT.sol

// License-Identifier: MIT

pragma solidity ^0.8.9; // solhint-disable-line


/**
    Smart-Contract used by CryptoGouv Capital (https://cryptogouv.capital)

    Smart-Contract designed by SealKey squad (https://sealkey.io)
*/
contract CGBaseNFT is NFTokenMetadataEnumerable, Abilitable {

    uint8 public constant LVL_URI_MGR = 0x01;
    uint8 public constant LVL_MINTER = 0x02;

    uint256 public tokenIndex;
    string internal uniqueUri;
    

    constructor(string memory _name, string memory _symbol) Abilitable(LVL_URI_MGR | LVL_MINTER){
        _changeAbilities(msg.sender, LVL_URI_MGR);
        nftName = _name;
        nftSymbol = _symbol;

        tokenIndex = 1;
        uriPrefix = "";
        uriPostfix = "";
        uniqueUri = "";
    }

    function isMinter() external view returns ( bool ) {
        return hasAbilities(LVL_MINTER);
    }

    function setBaseURI(string calldata _uriPrefix, string calldata _uriPostfix) external onlyAbilited(LVL_URI_MGR){
        uriPrefix = _uriPrefix;
        uriPostfix = _uriPostfix;
    }

    function setUniqueURI(string calldata _uri) external onlyAbilited(LVL_URI_MGR){
        uniqueUri = _uri;
    }

    function mint(address _to) external onlyAbilited(LVL_MINTER) {
        super._create(_to, tokenIndex);

        tokenIndex++;
    }

    function massMint(address [] calldata _to) external onlyAbilited(LVL_MINTER) {
        for(uint256 i = 0; i < _to.length; ++i){
            super._create(_to[i], tokenIndex);
            tokenIndex++;
        }
    }

    function burn(uint256 _nftId) external {
        require(idToOwner[_nftId] == msg.sender || isOwner(), "NFT_NOT_OWNER");
        super._destroy(_nftId);
    }
    
    // Override tokenURI for handling unique URI 
    function tokenURI(uint256 _tokenId ) public override view returns (string memory) {
        if (bytes(uniqueUri).length > 0) {
            return uniqueUri;
        }

        return super.tokenURI(_tokenId);
    }

}


// File contracts/CGBaseClaim.sol

// License-Identifier: MIT

pragma solidity ^0.8.9; // solhint-disable-line







/**
    Smart-Contract used by CryptoGouv Capital (https://cryptogouv.capital)

    Smart-Contract designed by SealKey squad (https://sealkey.io)

    Investment pool tools for rewards divitions between each NFT possesor
*/
contract CGBaseClaim is  IBaseDeposit, IBaseClaim, Abilitable, NoCyclic {

    uint8 constant public LVL_CLAIMER = 0x01;
    uint8 constant public LVL_ADMIN = 0x02;
    uint8 constant public LVL_DEPOSITER = 0x04;

    IERC20 public                               claimableToken;
    CGBaseNFT public                            pool;
    uint256 public                              nftQuotePart;
    mapping (uint256 => uint256) internal       claimedAmountByNFT;
    
    event Deposit(address indexed _from, uint256 _addedAmount, uint256 _addedNFTQuotePart);

    constructor(CGBaseNFT _pool, IERC20 _token) Abilitable(LVL_CLAIMER | LVL_ADMIN){
        claimableToken = _token;
        pool = _pool;

        nftQuotePart = 0;
    }

    function setClaimableToken(IERC20 _token) external onlyOwner() {
        claimableToken = _token; 
    }

    function setCGBaseNFT(CGBaseNFT _pool) external onlyOwner() {
        pool = _pool;    
    }

    function canDeposit() external view returns(bool) {
        return hasAbilities(LVL_DEPOSITER);
    }

    function deposit(uint256 _amount) external onlyAbilited(LVL_DEPOSITER) unique() returns(uint256) {
        uint256 poolSize = pool.totalSupply();
        require(poolSize > 0, "NO_NFT_MINTED");
        
        uint256 addedAmountByNFT = _amount / poolSize;
        nftQuotePart += addedAmountByNFT;

        uint256 addedAmount = addedAmountByNFT * poolSize;
        TransferHelper.safeTransferFrom(claimableToken, msg.sender, address(this), addedAmount);

        emit Deposit(msg.sender, addedAmount, addedAmountByNFT);
        return addedAmount;
    }

    function getClaimableAmount(address _user) external view returns( uint256 ){
        uint256 totalClaimable = 0;
        uint256 balanceNFT = pool.balanceOf(_user);
        for(uint256 idxNft = 0; idxNft < balanceNFT; ++idxNft){
            uint256 idNFT = pool.tokenOfOwnerByIndex(_user, idxNft);
            totalClaimable += nftQuotePart - claimedAmountByNFT[idNFT];
        }
        return totalClaimable;
    }

    function _claimRewardsFor(address _user) internal unique() returns( uint256 ) {
        uint256 totalRewards = 0;
        uint256 balanceNFT = pool.balanceOf(_user);
        for(uint256 idxNft = 0; idxNft < balanceNFT; ++idxNft){
            uint256 idNFT = pool.tokenOfOwnerByIndex(_user, idxNft);

            uint256 claimableNFT = nftQuotePart - claimedAmountByNFT[idNFT];
            claimedAmountByNFT[idNFT] += claimableNFT;

            totalRewards += claimableNFT;
        }

        if(totalRewards > 0){
            TransferHelper.safeTransfer(claimableToken, msg.sender, totalRewards);
        }

        return totalRewards;
    }

    function claimRewardsFor(address _user) external returns( uint256 ) {
        require(msg.sender == _user || hasAbilities(LVL_CLAIMER), "CLAIM_UNAUTHORIZED");
        return _claimRewardsFor(_user);
    }
    
    function claimRewards() external returns( uint256 ) {
        uint256 totalRewards =  _claimRewardsFor(msg.sender);
        require(totalRewards > 0, "NO_CLAIMABLE_TOKEN");
        emit Withdraw(msg.sender, totalRewards);
        return totalRewards;
    }
}