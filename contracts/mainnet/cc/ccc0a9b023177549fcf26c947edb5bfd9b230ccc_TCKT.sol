// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// dev.kimlikdao.eth
// dev.kimlikdao.avax
address constant DEV_KASASI = 0xC152e02e54CbeaCB51785C174994c2084bd9EF51;

// kimlikdao.eth
// kimlikdao.avax
address payable constant DAO_KASASI = payable(
    0xcCc0106Dbc0291A0d5C97AAb42052Cb46dE60cCc
);
address constant DAO_KASASI_DEPLOYER = 0x0DabB96F2320A170ac0dDc985d105913D937ea9A;

// OYLAMA addresses
address constant OYLAMA = 0xcCc01Ec0E6Fb38Cce8b313c3c8dbfe66efD01cCc;
address constant OYLAMA_DEPLOYER = 0xD808C187Ef7D6f9999b6D9538C72E095db8c6df9;

// TCKT addresses
address constant TCKT_ADDR = 0xcCc0a9b023177549fcf26c947edb5bfD9B230cCc;
address constant TCKT_DEPLOYER = 0x305166299B002a9aDE0e907dEd848878FD2237D7;
address constant TCKT_SIGNERS = 0xcCc09aA0d174271259D093C598FCe9Feb2791cCc;
address constant TCKT_SIGNERS_DEPLOYER = 0x4DeA92Bcb2C22011217C089797A270DfA5A51d53;

// TCKO addresses
address constant TCKO_ADDR = 0xcCc0AC04C9251B74b0b30A20Fc7cb26EB62B0cCc;
address constant TCKO_DEPLOYER = 0xe7671eb60A45c905387df2b19A3803c6Be0Eb8f9;

// TCKOK addresses
address constant TCKOK = 0xcCc0c4e5d57d251551575CEd12Aba80B43fF1cCc;
address constant TCKOK_DEPLOYER = 0x2EF1308e8641a20b509DC90d0568b96359498BBa;

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

uint256 constant END_TS_OFFSET = 112;

uint256 constant END_TS_MASK = uint256(type(uint64).max) << 112;

uint256 constant WITHDRAW_OFFSET = 176;

uint256 constant WITHDRAW_MASK = uint256(type(uint48).max) << 176;

