// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../interfaces/IERC721.sol";
import "../interfaces/IERC165.sol";
import "../utils/Ownable.sol";
import "../utils/ERC165Checker.sol";
import "../tokens/Endorsable/IERC721Endorsable.sol";
import "../tokens/Seal/IERC721Seal.sol";

contract Endorsement is Ownable {
    struct EndorseRequest {
        bool isActive;
        address endorsable;
        address seal;
        uint8 sealPossibleCorners;
        uint256 price;
    }

    mapping(address => mapping(address => EndorseRequest)) public _requests;

    modifier assertTokenOwner(address tokenAddress) {
        require(IERC721(tokenAddress).ownerOf(0) == _msgSender(), "You are not the owner of the token");
        _;
    }

    function requestEndorse(
        address endorsable,
        address seal,
        uint8 sealPossibleCorners,
        uint64 price
    ) public payable assertTokenOwner(endorsable) {
        require(msg.value >= price, "Invalid value");

        require(
            _requests[seal][endorsable].isActive == false,
            "You have already requested an endorsement for this token"
        );

        require(
            ERC165Checker.supportsInterface(seal, type(IERC721Seal).interfaceId),
            "The given seal does not support the IERC721Seal interface"
        );

        require(
            ERC165Checker.supportsInterface(endorsable, type(IERC721Endorsable).interfaceId),
            "The given endorsable does not support the IERC721Endorsable interface"
        );

        require(!IERC721Endorsable(endorsable).isEndorsed(), "The given endorsable is already endorsed");

        _requests[seal][endorsable] = EndorseRequest({
            isActive: true,
            endorsable: endorsable,
            seal: seal,
            sealPossibleCorners: sealPossibleCorners,
            price: price
        });
    }

    function cancelEndorse(
        address endorsable, address seal
    ) public assertTokenOwner(endorsable) {
        EndorseRequest storage request = _requests[seal][endorsable];

        require(
            request.isActive == true,
            "You have not requested an endorsement for this token"
        );

        request.isActive = false;
    }

    function endorse(
        address endorsable, address seal, uint8 sealCorner
    ) public assertTokenOwner(seal) {
        EndorseRequest storage request = _requests[seal][endorsable];

        require(request.isActive == true, "There is no an endorsement for this token");

        uint8 possibleCorners = request.sealPossibleCorners;

        require(
            (possibleCorners & sealCorner) != 0,
            "The given seal corner is not possible for this token"
        );

        IERC721Seal(seal).markAsEndorsed(
            endorsable,
            sealCorner
        );

        IERC721Endorsable(endorsable).endorse(seal);

        payable(IERC721(seal).ownerOf(0)).transfer(request.price);

        request.isActive = false;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "./IERC165.sol";

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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "./Context.sol";

abstract contract Ownable is Context {
    address private _owner;

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function withdraw() public payable onlyOwner {
        payable(owner()).transfer(address(this).balance);
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
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../interfaces/IERC165.sol";

library ERC165Checker {
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {
        return
            supportsERC165InterfaceUnchecked(account, type(IERC165).interfaceId) &&
            !supportsERC165InterfaceUnchecked(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        return supportsERC165(account) && supportsERC165InterfaceUnchecked(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = supportsERC165InterfaceUnchecked(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!supportsERC165InterfaceUnchecked(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function supportsERC165InterfaceUnchecked(address account, bytes4 interfaceId) internal view returns (bool) {
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (uint256)) > 0;
    }
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../../interfaces/IERC721.sol";

interface IERC721Endorsable is IERC721 {
    function getEndorsementInfo() external view returns (address seal, uint8 sealCorner);
    function isEndorsed() external view returns (bool);
    function endorse(address seal) external;

    function getTimeLimitedEndorsementInfo(address seal) external view returns (uint32 expirationTime);
    function endorseTimeLimited(address seal) external;

    function isCrossEndorsedBy(address endorsable) external view returns (bool);
    function hasCrossEndorsedForeign(address endorsable) external view returns (bool);
    function getCrossEndorsementInfo() external view returns (address endorsable);
    function isCrossEndorsed() external view returns (bool);
    function markAsCrossEndorsed(address foreignEndorsable) external;
    function endorseCross(address endorsable) external;

    function setDraftForever(address draftForever) external;
    function resetDraftForever() external;

    function getForever() external view returns (address forever);
    function commitForever() external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

import "../../interfaces/IERC721.sol";

interface IERC721Seal is IERC721 {
    function getEndorsementInfo(
        address endorsableToken
    ) external view returns (bool isEndorsed, uint8 sealCorner);

    function getTimeLimitedEndorsementInfo(
        address endorsableToken
    ) external view returns (bool isEndorsed, uint32 endTime);

    function markAsEndorsed(address endorsableToken, uint8 sealCorner) external;
    function markAsEndorsedTimeLimited(address endorsableToken, uint32 endTime) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}