/**
 *Submitted for verification at BscScan.com on 2022-08-15
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

contract PresaleV3 is Context, Ownable {
    using SafeMath for uint256;
  
    uint256 public minIndividualCap = 38e18;
   
     

    IERC20 public usdt;
 
    uint256 public startTime;
  
    uint256 public endTime;
 
    uint256 public durationTime = 365 * 24 hours;
 
    bool public ended;
   
   
 
    mapping(address=>uint256) public bncBalances;
    mapping(address=>uint256) public rewardUBalances;
 
    // 默认的钱包
    address public defaultFirst;
    address public defaultSecond;
    address public defaultThird;


    mapping(address=>bool) first00Reached;
    mapping(address=>bool) second00Reached;
    mapping(address=>bool) third00Reached;

    uint16 NumberOfWallet1=100;
    uint16 NumberOfWallet2=200;
    uint16 NumberOfWallet3=300;
    uint16 NumberOfWallet4=400;

    event PresaleEvent(
        address indexed msgsender,
        address  first,
        address  second,
        address  third,
        uint256  totalu
    );


    event AirDropEvent(
        address indexed msgsender,
        uint256 totalu
    );
  
     event PresaleBncEvent(
        address indexed msgsender,
        uint256 totalbnc
    );

    mapping(address =>mapping(uint8=>uint256)) public NumberOfObject;
 
    mapping(address => address) public meParent ;
   
    constructor(
    
        address _usdt,
        address  _defaultFirst,
        address  _defaultSecond,
        address  _defaultThird
    ) public {
 
        usdt = IERC20(_usdt);

        //建立子代关系
   
       defaultFirst=_defaultFirst;
       defaultSecond=_defaultSecond;
       defaultThird=_defaultThird;

       meParent[defaultFirst]=defaultSecond;
       meParent[defaultSecond]=defaultThird;

       NumberOfObject[defaultSecond][1]=1;
       NumberOfObject[defaultThird][1]=1;
       NumberOfObject[defaultThird][2]=1;
        
    }
 
 
    function startIdo() public onlyOwner {
        require(startTime == 0, "PresaleV3:ido started");
        startTime = block.timestamp;
        endTime = startTime.add(durationTime);
    }

    
     
    modifier modifierActivityTime(){
         
        require(startTime > 0, "PresaleV3: not start");
      
        require(endTime > block.timestamp, "PresaleV3 Ended"); 
        _;   
    }
  
    function ido(uint256 _amount,address _parent,uint256 _bncAmount) external modifierActivityTime(){

  
        require(_msgSender()!=_parent,"PresaleV3:not same"); 
   
        require(_amount >= minIndividualCap, "PresaleV3:too small");
        
         
        _handleParentSon(_parent,_amount,_bncAmount);
        

    }
 

    function _handleParentSon(address _parent,uint256 _amount,uint256 _bncAmount) internal{

           uint256 tokenOfContact=10e18;
           bool isNew=false;
           // if current 
           if(meParent[_msgSender()]==address(0)){     

              isNew=true;
            // new person 
              meParent[_msgSender()]= _parent;

              bncBalances[_msgSender()]=bncBalances[_msgSender()].add(tokenOfContact);

              emit AirDropEvent(_msgSender(),tokenOfContact);

              
           } 

           // first 
           address parent = meParent[_msgSender()];
         

           address gradePa= meParent[parent];
           if(gradePa==address(0)){
                gradePa =defaultFirst;
                meParent[parent]=gradePa;
                NumberOfObject[gradePa][1]= NumberOfObject[gradePa][1].add(1);
                NumberOfObject[meParent[gradePa]][2]= NumberOfObject[meParent[gradePa]][2].add(1);
                NumberOfObject[meParent[meParent[gradePa]]][3]= NumberOfObject[meParent[meParent[gradePa]]][3].add(1);
           }
           // third 
           address gradePaPa= meParent[gradePa];
            if(gradePaPa==address(0) ){
                gradePaPa =defaultSecond;
                meParent[gradePa]=gradePaPa;
           }
          


           if(isNew==true){

            
           NumberOfObject[parent][1]= NumberOfObject[parent][1].add(1); 
           NumberOfObject[gradePa][2]= NumberOfObject[gradePa][2].add(1);
           NumberOfObject[gradePaPa][3]= NumberOfObject[gradePaPa][3].add(1);



          _totalSonCalFee(parent);
          _totalSonCalFee(gradePa);
          _totalSonCalFee(gradePaPa);
          
           }
        
           // pay for money 
           
          
          uint256 moneyOfContact = _amount.mul(83).div(100);   
          uint256 firstMoney = _amount.mul(10).div(100);  
          uint256 secondMoney = _amount.mul(5).div(100);  
          uint256 thirdMoney =  _amount.mul(2).div(100);   

          usdt.transferFrom(_msgSender(),address(this), moneyOfContact); 
          usdt.transferFrom(_msgSender(),parent, firstMoney);
          usdt.transferFrom(_msgSender(),gradePa, secondMoney);
          usdt.transferFrom(_msgSender(),gradePaPa, thirdMoney);

          rewardUBalances[address(this)]=rewardUBalances[address(this)].add(moneyOfContact);
          rewardUBalances[parent]=rewardUBalances[parent].add(firstMoney);
          rewardUBalances[gradePa]=rewardUBalances[gradePa].add(secondMoney);
          rewardUBalances[gradePaPa]=rewardUBalances[gradePaPa].add(thirdMoney);

          // send token  
         
          bncBalances[_parent]=bncBalances[_parent].add(tokenOfContact);
          bncBalances[_msgSender()]=bncBalances[_msgSender()].add(_bncAmount);
          emit AirDropEvent(_parent,tokenOfContact);
          emit PresaleEvent(_msgSender(),parent,gradePa,gradePaPa,_amount);
          emit PresaleBncEvent(_msgSender(),_bncAmount);
 
 
    }

    // first + second + third 
    function _totalSonCalFee(address _addr)  internal  {


     uint256 rewardOfContact=3000e18;
     uint256 total = NumberOfObject[_addr][1].add( NumberOfObject[_addr][2]);
     total =total.add(NumberOfObject[_addr][1]);

    if(total >=NumberOfWallet1 && total<NumberOfWallet2 && !first00Reached[_addr]){
           bncBalances[_addr]=bncBalances[_addr].add(rewardOfContact);
           emit AirDropEvent(_addr,rewardOfContact);
           first00Reached[_addr]=true;

     }else if(total >=NumberOfWallet2 && total<NumberOfWallet3 && !second00Reached[_addr]){
            bncBalances[_addr]=bncBalances[_addr].add(rewardOfContact);
            emit AirDropEvent(_addr,rewardOfContact);
            second00Reached[_addr]=true;

    }else if(total >=NumberOfWallet3 && total<NumberOfWallet4 && !third00Reached[_addr]){
             bncBalances[_addr]=bncBalances[_addr].add(rewardOfContact);
             emit AirDropEvent(_addr,rewardOfContact);
             third00Reached[_addr]=true;

    }
    
    }


    function setRelationship(address _parent,address _me,uint256 _amount,uint256 _bncAmount) external onlyOwner {

        require(_me!=_parent,"PresaleV3:not same"); 
        require(_me!=address(0),"PresaleV3:is not null");
        require(_parent!=address(0),"PresaleV3:is not null");
   
        require(_amount >= minIndividualCap, "PresaleV3:too small");


        uint256 tokenOfContact=10e18;
        bool isNew=false;
           // if has current
        if(meParent[_me]==address(0)){     

              isNew=true;
            // is new person 
              meParent[_me]= _parent;

              bncBalances[_me]=bncBalances[_me].add(tokenOfContact);

              emit AirDropEvent(_me,tokenOfContact);
 
           } 

          
           // current 
           address parent = meParent[_me];
           // my second
           address gradePa= meParent[parent];
           if(meParent[parent]==address(0)){
                gradePa =defaultFirst;
                meParent[parent]=gradePa;
                NumberOfObject[gradePa][1]= NumberOfObject[gradePa][1].add(1);
                NumberOfObject[meParent[gradePa]][2]= NumberOfObject[meParent[gradePa]][2].add(1);
                NumberOfObject[meParent[meParent[gradePa]]][3]= NumberOfObject[meParent[meParent[gradePa]]][3].add(1);
           }
           // third
           address gradePaPa= meParent[gradePa];
            if(meParent[gradePa]==address(0)){
                gradePaPa =defaultSecond;
                meParent[gradePa]=gradePaPa;
           }
          


           if(isNew==true){

           NumberOfObject[parent][1]= NumberOfObject[parent][1].add(1); 
           NumberOfObject[gradePa][2]= NumberOfObject[gradePa][2].add(1);
           NumberOfObject[gradePaPa][3]= NumberOfObject[gradePaPa][3].add(1);
          _totalSonCalFee(parent);
          _totalSonCalFee(gradePa);
          _totalSonCalFee(gradePaPa);
          
        }
      
          uint256 moneyOfContact = _amount.mul(83).div(100);   
          uint256 firstMoney = _amount.mul(10).div(100);  
          uint256 secondMoney = _amount.mul(5).div(100);  
          uint256 thirdMoney =   _amount.mul(2).div(100);   
 
 

          rewardUBalances[address(this)]=rewardUBalances[address(this)].add(moneyOfContact);
          rewardUBalances[parent]=rewardUBalances[parent].add(firstMoney);
          rewardUBalances[gradePa]=rewardUBalances[gradePa].add(secondMoney);
          rewardUBalances[gradePaPa]=rewardUBalances[gradePaPa].add(thirdMoney);

     
          // send token please 
          bncBalances[parent]=bncBalances[parent].add(tokenOfContact);
          bncBalances[_me]=bncBalances[_me].add(_bncAmount);
          emit AirDropEvent(_parent,tokenOfContact);
          emit PresaleBncEvent(_me,_bncAmount);
          emit PresaleEvent(_me,parent,gradePa,gradePaPa,_amount);

      
    }
 
 
    function safeEndPresale() external onlyOwner {
       
        usdt.transfer(_msgSender(), usdt.balanceOf(address(this)));
    }

  
     
    function setMinIndividualCap(uint256 _amount) public onlyOwner {
        minIndividualCap = _amount;
    }
     
 

}