/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

/**
 *Submitted for verification at polygonscan.com on 2022-02-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

//SPDX-License-Identifier: UNLICENSE
pragma solidity 0.8.11;

// interface
interface IBEP721 {
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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the BEP721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IBEP721Receiver-onBEP721Received}, which is called upon a safe transfer.
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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IBEP721Receiver-onBEP721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IBEP1155 {
    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

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
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IBEP1155Receiver-onBEP1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

interface ILazyMintBEP721 {
    function safeMint(
        address to,
        string memory uri,
        uint256 blockExpiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

interface ILazyMintBEP1155 {
    function mint(
        address to,
        uint256 id,
        uint256 blockExpiry,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 supply,
        string memory uri
    ) external returns (bool);
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// abtract contract
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// library
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
}

// Market place
contract HerosExchange is Ownable {

    address beneficiary;
    uint beneficiaryFee = 100; // 1000 = 10%
    uint denominator = 10000;

    bytes32 public MARKET_PLACE = keccak256("MARKET_PLACE");

    mapping(uint => OrderStruct) public fixedOrders;
    mapping(bytes32 => bool) public isHashExsit;
    mapping(address => bool) public operators;

    struct ExchangeStruct {
        address token; /*token address*/
        uint id; /*nft id*/
        uint price;/*price*/
    }

    struct AssetStruct {
        address token; /*token address*/
        uint id; /*nft id*/
        uint quantity; /*quantity*/
        uint8 tokenType; /*token type*/
    }
    
    struct OrderStruct {
        uint sequenceID; /*sequence id*/
        address user; /*user address*/
        AssetStruct asset; /*asset details*/
        ExchangeStruct exchangeFor; /*exchange details*/
        bool isSell; /*if sell true*/
        uint salt; /*random salt*/
        uint expiry; /*expiry time*/
        uint8 v; /*signature v*/
        bytes32 r; /*signature r*/
        bytes32 s; /*signature s*/
    }

    struct LazyMintStruct {
        uint256 expiry;
        uint256 supply;
        uint8 v;
        bytes32 r;
        bytes32 s;
        string uri;
    }

    constructor( address newBeneficiary, uint newBeneficiaryFee) {
        setBeneficiary( newBeneficiary);
        setBeneficiaryFee( newBeneficiaryFee);

        bytes32 messageHash = createLazyMintHash(
            LazyMintStruct(
                0,
                0,
                0,
                MARKET_PLACE,
                MARKET_PLACE,
                "uri"
            )
        );

        isHashExsit[messageHash] = true;
    }

    function auctionExecution( OrderStruct memory makerOrder, OrderStruct memory takerOrder, LazyMintStruct memory lazyMint, address royaltyAddress, uint royaltyFee) public {
        require(validateOrder(makerOrder) == makerOrder.user, "auctionExecution : incorrect maker signature");
        require(validateOrder(takerOrder) == takerOrder.user, "auctionExecution : incorrect taker signature");
        require(((royaltyAddress == address(0)) && (royaltyFee == 0)) || ((royaltyAddress != address(0)) && (royaltyFee > 0)),"Invalid Royaltyfee and address");
        
        if (makerOrder.isSell) {
            if(makerOrder.asset.tokenType == 2) { 
                _lazyMintBEP1155( lazyMint, makerOrder.asset.token, makerOrder.user, makerOrder.asset.id);
            } else if (makerOrder.asset.tokenType == 1) {
                _lazyMintBEP721( lazyMint, makerOrder.asset.token, makerOrder.user);
            }
        } else if(takerOrder.isSell) { 
            if(takerOrder.asset.tokenType == 2) {
                _lazyMintBEP1155( lazyMint, takerOrder.asset.token, takerOrder.user, takerOrder.asset.id);
            } else if (takerOrder.asset.tokenType == 1) {
                _lazyMintBEP721( lazyMint, takerOrder.asset.token, takerOrder.user);
            }
        }

        validateOrdersType( makerOrder, takerOrder);
        exchange( makerOrder, takerOrder, royaltyAddress, royaltyFee, 1);
    }

    // maker is the executor and taker is the receiver
    function fixedOrderExecution( OrderStruct memory makerOrder, OrderStruct memory takerOrder, LazyMintStruct memory lazyMint, address royaltyAddress, uint royaltyFee) public {
        require(((royaltyAddress == address(0)) && (royaltyFee == 0)) || ((royaltyAddress != address(0)) && (royaltyFee > 0)),"Invalid Royaltyfee and address");
        if(fixedOrders[makerOrder.sequenceID].expiry == 0) 
            require(validateOrder(makerOrder) == makerOrder.user, "fixedOrderExecution : incorrect maker signature");
        else 
            require(fixedOrders[makerOrder.sequenceID].expiry > block.timestamp, "fixedOrderExecution : exceed makerOrder expiry time");

        if(fixedOrders[takerOrder.sequenceID].expiry == 0)
            require(validateOrder(takerOrder) == takerOrder.user, "fixedOrderExecution : incorrect taker signature");
        else 
            require(fixedOrders[takerOrder.sequenceID].expiry > block.timestamp, "fixedOrderExecution : exceed takerOrder expiry time");

	   

        if (makerOrder.isSell) {
            if(makerOrder.asset.tokenType == 2) { 
                storeFixedSellOrder( makerOrder, takerOrder.exchangeFor.price);
                _lazyMintBEP1155( lazyMint, makerOrder.asset.token, makerOrder.user, makerOrder.asset.id);
            } else if (makerOrder.asset.tokenType == 1) {
                _lazyMintBEP721( lazyMint, makerOrder.asset.token, makerOrder.user);
            }
        } else if(takerOrder.isSell) { 
            if(takerOrder.asset.tokenType == 2) {
                storeFixedSellOrder( takerOrder, makerOrder.exchangeFor.price); 
                _lazyMintBEP1155( lazyMint, takerOrder.asset.token, takerOrder.user, takerOrder.asset.id);
            } else if (takerOrder.asset.tokenType == 1) {
                _lazyMintBEP721( lazyMint, takerOrder.asset.token, takerOrder.user);
            }
        }

        validateOrdersType( makerOrder, takerOrder);
        exchange( makerOrder, takerOrder, royaltyAddress, royaltyFee, 0);  
    }

    function exchange( OrderStruct memory makerOrder, OrderStruct memory takerOrder, address royaltyAddress, uint royaltyFee, uint8 executionType ) private returns (bool) {
        uint platformFee; 
        uint royaltyFees;
        uint price;

        bool exeType = (executionType == 0) ? true/* fixed */ : false/* auction */;

        if(((makerOrder.asset.tokenType == 0) && (takerOrder.asset.tokenType == 1)) || ((makerOrder.asset.tokenType == 1) && (takerOrder.asset.tokenType == 0))) {
            
            if(makerOrder.asset.tokenType == 0) {
                (platformFee, royaltyFees, price) = calculateFees(
                    (exeType != makerOrder.isSell) ? makerOrder.asset.quantity : takerOrder.exchangeFor.price,
                    beneficiaryFee,
                    royaltyFee
                );

                //Fees
                sendBEP20(IBEP20(takerOrder.exchangeFor.token), makerOrder.user, beneficiary, platformFee);
                sendBEP20(IBEP20(takerOrder.exchangeFor.token), makerOrder.user, royaltyAddress, royaltyFees);
                //Swap
                sendBEP20(IBEP20(takerOrder.exchangeFor.token), makerOrder.user, takerOrder.user, price);
                sendBEP721(IBEP721(makerOrder.exchangeFor.token), takerOrder.user, makerOrder.user, makerOrder.exchangeFor.id);
            } else {                
                (platformFee, royaltyFees, price) = calculateFees(
                    (exeType != makerOrder.isSell) ? takerOrder.asset.quantity : makerOrder.exchangeFor.price, 
                    beneficiaryFee, 
                    royaltyFee
                );
               

                //Fees
                sendBEP20(IBEP20(makerOrder.exchangeFor.token), takerOrder.user, beneficiary, platformFee);
                sendBEP20(IBEP20(makerOrder.exchangeFor.token), takerOrder.user, royaltyAddress, royaltyFees);
                //Swap
                sendBEP20(IBEP20(makerOrder.exchangeFor.token), takerOrder.user, makerOrder.user, price);
                sendBEP721(IBEP721(takerOrder.exchangeFor.token), makerOrder.user, takerOrder.user, takerOrder.exchangeFor.id);
            }
        } else if(((makerOrder.asset.tokenType == 0) && (takerOrder.asset.tokenType == 2)) || ((makerOrder.asset.tokenType == 2) && (takerOrder.asset.tokenType == 0))) {
            
            if(makerOrder.asset.tokenType == 0) {
                if((exeType) && (fixedOrders[takerOrder.sequenceID].expiry > 0)) {
                    takerOrder = fixedOrders[takerOrder.sequenceID];
                }
                
                require(makerOrder.exchangeFor.price <= takerOrder.asset.quantity, "exchange : buyer price exceed the quantity or all copies were sold");

                (platformFee, royaltyFees, price) = calculateFees(
                    (((exeType != makerOrder.isSell) ?  takerOrder.exchangeFor.price : makerOrder.asset.quantity ) * makerOrder.exchangeFor.price /*no of copies*/),
                    beneficiaryFee,
                    royaltyFee
                );

                //Fees
                sendBEP20(IBEP20(takerOrder.exchangeFor.token), makerOrder.user, beneficiary, platformFee);
                sendBEP20(IBEP20(takerOrder.exchangeFor.token), makerOrder.user, royaltyAddress, royaltyFees);
                //Swap
                sendBEP20(IBEP20(takerOrder.exchangeFor.token), makerOrder.user, takerOrder.user, price);
                sendBEP1155( IBEP1155(makerOrder.exchangeFor.token), takerOrder.user, makerOrder.user, takerOrder.asset.id, makerOrder.exchangeFor.price);
                
                if((exeType) && (fixedOrders[takerOrder.sequenceID].expiry > 0)) {
                    fixedOrders[takerOrder.sequenceID].asset.quantity -= makerOrder.exchangeFor.price;
                }
            } else {
                if((exeType) && (fixedOrders[makerOrder.sequenceID].expiry > 0)) {
                    makerOrder = fixedOrders[makerOrder.sequenceID];
                }

                require(takerOrder.exchangeFor.price <= makerOrder.asset.quantity, "exchange : buyer price exceed the quantity or all copies were sold");

                (platformFee, royaltyFees, price) = calculateFees(
                    (((exeType != makerOrder.isSell) ? takerOrder.asset.quantity : makerOrder.exchangeFor.price) * takerOrder.exchangeFor.price /*no of copies*/),
                    beneficiaryFee, 
                    royaltyFee
                );
              
                //Fees
                sendBEP20(IBEP20(makerOrder.exchangeFor.token), takerOrder.user, beneficiary, platformFee);
                sendBEP20(IBEP20(makerOrder.exchangeFor.token), takerOrder.user, royaltyAddress, royaltyFees);
                //Swap
                sendBEP20(IBEP20(makerOrder.exchangeFor.token), takerOrder.user, makerOrder.user, price);
                sendBEP1155( IBEP1155(takerOrder.exchangeFor.token), makerOrder.user, takerOrder.user, makerOrder.asset.id, takerOrder.exchangeFor.price);

                if((exeType) && (fixedOrders[makerOrder.sequenceID].expiry > 0)) {
                    fixedOrders[makerOrder.sequenceID].asset.quantity -= takerOrder.exchangeFor.price;
                }
            }
        } else {
            revert("Exchange token should be different");
        }

        return true;
    }

    function sendBEP20(IBEP20 token, address sender, address receiver, uint amount) private {
        require(operators[address(token)],"Invalid Token");
        token.transferFrom(sender, receiver, amount);
    }

    function sendBEP721(IBEP721 token, address sender, address receiver, uint tokenId) private {
        token.transferFrom(sender, receiver, tokenId);
    }

    function sendBEP1155(IBEP1155 token, address sender, address receiver, uint tokenId, uint amount) private {
        token.safeTransferFrom(sender, receiver, tokenId, amount, "0x");
    }

    function setBeneficiary( address newBeneficiary) public onlyOwner {
        beneficiary = newBeneficiary;
    }

    function setBeneficiaryFee( uint newBeneficiaryFee) public onlyOwner {
        require((newBeneficiaryFee > 0) && (newBeneficiaryFee < 10000), "setBeneficiaryFee : newBeneficiaryFee should > 0 and <10000");
        beneficiaryFee = newBeneficiaryFee;
    }

    function storeFixedSellOrder( OrderStruct memory order, uint price) private returns ( bool) {
    
        if((fixedOrders[order.sequenceID].expiry == 0) && (price < order.asset.quantity)) {
            fixedOrders[order.sequenceID] = order;
        }

        return true;
    }

    function _lazyMintBEP721( LazyMintStruct memory lazyMint, address token, address minter) private returns (bool) {
        bytes32 messageHash = createLazyMintHash(lazyMint);

        if(!isHashExsit[messageHash]){
            ILazyMintBEP721(token).safeMint(
                minter,
                lazyMint.uri,
                lazyMint.expiry,
                lazyMint.v,
                lazyMint.r,
                lazyMint.s
            );
        }

        isHashExsit[messageHash] = true;
        return true;
    }

    function _lazyMintBEP1155( LazyMintStruct memory lazyMint, address token, address minter, uint id) private returns (bool) {
        bytes32 messageHash = createLazyMintHash( lazyMint);

        if(!isHashExsit[messageHash]){
            ILazyMintBEP1155(token).mint(
                minter,
                id,
                lazyMint.expiry,
                lazyMint.v,
                lazyMint.r,
                lazyMint.s,
                lazyMint.supply,
                lazyMint.uri
            );
        }

        isHashExsit[messageHash] = true;
        return true;
    }

    function validateOrder( OrderStruct memory order) private returns ( address signer) {
        bytes32 messageHash = createMessageHash( order);
        messageHash = ECDSA.toEthSignedMessageHash(messageHash);
        require(!isHashExsit[messageHash], "validateOrder : hash exist");
        isHashExsit[messageHash] = true;
        return ECDSA.recover( messageHash, order.v, order.r, order.s);
    }

    function cancelOrder(OrderStruct memory order) external {
        require(order.user == msg.sender);

        if(order.asset.tokenType != 2) {
            validateOrder(order);
        } else {
            if((fixedOrders[order.sequenceID].expiry == 0)) {
                validateOrder(order);
                fixedOrders[order.sequenceID] = order;
                fixedOrders[order.sequenceID].asset.quantity = 0;
            } else {
                require(fixedOrders[order.sequenceID].asset.quantity > 0, "cancelOrder : order already cancelled");
                fixedOrders[order.sequenceID].asset.quantity = 0;
            }
        }

    }

    function validateOrdersType( OrderStruct memory makerOrder, OrderStruct memory takerOrder) private view {
        require(makerOrder.sequenceID != takerOrder.sequenceID, "validateOrdersType : orderID should not be same");
        require(makerOrder.asset.tokenType != takerOrder.asset.tokenType, "validateOrdersType : makerOrder token type is same as taker");
        require(makerOrder.asset.token == takerOrder.exchangeFor.token, "validateOrdersType : maker asset token should same as taker exchange token");
        require(takerOrder.asset.token == makerOrder.exchangeFor.token, "validateOrdersType : taker asset token should same as maker exchange token");
        require(takerOrder.user != makerOrder.user, "validateOrdersType : taker user should not be same");
        require(makerOrder.isSell != takerOrder.isSell, "validateOrdersType : both cannot be a seller");
        require(makerOrder.expiry > block.timestamp, "validateOrdersType : maker exceed expiry");
        require(takerOrder.expiry > block.timestamp, "validateOrdersType : taker exceed expiry");
    }

    function createMessageHash( OrderStruct memory order) public pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                order.sequenceID,
                abi.encodePacked(
                    order.asset.token,
                    order.asset.id,
                    order.asset.quantity,
                    order.asset.tokenType
                ),
                abi.encodePacked(
                    order.exchangeFor.token,
                    order.exchangeFor.id,
                    order.exchangeFor.price
                ),
                order.user,
                order.isSell,
                order.expiry
            )
        );
    }

    function createLazyMintHash( LazyMintStruct memory lazyMint) public pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                lazyMint.expiry,
                lazyMint.supply,
                lazyMint.v,
                lazyMint.r,
                lazyMint.s,
                lazyMint.uri
            )
        );
    }

    function setTokenstatus(address operator,bool status)public onlyOwner{
        operators[operator] = status;
    }

    function calculateFees(uint amount, uint beneficaryFees, uint royaltyFees) private view returns ( uint platformFee, uint secondaryFee, uint value) {
        platformFee = (amount * beneficaryFees) / denominator;
        secondaryFee = (amount * royaltyFees) / denominator;
        value = amount - (platformFee + secondaryFee);
    }
}