pragma solidity 0.8.11;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IContract.sol";


contract Clover_Seeds_Picker is Ownable {
    using SafeMath for uint256;

    uint256 public totalCloverFieldCarbon = 330; // 33% for total Clover Field
    uint256 public totalCloverFieldPearl = 330; // 33% for total Clover Field
    uint256 public totalCloverFieldRuby = 330; // 33% for total Clover Field
    uint256 public totalCloverFieldDiamond = 10; // 1% for total Clover Field

    uint256 public totalCloverYardCarbon = 3300; // 33% for total Clover Yard
    uint256 public totalCloverYardPearl = 3300; // 33% for total Clover Yard
    uint256 public totalCloverYardRuby = 3300; // 33% for total Clover Yard
    uint256 public totalCloverYardDiamond = 100; // 1% for total Clover Yard

    uint256 public totalCloverPotCarbon = 33000; // 33% for total Clover Pot
    uint256 public totalCloverPotPearl = 33000; // 33% for total Clover Pot
    uint256 public totalCloverPotRuby = 33000; // 33% for total Clover Pot
    uint256 public totalCloverPotDiamond = 1000; // 1% for total Clover Pot

    uint256 public totalCloverFieldCarbonMinted;
    uint256 public totalCloverFieldPearlMinted;
    uint256 public totalCloverFieldRubyMinted;
    uint256 public totalCloverFieldDiamondMinted;

    uint256 public totalCloverYardCarbonMinted;
    uint256 public totalCloverYardPearlMinted;
    uint256 public totalCloverYardRubyMinted;
    uint256 public totalCloverYardDiamondMinted;

    uint256 public totalCloverPotCarbonMinted;
    uint256 public totalCloverPotPearlMinted;
    uint256 public totalCloverPotRubyMinted;
    uint256 public totalCloverPotDiamondMinted;

    uint256[] private layersCarbon;
    uint256[] private layersPearl;
    uint256[] private layersRuby;

    address public Clover_Seeds_Controller;
    address public Clover_Seeds_NFT_Token;

    string private _baseURIFieldCarbon;
    string private _baseURIFieldPearl;
    string private _baseURIFieldRuby;
    string private _baseURIFieldDiamond;
    string private _baseURIYardCarbon;
    string private _baseURIYardPearl;
    string private _baseURIYardRuby;
    string private _baseURIYardDiamond;
    string private _baseURIPotCarbon;
    string private _baseURIPotPearl;
    string private _baseURIPotRuby;
    string private _baseURIPotDiamond;

    constructor(address _Seeds_NFT_Token, address _Clover_Seeds_Controller) {
        Clover_Seeds_Controller = _Clover_Seeds_Controller;
        Clover_Seeds_NFT_Token = _Seeds_NFT_Token;
    }

    function setBaseURIFieldCarbon(string calldata _uri) public {
        _baseURIFieldCarbon = _uri;
    }
    function setBaseURIFieldPearl(string calldata _uri) public {
        _baseURIFieldPearl = _uri;
    }
    function setBaseURIFieldRuby(string calldata _uri) public {
        _baseURIFieldRuby = _uri;
    }
    function setBaseURIFieldDiamond(string calldata _uri) public {
        _baseURIFieldDiamond = _uri;
    }

    function setBaseURIYardCarbon(string calldata _uri) public {
        _baseURIYardCarbon = _uri;
    }
    function setBaseURIYardPearl(string calldata _uri) public {
        _baseURIYardPearl = _uri;
    }
    function setBaseURIYardRuby(string calldata _uri) public {
        _baseURIYardRuby = _uri;
    }
    function setBaseURIYardDiamond(string calldata _uri) public {
        _baseURIYardDiamond = _uri;
    }
    function setBaseURIPotCarbon(string calldata _uri) public {
        _baseURIPotCarbon = _uri;
    }
    function setBaseURIPotPearl(string calldata _uri) public {
        _baseURIPotPearl = _uri;
    }
     function setBaseURIPotRuby(string calldata _uri) public {
        _baseURIPotRuby = _uri;
    }
     function setBaseURIPotDiamond(string calldata _uri) public {
        _baseURIPotDiamond = _uri;
    }


    function randomNumber(uint256 seed) public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
            tx.origin,
            block.difficulty,
            blockhash(block.number - 1), 
            block.timestamp, 
            seed
            )));
    }

    function random(uint seed) public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(tx.origin, blockhash(block.number), block.timestamp, seed)));
    }

    function setSeeds_NFT_Token(address _Seeds_NFT_Token) public onlyOwner {
        Clover_Seeds_NFT_Token = _Seeds_NFT_Token;
    }

    function setClover_Seeds_Controller(address _Clover_Seeds_Controller) public onlyOwner {
        Clover_Seeds_Controller = _Clover_Seeds_Controller;
    }

    function randomLayer(uint256 tokenId) public returns (bool) {
        require(msg.sender == Clover_Seeds_NFT_Token, "Clover_Seeds_Picker: You are not Clover_Seeds_NFT_Token..");
        
        uint256 index = random(tokenId);
        uint8 num = uint8(index % 100);
        if (tokenId <= 1e3) {
            if (totalCloverFieldDiamondMinted == totalCloverFieldDiamond) {
                num = uint8(num % 99) + 1;
            }
            if (totalCloverFieldCarbonMinted == totalCloverFieldCarbon) {
                num = uint8(num % 67);
                if (num >= 1 && num <= 33) {
                    num += 66;
                }
            }
            if (totalCloverFieldPearlMinted == totalCloverFieldPearl) {
                num = uint8(num % 67);
                if (num >= 34 && num <= 66) {
                    num += 33;
                }
            }
            if (totalCloverFieldRubyMinted == totalCloverFieldRuby) {
                num = uint8(num % 67);
            }

            string memory uri;
            if (num == 0) {
                totalCloverFieldDiamondMinted++;
                uri = string(abi.encodePacked(_baseURIFieldDiamond, Strings.toString(totalCloverFieldDiamondMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverFieldDiamond(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverFieldDiamond..");
            }
            if (num >= 1 && num <= 33) {
                totalCloverFieldCarbonMinted++;
                uri = string(abi.encodePacked(_baseURIFieldCarbon, Strings.toString(totalCloverFieldCarbonMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverFieldCarbon(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverFieldCarbon..");
            }
            if (num >= 34 && num <= 66) {
                totalCloverFieldPearlMinted++;
                uri = string(abi.encodePacked(_baseURIFieldPearl, Strings.toString(totalCloverFieldPearlMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverFieldPearl(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverFieldPearl..");
            }
            if (num >= 67 && num <= 99) {
                totalCloverFieldRubyMinted++;
                uri = string(abi.encodePacked(_baseURIFieldRuby, Strings.toString(totalCloverFieldRubyMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverFieldRuby(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverFieldRuby..");
            }
            IContract(Clover_Seeds_NFT_Token).setTokenURI(tokenId, uri);

        } else if (tokenId <= 11e3) {
            if (totalCloverYardDiamondMinted == totalCloverYardDiamond) {
                num = uint8(num % 99) + 1;
            }
            if (totalCloverYardCarbonMinted == totalCloverYardCarbon) {
                num = uint8(num % 67);
                if (num >= 1 && num <= 33) {
                    num += 66;
                }
            }
            if (totalCloverYardPearlMinted == totalCloverYardPearl) {
                num = uint8(num % 67);
                if (num >= 34 && num <= 66) {
                    num += 33;
                }
            }
            if (totalCloverYardRubyMinted == totalCloverYardRuby) {
                num = uint8(num % 67);
            }

            string memory uri;
            if (num == 0) {
                totalCloverYardDiamondMinted++;
                uri = string(abi.encodePacked(_baseURIYardDiamond, Strings.toString(totalCloverYardDiamondMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverYardDiamond(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverYardDiamond..");
            }
            if (num >= 1 && num <= 33) {
                totalCloverYardCarbonMinted++;
                uri = string(abi.encodePacked(_baseURIYardCarbon, Strings.toString(totalCloverYardCarbonMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverYardCarbon(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverYardCarbon..");
            }
            if (num >= 34 && num <= 66) {
                totalCloverYardPearlMinted++;
                uri = string(abi.encodePacked(_baseURIYardPearl, Strings.toString(totalCloverYardPearlMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverYardPearl(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverYardPearl..");
            }
            if (num >= 67 && num <= 99) {
                totalCloverYardRubyMinted++;
                uri = string(abi.encodePacked(_baseURIYardRuby, Strings.toString(totalCloverYardRubyMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverYardRuby(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverYardRuby..");
            }

            IContract(Clover_Seeds_NFT_Token).setTokenURI(tokenId, uri);
        } else {
            if (totalCloverPotDiamondMinted == totalCloverPotDiamond) {
                num = uint8(num % 99) + 1;
            }
            if (totalCloverPotCarbonMinted == totalCloverPotCarbon) {
                num = uint8(num % 67);
                if (num >= 1 && num <= 33) {
                    num += 66;
                }
            }
            if (totalCloverPotPearlMinted == totalCloverPotPearl) {
                num = uint8(num % 67);
                if (num >= 34 && num <= 66) {
                    num += 33;
                }
            }
            if (totalCloverPotRubyMinted == totalCloverPotRuby) {
                num = uint8(num % 67);
            }

            string memory uri;
            if (num == 0) {
                totalCloverPotDiamondMinted++;
                uri = string(abi.encodePacked(_baseURIPotDiamond, Strings.toString(totalCloverPotDiamondMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverPotDiamond(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverPotDiamond..");
            }
            if (num >= 1 && num <= 33) {
                totalCloverPotCarbonMinted++;
                uri = string(abi.encodePacked(_baseURIPotCarbon, Strings.toString(totalCloverPotCarbonMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverPotCarbon(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverPotCarbon..");
            }
            if (num >= 34 && num <= 66) {
                totalCloverPotPearlMinted++;
                uri = string(abi.encodePacked(_baseURIPotPearl, Strings.toString(totalCloverPotPearlMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverPotPearl(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverPotPearl..");
            }
            if (num >= 67 && num <= 99) {
                totalCloverPotRubyMinted++;
                uri = string(abi.encodePacked(_baseURIPotRuby, Strings.toString(totalCloverPotRubyMinted)));
                require(IContract(Clover_Seeds_Controller).addAsCloverPotRuby(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverPotRuby..");
            }
            IContract(Clover_Seeds_NFT_Token).setTokenURI(tokenId, uri);
        }
        return true;
    }
    
    // function to allow admin to transfer *any* BEP20 tokens from this contract..
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "SEED$ Picker: amount must be greater than 0");
        require(recipient != address(0), "SEED$ Picker: recipient is the zero address");
        IContract(tokenAddress).transfer(recipient, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
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

pragma solidity 0.8.11;

// SPDX-License-Identifier: MIT

interface IContract {
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function mint(address, uint256) external;
    function Approve(address, uint256) external returns (bool);
    function AddFeeS(uint256, uint256, uint256) external returns (bool);
    function addAsNFTBuyer(address) external returns (bool);
    function addMintedTokenId(uint256) external returns (bool);
    function addAsCloverFieldCarbon(uint256) external returns (bool);
    function addAsCloverFieldPearl(uint256) external returns (bool);
    function addAsCloverFieldRuby(uint256) external returns (bool);
    function addAsCloverFieldDiamond(uint256) external returns (bool);
    function addAsCloverYardCarbon(uint256) external returns (bool);
    function addAsCloverYardPearl(uint256) external returns (bool);
    function addAsCloverYardRuby(uint256) external returns (bool);
    function addAsCloverYardDiamond(uint256) external returns (bool);
    function addAsCloverPotCarbon(uint256) external returns (bool);
    function addAsCloverPotPearl(uint256) external returns (bool);
    function addAsCloverPotRuby(uint256) external returns (bool);
    function addAsCloverPotDiamond(uint256) external returns (bool);
    function randomLayer(uint256) external returns (bool);
    function randomNumber(uint256) external returns (uint256);
    function safeTransferFrom(address, address, uint256) external;
    function setApprovalForAll_(address) external;
    function isCloverFieldCarbon_(uint256) external returns (bool);
    function isCloverFieldPearl_(uint256) external returns (bool);
    function isCloverFieldRuby_(uint256) external returns (bool);
    function isCloverFieldDiamond_(uint256) external returns (bool);
    function isCloverYardCarbon_(uint256) external returns (bool);
    function isCloverYardPearl_(uint256) external returns (bool);
    function isCloverYardRuby_(uint256) external returns (bool);
    function isCloverYardDiamond_(uint256) external returns (bool);
    function isCloverPotCarbon_(uint256) external returns (bool);
    function isCloverPotPearl_(uint256) external returns (bool);
    function isCloverPotRuby_(uint256) external returns (bool);
    function isCloverPotDiamond_(uint256) external returns (bool);
    function getLuckyWalletForCloverField() external returns (address);
    function getLuckyWalletForCloverYard() external returns (address);
    function getLuckyWalletForCloverPot() external returns (address);
    function setTokenURI(uint256, string memory) external;
    function getCSNFTsByOwner(address) external returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}