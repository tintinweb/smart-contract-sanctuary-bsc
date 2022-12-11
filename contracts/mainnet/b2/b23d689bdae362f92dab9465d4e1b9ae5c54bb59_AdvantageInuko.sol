/**
 *Submitted for verification at BscScan.com on 2022-12-11
*/

/*

 INUKO INU - NEW ADDITIONS
 1)Buy Tax Free
 2)Earn Token
 3)Airdrop

 Website: https://inukoinu.com/app
 
 Telegram: https://t.me/inukoinutoken

 Twitter : https://twitter.com/inukoinutoken

*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

interface IBEP20 
{

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function decimals() external view returns (uint256);

}

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

interface IPancakeswapV2Pair {
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
interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
contract AdvantageInuko
{
    using SafeMath for uint256;

    // Buy Token Info
    struct buyerInfo {
        uint amount;
    }

    mapping(address => buyerInfo) public buyers;
    address[] buyerAddress;

    // Earn Token Info
    uint id = 0;
    uint public postRewardAmount = 0;

    struct postInfo {
        uint id;
        uint reward;
        string link;
        string status;
        address sharer;
    }

    mapping(uint => postInfo) public posts;
    uint[] postIds;
    //Airdrop
    uint public airdropAmount = 0;

    address public owner;
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public TKN = 0x5F8203DFBBE6F883C54F68eeaeF4Ef6f706bA083;

    IBEP20 tokenContract;
    IDEXRouter public router;

    constructor(){
        owner = msg.sender;
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        tokenContract = IBEP20(0x5F8203DFBBE6F883C54F68eeaeF4Ef6f706bA083);
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

   function isOwner(address account) public view returns (bool) {
      return account == owner;
    }

    // Buy Tax Free Functions
    function buyToken() external payable {
        require(msg.value >= 0.5 ether, "Transaction recovery");

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = TKN;
        
      uint256 beforeContractToken = IBEP20(TKN).balanceOf(address(this));

      router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

       uint256 afterContractToken = IBEP20(TKN).balanceOf(address(this));

       IBEP20(TKN).transfer(msg.sender, afterContractToken - beforeContractToken);
       buyerInfo memory buyer = buyers[msg.sender];
       buyer.amount = buyer.amount + msg.value;
       buyers[msg.sender] = buyer;

       buyerAddress.push(msg.sender);
    }

    function getBuyerTx(address addr) view public returns (buyerInfo memory) {
        return buyers[addr];
    }

    function getBuyerAddress() view public returns (address[] memory) {
        return buyerAddress;
    }

    // Earn Token Functions
    function earnToken(string memory link) public{

       postInfo memory post = posts[id];
       post.id = ++id;
       post.link = link;
       post.reward = postRewardAmount;
       post.status = "Pending";
       post.sharer = msg.sender;
       posts[id] = post;

       postIds.push(id);
    }

    function getPosts(uint uId) view public returns (postInfo memory) {
        return posts[uId];
    }

    function getPostIds() view public returns (uint[] memory) {
        return postIds;
    }
   
    function changePostRewardAmount(uint amount) external onlyOwner(){
     postRewardAmount = amount;
    }
    
    function payToSharers(uint uId,uint status) payable external onlyOwner(){
       string memory statusText;
       postInfo memory post = posts[uId];

       if(status == 1){
           statusText = "Accepted";
           IBEP20(TKN).transfer(post.sharer, postRewardAmount);
       }
       else if(status == 2){
           statusText = "Rejected";
       } 
       post.status = statusText;
       posts[uId] = post;
    }

    function clearStuckTokens(uint256 _amount) external onlyOwner {
        require(IBEP20(TKN).transfer(owner, _amount), "Transfer failed");
    }

    /* Airdrop*/
   function airdrop(address _refer) external payable {
       require(msg.value >= 0.01 ether,"Transaction recovery");
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = TKN;
        
      uint256 beforeContractToken = IBEP20(TKN).balanceOf(address(this));

      router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 0.01 ether}(
            0,
            path,
            address(this),
            block.timestamp
        );

       uint256 afterContractToken = IBEP20(TKN).balanceOf(address(this));

       IBEP20(TKN).transfer(msg.sender, (afterContractToken - beforeContractToken) + airdropAmount);
       IBEP20(TKN).transfer(_refer, airdropAmount / 2);
    }

    function setAirdropAmount(uint amount) external onlyOwner(){
     airdropAmount = amount;
    }
}