interface IDIDSigners {
    /**
     * Maps a signer node address to a bit packed struct.
     *
     *`signerInfo` layout:
     * |-- color --|-- withdraw --|--  endTs --|-- deposit --|-- startTs --|
     * |--   32  --|--    48    --|--   64   --|--   48    --|--   64    --|
     */
    function signerInfo(address signer) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";

interface IERC20Permit is IERC20 {
    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC721 {
    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function balanceOf(address) external view returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function supportsInterface(bytes4 interfaceId) external pure returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {DAO_KASASI, OYLAMA, TCKT_DEPLOYER, TCKT_SIGNERS} from "interfaces/Addresses.sol";
import {IDIDSigners, END_TS_OFFSET} from "interfaces/IDIDSigners.sol";
import {IERC20, IERC20Permit} from "interfaces/IERC20Permit.sol";
import {IERC721} from "interfaces/IERC721.sol";

/**
 * An ECDSA signature (over secp256k1 curve) represented in compact form.
 *
 * See https://eips.ethereum.org/EIPS/eip-2098 for more information
 * on the compact form.
 */
struct Signature {
    bytes32 r;
    uint256 yParityAndS;
}

/**
 * @title TCKT: KimlikDAO DID Token.
 *
 * TCKT is a decentralized identifier (DID) NFT which can be minted by
 * interacting with the KimlikDAO protocol. To interact with the protocol,
 * one can use the reference dApp deployed at https://kimlikdao.org or run it
 * locally by cloning the repo https://github.com/KimlikDAO/dapp and following
 * the instructions therein.
 *
 * The contents of each TCKT is cryptographically committed to a single EVM
 * address, making it unusable from any other address.
 * TCKT implements most of the ERC-721 NFT interface excluding, notably, the
 * transfer-related methods, since TCKTs are non-transferrable.
 *
 * Minting
 * ========
 * One can mint a TCKT by using the various flavors of the `create()` method.
 * These methods differ in the payment type and whether a revoker list is
 * included. A discount is offerent for including a revoker list, which
 * increases security as explained below.
 *
 * Revoking
 * =========
 * A TCKT owner may call the `revoke()` method of a TCKT at any time to revoke
 * it, thereby making it unusable. This is useful, for example, when a user
 * gets their wallet private keys stolen.
 *
 * Social revoking
 * ================
 * When minting a TCKT, you can nominate 3-5 addresses as revokers, assign each
 * a weight and choose a revoke threshold. If enough of these addresses vote to
 * revoke the TCKT (with total weight at least the chosen threshold), it will
 * be revoked and become unusable.
 *
 * This feature is useful in the event that your wallet private keys are stolen
 * and, further, you no longer have access to them. In such circumstances, you
 * can inform the nominated revokers and request them to cast a revoke vote.
 *
 * To encourage setting up social revoke, a discount of 33% is offered
 * initially, and the discount rate is determined by the DAO vote thereafter.
 * The discount rate is set through the `updatePricesBulk()` method, which can
 * only be called by `OYLAMA`, the KimlikDAO voting contract.
 * (https://github.com/KimlikDAO/Oylama)
 *
 * Exposure report
 * ================
 * In the case a TCKT holder
 *
 *   1) gets their private keys stolen, and
 *   2) lose access to the keys themselves, and
 *   3) did not set up social revoke when minting the TCKT,
 *
 * there is one final way of disabling the stolen TCKT. The victim mints a new
 * TCKT and submits the `exposureReport` that comes with it to the
 * `reportExposure()` method of this contract. Doing so will disable *all*
 * previous TCKTs across all chains belonging to this person. For convenience,
 * one may use the interface at https://kimlikdao.org/report to submit the
 * `exposureReport` to the TCKT contract.
 *
 * Modifying the revoker list
 * ===========================
 * One can add new revokers, increase the weight of existing revokers or reduce
 * the revoke threshold after minting their TCKT by invoking the corresponding
 * methods of this contract. Removing a revoker is not possible since it would
 * allow an attacker having access to user privates key to remove all revokers.
 *
 * Pricing and payments
 * =====================
 * The price of a TCKT is set by the `updatePrice()` or the `updatePricesBulk()`
 * methods, which can only be called by `OYLAMA`, the KimlikDAO voting
 * contract.
 *
 * Fees collected as an ERC-20 token are transferred directly to the
 * `DAO_KASASI`, the KimlikDAO treasury and fees collected in the native token
 * are accumulated in this contract first and then swept to `DAO_KASASI`
 * periodically. The sweep mechanism was put in place to minimize the gas cost
 * of minting a TCKT. The sweep is completely permissionless; anyone can call
 * the `sweepNativeToken()` to transfer the native token balance of this
 * contract over to `DAO_KASASI`. Further, weekly sweeps are done by KimlikDAO
 * automation, covering the gas fee.
 *
 * @author KimlikDAO (https://kimlikdao.org)
 */
contract TCKT is IERC721 {
    /**
     * Returns the KimlikDAO protocol IPFS handle (in compact form) of an
     * address or zero if the address does not have a TCKT.
     */
    mapping(address => uint256) public handleOf;

    function name() external pure override returns (string memory) {
        return "KimlikDAO Kimlik Tokeni";
    }

    function symbol() external pure override returns (string memory) {
        return "TCKT";
    }

    /**
     * Returns the number of TCKTs in a given account, which can be 0 or 1.
     *
     * Each account can hold at most one TCKT, however a new TCKT can be minted
     * to the same address at any time replacing the previous one. While
     * obtaining a TCKT is subject to a KimlikDAO fee, subsequent updates can
     * be done by only paying the network fee.
     */
    function balanceOf(address addr) external view override returns (uint256) {
        return handleOf[addr] == 0 ? 0 : 1;
    }

    /**
     * Returns the URI of a TCKT with the given id (handle).
     *
     * @dev The handle of each TCKT is a compact representation of its
     * KimlikDAO protocol IPFS cid. Given the handle, the IPFS cid can be
     * obtained as
     *
     *     base58([0x12, 0x20, handle]).
     *
     * This method computes this value in a a gas efficient manner.
     */
    function tokenURI(uint256 id)
        external
        pure
        override
        returns (string memory)
    {
        unchecked {
            bytes memory toChar = bytes(
                "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
            );
            uint256 magic = 0x4e5a461f976ce5b9229582822e96e6269e5d6f18a5960a04480c6825748ba04;
            bytes
                memory out = "https://ipfs.kimlikdao.org/ipfs/Qm____________________________________________";
            out[77] = toChar[id % 58];
            id /= 58;
            for (uint256 p = 76; p > 34; --p) {
                uint256 t = id + (magic & 63);
                out[p] = toChar[t % 58];
                magic >>= 6;
                id = t / 58;
            }
            out[34] = toChar[id + 21];
            return string(out);
        }
    }

    /**
     * Returns whether a given ERC-165 interface is supported.
     *
     * Here we claim to support the full ERC-721 interface so that wallets
     * recognize TCKT as an NFT, even though we do not implement transfer
     * related methods since TCKTs are non-transferrable.
     *
     * See https://eips.ethereum.org/EIPS/eip-165 for more information.
     *
     * @param                  interfaceId to check support for.
     */
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 interface ID for ERC165.
            interfaceId == 0x80ac58cd || // ERC165 interface ID for ERC721.
            interfaceId == 0x5b5e139f; // ERC165 interface ID for ERC721Metadata.
    }

    /**
     * Creates a new TCKT and collects the fee in the native token.
     *
     * @param                  handle the compact encoding of the IPFS handle.
     */
    function create(uint256 handle) external payable {
        require(msg.value >= (priceIn[address(0)] >> 128));
        handleOf[msg.sender] = handle;
        emit Transfer(address(this), msg.sender, handle);
    }

    /**
     * Transfers the entire native token balance of this contract to
     * `DAO_KASASI`.
     *
     * @dev To optimize the TCKT creation gas fees, we do not forward fees
     * collected in the networks native token to `DAO_KASASI` in each TCKT
     * creation.
     *
     * Instead, the fees are accumulated in this contract until the following
     * method is called. The method is fully permissionless and can be invoked
     * by anyone. Further, KimlikDAO does weekly sweeps, again using this
     * method and covering the gas fee.
     *
     * @dev `DAO_KASASI` has an empty `receive()` method therefore the
     * `transfer()` below should have enough gas to complete.
     */
    function sweepNativeToken() external {
        DAO_KASASI.transfer(address(this).balance);
    }

    /**
     * Moves ERC-20 tokens sent to this address by accident to `DAO_KASASI`.
     */
    function sweepToken(IERC20 token) external {
        token.transfer(DAO_KASASI, token.balanceOf(address(this)));
    }

    /**
     * Creates a new TCKT with the given social revokers and collects the fee
     * in the native token.
     *
     * @param handle           IPFS handle of the persisted TCKT.
     * @param revokers         A list of pairs (weight, address), bit packed
     *                         into a single word, where the weight is a uint96
     *                         and the address is 20 bytes. Further, the first
     *                         word contains the revokeThreshold in the
     *                         leftmost 64 bits.
     */
    function createWithRevokers(uint256 handle, uint256[5] calldata revokers)
        external
        payable
    {
        require(msg.value >= uint128(priceIn[address(0)]));
        handleOf[msg.sender] = handle;
        emit Transfer(address(this), msg.sender, handle);
        setRevokers(revokers);
    }

    /**
     * Creates a new TCKT collecting the fee in the provided `token`.
     *
     * This method works only with DAO approved tokens: the token must have
     * been approved and set a nonzero price by the DAO vote beforehand.
     *
     * @param handle           IPFS handle of the persisted TCKT.
     * @param token            Contract address of an ERC-20 token.
     */
    function createWithTokenPayment(uint256 handle, IERC20 token) external {
        uint256 price = priceIn[address(token)] >> 128;
        require(price > 0);
        token.transferFrom(msg.sender, DAO_KASASI, price);
        handleOf[msg.sender] = handle;
        emit Transfer(address(this), msg.sender, handle);
    }

    /**
     * Creates a TCKT and collects the fee in the provided `token` using the
     * provided ERC-2612 permit signature.
     *
     * The provided token has to be IERC20Permit, in particular, it needs to
     * support approval by signature.
     *
     * Note if a price change occurs between the moment the user signs off the
     * payment and this method is called, the method call will fail as the
     * signature will be invalid. However, the price changes happen at most
     * once a week and off peak hours by the DAO vote.
     *
     * See https://eips.ethereum.org/EIPS/eip-2612 for more information on the
     * ERC-20 permit extension.
     *
     * @param handle           IPFS handle of the persisted TCKT.
     * @param deadlineAndToken Contract address of a IERC20Permit token and
     *                         the timestamp until which the payment
     *                         authorization is valid for.
     * @param signature        Signature authorizing the token spend.
     */
    function createWithTokenPermit(
        uint256 handle,
        uint256 deadlineAndToken,
        Signature calldata signature
    ) external {
        IERC20Permit token = IERC20Permit(address(uint160(deadlineAndToken)));
        uint256 price = priceIn[address(token)] >> 128;
        require(price > 0);
        unchecked {
            token.permit(
                msg.sender,
                address(this),
                price,
                deadlineAndToken >> 160,
                uint8(signature.yParityAndS >> 255) + 27,
                signature.r,
                bytes32(signature.yParityAndS & ((1 << 255) - 1))
            );
        }
        token.transferFrom(msg.sender, DAO_KASASI, price);
        handleOf[msg.sender] = handle;
        emit Transfer(address(this), msg.sender, handle);
    }

    /**
     * @param handle           IPFS handle of the persisted TCKT.
     * @param revokers         A list of pairs (weight, address), bit packed
     *                         into a single word, where the weight is a uint96
     *                         and the address is 20 bytes.
     * @param token            Contract address of a IERC20Permit token.
     */
    function createWithRevokersWithTokenPayment(
        uint256 handle,
        uint256[5] calldata revokers,
        IERC20 token
    ) external {
        uint256 price = uint128(priceIn[address(token)]);
        require(price > 0);
        token.transferFrom(msg.sender, DAO_KASASI, price);
        handleOf[msg.sender] = handle;
        emit Transfer(address(this), msg.sender, handle);
        setRevokers(revokers);
    }

    /**
     * @param handle           IPFS handle of the persisted TCKT.
     * @param revokers         A list of pairs (weight, address), bit packed
     *                         into a single word, where the weight is a uint96
     *                         and the address is 20 bytes.
     * @param deadlineAndToken Contract address of a IERC20Permit token.
     * @param signature        Signature authorizing the token spend.
     */
    function createWithRevokersWithTokenPermit(
        uint256 handle,
        uint256[5] calldata revokers,
        uint256 deadlineAndToken,
        Signature calldata signature
    ) external {
        IERC20Permit token = IERC20Permit(address(uint160(deadlineAndToken)));
        uint256 price = uint128(priceIn[address(token)]);
        require(price > 0);
        unchecked {
            token.permit(
                msg.sender,
                address(this),
                price,
                deadlineAndToken >> 160,
                uint8(signature.yParityAndS >> 255) + 27,
                signature.r,
                bytes32(signature.yParityAndS & ((1 << 255) - 1))
            );
        }
        token.transferFrom(msg.sender, DAO_KASASI, price);
        handleOf[msg.sender] = handle;
        emit Transfer(address(this), msg.sender, handle);
        setRevokers(revokers);
    }

    // keccak256(
    //     abi.encode(
    //         keccak256(
    //             "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    //         ),
    //         keccak256(bytes("TCKT")),
    //         keccak256(bytes("1")),
    //         43114,
    //         0xcCc0FD2f0D06873683aC90e8d89B79d62236BcCc
    //     )
    // );
    bytes32 public constant DOMAIN_SEPARATOR =
        0xe0e78e60d5cbd73f8fbb5ea3442cd6d0375f3e38a0e62fb21a11bf7c87f47465;

    // keccak256("CreateFor(uint256 handle)")
    bytes32 public constant CREATE_FOR_TYPEHASH =
        0xe0b70ef26ac646b5fe42b7831a9d039e8afa04a2698e03b3321e5ca3516efe70;

    /**
     * Creates a TCKT on users behalf, covering the transaction fee.
     *
     * The user has to explicitly authorize the TCKT creation with the
     * `createSig` and the token payment with the `paymentSig`.
     *
     * The gas fee is paid by the transaction sender, which can be either
     * `OYLAMA` or `TCKT_DEPLOYER`. We restrict the method to these two
     * addresses since the intent of a signature request is not as clear as
     * that of a transaction and therefore a user may be tricked into creating
     * a TCKT with incorrect and invalid contents. Note this restriction is not
     * about TCKTs soundness; even if we made this method unrestricted, only the
     * account owner could have created a valid TCKT. Still, we do not want
     * users to be tricked into creating invalid TCKTs for whatever reason.
     *
     * @param handle           IPFS handle with which to create the TCKT.
     * @param createSig        Signature endorsing the TCKT creation.
     * @param deadlineAndToken The payment token and the deadline for the token
     *                         permit signature.
     * @param paymentSig       Token spend permission from the TCKT creator.
     */
    function createFor(
        uint256 handle,
        Signature calldata createSig,
        uint256 deadlineAndToken,
        Signature calldata paymentSig
    ) external {
        require(msg.sender == OYLAMA || msg.sender == TCKT_DEPLOYER);
        IERC20Permit token = IERC20Permit(address(uint160(deadlineAndToken)));
        uint256 price = priceIn[address(token)] >> 128;
        require(price > 0);
        unchecked {
            bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(abi.encode(CREATE_FOR_TYPEHASH, handle))
                )
            );
            address signer = ecrecover(
                digest,
                uint8(createSig.yParityAndS >> 255) + 27,
                createSig.r,
                bytes32(createSig.yParityAndS & ((1 << 255) - 1))
            );
            require(signer != address(0) && handleOf[signer] == 0);
            token.permit(
                signer,
                address(this),
                price,
                deadlineAndToken >> 160,
                uint8(paymentSig.yParityAndS >> 255) + 27,
                paymentSig.r,
                bytes32(paymentSig.yParityAndS & ((1 << 255) - 1))
            );
            token.transferFrom(signer, DAO_KASASI, price);
            handleOf[signer] = handle;
            emit Transfer(address(this), signer, handle);
        }
    }

