// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <=0.6.12;
pragma experimental ABIEncoderV2;

import './modules/Initializable.sol';
import './modules/Configable.sol';
import "./interfaces/IBurgerDexManager.sol";

contract BurgerDexManagerV2 is Configable, Initializable, IBurgerDexManager{
    BurgerDexProtocol[] public override dexs;
    mapping(address => mapping(address => uint)) public pids;
    mapping(address => mapping(address => bool)) public exists;

    struct BurgerDexProtocol {
        address protocol;
        address dex;
        uint256 flag; // 2**n
        string name;
    }

    event SetProtocol(address protocol, address dex, uint flag, string name);

    function initialize() external initializer {
        owner = msg.sender;
    }

    function dexLength() external override view returns (uint) {
        return dexs.length;
    }

    function addProtocol(address _protocol, address _dex, uint256 _flag, string memory _name) public onlyDev {
        require(_protocol != address(0) && _dex != address(0), 'Zero address');
        require(!exists[_protocol][_dex], "Alreadly exists");

        uint pid = dexs.length;
        dexs.push(BurgerDexProtocol({
            dex: _dex,
            protocol: _protocol,
            flag: _flag,
            name: _name
        }));
        pids[_protocol][_dex] = pid;
        exists[_protocol][_dex] = true;

        emit SetProtocol(_protocol, _dex, _flag, _name);
    } 

    function batchAddProtocol(
        address[] calldata _protocols,
        address[] calldata _dexs,
        uint256[] calldata _flags,
        string[] calldata _names
    ) external onlyDev {
        require(
            _dexs.length == _protocols.length 
            && _protocols.length == _flags.length 
            && _flags.length == _names.length, 
            'invalid parameters'
        );
        for (uint i = 0; i < _dexs.length; i++) {
            addProtocol(_protocols[i], _dexs[i], _flags[i], _names[i]);
        }
    }

    function batchSetProtocol(
        address[] calldata _protocols,
        address[] calldata _dexs,
        uint256[] calldata _flags,
        string[] calldata _names
    ) external onlyDev {
        uint count = dexs.length;
        for(uint i; i<count; i++) {
            exists[dexs[i].protocol][dexs[i].dex] = false;
        }
        for(uint i; i<count; i++) {
            dexs.pop();
        }
        for (uint i = 0; i < _dexs.length; i++) {
            addProtocol(_protocols[i], _dexs[i], _flags[i], _names[i]);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <=0.6.12;

interface IConfig {
    function dev() external view returns (address);
    function admin() external view returns (address);
    function team() external view returns (address);
}

contract Configable {
    address public config;
    address public owner;

    event ConfigChanged(address indexed _user, address indexed _old, address indexed _new);
    event OwnerChanged(address indexed _user, address indexed _old, address indexed _new);
 
    function setupConfig(address _config) external onlyOwner {
        emit ConfigChanged(msg.sender, config, _config);
        config = _config;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'OWNER FORBIDDEN');
        _;
    }

    function admin() public view returns(address) {
        if(config != address(0)) {
            return IConfig(config).admin();
        }
        return owner;
    }

    function dev() public view returns(address) {
        if(config != address(0)) {
            return IConfig(config).dev();
        }
        return owner;
    }

    function team() public view returns(address) {
        if(config != address(0)) {
            return IConfig(config).team();
        }
        return owner;
    }

    function changeOwner(address _user) external onlyOwner {
        require(owner != _user, 'Owner: NO CHANGE');
        emit OwnerChanged(msg.sender, owner, _user);
        owner = _user;
    }
    
    modifier onlyDev() {
        require(msg.sender == dev() || msg.sender == owner, 'dev FORBIDDEN');
        _;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin() || msg.sender == owner, 'admin FORBIDDEN');
        _;
    }
  
    modifier onlyManager() {
        require(msg.sender == dev() || msg.sender == admin() || msg.sender == owner, 'manager FORBIDDEN');
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <=0.6.12;

import "./IERC20.sol";

interface IBurgerDexManager {
    function dexLength() external view returns (uint);
    function dexs(uint _pid) external view returns (address protocol, address dex, uint256 flag, string memory name);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <=0.6.12;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}