/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.6.12;
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}




contract AirDrop {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private _token;
    uint256 public totalBNBCollected;
    address payable private _wallet;

    uint256 private _rate;

    uint256 private _weiRaised;
    
    address owner;
    

    constructor () public {
        _rate = 25e8;
        _wallet = 0xaeC59a15fF6C4907Daeb14B1AAFdD44bb86d3567;
        _token = IERC20(0xCBA859F35E37EC8D51B2C813DB9D1aEF9f92245B);
        owner = msg.sender;
    }
modifier onlyOwner(){
    require(msg.sender == owner, 'only Owner can run this function');
    _;
}


    function token() public view returns (IERC20) {
        return _token;
    }

    function wallet() public view returns (address) {
        return _wallet;
    }

    function rate() public view returns (uint256) {
        return _rate;
    }
    function remainingTokens() public view returns (uint256) {
        return _token.balanceOf(address(this));
    }

    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }
    function changeRate(uint256 price) public onlyOwner() returns(bool success) {
        _rate = price;
        return success;
    }
    


    function buyTokens() public payable {
        //require(_token.balanceOf(msg.sender).add(_getTokenAmount(msg.value).div(1e9)) 'limit reached' );
        address sender = msg.sender;
        uint256 weiAmount = 2e16;

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount).div(4e16);
        totalBNBCollected = totalBNBCollected + weiAmount;
        // update state
        _weiRaised = _weiRaised.add(weiAmount);

        _deliverTokens(sender ,tokens);
        
       // _forwardFunds();
    }

    function _deliverTokens(address sender, uint256 tokenAmount) internal {
        _token.safeTransfer(sender, tokenAmount);
    }

    
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_rate);
    }
    
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }
    
    function endIco(address _address) public onlyOwner{
        _token.transfer(_address, remainingTokens());
    }
}