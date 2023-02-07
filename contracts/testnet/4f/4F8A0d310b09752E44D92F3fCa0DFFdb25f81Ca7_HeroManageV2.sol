// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./lib/openzeppelin/contracts/utils/math/SafeCast.sol";
import "./lib/openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./lib/openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Common.sol";
import "./Configable.sol";
import "./lib/Signature.sol";

contract HeroManageV2 is IHeroManage, ReentrancyGuard, Configable {

    using SafeCast for uint;

    address public SIGNER;
    IHero721V2 public hero721;
    IERC20 public burger20;

    address public nftlease;

    uint private rand_seed;
    uint public summon_price = 1 ether;

    uint32 public cd = 43200;

    uint32 public mutation_rate1 = 20;
    uint32 public mutation_rate2 = 10;

    uint16 constant max_creation = 10000;
    uint32 public descendants_token_count = max_creation;

    event OpenBox(address owner, uint32 token_id);
    event Summon(address owner, uint price);

    constructor(address _hero721, address _burger20, address _signer)
    {
        owner = msg.sender;
        hero721 = IHero721V2(_hero721);
        burger20 = IERC20(_burger20);
        SIGNER = _signer;
        rand_seed = 0;
    }

    function calcSummonBurger(uint32 _token_id1, uint32 _token_id2) external view returns (uint)
    {
        HeroMetaDataV2 memory meta1 = hero721.getMeta(_token_id1);
        HeroMetaDataV2 memory meta2 = hero721.getMeta(_token_id2);

        return calcSummonBurgerInner(meta1) + calcSummonBurgerInner(meta2);
    }

    function openBox(uint32 _token_id, address _account, uint _seed, uint _expiry_time, bytes memory _signatures) external nonReentrant
    {
        require(verify(_account, _seed, _expiry_time, _signatures), "this sign is not valid");
        require(_expiry_time > block.timestamp, "_seed expired");
        require(_account == msg.sender, "only the account signatures can open");
        _openBox(_token_id, _seed);
    }

    function batchOpenBox(uint32[] memory _token_ids) external onlyAdmin nonReentrant {
        for (uint i = 0; i < _token_ids.length; i++) {
            _openBox(_token_ids[i], block.timestamp);
        }
    }

    function summon(uint32 _token_id1, uint32 _token_id2, address _account, uint _seed, uint _expiry_time, bytes memory _signatures) external nonReentrant
    {
        require(_token_id1 != _token_id2, "same token_id");

        require(hero721.ownerOf(_token_id1) == msg.sender, "only the owner can summon");
        require(hero721.ownerOf(_token_id2) == msg.sender, "only the owner can summon");
        require(verify(_account, _seed, _expiry_time, _signatures), "this sign is not valid");
        require(_expiry_time > block.timestamp, "_seed expired");
        require(_account == msg.sender, "only the account signatures can summon");

        HeroMetaDataV2 memory meta1 = hero721.getMeta(_token_id1);
        HeroMetaDataV2 memory meta2 = hero721.getMeta(_token_id2);

        makeNew(msg.sender, _token_id1, meta1, _token_id2, meta2, _seed);
    }

    function summonLease(address _account, uint32 _token_id1, uint32 _token_id2, uint _seed, uint _expiry_time, bytes memory _signatures) external nonReentrant
    {
        require(msg.sender == nftlease);
        require(_token_id1 != _token_id2, "same token_id");
        require(hero721.ownerOf(_token_id1) == _account, "only the owner can summon");
        require(verify(_account, _seed, _expiry_time, _signatures), "this sign is not valid");
        require(_expiry_time > block.timestamp, "_seed expired");
        
        HeroMetaDataV2 memory meta1 = hero721.getMeta(_token_id1);
        HeroMetaDataV2 memory meta2 = hero721.getMeta(_token_id2);

        makeNew(_account, _token_id1, meta1, _token_id2, meta2, _seed);
    }

    //*****************************************************************************
    //* inner
    //*****************************************************************************
    function randMod(uint _seed) internal returns(uint) {
        uint base = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, rand_seed, _seed)));  
        unchecked {
            rand_seed += base;
        }     
        return base;
    }

    function max(uint _a, uint _b) internal pure returns(uint) {
        if (_a > _b) {
            return _a;
        }

        return _b;
    }

    function min(uint _a, uint _b) internal pure returns(uint) {
        if (_a < _b) {
            return _a;
        }

        return _b;
    }

    function calcRemainSummonCnt(HeroMetaDataV2 memory _meta) internal pure returns (uint32)
    {
        if (_meta.gen == 0) {
            return 100;
        }

        return (_meta.maxsummon_cnt - _meta.summon_cnt);
    }

    function calcSummonBurgerInner(HeroMetaDataV2 memory _meta) internal view returns (uint)
    {
        uint summon_cnt = min(_meta.summon_cnt, 13);

        uint burger = (uint(_meta.gen) * 10 + 6 + summon_cnt * 2) * summon_price;
        return burger;
    }

    function mixDNA(HeroMetaDataV2 memory _meta1, HeroMetaDataV2 memory _meta2, uint _seed) internal returns (uint8, uint8, uint8, uint8)
    {
        uint8[4] memory newdna;
        uint8[4] memory dna1;
        uint8[4] memory dna2;

        dna1[0] = _meta1.d;
        dna1[1] = _meta1.r1;
        dna1[2] = _meta1.r2;
        dna1[3] = _meta1.r3;

        dna2[0] = _meta2.d;
        dna2[1] = _meta2.r1;
        dna2[2] = _meta2.r2;
        dna2[3] = _meta2.r3;

        uint rand = randMod(_seed);      
        uint rate;
        
        //dna1
        rate = rand % 100;
        rand = rand / 100;
        if (rate < 25) {
            uint8 tmp = dna1[3];
            dna1[3] = dna1[2];
            dna1[2] = tmp;
        }

        rate = rand % 100;
        rand = rand / 100;
        if (rate < 25) {
            uint8 tmp = dna1[2];
            dna1[2] = dna1[1];
            dna1[1] = tmp;
        }

        rate = rand % 100;
        rand = rand / 100;
        if (rate < 25) {
            uint8 tmp = dna1[1];
            dna1[1] = dna1[0];
            dna1[0] = tmp;
        }

        //dna2
        rate = rand % 100;
        rand = rand / 100;
        if (rate < 25) {
            uint8 tmp = dna2[3];
            dna2[3] = dna2[2];
            dna2[2] = tmp;
        }

        rate = rand % 100;
        rand = rand / 100;
        if (rate < 25) {
            uint8 tmp = dna2[2];
            dna2[2] = dna2[1];
            dna2[1] = tmp;
        }

        rate = rand % 100;
        rand = rand / 100;
        if (rate < 25) {
            uint8 tmp = dna2[1];
            dna2[1] = dna2[0];
            dna2[0] = tmp;
        }

        //make new dna
        uint32 p1_rate1 = (100 - mutation_rate1) / 2 + mutation_rate1;
        uint32 p1_rate2 = (100 - mutation_rate2) / 2 + mutation_rate2;

        rate = rand % 100;
        rand = rand / 100;
        if ((dna1[0] == 1 && dna2[0] == 2) || (dna1[0] == 2 && dna2[0] == 1)) {
            if (rate < mutation_rate1) {
                newdna[0] = 9;
            } else if (rate < p1_rate1) {
                newdna[0] = dna1[0];
            } else {
                newdna[0] = dna2[0];
            }
        } else if ((dna1[0] == 3 && dna2[0] == 4) || (dna1[0] == 4 && dna2[0] == 3)) {
            if (rate < mutation_rate1) {
                newdna[0] = 10;
            } else if (rate < p1_rate1) {
                newdna[0] = dna1[0];
            } else {
                newdna[0] = dna2[0];
            }
        } else if ((dna1[0] == 5 && dna2[0] == 6) || (dna1[0] == 6 && dna2[0] == 5)) {
            if (rate < mutation_rate1) {
                newdna[0] = 11;
            } else if (rate < p1_rate1) {
                newdna[0] = dna1[0];
            } else {
                newdna[0] = dna2[0];
            }
        } else if ((dna1[0] == 7 && dna2[0] == 8) || (dna1[0] == 8 && dna2[0] == 7)) {
            if (rate < mutation_rate1) {
                newdna[0] = 12;
            } else if (rate < p1_rate1) {
                newdna[0] = dna1[0];
            } else {
                newdna[0] = dna2[0];
            }
        } else if ((dna1[0] == 9 && dna2[0] == 10) || (dna1[0] == 10 && dna2[0] == 9)) {
            if (rate < mutation_rate1) {
                newdna[0] = 13;
            } else if (rate < p1_rate1) {
                newdna[0] = dna1[0];
            } else {
                newdna[0] = dna2[0];
            }
        } else if ((dna1[0] == 11 && dna2[0] == 12) || (dna1[0] == 12 && dna2[0] == 11)) {
            if (rate < mutation_rate1) {
                newdna[0] = 14;
            } else if (rate < p1_rate1) {
                newdna[0] = dna1[0];
            } else {
                newdna[0] = dna2[0];
            }
        } else if ((dna1[0] == 13 && dna2[0] == 14) || (dna1[0] == 14 && dna2[0] == 13)) {
            if (rate < mutation_rate2) {
                newdna[0] = 15;
            } else if (rate < p1_rate2) {
                newdna[0] = dna1[0];
            } else {
                newdna[0] = dna2[0];
            }
        } else {
            if (rate < 50) {
                newdna[0] = dna1[0];
            } else {
                newdna[0] = dna2[0];
            } 
        }

        rate = rand % 100;
        rand = rand / 100;
        if (rate < 50) {
            newdna[1] = dna1[1];
        } else {
            newdna[1] = dna2[1];
        }

        rate = rand % 100;
        rand = rand / 100;
        if (rate < 50) {
            newdna[2] = dna1[2];
        } else {
            newdna[2] = dna2[2];
        }

        rate = rand % 100;
        rand = rand / 100;
        if (rate < 50) {
            newdna[3] = dna1[3];
        } else {
            newdna[3] = dna2[3];
        }

        return (newdna[0], newdna[1], newdna[2], newdna[3]);
    }

    function makeNew(address _to, uint32 _token_id1, HeroMetaDataV2 memory _meta1, uint32 _token_id2, HeroMetaDataV2 memory _meta2, uint _seed) internal
    {
        uint64 curtime = block.timestamp.toUint64();
        require(_meta1.opened, "token1 not open");
        require(_meta2.opened, "token2 not open");
        require(_meta1.summon_cd < curtime, "token1 cd");
        require(_meta2.summon_cd < curtime, "token2 cd");

        require(_meta1.p1 != _token_id2, "token1 p1 == token_id2");
        require(_meta1.p2 != _token_id2, "token1 p2 == token_id2");
        require(_meta2.p1 != _token_id1, "token2 p1 == token_id1");
        require(_meta2.p2 != _token_id1, "token2 p2 == token_id1");

        //calc summon num
        uint32 remainsummon1 = calcRemainSummonCnt(_meta1);
        uint32 remainsummon2 = calcRemainSummonCnt(_meta2);

        require(remainsummon1 > 0, "token1 cnt");
        require(remainsummon2 > 0, "token2 cnt");

        //calc burger
        uint sum_burger = calcSummonBurgerInner(_meta1) + calcSummonBurgerInner(_meta2);
        if (sum_burger > 0) {
            burger20.transferFrom(_to, address(this), sum_burger);
            emit Summon(_to, sum_burger);
        }

        //do summon logic
        HeroMetaDataV2 memory newmeta;
        //opened
        newmeta.opened = true;
        //gen
        newmeta.gen = uint8(max(_meta1.gen, _meta2.gen) + 1);
        //summon dna
        (newmeta.d, newmeta.r1, newmeta.r2, newmeta.r3) = mixDNA(_meta1, _meta2, _seed);
        //summon_cd
        newmeta.summon_cd = (uint(curtime) + 6 * uint(cd)).toUint64();
        //summon_cnt
        newmeta.summon_cnt = 0;
        //maxsummon_cnt
        if (newmeta.gen >= 11) {
            newmeta.maxsummon_cnt = 0;
        } else {
            uint maxsummon_cnt1 = 11 - newmeta.gen;
            uint maxsummon_cnt2;
            if (newmeta.d <= 8) {
                maxsummon_cnt2 = 10;
            } else if (newmeta.d <= 12) {
                maxsummon_cnt2 = 5;
            } else if (newmeta.d <= 14) {
                maxsummon_cnt2 = 3;
            } else {
                maxsummon_cnt2 = 1;
            }

            uint min1 = min(maxsummon_cnt1, maxsummon_cnt2);
            uint min2 = min(remainsummon1, remainsummon2) - 1;

            newmeta.maxsummon_cnt = uint8(min(min1, min2));
        }
        //p1
        newmeta.p1 = _token_id1;
        //p2
        newmeta.p2 = _token_id2;

        newmeta.morale = randMorale(newmeta.d, _seed);

        HeroMetaDataExt[] memory _exts;
        
        uint new_token_id = ++descendants_token_count;
        require(new_token_id < type(uint32).max, 'new_token_id overflow');
        hero721.mint(2, _to, new_token_id, newmeta, _exts);


        //change token1
        if (_meta1.summon_cnt < 100) {
            _meta1.summon_cnt += 1;            
        }

        uint summon_cnt1 = min(_meta1.summon_cnt, 13);

        _meta1.summon_cd = (uint(curtime) + (uint(_meta1.gen) + summon_cnt1) * uint(cd) + uint(cd)).toUint64();
        hero721.setMeta(_token_id1, _meta1, _exts);

        //change token2
        if (_meta2.summon_cnt < 100) {
            _meta2.summon_cnt += 1;            
        }

        uint summon_cnt2 = min(_meta2.summon_cnt, 13);

        _meta2.summon_cd = (uint(curtime) + (uint(_meta2.gen) + summon_cnt2) * uint(cd) + uint(cd)).toUint64();
        hero721.setMeta(_token_id2, _meta2, _exts);
    }

    function _openBox(uint32 _token_id, uint _seed) internal
    {
        require(hero721.ownerOf(_token_id) == msg.sender, "only the owner can open box");

        HeroMetaDataV2 memory meta = hero721.getMeta(_token_id);
        require(!meta.opened, "box opened");

        meta.opened = true;
        meta.gen = 0;

        uint cdtime = block.timestamp + 2 * uint(cd);
        meta.summon_cd = cdtime.toUint64();

        meta.summon_cnt = 0;
        meta.maxsummon_cnt = 0;

        uint rand = randMod(_seed);
        uint8 rate;

        rate = uint8(rand % 8);
        rand = rand / 8;
        meta.d = uint8(rate + 1);

        rate = uint8(rand % 8);
        rand = rand / 8;
        meta.r1 = uint8(rate + 1);

        rate = uint8(rand % 8);
        rand = rand / 8;
        meta.r2 = uint8(rate + 1);

        rate = uint8(rand % 8);
        rand = rand / 8;
        meta.r3 = uint8(rate + 1);

        meta.p1 = 0;
        meta.p2 = 0;

        meta.morale = randMorale(meta.d, _seed);

        HeroMetaDataExt[] memory _exts;

        hero721.setMeta(_token_id, meta, _exts);
        emit OpenBox(msg.sender, _token_id);
    }

    function randMorale(uint8 d, uint _seed) internal returns (uint8) {
        
        uint rand = randMod(_seed);
        uint8 rate = uint8(rand % 41);

        if (d >= 1 && d <= 8) {
            return 30 + rate;
        } else if (d >= 9 && d <= 12) {
            return 35 + rate;
        } else if (d >= 13 && d <= 14) {
            return 40 + rate;
        } else if (d == 15) {
            return 45 + rate;
        } else {
            return 0;
        }
    }

    function verify(address _account, uint _seed, uint _expiry_time, bytes memory _signatures) public view returns (bool) {

        bytes32 message = keccak256(abi.encodePacked(_account, _seed, _expiry_time));
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message));
        address[] memory sign_list = Signature.recoverAddresses(hash, _signatures);
        return sign_list[0] == SIGNER;
    }

    //*****************************************************************************
    //* manage
    //*****************************************************************************
    function withdraw(address _to) external onlyAdmin
    {
        if (address(this).balance > 0) {
            payable(_to).transfer(address(this).balance);
        }
    }

    function withdrawBurger(address _to) external onlyAdmin
    {
        uint balance = burger20.balanceOf(address(this));
        if (balance > 0) {
            burger20.transfer(_to, balance);
        }
    }

    function balanceOfBurger() external view returns (uint)
    {
        return burger20.balanceOf(address(this));
    }

    function setSummonPrice(uint _price) external onlyAdmin
    {
        require(_price > 0, "summon price should > 0");

        summon_price = _price;
    }

    function setSummonCD(uint32 _cd) external onlyAdmin
    {
        require(_cd > 0, "summon cd should > 0");

        cd = _cd;
    }

    function setMutationRate(uint32 _mutation_rate1, uint32 _mutation_rate2) external onlyAdmin
    {
        require(_mutation_rate1 <= 100, "_mutation_rate1 should <= 100");
        require(_mutation_rate2 <= 100, "_mutation_rate2 should <= 100");

        require(_mutation_rate1 % 2 == 0, "_mutation_rate1 must be an even number");
        require(_mutation_rate2 % 2 == 0, "_mutation_rate2 must be an even number");

        mutation_rate1 = _mutation_rate1;
        mutation_rate2 = _mutation_rate2;
    }

    function setHero721(address _hero721) external onlyDev
    {
        require(_hero721 != address(0), "address should not 0");
        hero721 = IHero721V2(_hero721);
    }

    function setBurger20(address _burger20) external onlyDev
    {
        require(_burger20 != address(0), "address should not 0");
        burger20 = IERC20(_burger20);
    }

    function setNFTLease(address _nftlease) external onlyDev
    {
        require(_nftlease != address(0), "address should not 0");
        nftlease = _nftlease;
    }

    function setSigner(address _signer) external onlyAdmin
    {
        SIGNER = _signer;
    }

    function setDescendantsTokenCount(uint32 _token_count) external onlyDev
    {
        require(_token_count > max_creation, "must be greater than max creation");
        descendants_token_count = _token_count;
    }

    function kill() external onlyOwner
    {
        uint balance = burger20.balanceOf(address(this));
        if (balance > 0) {
            burger20.transfer(owner, balance);
        }
        selfdestruct(payable(owner));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCast {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./lib/openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./lib/openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./lib/openzeppelin/contracts/token/ERC1155/IERC1155.sol";


//Hero data structure
struct HeroMetaData {
    bool opened;        //box or hero
    uint8 gen;          //generation

    uint64 summon_cd;       //next summon time
    uint8 summon_cnt;       //current summon count
    uint8 maxsummon_cnt;    //max summon count
    uint8 d;      //Dominant gene
    uint8 r1;     //Recessive gene 1
    uint8 r2;     //Recessive gene 2
    uint8 r3;     //Recessive gene 3
    uint32 p1;    //parent 1
    uint32 p2;    //parent 2
}

//Hero data structure
struct HeroMetaDataV2 {
    bool opened;        //box or hero
    uint8 gen;          //generation

    uint64 summon_cd;       //next summon time
    uint8 summon_cnt;       //current summon count
    uint8 maxsummon_cnt;    //max summon count
    uint8 d;      //Dominant gene
    uint8 r1;     //Recessive gene 1
    uint8 r2;     //Recessive gene 2
    uint8 r3;     //Recessive gene 3
    uint32 p1;    //parent 1
    uint32 p2;    //parent 2
    uint8 morale;      //morale
}

struct HeroMetaDataExt {
    uint256 key;
    uint256 val;
}


interface IHero721 is IERC721, IERC721Enumerable {
    function getMeta(uint32 token_id) external view returns (HeroMetaData memory);
    function setMeta(uint32 token_id, HeroMetaData calldata meta) external;
    function burn(uint32 token_id) external;
    function exists(uint32 token_id) external view returns (bool);
    function createCreationTo(address to, HeroMetaData calldata meta) external;
    function createDescendantsTo(address to, HeroMetaData calldata meta) external;
    function calcCreationLimit() external view returns (uint16);
}

interface IHero721V2 is IERC721, IERC721Enumerable {
    function getMeta(uint256 token_id) external view returns (HeroMetaDataV2 memory);
    function getMeta2(uint256 _token_id) external view returns (HeroMetaDataV2 memory meta, HeroMetaDataExt[] memory exts);
    function getMetas2(uint256[] memory _token_ids) external view returns (uint256[] memory token_ids, HeroMetaDataV2[] memory metas, HeroMetaDataExt[][] memory exts);
    function setMeta(uint256 _token_id, HeroMetaDataV2 calldata _meta, HeroMetaDataExt[] calldata _exts) external;
    function burn(uint256 token_id) external;
    function mint(uint8 _mint_type, address _to, uint256 _token_id, HeroMetaDataV2 calldata _meta, HeroMetaDataExt[] calldata _exts) external;
    function exists(uint256 token_id) external view returns (bool);
    function getExtKeys() external view returns (uint256[] memory);
    function existExtKey(uint256 _key) external view returns (bool);

}

interface IClothing721 {
    function manageMintTo(address to, uint32 clothes_id) external;
}

interface IHeroManage {
    function summonLease(address _account, uint32 _token_id1, uint32 _token_id2, uint _seed, uint _expiry_time, bytes memory _signatures) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IConfig {
    function dev() external view returns (address);
    function admin() external view returns (address);
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

pragma solidity >=0.8.0;

library Signature {
    function recoverAddresses(bytes32 _hash, bytes memory _signatures) internal pure returns (address[] memory addresses) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint count = _countSignatures(_signatures);
        addresses = new address[](count);
        for (uint i = 0; i < count; i++) {
            (v, r, s) = _parseSignature(_signatures, i);
            addresses[i] = ecrecover(_hash, v, r, s);
        }
    }
    
    function _parseSignature(bytes memory _signatures, uint _pos) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        uint offset = _pos * 65;
        assembly {
            r := mload(add(_signatures, add(32, offset)))
            s := mload(add(_signatures, add(64, offset)))
            v := and(mload(add(_signatures, add(65, offset))), 0xff)
        }

        if (v < 27) v += 27;

        require(v == 27 || v == 28);
    }
    
    function _countSignatures(bytes memory _signatures) internal pure returns (uint) {
        return _signatures.length % 65 == 0 ? _signatures.length / 65 : 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}