// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
import {IERC20} from './IERC20.sol';
import {SafeMath} from './SafeMath.sol';
import {Address} from './Address.sol';
import {IERC721} from './IERC721.sol';
import {IERC721Enumerable} from './IERC721Enumerable.sol';
import {IERC721Metadata} from './IERC721Metadata.sol';
import {IUserCowsBoy} from './IUserCowsBoy.sol';
import {IVerifySignature} from './IVerifySignature.sol';
import './ReentrancyGuard.sol';


contract COWSMarket721 is ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;
    address public operator;
    address public owner;
    address public POOL_MARKET;
    address public VERIFY_SIGNATURE;
    bool public _paused = false;
    uint256 public constant PERCENTS_DIVIDER = 1000000000;
   

    address[] public supportedPaymentTokenList;
    mapping(address => bool) public supportedPaymentMapping;
    uint256 public feePercent= PERCENTS_DIVIDER * 5/ 100; //default 5%
    uint256 public minPrice = 100*10**18; 
    address payable public feeReceiver;

    struct SaleInfo {
        bool isSold;
        bool isActive; //false mint already cancelled
        address payable owner;
        uint256 lastUpdated;
        uint256 tokenId;
        uint256 price;
        uint256 amount;
        uint256 saleId;
        address paymentToken;
        address nft;
    }

    address[] public supportedNFTList;
    mapping(address => bool) public supportedNFTMapping;

    SaleInfo[] public saleList;

    struct SaleIndex {
        uint256[] saleIds;
        mapping(uint256 => uint256) saleIdIndex;
    }
    SaleIndex private saleIndex;

    uint256 public totalSellingOrders=0;

    //events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ChangeOperator(address indexed previousOperator, address indexed newOperator);
    event ChangePool(address indexed previousPool, address indexed newPool);
    event NFTSupported(address nft, bool val);

    event NewTokenSale(
        address owner,
        address nft,
        uint256 updatedAt,
        uint256 tokenId,
        uint256 price,
        uint256 amount,
        uint256 saleId,
        address paymentToken
    );
    event TokenSaleUpdated(
        address owner,
        address nft,
        uint256 updatedAt,
        uint256 tokenId,
        uint256 price,
        uint256 amount,
        uint256 saleId
    );
    event SaleCancelled(
        address owner,
        address nft,
        uint256 updatedAt,
        uint256 tokenId,
        uint256 price,
        uint256 amount,
        uint256 saleId
    );
    event TokenPurchase(
        address owner,
        address buyer,
        address nft,
        uint256 updatedAt,
        uint256 tokenId,
        uint256 price,
        uint256 amount,
        uint256 saleId,
        address paymentToken
    );


    constructor() public {
        owner  = tx.origin;
        operator = tx.origin;
        feeReceiver = tx.origin;
        POOL_MARKET = tx.origin;
        VERIFY_SIGNATURE = 0x4f0736236903E5042abCc5F957fD0ae32f142405;         
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'INVALID owner');
        _;
    }
    modifier onlyOperator() {
        require(msg.sender == operator, 'INVALID operator');
        _;
    }

    fallback() external {

    }

    receive() payable external {
        
    }

    

    function pause() public onlyOwner {
        _paused=true;
    }

    function unpause() public onlyOwner {
        _paused=false;
    }

    modifier ifPaused(){
        require(_paused,"");
        _;
    }

    modifier ifNotPaused(){
        require(!_paused,"");
        _;
    }  

    modifier onlySaleOwner(uint256 _saleId) {
        require(msg.sender == saleList[_saleId].owner, "Invalid sale owner");
        _;
    }

    modifier onlySupportedPaymentToken(address _token) {
        require(supportedPaymentMapping[_token], "unsupported payment token");
        _;
    }

    modifier onlySupportedNFT(address _nft) {
        require(supportedNFTMapping[_nft], "not supported nft");
        _;
    }

    // Functions System 
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Transfers operator of the contract to a new account (`operator`).
     * Can only be called by the current owner.
     */
    function transferOperator(address _operator) public onlyOwner {
        emit ChangeOperator(operator , _operator);
        operator = _operator;
    }

    /**
     * @dev Transfers operator of the contract to a new account (`operator`).
     * Can only be called by the current owner.
     */
    function transferPool(address _pool) public onlyOwner {
        emit ChangePool(POOL_MARKET , _pool);
        POOL_MARKET = _pool;
    }

    /**
    * @dev Withdraw Token to an address, revert if it fails.
    * @param recipient recipient of the transfer
    */
    function clearToken(address recipient, address token, uint256 amount ) public onlyOwner {
        require(IERC20(token).balanceOf(address(this)) >= amount , "INVALID balance");
        IERC20(token).transfer(recipient, amount);
    }

    /**
    * @dev Withdraw  BNB to an address, revert if it fails.
    * @param recipient recipient of the transfer
    */
    function clearBNB(address payable recipient) public onlyOwner {
        _safeTransferBNB(recipient, address(this).balance);
    }

    /**
    * @dev transfer BNB to an address, revert if it fails.
    * @param to recipient of the transfer
    * @param value the amount to send
    */
    function _safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'BNB_TRANSFER_FAILED');
    }
    

    function setSupportedNFTs(address[] memory _nfts) external onlyOwner {
        _setSupportedNFTs(_nfts);
    }

    function _setSupportedNFTs(address[] memory _nfts) private {
        //diminish the current list
        for (uint256 i = 0; i < supportedNFTList.length; i++) {
            supportedNFTMapping[supportedNFTList[i]] = false;
            emit NFTSupported(supportedNFTList[i], false);
        }
        supportedNFTList = _nfts;
        for (uint256 i = 0; i < supportedNFTList.length; i++) {
            supportedNFTMapping[supportedNFTList[i]] = true;
            emit NFTSupported(_nfts[i], true);
        }
    }

    function changeFee(uint256 _newFee,uint256 _minPrice ) external onlyOwner {
        require(_newFee <= 100, "changeFee: new fee too high"); //max 10%
        feePercent = _newFee;
        minPrice = _minPrice;
    }

    function changeFeeReceiver(address payable _newFeeReceiver)
        external
        onlyOwner
    {
        require(
            _newFeeReceiver != payable(0),
            "changeFeeReceiver: null address"
        );
        feeReceiver = _newFeeReceiver;
    }

    function changePaymentList(address[] memory _supportedPaymentTokens)
        external
        onlyOwner
    {
        _changePaymentList(_supportedPaymentTokens);
    }

    function _changePaymentList(address[] memory _supportedPaymentTokens)
        private
    {
        //reset current list
        for (uint256 i = 0; i < supportedPaymentTokenList.length; i++) {
            supportedPaymentMapping[supportedPaymentTokenList[i]] = false;
        }
        supportedPaymentTokenList = _supportedPaymentTokens;
        for (uint256 i = 0; i < supportedPaymentTokenList.length; i++) {
            supportedPaymentMapping[supportedPaymentTokenList[i]] = true;
        }
    }
