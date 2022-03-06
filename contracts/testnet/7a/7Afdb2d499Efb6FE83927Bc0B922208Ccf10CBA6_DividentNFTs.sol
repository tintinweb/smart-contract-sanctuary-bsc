/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
  interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  }

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}


abstract contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}
library Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}




interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}


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
interface IERC721Enumerable
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
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender);
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract DividentNFTs is ERC165, IERC721, IERC721Metadata ,IERC721Enumerable,Ownable {
    using Strings for uint256;
    string private _name="NFT";
    string private _symbol="Symbol";
    string public _baseURI="BaseURI";
    string public baseExtension = ".json";
    string notRevealedUri="NOT Revealed";

    mapping(uint256 => address) private _owners;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => uint256[]) private _tokenOfOwner;
    address[] NFTHolders;
    uint256[] ownerID;
    uint[] ClaimedAmountOfNFT;
    mapping(address => mapping(address => bool)) private _operatorApprovals;


    uint LaunchTimestamp=type(uint).max;

    uint256 public MaxNFTCount=10000;
    uint256 public currentValue=0.0005 ether;

    bool public revealed;

    function setValue(uint newValue) public onlyOwner {
        currentValue=newValue;
    }
    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }
    function OwnerSetBaseURI(string memory newBaseURI) external onlyOwner{
        _baseURI=newBaseURI;
    }
    function reveal() external onlyOwner{
        revealed=true;
    }

    uint public totalClaimPerNFT;
    uint public totalClaimGlobal;
    //IERC20 shiba=IERC20(0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE);
    IERC20 shiba=IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

  function OwnerClaimETH() public onlyOwner{
      (bool sent,)=msg.sender.call{value:address(this).balance}("");
    require(sent);
  }
  event AddShiba(uint amount);
  function AddTokens(uint amount) public onlyOwner{
      shiba.transferFrom(msg.sender,address(this),amount);
      uint amountPerNFT=amount/totalSupply();
      totalClaimPerNFT+=amountPerNFT;
      totalClaimGlobal+=amount;
      emit AddShiba(amount);
  }
    
      function ClaimShiba() external{
      uint totalClaim=0;
      for(uint i=0;i<balanceOf(msg.sender);i++){
          uint ID=tokenOfOwnerByIndex(msg.sender,i);
            totalClaim+=(totalClaimPerNFT-ClaimedAmountOfNFT[ID]);
            ClaimedAmountOfNFT[ID]=totalClaimPerNFT;
      }
      shiba.transfer(msg.sender,totalClaim);
  }
  function ClaimShiba(uint From, uint To) external{
      uint totalClaim=0;
      
      for(uint i=From;i<To;i++){
          uint ID=tokenOfOwnerByIndex(msg.sender,i);
            totalClaim+=(totalClaimPerNFT-ClaimedAmountOfNFT[ID]);
            ClaimedAmountOfNFT[ID]=totalClaimPerNFT;
      }
      shiba.transfer(msg.sender,totalClaim);
  }






    constructor() {
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(type(IERC721).interfaceId);
        _registerInterface(type(IERC721Metadata).interfaceId);
        _registerInterface(type(IERC721Enumerable).interfaceId);

    }

    function setLaunchIn(uint TimeToLaunch) external{
        setLaunch(block.timestamp+TimeToLaunch);
    }
    function setLaunch(uint Timestamp) public onlyOwner{
        require(Timestamp>=block.timestamp);
        LaunchTimestamp=Timestamp;

    }


    function OwnerMint(uint count) external onlyOwner{
        for(uint i=0;i<count;i++)
            _mint();
    }
    function Mint() public payable{
        require(block.timestamp>LaunchTimestamp,"Sale not yet open");
        uint256 presalePurchases=msg.value/currentValue;
        require(presalePurchases>0,"Not enough ETH sent");

        require(NFTHolders.length+presalePurchases<=MaxNFTCount);
        for(uint i=0;i<presalePurchases;i++){
            _mint();
        }
    }

    function _mint() private{
        uint256 Number=NFTHolders.length;
        ClaimedAmountOfNFT.push(totalClaimPerNFT);
        NFTHolders.push(msg.sender);
        ownerID.push(0);
        _AddNFT(msg.sender,Number);
        emit Transfer(address(0),msg.sender,Number);
    }

    //Adds NFT during transfer
    function _AddNFT(address account, uint256 ID) private{
        ownerID[ID]=balanceOf(account);
        //the new NFT will be added as the last NFT of the holder
        _tokenOfOwner[account].push(ID);
        NFTHolders[ID]=account;
    }
    //Removes NFT during transfer
    function _RemoveNFT(address account, uint256 ID) private{
        //the token the holder holds
        uint256[] memory IDs=_tokenOfOwner[account];
        //the Index of the token to be removed
        uint256 TokenIndex=ownerID[ID];
        //If token isn't the last token, reorder token
        if(TokenIndex<IDs.length-1){
            uint256 lastID=IDs[IDs.length-1];
            _tokenOfOwner[account][TokenIndex]=lastID;
        }
        //Remove the Last token ID
        _tokenOfOwner[account].pop();
    }


    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //ERC721//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function transferFrom(address from, address to, uint256 tokenId) external override{
        require(_isApprovedOrOwner(msg.sender, tokenId));
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external override{
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override{
        require(_isApprovedOrOwner(msg.sender, tokenId));
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) private {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }




    
    function _transfer(address from, address to, uint256 tokenId) private {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");
        uint Claim=totalClaimPerNFT-ClaimedAmountOfNFT[tokenId];
        ClaimedAmountOfNFT[tokenId]=totalClaimPerNFT;
        if(Claim>0) shiba.transfer(msg.sender,Claim);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);
        _RemoveNFT(from, tokenId);
        _AddNFT(to,tokenId);
        emit Transfer(from, to, tokenId);
    }


    
    
    //the total Supply is the same as the Length of holders
    function totalSupply() public override view returns (uint256){
        return NFTHolders.length;
    }
    //Index is always = token ID
    function tokenByIndex(uint256 _index) external override view returns (uint256){
        require(_exists(_index));
        return _index;
    }
    
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = NFTHolders[tokenId];
        require(owner != address(0));
        return owner;
    }
    //returns the NFT ID of the owner at position
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public override view returns (uint256){
        return _tokenOfOwner[_owner][_index];
    }
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return NFTHolders.length>tokenId;
    }
    
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
        if (msg.sender!=tx.origin) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert();
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
    
    
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId));
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    } 
    
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0));
        return _tokenOfOwner[owner].length;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI;
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

    function baseURI() public view virtual returns (string memory) {
        return _baseURI;
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner);

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender)
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId));

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != msg.sender);

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }
}