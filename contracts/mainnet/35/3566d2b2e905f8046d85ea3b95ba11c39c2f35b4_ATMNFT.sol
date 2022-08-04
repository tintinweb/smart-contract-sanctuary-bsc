/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: GLP-3.0
pragma solidity >= 0.8.15;

contract ATMNFT {

//Events
    
    //ERC721 Compatibility
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    
    event Transfer(address approval, address indexed from, address indexed to, uint256 indexed tokenId);
    
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    event Mint(address indexed approval, address indexed to, uint256 indexed tokenId);
    
    event Burn(address indexed approval, address indexed from, uint256 indexed tokenId);
    
    event UpdateOnChainMetadata(uint256 indexed tokenId, uint24 indexed _groupId, uint8 indexed _classRarity, uint32 _upgradeLevel, uint64 _totalSupply);
    
    event FeeChanged(uint newFee);
    
//Variables

    //Constants
    
    //Specific Contract Variables
    address payable private _dev;
    uint private _balance;
    uint private _basicfee;
    address[] private _contracts;
    bool _paused;
    
    //Specific NFT Metadata
    struct _onChainMetadata {
        uint24 _groupId;
        uint8 _classRarity;
        uint32 _upgradeLevel;
        uint64 _upgradePoints;
    }
    mapping(uint256 => _onChainMetadata) private _tokenData;
    
    //ERC20 Compatibility
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    
    //ERC721 Compatibility
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;

    //ERC721 Enumerable Compatibility
    mapping(address => uint256[]) private _ownedTokens;
    
    //ERC721 URIStorage Compatibility
    mapping(uint256 => string) private _tokenURIs;

    constructor(){
        _name = "Ancient Tales & Myths - NFT Contract";
        _symbol = "ATMNFT";
        _dev = payable(msg.sender);
        _balance = 0;
        _basicfee = 50000;
        _paused = false;
        _totalSupply = 0;
    }

// Functions
    
    //ERC165 Compatibility
    function supportsInterface(bytes4 interfaceId) public view 
        returns (bool)
    {
        if(interfaceId == 0xffffffff) return false;
        if(interfaceId == 0x01ffc9a7) return true;
        if(interfaceId == 0x80ac58cd) return true;
        if(interfaceId == 0x5b5e139f) return true;
        if(interfaceId == 0x780e9d63) return true;
        return false;
    }
    
    //ERC721 Functions
    function balanceOf(address owner) public view returns (uint256){ 
        require(owner!=address(0), "ERC721:Invalid address"); 
        return _balances[owner];
    }
    
    function ownerOf(uint256 tokenId) public view returns(address){ 
        address owner = _owners[tokenId]; 
        require(owner!=address(0), "ERC721:Invalid token ID"); 
        return owner; 
    }
    
    function name() public view returns(string memory){
        return _name;
    }
  
    function symbol() public view returns(string memory){
        return _symbol;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function _baseURI() internal view returns(string memory){
        return "";
    }

    function tokenURI(uint256 tokenId) public view returns (string memory){
        require(_owners[tokenId] !=
            address(0), "Invalid token ID");
        return _tokenURIs[tokenId];
    }
    
    function setTokenURI(uint256 tokenId, string memory _tokenURI) public notPaused {
        require(_isApproved(), "Forbidden operation.");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function approve(address to, uint256 tokenId) public {}
    
    function getApproved(uint256 tokenId) public view returns (address){
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721:Invalid token ID");
        return owner;
    }
    
    function setApprovalForAll(address operator, bool approved) public {}
    
    function isApprovedForAll(address owner, address operator) public view returns (bool){
        if(owner==operator)return true;
        return false;
    }
    
    function _isApproved() internal view returns(bool){
        if(msg.sender==_dev) return true;
        address[] memory contracts = _contracts;
        for(uint i=0;i<contracts.length;i++){
            if(msg.sender==contracts[i]) return true;
        }
        return false;
    }
    
    error InsufficientFee(uint amount, uint fee);
    
    function transferFrom( 
        address from, address to, uint256 tokenId) public payable notPaused {
        require (to!=address(0), "Invalid receiver address.");
        address _owner = _owners[tokenId];
        require (from==_owner,"Source address is not Token owner.");
        if(!_isApproved()){
            uint _fee = 2 * _basicfee;
            if(msg.value<_fee) revert InsufficientFee({amount: msg.value, fee: _fee});
            require(msg.sender==from,"Caller is not Token owner.");
        }
        uint256 tokenLocale = locateTokenIndex(from, tokenId);
        _transfer(from, to, tokenId, tokenLocale);
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId) public payable notPaused {
        safeTransferFrom(from,to,tokenId,"");
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data ) public payable notPaused { 
        transferFrom(from, to, tokenId);
    }
    
    function transferToken(address from, address to, uint256 tokenId, uint256 tokenLocale) public payable notPaused {
        require (to!=address(0), "Invalid receiver address.");
        address _owner = _owners[tokenId];
        require (from==_owner,"Source address is not Token owner.");
        if(!_isApproved()){
            uint _fee = 2 * _basicfee;
            if(msg.value<_fee) revert InsufficientFee({amount: msg.value, fee: _fee});
            require(msg.sender==from,"Caller is not Token owner.");
        }
        _transfer(from, to, tokenId, tokenLocale);
    }
    
    function locateTokenIndex(address from, uint256 tokenId) public view returns (uint256) {
        uint256[] memory _tokenList = _ownedTokens[from];
        for(uint256 i=0;i<_tokenList.length;i++){
            if(_tokenList[i]==tokenId) 
                return i;
        }
        return _tokenList.length;
    }
    
    function _transfer(address from, address to, uint256 tokenId, uint256 tokenLocale) internal { 
        uint256[] memory _tokenList = _ownedTokens[from];
        require(_tokenList.length>tokenLocale, "Invalid token index.");
        require(_tokenList[tokenLocale]==tokenId, "Invalid token index.");

        _balances[from] -= 1;
        delete _ownedTokens[from][tokenLocale];
        _balances[to] += 1;
        _ownedTokens[to].push(tokenId);
        _owners[tokenId] = to; 

        emit Transfer(msg.sender, from, to, tokenId);
    }
    
    function mint(address to, uint256 tokenId, string memory URI) public notPaused {
        _mint(to, tokenId);
        setTokenURI(tokenId, URI);
        setTokenData(tokenId, 0, 0, 0, 0);
    }
    
    function _safeMint(address to, uint256 tokenId) public notPaused { 
        _safeMint(to, tokenId, "");
    }
    
    function _safeMint(address to, uint256 tokenId, bytes memory data) public notPaused {
        _mint(to, tokenId);
    }
    
    function _mint(address to, uint256 tokenId) internal {
        require (to!=address(0), "Invalid receiver address.");
        address _owner = _owners[tokenId];
        require(_owner == address(0), "Token already minted.");
        require(_isApproved(), "Forbidden operation.");
        
        _balances[to] += 1;
        _ownedTokens[to].push(tokenId);
        _owners[tokenId] = to;
        _totalSupply += 1;
        
        emit Mint(msg.sender, to, tokenId);
    }
    
    function burnToken(uint256 tokenId, uint256 tokenLocale) public notPaused {
        address _owner = _owners[tokenId];
        require(_owner != address(0), "Invalid Token.");
        require(_isApproved(), "Forbidden operation.");
        uint256[] memory _tokenList = _ownedTokens[_owner];
        require(_tokenList.length>tokenLocale, "Invalid token index.");
        require(_tokenList[tokenLocale]==tokenId, "Invalid token index.");
        
        _balances[_owner] -= 1;
        _totalSupply -= 1;
        delete _ownedTokens[_owner][tokenLocale];
        delete _owners[tokenId];
        
        emit Burn(msg.sender, _owner, tokenId);
    }

    function burn(uint256 tokenId) public notPaused {
        
        address _owner = _owners[tokenId];
        require(_owner != address(0), "Invalid Token.");
        require(_isApproved(), "Forbidden operation.");
        uint256 tokenLocale = locateTokenIndex(_owner, tokenId);
        uint256[] memory _tokenList = _ownedTokens[_owner];
        require(_tokenList.length>tokenLocale, "Invalid token index.");
        require(_tokenList[tokenLocale]==tokenId, "Invalid token index.");
        
        _balances[_owner] -= 1;
        _totalSupply -= 1;
        delete _ownedTokens[_owner][tokenLocale];
        delete _owners[tokenId];
        delete _tokenURIs[tokenId];
        delete _tokenData[tokenId];
        
        emit Burn(msg.sender, _owner, tokenId);
    }
    
    //ERC721 Enumerable Compatibility
    function tokenByIndex(uint256 index) public view returns (uint256) {
        return index;
    }
    
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner), "Invalid token index.");
        return _ownedTokens[owner][index];
    }
    
    //ERC721 Pausable
    modifier notPaused(){
        require(!_paused,"Contract is paused.");
        _;
    }
    
    function pauseContract() public payable isDev {
        _paused = true;
    }
    
    function resumeContract() public payable isDev {
        _paused = false;
    }
    
    function isPaused() public view returns (bool) {
        return _paused;
    }
    
    //Specific NFT Metadata Functions
    
    function setTokenData(uint256 tokenId, uint24 _groupId, uint8 _classRarity, uint32 _upgradeLevel, uint64 _upgradePoints) public {
        require(_isApproved(), "Forbidden operation.");
        _onChainMetadata memory data = _onChainMetadata(_groupId, _classRarity, _upgradeLevel, _upgradePoints);
        _tokenData[tokenId] = data;
        emit UpdateOnChainMetadata(tokenId, _groupId, _classRarity, _upgradeLevel, _upgradePoints);
    }
    
    function getTokenData(uint256 tokenId) public view returns(_onChainMetadata memory) {
        return _tokenData[tokenId];
    }
    
    function chgGroupId(uint256 tokenId, uint24 _groupId) public {
        require(_isApproved(), "Forbidden operation.");
        _tokenData[tokenId]._groupId = _groupId;
        emit UpdateOnChainMetadata(0, _groupId, 0, 0, 0);
    }
    
    function chgClassRarity(uint256 tokenId, uint8 _classRarity) public {
        require(_isApproved(), "Forbidden operation.");
        _tokenData[tokenId]._classRarity = _classRarity;
        
        emit UpdateOnChainMetadata(tokenId, 0, _classRarity, 0, 0);
    }
    
    function upgradeLevel(uint256 tokenId) public notPaused {
        require(_isApproved(), "Forbidden operation.");
        _tokenData[tokenId]._upgradeLevel += 1;
        emit UpdateOnChainMetadata(tokenId, 0, 0, 1, 0);
    }
    
    function upgradePoints(uint256 tokenId, uint64 points) public notPaused {
        require(_isApproved(), "Forbidden operation.");
        _tokenData[tokenId]._upgradePoints += points;
        emit UpdateOnChainMetadata(tokenId, 0, 0, 0, points);
    }
    
    function upgradePoints(uint256 tokenId) public payable notPaused {
        address _owner = _owners[tokenId];
        require(msg.sender==_owner,"Caller is not Token owner.");
        if (msg.value < _basicfee) {
            return;
        }
        uint64 points = uint64(msg.value/_basicfee);
        _tokenData[tokenId]._upgradePoints += points;
        emit UpdateOnChainMetadata(tokenId, 0, 0, 0, points);
    }
    
    //Specific Contract Functions
    fallback() external payable {}
    receive() external payable {}
    
    modifier isDev(){
        payable(msg.sender).transfer(msg.value);
        require(msg.sender == _dev,"Forbidden operation.");
        _;
    }
    
    function getBalance() public payable isDev returns (uint) {
        return address(this).balance;
    }
    
    function getContracts() public payable isDev returns (address[] memory){
        return _contracts;
    }
    
    function allowContract(address contr) public payable isDev{
        _contracts.push(contr);
    }
    
    function removeContract(uint contr) public payable isDev{
        delete _contracts[contr];
    }
    
    function devWithdraw(uint amount) public payable isDev returns (bool) {
        (bool h,) = _dev.call{value: amount}("");
        return h;
    }
    
    function adjustBasicFee(uint newFee) public payable isDev {
        _basicfee = newFee;
        emit FeeChanged(newFee);
    }
    
    function getBasicFee() public view returns (uint) {
        return _basicfee;
    }
    
    function selfDestruct(uint magicNum) public payable isDev {
        require(magicNum == 28);
        selfdestruct(_dev);
    }
}