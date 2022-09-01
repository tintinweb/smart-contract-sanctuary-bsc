// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/ERC1155.sol)

pragma solidity >=0.8.7;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./IERC1155MetadataURI.sol";
import "./ERC165.sol";
import "./Address.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./Pausable.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract RichmanHorseNFT is Context, Ownable, Pausable, ERC165, IERC1155, IERC1155MetadataURI
{
   using Address for address;

   struct TokenMetadata
   {
      string name;
      string color;
      string breed;
      string description;
   }

   /**
    * @dev Modifier to make a function callable only for using by the Marketplace
    */
   modifier onlyMarketplace() {
      require(_msgSender() == _marketplaceAddress, "ERC1155: available only for the Marketplace");
      _;
   }

   address public _marketplaceAddress;

   uint256[] public _tokens; // all NFT IDs
   address[] public _accounts; // all accounts

   // Mapping from token ID to account balances
   mapping(uint256 => mapping(address => uint256)) public _balances;

   // Mapping from token ID to its metadata
   mapping(uint256 => TokenMetadata) public _metadatas;

   // Mapping from account to operator approvals
   mapping(address => mapping(address => bool)) public _operatorApprovals;

   // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
   string public _uri;

   constructor() {
      _uri = "";
   }
   
   receive() external payable { }
   fallback() external payable { }

   /***********************************************************************/

   function pause() external onlyOwner whenNotPaused {
      _pause();
   }

   function unpause() external onlyOwner whenPaused {
      _unpause();
   }

   function getBalance() public view returns (uint256) {
      return address(this).balance;
   }

   function setMarketplaceAddress(address address_) external onlyOwner
   {
      require(address_ != address(0), "ERC1155: wrong address_");
      _marketplaceAddress = address_;
   }

   function setTokenMetadata(
      uint256 tokenId_,
      string memory name_,
      string memory color_,
      string memory breed_,
      string memory description_) external onlyOwner
   {
      TokenMetadata memory mdata = TokenMetadata(
      {
         name: name_
         , color: color_
         , breed: breed_
         , description: description_
      });
      _metadatas[tokenId_] = mdata;
   }

   function _tokenExists(uint256 tokenId) internal view returns(bool)
   {
      bool found = false;
      for (uint256 i = 0; i < _tokens.length; ++i)
      {
         if (_tokens[i] == tokenId)
         {
            found = true;
            break;
         }
      }
      return found;
   }

   function tokenExists(uint256 tokenId) external view returns(bool) {
      return _tokenExists(tokenId);
   }

   function _addTokenIfNotExists(uint256 tokenId) internal
   {
      if (!_tokenExists(tokenId)) {
         _tokens.push(tokenId);
      }
   }

   function _addAccountIfNotExists(address account) internal
   {
      bool found = false;
      for (uint256 i = 0; i < _accounts.length; ++i)
      {
         if (_accounts[i] == account)
         {
            found = true;
            break;
         }
      }
      if (!found) {
         _accounts.push(account);
      }
   }

   /**
    * @dev See {IERC1155-safeTransferFrom}.
    */
   function safeTransferFrom(
      address from,
      address to,
      uint256 id,
      uint256 amount,
      bytes memory data) public override whenNotPaused
   {
      require(
         (from == _msgSender()) || isApprovedForAll(from, _msgSender()),
         "ERC1155: caller is not token owner or approved"
      );
      require(to != address(0), "ERC1155: transfer to the zero address");

      address operator = _msgSender();
      uint256[] memory ids = _asSingletonArray(id);
      uint256[] memory amounts = _asSingletonArray(amount);

      _beforeTokenTransfer(operator, from, to, ids, amounts, data);

      uint256 fromBalance = _balances[id][from];
      require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
      unchecked {
         _balances[id][from] = fromBalance - amount;
      }
      _balances[id][to] += amount;

      _addAccountIfNotExists(to);

      emit TransferSingle(operator, from, to, id, amount);

      _afterTokenTransfer(operator, from, to, ids, amounts, data);

      _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
   }

   /**
    * @dev See {IERC1155-safeBatchTransferFrom}.
    */
   function safeBatchTransferFrom(
      address from,
      address to,
      uint256[] memory ids,
      uint256[] memory amounts,
      bytes memory data) public override whenNotPaused
   {
      require(
         (from == _msgSender()) || isApprovedForAll(from, _msgSender()),
         "ERC1155: caller is not token owner or approved"
      );
      require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
      require(to != address(0), "ERC1155: transfer to the zero address");

      address operator = _msgSender();

      _beforeTokenTransfer(operator, from, to, ids, amounts, data);

      for (uint256 i = 0; i < ids.length; ++i)
      {
         uint256 id = ids[i];
         uint256 amount = amounts[i];

         uint256 fromBalance = _balances[id][from];
         require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
         unchecked {
            _balances[id][from] = fromBalance - amount;
         }
         _balances[id][to] += amount;
      }

      _addAccountIfNotExists(to);

      emit TransferBatch(operator, from, to, ids, amounts);

      _afterTokenTransfer(operator, from, to, ids, amounts, data);

      _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
   }

   function mintToken(
      address to,
      uint256 id,
      uint256 amount,
      bytes memory data) external onlyOwner
   {
      require(to != address(0), "ERC1155: mint to the zero address");

      address operator = _msgSender();
      uint256[] memory ids = _asSingletonArray(id);
      uint256[] memory amounts = _asSingletonArray(amount);

      _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

      _balances[id][to] += amount;

      _addTokenIfNotExists(id);
      _addAccountIfNotExists(operator);

      emit TransferSingle(operator, address(0), to, id, amount);

      _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

      _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
   }   

   /**
    * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
    *
    * Emits a {TransferBatch} event.
    *
    * Requirements:
    *
    * - `ids` and `amounts` must have the same length.
    * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
    * acceptance magic value.
    */
   function mintBatch(
      address to,
      uint256[] memory ids,
      uint256[] memory amounts,
      bytes memory data) external onlyOwner
   {
      require(to != address(0), "ERC1155: mint to the zero address");
      require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

      address operator = _msgSender();

      _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

      for (uint256 i = 0; i < ids.length; i++)
      {
         _balances[ids[i]][to] += amounts[i];

         _addTokenIfNotExists(ids[i]);
      }
      _addAccountIfNotExists(operator);

      emit TransferBatch(operator, address(0), to, ids, amounts);

      _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

      _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
   }

   function mintByMarketplace(address to, uint256 id, uint256 amount) external onlyMarketplace
   {
      _balances[id][to] += amount;

      _addTokenIfNotExists(id);
      _addAccountIfNotExists(to);
   }

   /**
    * @dev Destroys `amount` tokens of token type `id` from `from`
    *
    * Emits a {TransferSingle} event.
    */
   function burnToken(uint256 id, uint256 amount) external whenNotPaused
   {
      address sender = _msgSender();

      uint256[] memory ids = _asSingletonArray(id);
      uint256[] memory amounts = _asSingletonArray(amount);

      _beforeTokenTransfer(sender, sender, address(0), ids, amounts, "");

      uint256 fromBalance = _balances[id][sender];
      require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
      unchecked {
         _balances[id][sender] = fromBalance - amount;
      }

      emit TransferSingle(sender, sender, address(0), id, amount);

      _afterTokenTransfer(sender, sender, address(0), ids, amounts, "");
   }

   /**
    * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
    *
    * Emits a {TransferBatch} event.
    *
    * Requirements:
    *
    * - `ids` and `amounts` must have the same length.
    */
   function burnTokenBatch(
      uint256[] memory ids,
      uint256[] memory amounts) external whenNotPaused
   {
      address sender = _msgSender();
      require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

      _beforeTokenTransfer(sender, sender, address(0), ids, amounts, "");

      for (uint256 i = 0; i < ids.length; i++)
      {
         uint256 id = ids[i];
         uint256 amount = amounts[i];

         uint256 fromBalance = _balances[id][sender];
         require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
         unchecked {
            _balances[id][sender] = fromBalance - amount;
         }
      }

      emit TransferBatch(sender, sender, address(0), ids, amounts);

      _afterTokenTransfer(sender, sender, address(0), ids, amounts, "");
   }

   function burnByMarketplace(address account, uint256 id, uint256 amount) external onlyMarketplace
   {
      uint256 fromBalance = _balances[id][account];
      require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
      unchecked {
         _balances[id][account] = fromBalance - amount;
      }
   }

   /***********************************************************************/

   function getTokensLength() external view returns(uint256) {
      return _tokens.length;
   }

   function getAccountsLength() external view returns(uint256) {
      return _accounts.length;
   }

   /**
    * @dev See {IERC165-supportsInterface}.
    */
   function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool)
   {
      return(
         (interfaceId == type(IERC1155).interfaceId) ||
         (interfaceId == type(IERC1155MetadataURI).interfaceId) ||
         super.supportsInterface(interfaceId)
      );
   }

   /**
    * @dev See {IERC1155MetadataURI-uri}.
    *
    * This implementation returns the same URI for *all* token types. It relies
    * on the token type ID substitution mechanism
    * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
    *
    * Clients calling this function must replace the `\{id\}` substring with the
    * actual token type ID.
    */
   function uri(uint256) public view override returns (string memory) {
      return _uri;
   }

   /**
    * @dev See {IERC1155-balanceOf}.
    *
    * Requirements:
    *
    * - `account` cannot be the zero address.
    */
   function balanceOf(address account, uint256 id) public view virtual override returns (uint256)
   {
      require(account != address(0), "ERC1155: address zero is not a valid owner");
      return _balances[id][account];
   }

   /**
    * @dev See {IERC1155-balanceOfBatch}.
    *
    * Requirements:
    *
    * - `accounts` and `ids` must have the same length.
    */
   function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
      public
      view
      virtual
      override
      returns (uint256[] memory)
   {
      require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

      uint256[] memory batchBalances = new uint256[](accounts.length);

      for (uint256 i = 0; i < accounts.length; ++i) {
         batchBalances[i] = balanceOf(accounts[i], ids[i]);
      }

      return batchBalances;
   }

   /**
    * @dev See {IERC1155-setApprovalForAll}.
    */
   function setApprovalForAll(address operator, bool approved) public virtual override {
      _setApprovalForAll(_msgSender(), operator, approved);
   }

   /**
    * @dev See {IERC1155-isApprovedForAll}.
    */
   function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
      return _operatorApprovals[account][operator];
   }

   /**
    * @dev Sets a new URI for all token types, by relying on the token type ID
    * substitution mechanism
    * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
    *
    * By this mechanism, any occurrence of the `\{id\}` substring in either the
    * URI or any of the amounts in the JSON file at said URI will be replaced by
    * clients with the token type ID.
    *
    * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
    * interpreted by clients as
    * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
    * for token type ID 0x4cce0.
    *
    * See {uri}.
    *
    * Because these URIs cannot be meaningfully represented by the {URI} event,
    * this function emits no events.
    */
   function setURI(string memory newuri) public onlyOwner {
      _uri = newuri;
   }

   /**
    * @dev Approve `operator` to operate on all of `owner` tokens
    *
    * Emits an {ApprovalForAll} event.
    */
   function _setApprovalForAll(
      address owner,
      address operator,
      bool approved
   )
   internal virtual
   {
      require(owner != operator, "ERC1155: setting approval status for self");
      _operatorApprovals[owner][operator] = approved;
      emit ApprovalForAll(owner, operator, approved);
   }

   /**
    * @dev Hook that is called before any token transfer. This includes minting
    * and burning, as well as batched variants.
    *
    * The same hook is called on both single and batched variants. For single
    * transfers, the length of the `ids` and `amounts` arrays will be 1.
    *
    * Calling conditions (for each `id` and `amount` pair):
    *
    * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
    * of token type `id` will be  transferred to `to`.
    * - When `from` is zero, `amount` tokens of token type `id` will be minted
    * for `to`.
    * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
    * will be burned.
    * - `from` and `to` are never both zero.
    * - `ids` and `amounts` have the same, non-zero length.
    *
    * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
    */
   function _beforeTokenTransfer(
      address operator,
      address from,
      address to,
      uint256[] memory ids,
      uint256[] memory amounts,
      bytes memory data
   )
   internal virtual { }

   /**
    * @dev Hook that is called after any token transfer. This includes minting
    * and burning, as well as batched variants.
    *
    * The same hook is called on both single and batched variants. For single
    * transfers, the length of the `id` and `amount` arrays will be 1.
    *
    * Calling conditions (for each `id` and `amount` pair):
    *
    * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
    * of token type `id` will be  transferred to `to`.
    * - When `from` is zero, `amount` tokens of token type `id` will be minted
    * for `to`.
    * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
    * will be burned.
    * - `from` and `to` are never both zero.
    * - `ids` and `amounts` have the same, non-zero length.
    *
    * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
    */
   function _afterTokenTransfer(
      address operator,
      address from,
      address to,
      uint256[] memory ids,
      uint256[] memory amounts,
      bytes memory data
   ) internal virtual { }

   function _doSafeTransferAcceptanceCheck(
      address operator,
      address from,
      address to,
      uint256 id,
      uint256 amount,
      bytes memory data
   )
   private
   {
      if (to.isContract())
      {
         try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response)
         {
            if (response != IERC1155Receiver.onERC1155Received.selector) {
               revert("ERC1155: ERC1155Receiver rejected tokens");
            }
         }
         catch Error(string memory reason) {
            revert(reason);
         }
         catch {
            revert("ERC1155: transfer to non-ERC1155Receiver implementer");
         }
      }
   }

   function _doSafeBatchTransferAcceptanceCheck(
      address operator,
      address from,
      address to,
      uint256[] memory ids,
      uint256[] memory amounts,
      bytes memory data
   )
   private
   {
      if (to.isContract())
      {
         try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data)
         returns (bytes4 response)
         {
            if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
               revert("ERC1155: ERC1155Receiver rejected tokens");
            }
         }
         catch Error(string memory reason) {
            revert(reason);
         }
         catch {
            revert("ERC1155: transfer to non-ERC1155Receiver implementer");
         }
      }
   }

   function _asSingletonArray(uint256 element) private pure returns (uint256[] memory)
   {
      uint256[] memory array = new uint256[](1);
      array[0] = element;

      return array;
   }

} // RichmanHorseNFT