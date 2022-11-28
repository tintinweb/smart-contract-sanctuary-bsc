// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./lib/OrderValidator.sol";
import "./lib/TransferHelper.sol";
import "./interfaces/IConduit.sol";
import "./interfaces/IManager.sol";
import {DEXConfig, EIP712} from "./lib/DEXConfig.sol";

contract MgNftDex is DEXConfig, ReentrancyGuard, OrderValidator, TransferHelper {


    constructor(address _feeRecipient, string memory _name, string memory _version) DEXConfig(_feeRecipient, _name, _version)  {

    }

    /**
     * @dev 链上匹配订单成交
     */
    function fulfillFixedPriceOrder(FixedPriceOrder calldata _makerOrder, bytes calldata _makerSig)
        external
        payable
        nonReentrant
    {
        // 验证订单正确性，参数为订单信息和签名信息，订单信息从中心化数据查询，签名信息从前端将订单信息打包签名
        // taker 吃单=购买者
        address taker = msg.sender;
        // 验证订单参数
        (bytes memory assetsBytes, bytes32 orderHash, bytes memory orderBytes) = validateOrder(
            _makerOrder,
            _makerSig,
            taker
        );
        // 赋值匹配状态，匹配状态成功，赋值标记成功，匹配失败，交易回滚
        ordersStatus[orderHash].matched = true;
        //买方地址
        address nftOwnerFtRecipient = taker;
        //卖方挂单地址
        address ftOwnerNftRecipient = _makerOrder.maker;

        // Reverse maker and taker  根据卖方市价单和买方限价单不同，置换maker 和 taker位置，默认是卖方市价单
        // takerGetNft  卖单的话是true, 买单的话是false
        if (_makerOrder.takerGetNft) {
            // token接收者=卖方
            nftOwnerFtRecipient = _makerOrder.maker;
            // nft 接收者= 买方
            ftOwnerNftRecipient = taker;
        }

        // transfer nft  转移支付nft
        transferNFT(_makerOrder, nftOwnerFtRecipient, ftOwnerNftRecipient);

        // transfer token  转移支付代币
        transferFT(
            _makerOrder.assets.ft,
            ftOwnerNftRecipient,
            nftOwnerFtRecipient,
            _makerOrder.assets.ftAmount,
            _makerOrder.royaltyRecipient,
            _makerOrder.royaltyRate
        );

        // emit log， 监控日志事件的十六进制数据通过abi.decode方法解析出来
        emit FixedPriceOrderMatched(_makerOrder.maker, taker, orderHash, orderBytes, assetsBytes);
    }

    /**
     * @dev 取消订单
     */
    function cancelOrder(FixedPriceOrder[] calldata _orders) external {
        address maker = msg.sender;
        for (uint256 i = 0; i < _orders.length; i++) {
            FixedPriceOrder calldata order = _orders[i];
            // Verify order base infomation
            require(maker != order.maker,"maker != order.maker");
//            if (maker != order.maker) {
//                revert MakerNotMatch(maker);
//            }

            (, , bytes32 orderHash, ) = deriveOrder(order);

            require(ordersStatus[orderHash].matched, "ordersStatus[orderHash].matched");
//            if (ordersStatus[orderHash].matched) {
//                revert OrderIsDealt(ordersStatus[orderHash].matched);
//            }
            require(ordersStatus[orderHash].cancelled, "ordersStatus[orderHash].cancelled");
//            if (ordersStatus[orderHash].cancelled) {
//                revert OrderIsCancelled(ordersStatus[orderHash].cancelled);
//            }

            ordersStatus[orderHash].cancelled = true;

            emit OrderCancelled(maker, orderHash);
        }
    }



    function _feeDenominator() internal view override returns (uint256) {
        return feeDenominator;
    }

    function _feeRate() internal view override returns (uint256) {
        return feeRate;
    }

    function _feeRecipient() internal view override returns (address) {
        return feeRecipient;
    }

    function hashOrder(bytes memory _orderBytes) public  view  override returns (bytes32) {
        return EIP712._hashTypedDataV4(keccak256(_orderBytes));
    }


    function _maxRoyaltyRate() public view override returns (uint256) {
        return maxRoyaltyRate;
    }

    /**
     * @dev  recover public address
     */
    function recover(bytes32 _hash, bytes calldata _signature)
        public
        pure
        override
        returns (address)
    {
        return ECDSA.recover(_hash, _signature);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./OrderDeriver.sol";
import "./NonceManager.sol";
import "../interfaces/IManager.sol";


abstract contract OrderValidator is NonceManager, OrderDeriver {
    mapping(bytes32 => OrderStatus) public ordersStatus;

    /**
     * @dev verify order info
     */
    function validateOrder(
        FixedPriceOrder calldata _makerOrder,
        bytes calldata _makerSig,
        address _taker
    )
        public
        view
        returns (
            bytes memory assetsBytes,
            bytes32 orderHash,
            bytes memory orderBytes
        )
    {
        // TODO:  构建签名信息
        (, assetsBytes, orderHash, orderBytes) = deriveOrder(_makerOrder);
        // 验证订单是否已经匹配过
        require(!ordersStatus[orderHash].matched, "ordersStatus[orderHash].matched");
//        if (ordersStatus[orderHash].matched) {
//            revert OrderIsDealt(ordersStatus[orderHash].matched);
//        }
        // 验证订单是否已经取消
        require(!ordersStatus[orderHash].cancelled,"ordersStatus[orderHash].cancelled");
//        if (ordersStatus[orderHash].cancelled) {
//            revert OrderIsCancelled(ordersStatus[orderHash].cancelled);
//        }
        // TODO: 恢复签名地址，判断是否是买方签名， 复写该方法
        address maker = recover(orderHash, _makerSig);
        require(!(maker != _makerOrder.maker),"maker != _makerOrder.maker");
//        if (maker != _makerOrder.maker) {
//            revert MakerNotMatch(maker);
//        }

        // 校验买卖双方是不同地址
        require(!(_makerOrder.taker != address(0) && _makerOrder.taker != _taker), "_makerOrder.taker != address(0) && _makerOrder.taker != _taker");
//        if (_makerOrder.taker != address(0) && _makerOrder.taker != _taker) {
//            revert TakerNotMatch({maker:_makerOrder.taker});
//        }
        //校验订单nonce值，前端默认传0，扩展批量取消订单的方法（预留）
        require(!(_makerOrder.makerNonce != _nonce(maker)),"_makerOrder.makerNonce != _nonce(maker)");
//        if (_makerOrder.makerNonce != _nonce(maker)) {
//            revert MakerNonceNotMatch(_makerOrder.makerNonce);
//        }
        // 校验订单开启时间
        require(!(_makerOrder.startAt > block.timestamp),"_makerOrder.startAt > block.timestamp");
//        if (_makerOrder.startAt > block.timestamp) {
//            revert OrderNotReady(_makerOrder.startAt);
//        }
        // 校验订单过期时间
        require(!(_makerOrder.expireAt <= block.timestamp),"_makerOrder.expireAt <= block.timestamp");
//        if (_makerOrder.expireAt <= block.timestamp) {
//            revert OrderIsExpired(_makerOrder.expireAt);
//        }

        require(!(maker == _taker), "maker == _taker");
//        if (maker == _taker) {
//            revert TakerEqualsMaker(maker);
//        }
        // 校验手续费
        require(!(_makerOrder.royaltyRate > _maxRoyaltyRate()), "_makerOrder.royaltyRate > _maxRoyaltyRate()");
//        if (_makerOrder.royaltyRate > _maxRoyaltyRate()) {
//            revert TooHighRoyaltyRate(_makerOrder.royaltyRate);
//        }
    }

    function _maxRoyaltyRate() public view virtual returns (uint256);

    function recover(bytes32 _hash, bytes calldata _signature)
        public
        pure
        virtual
        returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {EIP712} from "./EIP712.sol";

import "../interfaces/IManager.sol";
import "../interfaces/DEXEventsAndErrors.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract DEXConfig is EIP712, DEXEventsAndErrors, Ownable {

//    address public manager;
    //手续费分母
    uint256 public feeDenominator;
    //最大手续费
    uint256 public maxRoyaltyRate;
    //手续费
    uint256 public feeRate;
    //手续费接收地址
    address public feeRecipient;


    constructor(address _feeRecipient, string memory _name, string memory _version) EIP712(_name, _version) {
        feeRecipient = _feeRecipient;
        feeDenominator = 1000_000_000;
        // 10%
        maxRoyaltyRate = feeDenominator / 10;
        //  == 2%
        feeRate = 20_000_000; //手续费分子

    }

    function setFeeRate(uint256 _feeRate) external onlyOwner() {
        if (_feeRate > feeDenominator) {
            revert TooHighFeeRate();
        }

        feeRate = _feeRate;
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner() {
        if (_feeRecipient == address(0)) {
            revert ZeroAddress();
        }

        feeRecipient = _feeRecipient;
    }

    function setMaxRoyaltyRate(uint256 _maxRoyaltyRate) external onlyOwner() {
        if (_maxRoyaltyRate > feeDenominator) {
            revert TooHighRoyaltyRate({royaltyRate:feeDenominator});
        }

        maxRoyaltyRate = _maxRoyaltyRate;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../interfaces/IConduit.sol";

import "../interfaces/ILazyMint.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "./DEXConstantsAndStructs.sol";

//  erc20   =》 erc 721
//  erc20   =》 erc 1155
//  eth     =》 erc 721
//  eth     =》 erc  1155

//  erc721  =》 erc 20
//  erc1155 =》 erc 20
abstract contract TransferHelper is DEXConstantsAndStructs {

    /**
     * @dev transfer nft
     */
    function transferNFT(
        FixedPriceOrder calldata _order,
        address _nftOwner,
        address _nftRecipient
    ) public {
        // erc1155 transfer
        if (_order.assets.nftAmount > 0) {
            transferERC1155(
                _order.assets.nft,
                _nftOwner,
                _nftRecipient,
                _order.assets.nftId,
                _order.assets.nftAmount
            );

            return;
        }
        // erc721 transfer
        transferERC721(
            _order.assets.nft,
            _nftOwner,
            _nftRecipient,
            _order.assets.nftId
        );
    }

    /**
     * @dev erc721 transfer
     */
    function transferERC721(
        address _nftContract,
        address _nftOwner,
        address _nftRecipient,
        uint256 _nftId
    ) internal {
        _transferFrom(_nftContract, _nftOwner, _nftRecipient, _nftId);
    }

    /**
     * @dev erc1155 transfer
     */
    function transferERC1155(
        address _nftContract,
        address _nftOwner,
        address _nftRecipient,
        uint256 _nftId,
        uint256 _nftAmount
    ) public {
        _safeTransferFromERC1155(_nftContract, _nftOwner, _nftRecipient, _nftId, _nftAmount);
    }


    /**
     * @dev transfer token
     */
    function transferFT(
        address _ftContract,
        address _ftOwner,
        address _ftRecipient,
        uint256 _ftAmount,
        address _royaltyRecipient,
        uint256 _royaltyRate
    ) internal {
        uint256 feeDenominator = _feeDenominator();
        address feeRecipient = _feeRecipient();

        uint256 royaltyAmount = (_ftAmount * _royaltyRate) / feeDenominator;

        uint256 platformAmount = (_ftAmount * _feeRate()) / feeDenominator;

        uint256 remainAmount = _ftAmount - (royaltyAmount + platformAmount);

        uint256 msgVal = msg.value;

        if (_ftContract != address(0)) {
            if (msgVal != 0) {
                revert ExtraMsgValue(msgVal);
            }

            _transferFrom(_ftContract, _ftOwner, _royaltyRecipient, royaltyAmount);

            _transferFrom(_ftContract, _ftOwner, feeRecipient, platformAmount);

            _transferFrom(_ftContract, _ftOwner, _ftRecipient, remainAmount);
            return;
        }

        if (msgVal < _ftAmount) {
            revert NotEnoughMsgValue(msgVal);
        }

        if (msgVal > _ftAmount) {
            sendValue(payable(msg.sender), msgVal - _ftAmount);
        }

        sendValue(payable(_royaltyRecipient), royaltyAmount);

        sendValue(payable(feeRecipient), platformAmount);

        sendValue(payable(_ftRecipient), remainAmount);
    }

    // 授权转移
    function _transferFrom(
        address _tokenContract,
        address _tokenOwner,
        address _tokenRecipient,
        uint256 _tokenIdOrAmount
    ) public {
        bytes memory callData = abi.encodeWithSignature(
            "transferFrom(address,address,uint256)",
            _tokenOwner,
            _tokenRecipient,
            _tokenIdOrAmount
        );


         (bool status, bytes memory ret) = _tokenContract.call{value: 0}(callData);
        require(status, "status1");
//        if (!status) {
//            revert AssertCallError(status);
//        }
        require(!((ret.length > 0 && !abi.decode(ret, (bool)))), "status1");
//        if (ret.length > 0 && !abi.decode(ret, (bool))) {
//            revert TransferERC20Failed(status);
//        }

    }

    // 授权转移
    function _safeTransferFromERC1155(
        address _tokenContract,
        address _tokenOwner,
        address _tokenRecipient,
        uint256 _tokenId,
        uint256 _tokenAmount
    ) public {
        bytes memory callData = abi.encodeWithSignature(
            "safeTransferFrom(address,address,uint256,uint256,bytes)",
            _tokenOwner,
            _tokenRecipient,
            _tokenId,
            _tokenAmount,
            ""
        );


        (bool status, bytes memory ret) = _tokenContract.call{value: 0}(callData);
        if (!status) {
            revert AssertCallError(status);
        }
        if (ret.length > 0 && !abi.decode(ret, (bool))) {
            revert TransferERC20Failed(status);
        }
    }


    /**
     * @dev send eth
     */
    function sendValue(address payable _recipient, uint256 _amount) internal {
        require(!(address(this).balance < _amount), "address(this).balance < _amount");
//        if (address(this).balance < _amount) {
//            revert InsufficientBalance(address(this).balance);
//        }

        (bool success, ) = _recipient.call{value: _amount}("");
        require(success, "success1");
//        if (!success) {
//            revert UnableSendValue(success);
//        }
    }


    function _feeDenominator() internal view virtual returns (uint256);

    function _feeRate() internal view virtual returns (uint256);

    function _feeRecipient() internal view virtual returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IConduit {

    function call(address target, bytes memory data)
        external
        payable
        returns (bool status, bytes memory ret);

    function assertCall(address target, bytes memory data)
        external
        payable
        returns (bool status, bytes memory ret);

    function transferOwnership(address newOwner) external ;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IManager {
    function operators(address addr) external view returns (bool);

    function dao() external view returns (address);

    function platformDex(address addr) external view returns (bool);

    function platformNft(address addr) external view returns (bool);

    function allowedPayment(address addr) external view returns (uint256);

    function allowedNft(address addr) external view returns (bool);

    function allNftAllowed() external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
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
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./DEXConstantsAndStructs.sol";


abstract contract OrderDeriver is DEXConstantsAndStructs {

    // 订单信息处理，打包资产信息（结构体）为十六进制数据
    function hashAssets(Assets calldata assets) public pure returns (bytes32, bytes memory) {
        bytes memory assetsBytes = abi.encode(
            AssetsStructHash,
            assets.nft,
            assets.nftId,
            assets.nftAmount,
            assets.ft,
            assets.ftAmount
        );
        bytes32 hash = keccak256(assetsBytes);
        return (hash, assetsBytes);
    }

    // https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct
    function eip712Encode(FixedPriceOrder calldata _order, bytes32 _assetsHash)
        public
        pure
        returns (bytes memory orderBytes)
    {
        orderBytes = abi.encode(
            OrderStructHash,
            _order.maker,
            _order.taker,
            _order.royaltyRecipient,
            _order.royaltyRate,
            _order.startAt,
            _order.expireAt,
            _order.makerNonce,
            _order.takerGetNft,
            _assetsHash
        );
    }

    function deriveOrder(FixedPriceOrder calldata _order)
        public
        view
        returns (
            bytes32 assetsHash,
            bytes memory assetsBytes,
            bytes32 orderHash,
            bytes memory orderBytes
        )
    {
        (assetsHash, assetsBytes) = hashAssets(_order.assets);

        orderBytes = eip712Encode(_order, assetsHash);

        orderHash = hashOrder(orderBytes);
    }

    function hashOrder(bytes memory orderBytes) public view virtual returns (bytes32);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


contract NonceManager {
    // Only orders signed using an offerer's current nonce are fulfillable.
    mapping(address => uint256) private nonce_;

    // TODO: 批量取消全部挂单预留函数
    function _increaseNonce(address _address) public returns (uint256 newNonce) {
        // Skip overflow check as counter cannot be incremented that far.
        unchecked {
            newNonce = ++nonce_[_address];
        }
    }

    function _nonce(address _address) public view returns (uint256 currentNonce) {
        currentNonce = nonce_[_address];
    }

    function nonce(address _address) public view virtual returns (uint256 currentNonce) {
        currentNonce = _nonce(_address);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../interfaces/DEXEventsAndErrors.sol";

abstract contract DEXConstantsAndStructs is DEXEventsAndErrors {
    bytes32 public constant OrderStructHash =
        keccak256(
            "FixedPriceOrder(address maker,address taker,address royaltyRecipient,uint256 royaltyRate,uint64 startAt,uint64 expireAt,uint64 makerNonce,bool takerGetNft,Assets assets)Assets(address nft,uint256 nftId,uint256 nftAmount,address ft,uint256 ftAmount)"
        );

    bytes32 public constant AssetsStructHash =
        keccak256(
            "Assets(address nft,uint256 nftId,uint256 nftAmount,address ft,uint256 ftAmount)"
        );

    // 订单状态
    struct OrderStatus {
        bool matched;   // 是否已经匹配
        bool cancelled; // 是否取消
    }

    // 订单中资产信息
    struct Assets {
        // 订单nft地址
        address nft;
        // nft token id
        uint256 nftId;
        // 0 is ERC721, not 0 is ERC1155
        uint256 nftAmount;
        // address(0) means ETH, 0x000000000000000000000000000000000 0地址硬编码代表eth原生币
        address ft;
        // price
        uint256 ftAmount;
    }

    // 订单信息
    struct FixedPriceOrder {
        // 卖方
        address maker;
        // 买方
        address taker;
        // 版权费接收者
        address royaltyRecipient;
        // 版权手续费
        uint256 royaltyRate;
        // 开始时间
        uint64 startAt;
        // 订单过期时间
        uint64 expireAt;
        // nonce， 默认为0， 扩展批量取消订单预留字段
        uint64 makerNonce;
        // Reversal taker and maker， 反转买卖双方地址， 市价卖单成交状态为true, offers 报价单成交false
        bool takerGetNft;
        // 资产信息
        Assets assets;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title DEXEventsAndErrors
 * @notice DEXEventsAndErrors contains all events and errors.
 */
interface DEXEventsAndErrors {
    event OrderCancelled(address indexed maker, bytes32 indexed orderHash);

    event AllOrdersCancelled(address indexed offerer, uint256 increasedNonce);

    event FixedPriceOrderMatched(
        address indexed maker,
        address indexed taker,
        bytes32 orderHash,
        bytes orderBytes,
        bytes assetsBytes
    );

    error NotDao();

    error TooHighFeeRate();

    error ZeroAddress();

    error TooHighRoyaltyRate(uint256 royaltyRate);

    error OrderIsDealt(bool isDealt);

    error OrderIsCancelled(bool isCanceled);

    error MakerNotMatch(address maker);

    error TakerNotMatch(address maker);

    error MakerNonceNotMatch(uint256 nonce);

    error OrderNotReady(uint256 startAt);

    error OrderIsExpired(uint256 expireAt);

    error FTNotAllowed(uint256 minPrice);

    error TooLowPrice();

    error NFTNotAllowed(bool result);

    error TakerEqualsMaker(address maker);

    error OrderRoyaltyNotMatchIERC2981();

    error ExtraMsgValue(uint256 value);

    error NotEnoughMsgValue(uint256 amount);

    error InsufficientBalance(uint256 amount);

    error UnableSendValue(bool result);

    error NotFoundUserConduit();

    error AssertCallError(bool result);

    error TransferERC20Failed(bool status);


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 *
 * @custom:storage-size 52
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    string private _NAME;
    string private _VERSION;
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    constructor(string memory _name, string memory _version) {
        _NAME = _name;
        _VERSION = _version;
        _HASHED_NAME = keccak256(bytes(_name));
        _HASHED_VERSION = keccak256(bytes(_version));
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
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

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal view virtual returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal view virtual returns (bytes32) {
        return _HASHED_VERSION;
    }

    function version() public view virtual returns (string memory) {
        return _VERSION;
    }

    function name() public view virtual returns (string memory) {
        return _NAME;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface ILazyMint is IERC165 {
    function exists(uint256 tokenId) external view returns (bool);

    function lazyMint(
        address to,
        uint256 tokenId,
        address royaltyRecipient,
        uint256 royaltyRate
    ) external;

    function setRoyaltyInfo(
        uint256 tokenId,
        address receiver,
        uint256 royaltyRate
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
// OpenZeppelin Contracts (last updated v4.6.0) (interfaces/IERC2981.sol)

pragma solidity ^0.8.0;

import "../utils/introspection/IERC165.sol";

/**
 * @dev Interface for the NFT Royalty Standard.
 *
 * A standardized way to retrieve royalty payment information for non-fungible tokens (NFTs) to enable universal
 * support for royalty payments across all NFT marketplaces and ecosystem participants.
 *
 * _Available since v4.5._
 */
interface IERC2981 is IERC165 {
    /**
     * @dev Returns how much royalty is owed and to whom, based on a sale price that may be denominated in any unit of
     * exchange. The royalty amount is denominated and should be paid in that same unit of exchange.
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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