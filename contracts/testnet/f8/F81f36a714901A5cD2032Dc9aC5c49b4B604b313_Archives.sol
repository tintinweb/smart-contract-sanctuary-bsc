// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import {OwnedAndParsed} from  "./OwnedAndParsed.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IMinter} from "./IMinter.sol";


contract Archives is OwnedAndParsed {

    constructor(address Owner, address Parser) OwnedAndParsed(Owner, Parser){}

    mapping(IERC20 => bool) allowedTokens;
    function isTokenAllowed(address token) public view returns (bool){
    	return allowedTokens[IERC20(token)];
    }
    function setTokenAllowed(IERC20 token, bool state) public onlyOwnerOrParser returns(bool){
    	allowedTokens[token] = state;
    	return true;
    }

    // chain id (for teleported nft royalties)
    // address of wallet on that chain
    // token address
    // token balance
    mapping(uint => mapping(address => mapping(IERC20 => uint))) balances;

    function getBalance(uint chainId, address adr, IERC20 token) public view returns (uint){
    	return balances[chainId][adr][token];
    }

    // not supposed to be used with tokens with royalties
    function topupToken(IERC20 token, uint q) public payable returns (bool){

    	require(allowedTokens[token], "Token is not allowed");

    	if(address(token) == address(0)){
    		balances[block.chainid][msg.sender][token] += msg.value;
    		return true;
    	}
    	require(q != 0, "Non-zero topup is needed");
    	// if allowance < topup - the token contract reverts it
    	require(token.transferFrom(msg.sender, address(this), q));
    	balances[block.chainid][msg.sender][token] += q;
    	return true;

    }
    function withdrawToken(IERC20 token, uint q) public returns(bool){
    	// will revert on underflow in 0.8+
    	balances[block.chainid][msg.sender][token] -= q;
    	if(address(token) == address(0)){
    		payable(msg.sender).transfer(q);
    		return true;
    	}
    	require(token.transfer(msg.sender, q), "Token transfer error");
    	return true;
    }


    function transferTokenUser(IERC20 token, uint q, address to) public returns(bool){
    	balances[block.chainid][msg.sender][token] -= q;
    	balances[block.chainid][to][token] += q;
    	return true;
    }
    function transferTokenProtocol(uint chainId, address sndr, IERC20 token, uint q, address to) public returns (bool){
    	// to release royalties from teleported NFTs to creator
    	require(msg.sender == serverParser, "Only for protocol bot");
    	require(chainId != 0);
    	balances[chainId][sndr][token] -= q;
    	balances[block.chainid][to][token] += q;
    	return true;
    }

    struct wallet{
    	uint chainId;
    	address adr;
    }
    struct royaltyRecord{
    	wallet adr;
    	uint q;
    }


    uint lastNftId = 1;
    // chain id => internal id of nft => nft data
    struct creationRecord {

    	// dynamic things
        uint royaltySize;
        mapping(uint => royaltyRecord) royaltyWallets;

        address currentOwner;
        uint status;

        // one time changed
        IERC721 realNftAdr;

    	// static things
        address creator;
        uint index;
        uint maxIndex;
        uint timestamp;
        uint factoryIndex;
        uint nftContract;

        uint onchainDataSize;
        mapping(uint => string) onchainData;
    }
    mapping(uint => mapping(uint => creationRecord)) public recordTable;

    function getCreator(uint chainId, uint id) public view returns(address){
    	return recordTable[chainId][id].creator;
    }

    function getCurrentOwner(uint chainId, uint id) public view returns(address){
    	return recordTable[chainId][id].currentOwner;
    }

    function getCurrentStatus(uint chainId, uint id) public view returns(uint){
    	return recordTable[chainId][id].status;
    }
    function getRoyaltySize(uint chainId, uint id) public view returns(uint){
    	return recordTable[chainId][id].royaltySize;
    }

    struct Info{
    	uint royaltySize;
    	address currentOwner;
        uint status;
        IERC721 realNftAdr;
        address creator;
        uint index;
        uint maxIndex;
        uint timestamp;
        uint factoryIndex;
        uint nftContract;
        uint onchainDataSize;
    }
    function getInfo(uint chainId, uint id) public view returns(Info memory){
    	Info memory res;

    	res.royaltySize = recordTable[chainId][id].royaltySize;
    	res.currentOwner = recordTable[chainId][id].currentOwner;
        res.status = recordTable[chainId][id].status;
        res.realNftAdr = recordTable[chainId][id].realNftAdr;
        res.creator = recordTable[chainId][id].creator;
        res.index = recordTable[chainId][id].index;
        res.maxIndex = recordTable[chainId][id].maxIndex;
        res.timestamp = recordTable[chainId][id].timestamp;
        res.factoryIndex = recordTable[chainId][id].factoryIndex;
        res.onchainDataSize = recordTable[chainId][id].onchainDataSize;
        res.nftContract = recordTable[chainId][id].nftContract;

        return res;
    }

    // check size first
    struct royaltiesView{
        uint chainId;
        address adr;
        uint q;
    }
    function getRoyalties(uint chainId, uint id) public view returns(royaltiesView[] memory){


    	uint sz = recordTable[chainId][id].royaltySize;
    	royaltiesView[] memory res;

    	if(sz == 0){
    	    res = new royaltiesView[](1);
    	    return res;
    	}

    	res = new royaltiesView[](sz);
    	for(uint i=0; i<sz; i++){
    		res[i].q = recordTable[chainId][id].royaltyWallets[i].q;
    		res[i].chainId  = recordTable[chainId][id].royaltyWallets[i].adr.chainId;
    		res[i].adr      = recordTable[chainId][id].royaltyWallets[i].adr.adr;
    	}
    	return res;
    }
    function getOnchainData(uint chainId, uint id) public view returns (string[] memory){
    	string[] memory res = new string[](recordTable[chainId][id].onchainDataSize);
    	for(uint i=0; i<recordTable[chainId][id].onchainDataSize; i++){
    		res[i] = recordTable[chainId][id].onchainData[i];
    	}
    	return res;
    }


    struct nftId{
    	uint chainId;
    	uint internalId;
    }
    mapping(IERC721 => nftId) public nftToId;
    function topupNft(IERC721 nft) public returns(bool){
	nftId memory uid = nftToId[nft];
    	require(uid.chainId != 0, "NFT wasnt minted in the system");
    	nft.transferFrom(msg.sender, address(this), 1);
    	recordTable[uid.chainId][uid.internalId].status = 2;
    	recordTable[uid.chainId][uid.internalId].currentOwner = msg.sender;
    	return true;
    }

    mapping(uint => IMinter) mintFactory;
    function pushMinter(uint id, IMinter adr) public onlyOwnerOrParser returns (bool){
    	mintFactory[id] = adr;
    	return true;
    }

    function withdrawNft(uint chainId, uint internalId) public returns (bool){
    	creationRecord storage ptr = recordTable[chainId][internalId];

    	require(ptr.currentOwner == msg.sender, "Only for NFT owner");
    	require(ptr.status == 2, "NFT is used in a different contract. Please release it to archive");

    	if(address(ptr.realNftAdr) == address(0)){
    		ptr.realNftAdr = mintFactory[ptr.nftContract].mint(chainId, internalId);
    		nftToId[ptr.realNftAdr].chainId    =  chainId;
    		nftToId[ptr.realNftAdr].internalId =  internalId;
    	}

    	ptr.status = 1;
    	ptr.currentOwner = address(0);
    	ptr.realNftAdr.transferFrom(address(this), msg.sender, 1);

        return true;
    }

    uint public maxRoyalty; // 1000 = 100%

    function setMaxRoyalty(uint value) public onlyOwnerOrParser returns (bool){
    	require(value + fee< 1000);
        maxRoyalty = value;
        return true;
    }

    uint public fee;

    function setFee(uint value) public onlyOwnerOrParser returns(bool){
    	require(value + maxRoyalty< 1000);
    	fee = value;
    	return true;
    }


    function addRecord(
    	uint chainId,
    	uint internalId,
        royaltyRecord[] memory royaltyWallets,

        address currentOwner,
        uint status,

        address creator,
        uint index,
        uint maxIndex,
        uint timestamp,
        uint factoryIndex,
        uint nftContract,

        string[] memory onchainData
    ) public returns (bool){




    	if(msg.sender == serverParser){
    		require(chainId != block.chainid, "only for teleporting nft");
    	}else if(ActionPerformers[msg.sender] != 0){

    		require(isAllowed(creator), "You are not allowed to mint");
    		chainId = block.chainid;
    		internalId = lastNftId;
    		lastNftId++;
    	}else{
    		require(isAllowed(msg.sender), "You are not allowed to mint");
    		chainId = block.chainid;
    		internalId = lastNftId;
    		lastNftId++;
    		currentOwner = msg.sender;
    		status = 2;
    		creator = msg.sender;
    		index = 1;
    		maxIndex = 1;
    		timestamp = block.timestamp;
    		factoryIndex = 0;
    	}

    	creationRecord storage ptr = recordTable[chainId][internalId];

    	ptr.royaltySize = royaltyWallets.length;
    	uint r = 0;
    	for(uint i=0; i<royaltyWallets.length; i++){
    		ptr.royaltyWallets[i].q = royaltyWallets[i].q;
    		ptr.royaltyWallets[i].adr.chainId = royaltyWallets[i].adr.chainId;
    		ptr.royaltyWallets[i].adr.adr = royaltyWallets[i].adr.adr;
    		r += royaltyWallets[i].q;
    	}
    	require(r <= maxRoyalty, "decrease the royalty %");

    	ptr.currentOwner = currentOwner;
    	ptr.status = status;

    	ptr.creator = creator;
    	ptr.index = index;
    	ptr.maxIndex = maxIndex;
    	ptr.timestamp = timestamp;
    	ptr.factoryIndex = factoryIndex;
    	ptr.nftContract = nftContract;
    	ptr.onchainDataSize = onchainData.length;
    	for(uint i=0; i<onchainData.length; i++){
    		ptr.onchainData[i] = onchainData[i];
    	}
    	return true;

    }

    // for game owners to update nft with new data
    function updateRecord(uint internalId, string[] memory newonchainData) public returns (bool){
    	creationRecord storage ptr = recordTable[block.chainid][internalId];

    	require(ptr.creator == msg.sender, "Only for creator");
    	require(newonchainData.length > 0, "Info is needed");

    	for(uint i=0; i < newonchainData.length; i++){
    		ptr.onchainData[ptr.onchainDataSize + i] = newonchainData[i];
    	}
    	ptr.onchainDataSize += newonchainData.length;

    	return true;
    }



    // 0 default - not created
    // 1 - withdrawn
    // 2 - in archive
    // rest - to be added
    mapping(address => uint) ActionPerformers;
    mapping(uint => address) reverseAction;
    uint curMaxAction = 3;

    function openAction(address action) public onlyOwner returns (bool){
        require(ActionPerformers[action] == 0);

        ActionPerformers[action] = curMaxAction;
        reverseAction[curMaxAction] = action;

        curMaxAction++;

        return true;
    }

    function closeAction(address action) public onlyOwner returns (bool){
        require(ActionPerformers[action] > 2);

        reverseAction[ActionPerformers[action]] = address(0);
        ActionPerformers[action] = 0;

        return true;
    }

    function showActionStatus(address action) public view returns (uint){
        return ActionPerformers[action];
    }

    function showActionAddress(uint stat) public view returns (address){
        return reverseAction[stat];
    }


    // tp 0 & nonzero x - move token
    // a - quantity
    // token - token adr
    // z - address from (chainId from is current chain)
    // b - chainTo
    // x - addressTo

    // tp 1 & zero x - change owner
    // a - chainId
    // b - internalId
    // z - new owner

    // tp > 1 & nonzero z - transfer tokens for royalties + fees + api + the rest to current owner
    // tp - total
    // a - chainId
    // b - internalId
    // x - take token from
    // z - api
    // token - token to pay

    // tp 2+ zero x change status
    // a - chainId
    // b - internalId
    // tp - new status
    struct Action{
    	uint tp;
    	uint a;
    	uint b;
    	address z;
    	address x;
    	IERC20 token;
    }




    // quantity to pay


    function stackedActions(Action[] memory toDo) public returns (bool){
    	require(ActionPerformers[msg.sender] > 2, "Not allowed");

        for(uint i = 0; i<toDo.length; i++){
        	if(toDo[i].tp == 0){
        		if(toDo[i].a != 0 && toDo[i].x != address(0)){
        			balances[block.chainid][toDo[i].z][toDo[i].token] -= toDo[i].a;
    				  balances[toDo[i].b][toDo[i].x][toDo[i].token] += toDo[i].a;
        		}
        	}else{
        		creationRecord	storage ptr = recordTable[toDo[i].a][toDo[i].b];
        		require(ptr.status == 2 || ptr.status == ActionPerformers[msg.sender]);
        		if(toDo[i].x == address(0)){
        		    if(toDo[i].tp == 1){
        			    ptr.currentOwner = toDo[i].z;
        		    }else{
        			    require(toDo[i].tp == 2 || toDo[i].tp == ActionPerformers[msg.sender]);
        			    ptr.status = toDo[i].tp;
        		    }
        		}else{
        		    uint totalPay = toDo[i].tp;
                    uint leftPay = totalPay;
                    IERC20 token = toDo[i].token;
                    uint toPay;

                    // 1 step balance removal
        			balances[block.chainid][toDo[i].x][token] -= totalPay;

        		    // pay fee
                    toPay = totalPay*fee/1000;
    			    balances[block.chainid][owner][token] += toPay;
                    leftPay -= toPay;

        		    // pay api fee
                    toPay = totalPay*sideMarketplaces[toDo[i].z]/1000;
                    balances[block.chainid][toDo[i].z][token] += toPay;
    				leftPay -= toPay;


        		    // pay royalties
                    for(uint j=0; j<ptr.royaltySize; j++){
                        toPay = totalPay*ptr.royaltyWallets[j].q/1000;
    				    balances[ptr.royaltyWallets[j].adr.chainId][ptr.royaltyWallets[j].adr.adr][token] += toPay;
                        leftPay -= toPay;
                    }

        		    // pay owner
    				balances[block.chainid][ptr.currentOwner][token] += leftPay;
        		}
        	}
        }
        return true;
    }

    function moveRoyalty(uint internalId, uint q, uint chainIdTo, address to) public returns (bool){
    	creationRecord storage ptr = recordTable[block.chainid][internalId];
    	bool f = false;
    	for(uint i=0; i<ptr.royaltySize; i++){
    		if(ptr.royaltyWallets[i].adr.adr == msg.sender && ptr.royaltyWallets[i].adr.chainId == block.chainid){
    			require(ptr.royaltyWallets[i].q >= q, "Not enough royalty balance");
    			ptr.royaltyWallets[i].q -= q;
    			if(ptr.royaltyWallets[i].q == 0){
    				ptr.royaltyWallets[i].adr.adr = ptr.royaltyWallets[ptr.royaltySize-1].adr.adr;
    				ptr.royaltyWallets[i].adr.chainId = ptr.royaltyWallets[ptr.royaltySize-1].adr.chainId;
    				ptr.royaltyWallets[i].q = ptr.royaltyWallets[ptr.royaltySize-1].q;

    				ptr.royaltySize --;
    			}
    			f = true;
    			break;
    		}
    	}

    	require(f, "Royalty balance is not found");
    	if(to == address(0)){
    		return true;
    	}


    	for(uint i=0; i<ptr.royaltySize; i++){
    		if(ptr.royaltyWallets[i].adr.adr == to && ptr.royaltyWallets[i].adr.chainId == chainIdTo){
    			ptr.royaltyWallets[i].q += q;
    			return true;
    		}
    	}

    	ptr.royaltyWallets[ptr.royaltySize].q = q;
    	ptr.royaltyWallets[ptr.royaltySize].adr.chainId = chainIdTo;
    	ptr.royaltyWallets[ptr.royaltySize].adr.adr = to;
    	ptr.royaltySize++;
    	return true;


    }

    mapping(address => uint) sideMarketplaces;
    function getProportion(address api) public view returns (uint){
    	return sideMarketplaces[api];
    }
    function setProportion(address api, uint proportion) public onlyOwner returns (bool){
    	sideMarketplaces[api] = proportion;
    	return true;
    }



    mapping(address => bool) whitelist;
    bool whitelistOn = false;
    function isAllowed(address check) public view returns (bool){
    	return whitelistOn || whitelist[check];
    }
    function toggleWhitelist() public onlyOwner returns (bool){
    	whitelistOn = !whitelistOn;
    	return true;
    }

    function manualAddWhitelist(address adr) public onlyOwner returns (bool){
    	whitelist[adr] = true;
    	return true;
    }

    function selfAddToWhitelist(bytes memory sig) public returns (bool){

        bytes32 hash = keccak256(abi.encodePacked(msg.sender, uint(0)));
        bytes32 message = ECDSA.toEthSignedMessageHash(hash);
        address receivedAddress = ECDSA.recover(message, sig);

    	require(whitelist[msg.sender] == false, "You are already in the whitelist");
    	require(receivedAddress == serverParser, "It is not signed by server");

    	whitelist[msg.sender] = true;
    	return true;
    }





}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract OwnedAndParsed {

    modifier nonZeroAddr(address newOne){
        require(newOne != address(0));
        _;
    }

    modifier nonZeroUint(uint a){
        require(a != 0);
        _;
    }

    modifier  nonEmpty(string memory some, uint max){
        bytes memory someBytes = bytes(some);
        require((someBytes.length > 0) && (max == 0 || someBytes.length <= max));
        _;
    }

    address public owner;

    function getOwner() public view returns (address){
        return owner;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function setOwner(address newOne) public onlyOwner nonZeroAddr(newOne) returns (bool){
        owner = newOne;
        return true;
    }

    address public serverParser;

    function getServer() public view returns (address){
        return serverParser;
    }

    function setServerParser(address newOne) public onlyOwner nonZeroAddr(newOne) returns (bool){
        serverParser = newOne;
        return true;
    }

    modifier onlyOwnerOrParser(){
        require(msg.sender == owner || msg.sender == serverParser);
        _;
    }


    constructor (address Owner, address Parser){
        owner = Owner;
        serverParser = Parser;

    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import {Archives} from  "./Archives.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IMinter{
	function mint(uint chainId, uint internalId) external returns (IERC721);
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