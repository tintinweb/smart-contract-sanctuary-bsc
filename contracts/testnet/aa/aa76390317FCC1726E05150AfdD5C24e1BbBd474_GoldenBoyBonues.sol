/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: Unlicensed

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



pragma solidity ^0.8.0;


    contract GoldenBoyBonues{
        using SafeMath for uint256;
        uint256 constant public TIME_STEP = 1 days;
        uint256 constant public HALF_YEAR = 180 days;
        uint256 constant public ONE_YEAR = 365 days;
        address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 
        address public  Wallet_Market=0xa245fc74FA5759e9744b3b3011afa5f45A865dcD; 
        address public  Wallet_Project=0x36f2dAE586cC46fA9fbfe10DdadBbBbfFd178AD8; 
    address public  Wallet_GboyPool; 
    
         address private _gldycoinAddr;
        address private _subycoinAddr;
        address private _owner;
        uint256 private _beginTime;
        uint256 private totalWithdrawn;
         uint256 private  halfYearTime ;
       
        uint256 private GldyProjectBonus;
        uint256 private GldyPrivatetBonus;
        uint256 private projectwithdrawtime;
        uint256 private  projecttotalwithdraw;
        uint256 private   totalPrivateWithdraw;
        uint256 private  Privatewithdrawtime;
        uint256 private  SubyProjectBonus;
        uint256 private  SubyProjectBonusWithDraw;

        uint256 private  SubyGtokenBonus;

        uint256 private  SubyPrivateBonus;
        uint256 private  SubyPrivateBonusWithDraw;

        uint256 private  SubyBonusStartTime;
        bool private SubyBonusCanWithdraw;
        bool private _iscanCandy;
        mapping(address => uint256) public SubyGtokenBonusWithdrawTime;
        mapping(address => uint256) public SubyGtokenBonusTotalWithDraw;
         
        uint256 public  totalCandyUsers;
 
        struct CandyUser {
           uint256 start;
            uint256 amount;
            uint256 recommendamount;
            uint256 unlockamount;
            uint256 checkpoint;
            uint256 withdrawn;
        }

        struct SharePool {
            uint256 checkpoint;
            uint256 bonus;
            uint256 PrivateUserCount;
            uint256 GtokenUserCount;
            uint256 cointype;

        }
        mapping(address => uint256) private SharePoint;
        SharePool[] public sharePools;
       
        mapping(address => CandyUser) public CandyUsers;
        mapping(address => bool) private _whiteList;
        tokenInterFace GldyToken;
        tokenInterFace SubyToken;
        poolInterFace GBoyPool;
        event CandyWithdrawn(address indexed user, uint256 amount);
        event NewCandy(address indexed user,address referrer);
        event CandyUnlock(address indexed user,uint256 amount);
        event privatewithdraw(address indexed user,uint256 amount);
        event ProjectWithdraw(address indexed user,uint256 amount);

        constructor()   {
            _owner = msg.sender;
            _beginTime = block.timestamp;//开始释放时间
            halfYearTime=block.timestamp+HALF_YEAR;
            GldyProjectBonus =200000000*  10 ** 18;
            GldyPrivatetBonus=1500000000*  10 ** 18;

            SubyProjectBonus=1000000* 10 ** 18;//技术
            SubyGtokenBonus=2000000* 10 ** 18;//令牌
            SubyPrivateBonus=1000000* 10 ** 18;//私募
             _iscanCandy=true;
            
        

        }
        receive() external payable {}

        //有BNB共享池还有母币共享池
    function sharePoolsWithdraw(address userAddress) public {
        require(GBoyPool.gtokeUsers(msg.sender)==true, "only GToken user Withdraw");
        uint256 rate=1;
        if(GBoyPool.Level(userAddress)==2){
            rate=rate+10;
        }
        uint256 totaluser;
        uint256 dividends;
        uint256 totalGldy;
        uint256 totalBNB;
         
        for(uint256 i=SharePoint[userAddress];i<sharePools.length;i++){
            totaluser=sharePools[i].PrivateUserCount*10+sharePools[i].GtokenUserCount;
            if(totaluser>0){
                dividends=sharePools[i].bonus*rate/totaluser;
                if(sharePools[i].cointype==0){
                    totalGldy=totalGldy+dividends;
                }else{
                    totalBNB=totalBNB+dividends;
                }
            }
            
        }
        require(totalGldy > 0 || totalBNB>0);
        if(totalGldy>0){
            require(GldyToken.balanceOf(address(this))>=totalGldy , "User has no dividends");
            GldyToken.transfer(userAddress, totalGldy);
        }
        if(totalBNB>0){
            payable(userAddress).transfer(totalBNB);
        }
        SharePoint[userAddress]=sharePools.length;
    
    }

    function addSharePools(uint256 GtokenUserCount,uint256 amount,address useraddr,uint256 cointype) public  returns(bool){
        if(msg.sender == _owner||_whiteList[msg.sender]==true){
            uint256 PrivateUserCount=GBoyPool.PrivateUserCount();
            sharePools.push(SharePool(block.timestamp,amount,PrivateUserCount,GtokenUserCount,cointype));
            if(useraddr!=address(0)){
                SharePoint[useraddr]=sharePools.length;
            }
           
        }
        return true;
       
    }


    function sharePoolsCanWithdraw(address userAddress) public view returns(uint256,uint256){   
        if(GBoyPool.gtokeUsers(msg.sender)==false){
            return (0,0);
        }
        uint256 rate=1;
        if(GBoyPool.Level(userAddress)==2){
            rate=rate+10;
        }
        uint256 totaluser;
        uint256 dividends;
        uint256 totalGldy;
        uint256 totalBNB;
         
        for(uint256 i=SharePoint[userAddress];i<sharePools.length;i++){
            totaluser=sharePools[i].PrivateUserCount*10+sharePools[i].GtokenUserCount;
            if(totaluser>0){
                dividends=sharePools[i].bonus*rate/totaluser;
                if(sharePools[i].cointype==0){
                    totalGldy=totalGldy+dividends;
                }else{
                    totalBNB=totalBNB+dividends;
                }
            }
        }

        return (totalGldy,totalBNB);
    }



        function Candy(address referrer) public   returns (bool){
            require(_iscanCandy == true, "It's not Candy");
            require( block.timestamp>_beginTime , "It's not startTime1");
             (,uint256 amount ,)= GBoyPool.CandyUsers(msg.sender) ;
            CandyUser  storage user=CandyUsers[msg.sender];
            require(user.amount == 0&& amount == 0);
            require(totalCandyUsers+GBoyPool.totalCandyUsers() < 100000);
            if (GBoyPool.Referrers(msg.sender) == address(0)  && referrer != msg.sender) {
                GBoyPool.setReferrer(msg.sender,referrer);
             }

            address ref=GBoyPool.Referrers(msg.sender) ;
            require(ref != address(0));
            require(GBoyPool.Referrers(ref) != address(0)||ref==_owner);

            user.start = block.timestamp;
            user.amount=3000 ;
            totalCandyUsers = totalCandyUsers.add(1);
            CandyUsers[ref].recommendamount=CandyUsers[ref].recommendamount.add(1500);
            emit NewCandy(msg.sender, referrer);
            return true;
        } 

        //空投解锁。三分之一空投量，母币直接销毁
        function candyUnlock() public{
            (,uint256 amount ,uint256 recommendamount)= GBoyPool.CandyUsers(msg.sender) ;
            CandyUser  storage user=CandyUsers[msg.sender];
            require(block.timestamp > _beginTime);
            uint256 totalamount=amount+recommendamount+user.amount+user.recommendamount;
            uint unlockamount=totalamount/3*10**18-user.unlockamount;
            require(unlockamount>0);
            uint balances = GldyToken.balanceOf(msg.sender);
            require(balances>=unlockamount, "It's not enough  Token");
            require( GldyToken.transferFrom(msg.sender,Wallet_Burn, unlockamount),"token transfer failed");
            if(user.unlockamount==0)user.checkpoint=block.timestamp;
            user.unlockamount= user.unlockamount+unlockamount;
            emit CandyUnlock(msg.sender, unlockamount);
            
       
        }
        function candyWithDraw() public{
            (,uint256 amount ,uint256 recommendamount)= GBoyPool.CandyUsers(msg.sender) ;
            CandyUser storage user=CandyUsers[msg.sender];
            require(block.timestamp > _beginTime);
            uint256 totalamount=(amount+recommendamount+user.amount+user.recommendamount)*10**18;
            require(user.unlockamount>0," unlock first");
            require(totalamount>0);
            uint256 dividends;
            require(user.withdrawn  < totalamount);
        
		    dividends = (totalamount.div(30))
						.mul(block.timestamp.sub(user.checkpoint))
						.div(TIME_STEP);
            
			if (user.withdrawn.add(dividends) > totalamount) {
					dividends = totalamount.sub(user.withdrawn);
			}
            if (user.withdrawn.add(dividends) > user.unlockamount.mul(3)) {
					dividends = user.unlockamount.mul(3).sub(user.withdrawn);
			}

			user.withdrawn = user.withdrawn.add(dividends); /// changing of storage data

            require(dividends > 0, "User has no dividends");
            require(GldyToken.balanceOf(address(this))>=dividends, "User has no dividends");
            GldyToken.transfer(msg.sender, dividends);
            user.checkpoint = block.timestamp;
            totalWithdrawn = totalWithdrawn.add(dividends);
            
            emit CandyWithdrawn(msg.sender, dividends);  
            
        }
        function CandyCanWithDraw() public view returns(uint256){
            (,uint256 amount ,uint256 recommendamount)= GBoyPool.CandyUsers(msg.sender) ;
            CandyUser memory user=CandyUsers[msg.sender];
            uint256 totalamount=(amount+recommendamount+user.amount+user.recommendamount)*10**18;
            uint256 dividends;
            if(block.timestamp <= _beginTime)return 0;
            if(user.unlockamount==0)return 0;
            
		    dividends = (totalamount.div(30))
						.mul(block.timestamp.sub(user.checkpoint))
						.div(TIME_STEP);
            
			if (user.withdrawn.add(dividends) > totalamount) {
					dividends = totalamount.sub(user.withdrawn);
			}
            if (user.withdrawn.add(dividends) > user.unlockamount.mul(3)) {
					dividends = user.unlockamount.mul(3).sub(user.withdrawn);
			}
            return dividends;
            
        }

        function SubyProjectBonusWithdraw() public {
            require(SubyBonusCanWithdraw ==true);
            require(SubyBonusStartTime <block.timestamp);
             uint256 dividends;
             uint256 totalAmount;
            require(msg.sender==Wallet_Project);
            dividends=SubyProjectBonus.mul(block.timestamp.sub(SubyBonusStartTime)).div(ONE_YEAR);
            totalAmount=dividends-SubyProjectBonusWithDraw;
            if(SubyProjectBonusWithDraw+totalAmount>SubyProjectBonus)totalAmount=SubyProjectBonus-SubyProjectBonusWithDraw;
            SubyProjectBonusWithDraw=SubyProjectBonusWithDraw+totalAmount;
            require(SubyToken.balanceOf(address(this))>=totalAmount , "User has no dividends");
            SubyToken.transfer(msg.sender, totalAmount);
            
        }

        function SubyPrivateBonusWithdraw() public {
            require(SubyBonusCanWithdraw ==true);
            require(SubyBonusStartTime <block.timestamp);
             uint256 dividends;
             uint256 totalAmount;
            require(msg.sender==Wallet_Market);
            dividends=SubyPrivateBonus.mul(block.timestamp.sub(SubyBonusStartTime)).div(ONE_YEAR);
            totalAmount=dividends-SubyPrivateBonusWithDraw;
            if(SubyPrivateBonusWithDraw.add(totalAmount)>SubyPrivateBonus)totalAmount=SubyPrivateBonus.sub(SubyPrivateBonusWithDraw);
            SubyPrivateBonusWithDraw=SubyPrivateBonusWithDraw.add(totalAmount);
            require(SubyToken.balanceOf(address(this))>=totalAmount , "User has no dividends");
            SubyToken.transfer(msg.sender, totalAmount);
        }



        function SubyGtokenBonusWithdraw() public {
            require(SubyBonusCanWithdraw ==true);
            require(SubyBonusStartTime <block.timestamp);
            //require(SubyBonusStartTime+ONE_YEAR > block.timestamp);
             uint256 dividends;
             uint256 totalAmount;
            require(GBoyPool.gtokeUsers(msg.sender)==true, "only GToken user Withdraw");
            
             dividends=SubyGtokenBonus.mul(block.timestamp.sub(SubyBonusStartTime)).div(ONE_YEAR).div(20000);
            if(dividends>SubyGtokenBonus.div(20000)) {
                dividends=SubyGtokenBonus.div(20000);
            }
            totalAmount=dividends.sub(SubyGtokenBonusWithdrawTime[msg.sender]);
            
            SubyGtokenBonusWithdrawTime[msg.sender]=SubyGtokenBonusWithdrawTime[msg.sender].add(totalAmount);
            require(SubyToken.balanceOf(address(this))>=totalAmount , "User has no dividends");
            SubyToken.transfer(msg.sender, totalAmount);


        }

    //先期总共总量的%，其余的分一年，到销毁50后，需提一次后才开始释放。
    //总量每销毁5亿，释放5000万,销毁50亿后，12个月线性释放20+N提现

    function Privatewithdraw() public {
            require(msg.sender==Wallet_Market||msg.sender==_owner);
            uint256 burnamount=GldyToken.balanceOf(Wallet_Burn);
            uint256 burnrate=burnamount.div(500000000*10**18);
            uint256 CanWithdraw;
            if(burnrate<=10){
                uint256 totalCanWithdraw=burnrate*50000000*10**18;
                CanWithdraw=totalCanWithdraw-totalPrivateWithdraw;
            }else{
                uint256 release1=GldyPrivatetBonus.sub(500000000*10**18);
                uint256 dividends;
                if(Privatewithdrawtime> 0){
                    dividends=GldyPrivatetBonus.sub(release1).mul(block.timestamp.sub(Privatewithdrawtime)).div(HALF_YEAR*2);
                }
                else{
                    dividends=0;
                }
                CanWithdraw=release1+dividends-totalPrivateWithdraw;
            }
            if(burnrate>=50&&Privatewithdrawtime==0){
                Privatewithdrawtime=block.timestamp;
            }
            if(totalPrivateWithdraw+CanWithdraw>GldyPrivatetBonus)CanWithdraw=GldyPrivatetBonus-totalPrivateWithdraw;
            totalPrivateWithdraw=totalPrivateWithdraw+CanWithdraw;
            require(GldyToken.balanceOf(address(this))>=CanWithdraw , "User has no dividends");
             GldyToken.transfer(Wallet_Market, CanWithdraw);

            emit privatewithdraw(Wallet_Market, CanWithdraw);
         

    }


    function projectwithdraw() public {
            require(msg.sender==Wallet_Project||msg.sender==_owner);
            require(block.timestamp > halfYearTime);
            uint256 dividends;
            if(projectwithdrawtime> halfYearTime){
                dividends=GldyProjectBonus.mul(block.timestamp.sub(projectwithdrawtime)).div(HALF_YEAR);
            }
            else{
                dividends=GldyProjectBonus.mul(block.timestamp.sub(halfYearTime)).div(HALF_YEAR);
            }
            if(projecttotalwithdraw+dividends>GldyProjectBonus)dividends=GldyProjectBonus-projecttotalwithdraw;
            projecttotalwithdraw=projecttotalwithdraw+dividends;
            require(GldyToken.balanceOf(address(this))>=dividends , "User has no dividends");
             GldyToken.transfer(Wallet_Project, dividends);
             projectwithdrawtime=block.timestamp ;
            emit ProjectWithdraw(Wallet_Project, dividends);
         

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
    

         function setSubyBonusStatus(bool status,uint256 value) public returns (bool) {
            if(msg.sender == _owner||_whiteList[msg.sender]==true){
                SubyBonusCanWithdraw=status;
                SubyBonusStartTime=value;
            }
            return true;
        }

        function setGBoyPoolAddress(address Wallet)  public {
             require(_owner == msg.sender);
            Wallet_GboyPool=Wallet;
            GBoyPool=poolInterFace(Wallet_GboyPool);
     }


         function sethalfYearTime(uint256 value) public returns (bool) {
            if(msg.sender == _owner){
                halfYearTime=value;
            }
            return true;
        }

    //各种参数的设置及读取

           
        function bindCoinAddress(address gldycoinAddr,address subycoinAddr) public returns (bool){
            if(msg.sender == _owner){

                _gldycoinAddr=gldycoinAddr;
                _subycoinAddr=subycoinAddr;
                GldyToken = tokenInterFace(_gldycoinAddr);
                SubyToken = tokenInterFace(subycoinAddr);


            }
            return true;
        }

        function setbeginTime(uint256 value) public returns (bool) {
            if(msg.sender == _owner){
                     _beginTime = value;
            }
            return true;
        }


        function bindMarketAddress(address Addr) public returns (bool){
            if(msg.sender == _owner){
                Wallet_Market=Addr;
            }
            return true;
        }

         function bindProjectAddress(address Addr) public returns (bool){
            if(msg.sender == _owner){
                Wallet_Project=Addr;
            }
            return true;
        }

    function setCanCandy(bool value) public returns (bool){
            if(msg.sender == _owner){
                _iscanCandy=value;
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

    interface  tokenInterFace {
       function burnFrom(address addr, uint value) external   returns (bool);
       function transfer(address to, uint value) external;
       function transferFrom(address from, address to, uint value) external returns (bool);
       function balanceOf(address who) external  returns (uint);
       function approve(address spender, uint256 amount) external  returns (bool);
    }

    interface  poolInterFace {
        function EndorsementUsers(address addr) external  view returns (uint256,uint256,uint256,bool);
        function CandyUsers(address addr) external view  returns (uint256,uint256,uint256);
        function Level(address addr) external  view returns (uint256);
        function PrivateUserCount() external view  returns (uint256);
        function totalCandyUsers() external view  returns (uint256);
        
        function Referrers(address addr) external view returns (address);
        function gtokeUsers(address addr) external  view returns (bool);
        function setReferrer(address addr,address referrer) external returns (bool);
        function setgtokeUsers(address addr,bool flag) external returns (bool);
        function getGtokenReferrer(address addr) external  view returns (address);
        function setLevel(address addr,uint32 value) external returns (bool);
    }