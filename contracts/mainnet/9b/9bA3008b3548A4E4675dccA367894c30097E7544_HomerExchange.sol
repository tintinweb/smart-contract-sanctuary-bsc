/**
 *Submitted for verification at BscScan.com on 2022-08-23
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

contract HomerExchange {
    using SafeMath for uint256;

    address public owner;
    bool public enabled;
    address public fromTokenAddress;
    address public toTokenAddress;

    IERC20 private _fromToken;
    IERC20 private _toToken;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "no permissions");
        _;
    }
       
    modifier isEnabled() {
        require(enabled, "Exchange not enabled");
        _;
    }
    
    constructor() {
        owner = 0xABe96E7d756f251C48B869EE0aE9893be8A66097;
        fromTokenAddress = 0x4c4da68D45F23E38ec8407272ee4f38F280263c0;
        toTokenAddress = 0x06f7f4d2AB6A88ff5aFE37D2266A55f9E8F3D11E;

        _fromToken = IERC20(fromTokenAddress);
        _toToken = IERC20(toTokenAddress);
    }
    
    function status() public view returns (
            bool exchangeEnabled,
            address fromToken,
            address toToken,
            uint256 balance,
            uint256 approved,
            uint256 availableToken
        ) {
        exchangeEnabled = enabled;
        fromToken = fromTokenAddress;
        toToken = toTokenAddress;
        balance = _fromToken.balanceOf(msg.sender);
        approved = _fromToken.allowance(msg.sender, address(this));
        availableToken = _toToken.balanceOf(address(this));
    }
    
    function exchange(uint256 amount) external isEnabled {
        require(_fromToken.allowance(msg.sender, address(this)) >= amount, "Insufficient tokens approved");
        require(_fromToken.transferFrom(msg.sender, address(this), amount), "Unable to retrieve tokens");
        require(_toToken.transfer(msg.sender, amount), "Unable to exchange tokens");
    }
   
    // Admin methods
    function setOwner(address who) external onlyOwner {
        require(who != address(0), "cannot be zero address");
        owner = who;
    }
    
    function setEnabled(bool enable) external onlyOwner {
        enabled = enable;
    }

    function setFromToken(address fromToken) external onlyOwner {
        fromTokenAddress = fromToken;
        _fromToken = IERC20(fromTokenAddress);
    }

    function setToToken(address toToken) external onlyOwner {
        toTokenAddress = toToken;
        _toToken = IERC20(toTokenAddress);
    }

    function removeBnb() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }
    
    function removeTokens(address token) external onlyOwner returns(bool){
        uint256 balance = IERC20(token).balanceOf(address(this));
        return IERC20(token).transfer(owner, balance);
    }
}