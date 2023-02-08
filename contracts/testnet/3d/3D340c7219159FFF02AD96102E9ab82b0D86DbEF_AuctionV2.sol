/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

contract AuctionV2
{
    uint256 private constant ONE_HUNDRED = 100**10; // 100000000000000000000;
    uint public constant UINT_NULL = 2^256-1; // 115792089237316195423570985008687907853269984665640564039457584007913129639935
    bool private lockedOwner;

    uint private auctionSeed; 

    struct AuctionKeyData
    {
        address owner;
        uint index;
    }

    struct Auction 
    {
        uint id;
        address owner;
        uint index;
        address asset;
        uint256 amount;
        uint time_start;
        uint time_end;
        uint256 auction_starting_value;
        uint256 bid_next_increase_value;
        uint256 bid_current_price;
        uint bid_paid; // (0|1)
        uint bid_finished;
        uint active;
    }

    struct BID
    {
        uint auctionId;
        address bidder;
        uint256 value;
    }

    // Auction index data by ID: ID => AuctionKeyData
    mapping(uint => AuctionKeyData) auctionKey;

    // Auction owner address / Auction record
    mapping(address => Auction[]) auctionItem;

    // Bidders list: auction id => BID
    mapping(uint => BID[]) bidders;

    // Auction owners
    address[] auctionOwnersInAction;
    mapping(address => uint) auctionOwnersInActionIndex;
    mapping(address => uint) auctionOwnersInActionActive;

    // Administrative parameters
    address public owner;
    address public feeTo;
    uint256 public newAuctionFeePercent;
    address public auctionPaymentToken;
    uint256 public postponeAuctionFeePercent;
    uint256 public winnerClaimFeePercent;
    address public bidToken;
    uint256 public bidPrice;
    uint public bidDefaultTime;
    uint256 public bidDefaultIncreasePercent;
    uint public bidderWinerTimeToPayAndClaim;

    // Administrative pricing parameters
    address public chainWrapToken;
    address public swapRouter;
    address public usdToken;

    // Events
    event OnwerChange(address indexed newValue);
    event OnAuctionRegister(uint auctionId);
    event OnAuctionFinish(uint auctionId);
    event OnAuctionPostpone(uint auctionId);
    event OnWinnerBidClaim(uint auctionId, address winner, uint256 sellprice, uint256 fee);
    event OnValuedAdminParamChanged(uint paramId, uint256 newValue);
    event OnAddressAdminParamChanged(uint paramId, address newValue);

    constructor() 
    {
        owner = msg.sender;

        auctionSeed = 1;

        /*
        56: WBNB
        137: WMATIC
        1: WETH9
        43114: WAVAX
        97: WBNB testnet
        */
        chainWrapToken = block.chainid == 56 ?  address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c) : 
                    (block.chainid == 137 ?     address(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270) :
                    (block.chainid == 1 ?       address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2) : 
                    (block.chainid == 43114 ?   address(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7) : 
                    (block.chainid == 97 ?      address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd) : 
                                                address(0) ) ) ) );

        /*
        56: PancakeFactory
        137: SushiSwap UniswapV2Router02
        1: UniswapV2Router02
        43114: Pangolin Router
        97: PancakeRouter testnet
        */
        swapRouter = block.chainid == 56 ?      address(0x10ED43C718714eb63d5aA57B78B54704E256024E) : 
                    (block.chainid == 137 ?     address(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506) : 
                    (block.chainid == 1 ?       address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D) : 
                    (block.chainid == 43114 ?   address(0x44771c71250D303d32E638c1c7ca7d00135cd65f) : 
                    (block.chainid == 97 ?      address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3) : 
                                                address(0) ) ) ) );

        /*
        56: BUSD
        137: PUSD
        1: BUSD Ethereum
        43114: USDT
        97: BUSD testnet
        */
        usdToken = block.chainid == 56 ?        address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56) : 
                    (block.chainid == 137 ?     address(0x9aF3b7DC29D3C4B1A5731408B6A9656fA7aC3b72) : 
                    (block.chainid == 1 ?       address(0x4Fabb145d64652a948d72533023f6E7A623C7C53) : 
                    (block.chainid == 43114 ?   address(0xde3A24028580884448a5397872046a019649b084) : 
                    (block.chainid == 97 ?      address(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee) : 
                                                address(0) ) ) ) );

        feeTo = owner;
        bidDefaultTime = 259200; // 72 hours
        bidDefaultIncreasePercent = (10**18)*2; // 2%
        auctionPaymentToken = usdToken; // BUSD, USDT, etc
        newAuctionFeePercent = (10**18)*2; // 2%
        postponeAuctionFeePercent = (10**18)*2; // 2%
        winnerClaimFeePercent = (10**18)*2; // 2%
        bidToken = address(0xEA96DAA186C1fa0A709929822867Ec176Af8bafF); // LOLLIPOP
        bidPrice = (10**18)*10; // 10 units
        bidderWinerTimeToPayAndClaim = 18000; // 5 hours
    }

    modifier onlyOwner 
    {
        require(msg.sender == owner, 'FN'); //Forbidden
        _;
    }

    modifier noReentrancy() 
    {
        require(!lockedOwner, "NREE"); // No Reentrance

        lockedOwner = true;
        _;
        lockedOwner = false;
    }

    modifier validAddress(address _address) 
    {
       require(_address != address(0), "INVD"); // INVD = Invalid Address
       _;
    }

    modifier validWallet
    {
        require( !Hlp.isContract(msg.sender), "CTR"); // CTR = Wallet is a contract
        require(tx.origin == msg.sender, "INVW"); // INVW = Invalid wallet origin
        _;
    }

    modifier validAuctionForBid(uint auctionId)
    {
        require(auctionId > 0 && auctionId < auctionSeed, "INVID"); // Invalid auction id
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        require(auctionItem[auctionOwner].length > auctionIndex, "IX"); // Invalid auction index
        Auction memory record = auctionItem[auctionOwner][auctionIndex];
        require(record.active == 1, "DS"); // Disabled auction
        require(record.bid_finished == 0, "AF"); // Auction finished
        require(record.bid_paid == 0, "AP"); // Auction paid
        require(record.time_end > block.timestamp, "OOT"); // Out of time
        require(bidders[auctionId].length < UINT_NULL, "MAX"); // Maximum bid reached

        uint256 allowanceForBidToken = IERC20(bidToken).allowance(msg.sender, address(this));
        require(allowanceForBidToken >= bidPrice, "BIDAL"); //Check the bid token allowance. Use approve function.

        _;
    }

    modifier auctionRegisterUsingNetworkCoinValidate(address _asset, uint256 _amount, uint256 _auctionStartingValue)
    {
        require(_auctionStartingValue > 0, "ZRO"); // Zero starting value
        require(auctionPaymentToken == chainWrapToken, "NNC"); // Not a network coin
        uint256 newAuctionFee = getNewAuctionFee(_asset, _auctionStartingValue);
        require(msg.value >= newAuctionFee, "LOW"); // Low balance to create auction

        uint256 allowanceForAsset = IERC20(_asset).allowance(msg.sender, address(this));
        require(allowanceForAsset >= _amount, "AL"); //Check the auction token allowance. Use approve function.

        _;
    }

    modifier auctionRegisterValidate(address _asset, uint256 _amount, uint256 _auctionStartingValue)
    {
        require(_auctionStartingValue > 0, "ZRO"); // Zero starting value
        require(auctionPaymentToken != chainWrapToken, "INC"); // Is a network coin

        uint256 newAuctionFee = getNewAuctionFee(_asset, _auctionStartingValue);

        uint256 allowance = IERC20(auctionPaymentToken).allowance(msg.sender, address(this));
        require(allowance >= newAuctionFee, "PAL"); //Check the payment token allowance. Use approve function.

        require(IERC20(auctionPaymentToken).balanceOf(msg.sender) >= newAuctionFee, "LOW"); // Low balance to create auction

        uint256 allowanceForAsset = IERC20(_asset).allowance(msg.sender, address(this));
        require(allowanceForAsset >= _amount, "AL"); //Check the auction token allowance. Use approve function.

        _;
    }

    modifier winnerBidderClaimUsingNetworkCoinValidate(uint auctionId, uint bidderIx)
    {
        require(auctionPaymentToken == chainWrapToken, "NNC"); // Not a network coin
        require(auctionId > 0 && auctionId < auctionSeed, "INVID"); // Invalid auction id
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        require(auctionItem[auctionOwner][auctionIndex].active == 1, "DS"); // Disabled auction

        BID memory topBidder = getTopBidder(auctionId); // Timeout will be also checked into getTopBidder

        require(topBidder.bidder == msg.sender, 'Err500');  // Unauthorized
        require(bidders[auctionId][bidderIx].bidder == topBidder.bidder && bidders[auctionId][bidderIx].value == topBidder.value, 'Err501');  // Unauthorized match with top bidder
        require(auctionItem[auctionOwner][auctionIndex].time_end > 0 && auctionItem[auctionOwner][auctionIndex].time_end <= block.timestamp, 'Err423');  // Unfinished: Locked for claim
        require(auctionItem[auctionOwner][auctionIndex].bid_paid == 0, 'Err410');  // Already paid
        require(auctionItem[auctionOwner][auctionIndex].bid_finished == 0, "FN");

        uint256 winnerClaimFee = (topBidder.value * winnerClaimFeePercent) / ONE_HUNDRED;
        require(msg.value >= topBidder.value + winnerClaimFee, 'Err402');  //Invalid payment value

        _;
    }

    modifier winnerBidderClaimValidate(uint auctionId, uint bidderIx)
    {
        require(auctionPaymentToken != chainWrapToken, "INC"); // Is a network coin
        require(auctionId > 0 && auctionId < auctionSeed, "INVID"); // Invalid auction id
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        require(auctionItem[auctionOwner][auctionIndex].active == 1, "DS"); // Disabled auction

        BID memory topBidder = getTopBidder(auctionId); // Timeout will be also checked into getTopBidder

        require(topBidder.bidder == msg.sender, 'Err500');  // Unauthorized
        require(bidders[auctionId][bidderIx].bidder == topBidder.bidder && bidders[auctionId][bidderIx].value == topBidder.value, 'Err501');  // Unauthorized match with top bidder
        require(auctionItem[auctionOwner][auctionIndex].time_end > 0 && auctionItem[auctionOwner][auctionIndex].time_end <= block.timestamp, 'Err423');  // Unfinished: Locked for claim
        require(auctionItem[auctionOwner][auctionIndex].bid_paid == 0, 'Err410');  // Already paid
        require(auctionItem[auctionOwner][auctionIndex].bid_finished == 0, "FN");

        uint256 winnerClaimFee = (topBidder.value * winnerClaimFeePercent) / ONE_HUNDRED;

        uint256 allowance = IERC20(auctionPaymentToken).allowance(msg.sender, address(this));
        require(allowance >= topBidder.value + winnerClaimFee, "PAL"); //Check the payment token allowance. Use approve function.
        require(IERC20(auctionPaymentToken).balanceOf(msg.sender) >= topBidder.value + winnerClaimFee, "LOW"); // Low balance to claim bid

        _;
    }

    modifier withdrawFromTimedoutUnclaimedAuctionValidate(uint auctionId)
    {
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        require(auctionOwner == msg.sender, 'Err500');  // Unauthorized
        require(auctionItem[auctionOwner].length > auctionIndex, "IX"); // Wrong auction index
        require(auctionItem[auctionOwner][auctionIndex].active == 1, "DS"); // Disabled auction
        require(getTopBidderIx(auctionId) == UINT_NULL, 'HASBIDDER'); // There are a top bidder
        require(auctionItem[auctionOwner][auctionIndex].time_end > 0 && auctionItem[auctionOwner][auctionIndex].time_end <= block.timestamp, 'Err423');  // Unfinished: Locked for claim
        require(auctionItem[auctionOwner][auctionIndex].bid_paid == 0, 'Err410');  // Already paid
        require(auctionItem[auctionOwner][auctionIndex].bid_finished == 0, "FN"); // Already finished
        require(auctionItem[auctionOwner][auctionIndex].amount > 0, "AM"); // Empty auction
        _;
    }

    modifier postponeFromTimedoutUnclaimedAuctionUsingNetworkCoinValidate(uint auctionId)
    {
        require(auctionPaymentToken == chainWrapToken, "NNC"); // Not a network coin
        require(auctionId > 0 && auctionId < auctionSeed, "INVID"); // Invalid auction id

        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        require(auctionOwner == msg.sender, 'Err500');  // Unauthorized
        require(auctionItem[auctionOwner].length > auctionIndex, "IX"); // Wrong auction index
        require(auctionItem[auctionOwner][auctionIndex].active == 1, "DS"); // Disabled auction
        require(getTopBidderIx(auctionId) == UINT_NULL, 'HASBIDDER'); // There are a top bidder
        require(auctionItem[auctionOwner][auctionIndex].time_end > 0 && auctionItem[auctionOwner][auctionIndex].time_end <= block.timestamp, '423');  // Unfinished: Locked for postpone
        require(auctionItem[auctionOwner][auctionIndex].bid_paid == 0, 'Err410'); // Already paid
        require(auctionItem[auctionOwner][auctionIndex].bid_finished == 0, "FN"); // Already finished

        uint256 postponeFee = getPostponeVFee(auctionItem[auctionOwner][auctionIndex].asset, auctionItem[auctionOwner][auctionIndex].auction_starting_value);
        require(msg.value >= postponeFee, "LOW"); // Insufficient value to pay the fee
        _;
    }

    modifier postponeFromTimedoutUnclaimedAuctionValidate(uint auctionId)
    {
        require(auctionPaymentToken != chainWrapToken, "INC"); // Is a network coin
        require(auctionId > 0 && auctionId < auctionSeed, "INVID"); // Invalid auction id

        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        require(auctionOwner == msg.sender, 'Err500');  // Unauthorized
        require(auctionItem[auctionOwner].length > auctionIndex, "IX"); // Wrong auction index
        require(auctionItem[auctionOwner][auctionIndex].active == 1, "DS"); // Disabled auction
        require(getTopBidderIx(auctionId) == UINT_NULL, 'HASBIDDER'); // There are a top bidder
        require(auctionItem[auctionOwner][auctionIndex].time_end > 0 && auctionItem[auctionOwner][auctionIndex].time_end <= block.timestamp, '423');  // Unfinished: Locked for postpone
        require(auctionItem[auctionOwner][auctionIndex].bid_paid == 0, 'Err410'); // Already paid
        require(auctionItem[auctionOwner][auctionIndex].bid_finished == 0, "FN"); // Already finished

        uint256 postponeFee = getPostponeVFee(auctionItem[auctionOwner][auctionIndex].asset, auctionItem[auctionOwner][auctionIndex].auction_starting_value);

        uint256 allowance = IERC20(auctionPaymentToken).allowance(msg.sender, address(this));
        require(allowance >= postponeFee, "PAL"); // Check the payment token allowance. Use approve function.
        require(IERC20(auctionPaymentToken).balanceOf(msg.sender) >= postponeFee, "LOW"); // Insufficient value to pay the fee

        _;
    }

    modifier forceAuctionToFinishValidate(uint auctionId)
    {
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        require(auctionItem[auctionOwner].length > auctionIndex, "IX"); // Wrong auction index
        require(auctionItem[auctionOwner][auctionIndex].bid_finished == 0, "FN"); // Already finished
        require(auctionItem[auctionOwner][auctionIndex].amount > 0, "AM"); // Empty auction
        _;
    }

    function auctionRegisterUsingNetworkCoin(address asset, uint256 amount, uint256 auctionStartingValue) external payable validAddress(asset) auctionRegisterUsingNetworkCoinValidate(asset, amount, auctionStartingValue) validWallet
    {
        _auciontRegister(asset, amount, auctionStartingValue);

        // Send fee to fee to address
        payable(feeTo).transfer(msg.value);
    }

    function auciontRegister(address asset, uint256 amount, uint256 auctionStartingValue) external validAddress(asset) auctionRegisterValidate(asset, amount, auctionStartingValue) validWallet
    {
        _auciontRegister(asset, amount, auctionStartingValue);

        uint256 newAuctionFee = getNewAuctionFee(asset, auctionStartingValue);

        bool txOk = IERC20(auctionPaymentToken).transferFrom(msg.sender, feeTo, newAuctionFee);
        require(txOk, "TXERR"); // TXERR = Transaction Error
    }

    function _auciontRegister(address asset, uint256 amount, uint256 auctionStartingValue) internal
    {
        uint timeStart = block.timestamp;
        uint timeEnd = timeStart + bidDefaultTime;

        //If is not a current auction owner, register it
        if(auctionOwnersInActionActive[msg.sender] == 0)
        {
            auctionOwnersInAction.push(msg.sender);
            auctionOwnersInActionIndex[msg.sender] = auctionOwnersInAction.length -1;
            auctionOwnersInActionActive[msg.sender] = 1;
        }

        uint auctionArrayIndex = auctionItem[msg.sender].length;

        auctionItem[msg.sender].push(Auction({
            id: auctionSeed,
            owner: msg.sender,
            index: auctionArrayIndex,
            asset: asset,
            amount: amount,
            time_start: timeStart,
            time_end: timeEnd,
            auction_starting_value: auctionStartingValue,
            bid_next_increase_value: auctionStartingValue + ((auctionStartingValue * bidDefaultIncreasePercent) / ONE_HUNDRED),
            bid_current_price: auctionStartingValue,
            bid_paid: 0,
            bid_finished: 0,
            active: 1
        }));

        auctionKey[auctionSeed] = AuctionKeyData({
            owner: msg.sender,
            index: auctionArrayIndex
        });

        emit OnAuctionRegister(auctionSeed);

        auctionSeed++;

        bool txOk = IERC20(asset).transferFrom(msg.sender, address(this), amount);
        require(txOk, "TXERR"); // TXERR = Transaction Error
    }

    function getNewAuctionFee(address asset, uint256 auctionStartingValue) public view returns(uint256)
    {
        uint256 newAuctionFee = (auctionStartingValue * newAuctionFeePercent) / ONE_HUNDRED;
        if(asset == auctionPaymentToken)
        {
            return newAuctionFee;
        }
        uint256 newAuctionFeeInPaymentCoin = getAmountOutMin(asset, auctionPaymentToken, newAuctionFee);
        return newAuctionFeeInPaymentCoin;
    }

    function getPostponeVFee(address asset, uint256 auctionStartingValue) public view returns(uint256)
    {
        uint256 postponeVFee = (auctionStartingValue * postponeAuctionFeePercent) / ONE_HUNDRED;
        if(asset == auctionPaymentToken)
        {
            return postponeVFee;
        }         
        uint256 postponeVFeeInPaymentCoin = getAmountOutMin(asset, auctionPaymentToken, postponeVFee);
        return postponeVFeeInPaymentCoin;
    }

    function auctionFinish(uint auctionId) internal
    {
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        auctionItem[auctionOwner][auctionIndex].bid_finished = 1;
        emit OnAuctionFinish(auctionId);
    }

    // function getAllAuction() external view returns (uint listSize, Auction[] memory list) 
    function getAllAuction() external view returns (Auction[] memory list) 
    {
        uint count = auctionSeed - 1;
        Auction[] memory auctionList = new Auction[](count);

        uint i;
        for(uint ixAuctionOwner = 0; ixAuctionOwner < auctionOwnersInAction.length; ixAuctionOwner++)
        {
            address auctionOwner = auctionOwnersInAction[ixAuctionOwner];
            Auction[] memory auctionOwnerList = auctionItem[auctionOwner];
            for(uint ixAuction = 0; ixAuction < auctionOwnerList.length; ixAuction++)
            {
                auctionList[i] = auctionOwnerList[ixAuction];
                i++;
            }
        }

        // return (count, auctionList);
        return auctionList;
    }

    function getAuctionById(uint auctionId) external view returns (Auction memory result) 
    {
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        return auctionItem[auctionOwner][auctionIndex];
    }

    function getAuctionOwnerCount() external view returns (uint result)
    {
        return auctionOwnersInAction.length;
    }

    function getAuctionOwnerAddressByIndex(uint arrayIndex) external view returns (address result)
    {
        return auctionOwnersInAction[arrayIndex];
    }

    function doBid(uint auctionId) external validAuctionForBid(auctionId) validWallet
    {
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        //Set new BID
        auctionItem[auctionOwner][auctionIndex].bid_current_price = auctionItem[auctionOwner][auctionIndex].bid_next_increase_value;
        auctionItem[auctionOwner][auctionIndex].bid_next_increase_value = auctionItem[auctionOwner][auctionIndex].bid_current_price + ( (auctionItem[auctionOwner][auctionIndex].bid_current_price * bidDefaultIncreasePercent) / ONE_HUNDRED );
        bidders[auctionId].push(BID({
            auctionId: auctionId,
            bidder: msg.sender, 
            value: auctionItem[auctionOwner][auctionIndex].bid_current_price
        }));

        bool txOk = IERC20(bidToken).transferFrom(msg.sender, feeTo, bidPrice);
        require(txOk, "TXERR"); // TXERR = Transaction Error
    }

    function getBidders(uint auctionId) external view returns(BID[] memory result)
    {
        return bidders[auctionId];
    }

    function getTopBidder(uint auctionId) public view returns (BID memory result)
    {
        if(bidders[auctionId].length > 0)
        {
            uint topIx = getTopBidderIx(auctionId);

            if(topIx != UINT_NULL)
            {
                return bidders[auctionId][topIx];
            }
        }

        BID memory emptyBID = BID({
            auctionId: auctionId,
            bidder: address(0),
            value: 0
        });
        return emptyBID;
    }

    function getTopBidderIx(uint auctionId) public view returns(uint result)
    {
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        if(bidders[auctionId].length > 0)
        {
            //If auction is not finished, it does not check pay/claim timeout
            if(auctionItem[auctionOwner][auctionIndex].time_end > block.timestamp)
            {
                return bidders[auctionId].length - 1;
            }

            uint topIx = UINT_NULL;
            uint position = bidders[auctionId].length;

            //uint256 topValue = 0;

            do
            {
                //Auction is finished, check pay/claim timeout
                uint isTimedOutForBidder = getBidderPayClaimIsTimedOut(auctionId, position-1);

                //Set as Top Bidder if is not timed-out
                if(isTimedOutForBidder == 0)
                {
                    //topValue = bidders[auctionId][ix].value;
                    topIx = position-1;
                    break;
                }

                if(position-1 == 0)
                {
                    break; //uint cannot be negative
                }

                position--;
            }
            while(position > 0);

            return topIx;

        }

        return UINT_NULL;
    }

    function getBidderPayClaimIsTimedOut(uint auctionId, uint bidderIx) public view returns (uint result)
    {
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        //Auction initialized check
        if(auctionItem[auctionOwner].length <= auctionIndex)
        {
            return 0;
        }

        //Auction is finished check
        if(auctionItem[auctionOwner][auctionIndex].bid_finished == 1)
        {
            return 1;
        }

        //Auction time finished check
        if(block.timestamp < auctionItem[auctionOwner][auctionIndex].time_end)
        {
            return 0;
        }

        //Bidders list is not empty
        if(bidders[auctionId].length == 0)
        {
            return 0;
        }

        //Index exists into bidders list
        if(bidders[auctionId].length <= bidderIx)
        {
            return 0;
        }

        //Allowed time based on bid registration position (value = time_to_claim X top_position)
        uint valueToMultiplyForPosition = bidders[auctionId].length - bidderIx;
        uint allowedTimeAfterFinish = bidderWinerTimeToPayAndClaim * valueToMultiplyForPosition;
        uint maxTime = auctionItem[auctionOwner][auctionIndex].time_end + allowedTimeAfterFinish;

        //Check current time is greather than allowed time after finish to set as timed-out
        if(block.timestamp <= maxTime)
        {
            //Still has time
            return 0;
        }

        //Timed-out
        return 1;
    }


    function getWinnerBIDMaxTime(uint auctionId, uint bidderIx) external view returns (uint result)
    {
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        //Auction is finished check
        if(block.timestamp > auctionItem[auctionOwner][auctionIndex].time_end)
        {
            //Bidders list is not empty
            if(bidders[auctionId].length > 0)
            {
                //Index exists into bidders list
                if(bidders[auctionId].length > bidderIx)
                {
                    //Allowed time based on bid registration position (value = time_to_claim X top_position)
                    uint valueToMultiplyForPosition = bidders[auctionId].length - bidderIx;
                    uint allowedTimeAfterFinish = bidderWinerTimeToPayAndClaim * valueToMultiplyForPosition;
                    uint maxTime = auctionItem[auctionOwner][auctionIndex].time_end + allowedTimeAfterFinish;

                    return maxTime;
                }
            }
        }

        return 0;
    }

    function doWinnerBidderClaimUsingNetworkCoin(uint auctionId, uint bidderIx) external payable winnerBidderClaimUsingNetworkCoinValidate(auctionId, bidderIx) validWallet
    {
        BID memory topBidder = getTopBidder(auctionId); //Timeout will be also checked into getTopBidder
        uint256 winnerClaimFee = (topBidder.value * winnerClaimFeePercent) / ONE_HUNDRED;

        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        _doWinnerBidderClaim(auctionId, winnerClaimFee, topBidder);
        
        // Send fee to fee to address
        payable(feeTo).transfer(winnerClaimFee);

        // Send BID value to Auction owner
        payable(auctionOwner).transfer(topBidder.value);

        // Send BID amount to winner
        bool txOk = IERC20(auctionItem[auctionOwner][auctionIndex].asset).transfer(msg.sender, auctionItem[auctionOwner][auctionIndex].amount);
        require(txOk, "TXERR"); // TXERR = Transaction Error
    }

    function doWinnerBidderClaim(uint auctionId, uint bidderIx) external winnerBidderClaimValidate(auctionId, bidderIx) validWallet
    {
        BID memory topBidder = getTopBidder(auctionId); //Timeout will be also checked into getTopBidder
        uint256 winnerClaimFee = (topBidder.value * winnerClaimFeePercent) / ONE_HUNDRED;

        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        _doWinnerBidderClaim(auctionId, winnerClaimFee, topBidder);
        
        // Send fee to fee to address
        bool txFeeOk = IERC20(auctionPaymentToken).transferFrom(msg.sender, feeTo, winnerClaimFee);
        require(txFeeOk, "CFTXERR"); // CFTXERR = Claim Fee Transaction Error

        // Send BID value to Auction owner
        bool txValueOk = IERC20(auctionPaymentToken).transferFrom(msg.sender, auctionOwner, topBidder.value);
        require(txValueOk, "CVTXERR"); // CVTXERR = Claim Value Transaction Error

        // Send BID amount to winner
        bool txOk = IERC20(auctionItem[auctionOwner][auctionIndex].asset).transfer(msg.sender, auctionItem[auctionOwner][auctionIndex].amount);
        require(txOk, "TXERR"); // TXERR = Transaction Error
    }

    function _doWinnerBidderClaim(uint auctionId, uint256 winnerClaimFee, BID memory topBidder) internal
    {
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        auctionItem[auctionOwner][auctionIndex].bid_paid = 1;

        emit OnWinnerBidClaim(auctionId, msg.sender, topBidder.value, winnerClaimFee);

        auctionFinish(auctionId);
    }

    function doWithdrawalFromTimedoutUnclaimedAuction(uint auctionId) external withdrawFromTimedoutUnclaimedAuctionValidate(auctionId) validWallet
    {
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        auctionFinish(auctionId);

        // Send BID amount back to owner
        bool txOk = IERC20(auctionItem[auctionOwner][auctionIndex].asset).transfer(msg.sender, auctionItem[auctionOwner][auctionIndex].amount);
        require(txOk, "TXERR"); // TXERR = Transaction Error
    }

    function doPostponeFromTimedoutUnclaimedAuctionUsingNetworkCoin(uint auctionId) external payable postponeFromTimedoutUnclaimedAuctionUsingNetworkCoinValidate(auctionId) validWallet
    {
        // uint256 postponeFee = getPostponeVFee(auctionItem[auctionOwner][auctionIndex].asset, auctionItem[auctionOwner][auctionIndex].auction_starting_value);

        _doPostponeFromTimedoutUnclaimedAuction(auctionId);

        //Send fee to fee to address
        payable(feeTo).transfer(msg.value);
    }

    function doPostponeFromTimedoutUnclaimedAuction(uint auctionId) external postponeFromTimedoutUnclaimedAuctionValidate(auctionId) validWallet
    {
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        uint256 postponeFee = getPostponeVFee(auctionItem[auctionOwner][auctionIndex].asset, auctionItem[auctionOwner][auctionIndex].auction_starting_value);

        _doPostponeFromTimedoutUnclaimedAuction(auctionId);

        //Send fee to fee to address
        bool txOk = IERC20(auctionPaymentToken).transferFrom(msg.sender, feeTo, postponeFee);
        require(txOk, "TXERR"); // TXERR = Transaction Error
    }

    function _doPostponeFromTimedoutUnclaimedAuction(uint auctionId) internal
    {
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        //Set new end date
        uint time_end = block.timestamp + bidDefaultTime;
        auctionItem[auctionOwner][auctionIndex].time_end = time_end;

        emit OnAuctionPostpone(auctionId);
    }





    /* *****************************
        SUDO
    *  *****************************/
    function setOwner(address newValue) external onlyOwner noReentrancy validAddress(newValue)
    {
        owner = newValue;
        emit OnwerChange(newValue);
    }

    function transferFund(address token, address to, uint256 amountInWei) external onlyOwner noReentrancy validAddress(token) validAddress(to)
    {
        //Withdraw token
        bool txOk = IERC20(token).transfer(to, amountInWei);
        require(txOk, "TXERR"); // TXERR = Transaction Error
    }

    function transferNetworkCoinFund(address to, uint256 amountInWei) external onlyOwner noReentrancy validAddress(to)
    {
        //Withdraw Network Coin
        payable(to).transfer(amountInWei);
    }

    function setActiveAuction(uint auctionId, uint value) external onlyOwner noReentrancy
    {
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;
        auctionItem[auctionOwner][auctionIndex].active = value;
    }

    function forceAuctionToFinish(uint auctionId) external onlyOwner noReentrancy forceAuctionToFinishValidate(auctionId)
    {
        // Operation similar to doWithdrawalFromTimedoutUnclaimedAuction
        address auctionOwner = auctionKey[auctionId].owner;
        uint auctionIndex = auctionKey[auctionId].index;

        auctionFinish(auctionId);

        // Send BID amount back to owner
        bool txOk = IERC20(auctionItem[auctionOwner][auctionIndex].asset).transfer(msg.sender, auctionItem[auctionOwner][auctionIndex].amount);
        require(txOk, "TXERR"); // TXERR = Transaction Error
    }

    function setFeeTo(address newValue) external onlyOwner noReentrancy validAddress(newValue)
    {
        feeTo = newValue;
        emit OnAddressAdminParamChanged(1, newValue);
    }

    function setNewAuctionFeePercent(uint256 newValue) external onlyOwner noReentrancy
    {
        newAuctionFeePercent = newValue;
        emit OnValuedAdminParamChanged(2, newValue);
    }

    function setAuctionPaymentToken(address newValue) external onlyOwner noReentrancy validAddress(newValue)
    {
        auctionPaymentToken = newValue;
        emit OnAddressAdminParamChanged(3, newValue);
    }

    function setPostponeAuctionFeePercent(uint256 newValue) external onlyOwner noReentrancy
    {
        postponeAuctionFeePercent = newValue;
        emit OnValuedAdminParamChanged(4, newValue);
    }

    function setWinnerClaimFeePercent(uint256 newValue) external onlyOwner noReentrancy
    {
        winnerClaimFeePercent = newValue;
        emit OnValuedAdminParamChanged(5, newValue);
    }

    function setBidToken(address newValue) external onlyOwner noReentrancy validAddress(newValue)
    {
        bidToken = newValue;
        emit OnAddressAdminParamChanged(6, newValue);
    }

    function setBidPrice(uint256 newValue) external onlyOwner noReentrancy
    {
        bidPrice = newValue;
        emit OnValuedAdminParamChanged(7, newValue);
    }

    function setBidDefaultTime(uint newValue) external onlyOwner noReentrancy
    {
        bidDefaultTime = newValue;
        emit OnValuedAdminParamChanged(8, newValue);
    }

    function setBidDefaultIncreasePercent(uint256 newValue) external onlyOwner noReentrancy
    {
        bidDefaultIncreasePercent = newValue;
        emit OnValuedAdminParamChanged(9, newValue);
    }

    function setBidWinnerTimeToPayAndClaim(uint newValue) external onlyOwner noReentrancy
    {
        bidderWinerTimeToPayAndClaim = newValue;
        emit OnValuedAdminParamChanged(10, newValue);
    }


    function setChainWrapToken(address newValue) external onlyOwner noReentrancy validAddress(newValue)
    {
        chainWrapToken = newValue;
        emit OnAddressAdminParamChanged(11, newValue);
    }

    function setSwapRouter(address newValue) external onlyOwner noReentrancy validAddress(newValue)
    {
        swapRouter = newValue;
        emit OnAddressAdminParamChanged(12, newValue);
    }

    function setUSDToken(address newValue) external onlyOwner noReentrancy validAddress(newValue)
    {
        usdToken = newValue;
        emit OnAddressAdminParamChanged(13, newValue);
    }




    /* **********************************************************
            SWAP FUNCTIONS
    *  **********************************************************/

    // function getUSDPrice(address token, uint256 amount, uint multihopWithWrapToken) external view returns (uint256)
    function getUSDPrice(address token, uint256 amount) external view returns (uint256)
    {
        // uint256 result = getAmountOutMin(token, usdToken, amount, multihopWithWrapToken);
        uint256 result = getAmountOutMin(token, usdToken, amount);
        return result;
    }

    // function getAmountOutMin(address tokenIn, address tokenOut, uint256 amountIn, uint multihopWithWrapToken) public view returns (uint256) 
    function getAmountOutMin(address tokenIn, address tokenOut, uint256 amountIn) public view returns (uint256) 
    {

       //path is an array of addresses.
       //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
       //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path;
       
        path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        uint256[] memory amountOutMins = IUniswapV2Router(swapRouter).getAmountsOut(amountIn, path);
        return amountOutMins[path.length -1];  
    }
}

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _value) external returns (bool);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
  
    function swapExactTokensForTokens(
        //amount of tokens we are sending in
        uint256 amountIn,
        
        //the minimum amount of tokens we want out of the trade
        uint256 amountOutMin,
    
        //list of token addresses we are going to trade in.  this is necessary to calculate amounts
        address[] calldata path,
    
        //this is the address we are going to send the output tokens to
        address to,
    
        //the last time that the trade is valid for
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external returns (uint[] memory amounts);
}

// ****************************************************
// ***************** HELPER FUNCTIONS *****************
// ****************************************************
library Hlp 
{
    function isContract(address account) internal view returns (bool) 
    {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}