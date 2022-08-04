/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// File: contracts/libraries/MedapartMetadata.sol


pragma solidity ^0.8.0;

library MedapartMetadata {
  struct Metadata {
    Part partId;
    uint8 familyId;    
  }
  
  enum Part {
    Core,
    RightArm,
    LeftArm,
    Legs
  }//Agregar estados default

}
// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
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

    function reset(Counter storage counter) internal {
        counter._value = 0;
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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

// File: contracts/interfaces/IFeeBeneficiary.sol


pragma solidity ^0.8.0;



interface FeeBeneficiary  {
    //todo: getFeesVariables
    function getFee() external view returns(uint);
    function setFee(address _feeTo, uint256 _feePercentage) external;
    function getFeeLiquidity() external view returns(uint);
    function setFeeLiquidity(address _liquidity, uint256 _feeLiquidity) external;

    function chargeFeeFixedPrice(IERC20 _token, uint256 _totalAmount, address _from) external returns (uint256); 
    function chargeFeeAuction(uint256 _totalAmount, IERC20 _token, address _from) external returns (uint256);
    function tranferFoundOfMint(uint _amount, IERC20 _token, address _from) external;
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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: contracts/interfaces/IMedabotsGarage.sol


pragma solidity ^0.8.0;



interface IMedabotsGarage is IERC721 {
    struct Robot {
        uint8 familyId;
        uint256 tokenPartOne;
        uint256 tokenPartTwo;
        uint256 tokenPartThree;
        uint256 tokenPartFour;
    }

    /**
     * @dev Emitted when the user call to {assemble}
     **/
    event Assemble(
        uint256 robotId,
        uint8 familyId,
        address owner,
        uint256 tokenPartOne,
        uint256 tokenPartTwo,
        uint256 tokenPartThree,
        uint256 tokenPartFour
    );

    /**
     * @dev  Emitted when the user call to {disassemble}
     **/
    event Disassemble(
        uint256 robotId,
        uint8 familyId,
        address owner,
        uint256 tokenPartOne,
        uint256 tokenPartTwo,
        uint256 tokenPartThree,
        uint256 tokenPartFour
    );

    function assemble(uint8 _familyId, uint256[4] memory _tokenParts) external;

    function disassemble(uint256 robotId) external;

    function transferOwnership(address newOwner) external;

}

// File: contracts/Marketplace.sol


pragma solidity ^0.8.0;






//TODO: 
abstract contract Marketplace is Ownable, Pausable {
    mapping(IERC721 => bool) public isTokenWhitelisted;    
    IERC20 public currency;

    constructor(IERC721[] memory _tokens, IERC20 _currency) {
        currency = _currency;
        whitelistTokens(_tokens);
    }

    modifier onlyWhitelistedTokens(IERC721 _token) {
        require(isTokenWhitelisted[_token], "MARKETPLACE: Token address not whitelisted");
        _;
    }

    function pause(bool _paused) public onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }

    function setCurrency(IERC20 _currency) public onlyOwner {
        currency = _currency;
    }

    function whitelistTokens(IERC721[] memory _tokens) public onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            isTokenWhitelisted[_tokens[i]] = true;
        }
    }

    function blacklistTokens(IERC721[] memory _tokens) public onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            isTokenWhitelisted[_tokens[i]] = false;
        }
    }
}

// File: contracts/MarketplaceAuction.sol


pragma solidity ^0.8.0;



