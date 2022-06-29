/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Sign {

    uint256 private  expireTime;
    address private  signAddress;
    bool private signEnable;
    
    function getExpireTime() public view returns(uint256){
        return expireTime;
    }

    function getSignAddress() public view returns(address){
        return signAddress;
    }

    function getSignEnable() public view returns(bool){
        return signEnable;
    }

    function _setExpireTime(uint256 _expireTime) internal {
        expireTime = _expireTime;
    }

    function _setSignAddress(address _signAddress) internal {
        signAddress = _signAddress;
    }

    function _setSignEnable(bool _signEnable) internal {
        signEnable = _signEnable;
    }
    
    function _genMsg (uint256[] memory list,address _address) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked( list, _address));
    }

    function _check(uint256[] memory list,address _address,uint256 nonce,bytes memory sig) internal view returns (bool) {
        if(!signEnable){
            return true;
        }
        require(signAddress == _recoverSigner(_genMsg(list,_address),sig),"Sign: sign invalid");
        uint256 _now =  block.timestamp;
        uint256 diff;
        if(_now >=nonce){
            diff = _now - nonce;
        }else{
            diff = nonce - _now;
        }
        require(diff<= expireTime ,"Sign: nonce invalid");
        return true;
    }

    function _splitSignature(bytes memory sig)   internal pure  returns ( uint8, bytes32, bytes32){
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function _recoverSigner(bytes32 message, bytes memory sig) internal  pure   returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = _splitSignature(sig);

        return ecrecover(message, v, r, s);
    }
}


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

}

interface IERC721TokenInterface{
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

interface INFTGamePatchOne {
    function append(uint256  _orderId, uint256 _planetId,uint256 []  memory _stationIds ,string memory _remark,uint256 _nonce,bytes memory _sign)  external returns(bool);
    function getAppendOrder(uint256 _orderId) view external returns (address owner,uint256 planetId, uint256 []  memory  stationIds,uint256 time,string memory remark);
    event Append(uint256 indexed orderId,address owner ,uint256 planetId,uint256[]   stationIds,string remark);
}

contract Domains{
    struct AppendOrder{
        address owner;
        uint256 planetId;
        uint256 [] stationIds;
        uint256 time;
        string remark;
        bool succeed;
    }
}

contract  NFTGamePatchOne is INFTGamePatchOne,Domains,Ownable,Sign{

    address private _stationNFTAddress;
    address private _planetNFTAddress;
    mapping (uint256 => AppendOrder) private appendOrders;

    function append(uint256  _orderId, uint256 _planetId,uint256 []  memory _stationIds ,string memory _remark,uint256 _nonce,bytes memory _sign) external override returns(bool){
        require(_stationIds.length >0,"NFTGame: _stationIds can not empty.");
        uint256 [] memory _list = new uint256[](3+_stationIds.length );
        _list[0]=_orderId;
        _list[1]=_planetId;
        for(uint256 i = 0;i<_stationIds.length;i++){
            _list[i+2]=_stationIds[i];
        }
        _list[_list.length - 1] = _nonce;
        _check(_list,_msgSender(),_nonce,_sign);
        require(!appendOrders[_orderId].succeed,"NFTGame: Order already exists");
        require(IERC721TokenInterface(_planetNFTAddress).ownerOf(_planetId)==_msgSender(),"NFTGame: invalid planet owner");
        for(uint i=0;i<_stationIds.length;i++){
            require(IERC721TokenInterface(_stationNFTAddress).ownerOf(_stationIds[i])==_msgSender(),"NFTGame: invalid station owner");
            IERC721TokenFactoryInterface(_stationNFTAddress).burn(_stationIds[i]);
        }
        appendOrders[_orderId]=AppendOrder({
            owner:_msgSender(),
            planetId:_planetId,
            stationIds:_stationIds,
            time:block.timestamp,
            remark:_remark,
            succeed:true
            });
        emit Append(_orderId,_msgSender(),_planetId,_stationIds,_remark); 
        return true;
    }


    function getAppendOrder(uint256 _orderId)view  override external returns (address owner,uint256 planetId, uint256 []  memory  stationIds,uint256 time,string memory remark){
        AppendOrder memory order = appendOrders[_orderId];
        if(order.succeed){
            return (order.owner,order.planetId,order.stationIds,order.time,order.remark);
        }
    }

    function setExpireTime(uint256 _expireTime) public onlyOwner {
        _setExpireTime(_expireTime);
    }

    function setSignAddress(address _signAddress) public onlyOwner{
       _setSignAddress(_signAddress);
    }

    function setSignEnable(bool _signEnable) public onlyOwner{
       _setSignEnable(_signEnable);
    }

    constructor(address planetNFTAddress_,address stationNFTAddress_ ,bool signEnable_,address signAddress_,uint256 expireTime_)  {
        _stationNFTAddress = stationNFTAddress_;
        _planetNFTAddress = planetNFTAddress_;
        _setSignEnable(signEnable_);
        _setSignAddress(signAddress_);
        _setExpireTime(expireTime_);
    }
}