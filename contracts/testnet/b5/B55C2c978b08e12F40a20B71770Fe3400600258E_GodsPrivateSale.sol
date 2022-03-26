/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    
    int256 constant private INT256_MIN = -2**255;

    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract GodsPrivateSale {
    using SafeMath for uint256;

    address public owner;
    address public wallet;
    bool public enabled;
    uint256 public godsPerBnb;
    uint256 public minPurchase;
    uint256 public totalRaised;
    uint256 public fundingTarget;

    mapping(address => uint256) public purchases;
    address[] public purchasers;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "no permissions");
        _;
    }
       
    modifier isEnabled() {
        require(enabled, "sale not enabled");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        wallet = 0x545933b8FA2C6603c2f79D8Ef835671Dda2f68ec;

        godsPerBnb = 100;
        minPurchase = 100;
        fundingTarget = 112 * 10 ** 18;
    }
    
    function userStatus() public view returns (
            bool saleEnabled,
            uint256 godsPrice,
            uint256 raised,
            uint256 target
        ) {
        saleEnabled = enabled;
        godsPrice = godsPerBnb;
        raised = totalRaised;
        target = fundingTarget;
    }
    
    function exchange() payable public isEnabled {
        uint256 receivedGods = msg.value.mul(godsPerBnb).div(100);
        require(msg.value >= minPurchase, "minimum spend not met");
        totalRaised = totalRaised.add(msg.value);
        payable(wallet).transfer(msg.value);

        if (purchases[msg.sender] == 0) {
            purchasers.push(msg.sender);
        }
        purchases[msg.sender] += receivedGods;
    }
   
    // Admin methods
    function changeOwner(address who) external onlyOwner {
        require(who != address(0), "cannot be zero address");
        owner = who;
    }
    
    function changeWallet(address who) external onlyOwner {
        require(who != address(0), "cannot be zero address");
        wallet = who;
    }

    function enableSale(bool enable) external onlyOwner {
        enabled = enable;
    }

    function removeBnb() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }
    
    function transferTokens(address token, address to) external onlyOwner returns(bool){
        uint256 balance = IERC20(token).balanceOf(address(this));
        return IERC20(token).transfer(to, balance);
    }
    
   function editMinPurchase(uint256 min) external onlyOwner {
        minPurchase = min;
    }

    function editTarget(uint256 target) external onlyOwner {
        fundingTarget = target;
    }

    function airDrop(address tokenAddress) external onlyOwner {   
        IERC20 godsToken = IERC20(tokenAddress);
        for (uint256 i = 0; i < purchasers.length; i++) {
            godsToken.transfer(purchasers[i], purchases[purchasers[i]]);
        }
    }
}