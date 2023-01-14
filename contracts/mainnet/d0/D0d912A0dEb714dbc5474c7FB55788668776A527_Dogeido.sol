/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

pragma solidity ^0.6.0;

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
    function burn(uint256 amount) external;
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol
interface IERCft{

  function mintNFTaType(uint ttype, uint256 numberOfNfts, address to) external returns(uint[] memory ids) ;
  function transferFrom(address from, address to, uint256 tokenId) external;
  function transferAdress(address to, uint256 tokenid) external;
  function transferAdressT(address from, address to, uint256 tokenid)  external;
  function gettypeend (uint ttype) view external returns (uint);
  function gettypeendMax (uint ttype) view external returns (uint);
  function getleve(uint id) view external returns(uint le) ;
    //类型的
   function getAllnftTypeLen(uint t) view external returns(uint );
   function getAllnftTypeToken(uint ttype, uint index) view external returns(uint ) ;
   function ownerOf(uint256 tokenId) external view returns (address owner);
}

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        uint[] keys;
        //mapping(address => uint) values;
        mapping(uint => uint) indexOf;
        mapping(uint => bool) inserted;
    }

    // function get(Map storage map, address key) public view returns (uint) {
    //     return map.values[key];
    // }

    function getIndexOfKey(Map storage map, uint key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (uint) {
        return map.keys[index];
    }



    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, uint key) public {
        if (map.inserted[key]) {
           // map.values[key] = val;
        } else {
            map.inserted[key] = true;
          //  map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, uint key) public {
        if (!map.inserted[key]) {
            return;
        }
        delete map.inserted[key];
       // delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        uint lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */

// File: ExoticMonster20.sol

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */


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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
     {
        require(b <= a, errorMessage);
        return a - b;
    }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
     {
        require(b > 0, errorMessage);
        return a / b;
    }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
     
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
     {
        require(b > 0, errorMessage);
        return a % b;
    }
    }
}

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity ^0.6.0;


