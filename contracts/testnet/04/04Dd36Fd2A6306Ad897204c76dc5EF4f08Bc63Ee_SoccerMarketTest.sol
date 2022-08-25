// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

interface IERC721 {
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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from,address to,uint256 tokenId) external;

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
    function transferFrom(address from,address to,uint256 tokenId) external;

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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

contract SoccerMarketTest is Ownable {
    IERC721 public playerContract;
    IERC721 public equipmentContract;
    IERC20 public playerFragmentContract;
    IERC20 public equipmentFragmentContract;

    struct NFTItemSale{
        address payable seller;
        uint price;
        uint256 itemNum;
        uint256 tokenId;
        bool onSale;
    }

    struct FragmentItemSale{
        address payable seller;
        uint price;
        uint256 itemNum;
        uint256 amount;
        bool onSale;
    }

    uint public taxFee = 5;
    uint public minPrice = 0.005 ether;
    NFTItemSale[] playerItemSales;
    NFTItemSale[] equipmentItemSales;
    FragmentItemSale[] pFragmentItemSales;
    FragmentItemSale[] eFragmentItemSales;
    mapping (uint => NFTItemSale) public playerItemToSale;
    mapping (uint => NFTItemSale) public equipmentItemToSale;
    mapping (uint => FragmentItemSale) public pFragmentItemToSale;
    mapping (uint => FragmentItemSale) public eFragmentItemToSale;

    // constructor(address _playerContract, address _eContract, address _pFraContract, address _eFraContract) {
    //    setPlayerContract(_playerContract);
    //    setEquipmentContract(_eContract);
    //    setPlayerFragmentContract(_pFraContract);
    //    setequipmentFragmentContract(_eFraContract);
    // }

    function setPlayerContract(address _pContractAddress) public onlyOwner {
        playerContract = IERC721(_pContractAddress);
    }

    function setEquipmentContract(address _eContractAddress) public onlyOwner {
        equipmentContract = IERC721(_eContractAddress);
    }

    function setPlayerFragmentContract(address _pFraAddress) public onlyOwner {
        playerFragmentContract = IERC20(_pFraAddress);
    }

    function setequipmentFragmentContract(address _eFraAddress) public onlyOwner {
        equipmentFragmentContract = IERC20(_eFraAddress);
    }

    function getAllPlayerItemOnSale() external view returns(uint[] memory listOfItemsOnSale) {
        uint[] memory TokenForSale = new uint[](playerItemSales.length);
        uint counter = 0;
      for(uint256 i = 0; i < playerItemSales.length; i++) {
        if(playerItemSales[i].onSale) {
          TokenForSale[counter] = playerItemSales[i].tokenId;
          counter++;
        }
      }
        return TokenForSale;
    }

    function getAllEquipmentItemOnSale() external view returns(uint[] memory listOfItemsOnSale) {
        uint[] memory TokenForSale = new uint[](equipmentItemSales.length);
        uint counter = 0;
      for(uint256 i = 0; i < equipmentItemSales.length; i++) {
        if(equipmentItemSales[i].onSale) {
          TokenForSale[counter] = equipmentItemSales[i].tokenId;
          counter++;
        }
      }
        return TokenForSale;
    }

    function getAllPFragmentItemOnSale() external view returns(uint[] memory listOfItemsOnSale) {
        uint[] memory TokenForSale = new uint[](pFragmentItemSales.length);
        uint counter = 0;
      for(uint256 i = 0; i < pFragmentItemSales.length; i++) {
        if(pFragmentItemSales[i].onSale) {
          TokenForSale[counter] = pFragmentItemSales[i].itemNum;
          counter++;
        }
      }
        return TokenForSale;
    }

   function getAllEFragmentItemOnSale() external view returns(uint[] memory listOfItemsOnSale) {
        uint[] memory TokenForSale = new uint[](eFragmentItemSales.length);
        uint counter = 0;
      for(uint256 i = 0; i < eFragmentItemSales.length; i++) {
        if(eFragmentItemSales[i].onSale) {
          TokenForSale[counter] = eFragmentItemSales[i].itemNum;
          counter++;
        }
      }
        return TokenForSale;
    }

    function getEFragmentItemSales(uint256 _efindexId) external view returns(FragmentItemSale memory sales) {
        return eFragmentItemSales[_efindexId];
    }

    function saleMyPlayerItem(uint _ptokenId, uint _price) public payable {
        require(_price >= minPrice,"saleMyPlayerItem: The price entered must be greater than the sum of the minimum price and taxFee");
        require(msg.value == _price * taxFee / 100, "saleMyPlayerItem: Please pay the correct handling fee");
        require(playerContract.ownerOf(_ptokenId) == msg.sender, "saleMyPlayerItem: You are not the token owner");
        require(!playerItemToSale[_ptokenId].onSale, "saleMyPlayerItem: The item is onSale");
        require(playerContract.isApprovedForAll(msg.sender, address(this)), "saleMyPlayerItem: Marketplace contract is not an approved operator");
        NFTItemSale memory _newSale = NFTItemSale(payable(msg.sender), _price, playerItemSales.length, _ptokenId, true);
        playerItemToSale[_ptokenId] = _newSale;
        playerItemSales.push(_newSale);
    }

    function saleMyEquipmentItem(uint _etokenId, uint _price) public payable {
        require(_price >= minPrice,"saleMyEquipmentItem: The price entered must be greater than the sum of the minimum price and taxFee");
        require(msg.value == _price * taxFee / 100, "saleMyEquipmentItem: Please pay the correct handling fee");
        require(equipmentContract.ownerOf(_etokenId) == msg.sender, "saleMyEquipmentItem: You are not the token owner");
        require(!equipmentItemToSale[_etokenId].onSale, "saleMyEquipmentItem: The item is onSale");
        require(equipmentContract.isApprovedForAll(msg.sender, address(this)), "saleMyEquipmentItem: Marketplace contract is not an approved operator");
        NFTItemSale memory _newSale = NFTItemSale(payable(msg.sender), _price, equipmentItemSales.length, _etokenId, true);
        equipmentItemToSale[_etokenId] = _newSale;
        equipmentItemSales.push(_newSale);
    }

    function saleMyPFragmentItem(uint _pfAmount, uint _price) public payable {
        require(_price >= minPrice,"saleMyPFragmentItem: The price entered must be greater than the sum of the minimum price and taxFee");
        require(msg.value == _price * taxFee / 100, "saleMyPFragmentItem: Please pay the correct handling fee");
        require(playerFragmentContract.balanceOf(msg.sender) >= _pfAmount, "saleMyPFragmentItem: You don't have so many pieces of equipment");
        require(!pFragmentItemToSale[_pfAmount].onSale, "saleMyPFragmentItem: The item is onSale");
        require(playerFragmentContract.allowance(msg.sender, address(this)) >= _pfAmount, "saleMyPFragmentItem: Marketplace contract is not an approved operator");
        FragmentItemSale memory _newSale = FragmentItemSale(payable(msg.sender), _price, pFragmentItemSales.length, _pfAmount, true);
        pFragmentItemToSale[pFragmentItemSales.length] = _newSale;
        pFragmentItemSales.push(_newSale);
    }

    function saleMyEFragmentItem(uint _efAmount, uint _price) public payable {
        require(_price >= minPrice,"saleMyEFragmentItem: The price entered must be greater than the sum of the minimum price and taxFee");
        require(msg.value == _price * taxFee / 100, "saleMyEFragmentItem: Please pay the correct handling fee");
        require(equipmentFragmentContract.balanceOf(msg.sender) >= _efAmount, "saleMyEFragmentItem: You don't have so many pieces of equipment");
        require(!eFragmentItemToSale[_efAmount].onSale, "saleMyEFragmentItem: The item is onSale");
        require(equipmentFragmentContract.allowance(msg.sender, address(this)) >= _efAmount, "saleMyEFragmentItem: Marketplace contract is not an approved operator");
        FragmentItemSale memory _newSale = FragmentItemSale(payable(msg.sender), _price, eFragmentItemSales.length, _efAmount, true);
        eFragmentItemToSale[eFragmentItemSales.length] = _newSale;
        eFragmentItemSales.push(_newSale);
    }

    function _removePlayerItem(uint256 _ptokenId) private {
        playerItemSales[playerItemToSale[_ptokenId].itemNum].onSale = false;
        delete playerItemToSale[_ptokenId];
    }

    function _removeEquipmentItem(uint256 _etokenId) private {
        equipmentItemSales[equipmentItemToSale[_etokenId].itemNum].onSale = false;
        delete equipmentItemToSale[_etokenId];
    }

    function _removePFragmentItem(uint256 _pfindexId) private {
        pFragmentItemSales[_pfindexId].onSale = false;
        delete pFragmentItemToSale[_pfindexId];
    }

    function _removeEFragmentItem(uint256 _efindexId) private {
        eFragmentItemSales[_efindexId].onSale = false;
        delete eFragmentItemToSale[_efindexId];
    }

    function cancelMyPlayerOnSale(uint256 _ptokenId) external {
        NFTItemSale memory sale = playerItemToSale[_ptokenId];
        require(sale.seller == msg.sender, "cancelMyPlayerOnSale: Only the token seller can remove an offer");
        _removePlayerItem(_ptokenId);
    }

    function cancelMyEquipmentOnSale(uint256 _etokenId) external {
        NFTItemSale memory sale = equipmentItemToSale[_etokenId];
        require(sale.seller == msg.sender, "cancelMyEquipmentOnSale: Only the token seller can remove an offer");
        _removeEquipmentItem(_etokenId);
    }

    function cancelMyPFragmentOnSale(uint256 _pfindexId) external {
        FragmentItemSale memory sale = pFragmentItemToSale[_pfindexId];
        require(sale.seller == msg.sender, "cancelMyPFragmentOnSale: Only the token seller can remove an offer");
        _removePFragmentItem(_pfindexId);
    }

    function cancelMyEFragmentOnSale(uint256 _efindexId) external {
        FragmentItemSale memory sale = eFragmentItemToSale[_efindexId];
        require(sale.seller == msg.sender, "cancelMyEFragmentOnSale: Only the token seller can remove an offer");
        _removeEFragmentItem(_efindexId);
    }

    function buyShopPlayerItem(uint256 _ptokenId) external payable {
        NFTItemSale memory sale = playerItemToSale[_ptokenId];
        require(sale.price == msg.value, "buyShopPlayerItem: The price of the offer is incorrect");
        require(sale.onSale, "buyShopPlayerItem: There is no offer for this token");
        _removePlayerItem(_ptokenId);
        playerContract.transferFrom(sale.seller, msg.sender, _ptokenId);
        (bool success, ) = payable(sale.seller).call{value: sale.price}('');
        require(success, "buyShopPlayerItem: buyShopItem: unable to send transferFee, recipient may have reverted");
    }

    function buyShopEquipmentItem(uint256 _etokenId) external payable {
        NFTItemSale memory sale = equipmentItemToSale[_etokenId];
        require(sale.price == msg.value, "buyShopEquipmentItem: The price of the offer is incorrect");
        require(sale.onSale, "buyShopEquipmentItem: There is no offer for this token");
        _removeEquipmentItem(_etokenId);
        equipmentContract.transferFrom(sale.seller, msg.sender, _etokenId);
        (bool success, ) = payable(sale.seller).call{value: sale.price}('');
        require(success, "buyShopEquipmentItem: buyShopItem: unable to send transferFee, recipient may have reverted");
    }

    function buyShopPFragmentItem(uint256 _pfindexId) external payable {
        FragmentItemSale memory sale = pFragmentItemToSale[_pfindexId];
        require(sale.price == msg.value, "buyShopPFragmentItem: The price of the offer is incorrect");
        require(sale.onSale, "buyShopPFragmentItem: There is no offer for this token");
        _removePFragmentItem(_pfindexId);
        playerFragmentContract.transferFrom(sale.seller, msg.sender, sale.amount);
        (bool success, ) = payable(sale.seller).call{value: sale.price}('');
        require(success, "buyShopPFragmentItem: buyShopItem: unable to send transferFee, recipient may have reverted");
    }

    function buyShopEFragmentItem(uint256 _efindexId) external payable {
        FragmentItemSale memory sale = eFragmentItemToSale[_efindexId];
        require(sale.price == msg.value, "buyShopEFragmentItem: The price of the offer is incorrect");
        require(sale.onSale, "buyShopEFragmentItem: There is no offer for this token");
        _removeEFragmentItem(_efindexId);
        equipmentFragmentContract.transferFrom(sale.seller, msg.sender, sale.amount);
        (bool success, ) = payable(sale.seller).call{value: sale.price}('');
        require(success, "buyShopEFragmentItem: buyShopItem: unable to send transferFee, recipient may have reverted");
    }

    function withdrawAll() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setTax(uint _value)public onlyOwner{
        taxFee = _value;
    }

    function setMinPrice(uint _value)public onlyOwner{
        minPrice = _value;
    }
}