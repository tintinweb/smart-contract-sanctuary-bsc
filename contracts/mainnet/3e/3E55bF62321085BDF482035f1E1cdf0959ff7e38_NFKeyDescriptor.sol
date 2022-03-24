// SPDX-License-Identifier: MIT

/// @title The Keys NFT descriptor

pragma solidity ^0.8.12;

import { Operable } from "./extensions/Operable.sol";
import { NFTDescriptor } from "./libs/NFTDescriptor.sol";
import { MultiPartRLEToSVG } from "./libs/MultiPartRLEToSVG64.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IKeysDescriptor } from "./interfaces/IKeysDescriptor.sol";

contract NFKeyDescriptor is Operable {
	struct Trait {
		uint256 id;
		string name;
    uint256 pair;
    bool label;    
	}

	// Whether or not new Keys parts can be added
	bool public partsLocked;
	string public baseURI;

	// Keys Color Palettes (Index => Hex Colors)
	mapping(uint8 => string[]) public palettes;

	string[] public backgroundColors;
	string[] public backgroundNames;

  bytes public emptyLayer;

	// 0 - head
	// 1 - body
	// 2 - label
	// 3 - access
	mapping(uint256 => IKeysDescriptor.Layer[]) public layers;
  mapping(uint256 => bool) public headLabels;

	// ------------------------------ BACKGROUNDS --------------------------------
	function backgroundsCount() public view returns (uint256) {
		return backgroundNames.length;
	}

	//
	function addBackgrounds(string[] memory namesArr, string[] memory colorsArr) external onlyOwner whenPartsNotLocked {
		require(namesArr.length == colorsArr.length);
		for (uint256 i = 0; i < namesArr.length; i++) {
			backgroundNames.push(namesArr[i]);
			backgroundColors.push(colorsArr[i]);
		}
	}

  //
	function setEmptyLayer(
		bytes memory image		
	) external onlyOwner whenPartsNotLocked {
		emptyLayer = image;
	}

	//
	function setBackground(
		uint256 idx,
		string memory name,
		string memory color
	) external onlyOwner whenPartsNotLocked {
		require(idx < backgroundsCount());
		backgroundNames[idx] = name;
		backgroundColors[idx] = color;
	}

	//
	function backgroundsList(uint256 startIdx, uint256 endIdx) public view returns (Trait[] memory) {
		require(startIdx < backgroundsCount(), "startIdx");
		require(endIdx < backgroundsCount(), "endIdx");
		require(startIdx <= endIdx, "startIdx <= endIdx");

		if (startIdx == endIdx) {
			Trait[] memory list = new Trait[](1);
			list[0] = Trait(startIdx, backgroundNames[startIdx], 0, false);
			return list;
		} else {
			Trait[] memory list = new Trait[](endIdx - startIdx + 1);
			uint256 idx;
			for (uint256 index = startIdx; index <= endIdx; index++) {
				list[idx] = Trait(index, backgroundNames[index], 0, false);
				idx++;
			}
			return list;
		}
	}

	// ------------------------------ LAYERS --------------------------------
	function layersCount(uint256 layerIdx) public view layerIdxCorrect(layerIdx) returns (uint256) {
		return layers[layerIdx].length;
	}

	//
	modifier layerIdxCorrect(uint256 layerIdx) {
		require(layerIdx <= 4);
		_;
	}

	//
	function addLayers(
		uint256 layerIdx,
		string[] memory nameArr,
		bytes[] memory imageArr,
    uint256[] memory pairArr,		
		bool[] memory labelArr
    
	) external onlyOwner whenPartsNotLocked {
		require(nameArr.length == imageArr.length, "nameArr == imageArr");
    require(nameArr.length == pairArr.length, "nameArr == pairArr");	
		require(nameArr.length == labelArr.length, "nameArr == labelArr");	
    
		for (uint256 i = 0; i < nameArr.length; i++) {
			layers[layerIdx].push(IKeysDescriptor.Layer({ 
        name: nameArr[i], 
        image: imageArr[i],
        pair: pairArr[i],
        label: labelArr[i]
      }));
		}
	}

	//
	function setLayers(
		uint256 layerIdx,
		uint256[] memory idxArr,
		string[] memory nameArr,
		bytes[] memory imageArr,
    uint256[] memory pairArr,
		bool[] memory labelArr,
		uint8 setType // 0- all 1-name 2-image 2-pair 3-label
	) external onlyOwner whenPartsNotLocked layerIdxCorrect(layerIdx) {
		require(setType <= 3);  
    require(idxArr.length == nameArr.length, "idxArr == nameArr");  
    require(idxArr.length == imageArr.length, "idxArr == imageArr");
    require(idxArr.length == pairArr.length, "idxArr == pairArr");
		require(idxArr.length == labelArr.length, "idxArr == labelArr");
    
    for (uint256 i = 0; i < idxArr.length; i++) {
			require(idxArr[i] < layersCount(layerIdx), "idx");
			if (setType == 0) {
				layers[layerIdx][idxArr[i]].name = nameArr[i];
				layers[layerIdx][idxArr[i]].image = imageArr[i];	
        layers[layerIdx][idxArr[i]].pair = pairArr[i];
        layers[layerIdx][idxArr[i]].label = labelArr[i];               		
			} else if (setType == 1) {
				layers[layerIdx][idxArr[i]].name = nameArr[i];
			} else if (setType == 2) {
				layers[layerIdx][idxArr[i]].image = imageArr[i];
			} else if (setType == 3) {
				layers[layerIdx][idxArr[i]].pair = pairArr[i];
			} else if (setType == 4) {
				layers[layerIdx][idxArr[i]].label = labelArr[i];
			} 
		}
	}

	//
	function layersList(
		uint256 layerIdx,
		uint256 startIdx,
		uint256 endIdx
	) public view layerIdxCorrect(layerIdx) returns (Trait[] memory) {
		require(startIdx < layersCount(layerIdx), "startIdx");
		require(endIdx < layersCount(layerIdx), "endIdx");
		require(startIdx <= endIdx, "startIdx <= endIdx");

		if (startIdx == endIdx) {
			Trait[] memory list = new Trait[](1);
			list[0] = Trait(startIdx, layers[layerIdx][startIdx].name, layers[layerIdx][startIdx].pair, layers[layerIdx][startIdx].label);
			return list;
		} else {
			Trait[] memory list = new Trait[](endIdx - startIdx + 1);
			uint256 idx;
			for (uint256 index = startIdx; index <= endIdx; index++) {
				list[idx] = Trait(index, layers[layerIdx][index].name, layers[layerIdx][index].pair, layers[layerIdx][index].label);
				idx++;
			}
			return list;
		}
	}

	function addColorsToPalette(uint8 paletteIndex, string[] calldata colorsArr) external onlyOwner {
		require(palettes[paletteIndex].length + colorsArr.length <= 256);
		for (uint256 i = 0; i < colorsArr.length; i++) {
			palettes[paletteIndex].push(colorsArr[i]);
		}
	}

	function lockParts() external onlyOwner whenPartsNotLocked {
		partsLocked = true;
		emit PartsLocked();
	}

	function setBaseURI(string calldata newBaseURI) external onlyOwner {
		baseURI = newBaseURI;
		emit BaseURIUpdated(newBaseURI);
	}

	function tokenURI(uint256 tokenId, IKeysDescriptor.Key memory key) external view returns (string memory) {
		return dataURI(tokenId, key);
	}

	function dataURI(uint256 tokenId, IKeysDescriptor.Key memory key) public view returns (string memory) {
		NFTDescriptor.TokenURIParams memory params = NFTDescriptor.TokenURIParams({
			tokenId: tokenId,
			parts: getPartsForKey(key),
			backgroundName: backgroundNames[key.background],
			backgroundColor: backgroundColors[key.background],			
      accessId: key.access,
			head: layers[0][key.head],
			body: layers[1][key.body],
			label: layers[2][key.label],
			access: layers[3][key.access]      
		});
		return NFTDescriptor.constructTokenURI(params, palettes);
	}

	function generateSVGImage(IKeysDescriptor.Key memory key) external view returns (string memory) {
		MultiPartRLEToSVG.SVGParams memory params = MultiPartRLEToSVG.SVGParams({ parts: getPartsForKey(key), background: backgroundColors[key.background] });
		return NFTDescriptor.generateSVGImage(params, palettes);
	}

	function getKeyAccess(IKeysDescriptor.Key memory key) public view returns (uint48 id, string memory name) {
		id = key.access;
		name = layers[3][key.access].name;
	}

	function getPartsForKey(IKeysDescriptor.Key memory key) public view returns (bytes[] memory) {
		bytes[] memory parts = new bytes[](4);
		parts[0] = layers[0][key.head].image;
		parts[1] = layers[1][key.body].image;
		
    if (layers[0][key.head].label) {
			parts[2] = layers[2][key.label].image;
		} else {
			parts[2] = emptyLayer;
		}

		parts[3] = layers[3][key.access].image;

		return parts;
	}

	//// Added to support recovering
	function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOperator {
		IERC20(tokenAddress).transfer(_msgSender(), tokenAmount);
	}

	modifier whenPartsNotLocked() {
		require(!partsLocked);
		_;
	}

	event PartsLocked();
	event DataURIToggled(bool enabled);
	event BaseURIUpdated(string baseURI);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';

abstract contract Operable is Ownable {
	mapping(address => bool) public operators;
	address[] public operatorsList;

	constructor() {
		setOperator(_msgSender(), true);
	}

	function setOperator(address operator, bool state) public onlyOwner {
		operators[operator] = state;
		if (state) {
			operatorsList.push(operator);
		}
		emit OperatorSet(operator, state);
	}

	function operatorsCount() public view returns (uint256) {
		return operatorsList.length;
	}

	modifier onlyOperator() {
		require(operators[_msgSender()] || _msgSender() == owner(), "Sender is not the operator or owner");
		_;
	}
	event OperatorSet(address operator, bool state);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import { Base64 } from './Base64.sol';
import { MultiPartRLEToSVG } from './MultiPartRLEToSVG64.sol';
import { Strings } from '@openzeppelin/contracts/utils/Strings.sol';
import { IKeysDescriptor } from './../interfaces/IKeysDescriptor.sol';

library NFTDescriptor {
  using Strings for uint256;
  using Strings for uint48;

	struct TokenURIParams {
    uint256 tokenId;		
    bytes[] parts;
    string backgroundColor;
    string backgroundName;
    uint48 accessId;
    IKeysDescriptor.Layer head;
    IKeysDescriptor.Layer body;
    IKeysDescriptor.Layer label;
    IKeysDescriptor.Layer access;    
	}

	// prettier-ignore
	function constructTokenURI(TokenURIParams memory params, mapping(uint8 => string[]) storage palettes) public view returns (string memory) {
		string memory keyId = params.tokenId.toString();
    string memory name = string(abi.encodePacked("NFKey #", keyId));
    string memory description = string(abi.encodePacked("NFKey #", keyId, " provides access to ", params.access.name, " utilities, and is a member of the STEM DAO"));
    string memory label = params.label.name;
    
    uint256 rarityPoins;
    if (params.accessId == 0) rarityPoins++; 
    if (params.head.pair != 0 && params.head.pair == params.body.pair) rarityPoins++;  
    
    if (!params.head.label) {
      label = 'None';
      rarityPoins += 2;  
    } else if (params.head.pair != 0 && params.head.pair == params.label.pair) {
      rarityPoins++;
    }  

    string memory rarity = '';
    if (rarityPoins == 0) {
      rarity = 'Common';
    } else if (rarityPoins == 1) {
      rarity = 'Uncommon';
    } else if (rarityPoins == 2) {
      rarity = 'Rare';
    } else if (rarityPoins == 3) {
      rarity = 'Very Rare';
    } else if (rarityPoins == 4) {
      rarity = 'Ultra Rare';
    }
		    
    string memory attributes = string(
			abi.encodePacked(
				'"attributes":[',
				'{"trait_type":"Access","value":"',
				params.access.name,
        '"},{"trait_type":"Rarity","value":"',
				rarity,
				'"},{"trait_type":"Background","value":"',
				params.backgroundName,
				'"},{"trait_type":"Head","value":"',
				params.head.name,
				'"},{"trait_type":"Body","value":"',
				params.body.name,
				'"},{"trait_type":"Label","value":"',
				label,
				'"}]}'
			)
		);

    string memory image = generateSVGImage(MultiPartRLEToSVG.SVGParams({ parts: params.parts, background: params.backgroundColor }), palettes);

		return string(
			abi.encodePacked(
				"data:application/json;base64,", 
				Base64.encode(
					bytes(abi.encodePacked(
						'{"name":"', 
						name, 
						'","description":"', 
						description, 
            '","access":"', 
						params.accessId.toString(),
            '","access":"', 
						params.accessId.toString(),
						'","image":"data:image/svg+xml;base64,', 
						image, 
						'",', 
						attributes)
					)
				)
			)
		);
	}

	function generateSVGImage(MultiPartRLEToSVG.SVGParams memory params, mapping(uint8 => string[]) storage palettes) public view returns (string memory svg) {
		return Base64.encode(bytes(MultiPartRLEToSVG.generateSVG(params, palettes)));
	}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

library MultiPartRLEToSVG {
	struct SVGParams {
		bytes[] parts;
		string background;
	}

	struct ContentBounds {
		uint8 top;
		uint8 right;
		uint8 bottom;
		uint8 left;
	}

	struct Rect {
		uint8 length;
		uint8 colorIndex;
	}

	struct DecodedImage {
		uint8 paletteIndex;
		ContentBounds bounds;
		uint256 width;
		Rect[] rects;
	}

	function generateSVG(SVGParams memory params, mapping(uint8 => string[]) storage palettes) internal view returns (string memory svg) {
		// prettier-ignore
		return string(
            abi.encodePacked(
                '<svg width="320" height="320" viewBox="0 0 640 640" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges">',
                '<rect width="100%" height="100%" fill="#', params.background, '" />',
                _generateSVGRects(params, palettes),
                '</svg>'
            )
        );
	}

	// prettier-ignore
	function _generateSVGRects(SVGParams memory params, mapping(uint8 => string[]) storage palettes)
        private
        view
        returns (string memory svg)
    {
        string[65] memory lookup = [
            '0', '10', '20', '30', '40', '50', '60', '70', 
            '80', '90', '100', '110', '120', '130', '140', '150', 
            '160', '170', '180', '190', '200', '210', '220', '230', 
            '240', '250', '260', '270', '280', '290', '300', '310',
            '320', '330', '340', '350', '360', '370', '380', '390',
            '400', '410', '420', '430', '440', '450', '460', '470',
            '480', '490', '500', '510', '520', '530', '540', '550',
            '560', '570', '580', '590', '600', '610', '620', '630',
            '640'
        ];
        string memory rects;
        for (uint8 p = 0; p < params.parts.length; p++) {
            DecodedImage memory image = _decodeRLEImage(params.parts[p]);
            string[] storage palette = palettes[image.paletteIndex];
            uint256 currentX = image.bounds.left;
            uint256 currentY = image.bounds.top;
            uint256 cursor;
            string[16] memory buffer;

            string memory part;
            for (uint256 i = 0; i < image.rects.length; i++) {
                Rect memory rect = image.rects[i];
                if (rect.colorIndex != 0) {
                    buffer[cursor] = lookup[rect.length];          // width
                    buffer[cursor + 1] = lookup[currentX];         // x
                    buffer[cursor + 2] = lookup[currentY];         // y
                    buffer[cursor + 3] = palette[rect.colorIndex]; // color

                    cursor += 4;

                    if (cursor >= 16) {
                        part = string(abi.encodePacked(part, _getChunk(cursor, buffer)));
                        cursor = 0;
                    }
                }

                currentX += rect.length;
                if (currentX - image.bounds.left == image.width) {
                    currentX = image.bounds.left;
                    currentY++;
                }
            }

            if (cursor != 0) {
                part = string(abi.encodePacked(part, _getChunk(cursor, buffer)));
            }
            rects = string(abi.encodePacked(rects, part));
        }
        return rects;
    }

	// prettier-ignore
	function _getChunk(uint256 cursor, string[16] memory buffer) private pure returns (string memory) {
        string memory chunk;
        for (uint256 i = 0; i < cursor; i += 4) {
            chunk = string(
                abi.encodePacked(
                    chunk,
                    '<rect width="', buffer[i], '" height="10" x="', buffer[i + 1], '" y="', buffer[i + 2], '" fill="#', buffer[i + 3], '" />'
                )
            );
        }
        return chunk;
    }

	/**
	 * @notice Decode a single RLE compressed image into a `DecodedImage`.
	 */
	function _decodeRLEImage(bytes memory image) private pure returns (DecodedImage memory) {
		uint8 paletteIndex = uint8(image[0]);
		ContentBounds memory bounds = ContentBounds({ top: uint8(image[1]), right: uint8(image[2]), bottom: uint8(image[3]), left: uint8(image[4]) });
		uint256 width = bounds.right - bounds.left;

		uint256 cursor;
		Rect[] memory rects = new Rect[]((image.length - 5) / 2);
		for (uint256 i = 5; i < image.length; i += 2) {
			rects[cursor] = Rect({ length: uint8(image[i]), colorIndex: uint8(image[i + 1]) });
			cursor++;
		}
		return DecodedImage({ paletteIndex: paletteIndex, bounds: bounds, width: width, rects: rects });
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

/// @title The Keys ERC-721 token

pragma solidity ^0.8.12;

interface IKeysDescriptor {
	struct Key {
		uint48 background;
		uint48 head;
		uint48 body;
		uint48 label;
		uint48 access;
	}

  struct Layer {
		bytes image;
		string name;
    uint256 pair;
    bool label;
  }

	function tokenURI(uint256 tokenId, Key memory key) external view returns (string memory);

	function dataURI(uint256 tokenId, Key memory key) external view returns (string memory);

	function backgroundsCount() external view returns (uint256);

	function layersCount(uint256 layerIdx) external view returns (uint256);	

	function getKeyAccess(Key memory key) external view returns (uint48, string memory);
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

library Base64 {
	string internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

	function encode(bytes memory data) internal pure returns (string memory) {
		if (data.length == 0) return "";

		// load the table into memory
		string memory table = TABLE;

		// multiply by 4/3 rounded up
		uint256 encodedLen = 4 * ((data.length + 2) / 3);

		// add some extra buffer at the end required for the writing
		string memory result = new string(encodedLen + 32);

		assembly {
			// set the actual output length
			mstore(result, encodedLen)

			// prepare the lookup table
			let tablePtr := add(table, 1)

			// input ptr
			let dataPtr := data
			let endPtr := add(dataPtr, mload(data))

			// result ptr, jump over length
			let resultPtr := add(result, 32)

			// run over the input, 3 bytes at a time
			for {

			} lt(dataPtr, endPtr) {

			} {
				dataPtr := add(dataPtr, 3)

				// read 3 bytes
				let input := mload(dataPtr)

				// write 4 characters
				mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
				resultPtr := add(resultPtr, 1)
				mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
				resultPtr := add(resultPtr, 1)
				mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F)))))
				resultPtr := add(resultPtr, 1)
				mstore(resultPtr, shl(248, mload(add(tablePtr, and(input, 0x3F)))))
				resultPtr := add(resultPtr, 1)
			}

			// padding with '='
			switch mod(mload(data), 3)
			case 1 {
				mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
			}
			case 2 {
				mstore(sub(resultPtr, 1), shl(248, 0x3d))
			}
		}

		return result;
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