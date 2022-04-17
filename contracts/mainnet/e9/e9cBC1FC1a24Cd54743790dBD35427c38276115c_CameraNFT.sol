// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./token-ERC721-ERC721.sol";
import "./access-Ownable.sol";
import "./token-ERC721-extensions-ERC721Burnable.sol";
import "./token-ERC721-extensions-ERC721Enumerable.sol";
import "./CameraNFTData.sol";

contract CameraNFT is ERC721, Ownable, ERC721Burnable, ERC721Enumerable, CameraNFTData {
	uint256 public tradeLockTime = 5 * 60;
	address private marketer;
	address private operator;
	bool private isEnableTrade = true;
	uint256 newestTokenID = 0;
	
	// Mapping from token ID to banstatus
	mapping(uint256 => uint256) private _bans;
	mapping(address => uint256) private _ownerbans;
	mapping(uint256 => uint256) private _allowTradingTime;
	mapping(address => bool) private _notAllowForTrading;
	mapping(uint256 => mapping(uint256 => uint256)) public totalNftByRare;
	mapping(uint256 => bool) public isRented;
	mapping(uint256 => uint256) public ContractTime;

	modifier isMarketer() {
		require(msg.sender == marketer, "NFT: Denied");
		_;
	}
	
	modifier isOperator() {
		require(msg.sender == operator, "NFT: Denied");
		_;
	}
	
	modifier isAllowCall() {
		require(
			msg.sender == operator||
			msg.sender == marketer
			, "NFT: Denied"
		);
		_;
	}
	
	//constructor() ERC721("DBS Collectibles", "DBSC") {
	constructor() ERC721("Camera NFT", "CAMERANFT") {
		marketer = msg.sender;
		operator = msg.sender;
	}
	
	function _beforeTokenTransfer(address from, address to, uint256 tokenId)
		internal
		override(ERC721, ERC721Enumerable)
	{
		require(!isRented[tokenId], "NFT: Rented");
		require(isEnableTrade, "NFT: disable");
		require(_bans[tokenId] < block.timestamp, "NFT: baned");
		require(_ownerbans[from] < block.timestamp, "NFT: baned");
		require(_allowTradingTime[tokenId] < block.timestamp, "NFT: not time");
		require(from == address(0) || !_notAllowForTrading[from] || !_notAllowForTrading[to], "NFT: Not allow");

		super._beforeTokenTransfer(from, to, tokenId);
		_allowTradingTime[tokenId] = block.timestamp + tradeLockTime;
	}

	function supportsInterface(bytes4 interfaceId)
		public
		view
		override(ERC721, ERC721Enumerable)
		returns (bool)
	{
		return super.supportsInterface(interfaceId);
	}
	
	function evolve( address _to, uint256[] memory _values) external isAllowCall returns( uint256 ){
		require(_values.length == 6,'NFT: INVALID');
		newestTokenID ++;
		_allowTradingTime[newestTokenID] = block.timestamp - 3600;
		super._safeMint(_to, newestTokenID);
		totalNftByRare[_values[0]][_values[1]] = totalNftByRare[_values[0]][_values[1]] + 1;
		_initAllAttribute(newestTokenID, _values);
		return newestTokenID;
	}
	/**
	 * @dev config.
	 */
	function updateMarketer(address _marketer) external onlyOwner{
		marketer = _marketer;
	}

	function updateOperator(address newOperator) external onlyOwner{
		operator = newOperator;
	}

	function enableTrade() external onlyOwner{
		isEnableTrade = true;
	}

	function disableTrade() external onlyOwner{
		isEnableTrade = false;
	}

	function updateTimeLockAfterTrade(uint256 _tradeLockTime) external onlyOwner{
		tradeLockTime = _tradeLockTime;
	}

	function updateBaseURI(string memory newBaseURI) external onlyOwner{
        super.setbaseURI(newBaseURI);
    }
	
	/**
	 * Ban case.
	 */
	function banOwner(address _owner, uint256 _days) external isOperator{
		_ownerbans[_owner] = block.timestamp + _days * 86400;
	}

	function unbanOwner(address _owner) external isOperator{
		_ownerbans[_owner] = block.timestamp - 60;
	}
	
	function banNFT(uint256 _tokenId, uint256 _days) external isOperator{
		_bans[_tokenId] = block.timestamp + _days * 86400;
	}

	function unbanNFT(uint256 _tokenId) external isOperator{
		_bans[_tokenId] = block.timestamp - 60;
	}

	function getOnwerBannedStatus(address _owner) external view returns (bool, uint256) {
		if(_ownerbans[_owner] > block.timestamp){
			return (true, _ownerbans[_owner]);
		}else{
			return (false, 0);
		}
	}

	function getNFTBannedStatus(uint256 _tokenId) external view returns (bool, uint256) {
		if(_bans[_tokenId] > block.timestamp){
			return (true, _bans[_tokenId]);
		}else{
			return (false, 0);
		}
	}

	/**
	 * Trade case.
	 */

	function getTimeTradable(uint256 _tokenId) external view returns (uint256) {
		return _allowTradingTime[_tokenId];
	}
	
	function updateTimeTradable(uint256 _tokenId, uint256 _tradableTime) external isAllowCall{
		_allowTradingTime[_tokenId] = _tradableTime;
	}
	
	function includeAllowForTrading(address account) public isAllowCall {
		_notAllowForTrading[account] = false;
	}
	
	function excludeAllowForTrading(address account) public isAllowCall {
		_notAllowForTrading[account] = true;
	}

	function getAllowForTradingStatus(address account) public view returns(bool) {
		return !_notAllowForTrading[account];
	}

	/**
	 * Info case.
	 */
	function initAllAttribute(uint256 _tokenId, uint256[] memory _values) external isAllowCall{
		require(_values.length == 6,'itemdata: INVALID_VALUES');
		_initAllAttribute(_tokenId, _values);
	}

	function updateAllAttribute(uint256 _tokenId, uint256[] memory _values) external isAllowCall{
		require(_values.length == 6,'itemdata: INVALID_VALUES');
		_updateAllAttribute(_tokenId, _values);
	}

	function updateRareAndFactor(uint256 _tokenId, uint256 _rare, uint256 _factor) external isAllowCall{
		_updateRare(_tokenId, _rare);
		_updateFactor(_tokenId, _factor);
	}

	function updateIsOpen(uint256 _tokenId, bool _isOpen) external isAllowCall{
		_updateIsOpen(_tokenId, _isOpen);
	}
	
	function getTokenInfo(uint256 _tokenId) public view returns (uint256 factor, uint256 rare, uint256 pixel, uint256 level, uint256 energy, uint256 rank, bool isOpen){
		return _getTokenInfo(_tokenId);
	}

	function tokenURI(uint256 _tokenId) public view override(ERC721) returns (string memory){
		return super.tokenURI(_tokenId);
	}
}