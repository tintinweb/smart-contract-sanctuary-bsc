/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function transferERC20Token(address tokenAddress, uint _value) public virtual onlyOwner returns (bool) {
        return IERC20TokenInterface(tokenAddress).transfer(_owner, _value);
    }
}


interface IERC20TokenInterface {
    function totalSupply()  view external returns(uint256)  ;
    function balanceOf(address _owner) view external returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value)external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

interface IERC721TokenInterface{
    event Transfer(address indexed from,address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner,address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner,address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from,address to, uint256 tokenId ) external;
    function transferFrom(address from,address to,uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId)external  view  returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator)  external  view  returns (bool);
}

interface IERC721TokenFactoryInterface{
    function mint(address _owner,uint256 tokenId) external ;
    function burn(uint256 tokenId) external;
}

interface INFTGame {
    function makeSpaceStation(uint256 _stationId ,uint256 _price,uint256  _orderId) payable external returns(bool);
    function conquerPlanet(uint256[] memory  _stationIds ,uint256 _planetId,uint256 _conquerRecordId) external returns(bool);
    function conquerHistory(uint256 _conquerRecordId) external view returns (uint256 planetId, uint256 []  memory  stationIds);
    function ctoBuyProp(uint256 _price,uint256 orderId) external returns(bool);
    function sxcBuyProp(uint256 _price,uint256 orderId) external returns(bool);
}

contract  WhitelistManager{
    mapping (address =>bool) private whitelist;
    mapping (address =>bool) private lucklist;
    mapping (address =>uint256) private luckOrderCounts;
    uint256 private  maxLuckCount;
    uint256 private  currentLuckCount;
    uint256 private  maxLuckOrderCount;

    function _setMaxLuckCount(uint256 _maxLuckCount) internal{
        maxLuckCount=_maxLuckCount;
    }

    function _setmaxLuckOrderCount(uint256 _maxLuckOrderCount) internal{
        maxLuckOrderCount=_maxLuckOrderCount;
    }

    function _setWhitelists(address  []  memory addresses,bool enable) internal{
        require(addresses.length >0,"WhitelistManager: addresses can not empty.");
        for(uint32 i=0;i<addresses.length;i++){
            whitelist[addresses[i]]=enable;
        }
    }

    function isWhitelist(address owner) view public returns(bool enable) {
        return whitelist[owner];
    }

    function _addLuck(address  owner) internal {
        require(isWhitelist(owner),"WhitelistManager: Not on the white list");
        require(currentLuckCount<maxLuckCount,"WhitelistManager: come late!");
        lucklist[owner]=true;
        currentLuckCount+=1;
    }

    function _addLuckOrder(address  owner) internal{
        require(luckOrderCounts[owner]<maxLuckOrderCount,"WhitelistManager: Not on the white list");
        luckOrderCounts[owner]+=1;
    }

    function isLucklist(address owner) view public returns(bool enable) {
        return lucklist[owner];
    }

    function remainLuckCount() view public returns(uint256 count){
        return maxLuckCount -  currentLuckCount;
    }

    function getMaxLuckCount() view public returns(uint256 count){
        return maxLuckCount;
    }

    function getMaxLuckOrderCount() view public returns(uint256 count){
        return maxLuckOrderCount;
    }

    function getCurrentLuckCount() view public returns(uint256 count){
        return currentLuckCount;
    }

    function getLuckOrderCount(address owner) view  public returns(uint256 count){
        return luckOrderCounts[owner];
    }

}

contract Payment {
    address private _CTOTokenAddress;
    address private _SXCTokenAddress;
    address private _SXCTokenPoolAddress;
    address private _bnbPoolAddress;
    mapping (uint256 => uint256) private ctoOrderHistories;
    mapping (uint256 => uint256) private sxcOrderHistories;
    mapping (uint256 => uint256) private bnbOrderHistories;

    function getCTOTokenOrder(uint256 orderId) external  view returns (uint256){
        return ctoOrderHistories[orderId];
    }

    function getSXCTokenOrder(uint256 orderId) external  view returns (uint256){
        return sxcOrderHistories[orderId];
    }

    function getBNBOrder(uint256 orderId) external  view returns (uint256){
        return bnbOrderHistories[orderId];
    }

    function _setCTOTokenAddress(address tokenAddress)internal{
        _CTOTokenAddress = tokenAddress;
    }

    function _setSXCTokenAddress(address tokenAddress)internal{
        _SXCTokenAddress = tokenAddress;
    }

    function _setSXCTokenPoolAddress(address tokenPoolAddress)internal{
        _SXCTokenPoolAddress = tokenPoolAddress;
    }

    function _setBnbPoolAddress(address bnbPoolAddress)internal{
        _bnbPoolAddress = bnbPoolAddress;
    }

    function _CTOTokenPayment(uint256 orderId,address _from,uint _value) internal returns (bool){
        bool transferResult = IERC20TokenInterface(_CTOTokenAddress).transferFrom(_from,address(0), _value);
        assert(transferResult);
        ctoOrderHistories[orderId]=_value;
        return true;
    }


    function _SXCTokenPayment(uint256 orderId,address _from,uint _value) internal returns (bool){
        bool transferResult = IERC20TokenInterface(_SXCTokenAddress).transferFrom(_from,_SXCTokenPoolAddress, _value);
        assert(transferResult);
        sxcOrderHistories[orderId]=_value;
        return true;
    }

    function _bnbPayment(uint256 orderId,uint256 _price) internal returns (bool){
        require(msg.value >=_price,"Payment:  Full payment is required");
        bnbOrderHistories[orderId]=msg.value ;
        payable(_bnbPoolAddress).transfer(msg.value);
    return true;
    }

}

