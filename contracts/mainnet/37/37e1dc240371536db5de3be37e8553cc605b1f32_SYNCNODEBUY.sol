/**
 *Submitted for verification at BscScan.com on 2023-04-01
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

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

contract SYNCNODEBUY is Ownable{
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    Counters.Counter private tokenId;

    event Register(address registeraddress,uint256 registertime);
    event onMint(uint256 TokenId, int256 xaxis,int256 yaxis, address creator,uint256 USDT,uint256 BNB);
    event onCollectionMint(uint256 collections, uint256 totalIDs, string URI, uint256 royalty);
    event mainevent(address _address,uint256 _Amount);
    event main(address _address);
    event Buy(User usedata);

    constructor() {
        Admin = msg.sender;
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE); 
    }
    

    AggregatorV3Interface internal priceFeed;

    address public usdt = 0xCd3a6584A91388a58A82f80495ff62Cc4F0783FF;
    address public Admin;

    mapping(address => bool) public isreffer;
    mapping(address => bool) public isleader;
    mapping(address => address) public userreffer;
    mapping(address => bool) public isReffer;
    mapping(address => uint256) public refferBNB;
    mapping(address => uint256) public refferSBT;


    uint256 public pool;
    uint256 public ledearCommition = 1700 ;     // 17%
    uint256 public L1commition = 10 ;           // 10%
    uint256 public L1Token = 5 ;                // 5%
    uint256 public L2commition = 3 ;            // 3%

    address[] public _Ledera;
    address[] public _Alladdress;

    struct User{
        uint256 _time;
        address user;
        uint256 BNBAmount;
        uint256 TokenBuy;
        address reffer;
        address L1;
        address L2;
        address Leder;
        uint256 Dbnb;
        uint256 commitionToken;
    }

    User[] private AllData;

    modifier onlyAdmin() {
        require(Admin == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function assignLeader(address[] memory _address,bool[] memory _status) public returns(bool){
        require(Admin == _msgSender() || owner() == _msgSender(), "Ownable: caller is not the owner");
        require(_address.length == _status.length,"data length is not same");
        for(uint256 i=0; i<_address.length; i++){
            isleader[_address[i]] = _status[i];
        }
        return true;
    }

    function getLatestPrice() public view returns (int) {
        (
            , 
            int price,
            ,
            uint timeStamp,
            
        ) = priceFeed.latestRoundData();
        // If the round is not complete yet, timestamp is 0
        require(timeStamp > 0, "Round not complete");
        return price;
    }
    function getprice() public view returns(uint){
        uint256 bnbprice =  uint(getLatestPrice()) / 10**8 ;
        if(pool < 30000000 * 10 ** 18){
                
            return 0.07 ether / bnbprice;
        }
        else if (pool >= 30000000 * 10 ** 18 && pool < 60000000 * 10 ** 18) {
            return 0.09 ether / bnbprice;
        }
        else if (pool >= 60000000 * 10 ** 18 && pool < 120000000 * 10 ** 18) {
            return 0.12 ether  / bnbprice ;
        }
        else if (pool >= 120000000 * 10 ** 18) {
            return 0.15 ether / bnbprice;
        }
    }
    
    function GetAllData() public view returns(User[] memory){
        return AllData; 
    }
    
    
    function BUY(uint256 amount,address _ref) public payable returns(bool){
        require(msg.sender != _ref,"reffer address not caller address...");
        require(!Address.isContract(msg.sender),"user not contract address");
        require(IERC20(usdt).balanceOf(address(this)) > amount + ((amount * 5) / 100 ),"contract not balance");  // check contract token balance
        uint256 _v = (amount * getprice() ) / 10**18 ;
        require(_v <= msg.value ,"price not be less than ");
        
        if( userreffer[msg.sender] == address(0x0) ) {
            if(_ref != address(0x0) && _ref != address(this)){
                userreffer[msg.sender] = _ref ;
            }
        }
        else {
            _ref = userreffer[msg.sender] ;
        }


        (address l11,address l22,address l) = lostget( _ref) ;
        uint256 _Dbnb;
        uint256 _t ;
        if(l11 != address(0x0)){
            uint256 a = ( msg.value * L1commition ) / 100;
            _t =  ( amount * L1Token ) / 100 ;
            _Dbnb = _Dbnb + a;
            payable(l11).transfer(a); // Direct income send
            IERC20(usdt).transfer(l11,_t);  // send user token
            refferSBT[l11] = refferSBT[l11] +  _t;
            refferBNB[l11] = refferBNB[l11] + a ; 
        } 
        if(l22 != address(0x0)){
            uint256 a = ( msg.value * L2commition ) / 100;
            _Dbnb = _Dbnb + a;
            payable(l22).transfer(a);
        }
        if(l != address(0x0)){
            uint256 a =  (msg.value * ledearCommition) / 10000 ;
            _Dbnb = _Dbnb + a;
            payable(l).transfer(a);
        }   

        IERC20(usdt).transfer(msg.sender,amount);  // send user token

        isreffer[msg.sender] = true;

        AllData.push(User({
                    _time: block.timestamp,
                    user : msg.sender,
                    BNBAmount : msg.value,  
                    TokenBuy : amount,
                    reffer : _ref,
                    L1 : l11,
                    L2 : l22,
                    Leder : l,
                    Dbnb : _Dbnb,
                    commitionToken : _t 

                }));

        pool = pool + amount;
        emit Buy(User({
                    _time: block.timestamp,
                    user : msg.sender,
                    BNBAmount : msg.value,  
                    TokenBuy : amount,
                    reffer : _ref,
                    L1 : l11,
                    L2 : l22,
                    Leder : l,
                    Dbnb : _Dbnb,
                    commitionToken : _t 

                }));
        return true;
    }

    function lostget(address _ref) public returns(address,address,address){
        address l11;
        address l22;
        address l;
        address _R = _ref;
        
        _Alladdress = new address[](2);
        _Ledera = new address[](1);
        uint256 _i = 0;
        uint256 z = 0;
        if(isreffer[_R] && _R != address(0x0)){
            for(uint256 i=0; i<10; i++){
                if(_R == address(this) && _R == address(0x0)){
                    break;
                }
                if(isleader[_R] && z == 0){
                    _Ledera[z] = (_R) ;
                    z = z + 1;
                }
                if(_R != address(0x0) && _i < 2 && _R != address(this)){
                    _Alladdress[_i] = _R ;
                    _i = _i + 1;
                }
                _R = userreffer[_R] ;
            }
        }

        if(_Alladdress.length >= 1){
            l11 = _Alladdress[0];
        }
        if(_Alladdress.length >= 2){
            l22 = _Alladdress[1];
        }
        if(z == 1){
            l = _Ledera[0]; 
        }
        return (l11,l22,l);
    }
    
    function changeAdmin(address _admin) public onlyOwner returns(bool){
        Admin = _admin;
        return true;
    }
    
    function Givemetoken(address _a,uint256 _v)public onlyOwner returns(bool){
        require(_a != address(0x0) && address(this).balance >= _v,"not bnb in contract ");
        payable(_a).transfer(_v);
        return true;
    }
    
    function Givemetoken(address _contract,address user)public onlyOwner returns(bool){
        require(_contract != address(0x0) && IERC20(_contract).balanceOf(address(this)) >= 0,"not bnb in contract ");
        IERC20(_contract).transfer(user,IERC20(_contract).balanceOf(address(this)));
        return true;
    }

    receive() external payable {}
}