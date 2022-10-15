/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract HealEstateWealthChamber is Context, Ownable {
    
    using SafeMath for uint256;

    struct User{
        uint id;
        address userAddress;
        mapping(uint => Subscription) subscriptions;
    }

    struct Subscription {
        uint expiration;
        uint created;
    }

    mapping(address => User) public users;

    struct Product {
        bool status;
        uint cost;
        uint minLevelrequired;
        uint toVault;
        uint[] toSponsors;
        address vaultAddress;
        uint subscriptionTime;
        uint subscribers;
        mapping(address => bool) whitelisted;
    }

    mapping(uint => Product) public products;
    uint public totalProducts = 0;

    //Configuration
    address private constant CORE_CONTRACT = 0xC6B19D87e2815f6b31a069DfC71032732cf0aCA6;
    uint public GRACEPERIOD = 172800; //Number of seconds before expiry anyone is allowed to renew
    
    event newPayment(uint payer_id, uint receiver_id, uint product_id, uint level);
    event newSubscription(uint indexed user_id, uint product_id, uint newExpiration, bool isNewSubscriber);
    event updateUSDRate(uint256 rate);
    
    fallback() external {
        require(false, "Denied");
    }

    function buySubscription(uint productId) external payable {

        require(msg.value >= convertDollarToCrypto(products[productId].cost.div(100)), "Invalid Amount");
        address userAddress = _msgSender();
        require(products[productId].subscriptionTime > 0, "Product Not Found!");

        if(products[productId].status == false) {
            require(products[productId].whitelisted[userAddress], "Product not live or you are not whitelisted.");
        }

        //Check if user is registered in core system first
        uint userId = getCoreUserId(userAddress);
        require(userId > 0, "Register in Core Project first");

        //Get user active level and check if he/she is greater than required level
        if(users[userAddress].subscriptions[productId].expiration > 0) {
            require(block.timestamp > users[userAddress].subscriptions[productId].expiration.sub(GRACEPERIOD), "Too soon to renew.");
        }
        require(checkUserLevelInCore(userAddress, uint8(products[productId].minLevelrequired)), "Upgrade to required level first");

        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "Cannot be a contract");
        
        //Create new subscription
        bool isNewSubscriber = false;
        if(users[userAddress].subscriptions[productId].expiration == 0) {
            isNewSubscriber = true;
            Subscription memory subscription = Subscription({
                expiration: block.timestamp.add(products[productId].subscriptionTime),
                created: block.timestamp
            });
            users[userAddress].subscriptions[productId] = subscription;
            products[productId].subscribers = products[productId].subscribers.add(1);

        } else {
            if(users[userAddress].subscriptions[productId].expiration > block.timestamp) {
                users[userAddress].subscriptions[productId].expiration = users[userAddress].subscriptions[productId].expiration.add(products[productId].subscriptionTime);
            } else {
                users[userAddress].subscriptions[productId].expiration = block.timestamp.add(products[productId].subscriptionTime);
            }
        }

        //Send money to vault
        if(products[productId].toVault > 0) {
            if(!payable(products[productId].vaultAddress).send(convertDollarToCrypto(products[productId].toVault.div(100)))) {
                payable(products[productId].vaultAddress).transfer(convertDollarToCrypto(products[productId].toVault.div(100)));
            }
            emit newPayment(userId, 1, productId, 0);
        }
        
        //Send money to uplines
        address uplineAddress = userAddress;
        for(uint i = 1; i <= products[productId].toSponsors.length; i++) {
            if(uplineAddress == getCoreOwner()) {
                uplineAddress = getCoreOwner();
            } else {
                uplineAddress = getCoreuserUpline(uplineAddress);
            }
            if(!payable(uplineAddress).send(convertDollarToCrypto(products[productId].toSponsors[i.sub(1)].div(100)))) {
                payable(uplineAddress).transfer(convertDollarToCrypto(products[productId].toSponsors[i.sub(1)].div(100)));
            }
            emit newPayment(userId, getCoreUserId(uplineAddress), productId, i);
        }

        emit newSubscription(userId, productId, users[userAddress].subscriptions[productId].expiration, isNewSubscriber);
        return;
    }
    
    function getCoreUserId(address userAddress) public view returns (uint) {
	    bytes memory payload = abi.encodeWithSignature("users(address)", userAddress);
        (bool success, bytes memory data) = address(CORE_CONTRACT).staticcall(payload);
        require(success, "Could not connect to Core Contract");
        (uint id,,) = abi.decode(data, (uint, address, uint));
        return id;
	}
    
    function getCoreuserUpline(address userAddress) public view returns (address) {
	    bytes memory payload = abi.encodeWithSignature("users(address)", userAddress);
        (bool success, bytes memory data) = address(CORE_CONTRACT).staticcall(payload);
        require(success, "Could not connect to Core Contract");
        (, address referrer,) = abi.decode(data, (uint, address, uint));
        return referrer;
	}

    function checkUserLevelInCore(address userAddress, uint8 level) public view returns (bool) {
	    bytes memory payload = abi.encodeWithSignature("userslevelsActive(address,uint8)",userAddress,level);
        (bool success, bytes memory data) = address(CORE_CONTRACT).staticcall(payload);
        require(success, "Could not connect to Core Contract");
        (bool result) = abi.decode(data, (bool));
        return result;
	}

    function getCoreUSDRate() public view returns (uint) {
	    bytes memory payload = abi.encodeWithSignature("USD_RATE()");
        (bool success, bytes memory data) = address(CORE_CONTRACT).staticcall(payload);
        require(success, "Could not connect to Core Contract");
        (uint result) = abi.decode(data, (uint));
        return result;
	}

    function getCoreOwner() public view returns (address) {
	    bytes memory payload = abi.encodeWithSignature("owner()");
        (bool success, bytes memory data) = address(CORE_CONTRACT).staticcall(payload);
        require(success, "Could not connect to Core Contract");
        (address result) = abi.decode(data, (address));
        return result;
	}

    //Get Crypto Amount
    function convertDollarToCrypto(uint256 dollarVal) public view returns(uint256) {
       return ((dollarVal*100000/getCoreUSDRate())  * 1 ether)/100000;
    }

    function adjustGRACEPERIOD(uint256 period) external onlyOwner {
        GRACEPERIOD = period;
    }

    function addNewProduct(uint cost, uint minLevelrequired, uint toVault, uint[] memory toSponsors, address _vaultAddress,  uint subscriptionTime) external onlyOwner {
        totalProducts = totalProducts.add(1);
        
        Product storage product = products[totalProducts];
        product.status = false;
        product.cost = cost;
        product.minLevelrequired = minLevelrequired;
        product.toVault = toVault;
        product.toSponsors = toSponsors;
        product.vaultAddress = _vaultAddress;
        product.subscriptionTime = subscriptionTime;
        product.subscribers = 0;

    }

    function editProduct(uint productId, uint cost, uint minLevelrequired, uint toVault, uint[] memory toSponsors, address _vaultAddress, uint subscriptionTime) external onlyOwner {
        products[productId].cost = cost;
        products[productId].minLevelrequired = minLevelrequired;
        products[productId].toVault = toVault;
        products[productId].toSponsors = toSponsors;
        products[productId].vaultAddress = _vaultAddress;
        products[productId].subscriptionTime = subscriptionTime;
    }

    function editProductStatus(uint productId, bool status) external onlyOwner {
        products[productId].status = status;
    }
    
    function whitelistWallets(uint productId, address[] memory wallets, bool status) public onlyOwner {
        require(products[productId].subscriptionTime > 0, "Product Not Found!");
        for (uint256 i = 0; i < wallets.length; i++) {
            products[productId].whitelisted[wallets[i]] = status;
        }
    }

    //Viewing Functions    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    //Viewing Functions    
    function productSponsorCosts(uint productId) public view returns (uint[] memory) {
        return (products[productId].toSponsors);
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function userProductDetails(address userAddress, uint productId) public view returns(uint, uint) {
        return (users[userAddress].subscriptions[productId].expiration,
                users[userAddress].subscriptions[productId].created);
    }

    function getContractBalance() public view returns (uint256) {
		return address(this).balance;
	}
	
    //Withdraw excessive airdrop funds from contract to owner wallet
    function withdrawContractBalance(address payable toAddress) external payable onlyOwner {
        if(!toAddress.send(address(this).balance)) {
            toAddress.transfer(address(this).balance);
        }
        return;
    }
    
}