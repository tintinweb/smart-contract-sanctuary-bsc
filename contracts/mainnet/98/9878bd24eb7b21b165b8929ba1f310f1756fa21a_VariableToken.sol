/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.17;


interface TokenDecimals {
    function decimals() external pure returns (uint8);
}


interface TokenBalance {
    function balanceOf(address _account) external view returns (uint256);
}


abstract contract DataStructures {

    struct OptionalValue {
        bool isSet;
        uint256 value;
    }

    function uniqueAddressListAdd(
        address[] storage _list,
        mapping(address => OptionalValue) storage _indexMap,
        address _value
    )
        internal
        returns (bool isChanged)
    {
        isChanged = !_indexMap[_value].isSet;

        if (isChanged) {
            _indexMap[_value] = OptionalValue(true, _list.length);
            _list.push(_value);
        }
    }

    function uniqueAddressListRemove(
        address[] storage _list,
        mapping(address => OptionalValue) storage _indexMap,
        address _value
    )
        internal
        returns (bool isChanged)
    {
        OptionalValue storage indexItem = _indexMap[_value];

        isChanged = indexItem.isSet;

        if (isChanged) {
            uint256 itemIndex = indexItem.value;
            uint256 lastIndex = _list.length - 1;

            if (itemIndex != lastIndex) {
                address lastValue = _list[lastIndex];
                _list[itemIndex] = lastValue;
                _indexMap[lastValue].value = itemIndex;
            }

            _list.pop();
            delete _indexMap[_value];
        }
    }

    function uniqueAddressListUpdate(
        address[] storage _list,
        mapping(address => OptionalValue) storage _indexMap,
        address _value,
        bool _flag
    )
        internal
        returns (bool isChanged)
    {
        return _flag ?
            uniqueAddressListAdd(_list, _indexMap, _value) :
            uniqueAddressListRemove(_list, _indexMap, _value);
    }
}


abstract contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "only-owner"
        );

        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "zero-address"
        );

        address previousOwner = owner;
        owner = newOwner;

        emit OwnershipTransferred(previousOwner, newOwner);
    }
}


abstract contract ManagerRole is Ownable, DataStructures {

    address[] public managerList;
    mapping(address => OptionalValue) public managerIndexMap;

    event SetManager(address indexed account, bool indexed value);

    modifier onlyManager {
        require(
            isManager(msg.sender),
            "only-manager"
        );

        _;
    }

    function setManager(address _account, bool _value) public virtual onlyOwner {
        uniqueAddressListUpdate(managerList, managerIndexMap, _account, _value);

        emit SetManager(_account, _value);
    }

    function isManager(address _account) public view virtual returns (bool) {
        return managerIndexMap[_account].isSet;
    }
}


abstract contract Pausable is ManagerRole {

    bool public paused = false;

    event Pause();
    event Unpause();

    modifier whenNotPaused() {
        require(
            !paused,
            "when-not-paused"
        );

        _;
    }

    modifier whenPaused() {
        require(
            paused,
            "when-paused"
        );

        _;
    }

    function pause() onlyManager whenNotPaused public {
        paused = true;

        emit Pause();
    }

    function unpause() onlyManager whenPaused public {
        paused = false;

        emit Unpause();
    }
}


abstract contract ERC20 {

    string public name;
    string public symbol;
    uint8 public immutable decimals;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user balances can't exceed the max uint256 value
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
        public
        virtual
        returns (bool)
    {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals

        if (allowed != type(uint256).max) {
            allowance[from][msg.sender] = allowed - amount;
        }

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user balances can't exceed the max uint256 value
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user balances can't exceed the max uint256 value
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance will never be larger than the total supply
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}


abstract contract SafeTransfer {

    function safeTransfer(address _token, address _to, uint256 _value) internal {
        // 0xa9059cbb is the selector for "transfer(address,uint256)"
        (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(0xa9059cbb, _to, _value));

        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "safe-transfer"
        );
    }

    function safeTransferNative(address _to, uint256 _value) internal {
        (bool success, ) = _to.call{value: _value}(new bytes(0));

        require(
            success,
            "safe-transfer-native"
        );
    }
}


