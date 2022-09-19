/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-14
 */

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed from, address indexed to);

    /**
     * Constructor assigns ownership to the address used to deploy the contract.
     * */
    constructor() {
        owner = msg.sender;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    /**
     * Any function with this modifier in its method signature can only be executed by
     * the owner of the contract. Any attempt made by any other account to invoke the
     * functions with this modifier will result in a loss of gas and the contract's state
     * will remain untampered.
     * */
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Function restricted to owner of contract"
        );
        _;
    }

    /**
     * Allows for the transfer of ownership to another address;
     *
     * @param _newOwner The address to be assigned new ownership.
     * */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(
            _newOwner != address(0) && _newOwner != owner,
            "New owner can't be the zero address or the old owner"
        );
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

abstract contract ERCInterface {
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public virtual;

    function balanceOf(address who) public virtual returns (uint256);

    function allowance(address owner, address spender)
        public
        view
        virtual
        returns (uint256);

    function transfer(address to, uint256 value) public virtual returns (bool);
}

contract MultiSender is Ownable {
    using SafeMath for uint256;

    event TokenAirdrop(
        address indexed by,
        address indexed tokenAddress,
        uint256 totalTransfers
    );

    event EthAirdrop(
        address indexed by,
        uint256 totalTransfers,
        uint256 ethValue
    );

    event RefundIssued(address indexed to, uint256 totalWei);
    event ERC20TokensWithdrawn(address token, address sentTo, uint256 value);

    /**
     * Allows for the allowance of a token from its owner to this contract to be queried.
     * */
    function getTokenAllowance(address _addr, address _addressOfToken)
        public
        view
        returns (uint256)
    {
        ERCInterface token = ERCInterface(_addressOfToken);
        return token.allowance(_addr, address(this));
    }

    fallback() external payable {
        revert("Native tokens received in fallback method");
    }

    receive() external payable {
        revert("Native tokens received in fallback method");
    }

    /**
     * Checks if two strings are the same.
     **/
    function stringsAreEqual(string memory _a, string memory _b)
        internal
        pure
        returns (bool)
    {
        bytes32 hashA = keccak256(abi.encodePacked(_a));
        bytes32 hashB = keccak256(abi.encodePacked(_b));
        return hashA == hashB;
    }

    /**
        Function that allows airdropping eth to multiple recipients with a constant value.
     * */
    function singleValueEthAirdrop(address[] memory _recipients, uint256 _value)
        public
        payable
        returns (bool)
    {
        uint256 totalCost = _value.mul(_recipients.length);

        require(
            msg.value == totalCost,
            "Not enough ETH sent with transaction!"
        );

        for (uint256 i = 0; i < _recipients.length; i++) {
            if (_recipients[i] != address(0)) {
                payable(_recipients[i]).transfer(_value);
            }
        }

        emit EthAirdrop(
            msg.sender,
            _recipients.length,
            _value.mul(_recipients.length)
        );

        return true;
    }

    function _getTotalEthValue(uint256[] memory _values)
        internal
        pure
        returns (uint256)
    {
        uint256 totalVal = 0;
        for (uint256 i = 0; i < _values.length; i++) {
            totalVal = totalVal.add(_values[i]);
        }
        return totalVal;
    }

    /**
        Function that allows airdropping eth to multiple recipients with a each having a different value.
     * */
    function multiValueEthAirdrop(
        address[] memory _recipients,
        uint256[] memory _values
    ) public payable returns (bool) {
        require(
            _recipients.length == _values.length,
            "Total number of recipients and values are not equal"
        );

        uint256 totalEthValue = _getTotalEthValue(_values);

        require(
            msg.value == totalEthValue,
            "Not enough ETH sent with transaction!"
        );

        for (uint256 i = 0; i < _recipients.length; i++) {
            if (_recipients[i] != address(0) && _values[i] > 0) {
                payable(_recipients[i]).transfer(_values[i]);
            }
        }

        emit EthAirdrop(msg.sender, _recipients.length, totalEthValue);
        return true;
    }

    /**
        Function that allows airdropping ERC20 tokens to multiple recipients with a constant value.
     * */
    function singleValueTokenAirdrop(
        address _addressOfToken,
        address[] calldata _recipients,
        uint256 _value
    ) public returns (bool) {
        ERCInterface token = ERCInterface(_addressOfToken);

        for (uint256 i = 0; i < _recipients.length; i++) {
            if (_recipients[i] != address(0)) {
                token.transferFrom(msg.sender, _recipients[i], _value);
            }
        }

        emit TokenAirdrop(msg.sender, _addressOfToken, _recipients.length);
        return true;
    }

    /**
        Function that allows airdropping ERC20 tokens to multiple recipients with differing values
     * */
    function multiValueTokenAirdrop(
        address _addressOfToken,
        address[] calldata _recipients,
        uint256[] calldata _values
    ) public returns (bool) {
        ERCInterface token = ERCInterface(_addressOfToken);
        require(
            _recipients.length == _values.length,
            "Total number of recipients and values are not equal"
        );

        for (uint256 i = 0; i < _recipients.length; i++) {
            if (_recipients[i] != address(0) && _values[i] > 0) {
                token.transferFrom(msg.sender, _recipients[i], _values[i]);
            }
        }

        emit TokenAirdrop(msg.sender, _addressOfToken, _recipients.length);
        return true;
    }

    /**
     * Allows for any ERC20 tokens which have been mistakenly  sent to this contract to be returned
     * to the original sender by the owner of the contract. Any attempt made by any other account
     * to invoke the function will result in a loss of gas and no tokens will be transferred out.
     * */
    function withdrawERC20Tokens(
        address _addressOfToken,
        address _recipient,
        uint256 _value
    ) public onlyOwner returns (bool) {
        require(
            _addressOfToken != address(0) &&
                _recipient != address(0) &&
                _value > 0,
            "Address/recipient/value can't be zero"
        );
        ERCInterface token = ERCInterface(_addressOfToken);
        token.transfer(_recipient, _value);
        emit ERC20TokensWithdrawn(_addressOfToken, _recipient, _value);
        return true;
    }
}