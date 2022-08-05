/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol


pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easilly be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

// File: @chainlink/contracts/src/v0.8/KeeperBase.sol


pragma solidity ^0.8.0;

contract KeeperBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// File: @chainlink/contracts/src/v0.8/KeeperCompatible.sol


pragma solidity ^0.8.0;



abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}

// File: Keeper.sol


pragma solidity ^0.8.0;

// Farmageddon Lottery Keeper Automation 

// KeeperCompatible.sol imports the functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol



interface NFT{
    function cost() external view returns (uint256);
	function totalSupply() external view returns (uint256);	 
    function maxSupply() external view returns (uint256);	 
    function mint(uint256 _mintAmount) external payable;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function walletOfOwner(address _owner) external view returns (uint256[] memory);
	}

    interface IERC20{
        function transfer(address to, uint256 amount) external returns (bool);
    }



contract autoMinter is KeeperCompatibleInterface, IERC721Receiver, Ownable {
    // Setup Variables
        
        address treasury;
        uint256 currentTokenId;
        uint256 cost;
        uint256 howMany = 1;
        uint256[] steve = [10511, 10439, 680, 1];

    // assign token    
    NFT public NftAddress;

    constructor(address _NFTAddress, address _treasury) {
        NftAddress = NFT(_NFTAddress);
        treasury = _treasury;
    }

    function setHowMany(uint256 _howMany) external onlyOwner {
        howMany = _howMany;
    }

    function setTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    function SetNFTAddress(address _NFTAddress) external onlyOwner {
        NftAddress = NFT(_NFTAddress);
    }

    function currentCost() public view returns (uint256 BNBCost) {
        return NftAddress.cost();
    }

    function currentId() public view returns ( uint256 currentID)  {
        return NftAddress.totalSupply();
    }

    function nextCatch() public view returns (uint256 ) {
        return steve[steve.length-1];
    }

    function checkUpkeep(bytes calldata) view external override returns (bool upkeepNeeded, bytes memory) {
        // perform upkeep when timestamp is equal or more than upkeepTime
        upkeepNeeded = currentId() >= (nextCatch() - 5);
    }

    event gotIt(string);

    // Perform Tax changes
    function performUpkeep(bytes calldata /* performData */) external override {
        require (currentId() >= (nextCatch() - 5) && currentId() < NftAddress.maxSupply(), "Not gonna mint it yet");
            uint256 callCost = currentCost();

            NftAddress.mint{ value: callCost }( howMany );
            steve.pop;
            
            emit gotIt("got one");
    }

    function manualUpKeep() external onlyOwner {
        require (currentId() >= (nextCatch() - 5) && currentId() < NftAddress.maxSupply(), "Not gonna mint it yet");
            uint256 callCost = currentCost();

            NftAddress.mint{ value: callCost }( howMany );
            steve.pop;

            emit gotIt("got one");
    }

    function withdrawBNB() external onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
  }

  function collectNFTs() external onlyOwner {
      uint256[] memory tokenIds = NftAddress.walletOfOwner(address(this));
            for(uint i=0; i< tokenIds.length; i++){
                NftAddress.safeTransferFrom(address(this), treasury, tokenIds[i]);
            }
  }

  function collectTokenId(uint256 tokenId) external onlyOwner {
      NftAddress.safeTransferFrom(address(this), treasury, tokenId);
  }


  function withdrawlToken(address _tokenAddress, uint256 _amount) external onlyOwner {
    IERC20(_tokenAddress).transfer(address(msg.sender), _amount);
  }
    event NFTReceived();
   function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external override returns(bytes4){
        _operator;
        _from;
        _tokenId;
        _data;
        emit NFTReceived();
        return 0x150b7a02;
    }

  receive() external payable {}

}