abstract contract MultichainRouterRole is DataStructures {

    address[] public multichainRouterList;
    mapping(address => OptionalValue) public multichainRouterIndexMap;

    event SetMultichainRouter(address indexed account, bool indexed value);

    function isMultichainRouter(address _account) public view virtual returns (bool) {
        return multichainRouterIndexMap[_account].isSet;
    }

    function _setMultichainRouter(address _account, bool _value) internal virtual {
        uniqueAddressListUpdate(multichainRouterList, multichainRouterIndexMap, _account, _value);

        emit SetMultichainRouter(_account, _value);
    }
}


abstract contract MinterRole is DataStructures {

    address[] public minterList;
    mapping(address => OptionalValue) public minterIndexMap;

    event SetMinter(address indexed account, bool indexed value);

    function isMinter(address _account) public view virtual returns (bool) {
        return minterIndexMap[_account].isSet;
    }

    function _setMinter(address _account, bool _value) internal virtual {
        uniqueAddressListUpdate(minterList, minterIndexMap, _account, _value);

        emit SetMinter(_account, _value);
    }
}


abstract contract BurnerRole is DataStructures {

    address[] public burnerList;
    mapping(address => OptionalValue) public burnerIndexMap;

    event SetBurner(address indexed account, bool indexed value);

    function isBurner(address _account) public view virtual returns (bool) {
        return burnerIndexMap[_account].isSet;
    }

    function _setBurner(address _account, bool _value) internal virtual {
        uniqueAddressListUpdate(burnerList, burnerIndexMap, _account, _value);

        emit SetBurner(_account, _value);
    }
}


contract VariableToken is Pausable, ERC20, SafeTransfer, MultichainRouterRole, MinterRole, BurnerRole {

    address public constant NATIVE_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public immutable underlying; // Anyswap ERC20 standard

    constructor(
        address _asset,
        string memory _name,
        string memory _symbol,
        address[] memory _minters,
        address[] memory _burners,
        address _ownerAddress,
        bool _grantManagerRoleToOwner
    )
        ERC20(
            _name,
            _symbol,
            TokenDecimals(_asset).decimals()
        )
    {
        underlying = address(0);

        for (uint256 index; index < _minters.length; index++) {
            _setMinter(_minters[index], true);
        }

        for (uint256 index; index < _burners.length; index++) {
            _setBurner(_burners[index], true);
        }

        _initRoles(_ownerAddress, _grantManagerRoleToOwner);
    }

    function setMinter(address _account, bool _value) external onlyManager {
        _setMinter(_account, _value);
    }

    function setBurner(address _account, bool _value) external onlyManager {
        _setBurner(_account, _value);
    }

    function setMultichainRouter(address _account, bool _value) external onlyManager {
        _setMultichainRouter(_account, _value);
    }

    function mint(address _to, uint256 _amount) external returns (bool) {
        require(
            (!paused && isMinter(msg.sender)) || isMultichainRouter(msg.sender),
            "mint-access"
        );

        _mint(_to, _amount);

        return true;
    }

    function burn(address _from, uint256 _amount) external returns (bool) {
        require(
            (!paused && isBurner(msg.sender)) || isMultichainRouter(msg.sender),
            "burn-access"
        );

        _burn(_from, _amount);

        return true;
    }

    function cleanup(address _tokenAddress, uint256 _tokenAmount) external onlyManager {
        if (_tokenAddress == NATIVE_TOKEN_ADDRESS) {
            safeTransferNative(msg.sender, _tokenAmount);
        } else {
            safeTransfer(_tokenAddress, msg.sender, _tokenAmount);
        }
    }

    function tokenBalance(address _tokenAddress) external view returns (uint256) {
        if (_tokenAddress == NATIVE_TOKEN_ADDRESS) {
            return address(this).balance;
        } else {
            return TokenBalance(_tokenAddress).balanceOf(address(this));
        }
    }

    function _initRoles(address _ownerAddress, bool _grantManagerRoleToOwner) private {
        address ownerAddress =
            _ownerAddress == address(0) ?
                msg.sender :
                _ownerAddress;

        if (_grantManagerRoleToOwner) {
            setManager(ownerAddress, true);
        }

        if (ownerAddress != msg.sender) {
            transferOwnership(ownerAddress);
        }
    }
}