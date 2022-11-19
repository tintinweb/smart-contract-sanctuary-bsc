// SPDX-License-Identifier: Apache-2.0





/*
    ███████╗ █████╗  ██████╗ ██╗     ███████╗███╗   ██╗███████╗████████╗
    ██╔════╝██╔══██╗██╔════╝ ██║     ██╔════╝████╗  ██║██╔════╝╚══██╔══╝
    █████╗  ███████║██║  ███╗██║     █████╗  ██╔██╗ ██║█████╗     ██║
    ██╔══╝  ██╔══██║██║   ██║██║     ██╔══╝  ██║╚██╗██║██╔══╝     ██║
    ███████╗██║  ██║╚██████╔╝███████╗███████╗██║ ╚████║██║        ██║
    ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝        ╚═╝
*/

pragma solidity ^0.8.10;
pragma experimental ABIEncoderV2;

import "./Interface/token/ERC721/ERC721.sol";
import "./Interface/token/ERC20/IERC20.sol";
import "./Interface/utils/Strings.sol";
import "./Interface/utils/Base64.sol";

// @custom:security-contact EAGLE TEAM
contract EAGLENFT is ERC721 {
    using Strings for uint256;
    // @EAGLETOKEN EAGLE ERC20 address
    IERC20 public EAGLETOKEN;

    address public immutable MarketingWallet;
    address public immutable NFTWallet;
    uint128 public TigerEagleCardTAllowancel;
    uint128 public PhoenixEagleCardTAllowancel;
    // @imageURL EAGLENT imageURL
    string[2] private imageURL;

    // @initToken This variable is used only once
    uint128 private initToken = 1;
    uint128 private batchMint = 3;
    uint128 private _currentSupply;

    // @tokenConfig NFT configure
    struct tokenConfig {
        uint256 creationTime;
        uint256 EAGLESerial;
        bool onSale;
        mapping(uint256 => bool) Receive;
        uint256 orderId;
    }

    // @orderNFTList NFT market order configure
    //lowerShelf： Judge whether the order exists
    struct orderNFTList {
        uint256 tokenId;
        uint256 price;
        uint256 NFTListingTime;
        bool lowerShelf;
        address listingAddr;
}

    // @NFTDate Record user address and type
    struct NFTDate {
        address owner;
        uint256 serial;
    }

    // @NFTConfig NFT configure Point by NFT Token Id
    mapping(uint256 => tokenConfig) private NFTConfig;
    // @orderNFTLists NFT market order configure Point by NFT market order Id
    orderNFTList[] private orderNFTLists;
    // @NFTConfig
    mapping(uint256 => NFTDate) public NFTCurrency;
    mapping(address => uint256[]) public myNFT;
    mapping(address => uint256[]) public myOrderIds;
    mapping(uint256=>uint256[])private orderTypeId;
    mapping(uint256 => bool) private NFTEstablish;

    event listNFTEvent(
        uint256 tokenId,
        uint256 price,
        uint256 listingTime,
        bool onSale
    );
    event buyNFTEvent(
        uint256 tokenId,
        address from,
        address to,
        uint256 price,
        bool onSale,
        bool lowerShelf
    );
    event cancelNFTListEvent(uint256 tokenId, bool lowerShelf, bool onSale);

    constructor()
        ERC721("EAGLENFT", "EAGLE")
    {
        MarketingWallet = 0x3CCA48694A4d037883627f2e4F3a32D9383D7BE3;
//        NFTWallet = 0xf8320E62349b2cd30d2394eB554fdBdfA30A8132;
        NFTWallet = msg.sender;
        TigerEagleCardTAllowancel = 88;
        PhoenixEagleCardTAllowancel = 888;
        imageURL[
            0
        ] = "https://gateway.pinata.cloud/ipfs/QmZufShi4GnjcFj8NGYdCPWqjmySDg944vtawFQwn5Yucw";
        imageURL[
            1
        ] = "https://gateway.pinata.cloud/ipfs/QmNYy1kgu1ioyBPMqsWYbHtQmtEEUytErkUs4GZo4TnfLW";
    }

    function mintAllNFT1()external{
        uint128  TigerEagleCardTnum = 5;
        uint128  PhoenixEagleCardNum = 5;
        for(uint128 i = 0;i<TigerEagleCardTnum;i++){
            mintTigerEagleCard();
        }
        for(uint128 i = 0;i<PhoenixEagleCardNum;i++){
            mintPhoenixEagleCard();
        }
        batchMint = 2;
    }

    // @initEagleToken This function can only be used once
    // The purpose is to load EagleToken address
    function initEagleToken(address _EagleToken) external {
        require(initToken == 1,"initToken is not 1");
        EAGLETOKEN = IERC20(_EagleToken);
        initToken = 0;
    }

    function mint(uint256 tokenId) private {
        NFTCurrency[tokenId].owner = NFTWallet;
        _mint(NFTWallet, tokenId);
        _currentSupply++;
        myNFT[NFTWallet].push(tokenId);
    }

    // @mintTigerEagleCard Mint TigerEagleCard
    function mintTigerEagleCard() private {
        uint256 tokenId = _currentSupply;
        NFTCurrency[tokenId].serial = 0;
        mint(tokenId);
        NFTConfig[tokenId].EAGLESerial = 0;
    }

    // @mintPhoenixEagleCard Mint PhoenixEagleCard
    function mintPhoenixEagleCard() private {
        uint256 tokenId = _currentSupply;
        NFTCurrency[tokenId].serial = 1;
        mint(tokenId);
        NFTConfig[tokenId].EAGLESerial = 1;
    }

//    function mintAllNFT1()external{
//        require(batchMint == 3,"batchMint is not 3");
//        uint128  TigerEagleCardTnum = 88;
//        uint128  PhoenixEagleCardNum = 220;
//        for(uint128 i = 0;i<TigerEagleCardTnum;i++){
//            mintTigerEagleCard();
//        }
//        for(uint128 i = 0;i<PhoenixEagleCardNum;i++){
//            mintPhoenixEagleCard();
//        }
//        batchMint = 2;
//    }


    function mintAllNFT2()external{
        require(batchMint == 2,"batchMint is not 2");
        uint128  PhoenixEagleCardNum = 334;
        for(uint128 i = 0;i<PhoenixEagleCardNum;i++){
            mintPhoenixEagleCard();
        }
        batchMint = 1;
    }

    function mintAllNFT3()external{
        require(batchMint == 1,"batchMint is not 1");
        uint128  PhoenixEagleCardNum = 334;
        for(uint128 i = 0;i<PhoenixEagleCardNum;i++){
            mintPhoenixEagleCard();
        }
        batchMint = 0;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        if (NFTEstablish[tokenId] == false) {
            NFTConfig[tokenId].creationTime = block.timestamp;
            NFTEstablish[tokenId] = true;
        }
        NFTCurrency[tokenId].owner = from;
        removeOwnerId(from, tokenId);
        super._transfer(from, to, tokenId);
        myNFT[to].push(tokenId);
    }

    // @removeOwnerId remove my nft from tokenid
    function removeOwnerId(address user, uint256 tokenId) private {
        uint256 ownerNum = balanceOf(user);
        uint256 index;
        for (uint256 i = 0; i < ownerNum; i++) {
            if (myNFT[user][i] == tokenId) {
                index = i;
            }
        }
        require(index < myNFT[user].length, "index is not myNFT[user].length");
        for (uint256 i = index; i < myNFT[user].length - 1; i++) {
            myNFT[user][i] = myNFT[user][i + 1];
        }
        myNFT[user].pop();
    }

    // @myNFTTokenIds return my NFT IDS
    function myNFTTokenIds() public view returns (uint256[] memory) {
        return myNFT[msg.sender];
    }
    function myOrderIdList() public view returns (uint256[] memory) {
        return myOrderIds[msg.sender];
    }

    function removeOrderIds(address user, uint256 orderid) private {
        uint256 OrderIdNum =  myOrderIds[msg.sender].length;
        uint256 index;
        for (uint256 i = 0; i < OrderIdNum; i++) {
            if (myOrderIds[user][i] == orderid) {
                index = i;
            }
        }
        require(index < myOrderIds[user].length, "index is not myOrderIds[user].length");
        for (uint256 i = index; i < myOrderIds[user].length - 1; i++) {
            myOrderIds[user][i] = myOrderIds[user][i + 1];
        }
        myOrderIds[user].pop();
    }



    // @tokenURI return NFT tokenURI
    // return NFT details encoding form of base64
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "URI query for nonexistent token");
        uint256 serial = NFTConfig[tokenId].EAGLESerial;
        string memory cardName = tokenType(tokenId);
        string memory name = string(
            abi.encodePacked(cardName, "EAGLE NFT#", tokenId.toString())
        );
        string memory description = string(
            abi.encodePacked("This NFT is ", cardName, ":")
        );
        string memory image = string(abi.encodePacked(imageURL[serial]));
        uint256 creationTime = NFTConfig[tokenId].creationTime;
        string memory sale;
        if (NFTConfig[tokenId].onSale == true) {
            sale = "true";
        } else {
            sale = "false";
        }
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"token_id":',
                        tokenId.toString(),
                        ',"name":"',
                        name,
                        '","image":"',
                        image,
                        '","sale":"',
                        sale,
                        '","serial":"',
                        serial.toString(),
                        '","createTime":"',
                        creationTime.toString(),
                        '","description":"',
                        description,
                        '"}'
                    )
                )
            )
        );
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
    }

    // @sellNFT NFT market order
    // List your NFT in the market
    // precondition：You must receive the NFT reward of this month before you can sell it
    // NFT must be authorized to the contract
    function sellNFT(uint256 _tokenId, uint256 _price) external {
        require(_exists(_tokenId), "URI query for nonexistent token");
        require(_msgSender() == ownerOf(_tokenId), "you not owner this NFT");
        require(
            NFTConfig[_tokenId].onSale == false,
            "This NFT cannot be sold. Please cancel the sale first"
        );
        uint256 receiveNum = (block.timestamp -
            NFTConfig[_tokenId].creationTime) / 10 minutes;
        if (receiveNum > 12) {
            receiveNum = 12;
        }
        if (receiveNum != 0) {
            require(
                NFTConfig[_tokenId].Receive[receiveNum] == true,
                "This NFT cannot be sold,Please get the reward of this month first"
            );
        }
        _transfer(msg.sender, address(this), _tokenId);
        orderNFTList memory NFT = orderNFTList({
            tokenId: _tokenId,
            price: _price,
            NFTListingTime: block.timestamp,
            lowerShelf: true,
            listingAddr:msg.sender
        });
        orderNFTLists.push(NFT);
        NFTConfig[_tokenId].onSale = true;
        NFTConfig[_tokenId].orderId = orderNFTLists.length - 1;
        orderTypeId[0].push(NFTConfig[_tokenId].orderId);
        uint256 serial = NFTConfig[_tokenId].EAGLESerial;
        if  (serial == 0){
            orderTypeId[1].push(NFTConfig[_tokenId].orderId);
        }else{
            orderTypeId[2].push(NFTConfig[_tokenId].orderId);
        }
        myOrderIds[msg.sender].push(NFTConfig[_tokenId].orderId);
        emit listNFTEvent(_tokenId, _price, block.timestamp, true);
    }

    function getorderIdUseTokenId(uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        return NFTConfig[_tokenId].orderId;
    }

    // @buyNFT Buy NFT in the market
    // precondition：You must first approve the contract for a sufficient amount(EAGLETOKEN>orderNFTLists[orderID].price)
    function buyNFT(uint256 orderID) external {
        address tokenowner = orderNFTLists[orderID].listingAddr;
        uint256 price = orderNFTLists[orderID].price;
        uint256 tokenId = orderNFTLists[orderID].tokenId;
        require(orderNFTLists[orderID].lowerShelf == true, "This NFT is off the shelf");
        require(NFTConfig[tokenId].onSale == true);
        require(
            EAGLETOKEN.allowance(_msgSender(), address(this)) > price,
            "insufficient allowance"
        );
        EAGLETOKEN.transferFrom(_msgSender(), tokenowner, price);
        _transfer(address(this), _msgSender(), tokenId);
        NFTConfig[tokenId].onSale = false;
        orderNFTLists[orderID].lowerShelf = false;
        uint256 serial = NFTConfig[tokenId].EAGLESerial;
        removeIdDate(0,orderID);
        removeOrderIds(tokenowner,orderID);
        if  (serial == 0){
            removeIdDate(1,orderID);
        }else{
            removeIdDate(2,orderID);
        }
        emit buyNFTEvent(
            tokenId,
            _msgSender(),
            tokenowner,
            price,
            false,
            false
        );
    }

    // @cancelNFTList Cancel your NFT to be listed in the NFT market
    // Close NFT order for sale
    function cancelNFTList(uint256 orderID) external {
        uint256 tokenId = orderNFTLists[orderID].tokenId;
        address tokenowner = orderNFTLists[orderID].listingAddr;
        require(orderNFTLists[orderID].lowerShelf == true, "This NFT is off the shelf");
        require(NFTConfig[tokenId].onSale == true, "This NFT is not on sale");
        require(_msgSender() == tokenowner, "you not owner this NFT");
        orderNFTLists[orderID].lowerShelf = false;
        NFTConfig[tokenId].onSale = false;
        _transfer(address(this),msg.sender, tokenId);
        uint256 serial = NFTConfig[tokenId].EAGLESerial;
        removeIdDate(0,orderID);
        removeOrderIds(tokenowner,orderID);
        if  (serial == 0){
            removeIdDate(1,orderID);
        }else{
            removeIdDate(2,orderID);
        }
        emit cancelNFTListEvent(orderNFTLists[orderID].tokenId, false, false);
    }

    // @setNFTConfigReceiveOnlyEAGLETOKEN Set NFTConfig Receive Only EAGLETOKEN
    // Receive the reward of the specified month
    // Only after receiving rewards can they be sold in the market
    function setNFTConfigReceiveOnlyEAGLETOKEN(uint256 _tokenId, uint256 _batch)
        external
    {
        require(msg.sender == address(EAGLETOKEN), "you are not EAGLETOKEN");
        NFTConfig[_tokenId].Receive[_batch] = true;
    }

    function removeIdDate(uint256 types,uint orderId)public {
        uint256 index;
        uint256 ownerNum = orderTypeId[types].length-1;
        for (uint i =0;i < ownerNum ;i++){
            if(orderTypeId[types][i] == orderId){
                index = i;
            }
        }

        require(index < orderTypeId[types].length, "index out of bounds");
        for (uint i = index;i<orderTypeId[types].length-1;i++){
            orderTypeId[types][i] = orderTypeId[types][i+1];
        }
        orderTypeId[types].pop();

    }

    // @getdate return orderIds
    // 0 => all orderIds ; 1 => TigerEagle orderIds ; 2 => PhoenixEagleCard orderIds
    function getdate(uint256 orderListId)public view returns(uint256[] memory){
        return orderTypeId[orderListId];
    }

    // @getOrderDetails return order details
    function getOrderDetails(uint256 orderID)
        public
        view
        returns (string memory)
    {
        uint256 tokenId = orderNFTLists[orderID].tokenId;
        require(_exists(tokenId), "URI query for nonexistent token");
        uint256 price = orderNFTLists[orderID].price;
        uint256 serial = NFTConfig[tokenId].EAGLESerial;
        uint256 NFTListingTime = orderNFTLists[orderID].NFTListingTime;
        string memory owner = Strings.toHexString(uint256(uint160(ownerOf(tokenId))), 20);
        string memory name = tokenType(tokenId);
        string memory description = string(
            abi.encodePacked(
                '{"token_id":',
                    tokenId.toString(),
                    ',"order_id":',
                    orderID.toString(),
                    ',"serial":',
                    serial.toString(),
                    ',"name":"',
                    name,
                    '","price":',
                    price.toString(),
                    ',"NFTListingTime":',
                    NFTListingTime.toString(),
                    ',"owner":"',
                    owner,
                    '"}'
            )
        );
        return description;
    }



    // @totalSupply Query NFT totalsupply
    function totalSupply() external view returns (uint256) {
        return _currentSupply;
    }

    // @tokenType Query the type of an NFT
    function tokenType(uint256 tokenId) public view returns (string memory) {
        uint256 serial = NFTConfig[tokenId].EAGLESerial;
        string memory cardName;
        if (serial == 0) {
            cardName = "TigerEagleCard";
        } else {
            cardName = "PhoenixEagleCard";
        }
        return cardName;
    }


    // @getNFTCreateTime Query appoint NFT create time
    function getNFTCreateTime(uint256 tokenId) external view returns (uint256) {
        return NFTConfig[tokenId].creationTime;
    }

    // @getNFTDraw Query Whether the reward has been received in the specified month
    function getNFTDraw(uint256 tokenId, uint256 _batch)
        external
        view
        returns (bool)
    {
        if(_batch > 12){
            _batch = 12;
        }
        return NFTConfig[tokenId].Receive[_batch];
    }

    // @getNFTEAGLESerial get nft type
    function getNFTEAGLESerial(uint256 tokenId) public view returns (uint256) {
        return NFTConfig[tokenId].EAGLESerial;
    }

    // @getNFTCardNumber Query the respective quantity of the current two NFTs
    function getNFTCardNumber()
        external
        view
        returns (uint128 tigerEaglecardNum, uint128 PhoenixEagleCardNum)
    {
        return (
            88 - TigerEagleCardTAllowancel,
            888 - PhoenixEagleCardTAllowancel
        );
    }

    // @getNFTConfig get nft owner address and type
    function getNFTConfig()
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        uint256 total = _currentSupply;
        address[] memory owner = new address[](total);
        uint256[] memory serial = new uint256[](total);
        for (uint256 i = 0; i < total; i++) {
            NFTDate storage nftdates = NFTCurrency[i];
            owner[i] = nftdates.owner;
            serial[i] = nftdates.serial;
        }
        return (owner, serial);
    }

    function getSale(uint256 tokenId) external view returns (bool) {
        return NFTConfig[tokenId].onSale;
    }
}

