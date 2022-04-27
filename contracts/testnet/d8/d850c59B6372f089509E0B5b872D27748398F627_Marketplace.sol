/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount,"Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success,"Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data)internal returns (bytes memory){
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target,data,value,"Address: low-level call with value failed");
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value,string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value,"Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data)internal view returns (bytes memory){
        return functionStaticCall(target,data,"Address: low-level static call failed");
    }
    function functionStaticCall(address target,bytes memory data,string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data)internal returns (bytes memory){
        return functionDelegateCall(target,data,"Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(bool success,bytes memory returndata,string memory errorMessage) internal pure returns (bytes memory) {
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
interface IMarketplace {
    event CreateAsk(address indexed nft,uint256 indexed tokenID,uint256 price,address indexed to);
    event CancelAsk(address indexed nft, uint256 indexed tokenID);
    event AcceptAsk(address indexed nft,uint256 indexed tokenID,uint256 price,address indexed to);
    event CreateBid(address indexed nft,uint256 indexed tokenID,uint256 price);
    event CancelBid(address indexed nft, uint256 indexed tokenID);
    event AcceptBid(address indexed nft,uint256 indexed tokenID,uint256 price);
    struct Ask {
        bool exists;
        address seller;
        uint256 price;
        address to;
    }
    struct Bid {
        bool exists;
        address buyer;
        uint256 price;
    }
    function createAsk(INFTContract[] calldata nft,uint256[] calldata tokenID,uint256[] calldata price,address[] calldata to) external;
    function createBid(INFTContract[] calldata nft,uint256[] calldata tokenID,uint256[] calldata price) external payable;
    function cancelAsk(INFTContract[] calldata nft, uint256[] calldata tokenID)external;
    function cancelBid(INFTContract[] calldata nft, uint256[] calldata tokenID)external;
    function acceptAsk(INFTContract[] calldata nft, uint256[] calldata tokenID)external payable;
    function acceptBid(INFTContract[] calldata nft, uint256[] calldata tokenID)external;
    function withdraw() external;
}
interface INFTContract {
    function balanceOf(address _owner, uint256 _id)external view returns (uint256);
    function setApprovalForAll(address _operator, bool _approved) external;
    function safeTransferFrom(address _from,address _to,uint256 _id,uint256 _value,bytes calldata _data) external;
    function safeBatchTransferFrom(address _from,address _to,uint256[] calldata _ids,uint256[] calldata _values,bytes calldata _data) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function approve(address _approved, uint256 _tokenId) external payable;
    function safeTransferFrom(address _from,address _to,uint256 _tokenId,bytes calldata data) external payable;
    function safeTransferFrom(address _from,address _to,uint256 _tokenId) external payable;
}
library NFT {
    function safeTransferFrom_(INFTContract nft,address from,address to,uint256 tokenID,bytes memory data) internal returns (bool) {
        // most are 721s, so we assume that that is what the NFT type is
        try nft.safeTransferFrom(from, to, tokenID, data) {
            return true;
            // on fail, use 1155s format
        } catch (bytes memory) {
            try nft.safeTransferFrom(from, to, tokenID, 1, data) {
                return true;
            } catch (bytes memory) {
                return false;
            }
        }
    }
    function quantityOf(INFTContract nft,address potentialOwner,uint256 tokenID) internal view returns (uint256) {
        try nft.ownerOf(tokenID) returns (address owner) {
            if (owner == potentialOwner) {
                return 1;
            } else {
                return 0;
            }
        } catch (bytes memory) {
            try nft.balanceOf(potentialOwner, tokenID) returns (
                uint256 amount
            ) {
                return amount;
            } catch (bytes memory) {
                return 0;
            }
        }
    }
}
contract Marketplace is IMarketplace {
    using Address for address payable;
    using NFT for INFTContract;
    mapping(address => mapping(uint256 => Ask)) public asks;
    mapping(address => mapping(uint256 => Bid)) public bids;
    mapping(address => uint256) public escrow;
    address payable beneficiary;
    address admin;
    string public constant REVERT_NOT_OWNER_OF_TOKEN_ID ="Marketplace::not an owner of token ID";
    string public constant REVERT_OWNER_OF_TOKEN_ID ="Marketplace::owner of token ID";
    string public constant REVERT_BID_TOO_LOW = "Marketplace::bid too low";
    string public constant REVERT_NOT_A_CREATOR_OF_BID ="Marketplace::not a creator of the bid";
    string public constant REVERT_NOT_A_CREATOR_OF_ASK ="Marketplace::not a creator of the ask";
    string public constant REVERT_ASK_DOES_NOT_EXIST ="Marketplace::ask does not exist";
    string public constant REVERT_CANT_ACCEPT_OWN_ASK ="Marketplace::cant accept own ask";
    string public constant REVERT_ASK_IS_RESERVED ="Marketplace::ask is reserved";
    string public constant REVERT_ASK_INSUFFICIENT_VALUE ="Marketplace::ask price higher than sent value";
    string public constant REVERT_ASK_SELLER_NOT_OWNER ="Marketplace::ask creator not owner";
    string public constant REVERT_NFT_NOT_SENT = "Marketplace::NFT not sent";
    string public constant REVERT_INSUFFICIENT_FUNDS ="Marketplace::insufficient ether sent";
    constructor(address payable newBeneficiary) {
        beneficiary = newBeneficiary;
        admin = msg.sender;
    }
    //CREATE ASK / BID
    function createAsk(INFTContract[] calldata nft,uint256[] calldata tokenID,uint256[] calldata price,
        address[] calldata to ) external override {
            for (uint256 i = 0; i < nft.length; i++) {
            require(nft[i].quantityOf(msg.sender, tokenID[i]) > 0,REVERT_NOT_OWNER_OF_TOKEN_ID);
            // if feecollector extension applied, this ensures math is correct
            require(price[i] > 10_000, "price too low");
            // overwristes or creates a new one
            asks[address(nft[i])][tokenID[i]] = Ask({
                exists: true,
                seller: msg.sender,
                price: price[i],
                to: to[i]});
            emit CreateAsk({
                nft: address(nft[i]),
                tokenID: tokenID[i],
                price: price[i],
                to: to[i]
            });
        }
    }
    function createBid(INFTContract[] calldata nft,uint256[] calldata tokenID,uint256[] calldata price) external payable override {
        uint256 totalPrice = 0;
        for (uint256 i = 0; i < nft.length; i++) {
            address nftAddress = address(nft[i]);
            require(msg.value > bids[nftAddress][tokenID[i]].price,REVERT_BID_TOO_LOW);
            // if bid existed, let the prev. creator withdraw their bid. new overwrites
            if (bids[nftAddress][tokenID[i]].exists) {
                escrow[bids[nftAddress][tokenID[i]].buyer] += bids[nftAddress][tokenID[i]].price;
            }
            // overwrites or creates a new one
            bids[nftAddress][tokenID[i]] = Bid({
                exists: true,
                buyer: msg.sender,
                price: price[i]
            });
            emit CreateBid({
                nft: nftAddress,
                tokenID: tokenID[i],
                price: price[i]
            });
            totalPrice += price[i];
        }
        require(totalPrice == msg.value, REVERT_INSUFFICIENT_FUNDS);
    }
    //CANCEL ASK / BID
    function cancelAsk(INFTContract[] calldata nft, uint256[] calldata tokenID)external override{
        for (uint256 i = 0; i < nft.length; i++) {
            address nftAddress = address(nft[i]);
            require(asks[nftAddress][tokenID[i]].seller == msg.sender,REVERT_NOT_A_CREATOR_OF_ASK);
            delete asks[nftAddress][tokenID[i]];
            emit CancelAsk({nft: nftAddress, tokenID: tokenID[i]});
        }
    }
    function cancelBid(INFTContract[] calldata nft, uint256[] calldata tokenID)external override{
        for (uint256 i = 0; i < nft.length; i++) {
            address nftAddress = address(nft[i]);
            require(bids[nftAddress][tokenID[i]].buyer == msg.sender,REVERT_NOT_A_CREATOR_OF_BID);
            escrow[msg.sender] += bids[nftAddress][tokenID[i]].price;
            delete bids[nftAddress][tokenID[i]];
            emit CancelBid({nft: nftAddress, tokenID: tokenID[i]});
        }
    }
    // ACCEPT ASK / BID
    function acceptAsk(INFTContract[] calldata nft, uint256[] calldata tokenID) external payable override{
        uint256 totalPrice = 0;
        for (uint256 i = 0; i < nft.length; i++) {
            address nftAddress = address(nft[i]);
            require(asks[nftAddress][tokenID[i]].exists,REVERT_ASK_DOES_NOT_EXIST);
            require(asks[nftAddress][tokenID[i]].seller != msg.sender,REVERT_CANT_ACCEPT_OWN_ASK);
            if (asks[nftAddress][tokenID[i]].to != address(0)) {
                require(asks[nftAddress][tokenID[i]].to == msg.sender,REVERT_ASK_IS_RESERVED);
            }
            require(nft[i].quantityOf(asks[nftAddress][tokenID[i]].seller,tokenID[i]) > 0,REVERT_ASK_SELLER_NOT_OWNER);
            totalPrice += asks[nftAddress][tokenID[i]].price;
            escrow[asks[nftAddress][tokenID[i]].seller] += _takeFee(asks[nftAddress][tokenID[i]].price);
            // if there is a bid for this tokenID from msg.sender, cancel and refund
            if (bids[nftAddress][tokenID[i]].buyer == msg.sender) {
                escrow[bids[nftAddress][tokenID[i]].buyer] += bids[nftAddress][tokenID[i]].price;
                delete bids[nftAddress][tokenID[i]];
            }
            emit AcceptAsk({
                nft: nftAddress,
                tokenID: tokenID[i],
                price: asks[nftAddress][tokenID[i]].price,
                to: asks[nftAddress][tokenID[i]].to
            });
            bool success = nft[i].safeTransferFrom_(
                asks[nftAddress][tokenID[i]].seller,
                msg.sender,
                tokenID[i],
                new bytes(0)
            );
            require(success, REVERT_NFT_NOT_SENT);
            delete asks[nftAddress][tokenID[i]];
        }
        require(totalPrice == msg.value, REVERT_ASK_INSUFFICIENT_VALUE);
    }
    function acceptBid(INFTContract[] calldata nft, uint256[] calldata tokenID) external override{
        uint256 escrowDelta = 0;
        for (uint256 i = 0; i < nft.length; i++) {
            require(nft[i].quantityOf(msg.sender, tokenID[i]) > 0,REVERT_NOT_OWNER_OF_TOKEN_ID);
            address nftAddress = address(nft[i]);
            escrowDelta += bids[nftAddress][tokenID[i]].price;
            // escrow[msg.sender] += bids[nftAddress][tokenID[i]].price;
            emit AcceptBid({
                nft: nftAddress,
                tokenID: tokenID[i],
                price: bids[nftAddress][tokenID[i]].price
            });
            bool success = nft[i].safeTransferFrom_(msg.sender,bids[nftAddress][tokenID[i]].buyer,tokenID[i],new bytes(0));
            require(success, REVERT_NFT_NOT_SENT);
            delete asks[nftAddress][tokenID[i]];
            delete bids[nftAddress][tokenID[i]];
        }
        uint256 remaining = _takeFee(escrowDelta);
        escrow[msg.sender] = remaining;
    }
    //@notice Sellers can receive their payment by calling this function.
    function withdraw() external override {
        uint256 amount = escrow[msg.sender];
        escrow[msg.sender] = 0;
        payable(address(msg.sender)).sendValue(amount);
    }
    // ADMIN
    // @dev Used to change the address of the trade fee receiver.
    function changeBeneficiary(address payable newBeneficiary) external {
        require(msg.sender == admin, "");
        require(newBeneficiary != payable(address(0)), "");
        beneficiary = newBeneficiary;
    }
    // @dev sets the admin to the zero address. This implies that beneficiary
    // address and other admin only functions are disabled.
    function revokeAdmin() external {
        require(msg.sender == admin, "");
        admin = address(0);
    }
    //EXTENSIONS
    function _takeFee(uint256 totalPrice) internal virtual returns (uint256) {
        return totalPrice;
    }
}