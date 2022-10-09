/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

// File: Market.sol



pragma solidity ^0.8.7;

interface IBEP20 {
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
    function owner() external view returns (address);
}

contract Market{
    IBEP20 public token;
    IERC721 public nft;
    address public owner;
    uint serviceFee = 25;
    mapping(address => mapping(uint => uint)) public cost;
    struct mappedRoyalties {
        address receiver;
        uint percentage;
    }
    mapping(address => mappedRoyalties) public royalty;

    constructor(){
        token = IBEP20(0x4aB4f5dda682c5cFa9Bd0AA9dbCbC625AD0211aB); //token address
        owner = msg.sender;
    }

    modifier onlyOwner {
        //is the message sender owner of the contract?
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function buy(uint _id, address address_nft) public payable{
        uint amount = cost[address_nft][_id];
        require(amount != 0,"Not in sale");
        require(msg.value >= amount, "Insufficient funds");
        uint fee = amount * serviceFee / 10 / 100;
        if (royalty[address_nft].percentage != 0 && royalty[address_nft].receiver != address(0)) {
            uint _royalty = amount * royalty[address_nft].percentage / 100;
            amount = amount - fee - _royalty;
            address _receiver = royalty[address_nft].receiver;
            token.transferFrom(msg.sender, _receiver, _royalty);
            payable(_receiver).transfer(_royalty);
        }
        payable(IERC721(address_nft).ownerOf(_id)).transfer(amount);
        IERC721(address_nft).transferFrom(IERC721(address_nft).ownerOf(_id), msg.sender, _id);
    }

    function withdrawAdminCrypto(uint _value, address _address) public onlyOwner {
      require(address(this).balance >= _value, "Not enough funds!");
      payable(_address).transfer(_value);
    }

    function sale(uint _id, uint _amount, address _buyer, address _seller, address address_nft) public onlyOwner{
        require(token.balanceOf(_buyer) >= _amount, "Insufficient funds");
        require(_seller == IERC721(address_nft).ownerOf(_id), "You are not the owner");
        uint fee = _amount * serviceFee / 10 / 100;
        uint _royalty = _amount * royalty[address_nft].percentage / 100;
        _amount = _amount - fee - _royalty;
        token.transferFrom(_buyer, _seller, _amount);
        token.transferFrom(_buyer, address(this), fee);
        if (royalty[address_nft].percentage != 0) {
            address _receiver = royalty[address_nft].receiver;
            token.transferFrom(_buyer, _receiver, _royalty);
        }
        IERC721(address_nft).transferFrom(_seller, _buyer, _id);
    }
    
    function setCost(uint _id, uint _cost, address address_nft) public {
        address _owner = IERC721(address_nft).ownerOf(_id);
        require(msg.sender == _owner, "You are note the owner");
        cost[address_nft][_id] = _cost;
    }

    function setRoyalty(address _receiver, uint _percentage, address address_nft) public {
        address _owner = IERC721(address_nft).owner();
        require(msg.sender == _owner, "You are note the owner");
        require(_receiver != address(0), "Receiver is the zero address");
        require(_percentage != 0, "Percentage is the zero");
        royalty[address_nft].receiver = _receiver;
        royalty[address_nft].percentage = _percentage;
    }

    function withdraw(uint _amount) public onlyOwner{
        address _sender = msg.sender;
        require(token.balanceOf(address(this)) >= _amount);
        token.transfer(_sender, _amount);
    }

    function withdrawRemainder() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getCost(address address_nft, uint _id) external view returns(uint){
        return cost[address_nft][_id];
    }

    function setToken(address _token) public onlyOwner{
        token = IBEP20(_token);
    }

}