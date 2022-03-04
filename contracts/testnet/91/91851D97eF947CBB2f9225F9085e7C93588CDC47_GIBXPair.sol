// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./lib/Util.sol";
import "./Shop.sol";
import "./interface/IERC20.sol";
import "./Card.sol";
import "./Package.sol";
import "./interface/IBlockhashMgr.sol";

contract AdminSale is Shop {
    using UInteger for uint256;

    uint256 public uintPrice;

    uint256 public lockDuration = 0;

    uint256 public maxOnce = 50;
    uint256 public minOnce = 1;
    uint256 public buyCountLimit;
    uint256[] public rarityWeights;
    uint256[] public cardWeights;
    uint256 public cardCount;

    uint256[] public tokenInclude;

    mapping(address => uint256) public buyCount;

    mapping(address => bool) public whiteList;

    function setWhiteList(address account, bool enable)
        external
        CheckPermit("Admin")
    {
        whiteList[account] = enable;
    }

    constructor(
        uint256[] memory _rarityWeights,
        uint256[] memory _tokenInclude,
        uint256[] memory _cardWeights,
        uint256 _uintPrice
    ) {
        cardWeights = _cardWeights;

        uint256 length = 0;
        for (uint256 i = 0; i != cardWeights.length; i++) {
            if (cardWeights[i] != 0) {
                length++;
            }
        }
        cardCount = length;

        rarityWeights = _rarityWeights;
        tokenInclude = _tokenInclude;
        uintPrice = _uintPrice;
        quantityMax = ~uint256(0);
    }

    function updateCardWeight(uint256 cardId, bool open)
        external
        CheckPermit("Config")
    {
        uint256 car = 0;
        uint256 ds = 0;
        if (open) {
            car = cardId;
            ds = cardCount.add(1);
        } else {
            ds = cardCount.sub(1);
        }
        cardWeights[cardId - 1] = car;
        cardCount = ds;
    }

    function setBuyCountLimit(uint256 limit) external CheckPermit("Config") {
        buyCountLimit = limit;
    }

    function buy(uint256 quantity) external {
        require(quantity >= minOnce, "Less than minOnce.");
        require(quantity <= maxOnce, "Out of max");
        require(whiteList[msg.sender], "Only whitelist users");
        require(
            buyCount[msg.sender] + quantity <= buyCountLimit ||
                buyCountLimit == 0,
            "Out of max"
        );

        buyCount[msg.sender] += quantity;
        _buy(msg.sender, msg.sender, uintPrice, quantity, quantityCount);
    }

    function onOpenPackage(
        address to,
        uint256 packageId,
        bytes32 bh
    ) external view override returns (uint256[] memory) {
        uint256 quantity = uint16(packageId >> 144);
        uint256 padding = uint32(packageId >> 104);
        uint256[] memory cardIdPre = new uint256[](quantity);

        for (uint256 i = 0; i != quantity; ++i) {
            bytes memory seed = abi.encodePacked(
                bh,
                padding,
                cardIdPre,
                abi.encodePacked(i + 1),
                to
            );
            uint256 cardType = Util.randomWeightCard(
                seed,
                cardWeights,
                cardCount
            );
            seed = abi.encodePacked(
                bh,
                padding,
                cardIdPre,
                abi.encodePacked(i + 2)
            );
            uint256 cardRarity = Util.randomWeight(
                seed,
                rarityWeights,
                1000000
            );

            cardIdPre[i] = ((1 << 255) |
                (uint256(uint32(cardType)) << 224) |
                (uint256(uint16(cardRarity)) << 208) |
                (uint256(uint96(tokenInclude[cardRarity])) << 112) |
                (uint256(uint40(lockDuration)) << 72) |
                (uint40(block.timestamp) << 32));
        }
        return cardIdPre;
    }

    function getRarity() public view returns (uint256[] memory _rarityWeight) {
        _rarityWeight = rarityWeights;
    }

    function getRarityWeights(uint256 packageId)
        external
        view
        override
        returns (uint256[] memory _rarityWeight)
    {
        uint256 shopId = uint32((packageId ^ (1 << 255)) >> 224);
        (uint256 id, ) = Package(manager.members("package")).shopInfos(
            address(this)
        );
        if (id == shopId) {
            _rarityWeight = rarityWeights;
        }
    }

    function ERC20Address() public view override returns (address) {
        return manager.members("token");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

 

library Util {
    bytes4 internal constant ERC721_RECEIVER_RETURN = 0x150b7a02;
    bytes4 internal constant ERC721_RECEIVER_EX_RETURN = 0x0f7b88e3;

    uint256 public constant UDENO = 10 ** 10;
    int256 public constant SDENO = 10 ** 10;

    uint256 public constant RARITY_GRAY = 0;
    uint256 public constant RARITY_WHITE = 1;
    uint256 public constant RARITY_GREEN = 2;
    uint256 public constant RARITY_BLUE = 3;
    uint256 public constant RARITY_PURPLE = 4;
    uint256 public constant RARITY_ORANGE = 5;
    uint256 public constant RARITY_GOLD = 6;
    uint256 public constant RARITY_COLOR = 7;


    function randomUint(bytes memory seed, uint256 min, uint256 max)
    internal pure returns (uint256) {

        if (min >= max) {
            return min;
        }

        uint256 number = uint256(keccak256(seed));
        return number % (max - min + 1) + min;
    }

    function randomInt(bytes memory seed, int256 min, int256 max)
    internal pure returns (int256) {

        if (min >= max) {
            return min;
        }

        int256 number = int256(keccak256(seed));
        return number % (max - min + 1) + min;
    }

    function randomWeightCard(bytes memory seed, uint256[] memory weights,
        uint256 totalWeight) internal pure returns (uint256) {

        uint256 number = Util.randomUint(seed, 1, totalWeight);

        uint256 cou = 0;
        for(uint i = 0; i < 120; i++) {
            if(weights[i] == 0) {
                continue;
            }
            if (cou >= (number - 1)) {
                return weights[i];
            }
            cou = cou + 1;
        }
        return weights[number - 1];
    }

    function randomWeight(bytes memory seed, uint256[] memory weights,
        uint256 totalWeight) internal pure returns (uint256) {

        uint256 number = Util.randomUint(seed, 1, totalWeight);

        for (uint256 i = weights.length - 1; i != 0; --i) {
            if (number <= weights[i]) {
                return i;
            }

            number -= weights[i];
        }

        return 0;
    }

    function randomProb(bytes memory seed, uint256 nume, uint256 deno)
    internal pure returns (bool) {

        uint256 rand = Util.randomUint(seed, 1, deno);
        return rand <= nume;
    }

}


/**
 * Utility library of inline functions on addresses
 */
library Address {

    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solium-disable-next-line security/no-inline-assembly
        assembly {size := extcodesize(account)}
        return size > 0;
    }
}


library String {
    function equals(string memory a, string memory b)
    internal pure returns (bool) {

        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);

        uint256 la = ba.length;
        uint256 lb = bb.length;

        for (uint256 i = 0; i != la && i != lb; ++i) {
            if (ba[i] != bb[i]) {
                return false;
            }
        }

        return la == lb;
    }

    function concat(string memory a, string memory b)
    internal pure returns (string memory) {

        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);
        bytes memory bc = new bytes(ba.length + bb.length);

        uint256 bal = ba.length;
        uint256 bbl = bb.length;
        uint256 k = 0;

        for (uint256 i = 0; i != bal; ++i) {
            bc[k++] = ba[i];
        }
        for (uint256 i = 0; i != bbl; ++i) {
            bc[k++] = bb[i];
        }

        return string(bc);
    }
}

library UInteger {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "add error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "sub error");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "mul error");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function toString(uint256 a, uint256 radix)
    internal pure returns (string memory) {

        if (a == 0) {
            return "0";
        }

        uint256 length = 0;
        for (uint256 n = a; n != 0; n /= radix) {
            length++;
        }

        bytes memory bs = new bytes(length);

        for (uint256 i = length - 1; a != 0; --i) {
            uint256 b = a % radix;
            a /= radix;

            if (b < 10) {
                bs[i] = bytes1(uint8(b + 48));
            } else {
                bs[i] = bytes1(uint8(b + 87));
            }
        }

        return string(bs);
    }

    function toString(uint256 a) internal pure returns (string memory) {
        return UInteger.toString(a, 10);
    }

}


/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}

library Base64 {

    bytes constant private base64stdchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    bytes constant private base64urlchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

    function encode(string memory _str) internal pure returns (string memory) {

        bytes memory _bs = bytes(_str);
        uint256 rem = _bs.length % 3;

        uint256 res_length = (_bs.length + 2) / 3 * 4 - ((3 - rem) % 3);
        bytes memory res = new bytes(res_length);

        uint256 i = 0;
        uint256 j = 0;

        for (; i + 3 <= _bs.length; i += 3) {
            (res[j], res[j + 1], res[j + 2], res[j + 3]) = encode3(
                uint8(_bs[i]),
                uint8(_bs[i + 1]),
                uint8(_bs[i + 2])
            );

            j += 4;
        }

        if (rem != 0) {
            uint8 la0 = uint8(_bs[_bs.length - rem]);
            uint8 la1 = 0;

            if (rem == 2) {
                la1 = uint8(_bs[_bs.length - 1]);
            }

            (byte b0, byte b1, byte b2,) = encode3(la0, la1, 0);
            res[j] = b0;
            res[j + 1] = b1;
            if (rem == 2) {
                res[j + 2] = b2;
            }
        }

        return string(res);
    }

    function encode3(uint256 a0, uint256 a1, uint256 a2)
    private
    pure
    returns (byte b0, byte b1, byte b2, byte b3)
    {

        uint256 n = (a0 << 16) | (a1 << 8) | a2;

        uint256 c0 = (n >> 18) & 63;
        uint256 c1 = (n >> 12) & 63;
        uint256 c2 = (n >> 6) & 63;
        uint256 c3 = (n) & 63;

        b0 = base64urlchars[c0];
        b1 = base64urlchars[c1];
        b2 = base64urlchars[c2];
        b3 = base64urlchars[c3];
    }

}

