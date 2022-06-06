/**
 *Submitted for verification at BscScan.com on 2022-06-06
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
        
         IUniswapV2Router02 public uniswapV2Router;
        
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
            uint256 recommendamount;
            bool isCandy;
        }
        mapping(address => bool) private _whiteList;
        mapping(address => Endorsement) public EndorsementUsers;
        mapping(address => CandyUser) public CandyUsers;
        mapping(address => uint256) public Level;
        mapping(address => address) public Referrers;
        mapping(address => address[]) public endorseTeams;
        mapping(address => address[]) public candyTeams;
        mapping(address => uint256) public EndorsTeamsCount;
        mapping(address => uint256) public CandyTeamsCount;
        
        tokenInterFace GldyToken;
        event NewDeposit(address indexed user, uint256 amount);
        event Withdrawn(address indexed user, uint256 amount);
        event NewEndorseMent(address indexed user, uint256 amount);
        event NewCandy(address indexed user,address referrer);
        event userRedeem(address indexed user);
        
	
        constructor()   {
            _owner = msg.sender;
            _lastredeemTime =  block.timestamp;//       销毁时间12个月
            _startTime =  block.timestamp;//开始释放时间
            _beginredeemTime =  block.timestamp;//开始释放时间
            _iscanEndorse=true;
            _iscanCandy=true;
            //EndorsementMoney=3* 10 ** 17;
            EndorsementMoney=3* 10 ** 15;
            uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 
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
                endorseTeams[referrer].push(msg.sender);
            }
            require(Referrers[msg.sender] != address(0));
            //新增判断是否公募和空投
            
            address upline = Referrers[msg.sender];
             while(upline != address(0)){
                EndorsTeamsCount[upline]=EndorsTeamsCount[upline]+1;
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

        function Candy(address referrer) public   returns (bool){
            require(_iscanCandy == true, "It's not Candy");
            require( block.timestamp>_startTime , "It's not startTime1");
            require( block.timestamp<_beginredeemTime , "It's not startTime2");
            
            CandyUser storage user = CandyUsers[msg.sender];
            require(user.isCandy == false);
            require(totalCandyUsers < 100000);
            if (Referrers[msg.sender] == address(0)  && referrer != msg.sender) {
                Referrers[msg.sender] = referrer;
                candyTeams[referrer].push(msg.sender);
            }
            address upline = Referrers[msg.sender];
            while(upline != address(0)){
                CandyTeamsCount[upline]=CandyTeamsCount[upline]+1;
                upline = Referrers[upline];
			}

            user.checkpoint = block.timestamp;
            user.amount=user.amount.add(3000);
            totalCandyUsers = totalCandyUsers.add(1);
            user.isCandy=true;
            address refuser=Referrers[msg.sender] ;
            if(refuser!=address(0)){
                CandyUsers[refuser].recommendamount=CandyUsers[refuser].recommendamount.add(1500);
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
            require( GldyToken.transferFrom(msg.sender,_burnAddress, user.GLDYCoins),"token transfer failed");
            address payable useraddress = payable(msg.sender);
            useraddress.transfer(EndorsementMoney);
            emit userRedeem(msg.sender);
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

        function getendorseTeamsCount(address addr) public view returns (uint256){
                return endorseTeams[addr].length;
         }

        function getcandyTeamsCount(address addr) public view returns (uint256){
                return candyTeams[addr].length;
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

        function burnBNB(uint256 bnbAmount) public returns (bool) {
            if(msg.sender == _owner||_whiteList[msg.sender]==true){
                uint256 balance= address(this).balance;
                require(bnbAmount <=balance, "It's not enough BNB");
            
                if(block.timestamp > _lastredeemTime){
                    //address payable useraddress = payable(msg.sender);
                    //useraddress.transfer(balance);
                    swapBNBForTokens(_gldycoinAddr,bnbAmount);
                }
            }
            return true;
        }
        
  function swapBNBForTokens(address tokenaddress ,uint256 bnbAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = tokenaddress;
        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmount}(
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

 // Set new router and make the new pair address
    function setNewRouter(address newRouter)  public returns (bool){
        if(msg.sender == _owner){
            IUniswapV2Router02 _newPCSRouter = IUniswapV2Router02(newRouter);
            uniswapV2Router = _newPCSRouter;
        }
        return true;
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
       function transfer(address to, uint value) external returns (bool);
       function transferFrom(address from, address to, uint value) external returns (bool);
       function balanceOf(address who) external view returns (uint);
       function approve(address spender, uint256 amount) external  returns (bool);
    }


    

// pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}


// Dependency file: contracts/interfaces/IUniswapV2Router02.sol

// pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}



// Dependency file: contracts/interfaces/IUniswapV2Pair.sol

// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}