    /**
     * @param handle           Updates the contents of the TCKT with the given
     *                         IPFS handle.
     */
    function update(uint256 handle) external {
        require(handleOf[msg.sender] != 0);
        handleOf[msg.sender] = handle;
    }

    ///////////////////////////////////////////////////////////////////////////
    //
    // Revoking related fields and methods
    //
    ///////////////////////////////////////////////////////////////////////////

    event RevokerAssignment(
        address indexed owner,
        address indexed revoker,
        uint256 weight
    );

    // keccak256("RevokeFriendFor(address friend)");
    bytes32 public constant REVOKE_FRIEND_FOR_TYPEHASH =
        0xfbf2f0fb915c060d6b3043ea7458b132e0cbcd7973bac5644e78e4f17cd28b8e;

    uint256 private constant REVOKES_REMAINING_MASK =
        uint256(type(uint64).max) << 192;

    mapping(address => mapping(address => uint256)) public revokerWeight;

    // `revokeInfo` layout:
    // |-- revokesRemaining --|--   empty   --|-- lastRevokeTimestamp --|
    // |--        64        --|--    128    --|--          64         --|
    mapping(address => uint256) public revokeInfo;

    function revokesRemaining() external view returns (uint256) {
        return revokeInfo[msg.sender] >> 192;
    }

