/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

library SafeMath {
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
        require(c / a == b,"Invalid values");
        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0,"Invalid values");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a,"Invalid values");
        uint256 c = a - b;
        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a,"Invalid values");
        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0,"Invalid values");
        return a % b;
    }
}

contract OperonGame is IERC20 {
    using SafeMath for uint256;
    address public sigAddress;
    IERC20 public ZORO;
    mapping(bytes32 => bool) public hashConfirmation;
    event Claim(
        address indexed from,
        address indexed to,
        uint256 value,
        bytes32 hashConfirmation
    );

    constructor(address _zoro){
        ZORO = IERC20(_zoro);
        sigAddress = msg.sender;
    }


    function claimToken(
        address to,
        uint256 amount,
        bytes32[3] calldata _mrs,
        uint8 _v
    ) public payable returns(uint _value){
        require(hashConfirmation[_mrs[0]] != true, "Hash exists");
        require(
            ecrecover(_mrs[0], _v, _mrs[1], _mrs[2]) == sigAddress,
            "Invalid Signature"
        );
        require(balanceOf(address(this))>0,"no balance in Contract");
        uint value;
        bool success;
        if(balanceOf(address(this))>amount){
        (success)=transfer(to, amount);
        }else{
        value = balanceOf(address(this));
        (success)=transfer(to, amount);
        }
        require(success,"transaction failed");
        hashConfirmation[_mrs[0]] = true;
        emit Claim(address(this), to, amount, _mrs[0]);
        return _value;
    }


    function transfer(address to, uint256 value) public virtual override returns (bool){
        ZORO.transfer(to,value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual override returns (bool){

    }

    function balanceOf(address who) public virtual override view returns (uint256){
       return ZORO.balanceOf(who);
    }


}