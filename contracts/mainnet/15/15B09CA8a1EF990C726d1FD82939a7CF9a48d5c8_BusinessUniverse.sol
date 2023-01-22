/**
 *Submitted for verification at BscScan.com on 2023-01-22
*/

// File: asdas.sol

/**
 *Submitted for verification at BscScan.com on 2023-01-22
*/

// File: wbt.sol

/**
 *Submitted for verification at Etherscan.io on 2022-11-12
*/

// File: contracts/Ownable.sol


pragma solidity =0.8.12;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), 'Available only for owner');
        _;
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function isOwner(address userAddress) public view returns (bool) {
        return userAddress == _owner;
    }

    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// File: contracts/BlackList.sol


pragma solidity =0.8.12;


contract BlackList is Ownable {

    mapping(address => bool) _blacklist;

    function isBlacklisted(address _maker) public view returns (bool) {
        return _blacklist[_maker];
    }

    function blacklistAccount(address account, bool sign) external onlyOwner {
        _blacklist[account] = sign;
    }
}
// File: contracts/Pausable.sol


pragma solidity =0.8.12;


contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() onlyOwner whenNotPaused external {
        paused = true;
        emit Pause();
    }

    function unpause() onlyOwner whenPaused external {
        paused = false;
        emit Unpause();
    }
}
// File: contracts/IERC20.sol


pragma solidity =0.8.12;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256) ;

    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function decreaseAllowance(address spender,uint256 subtractedValue) external returns (bool);
    function increaseAllowance(address spender,uint256 addedValue) external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event DestroyedBlackFunds(
        address indexed blackListedUser,
        uint balance
    );
}
// File: contracts/ERC20.sol


pragma solidity =0.8.12;





contract ERC20 is IERC20, BlackList, Pausable {
    address public marketingAddress = 0xE7628a97fF7fBEf3277f96E19577b157440e5C98;
    uint public marketingFee = 40;
    uint public holdersFee =40 ;
    uint public burnFee =20 ;
    uint public feeAmount = 5;
    address public claimAddress = 0xa9e6F292e9863c174EF5c7b1476b43c1C7311875;

    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    address public routerAddress;
    address public pairAddress;
    address[] public holders;
    mapping (address => bool) holderss;



    mapping(address => uint256) public _holderBalances;

    mapping (address => uint256) _balances;

    mapping (address => mapping (address => uint256)) _allowed;

    uint256 internal _totalSupply;
    event HolderAdded(address indexed hodler);
    event HolderRemoved(address indexed hodler);


    function totalSupply() external view override virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address user) external view override returns (uint256) {
        return _balances[user];
    }

    function allowance(address user, address spender) external view returns (uint256) {
        return _allowed[user][spender];
    }
    function addWhitelist(address _address) external onlyOwner {
        holderss[_address] = true;
    }
    function removeWhitelist(address _address) external onlyOwner {
        holderss[_address] = false;
    }
    
    function isWhitelisted(address _address) external view returns (bool) {
        return holderss[_address];
    }

    function approve(address spender, uint256 value) external returns (bool) {
        require(spender != address(0));
        require(msg.sender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);

        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) external returns (bool)
    {
        require(spender != address(0), 'Spender zero address prohibited');
        require(msg.sender != address(0), 'Zero address could not call method');

        _allowed[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;
    }
    
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) external returns (bool)
    {
        require(spender != address(0), 'Spender zero address prohibited');
        require(msg.sender != address(0), 'Zero address could not call method');

        _allowed[msg.sender][spender] -= subtractedValue;
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(value <= _allowed[from][msg.sender], 'Not allowed to spend');
        _transfer(from, to, value);
        _allowed[from][msg.sender] -= value;

        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);

        return true;
    }
    function setMarketingAddress(address _marketingAddress) external onlyOwner {
        marketingAddress = _marketingAddress;
    }
    function setBurnAddress(address _burnAddress) external onlyOwner {
        burnAddress = _burnAddress;
    }
    function setMarketingFee(uint _marketingFee) external onlyOwner {
        marketingFee = _marketingFee;
    }
    function setHoldersFee(uint _holdersFee) external onlyOwner {
        holdersFee = _holdersFee;
    }
    function setClaimAddress(address _claimAddress) external onlyOwner {
        claimAddress = _claimAddress;
    }
    function setBurnFee(uint _burnFee) external onlyOwner {
        burnFee = _burnFee;
    }
    function setFeeAmount(uint _feeAmount) external onlyOwner {
        feeAmount = _feeAmount;
    }
    function setRouterAddress(address _routerAddress) external onlyOwner {
        routerAddress = _routerAddress;
    }
    function setPairAddress(address _pairAddress) external onlyOwner {
        pairAddress = _pairAddress;
    }
    function airdropHolders(address[] memory _addresses, uint256[] memory _amounts) external onlyOwner {
        require(_addresses.length == _amounts.length, 'Arrays length must be equal');
        for (uint i = 0; i < _addresses.length; i++) {
            _transfer(msg.sender, _addresses[i], _amounts[i]);
        }
    }
    function holderList(address[] memory _addresses) external onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            holderss[_addresses[i]] = true;
            emit HolderAdded(_addresses[i]);
        }
    }
    function addHolder(address _holder) external onlyOwner {
    require(_holder != address(0), "Cannot add zero address as a holder");
    holderss[_holder] = true;
    emit HolderAdded(_holder);
    }

