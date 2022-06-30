/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
        return mod(a, b);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract NebulaPresale is Context, Ownable {
    using SafeMath for uint256;
 
    uint256 public maxIndividualCap = 2000e18;
 
    uint256 public minIndividualCap = 100e18;
 
    uint256 public maxUsdtCap = 4000000e18;
 
    uint256 public raisedTotal;
   
    uint256 public tokenCap = 5000000e18;
  
    uint256 public airDropCap = 1000000e18;
     
    uint256 public uTos = 8;

    
    IERC20 public token;

    IERC20 public usdt;
 
    uint256 public startTime;
  
    uint256 public endTime;
 
    uint256 public durationTime = 365 * 24 hours;
 
    bool public ended;
 
    bool public isDepositedTokenCap;
  
    mapping(address => uint256) public balances;
  
    mapping(address => bool) public whitelists;
     
    address public leading ;

    address public liquidityWallet ;

    struct _Tree{
       address parent;
       address son;
       uint256 sonnum;
    }

    mapping(address => _Tree) public _trees ;

    event IdoInvitation(
        address indexed Invitee,
        address indexed Invitees
    );
  
   
    constructor(
        address _token,
        address _usdt,
        address _leading,
        address _liquidityWallet
    ) public {
        token = IERC20(_token);
        usdt = IERC20(_usdt);
        leading= _leading ;
        liquidityWallet= _liquidityWallet ;

    }
 
 
    function startIdo() public onlyOwner {
        require(startTime == 0, "ido started");
        startTime = block.timestamp;
        endTime = startTime.add(durationTime);
    }

    
     
    modifier modifierActivityTime(){
         
        require(startTime > 0, " not start");
      
        require(endTime > block.timestamp, " Ended"); 
        _;   
    }
  
    function ido(uint256 _amount,address _parent) external modifierActivityTime(){

 
        require(!whitelists[_msgSender()], "IDO ed");
 
        require(_msgSender()!=_parent,"not same"); 
 
        require(maxUsdtCap >= raisedTotal, "Sold out");
       
        require(
            balances[_msgSender()].add(_amount) <= maxIndividualCap,
            "Reach individual cap"
        );
  
        require(_amount >= minIndividualCap, "too small");
        
    
        require(balances[_msgSender()]<= maxIndividualCap, "exceed maxIndividualCap");
   
        require(maxUsdtCap >= raisedTotal, "Reach max cap");
        balances[_msgSender()] = balances[_msgSender()].add(_amount);
 
        uint8 _percent=_presaleVerify(_amount);
     
        uint256 invisterAmount = _amount.mul(_percent).div(100);   
        uint256 giveContract=_amount.sub(invisterAmount);
 
        raisedTotal = raisedTotal.add(giveContract); 

      
        _Tree storage _tree = _trees[_parent];
        if( _tree.son!=address(0)){

            if(raisedTotal >= 30000e18 && _percent==13){
                    usdt.transferFrom(_msgSender(),liquidityWallet, giveContract);
            }else{
                    usdt.transferFrom(_msgSender(), address(this), giveContract);
            }
            usdt.transferFrom(_msgSender(),_tree.son, invisterAmount); 
            _trees[_msgSender()] = _Tree(_parent,_msgSender(),_tree.sonnum.add(1));
            emit IdoInvitation(_msgSender(),_parent);
        }else{

            usdt.transferFrom(_msgSender(), address(this), giveContract);
            usdt.transferFrom(_msgSender(),leading, invisterAmount);
             _trees[_msgSender()] = _Tree(_parent,_msgSender(),1);
             emit IdoInvitation(_msgSender(),leading);
        }
        token.transfer(_msgSender(), _amount.mul(uTos).div(10));
        whitelists[_msgSender()] = true;
        

    }
 
    function _presaleVerify(uint256 _amount) view public  returns(uint8){
        
        require(_amount<=maxIndividualCap,"exceed");
        require(_amount>=minIndividualCap,"less than");
      
        uint256 newamount = _amount.div(100e18) ;
        uint8  percent =0;
        if (newamount >= 20){
            percent =20;
        }else if(newamount>=10){
            percent=16;
        }else if(newamount>=5){
            percent=13;
        }else if(newamount>=1){
            percent=8;
        } 
        return (percent);
    }

 
    function deposit() external onlyOwner {
        require(!isDepositedTokenCap, "Deposited");
        token.transferFrom(_msgSender(), address(this), tokenCap.add(airDropCap));
        isDepositedTokenCap = true;
    }
 
    function safeEndPresale() external onlyOwner {
        token.transfer(_msgSender(), token.balanceOf(address(this)));
        usdt.transfer(_msgSender(), usdt.balanceOf(address(this)));
    }

 
    function setMaxIndividualCap(uint256 _amount) public onlyOwner {
        maxIndividualCap = _amount;
    }
     
    function setMinIndividualCap(uint256 _amount) public onlyOwner {
        minIndividualCap = _amount;
    }
     function setTokenCap(uint256 _amount) public onlyOwner {
        tokenCap = _amount;
    }
    
    function setLiquidityWallet(address _liquidityWallet) public onlyOwner {
        liquidityWallet = _liquidityWallet;
    }

    function setLeading(address _leading) public onlyOwner {
        leading = _leading;
    }

     function setMaxUsdtCap(uint256 _amount) public onlyOwner {
        maxUsdtCap = _amount;
    }

     function setUtoS(uint256 _uTos) public onlyOwner {
        uTos = _uTos;
    }

}