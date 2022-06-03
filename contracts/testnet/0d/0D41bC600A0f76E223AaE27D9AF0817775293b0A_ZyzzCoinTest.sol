/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

pragma solidity 0.5.16;

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

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
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

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
}

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
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () internal {
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
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract ZyzzCoinTest is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (bytes32 => uint[2]) hash;

  mapping (bytes32 => bool) usedKeys;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

	uint public keysUsed = 0;
	uint256 public zyzzPerRedeem = 100;

  constructor() public {
    _name = "ZyzzTest3";
    _symbol = "ZyzzTest3";
    _decimals = 18;
    _totalSupply = 150000 * 10 ** 18;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);

	  hash[0x2d647303e2623440c07aa24f24f03c3feb4768509396961728cf3b5cd43fffa6] = [1, 1];
    hash[0xa8ef07cb5b8f7544d7233d9e11f7ddac8c006787e7e42ab47464fe7e463bb3ca] = [1, 2];
    hash[0x60276c2209d142b185f2027ea23ebab0ed4cbbab12bdae843d7acd1363c6d018] = [1, 3];
    hash[0x79647504b8bd34478d6b32c133db6e8fd836f04e18a7aa3af0a797bebac73183] = [1, 4];
    hash[0x06c8bb9190089700bdeb33056a4cbac6851eff29a84dfc1e2694217b614c430b] = [1, 5];
    hash[0x658bec7413db66e34a8cafee4c3ad0dc09e1721f5b7e88f19ce7bb688e60ce82] = [1, 6];
    hash[0xcf74ba1209f13804c384a8eaed677ef08aff1710c1239df6f8f21edf040429c8] = [1, 7];
    hash[0x03afd1ed81d0ae8d445954f354f7b17a8c5f4d8b8aa5f975aee0d13e17949b98] = [1, 8];
    hash[0xca8d38db94f1ddabe31a8b0f689377afb1509ac445f18ea2b0723a5d19174f34] = [1, 9];
    hash[0x06b2667c4d6344eb36393d686f76200e55bd29c26b27bbea1485c4afb6094859] = [1, 10];
    hash[0x601b99d17bc5ea40d718ebe705e3046b6162427330aee87ced176e47be138449] = [1, 11];
    hash[0xea7e899c4c7754f1d7c40c7bd0de238e95e3bf4f9b7e6efc23c4ce4cf5ff1fa7] = [1, 12];
    hash[0x1de2380ce2088a284a26a055d5108cace0d36c6aafe312b0ffb055f7ca01bd93] = [1, 13];
    hash[0x6efeb12dd823cecbbc575ecc27a842c58903fb7e76f66341c17cc51587d86e8a] = [1, 14];
    hash[0xe5792fbaa599a5f7b137ea1cb591ad35ae6fa481f4229e4252fa525884434a1b] = [1, 15];
    hash[0x8b73160c2504f73090c9de2d7dda01824f514bc6c89a26e30d2aa057b22ad407] = [2, 1];
    hash[0xf74b5c945f806e3a58c3607b41ac89513bb0a76037fd11f12f91decc0e0e023c] = [2, 2];
    hash[0x8258ed286b2e0a2f82eb2fffb95dc19a6e0d85b0854b07c68eb8f87daa9d90be] = [2, 3];
    hash[0x11b566097fbfbfdf6373cab7134f9bf877f07dc941e7856034c613f9b972519e] = [2, 4];
    hash[0x98c25258bcfcb3bd5550b7b89fb6e7a37fb78e75d736bb56830e9fcd6c7cf20f] = [2, 5];
    hash[0x3ef243edc9fef69435fc2afac31c3ae4fac94fb3a12efa1f8fc1d3f62d163f70] = [2, 6];
    hash[0xd662b5764c58def85c92eab1d151d86f80e4b1ef945c852edcbee76efe135264] = [2, 7];
    hash[0x6b40a68b1ce1a30a970d8138b2803b60c17716f9215f73432a7dc2184043b271] = [2, 8];
    hash[0xf7489aafe07e7da58dc4f4254fb98bd375d4425a3425e382bb77d0d6422bd2cf] = [2, 9];
    hash[0x2e6bd7702bfb8a711d189db3bf3ef13a8f79dfac24bb53fdbf6f4391f87fde75] = [2, 10];
    hash[0xca3173ccc54914f6dd159cd7ec7c23824eb2206b9510004225e5283fd35b3767] = [2, 11];
    hash[0x2d95d30c82291be829d3cdbc5a900d5bea0fb904af4486cd22bf52131e667f40] = [2, 12];
    hash[0x51f56564448417f4eb3426330ee9c841f189b218b561d79e7603ca22a33af7e4] = [2, 13];
    hash[0x6e5cb75c72b5c0ff65cf2ac92444ed08fbce78b64c03f16448a24bf84e5b98f3] = [2, 14];
    hash[0x9a8aefbf50e817ec7db55cf4efd83f20785e1d4a6d5c61568212fd10b41bdf92] = [2, 15];
    hash[0x46fc4408db0edf1ca2325ec01b1266f59a0e946028c463887facc5d5dd07b9d3] = [3, 1];
    hash[0xe7ec6b794e963619c488623d0d7040eb3fad9c2a6b91d18c14beee76e383dbab] = [3, 2];
    hash[0xb0d53fecb8acafefceef63b286aa5c3375f007929e2f5c496501c21443f545be] = [3, 3];
    hash[0xae43cf5b89644e0caaa1591c6a0916cfc50de19b502e30e50d68e11206c3e9d1] = [3, 4];
    hash[0x11e1cd50eaf9ac2883a01ad3a3fcc160eaf4c3a06ea2976eaa14b75f5ff2c024] = [3, 5];
    hash[0x8a8d21f2d9a79fafb7b6f9bd14c9296d129b8e4bac470b29225759ed8e0f859f] = [3, 6];
    hash[0x75d9e792250d57e609276a6516ba61424d521252990bec55d5724fb06072a7d0] = [3, 7];
    hash[0xa0083236c9f6cae9450aaa9f7f9a6918f345057d1f1122b1f97fa899a5989031] = [3, 8];
    hash[0x3db82c793795ba79df431b183748d83106bfd85edcbced03573adccb495511de] = [3, 9];
    hash[0xb62f1fe851692488a6845ed63e866f891a4eeb91fd8a9ec87513170337bd7ba9] = [3, 10];
    hash[0xc69e0adcfac78d15eb3a0ec4622abc22b8d88db566c7a8cd56eeb3722b082e80] = [3, 11];
    hash[0x891bd49b91cdff5b2315245fe1e7be3be044cc77b3fe08ad8744d1d994f6adc7] = [3, 12];
    hash[0x6639576139761058470a21f431daefbf2b4552a7c48fa1c16da6aaffeabcccf2] = [3, 13];
    hash[0xd7377ad97e0c88598cb682994fad3ea51d28a7edab4fc82a4183173eac48ba31] = [3, 14];
    hash[0x85d08abd638c71d32523dd363d58b9563979fe5ea3e7bf2f479c28f57aaaa22b] = [3, 15];
    hash[0xfae87677a1fcdba7fc43458b843bc5cfecfb2363d79d7721f6c709e63fa8bca0] = [4, 1];
    hash[0x10ff5a7eb5d504e0a8a7f10811ea493e8c6145c93f3638fbe59fb44fc00aa7d8] = [4, 2];
    hash[0xabd3d7bb5a6f0eac1718b5c89c21dc4ea69ffa348850bd677c1fa77049373530] = [4, 3];
    hash[0xad4ac5f32a2df2c318da7cdb2524f51d916064e9cc7ee8803b73864800c0f8eb] = [4, 4];
    hash[0x9dc9f37803962185bdbe014282c57f2a0d9c7f6624ebcf7e69cb84670c2f4a24] = [4, 5];
    hash[0xe84e475bc66e19c9b35dce8d3e0f0285b05fc9d4b1c455e43bba1ce4892d4644] = [4, 6];
    hash[0xe27f3e23ef8a79c99c4617f2cbafc1b643ec4fe8c5578f4813b3f78b937cdb2a] = [4, 7];
    hash[0x1f4fb1ef4093712affbe18edbffc1d2f490bbecf8a7659d8a89baa78264215dc] = [4, 8];
    hash[0x82568ff6a45fea73c8ea02270885d608a41e87133531d13aefb2bc96774adbcb] = [4, 9];
    hash[0x1d285af34198b494166bcb25b48bbbb990ef98e48d0d12f12fc43e4302b5a35c] = [4, 10];
    hash[0x3d017957551f5fd2a32774f3dcf9abf6a02bff1294904133a285cd904b908294] = [4, 11];
    hash[0xc3ffa70561b24549a49bd2f8262153a4bec7ce443ded3153a6de590a59c37027] = [4, 12];
    hash[0x144c64c41b8c86b14d16a2731f9a43c6ce25250a213e3021ee767ecfcac63594] = [4, 13];
    hash[0xc331cdccb173a7a9cd0f5a6f60f6e6d82020df78e334e9dc76c1c3f0ae383f87] = [4, 14];
    hash[0x15f30be11a1b1742b366e46e3145a2489aa0d3bfc697cf2381d7eee72d19f97f] = [4, 15];
  }

    function test() external view returns (address) {
        return owner();
    }

    function append(string memory a, string memory b, string memory c, string memory d) internal pure returns (string memory) {
      return string(abi.encodePacked(a, b, c, d));
    }

    function _checkValidity(string memory key1, string memory key2, string memory key3, string memory key4) internal returns(bool){

      bool isValid = false;

      bytes32[4] memory hashes = [
        sha256(abi.encodePacked(key1)),
        sha256(abi.encodePacked(key2)),
        sha256(abi.encodePacked(key3)),
        sha256(abi.encodePacked(key4))
      ];

      if(hash[hashes[0]][0] == 1){
        if(hash[hashes[1]][0] == 2){
          if(hash[hashes[2]][0] == 3){
            if(hash[hashes[3]][0] == 4){
              isValid = true;
            }
          }
        }
      }

      uint sum = 0;

      for(uint i = 0; i < 4; i++){
        sum += hash[hashes[i]][1];
      }

      if (sum != 30){
        isValid = false;
      }
      
      
      // string memory fullKey = sha256(abi.encodePacked(append(key1, key2, key3, key4)));

      return isValid;
    }

  function _setTier() internal{
    if(keysUsed == 100){ // tier 2
      zyzzPerRedeem = 50;
    } else if(keysUsed == 300){ // tier 3
      zyzzPerRedeem = 40;
    } else if(keysUsed == 500){ // tier 4
      zyzzPerRedeem = 30;
    } else if(keysUsed == 700){ // tier 5
      zyzzPerRedeem = 20;
    } else if(keysUsed == 800){ // tier 6
      zyzzPerRedeem = 10;
    } else if(keysUsed == 1200){ // tier 7, last 1000 drops are 5 Zyzz
      zyzzPerRedeem = 5; 
    }
  }

  function _sendAirdrop(address recipient) internal{
    _transfer(address(this), recipient, zyzzPerRedeem * 10 ** 18);
  }

  function redeem(string calldata key1, string calldata key2, string calldata key3, string calldata key4) external returns (bool) {
   
    if(_checkValidity(key1, key2, key3, key4)){
      _sendAirdrop(_msgSender());
       keysUsed+=1;
      _setTier();
    } else {
      revert("invalid key or empty");
    }

    return true;
  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  /**
   * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   *
   * Requirements
   *
   * - `msg.sender` must be the token owner
   */
  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
}