    /**
     * Returns the timestamp of the most recent revoke event for this account.
     *
     * All TCKTs obtained before this timestamp on this address across all
     * chains are considered invalid.
     *
     * If no revoke event happened, the zero value is returned.
     *
     * @return timestamp of the last revoke event, or zero if none happened.
     */
    function lastRevokeTimestamp(address addr) external view returns (uint64) {
        return uint64(revokeInfo[addr]);
    }

    function setRevokers(uint256[5] calldata revokers) internal {
        revokeInfo[msg.sender] =
            (revokeInfo[msg.sender] & type(uint64).max) |
            (revokers[0] & REVOKES_REMAINING_MASK);

        address rev0Addr = address(uint160(revokers[0]));
        uint256 rev0Weight = (revokers[0] >> 160) & type(uint32).max;
        require(rev0Addr != address(0) && rev0Addr != msg.sender);
        revokerWeight[msg.sender][rev0Addr] = rev0Weight;
        emit RevokerAssignment(msg.sender, rev0Addr, rev0Weight);

        address rev1Addr = address(uint160(revokers[1]));
        require(rev1Addr != address(0) && rev1Addr != msg.sender);
        require(rev1Addr != rev0Addr);
        revokerWeight[msg.sender][rev1Addr] = revokers[1] >> 160;
        emit RevokerAssignment(msg.sender, rev1Addr, revokers[1] >> 160);

        address rev2Addr = address(uint160(revokers[2]));
        require(rev2Addr != address(0) && rev2Addr != msg.sender);
        require(rev2Addr != rev1Addr && rev2Addr != rev0Addr);
        revokerWeight[msg.sender][rev2Addr] = revokers[2] >> 160;
        emit RevokerAssignment(msg.sender, rev2Addr, revokers[2] >> 160);

        address rev3Addr = address(uint160(revokers[3]));
        if (rev3Addr == address(0)) return;
        revokerWeight[msg.sender][rev3Addr] = revokers[3] >> 160;
        emit RevokerAssignment(msg.sender, rev3Addr, revokers[3] >> 160);

        address rev4Addr = address(uint160(revokers[4]));
        if (rev4Addr == address(0)) return;
        revokerWeight[msg.sender][rev4Addr] = revokers[4] >> 160;
        emit RevokerAssignment(msg.sender, rev4Addr, revokers[4] >> 160);
    }

