/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: Unlicensed


pragma solidity ^0.8.0;


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


    contract VitaPool {
        using SafeMath for uint256;

        uint256 constant public TIME_STEP = 1 days;
        address public _burnAddress = 0x000000000000000000000000000000000000dEaD;
        address public _owner;
        uint256 public _startTime;
        uint256 public GtokenUserCount;
        uint256 public totalwithdrawshareVita;
        uint256 public totalwithdrawshareUSDT;
        uint256 public sharePoolWithdrawType;
        address public vitacoinAddr;
        address public UsdtCoinAddr;
        tokenInterFace vitaToken;
        tokenInterFace UsdtToken;
        struct SharePool {
            uint256 checkpoint;
            uint256 bonus;
            uint256 GtokenUserCount;
            uint256 cointype;
            uint256 sharetype;
            uint256 totalVita;
            uint256 totalUSDT;
        }
        mapping(address => uint256) public SharePoint;
        SharePool[] public sharePools;

        mapping(address => bool) private _whiteList;
        mapping(address => address) public Referrers;
        mapping(address => bool) public gtokeUsers;
        event newGtokeUser(address indexed user);
		event WithdrawnShareVita(address indexed user, uint256 amount);
        event WithdrawnShareUSDT(address indexed user, uint256 amount);
    
        constructor(){
            _owner = msg.sender;
            _startTime =  block.timestamp;
            sharePoolWithdrawType=0;
        }
        receive() external payable {}

        function sharePoolsWithdraw() public {
            require(gtokeUsers[msg.sender]==true, "only GToken user Withdraw");
            uint256 sharePoint=SharePoint[msg.sender];
            uint256 sharePoolsLength=sharePools.length;
            uint256 totalVita;
            uint256 totalUSDT;
            if(sharePoolWithdrawType==0){
                (totalVita,totalUSDT)=sharePoolsCanWithdraw(msg.sender,sharePoint,sharePoolsLength);
            }
            else{
                (totalVita,totalUSDT)=sharePoolsCanWithdraw2(msg.sender,sharePoint,sharePoolsLength);
            }
            require(totalVita > 0 || totalUSDT>0, "User has no dividends");
            if(totalVita>0){
                require(vitaToken.balanceOf(address(this))>=totalVita , "no enough token");
                vitaToken.transfer(msg.sender, totalVita);
                emit WithdrawnShareVita(msg.sender, totalVita);
                totalwithdrawshareVita=totalwithdrawshareVita+totalVita;
            }
            if(totalUSDT>0){
                require(UsdtToken.balanceOf(address(this))>=totalUSDT , "no enough token");
                UsdtToken.transfer(msg.sender, totalUSDT);
                emit WithdrawnShareUSDT(msg.sender, totalUSDT);
                totalwithdrawshareUSDT=totalwithdrawshareUSDT+totalUSDT;

            }
            SharePoint[msg.sender]=sharePoolsLength;
        }

        function sharePoolsCanWithdraw(address userAddress,uint256 sharePoint,uint256 sharePoolsLength) public view returns(uint256,uint256){   
            if(gtokeUsers[userAddress]==false){
                return (0,0);
            }
            uint256 rate=1;
            uint256 totalVita;
            uint256 totalUSDT;
            for(uint256 i=sharePoint;i<sharePoolsLength;i++){
                SharePool memory sharepool=sharePools[i];               
                uint256 totaluser=sharepool.GtokenUserCount;
                if(totaluser>0){
                    uint256 dividends=sharepool.bonus*rate/totaluser;
                    if(sharepool.cointype==0){
                        totalVita=totalVita+dividends;
                    }else{
                        totalUSDT=totalUSDT+dividends;
                    }
                }                
            }
            return (totalVita,totalUSDT);
       }


        function sharePoolsCanWithdraw2(address userAddress,uint256 sharePoint,uint256 sharePoolsLength) public view returns(uint256,uint256){   
            if(gtokeUsers[userAddress]==false){
                return (0,0);
            }
            uint256 rate=1;
            uint256 totalVita;
            uint256 totalUSDT;
            sharePoolsLength=(sharePoolsLength>sharePools.length)?sharePools.length:sharePoolsLength;
            if(sharePoolsLength<=sharePoint)return (0,0);
            SharePool memory sharepool1=sharePools[sharePoolsLength-1];
            SharePool memory sharepool2=sharePools[sharePoint];
            uint256  totaluser1=sharepool1.GtokenUserCount;
            uint256  totaluser2=sharepool2.GtokenUserCount;
            uint256  totaluser=(totaluser2+totaluser1)/2;
            if(totaluser>0){
                totalVita=(sharepool1.totalVita-sharepool2.totalVita)*rate/totaluser;
                totalUSDT=(sharepool1.totalUSDT-sharepool2.totalUSDT)*rate/totaluser;
            }  
            return (totalVita,totalUSDT);
        }

        function setwhiteList(address addr,bool value) public returns (bool) {
            if(msg.sender == _owner){
                 _whiteList[addr] = value;
            }
            return true;
        }

        function getwhiteList(address addr) public view returns (bool){
                if(msg.sender == _owner){
                    return _whiteList[addr] ;
                }
                return true;
        }

        function setSharePoint(address addr,uint256 value) public returns (bool) {
            if(msg.sender == _owner){
                 SharePoint[addr] = value;
            }
            return true;
        }
  
        function getSharePoolsCount() public view returns (uint256){
                return sharePools.length;
         }

        function setgtokeUsers(address addr,bool flag) public returns (bool){
            if(msg.sender == _owner||_whiteList[msg.sender]==true){
                if(gtokeUsers[addr]==flag)
                {
                    return true;
                }
                gtokeUsers[addr]=flag;
                if(flag==true){
                    GtokenUserCount=GtokenUserCount+1;
                    SharePoint[addr]=sharePools.length;
                    emit newGtokeUser(addr);
                }else{
                    GtokenUserCount=GtokenUserCount-1;
                }

            }
            return true;
        }

        function addSharePools(uint256 amount,uint256 cointype,uint256 sharetype) public  returns(bool){
            if(msg.sender == _owner||_whiteList[msg.sender]==true){
                SharePool memory sharePool=sharePools[sharePools.length-1];
                uint256 totalVita=sharePool.totalVita+(cointype==0?amount:0);
                uint256 totalUSDT=sharePool.totalUSDT+(cointype==1?amount:0);
                sharePools.push(SharePool(block.timestamp,amount,GtokenUserCount,cointype,sharetype,totalVita,totalUSDT));
            }
            return true;
        }

        function userSetReferrer(address referrer) public returns (bool) {
            if(Referrers[msg.sender ]==address(0)&&Referrers[referrer]!=address(0)){
                    Referrers[msg.sender ]=referrer;
            }
            return true;
        }

        function setReferrer(address addr,address referrer) public returns (bool) {
            if(msg.sender == _owner||_whiteList[msg.sender]==true){
                    Referrers[addr] = referrer;
            }
            return true;
        }

        function getUserReferrer(address userAddress) public view returns(address) {
		    return Referrers[userAddress];
	    }
        
        function bindUsdtCoinAddress(address coinAddr) public returns (bool){
            if(msg.sender == _owner){

                UsdtCoinAddr=coinAddr;
                UsdtToken = tokenInterFace(UsdtCoinAddr);
 
            }
            return true;
        }
        function bindCoinAddress(address coinAddr) public returns (bool){
            if(msg.sender == _owner){

                vitacoinAddr=coinAddr;
                vitaToken = tokenInterFace(vitacoinAddr);
 
            }
            return true;
        }
        function bindOwner(address addressOwner) public returns (bool){
            if(msg.sender == _owner){
                _owner = addressOwner;
            }
            return true;
        }

        function remove_Random_Tokens(address random_Token_Address, uint256 percent_of_Tokens) public returns(bool ){
           if(msg.sender == _owner){
            require(random_Token_Address != address(this), "Can not remove native token");
            uint256 totalRandom = IERC20(random_Token_Address).balanceOf(address(this));
            uint256 removeRandom = totalRandom*percent_of_Tokens/100;
            bool _sent = IERC20(random_Token_Address).transfer(_owner, removeRandom);
            return _sent;
           }
           return true;
        }
    } 
       
    interface tokenInterFace {
       function transfer(address to, uint value) external returns (bool);
       function transferFrom(address from, address to, uint value) external returns (bool);
       function balanceOf(address who) external view returns (uint);
       function approve(address spender, uint256 amount) external  returns (bool);
    }

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}