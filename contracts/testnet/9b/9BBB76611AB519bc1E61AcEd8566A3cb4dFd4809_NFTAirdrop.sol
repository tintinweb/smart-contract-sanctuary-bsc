// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface INFT {
    function safeMintMulti(
        address to,
        uint256 num,
        uint256[] memory attr
    ) external;
}

contract NFTAirdrop is Ownable {
    using Counters for Counters.Counter;

    address public admin;
    INFT public nft;

    mapping(address => bool) public isClaimed;

    Counters.Counter private _randomCounter;
    uint256 public oneStarRate;
    uint256 public twoStarRate;
    uint256 public threeStarRate;
    uint256 public fourStarRate;
    uint256 public fiveStarRate;

    event Claimed(address indexed _to, uint256 amount, uint256[] listAttr);

    constructor(address _admin, address _nft) {
        admin = _admin;
        nft = INFT(_nft);
    }

    // setter
    function setAdmin(address _admin) external onlyOwner {
        admin = _admin;
    }

    function setNFT(address _nft) external onlyOwner {
        nft = INFT(_nft);
    }

    function setRate(
        uint256 _oneStarRate,
        uint256 _twoStarRate,
        uint256 _threeStarRate,
        uint256 _fourStarRate,
        uint256 _fiveStarRate
    ) external onlyOwner {
        oneStarRate = _oneStarRate;
        twoStarRate = _twoStarRate;
        threeStarRate = _threeStarRate;
        fourStarRate = _fourStarRate;
        fiveStarRate = _fiveStarRate;
    }

    function claim(
        uint256 _amount,
        bytes memory _adminSignature,
        bytes memory _userSignature
    ) external {
        require(!isClaimed[msg.sender], "ALREADY_CLAIMED");

        require(
            verify(msg.sender, _amount, _adminSignature, _userSignature),
            "NOT_PERMITTED"
        );

        // mint
        uint256[] memory attrList = new uint256[](_amount);

        for (uint256 i = 0; i < _amount; i++) {
            _randomCounter.increment();
            uint256 randomStar = calcStar(random(i));
            attrList[i] = randomStar;
        }

        nft.safeMintMulti(msg.sender, _amount, attrList);

        isClaimed[msg.sender] = true;
        emit Claimed(msg.sender, _amount, attrList);
    }

    function verify(
        address _to,
        uint256 _amount,
        bytes memory _adminSignature,
        bytes memory _userSignature
    ) public view returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _amount);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        // whether this permission is granted from admin
        // whether this user is the user admin permits to claim
        bool isPermittedByAdmin = recoverSigner(
            ethSignedMessageHash,
            _adminSignature
        ) == admin;

        // whether this user is who he says he is
        bool isAuthenticUser = recoverSigner(
            ethSignedMessageHash,
            _userSignature
        ) == msg.sender;

        return isPermittedByAdmin && isAuthenticUser;
    }

    function getMessageHash(address _to, uint256 _amount)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_to, _amount));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format (EIP-191 compliant):
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function recoverSigner(bytes32 _messageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_messageHash, v, r, s);
    }

    function splitSignature(bytes memory _sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(_sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(_sig, 32))
            // second 32 bytes
            s := mload(add(_sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(_sig, 96)))
        }

        // implicitly return (r, s, v)
    }

    function random(uint256 _num) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        _randomCounter.current(),
                        block.timestamp,
                        blockhash(block.number - 1),
                        _num,
                        tx.origin // Because may have many random in 1 block
                    )
                )
            ) % 100;
    }

    function calcStar(uint256 _randomNum) internal view returns (uint256) {
        if (_randomNum <= oneStarRate) {
            return 1;
        } else if (
            _randomNum > oneStarRate && _randomNum <= oneStarRate + twoStarRate
        ) {
            return 2;
        } else if (
            _randomNum > oneStarRate + twoStarRate &&
            _randomNum <= oneStarRate + twoStarRate + threeStarRate
        ) {
            return 3;
        } else if (
            _randomNum > oneStarRate + twoStarRate + threeStarRate &&
            _randomNum <=
            oneStarRate + twoStarRate + threeStarRate + fourStarRate
        ) {
            return 4;
        } else {
            return 5;
        }
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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