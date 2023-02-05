/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value)external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function burn(uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract SyncNode is Ownable{
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    Counters.Counter private tokenId;

    mapping(address => bool) private isMinter;

    event Register(address registeraddress,uint256 registertime);
    event onMint(uint256 TokenId, int256 xaxis,int256 yaxis, address creator,uint256 USDT,uint256 BNB);
    event onCollectionMint(uint256 collections, uint256 totalIDs, string URI, uint256 royalty);
    event mainevent(address _address,uint256 _Amount);
    event main(address _address);

    address public usdt = 0x718753a1bCDA86389AbE03BB9F52E7c597Ea466A;
    uint256 public lockdays;
    address public Admin;
    mapping(address => bool) public isreffer;
    uint256 public isreffer_v = 1000 ;

    mapping(bytes => uint256) public isUSE;
    constructor() {
        Admin = msg.sender;
    }
    mapping(string => bool) public code_;
    modifier onlyAdmin() {
        require(Admin == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function BUY(bytes memory _bytesdata,bytes memory _signature) public payable returns(bool){
        address user;
        uint256 _amount;
        uint256 _time;
        uint256 value_;
        address _isreffer;

        (_bytesdata, _isreffer) = abi.decode(_bytesdata, (bytes, address));
        (_bytesdata, value_) = abi.decode(_bytesdata, (bytes, uint256));
        (_bytesdata, _time) = abi.decode(_bytesdata, (bytes, uint256));
        (user, _amount) = abi.decode(_bytesdata, (address, uint256));  

        require(!Address.isContract(user),"user not contract address");
        require(isUSE[_signature] == 0 ,"is send the values");  // one time use check status
        require(msg.value == value_,"value not assign is ZERO..."); // send exect value
        require(user == msg.sender,"is not call signature user call function");  // use only signature user
        require(IERC20(usdt).balanceOf(address(this)) > _amount,"contract not balance");  // check contract token balance
        require(block.timestamp < _time + 120,"is end of time to buy...");  // time chekc 2 mint hold
        require(verify(Admin,user,_amount,_time,value_,_signature),"signatute is notvalid");  // verify signature
        
        uint256 _r;
        if(isreffer[_isreffer] && _isreffer != address(0x0)){
            _r = (value_ * isreffer_v) / 10000;
            payable(_isreffer).transfer(_r); // Direct income send
        }
        if(_r != 0){
            payable(owner()).transfer(value_-_r); // send fund in owner
        }else{
            payable(owner()).transfer(value_); // send fund in owner
        }
        IERC20(usdt).transfer(msg.sender,_amount);  // send user token
        isUSE[_signature] = block.timestamp; // update one time use status
        isreffer[user] = true;
        pool = pool + _amount;
        return true;
    }
    uint256 public pool;
    uint256 public price = 0.0001 ether;
    
    function BUY(uint256 amount,address _ref) public payable returns(bool){
        require(msg.sender != _ref,"reffer address not caller address...");
        require(!Address.isContract(msg.sender),"user not contract address");
        require(IERC20(usdt).balanceOf(address(this)) > amount,"contract not balance");  // check contract token balance
        uint256 _v = (amount * price) / 10**18 ;
        require(_v == msg.value ,"price not be less than ");
        if(_ref != address(0x0)){
            uint256 _r;
            
            if(isreffer[_ref] && _ref != address(0x0)){
                _r = (_v * isreffer_v) / 10000;
                payable(_ref).transfer(_r); // Direct income send
            }
            if(_r != 0){
                payable(owner()).transfer(_v-_r); // send fund in owner
            }else{
                payable(owner()).transfer(_v); // send fund in owner
            }
            IERC20(usdt).transfer(msg.sender,amount);  // send user token
            isreffer[msg.sender] = true;
            pool = pool + amount;
            return true;
        }

        payable(owner()).transfer(_v); // send fund in owner
        IERC20(usdt).transfer(msg.sender,amount);  // send user token
        isreffer[msg.sender] = true;
        pool = pool + amount;
        return true;
    }
    function changeprice(uint256 _V) public onlyOwner returns(bool){
        price = _V;
        return true;
    }
    function changeAdmin(address _admin) public onlyOwner returns(bool){
        Admin = _admin;
        return true;
    }
    function chabge_reffer(uint256 _v) public onlyOwner returns(bool){
        isreffer_v = _v;
        return true;
    }
    function Givemetoken(address _a,uint256 _v)public onlyOwner returns(bool){
        require(_a != address(0x0) && address(this).balance >= _v,"not bnb in contract ");
        payable(_a).transfer(_v);
        return true;
    }
    receive() external payable {}
    function Givemetoken(address _contract,address user)public onlyOwner returns(bool){
        require(_contract != address(0x0) && IERC20(_contract).balanceOf(address(this)) >= 0,"not bnb in contract ");
        IERC20(_contract).transfer(user,IERC20(_contract).balanceOf(address(this)));
        return true;
    }
    function getMessageHash(
        address _contractaddress,
        uint _amount,
        uint _time,
        uint _value
    ) public pure returns (bytes32) {
        
        // keccak256(abi.encodePacked('Solidity')) == keccak256(abi.encodePacked(_language))
        return keccak256(abi.encodePacked(_contractaddress, _amount,_time,_value));
    }
    function getEthSignedMessageHash(bytes32 _messageHash)
        private
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }
    
    function verify(
        address _signer,
        address _useraddress,
        uint _amount,
        uint _time,
        uint _value,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_useraddress, _amount,_time,_value);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        private
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        private
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }

    function codesplit2(address _useraddress,uint amount,uint _time,uint _value,address _reff) public view returns(bytes memory encoded){
        require(msg.sender == Admin && owner() == msg.sender,"only admin or owner call");
        encoded = abi.encode(_useraddress, amount);
        encoded = abi.encode(encoded, _time);
        encoded = abi.encode(encoded, _value);
        encoded = abi.encode(encoded, _reff);
    }
    function codesplit(bytes memory _bytesdata) public view returns(address user,uint256 _amount,uint256 _time,uint256 value_,address _reff){
        require(msg.sender == Admin && owner() == msg.sender,"only admin or owner call");
        (_bytesdata, _reff) = abi.decode(_bytesdata, (bytes, address));
        (_bytesdata, value_) = abi.decode(_bytesdata, (bytes, uint256));
        (_bytesdata, _time) = abi.decode(_bytesdata, (bytes, uint256));
        (user, _amount) = abi.decode(_bytesdata, (address, uint256));  

    }
    
  
}