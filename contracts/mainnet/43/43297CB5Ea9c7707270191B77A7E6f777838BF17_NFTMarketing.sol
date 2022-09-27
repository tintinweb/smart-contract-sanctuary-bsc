/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}

contract Base is Ownable, ReentrancyGuard {
    address internal _master;
    address internal _thisAddress;

    uint256 internal randKey = 0;
    function rand(uint256 max, uint256 randNums) internal returns (uint256) {
        uint256 rands = uint256(keccak256(abi.encodePacked(getTime(), block.difficulty, msg.sender, randKey, randNums))) % max;
        if (rands <= 0) {
            rands = max;
        }
        randKey++;
        return rands;
    }

    function getTime() view public returns(uint256) {
        return block.timestamp;
    }

    function getProportion(uint256 amount, uint per) internal pure returns(uint256) {
        return (amount * per) / 100;
    }
}

library Math {
    enum Rounding {
        Down,
        Up,
        Zero
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            uint256 prod0;
            uint256 prod1;
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            require(denominator > prod1);
            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)

                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            uint256 twos = denominator & (~denominator + 1);
            assembly {
                denominator := div(denominator, twos)

                prod0 := div(prod0, twos)
                twos := add(div(sub(0, twos), twos), 1)
            }

            prod0 |= prod1 * twos;

            uint256 inverse = (3 * denominator) ^ 2;

            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            result = prod0 * inverse;
            return result;
        }
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 result = 1 << (log2(a) >> 1);
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IData {
    function getTmToken() view external returns(IERC20);
    function getTmTokenAddress() view external returns(address);
    function getNFT() view external returns(address);
    function getMining() view external returns(address);
    function getNftMining() view external returns(address);
}

contract NFTMarketing is Base {
    struct NftInfo {
        uint256 tokenId;
        uint256 level;
        address seller;
        uint256 sellPrice;
        uint256 sellTime;
    }
    mapping(uint256 => NftInfo)   internal _nftList;
    mapping(address => uint256[]) internal _userNftList;
    mapping(address => uint256[]) internal _userSellList;
    uint256 private delTokenId = 99999999999999999999;
    uint256[] internal _sellList;
    address _nftDividendAddress;
    address _otherAddress;

    IERC721 _nft;
    IData _data;
    IERC20 tmToken;

    constructor() {
        _thisAddress        = address(this);
        _data               = IData(address(0xd2E4d55c74Dcc223085F6AA3229F2b46AD5cf7ef));
        _nftDividendAddress = address(0x780A4270798Ff0c453C177C38CC7546055204e1B);
        _otherAddress       = address(0xaD232a4DC0c7f4F2AAfdF3874Df36fCD93978dBD);
    }

    //出售NFT
    function sell(uint256 tokenId, uint256 price) public {
        address sender = _msgSender();
        _nftList[tokenId].tokenId   = tokenId;
        _nftList[tokenId].sellTime  = block.timestamp;
        _nftList[tokenId].seller    = sender;
        _nftList[tokenId].sellPrice = price;
        _nft = IERC721(_data.getNFT());
        _nft.transferFrom(sender, _thisAddress, tokenId);

        uint256 length = _userSellList[sender].length;
                
        if (length <= 0) {
            _userSellList[sender] = new uint256[](1);
            _userSellList[sender][0] = tokenId;
        }
        else {
            _userSellList[sender].push(tokenId);
        }

        length = _sellList.length;
                
        if (length <= 0) {
            _sellList = new uint256[](1);
            _sellList[0] = tokenId;
        }
        else {
            _sellList.push(tokenId);
        }
    }

    //下架
    function takeDown(uint256 tokenId) public {
        address seller = _nftList[tokenId].seller;
        address sender = _msgSender();
        require(seller == sender, "I can't take it off, it's not my own");
        _nft = IERC721(_data.getNFT());
        _nft.transferFrom(_thisAddress, sender, tokenId);
        _delSell(tokenId, sender);
    }

    //获取当前用户的销售列表
    function getSellList() view public returns(uint256[] memory) {
        uint256[] memory userSellList = _userSellList[_msgSender()];
        uint256[] memory list = new uint256[](userSellList.length);
        uint256 count = 0;
        for(uint256 i = userSellList.length; i > 0; i--) {
            list[count++] = userSellList[i - 1];
        }
        return list;
    }

    //获取所有销售列表
    function getTotalSellList(uint256 start, uint256 limit) view public returns(uint256[] memory) {
        uint256[] memory list = new uint256[](limit);
        uint count = 0;
        uint256 sellListLength = _sellList.length;
        for(uint256 i = start; i < start + limit; i++) {
            if (i < sellListLength) {
                list[count] = _sellList[sellListLength - i - 1];                
            }
            else {
                list[count] = delTokenId;
            }
            count++;
        }
        return list;
    }

    function getTokenInfo(uint256 tokenId) public view returns (NftInfo memory) {
        TmNFT nft = TmNFT(_data.getNFT());
        NftInfo memory list = _nftList[tokenId];
        list.level = nft.getTokenLevel(tokenId);
        return list;
    }    

    //购买NFT
    function buy(uint256 tokenId) public {
        address sender    = _msgSender();
        address seller    = _nftList[tokenId].seller;
        uint256 sellPrice = _nftList[tokenId].sellPrice;
        require(seller != address(0), "This NFT is not for sale");
        require(seller != sender, "Can't buy myself");
        uint256 _nftDividendAmount = getProportion(sellPrice, 2);
        uint256 _otherAmount       = getProportion(sellPrice, 1);
        tmToken = _data.getTmToken();
        tmToken.transferFrom(sender, _thisAddress, sellPrice);
        tmToken.approve(_thisAddress, sellPrice);
        tmToken.transferFrom(_thisAddress, seller, sellPrice - _nftDividendAmount - _otherAmount);       //支付代币
        tmToken.transferFrom(_thisAddress, _nftDividendAddress, _nftDividendAmount);
        tmToken.transferFrom(_thisAddress, _otherAddress, _otherAmount);
        _nft = IERC721(_data.getNFT());
        //_nft.approve(sender, tokenId);
        _nft.transferFrom(_thisAddress, sender, tokenId);
        _delSell(tokenId, seller);
    }

    function _delSell(uint256 tokenId, address seller) private {
        _nftList[tokenId].seller = address(0);
        uint256 length = _sellList.length;
        for (uint256 i = 0; i < length ; i++) {
            if (_sellList[i] == tokenId) {
                _sellList[i] = delTokenId;
                break;
            }
        }

        length = _userSellList[seller].length;

        for (uint256 i = 0; i < length ; i++) {
            if (_userSellList[seller][i] == tokenId) {
                _userSellList[seller][i] = delTokenId;
                break;
            }
        }
    }
}

interface TmNFT {
    function getTokenLevel(uint256 tokenId) external view returns (uint256);
}