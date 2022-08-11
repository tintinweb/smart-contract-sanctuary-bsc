/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

// File: BlindBox_flat.sol


// File: contracts/libs/SafeMath.sol

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;


/**
 * @dev From https://github.com/OpenZeppelin/openzeppelin-contracts
 * Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    using SafeMath for uint;

    uint constant internal PRECISION = 1e18;

  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function precisionDiv(uint256 a, uint256 b)internal pure returns (uint256) {
     a = a.mul(PRECISION);
     a = div(a, b);
     return div(a, PRECISION);
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, 'SafeMath: modulo by zero');
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }

  function exp(uint256 a, uint256 n) internal pure returns(uint256){
    require(n >= 0, "SafeMath: n less than 0");
    uint256 result = 1;
    for(uint256 i = 0; i < n; i++){
        result = result.mul(10);
    }
    return a.mul(result);
  }
}

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

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

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
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

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/BlindBox.sol



pragma solidity >=0.8.0;





error BoxIdNotExit(uint256 boxId);

contract BlindBox is Ownable{

    using Strings for uint;
    using SafeMath for uint;

    bool reentrancyLock = false;

    mapping(uint256 => Box) public boxPropertys;//盒子ID 和 盒子的映射

    mapping(uint256 => Buy[]) public buys;//盒子ID 和 可以购买的币种数组映射

    mapping(uint256 => Proportion[]) public proportions;//盒子ID和奖品数组映射

    mapping(uint256 => uint256) public alertBuys;//盒子ID 和已经购买的数量映射

    mapping(address => address) public inviteLink;//邀请关系映射

    uint256 public boxStartId = 0;//id起始位置

    address public platformAddress;//平台钱包地址

    bool public _paused;//系统维护标识

    Box[] public boxs;//盒子数组

    uint private unlocked = 1;

   struct Box{        
        address owenAddress;//土狗方地址
        address proxyAddress;//商务方地址
        uint256 owenIncome;//每开一个盲盒 土狗方获得的收益
        // string name;//盒子名称
        // string iamgeUrl;//盒子图片
        uint256 quantity; //盒子总数量
        uint256 sellQuantity;//已售盒子数量  
    }

    struct Buy{
        uint256 price;//盒子价格
        address ercAddress;//盒子币种
    }

    struct Proportion{
        uint totalNum;//总共可开出的数量
        uint sellNum;//已开出数量
        uint quantity;//奖励币种的数量       
        address tokenAddress;//奖励币种的地址
    }



    event addBoxEvn(uint _boxId);

    event delBoxEvn(uint256 _boxId);

    

    constructor(address _platformAddress){

        platformAddress = _platformAddress;
    
    }





    function addBox(uint boxId,address _owenAddress,address _proxyAddress,uint256 _owenIncome,uint256 _totalQuanity,
        address[]  memory _buyAddress,uint256[] memory _prices,
        address[]  memory _proportionAddress,uint[] memory _totalNum,uint[] memory _proQuantity) external onlyOwner returns(uint256){

        require(_owenAddress != address(0x0),"_ownaddress error");
        require(_proxyAddress != address(0x0),"_ownaddress error");
        require(_buyAddress.length == _prices.length,"buy length diff");
        require(_proportionAddress.length == _totalNum.length,"prop num length diff");
        require(_proQuantity.length == _totalNum.length,"prop quantity length diff");

        Box memory _box = Box(_owenAddress,_proxyAddress,_owenIncome,_totalQuanity,0);
        boxPropertys[boxId] = _box;
        Buy memory _buy;
        for(uint i=0;i<_buyAddress.length;i++){
            _buy = Buy(_prices[i],_buyAddress[i]);
            buys[boxId].push(_buy);
        }
        addProp(boxId,_proportionAddress,_totalNum,_proQuantity);
        emit addBoxEvn(boxId);
        return boxId;
    }

    function addProp(uint boxId,address[]  memory _proportionAddress,uint[] memory _totalNum,uint[] memory _proQuantity) internal onlyOwner {
        Proportion memory _proportion;
        for(uint i=0;i<_proportionAddress.length;i++){
            _proportion = Proportion(_totalNum[i],0,_proQuantity[i],_proportionAddress[i]);
            proportions[boxId].push(_proportion);
        }
    }



    function delBox(uint256 _boxId) external onlyOwner (){
        delete boxPropertys[_boxId];
        delete buys[_boxId];
        delete proportions[_boxId];
        delete alertBuys[_boxId];
        emit delBoxEvn(_boxId);
    }

    function getInfo(uint256 _boxId) external view returns(Box memory ,Buy[] memory, Proportion[] memory,uint256){
        return (boxPropertys[_boxId],buys[_boxId],proportions[_boxId],alertBuys[_boxId]);
    }

    function getBoxId() internal reentrancyGuard returns(uint256) {
        unchecked {
            return boxStartId = boxStartId.add(1);
        }
            
    }


    function ercApprove(address _erc20Address,uint256 _value) public{
        IERC20 erc = IERC20(_erc20Address);
        erc.approve(address(this),_value);
    }


    event openBoxEvn(uint _boxId , uint pquantity,address ptokenAddress,address _fromAddress);

    function buyBox(uint _boxId,address _fromAddress)  onlyWhenNotPaused  external {
        require(_fromAddress != msg.sender,"from is must diff");
        Buy[] memory _buys = buys[_boxId];
        if(_buys.length <= 0){
            revert BoxIdNotExit(_boxId);
        }
        Box memory _box = boxPropertys[_boxId];
        uint256 totalQuantity =_box.quantity;
        uint256 _sellQuantity = _box.sellQuantity.add(1);
        require(totalQuantity >= _sellQuantity,"Inventory shortage");   
        uint256 price = _buys[0].price;
        require(price > 0,"_buyErcAddress is not exit");
        IERC20 erc20 = IERC20(_buys[0].ercAddress);  
        erc20.transferFrom(msg.sender,address(this),price);
        
        doIncome(price,_box.owenAddress,_box.owenIncome,_box.proxyAddress,_fromAddress,erc20);//计算相关收益
        Proportion memory _proportion = openBox(_boxId);//给用户随机开奖
        boxPropertys[_boxId].sellQuantity = _sellQuantity;

        emit openBoxEvn(
            _boxId,
            _proportion.quantity,
           _proportion.tokenAddress,
           _fromAddress);
    }


    


    //计算收益并且发放
    function doIncome(uint256 _price,address _ownerAddress,uint _ownerIncome, address _proxyAddress,address _fromAddress,IERC20 erc20) internal { 
        address levelOne; 
        address levelTwo;
        (levelOne,levelTwo) = getLeveAddress(msg.sender,_fromAddress);

        //项目方收益
        uint256 platFormIncome = _price.mul(3).div(100);
        //商务收益
        uint256 proxyIncome = _price.mul(2).div(100);
        //lv1收益
        uint256 leveOneIncome = _price.mul(3).div(100);
        //lv2收益
        uint256 leveTwoIncome = _price.mul(2).div(100);
               
        erc20.transfer(platformAddress,platFormIncome);
        //土狗方
        erc20.transfer(_ownerAddress,_ownerIncome);
        erc20.transfer(_proxyAddress,proxyIncome);
        if(levelOne != address(0x0)){
            erc20.transfer(levelOne,leveOneIncome);
            if(levelTwo!=address(0x0)){
               erc20.transfer(levelTwo,leveTwoIncome); 
            }
        }

    }



    //获取价格
    //function getPrice(Buy[] memory _buys,address _buyErcAddress) internal returns(uint256){
        //获取支付币种的价格
    //    uint256 price = 0;
    //    Buy memory _buy;
    //    for(uint i=0;i<_buys.length;i++){
    //        _buy = _buys[i];
    //        if(_buy.ercAddress == _buyErcAddress){
    //            price = _buy.price;
    //            break;
    //        }
    //    }
    //    return price; 
    //}

    //获取地址
    function getLeveAddress(address _owner,address _fromAddress) internal returns (address,address){
        address _levelOne = inviteLink[_owner];

        if(_levelOne == address(0x0) && _fromAddress != address(0x0)){//如果当前有上级地址，之前没有绑定过
            inviteLink[_owner] = _fromAddress;
            _levelOne = _fromAddress;
        }
        address _levelTwo = address(0x0);
        if(_levelOne != address(0x0)){
            _levelTwo = inviteLink[_levelTwo];
        }
  
        return (_levelOne,_levelTwo);
    }

    
   // //计算当前开出奖励并且发放给用户
    function openBox(uint _boxId) internal lock returns(Proportion memory){
        address _owner =  msg.sender;
        Box memory _box = boxPropertys[_boxId];
        Proportion[] memory _pps = proportions[_boxId];
        require(_pps.length >= 1,"yi shou qin");
        require(_pps.length <= 3,"yi shou qin");   

        Proportion memory myProp;
        uint one = _pps[0].totalNum;
        uint firstNum = _pps[0].sellNum;
        if(_pps.length == 1){//当前只有一种概率        
            proportions[_boxId][0].sellNum = firstNum.add(1);
            myProp = _pps[0];
        }else {
            uint suiji = getRandom(_boxId);
            uint two = _pps[1].totalNum;
            uint secondNum = _pps[1].sellNum;
            uint first = one.sub(firstNum);
            uint second = first.add(two).sub(secondNum);
            if(_pps.length == 2){
                if(suiji <= first){
                    proportions[_boxId][0].sellNum = _pps[0].sellNum.add(1);
                     myProp = _pps[0];
                }else if(suiji>first && suiji <= second){
                    proportions[_boxId][1].sellNum = _pps[1].sellNum.add(1);    
                    myProp = _pps[1];                
                }
            }else{
                    myProp = openThree(_boxId,suiji,_owner);
            }
        }
        IERC20 erc20 = IERC20(myProp.tokenAddress);
        erc20.transfer(_owner,myProp.quantity);
        
        return myProp;
    }



    function openThree(uint _boxId,uint suiji,address _owner) internal returns(Proportion memory myProp){
                Proportion[] storage _pps = proportions[_boxId];
                uint one = _pps[0].totalNum;
                uint firstNum = _pps[0].sellNum;
                uint two = _pps[1].totalNum;
                uint secondNum = _pps[1].sellNum;
                uint first = one.sub(firstNum);
                uint second = first.add(two).sub(secondNum);

                uint three = _pps[2].totalNum;
                uint thirdNum = _pps[2].sellNum;
                uint third = second.add(three).sub(thirdNum);               
                if(suiji <= first){
                    _pps[0].sellNum = _pps[0].sellNum.add(1);
                    return myProp = _pps[0];
                }else if(suiji>first && suiji <= second){
                    _pps[1].sellNum = _pps[1].sellNum.add(1);
                    return myProp = _pps[1];                  
                }else if(suiji > second && suiji <= third){
                    _pps[2].sellNum = _pps[2].sellNum.add(1);
                    return myProp = _pps[2];
                }else{
                    require(_boxId>50,"suiji");
                }
    }


    function getRandom( uint _boxId) public  view returns (uint){
        Box memory _box = boxPropertys[_boxId];
        uint totalNum  = _box.quantity.sub(_box.sellQuantity);
        uint rand = 0;
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        rand =  random % totalNum +1;
        return rand;
    }

    function getRandomTwo( uint totalNum) public view returns (uint){
        uint rand = 0;
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        rand =  random % totalNum + 1;
        return rand;
    }


    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }


    function setPlatformAddress(address _platformAddress) external onlyOwner {
        require(_platformAddress != address(0x0),"_platformAddress is error");
        platformAddress = _platformAddress;
    }


   modifier reentrancyGuard {
        if (reentrancyLock) {
            revert();
        }
        reentrancyLock = true;
        _;
        reentrancyLock = false;
    }

    modifier onlyWhenNotPaused {
        require(!_paused, "PAUSED");
        _;
    }

    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function doToken(address _token,address _to) external onlyOwner{
        IERC20 erc = IERC20(_token);
        erc.transfer(_to,erc.balanceOf(address(this)));
    }


}