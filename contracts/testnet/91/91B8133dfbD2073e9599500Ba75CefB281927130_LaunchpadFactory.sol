//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0 ;

import "./IERC20.sol";
import "./Clones.sol";
import "./Context.sol";
import "./ReentrancyGuard.sol";

import "./ISale.sol";

contract LaunchpadFactory is ReentrancyGuard, Context{
    event TransferSent(address indexed from, address indexed to, uint amount);
    event LaunchpadCreated(address indexed contract_address, address indexed owner);

    struct AdditionalPrice {
        uint256 index;
        string name;
        uint256 price;
    }

    struct LaunchpadStruct {
        uint256 index;
        address launchpad;
        bool verified;
    }

    struct OwnedLaunchpadStuct {
        address token;
        address launchpad;
    }

    struct MyStandardStruct {
        uint256 index;
        address the_address;
    }

    address private saleImplementation;

    address private _owner;
    uint256 private _listingPrice;
    uint256 private _createTokenPrice;

    AdditionalPrice[] private _additionalPrices;

    /**
     * @dev Accepted currency data structure
     * see {ILaunchpad} for whole Accepted currency structure
    */
    MyStandardStruct[] private _acceptedRouterArr;
    mapping (address => MyStandardStruct) private _acceptedRouterMap;

    /**
     * @dev Launchpads data structure
     * see {ILaunchpad} for whole Launchpad structure
    */
    LaunchpadStruct[] private _launchpadsArr;
    mapping (address => LaunchpadStruct) private _launchPadsMap;
    mapping (address => OwnedLaunchpadStuct[]) private _ownedLaunchpads;


    modifier onlyOwner(){
        require(_msgSender() == _owner, "only owner can access this.");

        _;
    }

    constructor(uint256 listingPrice, uint256 createTokenPrice, address launchpad)
    {
        _owner = _msgSender();
       _listingPrice = listingPrice;
       _createTokenPrice = createTokenPrice;

       saleImplementation = launchpad;
    }

    /*================================*
     |           withdraw             |
     *================================*/

    /**
     * @dev withdraw function only owner can withraw
    */
    function withdraw(uint amount) onlyOwner public 
    {
        require(address(this).balance >= amount, "insufficient balance");

        payable(_owner).transfer(amount);

        emit TransferSent(_msgSender(), _owner, amount);
    }

    /*================================*
     |       contract balance         |
     *================================*/
    /**
     * @dev get the current balance of the contract
    */
    function balance() onlyOwner public view returns (uint256)
    {
        return address(this).balance;
    }

    /*================================*
     |           pricing              |
     *================================*/

    /**
     * @dev get the current balance of the contract
    */
    function getlistingPrice() public view returns (uint256)
    {
        return _listingPrice;
    }

    /**
     * @dev get the current information of the contract
    */
    function changeListingPrice(uint256 amount) onlyOwner public 
    {
        _listingPrice = amount;
    }

    /**
     * @dev get the current information of the contract
    */
    function getPricings() public view returns (AdditionalPrice[] memory)
    {
        return _additionalPrices;
    }

    /**
     * @dev Changes the payment price of launchpad listings
    */
    function changePricingInfo(uint index, uint256 amount) onlyOwner public 
    {
        _additionalPrices[index].price =  amount;
    }

    /**
     * @dev Changes the payment price of launchpad listings
    */
    function addPricing(string memory name, uint256 price) onlyOwner public 
    {
       _additionalPrices.push(AdditionalPrice(_additionalPrices.length , name, price));
    }

    /*================================*
     |        verify launchpad        |
     *================================*/
    /**
     * @dev Change the verification status of the launchpad
    */
    function verifyLaunchPad(address launchpadAddress) onlyOwner public 
    {
        require(_launchPadsMap[launchpadAddress].launchpad != address(0), "launchpad not found");
        LaunchpadStruct storage launchpad = _launchPadsMap[launchpadAddress];

        _launchpadsArr[launchpad.index].verified = true;
        launchpad.verified = true;
    }

    /*================================*
     |       accepted routers         |
     *================================*/
    /**
     * @dev Returns the available lists of accepted currency for listings
    */
    function getAcceptedRouter() public view returns(MyStandardStruct[] memory) 
    {
        return _acceptedRouterArr;
    }

    /**
     * @dev Adds the new accepted currency
     * must be existing contract address to be successfully remove
    */
    function addAcceptedRouter(address contractAddress) onlyOwner public
    {
        require(_acceptedRouterMap[contractAddress].the_address == address(0), "router already added");

         MyStandardStruct memory router = MyStandardStruct(_acceptedRouterArr.length, contractAddress);

        _acceptedRouterArr.push(router);
        _acceptedRouterMap[contractAddress] = router;
    }
    
    /**
     * @dev Removes the existing dex router
     * must be existing contract address to be successfully remove
    */
    function removeAcceptedRouter(address contractAddress) onlyOwner public
    {
        require(_acceptedRouterMap[contractAddress].the_address != address(0), "router not found");

         MyStandardStruct memory router = _acceptedRouterMap[contractAddress];

        _acceptedRouterArr[_acceptedRouterArr.length-1].index = router.index;
        _acceptedRouterMap[_acceptedRouterArr[_acceptedRouterArr.length-1].the_address].index = router.index;

        _acceptedRouterArr[router.index] = _acceptedRouterArr[_acceptedRouterArr.length-1];
        
        _acceptedRouterArr.pop();
        delete _acceptedRouterMap[contractAddress];
    }

    /*================================*
     |           Launchpads           |
     *================================*/
    /**
     * @dev Returns the available lists of all launch pad listed
    */
    function getLaunchpads() public view returns(LaunchpadStruct[] memory)
    {
        return _launchpadsArr;
    }

    /**
     * @dev Returns the available lists of all launch pad listed
    */
    function getOwnedLaunchpads() public view returns(OwnedLaunchpadStuct[] memory)
    {
        return _ownedLaunchpads[_msgSender()];
    }

    /**
     * @dev Returns the available lists of all launch pad listed
    */
    function getLaunchpad(address launchpadAddress) public view returns(LaunchpadStruct memory)
    {
        return (_launchPadsMap[launchpadAddress]);
    }

    /*================================*
     |        create launchpad        |
     *================================*/
    /**
     * @dev Returns the available lists of all launch pad listed
    */
    function createLaunchpad(
        address[2] memory addresses,
        bytes32[10] memory projectDetails,
        uint256[2] memory date,
        uint256[5] memory prices,
        uint256 sellQty,
        uint256 listingPrice,
        uint256[2] memory cap,
        uint256[2] memory minmaxBuy,
        uint256[2] memory liquidity,
        bool whitelist
    ) nonReentrant() public payable returns (address)
    {
        //check if the payment is correct
        require(msg.value == _listingPrice, "invalid amount for payment");

        _checkRequiredLaunchpadInfo(
            addresses,
            date,
            prices,
            sellQty,
            listingPrice,
            cap,
            minmaxBuy,
            liquidity
        );

        address clone = Clones.clone(saleImplementation);

        ISale(clone).init(_msgSender(), addresses, projectDetails, date, prices, sellQty, listingPrice, cap, minmaxBuy, liquidity, whitelist);

        LaunchpadStruct memory launchpadStruct = LaunchpadStruct(
            _launchpadsArr.length,
            clone,
            false
        );
    
        _launchpadsArr.push(launchpadStruct);
        _launchPadsMap[clone] = launchpadStruct;
        _ownedLaunchpads[_msgSender()].push(OwnedLaunchpadStuct(addresses[1], clone));

        emit LaunchpadCreated(clone, _msgSender());
        _transferPayment(msg.value);

        return clone;
    }

    /*================================*
     |   transfer the payment to      |
     |      owner's account           |
     *================================*/
    function _transferPayment(uint256 amount) internal virtual {
        require(address(this).balance >= amount, "insufficient balance");
        
        payable(_owner).transfer(amount);
        emit TransferSent(_msgSender(), _owner, amount);
    }
    
    /**
     * @dev check the required infos for the launchpad to be created
    */
    function _checkRequiredLaunchpadInfo(
        address[2] memory addresses,
        uint256[2] memory date,
        uint256[5] memory prices,
        uint256 sellQty,
        uint256 listingPrice,
        uint256[2] memory cap,
        uint256[2] memory minmaxBuy,
        uint256[2] memory liquidity
    ) internal virtual {
        require(addresses[0] != address(0), "TOKEN: ZERO_ADDRESS");
        require(IERC20(addresses[0]).balanceOf(_msgSender()) >= sellQty, "OUT_OF_BALANCE");

        require(addresses[1] != address(0), "ROUTER: ZERO_ADDRESS");
        require(_acceptedRouterMap[addresses[1]].the_address != address(0), "ROUTER: OUT_OF_SELECTION");

        require(date[0] > block.timestamp, "START_DATE: NOT_FUTURE_DATE");
        require(date[1] > date[0], "END_DATE: LESS_THAN_START");
        
        require(prices[0] > 0, "PRESALE_RATE: ZERO_VALUE");
        require(prices[2] < 4, "AUTO_INCREASED: OUT_OF_SELECTION");
        
        if(prices[2] > 0){
            require(prices[1] > 0, "AUTO_INCREASED: ZERO_VALUE");
            if(prices[2] == 1) {
                require(prices[3] < 6, "AUTO_INCREASED_PERCENT: OUT_OF_SELECTION");
                prices[4] = 0;
            }
            else {
                require(prices[4] < 4, "AUTO_INCREASED_PERIOD: OUT_OF_SELECTION");
                prices[3] = 0;
            }
        }
        else{
            prices[1] = 0;
        }

        require(cap[0] > 0, "CAP: ZERO_VALUE");
        require(cap[1] > cap[0], "CAP: LESS_THAN_SOFT_CAP");

        require(minmaxBuy[0] > 0, "MINMAX: ZERO_VALUE");
        require(minmaxBuy[1] > minmaxBuy[0], "MINMAX: LESS_THAN_MIN");

        require(listingPrice > 0, "LISTING_PRICE: ZERO_VALUE");

        require(liquidity[0] > 40, "LIQUIDITY: LESS_THAN_NORMAL");
        require(liquidity[1] > 0, "LIQUIDITY: ZERO_TIME_VALUE");

    }

}