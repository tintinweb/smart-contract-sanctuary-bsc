/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

//SPDX-License-Identifier: MIT
contract StakeTokenV2 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public excluded;

    uint256 public transferTax = 10;

    uint256 private _totalSupply;

    string private constant _name = "Stake V2";
    string private constant _symbol = "$STAKE_V2";
    uint8 private constant _decimals = 18;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    address public _faucet;
    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Excluded(address indexed user, bool value);
    event OwnershipTransferred(
        address indexed prevOwner,
        address indexed newOwner
    );

    modifier onlyFaucet() {
        require(
            msg.sender == _faucet && msg.sender != address(0),
            "Not Faucet"
        );
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        _mint(owner, 750_000 ether);
        changeExcludeStatus(owner, true);
    }

    // Redefining Ownable Here

    function balanceOf(address _user) public view returns (uint256) {
        return _balances[_user];
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // Define Transfer
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(to != address(0) && from != address(0), "Zero"); // Cant transfer to/from zero address
        _balances[from] -= amount; // uint underflow prevents spending more than the user has
        uint256 _totalTransfered = amount;
        if (!excluded[from] && !excluded[to]) {
            uint256 burnTax = (amount * transferTax) / 100;
            _totalTransfered -= burnTax;
            _totalSupply -= burnTax;
            emit Transfer(from, address(0), burnTax);
        }
        _balances[to] += _totalTransfered;
        emit Transfer(from, to, _totalTransfered);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(
            _allowances[from][msg.sender] >= value,
            "Insufficient Allowance"
        );
        _allowances[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }

    // Define approve
    function approve(address spender, uint256 value) public returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // Define increaseAllowance
    function increaseAllowance(address spender, uint256 value)
        public
        returns (bool)
    {
        _allowances[msg.sender][spender] += value;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    // Define decreaseAllowance
    function decreaseAllowance(address spender, uint256 value)
        public
        returns (bool)
    {
        _allowances[msg.sender][spender] -= value;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    // Define allowance
    function allowance(address holder, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    // Define Mint
    function _mint(address _to, uint256 value) private {
        _balances[_to] += value;
        _totalSupply += value;
        emit Transfer(address(0), _to, value);
    }

    function _burn(address _from, uint256 value) private {
        _balances[_from] -= value;
        _totalSupply -= value;
        emit Transfer(_from, address(0), value);
    }

    function mint(address to, uint256 value) public onlyFaucet {
        _mint(to, value);
    }

    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    function burnFrom(address from, uint256 value) public {
        require(
            _allowances[from][msg.sender] >= value,
            "Insufficient allowance"
        );
        _allowances[from][msg.sender] -= value;
        _burn(from, value);
    }

    function changeExcludeStatus(address _user, bool _status) public onlyOwner {
        excluded[_user] = _status;
        emit Excluded(_user, _status);
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0) && _newOwner != DEAD, "Call renounce");
        emit OwnershipTransferred(owner, _newOwner);
        excluded[owner] = false;
        owner = _newOwner;
        excluded[owner] = true;
    }

    function renounceOwnership() external onlyOwner {
        changeExcludeStatus(owner, false);
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function setFaucet(address faucetAddress) external onlyOwner {
        require(faucetAddress != owner, "Cant be owner");
        changeExcludeStatus(_faucet, false);
        _faucet = faucetAddress;
        changeExcludeStatus(_faucet, true);
    }
}