contract MarketplaceAuction is Marketplace {
    
    struct Listing {
        address lister;
        uint256 initialPrice;
        uint256 endTime;
        address highestBidder;
        uint256 highestBid;
    }

    mapping(IERC721 => mapping(uint256 => Listing)) public listings;
    

    uint public minTimeToAddPlus; //setter!//Tiempo minimo para a contemplar para agregar mas tiempo a la subasta
    uint public timePlus;//Tiempo que se agrega tras una puja
    uint public minEndTime; //tiempo que debe Manterse como minimo, en segundos.
    FeeBeneficiary public feeContract;
    uint public bidFee = 1; //Minimo que debe superar la puja entrante, respecto de la puja actual.
    

    event Listed(address lister, IERC721 token, uint256 tokenId, uint256 initialPrice, uint256 endTime);
    event Bid(address bidder, IERC721 token, uint256 tokenId, uint256 amount);
    event Unlisted(address lister, IERC721 token, uint256 tokenId);    
    event Claim(address purchaser, address lister, IERC721 token, uint256 tokenId, uint256 endPrice);


    constructor(
        IERC721[] memory _whitelistedTokens,
        IERC20 _currency        
    ) Marketplace(_whitelistedTokens, _currency) {}

    modifier bidAmountMeetsBidRequirements(
        IERC721 _nftContractAddress,
        uint256 _tokenId,
        uint256 _tokenAmount
    ) {
        require(
            _doesBidMeetBidRequirements(
                _nftContractAddress,
                _tokenId,
                _tokenAmount
            ),
            "Not enough funds to bid on NFT"
        );
        _;
    }

    /********************
    *  PUBLIC FUNCTIONS *
    *********************/

    function list(
        IERC721 _token,
        uint256 _tokenId,
        uint256 _initialPrice,
        uint256 _biddingTime
    ) public whenNotPaused onlyWhitelistedTokens(_token) {
        Listing storage listing = listings[_token][_tokenId];
        require(_token.ownerOf(_tokenId) == msg.sender, "MARKETPLACE: Caller is not token owner");
        _token.transferFrom(msg.sender, address(this), _tokenId);

        Listing memory newListing = Listing({
            lister: msg.sender,
            initialPrice: _initialPrice,
            endTime: block.timestamp + _biddingTime,
            highestBidder: msg.sender,
            highestBid: 0
        });
        listings[_token][_tokenId] = newListing;
        emit Listed(msg.sender, _token, _tokenId, _initialPrice, listing.endTime);
    }

    function listInLotes(
        IERC721 _token,
        uint256[] memory _tokenId,
        uint256[] memory _initialPrice,
        uint256[] memory _biddingTime
    ) public whenNotPaused onlyWhitelistedTokens(_token) {
        require(
            _tokenId.length == _initialPrice.length &&
            _tokenId.length == _biddingTime.length, 
            "MARKETPLACE: Arrays must have the same length"
        );
        for (uint256 i = 0; i < _tokenId.length; i++) {
            list(_token, _tokenId[i], _initialPrice[i], _biddingTime[i]);
        }      
    }
    
    function bid(
        IERC721 _token,
        uint256 _tokenId,
        uint256 _amount
    )   public
        whenNotPaused 
        onlyWhitelistedTokens(_token)
        bidAmountMeetsBidRequirements(
            _token,
            _tokenId,
            _amount
        )
    {
        //cambiar a memory
        Listing storage listing = listings[_token][_tokenId];
        require(listing.lister != address(0), "MARKETPLACE: Token not listed");
        require(listing.lister != msg.sender, "MARKETPLACE: Can't bid on your own token");
        require(block.timestamp < listing.endTime, "MARKETPLACE: Bid too late");
        require(_amount > listing.highestBid, "MARKETPLACE: Bid lower than previous bid");
        require(_amount > listing.initialPrice, "MARKETPLACE: Bid lower than initialPrice");

        address previousHighestBidder = listing.highestBidder;
        uint previousHighestBid = listing.highestBid;

        currency.transferFrom(msg.sender, address(this), _amount);
        listing.highestBid = _amount;
        listing.highestBidder = msg.sender;

        if (listing.highestBid != 0) {
            currency.transfer(previousHighestBidder, previousHighestBid);
        }

        if((minTimeToAddPlus > 0) && (_getTimeLeft(listing.endTime) < minTimeToAddPlus)){
            listing.endTime += timePlus;
            //agrega tiempo fijo tras una puja, por debajo de minTimeToAddPlus
        }

        listing.endTime += difTimeToend(listing.endTime);
        //Mantiene un tiempo minimo tras una puja.

        emit Bid(msg.sender, _token, _tokenId, _amount);
    }

    //Permite reclamar los resultados de una subasta terminada.
    function claim(IERC721 _token, uint256 _tokenId) public whenNotPaused{
        Listing storage listing = listings[_token][_tokenId];
        require(listing.lister != address(0), "MARKETPLACE: Token not listed");
        require(_getClaimers(msg.sender,listing), "MARKETPLACE: Can settle only your own token");
        require(block.timestamp > listing.endTime, "MARKETPLACE: endTime not reached");

        uint256 endPrice = listing.highestBid;
        uint256 resultingAmount = feeContract.chargeFeeAuction(endPrice, currency, msg.sender);

        currency.transfer(listing.lister, resultingAmount);
        _token.transferFrom(address(this), listing.highestBidder, _tokenId);

        emit Claim(listing.highestBidder, listing.lister, _token, _tokenId, endPrice);
        _unlist(_token, _tokenId);

    }

    //Permite quitar un nft de subasta solo si, nadie pujo por el.
    function unlist(IERC721 _token, uint256 _tokenId) public {
        Listing memory listing = listings[_token][_tokenId];
        require(listing.lister == msg.sender);
        require(listing.highestBidder == listing.lister);
        _unlist(_token, _tokenId);
        _token.transferFrom(address(this), msg.sender, _tokenId);
    }

    function unListInLotes(IERC721 _token, uint256[] memory _tokenId)public onlyOwner {
        Listing memory listing;
        address prevOwner;
        address highestBidder;
        uint highestBid;

        for(uint i; i < _tokenId.length; i++){
            listing = listings[_token][_tokenId[i]];
            if(listing.highestBidder == listing.lister){
                //si nadie pujo por el nft
                prevOwner = listing.lister;
                _unlist(_token, _tokenId[i]);					
                _token.transferFrom(address(this), prevOwner, _tokenId[i]);

            }else{
                //first get state of sell
                prevOwner = listing.lister;
                highestBidder = listing.highestBidder;
        highestBid = listing.highestBid;
                

                _unlist(_token, _tokenId[i]);					
                _token.transferFrom(address(this), prevOwner, _tokenId[i]);
                currency.transfer(highestBidder, highestBid);
            }
        }
    }
    
    //permite cambiar el precio minimo de puja, solo si, nadie pujo por el nft.
    function changePrice(IERC721 _token, uint256 _tokenId, uint _initialPrice) public {
        Listing storage listing = listings[_token][_tokenId];
        require(listing.lister == msg.sender);
        require(block.timestamp < listing.endTime, "MARKETPLACE: endTime finished");
        require(listing.highestBidder == listing.lister);
        listing.initialPrice = _initialPrice;
        //emit changePrice
    }

    /* Regresa la diferencia entre el tiempo que le queda a la subasta, con el minEndTime
    *  usar en la funcion de puja, para sumar al endTime, el tiempo retornado por esta funcion.
    */
    function difTimeToend(uint _endTime) public view returns(uint){
        uint timeLeft = _getTimeLeft(_endTime);
        //todo agregar que retorne cero si timeLeft = 0;
        if(minEndTime > timeLeft && timeLeft != 0) {
            // si el tiempo restante es menor, regresa la difrencia que se le debe sumar a endTime;
            return minEndTime - timeLeft;
        }
        return 0; //Si el tiempo es mayor, retorna 0, porque no se debe sumar ningun segundo.
    }

    function setBidFee(uint _bidFee) external onlyOwner{
        bidFee = _bidFee;
    }

    function setMinEndTime(uint _timeInSegs) public onlyOwner{
        minEndTime = _timeInSegs;
    }

    function setPlusTime(uint _plusTime, uint _minTimeToAddPlus)public onlyOwner{
        if(_plusTime > 0 ){
            timePlus =_plusTime;
        }
        if(_minTimeToAddPlus>0){
            minTimeToAddPlus = _minTimeToAddPlus;
        }
    }   

    function setFeeAddress(address _newFeecontract) public onlyOwner{
        feeContract = FeeBeneficiary(_newFeecontract);
    }

    /********************
    *INTERNAL FUNCTIONS *
    *********************/
    //Regresa tiempo restante de una subasta, para hacerlo publico modifcar parametreo de entrada
    function _getTimeLeft(uint _endTime) internal view returns(uint){
        if(_endTime>block.timestamp){
            return _endTime - block.timestamp;
        }
        return 0;
        //retorna error
    }

    //Regresa true si quien llama es el listador o  el ganador, de una subasta.
    function _getClaimers(address _sender, Listing memory _listing) internal pure returns(bool){
        if( (_sender == _listing.lister) || (_sender == _listing.highestBidder)){
            return true;
        }else{
            return false;
        }
    }

    //Quita el nft de una subasta. Borra los datos del mapping
    function _unlist(IERC721 _token, uint256 _tokenId) internal {
        delete listings[_token][_tokenId];
        emit Unlisted(msg.sender, _token, _tokenId);
    }  

    /*
     * An auction: the bid needs to be a bidFee% higher than the previous bid.
     */
    function _doesBidMeetBidRequirements(
        IERC721 _token,
        uint256 _tokenId,
        uint256 _tokenAmount
    ) internal view returns (bool) {        
        //if the NFT is up for auction, the bid needs to be a % higher than the previous bid
        uint256 bidIncreaseAmount = (listings[_token][_tokenId].highestBid * bidFee) / 100
            + listings[_token][_tokenId].highestBid;
        return   (_tokenAmount >= bidIncreaseAmount);
    }

}