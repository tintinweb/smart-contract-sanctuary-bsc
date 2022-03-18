pragma solidity ^0.5.0;

import "./Feeder.sol";

contract FeederFactory {
    event FeederCreated(address indexed owner, address indexed feedAddr);

    function create(address f1,address f2 ,address f3,bytes32 fiatCode, bytes32 collateralCode) public returns (address) {
        Feeder feeder = new Feeder(f1,f2,f3,msg.sender, fiatCode, collateralCode);
        emit FeederCreated(msg.sender, address(feeder));
        return address(feeder);
    }
}

pragma solidity ^0.5.0;

import "../interfaces/IFeeder.sol";
import "../book-room/CustomSafeMath.sol";

contract Feeder is IFeeder {
    using CustomSafeMath for uint;
    struct FeedPrice {
        uint priceInWei;
        uint timeInSecond;
        address source;
    }
    FeedPrice public firstPrice;
    FeedPrice public secondPrice;
    FeedPrice public lastPrice;
    uint public priceTolInBP = 500;
    uint constant BP_DENOMINATOR = 10000;
    uint public priceFeedTimeTol = 5 minutes;
    uint public priceUpdateCoolDown=15 minutes;
    uint public numOfPrices = 0;

    bool public started = false;
    address public priceFeed1;
    address public priceFeed2;
    address public priceFeed3;
    address public owner;


    bytes32 public fiatCode;
    bytes32 public collateralCode;

    event CommitPrice(uint indexed priceInWei, uint indexed timeInSecond, address sender, uint index);
    event AcceptPrice(uint indexed priceInWei, uint indexed timeInSecond, address sender);
    event UpdatePriceFeed(address updater, address newPriceFeed);
    event SetValue(uint index, uint oldValue, uint newValue);

    constructor(
        address pf1,
        address pf2,
        address pf3,
        address _owner,
        bytes32 _fiatCode,
        bytes32 _collateralCode) public {
        priceFeed1 = pf1;
        priceFeed2 = pf2;
        priceFeed3 = pf3;
        owner = _owner;
        fiatCode = _fiatCode;
        collateralCode = _collateralCode;
        lastPrice.timeInSecond =getNowTimestamp() ;
        lastPrice.priceInWei = 0;
        lastPrice.source = msg.sender;
    }
    /*
     * Modifier
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Feeder.onlyOwner: caller must be an owner of this contract");
        _;
    }
    modifier isPriceFeed() {
        require(msg.sender == priceFeed1 || msg.sender == priceFeed2 || msg.sender == priceFeed3);
        _;
    }

    /*
 * Public Functions
 */
    function startOracle(uint priceInWei)
    external isPriceFeed
    returns (bool success)
    {
        require(!started);
        require(priceInWei>0,"price need >0");
        uint timeInSecond=getNowTimestamp();
        lastPrice.timeInSecond = timeInSecond;
        lastPrice.priceInWei = priceInWei;
        lastPrice.source = msg.sender;
        started = true;
        emit AcceptPrice(priceInWei, timeInSecond, msg.sender);
        return true;
    }

    function commitPrice(uint priceInWei)
    external isPriceFeed
    returns (bool success)
    {
        uint timeInSecond=getNowTimestamp();
        require(started && timeInSecond >= lastPrice.timeInSecond.add(priceUpdateCoolDown));
        uint priceDiff;
        if (numOfPrices == 0) {
            priceDiff = priceInWei.diff(lastPrice.priceInWei);
            if (priceDiff.mul(BP_DENOMINATOR).div(lastPrice.priceInWei) <= priceTolInBP) {
                acceptPrice(priceInWei, timeInSecond, msg.sender);
            } else {
                // wait for the second price
                firstPrice = FeedPrice(priceInWei, timeInSecond, msg.sender);
                emit CommitPrice(priceInWei, timeInSecond, msg.sender, 0);
                numOfPrices++;
            }
        } else if (numOfPrices == 1) {
            if (timeInSecond > firstPrice.timeInSecond.add(priceUpdateCoolDown)) {
                if (firstPrice.source == msg.sender)
                    acceptPrice(priceInWei, timeInSecond, msg.sender);
                else
                    acceptPrice(firstPrice.priceInWei, timeInSecond, firstPrice.source);
            } else {
                require(firstPrice.source != msg.sender);
                // if second price times out, use first one
                if (firstPrice.timeInSecond.add(priceFeedTimeTol) < timeInSecond) {
                    acceptPrice(firstPrice.priceInWei, firstPrice.timeInSecond, firstPrice.source);
                } else {
                    priceDiff = priceInWei.diff(firstPrice.priceInWei);
                    if (priceDiff.mul(BP_DENOMINATOR).div(firstPrice.priceInWei) <= priceTolInBP) {
                        acceptPrice(firstPrice.priceInWei, firstPrice.timeInSecond, firstPrice.source);
                    } else {
                        // wait for the third price
                        secondPrice = FeedPrice(priceInWei, timeInSecond, msg.sender);
                        emit CommitPrice(priceInWei, timeInSecond, msg.sender, 1);
                        numOfPrices++;
                    }
                }
            }
        } else if (numOfPrices == 2) {
            if (timeInSecond > firstPrice.timeInSecond.add(priceUpdateCoolDown)) {
                if ((firstPrice.source == msg.sender || secondPrice.source == msg.sender))
                    acceptPrice(priceInWei, timeInSecond, msg.sender);
                else
                    acceptPrice(secondPrice.priceInWei, timeInSecond, secondPrice.source);
            } else {
                require(firstPrice.source != msg.sender && secondPrice.source != msg.sender);
                uint acceptedPriceInWei;
                // if third price times out, use first one
                if (firstPrice.timeInSecond.add(priceFeedTimeTol) < timeInSecond) {
                    acceptedPriceInWei = firstPrice.priceInWei;
                } else {
                    // take median and proceed
                    // first and second price will never be equal in this part
                    // if second and third price are the same, they are median
                    if (secondPrice.priceInWei == priceInWei) {
                        acceptedPriceInWei = priceInWei;
                    } else {
                        acceptedPriceInWei = getMedian(firstPrice.priceInWei, secondPrice.priceInWei, priceInWei);
                    }
                }
                acceptPrice(acceptedPriceInWei, firstPrice.timeInSecond, firstPrice.source);
            }
        } else {
            return false;
        }

        return true;
    }

    /*Internal Functions
     */
    function acceptPrice(uint priceInWei, uint timeInSecond, address source) internal {
        lastPrice.priceInWei = priceInWei;
        lastPrice.timeInSecond = timeInSecond;
        lastPrice.source = source;
        numOfPrices = 0;
        emit AcceptPrice(priceInWei, timeInSecond, source);
    }

    function getMedian(uint a, uint b, uint c) internal pure returns (uint) {
        if (a.gt(b) ^ c.gt(a) == 0x0) {
            return a;
        } else if(b.gt(a) ^ c.gt(b) == 0x0) {
            return b;
        } else {
            return c;
        }
    }

    function getNowTimestamp() internal view returns (uint) {
        return now;
    }

    function getLastPrice() external view returns(uint, uint) {
        return (lastPrice.priceInWei, lastPrice.timeInSecond);
    }
    // start of operator function
    function updatePriceFeed(uint index,address feeder)
    external
    onlyOwner
    returns (bool) {
        require(index < 3);
        address updater = msg.sender;
        address newAddr = feeder;
        if(index == 0)
            priceFeed1 = newAddr;
        else if (index == 1)
            priceFeed2 = newAddr;
        else // index == 2
            priceFeed3 = newAddr;

        emit UpdatePriceFeed(updater, newAddr);
        return true;
    }
    /*
      update  value
    */
    function setValue(
        uint idx,
        uint newValue
    )
    public
    onlyOwner
    returns (bool success) {
        uint oldValue;
        if (idx == 0) {
            oldValue = priceTolInBP;
            priceTolInBP = newValue;
        }  else if (idx == 1) {
            oldValue = priceFeedTimeTol;
            priceFeedTimeTol = newValue;
        } else if (idx == 2) {
            oldValue = priceUpdateCoolDown;
            priceUpdateCoolDown = newValue;
        } else {
            revert();
        }

        emit SetValue(idx, oldValue, newValue);
        return true;
    }

}