// SPDX-License-Identifier: Apache-2.0



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

// SPDX-License-Identifier: Apache-2.0



// OpenZeppelin Contracts (last updated v4.7.0) (utils/Base64.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides a set of functions to operate with Base64 strings.
 *
 * _Available since v4.5._
 */
library Base64 {
    /**
     * @dev Base64 Encoding/Decoding Table
     */
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /**
     * @dev Converts a `bytes` to its Bytes64 `string` representation.
     */
    function encode(bytes memory data) internal pure returns (string memory) {
        /**
         * Inspired by Brecht Devos (Brechtpd) implementation - MIT licence
         * https://github.com/Brechtpd/base64/blob/e78d9fd951e7b0977ddca77d92dc85183770daf4/base64.sol
         */
        if (data.length == 0) return "";

        // Loads the table into memory
        string memory table = _TABLE;

        // Encoding takes 3 bytes chunks of binary data from `bytes` data parameter
        // and split into 4 numbers of 6 bits.
        // The final Base64 length should be `bytes` data length multiplied by 4/3 rounded up
        // - `data.length + 2`  -> Round up
        // - `/ 3`              -> Number of 3-bytes chunks
        // - `4 *`              -> 4 characters for each chunk
        string memory result = new string(4 * ((data.length + 2) / 3));

        /// @solidity memory-safe-assembly
        assembly {
            // Prepare the lookup table (skip the first "length" byte)
            let tablePtr := add(table, 1)

            // Prepare result pointer, jump over length
            let resultPtr := add(result, 32)

            // Run over the input, 3 bytes at a time
            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                // Advance 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // To write each character, shift the 3 bytes (18 bits) chunk
                // 4 times in blocks of 6 bits for each character (18, 12, 6, 0)
                // and apply logical AND with 0x3F which is the number of
                // the previous character in the ASCII table prior to the Base64 Table
                // The result is then added to the table to get the character to write,
                // and finally write it in the result pointer but with a left shift
                // of 256 (1 byte) - 8 (1 ASCII char) = 248 bits

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) // Advance
            }

            // When data `bytes` is not exactly 3 bytes long
            // it is padded with `=` characters at the end
            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }

        return result;
    }
}

// SPDX-License-Identifier: Apache-2.0



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

// SPDX-License-Identifier: Apache-2.0



// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: Apache-2.0



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

// SPDX-License-Identifier: Apache-2.0



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

// SPDX-License-Identifier: Apache-2.0



// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: Apache-2.0



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

// SPDX-License-Identifier: Apache-2.0



// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: Apache-2.0



// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: Apache-2.0



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