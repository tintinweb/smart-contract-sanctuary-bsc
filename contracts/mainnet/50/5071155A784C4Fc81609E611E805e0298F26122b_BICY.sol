/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// File: contracts/BICY.sol




pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}

/****
   * BICY Token
****/

contract BICY is IERC20 {

    using SafeMath for uint256;

    string public constant name = "BICY";
    string public constant symbol = "BICY";
    uint8 public constant decimals = 18;
    uint256 private start_timestamp;
    address public _owner;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    
    address [] private angels;
    address [] private seeds;
    address [] private team;

    uint256 totalSupply_ = 3000000000000000000000000000;

    constructor() {
        balances[msg.sender] = totalSupply_;
        start_timestamp = block.timestamp;
        _owner = msg.sender;
    }
    /***
    Add to angels list
    ***/
    function addAngel(address _address) public returns (bool) {
        require(msg.sender == _owner, "Only owner can add to list");
        require(_address != _owner, "Forbidden for owner");
        angels.push(_address);
        return true;
    }
    /***
    Add to teeammates list
    ***/
    function addTeammate(address _address) public returns (bool) {
        require(msg.sender == _owner, "Only owner can add to list");
        require(_address != _owner, "Forbidden for owner");
        team.push(_address);
        return true;
    }
    /***
    Add to seeds list
    ***/
    function addSeed(address _address) public returns (bool) {
        require(msg.sender == _owner, "Only owner can add to list");
        require(_address != _owner, "Forbidden for owner");
        seeds.push(_address);
        return true;
    }
    /***
     Check is list contain address
    ***/
    function contain (address _address, address [] memory list) internal pure returns (bool) {
        bool doesListContainElement = false;
        for (uint i=0; i < list.length; i++) {
            if (_address == list[i]) {
                doesListContainElement = true;
            }
        }
        return doesListContainElement;
    }
    /***
      Get month since contract created
    ***/
    function getMonth() public view returns (uint){
         uint256 secondsInMonth = 2592000;
         uint256 diff = block.timestamp - start_timestamp;
         if(diff < secondsInMonth){
             return 0;
         }else{
             return diff / secondsInMonth;
         }
         
    }
    /***
      Check is address has rights to move his tokens
    ***/
    function hasRights(address _address) internal view returns (bool){
        uint month = getMonth();
        bool isAngel = contain(_address, angels);
        bool isTeammate = contain(_address, team);
        bool isSeed = contain(_address, seeds);
        if(isAngel || isTeammate){
            if(month >= 18){
                return true;
            }else{
                return false;
            }
        }else if(isSeed){
            if(month >= 24){
                return true;
            }else{
                return false;
            }
        }else{
            return true;
        }
    }

    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(hasRights(msg.sender), "Not time");
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function burn(uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Transfer(msg.sender, address(0),_value);
        return true;
    }
}