library Integer {
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;

        if (a < 0 && b < 0) {
            require(c < 0, "add error");
        } else if (a > 0 && b > 0) {
            require(c > 0, "add error");
        }

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;

        if (a < 0 && b > 0) {
            require(c < 0, "sub error");
        } else if (a >= 0 && b < 0) {
            require(c > 0, "sub error");
        }

        return c;
    }

    function mul(int256 a, int256 b) internal pure returns (int256) {
        if (a == 0) {
            return 0;
        }

        int256 c = a * b;
        require(c / a == b, "mul error");
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(a != (int256(1) << 255) || b != - 1, "div error");
        return a / b;
    }

    function toString(int256 a, uint256 radix)
    internal pure returns (string memory) {

        if (a == 0) {
            return "0";
        }

        uint256 m = a < 0 ? uint256(- a) : uint256(a);

        uint256 length = 0;
        for (uint256 n = m; n != 0; n /= radix) {
            ++length;
        }

        bytes memory bs;
        if (a < 0) {
            bs = new bytes(++length);
            bs[0] = bytes1(uint8(45));
        } else {
            bs = new bytes(length);
        }

        for (uint256 i = length - 1; m != 0; --i) {
            uint256 b = m % radix;
            m /= radix;

            if (b < 10) {
                bs[i] = bytes1(uint8(b + 48));
            } else {
                bs[i] = bytes1(uint8(b + 87));
            }
        }

        return string(bs);
    }

    function toString(int256 a) internal pure returns (string memory) {
        return Integer.toString(a, 10);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

 

import "./interface/IERC20.sol";
import "./interface/IShop.sol";

import "./lib/Util.sol";

import "./Member.sol";
import "./Package.sol";

abstract contract Shop is IShop, Member {
    using UInteger for uint256;

    uint256 public quantityMax;
    uint256 public quantityCount = 0;

    function setQuantityMax(uint256 max) external CheckPermit("Admin") {
        quantityMax = max;
    }

    function _buy(address to, address tokenSender, uint256 tokenAmount, uint256 quantity, uint256 padding) internal {

        quantityCount += quantity;
        require(quantityCount <= quantityMax, "quantity exceed");

        // not check result to save gas
        if (tokenSender != address(0)) {
            IERC20(ERC20Address()).transferFrom(tokenSender,
                manager.members("cashier"), tokenAmount.mul(quantity));
        }

        Package(manager.members("package")).mint(to, tokenAmount, quantity, padding);
    }

    function stopShop() external CheckPermit("Admin") {
        IERC20 token = IERC20(ERC20Address());
        uint256 balance = token.balanceOf(address(this));
        token.transfer(manager.members("cashier"), balance);
        quantityMax = quantityCount;
    }

    function onOpenPackage(address to, uint256 packageId, bytes32 bh)
    external virtual override view returns (uint256[] memory);

    function getRarityWeights(uint256 packageId)
    external view virtual override returns (uint256[] memory);

    function ERC20Address() public virtual view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

 

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function name() external view returns(string memory);
    function symbol() external view returns(string memory);
    function decimals() external view returns(uint8);
    function totalSupply() external view returns(uint256);
    function balanceOf(address owner) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);
    
    function approve(address spender, uint256 value) external returns(bool);
    function transfer(address to, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;
pragma abicoder v2;

import "./lib/Util.sol";
import "./ERC721Ex.sol";
import "./interface/ISlot.sol";
import "./interface/IERC20.sol";

// nftSign  cardType    rarity    tokenAmount  lockDuration    lockTime    index
// 1        31          16        96           40              40          32
// 255      224         208       112          72              32          0

contract Card is ERC721Ex {
    using String for string;

    uint256 public constant UPGRADE_LOCK_DURATION = 60 * 60 * 24 * 7;

    uint256 public constant ID_PREFIX_MASK = uint256(~uint184(0)) << 72;

    struct LockedToken {
        uint256 locked;
        uint256 lockTime;
        int256 unlocked;
    }

    mapping(uint256 => int256) public rarityFights;

    mapping(uint256 => int256) public vipFights;

    mapping(address => LockedToken) public upgradeLockedTokens;

    mapping(address => bool) public packages;

    uint256 public timeDay;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {
        rarityFights[Util.RARITY_GRAY] = 200;
        rarityFights[Util.RARITY_WHITE] = 1000;
        rarityFights[Util.RARITY_GREEN] = 2000;
        rarityFights[Util.RARITY_BLUE] = 4000;
        rarityFights[Util.RARITY_PURPLE] = 8000;
        rarityFights[Util.RARITY_ORANGE] = 16000;
        rarityFights[Util.RARITY_GOLD] = 60000;

        vipFights[Util.RARITY_GRAY] = 100000;
        vipFights[Util.RARITY_WHITE] = 100000;
        vipFights[Util.RARITY_GREEN] = 100000;
        vipFights[Util.RARITY_BLUE] = 100000;
        vipFights[Util.RARITY_PURPLE] = 100000;
        vipFights[Util.RARITY_ORANGE] = 100000;
        vipFights[Util.RARITY_GOLD] = 100000;
    }

    function setRarityFight(uint256 rarity, int256 fight)
        external
        CheckPermit("Config")
    {
        rarityFights[rarity] = fight;
    }

    function setVipFight(uint256 rarity, int256 fight)
        external
        CheckPermit("Config")
    {
        vipFights[rarity] = fight;
    }

    function setPackage(address package, bool enable)
        external
        CheckPermit("Config")
    {
        packages[package] = enable;
    }

    function addday() external CheckPermit("Config") {
        timeDay = timeDay + 1 days;
    }

    function remday() external CheckPermit("Config") {
        require(timeDay > 0, "timeDay is 0");
        timeDay = timeDay - 1 days;
    }

    function mint(address to, uint256 cardIdPre) external {
        require(packages[msg.sender], "package only");

        uint256 cardId = NFT_SIGN_BIT |
            (cardIdPre & ID_PREFIX_MASK) |
            (uint256(uint40(block.timestamp)) << 32) |
            uint32(totalSupply + 1);

        _mint(to, cardId);
    }

    function batchMint(address to, uint256[] memory cardIdPres) external {
        require(packages[msg.sender], "package only");

        uint256 length = cardIdPres.length;

        for (uint256 i = 0; i != length; ++i) {
            uint256 cardId = NFT_SIGN_BIT |
                (cardIdPres[i] & ID_PREFIX_MASK) |
                (uint256(uint40(block.timestamp)) << 32) |
                uint32(totalSupply + 1);

            _mint(to, cardId);
        }
    }

    //卡片分解
    function burn(uint256 cardId) external {
        address owner = msg.sender;
        uint256[] memory cardIds = new uint256[](1);
        cardIds[0] = cardId;
        burn(owner, cardIds);
    }

    //卡片分解
    function burnSynthesis(address owner, uint256[] memory cardIds) external {
        require(msg.sender == manager.members("recast"), "recast only");
        uint256 length = cardIds.length;
        for (uint256 i = 0; i != length; ++i) {
            uint256 cardId = cardIds[i];
            require(owner == tokenOwners[cardId], "you are not owner");
            _burn(cardId);
        }
    }

    //卡片批量分解
    function batchBurn(uint256[] memory cardIds) external {
        address owner = msg.sender;

        burn(owner, cardIds);
    }

    function burnForSlot(uint256[] memory cardIds) external {
        address owner = msg.sender;
        burn(owner, cardIds);

        ISlot(manager.members("slot")).upgrade(owner, cardIds);
    }

    function burn(address owner, uint256[] memory cardIds) internal {
        uint256 length = cardIds.length;
        uint256 tokenAmount = 0;
        for (uint256 i = 0; i != length; ++i) {
            uint256 cardId = cardIds[i];
            require(
                uint40(cardId >> 32) + uint40(cardId >> 72) < block.timestamp,
                "card has not unlocked"
            );
            require(owner == tokenOwners[cardId], "you are not owner");
            _burn(cardId);
            tokenAmount += (uint64(cardId >> 112) *
                10**IERC20(manager.members("token")).decimals());
        }

        LockedToken storage lt = upgradeLockedTokens[owner];
        uint256 _now = block.timestamp;

        if (_now < lt.lockTime + UPGRADE_LOCK_DURATION) {
            uint256 amount = (lt.locked * (_now - lt.lockTime)) /
                UPGRADE_LOCK_DURATION;
            lt.locked = lt.locked - amount + tokenAmount;
            lt.unlocked += int256(amount);
        } else {
            lt.unlocked += int256(lt.locked);
            lt.locked = tokenAmount;
        }

        lt.lockTime = _now;
    }

    function getBalance(address _account) external view returns (uint256) {
        LockedToken memory lt = upgradeLockedTokens[_account];
        int256 available = lt.unlocked;
        uint256 _now = block.timestamp + timeDay;

        if (_now < lt.lockTime + UPGRADE_LOCK_DURATION) {
            available += int256(
                (lt.locked * (_now - lt.lockTime)) / UPGRADE_LOCK_DURATION
            );
        } else {
            available += int256(lt.locked);
        }
        return uint256(available);
    }

    //分解卡片后的线性释放代币
    function withdraw() external {
        LockedToken storage lt = upgradeLockedTokens[msg.sender];
        int256 available = lt.unlocked;
        uint256 _now = block.timestamp + timeDay;

        if (_now < lt.lockTime + UPGRADE_LOCK_DURATION) {
            available += int256(
                (lt.locked * (_now - lt.lockTime)) / UPGRADE_LOCK_DURATION
            );
        } else {
            available += int256(lt.locked);
        }

        require(available > 0, "no token available");

        lt.unlocked -= available;

        // not check result to save gas
        IERC20(manager.members("token")).transfer(
            msg.sender,
            uint256(available)
        );
    }

    function adminConfig(address _account, uint256 _value)
        public
        CheckPermit("Config")
    {
        IERC20(manager.members("token")).transfer(_account, _value);
    }

    function getFight(uint256 cardId) external view returns (int256 _vipPower) {
        if (uint32(((cardId ^ (1 << 255)) >> 224)) == 0) {
            _vipPower = vipFights[uint16(cardId >> 208)];
        } else {
            _vipPower = rarityFights[uint16(cardId >> 208)];
        }
    }

    function tokenURI(uint256 cardId)
        external
        view
        override
        returns (string memory)
    {
        return
            uriPrefix.concat("card/").concat(
                Base64.encode(Strings.toString(cardId))
            );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;
pragma abicoder v2;

import "./interface/IBlockhashMgr.sol";

import "./lib/Util.sol";

import "./interface/IShop.sol";

import "./Card.sol";
import "./ERC721Ex.sol";

// nftSign  packageType tokenAmount quantity    padding mintTime    index
// 1        31          64          16          40      40          64
// 255      224         160         144         104     64          0

contract Package is ERC721Ex {
    using String for string;

    struct ShopInfo {
        uint256 id;
        bool enabled;
    }

    struct PackageInfo {
        uint256 blockNumber;
        IShop shop;
    }

    mapping(uint256 => PackageInfo) public packageInfos;

    uint256 public quantityMin = 1;
    uint256 public quantityMax = 50;

    mapping(address => ShopInfo) public shopInfos;
    uint256 public shopCount;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    function setShop(address addr, bool enable) external CheckPermit("Config") {
        ShopInfo storage si = shopInfos[addr];

        if (si.id == 0) {
            si.id = ++shopCount;
        }

        si.enabled = enable;
    }

    function setQuantityMin(uint256 min) external CheckPermit("Config") {
        quantityMin = min;
    }

    function setQuantityMax(uint256 max) external CheckPermit("Config") {
        quantityMax = max;
    }

    function mint(
        address to,
        uint256 tokenAmount,
        uint256 quantity,
        uint256 padding
    ) external {
        require(shopInfos[msg.sender].enabled, "shop not enabled");

        require(
            quantity >= quantityMin && quantity <= quantityMax,
            "invalid quantity"
        );

        uint256 shopId = shopInfos[msg.sender].id;

        uint256 packageId = NFT_SIGN_BIT |
            (uint256(uint32(shopId)) << 224) |
            (uint256(uint64(tokenAmount)) << 160) |
            (uint256(uint16(quantity)) << 144) |
            (uint256(uint40(padding)) << 104) |
            (block.timestamp << 64) |
            (uint64(totalSupply + 1));

        PackageInfo storage pi = packageInfos[packageId];

        pi.blockNumber = block.number + 1;
        IBlockhashMgr(manager.members("blockhashMgr")).request(pi.blockNumber);

        pi.shop = IShop(msg.sender);

        _mint(to, packageId);
    }

    function open(uint256 packageId) external {
        require(
            msg.sender == tokenOwners[packageId],
            "you not own this package"
        );
        _burn(packageId);

        PackageInfo storage pi = packageInfos[packageId];
        require(
            pi.blockNumber <= block.number,
            "The operation is too fast, please try again."
        );
        bytes32 bh = IBlockhashMgr(manager.members("blockhashMgr"))
            .getBlockhash(pi.blockNumber);

        uint256[] memory cardIdPres = pi.shop.onOpenPackage(
            msg.sender,
            packageId,
            bh
        );

        Card card = Card(manager.members("card"));
        uint256 length = cardIdPres.length;

        for (uint256 i = 0; i != length; ++i) {
            card.mint(msg.sender, cardIdPres[i]);
        }

        delete packageInfos[packageId];
    }

    function batchOpen(uint256 packageId) external {
        require(
            msg.sender == tokenOwners[packageId],
            "you not own this package"
        );

        _burn(packageId);

        PackageInfo storage pi = packageInfos[packageId];

        bytes32 bh = IBlockhashMgr(manager.members("blockhashMgr"))
            .getBlockhash(pi.blockNumber);

        uint256[] memory cardIdPres = pi.shop.onOpenPackage(
            msg.sender,
            packageId,
            bh
        );

        Card(manager.members("card")).batchMint(msg.sender, cardIdPres);

        delete packageInfos[packageId];
    }

    function tokenURI(uint256 eggId)
        external
        view
        override
        returns (string memory)
    {
        return
            uriPrefix.concat("package/").concat(
                Base64.encode(Strings.toString(eggId))
            );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

 

interface IBlockhashMgr {
    function request(uint256 blockNumber) external;

    function getBlockhash(uint256 blockNumber) external returns(bytes32);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

 

interface IShop {

    function onOpenPackage(address to, uint256 packageId, bytes32 bh) external view returns (uint256[] memory);

    function getRarityWeights(uint256 packageId) external view returns (uint256[] memory);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./Manager.sol";

abstract contract Member is Ownable{

    Manager public manager;

    address public contractOwner = msg.sender;

    modifier CheckPermit(string memory permit) {
        require(manager.userPermits(msg.sender, permit),
            "no permit");
        _;
    }

    function setManager(address addr) external onlyOwner {
        manager = Manager(addr);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Manager is Ownable {
    mapping(string => address) public members;

    mapping(address => mapping(string => bool)) public userPermits;

    address public contractOwner = msg.sender;

    function setMember(string memory name, address member) external onlyOwner {
        members[name] = member;
    }

    function setUserPermit(
        address user,
        string memory permit,
        bool enable
    ) external onlyOwner {
        userPermits[user][permit] = enable;
    }

    function getTimestamp() external view returns (uint256) {
        return block.timestamp;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/Context.sol";
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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

 

import "./lib/Util.sol";

import "./ERC721.sol";

abstract contract ERC721Ex is ERC721 {
    using Address for address;

    uint256 public constant NFT_SIGN_BIT = 1 << 255;

    uint256 public totalSupply = 0;

    string public uriPrefix = "https://nft-gods.com/";

    function _mint(address to, uint256 tokenId) internal {
        _addTokenTo(to, tokenId);

        ++totalSupply;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal {
        address owner = tokenOwners[tokenId];
        _removeTokenFrom(owner, tokenId);

        if (tokenApprovals[tokenId] != address(0)) {
            delete tokenApprovals[tokenId];
        }
        --totalSupply;
        emit Transfer(owner, address(0), tokenId);
    }

    function safeBatchTransferFrom(address from, address to,
        uint256[] memory tokenIds) external {

        safeBatchTransferFrom(from, to, tokenIds, "");
    }

    function safeBatchTransferFrom(address from, address to,
        uint256[] memory tokenIds, bytes memory data) public {

        batchTransferFrom(from, to, tokenIds);

        if (to.isContract()) {
            require(IERC721TokenReceiverEx(to)
            .onERC721ExReceived(msg.sender, from, tokenIds, data)
                == Util.ERC721_RECEIVER_EX_RETURN,
                "onERC721ExReceived() return invalid");
        }
    }

    function batchTransferFrom(address from, address to,
        uint256[] memory tokenIds) public {
        require(!_isExcludedFrom[from], "sender is excluded");
        require(from != address(0), "from is zero address");
        require(to != address(0), "to is zero address");

        uint256 length = tokenIds.length;
        address sender = msg.sender;

        bool approval = from == sender || approvalForAlls[from][sender];

        for (uint256 i = 0; i != length; ++i) {
            uint256 tokenId = tokenIds[i];

            require(from == tokenOwners[tokenId], "from must be owner");
            require(approval || sender == tokenApprovals[tokenId],
                "sender must be owner or approvaled");

            if (tokenApprovals[tokenId] != address(0)) {
                delete tokenApprovals[tokenId];
            }

            _removeTokenFrom(from, tokenId);
            _addTokenTo(to, tokenId);

            emit Transfer(from, to, tokenId);
        }
    }

    function setUriPrefix(string memory prefix)
    external CheckPermit("Config") {

        uriPrefix = prefix;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

 
interface ISlot {

    function upgrade(address owner, uint256[] memory cardIds) external;

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./interface/IERC721.sol";

import "./lib/Util.sol";

import "./Member.sol";

abstract contract ERC721 is Member, IERC165, IERC721, IERC721Metadata {
    using Address for address;

    /*
     * bytes4(keccak256("supportsInterface(bytes4)")) == 0x01ffc9a7
     */
    bytes4 private constant INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /*
     *     bytes4(keccak256("balanceOf(address)")) == 0x70a08231
     *     bytes4(keccak256("ownerOf(uint256)")) == 0x6352211e
     *     bytes4(keccak256("approve(address,uint256)")) == 0x095ea7b3
     *     bytes4(keccak256("getApproved(uint256)")) == 0x081812fc
     *     bytes4(keccak256("setApprovalForAll(address,bool)")) == 0xa22cb465
     *     bytes4(keccak256("isApprovedForAll(address,address)")) == 0xe985e9c5
     *     bytes4(keccak256("transferFrom(address,address,uint256)")) == 0x23b872dd
     *     bytes4(keccak256("safeTransferFrom(address,address,uint256)")) == 0x42842e0e
     *     bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)")) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant INTERFACE_ID_ERC721Metadata = 0x5b5e139f;

    string public override name;
    string public override symbol;

    mapping(address => uint256[]) internal ownerTokens;
    mapping(uint256 => uint256) internal tokenIndexs;
    mapping(uint256 => address) internal tokenOwners;

    mapping(uint256 => address) internal tokenApprovals;
    mapping(address => mapping(address => bool)) internal approvalForAlls;
    mapping(address => bool) public _isExcludedFrom;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function excludeFrom(address account) external CheckPermit("Admin") {
        _isExcludedFrom[account] = true;
    }

    function includeInFrom(address account) external CheckPermit("Admin") {
        _isExcludedFrom[account] = false;
    }

    function balanceOf(address owner) external view override returns (uint256) {
        require(owner != address(0), "owner is zero address");
        return ownerTokens[owner].length;
    }

    // [startIndex, endIndex)
    function tokensOf(
        address owner,
        uint256 startIndex,
        uint256 endIndex
    ) external view returns (uint256[] memory) {
        require(owner != address(0), "owner is zero address");

        uint256[] storage tokens = ownerTokens[owner];
        if (endIndex == 0 || endIndex > tokens.length) {
            return tokens;
        }

        require(startIndex < endIndex, "invalid index");

        uint256[] memory result = new uint256[](endIndex - startIndex);
        for (uint256 i = startIndex; i != endIndex; ++i) {
            result[i] = tokens[i];
        }

        return result;
    }

    function ownerOf(uint256 tokenId) external view override returns (address) {
        address owner = tokenOwners[tokenId];
        require(owner != address(0), "nobody own the token");
        return owner;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable override {
        _transferFrom(from, to, tokenId);

        if (to.isContract()) {
            require(
                IERC721TokenReceiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    data
                ) == Util.ERC721_RECEIVER_RETURN,
                "onERC721Received() return invalid"
            );
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable override {
        _transferFrom(from, to, tokenId);
    }

    function _transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        require(!_isExcludedFrom[from], "sender is excluded");
        require(from != address(0), "from is zero address");
        require(to != address(0), "to is zero address");

        require(from == tokenOwners[tokenId], "from must be owner");

        require(
            msg.sender == from ||
                msg.sender == tokenApprovals[tokenId] ||
                approvalForAlls[from][msg.sender],
            "sender must be owner or approvaled"
        );

        if (tokenApprovals[tokenId] != address(0)) {
            delete tokenApprovals[tokenId];
        }

        _removeTokenFrom(from, tokenId);
        _addTokenTo(to, tokenId);

        emit Transfer(from, to, tokenId);
    }

    // ensure everything is ok before call it
    function _removeTokenFrom(address from, uint256 tokenId) internal {
        uint256 index = tokenIndexs[tokenId];

        uint256[] storage tokens = ownerTokens[from];
        uint256 indexLast = tokens.length - 1;

        // save gas
        // if (index != indexLast) {
        uint256 tokenIdLast = tokens[indexLast];
        tokens[index] = tokenIdLast;
        tokenIndexs[tokenIdLast] = index;
        // }

        tokens.pop();

        // delete tokenIndexs[tokenId]; // save gas
        delete tokenOwners[tokenId];
    }

    // ensure everything is ok before call it
    function _addTokenTo(address to, uint256 tokenId) internal {
        uint256[] storage tokens = ownerTokens[to];
        tokenIndexs[tokenId] = tokens.length;
        tokens.push(tokenId);

        tokenOwners[tokenId] = to;
    }

    function approve(address to, uint256 tokenId) external payable override {
        address owner = tokenOwners[tokenId];

        require(
            msg.sender == owner || approvalForAlls[owner][msg.sender],
            "sender must be owner or approved for all"
        );

        tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function setApprovalForAll(address to, bool approved) external override {
        approvalForAlls[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function getApproved(uint256 tokenId)
        external
        view
        override
        returns (address)
    {
        require(tokenOwners[tokenId] != address(0), "nobody own then token");

        return tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator)
        external
        view
        override
        returns (bool)
    {
        return approvalForAlls[owner][operator];
    }

    function supportsInterface(bytes4 interfaceID)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceID == INTERFACE_ID_ERC165 ||
            interfaceID == INTERFACE_ID_ERC721 ||
            interfaceID == INTERFACE_ID_ERC721Metadata;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;


 

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns(bool);
}




/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface IERC721 /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns(uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns(address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns(address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns(bool);
}



/// @title ERC-721 Non-Fungible Token Standard, optional metadata extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x5b5e139f.
interface IERC721Metadata /* is ERC721 */ {
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string memory);

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string memory);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    /// {"name":"","description":"","image":""}
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}


/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface IERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);
}


interface IERC721TokenReceiverEx is IERC721TokenReceiver {
    // bytes4(keccak256("onERC721ExReceived(address,address,uint256[],bytes)")) = 0x0f7b88e3
    function onERC721ExReceived(address operator, address from,
        uint256[] memory tokenIds, bytes memory data)
    external returns(bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./lib/Util.sol";
import "./interface/IERC20.sol";
import "./Card.sol";
import "./Package.sol";
import "./interface/IBlockhashMgr.sol";

contract VIPSale is Member {

    uint256 public lockDuration = 9763200;
    uint256 public tokenAmount = 300000;

    function setLockDuration(uint256 _lockDuration) external CheckPermit("Config") {
        lockDuration = _lockDuration;
    }

    function setTokenAmount(uint256 _tokenAmount) external CheckPermit("Config") {
        tokenAmount = _tokenAmount;
    }

    function giveGodsCard(uint256 num, address _to, uint32 cardId, uint16 pin) external CheckPermit("Config") {
        uint256[] memory cards = new uint256[](num);
        for(uint i = 0; i < num; i++) {
            cards[i] = generateCard(cardId, pin);
        }
        Card(manager.members("card")).batchMint(_to, cards);
    }

    function generateCard(uint32 cardId, uint16 pin) public view returns (uint256) {
        return ((1 << 255)
        | (uint256(uint32(cardId)) << 224)
        | (uint256(uint16(pin)) << 208)
        | (uint256(uint96(tokenAmount)) << 112)
        | uint256(uint40(lockDuration)) << 72
        | uint40(block.timestamp) << 32);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./lib/Util.sol";
import "./interface/IERC20.sol";
import "./Shop.sol";
import "./Card.sol";
import "./Package.sol";
import "./interface/IBlockhashMgr.sol";

contract VIPCardSale is Shop {
    uint256 public uintPrice = 20 * (10**18);
    uint256 public lockDuration = 9763200;
    uint256 public tokenAmount = 0;
    uint256 public maxOnce = 50;
    uint256 public minOnce = 1;
    uint256 public buyCountLimit = 10000;
    uint16 public _quality = 1;

    mapping(address => uint256) public buyCount;
    mapping(address => bool) public witer;

    function setWiter(address[] memory account, bool _end)
        external
        CheckPermit("Config")
    {
        require(account.length > 0, "not length");
        for (uint256 i = 0; i < account.length; i++) {
            witer[account[i]] = _end;
        }
    }

    function setLockDuration(uint256 _lockDuration)
        external
        CheckPermit("Config")
    {
        lockDuration = _lockDuration;
    }

    function setUintPrice(uint256 price) external CheckPermit("Config") {
        uintPrice = price;
    }

    function setTokenAmount(uint256 _tokenAmount)
        external
        CheckPermit("Config")
    {
        tokenAmount = _tokenAmount;
    }

    function setMaxOnce(uint256 max) external CheckPermit("Config") {
        maxOnce = max;
    }

    function setMinOnce(uint256 min) external CheckPermit("Config") {
        minOnce = min;
    }

    function setVIPPin(uint16 min) external CheckPermit("Config") {
        _quality = min;
    }

    function setBuyCountLimit(uint256 limit) external CheckPermit("Config") {
        buyCountLimit = limit;
    }

    function giveGodsCard(
        uint256 num,
        address _to,
        uint32 cardId,
        uint16 pin
    ) external CheckPermit("Config") {
        uint256[] memory cards = new uint256[](num);
        for (uint256 i = 0; i < num; i++) {
            cards[i] = generateCard(cardId, pin);
        }
        Card(manager.members("card")).batchMint(_to, cards);
    }

    function generateCard(uint32 cardId, uint16 pin)
        public
        view
        returns (uint256)
    {
        return ((1 << 255) |
            (uint256(uint32(cardId)) << 224) |
            (uint256(uint16(pin)) << 208) |
            (uint256(uint96(tokenAmount)) << 112) |
            (uint256(uint40(lockDuration)) << 72) |
            (uint40(block.timestamp) << 32));
    }

    function buy(uint256 quantity) external {
        require(witer[msg.sender], "not witer");
        require(quantity >= minOnce, "Less than minOnce.");
        require(quantity <= maxOnce, "Out of max");
        require(
            buyCount[msg.sender] + quantity <= buyCountLimit ||
                buyCountLimit == 0,
            "Out of max"
        );

        buyCount[msg.sender] += quantity;
        _buy(msg.sender, msg.sender, uintPrice, quantity, quantityCount);
    }

    function onOpenPackage(
        address to,
        uint256 packageId,
        bytes32 bh
    ) external view override returns (uint256[] memory) {
        uint256 quantity = uint16(packageId >> 144);
        uint256[] memory cardIdPre = new uint256[](quantity);

        for (uint256 i = 0; i != quantity; ++i) {
            cardIdPre[i] = generateCard(0, _quality);
        }
        return cardIdPre;
    }

    function getRarityWeights(uint256 packageId)
        external
        view
        override
        returns (uint256[] memory)
    {}

    function ERC20Address() public view override returns (address) {
        return manager.members("token");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./lib/Util.sol";
import "./Shop.sol";
import "./interface/IERC20.sol";
import "./Card.sol";
import "./Package.sol";
import "./interface/IBlockhashMgr.sol";

contract SpecialAdminSale is Shop {
    using UInteger for uint256;

    uint256 public uintPrice;

    uint256 public lockDuration = 0;

    uint256 public maxOnce = 50;
    uint256 public minOnce = 1;
    uint256 public buyCountLimit;
    uint256[] public rarityWeights;
    uint256[] public cardWeights;
    uint256 public cardCount;

    uint256[] public tokenInclude;

    mapping(address => uint256) public buyCount;

    mapping(address => bool) public witer;

    function setWhiteList(address account, bool enable)
        external
        CheckPermit("Admin")
    {
        witer[account] = enable;
    }

    constructor(
        uint256[] memory _rarityWeights,
        uint256[] memory _tokenInclude,
        uint256[] memory _cardWeights,
        uint256 _uintPrice
    ) {
        cardWeights = _cardWeights;

        uint256 length = 0;
        for (uint256 i = 0; i != cardWeights.length; i++) {
            if (cardWeights[i] != 0) {
                length++;
            }
        }
        cardCount = length;

        rarityWeights = _rarityWeights;
        tokenInclude = _tokenInclude;
        uintPrice = _uintPrice;
        quantityMax = ~uint256(0);
    }

    function setWiter(address[] memory account, bool _end)
        external
        CheckPermit("Config")
    {
        require(account.length > 0, "not length");
        for (uint256 i = 0; i < account.length; i++) {
            witer[account[i]] = _end;
        }
    }

    function updateCardWeight(uint256 cardId, bool open)
        external
        CheckPermit("Config")
    {
        uint256 car = 0;
        uint256 ds = 0;
        if (open) {
            car = cardId;
            ds = cardCount.add(1);
        } else {
            ds = cardCount.sub(1);
        }
        cardWeights[cardId - 1] = car;
        cardCount = ds;
    }

    function setBuyCountLimit(uint256 limit) external CheckPermit("Config") {
        buyCountLimit = limit;
    }

    function buy(uint256 quantity) external {
        require(quantity >= minOnce, "Less than minOnce.");
        require(quantity <= maxOnce, "Out of max");
        require(witer[msg.sender], "Only whitelist users");
        require(
            buyCount[msg.sender] + quantity <= buyCountLimit ||
                buyCountLimit == 0,
            "Out of max"
        );

        buyCount[msg.sender] += quantity;
        _buy(msg.sender, msg.sender, uintPrice, quantity, quantityCount);
    }

    function onOpenPackage(
        address to,
        uint256 packageId,
        bytes32 bh
    ) external view override returns (uint256[] memory) {
        uint256 quantity = uint16(packageId >> 144);
        uint256 padding = uint32(packageId >> 104);
        uint256[] memory cardIdPre = new uint256[](quantity);

        for (uint256 i = 0; i != quantity; ++i) {
            bytes memory seed = abi.encodePacked(
                bh,
                padding,
                cardIdPre,
                abi.encodePacked(i + 1),
                to
            );
            uint256 cardType = Util.randomWeightCard(
                seed,
                cardWeights,
                cardCount
            );
            seed = abi.encodePacked(
                bh,
                padding,
                cardIdPre,
                abi.encodePacked(i + 2)
            );
            uint256 cardRarity = Util.randomWeight(
                seed,
                rarityWeights,
                1000000
            );

            cardIdPre[i] = ((1 << 255) |
                (uint256(uint32(cardType)) << 224) |
                (uint256(uint16(cardRarity)) << 208) |
                (uint256(uint96(tokenInclude[cardRarity])) << 112) |
                (uint256(uint40(lockDuration)) << 72) |
                (uint40(block.timestamp) << 32));
        }
        return cardIdPre;
    }

    function getRarity() public view returns (uint256[] memory _rarityWeight) {
        _rarityWeight = rarityWeights;
    }

    function getRarityWeights(uint256 packageId)
        external
        view
        override
        returns (uint256[] memory _rarityWeight)
    {
        uint256 shopId = uint32((packageId ^ (1 << 255)) >> 224);
        (uint256 id, ) = Package(manager.members("package")).shopInfos(
            address(this)
        );
        if (id == shopId) {
            _rarityWeight = rarityWeights;
        }
    }

    function ERC20Address() public view override returns (address) {
        return manager.members("token");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

 

import "./Member.sol";
import "./interface/IERC20.sol";

contract Receive is Member {

    mapping(address => uint256) public users;

    uint256 public dayAmount = 100;

    function updateDayAmount(uint256 _amount) public CheckPermit("Config") {
        dayAmount = _amount;
    }

    function currentDay() public view returns (uint){
        return block.timestamp / 86400;
    }

    function isUserReceive(address _account) public view returns(bool) {
        return users[_account] >= currentDay() ? true : false;
    }

    function receiveToken() external {
        address user = msg.sender;
        require(!isUserReceive(user), "not balance");
        uint8 lde = IERC20(manager.members("token")).decimals();
        IERC20(manager.members("token")).transfer(user, dayAmount * 10 ** lde);

        uint8 ude = IERC20(manager.members("usdt")).decimals();
        IERC20(manager.members("usdt")).transfer(user, dayAmount * 10 ** ude);

        users[user] = currentDay();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;
pragma abicoder v2;

import "./interface/IERC721.sol";

import "./lib/Util.sol";

import "./Card.sol";
import "./Member.sol";

contract Slot is Member, IERC721TokenReceiverEx {
    struct SlotInfo {
        uint256 level;
        uint256 exp;
        uint256 cardId;
        int256 fightBase;
        int256 bondBuffer;
    }

    struct UserInfo {
        SlotInfo[] slots;
        uint256 count;
        int256 fight;
        mapping(uint256 => bool) bondActives;
    }

    struct BondInfo {
        uint256[] cardTypes;
        int256 buffer;
    }

    struct LevelConfig {
        uint256 exp;
        int256 buffer;
    }

    event Upgrade(
        address indexed owner,
        uint256 indexed cardType,
        uint256 level
    );
    event FightChanged(
        address indexed owner,
        int256 indexed fight,
        int256 indexed buffer,
        uint256 cardId
    );
    event RewardEvent(
        address indexed owner,
        address indexed erc20,
        uint256 indexed fee
    );

    mapping(address => UserInfo) public ownerUserInfos;

    uint256[] public rarityExps = [100, 200, 300, 400, 500, 600, 700];
    LevelConfig[] public levelConfigs;

    BondInfo[] public bonds;
    mapping(uint256 => uint256[]) public cardTypeBonds;

    uint256 public receiveFee = 10;
    uint256 public rewardTime = 0;
    mapping(address => uint256) public userRewardTime;

    function getCardTypeBonds(uint256 _value)
        external
        view
        returns (uint256[] memory)
    {
        return cardTypeBonds[_value];
    }

    function getBonds(uint256 _value) external view returns (BondInfo memory) {
        return bonds[_value];
    }

    constructor() {
        levelConfigs.push(LevelConfig({exp: 0, buffer: 0}));
        levelConfigs.push(
            LevelConfig({exp: 100, buffer: (Util.SDENO * 10) / 100})
        );
        levelConfigs.push(
            LevelConfig({exp: 300, buffer: (Util.SDENO * 20) / 100})
        );
        levelConfigs.push(
            LevelConfig({exp: 500, buffer: (Util.SDENO * 30) / 100})
        );
        levelConfigs.push(
            LevelConfig({exp: 700, buffer: (Util.SDENO * 40) / 100})
        );
        levelConfigs.push(
            LevelConfig({exp: 900, buffer: (Util.SDENO * 50) / 100})
        );
        levelConfigs.push(
            LevelConfig({exp: 1100, buffer: (Util.SDENO * 60) / 100})
        );
        levelConfigs.push(
            LevelConfig({exp: 1300, buffer: (Util.SDENO * 70) / 100})
        );
        levelConfigs.push(
            LevelConfig({exp: 1500, buffer: (Util.SDENO * 80) / 100})
        );
        levelConfigs.push(
            LevelConfig({exp: 1700, buffer: (Util.SDENO * 90) / 100})
        );
        levelConfigs.push(
            LevelConfig({exp: 1900, buffer: (Util.SDENO * 100) / 100})
        );
    }

    function setRarityExp(uint256 rarity, uint256 exp)
        external
        CheckPermit("Config")
    {
        for (uint256 i = rarityExps.length; i <= rarity; ++i) {
            rarityExps.push(0);
        }

        rarityExps[rarity] = exp;
    }

    function setLevelConfig(
        uint256 level,
        uint256 exp,
        int256 buffer
    ) external CheckPermit("Config") {
        for (uint256 i = levelConfigs.length; i <= level; ++i) {
            levelConfigs.push(LevelConfig({exp: 0, buffer: 0}));
        }

        LevelConfig storage lc = levelConfigs[level];
        lc.exp = exp;
        lc.buffer = buffer;
    }

    function addBond(uint256[] memory cardTypes, int256 buffer)
        external
        CheckPermit("Config")
    {
        uint256 index = bonds.length;

        bonds.push(BondInfo({cardTypes: cardTypes, buffer: buffer}));

        uint256 length = cardTypes.length;
        for (uint256 i = 0; i != length; ++i) {
            cardTypeBonds[cardTypes[i]].push(index);
        }
    }

    function addBonds(uint256[][] memory cardTypess, int256[] memory buffers)
        external
        CheckPermit("Config")
    {
        uint256 cardTypesLength = cardTypess.length;
        uint256 index = bonds.length;

        for (uint256 i = 0; i != cardTypesLength; ++i) {
            uint256[] memory cardTypes = cardTypess[i];

            bonds.push(BondInfo({cardTypes: cardTypes, buffer: buffers[i]}));

            uint256 cardTypeLength = cardTypes.length;
            for (uint256 j = 0; j != cardTypeLength; ++j) {
                cardTypeBonds[cardTypes[j]].push(index);
            }

            ++index;
        }
    }

    function getUserInfo(address owner)
        external
        view
        returns (SlotInfo[] memory, int256 fight)
    {
        UserInfo storage ui = ownerUserInfos[owner];

        return (ui.slots, ui.fight);
    }

    function getSlotInfo(address owner, uint256 cardType)
        external
        view
        returns (SlotInfo memory)
    {
        return ownerUserInfos[owner].slots[cardType];
    }

    function onERC721Received(
        address,
        address from,
        uint256 cardId,
        bytes memory data
    ) external override returns (bytes4) {
        if (msg.sender == manager.members("card")) {
            uint256[] memory cardIds = new uint256[](1);
            cardIds[0] = cardId;
            _addCards(from, cardIds);
        }

        return Util.ERC721_RECEIVER_RETURN;
    }

    function onERC721ExReceived(
        address,
        address from,
        uint256[] memory cardIds,
        bytes memory data
    ) external override returns (bytes4) {
        if (msg.sender == manager.members("card")) {
            _addCards(from, cardIds);
        }

        return Util.ERC721_RECEIVER_EX_RETURN;
    }

    function _onFightChanged(address owner) internal {
        UserInfo storage ui = ownerUserInfos[owner];

        int256 buffer = 0;
        if (ui.slots[0].cardId != 0) {
            buffer = (20 * Util.SDENO) / 100;
        }
        int256 fight = (ui.fight * (Util.SDENO + buffer)) / (Util.SDENO**3);

        emit FightChanged(owner, fight, ui.fight, ui.slots[0].cardId);
    }

    function _addCards(address owner, uint256[] memory cardIds) internal {
        UserInfo storage ui = ownerUserInfos[owner];
        SlotInfo[] storage slots = ui.slots;

        Card card = Card(manager.members("card"));
        int256 delta = 0;

        uint256 lengthMax = ~uint256(0);

        for (uint256 c = cardIds.length - 1; c != lengthMax; --c) {
            uint256 cardId = cardIds[c];
            uint256 cardType = (cardId ^ (1 << 255)) >> 224;

            for (uint256 i = slots.length; i <= cardType; ++i) {
                slots.push(
                    SlotInfo({
                        level: 0,
                        exp: 0,
                        cardId: 0,
                        fightBase: 0,
                        bondBuffer: Util.SDENO
                    })
                );
            }

            SlotInfo storage si = slots[cardType];

            int256 fightBase = card.getFight(cardId) *
                (Util.SDENO + levelConfigs[si.level].buffer);

            if (si.cardId == 0) {
                si.cardId = cardId;
                ui.count++;

                si.fightBase = fightBase;
                delta += fightBase * Util.SDENO;

                uint256[] storage cbs = cardTypeBonds[cardType];

                for (uint256 i = cbs.length - 1; i != lengthMax; --i) {
                    BondInfo storage bi = bonds[cbs[i]];

                    uint256[] storage cardTypes = bi.cardTypes;

                    bool active = true;
                    for (
                        uint256 j = cardTypes.length - 1;
                        j != lengthMax;
                        --j
                    ) {
                        if (
                            cardTypes[j] >= slots.length ||
                            slots[cardTypes[j]].cardId == 0
                        ) {
                            active = false;
                            break;
                        }
                    }

                    if (active) {
                        ui.bondActives[cbs[i]] = true;

                        for (
                            uint256 j = cardTypes.length - 1;
                            j != lengthMax;
                            --j
                        ) {
                            SlotInfo storage slotInfo = slots[cardTypes[j]];

                            delta += slotInfo.fightBase * bi.buffer;

                            slotInfo.bondBuffer += bi.buffer;
                        }
                    }
                }
            } else {
                delta += (fightBase - si.fightBase) * si.bondBuffer;
                si.fightBase = fightBase;

                card.transferFrom(address(this), owner, si.cardId);
                si.cardId = cardId;
            }
        }

        ui.fight += delta;
        _onFightChanged(owner);
    }

    function removeCard(uint256 cardType) external {
        UserInfo storage ui = ownerUserInfos[msg.sender];
        SlotInfo[] storage slots = ui.slots;
        require(cardType < slots.length, "no card in slot");

        SlotInfo storage si = slots[cardType];
        require(si.cardId != 0, "no card in slot");

        uint256[] storage cbs = cardTypeBonds[cardType];
        uint256 cbsLength = cbs.length;

        int256 delta = si.fightBase * Util.SDENO;

        for (uint256 i = 0; i != cbsLength; ++i) {
            uint256 bondIndex = cbs[i];
            if (!ui.bondActives[bondIndex]) {
                continue;
            }
            ui.bondActives[bondIndex] = false;

            BondInfo storage bi = bonds[bondIndex];
            uint256[] storage cardTypes = bi.cardTypes;
            uint256 ctLength = cardTypes.length;

            for (uint256 j = 0; j != ctLength; ++j) {
                SlotInfo storage slotInfo = slots[cardTypes[j]];

                delta += slotInfo.fightBase * bi.buffer;
                slotInfo.bondBuffer -= bi.buffer;
            }
        }

        ui.fight -= delta;

        Card(manager.members("card")).transferFrom(
            address(this),
            msg.sender,
            si.cardId
        );
        si.cardId = 0;
        ui.count--;

        _onFightChanged(msg.sender);
    }

    function removeAllCards() external {
        address owner = msg.sender;
        UserInfo storage ui = ownerUserInfos[owner];

        Card card = Card(manager.members("card"));

        SlotInfo[] storage slots = ui.slots;
        uint256 slotLength = slots.length;

        for (uint256 cardType = 0; cardType != slotLength; ++cardType) {
            SlotInfo storage si = slots[cardType];
            if (si.cardId == 0) {
                continue;
            }

            card.transferFrom(address(this), owner, si.cardId);
            si.cardId = 0;
            si.bondBuffer = Util.SDENO;

            uint256[] storage cbs = cardTypeBonds[cardType];
            uint256 cbsLength = cbs.length;

            for (uint256 i = 0; i != cbsLength; ++i) {
                ui.bondActives[cbs[i]] = false;
            }
        }

        ui.fight = 0;
        ui.count = 0;

        _onFightChanged(owner);
    }

    function upgrade(address owner, uint256[] memory cardIds) external {
        address cardAddr = manager.members("card");
        require(msg.sender == cardAddr, "card only");
        Card card = Card(cardAddr);

        UserInfo storage ui = ownerUserInfos[owner];
        SlotInfo[] storage slots = ui.slots;

        uint256 cardIdLength = cardIds.length;

        for (uint256 i = 0; i != cardIdLength; ++i) {
            uint256 cardId = cardIds[i];
            uint256 cardType = (cardId ^ (1 << 255)) >> 224;

            for (uint256 j = slots.length; j <= cardType; ++j) {
                slots.push(
                    SlotInfo({
                        level: 0,
                        exp: 0,
                        cardId: 0,
                        fightBase: 0,
                        bondBuffer: Util.SDENO
                    })
                );
            }

            SlotInfo storage si = slots[cardType];
            uint256 levelLength = levelConfigs.length;
            require(si.level + 1 < levelLength, "slot level full");

            si.exp += rarityExps[uint16(cardId >> 208)];

            uint256 level = si.level;
            while (level + 1 < levelLength) {
                uint256 cost = levelConfigs[level + 1].exp;

                if (si.exp >= cost) {
                    si.exp -= cost;
                    ++level;
                } else {
                    break;
                }
            }

            if (si.level == level) {
                continue;
            }

            si.level = level;
            emit Upgrade(owner, cardType, level);

            if (si.cardId == 0) {
                continue;
            }

            int256 fightBase = card.getFight(si.cardId) *
                (Util.SDENO + levelConfigs[level].buffer);

            ui.fight += (fightBase - si.fightBase) * si.bondBuffer;

            si.fightBase = fightBase;
        }

        _onFightChanged(owner);
    }

    function receiveReward() external {
        address sender = msg.sender;
        require(userRewardTime[sender] <= block.timestamp);
        userRewardTime[sender] = block.timestamp + rewardTime;
        emit RewardEvent(sender, manager.members("token"), receiveFee);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./Member.sol";
import "./lib/Util.sol";
import "./ERC721.sol";
import "./interface/IPair.sol";
import "./interface/ISwap.sol";
import "./interface/IERC20.sol";

contract Market is Member {

    using UInteger for uint256;
    using Address for address;

    event BuyEvent(address account, address from, uint256 cardId, address erc20, uint256 tokenId, uint256 value, uint256 usdtValue);

    event SellEvent(address account, address erc20, uint256 tokenId, uint256 value, uint256 usdtValue);

    event CancelEvent(address account, address erc20, uint256 tokenId, uint256 cardId);

    bytes4 internal constant ERC721_RECEIVER_RETURN = 0x150b7a02;

    struct SellData {

        address sellOperator;

        address sellAddress;

        uint256 shValue;

        address erc20;

        address buyAddress;
    }

    struct tokenData {

        bool open;

        uint256 demValue;

        uint8 dem;
    }

    mapping(uint256 => SellData) public sellCardData;

    //新规则id =====  卡片id
    mapping(uint256 => uint256) public tokens;

    //新规则id得owner
    mapping(address => uint256[]) public marketCard;

    //记录新规则id下标
    mapping(uint256 => uint256) public marketIndex;

    //用户待提现余额
    mapping(address => mapping(address => uint256)) public marketBalance;

    mapping(address => tokenData) public sellTokenOpen;

    mapping(address => tokenData) public buyTokenOpen;

    uint32 swapTimestamp = 1200;

    uint256 marketFee = 10;

    //    receive () payable external {}


    function updateMarketFee(uint256 demValue) public CheckPermit("Config") {
        marketFee = demValue;
    }

    function updateSellTokenOpen(address token, bool open, uint8 de, uint256 demValue) public CheckPermit("Config") {
        sellTokenOpen[token].open = open;
        sellTokenOpen[token].dem = de;
        sellTokenOpen[token].demValue = demValue;
    }

    function updateBuyTokenOpen(address token, bool open, uint8 de, uint256 demValue) public CheckPermit("Config") {
        buyTokenOpen[token].open = open;
        buyTokenOpen[token].dem = de;
        buyTokenOpen[token].demValue = demValue;
    }

    //卖卡
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4) {
        require(msg.sender == manager.members("card"), "not operator.");
        (uint256 value, address erc20) = getBytes(data);
        require(value > 0 && erc20 != address(0));

        require(sellTokenOpen[erc20].open, "Token is not open.");

        value = value.div(sellTokenOpen[erc20].demValue);

        SellData storage sellData = sellCardData[tokenId];
        sellData.sellAddress = from;
        sellData.erc20 = erc20;
        sellData.sellOperator = operator;
        sellData.shValue = value.mul(sellTokenOpen[erc20].demValue);

        uint id = getMarketId(tokenId, value, from);
        _addToken(id, tokenId, erc20);

        uint256 usdtValue = getUsdtPrice(erc20, sellData.shValue);

        emit SellEvent(from, erc20, id, sellData.shValue, usdtValue);

        return ERC721_RECEIVER_RETURN;
    }



    //取消挂单
    function cancelSell(uint256 tokenId) public {
        uint256 cardId = tokens[tokenId];
        require(cardId > 0);
        require(sellCardData[cardId].sellAddress == msg.sender);

        //将卡牌返还卖家
        ERC721(manager.members("card")).safeTransferFrom(address(this), sellCardData[cardId].sellAddress, cardId);

        address erc20 = sellCardData[cardId].erc20;
        _removeToken(tokenId, sellCardData[cardId].erc20);
        delete sellCardData[cardId];

        emit CancelEvent(msg.sender, erc20, tokenId, cardId);
    }



    //批量取消挂单
    function batchCancel(uint256[] memory tokenId) public {
        require(tokenId.length <= 20);
        for (uint256 i = 0; i < tokenId.length; i++) {
            cancelSell(tokenId[i]);
        }
    }


    //ht购买卡片
    function ethBuyCard(address[] memory path, uint256 tokenId) public payable {
        require(buyTokenOpen[path[0]].open, "not buy token open");

        uint256 cardId = tokens[tokenId];
        require(cardId > 0);
        SellData storage sellData = sellCardData[cardId];
        require(path[path.length - 1] == sellData.erc20, "not erc20");
        require(msg.sender != sellData.sellAddress, "not sender.");

        //将token转到swap
        uint[] memory amounts = ISwap(manager.members("swap")).swapETHForExactTokens{value : msg.value}(sellData.shValue, path, address(this), block.timestamp.add(swapTimestamp));

        if (msg.value > amounts[0]) {
            msg.sender.transfer(msg.value.sub(amounts[0]));
        }

        //处理卡牌归属
        marketPing(msg.sender, cardId, tokenId, path[0], amounts[0]);
    }




    //买卡
    function buyCard(address[] memory path, uint256 tokenId, uint256 _value, uint256 _slippage) public {
        require(buyTokenOpen[path[0]].open, "not buy token open");

        uint256 cardId = tokens[tokenId];
        require(cardId > 0);
        SellData storage sellData = sellCardData[cardId];
        require(path[path.length - 1] == sellData.erc20, "not token");
        require(msg.sender != sellData.sellAddress, "not sender.");


        if (path[0] != sellData.erc20) {

            uint amountInMax = _value.add(_value.mul(_slippage).div(1000));

            address[] memory paths = IPair(manager.members("pair")).getTokenPath(path[0], path[path.length - 1]);

            //扣除买家token
            tokenTransferFrom(path[0], msg.sender, amountInMax);

            //将token转到swap
            IERC20(path[0]).approve(manager.members("swap"), amountInMax);
            uint[] memory _amount = ISwap(manager.members("swap")).swapTokensForExactTokens(sellData.shValue, amountInMax, paths, address(this), block.timestamp.add(swapTimestamp));

            if (amountInMax > _amount[0]) {
                IERC20(path[0]).transfer(msg.sender, amountInMax.sub(_amount[0]));
            }
            _value = _amount[0];

        } else {
            require(_value >= sellData.shValue, "bet amount not");
            //扣除买家token
            tokenTransferFrom(path[0], msg.sender, _value);
        }

        marketPing(msg.sender, cardId, tokenId, path[0], _value);
    }


    function marketPing(address account, uint256 cardId, uint256 tokenId, address buyToken, uint256 _value) internal {

        SellData storage sellData = sellCardData[cardId];

        //将卡牌转给买家
        ERC721(manager.members("card")).safeTransferFrom(address(this), account, cardId);

        uint256 fee = sellData.shValue.mul(marketFee).div(1000);
        //手续费转出
        IERC20(sellData.erc20).transfer(manager.members("cashier"), fee);
        //将卖家得到的代币存到合约，自行提现
        marketBalance[sellData.sellAddress][sellData.erc20] = marketBalance[sellData.sellAddress][sellData.erc20].add(sellData.shValue.sub(fee));

        sellData.buyAddress = account;

        //删除市场挂单
        _removeToken(tokenId, sellData.erc20);

        uint256 usdtValue = getUsdtPrice(buyToken, _value);

        emit BuyEvent(account, sellData.sellAddress, cardId, buyToken, tokenId, _value, usdtValue);
    }




    //用户交易账户提现
    function tokenWithdraw(address erc20, address account, uint256 value) public {
        require(account == msg.sender);
        require(value > 0, "not value");
        require(getMarketBalance(account, erc20) >= value, "not marketBalance");

        marketBalance[account][erc20] = marketBalance[account][erc20].sub(value);
        IERC20 erc20Data = IERC20(erc20);
        if (erc20Data.balanceOf(address(this)) < value) {
            revert("Withdraw:Insufficient balance.");
        }
        require(erc20Data.transfer(account, value), "withdraw fail");
    }


    function tokenTransferFrom(address _erc20, address _account, uint256 _value) private {
        IERC20 erc20 = IERC20(_erc20);
        if (erc20.allowance(_account, address(this)) < _value) {
            revert("Bet:Insufficient allowed.");
        }

        erc20.transferFrom(_account, address(this), _value);
    }


    function tokenSwapPrice(address[] memory erdd, uint256 _value, uint8 _type) public view returns (uint256 price) {
        address[] memory paths = IPair(manager.members("pair")).getTokenPath(erdd[0], erdd[erdd.length - 1]);
        if (_type == 1) {
            uint256[] memory amounts = ISwap(manager.members("swap")).getAmountsOut(_value, paths);
            price = amounts[amounts.length - 1];
        } else {
            uint256[] memory amounts = ISwap(manager.members("swap")).getAmountsIn(_value, paths);
            price = amounts[0];
        }
    }

    //当前币种得usdt价格
    function getUsdtPrice(address erc20, uint256 _value) internal view returns (uint256 _price) {
        address[] memory erdd = new address[](2);
        erdd[0] = erc20;
        erdd[1] = manager.members("usdt");
        if (erc20 == erdd[1]) {
            return _value;
        }
        return tokenSwapPrice(erdd, _value, 1);
    }

    function _addToken(uint256 id, uint256 tokenId, address erc20) internal {
        tokens[id] = tokenId;
        marketIndex[id] = marketCard[erc20].length;
        marketCard[erc20].push(id);
    }

    function _removeToken(uint256 tokenId, address erc20) internal {
        uint256 index = marketIndex[tokenId];

        uint256 indexLast = marketCard[erc20].length - 1;
        uint256 tokenIdLast = marketCard[erc20][indexLast];
        marketCard[erc20][index] = tokenIdLast;
        marketIndex[tokenIdLast] = index;

        marketCard[erc20].pop();
        delete tokens[tokenId];
    }


    function getTokenId(uint256 tokenId, uint256 value, uint8 de, address from) public pure returns (uint id) {
        id = (1 << 255)
        | (uint256(uint16((tokenId ^ (1 << 255)) >> 224)) << 240)
        | (uint256(uint16(tokenId >> 208)) << 224)
        | (uint256(uint8(de)) << 216)
        | (uint256(uint56(value)) << 160)
        | uint160(from);
    }

    function getMarketId(uint256 tokenId, uint256 value, address from) public view returns (uint id) {
        id = getTokenId(tokenId, value, 0, from);
        uint tokId = tokens[id];
        if (tokId > 0) {
            uint item = 1;
            while (tokId != 0) {
                id = getTokenId(tokenId, value, uint8(item), from);
                tokId = tokens[id];
                item = item.add(1);
            }
        }
    }


    function setBytes(address user1, uint128 value) public pure returns (bytes memory ds) {
        uint256 id = (1 << 255) | (uint256(uint96(value)) << 160) | uint160(user1);
        ds = toBytesEth(id);
    }

    function getBytes(bytes memory ds) public pure returns (uint256, address){
        uint256 token = bytesToUint(ds);

        return (((token ^ (1 << 255)) >> 160), address(uint160(token)));
    }

    function toBytesEth(uint256 x) public pure returns (bytes memory b) {
        b = new bytes(32);
        for (uint i = 0; i < 32; i++) {
            b[i] = byte(uint8(x / (2 ** (8 * (31 - i)))));
        }
    }


    function bytesToUint(bytes memory b) public pure returns (uint256){

        uint256 number;
        for (uint i = 0; i < b.length; i++) {
            number = number + uint8(b[i]) * (2 ** (8 * (b.length - (i + 1))));
        }
        return number;
    }

    function getMarketCard(address erc20) public view returns (uint256[] memory _market) {
        _market = marketCard[erc20];
    }

    function cardWithdraw(address erc20, address to, uint256 tokenId) public CheckPermit("Config") {
        uint256 cardId = tokens[tokenId];

        marketPing(to, cardId, tokenId, erc20, 0);
    }


    function withdraw(address _erc20, address payable account, uint256 value) public CheckPermit("Config") {
        if (_erc20 != address(0)) {
            IERC20 erc20 = IERC20(_erc20);
            erc20.transfer(account, value);
        } else {
            account.transfer(value);
        }
    }

    function getMarketBalance(address account, address erc20) public view returns (uint256 _balance) {
        _balance = marketBalance[account][erc20];
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
 

interface IPair {

    function getTokenPath(
        address token1,
        address token2
    ) external view returns (address[] memory _tokens);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
 

interface ISwap {

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./lib/Util.sol";
import "./Shop.sol";
import "./interface/IERC20.sol";
import "./Card.sol";
import "./Package.sol";
import "./interface/IBlockhashMgr.sol";

contract CardSale is Shop {
    using UInteger for uint256;

    uint256 public uintPrice;

    uint256 public lockDuration = 0;

    uint256 public maxOnce = 50;
    uint256 public minOnce = 1;
    uint256 public buyCountLimit;
    uint256[] public rarityWeights;
    uint256[] public cardWeights;
    uint256 public cardCount;

    uint256[] public tokenInclude;

    mapping(address => uint256) public buyCount;

    constructor(
        uint256[] memory _rarityWeights,
        uint256[] memory _tokenInclude,
        uint256[] memory _cardWeights,
        uint256 _uintPrice
    ) {
        cardWeights = _cardWeights;

        uint256 length = 0;
        for (uint256 i = 0; i != cardWeights.length; i++) {
            if (cardWeights[i] != 0) {
                length++;
            }
        }
        cardCount = length;

        rarityWeights = _rarityWeights;
        tokenInclude = _tokenInclude;
        uintPrice = _uintPrice;
        quantityMax = ~uint256(0);
    }

    function updateCardWeight(uint256 cardId, bool open)
        external
        CheckPermit("Config")
    {
        uint256 car = 0;
        uint256 ds = 0;
        if (open) {
            car = cardId;
            ds = cardCount.add(1);
        } else {
            ds = cardCount.sub(1);
        }
        cardWeights[cardId - 1] = car;
        cardCount = ds;
    }

    function setBuyCountLimit(uint256 limit) external CheckPermit("Config") {
        buyCountLimit = limit;
    }

    function buy(uint256 quantity) external {
        require(quantity >= minOnce, "Less than minOnce.");
        require(quantity <= maxOnce, "Out of max");
        require(
            buyCount[msg.sender] + quantity <= buyCountLimit ||
                buyCountLimit == 0,
            "Out of max"
        );

        buyCount[msg.sender] += quantity;
        _buy(msg.sender, msg.sender, uintPrice, quantity, quantityCount);
    }

    function onOpenPackage(
        address to,
        uint256 packageId,
        bytes32 bh
    ) external view override returns (uint256[] memory) {
        uint256 quantity = uint16(packageId >> 144);
        uint256 padding = uint32(packageId >> 104);
        uint256[] memory cardIdPre = new uint256[](quantity);

        for (uint256 i = 0; i != quantity; ++i) {
            bytes memory seed = abi.encodePacked(
                bh,
                padding,
                cardIdPre,
                abi.encodePacked(i + 1),
                to
            );
            uint256 cardType = Util.randomWeightCard(
                seed,
                cardWeights,
                cardCount
            );
            seed = abi.encodePacked(
                bh,
                padding,
                cardIdPre,
                abi.encodePacked(i + 2)
            );
            uint256 cardRarity = Util.randomWeight(
                seed,
                rarityWeights,
                1000000
            );

            cardIdPre[i] = ((1 << 255) |
                (uint256(uint32(cardType)) << 224) |
                (uint256(uint16(cardRarity)) << 208) |
                (uint256(uint96(tokenInclude[cardRarity])) << 112) |
                (uint256(uint40(lockDuration)) << 72) |
                (uint40(block.timestamp) << 32));
        }
        return cardIdPre;
    }

    function getRarity() public view returns (uint256[] memory _rarityWeight) {
        _rarityWeight = rarityWeights;
    }

    function getRarityWeights(uint256 packageId)
        external
        view
        override
        returns (uint256[] memory _rarityWeight)
    {
        uint256 shopId = uint32((packageId ^ (1 << 255)) >> 224);
        (uint256 id, ) = Package(manager.members("package")).shopInfos(
            address(this)
        );
        if (id == shopId) {
            _rarityWeight = rarityWeights;
        }
    }

    function ERC20Address() public view override returns (address) {
        return manager.members("token");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./Member.sol";
import "./Card.sol";

contract Recast is Member {

    bool public recastEnable = true;

    uint256 public lockDuration;

    mapping(uint256 => uint256) public rarityChance;

    uint256 public recastId;

    uint16 public cardRarity = 4;

    uint256[] public tokenAmount;

    constructor() {
        tokenAmount.push(10);
        tokenAmount.push(50);
        tokenAmount.push(100);
        tokenAmount.push(200);
        tokenAmount.push(400);
        tokenAmount.push(800);
        tokenAmount.push(3000);
    }

    function stopRecast() public CheckPermit("Admin") {
        recastEnable = false;
    }

    function startRecast() public CheckPermit("Admin") {
        recastEnable = true;
    }

    function updateCardRarity(uint16 _cardRarity) public CheckPermit("Config") {
        cardRarity = _cardRarity;
    }

    function onERC721ExReceived(address, address from, uint256[] memory tokenIds, bytes memory) external returns (bytes4) {
        require(recastEnable, "recast is not turned on");
        require(tokenIds.length > 1, "card number error.");
        require(msg.sender == manager.members("card"), "card contract address error");

        uint256 token = 0;
        uint16 rarity = uint16(tokenIds[0] >> 208);
        require(rarity < cardRarity, "rarity not error");
        uint32 cardType = uint32((tokenIds[0] ^ (1 << 255)) >> 224);
        for (uint i = 0; i < tokenIds.length; ++i) {
            uint256 cardId = tokenIds[i];
            if (rarity != uint16(cardId >> 208) || cardType != uint32((cardId ^ (1 << 255)) >> 224)) {
                continue;
            }
            token = token + uint256(uint96(cardId >> 112));
        }
        rarity = rarity + 1;
        require(token >= tokenAmount[rarity], "tokenAmount not error");

        Card card = Card(manager.members("card"));
        card.burnSynthesis(address(this), tokenIds);

        uint256 cardIdPre = ((1 << 255)
        | (uint256(uint32(cardType)) << 224)
        | (uint256(uint16(rarity)) << 208)
        | (uint256(uint96(tokenAmount[rarity])) << 112)
        | uint256(uint40(lockDuration)) << 72
        | uint40(block.timestamp) << 32);

        card.mint(from, cardIdPre);

        return Util.ERC721_RECEIVER_EX_RETURN;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;
 
import "./Member.sol";

contract Pair is Member {

    mapping(address => mapping(address => address[])) public trTokens;

    function getTokenPath(address token1, address token2) public view returns (address[] memory _tokens) {
        address[] memory token = trTokens[token1][token2];

        if (token.length <= 0) {
            _tokens = new address[](2);
            _tokens[0] = token1;
            _tokens[1] = token2;
            return _tokens;
        }
        _tokens = new address[](token.length + 2);
        _tokens[0] = token1;
        for (uint i; i < token.length; i++) {
            _tokens[i + 1] = token[i];
        }
        _tokens[_tokens.length - 1] = token2;
    }


    function setTokenPath(address token1, address token2, address[] memory _tokens) public CheckPermit("Config") {
        trTokens[token1][token2] = _tokens;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/math/Math.sol";

import "./Member.sol";

contract LPPool is Member {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public immutable initReward;
    uint256 public immutable startTime;
    uint256 public immutable periodFinish;
    uint256 public immutable rewardRate;
    uint256 public immutable DURATION;

    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    IERC20 public lpToken;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;

    constructor(
        IERC20 _lpToken,
        uint256 _startTime,
        uint256 _initReward,
        uint256 _duration
    ) {
        lpToken = _lpToken;
        initReward = _initReward;
        rewardRate = _initReward.div(_duration);
        startTime = _startTime;
        periodFinish = _startTime.add(_duration);
        DURATION = _duration;
        lastUpdateTime = _startTime;
        emit RewardAdded(_initReward);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount)
        public
        updateReward(msg.sender)
        checkStart
    {
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        lpToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount)
        public
        updateReward(msg.sender)
        checkStart
    {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        lpToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function withdraw() public updateReward(msg.sender) checkStart {
        uint256 amount = balanceOf(msg.sender);
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        lpToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkStart {
        uint256 reward = earned(msg.sender);
        if (reward <= 0) {
            return;
        }
        rewards[msg.sender] = 0;
        IERC20(manager.members("token")).safeTransfer(msg.sender, reward);
        emit RewardPaid(msg.sender, reward);
    }

    function adminConfig(address _account, uint256 _value)
        public
        CheckPermit("Config")
    {
        IERC20(manager.members("token")).transfer(_account, _value);
    }

    modifier checkStart() {
        require(block.timestamp > startTime, "not start");
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/math/Math.sol';
import '../interfaces/IGIBXFactory.sol';
import '../interfaces/IGIBXCallee.sol';
import '../libraries/UQ112x112.sol';
import '../libraries/GIBXLibrary.sol';
import '../interfaces/IGIBXPair.sol';
import '../libraries/SqrtMath.sol';
import '../token/GIBXERC20.sol';

contract GIBXPair is GIBXERC20 {
    using SafeMath  for uint;
    using UQ112x112 for uint224;

    uint public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;
    address public token0;
    address public token1;

    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'GIBX: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'GIBX: TRANSFER_FAILED');
    }

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor() {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, 'GIBX: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'GIBX: OVERFLOW');
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IGIBXFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = SqrtMath.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = SqrtMath.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint denominator = rootK.mul(GIBXLibrary.SWAP_FEE_LP.sub(1)).add(rootKLast);
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock returns (uint liquidity) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = SqrtMath.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
           _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'GIBX: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external lock returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        address _token0 = token0;                                // gas savings
        address _token1 = token1;                                // gas savings
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        uint liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        require(_totalSupply != 0, "influence balance");
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'GIBX: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
        require(amount0Out > 0 || amount1Out > 0, 'GIBX: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'GIBX: INSUFFICIENT_LIQUIDITY');

        uint balance0;
        uint balance1;
        { // scope for _token{0,1}, avoids stack too deep errors
        address _token0 = token0;
        address _token1 = token1;
        require(to != _token0 && to != _token1, 'GIBX: INVALID_TO');
        if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
        if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
        if (data.length > 0) IGIBXCallee(to).flyCall(msg.sender, amount0Out, amount1Out, data);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'GIBX: INSUFFICIENT_INPUT_AMOUNT');
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
        uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(GIBXLibrary.SWAP_FEE));
        uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(GIBXLibrary.SWAP_FEE));
        require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'GIBX: K');
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // force balances to match reserves
    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)).sub(reserve0));
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(reserve1));
    }

    // force reserves to match balances
    function sync() external lock {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

interface IGIBXFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function expectPairFor(address token0, address token1) external view returns (address);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external pure returns (bytes32);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

interface IGIBXCallee {
    function flyCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import '@openzeppelin/contracts/math/SafeMath.sol';
import '../interfaces/IGIBXPair.sol';
import '../interfaces/IGIBXFactory.sol';

library GIBXLibrary {
    using SafeMath for uint;

    uint256 constant SWAP_FEE = 3;
    uint256 constant SWAP_FEE_BASE = 1000;
    uint256 constant SWAP_FEE_LP = 2;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                IGIBXFactory(factory).INIT_CODE_PAIR_HASH()
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IGIBXPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(SWAP_FEE_BASE.sub(SWAP_FEE));
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(SWAP_FEE_BASE).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(SWAP_FEE_BASE);
        uint denominator = reserveOut.sub(amountOut).mul(SWAP_FEE_BASE.sub(SWAP_FEE));
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

interface IGIBXPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

// a library for performing various math operations

library SqrtMath {
    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import '@openzeppelin/contracts/math/SafeMath.sol';
import '../interfaces/IGIBXERC20.sol';

contract GIBXERC20 is IGIBXERC20 {
    using SafeMath for uint256;

    string public override constant name = 'GIBX LPs';
    string public override constant symbol = 'GIBX-LP';
    uint8 public override constant decimals = 18;
    uint  public override totalSupply;
    mapping(address => uint) public override balanceOf;
    mapping(address => mapping(address => uint)) public override allowance;

    bytes32 public override DOMAIN_SEPARATOR;
    bytes32 public override constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    mapping(address => uint) public override nonces;

    constructor() {
        uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external override returns (bool) {
        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external override {
        require(deadline >= block.timestamp, 'GIBX: EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'GIBX: INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

interface IGIBXERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '../interfaces/IGIBXERC20.sol';

contract TokenLocker {
    using SafeMath for uint256;

    ///@notice every block cast 3 seconds
    uint256 public constant SECONDS_PER_BLOCK = 3;

    ///@notice the token to lock
    IERC20 public immutable token;

    ///@notice who will receive this token
    address public immutable receiver;

    ///@notice the blockNum of last release, the init value would be the timestamp the contract created
    uint256 public lastReleaseAt;

    ///@notice how many block must be passed before next release
    uint256 public immutable interval;

    ///@notice the amount of one release time
    uint256 public immutable releaseAmount;

    ///@notice the total amount till now
    uint256 public totalReleasedAmount;

    constructor(
        address _token, address _receiver, uint256 _intervalSeconds, uint256 _releaseAmount
    ) {
        require(_token != address(0), "illegal token");
        token = IERC20(_token);
        receiver = _receiver; 
        //lastReleaseAt = block.number;
        require(_intervalSeconds > SECONDS_PER_BLOCK, 'illegal interval');
        uint256 interval_ = _intervalSeconds.add(SECONDS_PER_BLOCK).sub(1).div(SECONDS_PER_BLOCK);
        interval = interval_;
        uint256 lastReleaseAt_ = interval_ > block.number ? block.number : block.number.sub(interval_);
        lastReleaseAt = lastReleaseAt_;
        require(_releaseAmount > 0, 'illegal releaseAmount');
        releaseAmount = _releaseAmount;
    }

    function getClaimInfo() internal view returns (uint256, uint256) {
        uint currentBlockNum = block.number;
        uint intervalBlockNum = currentBlockNum - lastReleaseAt;
        if (intervalBlockNum < interval) {
            return (0, 0);
        }
        uint times = intervalBlockNum.div(interval);
        uint amount = releaseAmount.mul(times);
        if (token.balanceOf(address(this)) < amount) {
            amount = token.balanceOf(address(this));
        }
        return (amount, times);
    }

    function claim() external {
        (uint amount, uint times) = getClaimInfo();
        if (amount == 0 || times == 0) {
            return;
        }
        lastReleaseAt = lastReleaseAt.add(interval.mul(times));
        totalReleasedAmount = totalReleasedAmount.add(amount);
        SafeERC20.safeTransfer(token, receiver, amount);
    }

    ///@notice return the amount we can claim now, and the next timestamp we can claim next time
    function lockInfo() external view returns (uint256 amount, uint256 timestamp) {
        (amount, ) = getClaimInfo();
        if (amount == 0) {
            timestamp = block.timestamp.add(interval.sub(block.number.sub(lastReleaseAt)).mul(SECONDS_PER_BLOCK));
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/proxy/Initializable.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '../interfaces/IGIBXFactory.sol';
import '../interfaces/IGIBXRouter.sol';
import '../libraries/GIBXLibrary.sol';
import '../interfaces/IGIBXPair.sol';
import '../core/SafeOwnable.sol';
import 'hardhat/console.sol';

contract GIBXSwapFee is SafeOwnable, Initializable {
    using SafeMath for uint;
    using Address for address;

    address public constant hole = 0x000000000000000000000000000000000000dEaD;
    address public vault;
    IGIBXRouter public router;
    IGIBXFactory public factory;
    address public WETH;
    address public destroyToken;
    address public USDT;
    address public receiver;
    address public caller;

    function initialize(address vault_, IGIBXRouter router_, IGIBXFactory factory_, address WETH_, address destroyToken_, address USDT_, address receiver_, address caller_) external initializer {
        vault = vault_;
        router = router_;
        factory = factory_;
        WETH = WETH_;
        destroyToken = destroyToken_;
        USDT = USDT_;
        receiver = receiver_;
        caller = caller_;
    }

    function setCaller(address newCaller_) external onlyOwner {
        require(newCaller_ != address(0), "caller is zero");
        caller = newCaller_;
    }

    function setReceiver(address newReceiver_) external onlyOwner {
        require(newReceiver_ != address(0), "receiver is zero");
        receiver = newReceiver_;
    }

    function transferToVault(address token, uint balance) internal returns (uint balanceRemained) {
        uint balanceUsed = balance.mul(1).div(2); //1/2
        balanceRemained = balance.sub(balanceUsed);
        SafeERC20.safeTransfer(IERC20(token), vault, balanceUsed);
    }

    function canRemove(IGIBXPair pair) internal view returns (bool) {
        address token0 = pair.token0();
        address token1 = pair.token1();
        uint balance0 = IERC20(token0).balanceOf(address(pair));
        uint balance1 = IERC20(token1).balanceOf(address(pair));
        uint totalSupply = pair.totalSupply();
        if (totalSupply == 0) {
            return false;
        }
        uint liquidity = pair.balanceOf(address(this));
        uint amount0 = liquidity.mul(balance0) / totalSupply; // using balances ensures pro-rata distribution
        uint amount1 = liquidity.mul(balance1) / totalSupply; // using balances ensures pro-rata distribution
        if (amount0 == 0 || amount1 == 0) {
            return false;
        }
        return true;
    }

    function doHardwork(address[] calldata pairs, uint minAmount) external {
        require(msg.sender == caller, "illegal caller");
        for (uint i = 0; i < pairs.length; i ++) {
            IGIBXPair pair = IGIBXPair(pairs[i]);
            if (pair.token0() != USDT && pair.token1() != USDT) {
                continue;
            }
            uint balance = pair.balanceOf(address(this));
            if (balance == 0) {
                continue;
            }
            if (balance < minAmount) {
                continue;
            }
            if (!canRemove(pair)) {
                continue;
            }
            address token = pair.token0() != USDT ? pair.token0() : pair.token1();
            pair.approve(address(router), balance);
            router.removeLiquidity(
                token,
                USDT,
                balance,
                0,
                0,
                address(this),
                block.timestamp
            );
            address[] memory path = new address[](2);
            path[0] = token;path[1] = USDT;
            balance = IERC20(token).balanceOf(address(this));
            IERC20(token).approve(address(router), balance);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                balance,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function destroyAll() external onlyOwner {
        uint balance = IERC20(USDT).balanceOf(address(this));
        balance = transferToVault(USDT, balance);
        address[] memory path = new address[](2);
        path[0] = USDT;path[1] = destroyToken;
        balance = IERC20(USDT).balanceOf(address(this));
        IERC20(USDT).approve(address(router), balance);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            balance,
            0,
            path,
            address(this),
            block.timestamp
        );
        balance = IERC20(destroyToken).balanceOf(address(this));
        SafeERC20.safeTransfer(IERC20(destroyToken), hole, balance);
    }

    function transferOut(address token, uint amount) external onlyOwner {
        IERC20 erc20 = IERC20(token);
        uint balance = erc20.balanceOf(address(this));
        if (balance < amount) {
            amount = balance;
        }
        SafeERC20.safeTransfer(erc20, receiver, amount);
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

interface IGIBXRouter {
    function factory() external view returns (address);
    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import '@openzeppelin/contracts/utils/Context.sol';

/**
 * This is a contract copied from 'Ownable.sol'
 * It has the same fundation of Ownable, besides it accept pendingOwner for mor Safe Use
 */
abstract contract SafeOwnable is Context {
    address private _owner;
    address private _pendingOwner;

    event ChangePendingOwner(address indexed previousPendingOwner, address indexed newPendingOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyPendingOwner() {
        require(pendingOwner() == _msgSender(), "Ownable: caller is not the pendingOwner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
        if (_pendingOwner != address(0)) {
            emit ChangePendingOwner(_pendingOwner, address(0));
            _pendingOwner = address(0);
        }
    }

    function setPendingOwner(address pendingOwner_) public virtual onlyOwner {
        require(pendingOwner_ != address(0), "Ownable: pendingOwner is the zero address");
        emit ChangePendingOwner(_pendingOwner, pendingOwner_);
        _pendingOwner = pendingOwner_;
    }

    function acceptOwner() public virtual onlyPendingOwner {
        emit OwnershipTransferred(_owner, _pendingOwner);
        _owner = _pendingOwner;
        emit ChangePendingOwner(_pendingOwner, address(0));
        _pendingOwner = address(0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '../core/SafeOwnable.sol';
import "hardhat/console.sol";

contract MockToken is ERC20, SafeOwnable {
    constructor(string memory name_, string memory symbol_, uint8 decimals_) ERC20(name_, symbol_) {
        if (decimals_ != 18) {
            _setupDecimals(decimals_);
        }
    }

    function mint (address to_, uint amount_) external {
        _mint(to_, amount_);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../utils/Context.sol";
import "./IERC20.sol";
import "../../math/SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import '@openzeppelin/contracts/token/ERC20/ERC20Capped.sol';
import '../core/SafeOwnable.sol';

contract GIBXToken is ERC20Capped, SafeOwnable {
    using SafeMath for uint256;

    event MinterChanged(address indexed minter, bool avaliable);

    uint256 public constant MAX_SUPPLY = 1 * 10 ** 9 * 10 ** 18;
    mapping(address => bool) public minters;

    constructor() ERC20Capped(MAX_SUPPLY) ERC20("GDX", "GDX") {
        addMinter(msg.sender);
    }

    function addMinter(address _minter) public onlyOwner {
        require(_minter != address(0), "illegal minter");
        require(!minters[_minter], "already minter");
        minters[_minter] = true;
        emit MinterChanged(_minter, true);
    }

    function delMinter(address _minter) public onlyOwner {
        require(_minter != address(0), "illegal minter");
        require(minters[_minter], "not minter");
        delete minters[_minter];
        emit MinterChanged(_minter, false);
    }

    modifier onlyMinter() {
        require(minters[msg.sender], "caller is not minter");
        _;
    }

    function mint(uint256 amount) external onlyMinter {
        _mint(msg.sender, amount);
    }

    function mintFor(address to, uint256 amount) external onlyMinter {
        _mint(to, amount);
    }

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }
    mapping (address => address) internal _delegates;
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;
    mapping (address => uint32) public numCheckpoints;
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");
    mapping (address => uint) public nonces;

    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "GIBX::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "GIBX::delegateBySig: invalid nonce");
        require(block.timestamp <= expiry, "GIBX::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "GIBX::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying GIBXs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "GIBX::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

    function renounceOwnership() public override onlyOwner {
        delMinter(owner());
        SafeOwnable.renounceOwnership();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./ERC20.sol";

/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */
abstract contract ERC20Capped is ERC20 {
    using SafeMath for uint256;

    uint256 private _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor (uint256 cap_) internal {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - minted tokens must not cause the total supply to go over the cap.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) { // When minting tokens
            require(totalSupply().add(amount) <= cap(), "ERC20Capped: cap exceeded");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "../core/SafeOwnable.sol";
import '../libraries/TransferHelper.sol';
import '../interfaces/ISwapMining.sol';
import '../interfaces/IGIBXFactory.sol';
import '../interfaces/IGIBXRouter.sol';
import '../libraries/GIBXLibrary.sol';
import '../interfaces/IWETH.sol';

contract GIBXRouter is IGIBXRouter, SafeOwnable {
    using SafeMath for uint;

    address public immutable override factory;
    address public immutable override WETH;
    address public swapMining;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'GIBXRouter: EXPIRED');
        _;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function setSwapMining(address _swapMininng) public onlyOwner {
        swapMining = _swapMininng;
    }

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        // create the pair if it doesn't exist yet
        if (IGIBXFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            IGIBXFactory(factory).createPair(tokenA, tokenB);
        }
        (uint reserveA, uint reserveB) = GIBXLibrary.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = GIBXLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'GIBXRouter: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = GIBXLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'GIBXRouter: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = GIBXLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IGIBXPair(pair).mint(to);
    }
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external virtual override payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = GIBXLibrary.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IGIBXPair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = GIBXLibrary.pairFor(factory, tokenA, tokenB);
        IGIBXPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = IGIBXPair(pair).burn(to);
        (address token0,) = GIBXLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'GIBXRouter: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'GIBXRouter: INSUFFICIENT_B_AMOUNT');
    }
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountToken, uint amountETH) {
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountA, uint amountB) {
        address pair = GIBXLibrary.pairFor(factory, tokenA, tokenB);
        uint value = approveMax ? uint(-1) : liquidity;
        IGIBXPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountToken, uint amountETH) {
        address pair = GIBXLibrary.pairFor(factory, token, WETH);
        uint value = approveMax ? uint(-1) : liquidity;
        IGIBXPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountETH) {
        (, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountETH) {
        address pair = GIBXLibrary.pairFor(factory, token, WETH);
        uint value = approveMax ? uint(-1) : liquidity;
        IGIBXPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token, liquidity, amountTokenMin, amountETHMin, to, deadline
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = GIBXLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            if (swapMining != address(0)) {
                ISwapMining(swapMining).swap(msg.sender, input, output, amountOut);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? GIBXLibrary.pairFor(factory, output, path[i + 2]) : _to;
            IGIBXPair(GIBXLibrary.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = GIBXLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'GIBXRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, GIBXLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        amounts = GIBXLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'GIBXRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, GIBXLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'GIBXRouter: INVALID_PATH');
        amounts = GIBXLibrary.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'GIBXRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(GIBXLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'GIBXRouter: INVALID_PATH');
        amounts = GIBXLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'GIBXRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, GIBXLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'GIBXRouter: INVALID_PATH');
        amounts = GIBXLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'GIBXRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, GIBXLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'GIBXRouter: INVALID_PATH');
        amounts = GIBXLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= msg.value, 'GIBXRouter: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(GIBXLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = GIBXLibrary.sortTokens(input, output);
            IGIBXPair pair = IGIBXPair(GIBXLibrary.pairFor(factory, input, output));
            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
            amountOutput = GIBXLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            if (swapMining != address(0)) {
                ISwapMining(swapMining).swap(msg.sender, input, output, amountOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? GIBXLibrary.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, GIBXLibrary.pairFor(factory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'GIBXRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        override
        payable
        ensure(deadline)
    {
        require(path[0] == WETH, 'GIBXRouter: INVALID_PATH');
        uint amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(GIBXLibrary.pairFor(factory, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'GIBXRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        override
        ensure(deadline)
    {
        require(path[path.length - 1] == WETH, 'GIBXRouter: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, GIBXLibrary.pairFor(factory, path[0], path[1]), amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'GIBXRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual override returns (uint amountB) {
        return GIBXLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)
        public
        pure
        virtual
        override
        returns (uint amountOut)
    {
        return GIBXLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut)
        public
        pure
        virtual
        override
        returns (uint amountIn)
    {
        return GIBXLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint[] memory amounts)
    {
        return GIBXLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint[] memory amounts)
    {
        return GIBXLibrary.getAmountsIn(factory, amountOut, path);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        SafeERC20.safeApprove(IERC20(token), to, value);
    }

    function safeTransfer(address token, address to, uint value) internal {
        SafeERC20.safeTransfer(IERC20(token), to, value);
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        SafeERC20.safeTransferFrom(IERC20(token), from, to, value);
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

interface ISwapMining {
    function swap(address account, address input, address output, uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import '../libraries/GIBXLibrary.sol';
import './GIBXPair.sol';

contract GIBXFactory {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(GIBXPair).creationCode));

    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function expectPairFor(address token0, address token1) public view returns (address) {
        return GIBXLibrary.pairFor(address(this), token0, token1);
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'GIBX: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'GIBX: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'GIBX: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(GIBXPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IGIBXPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'GIBX: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'GIBX: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}

// SPDX-License-Identifier: MIT


pragma solidity 0.7.6;

import '../interfaces/IGIBXPair.sol';
import './FixedPoint.sol';

library OracleLibrary {
    using FixedPoint for *;

    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2 ** 32);
    }

    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.
    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IGIBXPair(pair).price0CumulativeLast();
        price1Cumulative = IGIBXPair(pair).price1CumulativeLast();

        // if time has elapsed since the last update on the pair, mock the accumulated price values
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IGIBXPair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            // subtraction overflow is desired
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            // addition overflow is desired
            // counterfactual
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            // counterfactual
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}

// SPDX-License-Identifier: MIT


pragma solidity 0.7.6;

library FixedPoint {
    // range: [0, 2**112 - 1]
    // resolution: 1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // range: [0, 2**144 - 1]
    // resolution: 1 / 2**112
    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }

    // encodes a uint144 as a UQ144x112
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {
        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    // multiply a UQ112x112 by a uint, returning a UQ144x112
    // reverts on overflow
    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {
        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    // returns a UQ112x112 which represents the ratio of the numerator to the denominator
    // equivalent to encode(numerator).div(denominator)
    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {
        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    // decode a UQ112x112 into a uint112 by truncating after the radix point
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }

    // decode a UQ144x112 into a uint144 by truncating after the radix point
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./interface/IERC20.sol";

import "./Member.sol";

contract LGToken is IERC20, Member {
    string public override name;
    string public override symbol;
    uint8 public override decimals;

    uint256 public override totalSupply;
    uint256 public remainedSupply;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    mapping(address => bool) public _isExcludedFrom;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _maxSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        remainedSupply = _maxSupply;
    }

    function excludeFrom(address account) external CheckPermit("Admin") {
        _isExcludedFrom[account] = true;
    }

    function includeInFrom(address account) external CheckPermit("Admin") {
        _isExcludedFrom[account] = false;
    }

    function mint(address to, uint256 amount) external CheckPermit("Config") {
        require(to != address(0), "zero address");
        require(remainedSupply >= amount, "mint too much");

        remainedSupply -= amount;
        totalSupply += amount;
        balanceOf[to] += amount;

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) private {
        require(balanceOf[from] >= amount, "balance not enough");

        balanceOf[from] -= amount;
        totalSupply -= amount;

        emit Transfer(from, address(0), amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function burnFrom(address from, uint256 amount) external {
        require(allowance[from][msg.sender] >= amount, "allowance not enough");

        allowance[from][msg.sender] -= amount;
        _burn(from, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_isExcludedFrom[from], "sender is excluded");
        require(to != address(0), "zero address");
        require(balanceOf[from] >= amount, "balance not enough");

        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);
    }

    function transfer(address to, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(allowance[from][msg.sender] >= amount, "allowance not enough");

        allowance[from][msg.sender] -= amount;
        _transfer(from, to, amount);

        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        require(spender != address(0), "zero address");

        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);

        return true;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;
 

import "./Member.sol";

contract Invite is Member {

    event InvEvent(address account, address inviter);
    event NameEvent(address indexed account, string name);
    event GodsReward(address indexed account, address indexed _token);

    mapping(address => address) public inviter;
    mapping(address => string) public vipName;

    function updateInviter(address _user) public CheckPermit("Config") {
        require(inviter[_user] == address(0));
        inviter[_user] = address(this);
    }

    function invite(address _inviter) public {
        require(inviter[msg.sender] == address(0));
        require(inviter[_inviter] != address(0));
        require(msg.sender != _inviter);

        inviter[msg.sender] = _inviter;
        emit InvEvent(msg.sender, _inviter);
    }

    function updateName(string memory _name) public {
        vipName[msg.sender] = _name;
        emit NameEvent(msg.sender, _name);
    }

    function godsReward() external {
        emit GodsReward(msg.sender, manager.members("token"));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;
 
import "./interface/IBlockhashMgr.sol";
import "./Member.sol";

contract BlockhashMgr is IBlockhashMgr, Member {

    mapping(uint256 => bytes32) public blockInfo;

    uint256 public preBlockNum = block.number;

    mapping(address => bool) permission;

    function setPermission(address sender, bool enable) public CheckPermit("Config") {
        permission[sender] = enable;
    }


    function request() external{
        require(blockInfo[preBlockNum] == 0);
        blockInfo[preBlockNum] = blockhash(preBlockNum);
    }

    function isRequest()public view returns(bool){
        return (blockInfo[preBlockNum] == 0) && (preBlockNum + 200 < block.number);
    }


    function request(uint256 blockNumber) external override {
        require(permission[msg.sender]);
        require(blockNumber >= block.number && blockNumber < block.number + 2);
        if (blockNumber != preBlockNum && blockInfo[preBlockNum] == 0) {
            if (block.number - preBlockNum > 256) {
                blockInfo[preBlockNum] = keccak256(abi.encodePacked(block.difficulty, blockNumber, block.timestamp, block.number, preBlockNum));
            } else {
                blockInfo[preBlockNum] = blockhash(preBlockNum);
            }
        }
        preBlockNum = blockNumber;
    }

    function getBlockhash(uint256 blockNumber) external override returns (bytes32) {
        require(permission[msg.sender]);
        require(block.number >= blockNumber);

        if (blockInfo[blockNumber] == 0) {
            if (block.number - blockNumber > 256) {
                blockInfo[blockNumber] = keccak256(abi.encodePacked(block.difficulty, blockNumber, block.timestamp, block.number, preBlockNum));
            } else {
                blockInfo[blockNumber] = blockhash(blockNumber);
            }
            preBlockNum = blockNumber;
        }

        return blockInfo[blockNumber];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;
pragma abicoder v2;

import "./Member.sol";
import "./Card.sol";
import "./interface/IERC20.sol";

contract Auction is Member {
    event RaiseEvent(address account, uint256 value, uint256 cardPre);

    uint256 public lockDuration;

    struct AuctionInfo {
        //开始时间
        uint256 startTime;
        //拍卖时长
        uint64 duration;
        //卡片
        uint256 cardPre;
        //购买币种
        address erc20;
        //当前价格
        uint256 value;
        //每次加价
        uint256 eachValue;
        //最后赢家
        address winner;
        //精度
        uint256 precision;
    }

    struct UserRaise {
        uint256 value;
        uint256 issue;
        address erc20;
    }

    uint256 public issue = 0;

    uint256[] public tokenAmount;

    //每局参与的用户及参与金额
    mapping(uint256 => uint256[]) public issues;
    //用户获得的卡片
    mapping(address => uint256[]) public userCard;

    AuctionInfo[] private auctions;

    constructor(address _erc20) {
        tokenAmount.push(10);
        tokenAmount.push(50);
        tokenAmount.push(100);
        tokenAmount.push(200);
        tokenAmount.push(400);
        tokenAmount.push(800);
        tokenAmount.push(3000);

        auctions.push(
            AuctionInfo({
                startTime: 1635465600,
                duration: 168 hours,
                cardPre: generateCard(120, 6),
                erc20: _erc20,
                eachValue: 3000 * 10**18,
                precision: 1e14,
                winner: address(0),
                value: 0
            })
        );
    }

    function updateLockDuration(uint16 _lockDuration)
        public
        CheckPermit("Config")
    {
        lockDuration = _lockDuration;
    }

    function updateAuction(
        uint256 _startTime,
        uint64 _duration,
        uint32 cardType,
        uint16 rarity,
        address _erc20,
        uint256 eachValue,
        uint256 precision
    ) public CheckPermit("Admin") {
        issue = issue + 1;
        auctions.push(
            AuctionInfo({
                startTime: _startTime,
                duration: _duration,
                cardPre: generateCard(cardType, rarity),
                erc20: _erc20,
                eachValue: eachValue,
                precision: 10**precision,
                winner: address(0),
                value: 0
            })
        );
    }

    function raise(uint256 _value) external {
        AuctionInfo storage auc = auctions[issue];
        address owner = msg.sender;
        uint256 _now = block.timestamp;
        require(auc.startTime > 0 && _now > auc.startTime, "not start");
        require(_now < auc.startTime + auc.duration, "end error");
        require(_value > auc.value, "not value");
        //扣款
        tokenTransferFrom(auc.erc20, owner, _value);

        if (auc.winner != address(0)) {
            //将上个用户参与的金额返还
            IERC20(auc.erc20).transfer(auc.winner, auc.value);
            // delete userCard[auc.winner][userCard[auc.winner].length - 1];
            updateUserCard(auc.winner);
        }

        //更新用户得到的卡片
        updateUserCardLe(owner, auc.cardPre);

        auc.winner = owner;
        auc.value = _value;

        //插入每期参与记录里
        uint256 tokenId = genAuctionId(uint64(_value / auc.precision), owner);
        issues[issue].push(tokenId);

        emit RaiseEvent(owner, _value, auc.cardPre);
    }

    function updateUserCard(address _account) internal {
        uint256 _index = userCard[_account].length - 1;
        if (_index <= 0) {
            userCard[_account] = new uint256[](0);
            return;
        }
        uint256[] memory urlList = new uint256[](_index);
        uint256 s = 0;
        for (uint256 i = 0; i < _index; i++) {
            urlList[s] = userCard[_account][i];
            s++;
        }
        userCard[_account] = urlList;
    }

    function updateUserCardLe(address owner, uint256 cardPre) internal {
        uint256 userCardLength = userCard[owner].length;
        if (userCardLength == 0) {
            userCard[owner].push(cardPre);
            return;
        }
        if (userCard[owner][userCardLength - 1] == 0) {
            userCard[owner][userCardLength - 1] = cardPre;
            return;
        }
        if (userCard[owner][userCardLength - 1] != cardPre) {
            userCard[owner].push(cardPre);
        }
    }

    function mintCard(address _account) external {
        uint256[] memory newCards = getMintCard(_account);
        require(newCards.length > 0, "not card length");

        //将拍卖到得卡片给用户
        Card(manager.members("card")).batchMint(_account, newCards);
        userCard[_account] = new uint256[](0);
    }

    function getMintCard(address _account)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] storage cards = userCard[_account];
        uint256 cardLength = cards.length;
        if (cardLength <= 0) {
            return cards;
        }
        AuctionInfo storage auc = auctions[issue];

        //有这张卡，没有结束
        if (
            auc.cardPre == cards[cardLength - 1] &&
            block.timestamp < auc.startTime + auc.duration
        ) {
            cardLength = cardLength - 1;
        }
        if (cardLength <= 0) {
            return new uint256[](0);
        }

        uint256[] memory newCards = new uint256[](cardLength);
        for (uint256 i = 0; i < cardLength; i++) {
            newCards[i] = cards[i];
        }
        return newCards;
    }

    //当前期参与得用户及参与金额
    function getIssueRaise() public view returns (uint256[] memory) {
        return issues[issue];
    }

    //历史所有期
    function getIssue() public view returns (AuctionInfo[] memory) {
        return auctions;
    }

    //当前期竞拍数据
    function getEachIssue() public view returns (AuctionInfo memory) {
        return auctions[issue];
    }

    function generateCard(uint32 cardType, uint16 rarity)
        public
        view
        returns (uint256 cardPre)
    {
        cardPre = ((1 << 255) |
            (uint256(uint32(cardType)) << 224) |
            (uint256(uint16(rarity)) << 208) |
            (uint256(uint96(tokenAmount[rarity])) << 112) |
            (uint256(uint40(lockDuration)) << 72) |
            (uint40(block.timestamp) << 32));
    }

    function tokenTransferFrom(
        address _erc20,
        address _account,
        uint256 _value
    ) internal {
        IERC20 erc20 = IERC20(_erc20);
        if (erc20.allowance(_account, address(this)) < _value) {
            revert("Bet:Insufficient allowed.");
        }

        erc20.transferFrom(_account, address(this), _value);
    }

    function adminConfig(
        address erc20,
        address to,
        uint256 _value
    ) public CheckPermit("Admin") {
        IERC20(erc20).transfer(to, _value);
    }

    function genAuctionId(uint64 _value, address account)
        public
        pure
        returns (uint256 id)
    {
        id = (1 << 255) | (uint256(uint96(_value)) << 160) | uint160(account);
    }

    function getAuctionId(uint256 token) public pure returns (uint96, address) {
        return (uint96(((token ^ (1 << 255)) >> 160)), address(uint160(token)));
    }
}