/**
 *Submitted for verification at BscScan.com on 2022-05-19
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


interface ISquadxWallet {
    function getCTOTokenAddress()external view returns (address);
    function getCTOTokenPoolAddress()external view returns (address);
    function getSXCTokenAddress()external view returns (address);
    function getSXCTokenPoolAddress()external view returns (address);
    function getBNBPoolAddress()external view returns (address);
    function setCTOTokenPoolAddress(address _ctoTokenPoolAddress) external ;
    function setCTOTokenAddress(address _ctoTokenAddress) external ;
    function setSXCTokenAddress(address _sxcTokenAddress) external ;
    function setCTOTokenPoolAddressToBlackHole() external ;
    function setSXCTokenPoolAddress(address _sxcTokenPoolAddress) external ;
    function setBNBPoolAddress(address _bnbTokenPoolAddress) external ;

    function ctoPay(uint256 _orderId,uint256 _price ,string memory _remark,uint256 _nonce,bytes memory _sign) external returns(bool);
    function sxcPay(uint256 _orderId,uint256 _price ,string memory _remark,uint256 _nonce,bytes memory _sign) external returns(bool);
    function bnbPay(uint256 _orderId,uint256 _price ,string memory _remark,uint256 _nonce,bytes memory _sign) payable external returns(bool);
    
    function getCTOPayOrder(uint256 _orderId) external view returns (address payer,uint256 amount,uint256 time,string memory remark);
    function getSXCPayOrder(uint256 _orderId) external view returns (address payer,uint256 amount,uint256 time,string memory remark);
    function getBNBPayOrder(uint256 _orderId) external view returns (address payer,uint256 amount,uint256 time,string memory remark);

    function ctoWithdraw(uint256 _orderId, address [] memory _users, uint256 [] memory _amounts ,string memory _remark) external returns(bool);
    function sxcWithdraw(uint256 _orderId,address [] memory _users, uint256 [] memory _amounts ,string memory _remark) external returns(bool);
    function bnbWithdraw(uint256 _orderId,address [] memory _users, uint256 [] memory _amounts ,string memory _remark) external returns(bool);

    function getCTOWithDrawOrder(uint256 _orderId) external view returns (uint256 time,address [] memory users, uint256 [] memory amounts,string memory remark);
    function getSXCWithDrawOrder(uint256 _orderId) external view returns (uint256 time,address [] memory users, uint256 [] memory amounts,string memory remark);
    function getBNBWithDrawOrder(uint256 _orderId) external view returns (uint256 time,address [] memory users, uint256 [] memory amounts,string memory remark);

    event CTOPay(uint256 indexed orderId,address buyer,uint256 price,string  remark) ;
    event SXCPay(uint256 indexed orderId,address buyer,uint256 price,string  remark) ;
    event BNBPay(uint256 indexed orderId,address buyer,uint256 price,string  remark) ;

    event CTOWithdraw(uint256 indexed orderId, address []  users, uint256 []  amounts ,string  remark) ;
    event SXCWithdraw(uint256 indexed orderId,address []  users, uint256 []  amounts ,string  remark) ;
    event BNBWithdraw(uint256 indexed orderId,address []  users, uint256 []  amounts ,string  remark) ;
    event SetCTOTokenAddress(address ctoTokenAddress);
    event SetSXCTokenAddress(address sxcTokenAddress);
}


contract SquadxWallet is ISquadxWallet,Sign, Ownable{

    struct PayOrder{
        address buyer;
        uint256 amount;
        uint256 time;
        string remark;
        bool succeed;
    }

    struct WithdrawItem{
        address user;
        uint256 amount;
    }

    struct WithdrawOrder{
        WithdrawItem []  items;
        uint256 time;
        string remark;
        bool succeed;
    }

    address private _CTOTokenAddress;
    address private _CTOTokenPoolAddress;
    address private _SXCTokenAddress;
    address private _SXCTokenPoolAddress;

    address private _BNBPoolAddress;
    mapping (uint256 => PayOrder) private ctoPayOrders;
    mapping (uint256 => PayOrder) private sxcPayOrders;
    mapping (uint256 => PayOrder) private bnbPayOrders;

    mapping (uint256 => WithdrawOrder) private ctoWithdrawOrders;
    mapping (uint256 => WithdrawOrder) private sxcWithdrawOrders;
    mapping (uint256 => WithdrawOrder) private bnbWithdrawOrders;

    function getCTOTokenAddress()external override view returns (address){
        return _CTOTokenAddress;
    }

    function getCTOTokenPoolAddress()external override view returns (address){
        return _CTOTokenPoolAddress;
    }

    function getSXCTokenAddress()external override view returns (address){
        return _SXCTokenAddress;
    }

    function getSXCTokenPoolAddress()external override view returns (address){
        return _SXCTokenPoolAddress;
    }

    function getBNBPoolAddress()external override view returns (address){
        return _BNBPoolAddress;
    }

    function setCTOTokenPoolAddressToBlackHole() external override onlyOwner {
         _CTOTokenPoolAddress=address(0);
    }

    function setCTOTokenAddress(address _address) external override onlyOwner {
         _CTOTokenAddress=_address;
         emit SetCTOTokenAddress(_address);
    }

    function setSXCTokenAddress(address _address) external override onlyOwner {
         _SXCTokenAddress=_address;
         emit SetSXCTokenAddress(_address);
    }

    function setCTOTokenPoolAddress(address CTOTokenPoolAddress_)external override onlyOwner {
        _CTOTokenPoolAddress=CTOTokenPoolAddress_;
    }

    function setSXCTokenPoolAddress(address SXCTokenPoolAddress_)external override onlyOwner  {
        _SXCTokenPoolAddress=SXCTokenPoolAddress_;
    }

    function setBNBPoolAddress(address BNBPoolAddress_)external override  onlyOwner {
        _BNBPoolAddress=BNBPoolAddress_;
    }

    function ctoPay(uint256 _orderId,uint256 _price ,string memory _remark,uint256 _nonce,bytes memory _sign) override external returns (bool){
        uint256 [] memory _list = new uint256[](3);
        _list[0]=_orderId;
        _list[1]=_price;
        _list[2]=_nonce;        
        _check(_list,_msgSender(),_nonce,_sign);
        require(!ctoPayOrders[_orderId].succeed,"SquadxWallet : Order already exists");
        ctoPayOrders[_orderId]=_ERC20Pay(_CTOTokenAddress,_CTOTokenPoolAddress,_msgSender(),_price,_remark);
        emit CTOPay(_orderId,_msgSender(),_price,_remark);
        return true;
    }

    function sxcPay(uint256 _orderId,uint256 _price ,string memory _remark,uint256 _nonce,bytes memory _sign) override external  returns (bool){
        uint256 [] memory _list = new uint256[](3);
        _list[0]=_orderId;
        _list[1]=_price;
        _list[2]=_nonce;        
        _check(_list,_msgSender(),_nonce,_sign);
        require(!sxcPayOrders[_orderId].succeed,"SquadxWallet : Order already exists");
        sxcPayOrders[_orderId]=_ERC20Pay(_SXCTokenAddress,_SXCTokenPoolAddress,_msgSender(),_price,_remark);
        emit SXCPay(_orderId,_msgSender(),_price,_remark);
        return true;
    }

    function _ERC20Pay(address _tokenAddress,address _tokenPoolAddress,address _buyer,uint256 _price ,string memory _remark)internal returns (PayOrder memory order){
       assert(IERC20TokenInterface(_tokenAddress).transferFrom(_buyer,_tokenPoolAddress, _price));
       order = _buildPayOrder(_buyer,_price,_remark);
    }

    function _buildPayOrder(address _buyer, uint256 _amount ,string memory _remark) view internal returns (PayOrder memory order){ 
        order = PayOrder({
            buyer:_buyer,
            amount:_amount,
            time:block.timestamp,
            remark:_remark,
            succeed:true
        });
    }

    function bnbPay(uint256 _orderId,uint256 _price ,string memory _remark,uint256 _nonce,bytes memory _sign) payable  override external  returns (bool){
        uint256 [] memory _list = new uint256[](3);
        _list[0]=_orderId;
        _list[1]=_price;
        _list[2]=_nonce;        
        _check(_list,_msgSender(),_nonce,_sign);
        require(!bnbPayOrders[_orderId].succeed,"SquadxWallet : Order already exists");
        require(msg.value >=_price,"Payment:  Full payment is required");
        PayOrder memory order =  _buildPayOrder(_msgSender(),msg.value,_remark);
        bnbPayOrders[_orderId]=order;
        payable(_BNBPoolAddress).transfer(msg.value);
        emit BNBPay(_orderId,_msgSender(),msg.value,_remark);
        return true;
    }

    function getCTOPayOrder(uint256 _orderId)   external override  view returns (address payer,uint256 amount,uint256 time,string memory remark){
        PayOrder memory order = ctoPayOrders[_orderId];
        if(order.succeed){
            return (order.buyer,order.amount,order.time,order.remark);
        }
    }

    function getSXCPayOrder(uint256 _orderId) external override  view returns (address payer,uint256 amount,uint256 time,string memory remark){
        PayOrder memory order = sxcPayOrders[_orderId];
        if(order.succeed){
            return (order.buyer,order.amount,order.time,order.remark);
        }
    }

    function getBNBPayOrder(uint256 _orderId) external override  view returns (address payer,uint256 amount,uint256 time,string memory remark){
        PayOrder memory order = bnbPayOrders[_orderId];
        if(order.succeed){
            return (order.buyer,order.amount,order.time,order.remark);
        }
    }

    function ctoWithdraw(uint256 _orderId, address [] memory _users, uint256 [] memory _amounts ,string memory _remark) external override onlyOwner returns(bool){   
        WithdrawOrder storage order = ctoWithdrawOrders[_orderId];
        _ERC20Withdraw(order,_CTOTokenAddress,_CTOTokenPoolAddress,_users,_amounts,_remark);
        emit CTOWithdraw(_orderId,_users,_amounts,_remark);
        return true;
    }

    function sxcWithdraw(uint256 _orderId, address [] memory _users, uint256 [] memory _amounts ,string memory _remark) external override onlyOwner returns(bool){       
        WithdrawOrder storage order = sxcWithdrawOrders[_orderId];
        _ERC20Withdraw(order,_SXCTokenAddress,_SXCTokenPoolAddress,_users,_amounts,_remark);
        emit SXCWithdraw(_orderId,_users,_amounts,_remark);
        return true;
    }
    
    function _ERC20Withdraw(WithdrawOrder storage _order,address _tokenAddress,address _tokenPoolAddress,address [] memory _users, uint256 [] memory _amounts ,string memory _remark) internal returns (bool){
        require(!_order.succeed,"SquadxWallet : Order already exists");       
        require(_users.length == _amounts.length,"SquadxWallet : users.length must equal amounts.length");
        _order.time = block.timestamp;
        _order.remark = _remark;
        _order.succeed = true;
        WithdrawItem  []  storage  _items = _order.items;
        for(uint256 i = 0; i < _users.length; i++){
            address _user = _users[i];
            uint256 _amount = _amounts[i];
            IERC20TokenInterface(_tokenAddress).transferFrom(_tokenPoolAddress,_user,_amount);
            WithdrawItem memory item = WithdrawItem({
                user:_user,
                amount:_amount
            });
            _items.push(item);
        }
        return true; 
    }

    function bnbWithdraw(uint256 _orderId, address [] memory _users, uint256 [] memory _amounts ,string memory _remark) external override onlyOwner returns(bool){       
        WithdrawOrder storage order = bnbWithdrawOrders[_orderId];
        require(!order.succeed,"SquadxWallet : Order already exists");       
        require(_users.length == _amounts.length,"SquadxWallet : users.length must equal amounts.length");       
        WithdrawItem  []  storage  _items = order.items;
        for(uint256 i = 0; i < _users.length; i++){
            address _user = _users[i];
            uint256 _amount = _amounts[i];
            payable(_user).transfer(_amount);
            WithdrawItem memory item = WithdrawItem({
                user:_user,
                amount:_amount
            });
            _items.push(item);
        }
        order.time = block.timestamp;
        order.remark = _remark;
        order.succeed = true;
        emit BNBWithdraw(_orderId,_users,_amounts,_remark);
        return true;
    }

     function getCTOWithDrawOrder(uint256 _orderId) external override view returns (uint256 time,address [] memory users, uint256 [] memory amounts,string memory remark){
        WithdrawOrder memory order = ctoWithdrawOrders[_orderId];
        return _getWithdrawOrder(order);
     }

     function getSXCWithDrawOrder(uint256 _orderId) external override view returns (uint256 time,address [] memory users, uint256 [] memory amounts,string memory remark){
        WithdrawOrder memory order = sxcWithdrawOrders[_orderId];
        return _getWithdrawOrder(order);
     }

     function getBNBWithDrawOrder(uint256 _orderId) external override view returns (uint256 time,address [] memory users, uint256 [] memory amounts,string memory remark){
        WithdrawOrder memory order = bnbWithdrawOrders[_orderId];
        return _getWithdrawOrder(order);
     }

     function _getWithdrawOrder(WithdrawOrder memory _order) internal pure returns ( uint256 time,address [] memory users, uint256 [] memory amounts,string memory remark){
         if(_order.succeed){
            WithdrawItem [] memory items = _order.items;
            users = new address[](items.length);
            amounts = new uint256 [](items.length);
            for(uint256 i =0;i<items.length;i++){
                WithdrawItem memory item = items[i];
                users[i]=item.user;
                amounts[i]=item.amount;
            }
            remark = _order.remark;
            time = _order.time;
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

    fallback ()  external payable{}
    receive () payable external {}

    constructor(address ctoTokenAddress_,address sxcTokenAddress_,address ctoTokenPoolAddress_,address sxcTokenPoolAddress_,address bnbPoolAddress_,bool signEnable_,address signAddress_,uint256 expireTime_)  {
        _CTOTokenAddress= ctoTokenAddress_;
        _SXCTokenAddress = sxcTokenAddress_;
        _CTOTokenPoolAddress = ctoTokenPoolAddress_;
        _SXCTokenPoolAddress = sxcTokenPoolAddress_;
        _BNBPoolAddress = bnbPoolAddress_;
        _setSignEnable(signEnable_);
        _setSignAddress(signAddress_);
        _setExpireTime(expireTime_);
    }
}