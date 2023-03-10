/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BeanQuestBosses is Ownable {
    using Strings for uint256;


    struct Boss {
        string name;
        string img;
        uint STRneeded;
        uint DEXneeded;
        uint INTneeded;
        uint rewardMultiplier;
        uint nftDrop;
        uint amountDropped;
    }

    struct UserInfo {
        address upline;
        uint256 checkpoint;
        uint256 deposit_amount;
        uint256 payouts;
        uint256 direct_bonus;
        uint256 pool_bonus;
        uint256 match_bonus;
    }
    
    uint randNonce = 42;

    mapping (address => bool) private arrowToTheKnee;
    function shootArrowToTheKnee(address _adventurer, bool _shot) public onlyOwner {
        arrowToTheKnee[_adventurer] = _shot;
    }


    uint recoveryTime = 43200;

    function setRecoveryTime(uint _newTime) public onlyOwner {
        recoveryTime = _newTime;
    }

    address kvrfAddress;
    KenshiVRF vrf = KenshiVRF(kvrfAddress);

    address gachaAddress;
    BeanQuestGacha gacha = BeanQuestGacha(gachaAddress);

    address minerContract; 
    BeanQuest miner = BeanQuest(minerContract);

    address nftContract;
    BeanQuestNFTs nft = BeanQuestNFTs(nftContract);

    address vrfAddress;
    BeanVRF bean = BeanVRF(vrfAddress);

    Boss[] private bosses;
    uint public currentBoss;

    
    function setCurrentBoss(uint id) public onlyOwner {
        currentBoss = id;
    }

    string public bossUrl;

    function setBossUrl(string memory url) public onlyOwner {
        bossUrl = url;
    }

    function getBossUrl(uint id) public view returns(string memory) {
        return bytes(bossUrl).length > 0 ? string(abi.encodePacked(bossUrl, id.toString())) : "";
    }

    function createBoss(string memory _name, string memory img, uint _str, uint _dex, uint _int, uint _rwd, uint _nft, uint _amtDropped) public onlyOwner {
        bosses.push(Boss(_name, img, _str, _dex, _int, _rwd, _nft, _amtDropped));
    }

    function setBoss(uint8 _id, string memory _name, string memory _img, uint _str, uint _dex, uint _int, uint _rwd, uint _nft, uint _amtDropped) public onlyOwner {
        Boss(bosses[_id].name = _name, bosses[_id].img = _img, bosses[_id].STRneeded = _str, bosses[_id].DEXneeded = _dex, bosses[_id].INTneeded = _int, bosses[_id].rewardMultiplier = _rwd, bosses[_id].nftDrop = _nft, bosses[_id].amountDropped = _amtDropped);
    }

    function setContracts(address _mContract, address _gachaAddress, address _vrfContract, address _nftContract, address _beanVRF) public onlyOwner {
        kvrfAddress = _vrfContract;
        vrf = KenshiVRF(_vrfContract);

        gachaAddress = _gachaAddress;
        gacha = BeanQuestGacha(_gachaAddress);

        minerContract = _mContract; 
        miner = BeanQuest(_mContract);

        nftContract = _nftContract;
        nft = BeanQuestNFTs(_nftContract);

        vrfAddress = _beanVRF;
        bean = BeanVRF(_beanVRF);
    }

    function getBossName(uint _id) external view returns (string memory) {
        return bosses[_id].name;
    }

    function getBossStats(uint _id) external view returns(uint[6] memory) {
        uint[6] memory _stats;
        _stats[0] = bosses[_id].STRneeded;
        _stats[1] = bosses[_id].DEXneeded;
        _stats[2] = bosses[_id].INTneeded;
        _stats[3] = _stats[0] + _stats[1] + _stats[2];
        if(_stats[0] < _stats[1] && _stats[0] < _stats[2]) {
            _stats[4] = _stats[0];
            _stats[5] = 0;
        }
        if(_stats[1] < _stats[0] && _stats[1] < _stats[2]) {
            _stats[4] = _stats[1];
            _stats[5] = 1;

        }
        if(_stats[2] < _stats[0] && _stats[2] < _stats[1]) {
            _stats[4] = _stats[2];
            _stats[5] = 2;
        }
        return _stats;
    }

    function getBossReward(uint _id) external view returns (uint) {
        // require(msg.sender == minerContract);
        return bosses[_id].rewardMultiplier;
    } 

    function getBossNFT(uint _id) external view returns (uint) {
        // require(msg.sender == minerContract);
        return bosses[_id].nftDrop;
    }

    function bossEverything(uint _id) external view returns(Boss memory) {
        return bosses[_id];
    }

    function getBossItemAmount(uint _id) external view returns(uint) {
        return bosses[_id].amountDropped;
    }

    function bossInfo(uint _id) external view returns (string memory _name, uint _rwd, uint _nft, string memory _img) {
        return (bosses[_id].name, bosses[_id].rewardMultiplier, bosses[_id].nftDrop, bosses[_id].img);
    }

    function getBossInfo() external view returns (string memory _name, uint _rwd, uint _nft, string memory _img) {
        return (bosses[currentBoss].name, bosses[currentBoss].rewardMultiplier, bosses[currentBoss].nftDrop, bosses[currentBoss].img);
    }

    function fightBoss(uint8 _attribute) external {
        (address upline, uint256 checkpoint, uint256 deposit_amount, uint256 payouts, uint256 direct_bonus, uint256 pool_bonus, uint256 match_bonus) = miner.userInfo(msg.sender);
        require(!miner.defeatedThisRound(currentBoss, msg.sender), "You have already defeated this boss.");
        uint _timeLimit = nft.getEffectStatus(18, msg.sender) ? recoveryTime - nft.getBonusMultiplier(nft.getRelicActiveForBonus(msg.sender, 18)) : recoveryTime;
        require(block.timestamp - checkpoint > _timeLimit, "You must wait 12 hours before attempting to fight the boss");
        uint requestId = gacha.getRequestId(_attribute, msg.sender, true);
        vrf.requestRandomness(requestId);   
    }

    function lookForBeanVRF() external {
        require(!arrowToTheKnee[msg.sender], "You used to be an adventurer, but then you took an arrow to the knee.");
        require (miner.checkIfEligibleForMagicBean(msg.sender), "You are not eligible to search for magic beans");
        bean.requestLookForBean(msg.sender);
    }

    

    // function chanceCalculator(uint _modulus) internal returns(uint){
    //     // increase nonce
    //     randNonce++; 
    //     return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
    // }

}

contract BeanQuestNFTs {
    function getEffectStatus(uint8 _bonus, address _add) public view returns(bool) {}
    function getRelicActiveForBonus(address _add, uint8 _bonus) public view returns(uint) {}
    function getBonusMultiplier(uint _id) public view returns (uint) {}
    function mint(uint _id, address _add, uint amount) public {}
    function _burnHaste(address _addr) external {}
    function updateStats(uint payout, address _addr, uint8 _attribute) external returns(uint) {}

}

contract BeanVRF {
    function requestLookForBean(address _addr) external{}
}

contract BeanQuestGacha {
    function getRequestId(uint8 _attribute, address _addr, bool _fightBoss) external returns(uint) {}
}

contract BeanQuest {
    function checkIfEligibleForMagicBean(address _addr) public view returns(bool) {}
    mapping(uint => mapping(address => bool)) public defeatedThisRound;
    // function getDefeatedThisRound(uint _boss, address _addr) view external returns(bool) {}
    function userInfo(address _addr) view external returns(address upline, uint256 checkpoint, uint256 deposit_amount, uint256 payouts, uint256 direct_bonus, uint256 pool_bonus, uint256 match_bonus) {}
}

contract KenshiVRF {
    function requestRandomness(uint requestId) external {}
}