/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

pragma solidity 0.5.10;

contract IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function burnFrom(address account, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract CryptoApesMarket {

    address owner;

    IERC20 public token;

    string public standard = 'FungiApes';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    string public baseURI;

    uint public nextApeIndexToAssign = 0;

    bool public allApesAssigned = false;
    uint public apesRemainingToAssign = 0;

    //mapping (address => uint) public addressToApeIndex;
    mapping (uint => address) public apeIndexToAddress;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    struct Offer {
        bool isForSale;
        uint apeIndex;
        address seller;
        uint minValue;          // in bnb
        address onlySellTo;     // specify to sell only to a specific person
    }

    struct Bid {
        bool hasBid;
        uint apeIndex;
        address bidder;
        uint value;
    }

    // A record of apes that are offered for sale at a specific minimum value, and perhaps to a specific person
    mapping (uint => Offer) public apesOfferedForSale;

    // A record of the highest ape bid
    mapping (uint => Bid) public apeBids;

    mapping (address => uint) public pendingWithdrawals;

    event Assign(address indexed to, uint256 apeIndex);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event ApeTransfer(address indexed from, address indexed to, uint256 apeIndex);
    event ApeOffered(uint indexed apeIndex, uint minValue, address indexed toAddress);
    event ApeBidEntered(uint indexed apeIndex, uint value, address indexed fromAddress);
    event ApeBidWithdrawn(uint indexed apeIndex, uint value, address indexed fromAddress);
    event ApeBought(uint indexed apeIndex, uint value, address indexed fromAddress, address indexed toAddress);
    event ApeNoLongerForSale(uint indexed apeIndex);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(address tokenAddr) payable public {
        //        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        owner = msg.sender;
        totalSupply = 10000;                        // Update total supply
        apesRemainingToAssign = totalSupply;
        name = "FungiApes";                                   // Set the name for display purposes
        symbol = "FA";                               // Set the symbol for display purposes
        decimals = 0;                                       // Amount of decimals for display purposes

        token = IERC20(tokenAddr);
    }

    function setBaseURI(string memory newBaseURI) public {
        require(msg.sender == owner);

        baseURI = newBaseURI;
    }

    function setInitialOwner(address to, uint apeIndex) public {
        if (msg.sender != owner) revert();
        if (allApesAssigned) revert();
        if (apeIndex >= 10000) revert();
        if (apeIndexToAddress[apeIndex] != to) {
            if (apeIndexToAddress[apeIndex] != address(0)) {
                balanceOf[apeIndexToAddress[apeIndex]]--;
            } else {
                apesRemainingToAssign--;
            }
            apeIndexToAddress[apeIndex] = to;
            balanceOf[to]++;
            emit Assign(to, apeIndex);
        }
    }

    function setInitialOwners(address[] memory addresses, uint[] memory indices) public {
        if (msg.sender != owner) revert();
        uint n = addresses.length;
        for (uint i = 0; i < n; i++) {
            setInitialOwner(addresses[i], indices[i]);
        }
    }

    function allInitialOwnersAssigned() public {
        if (msg.sender != owner) revert();
        allApesAssigned = true;
    }

    function getApe(uint apeIndex) public {
        require(msg.sender == address(token));

        if (!allApesAssigned) revert();
        if (apesRemainingToAssign == 0) revert();
        if (apeIndexToAddress[apeIndex] != address(0)) revert();
        if (apeIndex >= 10000) revert();

        address sender = tx.origin;

        apeIndexToAddress[apeIndex] = sender;
        balanceOf[sender]++;
        apesRemainingToAssign--;
        emit Assign(sender, apeIndex);
    }

    // Transfer ownership of a ape to another user without requiring payment
    function transferApe(address to, uint apeIndex) public {
        if (!allApesAssigned) revert();
        if (apeIndexToAddress[apeIndex] != msg.sender) revert();
        if (apeIndex >= 10000) revert();
        if (apesOfferedForSale[apeIndex].isForSale) {
            apeNoLongerForSale(apeIndex);
        }
        apeIndexToAddress[apeIndex] = to;
        balanceOf[msg.sender]--;
        balanceOf[to]++;
        emit Transfer(msg.sender, to, 1);
        emit ApeTransfer(msg.sender, to, apeIndex);
        // Check for the case where there is a bid from the new owner and refund it.
        // Any other bid can stay in place.
        Bid storage bid = apeBids[apeIndex];
        if (bid.bidder == to) {
            // Kill bid and refund value
            pendingWithdrawals[to] += bid.value;
            apeBids[apeIndex] = Bid(false, apeIndex, address(0), 0);
        }
    }

    function apeNoLongerForSale(uint apeIndex) public {
        if (!allApesAssigned) revert();
        if (apeIndexToAddress[apeIndex] != msg.sender) revert();
        if (apeIndex >= 10000) revert();
        apesOfferedForSale[apeIndex] = Offer(false, apeIndex, msg.sender, 0, address(0));
        emit ApeNoLongerForSale(apeIndex);
    }

    function offerApeForSale(uint apeIndex, uint minSalePriceInWei) public {
        if (!allApesAssigned) revert();
        if (apeIndexToAddress[apeIndex] != msg.sender) revert();
        if (apeIndex >= 10000) revert();
        apesOfferedForSale[apeIndex] = Offer(true, apeIndex, msg.sender, minSalePriceInWei, address(0));
        emit ApeOffered(apeIndex, minSalePriceInWei, address(0));
    }

    function offerApeForSaleToAddress(uint apeIndex, uint minSalePriceInWei, address toAddress) public {
        if (!allApesAssigned) revert();
        if (apeIndexToAddress[apeIndex] != msg.sender) revert();
        if (apeIndex >= 10000) revert();
        apesOfferedForSale[apeIndex] = Offer(true, apeIndex, msg.sender, minSalePriceInWei, toAddress);
        emit ApeOffered(apeIndex, minSalePriceInWei, toAddress);
    }

    function buyApe(uint apeIndex) public payable {
        if (!allApesAssigned) revert();
        Offer storage offer = apesOfferedForSale[apeIndex];
        if (apeIndex >= 10000) revert();
        if (!offer.isForSale) revert();                // ape not actually for sale
        if (offer.onlySellTo != address(0) && offer.onlySellTo != msg.sender) revert();  // ape not supposed to be sold to this user
        if (msg.value < offer.minValue) revert();      // Didn't send enough BNB
        if (offer.seller != apeIndexToAddress[apeIndex]) revert(); // Seller no longer owner of ape

        address seller = offer.seller;

        apeIndexToAddress[apeIndex] = msg.sender;
        balanceOf[seller]--;
        balanceOf[msg.sender]++;
        emit Transfer(seller, msg.sender, 1);

        apeNoLongerForSale(apeIndex);
        pendingWithdrawals[seller] += msg.value;
        emit ApeBought(apeIndex, msg.value, seller, msg.sender);

        // Check for the case where there is a bid from the new owner and refund it.
        // Any other bid can stay in place.
        Bid storage bid = apeBids[apeIndex];
        if (bid.bidder == msg.sender) {
            // Kill bid and refund value
            pendingWithdrawals[msg.sender] += bid.value;
            apeBids[apeIndex] = Bid(false, apeIndex, address(0), 0);
        }
    }

    function withdraw() public {
        if (!allApesAssigned) revert();
        uint amount = pendingWithdrawals[msg.sender];
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function enterBidForApe(uint apeIndex) public payable {
        if (apeIndex >= 10000) revert();
        if (!allApesAssigned) revert();
        if (apeIndexToAddress[apeIndex] == address(0)) revert();
        if (apeIndexToAddress[apeIndex] == msg.sender) revert();
        if (msg.value == 0) revert();
        Bid storage existing = apeBids[apeIndex];
        if (msg.value <= existing.value) revert();
        if (existing.value > 0) {
            // Refund the failing bid
            pendingWithdrawals[existing.bidder] += existing.value;
        }
        apeBids[apeIndex] = Bid(true, apeIndex, msg.sender, msg.value);
        emit ApeBidEntered(apeIndex, msg.value, msg.sender);
    }

    function acceptBidForApe(uint apeIndex, uint minPrice) public {
        if (apeIndex >= 10000) revert();
        if (!allApesAssigned) revert();
        if (apeIndexToAddress[apeIndex] != msg.sender) revert();
        address seller = msg.sender;
        Bid storage bid = apeBids[apeIndex];
        if (bid.value == 0) revert();
        if (bid.value < minPrice) revert();

        apeIndexToAddress[apeIndex] = bid.bidder;
        balanceOf[seller]--;
        balanceOf[bid.bidder]++;
        emit Transfer(seller, bid.bidder, 1);

        apesOfferedForSale[apeIndex] = Offer(false, apeIndex, bid.bidder, 0, address(0));
        uint amount = bid.value;
        apeBids[apeIndex] = Bid(false, apeIndex, address(0), 0);
        pendingWithdrawals[seller] += amount;
        emit ApeBought(apeIndex, bid.value, seller, bid.bidder);
    }

    function withdrawBidForApe(uint apeIndex) public {
        if (apeIndex >= 10000) revert();
        if (!allApesAssigned) revert();
        if (apeIndexToAddress[apeIndex] == address(0)) revert();
        if (apeIndexToAddress[apeIndex] == msg.sender) revert();
        Bid storage bid = apeBids[apeIndex];
        if (bid.bidder != msg.sender) revert();
        emit ApeBidWithdrawn(apeIndex, bid.value, msg.sender);
        uint amount = bid.value;
        apeBids[apeIndex] = Bid(false, apeIndex, address(0), 0);
        // Refund the bid money
        msg.sender.transfer(amount);
    }

    function toString(uint256 value) internal pure returns (string memory) {
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

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(apeIndexToAddress[tokenId] != address(0), "ERC721Metadata: URI query for nonexistent token");

        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, toString(tokenId))) : "";
    }
    
}