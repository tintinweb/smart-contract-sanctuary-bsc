// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "./Owner.sol";
import "./ERC1155Holder.sol";

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "C4001:SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "C4001:SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "C4001:SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "C4001:SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "C4001:SafeMath: modulo by zero");
        return a % b;
    }
}

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

library SafeMathExt {
    function add128(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a + b;
        require(c >= a, "C4002:uint128: addition overflow");

        return c;
    }

    function sub128(uint128 a, uint128 b) internal pure returns (uint128) {
        require(b <= a, "C4002:uint128: subtraction overflow");
        uint128 c = a - b;

        return c;
    }

    function add64(uint64 a, uint64 b) internal pure returns (uint64) {
        uint64 c = a + b;
        require(c >= a, "C4002:uint64: addition overflow");

        return c;
    }

    function sub64(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b <= a, "C4002:uint64: subtraction overflow");
        uint64 c = a - b;

        return c;
    }

    function safe128(uint256 a) internal pure returns(uint128) {
        require(a < 0x0100000000000000000000000000000000, "C4002:uint128: number overflow");
        return uint128(a);
    }

    function safe64(uint256 a) internal pure returns(uint64) {
        require(a < 0x010000000000000000, "C4002:uint64: number overflow");
        return uint64(a);
    }

    function safe32(uint256 a) internal pure returns(uint32) {
        require(a < 0x0100000000, "C4002:uint32: number overflow");
        return uint32(a);
    }

    function safe16(uint256 a) internal pure returns(uint16) {
        require(a < 0x010000, "C4002:uint16: number overflow");
        return uint16(a);
    }

    function safe8(uint256 a) internal pure returns(uint8) {
        require(a < 0x0100, "C4002:uint8: number overflow");
        return uint8(a);
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor()  {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    uint8 private unlocked = 1;
    uint8 private switch_ = 1; 

    modifier isOpen() {
        require(switch_ == 1, 'S3002: Contracts is Closed ');
        _;
    }

    function setSwitch(uint8 _switch) public  {
        require(_msgSender() == _owner, "O3003: not owner ... ");
        switch_ = _switch;
    }

    modifier lock() {
        require(unlocked == 1, 'S3001: is LOCKED ... ');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "O3001: owner error ... ");
        _;
    }

    function transferOwnership(address newOwner) public {
        require(newOwner != address(0), "O3002: newOwner invalid");
        if (_owner != address(0)) {
            require(_msgSender() == _owner, "O3003: not owner ... ");
        }
        
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IStakePool {
    function setAdmin(address _admin) external;
    function setSwitch(uint8 _switch) external;
}

// interface IHashratePool {
//     function settlementAll() external;
// }

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

/*
interface IYiBoxNFT {
    function mint(address to, uint256 tokenId) external returns (bool);
    function mint(address to, uint256 tokenId, uint8 _quality, uint32 _hashrate,uint16 ttype) external;
    function totalSupply() external returns (uint256);
}


interface IYiBoxSetting {
    function calcHashrate4() external returns (uint32);
    function calcHashrate5() external returns (uint32);
    function getMaxHeroType() external view returns (uint16);
}
*/
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
    address public NFTToken;
    address public factoryToken;
    address public factoryKeyToken;
    address public YiBoxSetting;

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

    function setSetting(address _setting) external onlyOwner {
        require(_setting != address(0), "setting is invali");
        YiBoxSetting = _setting;
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

    function swapBox(address _pair, uint256 _num, address _boxAddress) public lock {
        require(_pair != address(0) && mainToken != address(0) && _boxAddress != address(0), "M2002: need _pair and keyToken and _boxAddress");
        address _KeyPool = getKeyPool[mainToken][_pair];
        // require(_KeyPool != address(0) && HashratePool != address(0), "M2019: KeyPool or HashratePool error");
        require(_KeyPool != address(0) , "KeyPool error");
        require(_msgSender() != address(0), "need a sender");
        // uint256 _bal;
        // (,,,_bal) = IKeyPool(_KeyPool).queryIncome(_msgSender());

        // IHashratePool(HashratePool).settlementAll();

        IKeyPool(_KeyPool).purchase(_msgSender(),  _num * (10 ** 18));
        IYiBoxBoxNFT(_boxAddress).safeTransferFrom(address(this), _msgSender(), 1, _num, "");
        //uint256 _total = IYiBoxNFT(NFTToken).totalSupply();
        // tokenids = new uint256[](_num);
        // for (uint i = 0; i < _num; i++) {
        //     uint256 _tokenId = 100000000 + (++tokenIndex);
        //     IYiBoxNFT(NFTToken).mint(_msgSender(), _tokenId);
        //     tokenids[i] = _tokenId;
        // }
    }

    function unLockBox(uint256 _num, address _boxAddress) external {
        require(_boxAddress != address(0), "need _boxAddress");

        IYiBoxBoxNFT(_boxAddress).safeTransferFrom(_msgSender(), address(this),  1, _num, "");
        IYiBoxBoxNFT(_boxAddress).safeTransferFrom(address(this), _msgSender(),   2, _num, "");
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

    // function allocL4Hero(uint256 _num) external onlyOwner {
    //     require(YiBoxSetting != address(0), "setting error");
    //     require(NFTToken != address(0), "NFTToken error");

    //     uint16 _nt = IYiBoxSetting(YiBoxSetting).getMaxHeroType();
    //     for (uint16 i = 0; i < _nt; i++) {
    //         for (uint j = 1; j <= _num; j++) {
    //             uint32 _hr = IYiBoxSetting(YiBoxSetting).calcHashrate4();
    //             IYiBoxNFT(NFTToken).mint(address(this), j, 4, _hr, i);
    //         }
    //     }
    // }

    // function allocL5Hero(uint256 _num) external onlyOwner {
    //     require(YiBoxSetting != address(0), "setting error");
    //     require(NFTToken != address(0), "NFTToken error");

    //     uint16 _nt = IYiBoxSetting(YiBoxSetting).getMaxHeroType();
    //     for (uint16 i = 0; i < _nt; i++) {
    //         for (uint j = 1; j <= _num; j++) {
    //             uint32 _hr = IYiBoxSetting(YiBoxSetting).calcHashrate5();
    //             IYiBoxNFT(NFTToken).mint(address(this), j, 5, _hr, i);
    //         }
    //     }
    // }
}