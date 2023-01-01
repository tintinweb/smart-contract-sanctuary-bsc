// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./PauseControl.sol";

contract DryadToken is PauseControl {
    struct tokenProperties {
        uint256 totalSupply;
        string name;
        string symbol;
        string standard;
        uint8 decimals;
        bool paused;
    }

    mapping(address => uint256) private bal;
    mapping(address => mapping(address => uint256)) private allow;
    tokenProperties private properties;

    constructor(
        uint256 _initialSupply,
        string memory _name,
        string memory _symbol,
        string memory _standard,
        uint8 _decimals,
        bool _paused
    ) {
        properties.totalSupply = _initialSupply * (10**_decimals);
        bal[msg.sender] = properties.totalSupply;
        properties.name = _name;
        properties.symbol = _symbol;
        properties.standard = _standard;
        properties.decimals = _decimals;
        properties.paused = _paused;
        _pauseAdmin(msg.sender);

        if (properties.paused) {
            _pauseControl(properties.paused);
        } 
    }
    function allowance(address _owner, address _spender)
        public
        view
        whenNotpaused
        returns (uint256)
    {
        return allow[_owner][_spender];
    }

    //token properties
    function totalSupply() public view returns (uint256) {
        return properties.totalSupply;
    }

    function balanceOf(address _owner)
        public
        view
        whenNotpaused
        returns (uint256 balance)
    {
        return bal[_owner];
    }

    function name() public view  returns (string memory) {
        return properties.name;
    }

    function symbol() public view returns (string memory) {
        return properties.symbol;
    }

    function standard() public view whenNotpaused returns (string memory) {
        return properties.standard;
    }

    function decimals() public view returns (uint8) {
        return properties.decimals;
    }

    //token evens
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    event Mint(address indexed _to, uint256 _value);
    event Burn(address indexed _from, uint256 _value);

    //token methods
    function transfer(address _to, uint256 _value)
        public
        whenNotpaused
        returns (bool success)
    {
        require(balanceOf(msg.sender) >= _value);
        bal[msg.sender] -= _value;
        bal[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        whenNotpaused
        returns (bool success)
    {
        allow[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public whenNotpaused returns (bool success) {
        require(_value <= balanceOf(_from));
        require(_value <= allowance(_from, msg.sender));
        bal[_from] -= _value;
        bal[_to] += _value;
        allow[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    //advanced
    function mint(uint32 _value)
        public
        whenNotpaused
        onlyRole(_minter())
        returns (bool success)
    {
        properties.totalSupply += _value;
        bal[msg.sender] += _value;
        emit Mint(msg.sender, _value);
        return true;
    }

    function mintTo(address _to, uint32 _value)
        public
        whenNotpaused
        onlyRole(_minter())
    {
        properties.totalSupply += _value;
        bal[_to] += _value;
        emit Mint(_to, _value);
    }

    function burn(uint32 _value)
        public
        whenNotpaused
        onlyRole(_burner())
    {
        require(balanceOf(msg.sender) >= _value);
        properties.totalSupply -= _value;
        bal[msg.sender] -= _value;
        emit Mint(msg.sender, _value);
    }

    function burnFrom(address _from, uint32 _value)
        public
        whenNotpaused
        onlyRole(_burner())
    {
        properties.totalSupply += _value;
        bal[_from] -= _value;
        emit Burn(_from, _value);
    }
     
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./AccessControl.sol";

contract PauseControl is AccessControl {
    bool private paused = false;

    constructor() {
       
    }

    modifier whenNotpaused() {
        require(!paused, "Token is paused");
        _;
    }
    modifier whenPaused() {
        require(paused, "Token is not paused");
        _;
    }

    event Paused(address indexed _pauser, bool paused);

    function _pauseAdmin(address _adminPauser) internal{
        _grantRole(_admin(), _adminPauser);
    }

    function _pauseControl (bool _paused) internal{
        paused = _paused;
    }
    
    function pause()
        external
        whenNotpaused
        onlyRole(_pauser())
    {
        paused = true;
        emit Paused(msg.sender, true);
    }

    function unPause()
        external
        whenPaused
        onlyRole(_pauser())
    {
        paused = false;
        emit Paused(msg.sender, false);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract AccessControl {
    event GrantRole(bytes32 indexed _role, address indexed _account);
    event RevokeRole(bytes32 indexed _role, address indexed _account);

    mapping(bytes32 => mapping(address => bool)) private rol;

    bytes32 private constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    bytes32 private constant USER = keccak256(abi.encodePacked("USER"));
    bytes32 private constant MINTER = keccak256(abi.encodePacked("MINTER"));
    bytes32 private constant BURNER = keccak256(abi.encodePacked("BURNER"));
    bytes32 private constant PAUSER = keccak256(abi.encodePacked("PAUSER"));

    constructor() {}

    modifier onlyRole(bytes32 _role) {
        require(rol[_role][msg.sender], "No Authorized");
        _;
    }

    function _grantRole(bytes32 _role, address _account) internal {
        if (_role == ADMIN) {
            rol[ADMIN][_account] = true;
            rol[USER][_account] = true;
            rol[BURNER][_account] = true;
            rol[MINTER][_account] = true;
            rol[PAUSER][_account] = true;
        } else {
            rol[_role][_account] = true;
        }
        emit GrantRole(_role, _account);
    }

    function grantRole(bytes32 _role, address _account)
        external
        onlyRole(ADMIN)
    {
        _grantRole(_role, _account);
    }

    function revoketRole(bytes32 _role, address _account)
        external
        onlyRole(ADMIN)
    {
        if (_role == ADMIN) {
            rol[ADMIN][_account] = false;
            rol[USER][_account] = false;
            rol[BURNER][_account] = false;
            rol[MINTER][_account] = false;
            rol[PAUSER][_account] = false;
        } else {
            rol[_role][_account] = true;
        }
        emit RevokeRole(_role, _account);
    }

    function _admin() internal pure returns (bytes32) {
        return ADMIN;
    }

    function _user() internal pure returns (bytes32) {
        return USER;
    }

    function _minter() internal pure returns (bytes32) {
        return MINTER;
    }

    function _burner() internal pure returns (bytes32) {
        return BURNER;
    }

    function _pauser() internal pure returns (bytes32) {
        return PAUSER;
    }
}