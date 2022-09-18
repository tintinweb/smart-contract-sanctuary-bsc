/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

pragma solidity ^0.4.24;

interface USDT { 
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	function transfer(address recipient, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
	function allowance(address owner, address spender) external view returns (uint256);
}

interface GMSToken { 
    function balanceOf(address account) external view returns (uint256);
    function transferIboGMS(address account,uint256 amount) external returns (bool);
}


interface Soil { 
    function getLevel(address account) external view returns (uint256);
}

//USDT Testnet
// 0x337610d27c682e347c9cd60bd4b3b107c9d34ddd

// 0xA05e362E5F85a928257Db788F58E6fE8E6033f4C

contract Simupool {

    address public _owner;
	USDT public _usdt;
    GMSToken public _gms;
    Soil public _soil;
	string public _name;
    string public _symbol;
	address public _self;
    uint256 ldo_amount;
    mapping(address => uint256) public credits;
    mapping(address => uint256) public credits_left;
    mapping(address => uint256) public credits_withdrawed;
    mapping(address => uint256) public credits_can_withdraw;
    mapping(address => uint256) public level;

    uint256 level1_percent; //based on 100
    uint256 level2_percent; //based on 100
    uint256 level3_percent; //based on 100
    uint256 level4_percent; //based on 100
    uint256 price_withdraw;

    event Deposit(address _address,uint256 _usdt_amount);
    event Withdraw(address _address,uint256 _credits,uint256 _gms,uint256 _price);



    modifier  onlyOwner{
        if(msg.sender != _owner){
            revert();
        }else{
            _;
        }
    }

    function transferOwner(address _newOwner)  public onlyOwner{
        _owner = _newOwner;
    }

    constructor() public payable{
		_name = "SimuPool";
        _symbol = "Pool";
        _owner=msg.sender;
        _self=msg.sender;
        ldo_amount=1000000000000000000;
        level1_percent=0; //based on 100
        level2_percent=0; //based on 100
        level3_percent=0; //based on 100
        level4_percent=0; //based on 100
        price_withdraw=1;
    }
	
	function () public payable{

    }
	
	function ownerKill(address target) public onlyOwner {
		selfdestruct(target);
    }
	
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
    return sub(a, b, "SafeMath: subtraction overflow");
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
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
	

	
	function getUSDTBalance(address _add) public view returns (uint256){
		return _usdt.balanceOf(_add);
    }
	
	function setUSDTApprove(address spender, uint256 amount) onlyOwner public returns (bool){
		bool s=_usdt.approve(spender, amount);
		return s;
    }
	
	function getUSDTTotalSupply() public view returns (uint256){
		return _usdt.totalSupply();
    }
	
	function getUSDTName() public view returns (string memory){
		return _usdt.name();
    }
	
	function transferUSDT2Contract() public returns (bool){
		//approve first 
		bool b;

        uint256 bal=_usdt.balanceOf(msg.sender);
        if((bal>=ldo_amount)&&(credits[msg.sender]==0)){
		    b=_usdt.transferFrom(msg.sender, _self, ldo_amount);
            if(b==true){
                credits[msg.sender]=ldo_amount;
                credits_can_withdraw[msg.sender]=ldo_amount;
                credits_left[msg.sender]=ldo_amount;
                credits_withdrawed[msg.sender]=0;
                level[msg.sender]=1;
                emit Deposit(msg.sender,ldo_amount);
            }
        }else{
            return false;
        }
		return b;
    }
	
	function transferUSDTFromContrct2Add(address _add,uint256 _amount) public onlyOwner returns (bool){
		bool b;
		b=_usdt.transfer(_add, _amount);
		return b;
    }
	
	function getAllowance(address myowner, address spender) public view returns (uint256){
		return _usdt.allowance(myowner, spender);
    }
	
	function setTokenAddress(address _usdtToken) public onlyOwner returns (bool){
    	_usdt =USDT(_usdtToken);
        //_usdt2 =USDT(address(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd));
        return true;
    }
	
    function setGMSAddress(address _gmsToken) public onlyOwner returns (bool){
    	_gms =GMSToken(_gmsToken);
        return true;
    }

    function setSoilAddress(address _soiladd) public onlyOwner returns (bool){
    	_soil =Soil(_soiladd);
        return true;
    }
	
	function setSelfAddress(address _selfadd) public onlyOwner returns(bool){
    	_self =_selfadd;
        return true;
    }

    function setWithdrawLevelPercent(uint256 _level1_percent,uint256 _level2_percent,uint256 _level3_percent,uint256 _level4_percent) public onlyOwner returns(bool){
    	level1_percent=_level1_percent; //based on 100
        level2_percent=_level2_percent; //based on 100
        level3_percent=_level3_percent; //based on 100
        level4_percent=_level4_percent; //based on 100
        return true;
    }

    function setWithdrawPrice(uint256 _price) public onlyOwner returns (bool){
    	price_withdraw=_price;
        return true;
    }

    function setLevel(address _add,uint256 _level) public onlyOwner returns (bool){
    	level[_add]=_level;
        return true;
    }

    function setLevel(address _add) public onlyOwner returns (bool){
    	level[_add]=_soil.getLevel(_add);
        return true;
    }

    function getWithdrawAvailableGMS() public view returns (uint256){
        uint256 level_percent=0;
        if(level[msg.sender]==1){level_percent=level1_percent;}
        if(level[msg.sender]==2){level_percent=level2_percent;}
        if(level[msg.sender]==3){level_percent=level3_percent;}
        if(level[msg.sender]==4){level_percent=level4_percent;}
        uint256 mycredits_can_withdraw=mul(div(credits[msg.sender],100),level_percent); //usd
        uint256 gms_am=0;
        if(mycredits_can_withdraw>credits_withdrawed[msg.sender]){
            gms_am=div(mycredits_can_withdraw-credits_withdrawed[msg.sender],price_withdraw);
        }
        return gms_am;
    }

   

    function withdrawGMS() public returns (uint256){
        uint256 level_percent=0;
        if(level[msg.sender]==1){level_percent=level1_percent;}
        if(level[msg.sender]==2){level_percent=level2_percent;}
        if(level[msg.sender]==3){level_percent=level3_percent;}
        if(level[msg.sender]==4){level_percent=level4_percent;}
        credits_can_withdraw[msg.sender]=mul(div(credits[msg.sender],100),level_percent); //usd
        uint256 gms_am=0;
        if(credits_can_withdraw[msg.sender]>credits_withdrawed[msg.sender]){
            gms_am=div(credits_can_withdraw[msg.sender]-credits_withdrawed[msg.sender],price_withdraw);
            if(gms_am>0){
                bool b=_gms.transferIboGMS(msg.sender,gms_am);
                if(b==true){
                    credits_left[msg.sender]=credits[msg.sender]-credits_can_withdraw[msg.sender];
                    credits_withdrawed[msg.sender]=credits_withdrawed[msg.sender]+credits_can_withdraw[msg.sender];
                    emit Withdraw(msg.sender,credits_can_withdraw[msg.sender]-credits_withdrawed[msg.sender],gms_am,price_withdraw);
                }
            }
        }
        return gms_am;
    }

    function getLevel(address account) public view returns (uint256){
        return _soil.getLevel(account);
    }

    function setAllAddress(address _selfadd,address _usdtToken,address _gmsToken,address _soiladd) public onlyOwner returns (bool){
    	_usdt =USDT(_usdtToken);
        _soil =Soil(_soiladd);
        _gms =GMSToken(_gmsToken);
        _self =_selfadd;
        return true;
    }




}