/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

pragma solidity 0.8.0;

// SPDX-License-Identifier: UNLICENSED


/**

 * @title TRC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface ITRC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */

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

    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);

        uint256 c = a - b;

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

    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);

        return a % b;
    }
}

/**

 * @title Standard TRC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood:

 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 *

 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for

 * all accounts just by listening to said events. Note that this isn't required by the specification, and other

 * compliant implementations may not do it.

 */



contract ownable  {
    /**

    * @dev Event to show ownership has been transferred

    * @param previousOwner representing the address of the previous owner

    * @param newOwner representing the address of the new owner

    */

    event OwnershipTransferred(address previousOwner, address newOwner);

    address ownerAddress;

    constructor()  {
        ownerAddress = msg.sender;
    }

    /**

    * @dev Throws if called by any account other than the owner.

    */

    modifier onlyOwner() {
        require(msg.sender == owner());

        _;
    }

    /**

    * @dev Tells the address of the owner

    * @return the address of the owner

    */

    function owner() public view returns (address) {
        return ownerAddress;
    }

    /**

    * @dev Allows the current owner to transfer control of the contract to a newOwner.

    * @param newOwner the address to transfer ownership to.

    */

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));

        setOwner(newOwner);
    }

    /**

    * @dev Sets a new owner address

    */

    function setOwner(address newOwner) internal {
        emit OwnershipTransferred(owner(), newOwner);

        ownerAddress = newOwner;
    }
}

contract Verifier {
    function recoverAddr(
        bytes32 msgHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public pure returns (address) {
        return ecrecover(msgHash, v, r, s);
    }

    function isSigned(
        address _addr,
        bytes32 msgHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public pure returns (bool) {
        return ecrecover(msgHash, v, r, s) == _addr;
    }
}

contract Yeep_ule_withdraw is ownable, Verifier {
    using SafeMath for uint256;

    address public trc20token;
    address signatureAddress;

    ITRC20 _WYZTH;

    event Transfer(address from, address to, uint256 amount);

    constructor(ITRC20 _tokenaddress, address _sigAddress)  {
        _WYZTH = _tokenaddress;
        signatureAddress = _sigAddress;
    }

    // event Multisended(uint256 total, address tokenAddress);

    struct User {
        uint256 amount;
        uint256 tokenAmount;
    }

    mapping(address => User) public Users;
    mapping(bytes32 => mapping(uint256 => bool)) public seenNonces;



    function withDraw(uint256 _amount) external onlyOwner {
        payable(msg.sender).transfer(_amount * 1000000);
    }

    function getTokens(uint256 _amount) external onlyOwner {
        _WYZTH.transfer(address(this), _amount * 1000000);
    }

    function userTokenWithdraw(
        uint256 amount,
        uint256 nonce,
        bytes32[] memory msgHash_r_s,
        uint8 v
    ) public {
        // Signature Verification
        require(
            isSigned(
                signatureAddress,
                msgHash_r_s[0],
                v,
                msgHash_r_s[1],
                msgHash_r_s[2]
            ),
            "Signature Failed"
        );
        // Duplication check
        require(seenNonces[msgHash_r_s[0]][nonce] == false);
        seenNonces[msgHash_r_s[0]][nonce] = true;
        // Token Transfer
        _WYZTH.transfer(msg.sender, amount);
        emit Transfer(address(this), msg.sender, amount);
    }

    function userTRXWithdraw(
        uint256 amount,
        uint256 nonce,
        bytes32[] memory msgHash_r_s,
        uint8 v
    ) public {
        // Signature Verification
        require(
            isSigned(
                signatureAddress,
                msgHash_r_s[0],
                v,
                msgHash_r_s[1],
                msgHash_r_s[2]
            ),
            "Signature Failed"
        );
        // Duplication check
        require(seenNonces[msgHash_r_s[0]][nonce] == false);
        seenNonces[msgHash_r_s[0]][nonce] = true;
        // TRX Transfer
        payable(msg.sender).transfer(amount);
        emit Transfer(address(this), msg.sender, amount);
    }
    
    function changeSigAddress(address _sigAddress) public onlyOwner {
        signatureAddress = _sigAddress;
    }
}