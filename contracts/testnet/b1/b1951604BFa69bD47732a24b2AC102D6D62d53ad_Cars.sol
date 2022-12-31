// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import './Cars721.sol';
import '../controller/IController.sol';
import '../fcoin/IFCoin.sol';


contract Cars is Cars721
{


struct CarModel
{
	string name;
	uint8 class;
	uint16 speed;
	uint16 acceleration;
	uint16 steerability;
}

struct Car
{
	address owner;
	uint8 modelId;
}

struct Tuning
{
	TuningBody body;
	uint32 exhaust;
	uint32 lightFront;
	uint32 lightRear;
	uint32 mirrors;
	uint32 roof;
	uint32 spoiler;
	uint32 wheel;
	uint32 brand;
	string paint;
}

struct TuningBody
{
	uint32 bamperFront;
	uint32 bamperRear;
	uint32 bonnet;
	uint32 chassis;
	uint32 doors;
	uint32 skirts;
	uint32 trunk;
}


// List of existing car models
CarModel[] private carModels;

// All car instances by id
mapping(uint => Car) private cars;

// Tuning setup info of certain car
mapping(uint => Tuning) private tuningOf;


// Modules
IController public immutable CONTROLLER;
IFCoin public FCC;
bool private _initialized;


event CarBought(uint indexed carId);
event CarTuned(uint indexed carId);
event CarPainted(uint indexed carId);
event CarDecaled(uint indexed carId);


constructor(address controller_)
{
	CONTROLLER = IController(controller_);

	carModels.push(CarModel({ // modelId: 0
		name: 'BJURGER', // BMW M3 E36 1997
		class: 1,
		speed: 208,
		acceleration: 312,
		steerability: 325
	}));
	carModels.push(CarModel({ // modelId: 1
		name: 'BREEZE', // Subaru BRZ
		class: 2,
		speed: 215,
		acceleration: 283,
		steerability: 354
	}));
	carModels.push(CarModel({ // modelId: 2
		name: 'GODZILLA', // Nissan GT-R
		class: 3,
		speed: 245,
		acceleration: 360,
		steerability: 403
	}));
	carModels.push(CarModel({ // modelId: 3
		name: 'FAN', // Lamborghini Aventador
		class: 3,
		speed: 268,
		acceleration: 424,
		steerability: 450
	}));
	carModels.push(CarModel({ // modelId: 4
		name: 'DRAKEN', // Koenigsegg Agera RS
		class: 4,
		speed: 320,
		acceleration: 488,
		steerability: 568
	}));
	carModels.push(CarModel({ // modelId: 5
		name: 'LOUIS', // Bugatti Chiron
		class: 4,
		speed: 350,
		acceleration: 600,
		steerability: 600
	}));
}

function init() external
{
	require(!_initialized, 'Cars: initialized');

	FCC = IFCoin(CONTROLLER.aFCC());

	_initialized = true;
}


// ERC721
function _ownerOf(uint tokenId) internal view virtual override returns(address)
{
	require(tokenId <= carsCounter, 'ERC721: invalid token ID');
	return cars[tokenId].owner;
}


function getCarModel(uint modelId) external view returns(CarModel memory)
{ return carModels[modelId]; }

function getCarModels() external view returns(CarModel[] memory)
{ return carModels; }

function getCar(uint carId) external view returns(Car memory)
{ return cars[carId]; }

function getCarTuning(uint carId) external view returns(Tuning memory)
{ return tuningOf[carId]; }

function totalSupply() external view returns (uint)
{ return carsCounter; }

function _validateCarId(uint carId) private view
{ require(carId > 0 && carId <= carsCounter, 'Cars: invalid car id'); }

function getFullCarInfo(uint carId) external view returns(Car memory, CarModel memory, Tuning memory)
{
	_validateCarId(carId);

	Car memory car = cars[carId];
	return (car, carModels[car.modelId], tuningOf[carId]);
}


function buyCar(address player, uint8 modelId, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	require(modelId < carModels.length, 'Cars: invalid model id');

	// Pay
	if (payAmount > 0) FCC.fcBurn(player, payAmount);

	Car storage car = cars[++carsCounter];
	car.owner = player;
	car.modelId = modelId;

	// Mint NFT
	_mint(player, carsCounter);

	emit CarBought(carsCounter);
}

function tuneCar(uint carId, uint32 brandId, uint[] memory typeIds, uint32[] memory detailIds, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	_validateCarId(carId);
	require(typeIds.length > 0 && typeIds.length == detailIds.length, 'Cars: invalid arrays');

	// Pay for
	if (payAmount > 0) FCC.fcBurn(cars[carId].owner, payAmount);

	Tuning storage tun = tuningOf[carId];
	if (tun.brand != brandId) tun.brand = brandId;

	for (uint i; i < typeIds.length; i++)
	{
		//string memory detail = details[i];
		//require(bytes(detail).length < 16, 'Cars: invalid detail length');
		//uint32 detailId = uint32(detailIds[i]);

		uint typeId = typeIds[i];
		if (typeId == 0) tun.body.bamperFront = detailIds[i];
		else if (typeId == 1) tun.body.bamperRear = detailIds[i];
		else if (typeId == 2) tun.body.bonnet = detailIds[i];
		else if (typeId == 3) tun.body.chassis = detailIds[i];
		else if (typeId == 4) tun.body.doors = detailIds[i];
		else if (typeId == 5) tun.body.skirts = detailIds[i];
		else if (typeId == 6) tun.body.trunk = detailIds[i];
		else if (typeId == 7) tun.exhaust = detailIds[i];
		else if (typeId == 8) tun.lightFront = detailIds[i];
		else if (typeId == 9) tun.lightRear = detailIds[i];
		else if (typeId == 10) tun.mirrors = detailIds[i];
		else if (typeId == 11) tun.roof = detailIds[i];
		else if (typeId == 12) tun.spoiler = detailIds[i];
		else if (typeId == 13) tun.wheel = detailIds[i];
	}

	emit CarTuned(carId);
}

function paintCar(uint carId, string memory paint, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	_validateCarId(carId);
	require(bytes(paint).length < 16, 'Cars: invalid paint');

	// Pay for
	if (payAmount > 0) FCC.fcBurn(cars[carId].owner, payAmount);

	tuningOf[carId].paint = paint;
	emit CarPainted(carId);
}

/*function decalCar(uint carId, string memory decals, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	_validateCarId(carId);
	require(bytes(decals).length < 1024, 'Cars: invalid paint');

	// Pay for
	if (payAmount > 0) FCC.fcBurn(cars[carId].owner, payAmount);

	tuningOf[carId].decals = decals;
	emit CarDecaled(carId);
}*/

/*function buyTuning(address player, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	if (payAmount > 0) FCC.fcBurn(player, payAmount);
}*/

/*function buyDecal(address player, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	if (payAmount > 0) FCC.fcBurn(player, payAmount);
}*/

function buyPaint(address player, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	if (payAmount > 0) FCC.fcBurn(player, payAmount);
}

function mixPaint(address player, uint payAmount) external
{
	CONTROLLER.onlyRelayer(msg.sender);
	if (payAmount > 0) FCC.fcBurn(player, payAmount);
}


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";


contract Cars721 is ERC165, IERC721, IERC721Metadata
{
	using Address for address;
	using Strings for uint256;

	uint internal carsCounter;
	string internal _baseURI;
	mapping(uint256 => address) private _owners;
	mapping(address => uint256) private _balances;

	
	constructor() {}

	
	function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
		return
			interfaceId == type(IERC721).interfaceId ||
			interfaceId == type(IERC721Metadata).interfaceId ||
			super.supportsInterface(interfaceId);
	}

	function balanceOf(address owner) public view virtual override returns (uint256) {
		require(owner != address(0), "ERC721: address zero is not a valid owner");
		return _balances[owner];
	}

	function name() public view virtual override returns (string memory)
	{ return "FormacarCar"; }

	function symbol() public view virtual override returns (string memory)
	{ return "FCAR"; }

	function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
	{
		require(tokenId <= carsCounter, 'ERC721: invalid token ID');
		return bytes(_baseURI).length > 0 ? string(abi.encodePacked(_baseURI, tokenId.toString())) : "";
	}

	function _ownerOf(uint tokenId) internal view virtual returns(address)
	{ return address(0); }
	function ownerOf(uint256 tokenId) public view virtual override returns (address)
	{ return _ownerOf(tokenId); }
	
	function _setBaseURI(string memory uri) internal
	{ _baseURI = uri; }

	function approve(address to, uint256 tokenId) public virtual override
	{ require(false, 'FCAR: disabled'); }

	function getApproved(uint256 tokenId) public view virtual override returns (address)
	{ return address(0); }

	function setApprovalForAll(address operator, bool approved) public virtual override
	{ require(false, 'FCAR: disabled'); }

	function isApprovedForAll(address owner, address operator) public view virtual override returns (bool)
	{ return false; }

	function transferFrom(address from, address to, uint256 tokenId) public virtual override
	{ require(false, 'FCAR: disabled'); }

	function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override
	{ require(false, 'FCAR: disabled'); }

	function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override
	{ require(false, 'FCAR: disabled'); }

	function _mint(address to, uint256 tokenId) internal virtual
	{
		_balances[to] += 1;

		emit Transfer(address(0), to, tokenId);
	}

	/*function _burn(uint256 tokenId) internal virtual {
		address owner = ownerOf(tokenId);

		_balances[owner] -= 1;
		delete _owners[tokenId];

		emit Transfer(owner, address(0), tokenId);
	}

	function _transfer(
		address from,
		address to,
		uint256 tokenId
	) internal virtual {
		require(ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
		require(to != address(0), "ERC721: transfer to the zero address");

		_balances[from] -= 1;
		_balances[to] += 1;
		_owners[tokenId] = to;

		emit Transfer(from, to, tokenId);
	}*/
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IController
{
	function aFCG() external view returns(address);
	function aFCC() external view returns(address);
	function aPlayers() external view returns(address);
	function aCars() external view returns(address);
	//function aRaces() external view returns(address);

	function isOwner(address account) external view returns(bool);
	function isAdmin(address account) external view returns(bool);
	//function isModer(address account) external view returns(bool);
	function isDispatcher(address account) external view returns(bool);
	function isRelayer(address account) external view returns(bool);

	function onlyDispatcher(address account) external view;
	function onlyRelayer(address account) external view;

	function fccToFcgExchangeEnabled() external view returns(bool);
	function fcgToFccExchangeEnabled() external view returns(bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IFCoin
{
	function fcMint(address to, uint amount) external;
	function fcBurn(address from, uint amount) external;
	function fcTransfer(address from, address to, uint amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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