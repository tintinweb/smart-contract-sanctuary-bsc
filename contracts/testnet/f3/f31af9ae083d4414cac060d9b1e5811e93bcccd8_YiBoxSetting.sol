/**
 *Submitted for verification at BscScan.com on 2022-07-12
*/

/**
 *Submitted for verification at BscScan.com on 2021-04-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMathExt {
    function add128(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a + b;
        require(c >= a, "uint128: addition overflow");

        return c;
    }

    function sub128(uint128 a, uint128 b) internal pure returns (uint128) {
        require(b <= a, "uint128: subtraction overflow");
        uint128 c = a - b;

        return c;
    }

    function add64(uint64 a, uint64 b) internal pure returns (uint64) {
        uint64 c = a + b;
        require(c >= a, "uint64: addition overflow");

        return c;
    }

    function sub64(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b <= a, "uint64: subtraction overflow");
        uint64 c = a - b;

        return c;
    }

    function safe128(uint256 a) internal pure returns(uint128) {
        require(a < 0x0100000000000000000000000000000000, "uint128: number overflow");
        return uint128(a);
    }

    function safe64(uint256 a) internal pure returns(uint64) {
        require(a < 0x010000000000000000, "uint64: number overflow");
        return uint64(a);
    }

    function safe32(uint256 a) internal pure returns(uint32) {
        require(a < 0x0100000000, "uint32: number overflow");
        return uint32(a);
    }

    function safe16(uint256 a) internal pure returns(uint16) {
        require(a < 0x010000, "uint32: number overflow");
        return uint16(a);
    }
}

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_msgSender() == _owner, "not owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public {
        require(newOwner != address(0), "newOwner invalid");
        if (_owner != address(0)) {
            require(_msgSender() == _owner, "not owner");
        }
        
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract YiBoxSetting is Ownable {
    // address public settingGuardian;
    mapping(address => bool) public _settingGuardians;

    uint16 maxHeroType;

    uint256 levelMaxV4;
    uint256 levelMaxV5;
    uint256 levelMaxV6;
    
    mapping (uint256 => uint256) _levelUpV4;
    mapping (uint256 => uint256) _levelUpV5;
    mapping (uint256 => uint256) _levelUpV6;


    mapping (uint256 => string) _ipfsUrisGeneral; 
    mapping (uint256 => string) _ipfsUrisSpecial;

    uint32[]  m_u32Hashrate4;
    uint32[]  m_u32Hashrate4Per;
 
    uint32[]  m_u32Hashrate5;
    uint32[]  m_u32Hashrate5Per;

    uint32 level4HashrateMin;
    uint32 level5HashrateMin;
    uint32 level6HashrateMin;
    uint32 level4HashrateMax;
    uint32 level5HashrateMax;
    uint32 level6HashrateMax;
    uint32 level4HashrateStep;
    uint32 level5HashrateStep;
    uint32 level6HashrateStep;
    uint32 level4HashrateStep1;
    uint32 level5HashrateStep1;
    uint32 level6HashrateStep1;

    uint32 public m_u32Level4Count;
    uint32 public m_u32Level5Count;

    uint32 m_u32Level4Used;
    uint32 m_u32Level5Used;

    uint32 m_u32ProbabilityL1;
    uint32 m_u32ProbabilityL2;
    uint32 m_u32ProbabilityL3;
    uint32 m_u32ProbabilityL4;
    uint32 m_u32ProbabilityL5;

    address seedAddress;

    address incomePool;
    address repoPool;

    uint32 inpcomePer;
    uint32 repoPer;

    constructor() public {
        _settingGuardians[msg.sender] = true;

        level4HashrateMin = 10;
        level5HashrateMin = 50;
        level6HashrateMin = 180;
        level4HashrateMax = 120;
        level5HashrateMax = 250;
        level6HashrateMax = 280;
        level4HashrateStep = 20;
        level5HashrateStep = 50;
        level6HashrateStep = 100;
        level4HashrateStep1 = 4;
        level5HashrateStep1 = 15;
        level6HashrateStep1 = 40;

        levelMaxV4 = 40;
        levelMaxV5 = 40;
        levelMaxV6 = 40;

        m_u32Level4Count = 200;
        m_u32Level5Count = 50;

        m_u32Level4Used = 0;
        m_u32Level5Used = 0;

        m_u32ProbabilityL1 = 5000;
        m_u32ProbabilityL2 = 3500;
        m_u32ProbabilityL3 = 1200;
        m_u32ProbabilityL4 = 250;
        m_u32ProbabilityL5 = 50;

        m_u32Hashrate4.push(10);
        m_u32Hashrate4.push(20);
        m_u32Hashrate4.push(30);
        m_u32Hashrate4.push(40);
        m_u32Hashrate4Per.push(0);
        m_u32Hashrate4Per.push(5000);
        m_u32Hashrate4Per.push(3000);
        m_u32Hashrate4Per.push(2000);

        m_u32Hashrate5.push(50);
        m_u32Hashrate5.push(80);
        m_u32Hashrate5.push(100);
        m_u32Hashrate5.push(120);
        m_u32Hashrate5Per.push(0);
        m_u32Hashrate5Per.push(5000);
        m_u32Hashrate5Per.push(3000);
        m_u32Hashrate5Per.push(2000);

        maxHeroType = 72;

        incomePool = 0xAe19DDA64bDa57b54E93c8a955c432A0284fA3c4;
        repoPool = 0xAe19DDA64bDa57b54E93c8a955c432A0284fA3c4;
        inpcomePer = 100;
        repoPer = 400;
    }
    
    function setMaxHeroType(uint16 _max) external onlyGuardian {
        maxHeroType = _max;
    }

    function getIncomePool() external view returns (address _incomePool) {
        _incomePool = incomePool;
    }

    function getrepoPool() external view returns (address _repoPool) {
        _repoPool = repoPool;
    }

    function setIncomePool(address _incomePool) external onlyGuardian {
        incomePool = _incomePool;
    }

    function setrepoPool(address _repoPool) external onlyGuardian {
        repoPool = _repoPool;
    }

    function getIncomePer() external view returns (uint32 _incomePer) {
        _incomePer = inpcomePer;
    }

    function getRepoPer() external view returns (uint32 _repoPer) {
        _repoPer = repoPer;
    }

    function setIncomePer(uint32 _incomePer) external onlyGuardian {
        inpcomePer = _incomePer;
    }

    function setrepoPer(uint32 _repoPer) external onlyGuardian {
        repoPer = _repoPer;
    }

    function getLevel4Used() external view returns (uint32 _Level4Used) {
        _Level4Used = m_u32Level4Used;
    }

    function getLevel5Used() external view returns (uint32 _Level5Used) {
        _Level5Used = m_u32Level5Used;
    }

    function setLevel4Count(uint32 _newVal) external onlyGuardian {
        m_u32Level4Count = _newVal;
    }

    function setLevel5Count(uint32 _newVal) external onlyGuardian {
        m_u32Level5Count = _newVal;
    }

    function setProbabilityL1(uint32 _newVal) external onlyGuardian {
        m_u32ProbabilityL1 = _newVal;
    }

    function setProbabilityL2(uint32 _newVal) external onlyGuardian {
        m_u32ProbabilityL2 = _newVal;
    }

    function setProbabilityL3(uint32 _newVal) external onlyGuardian {
        m_u32ProbabilityL3 = _newVal;
    }

    function setProbabilityL4(uint32 _newVal) external onlyGuardian {
        m_u32ProbabilityL4 = _newVal;
    }

    function setProbabilityL5(uint32 _newVal) external onlyGuardian {
        m_u32ProbabilityL5 = _newVal;
    }

    function addSettingGuardian(address addr_) external onlyOwner {
        _settingGuardians[addr_] = true;
    }

    function removeSettingGuardian(address addr_) external onlyOwner {
        _settingGuardians[addr_] = false;
    }

    modifier onlyGuardian() {
        require(_settingGuardians[msg.sender], "not writer");
        _;
    }

    function setLevel4Hashrate(uint32[] memory _hr, uint32[] memory _hrp) public {
        require(_hr.length == _hrp.length, "length error");
        delete m_u32Hashrate4;
        delete m_u32Hashrate4Per;

        for (uint i = 0; i < _hr.length; i++ )
        {
            m_u32Hashrate4.push(_hr[i]);
            m_u32Hashrate4Per.push(_hrp[i]);
        }
    } 

    function setLevel5Hashrate(uint32[] memory _hr, uint32[] memory _hrp) public {
        require(_hr.length == _hrp.length, "length error");
        delete m_u32Hashrate5;
        delete m_u32Hashrate5Per;

        for (uint i = 0; i < _hr.length; i++ )
        {
            m_u32Hashrate5.push(_hr[i]);
            m_u32Hashrate5Per.push(_hrp[i]);
        }
    } 

    function setMaxLevel(uint256 lvv4_, uint256 lvv5_, uint256 lvv6_) external onlyGuardian {
        require(lvv4_ > levelMaxV4 && lvv4_ < 256, "invalid lvv4");
        require(lvv5_ > levelMaxV5 && lvv5_ < 256, "invalid lvv5");
        require(lvv6_ > levelMaxV6 && lvv6_ < 256, "invalid lvv6");

        levelMaxV4 = lvv4_;
        levelMaxV5 = lvv5_;
        levelMaxV6 = lvv6_;
    }

    function getMaxLevel(uint8 _vLevel) public view returns(uint256 _levelMax) {
        if (_vLevel == 4) {
            _levelMax = levelMaxV4;
        } else if (_vLevel == 5) {
            _levelMax = levelMaxV5;
        } else if (_vLevel == 6) {
            _levelMax = levelMaxV6;
        } else {
            _levelMax = 0;
        }
    }

    function setSeedAddress(address _tar) public onlyGuardian {
        seedAddress = _tar;
    }

    function calcOpenBox() external onlyGuardian returns (uint256 _lv, uint256 _hr, uint256 _ty,uint256[2] memory _seed) {
        require(seedAddress!=address(0), "seedaddr error");
        
        for (uint xx = 0; xx < 2 ; xx++) {
            bytes memory payload = abi.encodeWithSignature("Hash(uint256)", 10000);
            (, bytes memory returnData) = address(seedAddress).call(payload);
            _seed[xx] = abi.decode(returnData,(uint256));
        }
        uint256 _hr4 = 0;
        for (uint i = 0; i < m_u32Hashrate4Per.length; i++) {
            uint _t = 0;
            for (uint _i = 0; _i <= i; _i++) {
                _t += m_u32Hashrate4Per[_i];
            }
            if (_seed[1] <= _t) {
                if (i == 0) {
                    _hr4 = _seed[1] % m_u32Hashrate4[i];
                } else {
                    _hr4 = (_seed[1] %(m_u32Hashrate4[i] - m_u32Hashrate4[i-1])) + m_u32Hashrate4[i-1];
                }
                break;
            }
        }

        uint256 _hr5 = 0;
        for (uint i = 0; i < m_u32Hashrate5Per.length; i++) {
           uint _t = 0;
           for (uint _i = 0 ; _i <= i; _i++) {
               _t += m_u32Hashrate5Per[_i];
           }
           if (_seed[1] <= _t) {
               if (i == 0) {
                   _hr5 = _seed[1] % m_u32Hashrate5[i];
               } else {
                   _hr5 = (_seed[1] % (m_u32Hashrate5[i] - m_u32Hashrate5[i-1])) + m_u32Hashrate5[i-1];
               }
               break;
           }
        }

        _lv = 1;
        if (_seed[0] <= m_u32ProbabilityL1) {
            _lv = 1;
        } else if (_seed[0] <= m_u32ProbabilityL1 + m_u32ProbabilityL2) {
            _lv = 2;
        } else if (_seed[0] <= m_u32ProbabilityL1 + m_u32ProbabilityL2) {
            _lv = 2;
        } else if (_seed[0] <= m_u32ProbabilityL1 + m_u32ProbabilityL2 + m_u32ProbabilityL3) {
            _lv = 3;
        } else if (_seed[0] <= m_u32ProbabilityL1 + m_u32ProbabilityL2 + m_u32ProbabilityL3 + m_u32ProbabilityL4) {
            if (m_u32Level4Used >= m_u32Level4Count) {
                _lv = 3;
            } else {
                _lv = 4;
            }
        }  else if (_seed[0] <= m_u32ProbabilityL1 + m_u32ProbabilityL2 + m_u32ProbabilityL3 + m_u32ProbabilityL4 + m_u32ProbabilityL5) {
            if (m_u32Level5Used >= m_u32Level5Count) {
                _lv = 3;
            } else {
                _lv = 5;
            }
        } 

        _hr = _lv;
        if (_lv == 4) {
            _hr = _hr4;
            m_u32Level4Used++;
        } else if (_lv == 5) {
            _hr = _hr5;
            m_u32Level5Used++;
        }

        _ty = (_seed[0] * _seed[1] + now) % maxHeroType;
    }

    function setHashCfg (
        uint32 _level4HashrateMin,
        uint32 _level5HashrateMin,
        uint32 _level6HashrateMin,
        uint32 _level4HashrateMax,
        uint32 _level5HashrateMax,
        uint32 _level6HashrateMax,
        uint32 _level4HashrateStep,
        uint32 _level5HashrateStep,
        uint32 _level6HashrateStep,
        uint32 _level4HashrateStep1,
        uint32 _level5HashrateStep1,
        uint32 _level6HashrateStep1
    ) public onlyGuardian {
        level4HashrateMin =   _level4HashrateMin;
        level5HashrateMin =   _level5HashrateMin;
        level6HashrateMin =   _level6HashrateMin;
        level4HashrateMax =   _level4HashrateMax;
        level5HashrateMax =   _level5HashrateMax;
        level6HashrateMax =   _level6HashrateMax;
        level4HashrateStep =  _level4HashrateStep;
        level5HashrateStep =  _level5HashrateStep;
        level6HashrateStep =  _level6HashrateStep;
        level4HashrateStep1 = _level4HashrateStep1;
        level5HashrateStep1 = _level5HashrateStep1;
        level6HashrateStep1 = _level6HashrateStep1;
    }

    function setLevelUpV4(
        uint256[] memory lvs_, 
        uint256[] memory countV1_, 
        uint256[] memory countV2_, 
        uint256[] memory countV3_, 
        uint256[] memory countV4self_,
        uint256[] memory levelV4_
    ) public onlyGuardian {
        require(lvs_.length == countV1_.length && lvs_.length == countV2_.length, "invalid param");
        require(lvs_.length == countV3_.length && lvs_.length == countV4self_.length, "invalid param");
        uint256 level;
        for (uint256 i = 0; i < lvs_.length; ++i) {
            level = lvs_[i];
            require(level > 0 && level <= levelMaxV4, "invalid prototype");
            uint256 cfgVal = countV1_[i] + (countV2_[i] << 32) + (countV3_[i] << 64) + (countV4self_[i] << 96) + (levelV4_[i] << 128);
            _levelUpV4[level] = cfgVal;
        }
    }

    function setLevelUpV5(
        uint256[] memory lvs_, 
        uint256[] memory countV1_, 
        uint256[] memory countV2_, 
        uint256[] memory countV3_,
        uint256[] memory countV4_, 
        uint256[] memory levelV4_,
        uint256[] memory countV5self_
    ) public onlyGuardian {
        require(lvs_.length == countV1_.length && lvs_.length == countV2_.length && lvs_.length == countV3_.length, "invalid param");
        require(lvs_.length == countV4_.length && lvs_.length == levelV4_.length && lvs_.length == countV5self_.length, "invalid param");
        uint256 level;
        for (uint256 i = 0; i < lvs_.length; ++i) {
            level = lvs_[i];
            require(level > 0 && level <= levelMaxV5, "invalid prototype");
            uint256 cfgVal = countV1_[i] + (countV2_[i] << 32) + (countV3_[i] << 64) + (countV4_[i] << 96) + (levelV4_[i] << 128) + (countV5self_[i] << 160);
            _levelUpV5[level] = cfgVal;
        }
    }

    function setLevelUpV6(
        uint256[] memory lvs_, 
        uint256[] memory countV1_, 
        uint256[] memory countV2_, 
        uint256[] memory countV3_,
        uint256[] memory countV4_, 
        uint256[] memory levelV4_,
        uint256[] memory countV5_,
        uint256[] memory countV6Self
    ) public onlyGuardian {
        require(lvs_.length == countV1_.length && lvs_.length == countV2_.length && lvs_.length == countV3_.length, "invalid param");
        require(lvs_.length == countV4_.length && lvs_.length == levelV4_.length && lvs_.length == countV5_.length, "invalid param");
        require(lvs_.length == countV6Self.length, "invalid param");
        uint256 level;
        for (uint256 i = 0; i < lvs_.length; ++i) {
            level = lvs_[i];
            require(level > 0 && level <= levelMaxV6, "invalid prototype");
            uint256 cfgVal = countV1_[i] + (countV2_[i] << 32) + (countV3_[i] << 64) + (countV4_[i] << 96) + (levelV4_[i] << 128) + (countV5_[i] << 160) + (countV6Self[i] << 192);
            _levelUpV6[level] = cfgVal;
        }
    }

    function getURI(uint256 tokenId_, uint256 prototype_) external view returns(string memory uri) {
        uri = _ipfsUrisSpecial[tokenId_];
        if (bytes(uri).length < 1) {
            uri = _ipfsUrisGeneral[prototype_];
        } 
    }


    function getLevelUpV4(uint256 currentLevel_) 
        external 
        view 
        returns(
            uint256 countV1,
            uint256 countV2,
            uint256 countV3,
            uint256 countV4Self,
            uint256 levelV4
        ) 
    {
        uint256 cfgVal = _levelUpV4[currentLevel_];
        require(cfgVal > 0 && currentLevel_ < levelMaxV4, "level limited");
        countV1 = cfgVal % 0x0100000000;
        countV2 = (cfgVal >> 32) % 0x0100000000;
        countV3 = (cfgVal >> 64) % 0x0100000000;
        countV4Self = (cfgVal >> 96) % 0x0100000000;
        levelV4 = (cfgVal >> 128) % 0x0100000000;
    }

    function getLevelUpV5(uint256 currentLevel_) 
        external 
        view 
        returns(
            uint256 countV1,
            uint256 countV2,
            uint256 countV3,
            uint256 countV4,
            uint256 levelV4,
            uint256 countV5Self
        ) 
    {
        uint256 cfgVal = _levelUpV5[currentLevel_];
        require(cfgVal > 0 && currentLevel_ < levelMaxV5, "level limited");
        countV1 = cfgVal % 0x0100000000;
        countV2 = (cfgVal >> 32) % 0x0100000000;
        countV3 = (cfgVal >> 64) % 0x0100000000;
        countV4 = (cfgVal >> 96) % 0x0100000000;
        levelV4 = (cfgVal >> 128) % 0x0100000000;
        countV5Self = (cfgVal >> 160) % 0x0100000000;
    }

    function getLevelUpV6(uint256 currentLevel_) 
        external 
        view 
        returns(
            uint256 countV1,
            uint256 countV2,
            uint256 countV3,
            uint256 countV4,
            uint256 levelV4,
            uint256 countV5,
            uint256 countV6Self
        ) 
    {
        uint256 cfgVal = _levelUpV6[currentLevel_];
        require(cfgVal > 0 && currentLevel_ < levelMaxV6, "level limited");
        countV1 = cfgVal % 0x0100000000;
        countV2 = (cfgVal >> 32) % 0x0100000000;
        countV3 = (cfgVal >> 64) % 0x0100000000;
        countV4 = (cfgVal >> 96) % 0x0100000000;
        levelV4 = (cfgVal >> 128) % 0x0100000000;
        countV5 = (cfgVal >> 160) % 0x0100000000;
        countV6Self = (cfgVal >> 192) % 0x0100000000;
    }

    struct HsTmp {
        uint start;
        uint end;
        uint step;
        uint step1;
        uint rate;
        uint _levelMax;
    }

    function getHashrate(uint q, uint com, uint r) public view returns (uint[] memory _hr, uint[] memory _lhr) {
    // function getHashrate(uint16 q, uint8 com, uint8 r) public  {
        HsTmp memory hst = HsTmp(level4HashrateMin, level4HashrateMax, level4HashrateStep, level4HashrateStep1, r, SafeMathExt.safe16(levelMaxV4));

        if (q == 5) {
            hst.start = level5HashrateMin;
            hst.end = level5HashrateMax;
            hst.step = level5HashrateStep;
            hst.step1 = level5HashrateStep1;

            hst._levelMax = SafeMathExt.safe16(levelMaxV5);
        } else if (q == 6) {
            hst.start = level6HashrateMin;
            hst.end = level6HashrateMax;
            hst.step = level6HashrateStep;
            hst.step1 = level6HashrateStep1;

            hst._levelMax = SafeMathExt.safe16(levelMaxV6);
        }

        uint inc1 = (com - hst.start)/2;
        uint inc2;
        if ((com - hst.start)%2==0){
            inc2 = inc1;
        }else{
            inc2 = inc1+1;
        }

        uint _value=0;
        uint _last = com*1;
        uint pianyi = 0;
        

        if ((com * 1000000 - hst.start * 1000000) / 20  < 125000 && com > hst.start){
            pianyi = 125000;
        }else {
            pianyi = (com * 1000000 - hst.start * 1000000)/20;
        }

        uint256 ispianyi=0;
        uint256 lastrate=0;//上次产生偏移时的余数
        uint256 lastlv=0;//上次产生偏移的等级
        uint256 steprate=0;//5级阶梯偏移量

        uint16 xx = 0;
        
        _hr = new uint[](39);
        _lhr = new uint[](39);

        for (uint m=2;m<hst._levelMax + 1;m++){
            uint _last1 = _last;
            if ((m-1)%2>0 && m>1){
                _value = hst.step+inc1;
            }else{
                _value = hst.step+inc2;
            }
            if (m%hst.rate==0&&m>4){


                if ((pianyi*(m * 1000000 / hst.rate) / 1000000) >= 500000){//产生偏移

                    if (pianyi*(m*1000000/hst.rate)/1000000-lastrate>=500000)//减去上次积累的余数
                    {
                        ispianyi ++;
                        _value = _value + ispianyi;
                        lastrate = lastrate +pianyi*((m-lastlv)*1000000/hst.rate)/1000000;
                        if (lastlv > 0) {
                            if ((pianyi*((m-lastlv)*1000000/hst.rate)/1000000)*(((m-lastlv)*1000000)/hst.rate/1000000) >= 500000) {
                                
                                uint x1 = (pianyi*(((m-lastlv)*1000000/hst.rate))/1000000) * (((m-lastlv)*1000000/hst.rate) / 1000000);
                                if (x1 % 1000000 >= 500000) {
                                    x1 = x1 / 1000000 + 1;
                                } else {
                                    x1 = x1 / 1000000;
                                }

                                steprate = steprate+x1;
                                // steprate = steprate+pianyi*(((m-lastlv)*1000/hst.rate)/1000)/1000*((m-lastlv)*1000/hst.rate/1000);
                            }
                        }
                    }

                    if(lastlv == 0){
                        lastlv = m;
                    }
                }
                _value = _value + m*1000000/hst.rate*hst.step1/1000000+steprate;
            }

            _last = _last+_value;
            _hr[xx] = _last;
            _lhr[xx] = _last1;
            xx++;
        }
        // max = _hr[xx-1];
        // max = _last;
    }
}