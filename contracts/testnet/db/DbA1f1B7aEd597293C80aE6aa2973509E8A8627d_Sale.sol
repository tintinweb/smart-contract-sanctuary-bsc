// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ISpecialCollection.sol";
import "./libraries/Util.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./PriceConverter.sol";

contract Sale is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using PriceConverter for uint256;
    struct SaleInfo {
        uint256 fixedPrice;
        address paymentToken;
    }

    struct ReSaleInfo {
        address owner;
        uint256 fixedPrice;
        address paymentToken;
    }

    address[] public  beneficiaries;
    uint256[] public percentages;
    address public immutable COLLECTION;



    address public usdToken;
    uint8 public usdTokenDecimal;

    mapping(uint256 => SaleInfo) public sales;
    mapping(uint256 => bool) public endSales;
    mapping(uint256 => bool) public sold;
    uint256[] saleIndexer;

    // Based on fragment token id not the saleId(original art)
    address[] public  resaleBeneficiaries;
    uint256[] public resalePercentages;
    uint256[] resaleIndexer;
    mapping(uint256 => ReSaleInfo) public resales;

    // Map contain fragment of Original token
    mapping(uint256 => uint256 []) public fragmentOriginal;

    event Create(uint256 indexed id, address indexed payment, uint256 indexed price);
    event Terminate(uint256 indexed id);
    event Adjust(uint256 indexed id, address indexed payment, uint256 indexed price);
    event Reopen(uint256 indexed id, address indexed payment, uint256 indexed price);
    event Sold(address indexed buyer, uint256 indexed tokenId, address indexed payment, uint256 price);

    event SetUsdToken(address usd, uint8 decimal);

    event SetSplitter(address[] beneficiaries, uint256[] _percentages);
    event SetResaleSplitter(address[] beneficiaries, uint256[] _percentages);
    
    event UserListFragment(uint256 id, address payment, uint256 price);
    event UserDelistFragment(uint256 id);
    event ResaleSold(address indexed buyer, uint256 indexed tokenId, address indexed payment, uint256 price);

    constructor(address _collection, address[] memory _beneficiaries, uint256[] memory _percentages, address[] memory _resaleBeneficiaries, uint256[] memory _resalePercentages ) Ownable() {
        COLLECTION = _collection;
        setSaleSpliter(_beneficiaries, _percentages);
        setResaleSpliter(_resaleBeneficiaries, _resalePercentages);
    }
    
    /**
       	@notice Set usd token
       	@dev  Caller must be Owner
        @param	_tokenAddress USD token address
    */
    function setUsdToken(address _tokenAddress) public onlyOwner {
        setUsdTokenWithDecimals(_tokenAddress, 18);
    }

    /**
       	@notice Set usd token
       	@dev  Caller must be Owner
        @param	_tokenAddress USD token address
        @param  _decimal if the decimal is difference than 18
    */
    function setUsdTokenWithDecimals(address _tokenAddress, uint8 _decimal) public onlyOwner {
        usdToken = _tokenAddress;
        usdTokenDecimal = _decimal;
        emit SetUsdToken(usdToken, usdTokenDecimal);
    }

    /**
       	@notice Set address of spliter
       	@dev  Caller must be Owner
        @param	_beneficiaries address that receive payments
        @param _percentages is the percent of the total (total must be 100)
    */
    function setSaleSpliter(address[] memory _beneficiaries, uint256[] memory _percentages) public onlyOwner {
        require(_beneficiaries.length == _percentages.length, "Not same length");
        require(_beneficiaries.length >= 1, "Must have more than 1 beneficiary account");
        
        uint256 total;
        for (uint256 i; i < _beneficiaries.length; i++){
            require(_beneficiaries[i] != address(0), "ZeroAddress");
            require(_percentages[i] > 0, "Percentage for each beneficiary must bigger than 0");
            total += _percentages[i];
        }

        require(total == 100, "Total not 100");

        beneficiaries = _beneficiaries;
        percentages = _percentages;

        emit SetSplitter(_beneficiaries, _percentages);
    }

    /**
       	@notice Set address of spliter
       	@dev  Caller must be Owner
        @param	_beneficiaries address that receive payments
        @param _percentages is the percent of the total (total must be 100)
    */
    function setResaleSpliter(address[] memory _beneficiaries, uint256[] memory _percentages) public onlyOwner {
        require(_beneficiaries.length == _percentages.length, "Not same length");
        require(_beneficiaries.length >= 1, "Must have more than 1 beneficiary account");
        
        uint256 total;
        for (uint256 i; i < _beneficiaries.length; i++){
            require(_beneficiaries[i] != address(0), "ZeroAddress");
            require(_percentages[i] > 0, "Percentage for each beneficiary must bigger than 0");
            total += _percentages[i];
        }

        require(total < 80, "Owner of this NFT has atlest 20%");

        resaleBeneficiaries = _beneficiaries;
        resalePercentages = _percentages;

        emit SetResaleSplitter(_beneficiaries, _percentages);
    }

    /**
       	@notice Get current fragment of token customer been selling 
       	@dev  
        @param	_tokenId		_originalToken ID or FragmentId
        Note: 
    */
    function getUserFragmentSale(uint256 _tokenId) public view returns(uint256 [] memory) {
        return fragmentOriginal[Util._getOriginalId(_tokenId)];
    }

    /**
       	@notice Get resale length 
       	@dev  
        Note: 
    */
    function getResaleLength() public view returns(uint256 _len) {
        _len = resaleIndexer.length;
    }

    /**
       	@notice Get resale original NFT list by index for FE to load sales on UI 
       	@dev  
        @param	_from, _to
        Note: 
    */
    function getResaleOriginalIdListByIndex(uint256 _from, uint256 _to) public view returns(uint256 [] memory) {
        uint256 len = resaleIndexer.length;

        require(_to >= _from, "Incorrect input params");
        require(_from < len, "Incorrect input params");
        if(_to >= len) _to = len-1;
        uint256[] memory _ret = new uint256[](_to - _from + 1);
        for(uint i = _from; i <= _to; i++ ){
            _ret[i - _from] = resaleIndexer[i];
        }

        return _ret;
    }


    /**
       	@notice User resale the NFT token
       	@dev  Caller must be Owner
        @param	_fragmentId				fragment ID
        @param	_paymentToken		    Payment Token (Native Coin = 0x00)
        @param	_price				    Fixed Price per fragment

        Note:
    */
    function userListFragment(uint256 _fragmentId, address _paymentToken, uint256 _price) external {
        require(_paymentToken != address(0), "Pay with native when set paymentToken to usdToken");
        require(_price != 0, "ZeroPrice");
        require(
            IERC721(COLLECTION).ownerOf(_fragmentId) == msg.sender, "Must be the owner of this token"
        );

        // Add to mapping
        resales[_fragmentId].fixedPrice = _price;
        resales[_fragmentId].paymentToken = _paymentToken;
        resales[_fragmentId].owner = msg.sender;
        // Add to indexer
        addToIndexer(_fragmentId);

        // Transfer to this address for sale
        IERC721(COLLECTION).safeTransferFrom(msg.sender, address(this), _fragmentId);

        emit UserListFragment(_fragmentId, _paymentToken, _price);
    }

    /**
       	@notice User delist resale the NFT token
       	@dev  Caller must be Owner
        @param	_fragmentId				fragment ID
        Note: 
    */
    function userDelistFragment(uint256 _fragmentId) external {
        require(
            resales[_fragmentId].owner == msg.sender, "NOT THE OWNER"
        );
        
        // Transfer to the owner
        IERC721(COLLECTION).safeTransferFrom(address(this), msg.sender , _fragmentId);
        // remove from mapping
        delete resales[_fragmentId];
        // remove from indexer
        removeFromIndexer(_fragmentId);

        emit UserDelistFragment(_fragmentId);
    }



    /**
       	@notice Create Sale Event for each of Original NFT
       	@dev  Caller must be Owner
        @param	_saleId				    Sale ID is `tokenId` of Original NFT
        @param	_paymentToken		    Payment Token (Native Coin = 0x00)
        @param	_price				    Fixed Price per fragment

        Note: This function can also be used for:
            + Create a new sale
            + Adjust Payment Token/Price for one current sale
            + Re-open a closed sale event
    */
    function createSale(uint256 _saleId, address _paymentToken, uint256 _price) external onlyOwner {
        require(_paymentToken != address(0), "Pay with native when set paymentToken to usdToken");
        require(_price != 0, "ZeroPrice");
        require(
            ISpecialCollection(COLLECTION).isOriginalCreated(_saleId), "OriginalIdNotExist"
        );

        sales[_saleId].fixedPrice = _price;
        sales[_saleId].paymentToken = _paymentToken;

        if(endSales[_saleId]) {
            delete endSales[_saleId];

            emit Reopen(_saleId, _paymentToken, _price);
        }
        else if (sales[_saleId].fixedPrice != 0) 
            emit Adjust(_saleId, _paymentToken, _price);
        else
            emit Create(_saleId, _paymentToken, _price);
    }

    /**
       	@notice Terminate a current Sale Event
       	@dev  Caller must be Owner
        @param	_saleId				    Sale ID is `tokenId` of Original NFT

        Note: One sale event does not have start/end time. 
            Thus, this function is dedicated, for Owner only, to terminate a current sale event
    */
    function terminateSale(uint256 _saleId) external onlyOwner {
        require(sales[_saleId].fixedPrice != 0, "SaleNotExist");
        require(!endSales[_saleId], "Terminated");

        endSales[_saleId] = true;
    }

    function getNativePrice(uint256 saleID) public view returns(uint256){
        
        SaleInfo memory _info = sales[saleID];

        require(_info.paymentToken == usdToken, "Payment has to set in USD for pay with Native");

        // Check the value send by sender have to bigger than  the current price
        uint256 maticPrice = PriceConverter.getPrice();

        return maticPrice * (_info.fixedPrice / usdTokenDecimal);
    }

    /**
       	@notice Purchase NFT fragment
       	@dev  Caller can be ANY
        @param	_tokenId            Token Id of a fragment NFT
    */
    function purchase(uint256 _tokenId) external payable {
        address _buyer = msg.sender;
        SaleInfo memory _info = checkPrice(_tokenId);

        require(_info.paymentToken != address(0), "Not payable with native with this function");

        _makePayment(_info.paymentToken, _buyer, _info.fixedPrice);
        ISpecialCollection(COLLECTION).mintFragment(_buyer, _tokenId);
        sold[_tokenId] = true;

        emit Sold(_buyer, _tokenId, _info.paymentToken, _info.fixedPrice);
    }

    /**
       	@notice Purchase NFT fragment
       	@dev  Caller can be ANY
        @param	_tokenId            Token Id of a fragment NFT
    */
    function purchaseWithNative(uint256 _tokenId) external payable {
        address _buyer = msg.sender;
        SaleInfo memory _info = checkPrice(_tokenId);

        require(_info.paymentToken == usdToken, "Payment has to set in USD for pay with Native");

        // Check the value send by sender have to bigger than  the current price
        uint256 maticPrice = PriceConverter.getPrice();

        // Convert to native 
        uint256 nativePrice = maticPrice * _info.fixedPrice / usdTokenDecimal;

        require(msg.value >= nativePrice, "Not enough matic");

        _makePayment(address(0), _buyer, msg.value);
        ISpecialCollection(COLLECTION).mintFragment(_buyer, _tokenId);
        sold[_tokenId] = true;

        emit Sold(_buyer, _tokenId, address(0), msg.value);
    }

    /**
       	@notice Purchase NFT fragment
       	@dev  Caller can be ANY
        @param	_fragmentId            Token Id of a fragment NFT
    */
    function purchaseResale(uint256 _fragmentId) external payable {
        address _buyer = msg.sender;

        ReSaleInfo memory _info = checkPriceResale(_fragmentId);

        require(_info.paymentToken != address(0), "Not payable with native with this function");

        _makeResalePayment(_info.paymentToken, _buyer, _info.owner, _info.fixedPrice);

        IERC721(COLLECTION).safeTransferFrom(address(this), _buyer, _fragmentId);

        removeFromIndexer(_fragmentId);

        emit ResaleSold(_buyer, _fragmentId, _info.paymentToken, _info.fixedPrice);
    }

    /**
       	@notice Purchase NFT fragment
       	@dev  Caller can be ANY
        @param	_fragmentId            Token Id of a fragment NFT
    */
    function purchaseWithNativeResale(uint256 _fragmentId) external payable {

        address _buyer = msg.sender;

        ReSaleInfo memory _info = checkPriceResale(_fragmentId);

        require(_info.paymentToken == usdToken, "Payment has to set in USD for pay with Native");
        
        // Check the value send by sender have to bigger than  the current price
        uint256 maticPrice = PriceConverter.getPrice();

        // Convert to native 
        uint256 nativePrice = maticPrice * _info.fixedPrice / usdTokenDecimal;

        require(msg.value >= nativePrice, "Not enough native");

        _makeResalePayment(_info.paymentToken, _buyer, _info.owner, _info.fixedPrice);

        IERC721(COLLECTION).safeTransferFrom(address(this), _buyer, _fragmentId);

        removeFromIndexer(_fragmentId);

        emit ResaleSold(_buyer, _fragmentId, _info.paymentToken, _info.fixedPrice);
    }

    /**
       	@notice Check current fixed price of one fragment NFT
       	@dev  Caller can be ANY
        @param	_tokenId            Token Id of a fragment NFT
    */
    function checkPrice(uint256 _tokenId) public view returns (SaleInfo memory _info) {
        require(ISpecialCollection(COLLECTION).validate(_tokenId), "InvalidFragmentId");
        require(!sold[_tokenId], "ItemSold");
        
        //  @dev `_saleId` is the Original NFT's tokenId
        uint256 _saleId = Util._getOriginalId(_tokenId);
        _info = sales[_saleId];
        require(_info.fixedPrice != 0, "SaleNotExist");
        require(!endSales[_saleId], "SaleEnd");
    }

    
    /**
       	@notice get resale Infor
       	@dev  Caller can be ANY
        @param	_fragmentId            Token Id of a fragment NFT
    */
    function checkPriceResale(uint256 _fragmentId) public view returns (ReSaleInfo memory _info) {
        // require in  resale
        require(resales[_fragmentId].owner != address(0));
        _info = resales[_fragmentId];
    }

    function _makePayment(address _token, address _from, uint256 _amount) nonReentrant private {
        
        uint256 hasLeft = _amount;
        for(uint256 i; i < beneficiaries.length; i++){

            uint256 transferAmount = _amount * percentages[i] / 100;
            if(transferAmount > hasLeft){
                transferAmount = hasLeft;
            }
            hasLeft = hasLeft - _amount * percentages[i] / 100;

            if (_token == address(0))
                Address.sendValue(payable(beneficiaries[i]), transferAmount);
            else
                IERC20(_token).safeTransferFrom(_from, beneficiaries[i], transferAmount);
        }
    }

    function _makeResalePayment(address _token, address _from, address _owner, uint256 _amount) nonReentrant private {
        
        uint256 hasLeft = _amount;
        for(uint256 i; i < beneficiaries.length; i++){

            uint256 transferAmount = _amount * percentages[i] / 100;
            if(transferAmount > hasLeft){
                transferAmount = hasLeft;
            }
            hasLeft = hasLeft - _amount * percentages[i] / 100;

            if (_token == address(0))
                Address.sendValue(payable(beneficiaries[i]), transferAmount);
            else
                IERC20(_token).safeTransferFrom(_from, beneficiaries[i], transferAmount);
        }
        
        if (_token == address(0))
                Address.sendValue(payable(_owner), hasLeft);
            else
                IERC20(_token).safeTransferFrom(_from, _owner, hasLeft);

    }

    function addToIndexer(uint256 _fragmentId) private {
        uint256 originalId = Util._getOriginalId(_fragmentId);
        uint256 indexToAdd = 0xffffff;
        uint256 len = fragmentOriginal[originalId].length;
        for(uint i = 0; i < len; i++){
            if(fragmentOriginal[originalId][i] == _fragmentId){
                indexToAdd = i;
                break;
            }
        }
        require(indexToAdd == 0xffffff, "Already in indexer");

        fragmentOriginal[originalId].push(_fragmentId);

        // Add element into indexer
        uint256 resaleIndex = 0xffffff;
        for(uint i = 0; i < resaleIndexer.length; i++){
            if(resaleIndexer[i] == originalId){
                resaleIndex = i;
                break;
            }
        }
        if(resaleIndex == 0xffffff){
            resaleIndexer.push(originalId);
        }
    }

    function removeFromIndexer(uint256 _fragmentId) private {
        uint256 originalId = Util._getOriginalId(_fragmentId);
        uint256 indexToRemove = 0xffffff;
        uint256 len = fragmentOriginal[originalId].length;

        require(len > 0, "No fragment");
    
        for(uint i = 0; i < len; i++){
            if(fragmentOriginal[originalId][i] == _fragmentId){
                indexToRemove = i;
                break;
            }
        }
        require(indexToRemove != 0xffffff, "No Fragment to remove");

        for(uint i = indexToRemove; i < len - 1; i++){
            fragmentOriginal[originalId][i] = fragmentOriginal[originalId][i + 1];
        }
        fragmentOriginal[originalId].pop();

        if(fragmentOriginal[originalId].length == 0){
            // remove originalId from indexer
            uint256 resaleIndex = 0xffffff;
            for(uint i = 0; i < resaleIndexer.length; i++){
                if(resaleIndexer[i] == originalId){
                    resaleIndex = i;
                    break;
                }
            }
            if(resaleIndex != 0xffffff){
                for(uint i = resaleIndex; i < len - 1; i++){
                    resaleIndexer[i] = resaleIndexer[i + 1];
                }
                resaleIndexer.pop();
            }
        }

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
        
    // We could make this public, but then we'd have to deploy it
    function getPrice() internal view returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        
        address aggregatorAddress;

        if(id == 137){
            aggregatorAddress = 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0;
        }
        else if (id == 80001){
            // aggregatorAddress = 0x0715A7794a1dc8e42615F059dD6e406A6594651A;
            // Default the value to 1
            return 1000000000000000000;
        }
        else{
            // aggregatorAddress = 0x0000000000000000000000000000000000000000;
            // default the value to 1
            return 1000000000000000000;
        }


        AggregatorV3Interface priceFeed = AggregatorV3Interface(aggregatorAddress);

        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // MATIC/USD rate in 18 digit
        return uint256(answer * 1e10); //Chainlink USD datafeeds return price data with 8 decimals precision, not 18. convert the value to 18 decimals, you can add 10 zeros to the result:
    }

    // 1000000000
    function getConversionRate(uint256 ethAmount)
        internal
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        // the actual MATIC/USD conversion rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }


    function getOrgUsdMatic(uint256  _amount) internal view returns (uint256) {
        uint256 ethPrice = getPrice() ;
        uint256  adjust_price = uint256 (ethPrice) * 1e18;
        uint256  usd = _amount * 1e18;
        uint256  rate = (usd * 1e18) / adjust_price;
        return rate;
    }

    function getUsdMatic(uint256  _amount) internal view returns (uint256) {
        uint256 ethPrice = getPrice() ;
        uint256  adjust_price = uint256 (ethPrice) * 1e18;
        uint256  usd = _amount * 1e18;
        uint256  rate = (usd * 1e18) / adjust_price;
        return rate * 102 / 100; 
    }

}

// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

interface ISpecialCollection {
    
    /**
       	@notice Checking whether Original NFT has been created
       	@dev  Caller can be ANY
		@param	_originalId				TokenId of Original NFT
    */
    function isOriginalCreated(uint256 _originalId) external view returns (bool);

    /**
       	@notice Checking validity of Fragment ID
       	@dev  Caller can be ANY
		@param	_tokenId				TokenId of Fragment NFT
    */
    function validate(uint256 _tokenId) external view returns (bool);

    /**
       	@notice Mint NFT to `_beneficiary`
       	@dev  Caller must be MINTER
		@param	_beneficiary				Address of Beneficiary
        @param	_tokenId				    ID of a minting token
    */
    function mintFragment(address _beneficiary, uint256 _tokenId) external;

    /**
       	@notice Mint a batch of NFT to `_beneficiaries`
       	@dev  Caller must be Owner
		@param	_beneficiaries				A list of Beneficiaries
        @param	_tokenIds				    A list of minting TokenIds
    */
    function mintFragments(address[] calldata _beneficiaries, uint256[] calldata _tokenIds) external;

    /**
       	@notice Burn a batch of `_tokenIds`
       	@dev  Caller can be ANY who currently owns burning NFTs
		@param	_tokenIds		        A list of burning `_tokenIds`

        NOTE: Collection's Owner is granted a priviledge to burn NFTs
    */
    function burn(uint256[] calldata _tokenIds) external;
}

// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

library Util {
    
    uint256 private constant MASK = 10**6;
    uint256 private constant SUB_MASK = 10**3;

    function _getOriginalId(uint256 _tokenId) internal pure returns (uint256) {
        return _tokenId / MASK;
    }

    function _getFragmentCoord(uint256 _tokenId) internal pure returns (uint256 _row, uint256 _col) {
        uint256 _fragmentNo = _tokenId % MASK;
        _row = _fragmentNo / SUB_MASK;
        _col = _fragmentNo % SUB_MASK;
    }
}

// SPDX-License-Identifier: MIT
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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