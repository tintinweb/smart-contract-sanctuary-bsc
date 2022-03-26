/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

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
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

library Constants {
    bytes32 constant PLASTIKSELL_TYPEHASH =
        keccak256("PlastikSell(address buyer,uint256 price,uint256 timestamp,address tokenAddress)");
}

contract GetCrypto is EIP712 {
    event TokenBought(address from, uint256 amount, uint256 price);
    event WithDraw(uint256 amount, uint256 balance);
    event Transfer(address _from, uint256 amount, uint256 balance);
    IERC20 internal _token;
    address internal tokenPool;
    address internal priceSigner;
    address private owner;
    uint256 public fee;
    uint256 public minTokensToBuy;
    uint256 public maxTokensToBuy;
    mapping(address => bool) public whitelistedTokens;

    /* An ECDSA signature. */
    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct PlastikSell {
        address buyer;
        uint256 price;
        uint256 timestamp;
        address tokenAddress;
    }

    constructor(
        address tokenAddress,
        address _tokenPool,
        address _priceSigner
    ) payable EIP712("PLASTIKSELL", "1.0") {
        _token = IERC20(tokenAddress);
        owner = msg.sender;
        tokenPool = _tokenPool;
        priceSigner = _priceSigner;
        fee = 0; // 10.00% fee is multipliee by 100
        minTokensToBuy = 0;
        maxTokensToBuy = 0;
        whitelistedTokens[0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c] = true;
        whitelistedTokens[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] = true;
        whitelistedTokens[0x55d398326f99059fF775485246999027B3197955] = true;

    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    fallback() external payable {}

    receive() external payable {}

    function setTokenPool(address pool) public virtual onlyOwner {
        tokenPool = pool;
    }

    function setFee(uint256 _fee) public virtual onlyOwner {
        fee = _fee;
    }

    function setWhitelistedToken(address _tokenAdress, bool isAllowed)
        public
        virtual
        onlyOwner
    {
        whitelistedTokens[_tokenAdress] = isAllowed;
    }

    function setMinTokensToBuy(uint256 _minToBuy) public virtual onlyOwner {
        minTokensToBuy = _minToBuy;
    }

    function setMaxTokensToBuy(uint256 _maxToBuy) public virtual onlyOwner {
        maxTokensToBuy = _maxToBuy;
    }

    function setPriceSigner(address _priceSigner) public virtual onlyOwner {
        priceSigner = _priceSigner;
    }

    function buyTokensWithAnotherToken(
        address _tokenAddress,
        uint256 _amount,
        PlastikSell calldata _sell,
        bytes calldata _signature
    ) public virtual returns (bool) {
        require(whitelistedTokens[_tokenAddress], "This token is not allowed");

        //verify signature
        address signer = verify(_sell, _signature);

        require(_tokenAddress == _sell.tokenAddress, "Token address does not match");
        
        //verify sender with _sell.buyer
        require(msg.sender == _sell.buyer, "Buyer Address does not match");
        require(priceSigner == signer, "Price Signer does not match");
        //verify time send
        require(
            block.timestamp < _sell.timestamp + 5 minutes,
            "Buy request is expired"
        );

        IERC20 coinToken = IERC20(_tokenAddress);

        require(_amount > 0, "You need to send amount > 0");
        require(
            coinToken.balanceOf(msg.sender) >= _amount,
            "There is not enough balance"
        );

        uint256 poolBalance = _token.balanceOf(tokenPool);

        uint256 amountOfTokens = calculateAmountOfTokens(_amount, _sell.price);

        require(
            amountOfTokens <= poolBalance,
            "Not enough tokens in the reserve"
        );

        if (minTokensToBuy > 0) {
            require(
                amountOfTokens >= minTokensToBuy,
                "You need to buy more tokens"
            );
        }

        if (maxTokensToBuy > 0) {
            require(
                amountOfTokens <= maxTokensToBuy,
                "You need to buy less tokens"
            );
        }

        require(
            coinToken.transferFrom(msg.sender, address(this), _amount),
            "Payment failed"
        );

        require(
            _token.transferFrom(tokenPool, msg.sender, amountOfTokens),
            "Transfer failed"
        );
        emit TokenBought(msg.sender, amountOfTokens, _sell.price);
        return true;
    }

    function buyTokens(PlastikSell calldata _sell, bytes calldata _signature)
        public
        payable
        virtual
        returns (bool)
    {

        //verify signature
        address signer = verify(_sell, _signature);
        

        //verify sender with _sell.buyer
        require(msg.sender == _sell.buyer, "Buyer Address does not match");

        require(priceSigner == signer, "Price Signer does not match");
        //verify time send
        require(
            block.timestamp < _sell.timestamp + 5 minutes,
            "Buy request is expired"
        );

        uint256 amountToBuy = msg.value;
        uint256 poolBalance = _token.balanceOf(tokenPool);

        require(amountToBuy > 0, "You need to send some ether or bnb");

        uint256 amountOfTokens = calculateAmountOfTokens(
            amountToBuy,
            _sell.price
        );


        require(
            amountOfTokens <= poolBalance,
            "Not enough tokens in the reserve"
        );

        if (minTokensToBuy > 0) {
            require(
                amountOfTokens >= minTokensToBuy,
                "You need to buy more tokens"
            );
        }

        if (maxTokensToBuy > 0) {
            require(
                amountOfTokens <= maxTokensToBuy,
                "You need to buy less tokens"
            );
        }

        // transfer token from contract wallet to sender wallet
        require(
            _token.transferFrom(tokenPool, msg.sender, amountOfTokens),
            "Transfer failed"
        );
        emit TokenBought(msg.sender, amountOfTokens, _sell.price);
        return true;
    }

    function calculateAmountOfTokens(uint256 _amount, uint256 _price)
        public
        view
        returns (uint256)
    {
        // the tokens must have 18 decimals
        uint256 amountAfterFee = _amount - ((_amount * fee) / 10000);
        return (1000000000 * amountAfterFee) / (_price);
    }

    function getContractTokens() public view returns (uint256) {
        return _token.balanceOf(address(this));
    }

    function withDraw(uint256 _amount) public onlyOwner returns (bool) {
        require(_amount <= contractBalance(), "Not enough BNB in the reserve");
        payable(owner).transfer(_amount);
        emit WithDraw(_amount, address(this).balance);
        return true;
    }

    function withDrawToken(address _tokenAddress, uint256 _amount)
        public
        onlyOwner
        returns (bool)
    {
        require(whitelistedTokens[_tokenAddress], "This token is not allowed");
        require(
            _amount <= contractTokenBalance(_tokenAddress),
            "Not enough BNB in the reserve"
        );
        require(
            IERC20(_tokenAddress).transfer(owner, _amount),
            "Withdraw failed"
        );
        return true;
    }

    function transfer(address payable _to, uint256 _amount)
        public
        onlyOwner
        returns (bool)
    {
        require(_amount <= contractBalance(), "Not enough BNB in the reserve");
        _to.transfer(_amount);
        emit Transfer(_to, _amount, address(this).balance);
        return true;
    }

    function transferToken(
        address _tokenAddress,
        address payable _to,
        uint256 _amount
    ) public onlyOwner returns (bool) {
        require(whitelistedTokens[_tokenAddress], "This token is not allowed");
        require(
            _amount <= contractTokenBalance(_tokenAddress),
            "Not enough in the reserve"
        );
        require(
            IERC20(_tokenAddress).transfer(_to, _amount),
            "Withdraw failed"
        );
        return true;
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function contractTokenBalance(address _tokenAddress)
        public
        view
        returns (uint256)
    {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function availableTokens() public view returns (uint256) {
        uint256 tokens = _token.balanceOf(tokenPool);
        uint256 allowedToSell = _token.allowance(tokenPool, address(this));
        if (tokens <= allowedToSell) {
            return tokens;
        }
        return allowedToSell;
    }

    function verify(PlastikSell calldata plastikSell, bytes memory signature)
        public
        view
        returns (address)
    {
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    Constants.PLASTIKSELL_TYPEHASH,
                    plastikSell.buyer,
                    plastikSell.price,
                    plastikSell.timestamp,
                    plastikSell.tokenAddress
                )
            )
        );
        return ECDSA.recover(digest, signature);
    }
}