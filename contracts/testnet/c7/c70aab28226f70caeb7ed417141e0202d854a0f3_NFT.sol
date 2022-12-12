// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Ownable.sol";
import "./ERC1155.sol";
import "./Strings.sol";


contract NFT is ERC1155, Ownable {
    
    using Strings for uint256;

    bool public paused = true; 
    bool public revealed;

    uint256 public totalPaid;
    uint256 private _tokenIds;
    uint256 public adminCounter;
    uint256 public blacklistCounter;
    uint256 public privatelistCounter;    
    uint256 public mintAmountPerUser = 26;
    uint256 public maxTotalMintAmount = 26;    
    uint256 public mintCost = 0.005 ether;
    uint256 public transferFee = 0.001 ether;
    

    string private _baseURI;    
    string private _notRevealedUri;
    string private _baseExtension = ".json";
    
    struct adminInfo {
        bool oldAdmin;
        bool nowAdmin;
    }

    struct metadataInfo {
        string metadataUri;
        bool updatedStatus;
    }

    struct Item {
        uint256 id;
        address creator;
        uint256 quantity;
        address holder;
    }    

     //private user info
    struct PUserInfo {
        bool status;
        uint256 mintAmount;
        uint256 transferFee;
        uint256 nftMintCost;
    }
    
    mapping(uint256 => Item) private _items;    
    mapping(address => bool) private _blacklist;
    mapping(address => adminInfo) private _admins;
    mapping(address => uint256[]) private _adrToIds;
    mapping(address => PUserInfo) private _privatelist;
    mapping(address => uint256) private _amountsNFTMinted;
    mapping(uint256 => metadataInfo) private _updateMetadata;

    constructor(
        string memory uri_,
        string memory notRevealedUri_       
    ) ERC1155(uri_) {
        _notRevealedUri = notRevealedUri_;
        _baseURI = uri_;        
    }
     
    modifier onlyOwnerorAdmin(){                
        require(owner()== msg.sender || _admins[msg.sender].nowAdmin, "You are not Authorized");            
         _;
    }

    modifier onlyOwnerorAdminorSender(address user_){        
        require(owner()== msg.sender || _admins[msg.sender].nowAdmin || msg.sender == user_ ,"You are not Authorized");
        _;
    }

    modifier blacklistControl(address user_){        
        require(!_blacklist[msg.sender] && !_blacklist[user_], "blacklisted address");
        _;
    }

    modifier issAddress(address user_){ 
        require(user_ == address(user_) && user_ != address(0), "Address type is invalid"); 
        _;
    }

    modifier issStrEmpty(string memory str_) { 
        require(bytes(str_).length>0, "invalid data"); 
        _;
    }

    function postMint(address toUser_, uint256 mintAmount_) external blacklistControl(toUser_) issAddress(toUser_) payable {
        require(!paused, "mint is paused");
        require(_tokenIds + mintAmount_ <= maxTotalMintAmount, "mint amount is trying to mint non-collection id");

        if (_privatelist[msg.sender].status) {
            require(
                msg.value >= _privatelist[msg.sender].nftMintCost * mintAmount_,
                "Insufficient funds for mint"
            );
            
            require(
                _amountsNFTMinted[msg.sender] + mintAmount_ <= _privatelist[msg.sender].mintAmount,
                "nft collection amount is exceeded"
            );
            totalPaid += mintAmount_ * _privatelist[msg.sender].nftMintCost;
        } else {
            require(msg.value >= mintCost * mintAmount_, "Insufficient funds for mint");
            require(
                _amountsNFTMinted[msg.sender] + mintAmount_ <= mintAmountPerUser,
                "nft collection amount is exceeded"
            );
            totalPaid += mintAmount_ * mintCost;
        }

        for (uint256 i; i < mintAmount_; i++) {
            _mint(toUser_, _tokenIds, 1, "");
            
            if (!isInArray(_adrToIds[toUser_], _tokenIds)) {
                _adrToIds[toUser_].push(_tokenIds);
            }

            _items[_tokenIds] = Item(_tokenIds, msg.sender, 1, toUser_);
            
            _amountsNFTMinted[msg.sender]++;                   
            _tokenIds++;
        }
    }
 

    function putPauseStatus() external onlyOwner {
        paused = !paused;
    }

    function putMaxTotalMintAmount(uint256 newMaxTotalMintAmount_) external onlyOwner {
        require(newMaxTotalMintAmount_ > _tokenIds, "The maximum amount cannot be less than or equal to the mint amount.");
        maxTotalMintAmount = newMaxTotalMintAmount_;
    }

    function putMintAmountPerUser(uint256 newMintAmountPerUser_) external onlyOwner {
        mintAmountPerUser = newMintAmountPerUser_;
    }

    function getUserIdsAmount(address user_) external view returns (uint256, uint256[] memory) {
        return (_adrToIds[user_].length, _adrToIds[user_]);
    }    

    function getMintCurrentAmount() external view returns (uint256) {
        return _tokenIds;
    }

    function getUserMintedAmount(address _user) external view returns (uint256) {
        return _amountsNFTMinted[_user];
    }   

    function isInArray(uint256[] memory tokenIds_, uint256 tokenId_) private pure returns (bool) {
        for (uint256 i; i < tokenIds_.length; i++) {
            if (tokenIds_[i] == tokenId_) {
                return true;
            }
        }
        return false;
    }

     function putLvNFT(uint256 id_, string memory newMetaUri_) external onlyOwnerorAdmin {        
        _updateMetadata[id_].metadataUri = newMetaUri_;
        _updateMetadata[id_].updatedStatus = true;
    }

    function uri(uint256 tokenId_) public view virtual override returns (string memory) {
        require(tokenId_ >= 0 && _items[tokenId_].creator != address(0), "Non existing nft id");
        return _updateMetadata[tokenId_].updatedStatus ? _updateMetadata[tokenId_].metadataUri:
         string(abi.encodePacked(_baseURI, tokenId_.toString(), _baseExtension));
    }

    function remove(uint256 index, address user) private returns (uint256[] memory) {       
        for (uint256 i = index; i < _adrToIds[user].length - 1; i++) {
            _adrToIds[user][i] = _adrToIds[user][i + 1];
        }
        delete _adrToIds[user][_adrToIds[user].length - 1];
        _adrToIds[user].pop();
        return _adrToIds[user];
    }

    function putBatchTransfer(
        address from_,
        address to_,
        uint256[] memory ids_,
        uint256[] memory amounts_
    ) external blacklistControl(to_) issAddress(to_) payable {                
        for (uint256 i; i < amounts_.length; i++) {
            require(amounts_[i] == 1, "amount has to be 1");
        }
        require(from_ == msg.sender, "not allowance");
                
        if (_privatelist[msg.sender].status) {
            require( msg.value >= _privatelist[msg.sender].transferFee * ids_.length,
                "Insufficient funds for batchTransfer"
            );
            totalPaid += ids_.length * _privatelist[msg.sender].transferFee;
        } else {
            require( msg.value >= transferFee * ids_.length,
                "Insufficient funds for batchTransfer"
            );
            totalPaid += ids_.length * transferFee;
        }
        
        _safeBatchTransferFrom(from_, to_, ids_, amounts_, "");
        
        for (uint256 j; j < ids_.length; j++) {
            for (uint256 i; i < _adrToIds[msg.sender].length; i++) {
                if (_adrToIds[msg.sender][i] == ids_[j]) {
                    _adrToIds[to_].push(ids_[j]);
                    remove(i, msg.sender);
                    _items[ids_[j]].holder = to_;
                }
            }
        }
    }

    function getAllMetadataInfo() external onlyOwnerorAdmin view returns(string memory, string memory, string memory)
    {
        return (_baseURI, _notRevealedUri, _baseExtension) ;
    }

    function putTransfer(
        address from_,
        address to_,
        uint256 id_,
        uint256 amount_
    ) external blacklistControl(to_) issAddress(to_) payable {        
        require(from_ == msg.sender, "not allowance");
        require(amount_ == 1, "amount has to be 1");
        if (_privatelist[msg.sender].mintAmount > 0) {
            require(
                msg.value >= _privatelist[msg.sender].transferFee,
                "Insufficient funds for transfer"
            );
            totalPaid += _privatelist[msg.sender].transferFee;
        } else {
            require(msg.value >= transferFee, "Insufficient funds for transfer");
            totalPaid += transferFee;
        }        
        _safeTransferFrom(from_, to_, id_, amount_, "");
        _items[id_].holder = to_;

        for (uint256 i; i < _adrToIds[msg.sender].length; i++) {
            if (_adrToIds[msg.sender][i] == id_) {
                _adrToIds[to_].push(id_);
                remove(i, msg.sender);
            }
        }
    }   

    function renounceOwnership() public virtual override onlyOwner {}

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {}   

    function putBaseURI(string memory newBaseURI_) public onlyOwner issStrEmpty(newBaseURI_) {
        _baseURI = newBaseURI_;
    }

    function postAddWhitelistMember(
        address user_,
        uint256 mintAmount_,
        uint256 nftTransferFee_,
        uint256 nftMintCost_
    ) external onlyOwnerorAdmin issAddress(user_) blacklistControl(user_) {
         
        require(user_ != owner(), "Not possible to add owner");
        require(!_admins[user_].nowAdmin, "Not possible to add admin");       
        require(!_privatelist[user_].status, "Already in whitelist");
               
        _privatelist[user_].mintAmount = mintAmount_;
        _privatelist[user_].transferFee = nftTransferFee_;
        _privatelist[user_].nftMintCost = nftMintCost_;
        _privatelist[user_].status = true;
        privatelistCounter++;
    }

    function deleteWhitelistMember(address user_) external onlyOwnerorAdmin issAddress(user_) {        
        require(_privatelist[user_].status, "User is not in whitelist");
        delete _privatelist[user_];
        privatelistCounter--;
    }

    function postAddBlacklistMember(address user_) external onlyOwnerorAdmin issAddress(user_) {  
        require(!_blacklist[user_], "User already blacklisted"); 
        if(_admins[user_].nowAdmin){
            require(msg.sender == owner(), "only owner admin has permission to add blacklist");
            _admins[user_].nowAdmin = false;
            _admins[user_].oldAdmin = true;
        }
        require(user_ != owner(), "Not possible to add owner");                
        _blacklist[user_] = true;        
        blacklistCounter++;
    }

    function deleteBlacklistMember(address user_) external onlyOwnerorAdmin issAddress(user_) {
        require(_blacklist[user_], "the address is not on the black list");
        if(_admins[user_].oldAdmin){
            require(msg.sender == owner(), "only owner admin has permission to add blacklist");            
        }        
        delete _blacklist[user_];        
        blacklistCounter--;
    }

    function postAddAdminlistMember(address user_) external onlyOwner issAddress(user_) blacklistControl(user_) {        
        require(!_admins[user_].nowAdmin, "address has admin privileges");        
        _admins[user_].nowAdmin = true;
        adminCounter++;
    }

    function deleteAdminlistMember(address user_) external onlyOwner issAddress(user_) {
        require(_admins[user_].nowAdmin, "user is not admin");        
        _admins[user_].nowAdmin = false;
        _admins[user_].oldAdmin = true;
        adminCounter--;        
    }
    
    function getAdminlistMember(address user_) external onlyOwnerorAdmin view returns (bool, bool) {
        return (_admins[user_].nowAdmin, _admins[user_].oldAdmin);
    }

    function getShowItem(uint256 tokenId_) external view returns (Item memory) {
        require(_items[tokenId_].id <= _tokenIds);
        return _items[tokenId_];
    }

    function getBlacklistMember(address user_) external onlyOwnerorAdmin view returns (bool) {         
        return _blacklist[user_];
    }
    
    function getWhitelistMember(address user_) external onlyOwnerorAdminorSender(user_) view
        returns (uint256, uint256, uint256) {                
            require(_privatelist[user_].status, "User is not whitelisted");            
            return (                
                _privatelist[user_].mintAmount,
                _privatelist[user_].transferFee,
                _privatelist[user_].nftMintCost
            );        
    }

    function getAvailableNFTs(address user_) external onlyOwnerorAdminorSender(user_) view
        returns (uint256, uint256, uint256) {
        if (_privatelist[user_].status) {            
            return (
                _privatelist[user_].mintAmount - _amountsNFTMinted[user_],
                _privatelist[user_].transferFee,
                _privatelist[user_].nftMintCost
            );
        } else {
            return (
                mintAmountPerUser - _amountsNFTMinted[user_],
                transferFee,
                mintCost
            );
        }
    }

    function putWithdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }   
}