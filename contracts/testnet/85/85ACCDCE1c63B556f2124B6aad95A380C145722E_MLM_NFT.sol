/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract Ownable {
    address private _owner;
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC721 is IERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

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

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

pragma solidity ^0.8.0;

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
pragma solidity ^0.8.0;

library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {
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

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
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

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

contract MLM_NFT is Context, ERC165, IERC721, IERC721Metadata, Ownable {
    using Address for address;
    using Strings for uint256;
    string private _name = "MLM_NFT";
    string private _symbol = "MLM_NFT";
    struct NFTData {
        uint8 _class;
        uint256 _lv;
    }
    struct ClaimReward {
        uint256 silver;
        uint256 gold;
        uint256 diamond;
    }
    mapping(uint256 => address) private _owners;
    mapping(uint256 => NFTData) private _nftData;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(address => ClaimReward) public _nftToClaim;
    mapping(address => uint256[]) public _nftByAddress;

    address public treasuryReceiver =
        0x0000A4Ae346c9eafFb0d007fa9E9662397890000;

    uint256 private _tokenId = 1;

    constructor() Ownable() {
        _nftToClaim[0x8CfDA1e5814631C3EE41505E76c13D1240227122] = ClaimReward(
            1,
            1,
            1
        );
        _nftToClaim[0x748EfA2cC29f2B8C112E331f7C9174DB2Fa1df69] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xb1Ac5549De295711079E10815B017F9B7171f66E] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0xE0eEA73b66ed7Ec50E898d67Ce21B76756b8a00a] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x71C1Eb4ac5c2b85B40f792b2E0cA7ab2C69cef9d] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x95dB96342c5d57a12fe94F21a42a271488888888] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xc4E415c31aaE76818673911aa9a9a13C1DE79733] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x776A5CD46137e5B6375ffED6E22725C3dEc05a90] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x3d983307829a48657C905CA6B469eCB582876564] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0xA81293A41bad0e4156E4eF3AC25a472201332a33] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0xf6b8ea68af97eA46627877E1E94C7DB059018cEB] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x548e88Cd74951b354f81dc770635B8f95E230B78] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x6bE5772FA1FD9d6C8FC4Ce9292DA3CCAa729Fb47] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xcB6EfC0890E2169f5b60881aD11762f4403480bE] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xd671947837f9d56061f5F766846bee3EEE452598] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x2fD38cEa984313BE7a6c6555174Fa1a1Aeb9392c] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x11c56dA448Fb08C146BaE62ED13c06a82863C110] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x655DD0321aCa601864a79866dE90648A76febe55] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xff24e8fEdDDa10a8F903C84Dc74D59484d324bb6] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xD36AF4E4D4C5c23172C6e8858Da2240a6e83Db0d] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x78B2419bEC6993b50b7f7C0005034c5754618BF0] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x2922B6c73B23e3B4F61a9f216A32eBf4BF22B388] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x3aF57a1258e66c6bC49A8046Fb60d0d11970Ed91] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x2375CbDA2cfEEd568c94B3119e4A4CAf701090F5] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x7F4F3Ca09D17bb1844FC70E2F4254b3aEEc34E59] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x4CcFEcE832bf8580fb3545236198758fc552785B] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x3A8969bA0Ad371B1BF469DbeDcC13801edA9Cc8F] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x607E7835F586f11fE77747DAEf0c9c78e52873F2] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x925d0CD4694577b48008A5E3586E84d4313DCBD8] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x46480c617f3ECdF0a8CF55C5CB6ab22E57817c01] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0xCF28a4dfb7a13634aCeA85fE313448907Ee1E94d] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xfa8327C6FF914Ccc2BCaEAeC8B09594dAB3cb5ba] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x85dC137379F537346607F78842Ac11F632cd1a32] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x101476b92b83e1bD8Bb63aD6aBE4FF66958fcc89] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x96663B5ef450aB3454690CBEe0418f2d11b23f9e] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xF1aaB4A46bCCd82a0B2B9a7249FA058D5f58356f] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x4f5768f63C7E2f5B8aE01320aab921D77125D038] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x3e55f6B128303205eE2617B9726d71629edcd10b] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xB8557a2d63955832ae0A33E4221b238805BcB556] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x0a12788ec910834041DD23475C4F27DD0F8B6a4A] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x313AcF9cC0d9460fD8A6e8560342fb9E0C4457dD] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x21890656db29397952Fe3436348414fb939EAe48] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x1EF12d27E1242dF33Cc68F3aA5920710Ffd9490a] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xe4484D4c4598eA7913dF9d46fd4359c10a6b3225] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x34964a05A92A969c3ecEadC2218b087d1a08Dd06] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x8272983116Ed9c1dF76e1099428BE0A68eE4a5C2] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x413DeE3d9825D9fDcc1e00FBCAEd0622F5A1F9AC] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x745C0756157DCbE29883fbB4e1450b816f206a66] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x905b71D1036B23FE3Afdb6eAFf9eB28B7821b44b] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x87b7d5254741997B1345269f6dE6299f677ce421] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x65C2A07fbf906356F18424935080B63b26771835] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x12B331eB2E25443212073F6a97C54C2eF462B202] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x1cAee6c3B32833D3b0C463CEc50D23d0766e4c37] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x818416066d4a69c05046F6f2d43d50E50E46B6cE] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x0f6975A059ed5cb2123352991E71E6B7Cb160aEa] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x0EbbaaA6A3Ae210eBb6b5e5c4c139eC52C88378f] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x3eCeE424b904b1eA27Ac544D33969e18689833E0] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xe70EDA20ab493244171aD742a94fbf584765Ec63] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x279BCCC6f8277b1B113c57313Dd546E45E02DDA9] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x4EBB54e8A697b5420e32ccC917b49171c3C333E7] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xe6bD533A8EB24D72ff77b03069Aa0c5BC08a33e3] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x554bA19Cf2fe99c1BE151e0aD1bC4eFFBFCE8425] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x7d2b7BCD5EbE577c1ED1C0636D14c13b75f5A707] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x323230EC783bAf724C82949E1eB57d61472225bf] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x8CE0D7e73E024Df6fac861357e3F69b029208bf6] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x1657D10EefEdfc20848A88B1814eb8eC0E59C786] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x564760a823f97b9c853bEf43D1d8fBce3537edc6] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x0E4D236C814dF3E19162d6572c33C92A697841D2] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0xCE8E48bFa7196add9Bf72A106Bff3A29cF1E7EDf] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x958fd189CD9a30135758120b3216AB3f823a71cc] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xc86346D5F55DeBd096a682b74e68B380f80bA842] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xC5353AfF48b24191281d766CD88ddf7eCB665D87] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xBc42575408683711F4Ee51C7F257f458B3D65F2C] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xeA4fdcD12c1C3cB26075278Af03D6fb38cbFa37a] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xBa548e674D785cD6D12E1bE92cDc5774A52F20F2] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xD5909F5729A44044b51e327499cfD524fD914B71] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xE66310A974b787CD48f9772Fdef87fb2bE28E044] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x401Eb45bDCD6C3fEaDCC0a8edEB43Bd5c46F4446] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xB5A570c29759FA8Cc0E3c73f40E49d555aC8A771] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xE38669d91018F3e16a5968Dd4695F7F209f0dDfB] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x52D7185Aea1c1c12d84476E83857FaC39318632A] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0xFdb3BD08D0775B1771B3AdBaD9198baE84324460] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0xdf51834697D309c40f75fdF62dc115E32B7FaE12] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0xe3E710F32E891260aBb51Cb2Cd561a8466f42428] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xDf9528770963538330D7f04f338eDCF50F645f93] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x57F1305F3fFe0f8D7c2e5c6cac99F4806a0CB93e] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x201e7859219eF6aa3d91b45dc37b30F5d3F821A9] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x7851dE9EdA5EfaF21C8FDd9DE5D83cA063C22142] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x60740cB8B37d043ee035E5614De8C3c7C41a59d7] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xEbdf70080E0Ae2C2666fe24934D7D02ED64b2674] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x01142e8fA764b5ef21091d1CBB2740cfb83D5096] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xd9283a927f1eB0c6cB72375b73a985558A8Df674] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x882CE9e1307CD42e3dAf573BDb76055cC89A4df8] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xfA0719662021934103Ba90a9458716D294A0dC50] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xE8899732C51517553b1837C8540aA5FcD3a997f4] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xc4B963b00102026d2f5b4453F49B3322F58B431c] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0xc51521865Fec24c7F617a6B006c63494F5d07EC4] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x1bBdB7AA8C208396e84Ce65dD57ae97764788cC8] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x04366aD174c649f50DD5994900de30d27B67Fd51] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0xed7fE19D296E8fa39B92E9b07f49ce96D002C273] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x35D90F93830c180f33f39c7E9FB49c726C2F4a6E] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x88611e242A82dCFef70E763aA1aA5ed14dD033EE] = ClaimReward(
            1,
            0,
            0
        );
        _nftToClaim[0x3DC14E6eEB556C1d7cA8f90D109A853B95F6a3D7] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x6bf399759d291688270fd4d7F4095b0133b10451] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x6324586Cae335e7cB3e951358ed618F87095Dfe8] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x58dB200AfE7BC676Cd539d75a51fF8D2Cc8EAe77] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0xbd00BEcaa72D7d8D8E5dE0396e425b5a6fD2d64c] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x6d17a2Be4c068d0cDa15316868FB1973104F8B2c] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0x48d6756dbd8bC68e8f9De118630AdE8A0445364b] = ClaimReward(
            0,
            1,
            0
        );
        _nftToClaim[0xb9D4F126A5149f539E7011D1092B9E7bD52d58df] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x982E6F4Fe93C443fC7f0a8708b39D2bF54636bf1] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x265d39968aB11b27A984dF4C8e1F1eD1f67012f6] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x0B8088BD4d36d086fC3A0e5070F9A9b683554998] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0xCd6bfD0768634F319C2B522607FB82305ca3002f] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x81e88F70D78ba55dA7BABE49EA5c64552eFB8285] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0xaB9aFC47d9BEceA4c2BFded4E4f3Cb85E2528bef] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x59766aE2a332525b420F873267e108847435f149] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x994a47a6c770B10b4948DAA99fd025871423bebd] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0xB61e9656459347f6CD6453913Be0b1838Fa6B3E6] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x13b88eE73Acfc390A67b0c83D821e0a1B851ade8] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x2A709507535dECc6d4d38250F2d79CaaD12B2DCB] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x62925e8B1Bfb7f87A83a41EA91C43Fd9b70A6fB3] = ClaimReward(
            1,
            1,
            0
        );
        _nftToClaim[0xBEed96276196b2ff1D33C3bB093E42b28Ce38623] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x8eCF5Fc5605aB53FF7243aed97E42DA47aCCBb53] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x8fBbDB2280ed4150C07B381A48bF2c3cbd16aF96] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0xBD08373Eab97e577dA9D555183F929842343cfa1] = ClaimReward(
            1,
            1,
            0
        );
        _nftToClaim[0x3ee5F556f99b6ebA742a5d86e9df695B8f4d67Aa] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x88000BA1bd0f7c27ddD3E7FC0E912446eFdEa1C5] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x9570A8815971b126f29C3c8758519636c0123456] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x64Be9bae8f370615815D9D42C947688E0729F378] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0xBCD7A7554fDa4dd7f67ca6691c786d2eca4C4A67] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0xe03aA678fcB1d9D6498e53505038d423bFDD2F27] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x482CcA57444A9fcCb87db929E93E5DD03ceE0C2a] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x50c66075ECbaB17995d9Eb1C0135B1367Ae7Ef29] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0xE0B46FE515f3Ec4cd32aF3d71395fdA21D999991] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x70DFe0A48F2359bdD8089149b020005dD437dC16] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0xf2F25688E3D295d3b1bb6fD729a9E0357a8F1233] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x2f57182CDe512Eee45dF74217A36F7b4d279E934] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x8D151B0f6a23Dd6aaa183e6DEab4fF5A75D20C76] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0xdf83fD5bb6DDFAF0761123dcAab83863F004A92d] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x1216b58332BbcB40169b67ad3C79CEe10d2071C5] = ClaimReward(
            1,
            1,
            0
        );
        _nftToClaim[0x7A51851F13C7f21891F850319Af6Da7e22152Ad2] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x9323FEaF96B69a3327442C68641F50157Cc8Bf22] = ClaimReward(
            1,
            1,
            0
        );
        _nftToClaim[0x968eF4d547df73e16Be747eCfe8B637Fb5984CCF] = ClaimReward(
            1,
            1,
            0
        );
        _nftToClaim[0xb4B4Db44844727Ef4B09BEBf0137ed5e9Aae79Ad] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0xA0892AEb2E288199a9B4fcc6f328698d7d03e992] = ClaimReward(
            1,
            1,
            0
        );
        _nftToClaim[0x526f334BF25B93c324aA40A31D82Cb67623ef04D] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0xF2fB099e07eB5E69c025A03fe5827CD703d701B6] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0xE90Ee7bf8dFaB3a4c37C31DF1025A0A48364cB00] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0xCaB005F52204903deFaf35A3B7273850Cd213467] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0xE0fce499E237F99b6f8bdB754Bf55e0F0b1A15d1] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x830AfD24A47FB8b1ae8bEE3E49B8c3421C9f4d2d] = ClaimReward(
            1,
            1,
            0
        );
        _nftToClaim[0x306e60f8Bcee02d5d17DF02690A0750FD69546B6] = ClaimReward(
            2,
            0,
            0
        );
        _nftToClaim[0x74b672ED17C907C8B04bB60e6b6981c42E37a2aC] = ClaimReward(
            1,
            1,
            0
        );
        _nftToClaim[0xD0A57E75FcaC235Ea3F970EBfAEcb5bdd7E4c9aE] = ClaimReward(
            1,
            1,
            0
        );
        _nftToClaim[0xFeE6B4a349105549fC60ab0af41B667D00c104b2] = ClaimReward(
            3,
            0,
            0
        );
        _nftToClaim[0x7bCa28c9989033E05fB829Dd742167E0d853Ef43] = ClaimReward(
            3,
            0,
            0
        );
        _nftToClaim[0x895F56E69B2282D537EE77ecBD62Dce327bD5232] = ClaimReward(
            3,
            0,
            0
        );
        _nftToClaim[0x726b21934703637A8691b705Ae56C0c71d72E248] = ClaimReward(
            2,
            1,
            0
        );
        _nftToClaim[0x34C49b21163683049bEB28016c5cc2Fb06216917] = ClaimReward(
            3,
            0,
            0
        );
        _nftToClaim[0x0Ac8997BA796867bE9c6BFB907C8C48838146b29] = ClaimReward(
            3,
            0,
            0
        );
        _nftToClaim[0xBF60A8D55E11D64aff1feAB9aE4eB585A085785B] = ClaimReward(
            3,
            0,
            0
        );
        _nftToClaim[0xB86f8c424A8ff057EA651aB701bb8fffD9a3bB8D] = ClaimReward(
            3,
            0,
            0
        );
        _nftToClaim[0x97fCE2DDFB2876b0d27BCDD7087c6D5eb37EB5D9] = ClaimReward(
            3,
            0,
            0
        );
        _nftToClaim[0xD91b1513f4B7F9b7570C252C0D482b9f887D204b] = ClaimReward(
            3,
            0,
            0
        );
        _nftToClaim[0xE53A02848392c8071636815a2D2ADEA58Ded8AB4] = ClaimReward(
            3,
            0,
            0
        );
        _nftToClaim[0x515d7B46089AA36c2933349e918EC1916e09C332] = ClaimReward(
            3,
            0,
            0
        );
        _nftToClaim[0x7bE9bb4b880b232886bDB621ae106ccB283D1B0E] = ClaimReward(
            3,
            0,
            0
        );
        _nftToClaim[0xeb38b48b89AF2e3a35f69D9e101D8040dcCA8E53] = ClaimReward(
            3,
            0,
            0
        );
        _nftToClaim[0x1B77A9ee87F70abc0FB3Feb926856570CBe1e2D2] = ClaimReward(
            4,
            0,
            0
        );
        _nftToClaim[0x6E89Fd0C96841cF6CCe5DCA871e3ac1720ae37CF] = ClaimReward(
            4,
            0,
            0
        );
        _nftToClaim[0x3983d951AD93838582d657C71510f0Af647F7F0d] = ClaimReward(
            4,
            0,
            0
        );
        _nftToClaim[0xA0BF7B93479070C1E10FdFe520EFe4fd3020b6fF] = ClaimReward(
            3,
            1,
            0
        );
        _nftToClaim[0xea85604C31b3cB82fbB546Fd2A80c4D4A1a225CF] = ClaimReward(
            3,
            1,
            0
        );
        _nftToClaim[0x72d47984FeeD149df7748Ba6426296333e0064CF] = ClaimReward(
            5,
            0,
            0
        );
        _nftToClaim[0xF7644F02694b1ecbA4b4433AF5aF494237Ec583e] = ClaimReward(
            5,
            0,
            0
        );
        _nftToClaim[0x2B63a8e075C518D4d8F16569012e25b707b76EF6] = ClaimReward(
            5,
            0,
            0
        );
        _nftToClaim[0x59435f6D35432A3BFfBE3f0700EF249bb58D8B10] = ClaimReward(
            5,
            0,
            0
        );
        _nftToClaim[0xD2eC57e2397b9fF2da7778e883F151022BF727a0] = ClaimReward(
            5,
            0,
            0
        );
        _nftToClaim[0x792197F0dcDC54e439D41C75C5b3aaca721010B6] = ClaimReward(
            5,
            0,
            0
        );
        _nftToClaim[0x264C5EC670c79aec431F456E36D7AE91d206C009] = ClaimReward(
            5,
            0,
            0
        );
        _nftToClaim[0x4097e87d29B9589dcB01f75F072Cf814b136C6b9] = ClaimReward(
            6,
            0,
            0
        );
        _nftToClaim[0xF70B5F4f8130c5fcabe247e59873b9d5Bd18C5Fb] = ClaimReward(
            6,
            0,
            0
        );
        _nftToClaim[0x82B435626F631B3f18c3239a0CF1D63Aa190Af86] = ClaimReward(
            7,
            0,
            0
        );
        _nftToClaim[0x2e6A853d07c28a7ab7a76a6a871ef7fC5F897E7d] = ClaimReward(
            9,
            0,
            0
        );
        _nftToClaim[0x88948D7B96f09213C5b71dEBC0D281F1E20Bdd36] = ClaimReward(
            9,
            0,
            0
        );
        _nftToClaim[0x342b66992a3F79A0CaFb32628F9759C491bEFBf2] = ClaimReward(
            10,
            0,
            0
        );
        _nftToClaim[0x681321673538a610E24878e463a187633f8a8350] = ClaimReward(
            10,
            0,
            0
        );
        _nftToClaim[0xdDb638f2bE5FDB00C7ea296135B36542d3d45853] = ClaimReward(
            9,
            1,
            0
        );
        _nftToClaim[0x9E784fE41C9A86b4Cc0E64335c898dc9A6cc0aFb] = ClaimReward(
            10,
            0,
            0
        );
        _nftToClaim[0xe593BBf6f684A8e3eF8b136b2d677127AA49C119] = ClaimReward(
            14,
            0,
            0
        );
        _nftToClaim[0x1f00b172a6bBbDb1e8712A30FcA8b4e8E1Aa353b] = ClaimReward(
            26,
            0,
            0
        );
        _nftToClaim[0x5eDD631e1b4423AFA3b8d9C541C6ab34AB4b0eea] = ClaimReward(
            28,
            1,
            1
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "http://multifinance.io/nft/";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = MLM_NFT.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non MLM_NFTReceiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = MLM_NFT.ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint8 _class) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        uint256 tokenId = _tokenId;
        require(!_exists(tokenId), "ERC721: token already minted");
        require(_class < 3, "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        if (_nftByAddress[msg.sender].length > _balances[to]) {
            _nftByAddress[msg.sender][_balances[to]] = tokenId;
        } else {
            _nftByAddress[msg.sender].push(tokenId);
        }
        _balances[to] += 1;
        _owners[tokenId] = to;
        _tokenId += 1;

        _nftData[tokenId]._class = _class;
        _nftData[tokenId]._lv = 0;

        emit Transfer(address(0), to, tokenId);
    }

    function randomNumber(uint256 maxNumber, address _address)
        internal
        view
        returns (uint256)
    {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        _address,
                        _tokenId
                    )
                )
            ) % maxNumber;
    }

    function mint(uint256) external payable {
        require(msg.value == 10**18);
        uint256 ran = randomNumber(100, msg.sender);
        uint8 _class = 0;
        if (ran > 96) {
            _class = 2;
        } else if (ran > 69) {
            _class = 1;
        }
        _mint(msg.sender, _class);
        payable(owner()).transfer(address(this).balance);
    }

    function claimNFTPresale() external {
        require(
            _nftToClaim[msg.sender].silver +
                _nftToClaim[msg.sender].gold +
                _nftToClaim[msg.sender].diamond >
                0
        );
        if (_nftToClaim[msg.sender].diamond > 0) {
            for (uint256 i = 0; i < _nftToClaim[msg.sender].diamond; i++) {
                _mint(msg.sender, 2);
            }
            _nftToClaim[msg.sender].diamond = 0;
        }
        if (_nftToClaim[msg.sender].gold > 0) {
            for (uint256 i = 0; i < _nftToClaim[msg.sender].gold; i++) {
                _mint(msg.sender, 1);
            }
            _nftToClaim[msg.sender].gold = 0;
        }
        if (_nftToClaim[msg.sender].silver > 0) {
            for (uint256 i = 0; i < _nftToClaim[msg.sender].silver; i++) {
                _mint(msg.sender, 0);
            }
            _nftToClaim[msg.sender].silver = 0;
        }
    }

    function claimOneNFTPresale() external {
        require(
            _nftToClaim[msg.sender].silver +
                _nftToClaim[msg.sender].gold +
                _nftToClaim[msg.sender].diamond >
                0
        );
        if (_nftToClaim[msg.sender].diamond > 0) {
            _mint(msg.sender, 2);
            _nftToClaim[msg.sender].diamond -= 1;
            return;
        }
        if (_nftToClaim[msg.sender].gold > 0) {
            _mint(msg.sender, 1);
            _nftToClaim[msg.sender].gold -= 1;
            return;
        }
        if (_nftToClaim[msg.sender].silver > 0) {
            _mint(msg.sender, 0);
            _nftToClaim[msg.sender].silver -= 1;
            return;
        }
    }

    function updateNFTLv(uint256 tokenId, uint256 Lv) external onlyOwner {
        require(_exists(tokenId), "ERC721: token already minted");
        require(Lv > _nftData[tokenId]._lv);
        _nftData[tokenId]._lv = Lv;
    }

    function getNFTData(uint256 tokenId)
        external
        view
        returns (uint8, uint256)
    {
        require(_exists(tokenId), "ERC721: token already minted");
        return (_nftData[tokenId]._class, _nftData[tokenId]._lv);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(
            MLM_NFT.ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );
        require(to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenId);
        _approve(address(0), tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        uint256 index = 0;
        bool flag = false;
        for (uint256 i = 0; i < _nftByAddress[from].length; i++) {
            if (tokenId == _nftByAddress[from][i]) {
                index = i;
                flag = true;
                break;
            }
        }
        if (flag) {
            _nftByAddress[to].push(tokenId);
            _nftByAddress[from][index] = _nftByAddress[from][
                _nftByAddress[from].length - 1
            ];
            delete _nftByAddress[from][_nftByAddress[from].length - 1];
        }

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(MLM_NFT.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non MLM_NFTReceiver implementer"
                    );
                } else {
                    // solhint-disable-next-line no-inline-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}