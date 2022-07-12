/**
 *Submitted for verification at BscScan.com on 2022-07-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
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

contract ERC20 is IERC20 {
    using SafeMath for uint256;
    address private _owner; //owner
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;
    uint256 private _totalSupply;
    uint256 private _cap;
    bool public paused = true;
    mapping(address => bool) private _minters;

    event Pause();
    event Unpause();
    event MinterAdd(address indexed account);
    event MinterRemove(address indexed account);

    constructor(uint256 c) {
        _owner = msg.sender;
        _cap = c;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) _owner = newOwner;
    }

    modifier isNotPaused() {
        require(!paused);
        _;
    }

    modifier isPaused() {
        require(paused);
        _;
    }

    function pause() public onlyOwner {
        require(!paused);
        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner {
        require(paused);
        paused = false;
        emit Unpause();
    }

    function addMinter(address account) public onlyOwner {
        require(!isMinter(account));
        _minters[account] = true;
        emit MinterAdd(account);
    }

    function removeMinter(address account) public onlyOwner {
        require(isMinter(account));
        _minters[account] = false;
        emit MinterRemove(account);
    }

    function isMinter(address account) internal view returns (bool) {
        require(account != address(0));
        return _minters[account];
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function cap() public view returns (uint256) {
        return _cap;
    }

    function increaseCap(uint256 addedValue) public onlyOwner returns (bool) {
        _cap = _cap.add(addedValue);
        return true;
    }

    function decreaseCap(uint256 addedValue) public onlyOwner returns (bool) {
        _cap = _cap.sub(addedValue);
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view override returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        isNotPaused
        returns (uint256)
    {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value)
        public
        override
        isNotPaused
        returns (bool)
    {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value)
        public
        override
        isNotPaused
        returns (bool)
    {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override isNotPaused returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    function mint(address to, uint256 value) public onlyMinter returns (bool) {
        _mint(to, value);
        return true;
    }

    function burn(uint256 value) public isNotPaused returns (bool) {
        _burn(msg.sender, value);
        return true;
    }

    function burnFrom(address from, uint256 value)
        public
        isNotPaused
        returns (bool)
    {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _burn(from, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {
        require(to != address(0));
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0));
        require(_totalSupply.add(value) <= _cap);

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
}

contract XNBCT is ERC20 {
    string public constant name = "NatureBaseCarbonTokenTestnet";
    string public constant symbol = "XNBCT";
    uint8 public constant decimals = 18;

    constructor(uint256 c) ERC20(c) {}
}