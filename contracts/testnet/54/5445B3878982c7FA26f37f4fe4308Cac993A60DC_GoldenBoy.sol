/**
 *Submitted for verification at BscScan.com on 2022-06-05
*/

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





    contract GoldenBoy {
        using SafeMath for uint256;

        uint256 constant public TIME_STEP = 1 days;
        address public _burnAddress = 0x000000000000000000000000000000000000dEaD;
        address private _gldycoinAddr;
        
        uint256 public EndorsementMoney;
        
        address private _owner;
        uint256 private _lastredeemTime;
        uint256 private _startTime;
        uint256 private _beginredeemTime;
        bool private _iscanEndorse;
        bool private _iscanCandy;
        
        uint256 public totalEndorsementUsers;
        uint256 public  totalEndorsed;
        uint256 public  totalCandyUsers;
        uint256 public   PrivateUserCount;
        
        struct Endorsement {
            uint256 amount;
            uint256 GLDYCoins;
            uint256 withdrawn;
            uint256 start;
            uint256 checkpoint;
            bool isredeem; //是否赎回
        }
 
        struct CandyUser {
           uint256 checkpoint;
            uint256 amount;
            uint256 withdrawn;
            uint256 teamamount;
            bool isCandy;
        }
        mapping(address => bool) private _whiteList;
        mapping(address => Endorsement) public EndorsementUsers;
        mapping(address => CandyUser) public CandyUsers;
        mapping(address => uint256) public Level;
        mapping(address => address) public Referrers;
        mapping(address => address[]) public Teams;
        mapping(address => uint256) public PrivateUserTeamsCount;
        
        tokenInterFace GldyToken;
        event NewDeposit(address indexed user, uint256 amount);
        event Withdrawn(address indexed user, uint256 amount);
        event NewEndorseMent(address indexed user, uint256 amount);
        event NewCandy(address indexed user,address referrer);
        
	
        constructor()   {
            _owner = msg.sender;
            //_gldycoinAddr=gldycoinAddr;
            // GldyToken = tokenInterFace(_gldycoinAddr);
            _lastredeemTime =  block.timestamp;//       销毁时间12个月
            _startTime =  block.timestamp;//开始释放时间
            _beginredeemTime =  block.timestamp;//开始释放时间
            _iscanEndorse=true;
            _iscanCandy=true;
            EndorsementMoney=3* 10 ** 17;
        }
        receive() external payable {}

        function Endorsing(address referrer) public payable  returns (bool){
            require(msg.value == EndorsementMoney, "It's not enough BNB");
            require(_iscanEndorse == true, "It's not Endorse");
            require( block.timestamp>_startTime , "It's not startTime1");
            require( block.timestamp<_beginredeemTime , "It's not startTime2");
            Endorsement storage user = EndorsementUsers[msg.sender];
            require(user.amount == 0);
            require(totalEndorsementUsers < 2700);
            if (Referrers[msg.sender] == address(0) && referrer != msg.sender) {
                Referrers[msg.sender] = referrer;
                Teams[referrer].push(msg.sender);
            }
            require(Referrers[msg.sender] != address(0));
            
            address upline = Referrers[msg.sender];
             while(upline != address(0)){
                if(Level[upline]==2){
                    PrivateUserTeamsCount[upline]=PrivateUserTeamsCount[upline]+1;
                    break;
                }
                upline = Referrers[upline];
			}
            user.start = block.timestamp;
            user.checkpoint = block.timestamp;
            user.GLDYCoins=1500000 * 10 ** 18;
            user.amount=EndorsementMoney;
            totalEndorsementUsers = totalEndorsementUsers.add(1);
            totalEndorsed = totalEndorsed.add(msg.value);
            
            emit NewEndorseMent(msg.sender, msg.value);

            return true;
        }  
        //一年后的BNB销毁
        //销毁到40.5亿后，开始把多余的BNB注入底池
        //L2玩家统计公募数量不能大于100

        //公募不够，停止项目：缺
        function Candy(address referrer) public   returns (bool){
            require(_iscanCandy == true, "It's not Candy");
            require( block.timestamp>_startTime , "It's not startTime1");
            require( block.timestamp<_beginredeemTime , "It's not startTime2");
            
            CandyUser storage user = CandyUsers[msg.sender];
            require(user.isCandy == false);
            require(totalCandyUsers < 100000);
            if (Referrers[msg.sender] == address(0)  && referrer != msg.sender) {
                Referrers[msg.sender] = referrer;
                Teams[referrer].push(msg.sender);
            }
            user.checkpoint = block.timestamp;
            user.amount=user.amount.add(3000);
            totalCandyUsers = totalCandyUsers.add(1);
            user.isCandy=true;
            address refuser=Referrers[msg.sender] ;
            if(refuser!=address(0)){
                CandyUsers[refuser].amount=CandyUsers[refuser].amount.add(1500);
           }
            emit NewCandy(msg.sender, referrer);
            return true;
        } 


 
        function redeem() public  returns (bool)  {
            Endorsement storage user = EndorsementUsers[msg.sender];
		    require(user.isredeem == false, "It's not redeem");
            require(user.amount > 0, "It's not redeem");
            require(block.timestamp > _beginredeemTime);
            require(block.timestamp < _lastredeemTime);
            user.isredeem = true;
            user.amount=0;
            require( GldyToken.transferFrom(msg.sender,address(this), user.GLDYCoins),"token transfer failed");
            address payable useraddress = payable(msg.sender);
            //msg.sender.transfer(EndorsementMoney);
            useraddress.transfer(EndorsementMoney);
           // emit NewEndorseMent(msg.sender, msg.value);
           return true;
        }   

        function burnBNB() public returns (bool) {
            if(msg.sender == _owner||_whiteList[msg.sender]==true){
                uint256 balance= address(this).balance;
                if(block.timestamp > _lastredeemTime){
                    address payable useraddress = payable(msg.sender);
                    useraddress.transfer(balance);
                }
            }
            return true;
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
        function setLevel(address addr,uint32 value) public returns (bool) {
            if(msg.sender == _owner||_whiteList[msg.sender]==true){
                    if(Level[addr]<2&&value==2){
                        PrivateUserCount=PrivateUserCount+1;
                    }else if(Level[addr]==2&&value<2){
                        PrivateUserCount=PrivateUserCount-1;
                    }
                    Level[addr] = value;
            }
            return true;
        }

        function setbeginTime(uint256 value) public returns (bool) {
            if(msg.sender == _owner){
                     _beginredeemTime = value;
            }
            return true;
        }

        function setstartTime(uint256 value) public returns (bool) {
            if(msg.sender == _owner){
                     _startTime = value;
            }
            return true;
        }

        function setlastTime(uint256 value) public returns (bool) {
            if(msg.sender == _owner){
                     _lastredeemTime = value;
            }
            return true;
        }
        function getbeginTime() public view returns (uint256){
                return _beginredeemTime;
         }
         function getlastTime() public view returns (uint256){
                return _lastredeemTime;
         }
          function getstartTime() public view returns (uint256){
                return _startTime;
         }


        function setReferrer(address addr,address referrer) public returns (bool) {
            if(msg.sender == _owner||_whiteList[msg.sender]==true){
                    Referrers[addr] = referrer;
            }
            return true;
        }


       function setcanEndorse(bool flag) public returns (bool){
            if(msg.sender == _owner){
                _iscanEndorse=flag;
            }
            return true;
        }

        function setcanCandy(bool flag) public returns (bool){
            if(msg.sender == _owner){
                _iscanCandy=flag;
            }
            return true;
        }


        function getGtokenReferrer(address addr) public view returns (address){
            address upline = Referrers[addr];
             while(upline != address(0)){
                if(Level[upline]>0){
                    return upline;
                }
                upline = Referrers[upline];
			}
            return address(0);
         }

        function getUserReferrer(address userAddress) public view returns(address) {
		    return Referrers[userAddress];
	    }
        
        function getcanEndorse() public view returns (bool){
                return _iscanEndorse;
         }

         function getcanCandy() public view returns (bool){
                return _iscanCandy;
         }

            
        function bindCoinAddress(address gldycoinAddr) public returns (bool){
            if(msg.sender == _owner){

                _gldycoinAddr=gldycoinAddr;
                GldyToken = tokenInterFace(_gldycoinAddr);
 
            }
            return true;
        }
        function bindOwner(address addressOwner) public returns (bool){
            if(msg.sender == _owner){
                _owner = addressOwner;
            }
            return true;
        }

    } 
       



    interface tokenInterFace {
       function burnFrom(address addr, uint value)  external    returns (bool);
       function transfer(address to, uint value) external returns (bool);
       function transferFrom(address from, address to, uint value) external returns (bool);
       function balanceOf(address who) external view returns (uint);
       function approve(address spender, uint256 amount) external  returns (bool);
    }