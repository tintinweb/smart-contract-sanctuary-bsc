pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./Ownable.sol";
import "./IContract.sol";
import "./SafeMath.sol";
import "./Strings.sol";

contract CloverDarkSeedPicker is Ownable {
    using SafeMath for uint256;

    uint16 public totalCloverFieldCarbon = 494; // 49.4% for total Clover Field
    uint16 public totalCloverFieldPearl = 494; // 49.4% for total Clover Field
    uint16 public totalCloverFieldRuby = 10; // 1% for total Clover Field
    uint16 public totalCloverFieldDiamond = 2; // 0.2% for total Clover Field

    uint16 public totalCloverYardCarbon = 4940; // 33% for total Clover Yard
    uint16 public totalCloverYardPearl = 4940; // 33% for total Clover Yard
    uint16 public totalCloverYardRuby = 100; // 33% for total Clover Yard
    uint16 public totalCloverYardDiamond = 20; // 1% for total Clover Yard

    uint16 public totalCloverPotCarbon = 49400; // 33% for total Clover Pot
    uint16 public totalCloverPotPearl = 49400; // 33% for total Clover Pot
    uint16 public totalCloverPotRuby = 1000; // 33% for total Clover Pot
    uint16 public totalCloverPotDiamond = 200; // 1% for total Clover Pot

    uint16 public totalCloverFieldCarbonMinted;
    uint16 public totalCloverFieldPearlMinted;
    uint16 public totalCloverFieldRubyMinted;
    uint16 public totalCloverFieldDiamondMinted;

    uint16 public totalCloverYardCarbonMinted;
    uint16 public totalCloverYardPearlMinted;
    uint16 public totalCloverYardRubyMinted;
    uint16 public totalCloverYardDiamondMinted;

    uint24 public totalCloverPotCarbonMinted;
    uint24 public totalCloverPotPearlMinted;
    uint24 public totalCloverPotRubyMinted;
    uint24 public totalCloverPotDiamondMinted;

    address public DarkSeedController;
    address public DarkSeedNFT;

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

    uint256 private rand;

    constructor(address _Seeds_NFT_Token, address _DarkSeedController) {
        DarkSeedController = _DarkSeedController;
        DarkSeedNFT = _Seeds_NFT_Token;
    }

    function setBaseURIFieldCarbon(string calldata _uri) public onlyOwner {
        _baseURIFieldCarbon = _uri;
    }
    function setBaseURIFieldPearl(string calldata _uri) public onlyOwner {
        _baseURIFieldPearl = _uri;
    }
    function setBaseURIFieldRuby(string calldata _uri) public onlyOwner {
        _baseURIFieldRuby = _uri;
    }
    function setBaseURIFieldDiamond(string calldata _uri) public onlyOwner {
        _baseURIFieldDiamond = _uri;
    }
    function setBaseURIYardCarbon(string calldata _uri) public onlyOwner {
        _baseURIYardCarbon = _uri;
    }
    function setBaseURIYardPearl(string calldata _uri) public onlyOwner {
        _baseURIYardPearl = _uri;
    }
    function setBaseURIYardRuby(string calldata _uri) public onlyOwner {
        _baseURIYardRuby = _uri;
    }
    function setBaseURIYardDiamond(string calldata _uri) public onlyOwner {
        _baseURIYardDiamond = _uri;
    }
    function setBaseURIPotCarbon(string calldata _uri) public onlyOwner {
        _baseURIPotCarbon = _uri;
    }
    function setBaseURIPotPearl(string calldata _uri) public onlyOwner {
        _baseURIPotPearl = _uri;
    }
     function setBaseURIPotRuby(string calldata _uri) public onlyOwner {
        _baseURIPotRuby = _uri;
    }
     function setBaseURIPotDiamond(string calldata _uri) public onlyOwner {
        _baseURIPotDiamond = _uri;
    }

    function randomNumber(uint256 entropy) public returns (uint256) {
        rand = uint256(keccak256(abi.encodePacked(
            block.difficulty,
            block.timestamp,
            entropy
        )));
        return rand;
    }

    function setSeeds_NFT_Token(address _Seeds_NFT_Token) public onlyOwner {
        DarkSeedNFT = _Seeds_NFT_Token;
    }

    function setDarkSeedController(address _DarkSeedController) public onlyOwner {
        DarkSeedController = _DarkSeedController;
    }

    function randomLayer(uint256 tokenId) public returns (bool) {
        require(msg.sender == DarkSeedNFT, "Clover_Seeds_Picker: You are not CloverDarkSeedNFT..");
        
        uint16 num = uint16((rand >> 16) % 1000);
        if (tokenId <= 1e3) {
            if (totalCloverFieldDiamondMinted == totalCloverFieldDiamond) {
                num = num % 998 + 2;
            }
            if (totalCloverFieldCarbonMinted == totalCloverFieldCarbon) {
                num = num % 506;
                if (num >= 2 && num <= 495) {
                    num += 504;
                }
            }
            if (totalCloverFieldPearlMinted == totalCloverFieldPearl) {
                num = num % 506;
                if (num >= 496 && num <= 505) {
                    num += 494;
                }
            }
            if (totalCloverFieldRubyMinted == totalCloverFieldRuby) {
                num = num % 990;
            }

            string memory uri;
            if (num >= 0 && num <= 1) {
                totalCloverFieldDiamondMinted++;
                uri = string(abi.encodePacked(_baseURIFieldDiamond, Strings.toString(totalCloverFieldDiamondMinted)));
                require(IContract(DarkSeedController).addAsCloverFieldDiamond(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverFieldDiamond..");
            }
            if (num >= 2 && num <= 495) {
                totalCloverFieldCarbonMinted++;
                uri = string(abi.encodePacked(_baseURIFieldCarbon, Strings.toString(totalCloverFieldCarbonMinted)));
                require(IContract(DarkSeedController).addAsCloverFieldCarbon(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverFieldCarbon..");
            }
            if (num >= 496 && num <= 989) {
                totalCloverFieldPearlMinted++;
                uri = string(abi.encodePacked(_baseURIFieldPearl, Strings.toString(totalCloverFieldPearlMinted)));
                require(IContract(DarkSeedController).addAsCloverFieldPearl(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverFieldPearl..");
            }
            if (num >= 990 && num <= 999) {
                totalCloverFieldRubyMinted++;
                uri = string(abi.encodePacked(_baseURIFieldRuby, Strings.toString(totalCloverFieldRubyMinted)));
                require(IContract(DarkSeedController).addAsCloverFieldRuby(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverFieldRuby..");
            }
            IContract(DarkSeedNFT).setTokenURI(tokenId, uri);

        } else if (tokenId <= 11e3) {
            if (totalCloverYardDiamondMinted == totalCloverYardDiamond) {
                num = num % 998 + 2;
            }
            if (totalCloverYardCarbonMinted == totalCloverYardCarbon) {
                num = num % 506;
                if (num >= 2 && num <= 495) {
                    num += 504;
                }
            }
            if (totalCloverYardPearlMinted == totalCloverYardPearl) {
                num = num % 506;
                if (num >= 495 && num <= 505) {
                    num += 494;
                }
            }
            if (totalCloverYardRubyMinted == totalCloverYardRuby) {
                num = num % 990;
            }

            string memory uri;
            if (num >= 0 && num <= 1) {
                totalCloverYardDiamondMinted++;
                uri = string(abi.encodePacked(_baseURIYardDiamond, Strings.toString(totalCloverYardDiamondMinted)));
                require(IContract(DarkSeedController).addAsCloverYardDiamond(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverYardDiamond..");
            }
            if (num >= 2 && num <= 495) {
                totalCloverYardCarbonMinted++;
                uri = string(abi.encodePacked(_baseURIYardCarbon, Strings.toString(totalCloverYardCarbonMinted)));
                require(IContract(DarkSeedController).addAsCloverYardCarbon(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverYardCarbon..");
            }
            if (num >= 496 && num <= 989) {
                totalCloverYardPearlMinted++;
                uri = string(abi.encodePacked(_baseURIYardPearl, Strings.toString(totalCloverYardPearlMinted)));
                require(IContract(DarkSeedController).addAsCloverYardPearl(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverYardPearl..");
            }
            if (num >= 990 && num <= 999) {
                totalCloverYardRubyMinted++;
                uri = string(abi.encodePacked(_baseURIYardRuby, Strings.toString(totalCloverYardRubyMinted)));
                require(IContract(DarkSeedController).addAsCloverYardRuby(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverYardRuby..");
            }

            IContract(DarkSeedNFT).setTokenURI(tokenId, uri);

        } else {
            if (totalCloverPotDiamondMinted == totalCloverPotDiamond) {
                num = num % 998 + 2;
            }
            if (totalCloverPotCarbonMinted == totalCloverPotCarbon) {
                num = num % 506;
                if (num >= 2 && num <= 495) {
                    num += 504;
                }
            }
            if (totalCloverPotPearlMinted == totalCloverPotPearl) {
                num = num % 506;
                if (num >= 496 && num <= 505) {
                    num += 494;
                }
            }
            if (totalCloverPotRubyMinted == totalCloverPotRuby) {
                num = num % 990;
            }

            string memory uri;
            if (num >= 0 && num <= 1) {
                totalCloverPotDiamondMinted++;
                uri = string(abi.encodePacked(_baseURIPotDiamond, Strings.toString(totalCloverPotDiamondMinted)));
                require(IContract(DarkSeedController).addAsCloverPotDiamond(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverPotDiamond..");
            }
            if (num >= 2 && num <= 495) {
                totalCloverPotCarbonMinted++;
                uri = string(abi.encodePacked(_baseURIPotCarbon, Strings.toString(totalCloverPotCarbonMinted)));
                require(IContract(DarkSeedController).addAsCloverPotCarbon(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverPotCarbon..");
            }
            if (num >= 496 && num <= 989) {
                totalCloverPotPearlMinted++;
                uri = string(abi.encodePacked(_baseURIPotPearl, Strings.toString(totalCloverPotPearlMinted)));
                require(IContract(DarkSeedController).addAsCloverPotPearl(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverPotPearl..");
            }
            if (num >= 990 && num <= 999) {
                totalCloverPotRubyMinted++;
                uri = string(abi.encodePacked(_baseURIPotRuby, Strings.toString(totalCloverPotRubyMinted)));
                require(IContract(DarkSeedController).addAsCloverPotRuby(tokenId), "Clover_Seeds_Picker: Unable to call addAsCloverPotRuby..");
            }
            IContract(DarkSeedNFT).setTokenURI(tokenId, uri);
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

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./Context.sol";

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

interface IContract {
    function balanceOf(address) external returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function mint(address, uint256) external;
    function Approve(address, uint256) external returns (bool);
    function sendToken2Account(address, uint256) external returns(bool);
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
    function tokenURI(uint256) external view returns (string memory);
    function getCSNFTsByOwner(address) external returns (uint256[] memory);
    //functions for potion
    function burn(address, bool) external;
    //function for token
    function burnForNFT(uint256) external;
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/OpenZeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

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

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

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
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}