    /**
     * Revokes user's own TCKT, rendering it invalid.
     *
     * The owner may delete their TCKT at any time using this method.
     */
    function revoke() external {
        emit Transfer(msg.sender, address(this), handleOf[msg.sender]);
        revokeInfo[msg.sender] = block.timestamp;
        delete handleOf[msg.sender];
    }

    /**
     * Casts a "social revoke" vote on a friends TCKT.
     *
     * If a friend has granted the user a nonzero "social revoke" weight, the
     * user can invoke this method to cast a "social revoke" vote on their
     * friends TCKT. After calling this method, the users revoke weight is set
     * to zero.
     *
     * @param friend           The wallet address of a friends TCKT.
     */
    function revokeFriend(address friend) external {
        uint256 revInfo = revokeInfo[friend];
        uint256 senderWeight = revokerWeight[friend][msg.sender] << 192;

        require(senderWeight > 0);
        delete revokerWeight[friend][msg.sender];

        unchecked {
            if (senderWeight >= (revInfo & REVOKES_REMAINING_MASK)) {
                revokeInfo[friend] = block.timestamp;
                if (handleOf[friend] != 0) {
                    emit Transfer(friend, address(this), handleOf[friend]);
                    delete handleOf[friend];
                }
            } else revokeInfo[friend] = revInfo - senderWeight;
        }
    }

