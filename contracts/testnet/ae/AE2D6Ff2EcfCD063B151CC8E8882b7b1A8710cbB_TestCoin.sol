contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract TestCoin is ERC20Detailed, Ownable {

    uint256 private constant DECIMALS = 18;
    uint256 private constant INITIAL_SUPPLY = 4 * 10**9 * 10**DECIMALS;
    mapping(address => uint256) private _Balances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    bool public initialDistributionFinished;

    mapping(address => bool) allowTransfer;
    mapping(address => bool) _isFeeExempt;

    modifier initialDistributionLock() {
        require(
            initialDistributionFinished ||
                isOwner() ||
                allowTransfer[msg.sender]
        );
        _;
    }

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 private _totalSupply;

    // Create ERC20 Token when creating This contract
    constructor() ERC20Detailed("Test Token", "TEST", uint8(DECIMALS)) {

        // Set inital total Supply
        _totalSupply = INITIAL_SUPPLY;
        // First set alloance at max
        _allowedFragments[msg.sender][address(this)] = type(uint256).max;

        // Set full balance to be owned by owner
        _Balances[msg.sender] = _totalSupply;

    }

    // Return total Supply
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    // transfer function
    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        initialDistributionLock
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount;
        //_Balances[from] = _Balances[from].sub(gonAmount);
        //_Balances[to] = _Balances[to].add(gonAmount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        
        return _basicTransfer(sender, recipient, amount);
    }


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        // if (_allowedFragments[from][msg.sender] != type(uint256).max) {
        //     _allowedFragments[from][msg.sender] = _allowedFragments[from][
        //         msg.sender
        //     ].sub(value, "Insufficient Allowance");
        // }

        _transferFrom(from, to, value);
        return true;
    }

    function balanceOf(address who) external view override returns (uint256) {
        return _Balances[who];
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function approve(address spender, uint256 value)
        external
        override
        initialDistributionLock
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

}