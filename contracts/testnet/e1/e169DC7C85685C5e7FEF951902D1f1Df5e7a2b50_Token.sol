/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

contract Owner {

    address private owner;
    
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    modifier isOwner() {
       
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor() {
        owner = msg.sender; 
        emit OwnerSet(address(0), owner);
    }

    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}

library SafeMath {
    int256 constant private INT256_MIN = -2**255;

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function mul(int256 a, int256 b) internal pure returns (int256) {
    
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN));

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); 
        require(!(b == -1 && a == INT256_MIN));

        int256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

  
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

   
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


abstract contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }




}



contract Blacklist is Ownable {
  mapping(address => bool) blacklist;
  address[] public blacklistAddresses;

  event BlacklistedAddressAdded(address addr);
  event BlacklistedAddressRemoved(address addr);

  /**
   * @dev Throws if called by any account that's whitelist (a.k.a not blacklist)
   */
  modifier isBlacklisted() {
    require(blacklist[msg.sender]);
    _;
  }

  /**
   * @dev Throws if called by any account that's blacklist.
   */
  modifier isNotBlacklisted() {
    require(!blacklist[msg.sender]);
    _;
  }

  /**
   * @dev Add an address to the blacklist
   * @param addr address
   * @return success true if the address was added to the blacklist, false if the address was already in the blacklist
   */
  function addAddressToBlacklist(address addr) onlyOwner public returns(bool success) {
    if (!blacklist[addr]) {
      blacklistAddresses.push(addr);
      blacklist[addr] = true;
      emit BlacklistedAddressAdded(addr);
      success = true;
    }
  }

  /**
   * @dev Add addresses to the blacklist
   * @param addrs addresses
   * @return success true if at least one address was added to the blacklist,
   * false if all addresses were already in the blacklist
   */
  function addAddressesToBlacklist( address[] memory addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (addAddressToBlacklist(addrs[i])) {
        success = true;
      }
    }
  }

  /**
   * @dev Remove an address from the blacklist
   * @param addr address
   * @return success true if the address was removed from the blacklist,
   * false if the address wasn't in the blacklist in the first place
   */
  function removeAddressFromBlacklist(address addr) onlyOwner public returns(bool success) {
    if (blacklist[addr]) {
      blacklist[addr] = false;
      for (uint i = 0; i < blacklistAddresses.length; i++) {
        if (addr == blacklistAddresses[i]) {
          delete blacklistAddresses[i];
        }
      }
      emit BlacklistedAddressRemoved(addr);
      success = true;
    }
  }

  /**
   * @dev Remove addresses from the blacklist
   * @param addrs addresses
   * @return success true if at least one address was removed from the blacklist,
   * false if all addresses weren't in the blacklist in the first place
   */
  function removeAddressesFromBlacklist(address[] memory addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (removeAddressFromBlacklist(addrs[i])) {
        success = true;
      }
    }
  }

  /**
   * @dev Get all blacklist wallet addresses
   */
  function getBlacklist() public view returns (address[] memory) {
    return blacklistAddresses;
  }

}






