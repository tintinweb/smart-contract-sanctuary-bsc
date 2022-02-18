// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
import {IUserCowsBoy} from './IUserCowsBoy.sol';
import {IERC20} from './IERC20.sol';
import {SafeMath} from './SafeMath.sol';
import {IERC721} from './IERC721.sol';
import {IERC1155} from './IERC1155.sol';
import {IERC721Enumerable} from './IERC721Enumerable.sol';
import {IERC721Metadata} from './IERC721Metadata.sol';
import {IUserCowsBoy} from './IUserCowsBoy.sol';
import {IVerifySignature} from './IVerifySignature.sol';
import './ReentrancyGuard.sol';


contract COWS_Market_1155 is ReentrancyGuard {
    using SafeMath for uint256;
    address public operator;
    address public owner;
    address public POOL_MARKET;
    address public VERIFY_SIGNATURE;
    address public USER_COWSBOY;
    bool public _paused = false;
    uint256 public constant PERCENTS_DIVIDER = 1000000000;
    address public constant NATIVE_TOKEN =
        0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    address[] public supportedPaymentTokenList;
    mapping(address => bool) public supportedPaymentMapping;
    uint256 public feePercent= PERCENTS_DIVIDER * 5/ 100; //default 5%
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
        USER_COWSBOY = 0x009fbfe571f29c3b994a0cd84B2f47b7e7D73CDC;
        VERIFY_SIGNATURE = 0x4f0736236903E5042abCc5F957fD0ae32f142405;  
        /*    
        address[] memory _nftsAllow = new address[](1);
        _nftsAllow[0] = 0x40C86ce37BBb861c42D007Fa81461Bc5F6136327; // EGG-1155
        _setSupportedNFTs(_nftsAllow);
        address[] memory _tokensAllow = new address[](1);
        _tokensAllow[0] = 0xb084b320da2a9ac57e06e143109cd69d495275e8;
        _changePaymentList(_tokensAllow);
        */
          
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
    // Functions NFT 
    function isNative(address _token) public pure returns (bool) {
        return _token == NATIVE_TOKEN;
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

    function changeFee(uint256 _newFee) external onlyOwner {
        require(_newFee <= 100, "changeFee: new fee too high"); //max 10%
        feePercent = _newFee;
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

    function sendNFT(
        address _nft,
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _amount
    ) public onlyOwner{

        IERC1155(_nft).safeTransferFrom(
                _from,
                _to,
                _tokenId,
                _amount,
                ""
            );

    }

    function setTokenSale(
        address _nft,
        uint256 _tokenId,
        address _paymentToken,
        uint256 _price,
        uint256 _amount
    ) external onlySupportedNFT(_nft) onlySupportedPaymentToken(_paymentToken) ifNotPaused {
        require(_price > 0, "price must not be 0");
        //transfer token from sender to contract
        require(IERC1155(_nft).isApprovedForAll(msg.sender,address(this))  == true, "setTokenSale: Check the nft approve ");

        IERC1155(_nft).safeTransferFrom(
                msg.sender,
                POOL_MARKET,
                _tokenId,
                _amount,
                ""
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

        totalSellingOrders = totalSellingOrders + 1;

    }

    function updateSaleInfo(
        uint256 _saleId,
        uint256 _newPrice
    ) external onlySaleOwner(_saleId) ifNotPaused {
        require(_newPrice > 0, "price must not be 0");
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
        SaleInfo storage sale = saleList[_saleId];
        require(
            sale.isActive && !sale.isSold,
            "cancelTokenSale: sale inactive or already sold"
        );
        address _nft = sale.nft;
        //require(sale.nft == _nft, "cancelTokenSale: invalid nft address");
        sale.isActive = false;

        IERC1155(_nft).safeTransferFrom(
                POOL_MARKET,
                msg.sender, 
                sale.tokenId,
                sale.amount,
                ""
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
        totalSellingOrders = totalSellingOrders + 1;
    }

    function buyNFT(uint256 _saleId, uint256 _amount) external ifNotPaused{ //payable
        SaleInfo storage sale = saleList[_saleId];
        require(
            sale.isActive && !sale.isSold,
            "cancelTokenSale: sale inactive or already sold"
        );
    
        require(
                sale.amount >= _amount,
                "buyToken: invalid amount to buy"
            );


        uint256 price = sale.price * _amount;
        require(IERC20(sale.paymentToken).allowance(msg.sender, address(this)) >= price, "buyToken: Check the token allowance");
        require(IERC20(sale.paymentToken).balanceOf(msg.sender) >= price, "buyToken: not enough balance to buy ");

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

        IERC1155(sale.nft).safeTransferFrom(
                POOL_MARKET,
                msg.sender, 
                sale.tokenId,
                _amount,
                ""
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
            totalSellingOrders = totalSellingOrders - 1;
        }
    }

    function getAllSellings() external view returns (SaleInfo[] memory _nftItems) {
        SaleInfo[] memory sellings = new SaleInfo[](totalSellingOrders);
        uint j = 0;
        for(uint i = 0; i < saleList.length; i++) {
            if(saleList[i].isActive && !saleList[i].isSold){
                sellings[j] = saleList[i];
                j++;
            }
        }
        return (sellings);
    }

    function getAllSales() external view returns (SaleInfo[] memory _nftItems) {
        return (saleList);
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