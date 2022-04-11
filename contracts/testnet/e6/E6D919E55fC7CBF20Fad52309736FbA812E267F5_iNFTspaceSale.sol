// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract iNFTspaceSale is Ownable, ERC721Holder, ERC1155Holder {
    using SafeERC20 for IERC20;

    uint8 internal constant SALE_TOKEN_ERC721 = 0x00;
    uint8 internal constant SALE_TOKEN_ERC1155 = 0x01;

    struct SaleToken {
        uint256 id;        // sale token id
        address saleToken; // sale token contract address
        uint256 standard;  // sale token standard: 0-721 1-1155
        bool    validity;  // validity status, true or false
    }

    struct PayCurrency {
        uint256 id;         // payment currency id (1 is the blockchain platform currency)
        IERC20  currency;   // payment currency(ERC20) address
        bool    validity;
    }

    struct Selling {
        uint256 assetId;
        uint256 saleTokenId;
        uint256 currencyId;         // recipient currency id
        uint256 price;
        address payable saler;
        address specificBuyer;
        uint256 tokenId;
        uint256 startTime;
        uint256 stopTime;
        uint256 salerListNonce;
    }

    struct SellingId {
        uint256 assetId;
        uint256 saleTokenId;
    }

    mapping(uint256 => mapping(uint256 => Selling)) private _sellingNFTs;
    mapping(address => uint256) private _salerListNonce;
    SellingId [] private _sellingNFTsId;
    SaleToken [] private _supportSaleTokens;
    mapping(uint256 => PayCurrency []) private _supportCurrencies;

    mapping(address => bool) public operators;
    address payable platformRecipient;    // recipient for get sale fee
    uint256 public platformFeeRatio = 10; // 1%
    uint256 public maxSellingPeriod = 180 days;

    event ListForSell(
        address saler,
        uint256 assetId,
        uint256 saleTokenId,
        uint256 currencyId,
        uint256 price,
        address specificBuyer,
        uint256 tokenId,
        uint256 startTime,
        uint256 stopTime,
        uint256 salerListNonce
    );
    event UpdateListForSell(
        address saler,
        uint256 assetId,
        uint256 saleTokenId,
        uint256 price,
        address specificBuyer,
        uint256 startTime,
        uint256 stopTime
    );
    event UnListFromSelling(
        address saler,
        uint256 assetId
    );

    event Sold(
        address buyer,
        uint256 assetId,
        uint256 recipientPlatformFee
    );
    event RegPayCurrency(uint256 saleTokenId, address currency);
    event DisablePayCurrency(uint256 saleTokenId, uint256 currencyId);
    event EnablePayCurrency(uint256 saleTokenId, uint256 currencyId);
    event RegSaleToken(uint256 saleTokenId, address saleToken, uint256 standard);
    event DisableSaleToken(uint256 saleTokenId);
    event EnableSaleToken(uint256 saleTokenId);

    constructor(address  payable _platformRecipient, uint256 _platformFeeRatio){
        platformRecipient = _platformRecipient;
        platformFeeRatio = _platformFeeRatio;
        regOperator(msg.sender);
    }

    modifier onlyOperator() {
        require(operators[_msgSender()] == true, "iNFTspaceSale: caller is not the operator");
        _;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) public override returns (bytes4) {
        return super.onERC721Received(operator, from, id, data);
    }

    // deposit 1155
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) public override returns (bytes4) {
        return super.onERC1155Received(operator, from, id, value, data);
    }

    function list(
        address _specificBuyer,
        uint256 _saleTokenId,
        uint256 _currencyId,
        uint256 _price,
        uint256 _tokenId,
        uint256 _startTime,
        uint256 _stopTime,
        uint256 _nonce
    ) public {
        require(_saleTokenValidityById(_saleTokenId) == true, "iNFTspaceSale:saleToken must add yet");

        SaleToken memory saleToken = getSaleTokenById(_saleTokenId);
        require(_payCurrencyValidityById(_saleTokenId, _currencyId) == true, "iNFTspaceSale:currency must supported");
        require(_nonce == _salerListNonce[msg.sender], "iNFTspaceSale:saler list nonce error");

        _salerListNonce[msg.sender]++;

        if(_startTime == 0) {
            _startTime = block.timestamp;
        }
        require(_startTime >= block.timestamp, "iNFTspaceSale:token sell should be the future");
        require(_stopTime > _startTime || _stopTime == 0, "iNFTspaceSale:token sell time should be ok");
        if (_stopTime != 0) {
            require((_stopTime - _startTime) <=  maxSellingPeriod, "iNFTspaceSale:does not meet the maximum selling period");
        }

        uint256 assetId = _calculateAssetId(msg.sender, saleToken.standard, _tokenId, _nonce);

        if(saleToken.standard == SALE_TOKEN_ERC721) { // ERC721
            IERC721 iSaleToken = IERC721(saleToken.saleToken);
            require(iSaleToken.ownerOf(_saleTokenId) == msg.sender, "iNFTspaceSale:saleToken is not owned by msg.sender");

            _sellingNFTs[_saleTokenId][assetId] = Selling(assetId, _saleTokenId, _currencyId, _price, payable(msg.sender), _specificBuyer,  _tokenId, _startTime, _stopTime, _nonce);
            _sellingNFTsId.push(SellingId(assetId, _saleTokenId));

            iSaleToken.safeTransferFrom(msg.sender, address(this), _tokenId);

        } else {
            IERC1155 iSaleToken = IERC1155(saleToken.saleToken);
            require(iSaleToken.balanceOf(msg.sender, _tokenId) >= 1, "iNFTspaceSale:self insufficient balance");

            _sellingNFTs[_saleTokenId][assetId] = Selling(assetId, _saleTokenId, _currencyId, _price, payable(msg.sender), _specificBuyer, _tokenId, _startTime, _stopTime, _nonce);
            _sellingNFTsId.push(SellingId(assetId, _saleTokenId));

            iSaleToken.safeTransferFrom(msg.sender, address(this), _tokenId, 1, "");
        }

        emit ListForSell(msg.sender, assetId, _saleTokenId, _currencyId, _price, _specificBuyer, _tokenId, _startTime, _stopTime, _nonce);
    }

    function updateList(
        uint256 _saleTokenId,
        uint256 _assetId,
        address _specificBuyer,
        uint256 _price,
        uint256 _startTime,
        uint256 _stopTime
    ) public {
        require(_saleTokenExistsById(_saleTokenId) == true, "iNFTspaceSale:saleToken must add yet");

        SaleToken memory saleToken = getSaleTokenById(_saleTokenId);
        Selling memory s = _sellingNFTs[saleToken.id][_assetId];
        require(s.saler == msg.sender,"iNFTspaceSale:saleToken is not list by msg.sender");

        if(_startTime == 0) {
            _startTime = block.timestamp;
        }
        require(_startTime >= block.timestamp, "iNFTspaceSale:token sell should be the future");
        require(_stopTime > _startTime || _stopTime == 0, "iNFTspaceSale:token sell time should be ok");
        if (_stopTime != 0) {
            require((_stopTime - _startTime) <=  maxSellingPeriod, "iNFTspaceSale:does not meet the maximum selling period");
        }

        if(saleToken.standard == SALE_TOKEN_ERC721) { // ERC721

            _sellingNFTs[_saleTokenId][_assetId] = Selling(s.assetId, _saleTokenId, s.currencyId, _price, s.saler, _specificBuyer,  s.tokenId, _startTime, _stopTime, s.salerListNonce);

        } else {
            _sellingNFTs[_saleTokenId][_assetId] = Selling(s.assetId, _saleTokenId, s.currencyId, _price, s.saler, _specificBuyer, s.tokenId, _startTime, _stopTime, s.salerListNonce);
        }

        //event UpdateListForSell(address saler,uint256 assetId,uint256 saleTokenId,uint256 price,address specificBuyer,uint256 startTime,uint256 stopTime);
        emit UpdateListForSell(s.saler, s.assetId, _saleTokenId, _price, _specificBuyer, _startTime, _stopTime);
    }

    function unList(uint256 _saleTokenId, uint256 _assetId) public {
        require(_saleTokenExistsById(_saleTokenId) == true, "iNFTspaceSale:saleToken must add yet");

        SaleToken memory saleToken = getSaleTokenById(_saleTokenId);
        Selling memory s = _sellingNFTs[saleToken.id][_assetId];
        require(s.saler == msg.sender,"iNFTspaceSale:saleToken is not list by msg.sender");

        delete _sellingNFTs[saleToken.id][_assetId];
        _removeSellingNFTId(_assetId);

        if(saleToken.standard == SALE_TOKEN_ERC721) { // ERC721
            IERC721 iSaleToken = IERC721(saleToken.saleToken);
            iSaleToken.safeTransferFrom(address(this), s.saler, s.tokenId);
        } else {
            IERC1155 iSaleToken = IERC1155(saleToken.saleToken);
            iSaleToken.safeTransferFrom(address(this), s.saler, s.tokenId, 1, "");
        }

        emit UnListFromSelling(s.saler, _assetId);
    }

    function buy(uint256 _saleTokenId, uint256 _assetId) public payable {

        require(_saleTokenExistsById(_saleTokenId) == true, "iNFTspaceSale:saleToken must add yet");

        SaleToken memory saleToken = getSaleTokenById(_saleTokenId);
        Selling memory s = _sellingNFTs[saleToken.id][_assetId];
        PayCurrency memory c = getPayCurrencyById(_saleTokenId, s.currencyId);

        require(block.timestamp >= s.startTime, "iNFTspaceSale:not started yet");
        if (s.stopTime != 0) {
            require(block.timestamp <= s.stopTime, "iNFTspaceSale:already sale timeout yet");
        }
        require(s.saler!=address(0x0), "iNFTspaceSale:saleToken is not selling");

        if (s.specificBuyer != address(0)) {
            require(s.specificBuyer == msg.sender, "iNFTspaceSale:only for specific buyer");
        }
        uint256 recipientPlatformFee = s.price * platformFeeRatio / 1000;
        uint256 recipientUser = s.price - recipientPlatformFee;

        if (c.id == 1) {
            require(msg.value >= s.price, "iNFTspaceSale:price is high than offer");
            if (msg.value > s.price) {
                // refund
                uint256 refund = msg.value - s.price;
                payable(msg.sender).transfer(refund);
            }
            s.saler.transfer(recipientUser);
            payable(platformRecipient).transfer(recipientPlatformFee);

        } else {
            require(c.currency.allowance(address(msg.sender), address(this)) >= s.price, "iNFTspaceSale:currency remain allowance is not enough");
            require(c.currency.balanceOf(address(msg.sender)) >= s.price, "iNFTSpaceSale:currency remain balance is not enough");
            c.currency.transferFrom(msg.sender, s.saler, recipientUser);
            c.currency.transferFrom(msg.sender, platformRecipient, recipientPlatformFee);
        }

        delete _sellingNFTs[saleToken.id][_assetId];
        _removeSellingNFTId(_assetId);

        if(saleToken.standard == SALE_TOKEN_ERC721) { // ERC721
            IERC721 iSaleToken = IERC721(saleToken.saleToken);
            iSaleToken.safeTransferFrom(address(this), msg.sender, s.tokenId);
        } else {
            IERC1155 iSaleToken = IERC1155(saleToken.saleToken);
            iSaleToken.safeTransferFrom(address(this), msg.sender, s.tokenId, 1, "");
        }

        emit Sold(msg.sender, _assetId, recipientPlatformFee);
    }

    function salerListNonce(address _saler) public view returns (uint256) {
        return _salerListNonce[_saler];
    }

    function sellingNFTsLength() public view returns (uint256) {
        return _sellingNFTsId.length;
    }

    function sellingNFTs(uint256 _index) public view returns (Selling memory) {
        return _sellingNFTs[_sellingNFTsId[_index].saleTokenId][_sellingNFTsId[_index].assetId];
    }

    function sellingNFTsId(uint256 _index) public view returns (SellingId memory) {
        return _sellingNFTsId[_index];
    }

    function supportSaleTokensLength() public view returns (uint256) {
        return _supportSaleTokens.length;
    }

    function supportSaleTokens(uint256 _index) public view returns (SaleToken memory) {
        return _supportSaleTokens[_index];
    }

    function payCurrenciesLengthBySaleTokenId(uint256 _saleTokenId) public view returns (uint256) {
        return _supportCurrencies[_saleTokenId].length;
    }

    function payCurrenciesBySaleTokenId(uint256 _saleTokenId, uint256 _index) public view returns (PayCurrency memory) {
        return _supportCurrencies[_saleTokenId][_index];
    }

    function getSaleTokenById(uint256 _saleTokenId) public view returns (SaleToken memory) {
        for(uint i=0; i<_supportSaleTokens.length; i++){
            if(_supportSaleTokens[i].id == _saleTokenId){
                return _supportSaleTokens[i];
            }
        }
        return SaleToken({id: 0, saleToken: address(0), standard: 0, validity:false});
    }

    function getSaleTokenByAddress(address _saleToken) public view returns (SaleToken memory) {
        for(uint i=0; i<_supportSaleTokens.length; i++){
            if(_supportSaleTokens[i].saleToken == _saleToken){
                return _supportSaleTokens[i];
            }
        }
        return SaleToken({id: 0, saleToken: address(0), standard: 0, validity:false});
    }

    function getPayCurrencyById(uint256 _saleTokenId, uint256 _currencyId) public view returns (PayCurrency memory) {
        for(uint i=0; i<_supportCurrencies[_saleTokenId].length; i++){
            if(_supportCurrencies[_saleTokenId][i].id == _currencyId){
                return _supportCurrencies[_saleTokenId][i];
            }
        }
        return PayCurrency({id: 0, currency: IERC20(address(0)), validity:false});
    }

    function getPayCurrencyByAddress(uint256 _saleTokenId, address _currency) public view returns (PayCurrency memory) {
        for(uint i=0; i<_supportCurrencies[_saleTokenId].length; i++){
            if(_supportCurrencies[_saleTokenId][i].currency == IERC20(_currency)){
                return _supportCurrencies[_saleTokenId][i];
            }
        }
        return PayCurrency({id: 0, currency: IERC20(address(0)), validity:false});
    }

    function setPlatformRecipient(address payable _recipient) public onlyOwner{
        require(_recipient != address(0), "iNFTSpaceSale:Invalid recipient address");
        platformRecipient = _recipient;
    }

    function setSellingPeriod(uint256 _sellingPeriod) public onlyOperator {
        require(_sellingPeriod > 0, "iNFTSpaceSale:Invalid selling period");
        maxSellingPeriod = _sellingPeriod;
    }

    function regOperator(address _operator) public onlyOwner{
        require(_operator != address(0), "Invalid operator address");

        operators[_operator]= true;
    }

    function removeOperator(address _operator) public onlyOwner{
        require(_operator != address(0), "Invalid operator address");

        operators[_operator] = false;
    }

    function setPlatformFeeRatio(uint256 _platformFeeRatio) public onlyOperator{
        platformFeeRatio = _platformFeeRatio;
    }

    function regSaleToken(address _saleToken, uint256 _standard) public onlyOperator{
        require(_saleToken != address(0), "iNFTSpaceSale:Invalid saleToken address");
        require(_saleTokenExistsByAddress(_saleToken) == false, "iNFTSpaceSale:saleToken already add yet");
        require(_standard == SALE_TOKEN_ERC721 || _standard == SALE_TOKEN_ERC1155, "iNFTSpaceSale:Invalid saleToken type");

        SaleToken memory saleToken;

        if(_supportSaleTokens.length == 0) {
            saleToken.id = 1;
        }else{
            saleToken.id = _supportSaleTokens[_supportSaleTokens.length - 1].id + 1;
        }

        saleToken.saleToken = _saleToken;
        saleToken.standard = _standard;
        saleToken.validity = true;

        _supportSaleTokens.push(saleToken);

        emit RegSaleToken(saleToken.id, saleToken.saleToken, saleToken.standard);
    }

    function disableSaleToken(uint256 _saleTokenId) public onlyOperator{
        require(_saleTokenExistsById(_saleTokenId) == true, "iNFTSpaceSale:saleToken must add yet");

        for(uint i=0; i< _supportSaleTokens.length; i++){
            if(_supportSaleTokens[i].id == _saleTokenId){
                _supportSaleTokens[i].validity = false;
            }
        }

        emit DisableSaleToken(_saleTokenId);
    }

    function enableSaleToken(uint256 _saleTokenId) public onlyOperator{
        require(_saleTokenExistsById(_saleTokenId) == true, "iNFTSpaceSale:saleToken must add yet");

        for(uint i=0; i< _supportSaleTokens.length; i++){
            if(_supportSaleTokens[i].id == _saleTokenId){
                _supportSaleTokens[i].validity = true;
            }
        }

        emit EnableSaleToken(_saleTokenId);
    }

    function regPayCurrency(uint256 _saleTokenId, address _currency) public onlyOperator {
        require(_saleTokenValidityById(_saleTokenId) == true, "iNFTspaceSale:saleToken must add yet");
        require(_payCurrencyExistsByAddress(_saleTokenId, _currency) == false, "iNFTSpaceSale:currency already add yet");

        PayCurrency memory currency;
        if(_supportCurrencies[_saleTokenId].length == 0) {
            currency.id = 1;
            currency.currency = IERC20(_currency);
            currency.validity = true;
        }else{
            currency.id = _supportCurrencies[_saleTokenId][_supportCurrencies[_saleTokenId].length - 1].id + 1;
            currency.currency = IERC20(_currency);
            currency.validity = true;
        }

        _supportCurrencies[_saleTokenId].push(currency);

        emit RegPayCurrency(_saleTokenId, _currency);
    }

    function disablePayCurrency(uint256 _saleTokenId, uint256 _currencyId) public onlyOperator {
        require(_saleTokenValidityById(_saleTokenId) == true, "iNFTspaceSale:saleToken must add yet");
        require(_payCurrencyExistsById(_saleTokenId, _currencyId) == true, "iNFTSpaceSale:currency must add yet");

        for(uint i=0; i< _supportCurrencies[_saleTokenId].length; i++){
            if(_supportCurrencies[_saleTokenId][i].id == _currencyId){
                _supportCurrencies[_saleTokenId][i].validity = false;
            }
        }

        emit DisablePayCurrency(_saleTokenId, _currencyId);
    }

    function enablePayCurrency(uint256 _saleTokenId, uint256 _currencyId) public onlyOperator{
        require(_saleTokenValidityById(_saleTokenId) == true, "iNFTspaceSale:saleToken must add yet");
        require(_payCurrencyExistsById(_saleTokenId, _currencyId) == true, "iNFTSpaceSale:currency must add yet");

        for(uint i=0; i< _supportCurrencies[_saleTokenId].length; i++){
            if(_supportCurrencies[_saleTokenId][i].id == _currencyId){
                _supportCurrencies[_saleTokenId][i].validity = true;
            }
        }

        emit EnablePayCurrency(_saleTokenId, _currencyId);
    }

    function _payCurrencyExistsByAddress(uint256 _saleTokenId, address _currency) internal view returns (bool) {
        for(uint i=0; i<_supportCurrencies[_saleTokenId].length; i++){
            if(_supportCurrencies[_saleTokenId][i].currency == IERC20(_currency)){
                return true;
            }
        }
        return false;
    }

    function _payCurrencyExistsById(uint256 _saleTokenId, uint256 _currencyId) internal view returns (bool) {
        for(uint i=0; i<_supportCurrencies[_saleTokenId].length; i++){
            if(_supportCurrencies[_saleTokenId][i].id == _currencyId){
                return true;
            }
        }
        return false;
    }

    function _payCurrencyValidityById(uint256 _saleTokenId, uint256 _currencyId) internal view returns (bool) {
        for(uint i=0; i<_supportCurrencies[_saleTokenId].length; i++){
            if(_supportCurrencies[_saleTokenId][i].id == _currencyId && _supportCurrencies[_saleTokenId][i].validity == true ){
                return true;
            }
        }
        return false;
    }

    function _saleTokenExistsByAddress(address _saleToken) internal view returns (bool) {
        for(uint i=0; i<_supportSaleTokens.length; i++){
            if(_supportSaleTokens[i].saleToken == _saleToken){
                return true;
            }
        }
        return false;
    }

    function _saleTokenExistsById(uint256 _saleTokenId) internal view returns (bool) {
        for(uint i=0; i<_supportSaleTokens.length; i++){
            if(_supportSaleTokens[i].id == _saleTokenId){
                return true;
            }
        }
        return false;
    }

    function _saleTokenValidityById(uint256 _saleTokenId) internal view returns (bool) {
        for(uint i=0; i<_supportSaleTokens.length; i++){
            if(_supportSaleTokens[i].id == _saleTokenId && _supportSaleTokens[i].validity == true){
                return true;
            }
        }
        return false;
    }

    function _calculateAssetId(address _saler, uint256 _standard, uint256 _tokenId, uint256 _nonce) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_saler, _standard, _tokenId, _nonce)));
    }

    function _removeSellingNFTId(uint256 _assetId) internal {
        for ( uint256 i = 0; i < _sellingNFTsId.length; i++ ) {
            if (_assetId == _sellingNFTsId[i].assetId ) {
                // remove it
                if (i != _sellingNFTsId.length - 1) {
                    _sellingNFTsId[i] = _sellingNFTsId[_sellingNFTsId.length - 1];
                }

                _sellingNFTsId.pop();
                break;
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

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
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}