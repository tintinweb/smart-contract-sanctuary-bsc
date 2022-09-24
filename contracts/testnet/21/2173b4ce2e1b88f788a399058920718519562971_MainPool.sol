// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Owner.sol";
import "./ERC1155Holder.sol";

interface IStakePool {
    function setAdmin(address _admin) external;
    function setSwitch(uint8 _switch) external;
}

interface IKeyPool {
    function setAdmin(address _admin) external;
    function setSwitch(uint8 _switch) external;
    function purchase(address _staker, uint256 _keyNum) external returns (bool);
    function queryIncome(address _staker) external view returns(uint256,uint256,uint256,uint256);
}

interface IKeyToken {
    function mintForEvent(address dest_) external;
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
}

interface YiToken {
    function mint(address dest_) external;
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
}

interface IYiBoxFactory {
    function createStakePool(address _pair, address mainToken) external returns (address _StakePool);
}

interface IYiBoxFactoryKey {
    function createKeyPool(address _pair, address mainToken, address _keyToken) external returns (address _KeyPool);
}

interface IYiBoxBoxNFT {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

contract MainPool is Ownable, ERC1155Holder {
    using SafeMath for uint256;
    uint256 decimal = 10 ** 18;
    address public mainToken;
    address public keyToken;
    address public _boxAddress;
    address public factoryToken;
    address public factoryKeyToken;

    mapping(address => bool) public StakePoolUsed;
    address[] public allStakePools;

    mapping(address => bool) public KeyPoolUsed;
    address[] public allKeyPools;

    mapping(address => bool) public HashratePoolUsed;
    address[] public allHashratePools;
    address public mainPool;

    uint256 tokenIndex = 0;

    event PairCreated(address indexed _main, address indexed _pair, address pair, uint);

    function setStakePoolUsed(address _stakePool, bool _used) public onlyOwner {
        for (uint i = 0; i < allStakePools.length; i++) {
            if (allStakePools[i] == _stakePool) {
                StakePoolUsed[_stakePool] = _used;
                break;
            }
        }
    }

    function switchStakePool(address _stakePool, uint8 _sw) external onlyOwner {
        require(StakePoolUsed[_stakePool], "_keyPool not used");
        IStakePool(_stakePool).setSwitch(_sw);
    }

    function setKeyPoolUsed(address _keyPool, bool _used) public onlyOwner {
        for (uint i = 0; i < allKeyPools.length; i++) {
            if (allKeyPools[i] == _keyPool) {
                KeyPoolUsed[_keyPool] = _used;
                break;
            }
        }
    }
    
    function switchKeyPool(address _keyPool, uint8 _sw) external onlyOwner {
        // address _KeyPool = getKeyPool[mainToken][_pair];
        require(KeyPoolUsed[_keyPool], "_keyPool not used");
        IKeyPool(_keyPool).setSwitch(_sw);
    }

    function setTokenMain(address _main, address _key, address _box) public onlyOwner {
        require(_main != address(0) && _key != address(0) && _box != address(0), "M2001: maintoken or keytoken or _boxAddress is invali");
        mainToken = _main;
        keyToken = _key;
        _boxAddress = _box;
    }

    function setFactory(address _stake, address _key) public onlyOwner {
        require(_stake != address(0) && _key != address(0), "M2001: factoryToken is invali");
        factoryToken = _stake;
        factoryKeyToken = _key;
    }

    function setHashratePool(address _tar) public onlyOwner {
        require(_tar != address(0), "M2001: HashratePool is invali");
        allHashratePools.push(_tar);
        HashratePoolUsed[_tar] = true;
    }

    function setHashratePoolUsed(address _HashratePool, bool _used) public onlyOwner {
        for (uint i = 0; i < allHashratePools.length; i++) {
            if (allHashratePools[i] == _HashratePool) {
                HashratePoolUsed[_HashratePool] = _used;
                break;
            }
        }
    }

    function tranStakeAdmin(address _stake, address _target) external onlyOwner {
        IStakePool(_stake).setAdmin(_target);
    }

    function tranKeyAdmin(address _key, address _target) external onlyOwner {
        IKeyPool(_key).setAdmin(_target);
    }

    //合约创建，只有管理员操作
    function createStakePool(address _pair) public onlyOwner returns (address _StakePool) {
        require(mainToken != address(0), "M2002: need a mainToken");
        require(factoryToken != address(0), "M2009: need a factoryToken");
        require(_pair != address(0), "M2010: need a _pair");

        _StakePool = IYiBoxFactory(factoryToken).createStakePool(_pair, mainToken);
        // getStakePool[mainToken][_pair] = _StakePool;
        // getStakePool[_pair][mainToken] = _StakePool; // populate mapping in the reverse direction
        allStakePools.push(_StakePool);
        StakePoolUsed[_StakePool] = true;
        emit PairCreated(mainToken, _pair, _StakePool, allStakePools.length);
    }

    function createKeyPool(address _pair) public onlyOwner returns (address _KeyPool) {
        require(mainToken != address(0) && keyToken != address(0), "M2002: need mainToken and keyToken");
        require(factoryKeyToken != address(0), "M2009: need a factoryToken");
        require(_pair != address(0), "M2010: need a _pair");

        _KeyPool = IYiBoxFactoryKey(factoryKeyToken).createKeyPool(_pair, mainToken, keyToken);
        // getKeyPool[mainToken][_pair] = _KeyPool;
        // getKeyPool[_pair][mainToken] = _KeyPool; // populate mapping in the reverse direction
        allKeyPools.push(_KeyPool);
        KeyPoolUsed[_KeyPool] = true;
        emit PairCreated(mainToken, _pair, _KeyPool, allKeyPools.length);
    }

    //1 = main token , 2 = keytoken
    function allocationStake() public {
        require(mainToken != address(0), "mainToken is invali");
        YiToken(mainToken).mint(address(this));
    }

    function allocationKey(address _keyPool) public {
        require(keyToken != address(0), "keyToken is invali");
        require(KeyPoolUsed[_keyPool], "_keyPool not used");
        IKeyToken(keyToken).mintForEvent(_keyPool);
    }

    function swapBox(address _keyPool, uint256 _num) public {
        require(mainToken != address(0) && _boxAddress != address(0), "M2002: need _pair and keyToken and _boxAddress");
        require(KeyPoolUsed[_keyPool], "_keyPool not used");
        require(_msgSender() != address(0), "need a sender");

        IKeyPool(_keyPool).purchase(_msgSender(),  _num * (10 ** 18));
        IYiBoxBoxNFT(_boxAddress).safeTransferFrom(address(this), _msgSender(), 1, _num, "");
    }

    function tranMainPool(address _new) external {
        require(_new != address(0));
        require(msg.sender == mainPool);
        mainPool = _new;
    }

    //给指定账号分配指定数量的币
    function allocTo(address _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "target address is null");
        require(_amount > 0, "wrong amount");

        uint256 _balance = YiToken(mainToken).balanceOf(address(this));
        require(_balance >= _amount, "Insufficient balance");
        bool res = YiToken(mainToken).transfer(_to,_amount);
        require(res);
    }

