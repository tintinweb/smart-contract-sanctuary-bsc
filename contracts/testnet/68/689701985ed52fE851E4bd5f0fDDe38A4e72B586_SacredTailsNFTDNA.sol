//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract SacredTailsNFTDNA is Ownable
{
    using Address for address;
    using Strings for uint256;

    struct Shinsei
    {
        uint256 id;
        uint256 baseId;
        bool isBase;
        bool isGenesis;
        uint[] genesisTraits;
        uint seed;
        uint dna;
        address owner;
        bool isBurned;
    }

    mapping(uint256 => Shinsei) public shinseis;
    mapping(uint256 => address) public originalOwner;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(address => uint256) private _balances;

    // ERC721Enumerable
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;
    uint256[] private _allTokens;
    mapping(uint256 => uint256) private _allTokensIndex;

    uint256 public totalShinseis;
    uint[] public bitsInitial;
    uint[] public bitsCapacity;

    string private _name;
    string private _symbol;
    string private _tokenURIServer;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _id);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _id);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    constructor(string memory name, string memory symbol, string memory serverURI, uint[] memory bits)
    {
        _name = name;
        _symbol = symbol;
        _tokenURIServer = serverURI;

        require(bits.length == 11, "The bits length doesn't equal to eleven parameters");

        bitsInitial = bits;

        for(uint i = 0; i < bits.length; i++)
        {
            bitsCapacity.push(log2(bits[i]));
        }
    }

    function transferFrom (address _from, address _to, uint256 _tokenId) external payable
    {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(_from, _to, _tokenId);
    }

    function mintShinseis(address to, uint quantity) public onlyOwner()
    {
        shinseis[totalShinseis].id = totalShinseis;
        shinseis[totalShinseis].seed = block.timestamp + block.difficulty * 1;
        shinseis[totalShinseis].baseId = totalShinseis;
        shinseis[totalShinseis].isBase = true;
        shinseis[totalShinseis].isGenesis = false;
        shinseis[totalShinseis].owner = to;
        shinseis[totalShinseis].dna = randomShinsei(block.timestamp + block.difficulty * 1, totalShinseis * bitsCapacity.length);

        originalOwner[totalShinseis] = to;

        _balances[to] += quantity;
        totalShinseis += quantity;
    }

    function mintSaleShinseis(address to, uint quantity, uint baseFamily, uint familyInitialLimit, uint familyFinalLimit, uint baseRarity) public onlyOwner()
    {
        shinseis[totalShinseis].id = totalShinseis;
        shinseis[totalShinseis].seed = block.timestamp + block.difficulty * 1;
        shinseis[totalShinseis].baseId = totalShinseis;
        shinseis[totalShinseis].isBase = true;
        shinseis[totalShinseis].isGenesis = true;
        shinseis[totalShinseis].owner = to;
        shinseis[totalShinseis].dna = randomLimitedShinsei(block.timestamp + block.difficulty * 1,
            totalShinseis * bitsCapacity.length,
            baseFamily,
            familyInitialLimit,
            familyFinalLimit,
            baseRarity);
        // Genesis Traits
        shinseis[totalShinseis].genesisTraits.push(baseFamily);
        shinseis[totalShinseis].genesisTraits.push(familyInitialLimit);
        shinseis[totalShinseis].genesisTraits.push(familyFinalLimit);
        shinseis[totalShinseis].genesisTraits.push(baseRarity);

        originalOwner[totalShinseis] = to;

        _balances[to] += quantity;
        totalShinseis += quantity;
    }

    function getShinseiDNA(uint id) public view returns (uint dna)
    {
        Shinsei memory shinsei = getVirtualShinsei(id);

        uint seed = shinsei.seed;
        uint seedExtra = (id - shinsei.baseId) * bitsCapacity.length;

        return shinsei.isGenesis ?
        randomLimitedShinsei(
            seed,
            seedExtra,
            shinsei.genesisTraits[0],
            shinsei.genesisTraits[1],
            shinsei.genesisTraits[2],
            shinsei.genesisTraits[3]) :
        randomShinsei(seed, seedExtra);
    }

    function getVirtualShinsei(uint id) public view returns (Shinsei memory)
    {
        require(id < totalShinseis, "Shinsei does not exist!");

        if(shinseis[id].seed != 0) return shinseis[id];

        // If the Shinsei doesnt generated yet

        Shinsei storage baseNFT = shinseis[0];

        for(uint i = id; i >= 0; i--)
        {
            if(shinseis[i].isBase)
            {
                baseNFT = shinseis[i];
                break;
            }
        }

        uint seed = baseNFT.seed;
        uint seedExtra = (id - baseNFT.id) * bitsCapacity.length;

        Shinsei memory shinsei;
        shinsei.id = id;
        shinsei.baseId = baseNFT.id;
        shinsei.dna = baseNFT.isGenesis ?
        randomLimitedShinsei(seed,
            seedExtra,
            baseNFT.genesisTraits[0],
            baseNFT.genesisTraits[1],
            baseNFT.genesisTraits[2],
            baseNFT.genesisTraits[3]) :
        randomShinsei(seed, seedExtra);
        shinsei.owner = originalOwner[baseNFT.id];
        shinsei.seed = baseNFT.seed;
        shinsei.isBase = false;
        shinsei.isGenesis = baseNFT.isGenesis;
        shinsei.genesisTraits = baseNFT.genesisTraits;

        return shinsei;
    }

    function randomShinsei(uint seed, uint startingSeed) private view returns (uint)
    {
        uint cromo = 0;
        uint bitPosition = 0;
        uint lastFamily = 0;
        uint randomValue = 0;

        for(uint i = 0; i < bitsCapacity.length; i++)
        {
            randomValue = random(bitsInitial[i], seed, startingSeed + i);

            if(i % 2 == 0)
            {
                lastFamily = random(bitsInitial[i], seed, startingSeed + i);
            }

            if(i % 2 != 0)
            {
                if(randomValue > 4 && lastFamily < 12)
                {
                    randomValue = 4 - random(4, seed, startingSeed % i);
                }
                else if (lastFamily >= 12 && randomValue < 5)
                {
                    randomValue = 9 - random(4, seed, startingSeed % i);
                }
            }

            cromo = cromo | (randomValue << bitPosition);

            bitPosition += bitsCapacity[i];
        }

        return cromo;
    }

    function randomLimitedShinsei(uint seed, uint startingSeed, uint baseFamily, uint familyInitialLimit, uint familyFinalLimit, uint baseRarity) private view returns (uint)
    {
        uint cromo = 0;
        uint bitPosition = 0;
        uint randomValue = 0;

        for(uint i = 0; i < bitsCapacity.length; i++)
        {
            if(i % 2 == 0 && i != 10)
            {
                randomValue = familyInitialLimit + (familyFinalLimit - random(familyFinalLimit, seed, startingSeed + i));
            }
            else if(i == 10)
            {
                randomValue = baseFamily;
            }

            if(i % 2 != 0)
            {
                randomValue = baseRarity;
            }

            cromo = cromo | (randomValue << bitPosition);

            bitPosition += bitsCapacity[i];
        }

        return cromo;
    }

    function random(uint256 max, uint256 seed, uint seedExtra) private pure returns (uint256)
    {
        return uint256(
            keccak256(
                abi.encodePacked(
                    seed,
                    seedExtra
                )
            )
        ) % max;
    }

    // Helper function get a base 2 - Economic way gas < 700;
    function log2(uint x) private pure returns (uint y)
    {
        assembly
        {
            let arg := x
            x := sub(x,1)
            x := or(x, div(x, 0x02))
            x := or(x, div(x, 0x04))
            x := or(x, div(x, 0x10))
            x := or(x, div(x, 0x100))
            x := or(x, div(x, 0x10000))
            x := or(x, div(x, 0x100000000))
            x := or(x, div(x, 0x10000000000000000))
            x := or(x, div(x, 0x100000000000000000000000000000000))
            x := add(x, 1)
            let m := mload(0x40)
            mstore(m,           0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
            mstore(add(m,0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
            mstore(add(m,0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
            mstore(add(m,0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
            mstore(add(m,0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
            mstore(add(m,0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
            mstore(add(m,0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
            mstore(add(m,0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
            mstore(0x40, add(m, 0x100))
            let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
            let shift := 0x100000000000000000000000000000000000000000000000000000000000000
            let a := div(mul(x, magic), shift)
            y := div(mload(add(m,sub(255,a))), shift)
            y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
        }
    }

    // ERC721
    function balanceOf(address _owner) public view returns (uint256)
    {
        require(_owner != address(0), "ERC721: balance query for the zero address");
        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address)
    {
        Shinsei memory shinsei = getVirtualShinsei(_tokenId);

        require(shinsei.owner != address(0), "ERC721: owner query for nonexistent token");
        return shinsei.owner;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable
    {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public payable
    {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(_from, _to, _tokenId, data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual
    {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _transfer(address from, address to, uint256 id) internal virtual
    {
        Shinsei memory shinsei = getVirtualShinsei(id);

        require(shinsei.owner == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");
        // if (to.isContract()) revert("You can't transfer Shinseis to contracts!");

        address fromQuestion = from.isContract() ? address(0) : from;
        _beforeTokenTransfer(fromQuestion, to, id);

        // Clear approvals from the previous owner
        _approve(address(0), id);

        _balances[from] -= 1;
        _balances[to] += 1;
        shinseis[id].owner = to;

        if(shinseis[id].seed == 0)
        {
            uint seed = shinsei.seed;
            uint seedExtra = (id - shinsei.baseId) * bitsCapacity.length;

            shinseis[id].id = id;
            shinseis[id].baseId = shinsei.baseId;
            shinseis[id].seed = shinsei.seed;
            shinseis[id].dna = shinsei.isGenesis ?
            randomLimitedShinsei(seed,
                seedExtra,
                shinsei.genesisTraits[0],
                shinsei.genesisTraits[1],
                shinsei.genesisTraits[2],
                shinsei.genesisTraits[3]) :
            randomShinsei(seed, seedExtra);
            shinseis[id].isBase = false;
            shinseis[id].isGenesis = shinsei.isGenesis;
            shinseis[id].genesisTraits = shinsei.genesisTraits;
        }

        emit Transfer(from, to, id);

        _afterTokenTransfer(from, to, id);
    }

    function _isApprovedOrOwner(address spender, uint256 id) internal view virtual returns (bool)
    {
        require(_exists(id), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(id);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(id) == spender);
    }

    function _exists(uint256 id) internal view virtual returns (bool)
    {
        Shinsei memory shinsei = getVirtualShinsei(id);
        return shinsei.owner != address(0);
    }

    function getApproved(uint256 id) public view virtual returns (address)
    {
        require(_exists(id), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[id];
    }

    function _approve(address to, uint256 id) internal virtual
    {
        _tokenApprovals[id] = to;
        emit Approval(ownerOf(id), to, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual
    {
        _setApprovalForAll(_msgSender(), operator, approved);
    }


    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual
    {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool)
    {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function tokenURI(uint256 id) public view returns (string memory)
    {
        require(_exists(id), "ERC721: request URI for nonexistent token");
        string memory generatedTokenURI = string(abi.encodePacked(_tokenURIServer, Strings.toString(id)));

        return generatedTokenURI;
    }
    // END ERC721

    // ERC721Enumerable
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {
        return totalShinseis;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal
    {
        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _afterTokenTransfer(address from, address to, uint256 tokenId) internal {}

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
    // END ERC721Enumerable
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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