function removeHolder(address _holder) external onlyOwner {
    require(_holder != address(0), "Cannot remove zero address from holders");
    holderss[_holder] = false;
    emit HolderRemoved(_holder);
    }

    function isHolder(address _holder) public view returns (bool) {
    return holderss[_holder];
    }

    function distributeHoldersFee(address[] memory holders, uint256 value) internal {
    uint256 totalHolders = ERC20.holders.length;
    for (uint256 i = 0; i < ERC20.holders.length; i++) {
        _holderBalances[ERC20.holders[i]] += value / totalHolders;
    }
    }


    function _transfer(address from, address to, uint256 value) internal whenNotPaused {
        require(!isBlacklisted(from), 'Sender address in blacklist');
        require(!isBlacklisted(to), 'Receiver address in blacklist');
        require(to != address(0), 'Zero address can not be receiver');
        if (to == routerAddress || to == pairAddress) {
            uint256 fee = (value /100) * feeAmount ;
            uint256 softValue = value - fee;
            uint256 marketingPerc = (fee / 100)* (marketingFee);
            uint256 marketingValue = (fee - marketingPerc);
            uint256 burnPerc = (fee / 100)* (burnFee);
            uint256 burnValue = (fee - burnPerc);
            uint256 holdersPerc = (fee / 100)* (holdersFee);
            uint256 holdersValue = (fee - holdersPerc);

            _balances[claimAddress] += holdersValue;
            _balances[burnAddress] += burnValue;
            _balances[marketingAddress] += marketingValue;
            _balances[from] -= value;
            _balances[to] += softValue;
            emit Transfer(from, to, softValue);
        } else {
                _balances[from] -= value;
                _balances[to] += value;
                emit Transfer(from, to, value);
        }


    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply += value;
        _balances[account] += value;
        emit Transfer(address(0), account, value);
    }

    function burn(uint256 amount) external onlyOwner() virtual {
        _burn(msg.sender, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply -= value;
        _balances[account] -= value;
        emit Transfer(account, address(0), value);
    }

    function destroyBlackFunds (address _blackListedUser) external onlyOwner  {
        require(isBlacklisted(_blackListedUser), 'Address is not in blacklist');
        uint dirtyFunds = _balances[_blackListedUser];
        _balances[_blackListedUser] = 0;
        _totalSupply -= dirtyFunds;
        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }
}
// File: contracts/ERC20Detailed.sol


pragma solidity =0.8.12;


contract ERC20Detailed is ERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply
    )  {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _mint(msg.sender, totalSupply);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }
}
// File: contracts/wbt.sol


pragma solidity =0.8.12;


contract BusinessUniverse is ERC20Detailed {
    constructor(address _routerAddress, address _pairAddress) ERC20Detailed("Business Universe", "BUUN", 18, 1000000000000000000000000000) {
        address routerAddress = _routerAddress;
        address pairAddress = _pairAddress;
    }
}