// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./Owner.sol";

interface IStakePool {
    function setAdmin(address _admin) external;
    function setSwitch(uint8 _switch) external;
}

interface IHashratePool {
    function settlementAll() external;
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

interface IYiBoxNFT {
    function mint(address to, uint256 tokenId) external returns (bool);
    //function totalSupply() external returns (uint256);
}

contract MainPool is Ownable {
    using SafeMath for uint256;
    uint256 decimal = 10 ** 18;
    address public mainToken;
    address public keyToken;
    address public NFTToken;
    address public factoryToken;
    address public factoryKeyToken;

    //mapping(address => mapping(address => address)) public getStakePool;
    uint32 public UsedStake;
    address[] public allStakePools;

    mapping(address => mapping(address => address)) public getKeyPool;
    address[] public allKeyPools;

    address public HashratePool;
    address public mainPool;

    uint256 tokenIndex = 0;

    event PairCreated(address indexed _main, address indexed _pair, address pair, uint);

    function setUsedStake(uint32 _idx) external onlyOwner {
        require(_idx < allStakePools.length, "out of range");
        UsedStake = _idx;
    }

    function switchStakePool(uint8 _sw) external onlyOwner {
        address _StakePool = allStakePools[UsedStake];  //getStakePool[mainToken][_pair];
        IStakePool(_StakePool).setSwitch(_sw);
    }
    
    function switchKeyPool(address _pair, uint8 _sw) external onlyOwner {
        address _KeyPool = getKeyPool[mainToken][_pair];
        IKeyPool(_KeyPool).setSwitch(_sw);
    }

    function setTokenMain(address _main, address _key, address _nft) public onlyOwner {
        require(_main != address(0) && _key != address(0) && _nft != address(0), "M2001: maintoken or keytoken or nfttoken is invali");
        mainToken = _main;
        keyToken = _key;
        NFTToken = _nft;
    }

    function setFactory(address _stake, address _key) public onlyOwner {
        require(_stake != address(0) && _key != address(0), "M2001: factoryToken is invali");
        factoryToken = _stake;
        factoryKeyToken = _key;
    }

    function setHashratePool(address _tar) public onlyOwner {
        require(_tar != address(0), "M2001: HashratePool is invali");
        HashratePool = _tar;
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
        UsedStake = SafeMathExt.safe32(allStakePools.length - 1);
        emit PairCreated(mainToken, _pair, _StakePool, allStakePools.length);
    }

    function createKeyPool(address _pair) public onlyOwner returns (address _KeyPool) {
        require(mainToken != address(0) && keyToken != address(0), "M2002: need mainToken and keyToken");
        require(factoryKeyToken != address(0), "M2009: need a factoryToken");
        require(_pair != address(0), "M2010: need a _pair");

        _KeyPool = IYiBoxFactoryKey(factoryKeyToken).createKeyPool(_pair, mainToken, keyToken);
        getKeyPool[mainToken][_pair] = _KeyPool;
        getKeyPool[_pair][mainToken] = _KeyPool; // populate mapping in the reverse direction
        allKeyPools.push(_KeyPool);
        emit PairCreated(mainToken, _pair, _KeyPool, allKeyPools.length);
    }

    //1 = main token , 2 = keytoken
    function allocation (uint8 tokenType) public {
        if (tokenType == 1) {
            require(mainToken != address(0), "M2003: mainToken is invali");
            YiToken(mainToken).mint(address(this));
        } else if (tokenType == 2) {
            require(keyToken != address(0), "M2003: keyToken is invali");
            IKeyToken(keyToken).mintForEvent(address(this));
        }
    }

    function swapBox(address _pair, uint256 _num) public lock returns(uint256[] memory tokenids) {
        require(_pair != address(0) && mainToken != address(0) && NFTToken != address(0), "M2002: need _pair and keyToken and NFTToken");
        address _KeyPool = getKeyPool[mainToken][_pair];
        require(_KeyPool != address(0) && HashratePool != address(0), "M2019: KeyPool or HashratePool error");
        require(_msgSender() != address(0), "need a sender");
        // uint256 _bal;
        // (,,,_bal) = IKeyPool(_KeyPool).queryIncome(_msgSender());

        IHashratePool(HashratePool).settlementAll();

        IKeyPool(_KeyPool).purchase(_msgSender(),  _num * (10 ** 18));
        //uint256 _total = IYiBoxNFT(NFTToken).totalSupply();
        tokenids = new uint256[](_num);
        for (uint i = 0; i < _num; i++) {
            uint256 _tokenId = 100000000 + (++tokenIndex);
            IYiBoxNFT(NFTToken).mint(_msgSender(), _tokenId);
            tokenids[i] = _tokenId;
        }
    }

    function tranMainPool(address _new) external {
        require(_new != address(0));
        require(msg.sender == mainPool);
        mainPool = _new;
    }

    //给指定账号分配指定数量的币
    function allocTo(address _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "M2004: target address is null");
        require(_amount > 0, "M2005: wrong amount");

        uint256 _balance = YiToken(mainToken).balanceOf(address(this));
        require(_balance >= _amount, "M2006: Insufficient balance");
        bool res = YiToken(mainToken).transfer(_to,_amount);
        require(res);
    }

    function allocAirDrop(uint256 _stake) external returns (uint256 _need) {
        //address _StakePool = getStakePool[mainToken][_pair];
        address _StakePool = allStakePools[UsedStake];
        require(msg.sender == _StakePool,"M2008: StakePool is not manager");
        if (_stake <= 50000000 * decimal) {
            _need = 50000 * decimal;
        } else if (_stake <= 100000000 * decimal) {
            _need = 75000 * decimal;
        } else if (_stake <= 200000000 * decimal) {
            _need = 100000 * decimal;
        } else {
            _need = 125000 * decimal;
        }

        uint256 _balance = YiToken(mainToken).balanceOf(address(this));
        require(_balance >= _need);
        bool res = YiToken(mainToken).transfer(_StakePool,_need);
        require(res);
    }

    function allocKeyAirDrop(address _pair, uint256 _stake) external returns (uint256 _need) {
        address _KeyPool = getKeyPool[mainToken][_pair];
        require(msg.sender == _KeyPool,"M2008: KeyPool is not managed");
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

        uint256 _balance = IKeyToken(keyToken).balanceOf(address(this));
        require(_balance >= _need);
        bool res = IKeyToken(keyToken).transfer(_KeyPool,_need);
        require(res);
    }

    function allocHashrateAirDrop(uint256 _hashrateTotal) external returns (uint256 _need) {
        require(msg.sender == HashratePool,"M2008: HashratePool is not managed");

        if (_hashrateTotal >= 500001) {
            _need = 200000 * decimal;
        } else if (_hashrateTotal >= 400001) {
            _need = 120000 * decimal;
        } else if (_hashrateTotal >= 300001) {
            _need = 70000 * decimal;
        } else if (_hashrateTotal >= 200001) {
            _need = 30000 * decimal;
        } else if (_hashrateTotal >= 100001) {
            _need = 20000 * decimal;
        } else {
            _need = 10000 * decimal;
        }

        uint256 _balance = YiToken(mainToken).balanceOf(address(this));
        require(_balance >= _need);
        bool res = YiToken(mainToken).transfer(HashratePool,_need);
        require(res);
    }
}