    function allocAirDrop(uint256 _need) external {
        require(StakePoolUsed[msg.sender], "sender StakePool not used");
        uint256 _balance = YiToken(mainToken).balanceOf(address(this));
        require(_balance >= _need,"Insufficient balance");
        bool res = YiToken(mainToken).transfer(msg.sender,_need);
        require(res);
    }

    function allocKeyAirDrop(uint256 _stake) external view returns (uint256 _need) {
        require(KeyPoolUsed[msg.sender], "sender KeyPool not used");
        if (_stake < 1000000 * decimal) {
            _need = 600 * decimal;
        } else if (_stake < 2000000 * decimal) {
            _need = 1200 * decimal;
        } else if (_stake < 5000000 * decimal) {
            _need = 2400 * decimal;
        } else if (_stake < 10000000 * decimal) {
            _need = 3600 * decimal;
        } else if (_stake < 30000000 * decimal) {
            _need = 4800 * decimal;
        } else {
            _need = 6000 * decimal;
        }
    
        // uint256 _balance = IKeyToken(keyToken).balanceOf(address(this));
        // require(_balance >= _need);
        // bool res = IKeyToken(keyToken).transfer(_KeyPool,_need);
        // require(res);
    }

    function allocHashrateAirDrop(uint256 _need) external {
        require(HashratePoolUsed[msg.sender], "sender HashratePool not used");
        
        uint256 _balance = YiToken(mainToken).balanceOf(address(this));
        require(_balance >= _need,"Insufficient balance");
        bool res = YiToken(mainToken).transfer(msg.sender,_need);
        require(res);
    }
}