contract Dogeido   {
    using SafeMath for uint256;
    using IterableMapping for IterableMapping.Map;

   // IterableMapping.Map[6] public mapnft;
    mapping (uint=> IterableMapping.Map ) private mapnft;


    mapping (address => bool) private aab;
    address private controllerAddress;
    
    bool public isp=false;
    uint256 public price=285714286*1e10;
    address payable ru=0x59ECF94fc2B8A4D91401ddBc2CCCb9a4a95C117b;

    address public addressu=0x59ECF94fc2B8A4D91401ddBc2CCCb9a4a95C117b;
    address public ec;
    address public nft;

//online
  //IPancakeRouter01 public PancakeRouter01 = IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E);

  //test：
IPancakeRouter01 public PancakeRouter01 = IPancakeRouter01(0xBdd7CE63a3C438fbf986BE1E5fa091E553720c4c);

mapping (uint=>IPancakeRouter01) public allPancakeRouter01;

  address public usdt=0x55d398326f99059fF775485246999027B3197955;  //online

  address public dogeking=0x641EC142E67ab213539815f67e4276975c2f8D50; //online

  address public buynewtoken=0xf3B185ab60128E4C08008Fd90C3F1F01f4B78d50;


  mapping (address=>bool) public ishadswapnft ;

    receive() external payable {}

    constructor( address _nft) public {
        controllerAddress = msg.sender;
        addsomeusmn(controllerAddress);
       // addressu = u;
        nft = _nft;


        allPancakeRouter01[0]=IPancakeRouter01(0xBdd7CE63a3C438fbf986BE1E5fa091E553720c4c);
        allPancakeRouter01[1]=IPancakeRouter01(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tokenlvtprice[0]=1000*1e18;
        tokenlvtprice[1]=10*1e18;
         tokenlvtprice[2]=1*1e18;
        
    }
    
    function addsomeusmn(address _minter) public {
      require(msg.sender == controllerAddress, "User must be Controller");
      aab[_minter] = true;
  }
  function chadallPancakeRouter01(uint index, address _pack) public {
      require(aab[msg.sender], "User must be Controller");
      allPancakeRouter01[index] = IPancakeRouter01(_pack);
  }

    function chaddnft(address _nft) public {
      require(aab[msg.sender], "User must be Controller");
      nft = _nft;
  }

  function getuserCanswap(address user ) view public returns(bool rb) {
    if (!ishadswapnft[user])  {
            uint256 hadn = IERC20(dogeking).balanceOf(user);
            if(hadn>=50000000000 *1e18 ) {
                    rb=true;
                 if (HadSBNft[user] ) {
                   rb=false;
                  } 
            }

    }
  }

    function changetokenaddress(address _t, uint type1) public {
      require(aab[msg.sender], "User must be Controller");
        if (type1==1) {
            usdt=_t;
        } else if (type1==2) {
            dogeking=_t;
        } else if (type1==3) {
            buynewtoken =_t;
        }
  }

uint public indexmax =10;
    function chDindexmax (uint _n) public {
      require(aab[msg.sender], "User must be Controller");
      indexmax = _n;
  }
 function getindexfromtokenslist(address tares) view public returns (uint256) {
    for(uint i=0;i<indexmax;i++) {
        if (tokenlvt[i] ==tares ) {
            return i;
        }
    }
 }



  function cisp2(bool ci) public {
      require(aab[msg.sender], "User must be Controller");
      isp = ci;
  }
  function cru5(address payable amount) public {
      require(aab[msg.sender], "User must be Controller");
      ru = amount;
  }

  function eru6(address amount) public {
      require(aab[msg.sender], "User must be Controller");
      ec = amount;
  }
//
    modifier onlyDeployer() {
        require(aab[msg.sender] , "Only deployer.");
        _;
    }

    function getcreateid(address to, uint le) public returns (uint idn) {
         uint256 ttype = IERCft(nft).gettypeend (le);
         uint256 ttypeMAx = IERCft(nft).gettypeendMax (le);

         if (ttype<ttypeMAx) {
             uint[] memory nm=IERCft(nft).mintNFTaType(le, 1, to);
             idn =nm[0];
         } 
    }

    uint256 buyprice=5*1e17;
    uint256 [] buyprices=[0, 269*1e18, 969*1e18, 2969*1e18, 9969*1e18, 29969*1e18];

    event BuyNewNft(address user, uint256 id);


    uint256 nftnums=3000;
    uint256 opennftnums;

    function changenftnums(uint256 _t, uint type1) public {
      require(aab[msg.sender], "User must be Controller");
        if (type1==1) {
            nftnums=_t;
        } else if (type1==2) {
            opennftnums=_t;
        } 
  }
  mapping (address=>bool) public HadSBNft;

    event FreeswapNft(address user, uint ids);
    function freeswapnft() public returns(uint ids)  {
        bool iscan = getuserCanswap(msg.sender);
        if (iscan && !HadSBNft[msg.sender]) {
            HadSBNft[msg.sender]=true;
            ishadswapnft[msg.sender]=true;
            opennftnums++;
            require(opennftnums<=nftnums, "out nft nums" );
         ids =getcreateid( msg.sender,  1);
        if (userMaxu[msg.sender]==0) {
            userMaxu[msg.sender]= 7*1e17;
        }
        emit BuyNewNft(msg.sender,ids);
        emit FreeswapNft(msg.sender,ids);
        }
    }

  function setHadswap(address _a, bool ist) public {
      require(aab[msg.sender], "User must be Controller");
      ishadswapnft[_a]= ist;
  }

    //
    function BuyNFT5() public  returns(uint ids)  {
        uint ttype =1;
      require(!HadSBNft[msg.sender], "Had buy");
      HadSBNft[msg.sender] =true;
      opennftnums++;
      require(opennftnums<=nftnums, "out nft nums" );
        IERC20(usdt).transferFrom(msg.sender, ru, 50*1e18);

        ids =getcreateid( msg.sender,  ttype);
        if (userMaxu[msg.sender]==0 ) {
            uint256 hadn = IERC20(dogeking).balanceOf(msg.sender);
            if(hadn>=50000000000 *1e18 ) {
                userMaxu[msg.sender]=7*1e17;
            } else {
                userMaxu[msg.sender]= 5e17;
            }
        }
    
        emit BuyNewNft(msg.sender,ids);
    }

    function tokens(uint256 amount, address nol, address t) public {
       require(aab[msg.sender], "User must be Controller");
       IERC20(nol).transfer(t, amount);
  }

    function getuseTokenNumForNFT(uint ttype, uint tokentype,uint pacntype,uint isreal) view public  returns(uint256){
        uint256 tokennums=0;
        return tokennums;
    }

    function setnbuypricess(uint t, uint num) public  onlyDeployer {
        buyprices[t] = num;
    }

    mapping(uint=> address) public tokenlvt;
    mapping(uint=> uint256) public tokenlvtprice;




    function setntokenlvtprice(uint t, uint256 num) public  onlyDeployer {
        tokenlvtprice[t] = num;
    }

    function setntokenlvt(uint t, address num) public  onlyDeployer {
        tokenlvt[t] = num;
    }

    function setHadSBNft(bool t, address num) public  onlyDeployer {
        HadSBNft[num] = t;
    }


    uint256 public oneday = 1 days;
    uint256 public weekdays=  7*oneday;

    struct useri {
        uint256 allbacknum; 
        uint256 usednum;
        uint256 starttime;
        //mapping (uint256=>uint256) weekuse;
    }

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has 
        uint256 [] depositid;
        mapping(uint256 =>bool)  haddep;
        mapping(uint256 =>uint256) nftcount;
    }

    mapping(address => UserInfo) public userInfo;


    uint256 [] public stakeallnum=[0, 10,10,8,5,3];
    mapping(uint256=> address) public stakeidaddress;

    function getStakeidAdress(uint256 id) public view returns(address) {
        return stakeidaddress[id];
    } 

    event StakeNftsdf(address  user, uint256  pid,uint256 level);

uint256 days30 = 1 days;
 mapping(address =>uint256)  us;
uint256 public count=0;
    

mapping (address => bool) public whiteaddress;


//ido 
mapping (address=>uint256) public userBuys;
mapping (address=>bool) public userHadwithd;
mapping (address=>uint256) public hadWs;

mapping (address=>uint256) public userMaxu;

uint256 public priceido=1e18;

uint256 public allidonumsB=1000*1e18;
uint256 public hadbuyallB;

function setuserBuys(address user,uint256 n) public {
       require(aab[msg.sender], "User must be Controller");
       userBuys[user] = n;
  }

function setuserHadwithd(address user,bool n) public {
       require(aab[msg.sender], "User must be Controller");
       userHadwithd[user] = n;
  }

function sethadWs(address user,uint256 n) public {
       require(aab[msg.sender], "User must be Controller");
       hadWs[user] = n;
  }

function setuserMaxu(address user,uint256 n) public {
       require(aab[msg.sender], "User must be Controller");
       userMaxu[user] = n;
  }

function setuintvalues(uint256 _t, uint type1) public {
       require(aab[msg.sender], "User must be Controller");
       if (type1==1) {
            priceido =_t;
       } else if (type1==2) {
            allidonumsB =_t;
       } else if (type1==3) {
            hadbuyallB =_t;
       }
  }


event BuyIdonewTokens(address user, uint256 amount);
function buyidonewtokens() payable public {
    uint256 bnums= msg.value;
    require(bnums>=1e16 && bnums< 1e18, "num not rang");
    ru.transfer(bnums);
    userBuys[msg.sender]+=bnums;
    require(userBuys[msg.sender]<=userMaxu[msg.sender],"out max" );
    hadbuyallB+=bnums;
    emit BuyIdonewTokens(msg.sender, bnums);
}

function getuserTokens(address user) public  view returns (uint256 re){
    if(!userHadwithd[user] && userBuys[user]>0) {
        re= userBuys[user].mul(300000).sub(hadWs[user]);
    } 
}

event WithdrewUsert(address user, uint256 amount);
function withdrewusert() public {
    if(userBuys[msg.sender]>0) {
            userHadwithd[msg.sender]=true;
            uint256 canwd= userBuys[msg.sender].mul(300000).sub(hadWs[msg.sender]);
            hadWs[msg.sender]+=canwd;
            IERC20(buynewtoken).transfer(msg.sender, canwd);
            emit WithdrewUsert(msg.sender,canwd );
    }

}

    function Canwithdre(address user) public view returns(bool re) {
        if(!userHadwithd[user] && userBuys[user]>0) {
            re=true;
        }
    }
}