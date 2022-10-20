/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        unchecked {
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
        unchecked {
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: contract/Defi33.sol



pragma solidity ^0.8.0;



struct user{
        address userid;
        address pid;
        uint256 layerAll;
        uint256 zhiLp;
        uint256 lpall;
        uint256 lockNum;
        uint256 unLockNum;
        uint256 lastTime;
        uint256 rank;
        bool isMore50;
        bool isPro;
    }

interface Daov1{
    function getChildren(address _address) external view returns(user[] memory);
    function userInfo (address) view external returns (user memory);
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    //   mapping (address => user) public userInfo;
    //   mapping (address => uint) public colDayBonus;
    //   mapping (address => address[]) public userPath;
}

struct pledgeRecordv2{
        uint lp;
        uint usdt;
        uint token;
        uint lastTime;
    }

interface Daov2{
    function getPledgeRecordInfov2(address qaddress) external view returns(pledgeRecordv2 memory);
}

interface Token20{      
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function decimals() external view returns (uint256);
    function name() external view returns (string memory);
    function approve(address spender, uint256 amount) external returns (bool);
}

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



contract  Defi3  is  Ownable  {
    using SafeMath for uint256;

    Daov1 fire;
    Daov2 firev2;
    Token20 usdt;
    IUniswapV2Pair  uniswapV2Pair;
    address usdtAddress;
    address deadAddress;
    address topAddress;
    
    uint[4][3] per =[[1140,1300,1800,3600],[1180,1400,2000,4500],[1220,1500,2200,5000]];
    uint[5] ji=[0,200,250,300,400];
    uint allBurnFire;
    uint allBurnUsdt;
    uint waitTime = 24*60*60;

    constructor(){
        fire=Daov1(0xF8c13eBDD4E7a78603ECA2c3043E4761D93074b1);
        firev2=Daov2(0x124cDc0A402078cF9aBFBA1a3A86B0dFcB37A079);
        usdt=Token20(0x55d398326f99059fF775485246999027B3197955);
        uniswapV2Pair=IUniswapV2Pair(0x9fFBF72E7aE0B1AfEC3Bb45Ce9804E216D226E3F);
        usdtAddress=0x55d398326f99059fF775485246999027B3197955;
        deadAddress=0x0000000000000000000000000000000000000001;
        topAddress = 0x859606D8598b59f3895AAb3103CE25D8d7758BEd;
        
    }

    struct record {
        uint256 usdt;
        uint256 fire;
        uint256 backUsdt;
        uint256 day;
        uint256 lastTime;
        uint256 state;
    }

    mapping (address => record) private recordByAddress;
    // mapping (address => bool) private isNode;
    // mapping (address => bool) private isPartner;
    mapping (address => uint) private level;
    mapping (address => uint) private teamUsdt;

    // mapping (address => uint) private allIn;

    mapping (address => uint) private nft3;
    mapping (address => uint) private nft4;
    mapping (address => uint) private nft5;
   
    mapping (address => uint) private dBalance;
    mapping (address => uint) private dallCol; 
    mapping (address => uint) private lastColTime;
   
    event log(address indexed userid,uint lastTime,uint classes, uint num);
    // address[] nodes;
    // address[] partners;

   

    function pledge(uint usdtNum,uint day) external {
        
        require(fire.userInfo(msg.sender).userid!=address(0),"A");
        require(day==7 || day==15 || day==30 || day==90 ,"B");
        require(usdtNum>=100 ether,"C");
        //require(recordByAddress[msg.sender].state==1 || recordByAddress[msg.sender].usdt==0 ,"D");
        require(recordByAddress[msg.sender].usdt==0 ,"D");
        uint fireNum =u2token(usdtNum); 
        fire.transferFrom(msg.sender, address(this), fireNum);
        fire.transfer(deadAddress, fireNum);
        //fire.transfer(msg.sender, fireNum);//re
        allBurnFire+=fireNum;
        allBurnUsdt+=usdtNum;
        // allIn[msg.sender]+=usdtNum;

        uint backUsdt = usdtNum.mul(getPerIndex(usdtNum,day)).div(1000);

        uint jiNum = u2token(backUsdt.sub(usdtNum)); 
        recordByAddress[msg.sender] = record(
            usdtNum, 
            fireNum,
            backUsdt,
            day,
            block.timestamp,
            0
            );

        
        uint myLevel=getLevel(msg.sender);
            if(myLevel!=level[msg.sender]){
                level[msg.sender]=myLevel;
        }
        
        address pid =fire.userInfo(msg.sender).pid;
        uint newLevel ;
        for(uint i=0 ; i<10;i++){
            if(i>0){
                pid=fire.userInfo(pid).pid;
            }
            
            if(pid==address(0) || pid == topAddress){
                break;
            }

            teamUsdt[pid]+=usdtNum;

            
            newLevel=getLevel(pid);
            if(newLevel!=level[pid]){
                level[pid]=newLevel;
            }
        }
        uint edu = 0;
        uint preRank =0;
        pid =fire.userInfo(msg.sender).pid;
        for(uint i=0 ; i<10;i++){
            if(i>0){
                pid=fire.userInfo(pid).pid;
            }
            
            if(pid==address(0) || pid == topAddress){
                break;
            }

            if(level[pid]>preRank){
                uint toNum= jiNum.mul(ji[level[pid]]-edu).div(1000);
                dBalance[pid]+=toNum;
                edu=ji[level[pid]];
                preRank=level[pid];
                emit log(pid,block.timestamp,1,toNum);
            }
           
            if(edu==400){
                break;
            }

        }

        //uint inday = recordByAddress[msg.sender].day;
        // /uint instate = recordByAddress[msg.sender].state;
        // uint inallIn = allIn[msg.sender];
        if(usdtNum>=1000 ether && usdtNum<2001 ether && day>=90 ){
            if(nft3[msg.sender]==0){
                nft3[msg.sender]=1;
            }
        }else if(usdtNum>=2001 ether && usdtNum<5001 ether && day>=90 ){
            if(nft4[msg.sender]==0){
                nft4[msg.sender]=1;
            }
        }else if(usdtNum>=5001 ether && day>=90 ){
            if(nft5[msg.sender]==0){
                nft5[msg.sender]=1;
            }
        }

        // if(usdtNum>=1000 && usdtNum<2001 && inday>=90 && instate==0){
        //     if(nft3[msg.sender]==0){
        //         nft3[msg.sender]=1;
        //     }
        // }else if(usdtNum>=2001 && usdtNum<5001 && inday>=90 && instate==0){
        //     if(nft4[msg.sender]==0){
        //         nft4[msg.sender]=1;
        //     }
        // }else if(usdtNum>=5001 && inday>=90 && instate==0){
        //     if(nft5[msg.sender]==0){
        //         nft5[msg.sender]=1;
        //     }
        // }
           
    }

    function col() external {
        uint userusdt=recordByAddress[msg.sender].usdt;
        require(userusdt>0,"A");
         uint endTime = recordByAddress[msg.sender].lastTime + recordByAddress[msg.sender].day*waitTime;
        //uint endTime = recordByAddress[msg.sender].lastTime + waitTime;//re
        require(endTime<=block.timestamp,"B");
        require(recordByAddress[msg.sender].state==0,"C");
        
        // recordByAddress[msg.sender].state==1;
        uint fireNum =u2token(recordByAddress[msg.sender].backUsdt);
        fire.transfer(msg.sender, fireNum);

        recordByAddress[msg.sender] = record(
            0, 
            0,
            0,
            0,
            0,
            0
            );
        

        uint myLevel=getLevel(msg.sender);
            if(myLevel!=level[msg.sender]){
                level[msg.sender]=myLevel;
        }

        address pid =fire.userInfo(msg.sender).pid;
        uint newLevel ;
        for(uint i=0 ; i<10;i++){
            if(i>0){
                pid=fire.userInfo(pid).pid;
            }
            
            if(pid==address(0) || pid == topAddress){
                break;
            }

           

            if(userusdt>=teamUsdt[pid]){
                teamUsdt[pid]=0;
            }else{
                teamUsdt[pid]-=userusdt;
            }
           
            newLevel=getLevel(pid);
            if(newLevel!=level[pid]){
                level[pid]=newLevel;
            }
        }
        
    }

    function dCol() external {
        require(dBalance[msg.sender]>0,"A");
        if(lastColTime[msg.sender]>0){
            require(lastColTime[msg.sender]+waitTime<=block.timestamp,"B");
        }
        
        uint reToken = dBalance[msg.sender].mul(20).div(1000);
        if(dBalance[msg.sender]>=reToken){
            dBalance[msg.sender]=dBalance[msg.sender].sub(reToken);
        }else{
            dBalance[msg.sender]=0;
        }
        lastColTime[msg.sender]=block.timestamp;
        dallCol[msg.sender]+=reToken;
        fire.transfer(msg.sender, reToken);

        
    }

   

    
    function getLevel(address _address) private view returns (uint){
        uint _ut= teamUsdt[_address];
        uint usdtv2 = firev2.getPledgeRecordInfov2(_address).usdt;
        uint newlevel;

        if(_ut>=500000 ether && usdtv2 >=1000 ether ){
            return 4;
        }
        if(_ut>=100000 ether && usdtv2 >=500 ether ){
            return 3;
        }
        if(_ut>=50000 ether && usdtv2 >=200 ether ){
            return 2;
        }
        if(_ut>=10000 ether && usdtv2 >=100 ether ){
            return 1;
        }
        return newlevel;
        
    }

 

    function getPerIndex(uint usdtNum , uint day) private view returns(uint){
        uint index = 0;
        if(day == 7){
            index = 0;
        }else if(day == 15){
            index = 1;
        }else if(day == 30){
            index = 2;
        }else if(day == 90){
            index = 3;
        }
        if(usdtNum>=100 ether &&  usdtNum<=2000 ether){
            return per[0][index];
        }else if(usdtNum>2000 ether &&  usdtNum<=5000 ether){
            return per[1][index];
        }else if(usdtNum>5000 ether){
            return per[2][index];
        }else{
            return per[0][index];
        }

    }

    //ok
    function u2token(uint _u) private view returns(uint){
        uint _token;
        uint _usdt;
        
        (_token,_usdt,) = uniswapV2Pair.getReserves();
        if(_token==0 || _usdt==0){
            return 0;
        }else{
            if(uniswapV2Pair.token1()==usdtAddress){
                return _u.mul(_token).div(_usdt);
            }else{
                return _u.mul(_usdt).div(_token);
            }

        }
        
    }

    function token2u(uint _tokenMy) private view returns(uint){
        uint _token;
        uint _usdt;
        
        (_token,_usdt,) = uniswapV2Pair.getReserves();
        if(_token==0 || _usdt==0){
            return 0;
        }else{
            if(uniswapV2Pair.token1()==usdtAddress){
                return _tokenMy.mul(_usdt).div(_token);
            }else{
                return _tokenMy.mul(_token).div(_usdt);
            }

        }
        
    }

    


    function getJi(uint _index) external view returns (uint){
        return ji[_index];
    }

    

    function getDinfo(address _address) external view returns (uint,uint,uint,uint,uint){
        return(
            dBalance[_address],
            dallCol[_address],
            lastColTime[_address],
            dBalance[_address]+dallCol[_address],
            dBalance[_address].mul(20).div(1000)
        );
    }

    function getNftInfo(address _address) external view returns (uint,uint,uint){
        return(
            nft3[_address],
            nft4[_address],
            nft5[_address]
        );
    }

    function getNft3(address _address) external view returns (uint){
        return nft3[_address];
    }
    function getNft4(address _address) external view returns (uint){
        return nft4[_address];
    }
    function getNft5(address _address) external view returns (uint){
        return nft5[_address];
    }

    function getdBalance(address _address) external view returns (uint){
        return dBalance[_address];
    }

    function getdallCol(address _address) external view returns (uint){
        return dallCol[_address];
    }

    function getLastColTime(address _address) external view returns (uint){
        return lastColTime[_address]; 
    }

    function recordInfo(address _address) external view returns (record memory){
        return recordByAddress[_address];
    }

    function getTeamUsdt(address _address) external view returns (uint){
        return teamUsdt[_address];
    }

    function getUserInfo(address _address) external view returns (uint,uint,uint){
        return (
            teamUsdt[_address],
            firev2.getPledgeRecordInfov2(_address).usdt,
            level[_address]
        );
    }

    function getBurnNum() external view returns (uint ,uint ){
            return (allBurnFire,allBurnUsdt);
        }

    function getu2token(uint _u) external view returns (uint ){
            return u2token(_u);
        }
}