    /**
     * Casts a social revoke vote for a friend on `signature` creators behalf.
     *
     * This method is particularly useful when the revoker is virtual; the TCKT
     * owner generates a private key and immediately signs a `revokeFriendFor`
     * request and emails the signature to a fiend. This way a friend without an
     * EVM adress (but an email address) can cast a social revoke vote.
     *
     * @param friend           Account whose TCKT will be cast a revoke vote.
     * @param signature        Signature from the revoker, authorizing a revoke
     *                         for `friend`.
     */
    function revokeFriendFor(address friend, Signature calldata signature)
        external
    {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(REVOKE_FRIEND_FOR_TYPEHASH, friend))
            )
        );
        unchecked {
            address revoker = ecrecover(
                digest,
                uint8(signature.yParityAndS >> 255) + 27,
                signature.r,
                bytes32(signature.yParityAndS & ((1 << 255) - 1))
            );
            require(revoker != address(0));
            uint256 revInfo = revokeInfo[friend];
            uint256 revokerW = revokerWeight[friend][revoker] << 192;
            // revokerW > 0 if and only if revokerWeight[friend][revoker] > 0.
            require(revokerW > 0);
            delete revokerWeight[friend][revoker];

            if (revokerW >= (revInfo & REVOKES_REMAINING_MASK)) {
                revokeInfo[friend] = block.timestamp;
                if (handleOf[friend] != 0) {
                    emit Transfer(friend, address(this), handleOf[friend]);
                    delete handleOf[friend];
                }
            } else revokeInfo[friend] = revInfo - revokerW;
        }
    }

    /**
     * Adds a revoker or increase a revokers weight.
     *
     * @param deltaAndRevoker  Address who is given the revoke vote permission
     *                         and the added weight packed into a single word.
     *                         The first 4 bytes have to be zero, the following
     *                         8 bytes encode the added weight and the last 20
     *                         bytes are the revoker address.
     */
    function addRevoker(uint256 deltaAndRevoker) external {
        address revoker = address(uint160(deltaAndRevoker));
        unchecked {
            uint256 weight = revokerWeight[msg.sender][revoker] +
                (deltaAndRevoker >> 160);
            // Even after a complete compromise of the wallet private key, the
            // attacker should not be able to decrease revoker weights by
            // overflowing.
            require(weight <= type(uint64).max);
            revokerWeight[msg.sender][revoker] = weight;
            emit RevokerAssignment(msg.sender, revoker, weight);
        }
    }

    /**
     * Reduces a TCKTs revoke threshold by the given amount.
     *
     * @param reduce           The amount to reduce.
     */
    function reduceRevokeThreshold(uint256 reduce) external {
        uint256 threshold = revokeInfo[msg.sender] >> 192;
        revokeInfo[msg.sender] = (threshold - reduce) << 192; // Checked substraction
    }

    ///////////////////////////////////////////////////////////////////////////
    //
    // Price fields and methods
    //
    ///////////////////////////////////////////////////////////////////////////

    event PriceChange(address indexed token, uint256 price);

    /**
     * The multiplicative premium for getting a TCKT wihout setting up social
     * revoke. The initial value is 3/2, and adjusted by the DAO vote
     * thereafter.
     */
    uint256 private revokerlessPremium = (3 << 128) | uint256(2);

    /**
     * The price of creating a TCKT with and without a revoker list denominated
     * in a given token.
     *
     * The first 128 bytes of the returned vaule denotes the price without a
     * revoker list and the last 128 bytes are the discounted price for setting
     * up social revoke.
     *
     * The address 0 is understood as the native token.
     */
    mapping(address => uint256) public priceIn;

    constructor() {
        priceIn[0x0000000000000000000000000000000000000000] =
            (0.0050e18 << 128) |
            0.0034e18;
        priceIn[0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d] =
            (1.5e18 << 128) |
            1e18;
        priceIn[0xC1fdbed7Dac39caE2CcC0748f7a80dC446F6a594] =
            (28.5e6 << 128) |
            19e6;
        priceIn[0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56] =
            (1.5e18 << 128) |
            1e18;
    }

    /**
     * Updates TCKT prices in a given list of tokens.
     *
     * @param premium          The multiplicative price premium for getting a
     *                         TCKT without specifying a social revokers list.
     *                         The 256-bit value is understood as 128-bit
     *                         numerator followed by 128-bit denominator.
     * @param prices           A list of tuples (price, address) where the
     *                         price is an uint96 and the address is 20 bytes.
     */
    function updatePricesBulk(uint256 premium, uint256[5] calldata prices)
        external
    {
        require(msg.sender == OYLAMA);
        unchecked {
            revokerlessPremium = premium;
            for (uint256 i = 0; i < 5; ++i) {
                if (prices[i] == 0) break;
                address token = address(uint160(prices[i]));
                uint256 price = prices[i] >> 160;
                uint256 t = (price * premium) / uint128(premium);
                priceIn[token] = (t & (type(uint256).max << 128)) | price;
                emit PriceChange(token, price);
            }
        }
    }

    /**
     * Updates the price of a TCKT denominated in a given token.
     *
     * @param priceAndToken    The price as a 96 bit integer, followed by the
     *                         token address for a ERC-20 token or the zero
     *                         address, which is understood as the native
     *                         token.
     */
    function updatePrice(uint256 priceAndToken) external {
        require(msg.sender == OYLAMA);
        unchecked {
            address token = address(uint160(priceAndToken));
            uint256 price = priceAndToken >> 160;
            uint256 premium = revokerlessPremium;
            uint256 t = (price * premium) / uint128(premium);
            priceIn[token] = (t & (type(uint256).max << 128)) | price;
            emit PriceChange(token, price);
        }
    }
}