pragma solidity ^0.5.0;

interface IFeeder {
    function commitPrice(uint priceInWei) external  returns (bool);
    function startOracle(uint priceInWei) external  returns (bool);
    function getLastPrice() external view returns(uint, uint);
    event CommitPrice(uint indexed priceInWei, uint indexed timeInSecond, address sender, uint index);
    event AcceptPrice(uint indexed priceInWei, uint indexed timeInSecond, address sender);
}

pragma solidity ^0.5.0;

library CustomSafeMath {
	function mul(uint a, uint b) internal pure returns (uint) {
		uint c = a * b;
		require(a == 0 || c / a == b);
		return c;
	}

	function div(uint a, uint b) internal pure returns (uint) {
		require (b > 0 , "CustomSafeMath: division by zero") ;
		uint c = a / b;
		return c;
	}

	function sub(uint a, uint b) internal pure returns (uint) {
		require(b <= a);
		return a - b;
	}

	function add(uint a, uint b) internal pure returns (uint) {
		uint c = a + b;
		require(c >= a);
		return c;
	}

	function diff(uint a, uint b) internal pure returns (uint) {
		return a > b ? sub(a, b) : sub(b, a);
	}

	function gt(uint a, uint b) internal pure returns(bytes1) {
		bytes1 c;
		c = 0x00;
		if (a > b) {
			c = 0x01;
		}
		return c;
	}
}