contract  NFTGame is INFTGame,Payment,WhitelistManager,Ownable{
    struct ConquerLog{
        uint256 planetId;
        uint256 [] stationIds;
        bool status;
    }


    address private _stationNFTAddress;
    address private _planetNFTAddress;
    mapping (uint256 => ConquerLog) private conquerHistories;

    function makeSpaceStation(uint256 _stationId ,uint256 _price,uint256 orderId) payable external override  returns(bool){
        if(!isLucklist(_msgSender())){
            _addLuck(_msgSender());
        }
        _addLuckOrder(_msgSender());
        require(_bnbPayment(orderId,_price),"NFTController: pay failed!");
        IERC721TokenFactoryInterface(_stationNFTAddress).mint(_msgSender(),_stationId);
        return true;
    }

    function ctoBuyProp(uint256 _price,uint256 orderId) external override returns(bool){
        require(_CTOTokenPayment(orderId,_msgSender(),_price),"NFTController: pay failed!");
        return true;
    }

    function sxcBuyProp(uint256 _price,uint256 orderId) external override returns(bool){
        require(_CTOTokenPayment(orderId,_msgSender(),_price),"NFTController: pay failed!");
        return true;
    }

    function conquerPlanet(uint256[] memory  _stationIds ,uint256 _planetId,uint256  _conquerRecordId) external override returns(bool){
        require(_stationIds.length >0,"NFTController: _stationIds can not empty.");
        for(uint i=0;i<_stationIds.length;i++){
            require(IERC721TokenInterface(_stationNFTAddress).ownerOf(_stationIds[i])==_msgSender(),"NFTController: invalid station owner");
            IERC721TokenFactoryInterface(_stationNFTAddress).burn(_stationIds[i]);
        }
        IERC721TokenFactoryInterface(_planetNFTAddress).mint(_msgSender(),_planetId);
        conquerHistories[_conquerRecordId]=ConquerLog({
            planetId:_planetId,
            stationIds:_stationIds,
            status:true
            });
        return true;
    }

    function conquerHistory(uint256  _conquerRecordId) external override view returns (uint256 planetId, uint256 []  memory  stationIds){
        ConquerLog memory log = conquerHistories[_conquerRecordId];
        if(log.status){
            return (log.planetId,log.stationIds);
        }
        uint256 []  memory   emptyArr;
        return (0,emptyArr);
    }

    function setWhitelists(address  []  memory addresses,bool enable)  onlyOwner external{
        _setWhitelists(addresses,enable);
    }

    function setMaxLuckCount(uint256 _maxLuckCount)  onlyOwner external{
        _setMaxLuckCount(_maxLuckCount);
    }

    function setmaxLuckOrderCount(uint256 _maxLuckOrderCount)  onlyOwner external{
        _setmaxLuckOrderCount(_maxLuckOrderCount);
    }

    constructor(address stationNFTAddress_ ,address planetNFTAddress_,address ctoTokenAddress_,address sxcTokenAddress_,address sxcTokenPoolAddress_,address bnbPoolAddress_,uint256 maxLuckCount_,uint256 maxLuckOrderCount_)  {
        super._setCTOTokenAddress(ctoTokenAddress_);
        super._setSXCTokenAddress(sxcTokenAddress_);
        super._setSXCTokenPoolAddress(sxcTokenPoolAddress_);
        super._setBnbPoolAddress(bnbPoolAddress_);
        _stationNFTAddress = stationNFTAddress_;
        _planetNFTAddress = planetNFTAddress_;
        _setMaxLuckCount(maxLuckCount_);
        _setmaxLuckOrderCount(maxLuckOrderCount_);
    }
}