contract Token is Owner,Blacklist {

    mapping(address => bool) private _blacklist;
    using SafeMath for uint256;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => Unlock[]) public TimeToRelease;
    mapping(address => uint256) public unlock_amount_transfered;
    struct Unlock {
    uint256 unlock_time;
    uint256 amount;
    }

    mapping (address => bool) private _isExcludedFromFee;
    uint public totalSupply = 66000000 * 10**9;
    string public constant name = "TueCityNFT";
    string public constant symbol = "TRU";
    uint public constant decimals = 9;
    
    //Fees
    address public constant adicionalFeeReguler = 0xC21a384D2755c8fDE0bd3fb5886CdA111cEa7E5E; //si exede de transsacion el porsentaje de la comision caera en esta billetera
    //Principal wallets
    address public constant investmentsTruCity_wallet = 0x78C13A4861E8ea815d7fdb7De12D0E6993489AA6; // investmentsTruCity_supply 51336972
    address public constant liquidez_W = 0x184500B821bDAfed164Ca836B78583eebB41a73a; //liquidez_supply 14663028
    //Supply
    uint public constant investmentsTruCity_supply = 51336972 * 10**9;
    uint public constant liquidez_supply = 14663028 * 10**9;

    
    event SetLiquidityFee(uint256 oldValue, uint256 newValue);
    event SetAditionalFeePercentage_1(uint256 oldValue, uint256 newValue);
    event SetAditionalFeePercentage_2(uint256 oldValue, uint256 newValue);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[investmentsTruCity_wallet] = investmentsTruCity_supply;
        emit Transfer(address(0), investmentsTruCity_wallet, investmentsTruCity_supply);
        balances[liquidez_W] = liquidez_supply;
        emit Transfer(address(0), liquidez_W, liquidez_supply);

        
        // tge_time = 01/01/1111 14:00:00
        uint256 tge_time = 1646078623;//modificar fecha de lanzamiento
        // 2592000 = 1 days
        uint256 six_weeks_time = 1; // modificar fecha de lanzamiento

        // are unlocked to date 10mts the amount of 1.155.000
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 1),1155000 * 10**9));
        // are unlocked to date 10mts the amount of 4.248.742
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 2),4248742 * 10**9));
        // are unlocked to date 10mts the amount of 1.116.494
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 3),1116494 * 10**9));
        // are unlocked to date 10mts the amount of 6.885.998
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 4),6885998 * 10**9));
        // are unlocked to date 10mts the amount of 1.674.750
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 5),1674750 * 10**9));
        // are unlocked to date 10mts the amount of 6.168.262
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 6),6168262 * 10**9));
        // are unlocked to date 10mts the amount of 1.196.250
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 6),1196250 * 10**9));
        // are unlocked to date 10mts the amount of 5.354.244
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 7),5354244 * 10**9));
        // are unlocked to date 10mts the amount of 1.196.250
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 8),1196250 * 10**9));
        // are unlocked to date 10mts the amount of 4.706.617
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 9),4706617 * 10**9));
        // are unlocked to date 10mts the amount of 837.375
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 10),837375 * 10**9));
        // are unlocked to date 10mts the amount of 3.697.382
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 11),3697382 * 10**9));
        // are unlocked to date 10mts the amount of 837.375
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 12),837375 * 10**9));
        // are unlocked to date 10mts the amount of 3.617.613
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 13),3617613 * 10**9));
        // are unlocked to date 10mts the amount of 598.125
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 14),598125 * 10**9));
        // are unlocked to date 10mts the amount of 3.073.132
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 15),3073132 * 10**9));
        // are unlocked to date 10mts the amount of 598.125
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 16),598125 * 10**9));
        // are unlocked to date 10mts the amount of 2.620.750
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 17),2620750 * 10**9));
        // are unlocked to date 10mts the amount of 478.500
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 18),478500 * 10**9));
        // are unlocked to date 10mts the amount of 478.500
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 19),478500 * 10**9));
        // are unlocked to date 10mts the amount of 478.500
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 20),478500 * 10**9));
        // are unlocked to date 10mts the amount of 318.988
        TimeToRelease[investmentsTruCity_wallet].push(Unlock(tge_time + (six_weeks_time * 21),318988 * 10**9));


           }

        function checkTimeToRelease(address _account, uint256 _amount) private returns(bool){
            bool allowed_operation = false;
            uint256 amount_unlocked = 0;
            bool last_unlock_completed = false;
            if(TimeToRelease[_account].length > 0){

                for(uint256 i=0; i<TimeToRelease[_account].length; i++){
                    if(block.timestamp >= TimeToRelease[_account][i].unlock_time){
                        amount_unlocked = amount_unlocked.add(TimeToRelease[_account][i].amount);
                    }
                    if(i == (TimeToRelease[_account].length-1) && block.timestamp >= TimeToRelease[_account][i].unlock_time){
                        last_unlock_completed = true;
                    }
                }

                if(last_unlock_completed == false){
                    if(amount_unlocked.sub(unlock_amount_transfered[_account]) >= _amount){
                        allowed_operation = true;
                    }else{
                        allowed_operation = false;
                    }
                }else{
                    allowed_operation = true;
                }

                if(allowed_operation == true){
                    unlock_amount_transfered[_account] = unlock_amount_transfered[_account].add(_amount);
                }
            }else{
                allowed_operation = true;
            }

            return allowed_operation;
        }

        function excludeFromFee(address[] memory accounts) public isOwner {
            for (uint256 i=0; i<accounts.length; i++) {
                _isExcludedFromFee[accounts[i]] = true;
            }
        }
        function includeInFee(address[] memory accounts) public isOwner {
            for (uint256 i=0; i<accounts.length; i++) {
                _isExcludedFromFee[accounts[i]] = false;
            }
        }
        function isExcludedFromFee(address account) public view returns(bool) {
            return _isExcludedFromFee[account];
        }
 
        function balanceOf(address owner) public view returns(uint) {
            return balances[owner];
        }
        
        function getAdditionalFee(uint256 _value) private pure returns(uint256){
            uint256 aditionalFee = 0;
            if(_value >= 21001 * 10**9){
                aditionalFee = _value.mul(1000).div(10**4); // 1000 = 10%
            }
            if(_value >= 25500 * 10**9){
                aditionalFee = _value.mul(2000).div(10**4); // 2000 = 20%
            }
            if(_value >= 31501 * 10**9){
                aditionalFee = _value.mul(3500).div(10**4); // 3500 = 35%
            }
            if(_value >= 36501 * 10**9){
                aditionalFee = _value.mul(6000).div(10**4); // 6000 = 60%
            }
            if(_value >= 40001 * 10**9){
                aditionalFee = _value.mul(8000).div(10**4); // 8000 = 80%
            }
            return aditionalFee;
        }

        
        function transfer(address to, uint value) public isNotBlacklisted returns(bool) {
            require(checkTimeToRelease(msg.sender, value) == true, "the amount is greater than the amount available unlocked");
            require(balanceOf(msg.sender) >= value, 'balance too low');
            
        
            //if any account belongs to _isExcludedFromFee account then remove the fee
            if(_isExcludedFromFee[msg.sender] || _isExcludedFromFee[to]){
                balances[to] += value;
                emit Transfer(msg.sender, to, value);
            }else{
                balances[adicionalFeeReguler] += getAdditionalFee(value);
                balances[to] += value.sub(getAdditionalFee(value));
                emit Transfer(msg.sender, adicionalFeeReguler, getAdditionalFee(value));
                emit Transfer(msg.sender, to, value.sub(getAdditionalFee(value)));
            }
            balances[msg.sender] -= value;
            return true;
        }

        function transferFrom(address from, address to, uint value)  public isNotBlacklisted  returns(bool) {
            require(checkTimeToRelease(from, value) == true, "the amount is greater than the amount available unlocked");
            require(balanceOf(from) >= value, 'balance too low');
            require(allowance[from][msg.sender] >= value, 'allowance too low');
            
            if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
                balances[to] += value;
                emit Transfer(from, to, value);
            }else{
                balances[adicionalFeeReguler] += getAdditionalFee(value);
                balances[to] += value.sub(getAdditionalFee(value));
                emit Transfer(from, adicionalFeeReguler, getAdditionalFee(value));
                emit Transfer(from, to, value.sub(getAdditionalFee(value)));
            }

            balances[from] -= value;
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
            return true;
        }
        
        function approve(address spender, uint value)  public isNotBlacklisted returns (bool) {
            allowance[msg.sender][spender] = value;
            emit Approval(msg.sender, spender, value);
            return true;   
        }


    }