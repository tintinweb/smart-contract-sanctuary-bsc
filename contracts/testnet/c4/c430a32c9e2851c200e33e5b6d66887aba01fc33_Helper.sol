/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


interface IERC165 {
  
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC1155 is IERC165 {
  
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferMultiple(address indexed operator, address indexed from, address[] to, uint256[] amount, uint256 id);

  
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

  
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

  
    function balanceOf(address account, uint256 id) external view returns (uint256);

   
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

   
    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

  
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

  
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _setOwner(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ERC165 is IERC165 {
  
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC1155Receiver is IERC165 {
  
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}


interface IERC1155MetadataURI is IERC1155 {
   
    function uri(uint256 id) external view returns (string memory);
}

library Helper {
      function isContract(address account) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function getEmptyArray() public pure returns(uint256[] memory out){
        out = new uint256[](0);
    }
    function getSingletonArrayAddr(address element) public pure returns (address[] memory) {
        address[] memory array = new address[](1);
        array[0] = element;

        return array;
    }
}


contract test is Ownable, ERC165, IERC1155 {
    // events to handle any UIUX updates
    event CollectionCreated(uint256 collectionID, uint256 totalSupply, string name);
    event CommonAdded(uint256 commonID, uint256 amount, string name);

    // Mapping from token ID to collectible reference
    mapping(uint256 => uint256) private tokenTracker;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Schema for NFT collectibles {see ERC721}
    struct Collection {
        bool _exsists;
        string _url;
        string _name;
        uint256 _totalSupply;
        uint256 _index;
        uint256 _discount;
        uint256[] _prices;
        mapping(address => bool) _whitelist;
        mapping(uint256 => uint256) _idRef;
    }
    // Mapping for a single reference from token IDs
    mapping(uint256 => Collection) private _collections;
    // Schema for FT collectibles {see ERC20}
    struct Common {
        bool _exsists;
        uint256 _totalSupply;
        uint256 _tokenID;
        string _url;
        string _name;
    }
    // Mapping for a single reference from token IDs
    mapping(uint256 => Common) _commons;
    // track all created collectibles
    uint256 public createCounter = 0;
    // track all created tokens
    uint256 public tokenCounter = 0;
    // a simple price basis multiplier for 18 decimals.
    uint256 priceBasis = 1 ether;


    // add wallet addresses to whitelist and set the discount price
    function AddWhitelist(uint256 collectionID, uint256 discount, address[] memory wallets) external onlyOwner {
        require(isCollection(collectionID), "test: collectionID does not exist");
        for(uint256 i=0; i<wallets.length; i++){
            _collections[collectionID]._whitelist[wallets[i]] = true; 
        }
        _collections[collectionID]._discount = discount;
    }
    // get the price of the current mint from the index of collection
    function _getIndexPricing(uint256 collectionID) internal view returns(uint256){
        uint256[] memory pricing = _collections[collectionID]._prices;
        uint256 curIndex = _collections[collectionID]._index;
        if(pricing.length > 1 && curIndex < (pricing.length-1)){
            return(pricing[curIndex]);
        }
        return(pricing[0]);
    }
    // check if wallet is whitelisted and get the mint prices accodingly
    function getMintPrice(uint256 collectionID, address wallet) public view returns(uint256 mintPrice){
        require(isCollection(collectionID), "test: collectionID does not exist");
        uint256 basePrice = _getIndexPricing(collectionID)*priceBasis;
        if(_collections[collectionID]._whitelist[wallet]){
            uint256 dscnt = _collections[collectionID]._discount;
            mintPrice = ((dscnt*basePrice)/100);
        }else{
            mintPrice = basePrice;
        }
    }
    // get the current supply and the maximum supply for a particular collection
    function getSupply(uint256 collectionID) public view returns(uint256 currentSupply, uint256 maxSupply){
        require(isCollection(collectionID), "test: collectionID does not exist");
        return(_collections[collectionID]._index, _collections[collectionID]._totalSupply);
    }
    // safe add a tokenID to the collection and remove wallet from whitelisting
    function _safeAddToCollection(uint256 collectionID, uint256 currentSupply, uint256 tokenID, address wallet) internal {
        _collections[collectionID]._idRef[currentSupply] = tokenID;
        _collections[collectionID]._totalSupply += 1;
        _collections[collectionID]._index += 1;
        _collections[collectionID]._whitelist[wallet] = false;
    }
    // mint function for NFTs in collections
    function mintNFT(uint256 collectionID, address to) external payable {
        tokenCounter += 1;
        (uint256 cur, uint256 max) = getSupply(collectionID);
        require(cur < max, "test: no more avaliable NFTs to mint from this collection");
        uint256 mintPrice = getMintPrice(collectionID, msg.sender);
        require(msg.value >= mintPrice, "test: insufficient funds to mint");
        _mint(to, tokenCounter, 1, "");
        _safeAddToCollection(collectionID,cur, tokenCounter, msg.sender);
    }


    // boring interface functions for outsider smart contracts.
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    // create a new collection {check ERC721}
    function createNewCollection(uint256 collectionSupply, string memory collectionName, uint256[] memory collectionPrices, string memory url) external onlyOwner {
        _createCollection(collectionSupply, collectionName, url, collectionPrices);
    }
    // create a new common {check ERC20}
    function createCommon(uint256 amount,string memory name, string memory url) external onlyOwner {
        _createCollection(amount, name, url, Helper.getEmptyArray());
    }
    // create a collection or a common based on parameters
    function _createCollection(uint256 _colSupply, string memory _colName, string memory _colUrl, uint256[] memory _colPrices) internal {
        createCounter += 1;
        if(_colPrices.length == 0){
            tokenCounter += 1;
            _commons[createCounter] = Common(true, _colSupply, tokenCounter, _colUrl, _colName);
            emit CommonAdded(createCounter, _colSupply, _colName);
        }else{
            _collections[createCounter]._totalSupply = _colSupply;
            _collections[createCounter]._exsists = true;
            _collections[createCounter]._url = _colUrl;
            _collections[createCounter]._name = _colName;
            _collections[createCounter]._prices = _colPrices; 
            emit CollectionCreated(createCounter, _colSupply, _colName);
        }
    }
    // check if the token ID is an NFT
    function isCollection(uint256 id) public view returns(bool){
        return(_collections[id]._exsists);
    }
    // check if the token ID is a FT
    function isCommon(uint256 id) public view returns(bool){
        return(!isCollection(id));
    }
    // returns the uri for any token (NFT && FT)
    function uri(uint256 tokenID) public view returns (string memory) {
        return(isCollection(tokenTracker[tokenID]) ? _collections[tokenTracker[tokenID]]._url : _commons[tokenTracker[tokenID]]._url);
    }
    // get the collection reference of the token
    function tokenReference(uint256 tokenID) public view returns(uint256 ref, bool isNFT){
        ref = tokenTracker[tokenID];
        isNFT = isCollection(ref);
    }
    // get the collection parameters of the token
    function getTokensCollection(uint256 tokenID) public view returns(uint256 collectionID, string memory collectionName, uint256 totalSupply){
        bool isCol;
        (collectionID, isCol) = tokenReference(tokenID);
        if(!isCol){
            revert("test: This ID is not a collection");
        }
        collectionName = _collections[collectionID]._name;
        totalSupply = _collections[collectionID]._totalSupply;
    }
    // get all token IDs associated with a collection
    function getCollectionTokens(uint256 collectionID) public view returns(uint256[] memory tokenIDs){
        require(isCollection(collectionID), "test: This ID is not a collection");
        uint256 mintIndex = _collections[collectionID]._index;
        tokenIDs = new uint256[](mintIndex);
        for(uint256 i=0; i<mintIndex; i++){
            tokenIDs[i] = _collections[collectionID]._idRef[i];
        }
    }
    /**
     * @dev sets a new uri for the collection
     * @notice this will set a new base uri for all the tokens included in the collection!
     */
    function _setURI(uint256 collectionID, string memory nURL) internal {
        if(isCollection(collectionID)){
            _collections[collectionID]._url = nURL;
        }else if(isCommon(collectionID)){
            _commons[collectionID]._url = nURL;
        }else{
            revert("test: CollectionID does not exist");
        }
    }
    // check the current balance of a particular id
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "test: balance query for the zero address");
        return _balances[id][account];
    }
    // check the balance of a batch of wallets vs a batch of ids
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view virtual override returns (uint256[] memory){
        require(accounts.length == ids.length, "test: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }
    // check the current balance of a wallet aganist a collection
    function balanceOfCollection(address account, uint256 collectionID) public view returns(uint256){
        uint256[] memory _tokenIDs = getCollectionTokens(collectionID);
        uint256 accountBalance = 0;
        for(uint256 i=0; i<_tokenIDs.length; i++){
            if(balanceOf(account, _tokenIDs[i]) > 0){
                accountBalance += 1;
            }
        }
        return accountBalance;
    }
    // set approval for a unique token
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(_msgSender() != operator, "test: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }
    // check if approved operator for all tokens
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[account][operator];
    }
    // safe transfer with onERC1155 recieved check
    function safeTransferFrom(address from,address to,uint256 id,uint256 amount,bytes memory data) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "test: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }
    // safe batch transfer multiple tokenIDs with multiple amounts
    function safeBatchTransferFrom(address from,address to,uint256[] memory ids,uint256[] memory amounts,bytes memory data) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "test: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }
    // an internal function with a check onERC1155received for a single token
    function _safeTransferFrom(address from,address to,uint256 id,uint256 amount,bytes memory data) internal virtual {
        require(to != address(0), "test: transfer to the zero address");

        address operator = _msgSender();

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "test: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }
    // an internal function with a check onERC1155received for a multiple tokens
    function _safeBatchTransferFrom(address from,address to,uint256[] memory ids,uint256[] memory amounts,bytes memory data) internal virtual {
        require(ids.length == amounts.length, "test: ids and amounts length mismatch");
        require(to != address(0), "test: transfer to the zero address");

        address operator = _msgSender();

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "test: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }
    // a public function to mint fungible tokens
    function mintFT(uint256 commonID, address[] memory to, uint256[] memory amounts) external onlyOwner {
        require(amounts.length == to.length, "test: Array mismatch");
        require(isCommon(commonID), "test: This common ID does not exist");        
        uint256 tokenID = _commons[commonID]._tokenID;
        address operator = _msgSender();
        for(uint256 i=0; i<to.length; i++){
            require(to[i] != address(0), "test: mint to the zero address");
            _balances[tokenID][to[i]] += amounts[i];
            _doSafeTransferAcceptanceCheck(operator, address(0), to[i], tokenID, amounts[i], "");
        }
        emit TransferMultiple(operator, address(0), to, amounts, tokenID);
    }   
    // an internal function to mint specifc tokens
    function _mint(address account,uint256 id,uint256 amount,bytes memory data) internal virtual {
        require(account != address(0), "test: mint to the zero address");

        address operator = _msgSender();

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }
    // an internal burn function that might be implemented via the interface for a single token
    function _burn(address account,uint256 id,uint256 amount) internal virtual {
        require(account != address(0), "test: burn from the zero address");

        address operator = _msgSender();

        uint256 accountBalance = _balances[id][account];
        require(accountBalance >= amount, "test: burn amount exceeds balance");
        unchecked {
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferSingle(operator, account, address(0), id, amount);
    }
    // an internal burn function that might be implemented via the interface for multiple tokens
    function _burnBatch(address account,uint256[] memory ids,uint256[] memory amounts) internal virtual {
        require(account != address(0), "test: burn from the zero address");
        require(ids.length == amounts.length, "test: ids and amounts length mismatch");

        address operator = _msgSender();

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(accountBalance >= amount, "test: burn amount exceeds balance");
            unchecked {
                _balances[id][account] = accountBalance - amount;
            }
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }
    // a check to make sure ERC1155 tokens do not get stuck in smart contracts for a single token
    function _doSafeTransferAcceptanceCheck(address operator,address from,address to,uint256 id,uint256 amount,bytes memory data) private {
            if(Helper.isContract(to)){
                try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                    if (response != IERC1155Receiver.onERC1155Received.selector) {
                        revert("test: ERC1155Receiver rejected tokens");
                    }
                } catch Error(string memory reason) {
                    revert(reason);
                } catch {
                    revert("test: transfer to non ERC1155Receiver implementer");
                }
            }
    }
    // a check to make sure ERC1155 tokens do not get stuck in smart contracts for multiple tokens
    function _doSafeBatchTransferAcceptanceCheck(address operator,address from,address to,uint256[] memory ids,uint256[] memory amounts,bytes memory data) private {
        if(Helper.isContract(to)){
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("test: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("test: transfer to non ERC1155Receiver implementer");
            }
        }
    }
}