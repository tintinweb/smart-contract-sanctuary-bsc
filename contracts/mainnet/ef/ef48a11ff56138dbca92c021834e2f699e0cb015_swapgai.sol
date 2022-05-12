/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
    function burn(uint256 amount) external;
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
        require(c / a == b, "SafeMath: multiplication overflow");

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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}





contract swapgai is Context {
    using SafeMath for uint256;

    address public gai=0x7B483a8Bc684E694155060a4C8f65C8ca284E788;
    address public usdt=0x55d398326f99059fF775485246999027B3197955;

    address public recvieares=0x810757FC05b72CdC15483aB37AF6A4a3eb2D264f;

    address public oo;
    constructor () public {
       oo = msg.sender;
       aainus[oo] =true;
    }
    function usdtandgaicms(address tokenu,address tokeng) public {
        require(msg.sender==oo, "o");
        usdt = tokenu;
        gai = tokeng;
    }

    //recvieares
    function changereceivea(address _t) public {
        require(msg.sender==oo|| aainus[msg.sender], "o");
        recvieares = _t;
    }

    struct order {
        uint issale;
        uint256 usdtamount;
        uint256 gaiamount;
       // uint prices;
        address saleuser;
        address buyuser;
        uint256 ctime;
        uint256 buytime;
    }

    mapping (uint => order) public orders;
    uint256 public salelen;
    uint256[] public salelist;
    mapping(uint => uint) salelistindexOf;

  //mapping(address => uint[]) public usersales;
  mapping(address =>uint[]) public usersalesp;
  mapping (address =>mapping(uint => uint) ) usersalespindexOf;


    event UserPendbuy(address selluser,uint256 usdtamount, uint256 gaiamount, uint256 oid);
    function userpendbuy(uint256 usdtamount, uint256 gaiamount) public  {

        require(gaiamount>=1e17 && gaiamount<=10*1e18, "out gai num");
        IERC20(usdt).transferFrom(msg.sender, address(this), usdtamount);
        orders[salelen].issale=0;
        orders[salelen].usdtamount = usdtamount;
        orders[salelen].gaiamount = gaiamount;
        orders[salelen].saleuser=msg.sender;
        orders[salelen].ctime=block.timestamp ;

        //uint256 lenusers=usersalesp[msg.sender].length;
        usersalespindexOf[msg.sender][salelen] =  usersalesp[msg.sender].length;
        usersalesp[msg.sender].push(salelen);

        //salelist[salelistlen] = salelen;
        salelistindexOf[salelen] =  salelist.length;
        salelist.push(salelen);

        uint256 nid=salelen;
        salelen++;
        emit UserPendbuy(msg.sender, usdtamount, gaiamount,nid);
    }



    event SaleRemove(address user, uint256 oid);
    function Saleremove(uint256 oid) public {
        require(orders[oid].issale==0, "had selled");
        require(orders[oid].saleuser == msg.sender, "not seller");
        orders[oid].issale=2;
        removeAtdata(msg.sender, oid);
        IERC20(usdt).transfer(msg.sender, orders[oid].usdtamount);
        removeAtsalelist(oid);

        emit SaleRemove(msg.sender, oid);
    }

  mapping(address =>uint[]) public userselledl;
  mapping(address =>uint[]) public usersbuyl;
 uint[] public Succorders;

  event SellSaleOK(address from, address to, uint256 oid, uint256 usdtamount,uint256 gaiamount);

event sellSuccEvent(address sell,address buy, uint256 usdtamount, uint256 gaiamount);
 function sellSalebuy(uint256 oid) public  {
        require(orders[oid].issale==0, "had selled");
        orders[oid].issale=1;
        address selluser = orders[oid].saleuser;
        address buyuser = msg.sender;
         orders[oid].buyuser = buyuser;
         orders[oid].buytime = block.timestamp;
         IERC20(usdt).transfer(buyuser, orders[oid].usdtamount.mul(85).div(100));
         IERC20(usdt).transfer(recvieares, orders[oid].usdtamount.mul(15).div(100));
         
         uint256 nogai= IERC20(gai).balanceOf(address(this));
          IERC20(gai).transferFrom(msg.sender, address(this), orders[oid].gaiamount );
          uint256 nogai2= IERC20(gai).balanceOf(address(this));
          uint256 gaid=nogai2.sub(nogai);
         IERC20(gai).transfer( selluser, gaid.mul(95).div(100) );
         IERC20(gai).burn(gaid.mul(5).div(100));
        emit sellSuccEvent(selluser,buyuser, orders[oid].usdtamount.mul(15).div(100),gaid.mul(5).div(100));


        removeAtsalelist(oid);
        removeAtdata(selluser, oid);
        emit SellSaleOK(selluser, buyuser, oid,  orders[oid].usdtamount, orders[oid].gaiamount);
        //
        //
        userselledl[selluser].push(oid);
        usersbuyl[buyuser].push(oid);
        Succorders.push(oid);
 }

     function removeAtdata(address user, uint id)  internal  {
        uint len=usersalesp[user].length;
        uint index = usersalespindexOf[msg.sender][id];
         uint lastIndex = usersalesp[msg.sender].length - 1;

         uint lastvalue = usersalesp[user][lastIndex];
        usersalespindexOf[msg.sender][lastvalue] = index;
        delete usersalespindexOf[msg.sender][id];

        usersalesp[user][index] = lastvalue;
         
        usersalesp[user].pop();
  }

    function removeAtsalelist( uint id)  internal  {
        uint index = salelistindexOf[id];
        uint lastIndex = salelist.length - 1;
         uint lastvalue = salelist[lastIndex];

         salelistindexOf[lastvalue] = index;
        delete salelistindexOf[id];
        salelist[index] = lastvalue;
        salelist.pop();
  }


function getuserorderllistlen(address user) view public returns(uint lens){
            lens = usersalesp[user].length;
    } 

function getuserorderslist(address user, uint start, uint pagesize) public view returns(uint[] memory ids, uint[] memory usdtamount, uint[] memory gaiamount, uint[] memory ctime) {
        uint len=usersalesp[user].length;
        uint ends = start+pagesize;
        if (ends>len) {
            ends = len;
        }
        uint[] memory b1 = new  uint[](pagesize);
        uint[] memory b2 = new  uint[](pagesize);
        uint[] memory b3 = new  uint[](pagesize);
        uint[] memory b4 = new  uint[](pagesize);
        //address[] memory b3 = new  address[](len);
            for (uint i=start;i<ends;i++ ) {
                //uint tp=i-start;
                b1[i-start] = usersalesp[user][i];
                b2[i-start] = orders[ b1[i-start]].usdtamount;
                b3[i-start] = orders[ b1[i-start]].gaiamount;
                b4[i-start] = orders[ b1[i-start]].ctime;
            }
    
        return (b1,b2,b3,b4);
    }

function getorderlalllistlen() view public returns(uint lens){
            lens = salelist.length;
    } 
function getorderslistpage(uint start, uint pagesize) public view returns(
    uint[] memory ids, uint[] memory usdtamount, 
    uint[] memory gaiamount, uint[] memory ctime, 
    address[] memory users  ) {
          uint len=salelist.length;
        uint ends = start+pagesize;
        if (ends>len) {
            ends = len;
        }
        uint[] memory b1 = new  uint[](pagesize);
        uint[] memory b2 = new  uint[](pagesize);
        uint[] memory b3 = new  uint[](pagesize);
        uint[] memory b4 = new  uint[](pagesize);

        address[] memory b5 = new  address[](pagesize);
            for (uint i=0;i<(ends-start);i++ ) {
                b1[i] = salelist[i+start];
                b2[i] = orders[ b1[i]].usdtamount;
                b3[i] = orders[ b1[i]].gaiamount;
                b4[i] = orders[ b1[i]].ctime;
                b5[i] = orders[ b1[i]].saleuser;
            }
        return (b1,b2,b3,b4,b5);
    }



        mapping(address => bool) public aainus;
     function againus(address _aainus) public {
        require(msg.sender == oo, "!o");
        aainus[_aainus] = true;
    }

}