/*
    function sendNFT(
        address _nft,
        address _from,
        address _to,
        uint256 _tokenId
    ) public onlyOwner{

        IERC721(_nft).transferFrom(
                _from,
                _to,
                _tokenId
            );    


    }
*/
    function _isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function setTokenSale(
        address _nft,
        uint256 _tokenId,
        address _paymentToken,
        uint256 _price,
        string memory _message,
        uint256 _expiredTime,
        bytes memory signature
    ) external onlySupportedNFT(_nft) onlySupportedPaymentToken(_paymentToken) ifNotPaused {
        require(_isContract(msg.sender) == false, "setTokenSale: anti bot");
        require(block.timestamp < _expiredTime, "setTokenSale: !expired");
        require(
            IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, 1 , _message, _expiredTime, signature) == true ,
            "setTokenSale: invalid operator"
        );

        require(_price > 0 && _price >= minPrice , "setTokenSale:price must not be 0");
        //transfer token from sender to contract
        require(IERC721(_nft).isApprovedForAll(msg.sender,address(this))  == true, "setTokenSale: Check the nft approve ");
        uint256 _amount = 1; 

        IERC721(_nft).transferFrom(
                msg.sender,
                POOL_MARKET,
                _tokenId
            );    


        saleList.push(
            SaleInfo(
                false,
                true,
                payable(msg.sender),
                block.timestamp,
                _tokenId,
                _price,
                _amount,
                saleList.length,
                _paymentToken,
                _nft
            )
        );

        emit NewTokenSale(
            msg.sender,
            _nft,
            block.timestamp,
            _tokenId,
            _price,
            _amount,
            saleList.length - 1,
            _paymentToken
        );
        // Pageging Index
        uint256 saleId = saleList.length - 1;
        saleIndex.saleIds.push(saleId);
        saleIndex.saleIdIndex[saleId] = saleIndex.saleIds.length;
        //=> IDsale => Index => idList
        totalSellingOrders = totalSellingOrders + 1;
    }

    function updateSaleInfo(
        uint256 _saleId,
        uint256 _newPrice,
        string memory _message,
        uint256 _expiredTime,
        bytes memory signature
    ) external onlySaleOwner(_saleId) ifNotPaused {
        require(_isContract(msg.sender) == false, "updateSaleInfo: anti bot");
        require(block.timestamp < _expiredTime, "updateSaleInfo: !expired");
        require(
            IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, 1 , _message, _expiredTime, signature) == true ,
            "updateSaleInfo: invalid operator"
        );
        require(_newPrice > 0 && _newPrice >= minPrice, "updateSaleInfo: price must not be 0");
        SaleInfo storage sale = saleList[_saleId];
        require(
            sale.isActive && !sale.isSold,
            "updateSaleInfo: sale inactive or already sold"
        );
        //address _nft = sale.nft;
        //require(sale.nft == _nft, "updateSaleInfo: invalid nft address");
        sale.price = _newPrice;
        sale.lastUpdated = block.timestamp;

        emit TokenSaleUpdated(
            msg.sender,
            sale.nft,
            block.timestamp,
            sale.tokenId,
            _newPrice,
            sale.amount,
            _saleId
        );
    }

    function cancelTokenSale(uint256 _saleId)
        external
        onlySaleOwner(_saleId) ifNotPaused
    {
        require(_isContract(msg.sender) == false, "updateSaleInfo: anti bot");
        SaleInfo storage sale = saleList[_saleId];
        require(
            sale.isActive && !sale.isSold,
            "cancelTokenSale: sale inactive or already sold"
        );
        address _nft = sale.nft;
        //require(sale.nft == _nft, "cancelTokenSale: invalid nft address");
        sale.isActive = false;

        IERC721(_nft).transferFrom(
               POOL_MARKET,
                msg.sender, 
                sale.tokenId
            );    


        sale.lastUpdated = block.timestamp;

        emit SaleCancelled(
            msg.sender,
            _nft,
            block.timestamp,
            sale.tokenId,
            sale.price,
            sale.amount,
            _saleId
        );
        //=> IDsale => Index => idList    
        // Pageging Index
        deleteElement(saleIndex.saleIdIndex[_saleId] - 1);
        delete saleIndex.saleIdIndex[_saleId];
        totalSellingOrders = totalSellingOrders - 1;
    }
    function deleteElement(uint _index) internal returns(bool) {
        if (_index < 0 || _index >= saleIndex.saleIds.length) {
            return false;
        } else if(saleIndex.saleIds.length == 1) {
            saleIndex.saleIds.pop();
            return true;
        } else if (_index == saleIndex.saleIds.length - 1) {
            saleIndex.saleIds.pop();
            return true;
        } else {
            for (uint i = _index ; i < saleIndex.saleIds.length - 1; i++) {
                saleIndex.saleIds[i] = saleIndex.saleIds[i + 1];
                saleIndex.saleIdIndex[saleIndex.saleIds[i]] = i + 1;
            }
            saleIndex.saleIds.pop();
            return true;
        }
    } 

    function buyNFT(uint256 _saleId,
        string memory _message,
        uint256 _expiredTime,
        bytes memory signature 
    ) external ifNotPaused{ //payable
        require(_isContract(msg.sender) == false, "buyNFT: anti bot");
        require(block.timestamp < _expiredTime, "buyNFT: !expired");
        require(
            IVerifySignature(VERIFY_SIGNATURE).verify(operator, msg.sender, 1 , _message, _expiredTime, signature) == true ,
            "buyNFT: invalid operator"
        );
        SaleInfo storage sale = saleList[_saleId];
        uint256 _amount = 1;
        require(
            sale.isActive && !sale.isSold,
            "buyNFT: sale inactive or already sold"
        );
    
        require(
                sale.amount >= _amount,
                "buyNFT: invalid amount to buy"
            );


        uint256 price = sale.price * _amount;
        require(IERC20(sale.paymentToken).allowance(msg.sender, address(this)) >= price, "buyNFT: Check the token allowance");
        require(IERC20(sale.paymentToken).balanceOf(msg.sender) >= price, "buyNFT: not enough balance to buy ");

        //transfer fee
        /*
        if (isNative(sale.paymentToken)) // Pay with BNB
        {
            require(msg.value >= price, "insufficiant payment value");
            _safeTransferBNB(sale.owner , price.mul(PERCENTS_DIVIDER - feePercent).div(PERCENTS_DIVIDER) );
            _safeTransferBNB(feeReceiver , address(this).balance);
           
        } else 
        */
        // Pay with ERC20
        {
            IERC20(sale.paymentToken).transferFrom(
                msg.sender,
                feeReceiver,
                price.mul(feePercent).div(PERCENTS_DIVIDER)
            );
            //transfer to seller
            IERC20(sale.paymentToken).transferFrom(
                msg.sender,
                sale.owner,
                price.mul(PERCENTS_DIVIDER - feePercent).div(PERCENTS_DIVIDER)
            );
        }

        sale.lastUpdated = block.timestamp;

        IERC721(sale.nft).transferFrom(
               POOL_MARKET,
                msg.sender, 
                sale.tokenId
            );   


        emit TokenPurchase(
            sale.owner,
            msg.sender,
            sale.nft,
            block.timestamp,
            sale.tokenId,
            sale.price,
            _amount,
            _saleId,
            sale.paymentToken
        );
        sale.amount = sale.amount - _amount;
        if(sale.amount <= 0){
            sale.isSold = true;
            sale.isActive = false;
            //delete saleList[_saleId];
            //=> IDsale => Index => idList    
            // Pageging Index
            deleteElement(saleIndex.saleIdIndex[_saleId] - 1);
            delete saleIndex.saleIdIndex[_saleId];
            totalSellingOrders = totalSellingOrders - 1;
        }
    }
    function getAllSaleIndex() external view returns (uint256[] memory _pageIndex)
    {
        return (saleIndex.saleIds);
    }


    function getAllSaleIndex2(uint256 _id) external view returns (uint256 _index)
    {
        return (saleIndex.saleIdIndex[_id]);
    }

    

    function getAllSellings(uint offset, uint limit) external view returns (SaleInfo[] memory _nftItems, uint nextOffset, uint total) {
        uint totalRows = totalSellingOrders;
        if(limit == 0) {
            limit = 1;
        }
        if (limit > totalRows- offset) {
            limit = totalRows - offset;
        }
        SaleInfo[] memory values = new SaleInfo[](limit);
        for (uint i = 0; i < limit; i++) {
            values[i] = saleList[saleIndex.saleIds[offset + i]];
        }
        return (values, offset + limit, totalRows);
        
    }
    

    function getAllSales(uint offset, uint limit) external view returns (SaleInfo[] memory _nftItems, uint nextOffset, uint total) {
        uint totalRows = saleList.length;
        if(limit == 0) {
            limit = 1;
        }
        
        if (limit > totalRows- offset) {
            limit = totalRows - offset;
        }

        SaleInfo[] memory values = new SaleInfo[] (limit);
        for (uint i = 0; i < limit; i++) {
            values[i] = saleList[offset + i];
        }
        return (values, offset + limit, totalRows);
    }

    function getSaleCounts() external view returns (uint256 _nftCount) {
        return saleList.length;
    }

    function getSaleInfo(uint256 _saleId)
        external
        view
        returns (SaleInfo memory sale)
    {
        return saleList[_saleId];
    }

}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, 'SafeMath: modulo by zero');
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;


contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        
        _notEntered = true;
    }

    
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        
        _notEntered = true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
 * @dev Interface of the SellToken standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */
interface IVerifySignature {
  
  function verify( address _signer, address _to, uint256 _amount, string memory _message, uint256 _expiredTime, bytes memory signature) 
  external view returns (bool);
  
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
 * @dev Interface of the SellToken standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */
interface IUserCowsBoy {
  /**
   * @dev Returns the  info of user in existence.
   */
  function isRegister(address account) external view returns (bool);
  function getReff(address account) external view returns (address);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
/// @title ERC-721 Non-Fungible Token Standard, optional metadata extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x5b5e139f.
import "./IERC721.sol";
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
/// @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x780e9d63.
import "./IERC721.sol";
interface IERC721Enumerable is IERC721 /* is ERC721 */ {
    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256);

    /// @notice Enumerate valid NFTs
    /// @dev Throws if `_index` >= `totalSupply()`.
    /// @param _index A counter less than `totalSupply()`
    /// @return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256);

    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owned by them
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
import "./IERC165.sol"; 
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
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 */
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

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
pragma solidity 0.6.12;
// 
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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
        return functionCall(target, data, 'Address: low-level call failed');
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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