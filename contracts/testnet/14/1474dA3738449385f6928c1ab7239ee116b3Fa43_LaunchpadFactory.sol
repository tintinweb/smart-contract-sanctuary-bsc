//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0 ;

import "./LaunchpadContract.sol";
import "./ILaunchpadFactory.sol";
import "./Clones.sol";

contract LaunchpadFactory is ILaunchpadFactory, ReentrancyGuard, Context{
    address public immutable saleImplementation;

    address private _owner;
    uint256 private _listingPrice;
    uint256 private _createTokenPrice;

    AdditionalPrice[] private _additionalPrices;

    /**
     * @dev Accepted currency data structure
     * see {ILaunchpad} for whole Accepted currency structure
    */
    address[] private _acceptedCurrencyArr;
    mapping (address => address) private _acceptedCurrencyMap;
    /**
     * @dev Accepted currency data structure
     * see {ILaunchpad} for whole Accepted currency structure
    */
    address[] private _acceptedRouterArr;
    mapping (address => address) private _acceptedRouterMap;

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
    function withdraw(uint amount) onlyOwner public override 
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
    function balance() onlyOwner public override view returns (uint256)
    {
        return address(this).balance;
    }

    /*================================*
     |           token info           |
     *================================*/

    /**
     * @dev get information of ERC20 token
     * get only name symbol and decimals
    */
    function isLaunchpadCreated(address tokenAddress) public override view returns (address)
    {
        OwnedLaunchpadStuct[] memory launchpads = _ownedLaunchpads[_msgSender()];
        uint total = launchpads.length;

        for(uint i = 0; i<total; i++){
            if(launchpads[i].token == tokenAddress){
                return launchpads[i].launchpad;
            } 
        }

        return address(0);
    }

    /*================================*
     |           pricing              |
     *================================*/

    /**
     * @dev get the current balance of the contract
    */
    function getlistingPrice() public override view returns (uint256)
    {
        return _listingPrice;
    }

    /**
     * @dev get the current information of the contract
    */
    function changeListingPrice(uint256 amount) onlyOwner public override 
    {
        _listingPrice = amount;
    }

    /**
     * @dev get the current information of the contract
    */
    function getPricings() public override view returns (AdditionalPrice[] memory)
    {
        return _additionalPrices;
    }

    /**
     * @dev Changes the payment price of launchpad listings
    */
    function changePricingInfo(uint index, uint256 amount) onlyOwner public override 
    {
        _additionalPrices[index].price =  amount;
    }

    /**
     * @dev Changes the payment price of launchpad listings
    */
    function addPricing(string memory name, uint256 price) onlyOwner public override 
    {
       _additionalPrices.push(AdditionalPrice(_additionalPrices.length , name, price));
    }

    /*================================*
     |        verify launchpad        |
     *================================*/
    /**
     * @dev Change the verification status of the launchpad
    */
    function verifyLaunchPad(address launchpadAddress) onlyOwner public override 
    {
        require(_launchPadsMap[launchpadAddress].launchpad != address(0), "launchpad not found");
        LaunchpadStruct storage launchpad = _launchPadsMap[launchpadAddress];

        _launchpadsArr[launchpad.index].verified = true;
        launchpad.verified = true;
    }


    /*================================*
     |       accepted currency        |
     *================================*/

    /**
     * @dev Returns the available lists of accepted currency for listings
    */
    function getAcceptedCurrency() public override view returns(address[] memory) 
    {
        return _acceptedCurrencyArr;
    }
    
    /**
     * @dev Adds the new accepted currency
     * must be non existing contract address to be successfully added
    */
    function acceptedCurrency(address contractAddress) onlyOwner public override
    {
        require(_acceptedCurrencyMap[contractAddress] == address(0), "currency already added");
       
        _acceptedCurrencyArr.push(contractAddress);
        _acceptedCurrencyMap[contractAddress] = contractAddress;
    }


    /*================================*
     |       accepted routers         |
     *================================*/
    /**
     * @dev Returns the available lists of accepted currency for listings
    */
    function getAcceptedRouter() public override view returns(address[] memory) 
    {
        return _acceptedRouterArr;
    }
    
    /**
     * @dev Adds the new accepted currency
     * must be non existing contract address to be successfully added
    */
    function acceptedRouter(address contractAddress) onlyOwner public override
    {
        require(_acceptedRouterMap[contractAddress] == address(0), "router already added");

        _acceptedRouterArr.push(contractAddress);
        _acceptedRouterMap[contractAddress] = contractAddress;
    }

    /*================================*
     |           Launchpads           |
     *================================*/
    /**
     * @dev Returns the available lists of all launch pad listed
    */
    function getLaunchpads() public override view returns(LaunchpadStruct[] memory)
    {
        return _launchpadsArr;
    }

    /**
     * @dev Returns the available lists of all launch pad listed
    */
    function getOwnedLaunchpads() public override view returns(OwnedLaunchpadStuct[] memory)
    {
        return _ownedLaunchpads[_msgSender()];
    }

    /**
     * @dev Returns the available lists of all launch pad listed
    */
    function getLaunchpad(address launchpadAddress) public override view returns(LaunchpadStruct memory)
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
        address[] memory addresses,
        bytes32 projectDetails,
        uint256[] memory date,
        uint256[] memory prices,
        uint256 listingPrice,
        uint256[] memory cap,
        uint256[] memory minmaxBuy,
        uint256[] memory liquidity,
        bool whitelist
    ) nonReentrant() public override payable
    {
        //check if the payment is correct
        require(msg.value == _listingPrice, "invalid amount for payment");
        uint256 sellQty = (prices[0] * cap[1]) + ((listingPrice * cap[1]) * liquidity[0]/100);

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

        LaunchpadContract(clone).init(_msgSender(), addresses, date, prices, sellQty, listingPrice, cap, minmaxBuy, liquidity, whitelist);

        LaunchpadStruct memory launchpadStruct = LaunchpadStruct(
            _launchpadsArr.length,
            clone,
            projectDetails,
            false
        );
    
        _launchpadsArr.push(launchpadStruct);
        _launchPadsMap[clone] = launchpadStruct;
        _ownedLaunchpads[_msgSender()].push(OwnedLaunchpadStuct(addresses[1], clone));

        _transferPayment(msg.value);
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
        address[] memory addresses,
        uint256[] memory date,
        uint256[] memory prices,
        uint256 sellQty,
        uint256 listingPrice,
        uint256[] memory cap,
        uint256[] memory minmaxBuy,
        uint256[] memory liquidity
    ) internal virtual {
        require(addresses.length == 3, "fill up all required adresses");

        require(addresses[0] != address(0), "accepted currency address not specified");
        require(addresses[1] != address(0), "token address not specified");
        require(addresses[2] != address(0), "dex router address not specified");
        
        require(IERC20(addresses[1]).balanceOf(_msgSender()) >= sellQty, "not enough balance");
        require(isLaunchpadCreated(addresses[1]) == address(0), "token launchpad is already created");

        require(_acceptedCurrencyMap[addresses[0]] != address(0), "select from the accepted currency list only");
        require(_acceptedRouterMap[addresses[2]] != address(0), "select from the accepted routers list only");

        require(date.length == 2, "fill up all required dates"); 
        require(prices.length == 5, "fill up all required prices");
        require(cap.length == 2, "fill up all required price cap");
        require(minmaxBuy.length == 2, "fill up all required minmaxBuy");
        require(liquidity.length == 2, "fill up all required liquidity");
        require(listingPrice > 0, "fill up listing price");
        
        require(date[0] > block.timestamp, "you should put future date for start date");
        require(date[1] > date[0], "end date should be greater than start date");
      
        require(prices[2] < 4, "select from selection only");

        if(prices[2] > 0){
            require(prices[1] > 0, "specify auto increase value");
            if(prices[2] == 1) {
                require(prices[3] < 6, "select from selection only");
                prices[4] = 0;
            }
            else {
                require(prices[4] < 4, "select from selection only");
                prices[3] = 0;
            }
        }
        else{
            prices[1] = 0;
        }
    }

}